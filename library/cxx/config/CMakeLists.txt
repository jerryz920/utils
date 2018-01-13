

add_library(jutils-config OBJECT simple.cc)
set_property(TARGET jutils-config PROPERTY POSITION_INDEPENDENT_CODE ON)

add_executable(test-simple-conf tests/test-simple.cc simple.cc)
add_test(NAME test-simple-conf
  COMMAND test-simple-conf)


