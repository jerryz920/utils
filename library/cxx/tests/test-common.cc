
#include "jutils/containers/common.h"
#include <vector>
#include <string>
#include <map>
#include <algorithm>



void test_print_vector() {
  std::vector<int> v = {1,2,3,4,5,6,7,8,9,10,11,12};
  std::vector<std::string> x = {"123", "346"};
  std::vector<std::pair<int, std::string>> y = {{1,"123"}, {2,"467"}};
  std::vector<std::tuple<int, std::string, double>> z;
  z.emplace_back(std::forward_as_tuple(1,"123",4.2));
  z.emplace_back(std::forward_as_tuple(2,"456",7.2));
  
  jutils::containers::show(v);
  jutils::containers::show(std::vector<int>());
  jutils::containers::show(x, 2);
  jutils::containers::show(x, 1);
  jutils::containers::show(y);
  jutils::containers::show(z);
  std::for_each(v.begin(), v.end(), jutils::containers::Shower<int>());
}

void test_print_map() {
  std::map<int, std::string> s = {{1,"123"}, {2, "456"}};
  jutils::containers::show(s);



}

int main() {
  test_print_vector();
  test_print_map();
  return 0;
}





