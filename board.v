enum Color {
	white = 0 // lower
	black = 1 // upper
}

fn (c Color) neg() Color {
	return if c == .white { Color.black } else { Color.white }
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
	pieces  [][]u64 = [][]u64{len: 2, init: []u64{len: 6, init: 0}} // 2d array 2x6 -> 2 players with 6 bitboards(/pieces) each.
	color   Color
	attacks []u64 = []u64{len: 2, init: 0}
	bits    byte // rightmost 4 bits are for castling
}

// returns where it is posisble to castle in a given corner
// 0 = top left, 1 = top right, 2 = bottom left, 3 = bottom right
fn (b Board) can_castle(pos byte) bool {
	mask := byte(1 << pos)
	return (b.bits & mask) != 0
}

// disables castling
// 0 = top left, 1 = top right, 2 = bottom left, 3 = bottom right
fn (mut b Board) disable_castle(pos byte) {
	mask := byte(1 << pos)
	b.bits &= ~mask
}

fn (mut b Board) init_default() { // sets the board state to default (used only at the start of the game)
	b.color = Color.white
	b.bits = 0b0000_1111

	/*
	for i in 0 .. 8 {
		b.pieces[Color.black][Piece.pawn] |= mask(i, 1)
	}
	for i in 0 .. 8 {
		b.pieces[Color.white][Piece.pawn] |= mask(i, 6)
	}*/

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

fn (mut b Board) refresh_attacks(c Color) {
	me := get_my(b, int(c) != 0)
	he := get_my(b, int(c) == 0)
	mut att := u64(0)

	mut bb := b.pieces[c][Piece.pawn] // PAWN
	mut i := ctz(bb)
	for _ in 0 .. popcount(bb) {
		att |= get_p_attacks(me, he, i, int(c) != 0)
		i = next(bb, i, 1)
	}
	bb = b.pieces[c][Piece.rook] // ROOK
	i = ctz(bb)
	for _ in 0 .. popcount(bb) {
		att |= get_r_attacks(me, he, i)
		i = next(bb, i, 1)
	}
	bb = b.pieces[c][Piece.knight] // KNIGHT
	i = ctz(bb)
	for _ in 0 .. popcount(bb) {
		att |= get_n_attacks(me, i)
		i = next(bb, i, 1)
	}
	bb = b.pieces[c][Piece.bishop] // BISHOP
	i = ctz(bb)
	for _ in 0 .. popcount(bb) {
		att |= get_b_attacks(me, he, i)
		i = next(bb, i, 1)
	}
	bb = b.pieces[c][Piece.queen] // QUEEN
	i = ctz(bb)
	for _ in 0 .. popcount(bb) {
		att |= get_q_attacks(me, he, i)
		i = next(bb, i, 1)
	}
	bb = b.pieces[c][Piece.king] // KING
	i = ctz(bb)
	for _ in 0 .. popcount(bb) {
		att |= get_k_attacks(me, me | he, b.attacks[int(!(int(b.color) != 0))], i, b)
		i = next(bb, i, 1)
	}

	println(c)
	bbprint(att)
	b.attacks[c] = att
}

fn (mut b Board) apply_move(m Move) Board {
	mut piece := m.promo

	if m.promo == Piece.empty {
		piece = b.piece_on(m.src, b.color) or { panic('???') }
	}

	// disabling castling moves
	if piece == .king { // when moving king
		if m.src == 7 * 8 + 4 { // from the default white king position
			b.disable_castle(2)
			b.disable_castle(3)
		} else if m.src == 4 { // of from the default black king position
			b.disable_castle(0)
			b.disable_castle(1)
		}
	} else if piece == .rook { // when moving rooks
		if m.src == 0 {
			b.disable_castle(0)
		} else if m.src == 7 {
			b.disable_castle(1)
		} else if m.src == 7 * 8 {
			b.disable_castle(2)
		} else if m.src == 7 * 8 + 7 {
			b.disable_castle(3)
		}
	}

	mut nb := b

	nb.clear_pos(m.src)
	nb.clear_pos(m.dst) // when capturing
	nb.pieces[b.color][piece] |= ones[m.dst]

	return nb
}
