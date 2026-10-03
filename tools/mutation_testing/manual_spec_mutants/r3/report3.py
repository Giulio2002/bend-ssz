#!/usr/bin/env python3
"""report3.py: merge the round-3 results into docs/mutation_testing/manual_round_3_survivors.json and the round-3 section.

  report3.py --pk PK_DIR --res res_all.json [--probe NAME=file.json ...] --judg judgments.json --out-json OUT.json --out-md OUT.md

Inputs: the patches (PK_DIR/<slug>/NN.patch with the '#' header), the verdict-A results (run3.py), the API-probe results (apiprobe3.py,
one file per probe program), and judgments.json: {fault id: {verdict, counterexample, reachability, evidence, rule?}} written by hand for
every fault that survived the proofs (the verdict is critical | gap-unreachable | equivalent | corpus-gap-only | unjudged)."""
import argparse, glob, json, os, re, sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from runner import header   # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pk', required=True); ap.add_argument('--res', required=True)
    ap.add_argument('--probe', action='append', default=[]); ap.add_argument('--judg', required=True)
    ap.add_argument('--out-json', required=True); ap.add_argument('--out-md', required=True)
    a = ap.parse_args()
    res = {r['id']: r for r in json.load(open(a.res))}
    probes = {}
    for p in a.probe:
        name, f = p.split('=', 1)
        probes[name] = json.load(open(f))
    judg = json.load(open(a.judg))
    heads = {}
    for f in sorted(glob.glob(os.path.join(a.pk, 'r3-*', '*.patch'))):
        h = header(f)
        h['patch'] = os.path.relpath(f, os.path.join(a.pk, '..'))
        heads[h['id']] = h
    rows, surv = [], []
    for fid in sorted(heads):
        h = heads[fid]
        r = res.get(fid)
        if r is None:
            continue
        A = r['A']
        killer = ''
        for c in r['checks']:
            if c['verdict'] == 'KILLED':
                killer = '%s: %s' % (os.path.basename(c['root']), ','.join(c.get('laws', [])[:2]))
        pk = []
        for n, d in probes.items():
            v = d.get(fid)
            if v:
                pk.append('%s %s%s' % (n, v['B2'], (' ' + ','.join(sorted(v.get('diff', {}), key=lambda x: int(x))[:6])) if v.get('diff') else ''))
        rows.append((fid, h.get('type'), h['file'], h.get('fault'), A, killer, '; '.join(pk)))
        if A != 'KILLED':
            j = judg.get(fid, {})
            surv.append({'id': fid, 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/' + h['patch'].split('pk/')[-1] if 'pk/' in h['patch'] else h['patch'],
                         'type': h.get('type'), 'file': h['file'], 'rule': h.get('spec'),
                         'fault': h.get('fault'),
                         'counterexample': j.get('counterexample', ''), 'reachability': j.get('reachability', ''),
                         'verdict': j.get('verdict', 'unjudged' if A in ('UNJUDGED', 'ERROR') else 'unclassified'),
                         'evidence': j.get('evidence', ''), 'proofs': A, 'probes': '; '.join(pk)})
    json.dump(surv, open(a.out_json, 'w'), indent=1)
    from collections import Counter
    cnt = Counter(r[4] for r in rows)
    vc = Counter(s['verdict'] for s in surv)
    with open(a.out_md, 'w') as f:
        f.write('| fault | type | file | fault | A | killed by | API probes |\n|---|---|---|---|---|---|---|\n')
        for r in rows:
            f.write('| ' + ' | '.join(str(x).replace('|', '/') for x in r) + ' |\n')
        f.write('\n')
    print('faults', len(rows), dict(cnt), 'survivor verdicts', dict(vc))


if __name__ == '__main__':
    main()
