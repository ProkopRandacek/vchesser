fn C.__builtin_ctzl(u64) byte

// GCC builtin functions
fn C.__builtin_clzl(u64) byte

// probably works with clang too
fn C.__builtin_popcountl(u64) byte

// holy trinity
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

[direct_array_access; inline]
fn mask(x byte, y byte) u64 {
	return ones[y * 8 + x]
}

[direct_array_access; inline]
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
		return 63 - clz(bb)
	} else {
		return ctz(bb)
	}
}

[direct_array_access; inline]
fn index_of(a []rune, r rune) int {
	for i in 0 .. a.len {
		if a[int(i)] == r {
			return int(i)
		}
	}
	return -1
}

[inline]
fn arr_or(bb []u64) u64 {
	mut o := u64(0)
	for x in bb {
		o |= x
	}
	return o
}

[direct_array_access]
fn bb_to_poss(bb u64) []byte {
	mut p := []byte{cap: int(popcount(bb))}
	for i in ctz(bb) .. 64 - clz(bb) {
		if ones[i] & bb != 0 {
			p << i
		}
	}
	return p
}
