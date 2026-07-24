#!/bin/bash
set -e

# 把本地成人向图片通过 SCP 推送到服务器，并重新构建
# 用法：
#   bash push-mature.sh
# 或指定用户/IP：
#   SERVER_USER=oath SERVER_IP=20.196.152.244 bash push-mature.sh

SERVER_IP="${SERVER_IP:-20.196.152.244}"
SERVER_USER="${SERVER_USER:-oath}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/curio-gallery}"
TMP_DIR="/tmp/curio-mature-upload"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "推送成人向图片到 $SERVER_USER@$SERVER_IP:$REMOTE_DIR"

echo "[1/2] 上传图片和 JSON 到临时目录..."
ssh $SSH_OPTS "$SERVER_USER@$SERVER_IP" "rm -rf $TMP_DIR && mkdir -p $TMP_DIR/gallery $TMP_DIR/works"

scp $SSH_OPTS \
  public/gallery/fallen-feathers.jpg \
  public/gallery/velvet-repose.png \
  "$SERVER_USER@$SERVER_IP:$TMP_DIR/gallery/"

scp $SSH_OPTS \
  src/data/works/fallen-feathers.json \
  src/data/works/velvet-repose.json \
  "$SERVER_USER@$SERVER_IP:$TMP_DIR/works/"

echo "[2/2] 移动到站点目录并重新构建..."
ssh $SSH_OPTS "$SERVER_USER@$SERVER_IP" \
  "sudo cp $TMP_DIR/gallery/* $REMOTE_DIR/public/gallery/ && sudo cp $TMP_DIR/works/* $REMOTE_DIR/src/data/works/ && cd $REMOTE_DIR && pnpm run build && sudo systemctl restart caddy"

echo "完成！成人向图片已上线。"
