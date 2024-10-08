#include <stdbool.h>
#include <string.h>

#include "check_password.h"

char user_password[] = "user123";

bool user_check_password(char *password) {
    return strcmp(password, user_password) == 0;
}
