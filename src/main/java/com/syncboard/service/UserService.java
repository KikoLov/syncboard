package com.syncboard.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.syncboard.dto.LoginRequest;
import com.syncboard.dto.RegisterRequest;
import com.syncboard.entity.User;
import com.syncboard.vo.LoginResponse;
import com.syncboard.vo.UserVO;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    /**
     * 用户注册
     */
    UserVO register(RegisterRequest request);

    /**
     * 用户登录
     */
    LoginResponse login(LoginRequest request);

    /**
     * 根据用户名或邮箱查找用户
     */
    User findByUsernameOrEmail(String username);

    /**
     * 转换为UserVO
     */
    UserVO toVO(User user);

    /**
     * 根据token获取用户
     */
    User getUserByToken(String token);
}
