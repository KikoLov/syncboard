-- ============================================
-- SyncBoard 实时协作任务平台 - 数据库初始化脚本
-- MySQL 8.0+
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS syncboard DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE syncboard;

-- ============================================
-- 1. 用户表 (sys_user)
-- ============================================
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
    nickname VARCHAR(50) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    status TINYINT DEFAULT 1 COMMENT '状态: 1-正常 0-禁用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================
-- 2. 看板表 (sb_board)
-- ============================================
DROP TABLE IF EXISTS sb_board;
CREATE TABLE sb_board (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '看板ID',
    name VARCHAR(100) NOT NULL COMMENT '看板名称',
    description TEXT COMMENT '看板描述',
    owner_id BIGINT NOT NULL COMMENT '所有者ID',
    is_public TINYINT DEFAULT 0 COMMENT '是否公开: 1-是 0-否',
    background_color VARCHAR(20) DEFAULT '#0079BF' COMMENT '背景颜色',
    sort_order INT DEFAULT 0 COMMENT '排序序号',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (owner_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    INDEX idx_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='看板表';

-- ============================================
-- 3. 看板成员表 (sb_board_member)
-- ============================================
DROP TABLE IF EXISTS sb_board_member;
CREATE TABLE sb_board_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成员ID',
    board_id BIGINT NOT NULL COMMENT '看板ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role VARCHAR(20) DEFAULT 'MEMBER' COMMENT '角色: OWNER-所有者 ADMIN-管理员 MEMBER-成员',
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    FOREIGN KEY (board_id) REFERENCES sb_board(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    UNIQUE KEY uk_board_user (board_id, user_id),
    INDEX idx_board (board_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='看板成员表';

-- ============================================
-- 4. 任务列表 (sb_column)
-- ============================================
DROP TABLE IF EXISTS sb_column;
CREATE TABLE sb_column (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '列ID',
    board_id BIGINT NOT NULL COMMENT '看板ID',
    name VARCHAR(50) NOT NULL COMMENT '列名称',
    color VARCHAR(20) DEFAULT '#EBECF0' COMMENT '列颜色',
    sort_order DECIMAL(20,10) NOT NULL DEFAULT 0 COMMENT '排序序号(支持小数,用于拖拽排序)',
    position INT DEFAULT 0 COMMENT '列位置索引',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (board_id) REFERENCES sb_board(id) ON DELETE CASCADE,
    INDEX idx_board (board_id),
    INDEX idx_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务列表';

-- ============================================
-- 5. 任务卡片 (sb_task)
-- ============================================
DROP TABLE IF EXISTS sb_task;
CREATE TABLE sb_task (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '任务ID',
    board_id BIGINT NOT NULL COMMENT '看板ID',
    column_id BIGINT NOT NULL COMMENT '列ID',
    title VARCHAR(200) NOT NULL COMMENT '任务标题',
    description TEXT COMMENT '任务描述',
    assignee_id BIGINT COMMENT '负责人ID',
    sort_order DECIMAL(20,10) NOT NULL DEFAULT 0 COMMENT '排序序号(使用浮点数实现Fractional Indexing)',
    labels JSON COMMENT '标签(JSON数组)',
    due_date DATETIME COMMENT '截止日期',
    start_time DATETIME COMMENT '任务开始时间',
    end_time DATETIME COMMENT '任务结束时间(截止时间)',
    priority TINYINT DEFAULT 1 COMMENT '优先级: 1-低 2-中 3-高 4-紧急',
    is_completed TINYINT DEFAULT 0 COMMENT '是否完成: 1-是 0-否',
    version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    created_by BIGINT COMMENT '创建者ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (board_id) REFERENCES sb_board(id) ON DELETE CASCADE,
    FOREIGN KEY (column_id) REFERENCES sb_column(id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES sys_user(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES sys_user(id) ON DELETE SET NULL,
    INDEX idx_board (board_id),
    INDEX idx_column (column_id),
    INDEX idx_assignee (assignee_id),
    INDEX idx_sort (sort_order),
    INDEX idx_version (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务卡片';

-- ============================================
-- 6. 活动日志 (sb_activity_log)
-- ============================================
DROP TABLE IF EXISTS sb_activity_log;
CREATE TABLE sb_activity_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    board_id BIGINT NOT NULL COMMENT '看板ID',
    task_id BIGINT COMMENT '任务ID(可为空,如看板级别的操作)',
    column_id BIGINT COMMENT '列ID(可为空)',
    user_id BIGINT NOT NULL COMMENT '操作用户ID',
    action_type VARCHAR(50) NOT NULL COMMENT '操作类型: TASK_CREATE/TASK_UPDATE/TASK_MOVE/TASK_DELETE/COLUMN_CREATE等',
    event_type VARCHAR(50) NOT NULL COMMENT '事件类型',
    details JSON COMMENT '操作详情(JSON格式)',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (board_id) REFERENCES sb_board(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES sb_task(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    INDEX idx_board (board_id),
    INDEX idx_task (task_id),
    INDEX idx_user (user_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='活动日志';

-- ============================================
-- 7. 任务评论表 (sb_task_comment)
-- ============================================
DROP TABLE IF EXISTS sb_task_comment;
CREATE TABLE sb_task_comment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    task_id BIGINT NOT NULL COMMENT '任务ID',
    user_id BIGINT NOT NULL COMMENT '评论用户ID',
    content TEXT NOT NULL COMMENT '评论内容',
    is_deleted TINYINT DEFAULT 0 COMMENT '是否删除: 1-是 0-否',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (task_id) REFERENCES sb_task(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    INDEX idx_task (task_id),
    INDEX idx_user (user_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务评论表';

-- ============================================
-- 初始化测试数据
-- ============================================

-- 插入测试用户
INSERT INTO sys_user (username, email, password, nickname, avatar_url) VALUES
('admin', 'admin@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '管理员', 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin'),
('user1', 'user1@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '张三', 'https://api.dicebear.com/7.x/avataaars/svg?seed=user1'),
('user2', 'user2@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '李四', 'https://api.dicebear.com/7.x/avataaars/svg?seed=user2');

-- 插入测试看板
INSERT INTO sb_board (name, description, owner_id) VALUES
('项目开发看板', 'SyncBoard项目开发任务管理', 1),
('个人任务管理', '我的个人任务列表', 2);

-- 插入看板成员
INSERT INTO sb_board_member (board_id, user_id, role) VALUES
(1, 1, 'OWNER'),
(1, 2, 'MEMBER'),
(1, 3, 'MEMBER'),
(2, 2, 'OWNER');

-- 插入测试列
INSERT INTO sb_column (board_id, name, color, sort_order, position) VALUES
(1, '待处理', '#F4F5F7', 0.0000000001, 0),
(1, '进行中', '#EBECF0', 0.0000000002, 1),
(1, '已完成', '#DCDFE4', 0.0000000003, 2);

-- 插入测试任务
INSERT INTO sb_task (board_id, column_id, title, description, assignee_id, sort_order, priority, created_by) VALUES
(1, 1, '设计数据库表结构', '完成MySQL数据库表设计，包括用户、看板、列、任务等表', 2, 0.0000000001, 3, 1),
(1, 1, '搭建Spring Boot项目', '初始化Spring Boot项目，配置依赖', 1, 0.0000000002, 3, 1),
(1, 2, '实现WebSocket通信', '配置WebSocket STOMP协议，实现实时消息推送', 1, 0.0000000001, 2, 1),
(1, 3, '环境搭建', '开发环境配置完成', 2, 0.0000000001, 1, 2);

-- ============================================
-- 创建存储过程：获取看板完整数据
-- ============================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_get_board_detail$$
CREATE PROCEDURE sp_get_board_detail(IN p_board_id BIGINT)
BEGIN
    -- 获取看板信息
    SELECT * FROM sb_board WHERE id = p_board_id;

    -- 获取列信息(按sort_order排序)
    SELECT c.*,
           (SELECT COUNT(*) FROM sb_task t WHERE t.column_id = c.id AND t.is_completed = 0) as pending_task_count
    FROM sb_column c
    WHERE c.board_id = p_board_id
    ORDER BY c.sort_order;

    -- 获取任务信息(按sort_order排序)
    SELECT t.*,
           u.username as assignee_name,
           u.avatar_url as assignee_avatar
    FROM sb_task t
    LEFT JOIN sys_user u ON t.assignee_id = u.id
    WHERE t.board_id = p_board_id
    ORDER BY t.column_id, t.sort_order;

    -- 获取看板成员
    SELECT m.*,
           u.username,
           u.nickname,
           u.avatar_url
    FROM sb_board_member m
    JOIN sys_user u ON m.user_id = u.id
    WHERE m.board_id = p_board_id;
END$$

DELIMITER ;

-- ============================================
-- 创建触发器：任务变更时记录日志
-- ============================================
DELIMITER $$

DROP TRIGGER IF EXISTS tr_task_insert_log$$
CREATE TRIGGER tr_task_insert_log
AFTER INSERT ON sb_task
FOR EACH ROW
BEGIN
    INSERT INTO sb_activity_log (board_id, task_id, column_id, user_id, action_type, event_type, details)
    VALUES (NEW.board_id, NEW.id, NEW.column_id, COALESCE(NEW.created_by, 1),
            'TASK_CREATE', 'TASK_CREATED',
            JSON_OBJECT('title', NEW.title, 'column_id', NEW.column_id));
END$$

DROP TRIGGER IF EXISTS tr_task_update_log$$
CREATE TRIGGER tr_task_update_log
AFTER UPDATE ON sb_task
FOR EACH ROW
BEGIN
    IF NEW.column_id != OLD.column_id THEN
        INSERT INTO sb_activity_log (board_id, task_id, column_id, user_id, action_type, event_type, details)
        VALUES (NEW.board_id, NEW.id, NEW.column_id, COALESCE(NEW.assignee_id, 1),
                'TASK_MOVE', 'TASK_MOVED',
                JSON_OBJECT('old_column_id', OLD.column_id, 'new_column_id', NEW.column_id,
                           'old_sort_order', OLD.sort_order, 'new_sort_order', NEW.sort_order));
    ELSEIF NEW.sort_order != OLD.sort_order THEN
        INSERT INTO sb_activity_log (board_id, task_id, column_id, user_id, action_type, event_type, details)
        VALUES (NEW.board_id, NEW.id, NEW.column_id, COALESCE(NEW.assignee_id, 1),
                'TASK_MOVE', 'TASK_REORDERED',
                JSON_OBJECT('old_sort_order', OLD.sort_order, 'new_sort_order', NEW.sort_order));
    END IF;
END$$

DELIMITER ;

-- 完成
SELECT '✅ SyncBoard 数据库初始化完成！' AS message;
