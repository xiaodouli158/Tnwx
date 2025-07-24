FROM alpine:latest

LABEL maintainer="Your Name <your.email@example.com>" \
      description="Nginx + Xray Proxy Service" \
      version="1.0.0"

# 安装必要工具
RUN apk add --no-cache bash gettext coreutils curl

# 创建非 root 用户
RUN addgroup -g 1000 appuser && \
    adduser -D -s /bin/bash -u 1000 -G appuser appuser

# 创建工作目录
WORKDIR /app

# 复制文件
COPY --chown=appuser:appuser Nginx/ ./Nginx/
COPY --chown=appuser:appuser Xray/ ./Xray/
COPY --chown=appuser:appuser config/ ./config/
COPY --chown=appuser:appuser scripts/ ./scripts/
COPY --chown=appuser:appuser docker-entrypoint.sh ./

# 设置权限
RUN chmod +x scripts/*.sh Nginx/nginx-static Xray/xray docker-entrypoint.sh

# 创建目录
RUN mkdir -p logs html && \
    chown -R appuser:appuser /app

# 切换到非 root 用户
USER appuser

# 环境变量
ENV DOMAIN=localhost \
    PORT=8080 \
    UUID=de04add9-5c68-8bab-950c-08cd5320df18 \
    VMESS_PATH=/api/stream/data \
    VLESS_PATH=/api/events/subscribe \
    LOG_LEVEL=warn

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/ || exit 1

# 启动脚本
ENTRYPOINT ["./docker-entrypoint.sh"]