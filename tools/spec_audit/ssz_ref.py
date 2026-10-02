"""An independent Python port of ssz/simple-serialize.md (consensus-specs v1.6.1): serialization, deserialization with the
prose's hardening list, and Merkleization, for every type of the document including the progressive ones. stdlib only.

It is written from the markdown, not from the Bend and not from remerkleable; tools/spec_audit/rk_oracle.py runs the same
cases through remerkleable (the pyspec's ssz implementation) as a second reference, and the differences are reported.

Type model (normal forms shared with constants.py):
    ('bool',) ('uint', bits) ('bytes', n) ('bytelist', limit) ('bitvector', n) ('bitlist', limit)
    ('vector', elem, n) ('list', elem, limit) ('container', ((name, type), ...))
    ('proglist', elem) ('progbits',) ('progcontainer', ((name, type), ...), active_bits)
    ('compatunion', selectors, options) ('union', options)      # options may contain ('null',) in position 0
A value is: bool | int | list (vector/list/container fields in order) | bytes (bytes, bytelist) | list[bool] (bit types)
| (selector, value) (unions).
"""
import hashlib

LAX = False      # test-corpus switch: serialize over-limit values (never set while producing reference roots)
BYTES_PER_CHUNK = 32
BYTES_PER_LENGTH_OFFSET = 4
BITS_PER_BYTE = 8


def hash_(b):
    return hashlib.sha256(b).digest()


class Reject(Exception):
    pass


# ------------------------------------------------------------------------------------------------------ typing
def is_basic(t):
    return t[0] in ('bool', 'uint')


def is_variable_size(t):
    k = t[0]
    if k in ('bool', 'uint', 'bytes', 'bitvector'):
        return False
    if k in ('bytelist', 'bitlist', 'list', 'proglist', 'progbits', 'union', 'compatunion'):
        return True
    if k == 'vector':
        return is_variable_size(t[1])
    if k in ('container', 'progcontainer'):
        return any(is_variable_size(ft) for _, ft in t[1])
    raise ValueError(k)


def fixed_size(t):
    k = t[0]
    if k == 'bool':
        return 1
    if k == 'uint':
        return t[1] // BITS_PER_BYTE
    if k == 'bytes':
        return t[1]
    if k == 'bitvector':
        return (t[1] + 7) // 8
    if k == 'vector':
        return t[2] * fixed_size(t[1])
    if k in ('container', 'progcontainer'):
        return sum(fixed_size(ft) for _, ft in t[1])
    raise ValueError('not fixed size: %s' % k)


def elems(t, v):
    """The element types and values of a vector/list/container as parallel lists."""
    k = t[0]
    if k in ('bytes', 'bytelist'):
        return [('uint', 8)] * len(v), list(v)
    if k in ('vector', 'list', 'proglist'):
        return [t[1]] * len(v), list(v)
    if k in ('container', 'progcontainer'):
        return [ft for _, ft in t[1]], list(v)
    raise ValueError(k)


