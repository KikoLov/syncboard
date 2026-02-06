package com.syncboard.redis;

import com.syncboard.dto.WebSocketMessageDTO;
import com.syncboard.service.WebSocketService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.stereotype.Component;

/**
 * Redis 订阅者
 * 监听 Redis 频道的消息，���转发到 WebSocket
 *
 * 当有多个服务器实例时，Redis 会将消息广播给所有订阅者
 * 确保所有在线用户都能收到实时更新
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RedisSubscriber implements MessageListener {

    private final WebSocketService webSocketService;

    /**
     * 接收 Redis 消息
     *
     * @param message 消息内容
     * @param pattern 订阅模式
     */
    @Override
    public void onMessage(Message message, byte[] pattern) {
        try {
            // 反序列化消息
            String jsonMsg = new String(message.getBody());
            WebSocketMessageDTO wsMessage = com.alibaba.fastjson2.JSON.parseObject(
                    jsonMsg, WebSocketMessageDTO.class);

            log.debug("收到 Redis 消息: boardId={}, eventType={}",
                    wsMessage.getBoardId(), wsMessage.getEventType());

            // 将消息转发到 WebSocket 客户端
            webSocketService.sendToBoard(wsMessage.getBoardId(), wsMessage);

        } catch (Exception e) {
            log.error("处理 Redis 消息失败", e);
        }
    }
}
