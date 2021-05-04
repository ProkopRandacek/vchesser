fn C.__builtin_ctzl(u64) int
fn C.__builtin_clzl(u64) int

[inline]
fn clz(i u64) int {
	return C.__builtin_clzl(i)
}

[inline]
fn ctz(i u64) int {
	return C.__builtin_ctzl(i)
}

[inline]
fn mask(x int, y int) u64 {
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
fn bit_scan(bb u64, reverse bool) int {
	if reverse {
		return 63 - C.__builtin_clzl(bb)
	} else {
		return C.__builtin_ctzl(bb)
	}
}
