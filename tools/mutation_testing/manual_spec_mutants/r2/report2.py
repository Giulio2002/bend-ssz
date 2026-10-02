#!/usr/bin/env python3
"""report2.py TREE OUTDIR: merge the round-2 results into the report files.

Inputs (all under OUTDIR, produced on the server): res_all.json (verdict A per fault, run2.py), corpus_r2.json (verdict B, corpus.py,
optional), wide_r2.json (the survivors re-run against every mentioning proof root, run2.py --wide, optional), judgments.json
({id: {counterexample, reachability, verdict, evidence}} written by hand for every fault that survives A), index.json (the patch
metadata of mk2.py: id, type, ops, spec, fault, why, file, sym, base). Writes
  TREE/docs/mutation_testing/manual_round_2_survivors.json   (the machine-readable list of survivors and unjudged faults)
  OUTDIR/round2_section.md                                    (the round-2 section of MANUAL_SPEC_MUTATIONS.md)
"""
import collections, json, os, sys
tree, out = sys.argv[1:3]
L = lambda n, d=None: json.load(open(os.path.join(out, n))) if os.path.exists(os.path.join(out, n)) else d
res = {r['id']: r for r in L('res_all.json', [])}
wide = {r['id']: r for r in L('wide_r2.json', [])}
corp = {r['id']: r for r in L('corpus_r2.json', [])}
judg = L('judgments.json', {})
idx = {x['id']: x for x in L('index.json', [])}
rows = []
for fid in sorted(idx):
    m = idx[fid]
    r = wide.get(fid) or res.get(fid) or {}
    a = r.get('A', 'NOT RUN')
    killer = ''
    for c in r.get('checks', []):
        if c.get('verdict') == 'KILLED':
            killer = '%s: %s' % (c['root'].split('/')[-1], ','.join(c.get('laws', [])[:2]) or c.get('msg', '')[:50])
    b = corp.get(fid, {})
    rows.append(dict(id=fid, type=m.get('type'), ops=m.get('ops'), file=m.get('file'), fault=m.get('fault'), spec=m.get('spec'),
                     A=a, killer=killer, B=(b.get('B') or ''), base=m.get('base') or 'd21616e2b'))
cnt = collections.Counter(x['A'] for x in rows)
surv = []
for x in rows:
    if x['A'] in ('SURVIVED', 'UNJUDGED', 'TIMEOUT', 'ERROR', 'NOT RUN'):
        j = judg.get(x['id'], {})
        surv.append({'id': x['id'], 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/%s.patch' % x['id'],
                     'type': x['type'], 'file': x['file'], 'rule': x['spec'], 'fault': x['fault'], 'proofs_verdict': x['A'],
                     'corpus_verdict': x['B'], 'counterexample': j.get('counterexample', ''), 'reachability': j.get('reachability', ''),
                     'verdict': j.get('verdict', 'unjudged'), 'evidence': j.get('evidence', '')})
os.makedirs(os.path.join(tree, 'docs/mutation_testing'), exist_ok=True)
json.dump(surv, open(os.path.join(tree, 'docs/mutation_testing/manual_round_2_survivors.json'), 'w'), indent=1)
md = ['## Round 2 (agent/manual-spec-mutations-r2)', '', 'faults: %d; proofs: %s' % (len(rows), dict(cnt)), '',
      '| fault | type | file | fault | A | killed by | B |', '|---|---|---|---|---|---|---|']
for x in rows:
    md.append('| %s | %s | %s | %s | %s | %s | %s |' % (x['id'], x['type'], x['file'], (x['fault'] or '').replace('|', '/'), x['A'], x['killer'].replace('|', '/'), x['B']))
open(os.path.join(out, 'round2_section.md'), 'w').write('\n'.join(md) + '\n')
print(len(rows), dict(cnt), len(surv))
