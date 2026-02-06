package com.syncboard.controller;

import com.syncboard.dto.Result;
import com.syncboard.entity.TaskComment;
import com.syncboard.service.TaskCommentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 任务评论控制器
 */
@Slf4j
@RestController
@RequestMapping("/task-comments")
@RequiredArgsConstructor
public class TaskCommentController {

    private final TaskCommentService commentService;

    /**
     * 添加评论
     * POST /api/task-comments
     *
     * @param comment 评论对象
     * @return 添加结果
     */
    @PostMapping
    public Result<TaskComment> addComment(@RequestBody TaskComment comment) {
        return commentService.addComment(comment);
    }

    /**
     * 获取任务的所有评论
     * GET /api/task-comments/task/{taskId}
     *
     * @param taskId 任务ID
     * @return 评论列表
     */
    @GetMapping("/task/{taskId}")
    public Result<List<TaskComment>> getCommentsByTaskId(@PathVariable Long taskId) {
        return commentService.getCommentsByTaskId(taskId);
    }

    /**
     * 删除评论
     * DELETE /api/task-comments/{id}
     *
     * @param id 评论ID
     * @param userId 用户ID
     * @return 删除结果
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteComment(@PathVariable Long id, @RequestParam Long userId) {
        return commentService.deleteComment(id, userId);
    }
}
