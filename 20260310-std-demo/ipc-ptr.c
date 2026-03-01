#include <assert.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * Illustrate pointer tag clearing across IPC.  It is an OS policy
 * choice as to whether to propagate tags to limit pointer injection.
 */
int
main(int argc, char *argv[])
{
	char c = 'A', *cp = &c, *rcp = NULL;
	size_t cplen = sizeof(cp), rcplen = sizeof(rcp);
	int fds[2];

	/* Send 'cp' over a pipe; receive as 'rcp'; dereference rcp. */
	assert(pipe(fds) == 0);                             /* Open */
	assert(write(fds[1], &cp, sizeof(cp)) == cplen);    /* Write */
	assert(read(fds[0], &rcp, sizeof(rcp)) == rcplen);  /* Read */
	printf("*rcp: %02x; cp: %p; rcp: %p\n", *rcp, cp, rcp); /* Deref. */
	exit(0);
}
