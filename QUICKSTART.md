# 快速入门指南

本指南将帮助您快速上手使用本项目。

## 1. 启动服务

```bash
./start-services.sh
```

## 2. 访问网页

打开浏览器，访问：

```
http://your-domain:8080
```

您将看到一个带有实时时间显示的网页。

## 3. 查看连接信息

连接信息保存在 `xray_connections.txt` 文件中：

```bash
cat xray_connections.txt
```

## 4. 查看访问日志

```bash
# 查看实时访问日志
tail -f Nginx/logs/default_access.log
```

## 5. 更新域名

如果需要更改域名，使用：

```bash
./update-domain.sh your-new-domain.com
```

然后重启服务：

```bash
./stop-services.sh
./start-services.sh
```

## 6. 停止服务

```bash
./stop-services.sh
```

## 7. 常见问题

如果遇到问题，请查看：

- 错误日志：`Nginx/logs/error.log` 和 `Xray/logs/error.log`
- 失败请求日志：`Nginx/logs/failed_requests.log`

更多详细信息，请参阅完整的 [README.md](README.md) 文档。
