package com.syncboard.vo;

import lombok.Data;

/**
 * 登录响应VO
 */
@Data
public class LoginResponse {
    private UserVO user;
    private String token;
}
