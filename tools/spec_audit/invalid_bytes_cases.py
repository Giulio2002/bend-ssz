#!/usr/bin/env python3
"""Byte-level corpus for the windows of variable-size fields, from the reference.

    python3 tools/spec_audit/invalid_bytes_cases.py --repo . --cs ../cs --out tools/spec_audit/data/invalid_bytes_cases.jsonl

cases.py mutates the offsets of valid encodings; which window lengths a field then gets is left to the random sample (300 cases per
type). A decoder bug that shows only for ONE window length of ONE field (an empty bit list, a window of one or three bytes, a
window whose last word is partial and is followed by the bytes of the next field, a window past the limit by one element) is
easily not in the sample. Here every variable field of every container in NAMES gets every raw window of a pool (by the kind
of the field), the other fields keep a valid value (all zero, and the maximum value), the offsets are recomputed so the container
is well formed around the window: the reference then decides whether that window is a value of the field.

Rows have the schema of cases.jsonl ({id, type, src, group, index, label, hex, len, verdict, reason, root}) and run with
run_bend.py (clean tree) or with the manual-mutant corpus runner.
"""
import argparse
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import ssz_ref as S  # noqa: E402
from cases import verdict  # noqa: E402

NAMES = ['BitsStruct', 'ProgressiveBitsStruct', 'ProgressiveVarTestStruct', 'VarTestStruct', 'ComplexTestStruct', 'FuluAttestation',
         'FuluPendingAttestation', 'FuluExecutionRequests', 'SingleFieldTestStruct', 'SmallTestStruct', 'FixedTestStruct']


# (type, elements per 32-byte chunk)
PROG = [('progbitlist', 256), ('proglist_bool', 32), ('proglist_uint8', 32), ('proglist_uint16', 16), ('proglist_uint32', 8),
        ('proglist_uint64', 4), ('proglist_uint128', 2), ('proglist_uint256', 1)]


