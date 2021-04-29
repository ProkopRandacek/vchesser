#ifndef BITBOARD_H
#define BITBOARD_H
#define bb_t uint64_t

#include <stdint.h>

#include "bbmask.h"
#include "state.h"


void bprint(bb_t bb);
void bbprint(bb_t bb);
void fbbprint(bb_t bb);
// positive o moves down
void bbhmove(bb_t* bb, int o);
void fstateprint(state s);

#endif
