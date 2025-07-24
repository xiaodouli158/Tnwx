#!/bin/bash

set -e

# 生成 .env 文件
echo "🔧 生成配置文件..."
cat > .env << EOF
DOMAIN=${DOMAIN:-localhost}
PORT=${PORT:-8080}
UUID=${UUID:-de04add9-5c68-8bab-950c-08cd5320df18}
VMESS_PATH=${VMESS_PATH:-/api/stream/data}
VLESS_PATH=${VLESS_PATH:-/api/events/subscribe}
LOG_LEVEL=${LOG_LEVEL:-warn}
EOF

echo "📋 当前配置:"
echo "  - 域名: $DOMAIN"
echo "  - 端口: $PORT"
echo "  - UUID: $UUID"
echo "  - VMess 路径: $VMESS_PATH"
echo "  - VLESS 路径: $VLESS_PATH"

# 生成配置文件
echo "⚙️ 生成服务配置..."
./scripts/setup.sh

# 启动服务
echo "🚀 启动服务..."
exec ./scripts/start.sh