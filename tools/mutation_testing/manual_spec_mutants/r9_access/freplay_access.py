#!/usr/bin/env python3
"""freplay_access.py --runner tools/mutation_testing/manual_spec_mutants --tree TREE --work W --out OUT PATCH...: replay round-9 patches on fixer G's tree (agent/access-laws).
Roots per patch: the element API modules (proofs/slop/validity/*_api_*) and the generic field laws (proofs/obj/gfields_*) whose import cone holds the patched file, then up to K other
proofs/slop roots whose cone holds it and whose text names one of the patch's symbols (cheapest by size). First kill stops.
At most 8 jobs, nice 19 (tools/check.sh pinned settings, 300 s)."""
import argparse, concurrent.futures as cf, glob, json, os, re, shutil, sys
sys.path.insert(0, sys.argv[sys.argv.index('--runner') + 1])
from runner import header, cone, private_tree, check   # noqa: E402


def mentions(tree, root, syms):
    t = open(os.path.join(tree, root)).read()
    return any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(s) + r'(?![A-Za-z0-9_])', t) for s in syms)


def one(a, cones, path):
    h = header(path); h['path'] = os.path.abspath(path)
    res = {'id': h['id'], 'file': h['file'], 'checks': []}
    try:
        f = h['file']
        mine = [r for r, c in cones.items() if ('_api_' in r or '/gfields_' in r) and f in c]
        syms = [s.strip() for s in h.get('sym', '').split(',') if s.strip()]
        other = [r for r, c in cones.items() if r not in mine and f in c and mentions(a.tree, r, syms)]
        other.sort(key=lambda r: os.path.getsize(os.path.join(a.tree, r)))
        cands = sorted(mine) + other[:a.k]
        if not cands:
            res['G'] = 'NOROOT'; return res
        files = set()
        for r in cands:
            files |= cones[r]
        d = private_tree(a.tree, a.work, h['id'].replace('/', '_'), files, h)
        v = 'SURVIVED'
        for r in cands:
            c = check(a.tree, d, r, 300)
            if c['verdict'] == 'STACK':
                c = check(a.tree, d, r, 300)
                c['verdict'] = 'CRASH' if c['verdict'] == 'STACK' else c['verdict']
            c['root'] = r
            res['checks'].append(c)
            if c['verdict'] == 'KILLED':
                v = 'KILLED'; break
            if c['verdict'] in ('TIMEOUT', 'CRASH', 'ERROR') and v == 'SURVIVED':
                v = 'UNJUDGED' if c['verdict'] != 'ERROR' else 'ERROR'
        res['G'] = v
        shutil.rmtree(d, ignore_errors=True)
    except Exception as e:
        res['G'] = 'ERROR'; res['msg'] = str(e)[:300]
    return res


def main():
    ap = argparse.ArgumentParser()
    for k in ('--tree', '--work', '--out', '--runner'):
        ap.add_argument(k, required=True)
    ap.add_argument('--jobs', type=int, default=8)
    ap.add_argument('--k', type=int, default=3)
    ap.add_argument('patches', nargs='+')
    a = ap.parse_args()
    a.tree = os.path.abspath(a.tree)
    os.makedirs(a.work, exist_ok=True)
    roots = [os.path.relpath(p, a.tree) for p in glob.glob(os.path.join(a.tree, 'proofs/slop/**/*.bend'), recursive=True)]
    roots += [os.path.relpath(p, a.tree) for p in glob.glob(os.path.join(a.tree, 'proofs/obj/gfields_*.bend'))]
    cones = {r: cone(a.tree, r) for r in roots}
    out = []
    with cf.ThreadPoolExecutor(min(a.jobs, 8)) as ex:
        for r in ex.map(lambda p: one(a, cones, p), a.patches):
            out.append(r)
            print(r['id'], r['G'], [(c['root'].split('/')[-1], c['laws'][:2]) for c in r['checks'] if c['verdict'] == 'KILLED'], r.get('msg', '')[:120], flush=True)
            json.dump(out, open(a.out, 'w'), indent=1)


if __name__ == '__main__':
    main()
