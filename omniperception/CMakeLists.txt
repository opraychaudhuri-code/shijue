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

find_package(OpenVINO QUIET PATHS "${OpenVINO_DIR}" COMPONENTS Runtime)
if(NOT OpenVINO_FOUND)
    message(STATUS "OpenVINO not found, skipping omniperception module")
    return()
endif()

add_library(omniperception OBJECT 
    decider.cpp
    perceptron.cpp
)
target_link_libraries(omniperception openvino::runtime)