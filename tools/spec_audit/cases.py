#!/usr/bin/env python3
"""Differential boundary corpus generated FROM the reference.

    python3 tools/spec_audit/cases.py --repo . --cs ../cs --out DIR [--seed N] [--per-type N] [--names a,b,c]

For every type (Fulu names from the consensus-specs markdown, generic names from the ssz_generic generator sources) the
reference port tools/spec_audit/ssz_ref.py (a port of ssz/simple-serialize.md) produces valid encodings at the boundaries
(empty, 1, limit-1, limit of every list/bitlist field, zero/max/random basic values) and invalid ones (limit+1, every
offset pushed out of order/range, first offset wrong, trailing and missing bytes, bitlist without delimiter and with
padding bits, bitvector padding bits, bad boolean/union selectors, wrong lengths), together with the reference verdict
(accept/reject + reason), and for accepted cases the hash_tree_root.

DIR/cases.jsonl: one JSON per line {id, type, label, hex, verdict, reason, root}.
"""
import argparse
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import ssz_ref as S  # noqa: E402
from constants import ref_generic  # noqa: E402
from refparse import Ref, RefError  # noqa: E402

BIG = 400_000     # a type whose zero encoding is larger than this gets a short case list


def list_like(t):
    return t[0] in ('list', 'bytelist', 'bitlist', 'proglist', 'progbits')


def limit_of(t):
    return t[-1] if t[0] in ('list', 'bytelist', 'bitlist') else None


def value_with_len(t, n, rng, mode):
    """A value of list-like type t with n elements; mode: zero | max | rand."""
    k = t[0]
    if k == 'bytelist':
        return bytes([{'zero': 0, 'max': 255}.get(mode, 0xA5)] * n) if mode != 'rand' else bytes(rng.getrandbits(8) for _ in range(n))
    if k in ('bitlist', 'progbits'):
        return [mode == 'max' or (mode == 'rand' and rng.random() < .5) for _ in range(n)]
    el = t[1]
    return [elem_value(el, rng, mode) for _ in range(n)]


def elem_value(t, rng, mode):
    if mode == 'zero':
        return S.zero_value(t)
    if mode == 'max':
        return max_value(t)
    return S.random_value(t, rng, 3)


def max_value(t):
    k = t[0]
    if k == 'bool':
        return True
    if k == 'uint':
        return (1 << t[1]) - 1
    if k == 'bytes':
        return b'\xff' * t[1]
    if k == 'bytelist':
        return b'\xff' * min(3, t[1])
    if k == 'bitvector':
        return [True] * t[1]
    if k in ('bitlist',):
        return [True] * min(3, t[1])
    if k == 'progbits':
        return [True] * 3
    if k == 'vector':
        return [max_value(t[1]) for _ in range(t[2])]
    if k == 'list':
        return [max_value(t[1])] * min(2, t[2])
    if k == 'proglist':
        return [max_value(t[1])] * 2
    if k in ('container', 'progcontainer'):
        return [max_value(ft) for _, ft in t[1]]
    if k in ('union', 'compatunion'):
        return S.zero_value(t)
    raise ValueError(k)


def elem_cost(t):
    """Rough encoded size of one element, to keep over-limit encodings small."""
    return 4 if S.is_variable_size(t) else max(1, S.fixed_size(t))


def feasible(t, n):
    """Whether a list-like value of n elements is cheap enough to build (<= 2 MB encoded, <= 1.1 M elements)."""
    unit = 0.125 if t[0] == 'bitlist' or t[0] == 'progbits' else (1 if t[0] == 'bytelist' else elem_cost(t[1]))
    return n * unit <= 2_000_000 and n <= 1_100_000


def len_choices(t):
    """(valid lengths, over-limit length or None)"""
    lim = limit_of(t)
    c = {0, 1, 2}
    if t[0] in ('proglist', 'progbits'):
        c |= {3, 4, 5, 20, 21, 22, 85, 86}
        if t[0] == 'progbits':
            c |= {255, 256, 257, 1023, 1024, 1025}
    over = None
    if lim is not None:
        if t[0] == 'bitlist':
            c |= {7, 8, 9, 15, 16, 17, 255, 256, 257}
        if feasible(t, lim):
            c |= {lim - 1, lim}
        if feasible(t, lim + 1):
            over = lim + 1
        c = {x for x in c if x <= lim}
    return sorted(x for x in c if x >= 0 and feasible(t, x)), over


