package com.syncboard.service;

import com.syncboard.dto.WebSocketMessageDTO;
import com.syncboard.redis.RedisPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

/**
 * WebSocket 服务类
 * 处理 WebSocket 消息的分发和广播
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WebSocketService {

    private final SimpMessagingTemplate messagingTemplate;
    private final RedisPublisher redisPublisher;

    /**
     * 向看板内的所有用户广播消息
     * 消息会先发送到 Redis，然后由 Redis 广播到所有服务器实例
     *
     * @param boardId  看板ID
     * @param message  消息内容
     */
    public void broadcastToBoard(Long boardId, WebSocketMessageDTO message) {
        log.info("广播消息到看板: boardId={}, eventType={}", boardId, message.getEventType());

        // 先发送到 Redis Pub/Sub，实现分布式广播
        redisPublisher.publish(boardId, message);

        // 同时也发送到当前服务器的 WebSocket 客户端
        sendToBoard(boardId, message);
    }

    /**
     * 向看板内的所有用户发送消息（单机模式）
     *
     * @param boardId  看板ID
     * @param message  消息内容
     */
    public void sendToBoard(Long boardId, WebSocketMessageDTO message) {
        try {
            // 发送到 /topic/board/{boardId} 主题
            messagingTemplate.convertAndSend("/topic/board/" + boardId, message);
            log.debug("消息已发送到看板: boardId={}", boardId);
        } catch (Exception e) {
            log.error("发送 WebSocket 消息失败: boardId={}", boardId, e);
        }
    }

    /**
     * 向指定用户发送消息
     *
     * @param userId   用户ID
     * @param message  消息内容
     */
    public void sendToUser(Long userId, WebSocketMessageDTO message) {
        try {
            // 发送到 /user/{userId}/queue/messages 队列
            messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/messages", message);
            log.debug("消息已发送给用户: userId={}", userId);
        } catch (Exception e) {
            log.error("发送消息给用户失败: userId={}", userId, e);
        }
    }

    /**
     * 广播用户上线消息
     *
     * @param boardId    看板ID
     * @param userId     用户ID
     * @param username   用户名
     */
    public void broadcastUserOnline(Long boardId, Long userId, String username) {
        WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                .eventType("USER_PRESENCE")
                .boardId(boardId)
                .payload(new OnlineUserPayload(userId, username, true))
                .operatorId(userId)
                .timestamp(java.time.LocalDateTime.now())
                .build();

        broadcastToBoard(boardId, message);
    }

    /**
     * 广播用户离线消息
     *
     * @param boardId    看板ID
     * @param userId     用户ID
     * @param username   用户名
     */
    public void broadcastUserOffline(Long boardId, Long userId, String username) {
        WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                .eventType("USER_PRESENCE")
                .boardId(boardId)
                .payload(new OnlineUserPayload(userId, username, false))
                .operatorId(userId)
                .timestamp(java.time.LocalDateTime.now())
                .build();

        broadcastToBoard(boardId, message);
    }

    /**
     * 在线用户负载类
     */
    public record OnlineUserPayload(Long userId, String username, Boolean online) {}
}
