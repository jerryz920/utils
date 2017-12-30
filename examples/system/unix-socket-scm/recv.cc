

#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdlib.h>
#include <stdio.h>

int main() {

  int s = socket(AF_UNIX, SOCK_STREAM, 0);
  struct sockaddr_un un;

  un.sun_family = AF_UNIX;
  strcpy(un.sun_path, "testunix-socket");

  int reuse = 1;
  setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));

  if (bind(s, (struct sockaddr*) &un, sizeof(un)) < 0) {
    perror("bind");
    exit(1);
  }
  if (listen(s, 100) < 0) {
    perror("listen");
    exit(1);
  }

  while(1) {

    struct sockaddr_un cun;
    socklen_t clen = sizeof(cun);

    int c = accept(s, (struct sockaddr*) &cun, &clen);
    if (c < 0) { 
      perror("accept");
      break;
    }

    struct ucred cred;
    socklen_t credlen = sizeof(cred);
    if (getsockopt(c, SOL_SOCKET, SO_PEERCRED, &cred, &credlen) < 0) {
      perror("getcred");
      break;
    }
    printf("recv cred: %u %u %u\n", cred.pid, cred.uid, cred.gid);
    close(c);
  }


  close(s);

  return 0;
}
