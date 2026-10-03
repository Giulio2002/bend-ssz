#!/usr/bin/env python3
"""Round-4 crash hunt: the round-3 lying-object sweep (gen_lie.py) on the size-limit runtime, with claims at the new limits.

    python3 tools/crash_hunt/gen_lie_r4.py gen --repo . --out tools/crash_hunt/lie       (then compile build/ch/lie_<id>, see compile_lie_r4.sh)
    python3 tools/crash_hunt/gen_lie_r4.py run --repo . --out DIR [--jobs 3]

Same programs and verdicts as gen_lie.py (8 words of storage, one operation per run); the claims add NMAX - 1, NMAX, NMAX + 1
(NMAX = 4294967264), 2^32 - 4, 2^32 - 2 and, for each element size es, floor(NMAX / es) * es +- es (the append bound).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gen_lie as L  # noqa: E402

NMAX = 4294967264
UNIT = {'u8': 1, 'u16': 2, 'u32': 4, 'u64': 8, 'u128': 16, 'u256': 32, 'b32': 32, 'b48': 48, 'cell': 2048, 'bool': 1}
_old = L.claims


def claims(s):
    cs = set(_old(s)) | {NMAX - 1, NMAX, NMAX + 1, 2 ** 32 - 4, 2 ** 32 - 2}
    if s['kind'] != 'bit':
        es = UNIT.get(s['kind'], 1)
        b = (NMAX // es) * es
        cs |= {b - es, b, b + es}
    return sorted(c for c in cs if 1 <= c < 2 ** 32)


L.claims = claims

if __name__ == '__main__':
    L.main()
