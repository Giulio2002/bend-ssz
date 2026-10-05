#!/usr/bin/env python3
"""gen_defs9.py TREE OUT_DIR: write the round-9 fault definitions (defs/r9_*.txt) from hand-designed fault templates.

Every template below is one implementer mistake (header: spec rule, fault, why); the script only instantiates it on the
kinds listed with it (it reads the generated file to find the exact old text and the same-typed neighbour field, so that
each definition is a type-correct single-site edit). mk9.py then materialises the definitions as patches and refuses any
whose old text does not occur exactly once, and any exact duplicate of an earlier round (rounds 1-8). Run on the server.
"""
import os, re, sys

tree, out = sys.argv[1:3]
os.makedirs(out, exist_ok=True)


def rd(rel):
    return open(os.path.join(tree, rel)).read()


class Defs:
    def __init__(self, name):
        self.name, self.blocks = name, []

    def add(self, rule, typ, ops, file, sym, spec, fault, why, old, new, proofs=None):
        assert old != new, (rule, file, old)
        b = ['=== ' + rule, 'type: ' + typ, 'ops: ' + ops, 'file: ' + file, 'sym: ' + sym,
             'spec: ' + spec, 'fault: ' + fault, 'why: ' + why]
        if proofs:
            b.append('proofs: ' + proofs)
        b += ['-' + l for l in old.split('\n')] + ['+' + l for l in new.split('\n')]
        self.blocks.append('\n'.join(b))

    def write(self):
        open(os.path.join(out, self.name), 'w').write('\n'.join(self.blocks) + '\n')
        print(self.name, len(self.blocks))


# ---------------------------------------------------------------------------------------------------------
# A. Typed accessors of packed scalar vectors / progressive lists (no law mentions <p>_get / <p>_set / <p>_len)
# ---------------------------------------------------------------------------------------------------------
VEC = [  # (type, prefix, element kind, width)
    ('vec_uint8_513', 'v513_u8', 'u', 1), ('vec_uint16_5', 'v5_u16', 'u', 2), ('vec_uint16_513', 'v513_u16', 'u', 2),
    ('vec_uint32_31', 'v31_u32', 'u', 4), ('vec_uint64_3', 'v3_u64', 'u64', 8), ('vec_uint128_3', 'v3_u128', 'u128', 16),
    ('vec_uint128_31', 'v31_u128', 'u128', 16), ('vec_uint256_5', 'v5_u256', 'u256', 32), ('vec_bool_5', 'v5_bool', 'bool', 1),
    ('vec_bool_513', 'v513_bool', 'bool', 1),
]
PL = [('proglist_uint32', 'pl_u32', 'u', 4), ('proglist_uint64', 'pl_u64', 'u64', 8), ('proglist_uint128', 'pl_u128', 'u128', 16),
      ('proglist_uint256', 'pl_u256', 'u256', 32), ('proglist_bool', 'pl_bool', 'bool', 1)]

