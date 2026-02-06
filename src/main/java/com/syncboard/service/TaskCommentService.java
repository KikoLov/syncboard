package com.syncboard.service;

import com.syncboard.dto.Result;
import com.syncboard.dto.WebSocketMessageDTO;
import com.syncboard.entity.Task;
import com.syncboard.entity.TaskComment;
import com.syncboard.mapper.TaskCommentMapper;
import com.syncboard.mapper.TaskMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 任务评论服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskCommentService {

    private final TaskCommentMapper commentMapper;
    private final TaskMapper taskMapper;
    private final WebSocketService webSocketService;

    /**
     * 添加评论
     *
     * @param comment 评论对象
     * @return 添加结果
     */
    @Transactional(rollbackFor = Exception.class)
    public Result<TaskComment> addComment(TaskComment comment) {
        try {
            // Validate task exists
            Task task = taskMapper.selectById(comment.getTaskId());
            if (task == null) {
                return Result.error("任务不存在");
            }

            // Save comment
            comment.setCreatedAt(LocalDateTime.now());
            commentMapper.insert(comment);

            // Fetch complete comment with user info
            TaskComment fullComment = commentMapper.selectCommentsByTaskId(comment.getTaskId())
                .stream()
                .filter(c -> c.getId().equals(comment.getId()))
                .findFirst()
                .orElse(comment);

            log.info("添加评论成功: commentId={}, taskId={}", comment.getId(), comment.getTaskId());

            // Broadcast via WebSocket
            WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                .eventType("COMMENT_ADD")
                .boardId(task.getBoardId())
                .payload(fullComment)
                .operatorId(comment.getUserId())
                .timestamp(LocalDateTime.now())
                .build();
            webSocketService.broadcastToBoard(task.getBoardId(), message);

            return Result.success(fullComment);
        } catch (Exception e) {
            log.error("添加评论失败", e);
            return Result.error("添加评论失败: " + e.getMessage());
        }
    }

    /**
     * 获取任务的所有评论
     *
     * @param taskId 任务ID
     * @return 评论列表
     */
    public Result<List<TaskComment>> getCommentsByTaskId(Long taskId) {
        try {
            List<TaskComment> comments = commentMapper.selectCommentsByTaskId(taskId);
            return Result.success(comments);
        } catch (Exception e) {
            log.error("获取评论列表失败", e);
            return Result.error("获取评论列表失败: " + e.getMessage());
        }
    }

    /**
     * 删除评论(软删除)
     *
     * @param commentId 评论ID
     * @param userId 用户ID
     * @return 删除结果
     */
    @Transactional(rollbackFor = Exception.class)
    public Result<Void> deleteComment(Long commentId, Long userId) {
        try {
            TaskComment comment = commentMapper.selectById(commentId);
            if (comment == null) {
                return Result.error("评论不存在");
            }

            // Permission check: only comment author can delete
            if (!comment.getUserId().equals(userId)) {
                return Result.error("无权删除此评论");
            }

            // Get task for board ID
            Task task = taskMapper.selectById(comment.getTaskId());

            // Soft delete
            commentMapper.deleteById(commentId);

            log.info("删除评论成功: commentId={}", commentId);

            // Broadcast via WebSocket
            WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                .eventType("COMMENT_DELETE")
                .boardId(task.getBoardId())
                .payload(commentId)
                .operatorId(userId)
                .timestamp(LocalDateTime.now())
                .build();
            webSocketService.broadcastToBoard(task.getBoardId(), message);

            return Result.success();
        } catch (Exception e) {
            log.error("删除评论失败", e);
            return Result.error("删除评论失败: " + e.getMessage());
        }
    }
}
