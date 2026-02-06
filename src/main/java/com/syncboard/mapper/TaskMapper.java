package com.syncboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.syncboard.entity.Task;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 任务Mapper接口
 */
@Mapper
public interface TaskMapper extends BaseMapper<Task> {

    /**
     * 获取看板中的所有任务(按列和排序序号排序)
     */
    @Select("SELECT * FROM sb_task WHERE board_id = #{boardId} ORDER BY column_id, sort_order")
    List<Task> selectTasksByBoardId(@Param("boardId") Long boardId);

    /**
     * 获取指定列中的所有任务
     */
    @Select("SELECT * FROM sb_task WHERE column_id = #{columnId} ORDER BY sort_order")
    List<Task> selectTasksByColumnId(@Param("columnId") Long columnId);
}
