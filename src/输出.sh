#!/bin/bash
# 实时输出 /cmd_vel 话题内容

echo "实时监控 /cmd_vel 话题输出..."
echo "按 Ctrl+C 停止"
echo ""

# 检查 ROS2 环境
if [ -z "$ROS_DISTRO" ]; then
    echo "错误: 未检测到 ROS2 环境，请先 source install/setup.bash"
    exit 1
fi

# 实时输出 /cmd_vel 话题内容
ros2 topic echo /cmd_vel

