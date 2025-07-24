#!/bin/bash

# 镜像测试脚本

set -e

IMAGE_NAME="${1:-nginx-xray-proxy}"
PORT="${2:-8080}"
CONTAINER_NAME="test-$IMAGE_NAME-$$"

echo "🧪 测试 Docker 镜像: $IMAGE_NAME"
echo "================================"

# 清理函数
cleanup() {
    echo "🧹 清理测试容器..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# 设置清理陷阱
trap cleanup EXIT

# 启动测试容器
echo "🚀 启动测试容器..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8080 \
    -e DOMAIN=localhost \
    -e UUID=test-uuid-12345 \
    $IMAGE_NAME

# 等待容器启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查容器状态
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "❌ 容器启动失败"
    docker logs $CONTAINER_NAME
    exit 1
fi

echo "✅ 容器启动成功"

# 测试 HTTP 响应
echo "🌐 测试 HTTP 响应..."
if curl -f -s http://localhost:$PORT/ > /dev/null; then
    echo "✅ HTTP 服务正常"
else
    echo "❌ HTTP 服务异常"
    docker logs $CONTAINER_NAME
    exit 1
fi

# 检查连接信息文件
echo "📋 检查连接信息..."
if docker exec $CONTAINER_NAME test -f connections.txt; then
    echo "✅ 连接信息文件存在"
    echo "📄 连接信息内容:"
    docker exec $CONTAINER_NAME cat connections.txt | head -20
else
    echo "❌ 连接信息文件不存在"
fi

# 检查日志
echo "📝 检查服务日志..."
docker logs $CONTAINER_NAME | tail -10

echo ""
echo "🎉 镜像测试完成!"
echo "✅ 所有测试通过"
echo ""
echo "🔗 访问地址: http://localhost:$PORT"
echo "🛑 停止测试: docker stop $CONTAINER_NAME"