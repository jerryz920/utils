
#ifndef JUTILS_FS_H
#define JUTILS_FS_H

#include <sys/stat.h>
#include <unistd.h>




#ifdef __cplusplus
extern "C" {
#endif

static inline int is_file_exist(const char *path) {
  struct stat s;
  if (lstat(path, &s) == 0) {
    return 1;
  }
  /// error is considered as "non-exist"
  return 0;
}



#ifdef __cplusplus
}
#endif



#endif
