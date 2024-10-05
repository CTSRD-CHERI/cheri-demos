#include <stdbool.h>
#include <stdio.h>

#include "check_password.h"

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
