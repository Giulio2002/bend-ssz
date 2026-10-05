#!/usr/bin/env python3
"""gen_defs12.py TREE OUT_DIR: round 12 fault definitions (defs/r12_*.txt). Run on the server only.

Round 12 focus (brief): PROOF GAPS in (1) the hash_tree_root of basic and byte-vector leaves as reached through container roots,
(2) bit list / bit vector roots, (3) the serialize path of unions and progressive containers, (4) cached trees created from a
non-empty (decoded) list and uncache, (5) boolean fields and bit vector padding inside containers. Each family below is one
implementer mistake against a rule of ssz/simple-serialize.md (consensus-specs v1.6.1), instantiated on every generated file
that has the shape (sampled where the shape repeats). Families:

  r12-a01-leaf-noswap      leaf root (ByteVector / Bitvector record): the first word not byte-swapped into the chunk
  r12-a02-leaf-last-drop   leaf root: the last word of the bytes left out of the chunk (zero)
  r12-a03-leaf-right-align single-word leaf root: the bytes right-aligned in the chunk (big-endian padding)
  r12-a04-leaf-word-order  leaf root: two adjacent words exchanged
  r12-a05-u64-as-u32       container root: a uint64 field's chunk packs only its low 32 bits
  r12-a06-uint-width-mask  uint16 / uint32 / uint8 root: the value masked to a narrower width before packing
  r12-a07-shared-chunks    src/obj.bend u64_chunk / bool_chunk / u32_chunk: limb order, unswapped boolean, wrong limb
  r12-b01-bitlist-depth    Bitlist[N] root: chunk-count depth one off (limit (N + 255) // 256 misread)
  r12-b02-delimiter        src/obj.bend bit list decode: the delimiter counted as a bit / searched in the wrong byte
  r12-c01-ser-flag         X_serialize: the validity flag of the checked writer ignored (an invalid value serialized)
  r12-c02-ser-unchecked    X_serialize: the unchecked writer (putn) used instead of the checked one (putk)
  r12-c03-union-payload-ok union validity: an option's payload validity dropped
  r12-c04-union-sel-index  union writer: the selector byte written as the option's index, not its selector value
  r12-c05-prog-valid-last  progressive container validity: the last field's validity dropped
  r12-d01-cache-lo         X_cache: the fresh cache's dirty window starts at leaf 1 (leaf 0 never hashed)
  r12-d02-cache-depth0     X_cache: the tree depth taken for an empty list (cap(0)), not for the list's length
  r12-d03-uncache-drop     X_uncache: returns the empty list (the items dropped)
  r12-e01-bool-pos         Validator boolean check on the wrong byte
  r12-e02-vlist-ck         List[Validator] validity: element checks dropped / wrong stride / first element unchecked
  r12-e03-bv-pad-pos       container decode: a bit vector field's padding checked at the wrong byte
"""
import json, os, re, sys

tree, out = sys.argv[1:3]
T = os.path.join(tree, 'types')
API = os.path.join(tree, 'proofs', 'api')
blocks = {}
OPN = {'decode': 'decode_ssz', 'encode': 'encode_ssz', 'root': 'hashtreeroot'}


def rd(f):
    return open(os.path.join(T, f)).read()


def add(fam, typ, ops, fname, syms, spec, fault, why, hunks, proofs=None, count=None):
    b = ['=== ' + fam, 'type: ' + typ, 'ops: ' + ops, 'file: ' + fname, 'sym: ' + ','.join(dict.fromkeys(s for s in syms if s)),
         'spec: ' + spec, 'fault: ' + fault, 'why: ' + why]
    if proofs:
        b.append('proofs: ' + ','.join(proofs))
    if count:
        b.append('count: %d' % count)
    for o, n in hunks:
        assert '\n' not in o and '\n' not in n
        b += ['-' + o, '+' + n]
    blocks.setdefault(fam, []).append('\n'.join(b))


def has_fac(typ, op):
    return os.path.exists(os.path.join(API, '%s_%s_proof_generated.bend' % (typ, OPN[op])))


def line_of(text, sub):
    for l in text.split('\n'):
        if sub in l:
            return l
    raise KeyError(sub)


