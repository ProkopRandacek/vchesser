import math.util

fn minimax(b Board, d int) int {
	if d == 0 {
		return eval(b, all_moves(b).to_array())
	}
	mut max_score := checkmate_score
	for move in all_moves(b).to_array() {
		mut new_board := b.apply_move(move)
		score := -minimax(new_board, d - 1)
		max_score = util.imax(score, max_score)
	}
	return max_score
}

fn make_ai_move(b Board, d int) Move {
	mut max_score := checkmate_score
	mut best_move := Move{}
	for move in all_moves(b).to_array() {
		mut new_board := b.apply_move(move)
		print_board(new_board, ones[move.src] | ones[move.dst])
		score := -minimax(new_board, d - 1)
		if score > max_score {
			max_score = score
			best_move = move
		}
	}

	return best_move
}
