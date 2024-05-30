ALL=buffer-overflow use-after-free ptr-type-confusion
#CC=clang		# aarch64
CC=cc			# aarch64c

all: ${ALL}

buffer-overflow: buffer-overflow.c
	${CC} -Wall -g -o buffer-overflow buffer-overflow.c

use-after-free: use-after-free.c
	${CC} -Wall -g -o use-after-free use-after-free.c

ptr-type-confusion: ptr-type-confusion.c
	${CC} -Wall -g -o ptr-type-confusion ptr-type-confusion.c

clean:
	rm -f ${ALL} *.core
