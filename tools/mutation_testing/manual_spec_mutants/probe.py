#!/usr/bin/env python3
"""probe.py --tree TREE --work WORK --cases cases.jsonl --out probe.json PATCH...   (server)
Verdict B3 for faults that survived the corpus: a differential probe of the mutant against the unmutated program of the same group.
Inputs: up to 40 accepted corpus cases of the representative types (at most 3000 bytes) and, around each, every offset-looking 4-byte slot
rewritten to value-4 .. value+4, 0, len, len+1, the truncations by 1 to 4 bytes, appended bytes, and single-byte flips of the first 48 bytes.
A difference in accept/reject, re-encoding or root between the mutant and the unmutated program is a distinguishing input: the corpus is missing it.
No difference means: equivalent, or only reachable by a value the probe did not build."""
import argparse, concurrent.futures as cf, hashlib, json, os, shutil, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import corpus
from runner import header

ap = argparse.ArgumentParser()
ap.add_argument('--tree', required=True); ap.add_argument('--work', required=True); ap.add_argument('--cases', required=True); ap.add_argument('--out', required=True)
ap.add_argument('--bend', default='/srv/ssz-optimization/toolchain-2.0.34/bin/bend'); ap.add_argument('--jobs', type=int, default=3)
ap.add_argument('patches', nargs='+')
a = ap.parse_args()
tree, work = os.path.abspath(a.tree), os.path.abspath(a.work)
corpus.CASE_TIMEOUT = 30
res = json.load(open(a.out)) if os.path.exists(a.out) else []
done = {r['id'] for r in res}
base_dirs, cache = {}, {}
import threading
BL = threading.Lock()


def base(p, k):
    with BL:
        if (p, k) not in base_dirs:
            base_dirs[(p, k)] = corpus.build(tree, work, 'base_%s%d' % (p, k), None, [(p, k)], a.bend)
    return os.path.join(base_dirs[(p, k)], 'build', 'obj-%s%d' % (p, k))


def inputs(c):
    b = bytes.fromhex(c['hex'])
    out = [('orig', b)]
    n = len(b)
    for p in range(0, min(n - 3, 400)):
        x = int.from_bytes(b[p:p + 4], 'little')
        if 4 <= x <= n + 8:
            for v in set([x + d for d in range(-4, 5)] + [0, n, n + 1, 2 ** 32 - 1]):
                if v != x and 0 <= v < 2 ** 32:
                    out.append(('u32@%d=%d' % (p, v), b[:p] + v.to_bytes(4, 'little') + b[p + 4:]))
    for t in range(1, 5):
        if n > t:
            out.append(('trunc%d' % t, b[:-t]))
    out += [('app00', b + b'\x00'), ('app01', b + b'\x01'), ('app4', b + b'\x00\x00\x00\x00')]
    slots = [p for p in range(0, min(n - 3, 400)) if 4 <= int.from_bytes(b[p:p + 4], 'little') <= n + 8]
    for i in range(len(slots) - 1):
        p, q = slots[i], slots[i + 1]
        if q - p >= 4:
            vp, vq = int.from_bytes(b[p:p + 4], 'little'), int.from_bytes(b[q:q + 4], 'little')
            bb = bytearray(b); bb[p:p + 4] = vq.to_bytes(4, 'little'); bb[q:q + 4] = vp.to_bytes(4, 'little')
            out.append(('swap@%d,%d' % (p, q), bytes(bb)))
            for dlt in (1, 2, 4):
                bb = bytearray(b); bb[p:p + 4] = ((vq + dlt) % 2 ** 32).to_bytes(4, 'little')
                out.append(('u32@%d=next+%d' % (p, dlt), bytes(bb)))
    for p in range(min(n, 48)):
        for v in (0x00, 0x01, 0x02, 0x7f, 0x80, 0x81, 0xff):
            if b[p] != v:
                out.append(('byte@%d=%02x' % (p, v), b[:p] + bytes([v]) + b[p + 1:]))
    return out


for pp in a.patches:
    pp = os.path.abspath(pp); h = header(pp); h['path'] = pp
    if h['id'] in done:
        continue
    r = {'id': h['id']}
    try:
        loc = [corpus.locate(tree, t) for t in h['type'].split(',')]
        groups = sorted({(p, k) for _, p, k in loc})
        d = corpus.build(tree, work, 'pr_' + h['id'].replace('/', '_'), h, groups, a.bend)
        wanted = {n for n, _, _ in loc}
        cs = [c for c in corpus.corpus_cases(a.cases, wanted) if c['verdict'] == 'accept' and len(c['hex']) <= 6000]
        step = max(1, len(cs) // 40)
        cs = cs[::step][:40]
        tmp = tempfile.mkdtemp(dir=work)
        jobs = []
        for c in cs:
            for lab, data in inputs(c):
                jobs.append((c, lab, data))
        def run(j):
            c, lab, data = j
            pk = ('x' if c['src'] == 'generic' else 'g', c['group'])
            key = (pk, c['index'], hashlib.sha1(data).hexdigest())
            if key not in cache:
                cache[key] = corpus.run_prog(base(*pk), c['index'], data, tmp)
            m = corpus.run_prog(os.path.join(d, 'build', 'obj-%s%d' % pk), c['index'], data, tmp)
            return None if m == cache[key] else (c['label'], lab, str(cache[key][0]), str(m[0]))
        diffs = []
        with cf.ThreadPoolExecutor(a.jobs) as ex:
            for x in ex.map(run, jobs):
                if x:
                    diffs.append(x)
        r.update(inputs=len(jobs), bases=len(cs), diffs=len(diffs), examples=['%s | %s | base %s mutant %s' % x for x in diffs[:3]],
                 B3='DISTINGUISHED' if diffs else 'NO-DIFFERENCE')
        shutil.rmtree(d, ignore_errors=True); shutil.rmtree(tmp, ignore_errors=True)
    except Exception as e:
        r.update(B3='ERROR', msg=str(e)[:300])
    res.append(r)
    print(r['id'], r.get('B3'), r.get('inputs'), r.get('diffs'), r.get('examples', [''])[:1], flush=True)
    json.dump(res, open(a.out, 'w'), indent=1)
