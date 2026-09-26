#!/usr/bin/env python3
"""Readable names for every type of the object API: the 109 Fulu names (as they are) and every
form of the official ssz_generic suite (codegen/generic.py's hashed names Gc / Gp / Gu / Gt).

    python3 codegen/names.py            # the full mapping, generated name -> readable name
    python3 codegen/names.py --check    # only the no-collision check

A container, progressive container or compatible union takes the official class name of the
ssz_generic suite: the classes the frozen tools/test_schemas.py reads from the pinned
test_formats/ssz_generic/README.md (the same declarations the official cases' paths name), matched
by their schema's generated name (generic._name of the class's own description). Every other form
takes a structural name: bool, uint8, bitvector_4, bitlist_33, progbitlist, vec_uint16_4,
list_uint8_1024, proglist_bool (an element's name inside, a container element by its class name).
A schema generic.py refuses (a zero-length vector) keeps a structural name and is marked refused.

The check: the readable names are distinct, and none is a Fulu name (but a basic type's: uint8 is
Fulu's uint8, the same type).
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
        return 'bool'
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
        rows.append((n, raw_name(raw, off), 'refused: ' + err if err else ('class' if raw['kind'] in PREFIX else 'form')))
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


def mapping():
    """{generated or Fulu name: readable name} over the whole API (Fulu names map to themselves)."""
    out = {n: n for n in fulu_names()}
    for n, r, _ in generic_names():
        out[n] = r
    return out


def check():
    rows = generic_names()
    fulu = set(fulu_names())
    by = {}
    for n, r, st in rows:
        by.setdefault(r, []).append(n)
    bad = {r: ns for r, ns in by.items() if len(ns) > 1}
    # a basic type's name is shared with Fulu's own basic name (the same type: uint8 is uint8)
    import schema
    fd = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = dict((n, r) for n, r, _ in rows)
    clash = sorted(r for r in by if r in fulu and not (fd[r].kind in ('uint', 'bool') and r in ('bool', f'uint{8 * (fd[r].size or 0)}')))
    if bad or clash:
        raise SystemExit(f'name collisions: {bad} {clash}')
    return rows, fulu


if __name__ == '__main__':
    rows, fulu = check()
    if '--check' in sys.argv:
        print(f'readable names are distinct ({len(rows)} generic, {len(fulu)} Fulu)')
        sys.exit(0)
    print(f'# {len(rows)} generic forms ({sum(1 for r in rows if r[2].startswith("class"))} classes), {len(fulu)} Fulu names (unchanged)')
    for n, r, st in sorted(rows, key=lambda x: (not x[2].startswith('class'), x[1])):
        print(f'{n:14} {r:48} {st}')