IMPORTERS = {}
for f in sorted(os.listdir(T)):
    if f.endswith('_hashtreeroot_generated.bend'):
        for m in re.finditer(r'^import \./(\S+_hashtreeroot_generated\.bend)', rd(f), re.M):
            IMPORTERS.setdefault(m.group(1), []).append(f)


def containers(leaf_file, n=2):
    """The smallest container root facades whose root file imports leaf_file."""
    c = []
    for f in IMPORTERS.get(leaf_file, []):
        t = f[:-len('_hashtreeroot_generated.bend')]
        p = os.path.join(API, '%s_hashtreeroot_proof_generated.bend' % t)
        if os.path.exists(p) and not t.startswith(('Fulu_list', 'Fulu_vec', 'vec_', 'list_', 'proglist')):
            c.append((os.path.getsize(os.path.join(T, f)), t))
    c.sort()
    return [t for _, t in c[:n]]


def leaf_target(typ, fname):
    """(type header, extra proofs) for a leaf root fault: the leaf's own facade if it has one, plus the smallest containers."""
    cs = containers(fname)
    extra = ['proofs/api/%s_hashtreeroot_proof_generated.bend' % t for t in cs]
    if has_fac(typ, 'root'):
        return typ, extra
    return (cs[0] if cs else typ), extra[1:]


S_LEAF = 'ssz/simple-serialize.md Merkleization: hash_tree_root(ByteVector / Bitvector) = merkleize(pack(bytes)): the bytes in order, little-endian chunk layout, zero right padding'
S_U = 'ssz/simple-serialize.md Merkleization: hash_tree_root(uintN / boolean) = pack: serialize(value) little-endian, right-padded with zeros to 32 bytes'

# ---- A: leaf roots ---------------------------------------------------------------------------------------------------------
LEAVES = ['FuluBytes1', 'FuluBytes4', 'FuluBytes8', 'FuluBytes20', 'FuluBytes32', 'FuluBytes48', 'FuluBytes96',
          'Fulu_bitvector_4', 'Fulu_bitvector_64', 'Fulu_bitvector_128', 'Fulu_bitvector_512', 'bitvector_15', 'bitvector_31']
for typ in LEAVES:
    fname = typ + '_hashtreeroot_generated.bend'
    t = rd(fname)
    fn = re.search(r'^def (\w+_root)\(', t, re.M).group(1)
    words = sorted(set(int(x) for x in re.findall(r'B\.swap32\(w(\d+)\)', t)))
    ty, extra = leaf_target(typ, fname)
    if t.count('B.swap32(w0)') == 1:
        add('r12-a01-leaf-noswap', ty, 'root', 'types/' + fname, [fn], S_LEAF,
            '%s: word 0 of the bytes put into the chunk without the byte swap (bytes 0..3 reversed in the chunk)' % typ,
            'the record words are little-endian loads of the bytes; SHA-256 reads the chunk big-endian, so every word must be swapped',
            [('B.swap32(w0)', 'w0')], extra)
    last = max(words)
    if last > 0:
        add('r12-a02-leaf-last-drop', ty, 'root', 'types/' + fname, [fn], S_LEAF,
            '%s: the last word (w%d) left out of the chunk (zero)' % (typ, last),
            'an off-by-one in the word count of a byte vector whose size is not a multiple of 32 (or whose last chunk is partial)',
            [('B.swap32(w%d)' % last, '0')], extra)
    if last == 0 and 'D.D{B.swap32(w0), 0, 0, 0, 0, 0, 0, 0}' in t:
        add('r12-a03-leaf-right-align', ty, 'root', 'types/' + fname, [fn], S_LEAF,
            '%s: the bytes right-aligned in the chunk (zero padding on the left)' % typ,
            'big-endian intuition: padding a short value on the left, as a number',
            [('D.D{B.swap32(w0), 0, 0, 0, 0, 0, 0, 0}', 'D.D{0, 0, 0, 0, 0, 0, 0, B.swap32(w0)}')], extra)
