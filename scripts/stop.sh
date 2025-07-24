#!/bin/bash

echo "停止服务..."

# 停止 Nginx
pkill -f nginx-static || true

# 停止 Xray
pkill -f xray || true

echo "服务已停止"