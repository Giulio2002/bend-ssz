#!/usr/bin/env python3
"""Structural validity of the root views (spec/value_domain.bend root_valid).

END_TO_END's root semantics (root_for_legal_type) asks for
Domain.root_valid(VAL(o), Spec.X()) == True for the view VAL(o) = v_X(o) that
each root law uses. codegen/root_laws.py emit_valid proves it for the Fulu
phase-A shapes (proofs/obj/valid_names.bend). This generator proves it for the
other root views, one lemma per shape, under the root law's own hypotheses,

  rv_<p>(+o[, +rp: RN.rp_<p>(o)]) : {VD.root_valid(RN.v_<p>(o), <schema>) == True{} : Bool}

and per name, at its specification schema,

  <Name>_root_valid(+o[, +rp]) : {VD.root_valid(RN.v_<p>(o), Spec.<Name>()) == True{} : Bool}

(the hypotheses are the root law's: its `for +rp: ...` binders, same names/types).

Outputs (named gvalid_* so codegen/e2e_bridge.py's valid_*.bend index does not pick
them up before it handles the generic object API, types/generic_obj.bend):
  proofs/obj/gvalid_gnames.bend the generic phase-A shapes and names (root_gnames.bend)

Library (hand-written): proofs/obj/valid_lib.bend (the uint domains of the one-word
leaves from their representation facts).

    python3 codegen/valid_laws.py [--check]
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import root_laws as RA  # noqa: E402
import root_laws_generic as RG  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OBJ = ROOT / 'proofs/obj'


def vneeds_rp(s):
    """The shape's validity needs a representation fact (uint8/16 fields)."""
    if s.kind in ('u8', 'u16'):
        return True
    if s.kind == 'container':
        return any(vneeds_rp(fs) for _, fs in s.fields)
    return False


def rp_names(s, xs, root='rp'):
    """Destructure lines for the rp chain of a container (as root_laws rs_), and
    the fact names per field index (only of fields whose rp_ is part of it)."""
    reps = [i for i, (_, fs) in enumerate(s.fields) if RA.needs_rep(fs)]
    lines, names, cur = [], {}, root
    for j, i in enumerate(reps):
        if j == len(reps) - 1:
            names[i] = cur
        else:
            lines.append(f'(+r{i}, +k{i}) = {cur}')
            names[i] = f'r{i}'
            cur = f'k{i}'
    return lines, names


def valid_shape(s, w, RN):
    p, k, t = s.p, s.kind, s.t
    R = RA.qual(s.rep)
    E = RA.spec_schema(s)
    rp = vneeds_rp(s)
    head = f'def rv_{p}(+o: {R}' + (f', +rp: {RN}.rp_{p}(o)' if rp else '') + f') -> {{VD.root_valid({RN}.v_{p}(o), {E}) == True{{}} : Bool}}:'
    Z7 = ', '.join(['0'] * 7)
    if k == 'bool':
        w(head + ' {==}')
    elif k == 'u8':
        w(head + ' VL.u8dom(o, rp)')
    elif k == 'u16':
        w(head + ' VL.u16dom(o, rp)')
    elif k == 'u32':
        w(head + ' VL.u32dom(o)')
    elif k == 'u64':
        w(head)
        w('  match o:')
        w('    case O.U64{+lo, +hi}: {==}')
    elif k == 'uwide':
        ws = [f'w{i}' for i in range(s.nw)]
        w(head)
        w('  match o:')
        w(f'    case {RA.pattern(R, ws)}: {{==}}')
    elif k == 'rec' and t.kind == 'bytes':
        w(head + f' {RN}.domain_{p}(o)')
    elif k == 'rec' and t.kind == 'bits' and RA.partial_bits(s):
        nb, nw = t.size, s.nw
        ws = [f'w{i}' for i in range(nw)]
        WL = '[' + ', '.join(ws) + ']'
        wargs = ', '.join(f'+{x}: U32' for x in ws)
        BITS = f'BLP.btk({nb}n, BLP.bitsof({WL}))'
        w(f'def vlh_{p}({wargs}) -> {{Nat.is_le({nb}n, List.length(&2, Bool, BLP.bitsof({WL}))) == True{{}} : Bool}}:')
        w(f'  %Equal.sym(Nat, List.length(&2, Bool, BLP.bitsof({WL})), {RN}.pbl32({WL}), {RN}.plen_bitsof({WL})) :')
        w(f'    {{Nat.is_le({nb}n, _) == True{{}} : Bool}}')
        w('  {==}')
        w(head)
        w('  match o:')
        w(f'    case {RA.pattern(R, ws)}:')
        w(f'      %Equal.sym(Nat, List.length(&2, Bool, {BITS}), {nb}n, {RN}.pbtk_len({nb}n, BLP.bitsof({WL}), vlh_{p}({", ".join(ws)}))) :')
        w(f'        {{Bool.and(Nat.is_lt(0n, {nb}n), Nat.is_eq(_, {nb}n)) == True{{}} : Bool}}')
        w('      {==}')
    elif k == 'rec' and t.kind == 'bits':
        w(head)
        w(f'  %Equal.sym(Nat, List.length(&2, Bool, {RN}.bits_{p}(o)), {t.size}n, {RN}.blen_{p}(o)) :')
        w(f'    {{Bool.and(Nat.is_lt(0n, {t.size}n), Nat.is_eq(_, {t.size}n)) == True{{}} : Bool}}')
        w('  {==}')
    elif k == 'container':
        F_ = s.fields
        n = len(F_)
        xs = [f'x{i}' for i in range(n)]
        w(head)
        w('  match o:')
        w(f'    case {RA.pattern(R, xs)}:')
        rpn = {}
        if rp:
            lines, rpn = rp_names(s, xs)
            for ln in lines:
                w('      ' + ln)

        def rest(i):
            items = 'S.EmptyItems{}'
            chain = 'S.End{}'
            for j in range(n - 1, i - 1, -1):
                items = f'S.Items{{{RN}.v_{F_[j][1].p}({xs[j]}), {items}}}'
                chain = f'S.Chain{{{RA.spec_schema(F_[j][1])}, {chain}}}'
            return f'VD.root_valid({items}, {chain})'
        for i, (f, fs) in enumerate(F_):
            ctx = f'Bool.and(_, {rest(i + 1)})'
            for _ in range(i):
                ctx = f'Bool.and(True{{}}, {ctx})'
            Ei = RA.spec_schema(fs)
            arg = f'{xs[i]}, {rpn[i]}' if vneeds_rp(fs) else xs[i]
            w(f'      %Equal.sym(Bool, VD.root_valid({RN}.v_{fs.p}({xs[i]}), {Ei}), True{{}}, rv_{fs.p}({arg})) :')
            w(f'        {{{ctx} == True{{}} : Bool}}')
        w('      {==}')
    else:
        raise RA.Skip(f'{p}: kind {k}')
    w('')


