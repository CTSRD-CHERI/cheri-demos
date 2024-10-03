CC=cc

LDFLAGS=-Wl,-rpath=.

obj: main.c password_checker.c database.c
	$(CC) -c -Og main.c password_checker.c database.c

all: obj
	$(CC) password_checker.o -shared -o password_checker.so -Wl,-soname,password_checker.so
	$(CC) database.o -shared -o database.so -Wl,-soname,database.so
	$(CC) main.o password_checker.so database.so $(LDFLAGS) -o main
	objcopy -T password_checker.so -T database.so main unified_main

clean:
	rm main password_checker.so database.so main.o password_checker.o database.o unified_main
