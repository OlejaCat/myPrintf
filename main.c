#include <stdio.h>

int myPrintf(const char* text, ...);

int main()
{
	int n;
	myPrintf("Write your number: ");
	scanf("%d", &n);
	myPrintf("Hello world x%d times!\n", n);

	return 0;
}
