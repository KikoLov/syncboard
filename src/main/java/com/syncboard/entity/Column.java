package com.syncboard.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 任务列实体类
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sb_column")
public class Column {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 看板ID
     */
    private Long boardId;

    /**
     * 列名称
     */
    private String name;

    /**
     * 列颜色
     */
    private String color;

    /**
     * 排序序号(支持小数,用于拖拽排序)
     */
    @TableField("sort_order")
    private BigDecimal sortOrder;

    /**
     * 列位置索引
     */
    private Integer position;

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
