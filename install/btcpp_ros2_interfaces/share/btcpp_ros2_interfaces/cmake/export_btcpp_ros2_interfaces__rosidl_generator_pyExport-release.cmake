#----------------------------------------------------------------
# Generated CMake target import file for configuration "release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "btcpp_ros2_interfaces::btcpp_ros2_interfaces__rosidl_generator_py" for configuration "release"
set_property(TARGET btcpp_ros2_interfaces::btcpp_ros2_interfaces__rosidl_generator_py APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(btcpp_ros2_interfaces::btcpp_ros2_interfaces__rosidl_generator_py PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libbtcpp_ros2_interfaces__rosidl_generator_py.so"
  IMPORTED_SONAME_RELEASE "libbtcpp_ros2_interfaces__rosidl_generator_py.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS btcpp_ros2_interfaces::btcpp_ros2_interfaces__rosidl_generator_py )
list(APPEND _IMPORT_CHECK_FILES_FOR_btcpp_ros2_interfaces::btcpp_ros2_interfaces__rosidl_generator_py "${_IMPORT_PREFIX}/lib/libbtcpp_ros2_interfaces__rosidl_generator_py.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
