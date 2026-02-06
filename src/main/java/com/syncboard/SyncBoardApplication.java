package com.syncboard;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * SyncBoard 主启动类
 * 实时协作任务平台 - 支持 WebSocket 和 Redis 分布式
 *
 * @author SyncBoard Team
 * @version 1.0.0
 */
@SpringBootApplication
@EnableAsync
@EnableScheduling
public class SyncBoardApplication {

    public static void main(String[] args) {
        SpringApplication.run(SyncBoardApplication.class, args);
        System.out.println("""

                ===================================
                   🚀 SyncBoard 启动成功！
                   实时协作任务平台运行中...
                   WebSocket: ws://localhost:8080/api/ws
                   API文档: http://localhost:8080/api
                ===================================
                """);
    }
}
