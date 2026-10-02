#!/usr/bin/env python3
"""Compare the dp<k> probe output (serialize(default()) size / checksum, root of default()) with the reference port's zero value.
    python3 tools/crash_hunt/check_defaults.py --repo . --cs CS OUT1 [OUT2 ...]
"""
import argparse, json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'spec_audit'))
import ssz_ref as S
from constants import ref_generic
from refparse import Ref

def cs(b):
    b = b + b'\0' * (-len(b) % 4)
    acc = 7
    for i in range(0, len(b), 4):
        acc = (acc * 31 + int.from_bytes(b[i:i + 4], 'little')) & 0xFFFFFFFF
    return acc

ap = argparse.ArgumentParser(); ap.add_argument('--repo', default='.'); ap.add_argument('--cs', required=True); ap.add_argument('outs', nargs='+')
a = ap.parse_args()
ref = Ref(a.cs); gen = ref_generic(a.cs)
fulu = json.load(open(os.path.join(a.repo, 'types/obj_groups.json')))
want = {}
bad = 0; n = 0; ok = 0
for f in a.outs:
    cur = {}
    for line in open(f):
        line = line.strip()
        if ' ok=' in line:
            name = line.split()[0]; kv = dict(x.split('=') for x in line.split()[1:]); cur.setdefault(name, {}).update(kv)
        elif ' root=' in line:
            name = line.split()[0]; cur.setdefault(name, {})['root'] = line.split('root=')[1]
    for name, d in cur.items():
        nm = name[4:] if name.startswith('Fulu') and name[4:] in fulu else name
        t = ref.type_of(nm) if nm in fulu else gen[nm][0]
        zv = S.zero_value(t)
        ser = S.serialize(t, zv)
        root = S.hash_tree_root(t, zv)
        exp_root = ','.join(str(int.from_bytes(root[i:i + 4], 'big')) for i in range(0, 32, 4))
        n += 1
        probs = []
        if d.get('ok') != '1': probs.append('serialize refused')
        if d.get('size') != str(len(ser)): probs.append('size %s expected %d' % (d.get('size'), len(ser)))
        elif d.get('cs') != str(cs(ser)): probs.append('bytes differ (checksum)')
        if d.get('root') != exp_root: probs.append('root differs')
        if probs:
            bad += 1; print('MISMATCH', name, '; '.join(probs))
        else:
            ok += 1
print('names compared', n, 'ok', ok, 'bad', bad)
