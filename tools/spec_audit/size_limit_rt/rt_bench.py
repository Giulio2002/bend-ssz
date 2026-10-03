#!/usr/bin/env python3
"""A/B benchmark of two trees' compiled object programs (build/obj-g<k>): deserialize, serialize (the checked writer, whose size pass is
the suspect), hash_tree_root of Fulu types, alternating the two trees, N repetitions, medians and the ratio B / A.

    python3 rt_bench.py --a TREE_A --b TREE_B --reps 5 --out bench.json [--types BeaconState,Attestation,...]

Inputs are the official fixtures of the type (the largest case, `cases.json` + `fixtures/`) or, for a byte list, a seeded synthetic. The number of
operations per run is calibrated once on tree A to a run of about TARGET_MS, then fixed for both trees. Same protocol as benchmarks/run.py:
SSZ_MODE 1 / 2 / 3, SSZ_INDEX, SSZ_OPS, SSZ_INPUT; the program prints MS=<milliseconds>. Server only; run it on a quiet machine (the script prints
the load average before and after and refuses to start above --max-load).
"""
import argparse
import hashlib
import json
import os
import re
import statistics
import subprocess
import sys
import tempfile

import snappy

OPS = {'deserialize': '1', 'serialize': '2', 'hash_tree_root': '3'}
TYPES = ['BeaconState', 'BeaconBlockBody', 'Attestation', 'Checkpoint', 'Transaction', 'Validator']
TARGET_MS = 1000


def load(repo, name):
    groups = json.load(open(os.path.join(repo, 'types/obj_groups.json')))
    cases = [c for c in json.load(open(os.path.join(repo, 'cases.json'))) if c.split('/')[4:5] == [name] and '/ssz_static/' in c]
    best = None
    for c in cases:
        d = os.path.join(repo, 'fixtures', c)
        data = snappy.decompress(open(os.path.join(d, 'serialized.ssz_snappy'), 'rb').read())
        if best is None or len(data) > len(best):
            best = data
    if best is None:
        out, ctr = bytearray(), 0
        while len(out) < 1 << 20:
            out += hashlib.sha256(f'{name}:{ctr}'.encode()).digest()
            ctr += 1
        best = bytes(out[:1 << 20])
    return groups[name], best


def run(repo, group, index, path, mode, ops, out=None):
    env = {**os.environ, 'SSZ_MODE': mode, 'SSZ_INDEX': str(index), 'SSZ_INPUT': path, 'SSZ_OPS': str(ops)}
    if out:
        env['SSZ_OUTPUT'] = out
    r = subprocess.run([os.path.join(repo, 'build', 'obj-g%d' % group), '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True, timeout=1800)
    m = re.search(r'\bMS=(\d+)', r.stdout)
    return (int(m.group(1)) if m else None), r.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--a', required=True)
    ap.add_argument('--b', required=True)
    ap.add_argument('--reps', type=int, default=5)
    ap.add_argument('--out', required=True)
    ap.add_argument('--types', default=','.join(TYPES))
    ap.add_argument('--max-load', type=float, default=10.0)
    a = ap.parse_args()
    load1 = os.getloadavg()[0]
    print('load average at start: %.2f' % load1)
    if load1 > a.max_load:
        print('server too busy (%.2f > %.1f): not starting' % (load1, a.max_load))
        return 3
    res = []
    for name in a.types.split(','):
        grp, data = load(a.a, name)
        fd, path = tempfile.mkstemp(suffix='.ssz')
        os.write(fd, data)
        os.close(fd)
        # the two trees must agree on the input first: decode, re-encode, root
        chk = {}
        for t in (a.a, a.b):
            outp = path + '.out'
            ms, text = run(t, grp['group'], grp['index'], path, '0', 1, outp)
            chk[t] = (open(outp, 'rb').read() == data if os.path.exists(outp) else None, re.search(r'ROOTWORDS=([\d,]+)', text).group(1) if 'ROOTWORDS' in text else None)
        for op, mode in OPS.items():
            ops = 1
            while True:
                ms, _ = run(a.a, grp['group'], grp['index'], path, mode, ops)
                if ms is None or ms >= TARGET_MS or ops > 1 << 24:
                    break
                ops = max(ops * 2, int(ops * TARGET_MS / max(ms, 1) * 1.1))
            samples = {a.a: [], a.b: []}
            for rep in range(a.reps):
                order = (a.a, a.b) if rep % 2 == 0 else (a.b, a.a)
                for t in order:
                    samples[t].append(run(t, grp['group'], grp['index'], path, mode, ops)[0])
            ma, mb = statistics.median(samples[a.a]), statistics.median(samples[a.b])
            row = {'type': name, 'op': op, 'bytes': len(data), 'ops': ops, 'a_ms': samples[a.a], 'b_ms': samples[a.b], 'a_median': ma, 'b_median': mb,
                   'ratio_b_over_a': round(mb / ma, 4) if ma else None, 'same_roundtrip_and_root': chk[a.a] == chk[a.b] and chk[a.a][0] is True}
            res.append(row)
            print('%-16s %-15s ops %-8d A %7.1f ms  B %7.1f ms  B/A %.3f%s' % (name, op, ops, ma, mb, row['ratio_b_over_a'] or 0, '' if row['same_roundtrip_and_root'] else '  (ROUNDTRIP/ROOT DIFFER)'), flush=True)
        os.unlink(path)
    json.dump({'load_start': load1, 'load_end': os.getloadavg()[0], 'rows': res}, open(a.out, 'w'), indent=1)
    print('load average at end: %.2f' % os.getloadavg()[0])
    return 0


if __name__ == '__main__':
    sys.exit(main())
