#!/bin/bash
set -e

# 本地构建 + SCP 上传到服务器
# 用法：
#   bash deploy-local.sh

SERVER_IP="${SERVER_IP:-20.196.152.244}"
SERVER_USER="${SERVER_USER:-oath}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/curio-gallery}"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "[1/3] 本地构建..."
pnpm install --frozen-lockfile
pnpm run build

echo "[2/3] 上传 dist 到服务器..."
if command -v sshpass >/dev/null 2>&1; then
  read -s -p "输入服务器密码: " PASS
  echo
  sshpass -p "$PASS" scp $SSH_OPTS -r dist "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"
  sshpass -p "$PASS" ssh $SSH_OPTS "$SERVER_USER@$SERVER_IP" \
    "sudo systemctl restart caddy"
else
  echo "未检测到 sshpass，将交互式输入密码..."
  scp $SSH_OPTS -r dist "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"
  ssh $SSH_OPTS "$SERVER_USER@$SERVER_IP" \
    "sudo systemctl restart caddy"
fi

echo "[3/3] 完成！"
echo "访问地址: http://$SERVER_IP 或 https://hwfee.me（DNS 生效后）"
