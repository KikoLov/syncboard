package com.syncboard.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * WebSocket 消息DTO
 * 用于实时推送
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketMessageDTO {

    /**
     * 事件类型
     * TASK_MOVE - 任务移动
     * TASK_UPDATE - 任务更新
     * TASK_CREATE - 任务创建
     * TASK_DELETE - 任务删除
     * USER_PRESENCE - 用户上线/离线
     */
    private String eventType;

    /**
     * 看板ID
     */
    private Long boardId;

    /**
     * 负载数据
     */
    private Object payload;

    /**
     * 操作者ID
     */
    private Long operatorId;

    /**
     * 操作者名称
     */
    private String operatorName;

    /**
     * 时间戳
     */
    private LocalDateTime timestamp;
}
