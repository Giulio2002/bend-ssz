#!/usr/bin/env python3
"""Replay manual-audit faults against named laws (round 11 / 12 fixes, agent/r11-fixes).

    python3 tools/mutation_testing/manual_spec_mutants/r11/replay_fix11.py PLAN.json OUT.json [--jobs 8] [--work DIR]

PLAN.json: [{"id": "r11-d02/03", "patch": "<patch path>", "laws": ["proofs/...bend" or a glob, ...]}, ...]. For each fault: a hard-linked copy of
the tree (the patched file is copied first, so the tree is never touched), the patch applied, then every law file checked with
tools/check.sh at the pinned settings. A law KILLS the fault when its check fails naming a definition of that file ("SOME PROOFS FAIL" and a
`Location:` in the file); a check that passes is SURVIVED; a crash or timeout is UNJUDGED (never a kill). OUT.json: per fault, per law:
status, seconds, the failing location.
"""
import concurrent.futures as cf
import glob
import json
import os
import re
import shutil
import subprocess
import sys

R = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))


def one(item, work):
    fid = item['id']
    d = os.path.join(work, re.sub(r'\W', '_', fid))
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    for e in os.listdir(R):
        if e != '.git':
            subprocess.run(['cp', '-al', os.path.join(R, e), d], check=True)
    patch = open(os.path.join(R, item['patch'])).read()
    target = re.search(r'^# file: (\S+)', patch, re.M).group(1)
    tp = os.path.join(d, target)
    data = open(tp).read()
    os.unlink(tp)                       # break the hard link: the original tree keeps its file
    with open(tp, 'w') as f:
        f.write(data)
    p = subprocess.run(['patch', '-p1', '-s', '--no-backup-if-mismatch', '-d', d], input=patch, text=True, capture_output=True)
    res = {'id': fid, 'patch': item['patch'], 'applied': p.returncode == 0, 'laws': []}
    if p.returncode:
        res['error'] = p.stdout + p.stderr
        shutil.rmtree(d, ignore_errors=True)
        return res
    laws = []
    for g in item['laws']:
        laws += sorted(glob.glob(os.path.join(R, g))) if any(c in g for c in '*?[') else [os.path.join(R, g)]
    env = dict(os.environ, CHECK_PINS_VERIFIED='1', CHECK_TIMEOUT=os.environ.get('CHECK_TIMEOUT', '300'))
    for lf in laws:
        rel = os.path.relpath(lf, R)
        q = subprocess.run(['nice', '-n', '19', 'tools/check.sh', rel], cwd=d, env=env, capture_output=True, text=True)
        out = q.stdout + q.stderr
        t = re.search(r'CHECK_TIME ([\d.]+)', out)
        loc = re.search(r'Location: (\S+)', out)
        if 'ALL PROOFS CHECK' in out:
            st = 'SURVIVED'
        elif 'SOME PROOFS FAIL' in out and loc:
            st = 'KILLED'
        else:
            st = 'UNJUDGED'
        res['laws'].append({'law': rel, 'status': st, 'secs': float(t.group(1)) if t else None, 'location': loc.group(1) if loc else None,
                            'tail': '' if st != 'UNJUDGED' else out[-400:]})
        if st == 'KILLED' and item.get('first', True):
            break
    res['verdict'] = 'KILLED' if any(x['status'] == 'KILLED' for x in res['laws']) else (
        'UNJUDGED' if any(x['status'] == 'UNJUDGED' for x in res['laws']) else 'SURVIVED')
    shutil.rmtree(d, ignore_errors=True)
    return res


def main():
    plan = json.load(open(sys.argv[1]))
    out = sys.argv[2]
    jobs = int(sys.argv[sys.argv.index('--jobs') + 1]) if '--jobs' in sys.argv else 8
    work = sys.argv[sys.argv.index('--work') + 1] if '--work' in sys.argv else os.path.join(R, '..', 'replay_work')
    os.makedirs(work, exist_ok=True)
    rows = []
    with cf.ThreadPoolExecutor(jobs) as ex:
        for r in ex.map(lambda it: one(it, work), plan):
            k = next((x for x in r['laws'] if x['status'] == 'KILLED'), None)
            print(f"{r['id']:<16} {r.get('verdict', 'NOT APPLIED'):<9} {k['law'] if k else ''} {k['location'] if k else ''} {k['secs'] if k else ''}", flush=True)
            rows.append(r)
    json.dump(rows, open(out, 'w'), indent=1)


if __name__ == '__main__':
    main()