for typ, a in [('FuluBytes8', 0), ('FuluBytes20', 3), ('FuluBytes32', 6), ('FuluBytes48', 7), ('FuluBytes96', 15), ('Fulu_bitvector_64', 0),
               ('Fulu_bitvector_512', 8)]:
    fname = typ + '_hashtreeroot_generated.bend'
    t = rd(fname)
    fn = re.search(r'^def (\w+_root)\(', t, re.M).group(1)
    ty, extra = leaf_target(typ, fname)
    o = 'B.swap32(w%d), B.swap32(w%d)' % (a, a + 1)
    if t.count(o) == 1:
        add('r12-a04-leaf-word-order', ty, 'root', 'types/' + fname, [fn], S_LEAF,
            '%s: words %d and %d exchanged in the chunk' % (typ, a, a + 1), 'a word-order slip in the generated chunk literal',
            [(o, 'B.swap32(w%d), B.swap32(w%d)' % (a + 1, a))], extra)
    elif typ in ('FuluBytes48', 'FuluBytes96'):
        # the pair crosses a chunk boundary: exchange the last word of chunk 0 with the first word of chunk 1
        o1 = 'B.swap32(w%d)}, D.D{B.swap32(w%d)' % (a, a + 1)
        if t.count(o1) == 1:
            add('r12-a04-leaf-word-order', ty, 'root', 'types/' + fname, [fn], S_LEAF,
                '%s: the last word of a chunk and the first word of the next chunk exchanged' % typ,
                'chunk boundary misplaced by one word', [(o1, 'B.swap32(w%d)}, D.D{B.swap32(w%d)' % (a + 1, a))], extra)

u64c = []
for f in sorted(os.listdir(T)):
    if not f.endswith('_hashtreeroot_generated.bend') or f.startswith(('Fulu_list', 'Fulu_vec', 'vec_', 'list_', 'proglist', 'uint64')):
        continue
    t = rd(f)
    m = re.search(r'uint64_h\.u64_root\(hl, h, (\w+), seg\)', t)
    if not m:
        continue
    typ = f[:-len('_hashtreeroot_generated.bend')]
    if not has_fac(typ, 'root'):
        continue
    o = m.group(0)
    if t.count(o) != 1:
        continue
    fn = None
    for d in re.finditer(r'^def (\w+)\(', t, re.M):
        if d.start() <= m.start():
            fn = d.group(1)
    u64c.append((typ, f, fn, o, m.group(1)))
for typ, f, fn, o, x in u64c[::2]:
    add('r12-a05-u64-as-u32', typ, 'root', 'types/' + f, [fn, 'u64_root'], S_U,
        '%s: the uint64 field `%s` hashed as its low 32 bits (packed like a uint32)' % (typ, x),
        'width confusion for an Epoch / Slot / Gwei field: the high word is dropped from the chunk',
        [(o, '(h, O.u32_chunk(O.u64_lo_of(%s)))' % x)])

for typ, fn, old, new, what in [
        ('uint16', 'u16_root', 'O.u32_chunk(o)', 'O.u32_chunk((o .&. 255 : U32))', 'uint16 masked to its low byte'),
        ('uint32', 'u32_root', 'O.u32_chunk(o)', 'O.u32_chunk((o .&. 65535 : U32))', 'uint32 masked to its low 16 bits'),
        ('uint8', 'u8_root', 'O.u32_chunk(o)', 'O.u32_chunk((o .&. 127 : U32))', 'uint8 masked to 7 bits')]:
    fname = typ + '_hashtreeroot_generated.bend'
    add('r12-a06-uint-width-mask', typ, 'root', 'types/' + fname, [fn], S_U, '%s root: %s before packing' % (typ, what),
        'a width table off by one size', [(old, new)], ['proofs/api/%s_hashtreeroot_proof_generated.bend' % c for c in containers(fname)])

