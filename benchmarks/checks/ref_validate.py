"""Independent SSZ validity oracle over the generator's parsed schema tree (debug aid)."""
import sys, re, pathlib, snappy
sys.path.insert(0, 'tools')
import generate_cschema as G
defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.+)$', G.SOURCE.read_text(), re.M))
def fs(n): return G.fixed_size(n)
def check(n, b, path, log):
    k = n[0]; size = len(b)
    if k == 'Boolean':
        return size == 1 and b[0] in (0, 1)
    if k in ('Unsigned', 'ByteVector'): return size == n[1]
    if k == 'BitVector':
        if size != (n[1] + 7)//8: return False
        return n[1] % 8 == 0 or (b[-1] >> (n[1] % 8)) == 0
    if k == 'ByteList': return size <= n[1]
    if k == 'BitList':
        if size == 0 or b[-1] == 0: return False
        return (size-1)*8 + b[-1].bit_length()-1 <= n[1]
    if k in ('Vector', 'ListOf'):
        e, cnt = n[1], n[2]; s = fs(e)
        if s is not None:
            if size % s: return False
            m = size // s
            if (k == 'Vector' and m != cnt) or m > cnt: return False
            return all(check(e, b[i*s:(i+1)*s], path+[i], log) for i in range(m))
        if size == 0: return k == 'ListOf'
        if size < 4: return False
        first = int.from_bytes(b[:4], 'little')
        if first % 4 or first == 0 or first > size: return False
        m = first // 4
        if (k == 'Vector' and m != cnt) or m > cnt: return False
        offs = [int.from_bytes(b[4*i:4*i+4], 'little') for i in range(m)] + [size]
        for i in range(m):
            if offs[i] > offs[i+1]: return False
            if not check(e, b[offs[i]:offs[i+1]], path+[i], log): return False
        return True
    if k == 'Container':
        fl = G.fields_of(n[1]); part = sum(G.header_size(f) for f in fl)
        if size < part: return False
        pos = 0; var = []; fixed = []
        for i, f in enumerate(fl):
            s = fs(f)
            if s is None: var.append((i, int.from_bytes(b[pos:pos+4], 'little'))); pos += 4
            else: fixed.append((i, b[pos:pos+s])); pos += s
        for i, x in fixed:
            if not check(fl[i], x, path+[i], log): log.append(path+[i]); return False
        if not var: return size == part
        if var[0][1] != part: log.append(path+['first_offset', var[0][1], part]); return False
        ends = [o for _, o in var[1:]] + [size]
        for (i, o), e in zip(var, ends):
            if o > e or e > size: log.append(path+[i, 'offset']); return False
            if not check(fl[i], b[o:e], path+[i], log):
                log.append(path+[i, 'len', e-o]); return False
        return True
    if k == 'Null': return size == 0
    raise SystemExit(k)
tree = G.parse(defs[sys.argv[1]], defs)
for p in sys.argv[2:]:
    raw = pathlib.Path(p).read_bytes()
    x = snappy.decompress(raw) if p.endswith('snappy') else raw
    log = []
    print(p, check(tree, x, [], log), log[:3])
