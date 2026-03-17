#!/bin/bash
# SP Vision 25 运行环境变量配置
# 使用方法: source setup_env.sh

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 添加构建目录到 PATH
export PATH="$SCRIPT_DIR/build:$PATH"

# 添加资源目录
export SP_VISION_ASSETS="$SCRIPT_DIR/assets"
export SP_VISION_CONFIGS="$SCRIPT_DIR/configs"

# OpenVINO 环境（如果已安装）
if [ -f /opt/intel/openvino/setupvars.sh ]; then
    source /opt/intel/openvino/setupvars.sh 2>/dev/null
fi

echo "SP Vision 25 环境已配置"
echo "  - 可执行文件: $SCRIPT_DIR/build/"
echo "  - 资源文件: $SP_VISION_ASSETS"
echo "  - 配置文件: $SP_VISION_CONFIGS"
