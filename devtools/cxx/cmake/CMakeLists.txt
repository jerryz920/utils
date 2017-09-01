
cmake_minimum_required (VERSION 2.6)
project (xxxx)
# The version number.
set (xxxx_VERSION_MAJOR 1)
set (xxxx_VERSION_MINOR 0)
set (SetInCmake "hello option")


# a list of useful directives so that it can be used 

# configure a header file to pass some of the CMake settings
# to the source code.
# Usage Note:
#    add #define yyyy @cmake_var_name@ (if no quote option in configure_file, then add "" for string value!)
#    for something that is controlled by cmake, use #cmakedefine, which is controlled by option, e.g.
option(FOO_ENABLE "enable foo" ON)
# control flow
if (FOO_ENABLE)
  set (Iamfine 1)
endif (FOO_ENABLE)
#
configure_file (
  "${PROJECT_SOURCE_DIR}/Config.h.in"
  "${PROJECT_SOURCE_DIR}/Config.h"
)


# using boost unit test


# add a subdirectory into this cmake
add_subdirectory(subdir)

add_executable(hello hello.cc)
add_executable(hello1 hello1.cc)

add_executable(testbar hellobar.cc)
target_include_directories(testbar PRIVATE "${PROJECT_SOURCE_DIR}/subdir")
target_link_libraries(testbar bar)
add_library(mytest libhello.cc)
add_library(myshared SHARED libhello.cc)


# install targets, things will be installed to $PREFIX/$path
install(TARGETS hello hello1 mytest myshared
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib-static)

# or simply install(TARGETS hello hello1 mytest myshared DESTINATION full/)

# install files
install(FILES Config.h DESTINATION include)
# install directory: read the fxxxx document
#install(DIRECTORY)


# testing

enable_testing()
add_subdirectory(tests)


