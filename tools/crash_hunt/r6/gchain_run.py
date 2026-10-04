"""Crash hunt round 6 (d): chains on the 131 GENERIC names (drivers from tools/crash_hunt/r6/gen_generic_fuzz.py, table types/generic_fuzz_ops.json
of the scratch tree), from round 5 (b): long in-process setter/append chains on the 109 Fulu names, against the oracle mirror of
tests_generated/fuzz_objects.py (same op table, same seed rule). Server only.

    python3 tools/crash_hunt/r5/chain_run.py --bin DIR --chains N --len L [--seed S] [--only A,B] [--jobs 4]

Per chain: a start value (random / zero / short / full / max), L operations (half of them appends when the name has
any, so small lists run to the limit and one past: the past-limit append must be refused), all applied in ONE process
(build DIR/chain-f<k>), then FLAGS (acceptance of every step), the checked encoding and the root are compared with the
mirror. Writes a JSON summary to stdout (last line) and every mismatch with its reproducer."""
import argparse, json, os, pathlib, random, re, subprocess, sys, tempfile, time, collections
from concurrent.futures import ThreadPoolExecutor
ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tests_generated'))
import fuzz_objects as F  # noqa: E402  (chdirs to ROOT)
F.FUZZ_OPS = json.loads((ROOT / 'types/generic_fuzz_ops.json').read_text())
_seed_value, _elem_seed = F.seed_value, F.elem_seed


def seed_value(t, x):
    if t.kind == 'pcontainer':
        return {f: seed_value(ft, (x + 1 + i) % (1 << 32)) for i, (f, ft) in enumerate(t.fields)}
    if t.kind == 'container':
        return {f: seed_value(ft, (x + 1 + i) % (1 << 32)) for i, (f, ft) in enumerate(t.fields)}
    return _seed_value(t, x)


def elem_seed(ct, seed):
    if ct.kind == 'pbits':
        return (seed & 1) == 1
    if ct.kind in ('bytes', 'bytelist', 'bits', 'bitlist'):
        return _elem_seed(ct, seed)
    return seed_value(ct.elem, seed)


F.seed_value, F.elem_seed = seed_value, elem_seed

def plan(name, rng, L, only_app=None):
    t = F.TY[name]; ops = F.FUZZ_OPS[name]['ops']
    mode = rng.choice(['random', 'zero', 'short', 'full', 'max', 'empty']) if only_app is None else 'empty'
    value = F.gen(t, rng, mode)
    start = F.oracle.serialize(t, value)
    apps = [i for i, o in enumerate(ops) if o['kind'] == 'append']
    steps, h, v = [], 0, value
    for _ in range(L):
        sel = only_app if only_app is not None else (rng.choice(apps) if apps and rng.random() < 0.5 else rng.randrange(len(ops)))
        op = ops[sel]
        ct = dict(t.fields)[op['field']] if op['field'] is not None else t
        tgt = v[op['field']] if op['field'] is not None else v
        n = len(tgt) if isinstance(tgt, (list, bytes, bytearray)) else 0
        idx = rng.choice([0, 1, rng.randrange(64), 4294967295, max(0, n - 1), n, n + 1])
        seed = rng.getrandbits(32)
        v, ok = F.apply_op(t, v, op, idx, seed)
        h = (h * 31 + (1 if ok else 0)) & 0xffffffff
        steps.append((sel, idx, seed))
    return start, steps, v, h, mode

