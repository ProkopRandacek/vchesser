#include <stdlib.h>
#include <stdio.h>

#include "bitboard.h"

// create default state
state* sdefault(void) {
	state* s = malloc(sizeof(state));

	s->black.pawn = 0;
	for (int i = 0; i < 8; i++) s->black.pawn |= mask(i, 1);
	s->black.rook   = mask(0, 0) | mask(7, 0);
	s->black.knight = mask(1, 0) | mask(6, 0);
	s->black.bishop = mask(2, 0) | mask(5, 0);
	s->black.king   = mask(3, 0);
	s->black.queen  = mask(4, 0);

	s->white.pawn = 0;
	for (int i = 0; i < 8; i++) s->white.pawn |= mask(i, 6);
	s->white.rook   = mask(0, 7) | mask(7, 7);
	s->white.knight = mask(1, 7) | mask(6, 7);
	s->white.bishop = mask(2, 7) | mask(5, 7);
	s->white.queen  = mask(3, 7);
	s->white.king   = mask(4, 7);

	return s;
}

int main(void) {
	state* s = sdefault();

	fstateprint(*s);

	uint64_t mask;
	mask = 1 << 8;
	bprint(mask);
	mask = 1;
	mask <<= 8;
	bprint(mask);


	free(s);

	return 0;

	//useful:
	//__builtin_clzl
	//__builtin_ctzl
	//__builtin_popcount
	//__builtin_bswap64
	//__builtin_ffs
}

