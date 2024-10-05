CC=cc

LDFLAGS=-Wl,-rpath=.

all: obj
	$(CC) admin_password.o -shared -o admin_password.so -Wl,-soname,admin_password.so
	$(CC) user_password.o -shared -o user_password.so -Wl,-soname,user_password.so
	$(CC) main.o admin_password.so user_password.so $(LDFLAGS) -o main
	objcopy -T admin_password.so -T user_password.so main unified_main

obj: main.c admin_password.c user_password.c check_password.h
	$(CC) -c -Og main.c admin_password.c user_password.c

clean:
	rm -f main admin_password.{o,so} user_password.{o,so} main.o unified_main
