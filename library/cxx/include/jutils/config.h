
#ifndef JUTILS_CONFIG_H
#define JUTILS_CONFIG_H


#ifdef __cplusplus
extern "C" {
#endif
#include <stddef.h>
#include <time.h>
#include <limits.h>

struct JConfig {
  char path[PATH_MAX];
  /// linux specific
  struct timespec mod_time;
  void *handle;
};

#define MAX_LINE 1024

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
/// C++ helper
#include <string>
#include <memory>
class Config {

  public:
    Config(const Config &config) = delete;
    Config& operator = (const Config &) = delete;

    Config(JConfig *config): Config(std::shared_ptr<JConfig>(config)) {
    }
    Config(std::shared_ptr<JConfig> config): jconfig_(config) {
      jconfig_->handle = (void*) this;
    }
    Config(Config &&config): jconfig_(std::move(config.jconfig_)) {
      jconfig_->handle = (void*) this;
    }
    Config& operator = (Config &&config) {
      jconfig_ = std::move(config.jconfig_);
      jconfig_->handle = (void*) this;
      return *this;
    }
    JConfig *jconfig() { return jconfig_.get(); }
    virtual const std::string* get(const std::string &config) const = 0;
    virtual void put(const std::string &key, const std::string &value) = 0;
    virtual void dump(FILE* f) = 0;

  private:
    std::shared_ptr<JConfig> jconfig_;
};
#endif


#endif
