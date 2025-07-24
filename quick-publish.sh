#!/bin/bash

# 快速发布脚本 - 一键发布到 Docker Hub

echo "🚀 Docker 镜像快速发布工具"
echo "================================"

# 获取用户输入
read -p "请输入你的 Docker Hub 用户名: " DOCKER_USERNAME
read -p "请输入版本号 (默认: latest): " VERSION
VERSION=${VERSION:-latest}

IMAGE_NAME="nginx-xray-proxy"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME"

echo ""
echo "📦 准备发布: $FULL_IMAGE_NAME:$VERSION"
echo ""

# 确认发布
read -p "确认发布? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 发布已取消"
    exit 1
fi

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 请先安装 Docker"
    exit 1
fi

# 登录 Docker Hub
echo "🔐 登录 Docker Hub..."
docker login

# 构建镜像
echo "🔨 构建镜像..."
docker build -t $FULL_IMAGE_NAME:$VERSION .

# 标记为 latest
if [ "$VERSION" != "latest" ]; then
    docker tag $FULL_IMAGE_NAME:$VERSION $FULL_IMAGE_NAME:latest
fi

# 推送镜像
echo "📤 推送镜像..."
docker push $FULL_IMAGE_NAME:$VERSION

if [ "$VERSION" != "latest" ]; then
    docker push $FULL_IMAGE_NAME:latest
fi

echo ""
echo "🎉 发布成功!"
echo ""
echo "📋 镜像信息:"
echo "   - $FULL_IMAGE_NAME:$VERSION"
if [ "$VERSION" != "latest" ]; then
    echo "   - $FULL_IMAGE_NAME:latest"
fi
echo ""
echo "🎯 使用命令:"
echo "docker run -d --name nginx-xray-proxy -p 8080:8080 $FULL_IMAGE_NAME:$VERSION"
echo ""
echo "🔗 查看镜像: https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"