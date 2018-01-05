
#include "../scope.h"
static int func(int a, int b, int c ,int d)
{
  return a+b+c+d;
}

static void test_guard()
{
  delay(func, 1,2,3,4);
}

