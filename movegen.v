const (
	empty_move = Move{0, 0, .empty}
)

[direct_array_access]
fn get_ray_attacks(occ u64, dir byte, pos byte) u64 {
	attacks := ray_attacks[dir * 64 + pos]
	blocker := attacks & occ
	if blocker > 0 {
		x := bit_scan(blocker, dir in [6, 7, 0, 1])
		return attacks ^ ray_attacks[dir * 64 + x]
	}
	return attacks
}

[direct_array_access]
fn get_bs_attacks(occ u64, pos u64) []u64 { // bishop
	mut moves := []u64{len: int(popcount(pos)), init: 0}
	mut j := 0
	for i in ctz(pos) .. 64 - clz(pos) {
		if ones[i] & pos != 0 {
			moves[j] |= get_ray_attacks(occ, 1, i) | get_ray_attacks(occ, 3, i) | get_ray_attacks(occ,
				5, i) | get_ray_attacks(occ, 7, i)
			j++
		}
	}
	return moves
}

[direct_array_access]
fn get_rs_attacks(occ u64, pos u64) []u64 { // rook
	mut moves := []u64{len: int(popcount(pos)), init: 0}
	mut j := 0
	for i in ctz(pos) .. 64 - clz(pos) {
		if ones[i] & pos != 0 {
			moves[j] |= get_ray_attacks(occ, 0, i) | get_ray_attacks(occ, 2, i) | get_ray_attacks(occ,
				4, i) | get_ray_attacks(occ, 6, i)
			j++
		}
	}
	return moves
}

[direct_array_access]
fn get_qs_attacks(occ u64, pos u64) []u64 { // queen
	mut moves := []u64{len: int(popcount(pos)), init: 0}
	mut j := 0
	for i in ctz(pos) .. 64 - clz(pos) {
		if ones[i] & pos != 0 {
			moves[j] |= get_ray_attacks(occ, 0, i) | get_ray_attacks(occ, 1, i) | get_ray_attacks(occ,
				2, i) | get_ray_attacks(occ, 3, i) | get_ray_attacks(occ, 4, i) | get_ray_attacks(occ,
				5, i) | get_ray_attacks(occ, 6, i) | get_ray_attacks(occ, 7, i)
			j++
		}
	}
	return moves
}

[direct_array_access]
fn get_ns_attacks(pos u64) []u64 { // knight
	mut moves := []u64{len: int(popcount(pos)), init: 0}
	mut j := 0
	for i in ctz(pos) .. 64 - clz(pos) {
		if ones[i] & pos != 0 {
			moves[j] |= knight_attacks[i]
			j++
		}
	}
	return moves
}

[direct_array_access]
fn get_ps_attacks(me u64, he u64, pos u64, plr bool) []u64 { // pawn
	occ := me | he
	mut moves := []u64{len: int(popcount(pos)), init: 0}
	mut j := 0
	if plr { // upper player
		for i in ctz(pos) .. 64 - clz(pos) {
			if ones[i] & pos != 0 {
				moves[j] |= (pawn_upper_attacks[i] & he) | ((ones[i] << 8) & ~occ)
				if ((ones[i] & pawn_start) != 0) && (((ones[i] << 8 | ones[i] << 16) & he) == 0) {
					moves[j] |= ones[i] << 16
				}
				j++
			}
		}
	} else {
		for i in ctz(pos) .. 64 - clz(pos) {
			if ones[i] & pos != 0 {
				moves[j] |= (pawn_upper_attacks[i] & he) | ((ones[i] >> 8) & ~occ)
				if ((ones[i] & pawn_start) != 0) && (((ones[i] >> 8 | ones[i] >> 16) & he) == 0) {
					moves[j] |= ones[i] >> 16
				}
				j++
			}
		}
	}
	return moves
}

