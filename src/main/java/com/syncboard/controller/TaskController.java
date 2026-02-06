package com.syncboard.controller;

import com.syncboard.dto.Result;
import com.syncboard.dto.TaskMoveDTO;
import com.syncboard.entity.Task;
import com.syncboard.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 任务控制器
 * 提供任务管理的 REST API
 */
@Slf4j
@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    /**
     * 创建任务
     * POST /api/tasks
     */
    @PostMapping
    public Result<Task> createTask(@RequestBody Task task) {
        return taskService.createTask(task);
    }

    /**
     * 更新任务
     * PUT /api/tasks/{id}
     */
    @PutMapping("/{id}")
    public Result<Task> updateTask(@PathVariable Long id, @RequestBody Task task) {
        task.setId(id);
        return taskService.updateTask(task);
    }

    /**
     * 移动任务（拖拽排序）
     * POST /api/tasks/move
     *
     * 请求体示例：
     * {
     *   "taskId": 1,
     *   "targetColumnId": 2,
     *   "previousSortOrder": 0.1,
     *   "nextSortOrder": 0.3,
     *   "version": 0
     * }
     */
    @PostMapping("/move")
    public Result<Task> moveTask(@RequestBody TaskMoveDTO dto) {
        return taskService.moveTask(dto);
    }

    /**
     * 删除任务
     * DELETE /api/tasks/{id}
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteTask(@PathVariable Long id) {
        return taskService.deleteTask(id);
    }

    /**
     * 获取看板中的所有任务
     * GET /api/tasks/board/{boardId}
     */
    @GetMapping("/board/{boardId}")
    public Result<List<Task>> getTasksByBoardId(@PathVariable Long boardId) {
        return taskService.getTasksByBoardId(boardId);
    }

    /**
     * 获取任务详情
     * GET /api/tasks/{id}
     */
    @GetMapping("/{id}")
    public Result<Task> getTaskById(@PathVariable Long id) {
        return taskService.getTaskById(id);
    }
}
