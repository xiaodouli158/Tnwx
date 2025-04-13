# 项目使用文档

## 项目概述

本项目是一个基于 Nginx 和 Xray 的服务，提供以下功能：

1. 网页服务：显示带有实时时间的简单网页
2. 代理服务：通过 WebSocket 提供 VMess 和 VLESS 协议的代理
3. 日志记录：详细记录所有访问请求，便于排查问题

## 目录结构

```
/
├── Nginx/                  # Nginx 相关文件
│   ├── html/               # 静态网页文件
│   ├── logs/               # Nginx 日志文件
│   ├── mime.types          # MIME 类型配置
│   ├── nginx-static        # Nginx 可执行文件
│   ├── nginx.conf          # Nginx 配置文件
│   └── start-nginx.sh      # Nginx 启动脚本
├── Xray/                   # Xray 相关文件
│   ├── certs/              # 证书文件
│   ├── config.json         # Xray 配置文件
│   ├── logs/               # Xray 日志文件
│   └── xray                # Xray 可执行文件
├── start-services.sh       # 服务启动脚本
├── stop-services.sh        # 服务停止脚本
├── update-domain.sh        # 域名更新脚本
└── xray_connections.txt    # 连接信息文件
```

## 配置说明

### Nginx 配置

Nginx 配置文件位于 `Nginx/nginx.conf`，主要配置包括：

1. 监听端口：8080
2. 服务器名称：当前配置为 `your-new-domain.com`
3. 日志格式：详细记录请求信息，包括请求时间、客户端 IP、请求方法、URL、状态码等
4. 日志文件：
   - 主访问日志：`logs/access.log`
   - 默认位置访问日志：`logs/default_access.log`
   - 失败请求日志：`logs/failed_requests.log`
   - 未知请求日志：`logs/unknown_requests.log`
   - VMess 代理日志：`logs/vmess_access.log` 和 `logs/vmess_error.log`
   - VLESS 代理日志：`logs/vless_access.log` 和 `logs/vless_error.log`

### Xray 配置

Xray 配置文件位于 `Xray/config.json`，主要配置包括：

1. 入站代理：
   - VMess 协议：监听 127.0.0.1:10000，路径为 `/api/stream/data`
   - VLESS 协议：监听 127.0.0.1:10001，路径为 `/api/events/subscribe`
2. 服务器名称：当前配置为 `nlvgkl-8080.csb.app`
3. 日志文件：
   - 访问日志：`logs/access.log`
   - 错误日志：`logs/error.log`

## 使用指南

### 启动服务

使用以下命令启动所有服务：

```bash
./start-services.sh
```

此命令将依次启动 Xray 和 Nginx 服务，并生成连接信息文件 `xray_connections.txt`。

### 停止服务

使用以下命令停止所有服务：

```bash
./stop-services.sh
```

### 更新域名

如果需要更改域名，使用以下命令：

```bash
./update-domain.sh your-new-domain.com
```

此命令将更新所有配置文件中的域名，包括 Nginx 配置、Xray 配置和启动脚本。

### 查看日志

可以使用以下命令查看各种日志：

```bash
# 查看 Nginx 主访问日志
tail -f Nginx/logs/access.log

# 查看默认位置访问日志
tail -f Nginx/logs/default_access.log

# 查看失败请求日志
tail -f Nginx/logs/failed_requests.log

# 查看 Xray 访问日志
tail -f Xray/logs/access.log

# 查看 Xray 错误日志
tail -f Xray/logs/error.log
```

### 连接信息

启动服务后，连接信息将自动生成在 `xray_connections.txt` 文件中，包括：

- VMess 连接链接
- VLESS 连接链接

## 部署指南

### 部署到新服务器

1. 将整个项目目录复制到新服务器上

2. 使用 `update-domain.sh` 脚本更新域名：
   ```bash
   ./update-domain.sh your-new-domain.com
   ```

3. 确保脚本具有执行权限：
   ```bash
   chmod +x *.sh
   chmod +x Nginx/start-nginx.sh
   chmod +x Xray/xray
   ```

4. 启动服务：
   ```bash
   ./start-services.sh
   ```

### 配置 HTTPS（可选）

如果需要配置 HTTPS，请按照以下步骤操作：

1. 准备 SSL 证书和私钥文件，放置在 `Xray/certs/` 目录下

2. 修改 Nginx 配置文件 `Nginx/nginx.conf`，取消注释 SSL 相关配置

3. 修改 Xray 配置文件 `Xray/config.json`，确保 TLS 配置正确

4. 重启服务：
   ```bash
   ./stop-services.sh
   ./start-services.sh
   ```

## 常见问题解答

### 1. 如何确认服务是否正常运行？

可以使用以下命令检查服务状态：

```bash
ps aux | grep -E 'nginx|xray'
```

如果看到 Nginx 和 Xray 进程，则表示服务正在运行。

也可以访问网页 `http://your-domain:8080` 查看是否显示带有时间的网页。

### 2. 如何查看访问记录？

所有对网页的访问记录都会被记录在 `Nginx/logs/default_access.log` 文件中。可以使用以下命令查看：

```bash
tail -f Nginx/logs/default_access.log
```

### 3. 如何排查连接问题？

如果遇到连接问题，可以按照以下步骤排查：

1. 检查服务是否正常运行
2. 检查域名是否正确解析到服务器 IP
3. 检查端口是否开放（8080）
4. 查看错误日志：
   ```bash
   tail -f Nginx/logs/error.log
   tail -f Xray/logs/error.log
   ```
5. 查看失败请求日志：
   ```bash
   tail -f Nginx/logs/failed_requests.log
   ```

### 4. 如何修改端口？

如果需要修改端口，请按照以下步骤操作：

1. 修改 Nginx 配置文件 `Nginx/nginx.conf` 中的 `listen` 指令
2. 如果使用 HTTPS，还需要修改 `start-services.sh` 中的 `SERVER_PORT` 变量
3. 重启服务

### 5. 如何更新 UUID？

如果需要更新 UUID，请按照以下步骤操作：

1. 生成新的 UUID
2. 修改 Xray 配置文件 `Xray/config.json` 中的 `id` 字段
3. 重启服务

## 安全建议

1. 定期更新 UUID 和密码
2. 使用 HTTPS 加密连接
3. 定期检查日志文件，查找异常访问
4. 限制 IP 访问范围
5. 使用防火墙保护服务器

## 更新日志

### 2025-04-12
- 添加了带有时间显示的网页
- 优化了日志记录功能
- 创建了域名更新脚本
- 完善了使用文档
