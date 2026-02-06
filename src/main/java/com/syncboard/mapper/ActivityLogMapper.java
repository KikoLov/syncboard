package com.syncboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.syncboard.entity.ActivityLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 活动日志Mapper接口
 */
@Mapper
public interface ActivityLogMapper extends BaseMapper<ActivityLog> {
}
