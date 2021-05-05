import os
// import term

fn main() {
	mut board := Board{}
	board.load_fen('rnbqkbnr/pppppppp/////PPPPPPPP/RNBQKBNR')
	// term.clear()
	mut hl := u64(0)
	for {
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
					move := move_from_string(inp)
					hl = ones[move.src] | ones[move.dst] // update last move highlight
					board.apply_move(move)
					board.color = board.color.neg() // switch player
				} else {
					println('input does not match the algebraic notation')
				}
			}
		}
	}
}
