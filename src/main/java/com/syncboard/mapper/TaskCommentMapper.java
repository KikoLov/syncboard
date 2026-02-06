package com.syncboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.syncboard.entity.TaskComment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 任务评论 Mapper
 */
@Mapper
public interface TaskCommentMapper extends BaseMapper<TaskComment> {

    /**
     * 获取任务的所有评论(包含用户信息)
     *
     * @param taskId 任务ID
     * @return 评论列表
     */
    @Select("SELECT c.*, u.username, u.avatar_url as userAvatar " +
            "FROM sb_task_comment c " +
            "LEFT JOIN sys_user u ON c.user_id = u.id " +
            "WHERE c.task_id = #{taskId} AND c.is_deleted = 0 " +
            "ORDER BY c.created_at ASC")
    List<TaskComment> selectCommentsByTaskId(@Param("taskId") Long taskId);
}
