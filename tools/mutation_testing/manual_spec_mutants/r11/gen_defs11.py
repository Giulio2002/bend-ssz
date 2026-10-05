#!/usr/bin/env python3
"""gen_defs11.py TREE UNMENTIONED.json OUT_DIR: round 11 fault definitions (defs/r11_gen_*.txt). Run on the server only.

Round 11 focus: PROOF GAPS. UNMENTIONED.json is r10/unmentioned10.py recomputed on fixer G's tree (agent/access-laws 19cc482d5):
the API-shaped definitions that no proof file names. G's families (element / field get, set, swap: the *_get_n / *_set_n /
*_get_in helpers behind the named X_get / X_set) and H's (X_default, offset order) are dropped; what remains is the `_read`
readers, the `_ok` / `_bx_ok` byte validators, the per-group `_gK_valid` predicates and `croot_read`. Every pattern below is an
implementer mistake in one of those functions, instantiated on each unmentioned function whose code has that shape (sampled where
the shape repeats across sizes). Families (spec: ssz/simple-serialize.md v1.6.1):

  r11-a01-reader-base     container reader: a field read at its offset inside the container, not rebased on the container's own
                          offset `off` (the reader is correct at top level, wrong when the container is nested or a list element)
  r11-a02-word-readback   multi-word scalar reader (bit vector, uint128, Bytes8): the last word read at the previous word's offset
  r11-a03-tail-keep       bit vector reader: the partial last word not masked to the vector's bytes (bytes past it read in)
  r11-a04-vector-count    basic vector reader: the copy stops one element short (the last element stays zero)
  r11-a05-vector-storage  basic vector reader: the word storage allocated one word short
  r11-b01-ok-len          fixed-size validator: a window longer than the type's size accepted (trailing bytes ignored)
  r11-b02-ok-pad          bit vector validator: the padding check one bit too permissive / on the wrong byte
  r11-b03-bx-ok           boxed field validator: the boxed container's own validity check skipped
  r11-b04-bool-count      Vector[boolean, N] validator: the last byte not checked to be 0 or 1
  r11-c01-group-acc       group validity predicate: the accumulator dropped at the last field (only that field's validity counts)
  r11-h01-budget-strict   decode_checked_budget: a budget equal to the cost refused (< for <=)
  r11-h02-budget-unchecked decode_checked_budget: the admitted branch calls X_decode, not X_decode_checked (the storage test skipped)
"""
import json, os, re, sys

tree, unm, out = sys.argv[1:4]
T = os.path.join(tree, 'types')
UN = json.load(open(unm))
blocks = {}


def add(fam, typ, ops, fname, syms, spec, fault, why, hunks, count=None):
    b = ['=== ' + fam, 'type: ' + typ, 'ops: ' + ops, 'file: types/' + fname, 'sym: ' + ','.join(dict.fromkeys(s for s in syms if s)),
         'spec: ' + spec, 'fault: ' + fault, 'why: ' + why]
    if count:
        b.append('count: %d' % count)
    for o, n in hunks:
        b += ['-' + o, '+' + n]
    blocks.setdefault(fam, []).append('\n'.join(b))


def owner(text, pos):
    best = None
    for m in re.finditer(r'^def (\w+)', text, re.M):
        if m.start() <= pos:
            best = m.group(1)
    return best


def typ_of(fname):
    return re.sub(r'_(hashtreeroot|encode_ssz|decode_ssz|def)_generated\.bend$', '', fname)


def pub(text, suffix):
    m = re.search(r'^def (\w+_%s)\(' % suffix, text, re.M)
    return m.group(1) if m else None


def facade_type(typ):
    return typ if os.path.exists(os.path.join(tree, 'proofs/api/%s_decode_ssz_proof_generated.bend' % typ)) else None


def users(typ):
    """Fulu / generic container types whose decode facade imports this type's decoder (for kinds with no facade)."""
    r = []
    for f in sorted(os.listdir(os.path.join(tree, 'types'))):
        if f.endswith('_decode_ssz_generated.bend') and f != typ + '_decode_ssz_generated.bend':
            t = open(os.path.join(tree, 'types', f)).read()
            if ('./%s_decode_ssz_generated.bend' % typ) in t and facade_type(typ_of(f)):
                r.append(typ_of(f))
    return r[:2]


