package com.syncboard.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.syncboard.dto.LoginRequest;
import com.syncboard.dto.RegisterRequest;
import com.syncboard.entity.User;
import com.syncboard.mapper.UserMapper;
import com.syncboard.service.UserService;
import com.syncboard.vo.LoginResponse;
import com.syncboard.vo.UserVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 用户服务实现类
 */
@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    @Transactional
    public UserVO register(RegisterRequest request) {
        // 验证两次密码是否一致
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new RuntimeException("两次密码输入���一致");
        }

        // 检查用户名是否已存在
        LambdaQueryWrapper<User> usernameWrapper = new LambdaQueryWrapper<>();
        usernameWrapper.eq(User::getUsername, request.getUsername());
        if (baseMapper.selectCount(usernameWrapper) > 0) {
            throw new RuntimeException("用户名已被注册");
        }

        // 检查邮箱是否已存在
        LambdaQueryWrapper<User> emailWrapper = new LambdaQueryWrapper<>();
        emailWrapper.eq(User::getEmail, request.getEmail());
        if (baseMapper.selectCount(emailWrapper) > 0) {
            throw new RuntimeException("邮箱已被注册");
        }

        // 创建新用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getNickname() != null ? request.getNickname() : request.getUsername());
        user.setStatus(1);
        user.setAvatarUrl("/api/images/default-avatar.png");

        baseMapper.insert(user);

        log.info("用户注册成功: {}", user.getUsername());
        return toVO(user);
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        // 查找用户（支持用户名或邮箱登录）
        User user = findByUsernameOrEmail(request.getUsername());
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        // 检查用户状态
        if (user.getStatus() == 0) {
            throw new RuntimeException("账号已被禁用");
        }

        // 生成token（简单实现，生产环境应该使用JWT）
        String token = UUID.randomUUID().toString().replace("-", "");

        // TODO: 将token存入Redis，设置过期时间

        log.info("用户登录成功: {}", user.getUsername());

        LoginResponse response = new LoginResponse();
        response.setUser(toVO(user));
        response.setToken(token);
        return response;
    }

    @Override
    public User findByUsernameOrEmail(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username)
                .or()
                .eq(User::getEmail, username);
        return baseMapper.selectOne(wrapper);
    }

    @Override
    public UserVO toVO(User user) {
        if (user == null) {
            return null;
        }
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setEmail(user.getEmail());
        vo.setNickname(user.getNickname());
        vo.setAvatarUrl(user.getAvatarUrl());
        vo.setCreatedAt(user.getCreatedAt());
        return vo;
    }

    @Override
    public User getUserByToken(String token) {
        // TODO: 从Redis中获取用户信息
        // 简化版本：暂时返回null
        return null;
    }
}
