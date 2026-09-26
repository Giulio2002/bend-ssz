#!/usr/bin/env python3
"""Encoder windows of FIXED-SIZE CONTAINERS at any byte position X = 4 q + r.

    python3 codegen/var_rec_enc.py [--check]

proofs/obj/encx_recs.bend (generated): for each fixed container R of RECS (and the fixed
containers nested in them, first), with its words w0 .. w{W-1}:

  PX_R(ws, dd, D, q, r)   the output tree after the runtime's T.R_put at X: the leaf writers'
                          models (vuwd: W64X for uint64, <P>X for the word-vector leaves) and
                          the nested containers' PX, field by field in the runtime's order;
  pf_R                    it is perfect;
  putx_R                  DK.P2( T.R_put(thaw D, X, obj(ws)) == thaw PX_R(..),
                                 BYT(PX_R(..)) == SPL(BYT D, 4 q + r, limbs(ws)) )
                          when the value's 4 W bytes at X are zero and its words fit the tree.

The bytes follow the region invariant of proofs/obj/vuw.bend (inv_init, inv_zero, inv_step):
the region is the value's 4 W bytes, starting as zeros, each field's write splices its limbs at
its offset; the regions' shapes are closed, so each zero window and the final bytes close by
evaluation. The leaves write their data bytes only (vuwd's data-only form), so a record's bytes
are exactly its words' limbs. Positions and room: proofs/obj/vrecx.bend.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))

import var_laws as VL  # noqa: E402

OUT = ROOT / 'proofs/obj/encx_recs.bend'
RECS = ['Withdrawal']
TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'

HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS',
        'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW', 'import ./vuwd.bend as WD', 'import ./vrecx.bend as VRX',
        'import ./dk.bend as DK']


def leaf(k):
    """(model, runtime lemma, bytes lemma, perfect lemma, runtime lemma takes hz) of a leaf field type."""
    if k.kind == 'u64':
        return 'WD.W64X', 'WD.w64_any', 'WD.w64_any_bytes', 'WD.w64x_perfect', False
    P = k.p
    return f'WD.{P.upper()}X', f'WD.{P}_any', f'WD.{P}_any_bytes', f'WD.{P}x_perfect', True


def layout():
    import schema
    import generate as G
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    return g, names


def order(g, names, recs):
    """The records and their nested fixed containers, children first."""
    out = []

    def visit(n, ft):
        for c, k in ft.kids:
            if k.kind == 'container':
                visit(k.s.rep, k)
        if n not in [o[0] for o in out]:
            out.append((n, ft))
    for n in recs:
        visit(n, VL.FT(g, names[n]))
    return out


def rec_text(n, ft):
    W = ft.W
    ws = [f'w{i}' for i in range(W)]
    WSIG = ', '.join(f'+{w}: U32' for w in ws)
    WA = ', '.join(ws)
    Ln = f'{4 * W}n'
    X0 = 'Nat.add(A.quad(q), r)'
    OBJ = ft.obj(ws)
    fields = []
    for c, k in ft.kids:
        kw = ws[c // 4:c // 4 + k.W]
        fields.append((c, k, kw))

    def model(i, inner):
        c, k, kw = fields[i]
        pos = f'Nat.add({c // 4}n, q)'
        if k.kind == 'container':
            return f'PX_{k.s.rep}({", ".join(kw)}, dd, {inner}, {pos}, r)'
        M = leaf(k)[0]
        return f'{M}(r, dd, {inner}, {pos}, {", ".join(kw)})'

    def tree(i):
        t = 'D'
        for j in range(i):
            t = model(j, t)
        return t
    L = []
    w = L.append
    w(f'# ---- {n}: {len(fields)} fields, {4 * W} bytes ----')
    w(f'def PX_{n}({WSIG}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}: {tree(len(fields))}')
    pfs = 'pf'
    for i, (c, k, kw) in enumerate(fields):
        pos = f'Nat.add({c // 4}n, q)'
        if k.kind == 'container':
            pfs = f'pf_{k.s.rep}({", ".join(kw)}, dd, {tree(i)}, {pos}, r, {pfs})'
        else:
            pfs = f'{leaf(k)[3]}(r, dd, {tree(i)}, {pos}, {", ".join(kw)}, {pfs})'
    w(f'def pf_{n}({WSIG}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})')
    w(f'    -> {{FD.array__perfect(U32, dd, PX_{n}({WA}, dd, D, q, r)) == {TRUE}}}:')
    w(f'  {pfs}')
    RT = f'{{T.{n}_put(FD.array__thaw(U32, D), X, {OBJ}) == FD.array__thaw(U32, PX_{n}({WA}, dd, D, q, r)) : Array<U32>}}'
    BY = f'{{UA.BYT(PX_{n}({WA}, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, FX.limbs([{WA}])) : +List<U32>}}'
    w(f'''def RT_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {RT}
def BY_{n}({WSIG}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data: {BY}

# T.{n}_put at X = 4 q + r writes the value's words' limbs into the {4 * W} zero bytes there.
def putx_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {Ln}))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({Ln}, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({Ln}) : +List<U32>}})
    -> DK.P2(RT_{n}({WA}, dd, D, X, q, r), BY_{n}({WA}, dd, D, q, r)):
  +hX = VRX.xstart(q, r, {Ln}, dd, D, pf, hl)
  +I0 = UW.inv_init(UA.BYT(D), {X0}, {Ln}, UW.ZB({Ln}), hz, {{==}})''')
    E = f'UW.ZB({Ln})'
    pf_cur = 'pf'
    rts = []
    for i, (c, k, kw) in enumerate(fields):
        m = 4 * k.W
        pos = f'Nat.add({c // 4}n, q)'
        Di = tree(i)
        Dn = tree(i + 1)
        Xi = f'U32.add(X, {c})'
        w(f'  +ep{i} = VRX.fpos(X, q, r, {c // 4}n, {c}, {Ln}, dd, e, {{==}}, hd, {{==}}, hl)')
        w(f'  +hl{i} = VRX.froom(q, r, dd, {c // 4}n, {m}n, {Ln}, {{==}}, hl)')
        w(f'  +z{i} = UW.inv_zero(UA.BYT(D), {X0}, {Ln}, {E}, {c}n, {m}n, UA.BYT({Di}), hX, I{i}, {{==}}, {{==}}, {{==}})')
        w(f'  +hz{i} = FD.logic__subst(Nat, zz => {{VS.bt({m}n, VS.bdr(zz, UA.BYT({Di}))) == UW.ZB({m}n) : +List<U32>}}, Nat.add({X0}, {c}n), Nat.add(A.quad({pos}), r), VRX.fpx(q, r, {c // 4}n), z{i})')
        if k.kind == 'container':
            w(f'  +g{i} = putx_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r, ep{i}, hr, hd, hl{i}, {pf_cur}, hz{i})')
            rt = f'DK.P2(RT_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r), BY_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r))'
            w(f'  +rt{i} = PA(RT_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r), BY_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r), g{i})')
            w(f'  +by{i} = PB(RT_{k.s.rep}({", ".join(kw)}, dd, {Di}, {Xi}, {pos}, r), BY_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r), g{i})')
            pf_next = f'pf_{k.s.rep}({", ".join(kw)}, dd, {Di}, {pos}, r, {pf_cur})'
        else:
            M, RTL, BYL, PFL, needz = leaf(k)
            if needz:
                w(f'  +rt{i} = {RTL}(dd, {Di}, {Xi}, {pos}, r, {", ".join(kw)}, ep{i}, hr, hd, hl{i}, {pf_cur}, hz{i})')
            else:
                w(f'  +rt{i} = {RTL}(dd, {Di}, {Xi}, {pos}, r, {", ".join(kw)}, ep{i}, hr, hd, hl{i}, {pf_cur})')
            w(f'  +by{i} = {BYL}(dd, {Di}, {Xi}, {pos}, r, {", ".join(kw)}, ep{i}, hr, hd, hl{i}, {pf_cur}, hz{i})')
            pf_next = f'{PFL}(r, dd, {Di}, {pos}, {", ".join(kw)}, {pf_cur})'
        Y = f'FX.limbs([{", ".join(kw)}])'
        w(f'  +hop{i} = FD.logic__subst(Nat, zz => {{UA.BYT({Dn}) == UW.SPL(UA.BYT({Di}), zz, {Y}) : +List<U32>}}, Nat.add(A.quad({pos}), r), Nat.add({X0}, {c}n), Equal.sym(Nat, Nat.add({X0}, {c}n), Nat.add(A.quad({pos}), r), VRX.fpx(q, r, {c // 4}n)), by{i})')
        rr = 4 * W - c - m
        w(f'  +I{i + 1} = UW.inv_step(UA.BYT(D), {X0}, {Ln}, {E}, {c}n, {Y}, {rr}n, UA.BYT({Di}), UA.BYT({Dn}), hX, I{i}, hop{i}, {{==}}, {{==}})')
        E = f'UW.SPL({E}, {c}n, {Y})'
        rts.append((i, c, k, kw, Di, Dn))
        pf_cur = pf_next
    # the runtime chain
    def put_expr(i, inner):
        c, k, kw = fields[i]
        Xi = f'U32.add(X, {c})'
        return f'T.{k.p}_put({inner}, {Xi}, {k.obj(kw)})'

    def outer(i, hole):
        t = hole
        for j in range(i + 1, len(fields)):
            t = put_expr(j, t)
        return t
    w(f'  +byf = FD.logic__subst(+List<U32>, zz => {{UA.BYT(PX_{n}({WA}, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VS.bt({Ln}, {E}), FX.limbs([{WA}]), {{==}}, I{len(fields)})')
    w(f'  (rt_{n}({WA}, dd, D, X, q, r, {", ".join(f"rt{i}" for i in range(len(fields)))}), byf)')
    w('')
    # the runtime lemma (by rewriting the nested puts, innermost first); it precedes putx
    mark = len(L)
    RTP = []
    for i, c, k, kw, Di, Dn in rts:
        lhs = put_expr(i, f'FD.array__thaw(U32, {Di})')
        RTP.append(f'+rt{i}: {{{lhs} == FD.array__thaw(U32, {Dn}) : Array<U32>}}')
    w(f'def rt_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,\n    ' + ',\n    '.join(RTP) + f')\n    -> {RT}:')
    for i, c, k, kw, Di, Dn in rts:
        lhs = put_expr(i, f'FD.array__thaw(U32, {Di})')
        w(f'  %Equal.sym(Array<U32>, {lhs}, FD.array__thaw(U32, {Dn}), rt{i}) :')
        w(f'    {{{outer(i, "_")} == FD.array__thaw(U32, PX_{n}({WA}, dd, D, q, r)) : Array<U32>}}')
    w('  {==}')
    w('')
    text = '\n'.join(L[:mark])
    cut = text.index(f'\n# T.{n}_put at X')
    return text[:cut] + '\n\n' + '\n'.join(L[mark:]) + text[cut:] + '\n'


def module_text():
    g, names = layout()
    L = HEAD + ['', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                '# Encoder windows of fixed-size containers at any byte position (see the generator).', '',
                'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b', '']
    for n, ft in order(g, names, RECS):
        L.append(rec_text(n, ft))
    return '\n'.join(L) + '\n'


def main():
    out = {OUT: module_text()}
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale generated record encoder windows: ' + ', '.join(stale))
            sys.exit(1)
        print('generated record encoder windows are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print(', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
