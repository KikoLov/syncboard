# 数据库初始化说明

## 方法一：使用 MySQL Workbench

1. 打开 MySQL Workbench
2. 连接到本地 MySQL 服务器
3. 点击 `File` -> `Open SQL Script`
4. 选择 `src/main/resources/sql/init.sql`
5. 点击执行按钮（闪电图标）

## 方法二：使用命令行

### Windows 命令提示符

```cmd
cd "C:\Program Files\MySQL\MySQL Server 8.0\bin"
mysql -u root -pEA7music666 < C:\Users\赵慧楠\SyncBoard\src\main\resources\sql\init.sql
```

### PowerShell

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -pEA7music666 < C:\Users\赵慧楠\SyncBoard\src\main\resources\sql\init.sql
```

## 方法三：让 Spring Boot 自动创建（测试用）

在 `application.yml` 中添加：

```yaml
spring:
  sql:
    init:
      mode: always
      schema-locations: classpath:sql/init.sql
```

然后启动应用即可自动创建数据库。

## 验证数据库

执行以下 SQL 查询验证：

```sql
USE syncboard;

-- 查看创建的表
SHOW TABLES;

-- 查看测试数据
SELECT * FROM sys_user;
SELECT * FROM sb_board;
SELECT * FROM sb_column;
SELECT * FROM sb_task;
```

## 如果遇到问题

1. 确保 MySQL 服务已启动
2. 检查用户名和密码是否正确
3. 确认端口 3306 未被占用
4. 查看错误日志
