
#include "config/simple.h"
#include <unordered_map>
#include <string.h>
#include <stdio.h>

namespace jutils {
namespace simple {
class SimpleConfig: public Config {

  public:

    static const SimpleConfig& get_config() {
      return *instance;
    }

    static const SimpleConfig& create_config(const std::string &path) {

      std::shared_ptr<JConfig> config = std::make_shared<JConfig>();
      if (path.size() >= PATH_MAX) {
        throw std::runtime_error("invalid path: too long");
      }
      strncpy(config->path, path.c_str(), path.size());
      instance = std::make_shared<SimpleConfig>(config);
      instance->parse();
      return *instance;
    }

    const std::string *get(const std::string &key) override {
      auto res = configs_.find(key);
      if (res != configs_.end()) {
        return &res->second;
      }
      return nullptr;
    }

    void put(const std::string &key, const std::string &value) override {
      configs_[key] = value;
    }

    void parse() {
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

    void parse_line(const char *line) {

      while (*line && isspace(*line++));
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
      std::string value(split);
      configs_[std::move(key)] = std::move(value);

    }

    void dump() {
      for (auto item: configs_) {
        printf("key [%s], value [%s]\n", item.first.c_str(),
            item.second.c_str());
      }
    }

    SimpleConfig(JConfig *config): Config(config) {}
    SimpleConfig(std::shared_ptr<JConfig> config): Config(config) {}

  private:
    std::unordered_map<std::string, std::string> configs_;

    static std::shared_ptr<SimpleConfig> instance;

};

std::shared_ptr<SimpleConfig> SimpleConfig::instance;

const Config& create_config(const std::string &path) {
  return SimpleConfig::create_config(path);
}

const JConfig *get_simple_jconfig() {
  return SimpleConfig::get_config().jconfig();
}
}





}


