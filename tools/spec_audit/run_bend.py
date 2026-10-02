#!/usr/bin/env python3
"""Run a cases.jsonl corpus through the compiled Bend object programs and report every disagreement with the reference.

    python3 tools/spec_audit/run_bend.py --repo . --cases DIR/cases.jsonl --out DIR [--jobs 10]

Uses the same programs and protocol as benchmarks/checks/generic_object_conformance.py: build/obj-x<k> (generic names) and
build/obj-g<k> (Fulu names), SSZ_MODE=0 (decode, re-encode to SSZ_OUTPUT, root), SSZ_INDEX the type index in the group.
Build them first on the server with benchmarks/quick.py --build all and --build-generic all (see docs/SPEC_AUDIT.md).
"""
import argparse
import collections
import json
import os
import re
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor


def run_case(repo, c, tmp):
    prog = os.path.join(repo, 'build', 'obj-%s%d' % ('x' if c['src'] == 'generic' else 'g', c['group']))
    data = bytes.fromhex(c['hex'])
    fd, inp = tempfile.mkstemp(dir=tmp, suffix='.ssz')
    os.write(fd, data)
    os.close(fd)
    out = inp + '.out'
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(c['index']), 'SSZ_OPS': '1', 'SSZ_INPUT': inp, 'SSZ_OUTPUT': out}
    try:
        r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=120)
        accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
        res = {'id': c['id'], 'bend': 'accept' if accepted else 'reject', 'rc': r.returncode}
        if accepted:
            m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
            res['root'] = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')).hex() if m else None
            res['reencode'] = open(out, 'rb').read().hex() if os.path.exists(out) and len(data) < 200000 else None
            res['reencode_equal'] = os.path.exists(out) and open(out, 'rb').read() == data
        else:
            res['stdout_tail'] = r.stdout[-120:]
            res['stderr_tail'] = r.stderr[-120:]
        return res
    except subprocess.TimeoutExpired:
        return {'id': c['id'], 'bend': 'TIMEOUT'}
    finally:
        for p in (inp, out):
            if os.path.exists(p):
                os.unlink(p)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cases', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=10)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    cases = [json.loads(l) for l in open(a.cases)]
    tmp = tempfile.mkdtemp(prefix='specaudit-run-')
    cases = [c for c in cases if c['hex'] is not None]
    with ThreadPoolExecutor(a.jobs) as ex:
        results = list(ex.map(lambda c: run_case(repo, c, tmp), cases))
    os.rmdir(tmp)
    by = {r['id']: r for r in results}
    dis, tally = [], collections.Counter()
    for c in cases:
        r = by[c['id']]
        rv, bv = c['verdict'], r['bend']
        kind = None
        if bv == 'TIMEOUT':
            kind = 'timeout'
        elif rv == 'accept' and bv == 'reject':
            kind = 'reference accepts, Bend rejects'
        elif rv == 'reject' and bv == 'accept':
            kind = 'reference rejects, Bend accepts'
        elif rv == 'accept' and bv == 'accept':
            if not r['reencode_equal']:
                kind = 'accepted, re-encoding differs from input'
            elif r['root'] != c['root']:
                kind = 'accepted, hash_tree_root differs'
        elif rv.startswith('ACCEPTED-BUT'):
            kind = 'reference port is not canonical on this case (port bug)'
        tally[(rv, bv, 'AGREE' if kind is None else 'DISAGREE')] += 1
        if kind:
            dis.append({'kind': kind, **{k: c[k] for k in ('id', 'type', 'label', 'len', 'reason', 'root')}, 'hex': c['hex'][:400], 'bend': r})
    json.dump({'cases': len(cases), 'tally': {'/'.join(k): v for k, v in sorted(tally.items())}, 'disagreements': dis}, open(os.path.join(a.out, 'bend_runtime.json'), 'w'), indent=1)
    print('cases %d' % len(cases))
    for k, v in sorted(tally.items()):
        print(' ', k, v)
    kinds = collections.Counter(d['kind'] for d in dis)
    print('disagreements %d %s' % (len(dis), dict(kinds)))
    for d in dis[:25]:
        print(' ', d['kind'], d['id'], d['label'], '|', d['reason'], '|', d['hex'][:60])
    return 1 if dis else 0


if __name__ == '__main__':
    sys.exit(main())
