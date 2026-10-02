#!/usr/bin/env python3
"""Mechanical constants audit of the bend-ssz specification transcription against consensus-specs.

    python3 tools/spec_audit/constants.py --repo . --cs /path/to/consensus-specs [--out DIR]

Stdlib only; nothing is executed from either side (the Bend and the markdown/python sources are read as text).
Reference: github.com/ethereum/consensus-specs at the tag pinned in upstream.lock.json (v1.6.1): ssz/simple-serialize.md,
specs/{phase0..fulu}/**/*.md (container classes, custom-type and constant tables), presets/mainnet/*.yaml,
configs/mainnet.yaml, tests/generators/runners/ssz_generic_cases/*.py (generic types).
Bend side: spec/*.bend, spec/fulu_schemas.bend, schemas/fulu_mainnet.json, codegen/fulu.yaml, types/byte_alias.bend,
types/list_alias.bend, proofs/obj/generic_specs_generated.bend, the generated types/*_generated.bend file names.

Writes DIR/constants_report.md (tables: item, Bend value (file:line), reference value (file:line), status) and
DIR/constants_report.json, and exits 1 if any row is a mismatch or a rule probe finds no Bend pattern.
"""
import argparse
import ast
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bendparse import Bend, YamlTypes, parse_expr, read_codegen_yaml, read_defs, read_json_schemas  # noqa: E402
from refparse import Ref, RefError  # noqa: E402

ROWS = []          # every compared item
COUNT = {'scalar': 0, 'attr': 0, 'name': 0, 'rule': 0}
TBL_E = 'E protocol constants in spec/*.bend'


def row(table, item, bend, ref, status, note=''):
    ROWS.append({'table': table, 'item': item, 'bend': bend, 'ref': ref, 'status': status, 'note': note})
    return status


# ---------------------------------------------------------------------------------------------------------------
# structural comparison of two normal forms, counting every compared numeric attribute and field name
# ---------------------------------------------------------------------------------------------------------------
def walk_cmp(a, b, path, diffs):
    if a is None or b is None or a[0] != b[0]:
        diffs.append('%s: kind %s vs %s' % (path, a and a[0], b and b[0]))
        return
    k = a[0]
    if k in ('container', 'progcontainer'):
        fa, fb = a[1], b[1]
        if len(fa) != len(fb):
            diffs.append('%s: %d fields vs %d' % (path, len(fa), len(fb)))
        for i, (x, y) in enumerate(zip(fa, fb)):
            COUNT['name'] += 1
            if x[0] != y[0]:
                diffs.append('%s field #%d: name %s vs %s' % (path, i, x[0], y[0]))
            walk_cmp(x[1], y[1], '%s.%s' % (path, x[0]), diffs)
        if k == 'progcontainer':
            COUNT['attr'] += len(a[2])
            if a[2] != b[2]:
                diffs.append('%s: active_fields differ' % path)
        return
    if k in ('vector', 'list'):
        COUNT['attr'] += 1
        if a[2] != b[2]:
            diffs.append('%s: %s %r vs %r' % (path, 'length' if k == 'vector' else 'limit', a[2], b[2]))
        walk_cmp(a[1], b[1], path + '[]', diffs)
        return
    if k == 'proglist':
        walk_cmp(a[1], b[1], path + '[]', diffs)
        return
    if k == 'compatunion':
        COUNT['attr'] += len(a[1])
        if a[1] != b[1]:
            diffs.append('%s: selectors %s vs %s' % (path, a[1], b[1]))
        if len(a[2]) != len(b[2]):
            diffs.append('%s: option count' % path)
        for s, x, y in zip(a[1], a[2], b[2]):
            walk_cmp(x, y, '%s<%s>' % (path, s), diffs)
        return
    if k in ('bool', 'progbits'):
        return
    COUNT['attr'] += 1
    if a != b:
        diffs.append('%s: %s vs %s' % (path, a, b))


def compare(a, b, path):
    d = []
    walk_cmp(a, b, path, d)
    return d


def short(nf):
    if nf is None:
        return '-'
    k = nf[0]
    if k == 'bool':
        return 'boolean'
    if k == 'uint':
        return 'uint%d' % nf[1]
    if k in ('bytes', 'bytelist', 'bitvector', 'bitlist'):
        return '%s[%d]' % ({'bytes': 'ByteVector', 'bytelist': 'ByteList', 'bitvector': 'Bitvector', 'bitlist': 'Bitlist'}[k], nf[1])
    if k in ('vector', 'list'):
        return '%s[%s,%d]' % (k.capitalize(), short(nf[1]), nf[2])
    if k == 'container':
        return 'Container(%s)' % ','.join(f for f, _ in nf[1])
    return k


# ---------------------------------------------------------------------------------------------------------------
# A. scalar constants: codegen/fulu.yaml constants vs the reference (presets, config, markdown tables)
# ---------------------------------------------------------------------------------------------------------------
def audit_scalars(ref, ycons, ypath):
    for name, (val, line) in sorted(ycons.items()):
        COUNT['scalar'] += 1
        try:
            rv = ref.const(name)
            loc = ref.where(name)
        except RefError as e:
            row('A scalar constants', name, '%d (%s:%d)' % (val, ypath, line), 'not found (%s)' % e, 'only in Bend')
            continue
        row('A scalar constants', name, '%d (%s:%d)' % (val, ypath, line), '%d (%s)' % (rv, loc),
            'match' if rv == val else 'MISMATCH')
    # internal consistency of the reference itself: preset yaml vs the markdown table of the same name
    for name, (v, loc) in sorted(ref.yaml.items()):
        if name in ref.table:
            try:
                tv = ref.ev(ast.parse(ref.table[name][0], mode='eval').body)
            except Exception:
                continue
            if isinstance(tv, int):
                COUNT['scalar'] += 1
                row('A2 reference preset yaml vs markdown table', name, '%d (%s)' % (tv, ref.table[name][1]),
                    '%d (%s)' % (v, loc), 'match' if tv == v else 'MISMATCH')


