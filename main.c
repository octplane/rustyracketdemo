#include <stdio.h>

extern char* replace_all(const char **s, const char **d, int sz, const char *t); 

int main() {
  const char* const src[] = { "a", "z" };
  const char* const dest[] = { "s", "x" };
  const char* transform = "azaz za za";

  char* ret = replace_all(src, dest, 2, transform);
  printf("Got: \"%s\"\n", ret);
  return 0;
}
