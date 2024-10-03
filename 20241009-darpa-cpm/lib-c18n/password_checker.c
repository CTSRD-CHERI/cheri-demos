int check_password(char *buf) {

	char *cur = "Password";

	if (!buf)
		return 0;
	while (*cur == *buf++)
		if (*cur++ == '\0')
			return 1;
	return 0;
}
