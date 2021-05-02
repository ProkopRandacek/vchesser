fn C.__builtin_ctzl(u64) int
fn C.__builtin_clzl(u64) int

fn get_my(b Board, plr bool) u64 {
	mut my := u64(0)
	for i in b.pieces[b.color] {
		my |= i
	}
	return my
}

fn bit_scan(bb u64, reverse bool) int {
	if reverse {
		return 63 - C.__builtin_clzl(bb)
	} else {
		return C.__builtin_ctzl(bb)
	}
}

fn get_ray_attacks(occ u64, dir int, pos int) u64 {
	attacks := ray_attacks[dir * 64 + pos]
	blocker := attacks & occ
	if blocker > 0 {
		x := bit_scan(blocker, dir in [6, 7, 0, 1])
		return attacks ^ ray_attacks[dir * 64 + x]
	}
	return attacks
}

fn filter_own_capture(my u64, attacks u64) u64 {
	return attacks & ~my
}

fn get_b_attacks(me u64, he u64, pos int) u64 {
	occ := me | he
	mut attacks := get_ray_attacks(occ, 1, pos) | get_ray_attacks(occ, 3, pos) | get_ray_attacks(occ,
		5, pos) | get_ray_attacks(occ, 7, pos)
	attacks = filter_own_capture(me, attacks)
	return attacks
}

fn get_r_attacks(me u64, he u64, pos int) u64 {
	occ := me | he
	mut attacks := get_ray_attacks(occ, 0, pos) | get_ray_attacks(occ, 2, pos) | get_ray_attacks(occ,
		4, pos) | get_ray_attacks(occ, 6, pos)
	attacks = filter_own_capture(me, attacks)
	return attacks
}

fn get_q_attacks(me u64, he u64, pos int) u64 {
	occ := me | he
	mut attacks := get_ray_attacks(occ, 0, pos) | get_ray_attacks(occ, 1, pos) | get_ray_attacks(occ,
		2, pos) | get_ray_attacks(occ, 3, pos) | get_ray_attacks(occ, 4, pos) | get_ray_attacks(occ,
		5, pos) | get_ray_attacks(occ, 6, pos) | get_ray_attacks(occ, 7, pos)
	attacks = filter_own_capture(me, attacks)
	return attacks
}

fn get_p_attacks(me u64, he u64, pos int, plr bool) u64 {
	startpos := u64(71776119061282560)
	occ := me | he
	if plr { // upper player
		//          those side attacks           and moving one forward if empty
		attacks := (pawn_upper_attacks[pos] & he) | ((ones[pos] << 8) & ~occ)
		// if pawn is at startpos      and  the pos above    is     free    and the above abot too
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
	return 0
}

fn get_k_attacks(me u64, pos int) u64 {
	return filter_own_capture(me, king_attacks[pos])
}

fn get_n_attacks(me u64, pos int) u64 {
	return filter_own_capture(me, knight_attacks[pos])
}

fn get_attacks(b Board, pos int) ?u64 {
	me := get_my(b, int(b.color) != 0)
	he := get_my(b, int(b.color) == 0)
	if b.pieces[b.color][Piece.pawn] & ones[pos] != 0 {
		return get_p_attacks(me, he, pos, int(b.color) != 0)
	} else if b.pieces[b.color][Piece.rook] & ones[pos] != 0 {
		return get_r_attacks(me, he, pos)
	} else if b.pieces[b.color][Piece.knight] & ones[pos] != 0 {
		return get_n_attacks(me, pos)
	} else if b.pieces[b.color][Piece.bishop] & ones[pos] != 0 {
		return get_b_attacks(me, he, pos)
	} else if b.pieces[b.color][Piece.king] & ones[pos] != 0 {
		return get_k_attacks(me, pos)
	} else if b.pieces[b.color][Piece.queen] & ones[pos] != 0 {
		return get_q_attacks(me, he, pos)
	}
	return error("no piece on that position")
}
