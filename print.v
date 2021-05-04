import strings
import term

const (
	b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
)

fn bprint(bb u64) {
	println(b64)
	tz := ctz(bb)
	lz := clz(bb)
	mut mask := u64(1)

	print(strings.repeat(`0`, tz)) // skip zeros at the start
	mask = mask << tz
	for _ in tz .. (64 - lz) {
		print(if (bb & mask) > 0 { '1' } else { '0' })
		mask <<= 1
	}
	println(strings.repeat(`0`, lz)) // skip zeros at the end
}

fn bbprint(bb u64) {
	mut mask := u64(1)
	for _ in 0 .. 8 {
		for _ in 0 .. 8 {
			print(if (bb & mask) > 0 { term.bg_red('1 ') } else { '0 ' })
			mask = mask << 1
		}
		println('')
	}
}

fn fbbprint(bb u64) {
	mut mask := u64(1)
	println('    0 1 2 3 4 5 6 7')
	println('  +-----------------+')
	for y in 0 .. 8 {
		print('$y | ')
		for _ in 0 .. 8 {
			print(if (bb & mask) > 0 { '1 ' } else { '0 ' })
			mask = mask << 1
		}
		println('| $y')
	}
	println('  +-----------------+')
	println('    0 1 2 3 4 5 6 7')
}

fn bb2char(bb u64, mut board []rune, c rune) {
	tz := ctz(bb)
	lz := clz(bb)
	mut m := u64(1)
	m <<= u64(tz)
	for i in tz .. (64 - lz) {
		if (bb & u64(m)) > 0 {
			board[i] = c
		}
		m = m << u64(1)
	}
}

fn fboardprint(b Board, pos int, hl u64) {
	mut board := []rune{len: 64, init: ` `}

	bb2char(b.pieces[Color.black][Piece.pawn], mut board, `♟`)
	bb2char(b.pieces[Color.black][Piece.rook], mut board, `♜`)
	bb2char(b.pieces[Color.black][Piece.knight], mut board, `♞`)
	bb2char(b.pieces[Color.black][Piece.bishop], mut board, `♝`)
	bb2char(b.pieces[Color.black][Piece.king], mut board, `♚`)
	bb2char(b.pieces[Color.black][Piece.queen], mut board, `♛`)

	bb2char(b.pieces[Color.white][Piece.pawn], mut board, `♙`)
	bb2char(b.pieces[Color.white][Piece.rook], mut board, `♖`)
	bb2char(b.pieces[Color.white][Piece.knight], mut board, `♘`)
	bb2char(b.pieces[Color.white][Piece.bishop], mut board, `♗`)
	bb2char(b.pieces[Color.white][Piece.king], mut board, `♔`)
	bb2char(b.pieces[Color.white][Piece.queen], mut board, `♕`)

	mut m := u64(1)
	println('  A B C D E F G H')
	println(' ╔════════════════╗')
	for y in 0 .. 8 {
		print('${8 - y}║')
		for x in 0 .. 8 {
			mut t := '${board[y * 8 + x]} '

			t = term.black(t)
			if x + y * 8 == pos {
				t = term.red(term.bg_cyan(t))
			}
			if (mask(x, y) & hl) > 0 {
				t = term.bg_green(t)
			}
			if (x + y) % 2 != 0 {
				t = term.bright_bg_black(t)
			} else {
				t = term.bright_bg_white(t)
			}

			print(t)

			m = m << 1
		}
		println('║${8 - y}')
	}
	println(' ╚════════════════╝')
	println('  A B C D E F G H')
	case := if b.color == .white { 'lower' } else { 'upper' }
	println('player: $b.color ($case case)')
}
