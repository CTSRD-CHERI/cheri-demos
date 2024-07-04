all: login-cheri login-fixed login-unsafe shell

USER=		admin
GROUP=		admin
PASSWORD=	cherries
UID=		10000
GID=		10000

.PHONY: all

login.h: login.h.in
	cp login.h.in login.h
	@sed -i "" "s/%%USER%%/${USER}/" login.h
	@sed -i "" "s/%%PASSWORD%%/${PASSWORD}/" login.h

login-cheri: login.h login.c
	cc -g -o login-cheri login.c

login-fixed: login.h login-fixed.c
	cc -g -mabi=aapcs -o login-fixed login-fixed.c

login-unsafe: login.h login.c
	cc -g -mabi=aapcs -o login-unsafe login.c

shell: shell.c
	sudo pw groupadd ${GROUP} -g ${GID} || true
	sudo pw useradd ${USER} -m -u ${UID} -g ${GID} || true
	@sudo sh -c 'echo ${PASSWORD} >/home/${USER}/flag'
	cc -o shell shell.c
	sudo chown ${USER}:${GROUP} shell
	sudo chmod 4755 shell

clean:
	rm -f login.h login-cheri login-fixed login-unsafe shell