def pool(ft):
    """raw windows for a variable field of type ft: (label, bytes)"""
    k = ft[0]
    z, f, a = b'\x00', b'\xff', b'\xaa'
    base = [('empty', b''), ('one00', z), ('one01', b'\x01'), ('one80', b'\x80'), ('oneff', f), ('two00', z * 2), ('three_ff', f * 3),
            ('three_aa', a * 3), ('five_ff', f * 5), ('seven_aa', a * 7), ('nine_ff', f * 9)]
    if k in ('bitlist', 'progbits'):
        base += [('delim_hi', b'\x00\x80'), ('delim_two_bytes', b'\x00\x00\x01'), ('two_delims', b'\x03\x01'), ('delim_after_zero', b'\x01\x00'),
                 ('full', b'\xff\x01'), ('word_delim', b'\xff\xff\xff\xff\x01'), ('word_nodelim', b'\xff\xff\xff\xff')]
        if k == 'bitlist':
            n = ft[1]
            nbytes = n // 8 + 1
            top = bytearray(nbytes)
            top[n // 8] = 1 << (n % 8)
            base.append(('limit', bytes(top)))
            over = bytearray(nbytes + 1)
            over[(n + 1) // 8] = 1 << ((n + 1) % 8)
            base.append(('limit+1', bytes(over)))
    elif k in ('bytelist', 'list', 'proglist', 'vector', 'bytes'):
        esz = ft[1][1] // 8 if (k in ('list', 'proglist', 'vector') and ft[1][0] == 'uint') else 1
        if k in ('bytelist', 'list'):
            lim = ft[-1]
            base.append(('limit', bytes([0xa5]) * (lim * esz)))
            base.append(('limit+1', bytes([0xa5]) * ((lim + 1) * esz)))
        base.append(('odd_unit', b'\xff' * (esz * 2 + 1)))
    return base


def assemble(ts, parts):
    """the container encoding of the field byte strings `parts` (fixed fields: their bytes; variable: the raw window)"""
    fixed_len = [len(p) if not S.is_variable_size(ft) else 4 for ft, p in zip(ts, parts)]
    run, out, var = sum(fixed_len), [], []
    for ft, p in zip(ts, parts):
        if S.is_variable_size(ft):
            out.append(run.to_bytes(4, 'little'))
            var.append(p)
            run += len(p)
        else:
            out.append(p)
    return b''.join(out + var)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--out', required=True)
    a = ap.parse_args()
    from refparse import Ref
    from constants import ref_generic
    ref = Ref(a.cs)
    gen = ref_generic(a.cs)
    fork = json.load(open(os.path.join(a.repo, 'types/obj_groups.json')))
    gi = json.load(open(os.path.join(a.repo, 'types/generic_obj_index.json')))['generated']
    n, stats = 0, {}
    with open(a.out, 'w') as f:
        for name in NAMES:
            nm = name[4:] if name.startswith('Fulu') else name
            if name.startswith('Fulu'):
                t, src, info = ref.type_of(nm), 'fulu', fork[nm]
            else:
                t, src, info = gen[name][0], 'generic', gi[name]
            if t[0] != 'container':
                continue
            fts = [ft for _, ft in t[1]]
            rng = random.Random('invalid-bytes/%s' % name)
            variants = {'zero': [S.serialize(ft, S.zero_value(ft)) for ft in fts]}
            for r in range(2):
                variants['rand%d' % r] = [S.serialize(ft, S.random_value(ft, rng)) for ft in fts]
            seen = set()
            for j, ft in enumerate(fts):
                if not S.is_variable_size(ft):
                    continue
                for lab, raw in pool(ft):
                    for vname, parts in variants.items():
                        p = list(parts)
                        p[j] = raw
                        s = assemble(fts, p)
                        if s in seen:
                            continue
                        seen.add(s)
                        vd, why, root = verdict(t, s)
                        f.write(json.dumps({'id': 'win/%s#%d' % (name, n), 'type': nm if name.startswith('Fulu') else name, 'src': src,
                                            'group': info['group'], 'index': info['index'], 'label': 'win|%s.%s' % (t[1][j][0], lab),
                                            'hex': s.hex(), 'len': len(s), 'verdict': vd, 'reason': why, 'root': root}) + '\n')
                        n += 1
                        stats[vd] = stats.get(vd, 0) + 1
        # progressive lists: the element counts around the chunk boundaries of the subtree sizes 1, 4, 16, 64, ... (1, 5, 21, 85 chunks):
        # the chunk count is a function of the byte or bit count, and a chunk too many or too few moves the progressive tree
        for name, per in PROG:
            t, info = gen[name][0], gi[name]
            for c in (1, 2, 5, 6, 21, 22, 85):
                for d in (-1, 0, 1):
                    k = per * c + d
                    if k < 0:
                        continue
                    for pat_name, val in (('ones', 1), ('alt', None)):
                        et = ('bool',) if t[0] == 'proglist' and t[1] == ('bool',) else None
                        if t[0] == 'progbits':
                            v = [1] * k if val else [(i % 3 == 0) * 1 for i in range(k)]
                        else:
                            top = (1 << t[1][1]) - 1 if t[1][0] == 'uint' else 1
                            v = [top] * k if val else [(top if i % 3 == 0 else 1 if i % 3 == 1 else 0) for i in range(k)]
                            if et:
                                v = [bool(x) for x in v]
                        s = S.serialize(t, v)
                        vd, why, root = verdict(t, s)
                        f.write(json.dumps({'id': 'prog/%s#%d' % (name, n), 'type': name, 'src': 'generic', 'group': info['group'],
                                            'index': info['index'], 'label': 'prog|%dchunks%+d.%s' % (c, d, pat_name), 'hex': s.hex(),
                                            'len': len(s), 'verdict': vd, 'reason': why, 'root': root}) + '\n')
                        n += 1
                        stats[vd] = stats.get(vd, 0) + 1
    print('cases %d %s' % (n, json.dumps(stats)))


if __name__ == '__main__':
    main()
