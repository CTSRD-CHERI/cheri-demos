#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

/* u.u_int64 and u.u_ptr's address field are in the same storage. */
union {
	char		*u_ptr;
	uint64_t	 u_int64;
} u;
char	c_array[2] = "AB";

int
main(int argc, char *argv[])
{

	u.u_ptr = &c_array[0];		/* Pointer to first entry. */
	u.u_int64++;			/* Increment address. */
	printf("%c\n", *u.u_ptr);	/* Dereference pointer. */
	exit(1);
}
