#!/usr/bin/env python3
"""report9.py RESULTS_DIR PK_DIR OUT_JSON: round-9 machine-readable survivors (docs/mutation_testing/manual_round_9_survivors.json) and the tallies
for MANUAL_SPEC_MUTATIONS.md. Inputs: res_b1.json (verdict A, run9.py), api_p9a.json (API probe p9a, apiprobe3.py), corpus9.json (verdict B, optional),
pk/index.json (fault headers) and judgements9.json (per-family judgement: reachability, verdict, counter-example template; per-id overrides).
Every survivor of A gets: the patch, the spec rule, a counter-example through public entry points (the probe line that differs, when the probe saw it),
the reachability and the verdict."""
import collections, json, os, sys

res_dir, pk, out = sys.argv[1:4]
here = os.path.dirname(os.path.abspath(__file__))
A = {}
for fn in ("res_b1.json", "res_b2.json", "res_p2.json"):   # narrow pass, the b/c re-run on their containing names, the second pass on survivors
    p = os.path.join(res_dir, fn)
    if os.path.exists(p):
        for r in json.load(open(p)):
            old = A.get(r["id"])
            if old and r["A"] != "KILLED" and old["A"] in ("SURVIVED", "UNJUDGED"):
                r = dict(r, checks=old["checks"] + r["checks"], A=old["A"] if old["A"] == "UNJUDGED" else r["A"])
            A[r["id"]] = r
FR = {r["id"]: r for r in json.load(open(os.path.join(res_dir, "freplay.json")))} if os.path.exists(os.path.join(res_dir, "freplay.json")) else {}
P = json.load(open(os.path.join(res_dir, 'api_p9a.json'))) if os.path.exists(os.path.join(res_dir, 'api_p9a.json')) else {}
Bc = {r['id']: r for r in json.load(open(os.path.join(res_dir, 'corpus9.json')))} if os.path.exists(os.path.join(res_dir, 'corpus9.json')) else {}
idx = {x['id']: x for x in json.load(open(os.path.join(pk, 'index.json')))}
J = json.load(open(os.path.join(here, 'judgements9.json')))
fam, ids = J['families'], J.get('ids', {})

surv, tally = [], collections.Counter()
for i, h in sorted(idx.items()):
    a = A.get(i, {}).get('A', 'NOTRUN')
    tally['A_' + a] += 1
    if a == 'KILLED':
        continue
    f = i.split('/')[0]
    j = dict(fam.get(f, {}))
    j.update(ids.get(i, {}))
    pr = P.get(i, {})
    b2 = pr.get('B2', 'NOTRUN')
    tally['probe_' + b2] += 1
    diff = pr.get('diff', {})
    ce = j.get('counterexample', '')
    if diff:
        c, (base, mut) = sorted(diff.items(), key=lambda kv: int(kv[0]))[0]
        ce = (ce + ' | ' if ce else '') + 'probe p9a case %s: unmutated "%s" / mutant "%s"' % (c, base, mut)
    verdict = j.get('verdict', 'UNJUDGED')
    if j.get('needs_probe') and b2 == 'SURVIVED':
        verdict = j.get('verdict_if_probe_silent', verdict)
    tally['verdict_' + verdict] += 1
    surv.append({
        'id': i, 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/%s.patch' % i, 'type': h.get('type'), 'file': h.get('file'),
        'rule': h.get('spec'), 'fault': h.get('fault'), 'counterexample': ce, 'reachability': j.get('reachability', ''), 'verdict': verdict,
        'evidence': {'A': a, 'roots': [(c['root'], c['verdict'], c.get('secs')) for c in A.get(i, {}).get('checks', [])],
                     'probe': b2, 'F_replay': (FR.get(i, {}).get('F', 'NOTRUN') + (' (' + str(len(FR.get(i, {}).get('checks', []))) + ' F roots in the cone)' if i in FR else '')), 'corpus': Bc.get(i, {}).get('B', 'NOTRUN'), 'note': j.get('evidence', '')}})
json.dump(surv, open(out, 'w'), indent=1)
print(json.dumps(dict(sorted(tally.items())), indent=0))
