#!/usr/bin/env python3
"""Readable names for every type of the object API: the 109 Fulu names under the fork's prefix and
every form of the official ssz_generic suite (codegen/generic.py's hashed names Gc / Gp / Gu / Gt).

    python3 codegen/names.py            # the full mapping, generated name -> readable name
    python3 codegen/names.py --check    # only the no-collision check

A container, progressive container or compatible union takes the official class name of the
ssz_generic suite: the classes the frozen tools/test_schemas.py reads from the pinned
test_formats/ssz_generic/README.md (the same declarations the official cases' paths name), matched
by their schema's generated name (generic._name of the class's own description). Every other form
takes a structural name: bool, uint8, bitvector_4, bitlist_33, progbitlist, vec_uint16_4,
list_uint8_1024, proglist_bool (an element's name inside, a container element by its class name).
A schema generic.py refuses (a zero-length vector) keeps a structural name and is marked refused.

A Fulu name takes the fork's prefix (codegen/fulu.yaml's `prefix:`, "Fulu"): FuluBeaconState,
FuluAttestation, FuluBytes32, FuluSlot, ... . The fork-independent SSZ basic types keep their plain
names and are shared by the fork and the generic suite: boolean and uint8 .. uint256 (the generic
suite's bool form is named boolean, the same type; inside a compound name the element is spelled
bool: vec_bool_4, proglist_bool).

The check: the readable names are distinct, with one allowed exception: a basic type's name
(boolean, uintN) names the same type in the fork and in the generic suite.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
sys.path.insert(0, str(ROOT / 'tools'))

import generic as GN  # noqa: E402

PREFIX = {'container': 'Gc', 'progressive_container': 'Gp', 'compatible_union': 'Gu'}


def official():
    """{generated name: official class name} of the suite's classes."""
    import test_schemas as TS
    out = {}
    for k, s in TS.TYPES.items():
        if isinstance(s, dict) and s.get('kind') in PREFIX:
            n = GN._name(PREFIX[s['kind']], s)
            if n in out and out[n] != k:
                raise SystemExit(f'two official classes with one schema: {out[n]}, {k}')
            out[n] = k
    return out


def raw_name(s, off):
    """A structural name of a frozen schema description (a class by its official name)."""
    k = s['kind']
    if k in PREFIX:
        n = GN._name(PREFIX[k], s)
        if n not in off:
            raise SystemExit(f'a class schema with no official name: {n}')
        return off[n]
    if k == 'bool':
        return 'bool'    # (a standalone bool form: boolean, see generic_names)
    if k == 'uint':
        return f'uint{8 * s["size"]}'
    if k == 'bytes':
        return f'bytevec_{s["length"]}'
    if k == 'bytelist':
        return f'bytelist_{s["limit"]}'
    if k == 'bits':
        return f'bitvector_{s["length"]}'
    if k == 'bitlist':
        return f'bitlist_{s["limit"]}'
    if k == 'progressive_bits':
        return 'progbitlist'
    if k == 'vector':
        return f'vec_{raw_name(s["element"], off)}_{s["length"]}'
    if k == 'list':
        return f'list_{raw_name(s["element"], off)}_{s["limit"]}'
    if k == 'progressive_list':
        return f'proglist_{raw_name(s["element"], off)}'
    raise SystemExit(f'no structural name for {k!r}')


def walk_raw(s, acc):
    """Every class description inside s (and s), by its generated name."""
    k = s['kind']
    if k in PREFIX:
        acc[GN._name(PREFIX[k], s)] = s
        for sub in (s['options'] if k == 'compatible_union' else [t for _, t in s['fields']]):
            walk_raw(sub, acc)
    elif 'element' in s:
        walk_raw(s['element'], acc)


def generic_names():
    """[(generated name, readable name, status)] for every generic form: each distinct schema of the
    suite (generic.inventory_all's rows) and each class nested in one."""
    off = official()
    rows, seen = [], {}
    inv = GN.inventory_all()
    raws = GN.distinct()
    assert len(inv) == len(raws)
    nested = {}
    for (n, t, err), raw in zip(inv, raws):
        r = 'boolean' if raw['kind'] == 'bool' else raw_name(raw, off)
        rows.append((n, r, 'refused: ' + err if err else ('class' if raw['kind'] in PREFIX else 'form')))
        seen[n] = True
        walk_raw(raw, nested)
    for n, s in sorted(nested.items()):
        if n not in seen:
            rows.append((n, raw_name(s, off), 'class (nested)'))
            seen[n] = True
    return rows


def fulu_names():
    import schema
    return list(schema.load(ROOT / 'codegen/fulu.yaml').keys())


BASIC = {'boolean'} | {f'uint{8 * k}' for k in (1, 2, 4, 8, 16, 32)}


def is_basic(name, t):
    """A fork-independent SSZ basic type under its own name (boolean, uintN)."""
    return name in BASIC and ((t.kind == 'bool' and name == 'boolean') or (t.kind == 'uint' and name == f'uint{8 * t.size}'))


def fulu_readable():
    """{Fulu name: readable name}: the fork's prefix, but on the basic types."""
    import schema
    pre = schema.load_prefix(ROOT / 'codegen/fulu.yaml')
    fd = schema.load(ROOT / 'codegen/fulu.yaml')
    return {n: (n if is_basic(n, t) else pre + n) for n, t in fd.items()}


def mapping():
    """{generated or Fulu name: readable name} over the whole API."""
    out = dict(fulu_readable())
    for n, r, _ in generic_names():
        out[n] = r
    return out


def check():
    rows = generic_names()
    fr = fulu_readable()
    by = {}
    for n, r in fr.items():
        by.setdefault(r, []).append(n)
    for n, r, st in rows:
        by.setdefault(r, []).append(n)
    # the one allowed share: a basic type's name, the fork's and the generic suite's same type
    bad = {r: ns for r, ns in by.items() if len(ns) > 1 and not (r in BASIC and len(ns) == 2 and fr.get(ns[0]) == r)}
    if bad:
        raise SystemExit(f'name collisions: {bad}')
    return rows, fr


if __name__ == '__main__':
    rows, fr = check()
    if '--check' in sys.argv:
        print(f'readable names are distinct ({len(rows)} generic, {len(fr)} Fulu; basic types shared)')
        sys.exit(0)
    print(f'# {len(fr)} Fulu names')
    for n, r in fr.items():
        print(f'{n:40} {r}')
    print(f'# {len(rows)} generic forms ({sum(1 for r in rows if r[2].startswith("class"))} classes)')
    for n, r, st in sorted(rows, key=lambda x: (not x[2].startswith('class'), x[1])):
        print(f'{n:14} {r:48} {st}')
