"""An independent SSZ oracle over the resolved schema: parse, serialize, root.

This is a test oracle only - it never runs in a measured path and the runtime
never calls it. It is written directly from the SSZ specification (offsets,
limits, packing, Merkleization with mix-in length) so that the generated Bend
object codec is compared with something that does not share its code.

    from codegen import oracle; v = oracle.parse(ty, data); oracle.root(ty, v)
"""
import hashlib


def h(a, b):
    return hashlib.sha256(a + b).digest()


def chunks(b):
    if not b:
        return [b'\0' * 32]
    b = b + b'\0' * ((-len(b)) % 32)
    return [b[i:i + 32] for i in range(0, len(b), 32)]


def merkleize(leaves, limit_chunks):
    d = 0
    while (1 << d) < max(1, limit_chunks):
        d += 1
    lv = list(leaves) or [b'\0' * 32]
    zero = b'\0' * 32
    for _ in range(d):
        if len(lv) % 2:
            lv.append(zero)
        lv = [h(lv[i], lv[i + 1]) for i in range(0, len(lv), 2)]
        zero = h(zero, zero)
    return lv[0]


def mix(root, n):
    return h(root, n.to_bytes(32, 'little'))


def fixed_size(t):
    return t.fixed_size()


def parse(t, b):
    k = t.kind
    if k == 'bool':
        if len(b) != 1 or b[0] > 1:
            raise ValueError('bool')
        return b[0] == 1
    if k == 'uint':
        if len(b) != t.size:
            raise ValueError('uint')
        return int.from_bytes(b, 'little')
    if k == 'bytes':
        if len(b) != t.size:
            raise ValueError('bytes')
        return bytes(b)
    if k == 'bits':
        if len(b) != (t.size + 7) // 8:
            raise ValueError('bitvector')
        bits = [(b[i // 8] >> (i % 8)) & 1 for i in range(t.size)]
        if any((b[i // 8] >> (i % 8)) & 1 for i in range(t.size, len(b) * 8)):
            raise ValueError('bitvector padding')
        return bits
    if k == 'bytelist':
        if len(b) > t.size:
            raise ValueError('bytelist limit')
        return bytes(b)
    if k == 'bitlist':
        if not b or b[-1] == 0:
            raise ValueError('bitlist delimiter')
        top = b[-1].bit_length() - 1
        n = 8 * (len(b) - 1) + top
        if n > t.size:
            raise ValueError('bitlist limit')
        return [(b[i // 8] >> (i % 8)) & 1 for i in range(n)]
    if k in ('vector', 'list'):
        e = t.elem
        if e.fixed():
            es = e.fixed_size()
            if len(b) % es:
                raise ValueError('element size')
            n = len(b) // es
            if k == 'vector' and n != t.size:
                raise ValueError('vector length')
            if k == 'list' and n > t.size:
                raise ValueError('list limit')
            return [parse(e, b[i * es:(i + 1) * es]) for i in range(n)]
        if not b:
            if k == 'vector':
                raise ValueError('empty vector')
            return []
        first = int.from_bytes(b[:4], 'little')
        if first % 4 or first > len(b) or first < 4:
            raise ValueError('offsets')
        n = first // 4
        if k == 'vector' and n != t.size:
            raise ValueError('vector length')
        if k == 'list' and n > t.size:
            raise ValueError('list limit')
        offs = [int.from_bytes(b[4 * i:4 * i + 4], 'little') for i in range(n)] + [len(b)]
        out = []
        for i in range(n):
            if offs[i] > offs[i + 1] or offs[i + 1] > len(b):
                raise ValueError('offsets')
            out.append(parse(e, b[offs[i]:offs[i + 1]]))
        return out
    if k == 'container':
        fixed = sum(ft.header() for _, ft in t.fields)
        if len(b) < fixed:
            raise ValueError('short container')
        vals, pos, var = {}, 0, []
        for f, ft in t.fields:
            if ft.fixed():
                vals[f] = parse(ft, b[pos:pos + ft.fixed_size()])
                pos += ft.fixed_size()
            else:
                var.append((f, ft, int.from_bytes(b[pos:pos + 4], 'little')))
                pos += 4
        for j, (f, ft, off) in enumerate(var):
            end = var[j + 1][2] if j + 1 < len(var) else len(b)
            if j == 0 and off != fixed:
                raise ValueError('first offset')
            if off > end or end > len(b):
                raise ValueError('offsets')
            vals[f] = parse(ft, b[off:end])
        return vals
    raise ValueError('kind ' + k)


def serialize(t, v):
    k = t.kind
    if k == 'bool':
        return b'\x01' if v else b'\x00'
    if k == 'uint':
        return int(v).to_bytes(t.size, 'little')
    if k in ('bytes', 'bytelist'):
        return bytes(v)
    if k == 'bits':
        out = bytearray((t.size + 7) // 8)
        for i, bit in enumerate(v):
            if bit:
                out[i // 8] |= 1 << (i % 8)
        return bytes(out)
    if k == 'bitlist':
        out = bytearray(len(v) // 8 + 1)
        for i, bit in enumerate(v):
            if bit:
                out[i // 8] |= 1 << (i % 8)
        out[len(v) // 8] |= 1 << (len(v) % 8)
        return bytes(out)
    if k in ('vector', 'list'):
        e = t.elem
        if e.fixed():
            return b''.join(serialize(e, x) for x in v)
        parts = [serialize(e, x) for x in v]
        off = 4 * len(parts)
        head = b''
        for p in parts:
            head += off.to_bytes(4, 'little')
            off += len(p)
        return head + b''.join(parts)
    if k == 'container':
        fixed = sum(ft.header() for _, ft in t.fields)
        head, body, off = b'', b'', fixed
        for f, ft in t.fields:
            if ft.fixed():
                head += serialize(ft, v[f])
            else:
                p = serialize(ft, v[f])
                head += off.to_bytes(4, 'little')
                body += p
                off += len(p)
        return head + body
    raise ValueError('kind ' + k)


def root(t, v):
    k = t.kind
    if k in ('bool', 'uint', 'bytes', 'bits'):
        return merkleize(chunks(serialize(t, v)), len(chunks(serialize(t, v))))
    if k == 'bytelist':
        limit = (t.size + 31) // 32
        return mix(merkleize(chunks(bytes(v)), limit), len(v))
    if k == 'bitlist':
        limit = (t.size + 255) // 256
        packed = bytearray((len(v) + 7) // 8)
        for i, bit in enumerate(v):
            if bit:
                packed[i // 8] |= 1 << (i % 8)
        return mix(merkleize(chunks(bytes(packed)) if packed else [], limit), len(v))
    if k in ('vector', 'list'):
        e = t.elem
        basic = e.kind in ('bool', 'uint')
        if basic:
            data = b''.join(serialize(e, x) for x in v)
            limit = ((t.size * e.fixed_size()) + 31) // 32
            r = merkleize(chunks(data) if data else [], limit)
        else:
            leaves = [root(e, x) for x in v]
            r = merkleize(leaves, t.size)
        return mix(r, len(v)) if k == 'list' else r
    if k == 'container':
        return merkleize([root(ft, v[f]) for f, ft in t.fields], len(t.fields))
    raise ValueError('kind ' + k)
