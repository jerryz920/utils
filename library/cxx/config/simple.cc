
#include "jutils/config/simple.h"
#include <unordered_map>
#include <string.h>
#include <stdio.h>

namespace jutils {
namespace config {

SimpleConfig& SimpleConfig::create_config(const std::string &path) {

  std::shared_ptr<JConfig> config = std::make_shared<JConfig>();
  if (path.size() >= PATH_MAX) {
    throw std::runtime_error("invalid path: too long");
  }
  strncpy(config->path, path.c_str(), path.size());
  instance = std::make_shared<SimpleConfig>(config);
  instance->parse();
  return *instance;
}

const std::string* SimpleConfig::get(const std::string &key) const {
  auto res = configs_.find(key);
  if (res != configs_.end()) {
    return &res->second;
  }
  return nullptr;
}

void SimpleConfig::put(const std::string &key, const std::string &value) {
  configs_[key] = value;
}

void SimpleConfig::parse() {
  auto conf = jconfig();
  FILE* f = fopen(conf->path, "r");
  if (!f) {
    throw std::runtime_error("can not open config file");
  }
  char buf[MAX_LINE];
  while (fgets(buf, MAX_LINE, f)) {
    parse_line(buf);
  }
}

void SimpleConfig::parse_line(const char *line) {

  printf("processing %s\n", line);
  while (*line && isspace(*line)) line++;
  if (*line == 0) return; // no content
  /// comment
  if (*line == '#') return ;

  const char *split = strchr(line, '=');
  if (!split) {
    throw std::runtime_error("error configure line, no '=' found");
  }
  const char *keyend = split - 1;
  while (keyend != line && isspace(*keyend)) --keyend;

  std::string key(line, keyend - line + 1);
  ++split;
  while (*split && isspace(*split)) split++;
  const char *vend = split + strlen(split) - 1;
  while (*vend && isspace(*vend)) --vend;

  std::string value(split, vend - split + 1);
  configs_[std::move(key)] = std::move(value);

}

void SimpleConfig::dump(FILE* f) {
  for (auto item: configs_) {
    fprintf(f, "key [%s], value [%s]\n", item.first.c_str(),
        item.second.c_str());
  }
}


std::shared_ptr<SimpleConfig> SimpleConfig::instance;

JConfig *get_simple_jconfig() {
  return SimpleConfig::get_config().jconfig();
}

}





}


