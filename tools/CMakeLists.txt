cmake_minimum_required(VERSION 3.16)

find_package(OpenCV REQUIRED)
find_package(fmt REQUIRED)

add_library(tools OBJECT 
    exiter.cpp
    extended_kalman_filter.cpp
    ransac_sine_fitter.cpp
    img_tools.cpp
    math_tools.cpp
    plotter.cpp
    trajectory.cpp
    recorder.cpp
    logger.cpp
    pid.cpp
    crc.cpp
)

# 为OBJECT库声明接口依赖，这样使用tools的目标会自动获得这些依赖
target_link_libraries(tools INTERFACE ${OpenCV_LIBS})
target_include_directories(tools INTERFACE ${OpenCV_INCLUDE_DIRS})