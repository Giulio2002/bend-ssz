#!/usr/bin/env python3
"""recheck.py --tree TREE --work WORK --results results.json --out recheck.json
Re-runs every proof check that ended in CRASH (checker stack exhaustion on the mutant), one at a time, with the pinned defaults of tools/check.sh
(ulimit -s 16384, JSC stack 10485760). A check that still exhausts the stack is UNJUDGED (not a detection)."""
import argparse, json, os, shutil, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import runner
ap = argparse.ArgumentParser()
ap.add_argument('--tree', required=True); ap.add_argument('--work', required=True); ap.add_argument('--results', required=True); ap.add_argument('--out', required=True)
ap.add_argument('--timeout', type=int, default=120)
a = ap.parse_args()
tree = os.path.abspath(a.tree); work = os.path.abspath(a.work)
res = json.load(open(a.results))
out = json.load(open(a.out)) if os.path.exists(a.out) else []
done = {o['id'] for o in out}
for r in res:
    if r['A'] != 'CRASH' or r['id'] in done:
        continue
    h = runner.header('patches/%s.patch' % r['id']); h['path'] = os.path.abspath('patches/%s.patch' % r['id'])
    c0 = [c for c in r['checks'] if c['verdict'] == 'CRASH'][0]
    fac = 'proofs/api/%s_%s_proof_generated.bend' % (c0['type'], runner.OPN[c0['op']])
    files = runner.cone(tree, fac)
    d = runner.private_tree(tree, work, 'rc_' + r['id'].replace('/', '_'), files, h)
    c = runner.check(tree, d, fac, a.timeout)           # pinned defaults, no big stack
    shutil.rmtree(d, ignore_errors=True)
    out.append({'id': r['id'], 'facade': fac, 'pinned_verdict': c['verdict'], 'laws': c['laws'], 'secs': c['secs'], 'msg': c['msg'][:200]})
    print(r['id'], c['verdict'], c['laws'], flush=True)
    json.dump(out, open(a.out, 'w'), indent=1)
