#include <stdio.h>
int x=1;
int secret_key = 4091;
int main() {
	int *p = &x;
	p = p+1;
	int y= *p;
	printf("%d\n",y);
}
