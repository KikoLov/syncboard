package com.syncboard.controller;

import com.syncboard.dto.LoginRequest;
import com.syncboard.dto.RegisterRequest;
import com.syncboard.dto.ResetPasswordRequest;
import com.syncboard.dto.Result;
import com.syncboard.service.UserService;
import com.syncboard.vo.LoginResponse;
import com.syncboard.vo.UserVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

/**
 * ���户控制器
 */
@Slf4j
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * 用户注册
     * POST /api/users/register
     */
    @PostMapping("/register")
    public Result<UserVO> register(@Valid @RequestBody RegisterRequest request) {
        try {
            UserVO userVO = userService.register(request);
            return Result.success(userVO);
        } catch (Exception e) {
            log.error("注册失败", e);
            return Result.error(400, e.getMessage());
        }
    }

    /**
     * 用户登录
     * POST /api/users/login
     */
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            LoginResponse response = userService.login(request);
            return Result.success(response);
        } catch (Exception e) {
            log.error("登录失败", e);
            return Result.error(400, e.getMessage());
        }
    }

    /**
     * 获取当前登录用户信息
     * GET /api/users/me
     */
    @GetMapping("/me")
    public Result<UserVO> getCurrentUser(@RequestHeader(value = "Authorization", required = false) String token) {
        // TODO: 根据token获取用户信息
        if (token == null) {
            return Result.error(401, "未登录");
        }
        return Result.error(401, "Token验证功能待实现");
    }

    /**
     * 用户退出登录
     * POST /api/users/logout
     */
    @PostMapping("/logout")
    public Result<Void> logout() {
        // TODO: 清除token
        return Result.success(null);
    }

    /**
     * 重置密码
     * POST /api/users/reset-password
     */
    @PostMapping("/reset-password")
    public Result<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        try {
            userService.resetPassword(request);
            return Result.success(null);
        } catch (Exception e) {
            log.error("重置密码失败", e);
            return Result.error(400, e.getMessage());
        }
    }
}
