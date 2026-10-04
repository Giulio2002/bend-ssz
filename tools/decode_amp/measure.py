#!/usr/bin/env python3
"""Decode amplification: the peak memory of `_decode` per input byte, for every one of the 240 names (docs/DECODE_AMPLIFICATION.md).

Per name, the candidate worst shapes are: every list-like node (list, progressive list, byte list, bit list, progressive bit list) reached from the
root through containers, unions (each option) and one element of an enclosing list, filled with N copies of the smallest value of its element
(an empty inner list, a 1-byte empty bit list, a zero fixed element), everything else the smallest value. N fills about --target bytes, capped at
the list's limit. Each candidate is checked against the independent oracle at a small N, then decoded once by the compiled object program of
its group (build/obj-{g,x}<k>, SSZ_MODE 1) under /usr/bin/time; the same input decoded as a fixed-size name of the same program (refused at once)
gives the cost of the program and the input buffer. Ratio = (peak - refused peak) / input bytes (the decoded object and the decode's
transients); total ratio = peak / input bytes.

    python3 tools/decode_amp/measure.py --tree TREE --out RESULT.json [--target BYTES] [--names a,b] [--max-cands K]

Server only, one program at a time.
"""
import argparse
import array
import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from codegen.core import generic_form_schemas as GEN  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import independent_ssz_oracle as oracle  # noqa: E402

LISTS = ('list', 'plist', 'bytelist', 'bitlist', 'pbits')
PROG_LIMIT = 2 ** 32


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


class Rep:
    """N copies of one element value (a list value)."""
    def __init__(self, x, n):
        self.x, self.n = x, n


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
    if k in ('bytelist',):
        return b''
    if k in ('bitlist', 'pbits', 'list', 'plist'):
        return []
    if k == 'vector':
        return [minval(t.elem)] * t.size
    if k in ('container', 'pcontainer'):
        return {f: minval(ft) for f, ft in t.fields}
    if k == 'cunion':
        best = min(range(len(t.fields)), key=lambda i: len(enc(t.fields[i][1], minval(t.fields[i][1]))))
        return {'selector': t.selectors[best], 'value': minval(t.fields[best][1])}
    raise SystemExit(k)


