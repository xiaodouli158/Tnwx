# Docker 镜像发布指南

## 📋 发布前准备

### 1. 注册 Docker Hub 账号
- 访问 [Docker Hub](https://hub.docker.com/)
- 注册账号并记住用户名

### 2. 安装 Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io

# CentOS/RHEL
sudo yum install docker

# macOS
brew install docker

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker
```

### 3. 验证 Docker 安装
```bash
docker --version
docker info
```

## 🚀 发布步骤

### 方法一: 使用发布脚本 (推荐)

1. **给脚本执行权限**
   ```bash
   chmod +x publish.sh
   ```

2. **运行发布脚本**
   ```bash
   # 发布 latest 版本
   ./publish.sh your-dockerhub-username
   
   # 发布指定版本
   ./publish.sh your-dockerhub-username v1.0.0
   ```

3. **输入 Docker Hub 密码**
   - 脚本会提示登录 Docker Hub
   - 输入你的用户名和密码

### 方法二: 手动发布

1. **登录 Docker Hub**
   ```bash
   docker login
   ```

2. **构建镜像**
   ```bash
   docker build -t your-username/nginx-xray-proxy:latest .
   ```

3. **推送镜像**
   ```bash
   docker push your-username/nginx-xray-proxy:latest
   ```

## 🔧 多架构构建 (可选)

如果要支持多种 CPU 架构 (AMD64, ARM64):

1. **创建 buildx builder**
   ```bash
   docker buildx create --name multiarch --use
   docker buildx inspect --bootstrap
   ```

2. **构建并推送多架构镜像**
   ```bash
   docker buildx build \
     --platform linux/amd64,linux/arm64 \
     --tag your-username/nginx-xray-proxy:latest \
     --push .
   ```

## 📦 发布后验证

### 1. 检查镜像是否成功上传
- 访问 `https://hub.docker.com/r/your-username/nginx-xray-proxy`
- 确认镜像存在且信息正确

### 2. 测试拉取和运行
```bash
# 拉取镜像
docker pull your-username/nginx-xray-proxy:latest

# 运行测试
docker run -d --name test-proxy -p 8080:8080 \
  -e DOMAIN=localhost \
  your-username/nginx-xray-proxy:latest

# 检查运行状态
docker ps
curl http://localhost:8080

# 清理测试容器
docker stop test-proxy
docker rm test-proxy
```

## 🔄 自动化发布 (GitHub Actions)

项目已包含 GitHub Actions 配置，推送代码时自动构建发布:

1. **设置 GitHub Secrets**
   - 进入 GitHub 仓库 Settings > Secrets and variables > Actions
   - 添加以下 secrets:
     - `DOCKER_USERNAME`: 你的 Docker Hub 用户名
     - `DOCKER_PASSWORD`: 你的 Docker Hub 密码

2. **推送代码触发构建**
   ```bash
   git add .
   git commit -m "feat: ready for release"
   git push origin main
   ```

3. **创建版本标签**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## 📝 发布清单

- [ ] Docker Hub 账号已注册
- [ ] Docker 已安装并运行
- [ ] 项目代码已完成
- [ ] 已测试本地构建
- [ ] 已设置正确的镜像标签
- [ ] 已登录 Docker Hub
- [ ] 镜像已成功推送
- [ ] 已验证镜像可正常拉取运行
- [ ] 已更新 README 中的镜像名称

## 🎯 使用示例

发布成功后，用户可以这样使用你的镜像:

```bash
# 基本使用
docker run -d --name nginx-xray-proxy -p 8080:8080 \
  your-username/nginx-xray-proxy:latest

# 自定义配置
docker run -d --name nginx-xray-proxy -p 8080:8080 \
  -e DOMAIN=your-domain.com \
  -e UUID=your-custom-uuid \
  -e VMESS_PATH=/custom/vmess/path \
  your-username/nginx-xray-proxy:latest

# 使用 Docker Compose
# 修改 docker-compose.yml 中的镜像名称后运行:
docker-compose up -d
```

## 🔍 故障排除

### 构建失败
- 检查 Dockerfile 语法
- 确保所有必需文件存在
- 检查文件权限

### 推送失败
- 确认已登录 Docker Hub
- 检查网络连接
- 验证镜像名称格式正确

### 运行失败
- 检查端口是否被占用
- 查看容器日志: `docker logs container-name`
- 验证环境变量设置