OBJ = 'src/obj.bend'
for typ, fn, old, new, what, cont in [
        ('uint64', 'u64_chunk', 'case U64{+lo, +hi}: D.D{B.swap32(lo), B.swap32(hi), 0, 0, 0, 0, 0, 0}',
         'case U64{+lo, +hi}: D.D{B.swap32(hi), B.swap32(lo), 0, 0, 0, 0, 0, 0}', 'the two words of a uint64 chunk exchanged (big-endian word order)', 'FuluCheckpoint'),
        ('uint64', 'u64_chunk', 'case U64{+lo, +hi}: D.D{B.swap32(lo), B.swap32(hi), 0, 0, 0, 0, 0, 0}',
         'case U64{+lo, +hi}: D.D{B.swap32(lo), hi, 0, 0, 0, 0, 0, 0}', 'the high word of a uint64 chunk not byte-swapped', 'FuluCheckpoint'),
        ('boolean', 'bool_chunk', 'case True{}: D.D{16777216, 0, 0, 0, 0, 0, 0, 0}', 'case True{}: D.D{1, 0, 0, 0, 0, 0, 0, 0}',
         'True packed as the word 1 (byte 3 of the chunk) instead of byte 0', 'FuluValidator'),
        ('boolean', 'bool_chunk', 'case True{}: D.D{16777216, 0, 0, 0, 0, 0, 0, 0}', 'case True{}: D.D{0, 0, 0, 0, 0, 0, 0, 16777216}',
         'True packed into the last limb of the chunk', 'FuluValidator'),
        ('uint32', 'u32_chunk', 'def u32_chunk(+v: U32) -> D.Digest: D.D{B.swap32(v), 0, 0, 0, 0, 0, 0, 0}',
         'def u32_chunk(+v: U32) -> D.Digest: D.D{0, B.swap32(v), 0, 0, 0, 0, 0, 0}', 'a uint8/16/32 packed into limb 1 (bytes 4..7)', 'FixedTestStruct')]:
    pr = ['proofs/api/%s_hashtreeroot_proof_generated.bend' % cont] if has_fac(cont, 'root') else []
    add('r12-a07-shared-chunks', typ, 'root', OBJ, [fn], S_U, 'src/obj.bend %s: %s' % (fn, what),
        'the shared leaf chunk helper used by every container root', [(old, new)], pr)

# ---- B: bit lists ----------------------------------------------------------------------------------------------------------
S_BL = 'ssz/simple-serialize.md Merkleization: hash_tree_root(Bitlist[N]) = mix_in_length(merkleize(pack_bits(value), limit=chunk_count(type)), len(value)), chunk_count = (N + 255) // 256'
for typ in ['bitlist_1', 'bitlist_2', 'bitlist_8', 'bitlist_15', 'bitlist_16', 'bitlist_17', 'bitlist_31', 'bitlist_32', 'bitlist_33',
            'bitlist_1280', 'bitlist_1281', 'Fulu_bitlist_2048', 'Fulu_bitlist_131072']:
    fname = typ + '_hashtreeroot_generated.bend'
    t = rd(fname)
    m = re.search(r'O\.bits_root\(hl, h, o, (\d+), seg\)', t)
    if not m:
        continue
    d = int(m.group(1))
    fn = re.search(r'^def (\w+_root)\(', t, re.M).group(1)
    ty, extra = leaf_target(typ, fname)
    for nd in ([d + 1] + ([d - 1] if d > 0 and typ in ('bitlist_1280', 'bitlist_1281', 'Fulu_bitlist_2048') else [])):
        if typ == 'Fulu_bitlist_131072' and nd != d + 1:
            continue
        add('r12-b01-bitlist-depth', ty, 'root', 'types/' + fname, [fn], S_BL,
            '%s: the bit chunk tree of depth %d instead of %d' % (typ, nd, d), 'chunk_count of the limit rounded the wrong way / counted in bytes',
            [(m.group(0), 'O.bits_root(hl, h, o, %d, seg)' % nd)], extra)
S_DL = 'ssz/simple-serialize.md Deserialization: Bitlist[N]: the last byte holds the delimiter (its highest set bit), which is not part of the value'
for fn, old, new, what in [
        ('bits_from', 'bits_clear((8 * (len - 1 : U32) + high_bit(last) : U32), copy_in(buf, off, len))',
         'bits_clear((8 * (len - 1 : U32) + high_bit(last) + 1 : U32), copy_in(buf, off, len))', 'the bit count includes the delimiter bit'),
        ('bits_from', 'bits_clear((8 * (len - 1 : U32) + high_bit(last) : U32), copy_in(buf, off, len))',
         'bits_clear((8 * len + high_bit(last) - 8 : U32), copy_in(buf, off, len))', 'the bit count from 8 * len - 8 + high bit (equal for len >= 1; designed as equivalent)')]:
    add('r12-b02-delimiter', 'bitlist_9', 'decode,root', OBJ, [fn, 'bits_in'], S_DL, 'src/obj.bend %s: %s' % (fn, what),
        'delimiter handling at decode', [(old, new)], ['proofs/api/FuluAttestation_decode_ssz_proof_generated.bend'])

