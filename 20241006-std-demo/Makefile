AARCH_ALL=buffer-overflow-aarch64 use-after-free-aarch64 ptr-type-confusion-aarch64 ipc-ptr-aarch64
CHERI_ALL=buffer-overflow-cheri use-after-free-cheri ptr-type-confusion-cheri ipc-ptr-cheri monotonicity-cheri

AARCH_CC=clang		# aarch64
CHERI_CC=cc		# aarch64c

all: ${AARCH_ALL} ${CHERI_ALL}

buffer-overflow-aarch64: buffer-overflow.c
	${AARCH_CC} -Wall -g -o buffer-overflow-aarch64 buffer-overflow.c

use-after-free-aarch64: use-after-free.c
	${AARCH_CC} -Wall -g -o use-after-free-aarch64 use-after-free.c

ptr-type-confusion-aarch64: ptr-type-confusion.c
	${AARCH_CC} -Wall -g -o ptr-type-confusion-aarch64 ptr-type-confusion.c

ipc-ptr-aarch64: ipc-ptr.c
	${AARCH_CC} -Wall -g -o ipc-ptr-aarch64 ipc-ptr.c

buffer-overflow-cheri: buffer-overflow.c
	${CHERI_CC} -Wall -g -o buffer-overflow-cheri buffer-overflow.c

use-after-free-cheri: use-after-free.c
	${CHERI_CC} -Wall -g -o use-after-free-cheri use-after-free.c

ptr-type-confusion-cheri: ptr-type-confusion.c
	${CHERI_CC} -Wall -g -o ptr-type-confusion-cheri ptr-type-confusion.c

ipc-ptr-cheri: ipc-ptr.c
	${CHERI_CC} -Wall -g -o ipc-ptr-cheri ipc-ptr.c

# Relies on CHERI C extensions
monotonicity-cheri: monotonicity.c
	${CHERI_CC} -Wall -g -o monotonicity-cheri monotonicity.c

clean:
	rm -f ${AARCH_ALL} ${CHERI_ALL} *.core
