cmake_minimum_required (VERSION 3.0)
project (jutils)
# The version number.
set (jutils_VERSION_MAJOR 1)
set (jutils_VERSION_MINOR 0)
set (jutils_INSTALL_PATH "/usr/local" CACHE PATH "prefix of installation")
set (CMAKE_INSTALL_PREFIX ${jutils_INSTALL_PATH} CACHE INTERNAL "prefix prepended to install directories" FORCE)
add_definitions("-Wall -std=c++11")

include_directories(PUBLIC ${PROJECT_SOURCE_DIR}/include)

enable_testing()
add_subdirectory(config)

add_library(jutils SHARED version.cc $<TARGET_OBJECTS:jutils-config> )
#set_property(TARGET jutils PROPERTY POSITION_INDEPENDENT_CODE ON)

file(GLOB testfiles RELATIVE ${PROJECT_SOURCE_DIR} tests/test-*.cc)
foreach(fullname ${testfiles})
  message(fullname=${fullname})
  STRING(REGEX REPLACE "[^/]*/" "" testfile "${fullname}")
  string(REGEX MATCH "^(.*)\\.cc$" dummy ${testfile})
  set(testname ${CMAKE_MATCH_1})
  add_executable(${testname} ${fullname})
  add_test(NAME ${testname}
  COMMAND ${testname})
endforeach(fullname)


install(TARGETS jutils
  LIBRARY DESTINATION lib
  )
install (DIRECTORY include DESTINATION include/jutils)