A = Defs('r9_01_vec_access.txt')
for typ, p, kind, w in VEC + PL:
    f = 'types/%s_def_generated.bend' % typ
    t = rd(f)
    vec = typ.startswith('vec_')
    what = 'Vector' if vec else 'ProgressiveList'
    sp = '%s element access: index i is valid iff i < length (%s)' % (what, 'N' if vec else 'the list length')
    # 1 get bound
    old = '  %s_get_in(U32.is_lt(i, n), o, i)' % p
    A.add('r9-a01-get-bound', typ, 'encode,root', f, '%s_get_n,%s_get' % (p, p), sp,
          'the getter accepts i == length (is_le instead of is_lt): get(v, len) answers Some of the bytes past the end',
          'off-by-one bound', old, old.replace('is_lt', 'is_le'))
    # 2 set bound
    m = re.search(r'^  %s_put_at\((.*), o, i, v\)$' % p, t, re.M)
    old = m.group(0)
    A.add('r9-a02-set-bound', typ, 'encode,root', f, '%s_set_n,%s_set' % (p, p), sp,
          'the setter accepts i == length (is_le): set(v, len, x) answers ok and writes past the last element',
          'off-by-one bound', old, old.replace('U32.is_lt(i, n)', 'U32.is_le(i, n)'))
    # 3 set bound dropped entirely
    if 'Bool.and' in old:
        new = old.replace('Bool.and(U32.is_lt(i, n), ', '').replace(', o, i, v)', ', o, i, v)')
        new = re.sub(r'U32\.is_le\(v, (\d+)\)\)', r'U32.is_le(v, \1)', new)
    else:
        new = old.replace('U32.is_lt(i, n)', 'True{}')
    A.add('r9-a03-set-no-index-check', typ, 'encode,root', f, '%s_set_n,%s_set' % (p, p), sp,
          'the setter does not test the index at all', 'missing guard', old, new)
    # 4 value range (u8 / u16 elements are U32 words)
    m = re.search(r'U32\.is_le\(v, (255|65535)\)', old)
    if m:
        lim = int(m.group(1))
        A.add('r9-a04-set-value-range', typ, 'encode,root', f, '%s_set_n,%s_set' % (p, p),
              'uint%d values are below 2^%d; a checked setter refuses a larger word' % ((8, 16)[lim > 255], (8, 16)[lim > 255]),
              'the range test admits 2^k (is_le(v, 2^k) instead of 2^k - 1): the setter writes a truncated value and answers ok',
              'off-by-one range', old, old.replace('U32.is_le(v, %d)' % lim, 'U32.is_le(v, %d)' % (lim + 1)))
    # 5 length divisor
    old = '  (o, U32.div(n, %d))' % w
    if kind == 'bool':
        new = '  (o, U32.div(n, 2))'
        fl = 'the element count of a boolean collection is computed as bytes / 2 (an element taken as 2 bytes)'
    else:
        new = '  (o, n)'
        fl = 'the element count is the byte count (the division by the element size %d is missing)' % w
    A.add('r9-a05-len-unit', typ, 'encode,root', f, '%s_len_of,%s_len,%s_get,%s_set' % (p, p, p, p),
          '%s length is counted in elements of %d bytes' % (what, w), fl, 'unit slip', old, new)
    # 6 reader position / width
    m = re.search(r'^def %s_at\(.*$' % p, t, re.M)
    old = m.group(0)
    if kind == 'u':
        new = old.replace('(i * %d : U32), %d)' % (w, w), '(i * %d : U32), %d)' % (w, max(1, w // 2))) if w > 1 else \
            old.replace('(i * 1 : U32), 1)', '((i + 1) * 1 : U32), 1)')
        fl = ('the reader takes %d byte(s) of the element (the high bytes are lost)' % max(1, w // 2)) if w > 1 else \
            'the reader takes the byte after the element'
    elif kind == 'u64':
        new = old.replace('(i * 8 : U32)', '(i * 4 : U32)')
        fl = 'the reader steps 4 bytes per element (uint32 stride)'
    elif kind == 'u128':
        new = old.replace('(i * 16 : U32)', '(i * 8 : U32)')
        fl = 'the reader steps 8 bytes per element (uint64 stride)'
    elif kind == 'u256':
        new = old.replace('(i * 32 : U32)', '(i * 16 : U32)')
        fl = 'the reader steps 16 bytes per element (uint128 stride)'
    else:
        new = None
    if new:
        A.add('r9-a06-get-position', typ, 'encode,root', f, '%s_at,%s_get_in,%s_get' % (p, p, p),
              'element i occupies bytes [i*size, (i+1)*size) of the packed serialization (little-endian)', fl, 'stride / width slip', old, new)
    # 7 writer position / width
    m = re.search(r'^    case True\{\}: \((O\.words_write|O\.words_write_u64|uint128_d\.Uint128_into_words|uint256_d\.Uint256_into_words)\(.*$', t, re.M)
    old = m.group(0)
    if kind == 'u':
        new = old.replace(', v, %d), True{})' % w, ', v, %d), True{})' % max(1, w // 2)) if w > 1 else old.replace('(i * 1 : U32)', '((i + 1) * 1 : U32)')
        fl = ('the writer stores only %d byte(s) of the value' % max(1, w // 2)) if w > 1 else 'the writer stores the byte at i + 1'
    elif kind == 'bool':
        new = old.replace('O.pick(v, 1, 0)', 'O.pick(v, 0, 1)')
        fl = 'the writer stores 1 for False and 0 for True'
    else:
        new = old.replace('(i * %d : U32)' % w, '(i * %d : U32)' % (w // 2))
        fl = 'the writer steps %d bytes per element' % (w // 2)
    A.add('r9-a07-set-position', typ, 'encode,root', f, '%s_put_at,%s_set_n,%s_set' % (p, p, p),
          'set(v, i, x) changes exactly element i to x', fl, 'stride / width / polarity slip', old, new)
    # 8 bool reader polarity
    if kind == 'bool':
        old = '  (o, U32.is_eq(x, 1))'
        A.add('r9-a08-bool-read', typ, 'encode,root', f, '%s_bool_at,%s_at,%s_get' % (p, p, p),
              'boolean byte 0x01 is True, 0x00 is False', 'the getter answers True for a byte 0 (is_eq(x, 0))', 'inverted polarity',
              old, '  (o, U32.is_eq(x, 0))')
        A.add('r9-a08-bool-read', typ, 'encode,root', f, '%s_bool_at,%s_at,%s_get' % (p, p, p),
              'boolean byte 0x01 is True, 0x00 is False (only those bytes occur)', 'the getter answers True for any non-zero byte (lt(0, x))',
              'lenient decode habit (equivalent on valid objects)', old, '  (o, U32.is_lt(0, x))')
    # 9 progressive list append (u128 / u256 have no law naming their append)
    if not vec:
        m = re.search(r'^    case True\{\}: %s_put_(?:at|app)\(True\{\}, O\.words_resize\(O\.words_fit\(o, \(\(n \+ 1 : U32\) \* %d : U32\)\), \(\(n \+ 1 : U32\) \* %d : U32\)\), n, v\)$' % (p, w, w), t, re.M)
        if m:
            old = m.group(0)
            A.add('r9-a09-append-slot', typ, 'encode,root', f, '%s_grow,%s_app_c,%s_append' % (p, p, p),
                  'append(l, x) adds x as element len(l)', 'the new element is written at index n - 1 (over the last element)', 'off-by-one slot',
                  old, old.replace(', n, v)', ', (n - 1 : U32), v)'))
            A.add('r9-a09-append-slot', typ, 'encode,root', f, '%s_grow,%s_app_c,%s_append' % (p, p, p),
                  'append(l, x) grows the length by one element', 'the length grows by one byte, not one element', 'unit slip',
                  old, old.replace('O.words_resize(O.words_fit(o, ((n + 1 : U32) * %d : U32)), ((n + 1 : U32) * %d : U32))' % (w, w),
                                   'O.words_resize(O.words_fit(o, ((n + 1 : U32) * %d : U32)), ((n * %d : U32) + 1 : U32))' % (w, w)))
A.write()

# ---------------------------------------------------------------------------------------------------------
# B. Bit vectors as byte arrays (bv1280 / bv1281: get / set / len have no law)
# ---------------------------------------------------------------------------------------------------------
B = Defs('r9_02_bitvec_access.txt')
for typ, p, nbytes, rbits in [('bitvector_1280', 'bv1280', 160, 0), ('bitvector_1281', 'bv1281', 161, 1)]:
    f = 'types/%s_def_generated.bend' % typ
    t = rd(f)
    old = '  %s_get_in(U32.is_lt(i, n), o, i)' % p
    B.add('r9-b01-bitvec-get', 'ProgressiveBitsStruct', 'encode,root', f, '%s_get_n,%s_get' % (p, p),
          'Bitvector[N] holds ceil(N/8) bytes; byte i exists iff i < ceil(N/8)', 'the byte getter accepts i == ceil(N/8)', 'off-by-one',
          old, old.replace('is_lt', 'is_le'))
    old = '  %s_put_at(Bool.and(U32.is_lt(i, n), U32.is_le(v, 255)), o, i, v)' % p
    B.add('r9-b02-bitvec-set', 'ProgressiveBitsStruct', 'encode,root', f, '%s_set_n,%s_set' % (p, p),
          'a byte of a bit vector is < 256', 'the byte setter admits 256 (writes 0 and answers ok)', 'off-by-one range',
          old, old.replace('U32.is_le(v, 255)', 'U32.is_le(v, 256)'))
    B.add('r9-b02-bitvec-set', 'ProgressiveBitsStruct', 'encode,root', f, '%s_set_n,%s_set' % (p, p),
          'Bitvector[N] holds ceil(N/8) bytes', 'the byte setter accepts i == ceil(N/8) (writes the byte after the vector)', 'off-by-one',
          old, old.replace('U32.is_lt(i, n)', 'U32.is_le(i, n)'))
    B.add('r9-b02-bitvec-set', 'ProgressiveBitsStruct', 'encode,root', f, '%s_set_n,%s_set' % (p, p),
          'Bitvector[N] holds ceil(N/8) bytes', 'the byte setter tests i against N bits, not ceil(N/8) bytes', 'bits-vs-bytes unit',
          old, old.replace('U32.is_lt(i, n)', 'U32.is_lt(i, %s)' % typ.split('_')[1]))
    old = '    case True{}: (O.words_write(o, i, v, 1), True{})'
    B.add('r9-b03-bitvec-write', 'ProgressiveBitsStruct', 'encode,root', f, '%s_put_at,%s_set' % (p, p),
          'set(b, i, x) changes byte i only', 'the setter writes two bytes (the next byte is cleared)', 'width slip',
          old, '    case True{}: (O.words_write(o, i, v, 2), True{})')
    old = '    case True{}: %s_some(O.words_byte_at(o, i, 1))' % p
    B.add('r9-b04-bitvec-read', 'ProgressiveBitsStruct', 'encode,root', f, '%s_get_in,%s_get' % (p, p),
          'get(b, i) is byte i', 'the getter reads byte i + 1', 'off-by-one position',
          old, '    case True{}: %s_some(O.words_byte_at(o, (i + 1 : U32), 1))' % p)
B.write()

# ---------------------------------------------------------------------------------------------------------
# C. Composite vectors / progressive lists of fixed containers (get / set have no law)
# ---------------------------------------------------------------------------------------------------------
C = Defs('r9_03_composite_access.txt')
OWN = {'vec_FixedTestStruct_4': 'ComplexTestStruct', 'proglist_SmallTestStruct': 'ProgressiveTestStruct'}
for typ, p, el in [('vec_FixedTestStruct_4', 'v4_FixedTestStruct', 'FixedTestStruct_d.FixedTestStruct'),
                   ('proglist_SmallTestStruct', 'pl_SmallTestStruct', 'SmallTestStruct_d.SmallTestStruct')]:
    f = 'types/%s_def_generated.bend' % typ
    old = '    case %s_Seq{arr, +n}: %s_get_in(U32.is_lt(i, n), arr, n, i)' % (p, p)
    C.add('r9-c01-composite-get', OWN[typ], 'encode,root', f, '%s_get' % p, 'element i exists iff i < length',
          'the getter accepts i == length (reads the slot after the last element: for a vector the array has exactly N slots)', 'off-by-one',
          old, old.replace('is_lt', 'is_le'))
    old = '    case %s_Seq{arr, +n}: %s_put_in(U32.is_lt(i, n), arr, n, i, v)' % (p, p)
    C.add('r9-c02-composite-set', OWN[typ], 'encode,root', f, '%s_set' % p, 'element i exists iff i < length',
          'the setter accepts i == length', 'off-by-one', old, old.replace('is_lt', 'is_le'))
    old = '  %s_took(n, Array.get(%s, arr, i))' % (p, el)
    C.add('r9-c03-composite-read', OWN[typ], 'encode,root', f, '%s_at,%s_get' % (p, p), 'get(l, i) is element i',
          'the getter reads element 0 whatever i', 'index ignored', old, '  %s_took(n, Array.get(%s, arr, 0))' % (p, el))
    old = '    case True{}: (%s_Seq{Array.set(%s, arr, i, v), n}, True{})' % (p, el)
    C.add('r9-c04-composite-write', OWN[typ], 'encode,root', f, '%s_put_in,%s_set' % (p, p), 'set(l, i, x) replaces element i',
          'the setter writes element 0 whatever i', 'index ignored', old, '    case True{}: (%s_Seq{Array.set(%s, arr, 0, v), n}, True{})' % (p, el))
C.write()

# ---------------------------------------------------------------------------------------------------------
# D. Container field getters / setters / swaps: a neighbour field of the same type
# ---------------------------------------------------------------------------------------------------------
D = Defs('r9_04_container_fields.txt')
CONT = [  # (type name, def file stem, record prefix, max faults per kind)
    ('FixedTestStruct', 'FixedTestStruct', 'FixedTestStruct', 2), ('SmallTestStruct', 'SmallTestStruct', 'SmallTestStruct', 2),
    ('VarTestStruct', 'VarTestStruct', 'VarTestStruct', 2), ('ComplexTestStruct', 'ComplexTestStruct', 'ComplexTestStruct', 2),
    ('BitsStruct', 'BitsStruct', 'BitsStruct', 3), ('ProgressiveBitsStruct', 'ProgressiveBitsStruct', 'ProgressiveBitsStruct', 3),
    ('ProgressiveComplexTestStruct', 'ProgressiveComplexTestStruct', 'ProgressiveComplexTestStruct', 2),
    ('FuluBeaconState', 'FuluBeaconState', 'BeaconState', 4), ('FuluExecutionPayload', 'FuluExecutionPayload', 'ExecutionPayload', 3),
    ('FuluExecutionPayloadHeader', 'FuluExecutionPayloadHeader', 'ExecutionPayloadHeader', 2),
    ('FuluLightClientUpdate', 'FuluLightClientUpdate', 'LightClientUpdate', 2), ('FuluLightClientHeader', 'FuluLightClientHeader', 'LightClientHeader', 1),
    ('FuluValidator', 'FuluValidator', 'Validator', 2), ('FuluBeaconBlockHeader', 'FuluBeaconBlockHeader', 'BeaconBlockHeader', 2),
    ('FuluAttestationData', 'FuluAttestationData', 'AttestationData', 2), ('FuluPendingDeposit', 'FuluPendingDeposit', 'PendingDeposit', 1),
    ('FuluDepositData', 'FuluDepositData', 'DepositData', 1), ('FuluWithdrawal', 'FuluWithdrawal', 'Withdrawal', 1),
    ('FuluSyncCommitteeContribution', 'FuluSyncCommitteeContribution', 'SyncCommitteeContribution', 1),
    ('FuluBeaconBlockBody', 'FuluBeaconBlockBody', 'BeaconBlockBody', 2),
]
SIG_GET = re.compile(r'^def (\w+?)_get_(\w+)\(o: (\w+)\) -> \3 & ([\w.]+):\n  match o:\n    case (\w+)\{([^}]*)\}: \((\w+)\{([^}]*)\}, (\w+)\)$', re.M)
SIG_SET = re.compile(r'^def (\w+?)_set_(\w+)\(o: (\w+), \+v: ([\w.]+)\) -> \3:\n  match o:\n    case (\w+)\{([^}]*)\}: (\w+)\{([^}]*)\}$', re.M)
SIG_SWAP = re.compile(r'^def (\w+?)_swap_(\w+)\(o: (\w+), v: ([\w.]+)\) -> \3 & \4:\n  match o:\n    case (\w+)\{([^}]*)\}: \((\w+)\{([^}]*)\}, (\w+)\)$', re.M)
for typ, stem, R0, k in CONT:
    f = 'types/%s_def_generated.bend' % stem
    t = rd(f)
    # record-level getters: group by (record, type)
    gets = [(m.group(1), m.group(2), m.group(3), m.group(4), m) for m in SIG_GET.finditer(t) if m.group(1) == m.group(3)]
    sets = [(m.group(1), m.group(2), m.group(3), m.group(4), m) for m in SIG_SET.finditer(t) if m.group(1) == m.group(3)]
    swaps = [(m.group(1), m.group(2), m.group(3), m.group(4), m) for m in SIG_SWAP.finditer(t) if m.group(1) == m.group(3)]
    by = {}
    for rec, fld, _, ty, _ in gets:
        by.setdefault((rec, ty), []).append(fld)
    nget = nset = 0
    for rec, fld, _, ty, m in gets:
        sib = by[(rec, ty)]
        if len(sib) < 2 or nget >= k:
            continue
        f2 = sib[(sib.index(fld) + 1) % len(sib)]
        line = m.group(0).split('\n')[-1]
        new = line[:line.rindex(', %s)' % fld)] + ', %s)' % f2
        D.add('r9-d01-getter-neighbour', typ, 'encode,root', f, '%s_get_%s,%s_get_%s' % (rec, fld, R0, fld),
              'a container getter returns the field it names (fields are distinct values)',
              '%s_get_%s returns the neighbour field %s of the same type' % (rec, fld, f2), 'copy-paste of the neighbour getter', line, new)
        nget += 1
    for rec, fld, _, ty, m in sets:
        sib = by.get((rec, ty), [])
        if len(sib) < 2 or fld not in sib or nset >= k:
            continue
        f2 = sib[(sib.index(fld) + 1) % len(sib)]
        line = m.group(0).split('\n')[-1]
        names = [x.strip().lstrip('+') for x in m.group(6).split(',')]
        args = [x.strip() for x in m.group(8).split(',')]
        i, j = names.index(fld), names.index(f2)
        args2 = list(args)
        args2[i], args2[j] = names[i], 'v'
        new = line[:line.rindex(m.group(7) + '{')] + m.group(7) + '{' + ', '.join(args2) + '}'
        D.add('r9-d02-setter-neighbour', typ, 'encode,root', f, '%s_set_%s,%s_set_%s' % (rec, fld, R0, fld),
              'a container setter replaces the field it names and no other',
              '%s_set_%s writes the neighbour field %s (the named field keeps its value)' % (rec, fld, f2), 'copy-paste of the neighbour setter', line, new)
        nset += 1
    ns = 0
    for rec, fld, _, ty, m in swaps:
        if ns >= 2:
            continue
        line = m.group(0).split('\n')[-1]
        names = [x.strip().lstrip('+') for x in m.group(6).split(',')]
        new = line[:line.rindex('(' + m.group(7) + '{')] + '(' + m.group(7) + '{' + ', '.join(names) + '}, v)'
        D.add('r9-d03-swap-noop', typ, 'encode,root', f, '%s_swap_%s,%s_swap_%s' % (rec, fld, R0, fld),
              'swap_f(o, v) puts v in field f and hands back the old value',
              '%s_swap_%s leaves the object unchanged and hands back v' % (rec, fld), 'swap written as a peek', line, new)
        ns += 1
    # top-level of grouped containers: the group call of a neighbour
    tg = [(mm.group(1), mm.group(2)) for mm in re.finditer(r'^def %s_get_(\w+)\(o: %s\) -> %s & ([\w.]+):' % (R0, R0, R0), t, re.M)]
    nt = 0
    for fld, ty in tg:
        mm = re.search(r'%s_got_%s\(([^\n]*?)(%s_g(\d+))_get_%s\(g\d+\)\)' % (R0, fld, R0, fld), t)
        if not mm or nt >= max(1, k // 2):
            continue
        grp = mm.group(2)
        sib = [x for (x, y) in tg if y == ty and re.search(r'^def %s_get_%s\(' % (grp, x), t, re.M) and x != fld]
        if not sib:
            continue
        f2 = sib[0]
        old = mm.group(0)
        D.add('r9-d04-top-getter-route', typ, 'encode,root', f, '%s_get_%s,%s_got_%s' % (R0, fld, R0, fld),
              'a container getter returns the field it names', 'the top-level getter of %s calls the group getter of %s' % (fld, f2),
              'routing slip in the grouped representation', old, old.replace('%s_get_%s(' % (grp, fld), '%s_get_%s(' % (grp, f2)))
        ms = re.search(r'%s\{([^\n]*?)%s_set_%s\((g\d+), v\)' % (R0, grp, fld), t)
        if ms:
            old = ms.group(0)
            D.add('r9-d05-top-setter-route', typ, 'encode,root', f, '%s_set_%s' % (R0, fld),
                  'a container setter replaces the field it names', 'the top-level setter of %s calls the group setter of %s' % (fld, f2),
                  'routing slip in the grouped representation', old, old.replace('%s_set_%s(' % (grp, fld), '%s_set_%s(' % (grp, f2)))
        nt += 1
D.write()

# ---------------------------------------------------------------------------------------------------------
# E. Group validity of grouped containers (X_gK_valid: no law names them) and BeaconState's serializer (no law names it)
# ---------------------------------------------------------------------------------------------------------
E = Defs('r9_05_group_validity.txt')
for typ, R0, ng in [('FuluBeaconState', 'BeaconState', 5), ('FuluExecutionPayload', 'ExecutionPayload', 2),
                    ('FuluExecutionPayloadHeader', 'ExecutionPayloadHeader', 2), ('FuluBeaconBlockBody', 'BeaconBlockBody', 2),
                    ('ProgressiveBitsStruct', 'ProgressiveBitsStruct', 2)]:
    f = 'types/%s_encode_ssz_generated.bend' % typ
    t = rd(f)
    for g in range(ng):
        # the last accumulation step of the group (va with the highest index): drop the child's flag
        vas = re.findall(r'^def (%s_g%d_va\d+)\(' % (R0, g), t, re.M)
        if not vas:
            continue
        top = sorted(vas, key=lambda s: int(s.rsplit('va', 1)[1]))[-1]
        body = re.search(r'^def %s\(.*\n  \((\w+), ok\) = pair\n(  .*)$' % top, t, re.M)
        if not body:
            continue
        fld, line = body.group(1), body.group(2)
        if 'Bool.and(acc, ok)' in line:
            E.add('r9-e01-group-validity', typ, 'encode', f, '%s,%s_g%d_valid,%s_valid_f,%s_valid' % (top, R0, g, R0, R0),
                  'a container value is valid iff every field is valid (here field %s of group %d)' % (fld, g),
                  'group %d ignores the validity of its field %s (Bool.and(acc, ok) -> acc)' % (g, fld), 'dropped conjunct', line,
                  line.replace('Bool.and(acc, ok)', 'acc'))
        # the first step: the group's first child flag is replaced by True
        mv = re.search(r'^def %s_g%d_valid\(.*\n  match o:\n(    case .*: %s_g%d_va0\(.*True\{\}, )([\w.]+_valid(?:_f)?)\((\w+)\)\)$' % (R0, g, R0, g), t, re.M)
        if mv:
            line = mv.group(0).split('\n')[-1]
            E.add('r9-e01-group-validity', typ, 'encode', f, '%s_g%d_valid,%s_valid_f,%s_valid' % (R0, g, R0, R0),
                  'a container value is valid iff every field is valid (here the first variable field %s of group %d)' % (mv.group(3), g),
                  'group %d does not check its first field %s (its validity is replaced by True)' % (g, mv.group(3)), 'dropped check', line,
                  line.replace('%s(%s))' % (mv.group(2), mv.group(3)), '(%s, True{}))' % mv.group(3)))
f = 'types/FuluBeaconState_encode_ssz_generated.bend'
old = '  (o, O.ser_done(O.is_poisoned(m), n, out))'
t = rd(f)
if t.count(old) == 1:
    E.add('r9-e02-state-serialize', 'FuluBeaconState', 'encode', f, 'BeaconState_senc_out,BeaconState_serialize',
          'serialize refuses a value whose checked writer reports an invalid field', 'BeaconState_serialize ignores the writers\' flag',
          'refusal dropped (the size pass alone decides)', old, '  (o, O.ser_done(False{}, n, out))')
old = ' .|. O.pz(Fulu_bitvector_4_e.bv4_valid(justification_bits)) : U32)'
if t.count(old) == 1:
    E.add('r9-e02-state-serialize', 'FuluBeaconState', 'encode', f, 'BeaconState_g2_pw0,BeaconState_putk,BeaconState_serialize',
          'Bitvector[4] has zero padding bits; serialize refuses a justification_bits byte above 15',
          'the checked writer of group 2 does not flag an invalid justification_bits', 'refusal dropped', old, ' : U32)')
E.write()

# ---------------------------------------------------------------------------------------------------------
# F. CompatibleUnion selectors (no law names <U>_selector) and roots of odd-length fixed vectors (chunk depth)
# ---------------------------------------------------------------------------------------------------------
F = Defs('r9_06_union_roots.txt')
for typ in ('CompatibleUnionA', 'CompatibleUnionBC', 'CompatibleUnionABCA'):
    f = 'types/%s_def_generated.bend' % typ
    t = rd(f)
    m = re.search(r'^def %s_selector\(.*\n  match o:\n((?:    case .*\n?)+)' % typ, t, re.M)
    cases = [l for l in m.group(1).split('\n') if l.strip()]
    sels = [int(re.search(r', (\d+)\)$', l).group(1)) for l in cases]
    for idx, l in enumerate(cases[:2]):
        s = sels[idx]
        s2 = sels[(idx + 1) % len(sels)] if len(set(sels)) > 1 else s + 1
        if s2 == s:
            s2 = s + 1
        F.add('r9-f01-union-selector', typ, 'encode,root', f, '%s_selector' % typ,
              'CompatibleUnion: the selector of a value is the index its option was declared with (1..127)',
              'the selector accessor answers %d for option %d (declared %d)' % (s2, idx, s), 'selector table slip', l, l[:l.rindex(', %d)' % s)] + ', %d)' % s2)
ROOTS = [  # (type, prefix, correct depth, wrong depth, chunks)
    ('vec_uint8_513', 'v513_u8', 5, 4, 17), ('vec_uint16_5', 'v5_u16', 0, 1, 1), ('vec_uint16_513', 'v513_u16', 6, 5, 33),
    ('vec_uint32_31', 'v31_u32', 2, 3, 4), ('vec_uint64_3', 'v3_u64', 0, 1, 1), ('vec_uint128_31', 'v31_u128', 4, 5, 16),
    ('vec_uint256_5', 'v5_u256', 3, 2, 5), ('vec_bool_513', 'v513_bool', 5, 6, 17), ('bitvector_1281', 'bv1281', 3, 2, 6),
    ('bitvector_1280', 'bv1280', 3, 4, 5), ('vec_uint256_3', 'v3_u256', 2, 1, 3), ('vec_uint128_3', 'v3_u128', 1, 2, 2),
]
for typ, p, d, d2, ch in ROOTS:
    f = 'types/%s_hashtreeroot_generated.bend' % typ
    t = rd(f)
    old = 'O.words_root(hl, h, o, %d, seg)' % d
    if t.count(old) != 1:
        print('skip root', typ, d)
        continue
    F.add('r9-f02-vector-root-depth', typ, 'root', f, '%s_root,%s_hash_tree_root' % (p, typ),
          'merkleize(pack(v)) pads the %d chunk(s) to the next power of two (depth %d)' % (ch, d),
          'the tree depth is %d (%s)' % (d2, 'one level too deep' if d2 > d else 'one level too shallow'), 'ceil/floor log2 slip', old,
          'O.words_root(hl, h, o, %d, seg)' % d2)
F.write()