# ---------------------------------------------------------------------------------------------------------------
# B. every Fulu name: three Bend/yaml sources against the reference markdown
# ---------------------------------------------------------------------------------------------------------------
def audit_types(ref, jsons, bendspec, ytypes, yeval, ypath, spec_path, json_path):
    names = sorted(set(jsons) | set(bendspec.defs) | set(ytypes))
    names = [n for n in names if not re.fullmatch(r'Schema\d+', n)]
    for name in names:
        refnf, rloc, rerr = None, None, None
        try:
            refnf, rloc = ref.type_of(name), ref.type_loc(name)
        except RefError as e:
            rerr = str(e)
        srcs = {}
        if name in jsons:
            srcs['json'] = (jsons[name][0], '%s:%s' % (json_path, jsons[name][1]))
        if name in bendspec.defs:
            srcs['bend'] = (bendspec.ref(name), '%s:%d' % (spec_path, bendspec.defs[name][1]))
        if name in ytypes:
            srcs['yaml'] = (yeval.named(name), '%s:%d' % (ypath, ytypes[name][1]))
        bendcell = '; '.join('%s %s' % (k, v[1]) for k, v in srcs.items())
        if rerr:
            row('B Fulu names', name, bendcell, rerr, 'only in Bend')
            continue
        diffs = []
        for k, (nf, loc) in srcs.items():
            diffs += ['[%s] %s' % (k, x) for x in compare(nf, refnf, name)]
        missing = [k for k in ('json', 'bend', 'yaml') if k not in srcs]
        status = 'MISMATCH' if diffs else ('match' if not missing else 'match (absent from %s)' % ','.join(missing))
        row('B Fulu names', name, bendcell, '%s %s' % (short(refnf), rloc), status, '; '.join(diffs[:4]))
    have = set(names)
    for cname, ent in sorted(ref.classes.items()):
        if cname not in have:
            row('B Fulu names', cname, '-', '%s (%s)' % (ent['fork'], ent['loc']), 'only in reference',
                'SSZ container class in the markdown of a fork <= fulu, no Bend schema')


# ---------------------------------------------------------------------------------------------------------------
# C. byte aliases / byte list alias constants
# ---------------------------------------------------------------------------------------------------------------
def audit_alias(ref, repo):
    be = Bend({})
    for path, kind in (('types/byte_alias.bend', 'bytes'), ('types/list_alias.bend', 'bytelist')):
        for i, line in enumerate(open(os.path.join(repo, path)), 1):
            m = re.match(r'^    case (\w+)\{\}: (.+)$', line)
            if not m:
                continue
            val = be.num(parse_expr(m.group(2)))
            COUNT['attr'] += 1
            try:
                nf = ref.named(m.group(1), ())
                row('C byte aliases', m.group(1), '%d (%s:%d)' % (val, path, i),
                    '%s (%s)' % (short(nf), ref.type_loc(m.group(1)) or 'ssz basic'), 'match' if nf == (kind, val) else 'MISMATCH')
            except RefError as e:
                row('C byte aliases', m.group(1), '%d (%s:%d)' % (val, path, i), str(e), 'only in Bend')


# ---------------------------------------------------------------------------------------------------------------
# D. generic names (ssz_generic suite) against tests/generators/runners/ssz_generic_cases/*.py
# ---------------------------------------------------------------------------------------------------------------
def gtype(n, env):
    """Type of an annotation AST in the ssz_generic_cases python files."""
    if isinstance(n, ast.Name):
        i = n.id
        basic = {'byte': ('uint', 8), 'boolean': ('bool',), 'uint8': ('uint', 8), 'uint16': ('uint', 16), 'uint32': ('uint', 32),
                 'uint64': ('uint', 64), 'uint128': ('uint', 128), 'uint256': ('uint', 256)}
        if i in basic:
            return basic[i]
        if i == 'ProgressiveBitlist':
            return ('progbits',)
        return env[i]
    if isinstance(n, ast.Subscript):
        h = n.value.id
        a = n.slice.elts if isinstance(n.slice, ast.Tuple) else [n.slice]
        if h in ('Vector', 'List'):
            el, ln = gtype(a[0], env), a[1].value
            if h == 'Vector':
                return ('bytes', ln) if el == ('uint', 8) else ('vector', el, ln)
            return ('bytelist', ln) if el == ('uint', 8) else ('list', el, ln)
        if h == 'ProgressiveList':
            return ('proglist', gtype(a[0], env))
        v = a[0].value
        return {'Bitvector': ('bitvector', v), 'Bitlist': ('bitlist', v), 'ByteList': ('bytelist', v),
                'ByteVector': ('bytes', v)}[h]
    raise KeyError(ast.dump(n)[:80])


