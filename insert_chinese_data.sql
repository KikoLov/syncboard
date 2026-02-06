-- SyncBoard 中文化数据脚本
-- 字符集：UTF-8
-- 请使用支持UTF-8的编辑器查看和执行

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

USE syncboard;

-- 清空现有数据
DELETE FROM sb_task WHERE board_id = 1;
DELETE FROM sb_column WHERE board_id = 1;
DELETE FROM sb_board WHERE id = 1;

-- 重新插入看板（中文）
INSERT INTO sb_board (id, name, description, owner_id, is_public, background_color, sort_order)
VALUES (1, '项目看板', 'SyncBoard项目管理看板', 1, 0, '#0079BF', 0);

-- 重新插入列（中文）
INSERT INTO sb_column (board_id, name, color, sort_order, position) VALUES
(1, '待办事项', '#F4F5F7', 0.0000000001, 0),
(1, '进行中', '#EBECF0', 0.0000000002, 1),
(1, '已完成', '#DCDFE4', 0.0000000003, 2);

-- 重新插入任务（中文）
INSERT INTO sb_task (board_id, column_id, title, description, assignee_id, sort_order, priority, created_by) VALUES
(1, 1, '设计数据库表', '完成MySQL数据库表结构设计', 2, 0.0000000001, 3, 1),
(1, 1, '搭建Spring Boot', '初始化Spring Boot项目并配置依赖', 1, 0.0000000002, 3, 1),
(1, 2, '实现WebSocket', '配置WebSocket STOMP实现实时消息推送', 1, 0.0000000001, 2, 1),
(1, 3, '开发环境配置', '开发环境配置完成', 2, 0.0000000001, 1, 2);

-- 验证结果
SELECT '=== 列信息 ===' AS '';
SELECT id AS 'ID', name AS '列名', position AS '位置'
FROM sb_column
WHERE board_id = 1
ORDER BY position;

SELECT '' AS '';
SELECT '=== 任务信息 ===' AS '';
SELECT t.id AS 'ID', c.name AS '所在列', t.title AS '任务标题', t.description AS '描述'
FROM sb_task t
LEFT JOIN sb_column c ON t.column_id = c.id
WHERE t.board_id = 1
ORDER BY c.position, t.sort_order;
