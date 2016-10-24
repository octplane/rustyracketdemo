#include <stdio.h>

extern char* some_content();

int main() {

  char* ret = some_content();
  printf("Got: \"%s\"\n", ret);
  return 0;
}
