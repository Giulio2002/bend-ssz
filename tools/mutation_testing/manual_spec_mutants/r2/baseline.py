#!/usr/bin/env python3
"""baseline.py --tree T --out baseline.json --res res.json[,res2.json...]: run every root that killed a round-2 fault on the UNMUTATED
tree. A kill only counts if its root checks there (ALL PROOFS CHECK); a root that already fails or times out unmutated is listed."""
import argparse, concurrent.futures as cf, json, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from runner import check   # noqa: E402
ap = argparse.ArgumentParser()
ap.add_argument('--tree', required=True); ap.add_argument('--out', required=True); ap.add_argument('--res', required=True)
ap.add_argument('--jobs', type=int, default=4)
a = ap.parse_args()
tree = os.path.abspath(a.tree)
roots = set()
for f in a.res.split(','):
    for r in json.load(open(f)):
        for c in r.get('checks', []):
            if c.get('verdict') == 'KILLED':
                roots.add(c['root'])
done = json.load(open(a.out)) if os.path.exists(a.out) else {}
todo = sorted(r for r in roots if r not in done)
def one(r):
    c = check(tree, tree, r, 300)
    if c['verdict'] == 'STACK':
        c = check(tree, tree, r, 300, big=True)
    return r, {'verdict': c['verdict'], 'secs': c['secs'], 'laws': c['laws'][:3]}
with cf.ThreadPoolExecutor(min(a.jobs, 4)) as ex:
    for r, v in ex.map(one, todo):
        done[r] = v
        print(r, v['verdict'], flush=True)
        json.dump(done, open(a.out, 'w'), indent=1)
json.dump(done, open(a.out, 'w'), indent=1)
