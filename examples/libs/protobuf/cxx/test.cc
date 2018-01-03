
#include "example.pb.h"
#include <stdio.h>
#include <iostream>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <fstream>
#include <thread>

using namespace std;
static const char* ep = "test-socket";
static int tcps[2];

void server_thread()
{
  int s = socket(AF_UNIX, SOCK_DGRAM, 0);
  char buffer[1024];
  struct sockaddr_un addr;
  socklen_t addrlen = sizeof(addr) - 2;
  struct sockaddr_un baddr;
  baddr.sun_family = AF_UNIX;
  strcpy(baddr.sun_path, ep);
  if (bind(s, (struct sockaddr*) &baddr, sizeof(baddr)) < 0) {
    perror("bind");
    return;
  }
  ssize_t ret = recvfrom(s, buffer, 1024, 0, (struct sockaddr*) &addr, &addrlen);
  if (ret < 0) {
    perror("recvfrom");
    return ;
  }
  printf("received addr: ");
  for (int i = 0; i < 20; i++) {
    printf("%x ", addr.sun_path[i]);
  }
  printf("\nreceived size = %zd\n", ret);

  test::Test t;
  if (!t.ParseFromArray(buffer, ret)) {
    printf("failed to parse from buffer\n");
    return;
  }

  if (t.pids_size() != 1) {
    printf("error pid cnt %d\n", t.pids_size());
    return;
  }
  auto any = t.msg();
  test::Test ta;
  any.UnpackTo(&ta);
  printf("pid = %lu, any is test %d, ta id = %d\n", t.pids(0), any.Is<test::Test>(), ta.id());
  ta.set_id(15);
  test::Test ta1;
  any.UnpackTo(&ta1);
  printf("pid = %lu, any is test %d, ta1 id = %d\n", t.pids(0), any.Is<test::Test>(), ta1.id());
  close(s);
  printf("test tcp\n");


  test::Test t1;
  t1.ParseFromFileDescriptor(tcps[1]);
  printf("received t1\n");
  printf("t1 pid size: %d\n", t1.pids_size());
  printf("t2 2nd pid %lu\n", t1.pids(1));
  close(tcps[1]);


}



int main()
{
  GOOGLE_PROTOBUF_VERIFY_VERSION;
  unlink(ep);
  socketpair(AF_UNIX, SOCK_STREAM, 0, tcps);
  std::thread pr(server_thread);
  
  test::Test t;
  t.add_pids(100);
  t.set_id(1);
  auto any = t.mutable_msg();
  test::Test another;
  another.set_id(2);
  any->PackFrom(another);
  printf("any is %d\n", any->Is<test::Test>());


  fstream out("tmp", ios::out | ios::trunc | ios::binary);
  t.SerializeToOstream(&out);
  out.close();
  printf("byte size = %zu %d %d\n", t.ByteSizeLong(), t.ByteSize(), t.GetCachedSize());

  fstream in("tmp", ios::in | ios::binary);
  
  test::Test t1;
  t1.ParseFromIstream(&in);
  printf("read in pids size : %d\n", t1.pids_size());
  printf("any is %d\n", t1.msg().Is<test::Test>());

  int c = socket(AF_UNIX, SOCK_DGRAM, 0);
  struct sockaddr_un addr;
  addr.sun_family = AF_UNIX;
  strcpy(addr.sun_path, ep);
  if (connect(c, (struct sockaddr*) &addr, sizeof(addr)) < 0) {
    perror("connect");
    exit(1);
  }
  t.SerializeToFileDescriptor(c);

  t.add_pids(200);
  t.SerializeToFileDescriptor(tcps[0]);
  printf("send t2\n");
  close(tcps[0]);
  // shutdown(tcps[0], SHUT_WR); will be enough


  pr.join();

  return 0;
}
