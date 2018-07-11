

add_library(jutils-containers OBJECT radix.cc)
set_property(TARGET jutils-containers PROPERTY POSITION_INDEPENDENT_CODE ON)

#add_executable(test-radix tests/test-radix.cc radix.cc)
#add_test(NAME test-radix
#  COMMAND test-radix)


