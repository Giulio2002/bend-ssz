#!/usr/bin/env python3
"""Crash hunt round 6 (a)/(b): decode heap and decode time per input byte of hand-picked dense shapes, against the decode budget's bound
X_dcost(size) = ((size >> 3) + 1) * K + 524288 heap words (docs/CRASH_HUNT.md, round 6).

For every shape: the value is built at a count N (about --target bytes, the count picked by the shape), encoded (fast encoder below,
checked against the independent oracle at a small count), decoded once by the compiled object program of its group (build/obj-{g,x}<k>,
SSZ_MODE 1: one `_decode`, the object forced; stock 2.0.34 compiler, as the Prysm library), under /usr/bin/time inside a systemd scope with a
hard memory cap. The same input given to a fixed-size name of the same program (refused at once) is the baseline. decoded = peak - refused.
Also the same shape at N / 4 (slope). margin = bound bytes / decoded bytes (below 1: the decode exceeds its bound).

    python3 tools/crash_hunt/r6/amp.py --tree TREE --k K.json --out OUT.jsonl [--only SUBSTR] [--target BYTES] [-j 4]

Server only.
"""
import argparse
import concurrent.futures as cf
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..'))
sys.path.insert(0, ROOT)
from codegen.core import generic_form_schemas as GEN  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import independent_ssz_oracle as oracle  # noqa: E402


def types(tree):
    groups = json.load(open(os.path.join(tree, 'types/obj_groups.json')))
    gi = json.load(open(os.path.join(tree, 'types/generic_obj_index.json')))['generated']
    ty = dict(schema.load(os.path.join(tree, 'codegen/fulu.yaml')).items())
    out = {}
    for n, g in groups.items():
        out[n] = (ty[n], 'build/obj-g%d' % g['group'], g['index'])
    for n, (t, _raw) in GEN.inventory().items():
        if n in gi and n not in out:
            out[n] = (t, 'build/obj-x%d' % gi[n]['group'], gi[n]['index'])
    return out


def minval(t):
    k = t.kind
    if k == 'bool':
        return False
    if k == 'uint':
        return 0
    if k == 'bytes':
        return bytes(t.size)
    if k == 'bits':
        return [False] * t.size
    if k == 'bytelist':
        return b''
    if k in ('bitlist', 'pbits', 'list', 'plist'):
        return []
    if k == 'vector':
        return [minval(t.elem)] * t.size
    if k in ('container', 'pcontainer'):
        return {f: minval(ft) for f, ft in t.fields}
    if k == 'cunion':
        return {'selector': t.selectors[0], 'value': minval(t.fields[0][1])}
    raise SystemExit(k)


