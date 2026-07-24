#!/bin/bash
set -e

# 本地构建 + SCP 上传到服务器（处理 /var/www 权限问题）
# 用法：
#   bash deploy-local.sh

SERVER_IP="${SERVER_IP:-20.196.152.244}"
SERVER_USER="${SERVER_USER:-oath}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/curio-gallery}"
TMP_DIR="/tmp/curio-dist-upload"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "[1/3] 本地构建..."
pnpm install --frozen-lockfile
pnpm run build

echo "[2/3] 上传 dist 到服务器临时目录..."
ssh $SSH_OPTS "$SERVER_USER@$SERVER_IP" "rm -rf $TMP_DIR && mkdir -p $TMP_DIR"
scp $SSH_OPTS -r dist/* "$SERVER_USER@$SERVER_IP:$TMP_DIR/"

echo "[3/3] 移动到 /var/www 并重启 Caddy..."
ssh $SSH_OPTS "$SERVER_USER@$SERVER_IP" \
  "sudo rm -rf $REMOTE_DIR/dist && sudo mkdir -p $REMOTE_DIR && sudo mv $TMP_DIR $REMOTE_DIR/dist && sudo systemctl restart caddy"

echo "完成！"
echo "访问地址: http://$SERVER_IP 或 https://hwfee.me（DNS 生效后）"