def boundary_values(t, rng, depth=0):
    """(label, value, over) triples: list-like lengths at the type's own level (valid lengths and limit+1) and, through
    containers and lists of containers, at every nested level up to depth 2; over=True when the value exceeds a limit."""
    out = []
    if list_like(t):
        valid, over = len_choices(t)
        for n in valid:
            for mode in ('zero', 'rand') if n <= 40 else ('zero',):
                out.append(('len%d_%s' % (n, mode), value_with_len(t, n, rng, mode), False))
        if over is not None:
            out.append(('limit+1', value_with_len(t, over, rng, 'zero'), True))
        if t[0] in ('list', 'proglist') and depth < 2 and t[1][0] in ('container', 'progcontainer'):
            for lab, ev, o in boundary_values(t[1], rng, depth + 1):
                out.append(('[0].' + lab, [ev], o))
    if t[0] in ('container', 'progcontainer') and depth < 3:
        base = [S.zero_value(ft) for _, ft in t[1]]
        for i, (fname, ft) in enumerate(t[1]):
            for lab, v, o in boundary_values(ft, rng, depth + 1):
                vv = list(base)
                vv[i] = v
                out.append(('%s.%s' % (fname, lab), vv, o))
    return out


def collect_offsets(t, v, base, acc, depth=0):
    """Absolute positions of the 4-byte offsets in serialize(t, v), nested levels included (bounded)."""
    k = t[0]
    if k in ('container', 'progcontainer', 'vector', 'list', 'proglist'):
        ets, evs = S.elems(t, v)
        if not any(S.is_variable_size(et) for et in ets):
            return
        pos = base
        fixed = [4 if S.is_variable_size(et) else S.fixed_size(et) for et in ets]
        parts = [S.serialize(et, ev) if S.is_variable_size(et) else None for et, ev in zip(ets, evs)]
        start = base + sum(fixed)
        cur = start
        for i, (et, ev) in enumerate(zip(ets, evs)):
            if S.is_variable_size(et):
                acc.append(pos)
                if depth < 2 and len(acc) < 200:
                    collect_offsets(et, ev, cur, acc, depth + 1)
                cur += len(parts[i])
            pos += fixed[i]
    elif k in ('union', 'compatunion'):
        sel, val = v
        et = t[1][sel] if k == 'union' else t[2][t[1].index(sel)]
        if et != ('null',) and depth < 2:
            collect_offsets(et, val, base + 1, acc, depth + 1)


def mutations(t, v, s, rng, budget):
    out = []
    n = len(s)
    out.append(('truncate1', s[:-1]) if n else ('empty_again', b''))
    out.append(('append00', s + b'\x00'))
    out.append(('append01', s + b'\x01'))
    out.append(('empty', b''))
    if n > 4:
        out.append(('truncate4', s[:-4]))
    if n:
        out.append(('prepend00', b'\x00' + s))
    offs = []
    collect_offsets(t, v, 0, offs)
    offs = offs[:60]
    for p in offs:
        o = int.from_bytes(s[p:p + 4], 'little')
        for nv in {0, 1, 3, 4, 5, o - 1, o + 1, o + 4, o - 4, n, n + 1, 2 ** 32 - 1, 2 ** 31}:
            if 0 <= nv < 2 ** 32 and nv != o:
                out.append(('off@%d=%d' % (p, nv), s[:p] + nv.to_bytes(4, 'little') + s[p + 4:]))
    for a, b in zip(offs, offs[1:]):                       # swap two successive offsets
        if s[a:a + 4] != s[b:b + 4]:
            out.append(('swap@%d,%d' % (a, b), s[:a] + s[b:b + 4] + s[a + 4:b] + s[a:a + 4] + s[b + 4:]))
    pos = list(range(n)) if n <= 12 else rng.sample(range(n), 10) + [n - 1, 0]
    for p in pos:
        for nv in (0x00, 0x01, 0x80, 0xFF, s[p] ^ 1):
            if nv != s[p]:
                out.append(('byte@%d=%02x' % (p, nv), s[:p] + bytes([nv]) + s[p + 1:]))
    if len(out) > budget:
        keep = out[:6] + rng.sample(out[6:], budget - 6)
        out = keep
    return out


