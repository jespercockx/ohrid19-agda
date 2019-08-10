#include <stdio.h>
#define printInt(e) printf("%d\n",e)

int main () {
  printInt(3>5 && 5>3 ? 5+8 : 1+1);
}
