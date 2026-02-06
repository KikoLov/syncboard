package com.syncboard.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 任务移动请求DTO
 */
@Data
public class TaskMoveDTO {

    /**
     * 任务ID
     */
    private Long taskId;

    /**
     * 目标列ID
     */
    private Long targetColumnId;

    /**
     * 目标位置的前一个任务的sort_order
     */
    private BigDecimal previousSortOrder;

    /**
     * 目标位置的后一个任务的sort_order
     */
    private BigDecimal nextSortOrder;

    /**
     * 版本号(乐观锁)
     */
    private Integer version;
}
