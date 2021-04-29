#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define clzl __builtin_clzl
#define ctzl __builtin_ctzl

#include "bitboard.h"

const char b64[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

void bprint(bb_t bb) {
	for (int i = 0; i < 64; i++) { printf("%c", b64[i]); } // the base64 ruler
	printf("\n");

	int tz = ctzl(bb);
	int lz = clzl(bb);
	bb_t mask = 1;

	for (int i = 0; i < tz; i++) printf("0"); // skip zeros at the start
	mask <<= tz;
	for (int i = tz; i < 64 - lz; i++) {
		printf("%c", (bb & mask) ? '1' : '0');
		mask <<= 1;
	}
	for (int i = 0; i < lz; i++) printf("0"); // skip zeros at the end


	printf("\n");
}

void bbprint(bb_t bb) {
	for (int y = 0; y < 8; y++) {
		for (int x = 0; x < 8; x++) {
			printf("%c ", (bb & 1) ? '1' : '0');
			bb = bb >> 1;
		}
		printf("\n");
	}
}

void fbbprint(bb_t bb) {
	printf("    0 1 2 3 4 5 6 7\n");
	printf("  +-----------------+\n");
	for (int y = 0; y < 8; y++) {
		printf("%d | ", y);
		for (int x = 0; x < 8; x++) {
			printf("%c ", (bb & 1) ? '1' : '0');
			bb = bb >> 1;
		}
		printf("| %d\n", y);
	}
	printf("  +-----------------+\n");
	printf("    1 2 3 4 5 6 7 8\n");
}

// this is really slow
void fstateprint(state s) {
	char board[64];
	memset(board, ' ', sizeof(board));

	int tz, lz;
	int loops = 0;
	bb_t mask;

	tz = ctzl(s.black.pawn  ); lz = clzl(s.black.pawn  ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.black.pawn   & mask) board[i] = 'P'; mask <<= 1; loops++; }
	tz = ctzl(s.black.rook  ); lz = clzl(s.black.rook  ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.black.rook   & mask) board[i] = 'R'; mask <<= 1; loops++; }
	tz = ctzl(s.black.king  ); lz = clzl(s.black.king  ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.black.king   & mask) board[i] = 'K'; mask <<= 1; loops++; }
	tz = ctzl(s.black.queen ); lz = clzl(s.black.queen ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.black.queen  & mask) board[i] = 'Q'; mask <<= 1; loops++; }
	tz = ctzl(s.black.bishop); lz = clzl(s.black.bishop); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.black.bishop & mask) board[i] = 'B'; mask <<= 1; loops++; }
	tz = ctzl(s.black.knight); lz = clzl(s.black.knight); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.black.knight & mask) board[i] = 'N'; mask <<= 1; loops++; }
	tz = ctzl(s.white.pawn  ); lz = clzl(s.white.pawn  ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.white.pawn   & mask) board[i] = 'p'; mask <<= 1; loops++; }
	tz = ctzl(s.white.rook  ); lz = clzl(s.white.rook  ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.white.rook   & mask) board[i] = 'r'; mask <<= 1; loops++; }
	tz = ctzl(s.white.king  ); lz = clzl(s.white.king  ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.white.king   & mask) board[i] = 'k'; mask <<= 1; loops++; }
	tz = ctzl(s.white.queen ); lz = clzl(s.white.queen ); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.white.queen  & mask) board[i] = 'q'; mask <<= 1; loops++; }
	tz = ctzl(s.white.bishop); lz = clzl(s.white.bishop); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.white.bishop & mask) board[i] = 'b'; mask <<= 1; loops++; }
	tz = ctzl(s.white.knight); lz = clzl(s.white.knight); mask = 1; mask <<= tz; for (int i = tz; i < 64 - lz; i++) { if (s.white.knight & mask) board[i] = 'n'; mask <<= 1; loops++; }

	printf("%d\n", loops);
	printf("    0 1 2 3 4 5 6 7\n");
	printf("  +-----------------+\n");
	for (int y = 0; y < 8; y++) {
		printf("%d | ", y);
		for (int x = 0; x < 8; x++) {
			printf("%c ", board[y * 8 + x]);
		}
		printf("| %d\n", y);
	}
	printf("  +-----------------+\n");
	printf("    1 2 3 4 5 6 7 8\n");
}

void bbhmove(bb_t* bb, int o) {
	if      (o > 0) *bb = *bb << o *  8;
	else if (o < 0) *bb = *bb >> o * -8;
}

