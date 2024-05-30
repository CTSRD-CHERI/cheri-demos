#include <sys/param.h>

#include <stdio.h>
#include <stdlib.h>

#include "libmalicious/malicious.h"

int
main(void)
{
	char c;
	void *csp;

	c = 'A';

	printf("%12s: c='%c'\n", "main", c);
	printf("%12s: &c=0x%#p\n", "main", &c);

	asm ("mov	%0, csp" : "=C" (csp));
	printf("%12s: csp=%#p\n", "main", csp);

	lib_function();

	printf("%12s: c='%c'\n", "main", c);

	/*
	 * Use exit(3) instead of return not to use potentially overwritten
	 * function return address from the stack.
	 */
	exit(0);
}
