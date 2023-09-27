USER=			demo

USER_HOME=		/home/${USER}

PACKAGES_CHERIABI=	git

PACKAGES_HYBRIDABI=	llvm-base
PACKAGES_HYBRIDABI+=	gdb-cheri

REPOS=			cheri-exercises.git
REPOS+=			chericat.git

all: ${PACKAGES_CHERIABI} ${PACKAGES_HYBRIDABI} ${REPOS} overlay chericat

${PACKAGES_CHERIABI}:
	sudo pkg64c install $@

${PACKAGES_HYBRIDABI}:
	sudo pkg64 install $@

${REPOS}:
	if [ ! -d "${USER_HOME}/${@:C/.git$//}" ]; then \
		git clone https://github.com/CTSRD-CHERI/$@ ${USER_HOME}/${@:C/.git$//}; \
	fi

overlay:
	sudo cp -a overlay/ /

chericat:
	make -C ${USER_HOME}/chericat
