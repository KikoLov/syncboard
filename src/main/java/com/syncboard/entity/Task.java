package com.syncboard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 任务卡片实体类
 * 包含乐观锁支持��用于并发控制
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sb_task")
public class Task {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 看板ID
     */
    private Long boardId;

    /**
     * 列ID
     */
    private Long columnId;

    /**
     * 任务标题
     */
    private String title;

    /**
     * 任务描述
     */
    private String description;

    /**
     * 负责人ID
     */
    private Long assigneeId;

    /**
     * 排序序号(使用浮点数实现Fractional Indexing)
     * 避免移动卡片时重排整个数据库
     */
    private BigDecimal sortOrder;

    /**
     * 标签(JSON数组)
     */
    private String labels;

    /**
     * 截止日期
     */
    @TableField("due_date")
    private LocalDateTime dueDate;

    /**
     * 优先级: 1-低 2-中 3-高 4-紧急
     */
    private Integer priority;

    /**
     * 是否完成: 1-是 0-否
     */
    @TableField("is_completed")
    private Integer isCompleted;

    /**
     * 乐观锁版本号
     * 每次更新时自动递增，用于并发冲突检测
     */
    @Version
    private Integer version;

    /**
     * 创建者ID
     */
    private Long createdBy;

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
}
