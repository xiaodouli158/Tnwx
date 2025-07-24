#!/bin/bash

# xiaodouli158 专用发布脚本
# Docker Hub 用户名: xiaodouli158

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DOCKER_USERNAME="xiaodouli158"
VERSION="${1:-latest}"
IMAGE_NAME="nginx-xray-proxy"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME"

echo -e "${BLUE}🚀 发布 Docker 镜像到 xiaodouli158 账户${NC}"
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

# 登录 Docker Hub
echo -e "${YELLOW}🔐 登录 Docker Hub (用户名: xiaodouli158)...${NC}"
if ! docker login -u xiaodouli158; then
    echo -e "${RED}❌ Docker Hub 登录失败${NC}"
    exit 1
fi

# 构建镜像
echo -e "${YELLOW}🔨 构建镜像...${NC}"
docker build -t $FULL_IMAGE_NAME:$VERSION .

# 如果版本不是 latest，也标记为 latest
if [ "$VERSION" != "latest" ]; then
    docker tag $FULL_IMAGE_NAME:$VERSION $FULL_IMAGE_NAME:latest
fi

echo -e "${GREEN}✅ 镜像构建完成${NC}"

# 推送镜像
echo -e "${YELLOW}📤 推送镜像到 Docker Hub...${NC}"
docker push $FULL_IMAGE_NAME:$VERSION

if [ "$VERSION" != "latest" ]; then
    docker push $FULL_IMAGE_NAME:latest
fi

echo -e "${GREEN}🎉 镜像发布成功！${NC}"
echo ""
echo -e "${BLUE}📋 镜像信息:${NC}"
echo -e "   - $FULL_IMAGE_NAME:$VERSION"
if [ "$VERSION" != "latest" ]; then
    echo -e "   - $FULL_IMAGE_NAME:latest"
fi
echo ""
echo -e "${BLUE}🎯 使用示例:${NC}"
echo -e "${GREEN}# 基本使用${NC}"
echo -e "${GREEN}docker run -d --name nginx-xray-proxy -p 8080:8080 \\${NC}"
echo -e "${GREEN}  $FULL_IMAGE_NAME:$VERSION${NC}"
echo ""
echo -e "${GREEN}# 自定义配置${NC}"
echo -e "${GREEN}docker run -d --name nginx-xray-proxy -p 8080:8080 \\${NC}"
echo -e "${GREEN}  -e DOMAIN=your-domain.com \\${NC}"
echo -e "${GREEN}  -e UUID=\$(uuidgen) \\${NC}"
echo -e "${GREEN}  $FULL_IMAGE_NAME:$VERSION${NC}"
echo ""
echo -e "${BLUE}🔗 Docker Hub 链接:${NC}"
echo -e "   https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
echo ""
echo -e "${BLUE}🧪 测试镜像:${NC}"
echo -e "   ./test-image.sh $FULL_IMAGE_NAME:$VERSION"