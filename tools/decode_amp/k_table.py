#!/usr/bin/env python3
"""The decode cost table (codegen/decode_cost.json) from a measurement (tools/decode_amp/measure.py): per name the heap bytes per input byte
K that `X_decode_checked_budget` charges (`O.dcost(size, K)` heap words of 8 bytes: ((size >> 3) + 1) * K + 524288, the constant 4 MiB).

K = ceil(1.25 * D + 1), D the worst density measured over the shapes of the name: the ratio (the decode's
peak above the same program refusing the same input, per input byte) of an input of at least 128 KiB (its constants count against it, so it is above the density) and the slope between a quarter of the count and the count when the
two inputs differ by at least 1 MiB (the slope also counts the input buffer, so it is above the decode's own cost). A name whose largest
encoding at 48 heap bytes per byte fits the constant has K = 0; one that does not and has no such measurement gets K = 48. A name's
K is at least that of every name nested in it.

    python3 tools/decode_amp/k_table.py MEASURE.json [--out codegen/decode_cost.json]
"""
import json
import math
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/decode_amp'))
import measure as M  # noqa: E402

CONST_BYTES = 524288 * 8
FALLBACK = 48


def mx(t):
    k = t.kind
    if t.fixed():
        return t.fixed_size()
    if k == 'bytelist':
        return t.size
    if k == 'bitlist':
        return t.size // 8 + 1
    if k == 'pbits':
        return 2 ** 32
    if k == 'list':
        e = t.elem
        return t.size * (mx(e) + (0 if e.fixed() else 4))
    if k == 'plist':
        return 2 ** 64
    if k == 'vector':
        return t.size * (mx(t.elem) + (0 if t.elem.fixed() else 4))
    if k in ('container', 'pcontainer'):
        return sum((ft.fixed_size() if ft.fixed() else 4 + mx(ft)) for _, ft in t.fields)
    if k == 'cunion':
        return 1 + max(mx(ft) for _, ft in t.fields)
    raise SystemExit(k)


def main():
    meas = json.load(open(sys.argv[1]))
    out = sys.argv[sys.argv.index('--out') + 1] if '--out' in sys.argv else str(ROOT / 'codegen/decode_cost.json')
    T = M.types(str(ROOT))
    tab = {}
    for n in sorted(T):
        t = T[n][0]
        dens = []
        for r in meas[n]['rows']:
            if 'ratio' in r and r['bytes'] >= (128 << 10):
                dens.append((r['ratio'], r['path'], r['bytes'], 'ratio'))
            if 'slope' in r and r['bytes'] - r.get('small_bytes', r['bytes']) >= (1 << 20):
                dens.append((r['slope'], r['path'], r['bytes'], 'slope'))
        m = mx(t)
        if m * FALLBACK <= CONST_BYTES:
            tab[n] = {'k': 0, 'max_input': m}
        elif dens:
            d, p, b, how = max(dens)
            tab[n] = {'k': math.ceil(1.25 * max(0.0, d) + 1), 'density': d, 'by': how, 'shape': p, 'input': b}
        else:
            tab[n] = {'k': FALLBACK, 'max_input': m, 'note': 'no measurement of at least 1 MiB'}
    # a name holds at least what any name nested in it charges (a block holds its body and its payload)
    byty = {}
    for n in T:
        nm = getattr(T[n][0], 'name', None)
        if nm:
            byty.setdefault(nm, []).append(n)

    def inner(t, acc):
        for _, ft in (t.fields or ()):
            for m in byty.get(getattr(ft, 'name', None), []):
                acc.add(m)
            inner(ft, acc)
        if t.elem is not None:
            for m in byty.get(getattr(t.elem, 'name', None), []):
                acc.add(m)
            inner(t.elem, acc)
        return acc
    for _ in range(3):
        for n in T:
            for m in inner(T[n][0], set()):
                if tab[m]['k'] > tab[n]['k']:
                    tab[n]['k'] = tab[m]['k']
                    tab[n]['inherits'] = m
    pathlib.Path(out).write_text(json.dumps({'unit': 'heap bytes per input byte; O.dcost(size, k) = ((size >> 3) + 1) * k + 524288 words of 8 bytes',
                                             'source': 'tools/decode_amp/measure.py + k_table.py, docs/DECODE_AMPLIFICATION.md', 'k': tab}, indent=1) + '\n')


if __name__ == '__main__':
    main()
