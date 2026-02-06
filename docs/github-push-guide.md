# GitHub 推送指南

本指南将帮助你将 SyncBoard 项目推送到 GitHub。

---

## 步骤 1：准备 GitHub 账号

1. 访问 [GitHub](https://github.com/) 并登录
2. 如果没有账号，请先注册

---

## 步骤 2：创建 GitHub 仓库

1. 点击右上角的 `+` 号，选择 `New repository`
2. 填写仓库信息：
   - **Repository name**: `syncboard`
   - **Description**: `实时协作任务管理平台`
   - **Visibility**: 选择 `Public`（公开）或 `Private`（私有）
   - **不要**勾选 "Add a README file"（我们已经有了）
   - **不要**勾选 "Add .gitignore"（我们已经有��）
3. 点击 `Create repository`

---

## 步骤 3：配置 Git（首次使用）

```bash
# 设置用户名
git config --global user.name "Your Name"

# 设置邮箱（与 GitHub 账号一致）
git config --global user.email "your.email@example.com"
```

---

## 步骤 4：初始化 Git 仓库

```bash
# 进入项目目录
cd C:\projects\SyncBoard

# 初始化 Git 仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "feat: initial commit of SyncBoard v1.0.0

- 实时协作任务管理平台
- 支持 WebSocket 实时同步
- 任务拖拽排序（Fractional Indexing）
- 乐观锁并发控制
- 多实例部署支持
"
```

---

## 步骤 5：关联远程仓库

```bash
# 添加远程仓库（替换成你的用户名）
git remote add origin https://github.com/yourusername/syncboard.git

# 验证远程仓库
git remote -v
```

---

## 步骤 6：推送到 GitHub

```bash
# 推送主分支
git push -u origin main
```

如果遇到错误，可能是分支名问题：

```bash
# 查看当前分支
git branch

# 如果是 master 分支，改为 main
git branch -M main

# 再次推送
git push -u origin main
```

---

## 步骤 7：验证推送成功

1. 访问你的 GitHub 仓库页面
2. 应该能看到所有文件和代码
3. 检查 README.md 是否正确显示

---

## 常见问题

### Q1: 推送时提示认证失败？

**A**: 使用 GitHub Personal Access Token：

1. 访问 https://github.com/settings/tokens
2. 点击 `Generate new token` → `Generate new token (classic)`
3. 勾选 `repo` 权限
4. 点击 `Generate token`
5. 复制 token（只显示一次）
6. 推送时使用 token 作为密码

```bash
# 推送时会提示输入用户名和密码
# 用户名：你的 GitHub 用户名
# 密码：粘贴刚才复制的 token
```

### Q2: 提示文件太大无法推送？

**A**: 检查 `.gitignore` 文件，确保排除了不必要的文件：

```bash
# 查看仓库大小
du -sh .git

# 移除大文件
git rm --cached large-file.jar
git commit -m "Remove large file"
git push
```

### Q3: 如何更新 README.md 中的信息？

**A**:

1. 编辑 `README.md` 文件
2. 修改以下占位符：
   - `yourusername` → 你的 GitHub 用户名
   - `your.email@example.com` → 你的邮箱
   - `Your Name` → 你的名字
   - `yourwebsite.com` → 你的个人网站（可选）

3. 提交更改：
```bash
git add README.md
git commit -m "docs: update README with personal info"
git push
```

---

## 步骤 8：设置仓库亮点

### 1. 添加 Topics

在仓库页面点击 `Settings` → `Topics`，添加以下标签：

```
spring-boot, websocket, realtime, task-management, collaboration,
kanban, mysql, redis, java, maven, mybatis-plus
```

### 2. 设置仓库描述

在仓库页面点击 `⚙️` → 编辑仓库描述：

```
📊 实时协作任务管理平台 | 基于 Spring Boot + WebSocket + Redis
```

### 3. 添加 Website

在 About 部分添加你的部署地址：

```
http://60.205.140.97:8080/api/login.html
```

---

## 步骤 9：创建 Releases（可选）

1. 访问仓库的 `Releases` 页面
2. 点击 `Create a new release`
3. 填写信息：
   - **Tag version**: `v1.0.0`
   - **Release title**: `SyncBoard v1.0.0 - 首次正式发布`
   - **Description**: 复制 CHANGELOG.md 中的内容
4. 点击 `Publish release`

---

## 步骤 10：邀请协作者（可选）

如果想邀请其他人共同开发：

1. 点击 `Settings` → `Collaborators`
2. 点击 `Add people`
3. 输入对方的用户名
4. 设置权限（Write/Admin）
5. 发送邀请

---

## 分享你的项目

推送成功后，可以通过以下方式分享：

1. **直接链接**: https://github.com/yourusername/syncboard
2. **社交媒体**:
   - 微信、微博等平台分享
   - 技术社区发布（掘金、CSDN、知乎等）
3. **开源社区**:
   - 提交到 [HelloGitHub](https://hellogithub.com/)
   - 提交到 [GitHub Trending](https://github.com/trending)

---

## 后续维护

### 更新代码

```bash
# 修改代码后
git add .
git commit -m "描述你的更改"
git push
```

### 创建开发分支

```bash
# 创建新分支
git checkout -b feature/new-feature

# 开发完成后
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# 在 GitHub 上创建 Pull Request
```

### 同步上游代码（如果 Fork 了其他项目）

```bash
# 添加上游仓库
git remote add upstream https://github.com/original-owner/syncboard.git

# 拉取上游更新
git fetch upstream
git merge upstream/main

# 推送到你的仓库
git push origin main
```

---

## 检查清单

推送前请确认：

- [ ] README.md 中的占位符已替换
- [ ] LICENSE 文件中的版权信息已更新
- [ ] `.gitignore` 文件配置正确
- [ ] 敏感信息（密码、密钥等）已删除
- [ ] 数据库连接字符串中的密码已改为占位符
- [ ] 项目能够正常编译和运行

---

## 获取 Star 的技巧

1. **完善 README**: 添加截图、GIF 动图演示
2. **在线演示**: 提供可访问的 Demo 地址
3. **文档完善**: API 文档、部署指南、贡献指南
4. **提交社区**: 在技术社区分享你的项目
5. **持续维护**: 及时回复 Issue，持续更新功能

---

祝你推送成功！🎉

如有问题，请查看：
- [GitHub 官方文档](https://docs.github.com/)
- [Git 官方文档](https://git-scm.com/doc)
