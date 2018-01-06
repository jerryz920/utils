
#ifndef _JUTIL_SYS_UNIX_H
#define _JUTIL_SYS_UNIX_H

#include <unistd.h>
#include <sys/un.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <string>
#include <sstream>
#include <tuple>

std::string check_proc(uint64_t pid) {
  std::stringstream exec_path_buf;
  exec_path_buf << "/proc/" << pid << "/exe";
  struct stat s;

  std::string exec_path = exec_path_buf.str();

  if (lstat(exec_path.c_str(), &s) < 0) {
    return "";
  }

  char *execbuf = (char*) malloc(s.st_size + 1);
  if (!execbuf) {
    return "";
  }
  int linksize = readlink(exec_path.c_str(), execbuf, s.st_size + 1);
  if (linksize < 0) {
    free(execbuf);
    return "";
  }
  if (linksize > s.st_size) {
    free(execbuf);
    return "";
  }
  execbuf[linksize] = '\0';
  auto result = std::string(execbuf, execbuf + linksize);
  free(execbuf);
  return result;
}

/// socket helper
std::tuple<pid_t, uid_t, gid_t> unix_auth_id(int fd) {
  struct ucred cred;
  socklen_t size = sizeof(cred);
  if (getsockopt(fd, SOL_SOCKET, SO_PEERCRED, &cred, &size) < 0) {
    /// for safety, don't set uid,gid to 0 (root)
    return std::make_tuple(0, -1, -1);
  }
  return std::make_tuple(cred.pid, cred.uid, cred.gid);
}


#endif
