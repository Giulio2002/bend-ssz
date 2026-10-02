#!/usr/bin/env python3
"""apiprobe.py --tree T --work W --out apiprobe.json [--jobs 4] [--baseline] PATCH...

Verdict B' (API probe) for round-2 faults on the collection API: compile r2/probes/api_probe.bend (public X_append / X_set / X_get / X_len of
bytelist_256, bitlist_9 and List[WithdrawalRequest, 16]) from a private hard-linked copy of its import cone with the patch applied,
run every SSZ_CASE and compare the printed lines with the unmutated build. KILLED: some line differs (the lines are listed);
SURVIVED: all lines equal; NOTAPPLICABLE: the patched file is not in the probe's cone. Uses the 2.0.34 runtime compiler like corpus.py."""
import argparse, concurrent.futures as cf, json, os, shutil, subprocess, sys, time
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from runner import header, cone   # noqa: E402

PROBE = os.environ.get('PROBE', 'tools/mutation_testing/manual_spec_mutants/r2/probes/api_probe.bend')
CASES = [int(x) for x in os.environ.get('CASES', '1,2,3,4,5,6,7,8,9,10,11,12,13,14,20,21,22,23,24,25,26,27,30,31,32,33,34,35,36,37').split(',')]


def build(tree, work, name, patch, bend):
    files = cone(tree, PROBE)
    d = os.path.join(work, name)
    shutil.rmtree(d, ignore_errors=True)
    for r in files:
        dst = os.path.join(d, r)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        os.link(os.path.join(tree, r), dst)
    if patch is not None:
        tgt = patch['file']
        if tgt not in files:
            return None
        os.unlink(os.path.join(d, tgt))
        shutil.copy(os.path.join(tree, tgt), os.path.join(d, tgt))
        r = subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', patch['path']], cwd=d, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('patch failed ' + r.stdout + r.stderr)
    out = os.path.join(d, 'probe')
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    r = subprocess.run(['nice', '-n', '19', bend, PROBE, '-o', out], cwd=d, env=env, capture_output=True, text=True)
    if r.returncode:
        raise RuntimeError('compile failed: ' + (r.stdout + r.stderr)[-400:])
    return d


def run_cases(d):
    lines = {}
    for c in CASES:
        env = dict(os.environ, SSZ_CASE=str(c))
        try:
            r = subprocess.run(['nice', '-n', '19', os.path.join(d, 'probe'), '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=120)
            lines[c] = (r.stdout.strip() or ('rc=%d %s' % (r.returncode, r.stderr.strip()[-80:])))
        except subprocess.TimeoutExpired:
            lines[c] = 'timeout'
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True); ap.add_argument('--work', required=True); ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4); ap.add_argument('--baseline', action='store_true')
    ap.add_argument('--bend', default='/srv/ssz-optimization/toolchain-2.0.34/bin/bend')
    ap.add_argument('patches', nargs='*')
    a = ap.parse_args()
    a.tree = os.path.abspath(a.tree)
    os.makedirs(a.work, exist_ok=True)
    res = json.load(open(a.out)) if os.path.exists(a.out) else {}
    if 'baseline' not in res or a.baseline:
        d = build(a.tree, a.work, 'baseline', None, a.bend)
        res['baseline'] = run_cases(d)
        shutil.rmtree(d, ignore_errors=True)
        json.dump(res, open(a.out, 'w'), indent=1)
        print('baseline', res['baseline'], flush=True)
    base = res['baseline']

    def one(p):
        h = header(p); h['path'] = os.path.abspath(p)
        name = h['id'].replace('/', '_')
        try:
            d = build(a.tree, a.work, name, h, a.bend)
            if d is None:
                return h['id'], {'B2': 'NOTAPPLICABLE'}
            ln = run_cases(d)
            shutil.rmtree(d, ignore_errors=True)
            diff = {str(c): [base[str(c)] if str(c) in base else base.get(c), ln[c]] for c in CASES if ln[c] != base.get(str(c), base.get(c))}
            return h['id'], {'B2': 'KILLED' if diff else 'SURVIVED', 'diff': diff}
        except Exception as e:
            shutil.rmtree(os.path.join(a.work, name), ignore_errors=True)
            return h['id'], {'B2': 'ERROR', 'msg': str(e)[:300]}
    todo = [p for p in a.patches if header(p)['id'] not in res]
    with cf.ThreadPoolExecutor(min(a.jobs, 4)) as ex:
        for i, r in ex.map(one, todo):
            res[i] = r
            print(i, r['B2'], list(r.get('diff', {}).items())[:1], flush=True)
            json.dump(res, open(a.out, 'w'), indent=1)


if __name__ == '__main__':
    main()