def run_one(bindir, name, start, steps, tmp):
    e = F.FUZZ_OPS[name]
    pad = (-len(start)) % 4
    data = start + bytes(pad) + b''.join(x.to_bytes(4, 'little') for s in steps for x in s)
    fd, inp = tempfile.mkstemp(dir=tmp); os.write(fd, data); os.close(fd)
    out = inp + '.out'
    env = {**os.environ, 'SSZ_INDEX': str(e['index']), 'SSZ_SIZE': str(len(start)), 'SSZ_NOPS': str(len(steps)),
           'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}
    t0 = time.time()
    try:
        r = subprocess.run(['nice', '-n', '19', os.path.join(bindir, 'gchain-f%d' % e['program']), '--threads', '1', '--gpu', 'off'],
                           env=env, capture_output=True, text=True, timeout=120)
        so, rc = r.stdout, r.returncode
    except subprocess.TimeoutExpired:
        so, rc = 'TIMEOUT', -9
    dt = time.time() - t0
    enc = open(out, 'rb').read() if os.path.exists(out) else None
    for p in (inp, out):
        if os.path.exists(p): os.unlink(p)
    m = re.search(r'ROOTWORDS=([\d,]+)', so); fl = re.search(r'FLAGS=(\d+)', so)
    root = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')) if m else None
    return so, rc, enc, root, int(fl.group(1)) if fl else None, dt, data

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--bin', required=True); ap.add_argument('--chains', type=int, default=4); ap.add_argument('--len', type=int, default=40)
    ap.add_argument('--seed', type=int, default=5); ap.add_argument('--only', default=''); ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--programs', default='')
    ap.add_argument('--to-limit', type=int, default=0, help='instead of random chains: per append op, limit + 2 appends from the empty value (limits up to this)')
    a = ap.parse_args()
    names = [n for n in F.FUZZ_OPS if F.FUZZ_OPS[n]['ops']]
    if a.only: names = [n for n in names if n in a.only.split(',')]
    if a.programs: names = [n for n in names if str(F.FUZZ_OPS[n]['program']) in a.programs.split(',')]
    names = [n for n in names if os.path.exists(os.path.join(a.bin, 'gchain-f%d' % F.FUZZ_OPS[n]['program']))]
    tmp = tempfile.mkdtemp(prefix='ch5-')
    jobs = []
    for n in names:
        if a.to_limit:
            t = F.TY[n]
            for sel, op in enumerate(F.FUZZ_OPS[n]['ops']):
                if op['kind'] != 'append': continue
                ct = dict(t.fields)[op['field']] if op['field'] is not None else t
                if ct.size + 2 > a.to_limit: continue
                rng = random.Random('%d/%s/app%d' % (a.seed, n, sel))
                jobs.append((n, 'app%d' % sel) + plan(n, rng, ct.size + 2, sel))
            continue
        for c in range(a.chains):
            rng = random.Random('%d/%s/%d' % (a.seed, n, c))
            jobs.append((n, c) + plan(n, rng, a.len))
    def go(j):
        n, c, start, steps, want_v, want_h, mode = j
        so, rc, enc, root, h, dt, data = run_one(a.bin, n, start, steps, tmp)
        t = F.TY[n]
        wb, wr = F.oracle.serialize(t, want_v), F.oracle.root(t, want_v)
        bad = []
        if 'DECODED=1' not in so: bad.append('start not decoded')
        if rc != 0: bad.append('rc=%d' % rc)
        if h != want_h: bad.append('flags differ')
        if enc != wb: bad.append('bytes differ (len %s vs %d)' % (None if enc is None else len(enc), len(wb)))
        if root != wr: bad.append('root differs')
        return {'name': n, 'chain': c, 'mode': mode, 'steps': len(steps), 'sec': round(dt, 2), 'bad': bad,
                'repro_hex': data.hex()[:20000] if bad else None, 'stdout': so[-300:] if bad else None}
    with ThreadPoolExecutor(a.jobs) as ex:
        res = list(ex.map(go, jobs))
    tally = collections.Counter('ok' if not r['bad'] else 'bad' for r in res)
    for r in res:
        if r['bad']: print(json.dumps(r))
    print(json.dumps({'names': len(names), 'runs': len(res), 'tally': tally, 'max_sec': max([r['sec'] for r in res] or [0])}))

if __name__ == '__main__':
    main()
