#ifndef STATE_H
#define STATE_H

#include "bitboard.h"

typedef struct pieces {
	bb_t king;
	bb_t queen;
	bb_t rook;
	bb_t bishop;
	bb_t knight;
	bb_t pawn;
} pieces;

typedef struct state {
	pieces black;
	pieces white;
} state;

#endif
