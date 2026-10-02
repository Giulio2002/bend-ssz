#!/usr/bin/env python3
"""e2e_check.py --tree TREE --work WORK --out e2e.json PATCH  NAME[,NAME..]   (server)
Verdict A2: the composed end-to-end files e2e/<Name>_e2e_*_generated.bend of the named types (the facades do not import them) checked on the mutant,
at most 3 files at a time, 120 s each. Reported per file: KILLED (law), SURVIVED, TIMEOUT, STACK, ERROR."""
import argparse, concurrent.futures as cf, glob, json, os, shutil, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import runner
ap = argparse.ArgumentParser()
ap.add_argument('--tree', required=True); ap.add_argument('--work', required=True); ap.add_argument('--out', required=True)
ap.add_argument('--jobs', type=int, default=3)
ap.add_argument('patch'); ap.add_argument('names')
a = ap.parse_args()
tree, work = os.path.abspath(a.tree), os.path.abspath(a.work)
p = os.path.abspath(a.patch); h = runner.header(p); h['path'] = p
targets = []
for n in a.names.split(','):
    targets += sorted(os.path.relpath(f, tree) for f in glob.glob(os.path.join(tree, 'e2e', n + '_e2e_*_generated.bend')) + glob.glob(os.path.join(tree, 'e2e', n + '_e2e_generated.bend')))
files = set()
for t in targets:
    files |= runner.cone(tree, t)
d = runner.private_tree(tree, work, 'e2e_' + h['id'].replace('/', '_'), files, h)
res = []
def one(t):
    c = runner.check(tree, d, t, 120)
    if c['verdict'] == 'STACK':
        c['verdict'] = 'STACK'
    return {'file': t, 'verdict': c['verdict'], 'laws': c['laws'], 'secs': c['secs']}
with cf.ThreadPoolExecutor(a.jobs) as ex:
    for r in ex.map(one, targets):
        res.append(r); print(h['id'], r, flush=True)
shutil.rmtree(d, ignore_errors=True)
old = json.load(open(a.out)) if os.path.exists(a.out) else []
old = [o for o in old if o['id'] != h['id']]
old.append({'id': h['id'], 'e2e': res, 'A2': 'KILLED' if any(r['verdict'] == 'KILLED' for r in res) else ('SURVIVED' if all(r['verdict'] == 'SURVIVED' for r in res) else 'MIXED')})
json.dump(old, open(a.out, 'w'), indent=1)
