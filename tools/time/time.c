
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <sys/wait.h>
int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: time [args]\n");
    exit(1);
  }
  struct timeval start, end;
  gettimeofday(&start, NULL);
  pid_t child = fork();
  if (child == 0) {
    return execve(argv[1], &argv[1], NULL);
  } else {
    int status;
    if (waitpid(child, &status, 0) < 0) {
      perror("waitpid");
      return 1;
    }
  gettimeofday(&end, NULL);
    int ret = WEXITSTATUS(status);
    if (ret != 0) {
      exit(ret);
    } else {
      fprintf(stderr, "%lld\n", (end.tv_sec - start.tv_sec) * 1000000LL+ (end.tv_usec - start.tv_usec));
    }
  }

  return 0;
}
