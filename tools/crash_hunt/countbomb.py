#!/usr/bin/env python3
"""Crash hunt: a count bomb. An ExecutionPayload whose transaction list is an offset table of K empty transactions
(4 bytes of input per element), K up to the limit 2^20 and one above. Wall time and peak RSS per run."""
import json
import os
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import scale_decode_real as S  # noqa: E402
from hostile_decode import u32  # noqa: E402

repo = os.path.abspath(sys.argv[sys.argv.index('--repo') + 1] if '--repo' in sys.argv else '.')
out = sys.argv[sys.argv.index('--out') + 1]
mem = float(sys.argv[sys.argv.index('--mem-gb') + 1]) if '--mem-gb' in sys.argv else 1000
groups = json.load(open(os.path.join(repo, 'types/obj_groups.json')))
name = 'FuluExecutionPayload' if 'FuluExecutionPayload' in groups else 'ExecutionPayload'
g = groups[name]
prog = os.path.join(repo, 'build', 'obj-g%d' % g['group'])
base = bytearray(528)
base[436:440] = u32(528)
base[504:508] = u32(528)
base[508:512] = u32(528)
tmp = tempfile.mkdtemp(prefix='cb-', dir=out)
res = []
for k in (0, 1, 1 << 10, 1 << 16, 1 << 20, (1 << 20) + 1, 1 << 22):
    tx = b''.join(u32(4 * k) for _ in range(k))
    m = bytearray(base)
    m[508:512] = u32(528 + 4 * k)
    r = S.run(prog, g['index'], bytes(m) + tx, tmp, mem, 100)
    r.update(type=name, label='%d empty transactions (offset table %d bytes)' % (k, 4 * k))
    res.append(r)
    print(json.dumps(r), flush=True)
json.dump(res, open(os.path.join(out, 'countbomb.json'), 'w'), indent=1)
