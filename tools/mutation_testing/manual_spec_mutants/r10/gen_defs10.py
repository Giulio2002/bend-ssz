#!/usr/bin/env python3
"""gen_defs10.py TREE OUT_DIR: round 10 fault definitions (defs/r10_*.txt) for the round-10 focus areas. Run on the server only.

Every block is a hand-designed fault PATTERN instantiated on the files where its shape occurs (the shape is the implementer
mistake; the instance is the type it hits). Families (spec rules from ssz/simple-serialize.md v1.6.1):
  r10-h01-root-neighbour   container hash_tree_root: two neighbouring field roots exchanged (first leaf pair)
  r10-h02-root-cross       container hash_tree_root: the second field root of one pair exchanged with the first of the next pair
  r10-h03-root-dup-pad     container hash_tree_root: an odd chunk promoted one level unhashed instead of hashed with the zero chunk (first version, Bitcoin-style
                           self-pairing, did not typecheck: a linear digest used twice; replaced)
  r10-h04-root-zero-level  container hash_tree_root: a zero subtree of depth k > 0 replaced by the zero chunk
  r10-w01-fixed-order      serializer: the first two fixed-part fields written at each other's positions
  r10-w02-var-slot         serializer: the offsets of the first two variable fields written into each other's slot
  r10-w03-size-fixed-part  serializer: the size pass counts the fixed part 4 bytes too long
  r10-w04-first-offset     serializer: the first variable field's offset written 4 too small (points into the fixed part)
  r10-r01-reader-advance   deserializer: a field read at the previous field's offset (the cursor not advanced)
  r10-d01-default          default value (spec 'Default values'): the default of a type is not all zeroes / has the wrong length
"""
import os, re, sys

tree, out = sys.argv[1:3]
T = os.path.join(tree, 'types')
blocks = {}


def add(fam, typ, ops, fname, syms, spec, fault, why, hunks):
    b = ['=== ' + fam, 'type: ' + typ, 'ops: ' + ops, 'file: types/' + fname, 'sym: ' + ','.join(dict.fromkeys(syms)),
         'spec: ' + spec, 'fault: ' + fault, 'why: ' + why]
    for o, n in hunks:
        b += ['-' + o, '+' + n]
    blocks.setdefault(fam, []).append('\n'.join(b))


def defs_of(text):
    """[(start_index, name)] of every top-level def."""
    return [(m.start(), m.group(1)) for m in re.finditer(r'^def (\w+)', text, re.M)]


def owner(text, pos):
    best = None
    for s, n in defs_of(text):
        if s <= pos:
            best = n
    return best


def line_at(text, pos):
    a = text.rfind('\n', 0, pos) + 1
    b = text.find('\n', pos)
    return text[a:b if b >= 0 else len(text)]


def typ_of(fname):
    return re.sub(r'_(hashtreeroot|encode_ssz|decode_ssz|def)_generated\.bend$', '', fname)


def pub(fname, text, suffix):
    m = re.search(r'^def (\w+_%s)\(' % suffix, text, re.M)
    return [m.group(1)] if m else []


