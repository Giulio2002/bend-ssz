#!/usr/bin/env python3
"""The first offset of a variable-size container must be exactly its fixed size (manual spec-mutation audit: c03/05).

    python3 codegen/proofs/slop/first_offset_check.py [--check]

Public counterexample: `T.ComplexTestStruct_decode(buf, n)` with the first offset 73 or 75 (the audit found 76 byte strings) instead
of exactly 71: the SSZ spec requires the first offset of a container to equal the size of its fixed part, otherwise the bytes are
malformed. A check `is_le(71, o0)` instead of `is_eq(o0, 71)` accepts them, and no statement pinned the check.

For every container name X whose validator opens with the first-offset check (`X_ok` guards the length, reads the 4-byte offset
at byte P and tests it against the fixed size H; the same generated code path for every variable-size container of the Fulu
schema and the generic test structs), proofs/slop/offsets/<runtime>_<X>_first_offset_generated.bend holds, symbolic in the
buffer, the position and the length,

  <X>_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)
      for a window long enough for the fixed part (hlen), whose first offset reads o0 (e: B.read32 at off + P), and o0 is not H
      (hne): {T.X_ok(buf, off, len) == (b2, False{})}. H and P are the SCHEMA's (the sum of the fixed sizes plus 4 per variable
      field; the position of the first variable field's slot), the generator stops if the generated validator spells them
      differently. The proof rewrites the three guards and closes by computation, so a first-offset test that is not the
      equality with H leaves the rewrite without its subterm and the statement fails.

The name `_decode_first_offset` is filed by api_gate under decode_offsets (the facade of X's decoder).
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
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402


def layout(t):
    """(H, P): the fixed part's size (4 per variable field) and the byte position of the first variable field's offset slot"""
    pos, first = 0, None
    for _, ft in t.fields:
        if ft.fixed():
            pos += ft.fixed_size()
        else:
            first = pos if first is None else first
            pos += 4
    return pos, first


def shapes(tx, X):
    """(H, P) as the generated validator spells them, or None when X's validator does not open with the first-offset check"""
    ok = tx.blk.get(f'{X}_ok', '')
    okl = tx.blk.get(f'{X}_ok_len', '')
    v0 = tx.blk.get(f'{X}_v0', '')
    a = re.search(rf'{re.escape(X)}_ok_len\(U32\.is_le\((\d+), len\), buf, off, len\)$', ok)
    b = re.search(rf'case True\{{\}}: {re.escape(X)}_v0\(off, len, B\.read32\(buf, \(off \+ (\d+) : U32\)\)\)', okl)
    c = re.search(rf'{re.escape(X)}_c0\(U32\.is_eq\(o0, (\d+)\), buf, off, len, o0\)$', v0)
    if not (a and b and c) or a.group(1) != c.group(1):
        return None
    return int(a.group(1)), int(b.group(1))


def law(X, H, P):
    ok = f'T.{X}_ok(buf, off, len)'
    return f'''def {X}_decode_first_offset(buf: B.Buf, +off: U32, +len: U32, b2: B.Buf, +o0: U32,
    hlen: {{U32.is_le({H}, len) == True{{}} : Bool}},
    e: {{B.read32(buf, (off + {P} : U32)) == (b2, o0) : B.Buf & U32}},
    hne: {{U32.is_eq(o0, {H}) == False{{}} : Bool}})
    -> {{{ok} == (b2, False{{}}) : B.Buf & Bool}}:
  %Equal.sym(Bool, U32.is_le({H}, len), True{{}}, hlen) : {{T.{X}_ok_len(_, buf, off, len) == (b2, False{{}}) : B.Buf & Bool}}
  %Equal.sym(B.Buf & U32, B.read32(buf, (off + {P} : U32)), (b2, o0), e) : {{T.{X}_v0(off, len, _) == (b2, False{{}}) : B.Buf & Bool}}
  %Equal.sym(Bool, U32.is_eq(o0, {H}), False{{}}, hne) : {{T.{X}_c0(_, b2, off, len, o0) == (b2, False{{}}) : B.Buf & Bool}}
  {{==}}
'''


def module(tmod, X, text):
    return '\n'.join(['import Base', 'import ../../src/buffer.bend as B', f'import ../../types/{tmod}.bend as T', '',
                      writer.header('first_offset_check'),
                      f'# {X}: the first offset of the container is exactly its fixed size (manual spec-mutation audit; docs/mutation_testing/MUTATION_PROOFS.md).', '',
                      text])


def outputs():
    out = {}
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        for X, t in names.items():
            if t.kind != 'container' or t.fixed():
                continue
            got = shapes(tx, X)
            if got is None:
                continue
            want = layout(t)
            if got != want:
                raise SystemExit(f'{X}: the generated first-offset check is {got}, the schema says {want}')
            out[LAYOUT.module_path('offsets', f'{runtime}_{X}_first_offset')] = module(tmod, X, law(X, *want))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'first_offset_check', ('offsets',), 'stale first offset laws: ', 'first offset laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
