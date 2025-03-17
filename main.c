int myPrintf(const char* text, ...);

int main()
{
	myPrintf("%d %s %x %d%%%c%b\n", -1, "love", 3802, 100, 33, 126);

	return 0;
}
