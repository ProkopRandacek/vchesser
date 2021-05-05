import regex

struct Move {
	src   byte
	dst   byte
	promo Piece = .empty
}

fn check_move_string(s string) bool {
	querry := r'^([a-h][1-8] [a-h][1-8])[qnbr]?$' // algebraic notation
	mut re := regex.regex_opt(querry) or { panic(err) }
	start, end := re.match_string(s)
	return start == 0 && end == s.len
}

fn move_from_string(s string) Move {
	srcy := 8 - s[1..2].str().int()
	dsty := 8 - s[4..5].str().int()
	srcx := index_of(abc, s[0])
	dstx := index_of(abc, s[3])
	mut prom := Piece.empty
	if s.len == 6 {
		prom = char2piece[s[5]]
	}
	return Move{byte(srcy * 8 + srcx), byte(dsty * 8 + dstx), prom}
}
