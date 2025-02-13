#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

/*
 * Show sentry capabilities protecting control flow from manipulation.
 */
volatile int x = 1;

static void
func(void)
{
	if (!x) printf("Invalid control flow\n");
	exit(1);
}

int
main(int argc, char *argv[])
{
	/* Construct + call a code pointer that skips the (!x) test. */
	void (*funcp)(void) = (void (*)(void))((uintptr_t)&func + 28);
	(*funcp)();
}
