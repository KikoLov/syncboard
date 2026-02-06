package com.syncboard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.syncboard.dto.Result;
import com.syncboard.dto.TaskMoveDTO;
import com.syncboard.dto.WebSocketMessageDTO;
import com.syncboard.entity.Task;
import com.syncboard.mapper.TaskMapper;
import com.syncboard.util.FractionalIndexingUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 任务服务类
 * 实现核心业务逻辑，包括拖拽排序和乐观锁并发控制
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskMapper taskMapper;
    private final WebSocketService webSocketService;

    /**
     * 创建任务
     */
    @Transactional(rollbackFor = Exception.class)
    public Result<Task> createTask(Task task) {
        try {
            // 查询当前列中已有的任务数量
            LambdaQueryWrapper<Task> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Task::getColumnId, task.getColumnId());
            Long count = taskMapper.selectCount(wrapper);

            // 生成初始排序序号
            BigDecimal sortOrder = FractionalIndexingUtil.generateInitialSortOrder(count.intValue());
            task.setSortOrder(sortOrder);

            // 保存任务
            task.setCreatedAt(LocalDateTime.now());
            taskMapper.insert(task);

            log.info("创建任务成功: taskId={}, title={}, sortOrder={}", task.getId(), task.getTitle(), sortOrder);

            // 发送 WebSocket 消息
            WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                    .eventType("TASK_CREATE")
                    .boardId(task.getBoardId())
                    .payload(task)
                    .operatorId(task.getCreatedBy())
                    .timestamp(LocalDateTime.now())
                    .build();
            webSocketService.broadcastToBoard(task.getBoardId(), message);

            return Result.success(task);
        } catch (Exception e) {
            log.error("创建任务失败", e);
            return Result.error("创建任务失败: " + e.getMessage());
        }
    }

    /**
     * 更新任务（带乐观锁）
     */
    @Transactional(rollbackFor = Exception.class)
    public Result<Task> updateTask(Task task) {
        try {
            // 检查版本号
            Task existingTask = taskMapper.selectById(task.getId());
            if (existingTask == null) {
                return Result.error("任务不存在");
            }

            // 乐观锁版本检查
            if (!existingTask.getVersion().equals(task.getVersion())) {
                log.warn("并发冲突: taskId={}, clientVersion={}, dbVersion={}",
                        task.getId(), task.getVersion(), existingTask.getVersion());
                return Result.conflict("任务已被其他用户修改，请刷新后重试");
            }

            // 更新任务（MyBatis-Plus 会自动处理乐观锁）
            task.setUpdatedAt(LocalDateTime.now());
            int rows = taskMapper.updateById(task);

            if (rows == 0) {
                // 更新失败，可能是乐观锁冲突
                return Result.conflict("更新失败，可能是并发冲突");
            }

            log.info("更新任务成功: taskId={}, version={}", task.getId(), task.getVersion() + 1);

            // 发送 WebSocket 消息
            WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                    .eventType("TASK_UPDATE")
                    .boardId(task.getBoardId())
                    .payload(task)
                    .operatorId(task.getAssigneeId())
                    .timestamp(LocalDateTime.now())
                    .build();
            webSocketService.broadcastToBoard(task.getBoardId(), message);

            return Result.success(task);
        } catch (Exception e) {
            log.error("更新任务失败", e);
            return Result.error("更新任务失败: " + e.getMessage());
        }
    }

    /**
     * 移动任务（拖拽排序）- 核心功能
     * 实现跨列移动和列内排序
     */
    @Transactional(rollbackFor = Exception.class)
    public Result<Task> moveTask(TaskMoveDTO dto) {
        try {
            // 查询任务
            Task task = taskMapper.selectById(dto.getTaskId());
            if (task == null) {
                return Result.error("任务不存在");
            }

            // 乐观锁版本检查
            if (!task.getVersion().equals(dto.getVersion())) {
                log.warn("移动任务时并发冲突: taskId={}, clientVersion={}, dbVersion={}",
                        dto.getTaskId(), dto.getVersion(), task.getVersion());
                return Result.conflict("任务已被其他用户移动，请刷新后重试");
            }

            Long oldColumnId = task.getColumnId();
            Long newColumnId = dto.getTargetColumnId();

            // 计算新的排序序号（核心算法）
            BigDecimal newSortOrder = FractionalIndexingUtil.calculateSortOrder(
                    dto.getPreviousSortOrder(),
                    dto.getNextSortOrder()
            );

            log.info("计算新排序序号: previous={}, next={}, new={}",
                    dto.getPreviousSortOrder(), dto.getNextSortOrder(), newSortOrder);

            // 更新任务
            task.setColumnId(newColumnId);
            task.setSortOrder(newSortOrder);
            task.setUpdatedAt(LocalDateTime.now());

            int rows = taskMapper.updateById(task);

            if (rows == 0) {
                return Result.conflict("移动失败，可能是并发冲突");
            }

            log.info("移动任务成功: taskId={}, oldColumnId={}, newColumnId={}, newSortOrder={}",
                    task.getId(), oldColumnId, newColumnId, newSortOrder);

            // 重新查询完整任务信息
            Task updatedTask = taskMapper.selectById(task.getId());

            // 发送 WebSocket 消息
            WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                    .eventType("TASK_MOVE")
                    .boardId(task.getBoardId())
                    .payload(updatedTask)
                    .operatorId(task.getAssigneeId())
                    .timestamp(LocalDateTime.now())
                    .build();
            webSocketService.broadcastToBoard(task.getBoardId(), message);

            return Result.success(updatedTask);
        } catch (Exception e) {
            log.error("移动任务失败", e);
            return Result.error("移动任务失败: " + e.getMessage());
        }
    }

    /**
     * 删除任务
     */
    @Transactional(rollbackFor = Exception.class)
    public Result<Void> deleteTask(Long taskId) {
        try {
            Task task = taskMapper.selectById(taskId);
            if (task == null) {
                return Result.error("任务不存在");
            }

            taskMapper.deleteById(taskId);

            log.info("删除任务成功: taskId={}", taskId);

            // 发送 WebSocket 消息
            WebSocketMessageDTO message = WebSocketMessageDTO.builder()
                    .eventType("TASK_DELETE")
                    .boardId(task.getBoardId())
                    .payload(taskId)
                    .timestamp(LocalDateTime.now())
                    .build();
            webSocketService.broadcastToBoard(task.getBoardId(), message);

            return Result.success();
        } catch (Exception e) {
            log.error("删除任务失败", e);
            return Result.error("删除任务失败: " + e.getMessage());
        }
    }

    /**
     * 获取看板中的所有任务
     */
    public Result<List<Task>> getTasksByBoardId(Long boardId) {
        try {
            List<Task> tasks = taskMapper.selectTasksByBoardId(boardId);
            return Result.success(tasks);
        } catch (Exception e) {
            log.error("获取任务列表失败", e);
            return Result.error("获取任务列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取任务详情
     */
    public Result<Task> getTaskById(Long taskId) {
        try {
            Task task = taskMapper.selectById(taskId);
            if (task == null) {
                return Result.error("任务不存在");
            }
            return Result.success(task);
        } catch (Exception e) {
            log.error("获取任务详情失败", e);
            return Result.error("获取任务详情失败: " + e.getMessage());
        }
    }
}
