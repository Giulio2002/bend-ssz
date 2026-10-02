#!/usr/bin/env python3
"""allcones.py TREE OUT.json: reverse import index over EVERY root of the full check (every .bend file outside tools/ and vendor/):
{file: [root, ...]} for files of src/ and types/ (all roots whose import cone contains the file) and {root: cost seconds} from
tools/check_costs.tsv. The full check (tools/check_fast.sh) kills a mutant if any root fails, so this is the complete set of proofs
that can notice an edit to a file. Run on the server."""
import json, os, re, sys
tree, out = sys.argv[1:3]
IMP = re.compile(r'^import\s+(\S+)', re.M)
roots, g = [], {}
for d, ds, fs in os.walk(tree):
    ds[:] = [x for x in ds if x not in ('tools', 'vendor', '.git', 'build', 'node_modules')]
    for f in fs:
        if f.endswith('.bend'):
            r = os.path.relpath(os.path.join(d, f), tree)
            roots.append(r)
for r in roots:
    deps = []
    for m in IMP.finditer(open(os.path.join(tree, r)).read()):
        t = m.group(1)
        if t == 'Base' or not t.endswith('.bend'):
            continue
        q = os.path.normpath(os.path.join(os.path.dirname(r), t))
        if os.path.exists(os.path.join(tree, q)):
            deps.append(q)
    g[r] = deps
memo = {}
def cone(r):
    if r in memo:
        return memo[r]
    s = {r}
    memo[r] = s   # imports are acyclic
    for q in g.get(r, []):
        s |= cone(q)
    return s
sys.setrecursionlimit(100000)
rev = {}
for r in roots:
    for x in cone(r):
        if x.startswith(('src/', 'types/')) and x != r:
            rev.setdefault(x, []).append(r)
cost = {}
for l in open(os.path.join(tree, 'tools/check_costs.tsv')):
    p = l.rstrip('\n').split('\t')
    if len(p) >= 4:
        try: cost[p[0]] = float(p[3])
        except ValueError: pass
json.dump({'rev': rev, 'cost': cost, 'direct': g}, open(out, 'w'))
print(len(roots), len(rev))
