#include <stdio.h>
#define printInt(e) printf("%d\n",e)

int main () {
  int a = 1;
  int b = 2+a;
  int c = 3+b;
  int result = a+b+c;
  printInt(result);
}
