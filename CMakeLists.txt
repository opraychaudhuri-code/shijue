cmake_minimum_required(VERSION 3.16.3)

project(sp_vision)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE Release)
# 强制使用 C++11 ABI，与系统库保持一致（fmt、yaml-cpp、OpenCV 都需要）
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=1")
message(STATUS "--------------------CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}--------------------")

find_package(OpenCV REQUIRED)
find_package(fmt REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(spdlog REQUIRED)
find_package(yaml-cpp REQUIRED)
find_package(nlohmann_json REQUIRED)

# 自动检测 OpenVINO 路径（支持多种安装方式）
# 优先使用 APT 安装的 OpenVINO（支持 C++11 ABI）
if(NOT DEFINED OpenVINO_DIR)
    # 优先使用 APT 安装的 OpenVINO 2024.6.0
    if(EXISTS "/usr/lib/cmake/openvino2024.6.0/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/usr/lib/cmake/openvino2024.6.0")
        message(STATUS "Found OpenVINO (APT 2024.6.0) at: ${OpenVINO_DIR}")
    # 其次尝试 APT 安装的 OpenVINO 2025.3.0
    elseif(EXISTS "/usr/lib/cmake/openvino2025.3.0/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/usr/lib/cmake/openvino2025.3.0")
        message(STATUS "Found OpenVINO (APT 2025.3.0) at: ${OpenVINO_DIR}")
    # 其次尝试 APT 安装的 OpenVINO 2024.6.0
    elseif(EXISTS "/usr/lib/cmake/openvino2024.6.0/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/usr/lib/cmake/openvino2024.6.0")
        message(STATUS "Found OpenVINO (APT 2024.6.0) at: ${OpenVINO_DIR}")
    # 最后尝试 Python 包中的 OpenVINO
    elseif(EXISTS "/home/nexium-4/.local/lib/python3.10/site-packages/openvino/cmake/OpenVINOConfig.cmake")
        set(OpenVINO_DIR "/home/nexium-4/.local/lib/python3.10/site-packages/openvino/cmake")
        message(STATUS "Found OpenVINO (Python) at: ${OpenVINO_DIR}")
    else()
        # 尝试常见的 OpenVINO 安装路径
        set(OPENVINO_SEARCH_PATHS
            "/opt/intel/openvino_2024/runtime/cmake"
            "/opt/intel/openvino/runtime/cmake"
            "$ENV{OPENVINO_PATH}/runtime/cmake"
            "/usr/local/runtime/cmake"
        )
        
        foreach(search_path ${OPENVINO_SEARCH_PATHS})
            if(EXISTS "${search_path}/OpenVINOConfig.cmake")
                set(OpenVINO_DIR "${search_path}")
                message(STATUS "Found OpenVINO at: ${OpenVINO_DIR}")
                break()
            endif()
        endforeach()
    endif()
endif()

if(DEFINED OpenVINO_DIR)
    find_package(OpenVINO QUIET PATHS "${OpenVINO_DIR}")
else()
    find_package(OpenVINO QUIET)
endif()

if(NOT OpenVINO_FOUND)
    message(WARNING "OpenVINO not found, some features may be disabled")
    set(ENABLE_AUTO_BUFF OFF)
    set(ENABLE_AUTO_AIM OFF)
else()
    message(STATUS "OpenVINO found and enabled")
    set(ENABLE_AUTO_BUFF ON)
    set(ENABLE_AUTO_AIM ON)
endif()

include_directories(${EIGEN3_INCLUDE_DIR})
include_directories(${OpenCV_INCLUDE_DIRS})
include_directories(${PROJECT_SOURCE_DIR})


add_subdirectory(tools)
add_subdirectory(io)
# auto_aim 和 omniperception 需要 OpenVINO，如果未找到则跳过
if(OpenVINO_FOUND)
    add_subdirectory(tasks/auto_aim)
    add_subdirectory(tasks/omniperception)
else()
    message(WARNING "OpenVINO not found, skipping auto_aim and omniperception modules")
endif()
# auto_buff 需要 OpenVINO，如果未找到则跳过
if(OpenVINO_FOUND)
    add_subdirectory(tasks/auto_buff)
endif()

####################src###################
if(OpenVINO_FOUND)
    add_executable(standard src/standard.cpp)
    add_executable(mt_standard src/mt_standard.cpp)
    add_executable(standard_mpc src/standard_mpc.cpp)
    add_executable(auto_aim_debug_mpc src/auto_aim_debug_mpc.cpp)
    add_executable(mt_auto_aim_debug src/mt_auto_aim_debug.cpp)
    add_executable(auto_buff_debug src/auto_buff_debug.cpp)
    add_executable(auto_buff_debug_mpc src/auto_buff_debug_mpc.cpp)
    add_executable(uav src/uav.cpp)
    add_executable(uav_debug src/uav_debug.cpp)

    # 禁用--as-needed选项以确保所有库都被链接
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-as-needed")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-as-needed")
    # 移除默认的--as-needed标志（在所有位置）
    string(REPLACE "-Wl,--as-needed" "" CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    string(REPLACE "-Wl,--as-needed" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
    # 全局禁用 --as-needed
    set(CMAKE_CXX_LINK_FLAGS "${CMAKE_CXX_LINK_FLAGS} -Wl,--no-as-needed")
    # 全局设置，确保所有目标都使用 C++11 ABI
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=1")

    target_link_libraries(standard PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(mt_standard PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(standard_mpc PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(auto_aim_debug_mpc PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(mt_auto_aim_debug PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(auto_buff_debug PRIVATE auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt ${CERES_LIBRARIES} openvino::runtime)
    target_link_libraries(auto_buff_debug_mpc PRIVATE auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt ${CERES_LIBRARIES} openvino::runtime)
    target_link_libraries(uav PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(uav_debug PRIVATE auto_aim auto_buff tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
else()
    message(WARNING "OpenVINO not found, skipping src targets that depend on auto_aim/auto_buff")
endif()

##################calibration################
add_executable(capture calibration/capture.cpp)
add_executable(calibrate_camera calibration/calibrate_camera.cpp)
add_executable(calibrate_handeye calibration/calibrate_handeye.cpp)
add_executable(calibrate_robotworld_handeye calibration/calibrate_robotworld_handeye.cpp)
add_executable(split_video calibration/split_video.cpp)
add_executable(biaoding_capture_intrinsics src/biaoding_capture_intrinsics.cpp)
add_executable(biaoding_calibrate_intrinsics src/biaoding_calibrate_intrinsics.cpp)
add_executable(biaoding_capture_handeye src/biaoding_capture_handeye.cpp)
add_executable(biaoding_calibrate_handeye src/biaoding_calibrate_handeye.cpp)

# 使用库目标名称，并确保在最后链接
target_link_libraries(capture PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(calibrate_camera PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(calibrate_handeye PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(calibrate_robotworld_handeye PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(split_video PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(biaoding_capture_intrinsics PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(biaoding_calibrate_intrinsics PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(biaoding_capture_handeye PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(biaoding_calibrate_handeye PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)

##################tests##################
# 不依赖 auto_aim/auto_buff 的测试目标
add_executable(camera_test tests/camera_test.cpp)
add_executable(cboard_test tests/cboard_test.cpp)
add_executable(fire_test tests/fire_test.cpp)
add_executable(gimbal_response_test tests/gimbal_response_test.cpp)
add_executable(multi_usbcamera_test tests/multi_usbcamera_test.cpp)
add_executable(usbcamera_test tests/usbcamera_test.cpp)
add_executable(dm_test tests/dm_test.cpp)

target_link_libraries(camera_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(cboard_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(fire_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(gimbal_response_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(multi_usbcamera_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(usbcamera_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
target_link_libraries(dm_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)

# 依赖 auto_aim/auto_buff 的测试目标，只在 OpenVINO 找到时编译
if(OpenVINO_FOUND)
    add_executable(auto_aim_test tests/auto_aim_test.cpp)
    add_executable(auto_buff_test tests/auto_buff_test.cpp)
    add_executable(camera_detect_test tests/camera_detect_test.cpp)
    add_executable(camera_thread_test tests/camera_thread_test.cpp)
    add_executable(detector_video_test tests/detector_video_test.cpp)
    add_executable(usbcamera_detect_test tests/usbcamera_detect_test.cpp)
    add_executable(handeye_test tests/handeye_test.cpp)
    add_executable(minimum_vision_system tests/minimum_vision_system.cpp)
    add_executable(gimbal_test tests/gimbal_test.cpp)
    add_executable(planner_test tests/planner_test.cpp)
    add_executable(planner_test_offline tests/planner_test_offline.cpp)

    target_link_libraries(auto_aim_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(auto_buff_test PRIVATE auto_buff tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(camera_detect_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(camera_thread_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(detector_video_test PRIVATE auto_aim tools ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(usbcamera_detect_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(handeye_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(minimum_vision_system PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(gimbal_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(planner_test PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
    target_link_libraries(planner_test_offline PRIVATE auto_aim tools io ${OpenCV_LIBS} /usr/lib/x86_64-linux-gnu/libyaml-cpp.so.0.7.0 /usr/lib/x86_64-linux-gnu/libfmt.so.8.1.1 openvino::runtime)
endif()

# 检查 ROS 环境
find_package(ament_cmake QUIET)
find_package(rclcpp QUIET)
find_package(std_msgs QUIET)
find_package(rosidl_typesupport_cpp QUIET)
find_package(sp_msgs QUIET)
# 只有在找到 ROS 环境时才会添加 sentry 和 publish_test
if(ament_cmake_FOUND AND rclcpp_FOUND AND std_msgs_FOUND AND rosidl_typesupport_cpp_FOUND AND sp_msgs_FOUND)
    # 编译 sentry 和 publish_test
    add_executable(sentry src/sentry.cpp)
    add_executable(sentry_bp src/sentry_bp.cpp)
    add_executable(sentry_debug src/sentry_debug.cpp)
    add_executable(sentry_multithread src/sentry_multithread.cpp)
    add_executable(publish_test tests/publish_test.cpp)
    add_executable(subscribe_test tests/subscribe_test.cpp)
    add_executable(topic_loop_test tests/topic_loop_test.cpp)

    target_link_libraries(sentry PRIVATE auto_aim omniperception tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(sentry_bp PRIVATE auto_aim omniperception tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(sentry_debug PRIVATE auto_aim omniperception tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(sentry_multithread PRIVATE auto_aim omniperception tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(publish_test PRIVATE auto_aim tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt openvino::runtime)
    target_link_libraries(subscribe_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
    target_link_libraries(topic_loop_test PRIVATE tools io ${OpenCV_LIBS} yaml-cpp fmt::fmt)
else()
    message(STATUS "ROS2 environment not found, skipping ROS2-related code.")
endif()
