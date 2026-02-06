# 贡献指南

感谢你有兴趣为 SyncBoard 贡献代码！

## 🤝 如何贡献

### 报告 Bug

如果你发现了 Bug，请：

1. 检查 [Issues](https://github.com/yourusername/syncboard/issues) 是否已有类似问题
2. 如果没有，创建一个新的 Issue，包含：
   - 清晰的标题
   - 详细的步骤重现
   - 预期行为和实际行为
   - 环境信息（操作系统、浏览器版本等）
   - 相关的错误日志或截图

### 提交新功能

1. 先创建一个 Issue 讨论你的想法
2. 等待维护者反馈
3. 获得批准后开始开发

### 拉取请求（Pull Request）

#### 开发流程

1. **Fork 项目**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   ```

2. **克隆到本地**
   ```bash
   git clone https://github.com/your-username/syncboard.git
   cd syncboard
   ```

3. **创建特性分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **进行开发**
   - 遵循代码规范
   - 添加必要的测试
   - 更新相关文档

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add some feature"
   ```

   提交信息格式：
   - `feat:` 新功能
   - `fix:` Bug 修复
   - `docs:` 文档更新
   - `style:` 代码格式调整
   - `refactor:` 代码重构
   - `test:` 测试相关
   - `chore:` 构建/工具相关

6. **推送到 GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 访问 GitHub 上的 Fork 页面
   - 点击 "New Pull Request"
   - 填写 PR 描述模板
   - 等待代码审查

## 📝 代码规范

### Java 代码规范

- 遵循 Google Java Style Guide
- 使用有意义的变量和方法名
- 添加必要的注释
- 保持方法简短（不超过 50 行）

### JavaScript 代码规范

- 使用 ES6+ 语法
- 使用 const/let，避免 var
- 函数名使用驼峰命名
- 添加必要的注释

### 提交信息规范

```
<type>(<scope>): <subject>

<body>

<footer>
```

示例：

```
feat(task): add drag and drop functionality

Implement task drag and drop using HTML5 Drag and Drop API.
- Add drag event listeners
- Implement drop zone logic
- Add visual feedback during drag

Closes #123
```

## 🧪 测试

在提交 PR 前，确保：

- [ ] 代码能够编译通过
- [ ] 所有测试通过
- [ ] 添加了新功能的测试
- [ ] 手动测试了主要功能

## 📖 文档

如果你的更改影响用户使用，请更新相关文档：

- README.md
- API 文档
- 数据库结构文档

## 🎯 PR 审查标准

PR 会被检查以下几个方面：

1. **代码质量**：是否遵循代码规范
2. **功能完整性**：是否完整实现了功能
3. **测试覆盖**：是否有足够的测试
4. **文档更新**：是否更新了相关文档
5. **向后兼容**：是否保持了 API 的向后兼容性

## ❓ 需要帮助？

如果你在贡献过程中遇到问题：

1. 查看 [文档](README.md)
2. 搜索 [Issues](https://github.com/yourusername/syncboard/issues)
3. 提问时提供尽可能详细的信息

## 📄 许可

贡献的代码将使用 [MIT License](LICENSE) 开源。

---

再次感谢你的贡献！🎉
