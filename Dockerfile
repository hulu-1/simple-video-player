# 使用官方 Node.js 镜像作为基础镜像
FROM node:16-alpine AS build

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json（如果有）
COPY package*.json ./

# 安装依赖
RUN npm install

# 安装 polyfill 包
RUN npm install crypto-browserify

# 复制项目的所有文件
COPY . .

# 在构建之前设置 polyfill
RUN echo "import { Buffer } from 'buffer'; globalThis.Buffer = Buffer;" > polyfill.js
RUN echo "import crypto from 'crypto-browserify'; globalThis.crypto = crypto;" >> polyfill.js
RUN echo "import './polyfill.js';" >> src/main.js # 确保在项目入口点导入 polyfill

# 构建项目
RUN npm run build

# 使用一个轻量级的 web 服务器来提供静态文件
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
