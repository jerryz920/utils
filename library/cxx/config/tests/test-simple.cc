
#include "jutils/config/simple.h"
#include <string.h>
#include <assert.h>
#include <stdlib.h>

const char *valid_test_config = 
"a=1\n\
b= 2\n\
 c = 3\n\
 d = 4\n\
#comment\n\
  # a=5 \n\
b= 3\n\
    \n\
 ";

const char *invalid_test_config = 
" a\n\
    \n\
  ";

static void write_config(const std::string &path, const char *data) {
  FILE* f = fopen(path.c_str(), "w");
  if (!f)
    throw std::runtime_error("can not write file " + path);
  fwrite(data, 1, strlen(data), f);
  fclose(f);
}

int main() {
#define GOOD_PATH "/tmp/good-config"
#define BAD_PATH "/tmp/bad-config"

  write_config(GOOD_PATH, valid_test_config);
  write_config(BAD_PATH, invalid_test_config);

  auto &conf = jutils::simple::SimpleConfig::create_config(GOOD_PATH);
  conf.dump(stdout);
  assert(strcmp(conf.get("d")->c_str(), "4") == 0);
  assert(strcmp(conf.get("a")->c_str(), "1") == 0);
  assert(strcmp(conf.get("b")->c_str(), "3") == 0);
  conf.put("asdasd", "123");
  assert(strcmp(conf.get("asdasd")->c_str(), "123") == 0);

  bool thrown = false;
  try {
    jutils::config::SimpleConfig::create_config(BAD_PATH);
  } catch (std::runtime_error &e) {
    thrown = true;
  }
  assert(thrown);


  return 0;
}
