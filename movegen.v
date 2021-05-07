const (
	empty_move = Move{0, 0, .empty}
)

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
	my_king := bn.pieces[bn.color.neg()][Piece.king]
	return (my_king & bn.attacks[bn.color]) != 0
}

[direct_array_access]
fn all_moves(b Board) &List {
	mut l := create([empty_move])
	c := b.color

	my := get_my(b, c == .black)
	he := get_my(b, c == .white)
	occ := my | he

	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.pawn]), get_ps_attacks(my, he, b.pieces[c][Piece.pawn], c == .black), mut l)
	bb_to_moves(ctz(b.pieces[c][Piece.king]), filter_own_capture(my, get_k_attacks(occ, b.attacks[c.neg()], b.pieces[c][Piece.king], b)), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.rook]), filter_own_captures(my, get_rs_attacks(occ, b.pieces[c][Piece.rook])), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.bishop]), filter_own_captures(my, get_bs_attacks(occ, b.pieces[c][Piece.bishop])), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.queen]), filter_own_captures(my, get_qs_attacks(occ, b.pieces[c][Piece.queen])), mut l)
	bbs_to_moves(bb_to_poss(b.pieces[c][Piece.knight]), filter_own_captures(my, get_ns_attacks(b.pieces[c][Piece.knight])), mut l)

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
	l.pop() // the initial empty move

	return l
}
