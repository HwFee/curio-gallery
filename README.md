# Curio Gallery

个人图片画廊，基于 React + Vite + Tailwind CSS。

**注意**：本站包含成人向图片，请使用境外服务器部署，不要部署在中国大陆或香港主机上。

## 推荐部署方式：本地构建 + SCP 上传

境外服务器直接跑 `pnpm install` 容易卡，推荐本地构建完把 `dist` 传上去。

### 1. 服务器上安装 Caddy

```bash
ssh oath@20.196.152.244 "curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/setup-server.sh | sudo bash"
```

### 2. 本地构建并上传

在 `C:/Users/17445/Desktop/Curio/app` 目录执行：

```bash
bash deploy-local.sh
```

这会：
- 本地 `pnpm install && pnpm run build`
- 把 `dist` 上传到服务器 `/var/www/curio-gallery/dist`
- 重启 Caddy

本地所有图片（包括成人向）都会一起打包上传。

## 备用方式：服务器上直接构建

如果服务器网络好，也可以直接构建：

```bash
curl -fsSL https://raw.githubusercontent.com/HwFee/curio-gallery/main/deploy.sh | sudo bash
```

> 必须用 `| sudo bash`，不能写 `sudo curl ... | bash`。

## 本地开发

```bash
pnpm install
pnpm dev
```
