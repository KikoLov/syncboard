package com.syncboard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 任务评论实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sb_task_comment")
public class TaskComment {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 任务ID
     */
    private Long taskId;

    /**
     * 评论用户ID
     */
    private Long userId;

    /**
     * 评论内容
     */
    private String content;

    /**
     * 是否删除: 1-是 0-否
     */
    @TableField("is_deleted")
    @TableLogic
    private Integer isDeleted;

    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    // Transient fields for joined data
    /**
     * 用户名(非数据库字段)
     */
    @TableField(exist = false)
    private String username;

    /**
     * 用户头像(非数据库字段)
     */
    @TableField(exist = false)
    private String userAvatar;
}
