#!/usr/bin/env python3
"""pass2_11.py TREE ALLCONES.json RES.json PKDIR OUT.json [N]: for every fault pass 1 did not kill, the N cheapest facade proofs
(proofs/api/<T>_<op>_proof_generated.bend of the patch's operations) whose import cone holds the mutated file and that pass 1 did
not check: the facades of the CONTAINING types, where a nested reader / validator / cache is actually reached with off != 0, a
fixed len, a boxed field. Writes {id: [roots]} for run11.py --roots-json. Run on the server."""
import json, os, re, sys
tree, cones, res, pk, out = sys.argv[1:6]
N = int(sys.argv[6]) if len(sys.argv) > 6 else 4
idx = json.load(open(cones))
OPN = {'decode': 'decode_ssz', 'encode': 'encode_ssz', 'root': 'hashtreeroot'}
plan = {}
for r in json.load(open(res)):
    if r['A'] == 'KILLED':
        continue
    t = open(os.path.join(pk, r['id'] + '.patch')).read()
    ops = re.search(r'^# ops: (.*)$', t, re.M).group(1).split(',')
    done = {c['root'] for c in r['checks']}
    suf = tuple('_%s_proof_generated.bend' % OPN[o] for o in ops)
    fac = [x for x in idx['rev'].get(r['file'], []) if x.startswith('proofs/api/') and x.endswith(suf) and x not in done]
    fac.sort(key=lambda x: idx['cost'].get(x, 60))
    if fac:
        plan[r['id']] = fac[:N]
json.dump(plan, open(out, 'w'), indent=1)
print(len(plan), 'faults with', sum(len(v) for v in plan.values()), 'roots')
