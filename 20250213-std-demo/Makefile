AARCH_ALL=buffer-overflow-aarch64 use-after-free-aarch64 ptr-type-confusion-aarch64 ipc-ptr-aarch64 sentry-aarch64
CHERI_ALL=buffer-overflow-cheri use-after-free-cheri ptr-type-confusion-cheri ipc-ptr-cheri monotonicity-cheri readonly-ptr-cheri sentry-cheri

AARCH_CC=clang		# aarch64
CHERI_CC=cc		# aarch64c
CFLAGS=-Wall -g

all: ${AARCH_ALL} ${CHERI_ALL}

buffer-overflow-aarch64: buffer-overflow.c
	${AARCH_CC} ${CFLAGS} -o buffer-overflow-aarch64 buffer-overflow.c

use-after-free-aarch64: use-after-free.c
	${AARCH_CC} ${CFLAGS} -o use-after-free-aarch64 use-after-free.c

ptr-type-confusion-aarch64: ptr-type-confusion.c
	${AARCH_CC} ${CFLAGS} -o ptr-type-confusion-aarch64 ptr-type-confusion.c

ipc-ptr-aarch64: ipc-ptr.c
	${AARCH_CC} ${CFLAGS} -o ipc-ptr-aarch64 ipc-ptr.c

sentry-aarch64: sentry.c
	${AARCH_CC} ${CFLAGS} -o sentry-aarch64 sentry.c

buffer-overflow-cheri: buffer-overflow.c
	${CHERI_CC} ${CFLAGS} -o buffer-overflow-cheri buffer-overflow.c

use-after-free-cheri: use-after-free.c
	${CHERI_CC} ${CFLAGS} -o use-after-free-cheri use-after-free.c

ptr-type-confusion-cheri: ptr-type-confusion.c
	${CHERI_CC} ${CFLAGS} -o ptr-type-confusion-cheri ptr-type-confusion.c

ipc-ptr-cheri: ipc-ptr.c
	${CHERI_CC} ${CFLAGS} -o ipc-ptr-cheri ipc-ptr.c

sentry-cheri: sentry.c
	${CHERI_CC} ${CFLAGS} -o sentry-cheri sentry.c

# Relies on CHERI C extensions
monotonicity-cheri: monotonicity.c
	${CHERI_CC} ${CFLAGS} -o monotonicity-cheri monotonicity.c

readonly-ptr-cheri: readonly-ptr.c
	${CHERI_CC} ${CFLAGS} -o readonly-ptr-cheri readonly-ptr.c

clean:
	rm -f ${AARCH_ALL} ${CHERI_ALL} *.core
