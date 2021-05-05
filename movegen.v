[inline]
fn filter_own_capture(my u64, attacks u64) u64 {
	return attacks & ~my
}

fn get_ray_attacks(occ u64, dir byte, pos byte) u64 {
	attacks := ray_attacks[dir * 64 + pos]
	blocker := attacks & occ
	if blocker > 0 {
		x := bit_scan(blocker, dir in [6, 7, 0, 1])
		return attacks ^ ray_attacks[dir * 64 + x]
	}
	return attacks
}

fn get_b_attacks(occ u64, pos byte) u64 { // bishop
	return get_ray_attacks(occ, 1, pos) | get_ray_attacks(occ, 3, pos) | get_ray_attacks(occ,
		5, pos) | get_ray_attacks(occ, 7, pos)
}

fn get_r_attacks(occ u64, pos byte) u64 { // rook
	return get_ray_attacks(occ, 0, pos) | get_ray_attacks(occ, 2, pos) | get_ray_attacks(occ,
		4, pos) | get_ray_attacks(occ, 6, pos)
}

fn get_q_attacks(occ u64, pos byte) u64 { // queen
	return get_ray_attacks(occ, 0, pos) | get_ray_attacks(occ, 1, pos) | get_ray_attacks(occ,
		2, pos) | get_ray_attacks(occ, 3, pos) | get_ray_attacks(occ, 4, pos) | get_ray_attacks(occ,
		5, pos) | get_ray_attacks(occ, 6, pos) | get_ray_attacks(occ, 7, pos)
}

fn get_p_attacks(me u64, he u64, pos byte, plr bool) u64 { // pawn
	startpos := u64(71776119061282560)
	occ := me | he
	if plr { // upper player
		//          those side attacks           and moving one forward if empty
		attacks := (pawn_upper_attacks[pos] & he) | ((ones[pos] << 8) & ~occ)
		// if pawn is at startpos       and  the pos above    is     free    and the above abot too
		if ((ones[pos] & startpos) != 0) && (((ones[pos] << 8) & occ) == 0)
			&& (((ones[pos] << 16) & occ) == 0) {
			// add the pos above above as a possible move
			return attacks | (ones[pos] << 16)
		}
		return attacks
	} else { // lower player same but bit shifting to the other side
		attacks := (pawn_lower_attacks[pos] & he) | (ones[pos] >> 8 & ~occ)
		if ((ones[pos] & startpos) != 0) && (((ones[pos] >> 8) & occ) == 0)
			&& (((ones[pos] >> 16) & occ) == 0) {
			return attacks | (ones[pos] >> 16)
		}
		return attacks
	}
}

fn get_k_attacks(occ u64, dang u64, pos byte, b Board) u64 { // king
	mut attacks := king_attacks[pos]
	if pos == 4 { // upper player castling?
		if b.can_castle(0) && (((ones[2] | ones[3]) & occ) == 0)
			&& (((ones[2] | ones[3] | ones[4]) & dang) == 0) {
			attacks |= ones[2]
		}
		if b.can_castle(1) && (((ones[5] | ones[6]) & occ) == 0)
			&& (((ones[4] | ones[5] | ones[6]) & dang) == 0) {
			attacks |= ones[6]
		}
	}
	if pos == 7 * 8 + 4 { // lower player castling?
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

fn get_n_attacks(me u64, pos byte) u64 { // knight
	return knight_attacks[pos]
}