def bitsenc(v):
    out = bytearray(len(v) // 8 + 1)
    for i, bit in enumerate(v):
        if bit:
            out[i // 8] |= 1 << (i % 8)
    out[len(v) // 8] |= 1 << (len(v) % 8)
    return bytes(out)


def enc(t, v):
    k = t.kind
    if k in ('bitlist', 'pbits'):
        if isinstance(v, tuple):          # ('ones' | 'zeros', nbits): a long bit list without a Python list
            kind, n = v
            out = bytearray((b'\xff' if kind == 'ones' else b'\x00') * (n // 8) + b'\x00')
            if kind == 'ones':
                out[n // 8] = (1 << (n % 8)) - 1
            out[n // 8] |= 1 << (n % 8)
            return bytes(out)
        return bitsenc(v)
    if k == 'cunion':
        i = list(t.selectors).index(v['selector'])
        return bytes([v['selector']]) + enc(t.fields[i][1], v['value'])
    if k in ('vector', 'list', 'plist'):
        e = t.elem
        if e.fixed():
            return b''.join(enc(e, x) for x in v)
        parts = [enc(e, x) for x in v]
        off, head = 4 * len(parts), bytearray()
        for p in parts:
            head += off.to_bytes(4, 'little')
            off += len(p)
        return bytes(head) + b''.join(parts)
    if k in ('container', 'pcontainer'):
        fixed = sum(ft.header() for _, ft in t.fields)
        head, body, off = [], [], fixed
        for f, ft in t.fields:
            p = enc(ft, v[f])
            if ft.fixed():
                head.append(p)
            else:
                head.append(off.to_bytes(4, 'little'))
                body.append(p)
                off += len(p)
        return b''.join(head) + b''.join(body)
    return oracle.serialize(t, v)


def materialize(v):
    if isinstance(v, tuple):
        kind, n = v
        return [kind == 'ones'] * n
    if isinstance(v, dict):
        return {a: materialize(b) for a, b in v.items()}
    if isinstance(v, list):
        return [materialize(x) for x in v]
    return v


def field_t(t, path):
    for p in path:
        if t.kind in ('container', 'pcontainer'):
            t = dict(t.fields)[p]
        elif t.kind == 'cunion':
            t = t.fields[list(t.selectors).index(int(p))][1]
        else:
            t = t.elem
    return t


def with_field(t, base, path, val):
    """base value with the field at path (container field names; '0' for the first element of a list; union selector) replaced"""
    if not path:
        return val
    p, rest = path[0], path[1:]
    if t.kind in ('container', 'pcontainer'):
        ft = dict(t.fields)[p]
        return {**base, p: with_field(ft, base[p], rest, val)}
    if t.kind == 'cunion':
        i = list(t.selectors).index(int(p))
        ft = t.fields[i][1]
        cur = base['value'] if base['selector'] == int(p) else minval(ft)
        return {'selector': int(p), 'value': with_field(ft, cur, rest, val)}
    # a list / vector: element 0
    e = t.elem
    cur = base[0] if base else minval(e)
    return [with_field(e, cur, rest, val)] + list(base[1:])


def run(tree, prog, index, path, cap):
    env = {**os.environ, 'SSZ_MODE': '1', 'SSZ_INDEX': str(index), 'SSZ_OPS': '1', 'SSZ_INPUT': path}
    cmd = ['systemd-run', '--quiet', '--scope', '-p', 'MemoryMax=%s' % cap, '-p', 'MemorySwapMax=0', '--',
           'nice', '-n', '19', 'bash', '-c', 'ulimit -s 16384; exec /usr/bin/time -f "PEAK_KB=%M ELAPSED=%e" timeout 300 "$0" --threads 1 --gpu off',
           os.path.join(tree, prog)]
    r = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=900)
    m = re.search(r'PEAK_KB=(\d+) ELAPSED=([\d.]+)', r.stderr)
    return {'rc': r.returncode, 'accepted': 'ACCEPTED=1' in r.stdout, 'peak_kb': int(m.group(1)) if m else None,
            'sec': float(m.group(2)) if m else None, 'ms': int(re.search(r'MS=(\d+)', r.stdout).group(1)) if 'MS=' in r.stdout else None,
            'tail': (r.stdout + r.stderr)[-160:]}


def dcost_words(size, k):
    v = ((size >> 3) + 1) * k + 524288
    return min(v, 2 ** 32 - 1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True)
    ap.add_argument('--k', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--shapes', default=os.path.join(os.path.dirname(__file__), 'shapes.py'))
    ap.add_argument('--only', default='')
    ap.add_argument('--target', type=int, default=3 << 20)
    ap.add_argument('--cap', default='16G')
    ap.add_argument('-j', type=int, default=3)
    ap.add_argument('--no-slope', action='store_true')
    a = ap.parse_args()
    tree = os.path.abspath(a.tree)
    T = types(tree)
    K = json.load(open(a.k))['k']
    ns = {'minval': minval, 'with_field': with_field, 'field_t': field_t, 'T': T}
    exec(open(a.shapes).read(), ns)
    shapes = [s for s in ns['SHAPES'](a.target) if a.only in s[0] + ' ' + s[1]]
    refuse = {}
    for n, (t, prog, idx) in T.items():
        if t.fixed() and (prog not in refuse or t.fixed_size() < refuse[prog][1]):
            refuse[prog] = (idx, t.fixed_size())
    tmp = tempfile.mkdtemp(prefix='amp6-', dir='/dev/shm')

    def one(i, s):
        name, label, build, n = s
        t, prog, idx = T[name]
        small = materialize(build(3))
        try:
            ok = oracle.serialize(t, oracle.parse(t, enc(t, small))) == enc(t, small)
        except Exception as exc:  # noqa: BLE001
            ok = False
        if not ok:
            return {'name': name, 'shape': label, 'error': 'oracle refuses the shape'}
        data = enc(t, build(n))
        p = os.path.join(tmp, 'in%d.ssz' % i)
        open(p, 'wb').write(data)
        r = run(tree, prog, idx, p, a.cap)
        rr = run(tree, prog, refuse[prog][0], p, a.cap)
        row = {'name': name, 'shape': label, 'n': n, 'bytes': len(data), 'peak_kb': r['peak_kb'], 'refused_kb': rr['peak_kb'],
               'accepted': r['accepted'], 'rc': r['rc'], 'sec': r['sec'], 'ms': r['ms'], 'refused_sec': rr['sec']}
        if not r['accepted']:
            row['tail'] = r['tail']
        k = K.get(name, {}).get('k')
        row['K'] = k
        if r['peak_kb'] and rr['peak_kb']:
            dec = (r['peak_kb'] - rr['peak_kb']) * 1024
            row['decoded_bytes'] = dec
            row['ratio'] = round(dec / len(data), 2)
            if k is not None:
                b = dcost_words(len(data), k) * 8
                row['bound_bytes'] = b
                row['margin'] = round(b / max(1, dec), 3)
        if r['ms'] is not None:
            row['sec_per_mib'] = round(r['ms'] / 1000 / (len(data) / 2 ** 20), 3)
        if not a.no_slope and n >= 16:
            n4 = max(1, n // 4 + (1 if n % 2 else 0))
            d4 = enc(t, build(n4))
            open(p, 'wb').write(d4)
            r4 = run(tree, prog, idx, p, a.cap)
            if r4['peak_kb'] and r['peak_kb'] and len(d4) < len(data):
                row['slope'] = round((r['peak_kb'] - r4['peak_kb']) * 1024 / (len(data) - len(d4)), 2)
        os.unlink(p)
        return row

    with open(a.out, 'a') as fo, cf.ThreadPoolExecutor(a.j) as ex:
        futs = [ex.submit(one, i, s) for i, s in enumerate(shapes)]
        for f in cf.as_completed(futs):
            try:
                row = f.result()
            except Exception as exc:  # noqa: BLE001
                row = {'error': repr(exc)}
            fo.write(json.dumps(row) + '\n')
            fo.flush()
            print(row.get('name'), row.get('shape'), row.get('bytes'), 'ratio', row.get('ratio'), 'slope', row.get('slope'), 'K', row.get('K'),
                  'margin', row.get('margin'), 's/MiB', row.get('sec_per_mib'), 'ACC' if row.get('accepted') else 'REJ %s %s' % (row.get('rc'), row.get('error', '')), flush=True)
    os.rmdir(tmp)


if __name__ == '__main__':
    main()
