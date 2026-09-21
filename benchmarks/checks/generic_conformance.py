"""Every official ssz_generic case through the compact primary API, natively.

For each case the schema comes from the frozen tools/test_schemas.py
description of that case (never from its expected outcome), and its index in
build/generic-index.json selects the compact schema in the native programs:

  valid case    build/compact-gdec must accept the bytes (API.validate),
                build/compact-groot must give exactly the root in meta.yaml
                (API.root), and build/compact-genc must re-encode them to the
                same bytes (A.encode after one decode)
  invalid case  build/compact-gdec must reject the bytes (exit 1)

Results go to benchmarks/evidence/generic_conformance.json.
"""
import collections
import json
import os
import pathlib
import re
import subprocess
import sys

import snappy

sys.path.insert(0, 'tools')
import test_schemas as TS  # noqa: E402

index = json.load(open('build/generic-index.json'))['schemas']
position = {json.dumps(s, sort_keys=True, separators=(',', ':')): i for i, s in enumerate(index)}
cases = [c for c in json.load(open('cases.json')) if '/ssz_generic/' in c]
tmp = pathlib.Path('build/performance/inputs')
tmp.mkdir(parents=True, exist_ok=True)
flags = ['--threads', '1', '--gpu', 'off']


def run(program, env):
    return subprocess.run(['build/' + program] + flags, env=env, capture_output=True, text=True)


tally = collections.Counter()
failures = []
for case in cases:
    family = case.split('/')[4]
    valid = '/valid/' in case
    directory = pathlib.Path('fixtures') / case
    data = snappy.decompress((directory / 'serialized.ssz_snappy').read_bytes())
    schema = TS.for_case(case)
    i = position[json.dumps(schema, sort_keys=True, separators=(',', ':'))]
    f = tmp / 'generic.ssz'
    f.write_bytes(data)
    out = tmp / 'generic-out.ssz'
    out.unlink(missing_ok=True)
    env = {**os.environ, 'SSZ_INDEX': str(i), 'SSZ_OPS': '1', 'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
    decoded = run('compact-gdec', env)
    if valid:
        want = re.search(r"0x([0-9a-f]{64})", (directory / 'meta.yaml').read_text()).group(1)
        rooted = run('compact-groot', env)
        encoded = run('compact-genc', env)
        m = re.search(r'ROOTWORDS=([\d,]+)', rooted.stdout)
        got = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')).hex() if m else None
        checks = {
            'accepted': decoded.returncode == 0,
            'root': rooted.returncode == 0 and got == want,
            'roundtrip': encoded.returncode == 0 and out.exists() and out.read_bytes() == data,
        }
    else:
        checks = {'rejected': decoded.returncode != 0 and 'decode rejected' in decoded.stderr}
    ok = all(checks.values())
    tally[(family, 'valid' if valid else 'invalid', 'pass' if ok else 'FAIL')] += 1
    if not ok:
        failures.append({'case': case, 'schema_index': i, 'checks': checks})

for k, v in sorted(tally.items()):
    print(v, *k)
passed = sum(v for k, v in tally.items() if k[2] == 'pass')
print('generic cases', len(cases), 'passed', passed, 'failed', len(failures))
for failure in failures[:15]:
    print(failure)
pathlib.Path('benchmarks/evidence').mkdir(parents=True, exist_ok=True)
json.dump({'cases': len(cases), 'passed': passed,
           'tally': {' '.join(k): v for k, v in sorted(tally.items())}, 'failures': failures},
          open('benchmarks/evidence/generic_conformance.json', 'w'), indent=1)
sys.exit(1 if failures else 0)