def ftype(typ):
    ft = facade_type(typ)
    if ft:
        return ft
    u = users(typ)
    return ','.join(u) if u else typ


unread = {f: [s for s in l if s.endswith('_read')] for f, l in UN.items()}
unok = {f: [s for s in l if s.endswith('_ok')] for f, l in UN.items()}
unval = {f: [s for s in l if s.endswith('_valid')] for f, l in UN.items()}

# ---- readers -------------------------------------------------------------------------------------------------------
cnt = {'a04': 0, 'a05': 0}
for f in sorted(unread):
    if not unread[f] or not f.endswith('_decode_ssz_generated.bend'):
        continue
    text = open(os.path.join(T, f)).read()
    typ = typ_of(f)
    dp = pub(text, 'decode')
    ty = ftype(typ)
    for rd in unread[f]:
        body_m = re.search(r'^def %s\(' % rd, text, re.M)
        # a01: container fields (calls of other readers at (off + K : U32)), take the last fixed field with K > 0
        ms = [m for m in re.finditer(r'(\w+\.\w+_read)\(buf, \(off \+ (\d+) : U32\), (\d+)\)', text) if int(m.group(2)) > 0]
        prefix = rd[:-len('_read')]
        ms = [m for m in ms if owner(text, m.start()).startswith(prefix)]
        if ms and rd not in ('pl_u32_read',):
            m = max(ms, key=lambda m: int(m.group(2)))
            o = m.group(0)
            if text.count(o) == 1:
                add('r11-a01-reader-base', ty, 'decode', f, [owner(text, m.start()), rd, dp],
                    'deserialize(Container): field i occupies bytes [start + sum(sizes before i), ...) of the CONTAINER\'s window',
                    'the field at container byte %s is read at absolute byte %s (the container\'s own offset off is not added)' % (m.group(2), m.group(2)),
                    'reader written for a top-level container: correct at off = 0, wrong for a nested container or a list element',
                    [(o, o.replace('(off + %s : U32)' % m.group(2), '(%s : U32)' % m.group(2)))])
            # the variable-field form (off + o_x)
            mv = list(re.finditer(r'(\w+\.\w+_read)\(buf, \(off \+ (o_\w+) : U32\)', text))
            mv = [x for x in mv if owner(text, x.start()).startswith(prefix)]
            if mv:
                x = mv[-1]
                o = x.group(0)
                if text.count(o) == 1:
                    add('r11-a01-reader-base', ty, 'decode', f, [owner(text, x.start()), rd, dp],
                        'deserialize(Container): a variable field\'s offset is relative to the start of the container',
                        'the variable field %s is read at the raw offset %s (not rebased on off)' % (x.group(2)[2:], x.group(2)),
                        'offsets taken as absolute buffer positions', [(o, o.replace('(off + %s : U32)' % x.group(2), '(%s : U32)' % x.group(2)))])
        # a02: multi-word scalar readers: last word read at the previous word's offset
        mw = [m for m in re.finditer(r'B\.read32\(buf, \(off \+ (\d+) : U32\)\)', text) if owner(text, m.start()).startswith(prefix + '_r')]
        if mw:
            m = max(mw, key=lambda m: int(m.group(1)))
            k = int(m.group(1))
            o = m.group(0)
            if k >= 4 and text.count(o) == 1:
                add('r11-a02-word-readback', ty, 'decode', f, [owner(text, m.start()), rd, dp],
                    'deserialize of a basic value / bit vector: little-endian bytes [off, off + size)',
                    'word %d (byte %d) is read at byte %d (the previous word read twice)' % (k // 4, k, k - 4),
                    'reader cursor not advanced', [(o, 'B.read32(buf, (off + %d : U32))' % (k - 4))])
        # a03: tail keep
        mk = [m for m in re.finditer(r'O\.keep\((\d), (\w+)\)', text) if owner(text, m.start()).startswith(prefix)]
        for m in mk[-1:]:
            o = m.group(0)
            if text.count(o) == 1:
                add('r11-a03-tail-keep', ty, 'decode', f, [owner(text, m.start()), rd, dp],
                    'Bitvector[N] occupies (N + 7) // 8 bytes; the bytes after it belong to the next field',
                    'the last word keeps all 4 bytes read (bytes past the %s-byte tail read into the value)' % m.group(1),
                    'a 32-bit read not masked to the value\'s width', [(o, m.group(2))])
        # a04 / a05: basic vector readers
        mc = re.search(r'O\.copy_into\(buf, off, (\d+), Array\.new\(U32, (\d+)n, 0\)\)', text)
        vm = re.match(r'vec_(uint8|uint16|uint32|uint64|uint128|uint256|bool)_(\d+)$', typ)
        if mc and vm:
            N, W = int(mc.group(1)), int(mc.group(2))
            n = int(vm.group(2))
            es = N // n
            o = mc.group(0)
            if n >= 2 and cnt['a04'] < 14 and text.count(o) == 1:
                cnt['a04'] += 1
                add('r11-a04-vector-count', ty, 'decode', f, [rd, dp],
                    'deserialize(Vector[T, N]) reads N elements of size(T)',
                    'the copy takes %d bytes instead of %d (the last element is left zero)' % (N - es, N),
                    'element count off by one (range(N - 1))', [(o, o.replace(', off, %d,' % N, ', off, %d,' % (N - es)))])
            if W >= 2 and cnt['a05'] < 5 and n in (3, 5, 513) and text.count(o) == 1:
                cnt['a05'] += 1
                add('r11-a05-vector-storage', ty, 'decode,root', f, [rd, dp],
                    'Vector[T, N] holds N * size(T) bytes',
                    'the word storage is allocated with %d words instead of %d' % (W - 1, W),
                    'storage sized by floor instead of the chunk-padded ceiling', [(o, o.replace('Array.new(U32, %dn, 0)' % W, 'Array.new(U32, %dn, 0)' % (W - 1)))])

# ---- validators ------------------------------------------------------------------------------------------------------
nb01 = 0
for f in sorted(unok):
    if not unok[f]:
        continue
    text = open(os.path.join(T, f)).read()
    typ = typ_of(f)
    dp = pub(text, 'decode')
    ty = ftype(typ)
    for ok in unok[f]:
        m = re.search(r'^def %s\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & Bool: (\w+)\(U32\.is_eq\(len, (\d+)\), buf, off\)$' % ok, text, re.M)
        if m and nb01 < 22:
            nb01 += 1
            o = 'U32.is_eq(len, %s), buf, off)' % m.group(2)
            line = m.group(0)
            add('r11-b01-ok-len', ty, 'decode', f, [ok, dp],
                'deserialize of a fixed-size type: the input must be exactly size(T) bytes',
                'the validator accepts any window of at least %s bytes' % m.group(2),
                'length test written as a bound', [(line, line.replace(o, 'U32.is_le(%s, len), buf, off)' % m.group(2)))])
        # b02: padding
        prefix = ok[:-len('_ok')]
        mp = re.search(r'^def %s_ok_at\(buf: B\.Buf, \+off: U32\) -> B\.Buf & Bool: O\.ok_pad\(buf, \(off \+ (\d+) : U32\), (\d)\)$' % prefix, text, re.M)
        if mp:
            line = mp.group(0)
            P, r = int(mp.group(1)), int(mp.group(2))
            add('r11-b02-ok-pad', ty, 'decode', f, [prefix + '_ok_at', ok, dp],
                'Bitvector[N] deserialize: the padding bits N..8*ceil(N/8)-1 of the last byte must be zero',
                'the padding check allows bit %d (checks bits %d..7 only)' % (r, r + 1),
                'pad mask off by one', [(line, line.replace(', %d)' % r, ', %d)' % (r + 1)))])
            if P >= 1:
                add('r11-b02-ok-pad', ty, 'decode', f, [prefix + '_ok_at', ok, dp],
                    'Bitvector[N] deserialize: the padding bits live in the LAST byte (byte ceil(N/8) - 1)',
                    'the padding is checked on byte %d instead of byte %d' % (P - 1, P),
                    'last-byte index off by one', [(line, line.replace('(off + %d : U32)' % P, '(off + %d : U32)' % (P - 1)) if P > 1 else line.replace('(off + 1 : U32)', 'off'))])
        mb = re.search(r'^def %s_ok_at\(buf: B\.Buf, \+off: U32\) -> B\.Buf & Bool: (\w+_ok_n)\(buf, off, (\d+)\)$' % prefix, text, re.M)
        if mb and int(mb.group(2)) >= 2:
            line = mb.group(0)
            n = int(mb.group(2))
            add('r11-b04-bool-count', ty, 'decode', f, [prefix + '_ok_at', ok, dp],
                'Vector[boolean, N] deserialize: every byte must be 0x00 or 0x01',
                'the last of the %d boolean bytes is not checked' % n,
                'loop bound off by one', [(line, line.replace('(buf, off, %d)' % n, '(buf, off, %d)' % (n - 1)))])

# b03: boxed validators
for f in sorted(UN):
    for s in UN[f]:
        if s.endswith('_bx_ok'):
            text = open(os.path.join(T, f)).read()
            m = re.search(r'^def %s\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & Bool: (\w+)\(buf, off, len\)$' % s, text, re.M)
            if m:
                typ = typ_of(f)
                # the boxed validator is called by the containers that box this type: judge on them
                cont = []
                base = s[:-len('_bx_ok')]
                for g in sorted(os.listdir(T)):
                    if g.endswith('_decode_ssz_generated.bend') and g != f:
                        t2 = open(os.path.join(T, g)).read()
                        if '.%s(' % s in t2 and facade_type(typ_of(g)):
                            cont.append(typ_of(g))
                add('r11-b03-bx-ok', ','.join(cont[:2]) or ftype(typ), 'decode', f, [s, pub(text, 'decode')],
                    'deserialize(Container): every field (here a boxed container field) must itself deserialize validly',
                    'the boxed %s field\'s validator returns True without checking the bytes' % base,
                    'validation skipped for boxed (heap) fields', [(m.group(0), m.group(0).replace(': %s(buf, off, len)' % m.group(1), ': (buf, True{})'))])

# ---- group validity --------------------------------------------------------------------------------------------------
for f in sorted(unval):
    for s in unval[f]:
        if not re.search(r'_g\d+_valid$', s):
            continue
        text = open(os.path.join(T, f)).read()
        typ = typ_of(f)
        g = s[:-len('_valid')]
        # the last step of the chain: (..._gK{...}, Bool.and(acc, ok))
        ms = list(re.finditer(r'\(((?:\w+\.)?%s)\{([^}]*)\}, Bool\.and\(acc, ok\)\)' % re.escape(g), text))
        ms = [m for m in ms if owner(text, m.start()).startswith(g + '_va')]
        if ms:
            m = ms[-1]
            o = m.group(0)
            if text.count(o) == 1:
                add('r11-c01-group-acc', typ, 'encode', f, [owner(text, m.start()), s, pub(text, 'encode'), pub(text, 'serialize')],
                    'a container is valid iff every field is valid (is_valid of each field type, conjunction)',
                    'the group %s returns only its last field\'s validity (the accumulated validity of the earlier fields is dropped)' % g,
                    'accumulator overwritten instead of and-ed', [(o, o.replace('Bool.and(acc, ok))', 'ok)'))])

# ---- decode_checked_budget ---------------------------------------------------------------------------------------------
budget_types = []
for f in sorted(os.listdir(T)):
    if f.endswith('_decode_ssz_generated.bend'):
        typ = typ_of(f)
        if facade_type(typ) and (f in UN or typ.startswith('Fulu') or typ.startswith('Progressive') or typ.startswith('Compatible')):
            budget_types.append((typ, f))
seen_t = 0
for typ, f in budget_types:
    text = open(os.path.join(T, f)).read()
    m = re.search(r'^def (\w+)_decode_checked_budget\(.*: (\w+_dcb)\(Bool\.and\(U32\.is_lt\((\w+_dcost)\(size\), 4294967295\), U32\.is_le\(\w+_dcost\(size\), budget\)\), buf, size\)$', text, re.M)
    mc = re.search(r'    case True\{\}: (\w+)_decode_checked\(buf, size\)', text)
    if not m or not mc:
        continue
    seen_t += 1
    if seen_t % 2 == 1:
        line = m.group(0)
        add('r11-h01-budget-strict', typ, 'decode', f, [m.group(1) + '_decode_checked_budget', m.group(2)],
            'API contract (docs/API_CONTRACTS.md): decode_checked_budget decodes when cost(size) <= budget',
            'a budget equal to the cost is refused (cost < budget)', 'boundary of the budget test',
            [(line, line.replace('U32.is_le(%s(size), budget)' % m.group(3), 'U32.is_lt(%s(size), budget)' % m.group(3)))])
    else:
        o = mc.group(0)
        if text.count(o) == 1:
            add('r11-h02-budget-unchecked', typ, 'decode', f, [m.group(2), m.group(1) + '_decode_checked_budget'],
                'API contract: decode_checked_budget = decode_checked when the budget admits the size (the storage test included)',
                'the admitted branch calls %s_decode (the size <= stored-words test of decode_checked is skipped)' % mc.group(1),
                'wrapper composed with the unchecked decoder', [(o, '    case True{}: %s_decode(buf, size)' % mc.group(1))])



# ==== hand-designed: cached tree, progressive append, union options (written as patterns, instantiated below) ===========
def hand(fam, typ, ops, fname, syms, spec, fault, why, old, new, count=None):
    text = open(os.path.join(T, fname)).read()
    if text.count(old) != (count or 1):
        print('SKIP (shape) %s %s: %d' % (fam, fname, text.count(old)))
        return
    add(fam, typ, ops, fname, syms, spec, fault, why, [(old, new)], count)


CACHED = [  # (file, prefix, facade type) - the cached lists with no generated cached-root law file of their own
    ('Fulu_list_ProposerSlashing_16_def_generated.bend', 'l16_ProposerSlashing', 'FuluBeaconBlockBody'),
    ('Fulu_list_Deposit_16_def_generated.bend', 'l16_Deposit', 'FuluBeaconBlockBody'),
    ('Fulu_list_Attestation_8_def_generated.bend', 'l8_Attestation', 'FuluBeaconBlockBody'),
    ('Fulu_list_AttesterSlashing_1_def_generated.bend', 'l1_AttesterSlashing', 'FuluBeaconBlockBody'),
    ('Fulu_list_bytelist_1073741824_1048576_def_generated.bend', 'l1048576_bl1073741824', 'FuluExecutionPayload'),
    ('list_ProgressiveSingleFieldContainerTestStruct_10_def_generated.bend', 'l10_ProgressiveSingleFieldContainerTestStruct', 'ProgressiveComplexTestStruct'),
]
SPEC_ROOT = 'hash_tree_root(List[T, N]) = mix_in_length(merkleize([hash_tree_root(e) for e in value], limit=N), len(value)) (cached-tree API must equal it after any sequence of cache / cset / capp / cached_root)'
for fname, P, ft in CACHED:
    pubs = [P + '_cache', P + '_cached_root', P + '_cset', P + '_capp', P + '_uncache']
    hand('r11-d01-cache-window', ft, 'root', fname, [P + '_cache_fin'] + pubs, SPEC_ROOT,
         'a fresh cache marks only the leaves 0..n-1 dirty (the padding leaves and their parents are never computed: they keep D.zero, not the zero-subtree roots)',
         'dirty window sized by the element count instead of the tree width',
         '%s_dfill(1n+d), 0, (O.pow2u(d) - 1 : U32)}' % P, '%s_dfill(1n+d), 0, (n - 1 : U32)}' % P)
    hand('r11-d02-cache-grow-window', ft, 'root', fname, [P + '_capp_fit'] + pubs, SPEC_ROOT,
         'when an append grows the cached tree one level, only leaves 0..n are marked dirty in the fresh node array (padding subtrees stay D.zero)',
         'dirty window after growth sized by the count',
         '%s_dfill(2n+d), 0, (O.pow2u(1n+d) - 1 : U32)}' % P, '%s_dfill(2n+d), 0, n}' % P)
    hand('r11-d03-cset-lo', ft, 'root', fname, [P + '_cset_in'] + pubs, SPEC_ROOT,
         'cset does not lower the dirty window\'s low end to i (a set below the window is never rehashed)',
         'only the high end of the window widened',
         'nodes, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})',
         'nodes, lo, O.pick(U32.is_le(i, hi), hi, i)}, True{})')
    if P in ('l16_ProposerSlashing', 'l8_Attestation', 'l1048576_bl1073741824'):
        hand('r11-d04-cset-hi', ft, 'root', fname, [P + '_cset_in'] + pubs, SPEC_ROOT,
             'cset does not raise the dirty window\'s high end to i (a set above the window is never rehashed)',
             'only the low end of the window widened',
             'nodes, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})',
             'nodes, O.pick(U32.is_le(lo, i), lo, i), hi}, True{})')
    hand('r11-d05-cache-depth', ft, 'root', fname, [P + '_cache'] + pubs, SPEC_ROOT,
         'the cached tree is built at depth bit_length(n) = capacity(n + 1) instead of ceil(log2 n) (one level too deep when n is a power of two; past the limit depth for a full list)',
         'depth from bit length',
         '%s_cache_at(arr, n, %s_cap(n))' % (P, P), '%s_cache_at(arr, n, %s_cap((n + 1 : U32)))' % (P, P))
P, fname = 'l16_ProposerSlashing', 'Fulu_list_ProposerSlashing_16_def_generated.bend'
pubs = [P + '_cache', P + '_cached_root', P + '_cset', P + '_capp']
hand('r11-d06-capp-lo', 'FuluBeaconBlockBody', 'root', fname, [P + '_capp_fit'] + pubs, SPEC_ROOT,
     'an append inside the tree does not lower the window\'s low end to n (EXPECTED EQUIVALENT: after a root the window is (n, 0) and lo <= n always)',
     'only the high end widened',
     '(n + 1 : U32), d, nodes, O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)}',
     '(n + 1 : U32), d, nodes, lo, O.pick(U32.is_le(n, hi), hi, n)}')
hand('r11-d07-croot-reset', 'FuluBeaconBlockBody', 'root', fname, [P + '_croot_fin'] + pubs, SPEC_ROOT,
     'after a root the window is reset to (0, 0) instead of empty (n, 0): leaf 0 is rehashed on every later root (EXPECTED EQUIVALENT: rehashing a clean leaf rewrites the same digest)',
     'empty window spelled as lo = hi = 0',
     '(h, (%s_Cached{arr, n, d, nodes, n, 0}, O.mix_len(hl, r, n)))' % P, '(h, (%s_Cached{arr, n, d, nodes, 0, 0}, O.mix_len(hl, r, n)))' % P)
for P, fname in (('l16_ProposerSlashing', 'Fulu_list_ProposerSlashing_16_def_generated.bend'), ('l8_Attestation', 'Fulu_list_Attestation_8_def_generated.bend')):
    pubs = [P + '_cache', P + '_cached_root', P + '_capp']
    hand('r11-d08-grow-reuse', 'FuluBeaconBlockBody', 'root', fname, [P + '_capp_fit'] + pubs, SPEC_ROOT,
         'growing the cached tree one level keeps the old node array (2^(d+1) slots for a depth-(d+1) tree that needs 2^(d+2))',
         'node array not reallocated on growth',
         '1n+d, %s_dfill(2n+d), 0,' % P, '1n+d, nodes, 0,')
hand('r11-d01-cache-window', 'FuluBeaconState', 'root', 'Fulu_list_Validator_1099511627776_def_generated.bend',
     ['l1099511627776_Validator_cache_fin', 'l1099511627776_Validator_cache', 'l1099511627776_Validator_cached_root'], SPEC_ROOT,
     'a fresh cache marks only the leaves 0..n-1 dirty (validators: the hand-proved instance)', 'dirty window sized by the count',
     'l1099511627776_Validator_dfill(1n+d), 0, (O.pow2u(d) - 1 : U32)}', 'l1099511627776_Validator_dfill(1n+d), 0, (n - 1 : U32)}')
hand('r11-d03-cset-lo', 'FuluBeaconState', 'root', 'Fulu_list_Validator_1099511627776_def_generated.bend',
     ['l1099511627776_Validator_cset_in', 'l1099511627776_Validator_cset', 'l1099511627776_Validator_cached_root'], SPEC_ROOT,
     'cset does not lower the window\'s low end (validators: the hand-proved instance)', 'only the high end widened',
     'nodes, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})', 'nodes, lo, O.pick(U32.is_le(i, hi), hi, i)}, True{})')

# progressive lists: append at the storage boundary, len
for t, k in (('uint8', 1), ('uint16', 2), ('uint32', 4), ('uint64', 8), ('uint128', 16), ('uint256', 32)):
    fname = 'proglist_%s_def_generated.bend' % t
    text = open(os.path.join(T, fname)).read()
    m = re.search(r'^def (pl_\w+)_grow\(', text, re.M)
    if not m:
        continue
    P = m.group(1)
    hand('r11-e01-prog-append-len', 'proglist_' + t, 'encode,root', fname, [P + '_grow', P + '_append'],
         'ProgressiveList append: the list holds n + 1 elements after appending to n (serialize / hash_tree_root see it)',
         'append grows the storage but leaves the byte length at n * %d (the appended element is written past the length and lost)' % k,
         'resize to the old length',
         'O.words_resize(O.words_fit(o, ((n + 1 : U32) * %d : U32)), ((n + 1 : U32) * %d : U32)), n, v)' % (k, k),
         'O.words_resize(O.words_fit(o, ((n + 1 : U32) * %d : U32)), (n * %d : U32)), n, v)' % (k, k))
hand('r11-e02-prog-len', 'proglist_uint64', 'encode,root', 'proglist_uint64_def_generated.bend', ['pl_u64_len_of', 'pl_u64_len', 'pl_u64_append'],
     'len(ProgressiveList[uint64]) = byte length / 8', 'len computed as n >> 3 (EXPECTED EQUIVALENT: same value for every U32)', 'shift for division',
     '(o, U32.div(n, 8))', '(o, U32.shrn(n, 3n))')
hand('r11-e02-prog-len', 'proglist_uint128', 'encode,root', 'proglist_uint128_def_generated.bend', ['pl_u128_len_of', 'pl_u128_len', 'pl_u128_append'],
     'len(ProgressiveList[uint128]) = byte length / 16', 'len rounds up: (n + 15) / 16 (EXPECTED EQUIVALENT in context: every public writer keeps the byte length a multiple of 16)', 'ceiling for floor',
     '(o, U32.div(n, 16))', '(o, U32.div((n + 15 : U32), 16))')

# unions with two options of the same type (CompatibleUnionABCA: options 1 and 4 are both ProgressiveSingleFieldContainerTestStruct)
U = 'CompatibleUnionABCA'
hand('r11-f01-union-same-type', U, 'encode', U + '_encode_ssz_generated.bend', [U + '_pt3', U + '_serialize', U + '_encode'],
     'serialize(CompatibleUnion): the selector byte is the option index of the value (4 for the fourth option)',
     'option 4 is written with selector 1 (the first option of the same payload type)', 'option looked up by payload type, not index',
     'O.w8(out, pos, 4)', 'O.w8(out, pos, 1)')
hand('r11-f01-union-same-type', U, 'root', U + '_hashtreeroot_generated.bend', [U + '_rt3', U + '_hash_tree_root'],
     'hash_tree_root(CompatibleUnion) = mix_in_selector(hash_tree_root(value), selector)',
     'option 4 mixes in selector 1', 'option looked up by payload type',
     '(h, (%s_d.%s_c3{v}, O.mix_len(hl, d, 4)))' % (U, U), '(h, (%s_d.%s_c3{v}, O.mix_len(hl, d, 1)))' % (U, U))
hand('r11-f01-union-same-type', U, 'decode', U + '_decode_ssz_generated.bend', [U + '_decode'],
     'deserialize(CompatibleUnion): selector 4 decodes to the fourth option',
     'selector 4 builds option 1 (same payload type, same bytes)', 'option constructor picked by type',
     '(buf, %s_d.%s_c3{v})' % (U, U), '(buf, %s_d.%s_c0{v})' % (U, U))
hand('r11-f01-union-same-type', U, 'encode', U + '_encode_ssz_generated.bend', [U + '_valid', U + '_serialize'],
     'a union value is valid iff its payload is valid',
     'option 4 is valid without checking its payload', 'validity case left as a stub',
     '(%s_d.%s_c3{v}, ProgressiveSingleFieldContainerTestStruct_e.ProgressiveSingleFieldContainerTestStruct_valid(v))' % (U, U),
     '(%s_d.%s_c3{v}, True{})' % (U, U))

os.makedirs(out, exist_ok=True)
for fam, bl in blocks.items():
    if fam.split('-')[1][0] in 'def':
        open(os.path.join(out, 'r11_hand_%s.txt' % fam.split('-')[1]), 'w').write('## round 11 hand-designed: ' + fam + '\n' + '\n'.join(bl) + '\n')
    else:
        open(os.path.join(out, 'r11_gen_%s.txt' % fam.split('-')[1]), 'w').write('## round 11 generated: ' + fam + '\n' + '\n'.join(bl) + '\n')
print({k: len(v) for k, v in blocks.items()}, sum(len(v) for v in blocks.values()))
