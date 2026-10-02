#!/usr/bin/env python3
"""Decode of the EMPTY byte string, for every name, against the reference.

    python3 tools/spec_audit/run_empty_input.py --repo . --cs ../cs --work DIR [--patch P] [--jobs 4]

The object programs read their input from a file and force its last byte before they start, which an empty file cannot survive: a
corpus of files never reaches a decoder with a window of length 0 at the top level (only inside a container, where the offsets
are checked first). This driver calls the group dispatcher `G.decode(i, buf, 0)` on a buffer of size 0 and prints whether it
accepted. The reference (ssz_ref.deserialize of b'') decides what the answer must be for each of the 240 names (empty lists and
bit-less types aside, every name must refuse). One tiny program per group, built in a private hard-linked copy of its closure.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from run_bytes_cases import closure, BEND  # noqa: E402

PROGRAM = """import Base
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../types/%s.bend as G
import ../benchmarks/compact/objio.bend as IOx

def res(m: Maybe<&1, G.Any>) -> IO(Unit):
  match m:
    case None{}: IO.print("DECODED=0")
    case Some{a}: IO.print("DECODED=1")

def after(pair: B.Buf & Maybe<&1, G.Any>) -> IO(Unit):
  (buf, m) = pair
  res(m)

def main() -> IO(Unit):
  do IO<Unit>:
    +i : U32 <- IOx.env_u32("SSZ_INDEX")
    after(G.decode(i, B.alloc(0), 0))
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--work', required=True)
    ap.add_argument('--patch', default=None)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--out', default=None)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    from cases import verdict
    from constants import ref_generic
    from refparse import Ref
    ref = Ref(a.cs)
    gen = ref_generic(a.cs)
    fork = json.load(open(os.path.join(repo, 'types/obj_groups.json')))
    gi = json.load(open(os.path.join(repo, 'types/generic_obj_index.json')))['generated']
    names = []
    for n, info in sorted(fork.items()):
        names.append((n, 'g', info['group'], info['index'], ref.type_of(n)))
    for n, info in sorted(gi.items()):
        names.append((n, 'x', info['group'], info['index'], gen[n][0]))
    d = os.path.join(os.path.abspath(a.work), 'tree')
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(os.path.join(d, 'build'))
    groups = sorted({(p, k) for _, p, k, _, _ in names})
    mod = {}
    for p, k in groups:
        src = open(os.path.join(repo, 'benchmarks/objprog/%s%d_generated.bend' % (p, k))).read()
        mod[(p, k)] = re.search(r'^import \.\./\.\./types/(\w+)\.bend as G$', src, re.M).group(1)
    files = set()
    for p, k in groups:
        open(os.path.join(d, 'build', 'empty_%s%d.bend' % (p, k)), 'w').write(PROGRAM % mod[(p, k)])
        files |= closure(repo, 'types/%s.bend' % mod[(p, k)]) | closure(repo, 'benchmarks/compact/objio.bend')
    for f in files:
        os.makedirs(os.path.dirname(os.path.join(d, f)), exist_ok=True)
        os.link(os.path.join(repo, f), os.path.join(d, f))
    if a.patch:
        tgt = [l[6:].strip() for l in open(a.patch) if l.startswith('+++ b/')][0]
        dst = os.path.join(d, tgt)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.exists(dst):
            os.unlink(dst)
        shutil.copy(os.path.join(repo, tgt), dst)
        r = subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', os.path.abspath(a.patch)], cwd=d, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError('patch failed: ' + r.stdout + r.stderr)
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    for p, k in groups:
        r = subprocess.run(['nice', '-n', '19', BEND, 'build/empty_%s%d.bend' % (p, k), '-o', os.path.join(d, 'build', 'empty_%s%d' % (p, k))],
                           cwd=d, env=env, capture_output=True, text=True)
        if r.returncode:
            print('compile failed %s%d: %s' % (p, k, (r.stdout + r.stderr)[-300:]))
            return 2

    def one(x):
        n, p, k, idx, t = x
        r = subprocess.run([os.path.join(d, 'build', 'empty_%s%d' % (p, k)), '--threads', '1', '--gpu', 'off'],
                           env={**os.environ, 'SSZ_INDEX': str(idx)}, capture_output=True, text=True, timeout=120)
        got = 'accept' if (r.returncode == 0 and 'DECODED=1' in r.stdout) else 'reject'
        want = verdict(t, b'')[0]
        return (n, want, got) if want != got else None
    with ThreadPoolExecutor(a.jobs) as ex:
        bad = [r for r in ex.map(one, names) if r]
    print('names %d, disagreements %d' % (len(names), len(bad)))
    for b in bad[:20]:
        print('  ', b)
    if a.out:
        json.dump({'names': len(names), 'disagreements': [list(b) for b in bad]}, open(a.out, 'w'), indent=1)
    shutil.rmtree(d, ignore_errors=True)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