def ref_generic(cs):
    d = os.path.join(cs, 'tests/generators/runners/ssz_generic_cases')
    pre = 'tests/generators/runners/ssz_generic_cases/'
    env, loc = {}, {}
    for f in ('ssz_container.py', 'ssz_progressive_container.py', 'ssz_compatible_union.py'):
        tree = ast.parse(open(os.path.join(d, f)).read())
        for node in tree.body:
            if isinstance(node, ast.ClassDef) and node.bases:
                b = node.bases[0]
                fields = tuple((x.target.id, gtype(x.annotation, env)) for x in node.body if isinstance(x, ast.AnnAssign))
                if isinstance(b, ast.Name) and b.id == 'Container':
                    env[node.name] = ('container', fields)
                elif isinstance(b, ast.Call) and b.func.id == 'ProgressiveContainer':
                    env[node.name] = ('progcontainer', fields, tuple(bool(e.value) for e in b.keywords[0].value.elts))
                else:
                    continue
                loc[node.name] = '%s%s:%d' % (pre, f, node.lineno)
            elif isinstance(node, ast.Assign) and isinstance(node.value, ast.Call) and getattr(node.value.func, 'id', '') == 'CompatibleUnion':
                dd = node.value.args[0]
                env[node.targets[0].id] = ('compatunion', tuple(k.value for k in dd.keys), tuple(env[v.id] for v in dd.values))
                loc[node.targets[0].id] = '%s%s:%d' % (pre, f, node.lineno)
    out = dict((k, (v, loc[k])) for k, v in env.items() if k in loc)

    def first_list(fname, var):
        src = open(os.path.join(d, fname)).read()
        m = re.search(r'for %s in (\[[0-9, ]+\])' % var, src)
        return ast.literal_eval(m.group(1)), '%s%s:%d' % (pre, fname, src[:m.start()].count('\n') + 1)
    vl, vloc = first_list('ssz_basic_vector.py', 'length')
    bvl, bvloc = first_list('ssz_bitvector.py', 'size')
    bll, blloc = first_list('ssz_bitlist.py', 'size')
    types = {'bool': ('bool',), 'uint8': ('uint', 8), 'uint16': ('uint', 16), 'uint32': ('uint', 32), 'uint64': ('uint', 64),
             'uint128': ('uint', 128), 'uint256': ('uint', 256)}
    for t, nf in types.items():
        for n in vl:
            out['vec_%s_%d' % (t, n)] = ((('bytes', n) if nf == ('uint', 8) else ('vector', nf, n)), vloc)
        if t in ('uint16', 'uint128'):
            out[t] = (nf, pre + 'ssz_uints.py')
        out['proglist_' + t] = (('proglist', nf), pre + 'ssz_basic_progressive_list.py')
    for n in bvl:
        out['bitvector_%d' % n] = (('bitvector', n), bvloc)
    for n in bll:
        out['bitlist_%d' % n] = (('bitlist', n), blloc)
    out['progbitlist'] = (('progbits',), pre + 'ssz_progressive_bitlist.py')
    return out


def strip_f(nf):
    k = nf[0]
    if k == 'container':
        return ('container', tuple((n[2:] if n.startswith('f_') else n, strip_f(t)) for n, t in nf[1]))
    if k == 'progcontainer':
        return ('progcontainer', tuple((n[2:] if n.startswith('f_') else n, strip_f(t)) for n, t in nf[1]), nf[2])
    if k in ('vector', 'list'):
        return (k, strip_f(nf[1]), nf[2])
    if k == 'proglist':
        return (k, strip_f(nf[1]))
    if k == 'compatunion':
        return (k, nf[1], tuple(strip_f(x) for x in nf[2]))
    return nf


def audit_generic(ref_g, repo):
    path = 'proofs/obj/generic_specs_generated.bend'
    defs = read_defs(os.path.join(repo, path))
    be = Bend(defs)
    shared = {'boolean', 'uint8', 'uint32', 'uint64', 'uint256'}
    for name in sorted(set(defs) | set(ref_g)):
        if name in shared:
            continue
        if name not in defs:
            if re.fullmatch(r'(vec_\w+|bitvector)_0', name):
                continue
            row('D generic names', name, '-', ref_g[name][1], 'only in reference')
            continue
        nf = strip_f(be.ref(name))
        if name not in ref_g:
            row('D generic names', name, '%s:%d' % (path, defs[name][1]), '-', 'only in Bend')
            continue
        diffs = compare(nf, ref_g[name][0], name)
        row('D generic names', name, '%s:%d' % (path, defs[name][1]), '%s (%s)' % (short(ref_g[name][0]), ref_g[name][1]),
            'MISMATCH' if diffs else 'match', '; '.join(diffs[:3]))


# ---------------------------------------------------------------------------------------------------------------
# E. protocol constants inside spec/*.bend: reference value read from simple-serialize.md, Bend value from a probe
# ---------------------------------------------------------------------------------------------------------------
def find_ref(lines, pattern, group=1, conv=int):
    for i, l in enumerate(lines, 1):
        m = re.search(pattern, l)
        if m:
            return conv(m.group(group)), i
    raise RefError('no match for ' + pattern)


