#!/usr/bin/env python3
"""freplay9.py --ftree FTREE --idx F_ALLCONES --roots F_NEW_ROOTS --work W --out OUT PATCH...: replay round-9 survivors on fixer F's tree
(agent/r8-fixes 674bbe68c). For each patch: the laws F added or changed (F_NEW_ROOTS, outside proofs/gate) whose import cone holds the
patched file, each with tools/check.sh (pinned settings, 120 s; a stack overflow is retried once and never a kill).
KILLED (root, laws) / SURVIVED / UNJUDGED / ERROR (patch does not apply on F's tree). At most 4 jobs, nice 19."""
import argparse, concurrent.futures as cf, json, os, shutil, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from runner import header, cone, private_tree, check, facades   # noqa: E402


def one(a, idx, new, path):
    h = header(path); h['path'] = os.path.abspath(path)
    res = {'id': h['id'], 'checks': []}
    try:
        rev = set(idx['rev'].get(h['file'], []))
        cands = [r for r in new if r in rev]
        files = set()
        for r in cands:
            files |= cone(a.ftree, r)
        d = private_tree(a.ftree, a.work, h['id'].replace('/', '_'), files, h)
        v = 'SURVIVED'
        for r in cands:
            c = check(a.ftree, d, r, 120)
            if c['verdict'] == 'STACK':
                c = check(a.ftree, d, r, 120)
                c['verdict'] = 'CRASH' if c['verdict'] == 'STACK' else c['verdict']
            c['root'] = r
            res['checks'].append(c)
            if c['verdict'] == 'KILLED':
                v = 'KILLED'; break
            if c['verdict'] in ('TIMEOUT', 'CRASH', 'ERROR') and v == 'SURVIVED':
                v = 'UNJUDGED' if c['verdict'] != 'ERROR' else 'ERROR'
        res['F'] = v
        shutil.rmtree(d, ignore_errors=True)
    except Exception as e:
        res['F'] = 'ERROR'; res['msg'] = str(e)[:300]
    return res


def main():
    ap = argparse.ArgumentParser()
    for k in ('--ftree', '--idx', '--roots', '--work', '--out'):
        ap.add_argument(k, required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('patches', nargs='+')
    a = ap.parse_args()
    a.ftree = os.path.abspath(a.ftree)
    idx = json.load(open(a.idx))
    new = [l.strip() for l in open(a.roots) if l.strip().endswith('.bend') and os.path.exists(os.path.join(a.ftree, l.strip()))]
    os.makedirs(a.work, exist_ok=True)
    out = []
    with cf.ThreadPoolExecutor(min(a.jobs, 4)) as ex:
        for r in ex.map(lambda p: one(a, idx, new, p), a.patches):
            out.append(r)
            print(r['id'], r['F'], [(c['root'].split('/')[-1], c['laws'][:2]) for c in r['checks'] if c['verdict'] == 'KILLED'], r.get('msg', '')[:120], flush=True)
            json.dump(out, open(a.out, 'w'), indent=1)


if __name__ == '__main__':
    main()
