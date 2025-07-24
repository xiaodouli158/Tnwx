#!/bin/bash

# Docker 镜像构建和发布脚本

set -e

# 配置
IMAGE_NAME="nginx-xray-proxy"
DOCKER_USERNAME="${DOCKER_USERNAME:-your-username}"
VERSION="${VERSION:-latest}"
PLATFORMS="linux/amd64,linux/arm64"

echo "🚀 开始构建 Docker 镜像..."

# 检查 Docker buildx
if ! docker buildx version >/dev/null 2>&1; then
    echo "❌ Docker buildx 不可用，请升级 Docker"
    exit 1
fi

# 创建 buildx builder (如果不存在)
if ! docker buildx ls | grep -q multiarch; then
    echo "📦 创建多架构构建器..."
    docker buildx create --name multiarch --use
    docker buildx inspect --bootstrap
fi

# 构建镜像
echo "🔨 构建多架构镜像..."
docker buildx build \
    --platform $PLATFORMS \
    --tag $DOCKER_USERNAME/$IMAGE_NAME:$VERSION \
    --tag $DOCKER_USERNAME/$IMAGE_NAME:latest \
    --push \
    .

echo "✅ 镜像构建完成!"
echo "📋 镜像信息:"
echo "   - $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
echo "   - $DOCKER_USERNAME/$IMAGE_NAME:latest"
echo "   - 支持架构: $PLATFORMS"

# 生成使用示例
echo ""
echo "🎯 使用示例:"
echo "docker run -d --name nginx-xray-proxy -p 8080:8080 -e DOMAIN=your-domain.com $DOCKER_USERNAME/$IMAGE_NAME:latest"