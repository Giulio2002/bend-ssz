"""Malformed variants of every ssz_static case through the typed object API.

The object programs (benchmarks/objprog/g*.bend) decode into the typed object,
then encode and hash it. The expected verdict of each mutated input comes from
the independent Python SSZ oracle codegen/oracle.py (written from the
specification, sharing no code with the generator's output), not from an
assumption that a mutation must be invalid: appending a byte to a variable-size
value can be legal. For inputs the reference calls valid, the object's fresh
encoding must equal the mutated bytes exactly.

    python3 benchmarks/checks/object_mutations.py
"""
import collections
import json
import os
import pathlib
import subprocess
import sys

import snappy

sys.path.insert(0, 'codegen')
import oracle  # noqa: E402
from provenance import stamp  # noqa: E402
import schema  # noqa: E402

TY = dict(schema.load('codegen/fulu.yaml').items())


def legal(t, b):
    # the oracle's parser plus canonicality: an accepted encoding is the only
    # encoding of its value (the same reference tests_generated/fuzz_objects.py uses)
    try:
        v = oracle.parse(t, b)
    except Exception:
        return False
    return oracle.serialize(t, v) == b

groups = json.load(open('types/obj_groups.json'))
cases = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
tmp = pathlib.Path('build/performance/inputs')
tmp.mkdir(parents=True, exist_ok=True)
tally = collections.Counter()
bad = []
for c in cases:
    t = c.split('/')[4]
    data = snappy.decompress((pathlib.Path('fixtures') / c / 'serialized.ssz_snappy').read_bytes())
    muts = [('truncated', data[:-1]), ('extended', data + b'\x00')]
    if len(data) >= 4:
        muts.append(('offset_ffffffff', b'\xff\xff\xff\xff' + data[4:]))
    if len(data) >= 1:
        muts.append(('flip_first', bytes([data[0] ^ 0x80]) + data[1:]))
    for k in range(min(16, len(data) // 4)):
        w = (int.from_bytes(data[4 * k:4 * k + 4], 'little') + 1) & 0xffffffff
        muts.append(('word%d_plus1' % k, data[:4 * k] + w.to_bytes(4, 'little') + data[4 * k + 4:]))
    g = groups[t]
    for label, m in muts:
        expect_valid = legal(TY[t], m)
        f = tmp / 'mut.ssz'
        f.write_bytes(m)
        o = tmp / 'mut-out.ssz'
        if o.exists():
            o.unlink()
        env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(g['index']), 'SSZ_OPS': '1',
               'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(o)}
        r = subprocess.run([f"build/obj-g{g['group']}", '--threads', '1', '--gpu', 'off'],
                           env=env, capture_output=True, text=True)
        accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
        ok = accepted == expect_valid
        if ok and expect_valid:
            ok = o.exists() and o.read_bytes() == m
            if not ok:
                label += '/reencode'
        tally[(label.split('/')[0], 'valid' if expect_valid else 'invalid', 'agree' if ok else 'DISAGREE')] += 1
        if not ok:
            bad.append((c, label, expect_valid, accepted, r.returncode))
for k, v in sorted(tally.items()):
    print(v, k)
print('disagreements', len(bad))
for b in bad[:10]:
    print(b)
json.dump({'tally': {' '.join(k): v for k, v in tally.items()}, 'disagreements': bad, 'provenance': stamp(__file__)},
          open('benchmarks/evidence/object_mutations.json', 'w'), indent=1)
sys.exit(1 if bad else 0)
