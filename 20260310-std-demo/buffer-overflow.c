#include <sys/types.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char c;
char buffer[16];
char *bp = buffer;

int
main(int argc, char *argv[])
{

	assert((uintptr_t)&c == (uintptr_t)buffer + 16);

	memset(bp, 'B', sizeof(buffer) + 1);
	printf("%c\n", c);
	exit(1);
}
