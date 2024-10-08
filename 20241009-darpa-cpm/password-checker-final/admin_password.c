#include <stdbool.h>
#include <string.h>

#include "check_password.h"

char admin_password[] = "admin100";

bool admin_check_password(char *password) {
    return strcmp(password, admin_password) == 0;
}
