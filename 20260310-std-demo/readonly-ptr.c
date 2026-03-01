#include <sys/types.h>
#include <cheri/cheri.h>
#include <cheri/cheric.h>
#include <assert.h>
#include <stdio.h>

static int a;
static int * __volatile ap = &a;

int
main(int argc, char **argv)
{

	/* Create a read-only pointer for 'a'. */
	ap = cheri_andperm(ap, ~(CHERI_PERM_STORE | CHERI_PERM_STORE_CAP));

	/* Attempt a store. */
	*ap = 0;
}
