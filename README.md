# Nginx + Xray 代理服务

🚀 轻量级的 Nginx + Xray 代理服务，支持 VMess 和 VLESS 协议，完全容器化部署。

## ✨ 特性

- 🐋 **Docker 支持** - 一键容器化部署
- 🔧 **环境变量配置** - 灵活的配置管理
- 🔒 **安全运行** - 非 root 用户运行
- 📊 **健康检查** - 内置服务监控
- 🎯 **轻量级** - 基于 Alpine Linux
- 🔄 **自动重启** - 服务异常自动恢复

## 🚀 快速开始

### Docker 部署 (推荐)

```bash
# 1. 使用 Docker Compose
docker-compose up -d

# 2. 或直接使用 Docker
docker run -d \
  --name nginx-xray-proxy \
  -p 8080:8080 \
  -e DOMAIN=your-domain.com \
  -e UUID=your-uuid-here \
  your-dockerhub-username/nginx-xray-proxy:latest
```

### GitHub Codespaces 部署 (推荐)

```bash
# 1. 在 GitHub 上创建 Codespace
# 2. 一键启动服务
chmod +x codespace-start.sh
./codespace-start.sh
```

### 本地部署

```bash
# 1. 配置环境变量
cp .env.example .env
# 编辑 .env 文件

# 2. 启动服务
chmod +x scripts/*.sh
./scripts/start.sh
```

## ⚙️ 配置说明

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DOMAIN` | `localhost` | 服务域名 |
| `PORT` | `8080` | 监听端口 |
| `UUID` | `de04add9-5c68-8bab-950c-08cd5320df18` | 客户端 UUID |
| `VMESS_PATH` | `/api/stream/data` | VMess WebSocket 路径 |
| `VLESS_PATH` | `/api/events/subscribe` | VLESS WebSocket 路径 |
| `LOG_LEVEL` | `warning` | 日志级别 |

### Docker Compose 示例

```yaml
version: '3.8'
services:
  nginx-xray-proxy:
    image: your-dockerhub-username/nginx-xray-proxy:latest
    ports:
      - "8080:8080"
    environment:
      - DOMAIN=your-domain.com
      - UUID=your-uuid-here
    restart: unless-stopped
```

## 📋 使用说明

### 获取连接信息

```bash
# 查看生成的连接信息
docker exec nginx-xray-proxy cat connections.txt

# 或通过 volume 挂载
docker run -v $(pwd)/connections:/app/connections your-image
```

### 查看日志

```bash
# 查看容器日志
docker logs nginx-xray-proxy

# 查看服务日志
docker exec nginx-xray-proxy tail -f logs/access.log
```

### 健康检查

```bash
# 检查服务状态
docker ps
curl http://localhost:8080/
```

## 🏗️ 构建和发布镜像

### 快速发布 (推荐)
```bash
# 一键发布到 Docker Hub
chmod +x quick-publish.sh
./quick-publish.sh
```

### 手动发布
```bash
# 1. 登录 Docker Hub
docker login

# 2. 构建镜像
docker build -t your-username/nginx-xray-proxy:latest .

# 3. 推送镜像
docker push your-username/nginx-xray-proxy:latest
```

### 使用发布脚本
```bash
# 发布指定版本
chmod +x publish.sh
./publish.sh your-username v1.0.0
```

详细发布指南请查看 [PUBLISH_GUIDE.md](PUBLISH_GUIDE.md)

## 📁 项目结构

```
├── config/              # 配置模板
├── scripts/             # 管理脚本
├── Nginx/               # Nginx 二进制文件
├── Xray/                # Xray 二进制文件
├── Dockerfile           # Docker 构建文件
├── docker-compose.yml   # Docker Compose 配置
└── .dockerignore        # Docker 忽略文件
```

## 🔒 安全说明

- 容器以非 root 用户运行
- 默认配置不使用 TLS (适合内网或反向代理后使用)
- 建议在生产环境中配置 HTTPS
- 定期更新 UUID 和路径

## 📝 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！