#!/usr/bin/env python3
"""A container is valid only if every one of its fields is valid (manual spec-mutation audit: c02/05, c06/03, c06/04, c06/05).

    python3 codegen/proofs/slop/container_field_validity.py [--check]

Public counterexample of the fault: `T.SmallTestStruct_serialize(T.SmallTestStruct{70000, 1})` (the constructor builds the object (the checked
setter `_set_f_A` refuses 70000, its unchecked `_go` body and the constructor do not); a container validity that skips the uint16 check lets the serializer
write 70000 as two bytes). For every container name X with a range-checked scalar field (uint8, uint16: the generic test
structs; the Fulu containers have none) proofs/slop/validity/<runtime>_<X>_fields.bend holds

  <X>_serialize_vfields(f, ...)      only for a container whose validity is a Bool computed from its own fields:
      {T.X_valid(T.X{f_A, ...}) == Bool.and(valid_1(f_1), Bool.and(valid_2(f_2), ...)) : Bool}, symbolic in every field.
      The conjunction is built from the schema (codegen/fulu.yaml, the generic inventory): in field order, `u8_valid` for a
      uint8, `u16_valid` for a uint16; every other fixed field (uint32 and wider, bool, byte vectors) has the constant-True
      validity and adds nothing. The generator stops if the generated encoder spells it differently. A mutant that drops,
      swaps or constant-folds the check of one field changes only the left side.
  <X>_serialize_vreject_<field>()    for each such field: the first out-of-range value makes the container invalid
      {T.X_valid(T.X_set_<field>_go(T.X_default(), 65536)) == False{} : Bool} (a Data container; for a container whose validity
      threads its children, the second component of the pair).

They are named so that api_gate files them under serialize_valid (the facade of X's encoder).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import generic_form_schemas as generic  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.collections.object_field_access_laws import qual  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402

RANGE = {1: ('u8_valid', 255), 2: ('u16_valid', 65535)}   # uint size in bytes -> (validity, largest valid value)
CONSTANT_TRUE = ('uint', 'bool', 'bytes')                  # fixed kinds whose validity is True{} (uint size >= 4 here)


def chain(parts):
    """right-nested Bool.and of the conjuncts (True{} for none)"""
    if not parts:
        return 'True{}'
    return parts[0] if len(parts) == 1 else f'Bool.and({parts[0]}, {chain(parts[1:])})'


def ranged(t):
    """[(field, validity, first bad value)] of the range-checked scalar fields of container type t, in order"""
    return [(fn, RANGE[ft.size][0], RANGE[ft.size][1] + 1) for fn, ft in t.fields if ft.kind == 'uint' and ft.size in RANGE]


def expected_conjunction(t):
    """the schema's validity of a fixed container, or None when a field's validity is not one of the known ones"""
    parts = []
    for fn, ft in t.fields:
        if ft.kind == 'uint' and ft.size in RANGE:
            parts.append(f'{RANGE[ft.size][0]}({fn})')
        elif ft.kind == 'bool' or (ft.kind in ('uint', 'bytes') and ft.fixed()):
            continue
        else:
            return None
    return chain(parts)


def laws_of(tx, X, t):
    rng = ranged(t)
    v = tx.get(f'{X}_valid')
    rep = v[1].split(' & ')[0] if v and ' & ' in v[1] else None     # pair-valued: `X & Bool`
    laws = []
    body = re.search(rf'^def {re.escape(X)}_valid\(\+?o: [\w.]+\) -> Bool:\n  match o:\n    case \w+\{{([^}}]*)\}}: (.*)$', tx.text, re.M)
    if body:
        want = expected_conjunction(t)
        got = body.group(2)
        if want is None or want != got:
            raise SystemExit(f'{X}: the encoder validity `{got}` is not the schema conjunction `{want}`')
        decl = re.search(rf'^type {re.escape(X)} is Data:\n  \w+\{{(.*)\}}$', tx.text, re.M)
        fields = [(a.split(':', 1)[0].strip(), a.split(':', 1)[1].strip()) for a in MC.split_top_args(decl.group(1))]
        params = ', '.join(f'{"+" if ty == "U32" else ""}{n}: {qual(ty)}' for n, ty in fields)
        rhs = re.sub(r'(?<![\w.])(\w+_valid)\(', r'T.\1(', want)
        laws.append(f'def {X}_serialize_vfields({params})\n    -> {{T.{X}_valid(T.{X}{{{", ".join(n for n, _ in fields)}}}) == {rhs} : Bool}}:\n  {{==}}')
    for fn, _, bad in rng:
        obj = f'T.{X}_set_{fn}_go(T.{X}_default(), {bad})'
        stmt = f'Pair.snd({qual(rep)}, Bool, T.{X}_valid({obj}))' if rep else f'T.{X}_valid({obj})'
        laws.append(f'def {X}_serialize_vreject_{fn}()\n    -> {{{stmt} == False{{}} : Bool}}:\n  {{==}}')
    return laws


def module(tmod, laws, X):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('container_field_validity'),
         f'# {X}: a container is valid only if every field is valid (manual spec-mutation audit; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        for X, t in names.items():
            if t.kind not in ('container', 'pcontainer') or not ranged(t):
                continue
            laws = laws_of(tx, X, t)
            if laws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_fields')] = module(tmod, laws, X)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'container_field_validity', ('validity',), 'stale container field validity laws: ',
                     'container field validity laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
