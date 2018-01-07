
#include "scope.h"
using namespace jutils;
static void func(int a, int b, int c ,int d)
{
  printf("%d\n", a+b+c+d);
}

static void test_guard()
{
  delay(func, 1,2,3,4);
}

int main() {
  test_guard();
}
