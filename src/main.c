#include <stdlib.h>
#include <stdio.h>
#include "list.h"

#define pawn   0b00000000
#define knight 0b00000001
#define bishop 0b00000010
#define rock   0b00000011
#define queen  0b00000100
#define king   0b00000101

#define black  0b00001000
#define white  0b00000000

/*
 * x    - 3 bits
 * y    - 3 bits
 * type - 3 bits
 * clr  - 1 bit
 * free - 6 bits
 * ==============
 *       10 bites -> 2 bytes -> unsigned short
 */

int main(void) {
	int i = atexit(checkatend);
	if (i != 0) fprintf(stderr, "cannot set exit function\n");

	/*piece_t var[4] = {(piece_t)0, (piece_t)1, (piece_t)2, (piece_t)3};

	list* l = linit(4, var);

	lprint(l);

	ldel(l, 3);
	printf("deleted\n");
	lprint(l);
	lappend(l, (piece_t)15);
	printf("added\n");
	lprint(l);

	lfree(l);*/
	bprint(0b0000001000000000);
	bprint(0b0000000111000000);
	bprint(0b0000000000111000);
	bprint(0b0000000000000111);
}
