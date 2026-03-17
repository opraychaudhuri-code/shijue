#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build_biaoding"
CONFIG_PATH="${ROOT_DIR}/configs/biaoding.yaml"

INTRINSICS_DIR="${ROOT_DIR}/assets/biaoding/intrinsics"
HANDEYE_DIR="${ROOT_DIR}/assets/biaoding/handeye"

build_targets() {
  cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}"
  cmake --build "${BUILD_DIR}" --target \
    biaoding_capture_intrinsics \
    biaoding_calibrate_intrinsics \
    biaoding_capture_handeye \
    biaoding_calibrate_handeye -j
}

run_cmd() {
  local exe="$1"
  shift
  "${BUILD_DIR}/${exe}" "$@"
}

print_menu() {
  echo "=============================="
  echo "  Biaoding Launcher"
  echo "=============================="
  echo "1. 采集相机内参图片"
  echo "2. 计算相机内参"
  echo "3. 采集手眼标定数据"
  echo "4. 计算手眼标定"
  echo "5. 仅编译"
  echo "0. 退出"
}

build_targets

if [[ ! -f "${CONFIG_PATH}" ]]; then
  echo "错误: 配置文件不存在: ${CONFIG_PATH}"
  echo "请创建 configs/biaoding.yaml 或修改 CONFIG_PATH"
  exit 1
fi

while true; do
  print_menu
  read -r -p "请选择操作: " choice

  case "${choice}" in
    1)
      mkdir -p "${INTRINSICS_DIR}"
      run_cmd biaoding_capture_intrinsics --config-path "${CONFIG_PATH}" --output-folder "${INTRINSICS_DIR}"
      ;;
    2)
      if [[ ! -d "${INTRINSICS_DIR}" ]] || ! ls "${INTRINSICS_DIR}"/*.jpg 1>/dev/null 2>&1; then
        echo "错误: 请先运行选项 1 采集内参图片到 assets/biaoding/intrinsics/"
        continue
      fi
      run_cmd biaoding_calibrate_intrinsics --config-path "${CONFIG_PATH}" --input-folder "${INTRINSICS_DIR}"
      ;;
    3)
      mkdir -p "${HANDEYE_DIR}"
      run_cmd biaoding_capture_handeye --config-path "${CONFIG_PATH}" --output-folder "${HANDEYE_DIR}"
      ;;
    4)
      if [[ ! -d "${HANDEYE_DIR}" ]] || ! ls "${HANDEYE_DIR}"/*.jpg 1>/dev/null 2>&1; then
        echo "错误: 请先运行选项 3 采集手眼数据到 assets/biaoding/handeye/"
        continue
      fi
      run_cmd biaoding_calibrate_handeye --config-path "${CONFIG_PATH}" --input-folder "${HANDEYE_DIR}"
      ;;
    5)
      echo "编译完成。"
      ;;
    0)
      exit 0
      ;;
    *)
      echo "无效选项，请重新输入。"
      ;;
  esac
done
