# Outline Docker 部署指南

## 快速开始

### 1. 配置环境变量

复制示例配置文件并编辑：
```bash
cp .env.example .env
```

### 2. 生成密钥

在 `.env` 文件中，你需要生成随机密钥：

**Windows PowerShell:**
```powershell
# 生成 SECRET_KEY
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})

# 生成 UTILS_SECRET
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})
```

**Linux/Mac:**
```bash
openssl rand -hex 32
```

### 3. 配置认证

Outline 需要配置 OAuth 认证。推荐使用 Google OAuth：

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 启用 "Google+ API"
4. 创建 OAuth 2.0 客户端 ID
   - 应用类型：Web 应用
   - 授权重定向 URI：`http://localhost:3000/auth/google.callback`
5. 将客户端 ID 和密钥填入 `.env` 文件

### 4. 启动服务

```bash
docker-compose up -d
```

### 5. 访问应用

打开浏览器访问：http://localhost:3000

## 常用命令

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看 Outline 日志
docker-compose logs -f outline

# 停止服务
docker-compose stop

# 停止并删除容器
docker-compose down

# 停止并删除容器和数据卷（会删除所有数据！）
docker-compose down -v
```

## 故障排查

### 检查服务状态
```bash
docker-compose ps
```

### 查看数据库连接
```bash
docker-compose exec postgres psql -U outline -d outline
```

### 重启服务
```bash
docker-compose restart outline
```

## 生产环境建议

1. **使用 HTTPS**：配置反向代理（如 Nginx）并启用 SSL
2. **修改端口**：不要暴露默认端口到公网
3. **备份数据**：定期备份 PostgreSQL 数据库
4. **使用强密码**：为所有密钥和密码使用强随机值
5. **配置域名**：修改 `.env` 中的 `URL` 为实际域名

## 数据备份

```bash
# 备份数据库
docker-compose exec postgres pg_dump -U outline outline > backup.sql

# 恢复数据库
docker-compose exec -T postgres psql -U outline outline < backup.sql
```

## 更新 Outline

```bash
docker-compose pull
docker-compose up -d
```
## Google
      - OIDC_AUTH_URI=https://accounts.google.com/o/oauth2/v2/auth
      - OIDC_TOKEN_URI=https://oauth2.googleapis.com/token
      - OIDC_USERINFO_URI=https://openidconnect.googleapis.com/v1/userinfo
      - OIDC_DISPLAY_NAME=Google

## GitHub
      - OIDC_AUTH_URI=https://github.com/login/oauth/authorize
      - OIDC_TOKEN_URI=https://github.com/login/oauth/access_token
      - OIDC_USERINFO_URI=https://api.github.com/user
      - OIDC_SCOPES=read:user user:email
      - OIDC_USERNAME_CLAIM=name
      - OIDC_DISPLAY_NAME=GitHub