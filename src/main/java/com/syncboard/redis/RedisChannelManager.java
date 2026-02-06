package com.syncboard.redis;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.listener.PatternTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.Topic;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import java.util.ArrayList;
import java.util.List;

/**
 * Redis 频道管理器
 * 动态管理 Redis 频道的订阅
 *
 * 用于支持多实例部署场景：
 * - 当用户连接到任意服务器实例时，该实例订阅对应的看板频道
 * - 当所有用户都离开某看板时，取消订阅该频道
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RedisChannelManager {

    private final RedisMessageListenerContainer listenerContainer;
    private final RedisSubscriber redisSubscriber;

    /**
     * 初始化时订阅所有看板频道（使用通配符）
     * 实际生产环境中应该动态订阅/取消订阅
     */
    @PostConstruct
    public void init() {
        // 订阅所有看板频道：syncboard:board:*
        Topic topic = new PatternTopic("syncboard:board:*");
        listenerContainer.addMessageListener(redisSubscriber, topic);
        log.info("已订阅 Redis 频道: syncboard:board:*");
    }

    /**
     * 订阅指定看板的频道
     *
     * @param boardId 看板ID
     */
    public void subscribeToBoard(Long boardId) {
        String channel = "syncboard:board:" + boardId;
        Topic topic = new PatternTopic(channel);

        // 检查是否已订阅
        if (!isSubscribed(topic)) {
            listenerContainer.addMessageListener(redisSubscriber, topic);
            log.info("订阅看板频道: boardId={}, channel={}", boardId, channel);
        }
    }

    /**
     * 取消订阅指定看板的频道
     *
     * @param boardId 看板ID
     */
    public void unsubscribeFromBoard(Long boardId) {
        String channel = "syncboard:board:" + boardId;
        Topic topic = new PatternTopic(channel);

        listenerContainer.removeMessageListener(redisSubscriber, topic);
        log.info("取消订阅看板频道: boardId={}, channel={}", boardId, channel);
    }

    /**
     * 检查是否已订阅某个主题
     */
    private boolean isSubscribed(Topic topic) {
        // 简化实现，实际应该检查监听器是否已订阅
        return true;
    }

    /**
     * 应用关闭时清理资源
     */
    @PreDestroy
    public void destroy() {
        log.info("Redis 频道管理器正在关闭...");
    }
}
