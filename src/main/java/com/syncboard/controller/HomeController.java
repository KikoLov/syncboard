package com.syncboard.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 首页控制器
 * 处理根路径访问
 */
@Controller
public class HomeController {

    /**
     * 根路径重定向到看板界面
     * 访问 http://localhost:8080 自动跳转
     */
    @GetMapping(path = "/")
    public String home() {
        return "redirect:/api/index.html";
    }
}
