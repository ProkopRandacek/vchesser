fn C.__builtin_ctzl(u64) byte
fn C.__builtin_clzl(u64) byte
fn C.__builtin_popcountl(u64) byte

[inline]
fn clz(i u64) byte {
	return C.__builtin_clzl(i)
}

[inline]
fn ctz(i u64) byte {
	return C.__builtin_ctzl(i)
}

[inline]
fn popcount(i u64) byte {
	return C.__builtin_popcountl(i)
}

[inline]
fn mask(x byte, y byte) u64 {
	return ones[y * 8 + x]
}

[inline]
fn get_my(b Board, plr bool) u64 {
	mut my := u64(0)
	for i in b.pieces[int(plr)] {
		my |= i
	}
	return my
}

[inline]
fn bit_scan(bb u64, reverse bool) byte {
	if reverse {
		return 63 - C.__builtin_clzl(bb)
	} else {
		return C.__builtin_ctzl(bb)
	}
}

fn next(s u64, p byte, o i8) byte {
	mut pos := int(p)
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
	return byte(pos)
}

fn index_of(a []rune, r rune) int {
	for i in 0 .. a.len {
		if a[int(i)] == r {
			return int(i)
		}
	}
	return -1
}
