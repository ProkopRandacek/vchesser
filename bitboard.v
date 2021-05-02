import strings
import term

fn C.__builtin_clzl(u64) int
fn C.__builtin_ctzl(u64) int

fn clz(i u64) int {
	return C.__builtin_clzl(i)
}

fn ctz(i u64) int {
	return C.__builtin_ctzl(i)
}

const (
	b64  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	ones = [u64(1), 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536,
		131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864,
		134217728, 268435456, 536870912, 1073741824, 2147483648, 4294967296, 8589934592, 17179869184,
		34359738368, 68719476736, 137438953472, 274877906944, 549755813888, 1099511627776,
		2199023255552, 4398046511104, 8796093022208, 17592186044416, 35184372088832, 70368744177664,
		140737488355328, 281474976710656, 562949953421312, 1125899906842624, 2251799813685248,
		4503599627370496, 9007199254740992, 18014398509481984, 36028797018963968, 72057594037927936,
		144115188075855872, 288230376151711744, 576460752303423488, 1152921504606846976,
		2305843009213693952, 4611686018427387904, 9223372036854775808]
)

fn mask(x int, y int) u64 {
	return ones[y * 8 + x]
}

fn bprint(bb u64) {
	println(b64)
	tz := C.__builtin_ctzl(bb)
	lz := C.__builtin_clzl(bb)
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

// this takes like a second
fn fboardprint(b Board, pos int, hl u64) {
	mut board := []rune{len: 64, init: ` `}

	bb2char(b.pieces[Color.black][Piece.pawn], mut board, `P`)
	bb2char(b.pieces[Color.black][Piece.rook], mut board, `R`)
	bb2char(b.pieces[Color.black][Piece.knight], mut board, `N`)
	bb2char(b.pieces[Color.black][Piece.bishop], mut board, `B`)
	bb2char(b.pieces[Color.black][Piece.king], mut board, `K`)
	bb2char(b.pieces[Color.black][Piece.queen], mut board, `Q`)

	bb2char(b.pieces[Color.white][Piece.pawn], mut board, `p`)
	bb2char(b.pieces[Color.white][Piece.rook], mut board, `r`)
	bb2char(b.pieces[Color.white][Piece.knight], mut board, `n`)
	bb2char(b.pieces[Color.white][Piece.bishop], mut board, `b`)
	bb2char(b.pieces[Color.white][Piece.king], mut board, `k`)
	bb2char(b.pieces[Color.white][Piece.queen], mut board, `q`)

	mut m := u64(1)
	println('  0 1 2 3 4 5 6 7')
	println(' +----------------+')
	for y in 0 .. 8 {
		print('$y|')
		for x in 0 .. 8 {
			mut t := '${board[y * 8 + x]} '

			// color trash code
			if x + y * 8 == pos {
				t = term.black(term.bg_cyan(t))
			}
			if (mask(x, y) & hl) > 0 {
				t = term.black(term.bg_green(t))
			}
			if (x + y) % 2 == 0 {
				t = term.white(term.bg_black(t))
			} else {
				t = term.black(term.bg_white(t))
			}
			// end of trash code

			print(t)

			m = m << 1
		}
		println('|$y')
	}
	println(' +----------------+')
	println('  0 1 2 3 4 5 6 7')
	println('player: ${b.color}')
}
