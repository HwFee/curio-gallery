#!/bin/bash
set -e

# Curio Gallery 一键部署脚本
# 在境外 VPS/虚拟机（Ubuntu/Debian）上以 root 身份运行：
#   curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/deploy.sh | bash
# 或先 clone 再执行：
#   git clone https://github.com/HwFee/curio-gallery.git
#   cd curio-gallery && sudo bash deploy.sh

REPO_URL="https://github.com/HwFee/curio-gallery.git"
INSTALL_DIR="/var/www/curio-gallery"
PORT="${PORT:-80}"
DOMAIN="${DOMAIN:-}"

if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 权限运行：sudo bash deploy.sh"
  exit 1
fi

log() { echo "[deploy] $*"; }

log "更新软件源..."
apt-get update -y

log "安装基础依赖..."
apt-get install -y curl gnupg ca-certificates git debian-keyring debian-archive-keyring apt-transport-https

log "安装 Node.js 24..."
if ! command -v node >/dev/null 2>&1 || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" != "24" ]; then
  curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
  apt-get install -y nodejs
fi
node -v

log "安装 pnpm..."
if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi
pnpm -v

log "安装 Caddy..."
if ! command -v caddy >/dev/null 2>&1; then
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
  apt-get update -y
  apt-get install -y caddy
fi
caddy version

log "拉取/更新项目代码..."
if [ -d "$INSTALL_DIR/.git" ]; then
  cd "$INSTALL_DIR"
  git fetch origin
  git reset --hard origin/main
else
  rm -rf "$INSTALL_DIR"
  git clone "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

log "安装项目依赖并构建..."
pnpm install --frozen-lockfile
pnpm run build

log "配置 Caddy..."
if [ -n "$DOMAIN" ]; then
  cat > /etc/caddy/Caddyfile <<EOF
$DOMAIN {
    root * $INSTALL_DIR/dist
    file_server
    encode gzip
    try_files {path} /index.html
}
EOF
else
  cat > /etc/caddy/Caddyfile <<EOF
:$PORT {
    root * $INSTALL_DIR/dist
    file_server
    encode gzip
    try_files {path} /index.html
}
EOF
fi

log "启动/重载 Caddy..."
systemctl enable caddy
systemctl restart caddy

log "部署完成！"
if [ -n "$DOMAIN" ]; then
  echo "访问地址: https://$DOMAIN"
else
  echo "访问地址: http://<服务器IP>:$PORT"
fi
