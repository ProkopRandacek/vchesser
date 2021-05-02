att = []
for _ in range(64):
    att.append(0)

move = [[-1, -2], [-2, -1], [1, -2], [2, -1], [1, 2], [2, 1], [-2, 1], [-1, 2]]

for x in range(8):
    for y in range(8):
        for xo, yo in move:
            if x + xo < 0 or x + xo >= 8:
                continue
            if y + yo < 0 or y + yo >= 8:
                continue
            att[y * 8 + x] |= (1 << (((y+yo) * 8) + (x+xo)))

out = ""
for j in range(64):
    add = hex(att[j])
    if len(out) + len(add) > 120:
        print(out)
        out = ""
    out += add + ", "
print()
