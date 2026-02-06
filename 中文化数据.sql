-- 中文化脚本
-- 请在MySQL命令行或工具中执行

SET NAMES utf8mb4;
USE syncboard;

-- 更新列名
UPDATE sb_column SET name = '待办事项' WHERE id = 1;
UPDATE sb_column SET name = '进行中' WHERE id = 2;
UPDATE sb_column SET name = '已完成' WHERE id = 3;

-- 更新任务
UPDATE sb_task SET title = '设计数据库表', description = '完成MySQL数据库表结构设计' WHERE id = 2;
UPDATE sb_task SET title = '实现WebSocket', description = '配置WebSocket STOMP实时消息推送' WHERE id = 3;
UPDATE sb_task SET title = '开发环境配置', description = '开发环境配置完成' WHERE id = 4;
UPDATE sb_task SET title = '设计数据库', description = '完成MySQL数据库表设计' WHERE id = 1;

-- 更新看板名称
UPDATE sb_board SET name = '项目看板', description = 'SyncBoard项目管理看板' WHERE id = 1;

SELECT '更新完成！' AS message;
SELECT id, name FROM sb_column WHERE board_id = 1 ORDER BY position;
