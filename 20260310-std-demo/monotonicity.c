#include <sys/types.h>
#include <cheri/cheri.h>
#include <cheri/cheric.h>
#include <assert.h>
#include <stdio.h>

static int a, *ap = &a;

int
main(int argc, char **argv)
{

	assert(cheri_getlen(ap) == sizeof(a));

	/* Attempt a non-monotonic expansion of bounds on 'a'. */
	ap = cheri_setbounds(ap, sizeof(a) * 2);

	/* Attempt a dereference outside of the original bounds. */
	printf("ap[1]: %d\n", ap[1]);
}
