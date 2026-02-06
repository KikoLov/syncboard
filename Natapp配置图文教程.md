# 📖 Natapp 详细配置教程（手把手版）

## 🎯 你现在的状态

✅ 已注册Natapp账号
✅ 已购买免费隧道
❓ 不知道如何配置客户端

---

## 📋 配置前准备清单

在开始前，请准备好：
- [ ] 你的authtoken（在Natapp官网"我的隧道"页面可以找到）
- [ ] 电脑上已经安装了WinRAR或7-Zip解压软件
- [ ] 5-10分钟的空闲时间

---

## 🚀 开始配置（跟随我的步骤）

### 第1步：下载Natapp客户端

#### 方法1：从官网下载
1. 打开浏览器，访问：https://natapp.cn/
2. 点击顶部菜单 "下载中心"
3. 找到 "Windows 64位" 或 "Windows 32位"（根据你的系统选择）
4. 点击下载，文件名：`natapp_windows_amd64.zip`

#### 方法2：直接链接（推荐）
- 直接访问：https://natapp.cn/#download
- 点击 "Windows版" 下载

**小技巧**：如果你不确定系统版本，下载64位版（amd64），现在大多数电脑都是64位的。

---

### 第2步：解压文件

1. 打开下载文件夹（通常在 `C:\Users\你的用户名\Downloads\`）
2. 找到 `natapp_windows_amd64.zip` 文件
3. 右键点击 → 选择 "解压到" 或 "Extract to"
4. 选择解压位置：`C:\natapp\`

**如果目录不存在**：
- 打开 "此电脑" → C盘
- 右键 → 新建文件夹 → 命名为 `natapp`

**解压后确认**：
```
C:\natapp\
  └── natapp.exe        ← 主程序（这才是我们要用的）
```

⚠️ **注意**：如果解压后是 `natapp_windows_amd64.exe`，请重命名为 `natapp.exe`

---

### 第3步：获取authtoken

1. 访问：https://natapp.cn/
2. 点击右上角 "登录"
3. 登录后，点击顶部 "我的隧道"
4. 在隧道列表中找到你刚创建的隧道
5. 点击 "复制 authtoken" 或 "查看"

**authtoken是什么样子的？**
```
authtoken = 一串很长的字符，例如：
abc123def456ghi789jkl012mno345pqr678
```

**复制这个authtoken，等下要用到！**

---

### 第4步：创建配置文件（重要！）

有两种方法：

#### 方法A：使用我创建的脚本（最简单）✅
1. 双击运行 `Natapp详细配置.bat`
2. 按照提示粘贴你的authtoken
3. 自动创建配置文件

#### 方法B：手动创建
1. 打开 `C:\natapp\` 文件夹
2. 右键 → 新建 → 文本文档
3. 命名为 `config.ini`（注意后缀是.ini，不是.txt）
4. 右键点击 `config.ini` → 打开方式 → 记事本
5. 粘贴以下内容：

```ini
[default]
authtoken=你的authtoken粘贴在这里
clienttoken=
log=none
loglevel=ERROR
```

6. 保存并关闭

**示例**（假设你的authtoken是 abc123）：
```ini
[default]
authtoken=abc123def456ghi789
clienttoken=
log=none
loglevel=ERROR
```

---

### 第5步：测试Natapp

#### 启动Natapp

**方法1**：双击运行 `C:\natapp\natapp.exe`
**方法2**：在命令行中运行：
```bash
cd C:\natapp
natapp
```

#### 你会看到这样的窗口：

```
   ___  _           _
  / _ \| |__   ___ | |__  _   _
 | | | | '_ \ / _ \| '_ \| | | |
 | |_| | |_) | (_) | |_) | |_| |
  \___/|_.__/ \___/|_.__/ \__, |
                     |___/
                    v3.0.2

Tunnel Status Online                online_url=http://abc123.natapp.cn
version                              3.0.2
...

Forwarding                          http://abc123.natapp.cn
                                    -> http://127.0.0.1:8080

Web Interface                       http://127.0.0.1:4040
```

#### 关键信息（找到这行）：
```
online_url=http://你的地址.natapp.cn
```

**复制这个地址！这就是你的外网访问地址！**

---

### 第6步：测试外网访问

1. 确保SyncBoard服务正在运行
   - 双击 `启动服务.bat`
   - 看到 "SyncBoard 启动成功！"

2. 打开浏览器，访问：
   ```
   http://你的地址.natapp.cn/api/login.html
   ```

3. 如果看到登录页面，说明配置成功！✅

---

## 🎉 分享给朋友

### 准备分享的地址

假设你的Natapp地址是 `http://abc123.natapp.cn`，那么分享给朋友的地址是：

