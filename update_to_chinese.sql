-- SyncBoard 中文化更新脚本
-- 将看板列名和任务内容从英文改为中文

USE syncboard;

-- 1. 更新列名（Column names）
UPDATE sb_column SET name = '待办' WHERE id = 1 AND board_id = 1;
UPDATE sb_column SET name = '��行中' WHERE id = 2 AND board_id = 1;
UPDATE sb_column SET name = '已完成' WHERE id = 3 AND board_id = 1;

-- 2. 更新任务内容（Task content）
-- 待办列的任务
UPDATE sb_task
SET title = '设计数据库',
    description = '完成MySQL数据库表结构设计'
WHERE id = 1;

UPDATE sb_task
SET title = '搭建Spring Boot',
    description = '初始化Spring Boot项目并配置依赖'
WHERE id = 2;

-- 进行中列的任务
UPDATE sb_task
SET title = '实现WebSocket',
    description = '配置WebSocket STOMP实现实时消息推送'
WHERE id = 3;

-- 已完成列的任务
UPDATE sb_task
SET title = '环境搭建',
    description = '开发环境配置完成'
WHERE id = 4;

-- 3. 更新看板名称
UPDATE sb_board
SET name = '项目看板',
    description = 'SyncBoard项目管理'
WHERE id = 1;

-- 验证更新结果
SELECT '列名更新结果：' AS '==';
SELECT id, name, position FROM sb_column WHERE board_id = 1 ORDER BY position;

SELECT '任务更新结果：' AS '==';
SELECT id, column_id, title, description FROM sb_task WHERE board_id = 1 ORDER BY column_id, sort_order;