files = sorted(f for f in os.listdir(T) if f.endswith('_generated.bend'))
LEAF = r'd_\w+'
for f in files:
    text = open(os.path.join(T, f)).read()
    typ = typ_of(f)
    if typ.startswith('CompatibleUnion'):
        continue
    if f.endswith('_hashtreeroot_generated.bend'):
        hp = pub(f, text, 'hash_tree_root')
        # h01: first leaf pair
        m = re.search(r'D\.node\(hl, (%s), (%s)\)' % (LEAF, LEAF), text)
        if m and m.group(1) != m.group(2):
            o = m.group(0)
            if text.count(o) == 1:
                add('r10-h01-root-neighbour', typ, 'root', f, [owner(text, m.start())] + hp,
                    'hash_tree_root(Container) = merkleize([hash_tree_root(field) for field in value]) in declaration order',
                    'the roots of %s and %s are exchanged in the chunk list' % (m.group(1)[2:], m.group(2)[2:]),
                    'field order: neighbouring fields hashed in the wrong order', [(o, 'D.node(hl, %s, %s)' % (m.group(2), m.group(1)))])
        # h02: cross-pair swap, last occurrence
        ms = list(re.finditer(r'D\.node\(hl, D\.node\(hl, (%s), (%s)\), D\.node\(hl, (%s), (%s)\)\)' % (LEAF, LEAF, LEAF, LEAF), text))
        if ms:
            m = ms[-1]
            o = m.group(0)
            if text.count(o) == 1:
                a, b, c, d = m.groups()
                add('r10-h02-root-cross', typ, 'root', f, [owner(text, m.start())] + hp,
                    'merkleize pairs chunk 2i with chunk 2i+1 in declaration order',
                    'the roots of %s and %s are exchanged (crossing a pair boundary)' % (b[2:], c[2:]),
                    'field order across subtrees',
                    [(o, 'D.node(hl, D.node(hl, %s, %s), D.node(hl, %s, %s))' % (a, c, b, d))])
        # h03: odd chunk paired with itself
        ms = list(re.finditer(r'D\.node\(hl, (%s), D\.zero\(\)\)' % LEAF, text))
        if ms and not typ.startswith('Progressive'):
            m = ms[-1]
            o = m.group(0)
            if text.count(o) == 1:
                add('r10-h03-root-dup-pad', typ, 'root', f, [owner(text, m.start())] + hp,
                    'merkleize pads the chunk list with zero chunks up to the next power of two',
                    'the last odd field root %s is carried up one level unhashed instead of being hashed with the zero chunk' % m.group(1)[2:],
                    'promoting the odd node (no zero padding)', [(o, m.group(1))])
        # h04: zero subtree of depth k replaced by the zero chunk (first use of z<k> as a node operand)
        m = re.search(r'D\.node\(hl, (D\.node\(hl, [^()]*(?:\([^()]*\))*[^()]*\)), (z\d)\)', text)
        if m and not typ.startswith('Progressive'):
            o = m.group(0)
            if text.count(o) == 1:
                add('r10-h04-root-zero-level', typ, 'root', f, [owner(text, m.start())] + hp,
                    'merkleize pads with zero chunks: a missing subtree of depth k is zerohashes[k], not the zero chunk',
                    'the padding subtree %s is the depth-0 zero chunk' % m.group(2),
                    'wrong zero-hash level', [(o, 'D.node(hl, %s, D.zero())' % m.group(1))])
    elif f.endswith('_encode_ssz_generated.bend'):
        ep = pub(f, text, 'serialize') + pub(f, text, 'encode')
        # w01: fixed part order (two smallest distinct positions written by a field writer)
        ms = [m for m in re.finditer(r'_put\w*\(out, \(pos \+ (\d+) : U32\)', text)]
        pos = {}
        for m in ms:
            pos.setdefault(int(m.group(1)), []).append(m)
        ks = sorted(k for k, v in pos.items() if len(v) == 1)
        if len(ks) >= 2:
            k1, k2 = ks[0], ks[1]
            m1, m2 = pos[k1][0], pos[k2][0]
            l1, l2 = line_at(text, m1.start()), line_at(text, m2.start())
            if l1 != l2 and text.count(l1) == 1 and text.count(l2) == 1:
                add('r10-w01-fixed-order', typ, 'encode', f, [owner(text, m1.start()), owner(text, m2.start())] + ep,
                    'serialize(Container): fixed parts in declaration order',
                    'the fields at byte %d and byte %d are written at each other\'s position' % (k1, k2),
                    'fixed part ordering', [(l1, l1.replace('(pos + %d : U32)' % k1, '(pos + %d : U32)' % k2)),
                                            (l2, l2.replace('(pos + %d : U32)' % k2, '(pos + %d : U32)' % k1))])
        # w02: variable offset slots of the first two variable fields
        ms = list(re.finditer(r'_putv\(out, pos, (\d+), ', text))
        sl = {}
        for m in ms:
            sl.setdefault(int(m.group(1)), []).append(m)
        ks = sorted(k for k, v in sl.items() if len(v) == 1)
        if len(ks) >= 2:
            k1, k2 = ks[0], ks[1]
            m1, m2 = sl[k1][0], sl[k2][0]
            l1, l2 = line_at(text, m1.start()), line_at(text, m2.start())
            if l1 != l2 and text.count(l1) == 1 and text.count(l2) == 1:
                add('r10-w02-var-slot', typ, 'encode', f, [owner(text, m1.start()), owner(text, m2.start())] + ep,
                    'serialize(Container): the offset of the k-th variable field sits at its own field position in the fixed part',
                    'the offsets of the variable fields at slots %d and %d are written into each other\'s slot' % (k1, k2),
                    'offset of the k-th variable field', [(l1, l1.replace('_putv(out, pos, %d, ' % k1, '_putv(out, pos, %d, ' % k2)),
                                                           (l2, l2.replace('_putv(out, pos, %d, ' % k2, '_putv(out, pos, %d, ' % k1))])
        # w03: size pass fixed part
        m = re.search(r'^def (\w+)_size\(o: [^\n]*\n  match o:\n    case [^\n]*?, (\d+), ([\w.]+_size\()', text, re.M)
        if m:
            o = ', %s, %s' % (m.group(2), m.group(3))
            if text.count(o) == 1:
                add('r10-w03-size-fixed-part', typ, 'encode', f, [m.group(1) + '_size'] + ep,
                    'serialize(Container): len = fixed part (fixed sizes + 4 per variable field) + variable parts',
                    'the size pass counts the fixed part as %d bytes (4 too many)' % (int(m.group(2)) + 4),
                    'one offset too many in the fixed-part length', [(o, ', %d, %s' % (int(m.group(2)) + 4, m.group(3)))])
        # w04: first variable offset
        m = re.search(r'^def (\w+)_putn\([^\n]*\n  match o:\n    case [^\n]*?_putv\(out, pos, (\d+), (\d+), ', text, re.M)
        if m:
            o = '_putv(out, pos, %s, %s, ' % (m.group(2), m.group(3))
            if text.count(o) == 1 and int(m.group(3)) >= 4:
                add('r10-w04-first-offset', typ, 'encode', f, [m.group(1) + '_putn'] + ep,
                    'serialize(Container): the first offset equals the length of the fixed part',
                    'the first variable field\'s offset is %d (fixed part %s)' % (int(m.group(3)) - 4, m.group(3)),
                    'fixed part length off by one offset', [(o, '_putv(out, pos, %s, %d, ' % (m.group(2), int(m.group(3)) - 4))])
    elif f.endswith('_decode_ssz_generated.bend'):
        dp = pub(f, text, 'decode')
        ms = list(re.finditer(r'_read\(buf, \(off \+ (\d+) : U32\), (\d+)\)', text))
        offs = sorted(set(int(m.group(1)) for m in ms))
        if len(offs) >= 2:
            # last field read whose start is > 0: read at the previous field's start
            m = max(ms, key=lambda m: int(m.group(1)))
            k = int(m.group(1))
            prev = max(x for x in offs if x < k)
            o = m.group(0)
            if text.count(o) == 1:
                add('r10-r01-reader-advance', typ, 'decode', f, [owner(text, m.start())] + dp,
                    'deserialize(Container): field i is bytes [sum(sizes before i), + size_i)',
                    'the field at byte %d is read at byte %d (the cursor is not advanced past the previous field)' % (k, prev),
                    'reader cursor', [(o, o.replace('(off + %d : U32)' % k, '(off + %d : U32)' % prev))])
    elif f.endswith('_def_generated.bend'):
        # d01: defaults
        for m in re.finditer(r'^def ((v)(\d+)_(\w+?)_default)\(\) -> O\.Words: O\.words_new\((\d+)\)$', text, re.M):
            n, total = int(m.group(3)), int(m.group(5))
            if n >= 2 and total % n == 0 and (typ.startswith('Fulu') or n in (5, 513)):
                es = total // n
                add('r10-d01-default', typ, 'encode,root', f, [m.group(1)],
                    'Default values: the default of Vector[T, N] is N default elements',
                    'the default vector has %d elements (%d bytes) instead of %d' % (n - 1, total - es, n),
                    'off-by-one length in the default constructor', [(m.group(0), m.group(0)[:-len('(%d)' % total)] + '(%d)' % (total - es))])
        for m in re.finditer(r'^def ((b\d+)_default)\(\) -> (Bytes\d+): (Bytes\d+)\{0, ', text, re.M):
            o = m.group(0)
            add('r10-d01-default', typ, 'encode,root', f, [m.group(1)],
                'Default values: the default of ByteVector[N] is N zero bytes',
                'the first word of the default is 1 (byte 0 is 0x01)', 'non-zero default',
                [(o, o[:-3] + '1, ')])
        for m in re.finditer(r'^def ((bv\d+)_default)\(\) -> (Bitvector\d+): (Bitvector\d+)\{0', text, re.M):
            o = m.group(0)
            if typ.startswith('Fulu') or typ in ('bitvector_5', 'bitvector_513'):
                add('r10-d01-default', typ, 'encode,root', f, [m.group(1)],
                    'Default values: the default of Bitvector[N] is N False bits',
                    'bit 0 of the default is set', 'non-zero default', [(o, o[:-1] + '1')])
        if f == 'boolean_def_generated.bend':
            o = 'def bool_default() -> Bool: False{}'
            if o in text:
                add('r10-d01-default', 'boolean', 'encode,root', f, ['bool_default'],
                    'Default values: the default of boolean is False', 'the default boolean is True', 'non-zero default',
                    [(o, 'def bool_default() -> Bool: True{}')])
        if f == 'uint64_def_generated.bend':
            o = 'def u64_default() -> O.U64: O.u64_zero()'
            if o in text:
                add('r10-d01-default', 'uint64', 'encode,root', f, ['u64_default'],
                    'Default values: the default of uint64 is 0', 'the default uint64 is 1', 'non-zero default',
                    [(o, 'def u64_default() -> O.U64: O.U64{1, 0}')])

os.makedirs(out, exist_ok=True)
names = {'h': 'roots', 'w': 'writers', 'r': 'readers', 'd': 'defaults'}
tot = 0
for i, (k, v) in enumerate(sorted(blocks.items())):
    pass
by = {}
for fam, bl in blocks.items():
    by.setdefault(fam.split('-')[1][0], []).extend(bl)
for k, bl in sorted(by.items()):
    open(os.path.join(out, 'r10_gen_%s.txt' % names[k]), 'w').write('## generated by r10/gen_defs10.py\n' + '\n'.join(bl) + '\n')
for fam, bl in sorted(blocks.items()):
    print(fam, len(bl))
    tot += len(bl)
print('total', tot)
