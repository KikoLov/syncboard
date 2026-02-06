package com.syncboard.websocket;

import com.syncboard.service.PresenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;
import org.springframework.web.socket.messaging.SessionUnsubscribeEvent;

/**
 * WebSocket 事件监听器
 * 处理用户连接、断开、订阅和取消订阅事件
 *
 * 用于更新在线状态和订阅 Redis 频道
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketEventListener {

    private final PresenceService presenceService;

    /**
     * 用户连接事件
     */
    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        log.info("WebSocket 用户连接: sessionId={}", sessionId);
    }

    /**
     * 用户断开连接事件
     */
    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();

        // 从会话属性中获取用户信息
        Long userId = (Long) headerAccessor.getSessionAttributes().get("userId");
        Long boardId = (Long) headerAccessor.getSessionAttributes().get("boardId");
        String username = (String) headerAccessor.getSessionAttributes().get("username");

        if (userId != null && boardId != null) {
            log.info("WebSocket 用户断开连接: sessionId={}, userId={}, boardId={}",
                    sessionId, userId, boardId);

            // 用户离开看板
            presenceService.userLeft(boardId, userId, username != null ? username : "未知用户");
        }
    }

    /**
     * 用户订阅事件
     * 当用户订阅看板频道时触发
     */
    @EventListener
    public void handleSessionSubscribeEvent(SessionSubscribeEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        String destination = headerAccessor.getDestination();

        log.debug("用户订阅: sessionId={}, destination={}", sessionId, destination);

        // 解析订阅目的地，例如：/topic/board/1
        if (destination != null && destination.startsWith("/topic/board/")) {
            try {
                String boardIdStr = destination.substring("/topic/board/".length());
                Long boardId = Long.parseLong(boardIdStr);

                // 从会话属性中获取用户信息
                Long userId = (Long) headerAccessor.getSessionAttributes().get("userId");
                String username = (String) headerAccessor.getSessionAttributes().get("username");

                if (userId != null) {
                    // 记录用户订阅的看板
                    headerAccessor.getSessionAttributes().put("boardId", boardId);

                    // 用户进入看板
                    presenceService.userJoined(boardId, userId, username != null ? username : "用户" + userId);

                    log.info("用户订阅看板: userId={}, boardId={}", userId, boardId);
                }
            } catch (NumberFormatException e) {
                log.warn("解析看板ID失败: destination={}", destination);
            }
        }
    }

    /**
     * 用户取消订阅事件
     */
    @EventListener
    public void handleSessionUnsubscribeEvent(SessionUnsubscribeEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        log.debug("用户取消订阅: sessionId={}", sessionId);

        // 用户取消订阅时，不需要特殊处理
        // 因为 SessionDisconnectEvent 会处理用户离开
    }
}
