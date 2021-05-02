struct Pieces {
mut:
	p u64
	k u64
	q u64
	r u64
	b u64
	n u64
}

struct State {
mut:
	p   [2]Pieces
	plr bool
}
