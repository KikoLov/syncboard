package com.syncboard.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 拖拽排序算法工具类
 * 实现 Fractional Indexing 算法
 *
 * 核心思想：
 * - 不使用简单的整数索引(1, 2, 3)，而是使用浮点数
 * - 移动卡片到 A 和 B 之间时，新序号 = (A + B) / 2
 * - 这样可以避免移动卡片时重排整个数据库
 *
 * 例如：
 * - 初始: [0.1, 0.2, 0.3, 0.4]
 * - 将 0.4 移到 0.1 和 0.2 之间: (0.1 + 0.2) / 2 = 0.15
 * - 结果: [0.1, 0.15, 0.2, 0.3]
 */
public class FractionalIndexingUtil {

    /**
     * 默认最小值(放在最前面)
     */
    private static final BigDecimal DEFAULT_MIN = BigDecimal.ZERO;

    /**
     * 默认最大值(放在最后面)
     */
    private static final BigDecimal DEFAULT_MAX = new BigDecimal("9999999999");

    /**
     * 排序精度(小数位数)
     */
    private static final int SCALE = 10;

    /**
     * 计算新位置的任务排序序号
     *
     * @param previousOrder 前一个任务的 sort_order (可为 null)
     * @param nextOrder     后一个任务的 sort_order (可为 null)
     * @return 新的排序序��
     */
    public static BigDecimal calculateSortOrder(BigDecimal previousOrder, BigDecimal nextOrder) {
        // 如果前一个任务为空，说明要放在最前面
        if (previousOrder == null) {
            if (nextOrder == null) {
                // 两个都为空，返回默认值
                return DEFAULT_MIN.add(BigDecimal.ONE);
            }
            // 返回 nextOrder 的一半
            return nextOrder.divide(BigDecimal.valueOf(2), SCALE, RoundingMode.HALF_UP);
        }

        // 如果后一个任务为空，说明要放在最后面
        if (nextOrder == null) {
            // 返回 previousOrder 和 DEFAULT_MAX 的中间值
            return previousOrder.add(DEFAULT_MAX)
                    .divide(BigDecimal.valueOf(2), SCALE, RoundingMode.HALF_UP);
        }

        // 正常情况：返回两个序号的中间值
        return previousOrder.add(nextOrder)
                .divide(BigDecimal.valueOf(2), SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 计算新位置的任务排序序号（简化版）
     * 用于在列末尾或列首添加任务
     *
     * @param positionType 位置类型: "first" (列首), "last" (列末尾)
     * @param baseOrder    基准排序序号（用于计算）
     * @return 新的排序序号
     */
    public static BigDecimal calculateSortOrderForPosition(String positionType, BigDecimal baseOrder) {
        if ("first".equals(positionType)) {
            // 放在列首
            if (baseOrder == null) {
                return new BigDecimal("0.0000000001");
            }
            return baseOrder.divide(BigDecimal.valueOf(2), SCALE, RoundingMode.HALF_UP);
        } else if ("last".equals(positionType)) {
            // 放在列末尾
            if (baseOrder == null) {
                return new BigDecimal("0.9999999999");
            }
            return baseOrder.add(BigDecimal.ONE)
                    .min(new BigDecimal("9999999999"));
        }
        throw new IllegalArgumentException("Invalid position type: " + positionType);
    }

    /**
     * 生成初始排序序号
     * 用于新创建的任务
     *
     * @param existingCount 列中已有的任务数量
     * @return 初始排序序号
     */
    public static BigDecimal generateInitialSortOrder(int existingCount) {
        // 使用 0.1, 0.2, 0.3... 作为初始序号
        return BigDecimal.valueOf(existingCount + 1)
                .divide(BigDecimal.TEN, SCALE, RoundingMode.HALF_UP);
    }

    /**
     * 检查两个排序序号是否接近（用于防止精度问题）
     *
     * @param order1 排序序号1
     * @param order2 排序序号2
     * @return 是否接近
     */
    public static boolean isTooClose(BigDecimal order1, BigDecimal order2) {
        if (order1 == null || order2 == null) {
            return false;
        }
        BigDecimal diff = order1.subtract(order2).abs();
        return diff.compareTo(new BigDecimal("0.0000000001")) < 0;
    }

    /**
     * 处理精度问题：当两个序号太接近时，重新生成序号
     *
     * @param currentOrder 当前排序序号
     * @return 调整后的排序序号
     */
    public static BigDecimal adjustForPrecision(BigDecimal currentOrder) {
        if (currentOrder == null) {
            return new BigDecimal("0.0000000001");
        }
        // 加上一个很小的值
        return currentOrder.add(new BigDecimal("0.0000000001"));
    }
}
