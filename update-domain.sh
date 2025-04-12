#!/bin/bash

# 检查是否提供了域名参数
if [ -z "$1" ]; then
  echo "错误: 请提供新的域名"
  # 用法: ./update-domain.sh <新域名>
  echo "用法: $0 <新域名>"
  exit 1
fi

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 新域名
NEW_DOMAIN="$1"

echo "正在将域名更新为: $NEW_DOMAIN"

# 更新 Nginx 配置中的域名
echo "更新 Nginx 配置..."
sed -i "s/server_name .*/server_name $NEW_DOMAIN;/" "$SCRIPT_DIR/Nginx/nginx.conf"

# 更新 Xray 配置中的域名
echo "更新 Xray 配置..."
sed -i "s/\"serverName\": \"[^\"]*\"/\"serverName\": \"$NEW_DOMAIN\"/" "$SCRIPT_DIR/Xray/config.json"

# 更新启动脚本中的域名
echo "更新启动脚本..."
sed -i "s/SERVER_ADDRESS=\"[^\"]*\"/SERVER_ADDRESS=\"$NEW_DOMAIN\"/" "$SCRIPT_DIR/start-services.sh"

echo "域名更新完成!"
echo "请重新启动服务以应用更改:"
echo "  ./stop-services.sh"
echo "  ./start-services.sh"
