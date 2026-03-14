
if(NOT "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-subbuild/small_gicp-populate-prefix/src/small_gicp-populate-stamp/small_gicp-populate-gitinfo.txt" IS_NEWER_THAN "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-subbuild/small_gicp-populate-prefix/src/small_gicp-populate-stamp/small_gicp-populate-gitclone-lastrun.txt")
  message(STATUS "Avoiding repeated git clone, stamp file is up to date: '/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-subbuild/small_gicp-populate-prefix/src/small_gicp-populate-stamp/small_gicp-populate-gitclone-lastrun.txt'")
  return()
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E rm -rf "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-src"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to remove directory: '/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-src'")
endif()

# try the clone 3 times in case there is an odd git clone issue
set(error_code 1)
set(number_of_tries 0)
while(error_code AND number_of_tries LESS 3)
  execute_process(
    COMMAND "/usr/bin/git"  clone --no-checkout --config "advice.detachedHead=false" "https://github.com/koide3/small_gicp.git" "small_gicp-src"
    WORKING_DIRECTORY "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps"
    RESULT_VARIABLE error_code
    )
  math(EXPR number_of_tries "${number_of_tries} + 1")
endwhile()
if(number_of_tries GREATER 1)
  message(STATUS "Had to git clone more than once:
          ${number_of_tries} times.")
endif()
if(error_code)
  message(FATAL_ERROR "Failed to clone repository: 'https://github.com/koide3/small_gicp.git'")
endif()

execute_process(
  COMMAND "/usr/bin/git"  checkout master --
  WORKING_DIRECTORY "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-src"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to checkout tag: 'master'")
endif()

set(init_submodules TRUE)
if(init_submodules)
  execute_process(
    COMMAND "/usr/bin/git"  submodule update --recursive --init 
    WORKING_DIRECTORY "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-src"
    RESULT_VARIABLE error_code
    )
endif()
if(error_code)
  message(FATAL_ERROR "Failed to update submodules in: '/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-src'")
endif()

# Complete success, update the script-last-run stamp file:
#
execute_process(
  COMMAND ${CMAKE_COMMAND} -E copy
    "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-subbuild/small_gicp-populate-prefix/src/small_gicp-populate-stamp/small_gicp-populate-gitinfo.txt"
    "/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-subbuild/small_gicp-populate-prefix/src/small_gicp-populate-stamp/small_gicp-populate-gitclone-lastrun.txt"
  RESULT_VARIABLE error_code
  )
if(error_code)
  message(FATAL_ERROR "Failed to copy script-last-run stamp file: '/home/nexium/ros_ws/build/small_gicp_relocalization/_deps/small_gicp-subbuild/small_gicp-populate-prefix/src/small_gicp-populate-stamp/small_gicp-populate-gitclone-lastrun.txt'")
endif()

