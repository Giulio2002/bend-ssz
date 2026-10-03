#!/usr/bin/env python3
"""The size ladder: objects whose encoded size is at, below and above the limits, on each tree, one at a time (rt_sizes.sh / size_probe.bend).

    python3 rt_ladder.py --trees main,sl --kit KIT --root SIZELIMIT_RT --out ladder.json [--only bytelist,validators,deposits] [--timeout 1800]

Byte list (proglist_uint8, lazily shared storage): n in 2^31-1, 2^31, 2^31+1, NMAX-1, NMAX, NMAX+1, 2^32-1 (NMAX = 2^32 - 32); per n: size, serialize
(ok, length), unchecked encode (length), hash_tree_root (compared with the root of the reference, computed analytically: every chunk is zero).
BeaconState with n validators / n pending deposits around the 2^31 and the NMAX bound of the whole state (its other fields are a constant
2,737,809 bytes): size, serialize.
Expected (the contract of agent/size-limit): valid iff the size is at most NMAX; refused beyond; main refuses from 2^31 on.
"""
import argparse
import hashlib
import json
import re
import subprocess
import sys

NMAX = 2 ** 32 - 32
BASE = 2737809           # the BeaconState's other fields (the size of the default state, measured)
ES = {'validators': 121, 'deposits': 192}


def H(x):
    return hashlib.sha256(x).digest()


Z = [bytes(32)]
for _ in range(40):
    Z.append(H(Z[-1] + Z[-1]))


def mp(c, k, d):
    """progressive merkleization of c zero chunks, the first subtree holding k chunks (depth d)"""
    if c == 0:
        return bytes(32)
    take = min(c, k)
    return H(mp(c - take, 4 * k, d + 2) + Z[d])


def ref_root(n):
    c = (n + 31) // 32
    return H(mp(c, 1, 0) + n.to_bytes(32, 'little')).hex()


def words_to_hex(s):
    return b''.join(int(x).to_bytes(4, 'big') for x in s.split(',')).hex()


def run(root, tree, case, n, timeout):
    r = subprocess.run(['bash', root + '/kit/rt_sizes.sh', root + '/' + tree, str(case), str(n), str(timeout)], capture_output=True, text=True)
    t = r.stdout.strip()
    m = re.search(r'sec=([\d.]+) :: (.*?) MAXRSS_KB=(\d+)', t)
    return {'raw': t, 'sec': float(m.group(1)) if m else None, 'out': m.group(2).strip() if m else t, 'rss_mb': int(m.group(3)) // 1024 if m else None}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--trees', default='main,sl')
    ap.add_argument('--root', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--only', default='bytelist,validators,deposits')
    ap.add_argument('--timeout', type=int, default=1800)
    a = ap.parse_args()
    rows = []
    sel = a.only.split(',')
    plan = []
    if 'bytelist' in sel:
        for n in (2 ** 31 - 1, 2 ** 31, 2 ** 31 + 1, NMAX - 1, NMAX, NMAX + 1, 2 ** 32 - 1):
            for case in (0, 1, 2, 3):
                plan.append(('bytelist', case, n, n))
    for kind, cs, cz, lo2, lo32 in (('validators', 7, 8, None, None), ('deposits', 5, 9, None, None)):
        if kind not in sel:
            continue
        es = ES[kind]
        for bound in (2 ** 31, NMAX):
            k = (bound - BASE) // es          # the largest n with total <= bound
            for n in (k - 1, k, k + 1):
                plan.append((kind, cz, n, BASE + es * n))
                plan.append((kind, cs, n, BASE + es * n))
    for kind, case, n, size in plan:
        for tree in a.trees.split(','):
            r = run(a.root, tree, case, n, a.timeout)
            r.update({'kind': kind, 'case': case, 'n': n, 'size': size, 'tree': tree, 'expect_valid': size <= NMAX})
            if kind == 'bytelist' and case == 3:
                m = re.search(r'root=([\d,]+)', r['out'])
                r['root_ok'] = (words_to_hex(m.group(1)) == ref_root(n)) if m else None
            rows.append(r)
            print(tree, kind, 'case', case, 'n', n, 'size', size, '->', r['out'][:90], r['sec'], 's', r['rss_mb'], 'MB', r.get('root_ok', ''), flush=True)
            json.dump(rows, open(a.out, 'w'), indent=1)


if __name__ == '__main__':
    sys.exit(main())
