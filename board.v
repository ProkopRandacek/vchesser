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
	bits    byte  = 0b000_1111
}

fn (b Board) can_castle(pos byte) bool {
	return (b.bits & byte(1 << pos)) != 0
}

fn (mut b Board) disable_castle(pos byte) {
	b.bits &= ~byte(1 << pos)
}

fn (mut b Board) load_fen(fen string) {
	for i in 0 .. 12 {
		b.pieces[i / 6][i % 6] = 0
	}
	mut x := byte(0)
	mut y := byte(0)
	for c in fen {
		if c == `/` {
			y++
			x = 0
		} else {
			if c.is_digit() {
				x += (c - 48)
			} else {
				color := if c.is_capital() { Color.white } else { Color.black }
				b.pieces[color][char2piece[c]] |= mask(x, y)
				x++
			}
		}
	}
}

[direct_array_access]
fn (b Board) piece_on(pos byte, color Color) Piece { // return what piece is on given position
	for i in 0 .. 6 {
		if (b.pieces[color][i] & ones[pos]) != 0 {
			return Piece(i)
		}
	}
	panic('piece_on(): asked position is empty\npos: $pos\nclr: $color.str()')
}

fn (mut b Board) clear_pos(pos byte) { // Clears position (sets all bitboards' bits on position `pos` to zero )
	mask := ~ones[pos]
	for c in 0 .. 2 {
		for p in 0 .. 6 {
			b.pieces[c][p] &= mask
		}
	}
}

//[direct_array_access]
fn (mut b Board) refresh_attacks(c Color) {
	me := get_my(b, int(c) != 0)
	he := get_my(b, int(c) == 0)
	occ := me | he

	b.attacks[c] |= arr_or(get_ns_attacks(b.pieces[c][Piece.knight]))
	b.attacks[c] |= arr_or(get_bs_attacks(occ, b.pieces[c][Piece.bishop]))
	b.attacks[c] |= arr_or(get_rs_attacks(occ, b.pieces[c][Piece.rook]))
	b.attacks[c] |= arr_or(get_qs_attacks(occ, b.pieces[c][Piece.queen]))
	b.attacks[c] |= arr_or(get_ps_attacks(me, he, b.pieces[c][Piece.pawn], int(c) != 0))
	b.attacks[c] |= get_k_attacks(occ, b.attacks[c], b.pieces[c][Piece.king], b)
}

fn (old_b Board) apply_move(m Move) Board {
	mut piece := m.promo
	mut b := Board{old_b.pieces.clone(), old_b.color, [u64(0), 0], old_b.bits}

	if m.promo == Piece.empty {
		piece = old_b.piece_on(m.src, b.color)
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
	if m.dst == 0 { // also disable castling if rook is captured
		b.disable_castle(0)
	} else if m.dst == 7 {
		b.disable_castle(1)
	} else if m.dst == 7 * 8 {
		b.disable_castle(2)
	} else if m.dst == 7 * 8 + 7 {
		b.disable_castle(3)
	}

	// move rook when castling
	if piece == Piece.king {
		if m.src == 4 { // upper king
			if m.dst == 2 { // castling left
				b.pieces[b.color][Piece.rook] |= ones[3]
				b.clear_pos(0)
			} else if m.dst == 6 { // castling right
				b.pieces[b.color][Piece.rook] |= ones[5]
				b.clear_pos(7)
			}
		} else if m.src == 7 * 8 + 4 { // lower king
			if m.dst == 7 * 8 + 2 { // castling left
				b.pieces[b.color][Piece.rook] |= ones[7 * 8 + 3]
				b.clear_pos(7 * 8 + 0)
			} else if m.dst == 7 * 8 + 6 { // castling right
				b.pieces[b.color][Piece.rook] |= ones[7 * 8 + 5]
				b.clear_pos(7 * 8 + 7)
			}
		}
	}

	b.clear_pos(m.src)
	b.clear_pos(m.dst) // when capturing
	b.pieces[b.color][piece] |= ones[m.dst]

	// b.refresh_attacks(Color.black)
	// b.refresh_attacks(Color.white)
	return b
}
