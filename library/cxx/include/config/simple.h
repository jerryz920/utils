
#ifndef _JUTILS_CONFIG_SIMPLE_H
#define _JUTILS_CONFIG_SIMPLE_H

#include "../config.h"

#ifdef __cplusplus
namespace jutils {
namespace simple {

const Config& create_config(const std::string &path);

}
}

extern "C" {
#endif

static inline const JConfig *create_simple_config(const char *path) {
  return jutils::simple::create_config(path).jconfig();
}

const JConfig *get_simple_config();
const char *get_simple_config_item(const JConfig *conf, const char *key);
void put_simple_config_item(const JConfig *conf, const char *key, const char *value);

#ifdef __cplusplus
}

#endif


#endif