# ---- C: union / progressive serialize ---------------------------------------------------------------------------------------
S_SER = 'ssz/simple-serialize.md Serialization: only values of the type are serialized; the object API refuses a value outside the type (docs/API_CONTRACTS.md X_serialize)'
SERT = ['CompatibleUnionA', 'CompatibleUnionBC', 'CompatibleUnionABCA', 'ProgressiveTestStruct', 'ProgressiveVarTestStruct',
        'ProgressiveComplexTestStruct', 'ProgressiveBitsStruct', 'ProgressiveSingleFieldContainerTestStruct',
        'ProgressiveSingleListContainerTestStruct', 'proglist_VarTestStruct', 'proglist_uint64']
for typ in SERT:
    fname = typ + '_encode_ssz_generated.bend'
    t = rd(fname)
    o = '(o, O.ser_done(O.is_poisoned(m), n, out))'
    if t.count(o) == 1:
        fn = re.search(r'^def (\w+_senc_out)\(', t, re.M).group(1)
        add('r12-c01-ser-flag', typ, 'encode', 'types/' + fname, [fn, fn.replace('_senc_out', '_serialize')], S_SER,
            '%s_serialize: the checked writer\'s validity flag ignored (an invalid value is serialized, not refused)' % typ,
            'the serialize result taken from the byte count alone', [(o, '(o, O.ser_done(False{}, n, out))')])
    m = re.search(r'(\w+)_putk\(O\.out_new\(n\), 0, o\)', t)
    if m and t.count(m.group(0)) == 1:
        p = m.group(1)
        add('r12-c02-ser-unchecked', typ, 'encode', 'types/' + fname, [p + '_senc_go', p + '_serialize'], S_SER,
            '%s_serialize writes with the unchecked writer (putn): no validity check on the serialize path' % typ,
            'the serialize path wired to the encode path\'s writer',
            [(m.group(0), '%s_putn(O.out_new(n), 0, o)' % p)])
S_UN = 'ssz/simple-serialize.md (EIP-8016 CompatibleUnion): serialize = selector byte || serialize(value); the value must be a valid value of the selected option'
for typ in ['CompatibleUnionA', 'CompatibleUnionBC', 'CompatibleUnionABCA']:
    fname = typ + '_encode_ssz_generated.bend'
    t = rd(fname)
    for m in re.finditer(r'\((%s_d\.%s_c(\d+)\{v\}), ok\)' % (typ, typ), t):
        add('r12-c03-union-payload-ok', typ, 'encode', 'types/' + fname, ['%s_va%s' % (typ, m.group(2)), typ + '_valid'], S_UN,
            '%s_valid: option %s\'s payload validity dropped (the union is valid whatever its payload)' % (typ, m.group(2)),
            'the union validity reduced to the selector being known', [(m.group(0), '(%s, True{})' % m.group(1))])
    for m in re.finditer(r'^def (%s_pt(\d+))\(' % typ, t, re.M):
        blk = t[m.start():].split('\ndef ')[0]
        ms = re.search(r'O\.w8\(out, pos, (\d+)\)', blk)
        if not ms:
            continue
        i, sel = int(m.group(2)), int(ms.group(1))
        if i == sel:
            continue
        nxt = line_of(blk, ms.group(0))
        o = ms.group(0)
        if nxt.count(o) == 1 and t.count(nxt) == 1:
            add('r12-c04-union-sel-index', typ, 'encode', 'types/' + fname, [m.group(1), typ + '_put'], S_UN,
                '%s: option %d written with selector byte %d (its index) instead of %d' % (typ, i, i, sel),
                'selector = position in the option list, not the declared selector',
                [(nxt, nxt.replace(o, 'O.w8(out, pos, %d)' % i))])
