package com.syncboard.redis;

import com.alibaba.fastjson2.JSON;
import com.syncboard.dto.WebSocketMessageDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

/**
 * Redis 发布者
 * 将 WebSocket 消息发布到 Redis 频道
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RedisPublisher {

    private final RedisTemplate<String, Object> redisTemplate;

    /**
     * 发布消息到指定看板的 Redis 频道
     *
     * @param boardId  看板ID
     * @param message  消息内容
     */
    public void publish(Long boardId, WebSocketMessageDTO message) {
        try {
            String channel = "syncboard:board:" + boardId;
            redisTemplate.convertAndSend(channel, message);
            log.debug("消息已发布到 Redis 频道: channel={}, eventType={}",
                    channel, message.getEventType());
        } catch (Exception e) {
            log.error("发布消息到 Redis 失败: boardId={}", boardId, e);
        }
    }
}