def audit_rules(repo, cs):
    ssl = 'ssz/simple-serialize.md'
    L = open(os.path.join(cs, ssl), encoding='utf-8').read().split('\n')
    R = {}

    def put(key, pattern, group=1, conv=int):
        v, ln = find_ref(L, pattern, group, conv)
        R[key] = (v, '%s:%d' % (ssl, ln))
    for name in ('BYTES_PER_CHUNK', 'BYTES_PER_LENGTH_OFFSET', 'BITS_PER_BYTE'):
        put(name, r'`%s`\s*\|\s*`(\d+)`' % name)
    put('uint widths', r'assert N in (\[[0-9, ]+\])', conv=ast.literal_eval)
    put('bitvector bytes pad', r'\(\(N \+ (\d+)\) // (\d+)\)')
    put('bitvector bytes div', r'\(\(N \+ (\d+)\) // (\d+)\)', group=2)
    put('bitfield chunk pad', r'`\(N \+ (\d+)\) // (\d+)`')
    put('bitfield chunk div', r'`\(N \+ (\d+)\) // (\d+)`', group=2)
    put('basic chunk pad', r'`\(N \* size_of\(B\) \+ (\d+)\) // (\d+)`')
    put('basic chunk div', r'`\(N \* size_of\(B\) \+ (\d+)\) // (\d+)`', group=2)
    put('union selector max', r'selectors above (\d+)')
    put('compat selector min', r'selector outside `uint8\((\d+)\)`')
    ln = next(i for i, l in enumerate(L) if 'selector outside' in l)
    R['compat selector max'] = (int(re.search(r'`uint8\((\d+)\)`', L[ln + 1]).group(1)), '%s:%d' % (ssl, ln + 2))
    put('active_fields max', r'more than (\d+)\s*$')
    put('progressive growth', r'num_leaves \* (\d+)')
    put('progressive first leaves', r'merkleize_progressive\(chunks, num_leaves=(\d+)\)')
    put('union min options (first is None)', r'at least (\d+) type options if the first is `None`')
    put('bitlist byte div', r'\(len\(value\) // (\d+)\) \+ 1')
    put('bitlist delimiter mod', r'1 << \(len\(value\) % (\d+)\)')
    put('None selector', r'value\.selector == (\d+)')
    _, ln = find_ref(L, r'2 \*\* \(BYTES_PER_LENGTH_OFFSET \* BITS_PER_BYTE\)', 0, str)
    R['offset limit'] = (2 ** (R['BYTES_PER_LENGTH_OFFSET'][0] * R['BITS_PER_BYTE'][0]), '%s:%d' % (ssl, ln))

    cache = {}

    def src(f):
        if f not in cache:
            cache[f] = open(os.path.join(repo, f), encoding='utf-8').read().split('\n')
        return cache[f]
    claimed = {}

    def probe(item, refloc, exp, f, pattern, group=1, note=''):
        """exp: the reference value (int or list); every match of the Bend regex must equal it."""
        refcell = '%s (%s)' % (exp, refloc)
        hits = []
        for i, l in enumerate(src(f), 1):
            for m in re.finditer(pattern, l):
                vals = tuple(int(x) for x in m.groups() if x is not None) if group == 'all' else (int(m.group(group)),)
                hits.append((i, vals))
                claimed.setdefault(f, set()).add(i)
        COUNT['rule'] += 1
        if not hits:
            row(TBL_E, item, '%s: probe found nothing' % f, refcell, 'MISMATCH', 'regex %r' % pattern)
            return
        got_all = []
        for i, vals in hits:
            got_all += list(vals)
            if group != 'all':
                ok = isinstance(exp, int) and vals[0] == exp
                row(TBL_E, item, '%d %s:%d' % (vals[0], f, i), refcell, 'match' if ok else 'MISMATCH', note)
        if group == 'all':
            ok = got_all == list(exp)
            row(TBL_E, item, '%s %s:%s' % (got_all, f, ','.join(str(i) for i, _ in hits)), refcell, 'match' if ok else 'MISMATCH', note)

    off, chunk, bpb = R['BYTES_PER_LENGTH_OFFSET'][0], R['BYTES_PER_CHUNK'][0], R['BITS_PER_BYTE'][0]
    loc = lambda *ks: ', '.join(R[k][1] for k in ks)

    # ---- BYTES_PER_LENGTH_OFFSET = 4 ----
    for f, pat, why in [
        ('spec/layout.bend', r'case T\.Variable\{xs\}: (\d+)n', 'a variable part occupies one offset in the fixed region'),
        ('spec/layout.bend', r'N\.digits\((\d+)n, offset\)', 'the offset is serialized as uint32'),
        ('spec/layout.bend', r'N\.fits\((\d+)n, Nat\.add\(fixed', 'sum(fixed_lengths + variable_lengths) < 2**(OFFSET*8)'),
        ('spec/layout.bend', r'N\.fits\((\d+)n, offset\)', 'every offset is representable in uint32'),
        ('spec/layout_decoding.bend', r'case None\{\}: (\d+)n', 'slot of a variable field while decoding'),
        ('spec/layout_decoding.bend', r'N\.fits\((\d+)n, List\.length', 'total size < 2**32 on decode'),
        ('spec/byte_list.bend', r'Length\.fits\((\d+)n, ', 'ByteList: sequence-serialization size assertion'),
    ]:
        probe('BYTES_PER_LENGTH_OFFSET: ' + why, loc('BYTES_PER_LENGTH_OFFSET'), off, f, pat)
    cnt = src('spec/bytes.bend')[5].count('Nat.div(')
    claimed.setdefault('spec/bytes.bend', set()).add(6)
    COUNT['rule'] += 1
    row(TBL_E, 'Vector[byte,N] size < 2**32: nested divisions by 256n in size_fits', '%d divisions, spec/bytes.bend:6' % cnt,
        '%d (%s)' % (off, loc('BYTES_PER_LENGTH_OFFSET')), 'match' if cnt == off else 'MISMATCH')
    probe('2**BITS_PER_BYTE: byte radix of a length digit (div)', loc('BITS_PER_BYTE'), 2 ** bpb, 'spec/nat_bytes.bend', r'Nat\.div\(n, (\d+)n\)')
    probe('2**BITS_PER_BYTE: byte radix of a length digit (mod)', loc('BITS_PER_BYTE'), 2 ** bpb, 'spec/nat_bytes.bend', r'Nat\.mod\(n, (\d+)n\)')
    probe('2**BITS_PER_BYTE: byte radix of a limb digit', loc('BITS_PER_BYTE'), 2 ** bpb, 'spec/primitives.bend', r'U32\.mod\(x, (256)\)')
    probe('limb digit weights 256**1, 256**2, 256**3', loc('BITS_PER_BYTE'), [2 ** bpb, 2 ** (2 * bpb), 2 ** (3 * bpb)],
          'spec/primitives.bend', r'U32\.div\(x, (256)\), 256\)|U32\.div\(x, (65536)\), 256\)|U32\.div\(x, (16777216)\)', group='all')
    probe('limb digit weights (byte at limb position 1..3)', loc('BITS_PER_BYTE'), [2 ** bpb, 2 ** (2 * bpb), 2 ** (3 * bpb)],
          'spec/primitives.bend', r'U32\.mul\((256), byte_at|U32\.mul\((65536), byte_at|U32\.mul\((16777216), byte_at', group='all')
    # ---- BYTES_PER_CHUNK = 32 ----
    for f, pat, why in [
        ('spec/merkle.bend', r'P\.byte_scope\((\d+)n, left\)', 'a hash input child is one chunk'),
        ('spec/merkle.bend', r'P\.zero_bytes\((\d+)n\)', 'the zero chunk'),
        ('spec/packing.bend', r'P\.byte_scope\((\d+)n, h\)', 'every packed chunk is BYTES_PER_CHUNK bytes'),
        ('spec/mixing.bend', r'P\.byte_scope\((\d+)n, root\)', 'a root is one chunk'),
        ('spec/bytes.bend', r'Nat\.is_le\(List\.length\(&2, U32, xs\), (\d+)n\)', 'chunk fragment length'),
        ('spec/bytes.bend', r'Nat\.sub\((\d+)n, List\.length', 'right-pad a chunk fragment'),
        ('spec/primitives.bend', r'Nat\.sub\((\d+)n, byte_width\(w\)\)', 'uint root: right-pad to a chunk'),
        ('spec/root_relation.bend', r'Nat\.sub\((\d+)n, List\.length\(&2, U32, BitPack', 'mix_in_active_fields: pack_bits padded to a chunk'),
    ]:
        probe('BYTES_PER_CHUNK: ' + why, loc('BYTES_PER_CHUNK'), chunk, f, pat)
    for f, pat, why in [
        ('spec/packing.bend', r'scan\(xs, (\d+)n, \[\], \[\]\)', 'pack: slots-left counter starts at CHUNK-1'),
        ('spec/packing.bend', r'scan\(t, (\d+)n, \[\]', 'pack: counter restarts after a full chunk'),
        ('spec/bit_root.bend', r'Pack\.scan\(Bits\.pack\(bits\), (\d+)n', 'pack_bits'),
        ('spec/byte_root.bend', r'Pack\.scan\(xs, (\d+)n', 'pack of a byte vector'),
        ('spec/byte_list.bend', r'Pack\.scan\(xs, (\d+)n', 'pack of a byte list'),
        ('spec/mixing.bend', r'zero_bytes\((\d+)n\)\)', 'mix_in_selector: selector chunk = 1 byte + 31 zero bytes'),
        ('spec/primitives.bend', r'zero_bytes\((\d+)n\)\)\s*$', 'boolean root = 1 byte + 31 zero bytes'),
        ('spec/root_relation.bend', r'P\.boolean_encoding\(b\), P\.zero_bytes\((\d+)n\)', 'boolean root'),
        ('spec/root_relation_serializable.bend', r'boolean_encoding\(b\), P\.zero_bytes\((\d+)n\)', 'boolean root (pre-correction snapshot)'),
    ]:
        probe('BYTES_PER_CHUNK-1: ' + why, loc('BYTES_PER_CHUNK'), chunk - 1, f, pat)
    probe('chunk_count basic: (N * size + 31) pad', R['basic chunk pad'][1], R['basic chunk pad'][0], 'spec/root_relation.bend', r'Nat\.add\(Nat\.mul\(limit, width\), (\d+)n\)')
    probe('chunk_count basic: // 32', R['basic chunk div'][1], R['basic chunk div'][0], 'spec/root_relation.bend', r'Nat\.mul\(limit, width\), \d+n\), (\d+)n\)')
    probe('chunk_count ByteList (basic of size 1): (N + 31) pad', R['basic chunk pad'][1], R['basic chunk pad'][0], 'spec/byte_list.bend', r'Nat\.add\(capacity, (\d+)n\)')
    probe('chunk_count ByteList: // 32', R['basic chunk div'][1], R['basic chunk div'][0], 'spec/byte_list.bend', r'Nat\.add\(capacity, \d+n\), (\d+)n\)')
    probe('chunk_count Bitlist/Bitvector: (N + 255) pad', R['bitfield chunk pad'][1], R['bitfield chunk pad'][0], 'spec/bit_root.bend', r'Nat\.add\(capacity, (\d+)n\)')
    probe('chunk_count Bitlist/Bitvector: // 256', R['bitfield chunk div'][1], R['bitfield chunk div'][0], 'spec/bit_root.bend', r'Nat\.add\(capacity, \d+n\), (\d+)n\)')
    probe('256 bits per chunk = BYTES_PER_CHUNK * BITS_PER_BYTE', loc('BYTES_PER_CHUNK', 'BITS_PER_BYTE'), chunk * bpb, 'spec/bit_root.bend', r'Nat\.add\(capacity, \d+n\), (\d+)n\)')
    for f, pat in [('spec/bit_root.bend', r'Length\.encoding\((\d+)n, List\.length'), ('spec/byte_list.bend', r'Length\.encoding\((\d+)n, List\.length'),
                   ('spec/root_relation.bend', r'Length\.encoding\((\d+)n, n\)'), ('spec/value_domain.bend', r'Length\.fits\((\d+)n, ')]:
        probe('mix_in_length: the length is a uint256 = 32 bytes', loc('BYTES_PER_CHUNK'), chunk, f, pat)
    # ---- bits ----
    probe('Bitvector bytes: (N + 7) pad (schema)', R['bitvector bytes pad'][1], R['bitvector bytes pad'][0], 'spec/schema.bend', r'Nat\.add\(n, (\d+)n\)')
    probe('Bitvector bytes: // 8 (schema)', R['bitvector bytes div'][1], R['bitvector bytes div'][0], 'spec/schema.bend', r'Nat\.add\(n, \d+n\), (\d+)n\)')
    probe('Bitvector bytes: (N + 7) pad (codec)', R['bitvector bytes pad'][1], R['bitvector bytes pad'][0], 'spec/codec.bend', r'Nat\.add\(n, (\d+)n\)')
    probe('Bitvector bytes: // 8 (codec)', R['bitvector bytes div'][1], R['bitvector bytes div'][0], 'spec/codec.bend', r'Nat\.add\(n, \d+n\), (\d+)n\)')
    probe('bit_packing.byte_count: 8 bits per byte', loc('BITS_PER_BYTE'), bpb, 'spec/bit_packing.bend', r'case (\d+)n\+p: 1n\+byte_count')
    probe('bitlist: at most 7 unused bits below the delimiter (BITS_PER_BYTE-1)', R['bitlist delimiter mod'][1], R['bitlist byte div'][0] - 1,
          'spec/bit_decode.bend', r'delimiter\(List\.reverse\(&2, Bool, expand\(xs\)\), (\d+)n\)')
    probe('bit weights of a packed octet: bit i has weight 2**i', loc('BITS_PER_BYTE'), [1, 2, 4, 8, 16, 32, 64, 128],
          'spec/bit_packing.bend', r'Bool\.pick\(U32, b0, (1), 0\)|Bool\.pick\(U32, b1, (2), 0\)|Bool\.pick\(U32, b2, (4), 0\)|Bool\.pick\(U32, b3, (8), 0\)|Bool\.pick\(U32, b4, (16), 0\)|Bool\.pick\(U32, b5, (32), 0\)|Bool\.pick\(U32, b6, (64), 0\)|Bool\.pick\(U32, b7, (128), 0\)', group='all')
    probe('bit weights: arithmetic decoding divisors (floor(x / 2**i) mod 2)', loc('BITS_PER_BYTE'), [1, 2, 4, 8, 16, 32, 64, 128],
          'spec/bit_decoding.bend', r'U32\.div\(x, (1)\)|U32\.div\(x, (2)\)|U32\.div\(x, (4)\)|U32\.div\(x, (8)\)|U32\.div\(x, (16)\)|U32\.div\(x, (32)\)|U32\.div\(x, (64)\)|U32\.div\(x, (128)\)', group='all')
    # ---- uint widths ----
    pw = {'U8': 8, 'U16': 16, 'U32Width': 32, 'U64': 64, 'U128': 128, 'U256': 256}
    seen = set()
    for i, l in enumerate(src('spec/primitives.bend'), 1):
        m = re.match(r'^    case T\.(\w+)\{\}: (\d+)n$', l)
        if m and m.group(1) in pw:
            COUNT['rule'] += 1
            claimed.setdefault('spec/primitives.bend', set()).add(i)
            seen.add(pw[m.group(1)])
            exp = pw[m.group(1)] // bpb
            row(TBL_E, 'byte_width(%s) = N // BITS_PER_BYTE' % m.group(1), '%s spec/primitives.bend:%d' % (m.group(2), i),
                '%d (%s; N in %s)' % (exp, loc('BITS_PER_BYTE', 'uint widths'), R['uint widths'][0]),
                'match' if int(m.group(2)) == exp and pw[m.group(1)] in R['uint widths'][0] else 'MISMATCH')
    COUNT['rule'] += 1
    row(TBL_E, 'the set of uint widths (T.Width constructors of types/primitive.bend)', sorted(seen), '%s (%s)' % (R['uint widths'][0], R['uint widths'][1]),
        'match' if seen == set(R['uint widths'][0]) else 'MISMATCH')
    pos = []
    for i, l in enumerate(src('spec/primitives.bend'), 1):
        if 'limb_value(xs, ' in l and 'def limb_value' not in l:
            pos += [int(x) for x in re.findall(r'limb_value\(xs, (\d+)n\)', l)]
            claimed.setdefault('spec/primitives.bend', set()).add(i)
    COUNT['rule'] += 1
    exp = [off * k for k in range(8)]
    row(TBL_E, 'integer_value: 8 limbs of BYTES_PER_LENGTH_OFFSET bytes = 32 bytes = uint256 (BYTES_PER_CHUNK)', pos,
        '%s (%s)' % (exp, loc('BYTES_PER_LENGTH_OFFSET', 'BYTES_PER_CHUNK')), 'match' if pos == exp and 8 * off == chunk else 'MISMATCH')
    # ---- unions ----
    probe('Union: at most 127 options after the first (selectors 0..127)', R['union selector max'][1], R['union selector max'][0],
          'spec/type_legality.bend', r'Nat\.is_le\(field_count\(rest\), (\d+)n\)')
    probe('CompatibleUnion selector upper bound: selector < 128 = 127 + 1', R['compat selector max'][1], R['compat selector max'][0] + 1,
          'spec/type_legality.bend', r'U32\.is_lt\(head, (\d+)\)')
    probe('CompatibleUnion selector lower bound: 0 < selector, i.e. >= 1', R['compat selector min'][1], R['compat selector min'][0] - 1,
          'spec/type_legality.bend', r'U32\.is_lt\((\d+), head\)')
    probe('Union with None first needs at least 2 options (0 < options after None)', R['union min options (first is None)'][1],
          R['union min options (first is None)'][0] - 2, 'spec/type_legality.bend',
          r'Nat\.is_lt\((\d+)n, field_count\(rest\)\) == True\{\} : Bool\} & \{Nat\.is_le\(field_count\(rest\), 127')
    probe('mix_in_selector: the selector is a uint8 (< 2**BITS_PER_BYTE)', loc('BITS_PER_BYTE'), 2 ** bpb, 'spec/mixing.bend', r'U32\.is_lt\(selector, (\d+)\)')
    probe('ProgressiveContainer: active_fields has at most 256 entries', R['active_fields max'][1], R['active_fields max'][0],
          'spec/type_legality.bend', r'Nat\.is_le\(List\.length\(&2, Bool, active\), (\d+)n\)')
    # ---- progressive ----
    probe('merkleize_progressive: num_leaves starts at 1 (depth 0)', R['progressive first leaves'][1], 0,
          'spec/progressive.bend', r'tree\(List\.length\(&2, \+List<U32>, chunks\), (\d+)n, chunks\)', note='literal is the depth log2(num_leaves)')
    probe('merkleize_progressive: num_leaves * 4 (depth increases by log2(4) = 2)', R['progressive growth'][1], 2,
          'spec/progressive.bend', r'tree\(p, (\d+)n\+depth', note='literal is log2(growth factor)')
    probe('merkleize_progressive (completeness predicate): depth increases by 2', R['progressive growth'][1], 2,
          'spec/progressive.bend', r'complete\(p, (\d+)n\+depth', note='literal is log2(growth factor)')
    probe('perfect tree: one level halves the width (depth step)', 'ssz/simple-serialize.md merkleize (binary tree)', 1, 'spec/merkle.bend', r'case (1)n\+p:')
    probe('limit 0 or 1 pads to one chunk: depth 0', 'ssz/simple-serialize.md next_pow_of_two 0->1', 0, 'spec/limits.bend', r'case (0)n: True\{\}')
    probe('illegal: empty Vector / ByteVector / Bitvector (0 < N)', 'ssz/simple-serialize.md Illegal types', 0, 'spec/type_legality.bend', r'\{Nat\.is_lt\((0)n, n\)')
    # ---- remaining structural constants ----
    probe('a byte is < 2**BITS_PER_BYTE (byte_scope, bytes_domain)', loc('BITS_PER_BYTE'), 2 ** bpb, 'spec/primitives.bend', r'U32\.is_lt\(h, (\d+)\)')
    probe('little-endian value of a byte string: radix 2**BITS_PER_BYTE', loc('BITS_PER_BYTE'), 2 ** bpb, 'spec/nat_bytes.bend', r'Nat\.mul\(value\(t\), (\d+)n\)')
    probe('empty merkleize_progressive is a zero chunk (BYTES_PER_CHUNK bytes)', 'ssz/simple-serialize.md merkleize_progressive: Bytes32()', chunk, 'spec/progressive.bend', r'P\.zero_bytes\((\d+)n\)')
    probe('inactive progressive-container slot is a zero chunk', 'ssz/simple-serialize.md (EIP-7495 active slots)', chunk, 'spec/root_relation.bend', r'\{slot == P\.zero_bytes\((\d+)n\)')
    probe('root of None in a Union is Bytes32() (zero chunk)', 'ssz/simple-serialize.md hash_tree_root: mix_in_selector(Bytes32(), 0)', chunk, 'spec/root_relation.bend', r'outputs == \[P\.zero_bytes\((\d+)n\)\]')
    probe('root of None in a Union is Bytes32() (pre-correction snapshot)', 'ssz/simple-serialize.md hash_tree_root: mix_in_selector(Bytes32(), 0)', chunk, 'spec/root_relation_serializable.bend', r'outputs == \[P\.zero_bytes\((\d+)n\)\]')
    # bit_packing.byte_count: the base cases 1..7 are one byte each, 8 starts a new byte: ceil(n / BITS_PER_BYTE)
    bad = []
    for i, l in enumerate(src('spec/bit_packing.bend'), 1):
        m = re.match(r'^    case (\d+)n: (\d+)n$', l)
        if m:
            claimed.setdefault('spec/bit_packing.bend', set()).add(i)
            n, v = int(m.group(1)), int(m.group(2))
            if v != -(-n // bpb):
                bad.append((i, n, v))
    COUNT['rule'] += 1
    row(TBL_E, 'bit_packing.byte_count base cases n = 0..7 equal ceil(n / BITS_PER_BYTE)', 'lines 21-29 of spec/bit_packing.bend',
        'ceil(n / %d) (%s)' % (bpb, loc('BITS_PER_BYTE')), 'match' if not bad else 'MISMATCH', str(bad))
    return R, claimed


def coverage(repo, claimed):
    """Numeric literals in spec/*.bend other than 0, 1, 2 (arity `&2`, base cases) that no probe claimed."""
    out = []
    d = os.path.join(repo, 'spec')
    for f in sorted(os.listdir(d)):
        if not f.endswith('.bend') or f == 'fulu_schemas.bend':
            continue
        rel = 'spec/' + f
        for i, l in enumerate(open(os.path.join(d, f), encoding='utf-8'), 1):
            code = l.split('#')[0]
            vals = [int(x) for x in re.findall(r'(?<![A-Za-z_0-9.&<])(\d+)n?\b(?![A-Za-z_])', code) if int(x) > 2]
            if vals and i not in claimed.get(rel, set()):
                out.append((rel, i, vals, l.strip()[:110]))
    return out


# ---------------------------------------------------------------------------------------------------------------
# F. generated type files carry limits in their names: compare with the limits in the reference types
# ---------------------------------------------------------------------------------------------------------------
def instances(nf, acc):
    k = nf[0]
    if k in ('bitvector', 'bitlist'):
        acc.add((k, nf[1]))
    elif k in ('vector', 'list'):
        el = nf[1]
        if k == 'vector' and el[0] == 'bool':
            acc.add(('vec_bool', nf[2]))
        elif k == 'vector' and el[0] == 'uint':
            acc.add(('vec_uint%d' % el[1], nf[2]))
        instances(el, acc)
    elif k in ('container', 'progcontainer'):
        for _, t in nf[1]:
            instances(t, acc)
    elif k == 'proglist':
        instances(nf[1], acc)


def audit_generated(repo, ref, ref_g, names):
    want = set()
    for n in names:
        try:
            instances(ref.type_of(n), want)
        except RefError:
            pass
    for n, (nf, _) in ref_g.items():
        instances(nf, want)
    have = {}
    for f in sorted(os.listdir(os.path.join(repo, 'types'))):
        m = re.fullmatch(r'(bitlist|bitvector|vec_bool|vec_uint\d+)_(\d+)_def_generated\.bend', f)
        if m:
            have[(m.group(1), int(m.group(2)))] = 'types/' + f
    for k in sorted(set(want) | set(have)):
        COUNT['attr'] += 1
        if k in want and k in have:
            row('F generated type files', '%s_%d' % k, have[k], 'occurs in the reference types', 'match')
        elif k in have:
            row('F generated type files', '%s_%d' % k, have[k], '-', 'only in Bend', 'generated type with no occurrence in the Fulu/generic reference types')
        else:
            row('F generated type files', '%s_%d' % k, '-', 'occurs in the reference types', 'only in reference',
                'no generated file of that name (the runtime may generate it under another shape)')


# ---------------------------------------------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--out', default='tools/spec_audit/data')
    a = ap.parse_args()
    repo, cs = a.repo, a.cs
    lock = json.load(open(os.path.join(repo, 'upstream.lock.json')))
    tag = lock['consensus_specs']['tag']
    ref = Ref(cs)
    ycons, ytypes = read_codegen_yaml(os.path.join(repo, 'codegen/fulu.yaml'))
    yeval = YamlTypes(ycons, ytypes)
    jsons = read_json_schemas(os.path.join(repo, 'schemas/fulu_mainnet.json'))
    bspec = Bend(read_defs(os.path.join(repo, 'spec/fulu_schemas.bend')))
    audit_scalars(ref, ycons, 'codegen/fulu.yaml')
    ref.used = set()
    audit_types(ref, jsons, bspec, ytypes, yeval, 'codegen/fulu.yaml', 'spec/fulu_schemas.bend', 'schemas/fulu_mainnet.json')
    used_by_types = set(ref.used)
    audit_alias(ref, repo)
    rg = ref_generic(cs)
    audit_generic(rg, repo)
    for name in sorted(used_by_types):
        if name not in ycons:
            COUNT['scalar'] += 1
            row('A3 constants the reference types depend on that codegen/fulu.yaml does not list', name, '-', '%s (%s)' % (ref.const(name), ref.where(name)), 'only in reference',
                'derived inside a type expression (floorlog2 of a generalized index, ...); the Bend value appears expanded in the schema')
    R, claimed = audit_rules(repo, cs)
    audit_generated(repo, ref, rg, sorted(set(jsons) | set(ytypes)))
    unclaimed = coverage(repo, claimed)
    os.makedirs(a.out, exist_ok=True)
    tables = {}
    for r in ROWS:
        tables.setdefault(r['table'], []).append(r)
    stat = {}
    for r in ROWS:
        k = r['status'].split(' (')[0]
        stat[k] = stat.get(k, 0) + 1
    md = ['# Constants audit (generated by tools/spec_audit/constants.py)', '',
          'Reference: consensus-specs %s (%s). Rows compared: %d. Status counts: %s.' % (tag, lock['consensus_specs']['commit'][:10], len(ROWS), json.dumps(stat)),
          'Compared items: %d scalar constants, %d numeric attributes (sizes, lengths, limits, active_fields bits, selectors), %d field names, %d protocol-rule probes.'
          % (COUNT['scalar'], COUNT['attr'], COUNT['name'], COUNT['rule']), '']
    for t in sorted(tables):
        md += ['## ' + t, '', '| item | Bend value (file:line) | reference value (file:line) | status | note |', '|---|---|---|---|---|']
        for r in tables[t]:
            md.append('| %s | %s | %s | %s | %s |' % tuple(str(r[k]).replace('|', '/') for k in ('item', 'bend', 'ref', 'status', 'note')))
        md.append('')
    md += ['## G literals in spec/*.bend not claimed by any probe (excluding 0, 1, 2 and fulu_schemas.bend)', '',
           '| file:line | literals | text |', '|---|---|---|']
    for rel, i, vals, txt in unclaimed:
        md.append('| %s:%d | %s | `%s` |' % (rel, i, vals, txt.replace('|', '/')))
    md.append('')
    if ref.dups_in_fork:
        md += ['## reference classes defined twice in one fork (last wins)', ''] + ['- %s: %s, %s' % d for d in ref.dups_in_fork] + ['']
    open(os.path.join(a.out, 'constants_report.md'), 'w').write('\n'.join(md))
    json.dump({'tag': tag, 'rows': ROWS, 'count': COUNT, 'status': stat, 'unclaimed': unclaimed}, open(os.path.join(a.out, 'constants_report.json'), 'w'), indent=1)
    print('rows %d  %s' % (len(ROWS), json.dumps(stat)))
    print('compared: scalars %(scalar)d  attrs %(attr)d  field names %(name)d  rules %(rule)d' % COUNT)
    print('unclaimed literals: %d' % len(unclaimed))
    bad = [r for r in ROWS if r['status'].startswith('MISMATCH')]
    for r in bad[:60]:
        print('MISMATCH', r['table'], r['item'], '|', r['bend'], '|', r['ref'], '|', r['note'])
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
