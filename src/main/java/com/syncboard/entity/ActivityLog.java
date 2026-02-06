package com.syncboard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 活动日志实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sb_activity_log")
public class ActivityLog {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 看板ID
     */
    private Long boardId;

    /**
     * 任务ID(可为空)
     */
    private Long taskId;

    /**
     * 列ID(可为空)
     */
    private Long columnId;

    /**
     * 操作用户ID
     */
    private Long userId;

    /**
     * 操作类型
     */
    private String actionType;

    /**
     * 事件类型
     */
    private String eventType;

    /**
     * 操作详情(JSON格式)
     */
    private String details;

    /**
     * IP地址
     */
    @TableField("ip_address")
    private String ipAddress;

    /**
     * 用户代理
     */
    @TableField("user_agent")
    private String userAgent;

    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
