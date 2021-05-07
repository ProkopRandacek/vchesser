const (
	piece_score     = [
		10 /* pawn */,
		30 /* knight */,
		30 /* bishop */,
		50 /* rook */,
		90 /* queen */,
	]
	checkmate_score = -10000
	center_score    = 1
	move_score      = 1
	center          = u64(0)
)

fn eval(b Board, l []Move) int {
	return eval_pieces(b) + eval_center(b) + eval_moves(l)
}

fn eval_center(b Board) int {
	return center_score * popcount(arr_or(b.pieces[b.color]) & center)
}

[direct_array_access; inline]
fn piece_diff(b Board, piece Piece) int {
	return popcount(b.pieces[b.color][piece]) - popcount(b.pieces[b.color.neg()][piece])
}

[direct_array_access]
fn eval_pieces(b Board) int {
	mut score := 0
	for p in [Piece.pawn, Piece.knight, Piece.bishop, Piece.rook, Piece.queen] {
		score += piece_score[p] * piece_diff(b, p)
	}
	return score
}

fn eval_moves(l []Move) int {
	if l.len == 0 {
		return checkmate_score
	} else {
		return l.len * move_score
	}
}