def kind_specific(t, rng):
    """Hand-picked invalid/edge encodings for the type's own kind."""
    k, out = t[0], []
    if k == 'bool':
        out += [('bool02', b'\x02'), ('boolff', b'\xff'), ('bool0000', b'\x00\x00'), ('bool_empty', b'')]
    if k == 'uint':
        nb = t[1] // 8
        out += [('uint_short', b'\x01' * (nb - 1)), ('uint_long', b'\x01' * (nb + 1)), ('uint_max', b'\xff' * nb), ('uint_empty', b'')]
    if k == 'bitvector':
        n, nb = t[1], (t[1] + 7) // 8
        out += [('bv_ones', b'\xff' * nb), ('bv_long', b'\x00' * (nb + 1)), ('bv_short', b'\x00' * (nb - 1)), ('bv_zero', b'\x00' * nb)]
        if n % 8:
            out.append(('bv_pad_bit_set', b'\x00' * (nb - 1) + bytes([1 << (n % 8)])))
            out.append(('bv_top_pad_bit', b'\x00' * (nb - 1) + b'\x80'))
        else:
            out.append(('bv_full_last', b'\x00' * (nb - 1) + b'\xff'))
    if k == 'bitlist':
        lim = t[1]
        out += [('bl_empty', b''), ('bl_00', b'\x00'), ('bl_0000', b'\x00\x00'), ('bl_01', b'\x01'), ('bl_80', b'\x80'), ('bl_ff', b'\xff'),
                ('bl_delim_after_zero_byte', b'\x01\x00'), ('bl_two_delims_in_zero_bytes', b'\x00\x00\x01')]
        for nbits in (lim, lim + 1, lim + 2):
            if nbits <= 4096:
                nb = (nbits + 8) // 8
                data = bytearray(nb)
                data[nbits // 8] |= 1 << (nbits % 8)
                out.append(('bl_delim_at_%d' % nbits, bytes(data)))
                data2 = bytearray(data)
                data2[0] |= 1
                out.append(('bl_delim_at_%d_bit0' % nbits, bytes(data2)))
        # bytes beyond the limit: limit+8 bits all ones + delimiter
        if lim + 9 <= 4096:
            out.append(('bl_too_many_bytes', b'\xff' * ((lim + 8) // 8 + 1) + b'\x01'))
    if k == 'progbits':
        out += [('pb_empty', b''), ('pb_00', b'\x00'), ('pb_0000', b'\x00\x00'), ('pb_01', b'\x01'), ('pb_80', b'\x80')]
    if k == 'bytes':
        out += [('bytes_short', bytes(t[1] - 1)), ('bytes_long', bytes(t[1] + 1))]
    if k == 'compatunion':
        sels = set(t[1])
        for sel in sorted({0, 1, 2, 3, 4, 5, 127, 128, 255} | {max(sels) + 1}):
            for pl in (b'', b'\x00', bytes(8)):
                out.append(('cu_sel%d_pl%d' % (sel, len(pl)), bytes([sel]) + pl))
        out.append(('cu_empty', b''))
    if k == 'union':
        for sel in sorted({0, 1, 2, 3, 127, 128, 255, len(t[1]), len(t[1]) - 1}):
            for pl in (b'', b'\x00', bytes(8)):
                out.append(('un_sel%d_pl%d' % (sel, len(pl)), bytes([sel]) + pl))
        out.append(('un_empty', b''))
    if k in ('vector', 'list', 'bytelist', 'proglist') and not S.is_variable_size(t[1] if k in ('vector', 'list', 'proglist') else ('uint', 8)):
        et = t[1] if k in ('vector', 'list', 'proglist') else ('uint', 8)
        sz = S.fixed_size(et)
        out += [('elem_misaligned', bytes(sz * 2 + 1)), ('elem_short', bytes(max(sz - 1, 0)))]
    if k in ('vector', 'list', 'proglist') and S.is_variable_size(t[1]):
        out += [('first_offset_0', b'\x00\x00\x00\x00'), ('first_offset_1', b'\x01\x00\x00\x00'), ('first_offset_5', b'\x05\x00\x00\x00'),
                ('first_offset_3_short', b'\x03\x00\x00'), ('only_offset_4', b'\x04\x00\x00\x00'), ('offset_8_short', b'\x08\x00\x00\x00'),
                ('two_equal_offsets', b'\x08\x00\x00\x00\x08\x00\x00\x00'), ('decreasing', b'\x08\x00\x00\x00\x04\x00\x00\x00')]
    return out


def zero_len(t):
    """Length of the encoding of the zero value, without building it."""
    k = t[0]
    if not S.is_variable_size(t):
        return S.fixed_size(t)
    if k in ('container', 'progcontainer'):
        return sum(4 + zero_len(ft) if S.is_variable_size(ft) else S.fixed_size(ft) for _, ft in t[1])
    if k == 'vector':
        return t[2] * (4 + zero_len(t[1]))
    if k in ('bitlist', 'progbits'):
        return 1
    return 0 if k in ('bytelist', 'list', 'proglist') else 1 + zero_len(t[2][0] if k == 'compatunion' else t[1][0])


def make_cases(name, t, rng, per_type):
    big = zero_len(t) > BIG
    cases, valid = [], []
    vals = [('zero', S.zero_value(t), False)]
    if not big:
        vals += [('max', max_value(t), False)] + [('rand%d' % i, S.random_value(t, rng, 3), False) for i in range(3)]
        vals += boundary_values(t, rng)
    else:
        vals += [('rand0', S.random_value(t, rng, 1), False)]
    seen = set()
    for lab, v, over in vals:
        S.LAX = over
        try:
            s = S.serialize(t, v)
        except (AssertionError, OverflowError):
            continue
        finally:
            S.LAX = False
        if s in seen:
            continue
        seen.add(s)
        cases.append((lab, s))
        if not over:
            valid.append((lab, s))
    if not big:
        cases += kind_specific(t, rng)
    mut_budget = max(10, per_type // max(1, min(len(valid), 8)))
    pool = [x for x in valid if len(x[1]) <= 70_000]
    for lab, s in pool[:8]:
        for mlab, ms in mutations(t, S.deserialize(t, s), s, rng, mut_budget):
            cases.append(('%s|%s' % (lab, mlab), ms))
    if big:
        cases = cases[:40]
    out, seen = [], set()
    for lab, s in cases:
        if s in seen:
            continue
        seen.add(s)
        out.append((lab, s))
    if len(out) > per_type:
        must = [x for x in out if '|' not in x[0]]           # every constructed case (valid, limit+1, kind-specific) is kept
        rest = [x for x in out if '|' in x[0]]
        out = must + rng.sample(rest, max(0, per_type - len(must)))
    return out


def verdict(t, s):
    try:
        v = S.deserialize(t, s)
    except S.Reject as e:
        return 'reject', str(e), None
    except (IndexError, ValueError) as e:       # a malformed slice the reference cannot even read is a rejection
        return 'reject', 'malformed: %s' % e, None
    root = S.hash_tree_root(t, v).hex()
    again = S.serialize(t, v)
    if again != s:
        return 'ACCEPTED-BUT-NONCANONICAL', 'reference re-serialization differs', root
    return 'accept', '', root


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--seed', type=int, default=20261002)
    ap.add_argument('--per-type', type=int, default=300)
    ap.add_argument('--names', default='')
    a = ap.parse_args()
    ref = Ref(a.cs)
    gen = ref_generic(a.cs)
    fulu_idx = json.load(open(os.path.join(a.repo, 'types/obj_groups.json')))
    gen_idx = json.load(open(os.path.join(a.repo, 'types/generic_obj_index.json')))['generated']
    os.makedirs(a.out, exist_ok=True)
    names = [x for x in a.names.split(',') if x] or sorted(set(fulu_idx) | set(gen_idx))
    n_cases, stats = 0, {}
    with open(os.path.join(a.out, 'cases.jsonl'), 'w') as f:
        for name in names:
            if name in fulu_idx:
                t, src, info = ref.type_of(name), 'fulu', fulu_idx[name]
            else:
                t, src, info = gen[name][0], 'generic', gen_idx[name]
            rng = random.Random('%s/%s' % (a.seed, name))
            for lab, s in make_cases(name, t, rng, a.per_type):
                vd, why, root = verdict(t, s)
                f.write(json.dumps({'id': '%s#%d' % (name, n_cases), 'type': name, 'src': src, 'group': info['group'], 'index': info['index'],
                                    'label': lab, 'hex': s.hex() if len(s) <= 2_000_000 else None, 'len': len(s), 'verdict': vd, 'reason': why, 'root': root}) + '\n')
                n_cases += 1
                stats[vd] = stats.get(vd, 0) + 1
    print('types %d cases %d %s' % (len(names), n_cases, json.dumps(stats)))


if __name__ == '__main__':
    main()