📝 **注册页面**：
```
http://abc123.natapp.cn/api/register.html
```

🔐 **登录页面**：
```
http://abc123.natapp.cn/api/login.html
```

📊 **主应用页面**：
```
http://abc123.natapp.cn/api/index.html
```

### 如何分享

1. **微信/QQ**：直接复制地址发送
2. **生成二维码**：使用免费二维码生成器
3. **短链接**：使用新浪短链等服务缩短

---

## ⚙️ 今后每次使用

### 启动流程

```
第1步：启动SyncBoard服务
   ↓
   双击 "启动服务.bat"
   等待 "SyncBoard 启动成功！"

第2步：启动Natapp内网穿透
   ↓
   双击 "C:\natapp\natapp.exe"
   或双击 "启动内网穿透-Natapp.bat"
   等待 "Tunnel Status Online"

第3步：获取外网地址
   ↓
   在Natapp窗口找到 online_url
   复制这个地址

第4步：分享给朋友
   ↓
   发送地址给朋友使用
```

### 重要提醒

⚠️ **两个窗口都要保持运行**：
- SyncBoard服务窗口
- Natapp窗口

❌ **不要关闭任何一个窗口，否则朋友无法访问！**

---

## 🔧 常见问题

### Q1: 启动后显示 "Tunnel Status Offline"

**原因**：
- authtoken配置错误
- 网络连接问题
- 隧道已过期

**解决方法**：
1. 检查 `C:\natapp\config.ini` 中的authtoken是否正确
2. 重新从官网复制authtoken
3. 访问 https://natapp.cn/ 检查隧道状态

---

### Q2: 朋友访问显示 "无法连接"

**检查清单**：
- [ ] SyncBoard服务是否运行？
- [ ] Natapp是否显示 "Online"？
- [ ] 朋友的地址是否正确？
- [ ] 你的电脑网络是否正常？

**解决方法**：
1. 本地测试：http://localhost:8080/api/login.html
2. 外网测试：用手机浏览器访问你的natapp地址
3. 如果本地可以但外网不行，重启Natapp

---

### Q3: 地址变了怎么办？

**原因**：
- 免费版重启后地址会变化
- 这是正常现象

**解决方法**：
1. 每次启动后重新复制地址
2. 或购买付费版（固定域名）
3. 或使用花生壳的固定域名服务

---

### Q4: 显示端口占用

**错误**：`Error: listen tcp :8080: bind: address already in use`

**原因**：端口8080已被占用

**解决方法**：
```bash
双击运行 "停止服务.bat"
然后重新启动
```

---

### Q5: Natapp窗口一闪而过

**原因**：配置文件错误或authtoken无效

**解决方法**：
1. 删除 `C:\natapp\config.ini`
2. 重新创建配置文件
3. 确保authtoken正确

---

## 📞 需要帮助？

### 官方帮助
- Natapp官网：https://natapp.cn/
- Natapp文档：https://natapp.cn/#doc
- 在线客服：官网右下角

### 常用命令

```bash
# 查看版本
natapp -v

# 查看帮助
natapp -h

# 指定配置文件
natapp -config=C:\natapp\config.ini
```

---

## ✅ 配置检查清单

配置完成后，检查以下项目：

- [ ] Natapp客户端已解压到 `C:\natapp\`
- [ ] `config.ini` 文件已创建
- [ ] authtoken已正确配置
- [ ] 双击 `natapp.exe` 能正常运行
- [ ] 窗口显示 "Tunnel Status Online"
- [ ] 本地浏览器能访问 http://localhost:8080/api
- [ ] 外网浏览器能访问 http://你的地址.natapp.cn/api
- [ ] 朋友能够注册登录

**全部打勾说明配置成功！** 🎉

---

## 🎯 快速参考卡

```
┌─────────────────────────────────────┐
│  Natapp快速参考卡                   │
├─────────────────────────────────────┤
│  客户端位置：C:\natapp\natapp.exe    │
│  配置文件：C:\natapp\config.ini     │
│  启动方式：双击natapp.exe           │
│  停止方式：关闭natapp窗口           │
├─────────────────────────────────────┤
│  外网地址格式：                     │
│  http://xxxx.natapp.cn              │
├─────────────────────────────────────┤
│  访问地址：                         │
│  注册：/api/register.html           │
│  登录：/api/login.html              │
│  主页：/api/index.html              │
└─────────────────────────────────────┘
```

---

**祝使用愉快！如有问题请随时查看此教程** 📖
