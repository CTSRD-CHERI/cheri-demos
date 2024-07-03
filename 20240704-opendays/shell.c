#include <unistd.h>

#include "login.h"

int
main(void)
{
	char *argv[] = { "/bin/sh", NULL };
	char *envv[] = { "PS1=\\u@\\h:\\w \\$ ", "HOME=/usr/home/" USER, NULL };

	chdir("/home/" USER);
	execve(argv[0], (char **)&argv, (char **)&envv);
	return (0);
}
