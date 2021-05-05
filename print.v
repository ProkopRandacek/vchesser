import term

fn bb_print(bb u64) {
	mut mask := u64(1)
	for _ in 0 .. 8 {
		for _ in 0 .. 8 {
			print(if (bb & mask) > 0 { term.bg_red('1 ') } else { '0 ' })
			mask = mask << 1
		}
		println('')
	}
}

fn bb_to_char(bb u64, mut board []rune, c rune) {
	tz := ctz(bb)
	lz := clz(bb)
	mut m := u64(1) << u64(tz)
	for i in tz .. (64 - lz) {
		if (bb & u64(m)) > 0 {
			board[i] = c
		}
		m = m << u64(1)
	}
}

fn print_board(b Board, hl u64) {
	mut board := []rune{len: 64, init: ` `}

	for i in 0 .. 12 {
		bb_to_char(b.pieces[i / 6][i % 6], mut board, icons[i])
	}

	println('  A B C D E F G H')
	for y in 0 .. 8 {
		print(8 - y)
		for x in 0 .. 8 {
			mut t := term.black('${board[y * 8 + x]} ')
			t = if (mask(x, y) & hl) != 0 { term.bg_green(t) } else { t }
			t = if (x + y) % 2 != 0 { term.bright_bg_black(t) } else { term.bright_bg_white(t) }
			print(t)
		}
		println(8 - y)
	}
	println('  A B C D E F G H')
}

fn print_internal_info(b Board) {
	case := if b.color == .white { 'lower' } else { 'upper' }
	println('player: $b.color ($case case)')
	println('castling 0: ${b.can_castle(0)}')
	println('castling 1: ${b.can_castle(1)}')
	println('castling 2: ${b.can_castle(2)}')
	println('castling 3: ${b.can_castle(3)}')
}