[direct_array_access]
fn get_k_attacks(occ u64, dang u64, p u64, b Board) u64 { // king
	assert popcount(p) <= 1 // when debugging there can be 0 kings
	pos := ctz(p)
	assert pos < 64
	mut attacks := king_attacks[pos] // ring aroung
	if pos == 4 { // upper player castling
		if b.can_castle(0) && (((ones[2] | ones[3]) & occ) == 0)
			&& (((ones[2] | ones[3] | ones[4]) & dang) == 0) {
			attacks |= ones[2]
		}
		if b.can_castle(1) && (((ones[5] | ones[6]) & occ) == 0)
			&& (((ones[4] | ones[5] | ones[6]) & dang) == 0) {
			attacks |= ones[6]
		}
	}
	if pos == 7 * 8 + 4 { // lower player castling
		if b.can_castle(2) && (((ones[7 * 8 + 2] | ones[7 * 8 + 3]) & occ) == 0)
			&& (((ones[7 * 8 + 2] | ones[7 * 8 + 3] | ones[7 * 8 + 4]) & dang) == 0) {
			attacks |= ones[7 * 8 + 2]
		}
		if b.can_castle(3) && (((ones[7 * 8 + 5] | ones[7 * 8 + 6]) & occ) == 0)
			&& (((ones[7 * 8 + 4] | ones[7 * 8 + 5] | ones[7 * 8 + 6]) & dang) == 0) {
			attacks |= ones[7 * 8 + 6]
		}
	}
	return attacks
}

[inline]
fn filter_own_capture(my u64, attacks u64) u64 {
	return attacks & ~my
}

[direct_array_access; inline]
fn filter_own_captures(my u64, attacks []u64) []u64 {
	mut filtered := []u64{len: attacks.len}
	for i in 0 .. attacks.len {
		filtered[i] = filter_own_capture(my, attacks[i])
	}
	return filtered
}

[direct_array_access; inline]
fn bb_to_moves(src byte, bb u64, mut l List) {
	for i in ctz(bb) .. 64 - clz(bb) {
		if ones[i] & bb != 0 {
			l.append(Move{src, i, .empty})
		}
	}
}

[direct_array_access; inline]
fn bbs_to_moves(src []byte, bb []u64, mut l List) {
	for i in 0 .. src.len {
		bb_to_moves(src[i], bb[i], mut l)
	}
}

fn leaves_in_check(b Board, m Move) bool {
	mut bn := b.apply_move(m)
	my_king := bn.pieces[bn.color][Piece.king]
	bn.color = bn.color.neg()
	bn.refresh_attacks(bn.color)
	return (my_king & bn.attacks[bn.color]) != 0
}

[direct_array_access]
fn all_moves(b Board, c Color) &List {
	mut l := create([empty_move])

	my := get_my(b, c == .black)
	he := get_my(b, c == .white)
	occ := my | he

	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.pawn]), get_ps_attacks(my, he, b.pieces[c][Piece.pawn],
		c == .black), mut l)
	bb_to_moves(ctz(b.pieces[c][Piece.king]), filter_own_capture(my, get_k_attacks(occ,
		b.attacks[c.neg()], b.pieces[c][Piece.king], b)), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.rook]), filter_own_captures(my, get_rs_attacks(occ,
		b.pieces[c][Piece.rook])), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.bishop]), filter_own_captures(my, get_bs_attacks(occ,
		b.pieces[c][Piece.bishop])), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.queen]), filter_own_captures(my, get_qs_attacks(occ,
		b.pieces[c][Piece.queen])), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.knight]), filter_own_captures(my, get_ns_attacks(b.pieces[c][Piece.knight])), mut
		l)

	mut pos := l.first
	for {
		if leaves_in_check(b, pos.next.val) { // if the move leaves king in check
			todel := pos.next
			pos.next = pos.next.next // remove it from list
			unsafe {
				free(todel)
			}
			l.count--
		} else {
			pos = pos.next // next move
		}
		if pos.next == 0 { // if at the end, break the loop
			break
		}
	}
	l.pop()

	return l
}
