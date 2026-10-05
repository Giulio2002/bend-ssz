#!/usr/bin/env python3
"""The fixed-part positions and offset slots every container writer step writes at (manual spec-mutation audit, round 10: r10-w01/03, w02/05).

    python3 codegen/proofs/slop/writer_window_laws.py [--check]

Round 10 planted, in BeaconState's writer, the first two fixed fields written at each other's position (w01/03: genesis_time at byte 176,
block_roots at byte 0) and the offsets of two variable fields written into each other's slot (w02/05: historical_roots' offset at slot 524540,
eth1_data_votes' at 524464). The same faults on every other container are killed by the facades and the literal round trips; on BeaconState
every root that holds the writer overflows the checker's stack before a statement can fail, and no literal of its 2.7 MB default fits a law.

For every container X (Fulu and generic) and every step of X's writer (`X_pw<i>`, `X_g<k>_pw<i>`: the steps that write the fixed part and the
offset slots one field at a time; `X_put`, `X_g<k>_put`: a writer of the whole record), proofs/slop/alignment/<runtime>_<X>_writer_win_generated.bend
holds, symbolic in the output array, the position and every field:

  <X>_serialize_vwin_<step>   the step unfolds to the writes the schema asks for: each fixed field f at (pos + p_f), p_f the sum of the
                              fixed sizes (4 for a variable field) of the fields before f, and the offset of each variable field f into its
                              own slot p_f (`_putv(out, pos, p_f, voff, f)`)

The generator checks every position of the generated writer against the schema (codegen/core/fulu_schema_loader.py,
codegen/core/generic_form_schemas.py) and stops on a difference; the statement unfolds one step, so a step that writes a field at another
field's position or slot fails it by name. By computation (`{==}`).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import generic_form_schemas as generic  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402
from codegen.proofs.slop.decode_literal_laws import qualify  # noqa: E402
from codegen.proofs.slop.default_value_laws import record  # noqa: E402

GEN = 'writer_window_laws'
PW = re.compile(r'def (\w+)\((.*), pair: Array<U32> & \((.*) & U32\)\) -> (.*):\n  \(out, r\) = pair\n  \((\w+), (\w+)\) = r\n  (.*)')
PUT = re.compile(r'def (\w+)\(out: Array<U32>, \+pos: U32, (\+voff: U32, )?o: (\w+)\) -> (.*):\n  match o:\n    case (\w+)\{(.*)\}: (.*)')
FIXW = re.compile(r'\(pos \+ (\d+) : U32\), (\w+)\)')
SLOTW = re.compile(r'_putv\(out, pos, (\d+), (\w+), (\w+)\)')


def layout(t):
    """({fixed field: position}, {variable field: slot}) in the fixed part"""
    fix, slot, pos = {}, {}, 0
    for fn, c in t.fields:
        if c.fixed():
            fix[fn] = pos
            pos += c.fixed_size()
        else:
            slot[fn] = pos
            pos += 4
    return fix, slot


def checked(name, body, fix, slot):
    """True when the body writes at least one field; every write is at the schema's position (else stop)"""
    w = FIXW.findall(body)
    s = SLOTW.findall(body)
    for p, f in w:
        if f not in fix or int(p) != fix[f]:
            raise SystemExit(f'{GEN}: {name} writes {f} at {p}, the schema says {fix.get(f, slot.get(f))}')
    for p, _, f in s:
        if f not in slot or int(p) != slot[f]:
            raise SystemExit(f'{GEN}: {name} writes the offset of {f} at {p}, the schema says {slot.get(f, fix.get(f))}')
    return bool(w or s)


def laws_of(tx, X, t, names):
    fix, slot = layout(t)
    out = []
    for name, b in sorted(tx.blk.items()):
        if not re.fullmatch(rf'{re.escape(X)}(_g\d+)?_(pw\d+|put)', name):
            continue
        m = PW.fullmatch(b)
        if m:
            _, prm, A, ret, F, FL, body = m.groups()
            if not checked(name, body, fix, slot):
                continue
            args = ', '.join(p.split(':')[0].strip().lstrip('+') for p in MC.split_top_args(prm))
            out.append(qualify(f'def {X}_serialize_vwin_{name[len(X) + 1:]}({prm}, out: Array<U32>, {F}: {A}, {FL}: U32)\n'
                               f'    -> {{{name}({args}, (out, ({F}, {FL}))) == {body} : {ret}}}:\n  {{==}}', names))
            continue
        m = PUT.fullmatch(b)
        if m:
            _, voff, R, ret, C, binds, body = m.groups()
            if C != R or not checked(name, body, fix, slot):
                continue
            decl = record(tx, R)
            bs = [x.strip() for x in binds.split(',')]
            if decl is None or len(decl) != len(bs) or [x.lstrip('+') for x in bs] != [f for f, _ in decl]:
                raise SystemExit(f'{GEN}: {name}: the case binds {bs}, the record {R} is {decl}')
            prm = ', '.join(f'{x}: {ty}' for x, (_, ty) in zip(bs, decl))
            vo = '+voff: U32, ' if voff else ''
            out.append(qualify(f'def {X}_serialize_vwin_{name[len(X) + 1:]}(out: Array<U32>, +pos: U32, {vo}{prm})\n'
                               f'    -> {{{name}(out, pos, {"voff, " if voff else ""}{R}{{{", ".join(x.lstrip("+") for x in bs)}}}) == {body} : {ret}}}:\n  {{==}}', names))
    return out


def module(tmod, X, laws):
    return '\n'.join(['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
                      writer.header(GEN), f'# {X}: the positions and offset slots of its writer steps (manual spec-mutation audit, round 10; '
                      'docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md).', '', '\n\n'.join(laws), ''])


def outputs():
    out = {}
    fu = dict(schema.load(ROOT / 'codegen/fulu.yaml').items())
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        rtnames = set(tx.blk) | set(re.findall(r'^type (\w+)', tx.text, re.M))
        for X, t in sorted(names.items()):
            if t.kind not in ('container', 'pcontainer') or t.name != X:
                continue
            laws = laws_of(tx, X, t, rtnames)
            if laws:
                out[LAYOUT.module_path('alignment', f'{runtime}_{X}_writer_win')] = module(tmod, X, laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), GEN, ('alignment',), 'stale writer window laws: ', 'writer window laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
