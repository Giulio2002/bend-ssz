"""Crash hunt round 5 (c): hostile decode of the 109 Fulu names through the round-5 chain drivers (SSZ_NOPS=0: plain `_decode`
with the size-vs-buffer window, then the checked encoding and the root). Server only.

    python3 tools/crash_hunt/r5/hostile_r5.py --bin build/ch5 --values 6 [--jobs 2] [--only A,B]

Per name: valid values (random / zero / max / full / short / empty), and for each encoding every OFFSET SLOT (found from the schema
with fuzz_objects.bounds' walk) rewritten to {0, 1, 3, 4, prev, prev-1, next, next+1, len-1, len, len+1, 2^31, NMAX-1, NMAX, NMAX+1,
2^32-4, 2^32-1}, every boundary cut, and the encoding with 1 and 4 trailing bytes. The oracle (codegen/core/independent_ssz_oracle)
decides legality; an accepted input must re-encode to itself with the oracle's root. A run must exit within 120 s; CRASH is any abort."""
import argparse, collections, json, os, pathlib, random, re, subprocess, sys, tempfile, time
from concurrent.futures import ThreadPoolExecutor
ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tests_generated'))
import fuzz_objects as F  # noqa: E402
NMAX = 4294967264

def offset_slots(t, v, base=0):
    """byte positions of every offset slot in serialize(t, v), with the slot's value"""
    k, out = t.kind, []
    if k in ('container', 'pcontainer'):
        pos = base; body = base + sum(ft.header() for _, ft in t.fields)
        for f, ft in t.fields:
            if ft.fixed():
                out += offset_slots(ft, v[f], pos)
            else:
                out.append(pos); out += offset_slots(ft, v[f], body); body += len(F.oracle.serialize(ft, v[f]))
            pos += ft.header()
    elif k in ('vector', 'list', 'plist'):
        e = t.elem
        if e.fixed():
            w = e.fixed_size()
            for i, x in enumerate(v):
                out += offset_slots(e, x, base + i * w)
        else:
            body = base + 4 * len(v)
            for i, x in enumerate(v):
                out.append(base + 4 * i); out += offset_slots(e, x, body); body += len(F.oracle.serialize(e, x))
    elif k == 'cunion':
        i = list(t.selectors).index(v['selector'])
        out += offset_slots(t.fields[i][1], v['value'], base + 1)
    return out

def muts(data, slots, rng):
    L = len(data)
    for p in slots:
        if p + 4 > L: continue
        cur = int.from_bytes(data[p:p + 4], 'little')
        for nv in {0, 1, 3, 4, cur - 1, cur + 1, cur + 4, L - 1, L, L + 1, 2 ** 31, NMAX - 1, NMAX, NMAX + 1, 2 ** 32 - 4, 2 ** 32 - 1}:
            nv &= 0xffffffff
            if nv != cur:
                yield 'off=%d@%d' % (nv, p), data[:p] + nv.to_bytes(4, 'little') + data[p + 4:]
    for p in sorted(set(slots) | {0, L // 2, L - 1}):
        if 0 <= p < L: yield 'cut@%d' % p, data[:p]
    yield 'trail1', data + b'\x01'
    yield 'trail4', data + b'\x00\x00\x00\x00'

def run(bindir, name, data, tmp):
    e = F.FUZZ_OPS[name]
    fd, inp = tempfile.mkstemp(dir=tmp); os.write(fd, data + bytes((-len(data)) % 4)); os.close(fd)
    out = inp + '.out'
    env = {**os.environ, 'SSZ_INDEX': str(e['index']), 'SSZ_SIZE': str(len(data)), 'SSZ_NOPS': '0', 'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}
    try:
        r = subprocess.run(['nice', '-n', '19', os.path.join(bindir, 'chain-f%d' % e['program']), '--threads', '1', '--gpu', 'off'], env=env,
                           capture_output=True, text=True, timeout=120)
        so, rc = r.stdout + r.stderr, r.returncode
    except subprocess.TimeoutExpired:
        so, rc = 'TIMEOUT', -9
    enc = open(out, 'rb').read() if os.path.exists(out) else None
    for p in (inp, out):
        if os.path.exists(p): os.unlink(p)
    m = re.search(r'ROOTWORDS=([\d,]+)', so)
    return so, rc, enc, (b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')) if m else None)

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--bin', required=True); ap.add_argument('--values', type=int, default=6)
    ap.add_argument('--jobs', type=int, default=2); ap.add_argument('--only', default=''); ap.add_argument('--seed', type=int, default=53)
    a = ap.parse_args()
    names = [n for n in F.FUZZ_OPS if n in F.TY and (not a.only or n in a.only.split(','))]
    tmp = tempfile.mkdtemp(prefix='h5-')
    cases = []
    for n in names:
        t = F.TY[n]
        for i in range(a.values):
            rng = random.Random('%d/%s/%d' % (a.seed, n, i))
            v = F.gen(t, rng, ['random', 'zero', 'max', 'full', 'short', 'empty'][i % 6])
            d = F.oracle.serialize(t, v)
            if len(d) > 300000: continue
            for lab, m in muts(d, offset_slots(t, v), rng):
                cases.append((n, lab, m))
    print('cases', len(cases), flush=True)
    def go(c):
        n, lab, m = c
        want_ok, want_root = F.reference(F.TY[n], m)
        so, rc, enc, root = run(a.bin, n, m, tmp)
        got = 'DECODED=1' in so
        if rc not in (0, 1) or ('DECODED' not in so):
            return 'CRASH', c, so[-200:]
        if got != want_ok:
            return ('WRONG_ACCEPT' if got else 'WRONG_REJECT'), c, so[-200:]
        if got and (enc != m or root != want_root):
            return 'WRONG_REENCODE', c, so[-200:]
        return 'OK', None, None
    tally, finds = collections.Counter(), []
    with ThreadPoolExecutor(a.jobs) as ex:
        for cls, c, so in ex.map(go, cases):
            tally[cls] += 1
            if c and len(finds) < 100:
                finds.append({'class': cls, 'name': c[0], 'mut': c[1], 'hex': c[2].hex()[:4000], 'out': so})
    for f in finds: print(json.dumps(f))
    print('FINAL', json.dumps(tally))

if __name__ == '__main__':
    main()
