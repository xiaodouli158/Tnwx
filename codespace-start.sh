#!/bin/bash

# Codespace 专用启动脚本

set -e

echo "🚀 在 GitHub Codespace 中启动 Nginx + Xray 代理服务"
echo "=================================================="

# 检查是否在 Codespace 环境中
if [ -n "$CODESPACES" ]; then
    echo "✅ 检测到 Codespace 环境"
    DOMAIN="${CODESPACE_NAME}-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    echo "🌐 自动检测域名: $DOMAIN"
else
    echo "⚠️  非 Codespace 环境，使用默认配置"
    DOMAIN="localhost"
fi

# 创建环境变量文件
echo "📝 生成环境变量配置..."
cat > .env << EOF
DOMAIN=$DOMAIN
PORT=8080
UUID=de04add9-5c68-8bab-950c-08cd5320df18
VMESS_PATH=/api/stream/data
VLESS_PATH=/api/events/subscribe
LOG_LEVEL=warning
EOF

echo "📋 当前配置:"
echo "  - 域名: $DOMAIN"
echo "  - 端口: 8080"
echo "  - UUID: de04add9-5c68-8bab-950c-08cd5320df18"

# 给脚本执行权限
chmod +x scripts/*.sh

# 启动服务
echo "🚀 启动服务..."
./scripts/start.sh &

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
if curl -f -s http://localhost:8080/ > /dev/null; then
    echo "✅ 服务启动成功!"
    
    if [ -n "$CODESPACES" ]; then
        echo ""
        echo "🌐 访问链接:"
        echo "   https://$DOMAIN"
        echo ""
        echo "📋 连接信息:"
        if [ -f connections.txt ]; then
            cat connections.txt
        fi
    else
        echo "🌐 本地访问: http://localhost:8080"
    fi
else
    echo "❌ 服务启动失败"
    exit 1
fi

echo ""
echo "🎉 服务已在后台运行"
echo "📝 查看日志: tail -f logs/access.log"
echo "🛑 停止服务: ./scripts/stop.sh"