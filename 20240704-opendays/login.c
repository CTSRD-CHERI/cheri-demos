#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "login.h"

static void
do_login(void)
{
	char *argv[2] = {
		"./shell",
		NULL
	};

	execve(argv[0], (char **)&argv, NULL);
}

int
main(void)
{
	char result;
	char name[] = USER;
	char input[sizeof(PASSWORD)];
	int index;
	char c;

	result = 0;
	for (;;) {
		printf("Hello, %s!\n", name);
		printf("password: ");

		index = 0;
		while ((c = getchar()) != '\n')
			input[index++] = c;
		input[index] = '\0';

		if (strcmp(input, PASSWORD) == 0)
			result = 1;

		if (result != 0) {
			printf("\nSuccess! Type 'exit' to log out.\n\n");
			do_login();
			break;
		} else {
			printf("Wrong password. Try again.\n\n");
		}
	}

	return (0);
}
