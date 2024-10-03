#include <stdio.h>

#define	BUFLEN	128

int check_password(char *);
const char *get_data();

int main() {
	char buf[BUFLEN];
	if (scanf("%127s", buf) == 0) {
		puts("scanf failed");
		return -1;
	}
	if (!check_password(buf)) {
		puts("wrong password");
		return -2;
	}
	printf("correct password, the data is %s\n", get_data());
	return 0;
}