HEAD_G = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/generic_obj.bend as T',
          'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
          'import ../../spec/value_domain.bend as VD', 'import ./generic_specs.bend as Spec',
          'import ./bitlist_pack.bend as BLP', 'import ./valid_lib.bend as VL', 'import ./root_gnames.bend as RN', '',
          '# GENERATED by codegen/valid_laws.py. Do not edit.',
          '# The generic phase-A root views are structurally valid (spec/value_domain.bend',
          '# root_valid), under the root laws\' own representation facts (rp_<p>).', '']


def emit_gnames():
    names = RG.generic_names()
    RA.PARTIAL_OK = RG.container_partial_bits(names)
    RA.PARTIAL_HOOK = RG.partial_bits_shape
    RA.EXTRA_LEAVES = True
    try:
        g = G.Gen()
        for n, t in names.items():
            g.shape(t)
        good = []
        for s in g.order:
            if s.kind == 'box':
                continue
            try:
                RA.covered(s)
                RA.spec_schema(s)
                good.append(s)
            except RA.Skip:
                pass
        L = list(HEAD_G)
        for s in good:
            valid_shape(s, L.append, 'RN')
        gp = {s.p for s in good}
        law_src = (OBJ / 'root_gnames.bend').read_text()
        for n, t in names.items():
            s = g.shape(t)
            if s.p not in gp or RA.partial_bits(s) or f'law {n}_root_correct:' not in law_src:
                continue
            rp = vneeds_rp(s)
            R = RA.qual(s.rep)
            L.append(f'def {n}_root_valid(+o: {R}' + (f', +rp: RN.rp_{s.p}(o)' if rp else '')
                     + f') -> {{VD.root_valid(RN.v_{s.p}(o), Spec.{n}()) == True{{}} : Bool}}: rv_{s.p}(o' + (', rp)' if rp else ')'))
        return '\n'.join(L) + '\n'
    finally:
        RA.EXTRA_LEAVES = False


def main():
    outs = [(OBJ / 'gvalid_gnames.bend', emit_gnames())]
    if '--check' in sys.argv:
        for path, text in outs:
            if not path.exists() or path.read_text() != text:
                sys.exit(f'{path.relative_to(ROOT)} is stale; run codegen/valid_laws.py')
        print('validity laws are current')
        return
    for path, text in outs:
        if not path.exists() or path.read_text() != text:
            path.write_text(text)


if __name__ == '__main__':
    main()
