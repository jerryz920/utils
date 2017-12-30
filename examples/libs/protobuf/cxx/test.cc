
#include "example.pb.h"
#include <stdio.h>
#include <iostream>
#include <fstream>

using namespace std;
int main()
{
  GOOGLE_PROTOBUF_VERIFY_VERSION;
  
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

  fstream in("tmp", ios::in | ios::binary);
  
  test::Test t1;
  t1.ParseFromIstream(&in);
  printf("read in pids size : %d\n", t1.pids_size());
  printf("any is %d\n", t1.msg().Is<test::Test>());
  return 0;
  
  
  
}
