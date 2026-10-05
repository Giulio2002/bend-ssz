#!/usr/bin/env python3
"""run9.py (round 9 = run8.py of round 8; run4.py with the stack retry at the pinned settings): verdict (A) (run3.py with the slop laws first among the mentioning roots, --direct and --fac limits). Run on the ssz server.

  run2.py --tree TREE --idx allcones.json --work WORK --out RESULTS.json [--jobs 4] [--k 6] PATCH...

Differs from runner.py (round 1) in which proofs a fault is judged against. Round 1 ran only the facade files
proofs/api/<Name>_<op>_proof_generated.bend. Most laws about shared helpers and collection operations (append, set, blit, validity,
crash-fix laws) live in proofs/obj, proofs/slop and proofs/*.bend and are not in any facade's import cone, so a facade-only run reports
them as survivors. Here a fault is checked against, in this order:
  1. the roots named in the header line '# proofs: a,b,c' (explicit), else
  2. the cheapest K proof roots (outside types/, tools/, vendor/; proofs/**, e2e/**) whose import cone contains the patched file
     and whose text mentions one of the symbols of the header line '# sym: f,g' (the definitions the fault changes and their
     direct callers), cost <= 150 s (tools/check_costs.tsv),
  3. the facade proof files proofs/api/<type>_<op>_proof_generated.bend of the header lines '# type:' and '# ops:'.
The first root that fails with a named law kills the patch. Verdict per patch: KILLED (root, laws), SURVIVED (every root checks),
UNJUDGED (some root timed out or overflowed the checker's stack, none killed), ERROR (patch or scope error). The private
hard-linked tree is deleted afterwards. With --survivors-wide the K limit and the cost limit are lifted (all mentioning roots up to
600 s) for patches that survived the first pass.
"""
import argparse, concurrent.futures as cf, json, os, re, shutil, subprocess, sys, time
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from runner import header, cone, private_tree, check, facades   # noqa: E402


def mentions(tree, root, syms):
    t = open(os.path.join(tree, root)).read()
    return any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(s) + r'(?![A-Za-z0-9_])', t) for s in syms)


def candidates(a, h, idx):
    out = []
    if h.get('proofs'):
        out += [p.strip() for p in h['proofs'].split(',') if p.strip()]
    syms = [s.strip() for s in h.get('sym', '').split(',') if s.strip()]
    if syms and not a.no_sym:
        rev, cost = idx['rev'], idx['cost']
        pool = [r for r in rev.get(h['file'], []) if not r.startswith(('types/', 'proofs/api/')) and r not in out]
        pool = [r for r in pool if cost.get(r, 60) <= (600 if a.wide else 60)]
        pool.sort(key=lambda r: (not r.startswith("proofs/slop/"), cost.get(r, 60)))
        hit = [r for r in pool if mentions(a.tree, r, syms)]
        out += hit[:(100 if a.wide else a.k)]
    direct = [r for r, ds in idx.get("direct", {}).items() if h["file"] in ds and not r.startswith(("types/", "proofs/api/", "benchmarks/", "tools/")) and r not in out]
    direct.sort(key=lambda r: idx["cost"].get(r, 60))
    out += [r for r in direct if idx["cost"].get(r, 60) <= (600 if a.wide else 60)][:(20 if a.wide else a.direct)]
    if h.get('type') and h.get('ops'):
        fac = [f for _, _, f in facades(h) if f not in out and os.path.exists(os.path.join(a.tree, f))]
        out += fac if a.wide else fac[:a.fac]
    return out


def one(a, idx, path):
    h = header(path)
    h['path'] = os.path.abspath(path)
    res = {'id': h['id'], 'type': h.get('type'), 'file': h['file'], 'checks': []}
    try:
        cands = candidates(a, h, idx)
        if not cands:
            res['A'] = 'ERROR'; res['msg'] = 'no proof roots'; return res
        files = set()
        for r in cands:
            files |= cone(a.tree, r)
        d = private_tree(a.tree, a.work, h['id'].replace('/', '_'), files, h)
        verdict = 'SURVIVED'
        for r in cands:
            cost = idx['cost'].get(r, 60)
            to = int(min(600, max(120, 2 * cost + 30))) if a.wide else 120
            c = check(a.tree, d, r, to)
            if c['verdict'] == 'STACK':
                c2 = check(a.tree, d, r, to)   # round 8: retry once with the PINNED settings (brief)
                c2['first_try'] = 'STACK'
                c = c2 if c2['verdict'] != 'STACK' else dict(c2, verdict='CRASH')
            c['root'] = r
            res['checks'].append(c)
            if c['verdict'] == 'KILLED':
                verdict = 'KILLED'; break
            if c['verdict'] in ('TIMEOUT', 'CRASH') and verdict == 'SURVIVED':
                verdict = 'UNJUDGED'
            elif c['verdict'] == 'ERROR' and verdict == 'SURVIVED':
                verdict = 'ERROR'
        res['A'] = verdict
        shutil.rmtree(d, ignore_errors=True)
    except Exception as e:
        res['A'] = 'ERROR'; res['msg'] = str(e)[:300]
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True); ap.add_argument('--idx', required=True)
    ap.add_argument('--work', required=True); ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4); ap.add_argument('--k', type=int, default=6)
    ap.add_argument('--wide', action='store_true'); ap.add_argument('--direct', type=int, default=1); ap.add_argument('--fac', type=int, default=1); ap.add_argument('--no-sym', action='store_true')
    ap.add_argument('--redo', action='store_true', help='re-run patches already in --out')
    ap.add_argument('patches', nargs='+')
    a = ap.parse_args()
    a.tree = os.path.abspath(a.tree)
    os.makedirs(a.work, exist_ok=True)
    idx = json.load(open(a.idx))
    done = {}
    if os.path.exists(a.out) and not a.redo:
        done = {r['id']: r for r in json.load(open(a.out))}
    todo = [p for p in a.patches if header(p)['id'] not in done]
    results = list(done.values())
    with cf.ThreadPoolExecutor(min(a.jobs, 4)) as ex:
        for r in ex.map(lambda p: one(a, idx, p), todo):
            results = [x for x in results if x['id'] != r['id']] + [r]
            k = [(c['root'].split('/')[-1], c['laws'][:2] or c['msg'][:50]) for c in r['checks'] if c['verdict'] in ('KILLED', 'CRASH')]
            print(r['id'], r['A'], k[:1], flush=True)
            json.dump(results, open(a.out, 'w'), indent=1)
    json.dump(results, open(a.out, 'w'), indent=1)


if __name__ == '__main__':
    main()
