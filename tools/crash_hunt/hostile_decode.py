#!/usr/bin/env python3
"""Crash hunt: hostile byte strings through the compiled typed-object decode programs (build/obj-g<k>, build/obj-x<k>).

    python3 tools/crash_hunt/hostile_decode.py --repo . --out DIR [--jobs 4] [--limit-seeds N] [--only Name,Name]

Seeds are the accepted cases of tools/spec_audit/data/cases_sample.jsonl (valid encodings of 234 types) plus type-agnostic
synthetic inputs. Mutators (all byte-level, none needs the type): prefix truncations, u32 words overwritten with extreme
values at every plausible offset slot, constant fills at many lengths, byte flips, appended and prepended bytes, union
selector sweeps, bit-list last-byte patterns. The oracle needs no reference: a clean run is a rejection (rc 1, DECODED=0)
or an acceptance whose re-encoding equals the input byte for byte (SSZ is canonical). Anything else is a finding:

  CRASH   signal / abort / non-clean exit code / stack overflow text / memory cap (ulimit -v) / timeout
  WRONG   accepted, but the re-encoding differs from the input
"""
import argparse
import collections
import json
import os
import random
import resource
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
V32 = [0, 1, 3, 4, 8, 0x7FFFFFFF, 0x80000000, 0x80000004, 0xFFFFFFF8, 0xFFFFFFFC, 0xFFFFFFFF, 0x20000000, 0x10000000, 0x40000000]
FILLS = [0x00, 0xFF, 0x01, 0x80, 0x7F]
FILL_LENS = list(range(0, 41)) + [47, 48, 49, 63, 64, 65, 96, 127, 128, 129, 255, 256, 257, 511, 512, 513, 1023, 1024, 1025, 4096, 4097, 65536, 65537]


def u32(v):
    return (v & 0xFFFFFFFF).to_bytes(4, 'little')