S_PV = 'ssz/simple-serialize.md ProgressiveContainer (EIP-7495): a value is valid when every field value is valid'
for typ in ['ProgressiveTestStruct', 'ProgressiveVarTestStruct', 'ProgressiveComplexTestStruct', 'ProgressiveBitsStruct',
            'ProgressiveSingleListContainerTestStruct']:
    fname = typ + '_encode_ssz_generated.bend'
    t = rd(fname)
    vas = [int(x) for x in re.findall(r'^def %s_va(\d+)\(' % typ, t, re.M)]
    if not vas:
        continue
    k = max(vas)
    body = t.split('def %s_va%d(' % (typ, k))[1].split('\ndef ')[0]
    for l in body.split('\n'):
        if 'Bool.and(acc, ok))' in l and l.count('Bool.and(acc, ok))') == 1:
            if t.count(l) == 1:
                add('r12-c05-prog-valid-last', typ, 'encode', 'types/' + fname, ['%s_va%d' % (typ, k), typ + '_valid_f', typ + '_valid'], S_PV,
                    '%s_valid: the last field\'s validity dropped' % typ, 'accumulator slip in the last step',
                    [(l, l.replace('Bool.and(acc, ok))', 'acc)'))])
            break

# ---- D: cached trees --------------------------------------------------------------------------------------------------------
S_C = 'ssz/simple-serialize.md Merkleization: hash_tree_root(List[T, N]) = mix_in_length(merkleize([hash_tree_root(e) for e in value], limit=N), len(value)); the cached root must equal it after any public sequence (X_cache of a decoded list, X_uncache)'
for f in sorted(os.listdir(T)):
    if not f.endswith('_def_generated.bend'):
        continue
    t = rd(f)
    m = re.search(r'^def (\w+)_cached_root\(', t, re.M)
    if not m:
        continue
    p = m.group(1)
    kind = f[:-len('_def_generated.bend')]
    laws = sorted(set(os.path.join('proofs/slop/validity', x) for x in os.listdir(os.path.join(tree, 'proofs/slop/validity'))
                      if re.search(r'_vroot_%s_cache_(set_0|set_1_3|set_3|app_1|app_2|app_3)_generated\.bend$' % re.escape(p), x)))
    o1 = re.search(r'%s_dfill\(1n\+d\), 0, \(O\.pow2u\(d\) - 1 : U32\)\}' % p, t)
    if o1:
        add('r12-d01-cache-lo', kind, 'root', 'types/' + f, [p + '_cache_fin', p + '_cache'], S_C,
            '%s_cache: the fresh cache\'s dirty window starts at leaf 1 (leaf 0 is never hashed until it is set or appended)' % p,
            'window initialised with a 1-based index', [(o1.group(0), o1.group(0).replace(', 0, (O.pow2u', ', 1, (O.pow2u'))], laws)
    o2 = '%s_cache_at(arr, n, %s_cap(n))' % (p, p)
    if t.count(o2) == 1:
        add('r12-d02-cache-depth0', kind, 'root', 'types/' + f, [p + '_cache'], S_C,
            '%s_cache: the tree depth taken for an empty list (cap(0)), not for the list\'s length' % p,
            'the cache sized for the default value it was first written for', [(o2, '%s_cache_at(arr, n, %s_cap(0))' % (p, p))], laws)
    blk = t.split('def %s_uncache(' % p)[1].split('\ndef ')[0]
    for l in blk.split('\n'):
        if l.endswith(': %s_Seq{arr, n}' % p) and t.count(l) == 1 and re.search(r'^def %s_default\(\)' % p, t, re.M):
            add('r12-d03-uncache-drop', kind, 'root', 'types/' + f, [p + '_uncache'], S_C,
                '%s_uncache: returns the empty list (the items are dropped)' % p, 'uncache written as a reset',
                [(l, l.replace('%s_Seq{arr, n}' % p, '%s_default()' % p))], laws)
            break

