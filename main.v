import os
// import term

fn main() {
	println('start')
	mut board := Board{}
	board.load_fen('rnbqkbnr/pppppppp/////PPPPPPPP/RNBQKBNR')
	board.color = Color.white
	mut hl := u64(0)
	for {
		l := all_moves(board).to_array()

		if l.len == 0 {
			println('CHECKMATE: $board.color.neg().str() won')
			break
		}

		println('possible moves: $l.len')
		println('score: ${eval(board, l)}')
		print_board(board, hl)
		inp := os.input('move: ')
		// term.clear()
		match inp {
			'q', 'quit' {
				if os.input('really? ').to_lower() == 'yes' {
					exit(0)
				}
			}
			'i', 'info' {
				print_internal_info(board)
			}
			'' {
				continue
			}
			else {
				if check_move_string(inp) {
					// HUMAN MOVE
					move := move_from_string(inp)
					if move !in l {
						println('illegal move')
						continue
					}
					hl = ones[move.src] | ones[move.dst] // update last move highlight
					board = board.apply_move(move)

					// AI MOVE
					aimove := ai_move(board)
					board = board.apply_move(aimove)
				} else {
					println('input does not match the algebraic notation')
				}
			}
		}
	}
}

fn ai_move(b Board) Move {
	println('AI is thinking...')
	move := make_ai_move(b, 4)
	return move
}