def mutations(seed, name, rng):
    n = len(seed)
    out = []
    # truncations
    for k in sorted({0, 1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17, 31, 32, 33, n - 1, n - 2, n - 3, n - 4, n - 5, n // 2, n // 3}):
        if 0 <= k < n:
            out.append(('trunc%d' % k, seed[:k]))
    # appends / prepends
    for extra in (b'\x00', b'\x01', b'\xff', b'\x00' * 3, b'\x00' * 4, b'\x00' * 8, b'\xff' * 4, b'\x80'):
        out.append(('append%d_%02x' % (len(extra), extra[0]), seed + extra))
        out.append(('prepend%d_%02x' % (len(extra), extra[0]), extra + seed))
    # u32 overwrites at plausible offset slots (value in [4, n], multiple of 4) and at the first 8 slots
    slots = []
    for p in range(0, max(0, n - 3), 4):
        v = int.from_bytes(seed[p:p + 4], 'little')
        if (4 <= v <= n and v % 4 == 0 and len(slots) < 14) or p < 32:
            slots.append(p)
    for p in slots[:20]:
        for v in V32 + [n, n + 1, n + 4, max(0, n - 1), 2 * n]:
            m = bytearray(seed)
            m[p:p + 4] = u32(v)
            out.append(('w%d=%x' % (p, v), bytes(m)))
    # byte flips at sampled positions
    if n:
        for p in sorted(set([0, n - 1] + [rng.randrange(n) for _ in range(12)])):
            for b in (0x00, 0x80, 0xFF):
                m = bytearray(seed)
                m[p] = b
                out.append(('flip%d=%02x' % (p, b), bytes(m)))
    # a seed repeated / doubled (list-count growth)
    out.append(('double', seed + seed))
    out.append(('x3', seed * 3))
    return out


def synthetic(name):
    out = []
    for f in FILLS:
        for L in FILL_LENS:
            out.append(('fill%02x_%d' % (f, L), bytes([f]) * L))
    # last-byte patterns for bit lists / delimiter handling
    for L in range(1, 24):
        for last in (0x00, 0x01, 0x02, 0x80, 0xFF):
            out.append(('bl%d_%02x' % (L, last), b'\x00' * (L - 1) + bytes([last])))
            out.append(('blF%d_%02x' % (L, last), b'\xff' * (L - 1) + bytes([last])))
    # offset-table shaped: first word = k*4 then k zero offsets
    for k in (1, 2, 3, 4, 7, 8, 9, 16, 17, 255, 256, 257, 1000, 4096, 65536, 100000):
        out.append(('offtab%d_zero' % k, u32(4 * k) + b'\x00' * (4 * (k - 1))))
        out.append(('offtab%d_inc' % k, b''.join(u32(4 * k + i) for i in range(k))))
        out.append(('offtab%d_same' % k, b''.join(u32(4 * k) for i in range(k))))
    # union selector sweep with a small payload
    if 'Union' in name:
        for s in list(range(0, 8)) + [127, 128, 129, 255]:
            for payload in (b'', b'\x00' * 8, b'\x00' * 40):
                out.append(('sel%d_%d' % (s, len(payload)), bytes([s]) + payload))
    return out


def prog_for(repo, name, groups, generic):
    if name in groups:
        g = groups[name]
        return os.path.join(repo, 'build', 'obj-g%d' % g['group']), g['index']
    if name in generic:
        g = generic[name]
        return os.path.join(repo, 'build', 'obj-x%d' % g['group']), g['index']
    return None, None


def run_one(prog, idx, data, tmp, mem_gb, timeout):
    fd, inp = tempfile.mkstemp(dir=tmp, suffix='.ssz')
    os.write(fd, data)
    os.close(fd)
    out = inp + '.out'
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(idx), 'SSZ_OPS': '1', 'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}

    def lim():
        resource.setrlimit(resource.RLIMIT_AS, (int(mem_gb * 2**30), int(mem_gb * 2**30)))
        os.nice(19)
    t0 = time.time()
    try:
        r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=timeout, preexec_fn=lim)
    except subprocess.TimeoutExpired:
        res = {'v': 'CRASH', 'why': 'timeout %ds' % timeout}
    else:
        so, se = r.stdout, r.stderr
        if r.returncode == 0 and 'DECODED=1' in so:
            same = os.path.exists(out) and open(out, 'rb').read() == data
            res = {'v': 'ACCEPT' if same else 'WRONG', 'why': '' if same else 're-encoding differs from input'}
        elif r.returncode == 1 and 'DECODED=0' in so:
            res = {'v': 'REJECT'}
        else:
            res = {'v': 'CRASH', 'why': 'rc=%d out=%r err=%r' % (r.returncode, so[-120:], se[-200:])}
    res['sec'] = round(time.time() - t0, 3)
    for p in (inp, out):
        if os.path.exists(p):
            os.unlink(p)
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--mem-gb', type=float, default=8)
    ap.add_argument('--timeout', type=int, default=60)
    ap.add_argument('--only', default=None)
    ap.add_argument('--limit-seeds', type=int, default=0, help='accepted seeds per type (0 = all in the sample)')
    ap.add_argument('--seed', type=int, default=1)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    rng = random.Random(a.seed)
    groups = json.load(open(os.path.join(repo, 'types/obj_groups.json')))
    generic = json.load(open(os.path.join(repo, 'types/generic_obj_index.json')))['generated']
    seeds = collections.defaultdict(list)
    for l in open(os.path.join(repo, 'tools/spec_audit/data/cases_sample.jsonl')):
        c = json.loads(l)
        if c['verdict'] == 'accept' and c['hex'] is not None and len(c['hex']) <= 8000:
            seeds[c['type']].append(bytes.fromhex(c['hex']))
    names = sorted(set(groups) | set(generic))
    if a.only:
        names = [n for n in names if n in a.only.split(',')]
    jobs = []
    for nm in names:
        prog, idx = prog_for(repo, nm, groups, generic)
        if not os.path.exists(prog or '/nonexistent'):
            print('skip (no program):', nm, prog)
            continue
        cases = synthetic(nm)
        ss = seeds.get(nm, [])
        if a.limit_seeds:
            ss = ss[:a.limit_seeds]
        for si, s in enumerate(ss):
            for lab, d in mutations(s, nm, rng):
                cases.append(('s%d:%s' % (si, lab), d))
        seen = set()
        for lab, d in cases:
            if d in seen:
                continue
            seen.add(d)
            jobs.append((nm, lab, prog, idx, d))
    os.makedirs(a.out, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix='crashhunt-', dir=a.out)
    print('types %d, runs %d' % (len(names), len(jobs)), flush=True)
    tally = collections.Counter()
    findings = []
    slow = []
    per_type = collections.defaultdict(collections.Counter)

    def work(j):
        nm, lab, prog, idx, d = j
        return j, run_one(prog, idx, d, tmp, a.mem_gb, a.timeout)
    done = 0
    with ThreadPoolExecutor(a.jobs) as ex:
        for j, res in ex.map(work, jobs):
            nm, lab, prog, idx, d = j
            tally[res['v']] += 1
            per_type[nm][res['v']] += 1
            if res['v'] in ('CRASH', 'WRONG'):
                findings.append({'type': nm, 'label': lab, 'len': len(d), 'hex': d[:300].hex(), 'res': res})
            if res['sec'] > 5:
                slow.append({'type': nm, 'label': lab, 'len': len(d), 'sec': res['sec']})
            done += 1
            if done % 5000 == 0:
                print(done, dict(tally), flush=True)
    json.dump({'tally': dict(tally), 'per_type': {k: dict(v) for k, v in per_type.items()}, 'findings': findings[:2000], 'slow': slow[:500]},
              open(os.path.join(a.out, 'hostile_decode.json'), 'w'), indent=1)
    print('DONE', dict(tally), 'findings', len(findings), 'slow', len(slow))


if __name__ == '__main__':
    main()
