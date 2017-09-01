
set(Boost_ADDITIONAL_VERSIONS "1.54" "1.54.0")
find_package(Boost 1.54 REQUIRED COMPONENTS unit_test_framework)

#set(Boost_INCLUDE_DIRS /usr/include)

add_executable(test_boost test_bar_boost.cc)
target_include_directories(test_boost PRIVATE ${Boost_INCLUDE_DIRS})
target_include_directories(test_boost PRIVATE ${PROJECT_SOURCE_DIR}/subdir)
# indicates the shared library variant
target_compile_definitions(test_boost PRIVATE "BOOST_TEST_DYN_LINK=1")
# indicates the link paths, which includes another path pointed library
target_link_libraries(test_boost bar ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

add_test(NAME test1 COMMAND test_boost)

