enum Color {
	white = 0 // lower
	black = 1 // upper
}

enum Piece {
	empty = -1 // Only used for `Move` when the move is not describing a pawn promotion. (basically always)
	pawn = 0
	knight = 1
	bishop = 2
	rook = 3
	queen = 4
	king = 5
}

struct Board {
mut:
	pieces [][]u64 = [][]u64{len: 2, init: []u64{len: 6, init: 0}} // 2d array 2x6 -> 2 players with 6 bitboards(/pieces) each.
	color  Color
}

fn (mut b Board) init_default() { // sets the board state to default (used only at the start of the game)
	b.color = Color.white

	for i in 0 .. 8 {
		b.pieces[Color.black][Piece.pawn] |= mask(i, 1)
	}
	for i in 0 .. 8 {
		b.pieces[Color.white][Piece.pawn] |= mask(i, 6)
	}

	// upper
	b.pieces[Color.black][Piece.rook] = mask(0, 0) | mask(7, 0)
	b.pieces[Color.black][Piece.knight] = mask(1, 0) | mask(6, 0)
	b.pieces[Color.black][Piece.bishop] = mask(2, 0) | mask(5, 0)
	b.pieces[Color.black][Piece.king] = mask(4, 0)
	b.pieces[Color.black][Piece.queen] = mask(3, 0)

	// lower
	b.pieces[Color.white][Piece.rook] = mask(0, 7) | mask(7, 7)
	b.pieces[Color.white][Piece.knight] = mask(1, 7) | mask(6, 7)
	b.pieces[Color.white][Piece.bishop] = mask(2, 7) | mask(5, 7)
	b.pieces[Color.white][Piece.king] = mask(4, 7)
	b.pieces[Color.white][Piece.queen] = mask(3, 7)
}

fn (b Board) piece_on(pos byte, color Color) ?Piece { // return what piece is on given position
	for i in 0 .. 6 {
		if (b.pieces[color][i] & ones[pos]) != 0 {
			return Piece(i)
		}
	}
	return error('asked position is empty') // Considering when this fnc is called, this should never happen
}

fn (mut b Board) clear_pos(pos byte) { // Clears position (sets all bitboards' bits on position `pos` to zero )
	mask := ~ones[pos]
	for c in 0 .. 2 {
		for p in 0 .. 6 {
			b.pieces[c][p] &= mask
		}
	}
}

fn (b Board) apply_move(m Move) Board {
	mut piece := m.promo
	if m.promo == Piece.empty {
		piece = b.piece_on(m.src, b.color) or { exit(0) }
	}

	mut nb := b

	nb.clear_pos(m.src)
	nb.clear_pos(m.dst) // when capturing
	nb.pieces[b.color][piece] |= ones[m.dst]

	return b
}
