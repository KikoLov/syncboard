package com.syncboard.vo;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户信息VO
 */
@Data
public class UserVO {
    private Long id;
    private String username;
    private String email;
    private String nickname;
    private String avatarUrl;
    private LocalDateTime createdAt;
}