def enc(t, v):
    """oracle.serialize, with Rep lists encoded without materialising them"""
    k = t.kind
    if isinstance(v, Rep):
        if k == 'bytelist':
            return bytes(v.n)
        if k in ('bitlist', 'pbits'):
            out = bytearray(v.n // 8 + 1)
            out[v.n // 8] |= 1 << (v.n % 8)
            return bytes(out)
        e = t.elem
        ex = enc(e, v.x)
        if e.fixed():
            return ex * v.n
        offs = array.array('I', range(4 * v.n, 4 * v.n + len(ex) * v.n, len(ex)) if ex else [4 * v.n] * v.n)
        return offs.tobytes() + ex * v.n
    if k == 'cunion':
        i = list(t.selectors).index(v['selector'])
        return bytes([v['selector']]) + enc(t.fields[i][1], v['value'])
    if k in ('vector', 'list', 'plist'):
        e = t.elem
        if e.fixed():
            return b''.join(enc(e, x) for x in v)
        parts = [enc(e, x) for x in v]
        off, head = 4 * len(parts), b''
        for p in parts:
            head += off.to_bytes(4, 'little')
            off += len(p)
        return head + b''.join(parts)
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


def realize(v):
    """a Rep-free value (small N) for the oracle"""
    if isinstance(v, Rep):
        return [realize(v.x) for _ in range(v.n)] if not isinstance(v.x, bool) else [v.x] * v.n
    if isinstance(v, dict):
        return {k: realize(x) for k, x in v.items()}
    if isinstance(v, list):
        return [realize(x) for x in v]
    return v


def small_variants(e):
    """non-empty small elements of a variable-size element type: their storage is rounded up (a byte list of 1 byte holds a chunk and its
    slack), so a short element can cost more heap per input byte than an empty one"""
    k = e.kind
    if k == 'bytelist':
        return [('%dB' % l, bytes(l)) for l in (1, 2, 3, 4, 5, 31, 32, 33) if l <= e.size]
    if k in ('bitlist', 'pbits'):
        return [('%db' % b, [False] * b) for b in (1, 7, 8, 9, 31, 32, 33) if k == 'pbits' or b <= e.size]
    if k in ('list', 'plist') and e.elem.fixed():
        fs = e.elem.fixed_size()
        return [('%dx' % m, [minval(e.elem)] * m) for m in sorted({1, 2, max(1, 32 // fs), max(1, 32 // fs) + 1}) if k == 'plist' or m <= e.size]
    if k in ('list', 'plist'):
        return [('1x', [minval(e.elem)])]
    if k in ('container', 'pcontainer'):
        out = []
        for f, ft in e.fields:
            if not ft.fixed():
                for tag, x in small_variants(ft):
                    out.append(('%s=%s' % (f, tag), {**minval(e), f: x}))
        return out
    return []


def cands(t, path=()):
    """(path label, limit, build(N) -> value) for every fillable list node"""
    k = t.kind
    if k in LISTS:
        lim = t.size if k in ('list', 'bytelist', 'bitlist') else PROG_LIMIT
        if k in ('bytelist',):
            yield (path + ('bytes',), lim, lambda n: Rep(0, n))
        elif k in ('bitlist', 'pbits'):
            yield (path + ('bits',), lim, lambda n: Rep(False, n))
        else:
            e = t.elem
            yield (path + ('[]',), lim, lambda n, e=e: Rep(minval(e), n))
            for tag, x in small_variants(e):
                yield (path + ('[%s]' % tag,), lim, lambda n, x=x: Rep(x, n))
            for p, l2, b in cands(e, path + ('[0]',)):
                yield (p, l2, lambda n, b=b: [b(n)])
        return
    if k == 'vector':
        e = t.elem
        for p, l2, b in cands(e, path + ('[0]',)):
            yield (p, l2, lambda n, b=b, e=e, s=t.size: [b(n)] + [minval(e)] * (s - 1))
        return
    if k in ('container', 'pcontainer'):
        for f, ft in t.fields:
            for p, l2, b in cands(ft, path + (f,)):
                yield (p, l2, lambda n, b=b, f=f, t=t: {**{g: minval(gt) for g, gt in t.fields}, f: b(n)})
        return
    if k == 'cunion':
        for i, (f, ft) in enumerate(t.fields):
            for p, l2, b in cands(ft, path + ('<%d>' % t.selectors[i],)):
                yield (p, l2, lambda n, b=b, s=t.selectors[i]: {'selector': s, 'value': b(n)})


def size_at(t, b, n):
    return len(enc(t, b(n)))


def pick_n(t, b, lim, target, kind):
    """the count closest below the target size that is worst for the storage rounding: a power of two plus one element (the array of a
    list then has twice the slots it needs), for bytes a power of two (the storage holds 8 words more, so its array doubles), for bits
    8 times a power of two (2^k + 1 bytes)"""
    s0 = size_at(t, b, 0)
    k = min(lim, 1024)
    per = max(1e-9, (size_at(t, b, k) - s0) / k)
    n = max(1, min(lim, int((target - s0) / per)))
    if n < 4:
        return n
    p = 1 << (n.bit_length() - 1)
    if kind == 'bytes':
        c = p
    elif kind == 'bits':
        c = p if p < 8 else p
    else:
        c = p + 1 if p + 1 <= n else p // 2 + 1
    return max(1, min(lim, c))


def run(tree, prog, index, path):
    env = {**os.environ, 'SSZ_MODE': '1', 'SSZ_INDEX': str(index), 'SSZ_OPS': '1', 'SSZ_INPUT': path}
    r = subprocess.run(['/usr/bin/time', '-f', 'PEAK_KB=%M ELAPSED=%e', os.path.join(tree, prog), '--threads', '1', '--gpu', 'off'],
                       env=env, capture_output=True, text=True, timeout=1800)
    m = re.search(r'PEAK_KB=(\d+) ELAPSED=([\d.]+)', r.stderr)
    return {'rc': r.returncode, 'accepted': 'ACCEPTED=1' in r.stdout, 'peak_kb': int(m.group(1)) if m else None, 'sec': float(m.group(2)) if m else None,
            'tail': (r.stdout + r.stderr)[-200:]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--target', type=int, default=32 << 20)
    ap.add_argument('--names', default='')
    ap.add_argument('--max-cands', type=int, default=64)
    a = ap.parse_args()
    tree = os.path.abspath(a.tree)
    T = types(tree)
    names = [n for n in sorted(T) if not a.names or n in a.names.split(',')]
    # a refusing name per program: the fixed-size name with the smallest size (any input of another size is refused at once)
    refuse = {}
    for n, (t, prog, idx) in T.items():
        if t.fixed() and (prog not in refuse or t.fixed_size() < refuse[prog][1]):
            refuse[prog] = (idx, t.fixed_size())
    tmp = tempfile.mkdtemp(prefix='damp-', dir='/dev/shm')
    inp = os.path.join(tmp, 'in.ssz')
    res = json.load(open(a.out)) if os.path.exists(a.out) else {}
    for n in names:
        t, prog, idx = T[n]
        rows = []
        cs = list(cands(t))[:a.max_cands]
        if not cs:
            data = enc(t, minval(t))
            cs_rows = [((), 0, data, None)]
        else:
            cs_rows = []
            for p, lim, b in cs:
                small = realize(b(min(3, lim)))
                try:
                    ok = oracle.serialize(t, oracle.parse(t, enc(t, b(min(3, lim))))) == enc(t, b(min(3, lim)))
                except Exception as exc:
                    ok = False
                if not ok:
                    rows.append({'path': '.'.join(p), 'error': 'oracle refuses the shape'})
                    continue
                nn = pick_n(t, b, lim, a.target, p[-1])
                n4 = pick_n(t, b, lim, max(1, size_at(t, b, nn) // 4), p[-1]) if nn >= 16 else None
                cs_rows.append((p, nn, enc(t, b(nn)), enc(t, b(n4)) if n4 and n4 < nn else None))
        for p, nn, data, small in cs_rows:
            open(inp, 'wb').write(data)
            r = run(tree, prog, idx, inp)
            ri = refuse.get(prog)
            rr = run(tree, prog, ri[0], inp) if ri and len(data) != ri[1] else None
            row = {'path': '.'.join(p) or '(fixed)', 'n': nn, 'bytes': len(data), **r, 'refused_peak_kb': rr['peak_kb'] if rr else None}
            if r['peak_kb'] and rr and rr['peak_kb']:
                row['ratio'] = round((r['peak_kb'] - rr['peak_kb']) * 1024 / max(1, len(data)), 2)
                row['total_ratio'] = round(r['peak_kb'] * 1024 / max(1, len(data)), 2)
            if small is not None and len(small) < len(data):
                # the slope between a quarter of the count and the count: the cost of one more input byte, the constants cancel
                open(inp, 'wb').write(small)
                r2 = run(tree, prog, idx, inp)
                if r2['peak_kb'] and r['peak_kb']:
                    row['small_bytes'] = len(small)
                    row['small_peak_kb'] = r2['peak_kb']
                    row['slope'] = round((r['peak_kb'] - r2['peak_kb']) * 1024 / (len(data) - len(small)), 2)
            rows.append(row)
            print(n, row.get('path'), row.get('bytes'), row.get('peak_kb'), row.get('refused_peak_kb'), row.get('ratio'), row.get('slope'), 'ACC' if row.get('accepted') else 'REJ rc=%s' % row.get('rc'), flush=True)
        res[n] = {'kind': t.kind, 'prog': prog, 'index': idx, 'rows': rows}
        json.dump(res, open(a.out, 'w'), indent=1)
    os.unlink(inp) if os.path.exists(inp) else None
    os.rmdir(tmp)


if __name__ == '__main__':
    main()
