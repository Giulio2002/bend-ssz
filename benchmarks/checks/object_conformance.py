"""Every official ssz_static case through the typed object API, natively.

build/obj-g<k> (benchmarks/objprog/g<k>.bend, generated) decodes the case into
its typed object, encodes the object into fresh bytes and hashes the object.
A case passes when the decode succeeds, the fresh encoding equals the input
byte for byte, and the root equals roots.yaml.

    python3 benchmarks/checks/object_conformance.py [--only Name,Name]
"""
import collections
import json
import os
import pathlib
import re
import subprocess
import sys

import snappy

from provenance import stamp

ROOT = pathlib.Path(__file__).resolve().parents[2]
os.chdir(ROOT)
groups = json.load(open('types/obj_groups.json'))
cases = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
only = None
if '--only' in sys.argv:
    only = set(sys.argv[sys.argv.index('--only') + 1].split(','))
tmp = pathlib.Path('build/performance/inputs')
tmp.mkdir(parents=True, exist_ok=True)
res = collections.Counter()
fails = []
for c in cases:
    t = c.split('/')[4]
    if only and t not in only:
        continue
    d = pathlib.Path('fixtures') / c
    data = snappy.decompress((d / 'serialized.ssz_snappy').read_bytes())
    want = re.search(r'0x([0-9a-f]{64})', (d / 'roots.yaml').read_text()).group(1)
    f = tmp / 'object.ssz'
    o = tmp / 'object-out.ssz'
    f.write_bytes(data)
    if o.exists():
        o.unlink()
    g = groups[t]
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(g['index']), 'SSZ_OPS': '1',
           'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(o)}
    r = subprocess.run([f"build/obj-g{g['group']}", '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True)
    m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
    got = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')).hex() if m else None
    out = o.read_bytes() if o.exists() else None
    ok_dec = r.returncode == 0 and 'DECODED=1' in r.stdout
    ok_enc = out == data
    ok_root = got == want
    ok = ok_dec and ok_enc and ok_root
    res['pass' if ok else 'fail'] += 1
    if not ok:
        fails.append({'case': c, 'decoded': ok_dec, 'encoding_equal': ok_enc, 'root_equal': ok_root,
                      'stdout': r.stdout[-300:], 'stderr': r.stderr[-300:],
                      'len_in': len(data), 'len_out': None if out is None else len(out)})
print(dict(res), 'types', len({c.split('/')[4] for c in cases if not only or c.split('/')[4] in only}))
for x in fails[:12]:
    print(x)
if not only:
    json.dump({'cases': len(cases), 'result': dict(res), 'failures': fails, 'provenance': stamp(__file__)},
              open('benchmarks/evidence/object_conformance.json', 'w'), indent=1)
sys.exit(1 if fails else 0)
