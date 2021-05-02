// player values:
// true  = upper = 1
// false = lower = 0
import os

fn next(s u64, p int, o int) int {
	mut pos := p
	for {
		pos += o
		if pos > 63 {
			pos = 0
		}
		if pos < 0 {
			pos = 64
			continue
		}
		if (ones[pos] & s) != 0 {
			break
		}
	}
	return pos
}

fn main() {
	mut board := Board{}
	board.init_default()
	mut pos := 0
	mut moving := false
	mut src := 0
	mut selecting := get_my(board, int(board.color) != 0)
	for {
		fboardprint(board, pos, if moving { selecting } else { 0 })
		inp := os.input('~: ')
		match inp {
			'n' { // next
				pos = next(selecting, pos, 1)
			}
			'b' { // back
				pos = next(selecting, pos, -1)
			}
			'q' { // quit
				exit(0)
			}
			'm' { // move
				selecting = get_attacks(board, pos) or {
					return
				}
				if selecting == 0 { // if no available moves for this piece, dont move
					selecting = get_my(board, int(board.color) != 0)
					continue
				}
				moving = true
				src = pos
				pos = next(selecting, pos, 1)
			}
			'c' { // cancel move
				if !moving {
					continue
				}
				moving = false
				selecting = get_my(board, int(board.color) != 0)
				pos = next(selecting, pos, 1)
			}
			'p' { // place
				move := Move{src: byte(src), dst: byte(pos), promo: .empty}
				board = board.apply_move(move)
				moving = false
				if board.color == Color.white { board.color = Color.black }
				else { board.color = Color.white }
				selecting = get_my(board, int(board.color) != 0)
				pos = next(selecting, pos, 1)
			}
			else {
				continue
			}
		}
	}
}
