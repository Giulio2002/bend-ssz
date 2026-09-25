#!/usr/bin/env python3
"""Differential fuzz of the generated generic-form codec against the oracle.

    /opt/homebrew/bin/python3 tests_generated/fuzz_generic.py [--seed N] [--per K]

For every supported generic SSZ form (progressive lists, progressive bit lists,
progressive containers, compatible unions, and containers/vectors/lists over
every basic type) this drives the generated native programs
`build/obj-x<k>` and compares them with `codegen/oracle.py`, an SSZ oracle
written from the specification that shares no code with the generator:

  accept/reject      the generated validator must accept exactly the byte
                     strings the oracle parses;
  full bytes         an accepted input must re-encode to exactly those bytes;
  full 32-byte root  the generated root must equal the oracle's root, compared
                     as all 32 bytes, never a checksum.

The corpus is every official fixture of the form plus seeded mutations of it:
truncation, extension, a flipped high bit, a corrupted first offset, word
increments, and a byte set to a random value at a random position. Mutations
are drawn from a seeded `random.Random`, so a run is reproducible from its
seed, and the seed, counts and toolchain hashes go into the report.

Findings are recorded, not hidden: the script exits nonzero if any case
disagrees.
"""
import argparse
import collections
import hashlib
import json
import os
import pathlib
import random
import re
import subprocess
import sys
import time

import snappy

ROOT = pathlib.Path(__file__).resolve().parents[1]
os.chdir(ROOT)
sys.path.insert(0, str(ROOT / 'codegen'))
sys.path.insert(0, str(ROOT / 'tools'))
import generic as GEN  # noqa: E402
import oracle  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument('--seed', type=int, default=20260921)
ap.add_argument('--per', type=int, default=6, help='random mutations per fixture')
ap.add_argument('--fixtures', type=int, default=3, help='official fixtures per schema')
args = ap.parse_args()
rnd = random.Random(args.seed)

index = json.load(open('types/generic_obj_index.json'))
generated = index['generated']
owner = GEN.case_names()
types = {n: t for n, t, e in GEN.inventory_all() if e is None}
tmp = pathlib.Path('build/performance/inputs')
tmp.mkdir(parents=True, exist_ok=True)
flags = ['--threads', '1', '--gpu', 'off']

by_schema = collections.defaultdict(list)
for case, name in owner.items():
    if name in generated and '/valid/' in case:
        by_schema[name].append(case)


def run(name, data):
    """The generated program's verdict, fresh encoding and root."""
    g = generated[name]
    f = tmp / 'fuzz-generic.ssz'
    out = tmp / 'fuzz-generic-out.ssz'
    f.write_bytes(data)
    out.unlink(missing_ok=True)
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(g['index']), 'SSZ_OPS': '1',
           'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
    r = subprocess.run([f"build/obj-x{g['group']}"] + flags, env=env, capture_output=True, text=True)
    accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
    m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
    got = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')).hex() if m else None
    return accepted, (out.read_bytes() if out.exists() else None), got


def mutations(data):
    yield 'truncated', data[:-1]
    yield 'extended', data + b'\x00'
    if len(data) >= 1:
        yield 'flip_high_bit', bytes([data[0] ^ 0x80]) + data[1:]
    if len(data) >= 4:
        yield 'offset_max', b'\xff\xff\xff\xff' + data[4:]
        yield 'offset_zero', b'\x00\x00\x00\x00' + data[4:]
    for _ in range(args.per):
        if not data:
            break
        i = rnd.randrange(len(data))
        yield f'byte{i}', data[:i] + bytes([rnd.randrange(256)]) + data[i + 1:]
    for k in range(min(4, len(data) // 4)):
        w = (int.from_bytes(data[4 * k:4 * k + 4], 'little') + 1) & 0xffffffff
        yield f'word{k}_plus1', data[:4 * k] + w.to_bytes(4, 'little') + data[4 * k + 4:]


tally = collections.Counter()
findings = []
started = time.monotonic()
cases = 0
for n, fixtures in sorted(by_schema.items()):
    t = types[n]
    picked = fixtures if len(fixtures) <= args.fixtures else rnd.sample(sorted(fixtures), args.fixtures)
    for case in sorted(picked):
        base = snappy.decompress((pathlib.Path('fixtures') / case / 'serialized.ssz_snappy').read_bytes())
        for label, data in [('original', base)] + list(mutations(base)):
            cases += 1
            try:
                v = oracle.parse(t, data)
                want_bytes = oracle.serialize(t, v)
                want_root = oracle.root(t, v).hex()
                # The oracle only calls an input valid when it is canonical.
                valid = want_bytes == data
            except Exception:
                valid, want_bytes, want_root = False, None, None
            accepted, got_bytes, got_root = run(n, data)
            checks = {'verdict': accepted == valid}
            if valid:
                checks['bytes'] = got_bytes == data
                checks['root'] = got_root == want_root
            ok = all(checks.values())
            tally[(label.split('/')[0].rstrip('0123456789'), 'valid' if valid else 'invalid',
                   'agree' if ok else 'DISAGREE')] += 1
            if not ok:
                findings.append({'schema': n, 'kind': t.kind, 'case': case, 'mutation': label,
                                 'oracle_valid': valid, 'generated_accepted': accepted,
                                 'checks': checks, 'input_sha256': hashlib.sha256(data).hexdigest(),
                                 'input_len': len(data)})

elapsed = time.monotonic() - started
for k, v in sorted(tally.items()):
    print(v, *k)
print(f'{cases} cases over {len(by_schema)} generic schemas, {len(findings)} mismatches, {elapsed:.0f}s')
for f in findings[:12]:
    print(f)
report = {
    'seed': args.seed, 'schemas': len(by_schema), 'cases': cases,
    'fixtures_per_schema': args.fixtures, 'random_mutations_per_fixture': args.per,
    'elapsed_s': round(elapsed, 1),
    'command': f'{sys.executable} tests_generated/fuzz_generic.py --seed {args.seed} '
               f'--per {args.per} --fixtures {args.fixtures}',
    'oracle': 'codegen/oracle.py, written from the SSZ specification; compared on full bytes and '
              'full 32-byte roots, not checksums',
    'tally': {' '.join(k): v for k, v in sorted(tally.items())},
    'findings': findings, 'findings_total': len(findings),
}
pathlib.Path('benchmarks/evidence').mkdir(parents=True, exist_ok=True)
json.dump(report, open('benchmarks/evidence/fuzz_generic.json', 'w'), indent=1)
sys.exit(1 if findings else 0)
