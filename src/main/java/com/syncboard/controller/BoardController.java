package com.syncboard.controller;

import com.syncboard.dto.Result;
import com.syncboard.entity.Board;
import com.syncboard.entity.Column;
import com.syncboard.entity.Task;
import com.syncboard.mapper.BoardMapper;
import com.syncboard.mapper.ColumnMapper;
import com.syncboard.mapper.TaskMapper;
import com.syncboard.service.PresenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

/**
 * 看板控制器
 * 提供看板管理的 REST API
 */
@Slf4j
@RestController
@RequestMapping("/boards")
@RequiredArgsConstructor
public class BoardController {

    private final BoardMapper boardMapper;
    private final ColumnMapper columnMapper;
    private final TaskMapper taskMapper;
    private final PresenceService presenceService;

    /**
     * 获取看板列表
     * GET /api/boards
     */
    @GetMapping
    public Result<List<Board>> listBoards() {
        try {
            List<Board> boards = boardMapper.selectList(
                    new LambdaQueryWrapper<Board>().orderByAsc(Board::getId)
            );
            return Result.success(boards);
        } catch (Exception e) {
            log.error("获取看板列表失败", e);
            return Result.error("获取看板列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取看板详情（包含列和任务）
     * GET /api/boards/{id}
     */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getBoardDetail(@PathVariable Long id) {
        try {
            // 获取看板信息
            Board board = boardMapper.selectById(id);
            if (board == null) {
                return Result.error("看板不存在");
            }

            // 获取列信息
            List<Column> columns = columnMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Column>()
                            .eq(Column::getBoardId, id)
                            .orderByAsc(Column::getSortOrder)
            );

            // 获取任务信息
            List<Task> tasks = taskMapper.selectTasksByBoardId(id);

            // 获取在线用户
            long onlineUserCount = presenceService.getOnlineUserCount(id);

            // 组装结果
            Map<String, Object> result = new HashMap<>();
            result.put("board", board);
            result.put("columns", columns);
            result.put("tasks", tasks);
            result.put("onlineUserCount", onlineUserCount);

            return Result.success(result);
        } catch (Exception e) {
            log.error("获取看板详情失败", e);
            return Result.error("获取看板详情失败: " + e.getMessage());
        }
    }

    /**
     * 创建看板
     * POST /api/boards
     */
    @PostMapping
    public Result<Board> createBoard(@RequestBody Board board) {
        try {
            boardMapper.insert(board);
            return Result.success(board);
        } catch (Exception e) {
            log.error("创建看板失败", e);
            return Result.error("创建看板失败: " + e.getMessage());
        }
    }

    /**
     * 创建列
     * POST /api/boards/{boardId}/columns
     */
    @PostMapping("/{boardId}/columns")
    public Result<Column> createColumn(@PathVariable Long boardId, @RequestBody Column column) {
        try {
            column.setBoardId(boardId);
            columnMapper.insert(column);
            return Result.success(column);
        } catch (Exception e) {
            log.error("创建列失败", e);
            return Result.error("创建列失败: " + e.getMessage());
        }
    }

    /**
     * 获取看板的在线用户
     * GET /api/boards/{id}/online-users
     */
    @GetMapping("/{id}/online-users")
    public Result<Map<Object, Object>> getOnlineUsers(@PathVariable Long id) {
        Map<Object, Object> onlineUsers = presenceService.getOnlineUsers(id);
        return Result.success(onlineUsers);
    }

    /**
     * 获取在线用户数量
     * GET /api/boards/{id}/online-count
     */
    @GetMapping("/{id}/online-count")
    public Result<Long> getOnlineUserCount(@PathVariable Long id) {
        long count = presenceService.getOnlineUserCount(id);
        return Result.success(count);
    }

    /**
     * 用户加入看板
     * POST /api/boards/{id}/join
     */
    @PostMapping("/{id}/join")
    public Result<Void> joinBoard(@PathVariable Long id, @RequestParam Long userId, @RequestParam String username) {
        presenceService.userJoined(id, userId, username);
        return Result.success(null);
    }

    /**
     * 用户离开看板
     * POST /api/boards/{id}/leave
     */
    @PostMapping("/{id}/leave")
    public Result<Void> leaveBoard(@PathVariable Long id, @RequestParam Long userId, @RequestParam String username) {
        presenceService.userLeft(id, userId, username);
        return Result.success(null);
    }
}
