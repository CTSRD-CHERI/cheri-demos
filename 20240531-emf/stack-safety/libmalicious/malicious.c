#include <sys/param.h>

#include <stdio.h>

#include "malicious.h"

#define	STACK_SIZE_CALLER	144
#define	STACK_SIZE_CALLEE	80

void
lib_function(void)
{
	/*
	 * Note that with optimizations this function does not store anything on
	 * the stack.
	 */
	void *csp;
	int ii;

	/*
	 * Get the current capability stack pointer.
	 */
	asm ("mov	%0, csp" : "=C" (csp));
	printf("%12s: csp=%#p\n", "libmalicious", csp);

	/*
	 * Overwrite the stack above lib_function()'s stack contents.
	 */
	for (ii = 0; ii < STACK_SIZE_CALLER; ii++)
		*((char *)csp + STACK_SIZE_CALLEE + ii) = 'B';
}
