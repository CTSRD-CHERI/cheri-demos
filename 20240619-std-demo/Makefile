ALL=buffer-overflow use-after-free ptr-type-confusion ipc-ptr
#CC=clang		# aarch64
CC=cc			# aarch64c

all: ${ALL}

buffer-overflow: buffer-overflow.c
	${CC} -Wall -g -o buffer-overflow buffer-overflow.c

use-after-free: use-after-free.c
	${CC} -Wall -g -o use-after-free use-after-free.c

ptr-type-confusion: ptr-type-confusion.c
	${CC} -Wall -g -o ptr-type-confusion ptr-type-confusion.c

ipc-ptr: ipc-ptr.c
	${CC} -Wall -g -o ipc-ptr ipc-ptr.c

clean:
	rm -f ${ALL} *.core
