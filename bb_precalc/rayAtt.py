rayAttacks = []
for i in range(8):
    rayAttacks.append([])
    for j in range(64):
        rayAttacks[i].append(0)

d = 0
m = [7, 6, 5, 0, 4, 1, 2, 3]

for xo in [-1, 0, 1]:
    for yo in [-1, 0, 1]:
        if xo == yo == 0:
            continue
        for pos in range(64):
            x = pos % 8 + xo
            y = pos // 8 + yo
            while (x >= 0 and x < 8 and y >= 0 and y < 8):
                rayAttacks[m[d]][pos] = rayAttacks[m[d]][pos] | (1 << ((y * 8) + x))
                x += xo
                y += yo
        d += 1

out = ""
for i in range(8):
    for j in range(64):
        add = hex(rayAttacks[i][j])
        if len(out) + len(add) > 120:
            print(out)
            out = ""
        out += add + ", "
print(out)
