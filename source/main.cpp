#include <stdio.h>

#include "myPrintf.h"


int main()
{
	int c = myPrintf("%s %x %d%%%c%b\n", "love", 3802, 100, 33, 126);
    myPrintf("%d\n", c);
	// c = printf("%v %x %d%%%c%b\n", "love", 3802, 100, 33, 126);
    // myPrintf("%d\n", c);

	return 0;
}
