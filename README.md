# Curio Gallery

个人图片画廊，基于 React + Vite + Tailwind CSS。

## 一键部署到境外 VPS

**注意**：本站包含成人向图片，请使用境外服务器部署，不要部署在中国大陆或香港主机上。

### 方式一：直接 curl 执行（推荐）

在境外 VPS 上以普通用户登录（例如 `oath`），用 `sudo` 执行：

```bash
curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/deploy.sh | sudo bash
```

默认监听 `80` 端口，访问 `http://<服务器IP>` 即可。

> 注意：必须用 `| sudo bash`，不能写 `sudo curl ... | bash`（后者只给 curl 提了权）。

或者先下载脚本再执行，更稳：

```bash
curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/deploy.sh -o deploy.sh
sudo bash deploy.sh
```

### 方式二：clone 后执行

```bash
git clone https://github.com/HwFee/curio-gallery.git
cd curio-gallery
sudo bash deploy.sh
```

### 使用自定义域名 + HTTPS

设置环境变量后执行脚本：

```bash
export DOMAIN=gallery.example.com
curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/deploy.sh | bash
```

Caddy 会自动申请并续期 Let's Encrypt 证书。

### 使用非 80 端口

```bash
export PORT=8080
curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/deploy.sh | bash
```

## 关于成人向图片

GitHub 禁止在仓库中托管色情内容，因此本仓库的源码**不包含**以下两张成人向图片：

- `public/gallery/fallen-feathers.jpg`
- `public/gallery/velvet-repose.png`
- 对应数据文件 `src/data/works/fallen-feathers.json`、`src/data/works/velvet-repose.json`

如果你想在自建服务器上展示完整画廊，请把上述文件手动上传到服务器的 `/var/www/curio-gallery/public/gallery/` 和 `/var/www/curio-gallery/src/data/works/`，然后在服务器上运行：

```bash
cd /var/www/curio-gallery
pnpm run build
systemctl restart caddy
```

## 本地开发

```bash
pnpm install
pnpm dev
```

```bash
pnpm run build
```
