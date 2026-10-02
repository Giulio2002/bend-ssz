#!/usr/bin/env python3
"""Run byte-level cases (cases.jsonl rows) against object programs built from a tree, optionally with one patch applied.

    python3 tools/spec_audit/run_bytes_cases.py --repo . --cases CASES.jsonl --work DIR [--types A,B] [--patch P] [--jobs 4] [--out R.json]

Same protocol as run_bend.py (decode, re-encode to SSZ_OUTPUT, root; reject = non-zero exit), but the programs
(benchmarks/objprog/{g,x}<k>.bend, one per group of the selected types) are compiled here in a private hard-linked copy of their
import closure, with the one file of --patch copied and patched: the mutated trees of the manual spec mutants, or any tree edit
one wants to test against the corpus. --types limits the rows (the names as in cases.jsonl's "type"); the default is every type
in the file. Server only (the Bend runtime compiler, the 2.0.34 release).
"""
import argparse
import collections
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

BEND = os.environ.get('BEND_RUNTIME', '/srv/ssz-optimization/toolchain-2.0.34/bin/bend')


def closure(repo, start):
    seen, todo = set(), [start]
    while todo:
        f = todo.pop()
        if f in seen:
            continue
        seen.add(f)
        for m in re.finditer(r'^import (\S+\.bend)', open(os.path.join(repo, f)).read(), re.M):
            p = os.path.normpath(os.path.join(os.path.dirname(f), m.group(1)))
            if os.path.exists(os.path.join(repo, p)):
                todo.append(p)
    return seen


def build(repo, work, groups, patch):
    d = os.path.join(work, 'tree')
    shutil.rmtree(d, ignore_errors=True)
    files = set()
    for p, k in groups:
        files |= closure(repo, 'benchmarks/objprog/%s%d.bend' % (p, k))
    for f in files:
        os.makedirs(os.path.dirname(os.path.join(d, f)), exist_ok=True)
        os.link(os.path.join(repo, f), os.path.join(d, f))
    if patch:
        tgt = [l[6:].strip() for l in open(patch) if l.startswith('+++ b/')][0]
        dst = os.path.join(d, tgt)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.exists(dst):
            os.unlink(dst)
        shutil.copy(os.path.join(repo, tgt), dst)
        r = subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', os.path.abspath(patch)], cwd=d, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('patch failed: ' + r.stdout + r.stderr)
    os.makedirs(os.path.join(d, 'build'), exist_ok=True)
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    for p, k in groups:
        r = subprocess.run(['nice', '-n', '19', BEND, 'benchmarks/objprog/%s%d.bend' % (p, k), '-o', os.path.join(d, 'build', 'obj-%s%d' % (p, k))],
                           cwd=d, env=env, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('compile failed %s%d: %s' % (p, k, (r.stdout + r.stderr)[-400:]))
    return d


def run_prog(prog, idx, data, tmp):
    fd, inp = tempfile.mkstemp(dir=tmp, suffix='.ssz')
    os.write(fd, data)
    os.close(fd)
    out = inp + '.out'
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(idx), 'SSZ_OPS': '1', 'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}
    try:
        r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=120)
        acc = r.returncode == 0 and 'DECODED=1' in r.stdout
        root = enc = None
        if acc:
            m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
            root = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')).hex() if m else None
            enc = open(out, 'rb').read() if os.path.exists(out) else None
        return acc, root, enc
    except subprocess.TimeoutExpired:
        return 'timeout', None, None
    finally:
        for p in (inp, out):
            if os.path.exists(p):
                os.unlink(p)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cases', required=True)
    ap.add_argument('--work', required=True)
    ap.add_argument('--types', default='')
    ap.add_argument('--patch', default=None)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--out', default=None)
    ap.add_argument('--max-hex', type=int, default=400000)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    want = set(x for x in a.types.split(',') if x)
    cases = []
    for l in open(a.cases):
        c = json.loads(l)
        if (not want or c['type'] in want) and c['hex'] is not None and len(c['hex']) < a.max_hex:
            cases.append(c)
    groups = sorted({('x' if c['src'] == 'generic' else 'g', c['group']) for c in cases})
    os.makedirs(a.work, exist_ok=True)
    d = build(repo, os.path.abspath(a.work), groups, a.patch)
    tmp = tempfile.mkdtemp(prefix='bytes-', dir=a.work)

    def one(c):
        prog = os.path.join(d, 'build', 'obj-%s%d' % ('x' if c['src'] == 'generic' else 'g', c['group']))
        acc, root, enc = run_prog(prog, c['index'], bytes.fromhex(c['hex']), tmp)
        rv, kind = c['verdict'], None
        if acc == 'timeout':
            kind = 'timeout'
        elif rv == 'accept' and not acc:
            kind = 'reference accepts, Bend rejects'
        elif rv == 'reject' and acc:
            kind = 'reference rejects, Bend accepts'
        elif rv == 'accept' and acc:
            if enc != bytes.fromhex(c['hex']):
                kind = 're-encoding differs'
            elif root != c['root']:
                kind = 'root differs'
        return (c['id'], c['label'], kind) if kind else None
    with ThreadPoolExecutor(a.jobs) as ex:
        bad = [r for r in ex.map(one, cases) if r]
    real = [b for b in bad if b[2] != 'timeout']
    kinds = collections.Counter(b[2] for b in bad)
    res = {'cases': len(cases), 'disagreements': len(real), 'kinds': dict(kinds), 'examples': [list(b) for b in real[:8]]}
    if a.out:
        json.dump(res, open(a.out, 'w'), indent=1)
    print('cases %d, disagreements %d %s' % (len(cases), len(real), dict(kinds)))
    for b in real[:10]:
        print('  ', b)
    shutil.rmtree(tmp, ignore_errors=True)
    shutil.rmtree(d, ignore_errors=True)
    return 1 if real else 0


if __name__ == '__main__':
    sys.exit(main())
