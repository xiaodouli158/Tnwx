#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 加载环境变量
source "$PROJECT_DIR/.env"

echo "生成连接信息..."

# VMess 配置 (无 TLS)
VMESS_JSON="{\"v\":\"2\",\"ps\":\"VMess\",\"add\":\"$DOMAIN\",\"port\":\"$PORT\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$DOMAIN\",\"path\":\"$VMESS_PATH\",\"tls\":\"\",\"sni\":\"\"}"
VMESS_LINK="vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"

# VLESS 配置 (无 TLS)
VLESS_LINK="vless://$UUID@$DOMAIN:$PORT?encryption=none&security=none&type=ws&host=$DOMAIN&path=$(echo -n "$VLESS_PATH" | sed 's/\//%2F/g')#VLESS"

# 保存到文件
cat > "$PROJECT_DIR/connections.txt" << EOF
# 连接信息 - $(date)

## VMess
$VMESS_LINK

## VLESS  
$VLESS_LINK

## 配置信息
域名: $DOMAIN
端口: $PORT
UUID: $UUID
VMess 路径: $VMESS_PATH
VLESS 路径: $VLESS_PATH
EOF

echo "连接信息已保存到 connections.txt"