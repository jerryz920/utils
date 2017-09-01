
#include <iostream>
#include "bar.h"
#define BOOST_TEST_MODULE TEST_EXAMPLE
#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_CASE(hello) {
  std::cout << "hello testbar: " << bar() << std::endl;
}
