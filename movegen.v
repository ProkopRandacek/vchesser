fn C.__builtin_ctzl(u64) int
fn C.__builtin_clzl(u64) int

fn get_occ(s State) u64 {
	return s.p[0].p | s.p[0].r | s.p[0].n | s.p[0].b | s.p[0].k | s.p[0].q | s.p[1].p | s.p[1].r | s.p[1].n | s.p[1].b | s.p[1].k | s.p[1].q
}

fn get_my(s State, plr bool) u64 {
	i := int(plr)
	return s.p[i].p | s.p[i].r | s.p[i].n | s.p[i].b | s.p[i].k | s.p[i].q
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
		attacks := (pawn_upper_attacks[pos] & he) | ((ones[pos] << 8) & ~(occ))
		// if pawn is at startpos      and  the pos above    is     free    and the above abot too
		if ((ones[pos] & startpos) != 0) && (((ones[pos] << 8) & occ) == 0) && (((ones[pos] << 16) & occ) == 0) {
			// add the pos above above as a possible move
			return attacks | (ones[pos] << 16)
		}
		return attacks
	} else { // lower player same but bit shifting to the other side
		attacks := (pawn_lower_attacks[pos] & he) | (ones[pos] >> 8 & ~(occ))
		if ((ones[pos] & startpos) != 0) && (((ones[pos] >> 8) & occ) == 0) && (((ones[pos] >> 16) & occ) == 0) {
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
