"""Every official ssz_generic case through the GENERATED typed object API.

The generated programs are benchmarks/objprog/x<k>.bend over
types/generic_obj*.bend, which codegen/generate.py emits from the frozen
schema descriptions in tools/test_schemas.py (translated by codegen/generic.py).
They are the same generated code the Fulu names use - one shape system, one
validator, one reader, one encoder, one root.

  valid case    the generated validator accepts the bytes, the generated
                reader builds the object, re-encoding the object reproduces
                the input byte for byte, and its root equals meta.yaml
  invalid case  the generated validator rejects the bytes

A schema the generator refuses as not an SSZ type (a zero-length vector, for
instance) has no generated code; every official case for such a schema is an
invalid case and is counted as rejected by construction, which this script
checks rather than assumes.

    python3 benchmarks/checks/generic_object_conformance.py [--only NAME]
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
sys.path.insert(0, str(ROOT / 'codegen'))
sys.path.insert(0, str(ROOT / 'tools'))
import generic as GEN  # noqa: E402

index = json.load(open('types/generic_obj_index.json'))
generated, unsupported = index['generated'], index['unsupported']
# the five generic forms that are also Fulu names (boolean, uint8, uint32, uint64, uint256) have one
# object API, the fork's: their cases run through the Fulu programs (build/obj-g<k>)
fork = json.load(open('types/obj_groups.json'))
owner = GEN.case_names()
cases = [c for c in json.load(open('cases.json')) if '/ssz_generic/' in c]
only = None
if '--only' in sys.argv:
    only = sys.argv[sys.argv.index('--only') + 1]
tmp = pathlib.Path('build/performance/inputs')
tmp.mkdir(parents=True, exist_ok=True)
flags = ['--threads', '1', '--gpu', 'off']

tally = collections.Counter()
failures = []
for case in cases:
    name = owner[case]
    if only and name != only:
        continue
    family = case.split('/')[4]
    valid = '/valid/' in case
    d = pathlib.Path('fixtures') / case
    data = snappy.decompress((d / 'serialized.ssz_snappy').read_bytes())
    if name in unsupported:
        # No generated codec exists for this schema; the suite must only ask
        # for rejections here, which is exactly what "no codec" delivers.
        ok = not valid
        tally[(family, 'valid' if valid else 'invalid', 'pass' if ok else 'FAIL')] += 1
        if not ok:
            failures.append({'case': case, 'schema': name, 'checks': {'unsupported_but_valid': False},
                             'reason': unsupported[name]})
        continue
    g = generated.get(name)
    prog = f"build/obj-x{g['group']}" if g else f"build/obj-g{fork[name]['group']}"
    g = g or fork[name]
    f = tmp / 'generic-object.ssz'
    out = tmp / 'generic-object-out.ssz'
    f.write_bytes(data)
    out.unlink(missing_ok=True)
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(g['index']), 'SSZ_OPS': '1',
           'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
    r = subprocess.run([prog] + flags, env=env, capture_output=True, text=True)
    accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
    if valid:
        want = re.search(r'0x([0-9a-f]{64})', (d / 'meta.yaml').read_text()).group(1)
        m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
        got = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')).hex() if m else None
        checks = {'accepted': accepted,
                  'roundtrip': out.exists() and out.read_bytes() == data,
                  'root': got == want}
    else:
        checks = {'rejected': not accepted}
    ok = all(checks.values())
    tally[(family, 'valid' if valid else 'invalid', 'pass' if ok else 'FAIL')] += 1
    if not ok:
        failures.append({'case': case, 'schema': name, 'group': g['group'], 'index': g['index'],
                         'checks': checks, 'stdout': r.stdout[-200:], 'stderr': r.stderr[-200:]})

for k, v in sorted(tally.items()):
    print(v, *k)
passed = sum(v for k, v in tally.items() if k[2] == 'pass')
total = sum(tally.values())
print('generic cases', total, 'passed', passed, 'failed', len(failures))
for x in failures[:15]:
    print(x)
if not only:
    pathlib.Path('benchmarks/evidence').mkdir(parents=True, exist_ok=True)
    json.dump({'cases': total, 'passed': passed, 'api': 'generated typed object API (types/generic_obj*.bend)',
               'tally': {' '.join(k): v for k, v in sorted(tally.items())},
               'unsupported_schemas': unsupported, 'failures': failures, 'provenance': stamp()},
              open('benchmarks/evidence/generic_object_conformance.json', 'w'), indent=1)
sys.exit(1 if failures else 0)
