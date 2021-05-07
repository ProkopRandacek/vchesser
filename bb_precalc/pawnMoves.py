mov = []
for _ in range(64):
    mov.append(0)

for x in range(8):
    for y in range(8):
        for xo, yo in [[-1, -1], [1, -1]]:
            if y + yo < 0 or y + yo >= 8:
                continue
            if x + xo < 0 or x + xo >= 8:
                continue
            mov[y * 8 + x] |= (1 << (((y+yo) * 8) + (x+xo)))
            # if y != 6:
            # break

out = ""
for j in range(64):
    add = hex(mov[j])
    if len(out) + len(add) > 120:
        print(out)
        out = ""
    out += add + ", "
print(out)
