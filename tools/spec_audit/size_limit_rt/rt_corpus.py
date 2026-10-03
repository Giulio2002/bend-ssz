#!/usr/bin/env python3
"""Run a cases.jsonl corpus through the compiled object programs of a tree and record, per case, what they answered.

    python3 rt_corpus.py --repo TREE --cases CASES.jsonl --out RESULTS.jsonl [--jobs 4]

One JSON per line: {id, bend: accept|reject|TIMEOUT, root, reencode_sha256, rc}. `rt_diff.py A.jsonl B.jsonl` compares two runs (two trees)
case by case. Same protocol as tools/spec_audit/run_bend.py (programs build/obj-{g,x}<k>, SSZ_MODE=0: decode, re-encode, root).
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
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
        acc = r.returncode == 0 and 'DECODED=1' in r.stdout
        res = {'id': c['id'], 'bend': 'accept' if acc else 'reject', 'rc': r.returncode}
        if acc:
            m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
            res['root'] = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')).hex() if m else None
            res['reencode_sha256'] = hashlib.sha256(open(out, 'rb').read()).hexdigest() if os.path.exists(out) else None
        return res
    except subprocess.TimeoutExpired:
        return {'id': c['id'], 'bend': 'TIMEOUT'}
    finally:
        for p in (inp, out):
            if os.path.exists(p):
                os.unlink(p)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', required=True)
    ap.add_argument('--cases', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--max-hex', type=int, default=400000)
    a = ap.parse_args()
    repo = os.path.abspath(a.repo)
    cases = [json.loads(l) for l in open(a.cases)]
    cases = [c for c in cases if c['hex'] is not None and len(c['hex']) < a.max_hex]
    tmp = tempfile.mkdtemp(prefix='rt-corpus-', dir=os.path.dirname(os.path.abspath(a.out)))
    with ThreadPoolExecutor(a.jobs) as ex, open(a.out, 'w') as f:
        for r in ex.map(lambda c: run_case(repo, c, tmp), cases):
            f.write(json.dumps(r) + '\n')
    os.rmdir(tmp)
    print('cases', len(cases))


if __name__ == '__main__':
    main()
