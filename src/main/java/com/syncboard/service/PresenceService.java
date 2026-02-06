package com.syncboard.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * 在线状态感知服务
 * 使用 Redis Hash 存储看板的在线用户列表
 *
 * 核心功能：
 * 1. 用户进入看板时，添加到在线列表
 * 2. 用户离开看板时，从在线列表移除
 * 3. 定期清理过期的在线用户（心跳机制）
 * 4. 广播在线状态变化
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PresenceService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final WebSocketService webSocketService;

    private static final String PRESENCE_KEY_PREFIX = "syncboard:presence:";
    private static final long PRESENCE_TIMEOUT_SECONDS = 300; // 5分钟超时

    /**
     * 用户进入看板
     *
     * @param boardId   看板ID
     * @param userId    用户ID
     * @param username  用户名
     */
    public void userJoined(Long boardId, Long userId, String username) {
        String key = PRESENCE_KEY_PREFIX + boardId;

        // 存储用户信息到 Redis Hash
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("userId", userId);
        userInfo.put("username", username);
        userInfo.put("joinedAt", LocalDateTime.now().toString());

        redisTemplate.opsForHash().put(key, userId.toString(), userInfo);

        // 设置过期时间（5分钟）
        redisTemplate.expire(key, PRESENCE_TIMEOUT_SECONDS, TimeUnit.SECONDS);

        log.info("用户进入看板: boardId={}, userId={}, username={}", boardId, userId, username);

        // 广播用户上线消息
        webSocketService.broadcastUserOnline(boardId, userId, username);
    }

    /**
     * 用户离开看板
     *
     * @param boardId   看板ID
     * @param userId    用户ID
     * @param username  用户名
     */
    public void userLeft(Long boardId, Long userId, String username) {
        String key = PRESENCE_KEY_PREFIX + boardId;

        // 从 Redis Hash 中移除用户
        redisTemplate.opsForHash().delete(key, userId.toString());

        log.info("用户离开看板: boardId={}, userId={}, username={}", boardId, userId, username);

        // 广播用户离线消息
        webSocketService.broadcastUserOffline(boardId, userId, username);
    }

    /**
     * 更新用户心跳（延长在线时间）
     *
     * @param boardId  看板ID
     * @param userId   用户ID
     */
    public void heartbeat(Long boardId, Long userId) {
        String key = PRESENCE_KEY_PREFIX + boardId;

        // 检查用户是否在线
        Boolean exists = redisTemplate.opsForHash().hasKey(key, userId.toString());

        if (Boolean.TRUE.equals(exists)) {
            // 延长过期时间
            redisTemplate.expire(key, PRESENCE_TIMEOUT_SECONDS, TimeUnit.SECONDS);
            log.debug("用户心跳: boardId={}, userId={}", boardId, userId);
        }
    }

    /**
     * 获取看板的所有在线用户
     *
     * @param boardId  看板ID
     * @return 在线用户列表
     */
    public Map<Object, Object> getOnlineUsers(Long boardId) {
        String key = PRESENCE_KEY_PREFIX + boardId;
        return redisTemplate.opsForHash().entries(key);
    }

    /**
     * 获取在线用户数量
     *
     * @param boardId  看板ID
     * @return 在线用户数量
     */
    public long getOnlineUserCount(Long boardId) {
        String key = PRESENCE_KEY_PREFIX + boardId;
        Long size = redisTemplate.opsForHash().size(key);
        return size != null ? size : 0;
    }

    /**
     * 检查用户是否在线
     *
     * @param boardId  看板ID
     * @param userId   用户ID
     * @return 是否在线
     */
    public boolean isUserOnline(Long boardId, Long userId) {
        String key = PRESENCE_KEY_PREFIX + boardId;
        Boolean exists = redisTemplate.opsForHash().hasKey(key, userId.toString());
        return Boolean.TRUE.equals(exists);
    }

    /**
     * 清理看板的所有在线用户
     *
     * @param boardId  看板ID
     */
    public void clearOnlineUsers(Long boardId) {
        String key = PRESENCE_KEY_PREFIX + boardId;
        redisTemplate.delete(key);
        log.info("清理看板在线用户: boardId={}", boardId);
    }
}
