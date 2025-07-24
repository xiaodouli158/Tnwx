#!/bin/bash

# Docker 镜像发布脚本
# 使用方法: ./publish.sh [your-dockerhub-username] [version]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DOCKER_USERNAME="${1:-your-username}"
VERSION="${2:-latest}"
IMAGE_NAME="nginx-xray-proxy"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME"

echo -e "${BLUE}🚀 开始发布 Docker 镜像${NC}"
echo -e "${BLUE}📦 镜像名称: $FULL_IMAGE_NAME:$VERSION${NC}"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装，请先安装 Docker${NC}"
    exit 1
fi

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker 未运行，请启动 Docker${NC}"
    exit 1
fi

# 检查用户名
if [ "$DOCKER_USERNAME" = "your-username" ]; then
    echo -e "${YELLOW}⚠️  请提供你的 Docker Hub 用户名${NC}"
    echo "使用方法: ./publish.sh your-dockerhub-username [version]"
    exit 1
fi

# 登录 Docker Hub
echo -e "${YELLOW}🔐 登录 Docker Hub...${NC}"
if ! docker login; then
    echo -e "${RED}❌ Docker Hub 登录失败${NC}"
    exit 1
fi

# 构建镜像
echo -e "${YELLOW}🔨 构建镜像...${NC}"
docker build -t $FULL_IMAGE_NAME:$VERSION .
docker tag $FULL_IMAGE_NAME:$VERSION $FULL_IMAGE_NAME:latest

echo -e "${GREEN}✅ 镜像构建完成${NC}"

# 推送镜像
echo -e "${YELLOW}📤 推送镜像到 Docker Hub...${NC}"
docker push $FULL_IMAGE_NAME:$VERSION
docker push $FULL_IMAGE_NAME:latest

echo -e "${GREEN}🎉 镜像发布成功！${NC}"
echo ""
echo -e "${BLUE}📋 镜像信息:${NC}"
echo -e "   - $FULL_IMAGE_NAME:$VERSION"
echo -e "   - $FULL_IMAGE_NAME:latest"
echo ""
echo -e "${BLUE}🎯 使用示例:${NC}"
echo -e "${GREEN}docker run -d --name nginx-xray-proxy -p 8080:8080 \\${NC}"
echo -e "${GREEN}  -e DOMAIN=your-domain.com \\${NC}"
echo -e "${GREEN}  -e UUID=your-uuid-here \\${NC}"
echo -e "${GREEN}  $FULL_IMAGE_NAME:latest${NC}"
echo ""
echo -e "${BLUE}🔗 Docker Hub 链接:${NC}"
echo -e "   https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"