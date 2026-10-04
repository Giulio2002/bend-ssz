#!/usr/bin/env python3
"""report7.py OUT_DIR PATCH_DIRS... : merge the round-7 verdict files (res_all.json narrow pass, pass2.json explicit roots, budget.json, replay*.json,
dopen.json, api_p7*.json) with the hand-written judgements (r7/judgements.json) into
  r7/results/final.json                 one row per fault: id, file, fault, (A) verdict and killing law, (B') probe verdict
  docs/mutation_testing/manual_round_7_survivors.json   the faults no named law kills, with reachability, counterexample and verdict
Run on the server (no python on the laptop)."""
import json, os, re, sys

out, *pdirs = sys.argv[1:]
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../../..'))


def load(n):
    p = os.path.join(out, n)
    return json.load(open(p)) if os.path.exists(p) else []


def hdr(path):
    h = {}
    for l in open(path):
        if not l.startswith('#'):
            break
        m = re.match(r'# (\w+): (.*)', l)
        if m:
            h[m.group(1)] = m.group(2).strip()
        m = re.match(r'# MANUAL SPEC MUTANT (\S+)', l)
        if m:
            h['id'] = m.group(1)
    return h


patches = {}
for d in pdirs:
    for fam in sorted(os.listdir(d)):
        fd = os.path.join(d, fam)
        if os.path.isdir(fd):
            for f in sorted(os.listdir(fd)):
                if f.endswith('.patch'):
                    h = hdr(os.path.join(fd, f))
                    patches[h['id']] = dict(h, patch=os.path.relpath(os.path.join(fd, f), d))
A = {}
for n in ('res_all.json', 'budget.json', 'pass2.json'):     # later files override (explicit roots)
    for r in load(n):
        if r['id'] in A and A[r['id']]['A'] == 'KILLED':
            continue
        A[r['id']] = r
probes = {}
for n in ('api_p7a.json', 'api_p7b.json', 'api_p7d.json', 'api_p7e.json'):
    for k, v in (load(n) if isinstance(load(n), dict) else {}).items():
        if k != 'baseline':
            probes.setdefault(k, {})[n[4:-5]] = v
J = json.load(open(os.path.join(HERE, 'judgements.json')))
rows, surv = [], []
for i, h in sorted(patches.items()):
    r = A.get(i, {'A': 'NOTRUN', 'checks': []})
    kill = [(c['root'], c['laws'][:2]) for c in r.get('checks', []) if c['verdict'] == 'KILLED']
    row = {'id': i, 'type': h.get('type'), 'file': h.get('file'), 'rule': h.get('spec'), 'fault': h.get('fault'), 'A': r['A'],
           'killed_by': kill[:1], 'probe': probes.get(i)}
    rows.append(row)
    if r['A'] != 'KILLED':
        j = J.get(i, {})
        surv.append({'id': i, 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/' + h['patch'] if not h.get('base') else 'tools/mutation_testing/manual_spec_mutants/r7/patches_budget/' + h['patch'],
                     'type': h.get('type'), 'file': h.get('file'), 'rule': h.get('spec'), 'fault': h.get('fault'), 'A': r['A'],
                     'counterexample': j.get('counterexample', ''), 'reachability': j.get('reachability', ''), 'verdict': j.get('verdict', 'unjudged'),
                     'evidence': {'roots': [(c['root'], c['verdict']) for c in r.get('checks', [])], 'probe': probes.get(i), 'note': j.get('evidence', '')}})
# the open round-5 decode faults and the replay: judged separately (judgements.json keys r5-* / replay ids)
for i, j in J.items():
    if i.startswith(('r5-', 'replay:')):
        surv.append(dict({'id': i}, **j))
json.dump(rows, open(os.path.join(HERE, 'results/final.json'), 'w'), indent=1)
json.dump(surv, open(os.path.join(ROOT, 'docs/mutation_testing/manual_round_7_survivors.json'), 'w'), indent=1)
c = {}
for r in rows:
    c[r['A']] = c.get(r['A'], 0) + 1
print(len(rows), c, 'survivor rows', len(surv))
