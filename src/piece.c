#include <stdio.h>

#include "piece.h"

/*
 *
 * 000000 0     000  000 000
 * freeee color type x   y
 */

void bprint(unsigned short c) {
	printf("c%c", (c & (1 << 9)) ? '1' : '0');
	printf("t");
	for (int i = 8; i >= 6; i--)
		printf("%c", (c & (1 << i)) ? '1' : '0');
	printf("y");
	for (int i = 5; i >= 3; i--)
		printf("%c", (c & (1 << i)) ? '1' : '0');
	printf("x");
	for (int i = 2; i >= 0; i--)
		printf("%c", (c & (1 << i)) ? '1' : '0');
	printf("\n");
}

