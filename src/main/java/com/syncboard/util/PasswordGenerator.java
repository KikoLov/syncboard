package com.syncboard.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 临时工具类 - 用于生成密码哈希
 * 运行此类的 main 方法可以生成密码的 BCrypt 哈希值
 *
 * 运行后请删除此类
 */
public class PasswordGenerator {

    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        // 常用测试密码
        String[] passwords = {"admin123", "123456", "password", "root123", "admin123456"};

        System.out.println("========================================");
        System.out.println("  密码哈希生成器");
        System.out.println("========================================\n");

        for (String password : passwords) {
            String hash = encoder.encode(password);
            System.out.println("密码: " + password);
            System.out.println("哈希: " + hash);
            System.out.println("---");
        }

        System.out.println("\n========================================");
        System.out.println("  验证密码");
        System.out.println("========================================\n");

        // 验证刚才生成的哈希
        String testPassword = "admin123";
        String testHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH";
        boolean matches = encoder.matches(testPassword, testHash);
        System.out.println("密码: " + testPassword);
        System.out.println("哈希: " + testHash);
        System.out.println("匹配结果: " + matches);

        // 生成一个新的 admin123 哈希
        String newHash = encoder.encode("admin123");
        System.out.println("\n新生成的 admin123 哈希: " + newHash);
        System.out.println("验证新生成的哈希: " + encoder.matches("admin123", newHash));
    }
}
