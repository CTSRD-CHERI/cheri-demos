#include <stdio.h>
#include <stdbool.h>
#include <string.h>

char user_password[] = "user123";
char admin_password[] = "admin100";

bool user_check_password(char *password) {
    return strcmp(password, user_password) == 0;
}

bool admin_check_password(char *password) {
    return strcmp(password, admin_password) == 0;
}

int main(int argc, char *argv[]) {
    char *password = argv[1];
    if (user_check_password(password)) {
        printf("logged in as user\n");
    } else if (admin_check_password(password)) {
        printf("logged in as admin\n");
    } else {
        printf("not logged in\n");
    }
}
