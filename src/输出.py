#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
实时输出 /cmd_vel 话题内容
"""

import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist


class CmdVelMonitor(Node):
    def __init__(self):
        super().__init__('cmd_vel_monitor')
        
        # 订阅 /cmd_vel 话题
        self.create_subscription(
            Twist,
            '/cmd_vel',
            self.cmd_vel_callback,
            10
        )
        
        print('已订阅 /cmd_vel 话题，等待数据...\n')
    
    def cmd_vel_callback(self, msg):
        """实时输出 /cmd_vel 话题内容"""
        print(f'[cmd_vel] linear: x={msg.linear.x:.3f}, y={msg.linear.y:.3f}, z={msg.linear.z:.3f} | '
              f'angular: x={msg.angular.x:.3f}, y={msg.angular.y:.3f}, z={msg.angular.z:.3f}')


def main():
    rclpy.init()
    
    monitor = CmdVelMonitor()
    
    try:
        rclpy.spin(monitor)
    except KeyboardInterrupt:
        print('\n\n程序已停止')
    finally:
        monitor.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()

