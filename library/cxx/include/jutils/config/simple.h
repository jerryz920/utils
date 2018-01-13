
#ifndef _JUTILS_CONFIG_SIMPLE_H
#define _JUTILS_CONFIG_SIMPLE_H

#include "../config.h"
#include <unordered_map>
#include <string.h>
#include <stdio.h>

#ifdef __cplusplus
namespace jutils {
namespace config {

class SimpleConfig: public Config {

  public:

    static SimpleConfig& get_config() {
      return *instance;
    }

    static SimpleConfig& create_config(const std::string &path);

    const std::string *get(const std::string &key) const override;

    void put(const std::string &key, const std::string &value) override;

    void parse();
    void parse_line(const char *line);

    void dump(FILE* f) override;

    SimpleConfig(JConfig *config): Config(config) {}
    SimpleConfig(std::shared_ptr<JConfig> config): Config(config) {}

  private:
    std::unordered_map<std::string, std::string> configs_;

    static std::shared_ptr<SimpleConfig> instance;

};

}
/// Just for compatibility
namespace simple = config;
}

extern "C" {
#endif

static inline JConfig *create_simple_config(const char *path) {
  return jutils::config::SimpleConfig::create_config(path).jconfig();
}

JConfig *get_simple_config();
static inline const char *get_simple_config_item(const JConfig *conf,
    const char *key) {
  auto result = reinterpret_cast<Config*>(conf->handle)->get(key);
  if (result) {
    return result->c_str();
  }
  return nullptr;
}

static inline void put_simple_config_item(const JConfig *conf, const char *key,
    const char *value) {
  reinterpret_cast<Config*>(conf->handle)->put(key, value);
}

#ifdef __cplusplus
}

#endif


#endif
