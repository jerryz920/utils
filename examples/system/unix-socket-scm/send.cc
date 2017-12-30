
#include <sys/socket.h>
#include <unistd.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>

int main() {

  int c = socket(AF_UNIX, SOCK_STREAM, 0);
  struct sockaddr_un un;
  un.sun_family = AF_UNIX;
  strcpy(un.sun_path, "testunix-socket");

  if (connect(c, (struct sockaddr*) &un, sizeof(un)) < 0) {
    perror("connect");
    exit(1);
  }
  sleep(1);
  close(c);
  pid_t p = getpid();
  printf("pid is %d\n", p);

  return 0;
}
