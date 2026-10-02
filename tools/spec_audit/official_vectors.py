#!/usr/bin/env python3
"""Validate the reference port (ssz_ref.py) against the OFFICIAL test vectors of the pinned release, so the oracle used by the
differential run is itself checked against independent ground truth: the 5,145 ssz_generic cases and the 295 mainnet/fulu
ssz_static cases of consensus-specs v1.6.1.

    python3 tools/spec_audit/official_vectors.py --repo . --cs ../cs --fx DIR     # DIR holds tests/general/... and tests/mainnet/...
    (DIR: extract tests/general/phase0/ssz_generic/* from general.tar.gz and tests/mainnet/fulu/ssz_static/* from mainnet.tar.gz;
     run with the python of the repository requirements: python-snappy, ruamel.yaml)

valid case: the port decodes, re-encodes to the same bytes and computes the official root; invalid case: the port rejects.
"""
import argparse
import json
import os
import re
import sys

import snappy

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import ssz_ref as S  # noqa: E402
from constants import ref_generic  # noqa: E402
from refparse import Ref  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument('--repo', default='.')
ap.add_argument('--cs', required=True)
ap.add_argument('--fx', required=True)
a = ap.parse_args()
sys.path.insert(0, os.path.join(a.repo, 'tools'))
sys.path.insert(0, a.repo)
from codegen.core import generic as GEN  # noqa: E402

ref, gen = Ref(a.cs), ref_generic(a.cs)
fulu = json.load(open(os.path.join(a.repo, 'types/obj_groups.json')))
owner = GEN.case_names()
bad, tally, skipped = [], {}, 0


def nf_of(name):
    if name in fulu:
        return ref.type_of(name)
    return gen[name][0] if name in gen else None


def check(case, t, d, valid, root_hex):
    data = snappy.decompress(open(os.path.join(d, 'serialized.ssz_snappy'), 'rb').read())
    try:
        v = S.deserialize(t, data)
        ok = True
    except S.Reject:
        ok = False
    key = ('valid' if valid else 'invalid', 'pass')
    if valid:
        good = ok and S.serialize(t, v) == data and S.hash_tree_root(t, v).hex() == root_hex
    else:
        good = not ok
    k = ('valid' if valid else 'invalid', 'pass' if good else 'FAIL')
    tally[k] = tally.get(k, 0) + 1
    if not good:
        bad.append((case, 'valid' if valid else 'invalid', ok))


for case, name in sorted(owner.items()):
    t = nf_of(name)
    d = os.path.join(a.fx, case)
    if t is None:           # a zero-length vector or bit vector: not an SSZ type, every official case is invalid
        skipped += 1
        assert '/invalid/' in case, case
        continue
    valid = '/valid/' in case
    root = None
    if valid:
        root = re.search(r'0x([0-9a-f]{64})', open(os.path.join(d, 'meta.yaml')).read()).group(1)
    check(case, t, d, valid, root)
base = os.path.join(a.fx, 'tests/mainnet/fulu/ssz_static')
for tname in sorted(os.listdir(base)):
    for sub in sorted(os.listdir(os.path.join(base, tname))):
        for c in sorted(os.listdir(os.path.join(base, tname, sub))):
            d = os.path.join(base, tname, sub, c)
            root = re.search(r'0x([0-9a-f]{64})', open(os.path.join(d, 'roots.yaml')).read()).group(1)
            check('ssz_static/%s/%s/%s' % (tname, sub, c), ref.type_of(tname), d, True, root)
print('official vectors vs port:', {'%s/%s' % k: v for k, v in sorted(tally.items())}, 'zero-length-type invalid cases not run:', skipped)
for b in bad[:20]:
    print('FAIL', b)
sys.exit(1 if bad else 0)
