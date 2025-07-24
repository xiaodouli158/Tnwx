# GitHub Codespaces 使用指南

## 🚀 快速开始

### 1. 创建 Codespace
1. 访问你的 GitHub 仓库
2. 点击绿色 "Code" 按钮
3. 选择 "Codespaces" 标签
4. 点击 "Create codespace on main"

### 2. 在 Codespace 中运行项目

```bash
# 1. 给脚本执行权限
chmod +x scripts/*.sh *.sh

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 文件设置你的域名

# 3. 启动服务
./scripts/start.sh
```

### 3. 访问服务

**方法一: 通过端口转发**
- 服务启动后，VS Code 会自动检测端口 8080
- 在 "PORTS" 面板中点击端口链接
- 访问类似 `https://xxx-8080.preview.app.github.dev` 的链接

**方法二: 手动配置端口**
- 在 "PORTS" 面板中点击 "Add Port"
- 输入 8080
- 设置为 Public 访问

### 4. 发布 Docker 镜像

```bash
# 在 Codespace 中发布镜像
./publish-xiaodouli158.sh latest
```

## 🔧 Codespace 配置

### 自动化配置 (.devcontainer)

创建 `.devcontainer/devcontainer.json`:

```json
{
  "name": "Nginx Xray Proxy",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "forwardPorts": [8080],
  "postCreateCommand": "chmod +x scripts/*.sh *.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode-remote.remote-containers",
        "GitHub.codespaces"
      ]
    }
  }
}
```

### 环境变量配置

在 Codespace 中设置环境变量:
```bash
# 设置 Docker Hub 凭据
export DOCKER_USERNAME=xiaodouli158
export DOCKER_PASSWORD=your_password

# 或使用 GitHub Secrets
gh secret set DOCKER_PASSWORD
```

## 🌐 远程访问方式

### 1. 浏览器访问
- 直接在 GitHub 上打开 codespace
- 完整的 VS Code 体验
- 无需本地安装

### 2. VS Code Desktop
```bash
# 安装 Codespaces 扩展后
# Ctrl+Shift+P -> "Codespaces: Connect to Codespace"
```

### 3. SSH 连接
```bash
# 使用 GitHub CLI
gh codespace ssh

# 或直接 SSH (需要配置)
ssh -i ~/.ssh/codespace_key user@codespace-name.github.dev
```

### 4. 移动设备访问
- 在手机/平板浏览器中访问 codespace
- 使用 GitHub Mobile App
- 通过 iPad 上的 VS Code

## 📱 移动端使用

### GitHub Mobile App
1. 下载 GitHub Mobile App
2. 找到你的仓库
3. 点击 "Code" -> "Codespaces"
4. 在移动浏览器中打开

### iPad/平板
- 使用 Safari 或 Chrome 访问 codespace
- 支持触摸操作和外接键盘
- 可以安装 VS Code for iPad (如果可用)

## 🔒 安全配置

### 1. 私有仓库访问
```bash
# 配置 GitHub token
gh auth login --scopes repo,codespace

# 克隆私有仓库
git clone https://github.com/username/private-repo.git
```

### 2. Docker Hub 认证
```bash
# 在 codespace 中登录 Docker Hub
docker login -u xiaodouli158

# 或使用环境变量
echo $DOCKER_PASSWORD | docker login -u xiaodouli158 --password-stdin
```

### 3. SSH 密钥管理
```bash
# 生成新的 SSH 密钥
ssh-keygen -t ed25519 -C "codespace@github.com"

# 添加到 GitHub
cat ~/.ssh/id_ed25519.pub
```

## 🚀 最佳实践

### 1. 预配置环境
- 使用 `.devcontainer` 配置自动化环境
- 预安装必要的工具和依赖
- 设置默认的环境变量

### 2. 端口管理
- 将常用端口设置为自动转发
- 使用有意义的端口标签
- 配置 HTTPS 访问

### 3. 资源优化
- 及时停止不用的 codespace
- 使用合适的机器类型
- 定期清理临时文件

### 4. 协作开发
- 共享 codespace 链接给团队成员
- 使用 Live Share 进行实时协作
- 配置统一的开发环境

## 🔧 故障排除

### 连接问题
```bash
# 检查网络连接
curl -I https://github.com

# 重启 codespace
gh codespace rebuild
```

### 端口访问问题
```bash
# 检查服务是否运行
ps aux | grep nginx
netstat -tlnp | grep 8080

# 手动添加端口转发
gh codespace ports forward 8080:8080
```

### 权限问题
```bash
# 修复脚本权限
chmod +x scripts/*.sh *.sh

# 检查 Docker 权限
docker info
sudo usermod -aG docker $USER
```