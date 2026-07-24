#!/bin/bash
set -e

# 服务器端只装 Caddy 和配置，不上传/构建代码
# 在服务器上以 sudo 运行：
#   curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/setup-server.sh | sudo bash

DOMAIN="${DOMAIN:-hwfee.me}"
INSTALL_DIR="${INSTALL_DIR:-/var/www/curio-gallery}"
PORT="${PORT:-80}"

if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 权限运行：sudo bash setup-server.sh"
  exit 1
fi

log() { echo "[setup] $*"; }

log "更新软件源..."
apt-get update -y --fix-missing

log "安装基础依赖..."
apt-get install -y --fix-missing curl gnupg ca-certificates debian-keyring debian-archive-keyring apt-transport-https

log "安装 Caddy..."
if ! command -v caddy >/dev/null 2>&1; then
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
  apt-get update -y --fix-missing
  apt-get install -y --fix-missing caddy
fi
caddy version

log "创建站点目录..."
mkdir -p "$INSTALL_DIR/dist"

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

log "启动 Caddy..."
systemctl enable caddy
systemctl restart caddy

log "服务器准备完成！"
if [ -n "$DOMAIN" ]; then
  echo "请在本地运行 deploy-local.sh 上传 dist，然后访问 https://$DOMAIN"
else
  echo "请在本地运行 deploy-local.sh 上传 dist，然后访问 http://<服务器IP>:$PORT"
fi