# ------------------------------------------------------------------------------------------------------ serialize
def serialize(t, v):
    k = t[0]
    if k == 'uint':
        assert t[1] in (8, 16, 32, 64, 128, 256)
        return int(v).to_bytes(t[1] // BITS_PER_BYTE, 'little')                  # raises OverflowError when out of range
    if k == 'bool':
        assert v in (True, False)
        return b'\x01' if v is True else b'\x00'
    if k == 'bitvector':
        n = t[1]
        assert len(v) == n and n > 0
        array = [0] * ((n + 7) // 8)
        for i in range(n):
            array[i // 8] |= int(v[i]) << (i % 8)
        return bytes(array)
    if k in ('bitlist', 'progbits'):
        if k == 'bitlist':
            assert LAX or len(v) <= t[1]
        array = [0] * ((len(v) // 8) + 1)
        for i in range(len(v)):
            array[i // 8] |= int(v[i]) << (i % 8)
        array[len(v) // 8] |= 1 << (len(v) % 8)
        return bytes(array)
    if k in ('bytes', 'bytelist'):                      # a vector/list of uint8: the concatenation of the elements
        assert (len(v) == t[1] and t[1] > 0) if k == 'bytes' else (LAX or len(v) <= t[1])
        assert len(v) < 2 ** (BYTES_PER_LENGTH_OFFSET * BITS_PER_BYTE)
        return bytes(v)
    if k in ('vector', 'list', 'proglist', 'container', 'progcontainer'):
        if k == 'bytes':
            assert len(v) == t[1] and t[1] > 0
        if k == 'vector':
            assert len(v) == t[2] and t[2] > 0
        if k in ('list', 'bytelist'):
            assert LAX or len(v) <= t[-1]
        ets, evs = elems(t, v)
        fixed_parts = [serialize(et, ev) if not is_variable_size(et) else None for et, ev in zip(ets, evs)]
        variable_parts = [serialize(et, ev) if is_variable_size(et) else b'' for et, ev in zip(ets, evs)]
        fixed_lengths = [len(p) if p is not None else BYTES_PER_LENGTH_OFFSET for p in fixed_parts]
        variable_lengths = [len(p) for p in variable_parts]
        assert sum(fixed_lengths + variable_lengths) < 2 ** (BYTES_PER_LENGTH_OFFSET * BITS_PER_BYTE)
        run, variable_offsets = sum(fixed_lengths), []      # == sum(fixed_lengths + variable_lengths[:i]), incrementally
        for i in range(len(evs)):
            variable_offsets.append(serialize(('uint', 32), run))
            run += variable_lengths[i]
        fixed_parts = [p if p is not None else variable_offsets[i] for i, p in enumerate(fixed_parts)]
        return b''.join(fixed_parts + variable_parts)
    if k == 'union':
        sel, val = v
        assert 0 <= sel < len(t[1])
        if t[1][sel] == ('null',):
            assert val is None and sel == 0
            return b'\x00'
        return sel.to_bytes(1, 'little') + serialize(t[1][sel], val)
    if k == 'compatunion':
        sel, val = v
        return sel.to_bytes(1, 'little') + serialize(t[2][t[1].index(sel)], val)
    raise ValueError(k)


# ------------------------------------------------------------------------------------------------------ deserialize
def u32(b):
    return int.from_bytes(b, 'little')


def layout(fts, data):
    """The fixed/variable layout of a container: the byte slice of every field, or Reject (shorter than the fixed part, first
    offset not the fixed size, offsets out of order or range, bytes after a fixed-size container)."""
    fixed_total = sum(fixed_size(ft) if not is_variable_size(ft) else BYTES_PER_LENGTH_OFFSET for ft in fts)
    if len(data) < fixed_total:
        raise Reject('shorter than the fixed part')
    pos, slots, offs = 0, [], []
    for ft in fts:
        if is_variable_size(ft):
            offs.append(u32(data[pos:pos + 4]))
            slots.append(None)
            pos += 4
        else:
            sz = fixed_size(ft)
            slots.append(data[pos:pos + sz])
            pos += sz
    if not offs:
        if len(data) != fixed_total:
            raise Reject('extra bytes after a fixed-size container')
    else:
        if offs[0] != fixed_total:
            raise Reject('first offset is not the fixed size')
        for i, o in enumerate(offs):
            end = offs[i + 1] if i + 1 < len(offs) else len(data)
            if o > end or end > len(data):
                raise Reject('offsets out of order or range')
    out, j = [], 0
    for s in slots:
        if s is None:
            end = offs[j + 1] if j + 1 < len(offs) else len(data)
            out.append(data[offs[j]:end])
            j += 1
        else:
            out.append(s)
    return out


def deserialize(t, data):
    """Return the value or raise Reject. The rejection conditions are the hardening list of the Deserialization section
    plus the validity of every basic value and of the delimiter/padding bits."""
    data = bytes(data)
    k = t[0]
    if k == 'uint':
        if len(data) != t[1] // 8:
            raise Reject('uint length')
        return int.from_bytes(data, 'little')
    if k == 'bool':
        if len(data) != 1 or data[0] not in (0, 1):
            raise Reject('boolean')
        return data[0] == 1
    if k == 'bitvector':
        n = t[1]
        if n == 0 or len(data) != (n + 7) // 8:
            raise Reject('bitvector length')
        if n % 8 and data[-1] >> (n % 8):
            raise Reject('bitvector padding bits')
        return [bool((data[i // 8] >> (i % 8)) & 1) for i in range(n)]
    if k in ('bitlist', 'progbits'):
        if len(data) == 0 or data[-1] == 0:
            raise Reject('bitlist delimiter')
        last = data[-1].bit_length() - 1
        n = (len(data) - 1) * 8 + last
        if k == 'bitlist' and n > t[1]:
            raise Reject('bitlist limit')
        return [bool((data[i // 8] >> (i % 8)) & 1) for i in range(n)]
    if k in ('bytes', 'bytelist'):
        n_req = t[1]
        if k == 'bytes' and (n_req == 0 or len(data) != n_req):
            raise Reject('byte vector length')
        if k == 'bytelist' and len(data) > n_req:
            raise Reject('byte list limit')
        return data
    if k in ('vector', 'list', 'proglist'):
        et = ('uint', 8) if k in ('bytes', 'bytelist') else t[1]
        limit = t[-1] if k in ('bytelist', 'list') else None
        if k in ('bytes', 'vector'):
            n_req = t[1] if k == 'bytes' else t[2]
            if n_req == 0:
                raise Reject('empty vector type')
        if not is_variable_size(et):
            sz = fixed_size(et)
            if len(data) % sz:
                raise Reject('scope not aligned with element size')
            n = len(data) // sz
            if k in ('bytes', 'vector') and n != n_req:
                raise Reject('vector length')
            if limit is not None and n > limit:
                raise Reject('list limit')
            vals = [deserialize(et, data[i * sz:(i + 1) * sz]) for i in range(n)]
        else:
            if len(data) == 0:
                n, offsets = 0, []
            else:
                if len(data) < 4:
                    raise Reject('short offset')
                first = u32(data[:4])
                if first % 4 or first < 4 or first > len(data):
                    raise Reject('first offset')
                n = first // 4
                offsets = [u32(data[4 * i:4 * i + 4]) for i in range(n)]
            if k == 'vector' and n != n_req:
                raise Reject('vector length')
            if limit is not None and n > limit:
                raise Reject('list limit')
            vals = []
            for i in range(n):
                end = offsets[i + 1] if i + 1 < n else len(data)
                if offsets[i] > end or end > len(data):
                    raise Reject('offsets out of order or range')
                vals.append(deserialize(et, data[offsets[i]:end]))
        if k in ('bytes', 'bytelist'):
            return bytes(vals)
        return vals
    if k in ('container', 'progcontainer'):
        fts = [ft for _, ft in t[1]]
        if not fts:
            raise Reject('empty container type')
        return [deserialize(ft, s) for ft, s in zip(fts, layout(fts, data))]
    if k == 'union':
        if len(data) < 1:
            raise Reject('empty union')
        sel = data[0]
        if sel >= len(t[1]) or sel > 127:
            raise Reject('union selector')
        if t[1][sel] == ('null',):
            if len(data) != 1:
                raise Reject('None with payload')
            return (sel, None)
        return (sel, deserialize(t[1][sel], data[1:]))
    if k == 'compatunion':
        if len(data) < 1:
            raise Reject('empty compatible union')
        sel = data[0]
        if sel not in t[1]:
            raise Reject('compatible union selector')
        return (sel, deserialize(t[2][t[1].index(sel)], data[1:]))
    raise ValueError(k)


# ------------------------------------------------------------------------------------------------------ merkleization
ZERO = [b'\x00' * 32]
for _ in range(80):
    ZERO.append(hash_(ZERO[-1] + ZERO[-1]))


def next_pow_of_two(i):
    return 1 if i <= 1 else 1 << (i - 1).bit_length()


def size_of(t):
    return fixed_size(t)


def chunk_count(t):
    k = t[0]
    if k in ('bool', 'uint'):
        return 1
    if k in ('bitvector', 'bitlist'):
        return (t[1] + 255) // 256
    if k in ('bytes', 'bytelist'):
        return (t[1] * 1 + 31) // 32
    if k in ('vector', 'list'):
        n = t[2]
        return (n * size_of(t[1]) + 31) // 32 if is_basic(t[1]) else n
    if k in ('container',):
        return len(t[1])
    raise ValueError(k)


def pack(serialized):
    b = serialized + b'\x00' * (-len(serialized) % BYTES_PER_CHUNK)
    return [b[i:i + 32] for i in range(0, len(b), 32)]


def pack_bits(bits):
    array = [0] * ((len(bits) + 7) // 8)
    for i, b in enumerate(bits):
        array[i // 8] |= int(b) << (i % 8)
    return pack(bytes(array))


def merkleize(chunks, limit=None):
    if limit is None:
        width = next_pow_of_two(len(chunks))
    else:
        if limit < len(chunks):
            raise ValueError('input exceeds limit')
        width = next_pow_of_two(limit)
    depth = width.bit_length() - 1
    # virtual padding: fold with the zero hashes (width can be huge, e.g. 2**40)
    nodes = list(chunks)
    for d in range(depth):
        if len(nodes) % 2:
            nodes.append(ZERO[d])
        nodes = [hash_(nodes[i] + nodes[i + 1]) for i in range(0, len(nodes), 2)]
    return nodes[0] if nodes else ZERO[depth]


def merkleize_progressive(chunks, num_leaves=1):
    if len(chunks) == 0:
        return b'\x00' * 32
    a = merkleize_progressive(chunks[num_leaves:], num_leaves * 4)
    b = merkleize(chunks[:num_leaves], num_leaves)
    return hash_(a + b)


def mix_in_length(root, length):
    return hash_(root + length.to_bytes(32, 'little'))


def mix_in_selector(root, selector):
    return hash_(root + selector.to_bytes(32, 'little'))        # the uint8 serialization as a 32-byte chunk


def mix_in_active_fields(root, active):
    return hash_(root + b''.join(pack_bits(active)))


def hash_tree_root(t, v):
    k = t[0]
    if k in ('bool', 'uint'):
        return merkleize(pack(serialize(t, v)))
    if k == 'bytes':
        return merkleize(pack(bytes(v)))
    if k == 'bytelist':
        return mix_in_length(merkleize(pack(bytes(v)), limit=chunk_count(t)), len(v))
    if k == 'bitvector':
        return merkleize(pack_bits(v), limit=chunk_count(t))
    if k == 'bitlist':
        return mix_in_length(merkleize(pack_bits(v), limit=chunk_count(t)), len(v))
    if k == 'progbits':
        return mix_in_length(merkleize_progressive(pack_bits(v)), len(v))
    if k == 'vector':
        if is_basic(t[1]):
            return merkleize(pack(b''.join(serialize(t[1], e) for e in v)))
        return merkleize([hash_tree_root(t[1], e) for e in v])
    if k == 'list':
        if is_basic(t[1]):
            return mix_in_length(merkleize(pack(b''.join(serialize(t[1], e) for e in v)), limit=chunk_count(t)), len(v))
        return mix_in_length(merkleize([hash_tree_root(t[1], e) for e in v], limit=chunk_count(t)), len(v))
    if k == 'proglist':
        if is_basic(t[1]):
            return mix_in_length(merkleize_progressive(pack(b''.join(serialize(t[1], e) for e in v))), len(v))
        return mix_in_length(merkleize_progressive([hash_tree_root(t[1], e) for e in v]), len(v))
    if k == 'container':
        return merkleize([hash_tree_root(ft, e) for (_, ft), e in zip(t[1], v)])
    if k == 'progcontainer':
        # one root per ACTIVE slot, a zero chunk at each inactive slot (EIP-7495 and the pyspec); see SPEC_AUDIT.md for the prose
        it = iter(zip(t[1], v))
        slots = []
        for bit in t[2]:
            if bit:
                (_, ft), e = next(it)
                slots.append(hash_tree_root(ft, e))
            else:
                slots.append(b'\x00' * 32)
        return mix_in_active_fields(merkleize_progressive(slots), t[2])
    if k == 'union':
        sel, val = v
        if t[1][sel] == ('null',):
            return mix_in_selector(b'\x00' * 32, 0)
        return mix_in_selector(hash_tree_root(t[1][sel], val), sel)
    if k == 'compatunion':
        sel, val = v
        return mix_in_selector(hash_tree_root(t[2][t[1].index(sel)], val), sel)
    raise ValueError(k)


def hash_tree_root_prose_progressive_container(t, v):
    """The literal reading of the prose line `mix_in_active_fields(merkleize_progressive([hash_tree_root(element) for element
    in value]), get_active_fields(value))`: one chunk per FIELD (no zero chunks for inactive slots). Kept to show where it differs."""
    roots = [hash_tree_root(ft, e) for (_, ft), e in zip(t[1], v)]
    return mix_in_active_fields(merkleize_progressive(roots), t[2])


# ------------------------------------------------------------------------------------------------------ value generation
def zero_value(t):
    k = t[0]
    if k == 'bool':
        return False
    if k == 'uint':
        return 0
    if k == 'bytes':
        return bytes(t[1])
    if k in ('bytelist',):
        return b''
    if k == 'bitvector':
        return [False] * t[1]
    if k in ('bitlist', 'progbits', 'list', 'proglist'):
        return []
    if k == 'vector':
        return [zero_value(t[1]) for _ in range(t[2])]
    if k in ('container', 'progcontainer'):
        return [zero_value(ft) for _, ft in t[1]]
    if k == 'union':
        return (0, zero_value(t[1][0]) if t[1][0] != ('null',) else None)
    if k == 'compatunion':
        return (t[1][0], zero_value(t[2][0]))
    raise ValueError(k)


def random_value(t, rng, maxlen=6):
    k = t[0]
    if k == 'bool':
        return rng.random() < 0.5
    if k == 'uint':
        return rng.choice([0, 1, (1 << t[1]) - 1, rng.getrandbits(t[1])])
    if k == 'bytes':
        return bytes(rng.getrandbits(8) for _ in range(t[1]))
    if k == 'bytelist':
        return bytes(rng.getrandbits(8) for _ in range(rng.randint(0, min(t[1], maxlen * 3))))
    if k == 'bitvector':
        return [rng.random() < 0.5 for _ in range(t[1])]
    if k == 'bitlist':
        return [rng.random() < 0.5 for _ in range(rng.randint(0, min(t[1], maxlen * 5)))]
    if k == 'progbits':
        return [rng.random() < 0.5 for _ in range(rng.randint(0, maxlen * 5))]
    if k == 'vector':
        return [random_value(t[1], rng, maxlen) for _ in range(t[2])]
    if k == 'list':
        return [random_value(t[1], rng, maxlen) for _ in range(rng.randint(0, min(t[2], maxlen)))]
    if k == 'proglist':
        return [random_value(t[1], rng, maxlen) for _ in range(rng.randint(0, maxlen))]
    if k in ('container', 'progcontainer'):
        return [random_value(ft, rng, maxlen) for _, ft in t[1]]
    if k == 'union':
        sel = rng.randrange(len(t[1]))
        return (sel, None if t[1][sel] == ('null',) else random_value(t[1][sel], rng, maxlen))
    if k == 'compatunion':
        i = rng.randrange(len(t[1]))
        return (t[1][i], random_value(t[2][i], rng, maxlen))
    raise ValueError(k)
