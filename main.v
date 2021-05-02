// player values:
// true  = upper = 1
// false = lower = 0

fn s_default() State {
	mut s := State{}

	s.plr = true

	for i in 0 .. 8 {
		s.p[1].p |= mask(i, 1)
	}
	for i in 0 .. 8 {
		s.p[0].p |= mask(i, 6)
	}

	// upper
	s.p[1].r = mask(0, 0) | mask(7, 0)
	s.p[1].n = mask(1, 0) | mask(6, 0)
	s.p[1].b = mask(2, 0) | mask(5, 0)
	s.p[1].k = mask(3, 0)
	s.p[1].q = mask(4, 0)

	// lower
	s.p[0].r = mask(0, 7) | mask(7, 7)
	s.p[0].n = mask(1, 7) | mask(6, 7)
	s.p[0].b = mask(2, 7) | mask(5, 7)
	s.p[0].q = mask(3, 7)
	s.p[0].k = mask(4, 7)

	return s
}

fn main() {
	state := s_default()
	me := get_my(state,  state.plr)
	he := get_my(state, !state.plr)
	bbprint(he)
	pos := 1*8+2
	attacks := get_p_attacks(me, he, pos, state.plr)
	fstateprint(state, pos, attacks)
}
