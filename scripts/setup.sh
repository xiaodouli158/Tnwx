#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 加载环境变量
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
else
    echo "错误: 未找到 .env 文件，请先复制 .env.example 并配置"
    exit 1
fi

# 创建必要目录
mkdir -p "$PROJECT_DIR/logs"
mkdir -p "$PROJECT_DIR/html"

# 生成配置文件
echo "生成 Nginx 配置..."
envsubst < "$PROJECT_DIR/config/nginx.conf.template" > "$PROJECT_DIR/nginx.conf"

echo "生成 Xray 配置..."
envsubst < "$PROJECT_DIR/config/xray.json.template" > "$PROJECT_DIR/xray.json"

# 生成简单的 HTML 页面
cat > "$PROJECT_DIR/html/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Service Status</title>
    <meta charset="utf-8">
</head>
<body>
    <h1>服务运行中</h1>
    <p>当前时间: <span id="time"></span></p>
    <script>
        function updateTime() {
            document.getElementById('time').textContent = new Date().toLocaleString();
        }
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
EOF

echo "配置生成完成!"