from decimal import Decimal as D
import re

raw = '''Silver 	1.59×10−8 	6.30×107
Copper 	1.68×10−8 	5.96×107
Annealed copper 	1.72×10−8 	5.80×107
Gold 	2.44×10−8 	4.10×107
Aluminum 	2.82×10−8 	3.5×107
Calcium 	3.36×10−8 	2.98×107
Tungsten 	5.60×10−8 	1.79×107
Zinc 	5.90×10−8 	1.69×107
Nickel 	6.99×10−8 	1.43×107
Lithium 	9.28×10−8 	1.08×107
Iron 	1.0×10−7 	1.00×107
Platinum 	1.06×10−7 	9.43×106
Tin 	1.09×10−7 	9.17×106
Lead 	2.2×10−7 	4.55×106
Titanium 	4.20×10−7 	2.38×106
Grain-oriented electrical steel 	4.60×10−7 	2.17×106
Manganin 	4.82×10−7 	2.07×106
Constantan 	4.9×10−7 	2.04×106
Stainless steel 	6.9×10−7 	1.45×106
Mercury 	9.8×10−7 	1.02×106
Nichrome 	1.10×10−6 	9.09×105'''.splitlines()

r = [[c.strip() for c in l.split('\t')] for l in raw]

float = D


def fix(s: str):
    s = s.replace('×10', '*10')
    s = s.replace('−', '-')
    s = s.replace('*10', '*10**')
    print(s)
    s = re.findall(r'[-]?[\d+]?\.?\d+', s)
    s = [D(x) for x in s]
    print(s)
    s2 = s[1] ** s[2]
    print(s[0], s2)
    return s[0] * s2


compares = []
for c in r:
    compare = []
    for i in range(1, len(c)):
        compare.append(fix(c[i]))
    compares.append(compare)


compares.sort(key=lambda x: -1 * x[1])

for c in compares:
    if c == compares[-1]:
        break
    n = compares[compares.index(c) + 1]
    print((c[0] / n[0]), (n[1] / c[1]))
