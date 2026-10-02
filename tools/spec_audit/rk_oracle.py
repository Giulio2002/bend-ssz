#!/usr/bin/env python3
"""Second reference: run the corpus through remerkleable (the ssz implementation of the pyspec), pinned to the commit in
consensus-specs v1.6.1 pyproject.toml (667eab00ecc3c25682c754dd72ad164fa8c1750e), and compare with the markdown port.

    /tmp/sa312/bin/python tools/spec_audit/rk_oracle.py --repo . --cs ../cs --cases DIR/cases.jsonl --out DIR

(Python 3.10-3.12: remerkleable's Container machinery does not import on 3.14, which the server's system python is.)
"""
import argparse
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from remerkleable.basic import boolean, uint8, uint16, uint32, uint64, uint128, uint256  # noqa: E402
from remerkleable.bitfields import Bitlist, Bitvector  # noqa: E402
from remerkleable.byte_arrays import ByteList, ByteVector  # noqa: E402
from remerkleable.complex import Container, List, Vector  # noqa: E402
from remerkleable.progressive import CompatibleUnion, ProgressiveBitlist, ProgressiveContainer, ProgressiveList  # noqa: E402
from constants import ref_generic  # noqa: E402
from refparse import Ref  # noqa: E402

UINT = {8: uint8, 16: uint16, 32: uint32, 64: uint64, 128: uint128, 256: uint256}
CACHE = {}


def rk(t, name='T'):
    k = t[0]
    if k == 'bool':
        return boolean
    if k == 'uint':
        return UINT[t[1]]
    if k == 'bytes':
        return ByteVector[t[1]]
    if k == 'bytelist':
        return ByteList[t[1]]
    if k == 'bitvector':
        return Bitvector[t[1]]
    if k == 'bitlist':
        return Bitlist[t[1]]
    if k == 'vector':
        return Vector[rk(t[1]), t[2]]
    if k == 'list':
        return List[rk(t[1]), t[2]]
    if k == 'proglist':
        return ProgressiveList[rk(t[1])]
    if k == 'progbits':
        return ProgressiveBitlist
    if k in ('container', 'progcontainer'):
        key = repr(t)
        if key not in CACHE:
            ann = {f: rk(ft) for f, ft in t[1]}
            base = Container if k == 'container' else ProgressiveContainer(active_fields=list(t[2]))
            CACHE[key] = type(name + str(len(CACHE)), (base,), {'__annotations__': ann})
        return CACHE[key]
    if k == 'compatunion':
        return CompatibleUnion({s: rk(o) for s, o in zip(t[1], t[2])})
    raise ValueError(k)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--cases', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--types', default='', help='comma separated type names (default: all)')
    ap.add_argument('--skip-types', default='ProgressiveBitsStruct,ProgressiveComplexTestStruct', help='types remerkleable cannot decode in reasonable time/memory (minutes and several GB per case); they are still run by the port and the Bend programs')
    ap.add_argument('--max-len', type=int, default=4000, help='skip cases longer than this (remerkleable is slow and memory-hungry on multi-MB inputs; the port and the Bend programs run them)')
    a = ap.parse_args()
    ref = Ref(a.cs)
    gen = ref_generic(a.cs)
    fulu = json.load(open(os.path.join(a.repo, 'types/obj_groups.json')))
    cases = [json.loads(l) for l in open(a.cases)]
    types, dis, tally = {}, [], collections.Counter()
    for done, c in enumerate(cases):
        if done % 4000 == 0:
            print("progress", done, "of", len(cases), file=sys.stderr, flush=True)
        if c['hex'] is None or c['len'] > a.max_len or (a.types and c['type'] not in a.types.split(',')) or c['type'] in a.skip_types.split(','):
            continue
        n = c['type']
        if n not in types:
            nf = ref.type_of(n) if n in fulu else gen[n][0]
            types[n] = rk(nf, n.replace('-', '_'))
        typ = types[n]
        data = bytes.fromhex(c['hex'])
        try:
            v = typ.decode_bytes(data)
            ok = True
            root = v.hash_tree_root().hex()
            canon = v.encode_bytes() == data
        except Exception as e:                  # noqa: BLE001  any exception is a rejection
            ok, root, canon, err = False, None, None, repr(e)[:80]
        rv = c['verdict']
        kind = None
        if rv == 'accept' and not ok:
            kind = 'markdown port accepts, remerkleable rejects'
        elif rv == 'reject' and ok:
            kind = 'markdown port rejects, remerkleable accepts'
        elif rv == 'accept' and ok and root != c['root']:
            kind = 'both accept, roots differ'
        elif ok and not canon:
            kind = 'remerkleable accepts, re-encoding differs from input'
        tally[(rv, 'accept' if ok else 'reject', 'AGREE' if kind is None else 'DISAGREE')] += 1
        if kind:
            dis.append({'kind': kind, 'id': c['id'], 'type': n, 'label': c['label'], 'reason': c['reason'], 'hex': c['hex'][:200]})
    json.dump({'cases': len(cases), 'tally': {'/'.join(k): v for k, v in sorted(tally.items())}, 'disagreements': dis},
              open(os.path.join(a.out, 'rk_oracle.json'), 'w'), indent=1)
    print('cases', len(cases))
    for k, v in sorted(tally.items()):
        print(' ', k, v)
    kinds = collections.Counter(d['kind'] for d in dis)
    print('disagreements', len(dis), dict(kinds))
    shown = collections.Counter()
    for d in dis:
        key = (d['type'], d['kind'])
        shown[key] += 1
        if shown[key] <= 2:
            print(' ', d['kind'], d['id'], d['label'], '|', d['reason'], '|', d['hex'][:50])


if __name__ == '__main__':
    main()
