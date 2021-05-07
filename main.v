import os
// import term

fn main() {
	println('start')
	mut board := Board{}
	// board.load_fen('rnbqkbnr/pppppppp/////PPPPPPPP/RNBQKBNR')
	// board.load_fen('rnbqkbnr///////RNBQKBNR')
	// board.load_fen('/1P//2Q2Q///3K2P/')
	board.load_fen('///2K//2k//')
	board.color = Color.white
	// term.clear()
	mut hl := u64(0)
	for {
		board.refresh_attacks(board.color.neg())
		l := all_moves(board, board.color).to_array()
		hl = 0
		for i in l {
			hl |= ones[i.dst]
		}

		println('possible moves: $l.len')
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
					if move !in l {
						println('illegal move')
						continue
					}
					hl = ones[move.src] | ones[move.dst] // update last move highlight
					board = board.apply_move(move)
					board.color = board.color.neg() // switch player
				} else {
					println('input does not match the algebraic notation')
				}
			}
		}
	}
}
