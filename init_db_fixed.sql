-- ============================================
-- SyncBoard 实时协作任务平台 - 数据库初始化脚本
-- MySQL 8.0+
-- ============================================

USE syncboard;

-- ============================================
-- 1. 用户表 (sys_user)
-- ============================================
SET FOREIGN_KEY_CHECKS = 0;
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

-- 完成
SELECT 'Database tables created successfully!' AS message;
