#include <stddef.h>
#include <stdio.h>
#include <string.h>

void f(ptraddr_t buf) {
	char *p, c;
	size_t off;

	asm ("mov	%0, csp" : "=C" (p));
	printf("sp = %#p\n", p);
  printf("(Hint: buf starts at at sp+%lu)\n", buf - (ptraddr_t)p);

	printf("Enter an offset: ");
	scanf("%zu", &off);

	printf("Enter a character: ");
	scanf(" %c", &c);

	p[off] = c;
}

int main() {
	char buf[] = "Hello, world!";
	printf("buf = %s\n", buf);
	printf("&buf = %#p\n", buf);
	f((ptraddr_t)&buf);
	printf("buf = %s\n", buf);
	return 0;
}
