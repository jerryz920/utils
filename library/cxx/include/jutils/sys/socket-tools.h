
#ifndef _JUTILS_SYS_SOCKET_TOOL_H
#define _JUTILS_SYS_SOCKET_TOOL_H

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string>
#include <string.h>
#include "errors.h"


namespace jutils {

  static int reliable_send(int fd, const char *buffer, int size) {
    while (size > 0) {
      auto ret = send(fd, buffer, size, MSG_NOSIGNAL);
      if (ret < 0) {
        if (errno == EAGAIN) {
          continue;
        }
        return errno;
      } else if (ret == 0) {
        /// other side closes
        return UNEXPECTED_CLOSE;
      } else {
        buffer += ret;
        size -= ret;
      }
    }
    return 0;
  }

  static int reliable_recv(int fd, char *buffer, int size) {
    while (size > 0) {
      auto ret = recv(fd, buffer, size, 0);
      if (ret < 0) {
        if (errno == EAGAIN) {
          continue;
        }
        return errno;
      } else if (ret == 0) {
        /// other side closes
        return UNEXPECTED_CLOSE;
      } else {
        buffer += ret;
        size -= ret;
      }
    }
    return 0;
  }

  static int unix_stream_conn(const std::string &path) {
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) {
      return fd;
    }

    struct sockaddr_un addr;
    addr.sun_family = AF_UNIX;
    if (path.size() >= sizeof(addr.sun_path)) {
      close(fd);
      return -1;
    }
    strncpy(addr.sun_path, path.c_str(), path.size());
    // just to make sure
    addr.sun_path[path.size()] = '\0';

    if (connect(fd, (struct sockaddr*) &addr, sizeof(addr)) < 0) {
      close(fd);
      return -1;
    }

    return fd;
  }

  static int unix_stream_listener(const std::string &path) {
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) {
      return fd;
    }

    struct sockaddr_un addr;
    addr.sun_family = AF_UNIX;
    if (path.size() >= sizeof(addr.sun_path)) {
      close(fd);
      return -1;
    }
    strncpy(addr.sun_path, path.c_str(), path.size());
    // just to make sure
    addr.sun_path[path.size()] = '\0';

    if (bind(fd, (struct sockaddr*) &addr, sizeof(addr)) < 0) {
      close(fd);
      return -1;
    }

    if (listen(fd, 100) < 0) {
      close(fd);
      return -1;
    }
    return fd;
  }



}


#endif
