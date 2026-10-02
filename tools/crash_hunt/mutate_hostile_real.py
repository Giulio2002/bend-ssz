#!/usr/bin/env python3
"""Crash hunt: the typed-object mutation driver (build/fuzz-f<k>, types/obj_fuzz_ops.json) with extreme indices and seeds.

    python3 tools/crash_hunt/mutate_hostile.py --repo . --out DIR [--jobs 4]

For every Fulu name that has set_elem / append / set_field operations, decode a valid seed (the 'zero' and 'rand0' cases of the
audit sample), apply operation `sel` at index `idx` with seed value `seed`, re-encode, take the root. Findings:
  CRASH  the program did not finish cleanly (signal, abort, timeout, memory cap)
  WRONG  a set_elem accepted an index >= 2^20 (no list or vector of a seed value is that long)
"""
import argparse
import collections
import json
import os
import resource
import subprocess
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

IDX = [0, 1, 2, 31, 32, 33, 127, 128, 129, 1023, 1024, 1025, 4095, 4096, 4097, 65535, 65536, 131071, 131072, 131073, 2**20, 2**31 - 1, 2**31, 2**32 - 2, 2**32 - 1]
SEEDS = [0, 1, 255, 256, 65535, 65536, 2**31, 2**32 - 1]


def run(prog, env, mem_gb, timeout):
    def lim():
        resource.setrlimit(resource.RLIMIT_DATA, (int(mem_gb * 2**30), int(mem_gb * 2**30)))
        os.nice(19)
    try:
        r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=timeout, preexec_fn=lim)
    except subprocess.TimeoutExpired:
        return None, 'timeout', ''
    return r.returncode, r.stdout, r.stderr


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--mem-gb', type=float, default=8)
    ap.add_argument('--timeout', type=int, default=60)
    ap.add_argument('--only', default=None)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    ops = json.load(open(os.path.join(repo, 'types/obj_fuzz_ops.json')))
    seeds = collections.defaultdict(list)
    for l in open(os.path.join(repo, 'tools/spec_audit/data/cases_sample.jsonl')):
        c = json.loads(l)
        if c['verdict'] == 'accept' and c['hex'] is not None and len(c['hex']) < 400000 and c['label'] in ('zero', 'rand0', 'max'):
            seeds[c['type']].append(bytes.fromhex(c['hex']))
    tmp = tempfile.mkdtemp(prefix='mut-', dir=a.out)
    jobs = []
    for name, e in sorted(ops.items()):
        if a.only and name not in a.only.split(','):
            continue
        prog = os.path.join(repo, 'build', 'fuzz-f%d' % e['program'])
        if not e['ops'] or not os.path.exists(prog) or name not in seeds:
            continue
        for si, d in enumerate(seeds[name][:3]):
            for sel, op in enumerate(e['ops']):
                for idx in IDX if op['kind'] in ('set_elem', 'append') else [0]:
                    for sd in SEEDS:
                        jobs.append((name, e['index'], prog, si, d, sel, op, idx, sd))
    print('runs', len(jobs), flush=True)
    tally = collections.Counter()
    findings = []
    nfile = [0]

    def work(j):
        name, index, prog, si, d, sel, op, idx, sd = j
        k = '%s_%d_%d_%d_%d' % (name, si, sel, idx, sd)
        inp = os.path.join(tmp, k + '.in')
        out = inp + '.out'
        open(inp, 'wb').write(d)
        env = {**os.environ, 'SSZ_MODE': '1', 'SSZ_INDEX': str(index), 'SSZ_SEL': str(sel), 'SSZ_IDX': str(idx), 'SSZ_SEED': str(sd),
               'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}
        t0 = time.time()
        rc, so, se = run(prog, env, a.mem_gb, a.timeout)
        for p in (inp, out):
            if os.path.exists(p):
                os.unlink(p)
        return j, rc, so, se, time.time() - t0
    with ThreadPoolExecutor(a.jobs) as ex:
        for j, rc, so, se, sec in ex.map(work, jobs):
            name, index, prog, si, d, sel, op, idx, sd = j
            if rc is None:
                v = 'CRASH'
                why = 'timeout'
            elif rc == 0 and 'ROOTWORDS=' in so:
                v = 'OK'
                why = ''
                if op['kind'] == 'set_elem' and idx >= 2**20 and 'STATUS=1' in so:
                    v = 'WRONG'
                    why = 'set_elem accepted index %d' % idx
            elif rc == 1 and 'DECODED=0' in so:
                v = 'SEED_REJECTED'
                why = ''
            else:
                v = 'CRASH'
                why = 'rc=%s out=%r err=%r' % (rc, so[-100:], se[-200:])
            tally[v] += 1
            if v in ('CRASH', 'WRONG'):
                findings.append({'type': name, 'op': op, 'sel': sel, 'idx': idx, 'seed': sd, 'seedcase': si, 'why': why, 'sec': round(sec, 1)})
    json.dump({'tally': dict(tally), 'findings': findings[:2000]}, open(os.path.join(a.out, 'mutate_hostile.json'), 'w'), indent=1)
    print('DONE', dict(tally), 'findings', len(findings))


if __name__ == '__main__':
    main()
