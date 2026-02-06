-- ============================================
-- SyncBoard 测试数据插入脚本
-- ============================================

USE syncboard;

-- 插入测试用户
INSERT INTO sys_user (username, email, password, nickname, avatar_url) VALUES
('admin', 'admin@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'Admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin'),
('user1', 'user1@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'ZhangSan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=user1'),
('user2', 'user2@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'LiSi', 'https://api.dicebear.com/7.x/avataaars/svg?seed=user2');

-- 插入测试看板
INSERT INTO sb_board (name, description, owner_id) VALUES
('Project Board', 'SyncBoard project management', 1),
('Personal Tasks', 'My personal task list', 2);

-- 插入看板成员
INSERT INTO sb_board_member (board_id, user_id, role) VALUES
(1, 1, 'OWNER'),
(1, 2, 'MEMBER'),
(1, 3, 'MEMBER'),
(2, 2, 'OWNER');

-- 插入测试列
INSERT INTO sb_column (board_id, name, color, sort_order, position) VALUES
(1, 'To Do', '#F4F5F7', 0.0000000001, 0),
(1, 'In Progress', '#EBECF0', 0.0000000002, 1),
(1, 'Done', '#DCDFE4', 0.0000000003, 2);

-- 插入测试任务
INSERT INTO sb_task (board_id, column_id, title, description, assignee_id, sort_order, priority, created_by) VALUES
(1, 1, 'Design Database', 'Complete MySQL database table design', 2, 0.0000000001, 3, 1),
(1, 1, 'Setup Spring Boot', 'Initialize Spring Boot project with dependencies', 1, 0.0000000002, 3, 1),
(1, 2, 'Implement WebSocket', 'Configure WebSocket STOMP for real-time messaging', 1, 0.0000000001, 2, 1),
(1, 3, 'Environment Setup', 'Development environment configuration completed', 2, 0.0000000001, 1, 2);

SELECT 'Test data inserted successfully!' AS message;
SELECT 'Board ID: 1, 2' AS info;
SELECT 'Users: admin, user1, user2' AS info;
SELECT 'Password: 123456 (BCrypt encrypted)' AS info;
