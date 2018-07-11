
#include "jutils/containers/common.h"
#include <vector>
#include <string>



void test_print_vector() {
  std::vector<int> v = {1,2,3,4,5,6,7,8,9,10,11,12};
  std::vector<std::string> x = {"123", "346"};
  std::vector<std::pair<int, std::string>> y = {{1,"123"}, {2,"467"}};
  jutils::containers::show(v);
  jutils::containers::show(x, 2);
  jutils::containers::show(x, 1);
  jutils::containers::show(y);
}

int main() {
  test_print_vector();
  return 0;
}