# ---- E: booleans and bit vector padding inside containers ---------------------------------------------------------------------
S_B = 'ssz/simple-serialize.md Deserialization: boolean: only 0x00 and 0x01 are valid; a container is valid when every field is'
f = 'FuluValidator_decode_ssz_generated.bend'
o = 'boolean_r.bool_ok_at(buf, (off + 88 : U32))'
for new, what in [('boolean_r.bool_ok_at(buf, (off + 87 : U32))', 'byte 87 (the last byte of effective_balance)'),
                  ('boolean_r.bool_ok_at(buf, (off + 89 : U32))', 'byte 89 (the first byte of activation_eligibility_epoch)'),
                  ('boolean_r.bool_ok_at(buf, off)', 'byte 0 of the container (the first pubkey byte)')]:
    add('r12-e01-bool-pos', 'FuluValidator', 'decode', 'types/' + f, ['Validator_ok_at', 'Validator_ok'], S_B,
        'Validator decode: the `slashed` boolean check reads %s' % what, 'field offset slip in the validity pass only (the reader is right)', [(o, new)])
f = 'Fulu_list_Validator_1099511627776_decode_ssz_generated.bend'
t = rd(f)
p = 'l1099511627776_Validator'
for old, new, what in [
        ('l1099511627776_Validator_ck(q, (i + 1 : U32), off, Bool.and(acc, ok), ', 'l1099511627776_Validator_ck(q, (i + 1 : U32), off, acc, ',
         'the validity of elements 0..n-2 dropped (only the last element is checked)'),
        ('FuluValidator_r.Validator_ok_at(buf, (off + (i + 1 : U32) * 121 : U32))', 'FuluValidator_r.Validator_ok_at(buf, (off + (i + 1 : U32) * 120 : U32))',
         'element i + 1 checked at stride 120'),
        ('l1099511627776_Validator_ck(U32.to_nat((n - 1 : U32)), 0, off, True{}, FuluValidator_r.Validator_ok_at(buf, off))',
         'l1099511627776_Validator_ck(U32.to_nat((n - 1 : U32)), 0, off, True{}, (buf, True{}))', 'the first element unchecked')]:
    if t.count(old) == 1:
        add('r12-e02-vlist-ck', 'FuluBeaconState', 'decode', 'types/' + f, [p + '_ck', p + '_ok_nz', p + '_ok'], S_B,
            'List[Validator] decode: %s' % what, 'loop bookkeeping slip in the element validity pass', [(old, new)],
            ['proofs/api/FuluBeaconState_decode_ssz_proof_generated.bend'])
S_BV = 'ssz/simple-serialize.md Deserialization: Bitvector[N]: the padding bits of the last byte (bits N mod 8 .. 7) must be zero'
for typ, old, new in [('BitsStruct', 'bv1_ok_at(buf, (off + 5 : U32)', 'bv1_ok_at(buf, (off + 4 : U32)'),
                      ('BitsStruct', 'bv2_ok_at(buf, (off + 4 : U32)', 'bv2_ok_at(buf, (off + 5 : U32)'),
                      ('ProgressiveBitsStruct', 'bv257_ok_at(buf, (off + 40 : U32)', 'bv257_ok_at(buf, (off + 41 : U32)'),
                      ('ProgressiveBitsStruct', 'bv1281_ok_at(buf, (off + 249 : U32)', 'bv1281_ok_at(buf, (off + 248 : U32)')]:
    f = typ + '_decode_ssz_generated.bend'
    t = rd(f)
    if t.count(old) == 1:
        fn = None
        for d in re.finditer(r'^def (\w+)\(', t, re.M):
            if d.start() <= t.index(old):
                fn = d.group(1)
        add('r12-e03-bv-pad-pos', typ, 'decode', 'types/' + f, [fn, typ + '_ok'], S_BV,
            '%s decode: a bit vector field\'s validity (padding) checked at the neighbouring field\'s position' % typ,
            'field offset slip in the validity pass', [(old, new)])

os.makedirs(out, exist_ok=True)
for fam, bs in blocks.items():
    open(os.path.join(out, 'r12_%s.txt' % fam.replace('r12-', '').replace('-', '_')), 'w').write('\n\n'.join(bs) + '\n')
    print(fam, len(bs))
print('total', sum(len(v) for v in blocks.values()))
