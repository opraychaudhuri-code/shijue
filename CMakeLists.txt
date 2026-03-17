cmake_minimum_required(VERSION 3.16)
# 尝试查找 OpenVINO，如果未找到则跳过此模块
# 优先使用 APT 安装的 OpenVINO 2025.3.0
if(NOT DEFINED OpenVINO_DIR)
    if(EXISTS "/usr/lib/cmake/openvino2025.3.0/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/usr/lib/cmake/openvino2025.3.0")
    elseif(EXISTS "/usr/lib/cmake/openvino2024.6.0/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/usr/lib/cmake/openvino2024.6.0")
    elseif(EXISTS "/home/nexium-4/.local/lib/python3.10/site-packages/openvino/cmake/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/home/nexium-4/.local/lib/python3.10/site-packages/openvino/cmake")
    else()
        set(OpenVINO_DIR "/opt/intel/openvino_2024.6.0/runtime/cmake")
    endif()
endif()

find_package(OpenVINO QUIET PATHS "${OpenVINO_DIR}")
if(NOT OpenVINO_FOUND)
    message(STATUS "OpenVINO not found, skipping auto_buff module")
    return()
endif()
find_package(Ceres REQUIRED)
find_package(OpenCV REQUIRED)
find_package(yaml-cpp REQUIRED)

add_library(auto_buff OBJECT 
    buff_type.cpp
    buff_detector.cpp
    buff_solver.cpp
    buff_aimer.cpp
    buff_target.cpp
    yolo11_buff.cpp
)

target_link_libraries(auto_buff PUBLIC auto_aim openvino::runtime ${CERES_LIBRARIES} ${OpenCV_LIBS} yaml-cpp)
target_include_directories(auto_buff PUBLIC ${OpenCV_INCLUDE_DIRS} /home/nexium-4/.local/lib/python3.10/site-packages/openvino/include)
# OpenVINO的include目录