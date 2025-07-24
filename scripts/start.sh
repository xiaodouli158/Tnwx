#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 加载环境变量
source "$PROJECT_DIR/.env"

# 检查配置文件是否存在
if [ ! -f "$PROJECT_DIR/nginx.conf" ] || [ ! -f "$PROJECT_DIR/xray.json" ]; then
    echo "配置文件不存在，正在生成..."
    "$SCRIPT_DIR/setup.sh"
fi

cd "$PROJECT_DIR"

# 启动 Xray
echo "启动 Xray..."
./Xray/xray run -c xray.json &
XRAY_PID=$!

# 等待 Xray 启动
sleep 2

# 检查 Xray 是否启动成功
if ! kill -0 $XRAY_PID 2>/dev/null; then
    echo "Xray 启动失败"
    exit 1
fi

echo "Xray 启动成功 (PID: $XRAY_PID)"

# 生成连接信息
"$SCRIPT_DIR/generate-links.sh"

# 启动 Nginx
echo "启动 Nginx..."
./Nginx/nginx-static -c "$PROJECT_DIR/nginx.conf" -p "$PROJECT_DIR"

# 清理
kill $XRAY_PID 2>/dev/null || true