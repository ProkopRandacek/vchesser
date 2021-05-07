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
