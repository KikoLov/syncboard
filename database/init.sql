/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : localhost:3306
 Source Schema         : syncboard

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 06/02/2026 20:20:51
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sb_activity_log
-- ----------------------------
DROP TABLE IF EXISTS `sb_activity_log`;
CREATE TABLE `sb_activity_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏃ュ織ID',
  `board_id` bigint NOT NULL COMMENT '鐪嬫澘ID',
  `task_id` bigint NULL DEFAULT NULL COMMENT '浠诲姟ID(鍙?负绌?濡傜湅鏉跨骇鍒?殑鎿嶄綔)',
  `column_id` bigint NULL DEFAULT NULL COMMENT '鍒桰D(鍙?负绌?',
  `user_id` bigint NOT NULL COMMENT '鎿嶄綔鐢ㄦ埛ID',
  `action_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鎿嶄綔绫诲瀷: TASK_CREATE/TASK_UPDATE/TASK_MOVE/TASK_DELETE/COLUMN_CREATE绛',
  `event_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '浜嬩欢绫诲瀷',
  `details` json NULL COMMENT '鎿嶄綔璇︽儏(JSON鏍煎紡)',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP鍦板潃',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢ㄦ埛浠ｇ悊',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_board`(`board_id` ASC) USING BTREE,
  INDEX `idx_task`(`task_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_created`(`created_at` ASC) USING BTREE,
  CONSTRAINT `sb_activity_log_ibfk_1` FOREIGN KEY (`board_id`) REFERENCES `sb_board` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `sb_activity_log_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `sb_task` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `sb_activity_log_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '娲诲姩鏃ュ織' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sb_activity_log
-- ----------------------------

-- ----------------------------
-- Table structure for sb_board
-- ----------------------------
DROP TABLE IF EXISTS `sb_board`;
CREATE TABLE `sb_board`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐪嬫澘ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐪嬫澘鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐪嬫澘鎻忚堪',
  `owner_id` bigint NOT NULL COMMENT '鎵?湁鑰匢D',
  `is_public` tinyint NULL DEFAULT 0 COMMENT '鏄?惁鍏?紑: 1-鏄?0-鍚',
  `background_color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '#0079BF' COMMENT '鑳屾櫙棰滆壊',
  `sort_order` int NULL DEFAULT 0 COMMENT '鎺掑簭搴忓彿',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_owner`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `sb_board_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐪嬫澘琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sb_board
-- ----------------------------
INSERT INTO `sb_board` VALUES (1, '项目看板', 'SyncBoard项目管理', 1, 0, '#0079BF', 0, '2026-01-31 20:11:44', '2026-01-31 20:11:44');
INSERT INTO `sb_board` VALUES (2, 'Personal Tasks', 'My personal task list', 2, 0, '#0079BF', 0, '2026-01-31 15:37:22', '2026-01-31 15:37:22');

-- ----------------------------
-- Table structure for sb_board_member
-- ----------------------------
DROP TABLE IF EXISTS `sb_board_member`;
CREATE TABLE `sb_board_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎴愬憳ID',
  `board_id` bigint NOT NULL COMMENT '鐪嬫澘ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'MEMBER' COMMENT '瑙掕壊: OWNER-鎵?湁鑰?ADMIN-绠＄悊鍛?MEMBER-鎴愬憳',
  `joined_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍔犲叆鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_board_user`(`board_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_board`(`board_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `sb_board_member_ibfk_1` FOREIGN KEY (`board_id`) REFERENCES `sb_board` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `sb_board_member_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐪嬫澘鎴愬憳琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sb_board_member
-- ----------------------------

-- ----------------------------
-- Table structure for sb_column
-- ----------------------------
DROP TABLE IF EXISTS `sb_column`;
CREATE TABLE `sb_column`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍒桰D',
  `board_id` bigint NOT NULL COMMENT '鐪嬫澘ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍒楀悕绉',
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '#EBECF0' COMMENT '鍒楅?鑹',
  `sort_order` decimal(20, 10) NOT NULL DEFAULT 0.0000000000 COMMENT '鎺掑簭搴忓彿(鏀?寔灏忔暟,鐢ㄤ簬鎷栨嫿鎺掑簭)',
  `position` int NULL DEFAULT 0 COMMENT '鍒椾綅缃?储寮',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_board`(`board_id` ASC) USING BTREE,
  INDEX `idx_sort`(`sort_order` ASC) USING BTREE,
  CONSTRAINT `sb_column_ibfk_1` FOREIGN KEY (`board_id`) REFERENCES `sb_board` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '浠诲姟鍒楄〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sb_column
-- ----------------------------
INSERT INTO `sb_column` VALUES (4, 1, '待办事项', '#F4F5F7', 0.0000000001, 0, '2026-01-31 20:11:44', '2026-01-31 20:11:44');
INSERT INTO `sb_column` VALUES (5, 1, '进行中', '#EBECF0', 0.0000000002, 1, '2026-01-31 20:11:44', '2026-01-31 20:11:44');
INSERT INTO `sb_column` VALUES (6, 1, '已完成', '#DCDFE4', 0.0000000003, 2, '2026-01-31 20:11:44', '2026-01-31 20:11:44');

-- ----------------------------
-- Table structure for sb_task
-- ----------------------------
DROP TABLE IF EXISTS `sb_task`;
CREATE TABLE `sb_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浠诲姟ID',
  `board_id` bigint NOT NULL COMMENT '鐪嬫澘ID',
  `column_id` bigint NOT NULL COMMENT '鍒桰D',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '浠诲姟鏍囬?',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '浠诲姟鎻忚堪',
  `assignee_id` bigint NULL DEFAULT NULL COMMENT '璐熻矗浜篒D',
  `sort_order` decimal(20, 10) NOT NULL DEFAULT 0.0000000000 COMMENT '鎺掑簭搴忓彿(浣跨敤娴?偣鏁板疄鐜癋ractional Indexing)',
  `labels` json NULL COMMENT '鏍囩?(JSON鏁扮粍)',
  `due_date` datetime NULL DEFAULT NULL COMMENT '鎴??鏃ユ湡',
  `priority` tinyint NULL DEFAULT 1 COMMENT '浼樺厛绾? 1-浣?2-涓?3-楂?4-绱ф?',
  `is_completed` tinyint NULL DEFAULT 0 COMMENT '鏄?惁瀹屾垚: 1-鏄?0-鍚',
  `version` int NOT NULL DEFAULT 0 COMMENT '涔愯?閿佺増鏈?彿',
  `created_by` bigint NULL DEFAULT NULL COMMENT '鍒涘缓鑰匢D',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `created_by`(`created_by` ASC) USING BTREE,
  INDEX `idx_board`(`board_id` ASC) USING BTREE,
  INDEX `idx_column`(`column_id` ASC) USING BTREE,
  INDEX `idx_assignee`(`assignee_id` ASC) USING BTREE,
  INDEX `idx_sort`(`sort_order` ASC) USING BTREE,
  INDEX `idx_version`(`version` ASC) USING BTREE,
  CONSTRAINT `sb_task_ibfk_1` FOREIGN KEY (`board_id`) REFERENCES `sb_board` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `sb_task_ibfk_2` FOREIGN KEY (`column_id`) REFERENCES `sb_column` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `sb_task_ibfk_3` FOREIGN KEY (`assignee_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `sb_task_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '浠诲姟鍗＄墖' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sb_task
-- ----------------------------
INSERT INTO `sb_task` VALUES (9, 1, 4, '设计数据库表', '完成MySQL数据库表结构设计', 2, 0.0000000001, NULL, NULL, 3, 0, 0, 1, '2026-01-31 20:12:40', '2026-01-31 20:12:40');
INSERT INTO `sb_task` VALUES (10, 1, 4, '搭建Spring Boot', '初始化Spring Boot项目并配置依赖', 1, 0.0000000002, NULL, NULL, 3, 0, 0, 1, '2026-01-31 20:12:40', '2026-01-31 20:12:40');
INSERT INTO `sb_task` VALUES (11, 1, 5, '实现WebSocket', '配置WebSocket STOMP实现实时消息推送', 1, 0.0000000001, NULL, NULL, 2, 0, 0, 1, '2026-01-31 20:12:40', '2026-01-31 20:12:40');
INSERT INTO `sb_task` VALUES (12, 1, 6, '开发环境配置', '开发环境配置完成', 2, 0.0000000001, NULL, NULL, 1, 0, 0, 2, '2026-01-31 20:12:40', '2026-01-31 20:12:40');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄦ埛ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閭??',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀵嗙爜(BCrypt鍔犲瘑)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏄电О',
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶村儚URL',
  `status` tinyint NULL DEFAULT 1 COMMENT '鐘舵?: 1-姝ｅ父 0-绂佺敤',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢ㄦ埛琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', 'admin@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'Admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin', 1, '2026-01-31 15:35:25', '2026-01-31 15:35:25');
INSERT INTO `sys_user` VALUES (2, 'user1', 'user1@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'ZhangSan', 'https://api.dicebear.com/7.x/avataaars/svg?seed=user1', 1, '2026-01-31 15:35:25', '2026-01-31 15:35:25');
INSERT INTO `sys_user` VALUES (3, 'user2', 'user2@syncboard.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'LiSi', 'https://api.dicebear.com/7.x/avataaars/svg?seed=user2', 1, '2026-01-31 15:35:25', '2026-01-31 15:35:25');
INSERT INTO `sys_user` VALUES (7, 'testuser2', 'test2@example.com', '$2a$10$2FwovyPxjO9H862kMzSdLuFBPpW09plhDFo2I18krmvyF/4A55E22', 'Test2', '/api/images/default-avatar.png', 1, NULL, NULL);
INSERT INTO `sys_user` VALUES (8, 'root', '2029002141@qq.com', '$2a$10$ITBAe2pfCwpF9jib513F2u3VFUDhCp1yctsKFh7MHJBKcSayZ.EEC', 'kiko', '/api/images/default-avatar.png', 1, NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
