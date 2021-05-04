import readline

fn main() {
	mut rl := readline.Readline{}
	rl.enable_raw_mode_nosig()
	mut board := Board{}
	board.init_default()
	mut moving := false
	mut src := 0
	mut selecting := get_my(board, int(board.color) != 0)
	mut pos := next(selecting, 0, 1)
	for {
		print_board(board, pos, if moving { selecting } else { 0 })
		inp := rl.read_char()
		board.refresh_attacks(Color.black)
		board.refresh_attacks(Color.white)
		match inp {
			110 { // next
				pos = next(selecting, pos, 1)
			}
			98 { // back
				pos = next(selecting, pos, -1)
			}
			113 { // quit
				exit(0)
			}
			109 { // move
				if moving {
					continue
				}
				selecting = filter_own_capture(get_my(board, int(board.color) != 0), get_pos_attacks(board,
					pos) or { return })
				if selecting == 0 { // if no available moves for this piece, dont move
					selecting = get_my(board, int(board.color) != 0)
					continue
				}
				moving = true
				src = pos
				pos = next(selecting, pos, 1)
			}
			99 { // cancel move
				if !moving {
					continue
				}
				moving = false
				selecting = get_my(board, int(board.color) != 0)
				pos = next(selecting, pos, 1)
			}
			112 { // place
				if moving == false {
					continue
				}
				move := Move{
					src: byte(src)
					dst: byte(pos)
					promo: .empty
				}
				board = board.apply_move(move)
				moving = false

				if board.color == Color.white {
					board.color = Color.black
				} else {
					board.color = Color.white
				}

				selecting = get_my(board, int(board.color) != 0)
				pos = next(selecting, pos, 1)
			}
			105 {
				print_internal_info(board)
				rl.read_char()
			}
			else {
				continue
			}
		}
	}
}
