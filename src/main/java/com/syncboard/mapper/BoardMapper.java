package com.syncboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.syncboard.entity.Board;
import org.apache.ibatis.annotations.Mapper;

/**
 * 看板Mapper接口
 */
@Mapper
public interface BoardMapper extends BaseMapper<Board> {
}
