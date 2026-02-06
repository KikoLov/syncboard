package com.syncboard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 看板实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sb_board")
public class Board {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 看板名称
     */
    private String name;

    /**
     * 看板描述
     */
    private String description;

    /**
     * 所有者ID
     */
    @TableField("owner_id")
    private Long ownerId;

    /**
     * 是否公开: 1-是 0-否
     */
    @TableField("is_public")
    private Integer isPublic;

    /**
     * 背景颜色
     */
    @TableField("background_color")
    private String backgroundColor;

    /**
     * 排序序号
     */
    @TableField("sort_order")
    private Integer sortOrder;

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
