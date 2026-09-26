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


# ---- lists of fixed records ----------------------------------------------------------------------

LISTS = [('ExecutionPayload', 'withdrawals')]


def lfile(p):
    return ROOT / f'proofs/obj/encx_{p}.bend'


def obj_text(VLW, EN, g, rt, walk):
    """The record's words, value, parts (var_rlist_enc.rec_text, without its aligned writer) and its
    object-level window over encx_recs: PXo, pfo, putxo, lenb."""
    txt, ft = EN.rec_text(VLW, g, rt, walk)
    txt = txt[:txt.index('\ndef putR_')] + '\n'
    R, W = rt.name, ft.W
    words = []
    ls, ind = EN.nest(ft, 'o', words, 2)
    body = '\n'.join(ls)
    pad = ' ' * ind
    WA = ', '.join(words)
    RS = 4 * W
    X0 = 'Nat.add(A.quad(q), r)'
    return txt + f'''
# ---- {R}: its writer at any byte position, on the object ----

def PXo_{R}(o: T.{R}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
{body}
{pad}ERC.PX_{R}({WA}, dd, D, q, r)

def pfo_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PXo_{R}(o, dd, D, q, r)) == {TRUE}}}:
{body}
{pad}ERC.pf_{R}({WA}, dd, D, q, r, pf)

def RTo_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{R}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_{R}(o, dd, D, q, r)) : Array<U32>}}
def BYo_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PXo_{R}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, F.limbs(RWD_{R}(o))) : +List<U32>}}

def putxo_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {RS}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({RS}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({RS}n) : +List<U32>}})
    -> DK.P2(RTo_{R}(o, dd, D, X, q, r), BYo_{R}(o, dd, D, q, r)):
{body}
{pad}ERC.putx_{R}({WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)

def lenb_{R}(+o: T.{R}) -> {{VRX.LN(F.limbs(RWD_{R}(o))) == {RS}n : Nat}}:
{body}
{pad}{{==}}
'''


def loop_text(p, R, RS, W, LIM):
    TRR = f'FD.array__Tree<T.{R}>'
    Wn = f'{W}n'
    QJ = f'Nat.add(Nat.mul(j, {Wn}), q)'
    RTP = f'Array<U32> & Array<T.{R}>'
    X0 = 'Nat.add(A.quad(q), r)'
    TH = f'FD.array__thaw(T.{R}, A)'
    return f'''
# ---- {p}: the write loop at X = 4 q + r (record j at byte X + {RS} j) ----

def EL_{p}(+A: {TRR}, +j: Nat) -> T.{R}: VRL.mget(T.{R}, FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), j), T.{R}_default())

def AG_{p}(+A: {TRR}, +i: U32) -> Array<T.{R}> & T.{R}: Array.get(T.{R}, {TH}, i)

# the records j, j + 1, ..., j + k of A written from byte X + {RS} j on
def WX_{p}(k: Nat, +j: Nat, +dd: Nat, D: {TR}, +q: Nat, +r: Nat, +A: {TRR}) -> {TR}:
  match k:
    case 0n: PXo_{R}(EL_{p}(A, j), dd, D, {QJ}, r)
    case 1n+p: WX_{p}(p, 1n+j, dd, PXo_{R}(EL_{p}(A, j), dd, D, {QJ}, r), q, r, A)

law pfWX_{p}:
  for +k: Nat
  for +j: Nat
  for +dd: Nat
  for +D: {TR}
  for +q: Nat
  for +r: Nat
  for +A: {TRR}
  for +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}}
  {{FD.array__perfect(U32, dd, WX_{p}(k, j, dd, D, q, r, A)) == {TRUE}}}
def pfWX_{p}(k, j, dd, D, q, r, A, pf):
  match k:
    case 0n: pfo_{R}(EL_{p}(A, j), dd, D, {QJ}, r, pf)
    case 1n+ +p: pfWX_{p}(p, 1n+j, dd, PXo_{R}(EL_{p}(A, j), dd, D, {QJ}, r), q, r, A, pfo_{R}(EL_{p}(A, j), dd, D, {QJ}, r, pf))

def RTK_{p}(k: Nat, +i: U32, +j: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: {TR}, +A: {TRR}) -> Data:
  {{T.{p}_pt(k, i, X, FD.array__thaw(U32, D), ({TH}, EL_{p}(A, j))) == (FD.array__thaw(U32, WX_{p}(k, j, dd, D, q, r, A)), {TH}) : {RTP}}}
def BYK_{p}(k: Nat, +j: Nat, +q: Nat, +r: Nat, +dd: Nat, +D: {TR}, +A: {TRR}) -> Data:
  {{UA.BYT(WX_{p}(k, j, dd, D, q, r, A)) == UW.SPL(UA.BYT(D), VRX.YP(j, {Wn}, q, r), F.flat(CHW_{p}(1n+k, A, j))) : +List<U32>}}

# The loop from record j (index i) on, k + 1 records, into LT bytes at X whose last k + 1 records' bytes are zero.
def ptx_{p}(k: Nat, +i: U32, +j: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: {TR}, +da: Nat, +A: {TRR}, +LT: Nat,
    +ei: {{U32.to_nat(i) == j : Nat}}, +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +pfD: {{FD.array__perfect(U32, dd, D) == {TRUE}}}, +hj: {{Nat.is_le(A.quad(Nat.mul(Nat.add(1n+k, j), {Wn})), LT) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == {TRUE}}},
    +hz: {{VS.bt(A.quad(Nat.mul(1n+k, {Wn})), VS.bdr(VRX.YP(j, {Wn}, q, r), UA.BYT(D))) == UW.ZB(A.quad(Nat.mul(1n+k, {Wn}))) : +List<U32>}},
    +pfA: {{FD.array__perfect(T.{R}, da, A) == {TRUE}}}, +hda: {{Nat.is_lt(da, 31n) == {TRUE}}}, +hk: {{Nat.is_lt(Nat.add(k, j), VB.pw(da)) == {TRUE}}})
    -> DK.P2(RTK_{p}(k, i, j, X, q, r, dd, D, A), BYK_{p}(k, j, q, r, dd, D, A)):
  match k:
    case 0n:
      +o = EL_{p}(A, j)
      +qj = {QJ}
      +Xj = U32.add(X, U32.mul(i, {RS}))
      +ej = VRX.rpos(X, i, j, 0n, q, r, {Wn}, {RS}, LT, dd, e, {{==}}, ei, hd, hj, hl)
      +hlj = VRX.rroom(j, 0n, q, r, {Wn}, LT, dd, hj, hl)
      +g = putxo_{R}(o, dd, D, Xj, qj, r, ej, hr, hd, hlj, pfD, hz)
      +rt = PA(RTo_{R}(o, dd, D, Xj, qj, r), BYo_{R}(o, dd, D, qj, r), g)
      +by = PB(RTo_{R}(o, dd, D, Xj, qj, r), BYo_{R}(o, dd, D, qj, r), g)
      +D1 = PXo_{R}(o, dd, D, qj, r)
      +Y = F.limbs(RWD_{R}(o))
      +rt0 = Equal.cong(Array<U32>, {RTP}, z => (z, {TH}), T.{R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +by0 = FD.logic__subst(+List<U32>, z => {{UA.BYT(D1) == UW.SPL(UA.BYT(D), VRX.YP(j, {Wn}, q, r), z) : +List<U32>}}, Y, List.append(&2, U32, Y, []),
        Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)), by)
      (rt0, by0)
    case 1n+ +p:
      +o = EL_{p}(A, j)
      +qj = {QJ}
      +Xj = U32.add(X, U32.mul(i, {RS}))
      +ej = VRX.rpos(X, i, j, 1n+p, q, r, {Wn}, {RS}, LT, dd, e, {{==}}, ei, hd, hj, hl)
      +hlj = VRX.rroom(j, 1n+p, q, r, {Wn}, LT, dd, hj, hl)
      +bm = A.quad(Nat.mul(1n+p, {Wn}))
      +B0 = UA.BYT(D)
      +Yj = VRX.YP(j, {Wn}, q, r)
      +hz0 = VRX.zhead({RS}n, bm, VS.bdr(Yj, B0), hz)
      +g = putxo_{R}(o, dd, D, Xj, qj, r, ej, hr, hd, hlj, pfD, hz0)
      +rt = PA(RTo_{R}(o, dd, D, Xj, qj, r), BYo_{R}(o, dd, D, qj, r), g)
      +by = PB(RTo_{R}(o, dd, D, Xj, qj, r), BYo_{R}(o, dd, D, qj, r), g)
      +D1 = PXo_{R}(o, dd, D, qj, r)
      +pf1 = pfo_{R}(o, dd, D, qj, r, pfD)
      +Y = F.limbs(RWD_{R}(o))
      +hX = VRX.xstart(qj, r, {RS}n, dd, D, pfD, hlj)
      +ey = VRX.ynext(j, {Wn}, q, r)
      +z1 = VRX.znext(B0, Yj, Y, VRX.YP(1n+j, {Wn}, q, r), {RS}n, bm, UA.BYT(D1), hX, lenb_{R}(o), ey, by, hz)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hi1 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(da)) == {TRUE}}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
      +hx = FD.logic__subst(Nat, z => {{FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), z) == Some{{EL_{p}(A, 1n+j)}} : Maybe<&2, T.{R}>}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
        VRL.nth_get(T.{R}, FD.array__slots(T.{R}, A), 1n+j, T.{R}_default(), FD.array__len_lt(T.{R}, da, A, 1n+j, pfA, h1)))
      +eg = FD.array__get(T.{R}, da, A, U32.add(i, 1), EL_{p}(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)
      +hj2 = FD.logic__subst(Nat, z => {{Nat.is_le(A.quad(Nat.mul(1n+z, {Wn})), LT) == {TRUE}}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hk2 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(da)) == {TRUE}}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      +ih = ptx_{p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, da, A, LT, ei1, e, hr, hd, pf1, hj2, hl, z1, pfA, hda, hk2)
      +rt2 = PA(RTK_{p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, A), BYK_{p}(p, 1n+j, q, r, dd, D1, A), ih)
      +by2 = PB(RTK_{p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, A), BYK_{p}(p, 1n+j, q, r, dd, D1, A), ih)
      +ea = Equal.cong(Array<U32>, {RTP}, z => T.{p}_pt(p, U32.add(i, 1), X, z, AG_{p}(A, U32.add(i, 1))), T.{R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +eb = Equal.cong(Array<T.{R}> & T.{R}, {RTP}, z => T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), z), AG_{p}(A, U32.add(i, 1)), ({TH}, EL_{p}(A, 1n+j)), eg)
      +rt3 = Equal.trans({RTP}, T.{p}_pt(p, U32.add(i, 1), X, T.{R}_put(FD.array__thaw(U32, D), Xj, o), AG_{p}(A, U32.add(i, 1))), T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_{p}(A, U32.add(i, 1))),
        (FD.array__thaw(U32, WX_{p}(p, 1n+j, dd, D1, q, r, A)), {TH}), ea,
        Equal.trans({RTP}, T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_{p}(A, U32.add(i, 1))), T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), ({TH}, EL_{p}(A, 1n+j))),
          (FD.array__thaw(U32, WX_{p}(p, 1n+j, dd, D1, q, r, A)), {TH}), eb, rt2))
      +rest = F.flat(CHW_{p}(1n+p, A, 1n+j))
      +eXn = Equal.trans(Nat, VRX.YP(1n+j, {Wn}, q, r), Nat.add(Yj, A.quad({Wn})), Nat.add(Yj, VRX.LN(Y)), ey,
        Equal.cong(Nat, Nat, z => Nat.add(Yj, z), A.quad({Wn}), VRX.LN(Y), Equal.sym(Nat, VRX.LN(Y), A.quad({Wn}), lenb_{R}(o))))
      +by3 = Equal.trans(+List<U32>, UA.BYT(WX_{p}(p, 1n+j, dd, D1, q, r, A)), UW.SPL(UA.BYT(D1), VRX.YP(1n+j, {Wn}, q, r), rest), UW.SPL(B0, Yj, VRX.AP(Y, rest)), by2,
        VRX.spl_catx(B0, Yj, Y, rest, VRX.YP(1n+j, {Wn}, q, r), UA.BYT(D1), hX, eXn, by))
      (rt3, by3)

# ---- {p}: the list's encoder window ----

def TDM_{p}(t: {TRR}) -> Nat:
  match t:
    case FD.TLeaf{{x}}: 0n
    case FD.TNode{{l, r}}: 1n+TDM_{p}(l)

# The list object Seq{{thaw(A), N}} and its facts: a perfect tree of depth < 31 holding the N records,
# N within the limit {LIM}.
def THL_{p}(+A: {TRR}, +N: U32) -> T.{p}_Seq: T.{p}_Seq{{{TH}, N}}
def OKL_{p}(+A: {TRR}, +N: U32) -> Bool:
  Bool.and(Nat.is_lt(TDM_{p}(A), 31n), Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM}))))
def okl_d_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{Nat.is_lt(TDM_{p}(A), 31n) == {TRUE}}}:
  and_l(Nat.is_lt(TDM_{p}(A), 31n), Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM}))), h)
def okl_1_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}})
    -> {{Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM}))) == {TRUE}}}:
  and_r(Nat.is_lt(TDM_{p}(A), 31n), Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM}))), h)
def okl_pf_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{FD.array__perfect(T.{R}, TDM_{p}(A), A) == {TRUE}}}:
  and_l(FD.array__perfect(T.{R}, TDM_{p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM})), okl_1_{p}(A, N, h))
def okl_2_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM})) == {TRUE}}}:
  and_r(FD.array__perfect(T.{R}, TDM_{p}(A), A), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM})), okl_1_{p}(A, N, h))
def okl_n_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))) == {TRUE}}}:
  and_l(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM}), okl_2_{p}(A, N, h))
def okl_lim_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{U32.is_le(N, {LIM}) == {TRUE}}}:
  and_r(Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), U32.is_le(N, {LIM}), okl_2_{p}(A, N, h))

# N <= 2^d as the runtime compares it.
def le_cap_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{U32.is_le(N, FD.u32__pow2u(TDM_{p}(A))) == {TRUE}}}:
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(TDM_{p}(A))), Nat.is_le(U32.to_nat(N), U32.to_nat(FD.u32__pow2u(TDM_{p}(A)))), VU.le_u32(N, FD.u32__pow2u(TDM_{p}(A)))) : {{_ == {TRUE}}}
  %Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(TDM_{p}(A))), VB.pw(TDM_{p}(A)), FD.u32__pow2u_value(TDM_{p}(A), FD.nat__lt_trans(TDM_{p}(A), 31n, 32n, okl_d_{p}(A, N, h), {{==}}))) : {{Nat.is_le(U32.to_nat(N), _) == {TRUE}}}
  okl_n_{p}(A, N, h)

# The list's bytes, their count, and the writer's model.
def LL_{p}(+A: {TRR}, +N: U32) -> Nat: A.quad(Nat.mul(U32.to_nat(N), {Wn}))
def ENCL_{p}(+A: {TRR}, +N: U32) -> +List<U32>: F.limbs(RWA_{p}(U32.to_nat(N), A, 0n))
def PUTLb_{p}(b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
  match b:
    case True{{}}: D
    case False{{}}: WX_{p}(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, q, r, A)
def PUTL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}: PUTLb_{p}(U32.is_eq(N, 0), A, N, dd, D, q, r)
def pfLb_{p}(+b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PUTLb_{p}(b, A, N, dd, D, q, r)) == {TRUE}}}:
  match b:
    case True{{}}: pf
    case False{{}}: pfWX_{p}(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, q, r, A, pf)

def RTN_{p}(+b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_pt_nz(b, X, N, FD.array__thaw(U32, D), {TH}) == (FD.array__thaw(U32, PUTLb_{p}(b, A, N, dd, D, q, r)), THL_{p}(A, N)) : Array<U32> & T.{p}_Seq}}
def BYN_{p}(+b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTLb_{p}(b, A, N, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, F.flat(CHW_{p}(U32.to_nat(N), A, 0n))) : +List<U32>}}

# The writer's non-empty test, and its loop.
def ptnz_{p}(+A: {TRR}, +N: U32, +b: Bool, +eb: {{U32.is_eq(N, 0) == b : Bool}}, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_{p}(A, N)))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt(LL_{p}(A, N), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(LL_{p}(A, N)) : +List<U32>}})
    -> DK.P2(RTN_{p}(b, A, N, dd, D, X, q, r), BYN_{p}(b, A, N, dd, D, q, r)):
  match b:
    case True{{}}:
      +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, 0, FD.u32alg__eq_of(N, 0, eb))
      ({{==}}, FD.logic__subst(Nat, z => {{UA.BYT(D) == UW.SPL(UA.BYT(D), {X0}, F.flat(CHW_{p}(z, A, 0n))) : +List<U32>}}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, eN),
        Equal.sym(+List<U32>, UW.SPL(UA.BYT(D), {X0}, []), UA.BYT(D), VRX.spl_nil(UA.BYT(D), {X0}))))
    case False{{}}:
      +c = U32.to_nat(N)
      +da = TDM_{p}(A)
      +pfA = okl_pf_{p}(A, N, h)
      +hda = okl_d_{p}(A, N, h)
      +hca = okl_n_{p}(A, N, h)
      +h1 = VRL.cposu(N, c, {{==}}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hj = FD.logic__subst(Nat, z => {{Nat.is_le(A.quad(Nat.mul(z, {Wn})), LL_{p}(A, N)) == {TRUE}}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), FD.nat__le_refl(LL_{p}(A, N)))
      +hz2 = FD.logic__subst(Nat, z => {{VS.bt(A.quad(Nat.mul(z, {Wn})), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(A.quad(Nat.mul(z, {Wn}))) : +List<U32>}}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hz)
      +hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(da)) == {TRUE}}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {{Nat.is_lt(k, z) == {TRUE}}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      +eg0 = FD.array__get(T.{R}, da, A, 0, EL_{p}(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.{R}, FD.array__slots(T.{R}, A), 0n, T.{R}_default(), FD.array__len_lt(T.{R}, da, A, 0n, pfA, h0)), pfA)
      +g = ptx_{p}(k, 0, 0n, X, q, r, dd, D, da, A, LL_{p}(A, N), {{==}}, e, hr, hd, pf, hj, hl, hz2, pfA, hda, hk)
      +rt = PA(RTK_{p}(k, 0, 0n, X, q, r, dd, D, A), BYK_{p}(k, 0n, q, r, dd, D, A), g)
      +by = PB(RTK_{p}(k, 0, 0n, X, q, r, dd, D, A), BYK_{p}(k, 0n, q, r, dd, D, A), g)
      +ea = Equal.cong(Array<T.{R}> & T.{R}, Array<U32> & T.{p}_Seq, z => T.{p}_pt_fin(N, T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), z)), Array.get(T.{R}, {TH}, 0), ({TH}, EL_{p}(A, 0n)), eg0)
      +eb2 = Equal.cong({RTP}, Array<U32> & T.{p}_Seq, z => T.{p}_pt_fin(N, z), T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), ({TH}, EL_{p}(A, 0n))), (FD.array__thaw(U32, WX_{p}(k, 0n, dd, D, q, r, A)), {TH}), rt)
      (Equal.trans(Array<U32> & T.{p}_Seq, T.{p}_pt_fin(N, T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), Array.get(T.{R}, {TH}, 0))), T.{p}_pt_fin(N, T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), ({TH}, EL_{p}(A, 0n)))),
         T.{p}_pt_fin(N, (FD.array__thaw(U32, WX_{p}(k, 0n, dd, D, q, r, A)), {TH})), ea, eb2),
       FD.logic__subst(Nat, z => {{UA.BYT(WX_{p}(k, 0n, dd, D, q, r, A)) == UW.SPL(UA.BYT(D), {X0}, F.flat(CHW_{p}(z, A, 0n))) : +List<U32>}}, 1n+k, c, e1, by))

# The runtime's validity check of the list.
def valid_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{T.{p}_valid(THL_{p}(A, N)) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}:
  +d = TDM_{p}(A)
  %Equal.sym(Array<T.{R}> & U32, Array.size(T.{R}, {TH}), ({TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.{R}, d, A, okl_pf_{p}(A, N, h))) :
    {{T.{p}_va_cap(Bool.or(False{{}}, U32.is_le(N, {LIM})), N, _) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}
  %Equal.sym(Bool, U32.is_le(N, {LIM}), True{{}}, okl_lim_{p}(A, N, h)) :
    {{(THL_{p}(A, N), Bool.and(Bool.or(False{{}}, _), U32.is_le(N, FD.u32__pow2u(d)))) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{{}}, le_cap_{p}(A, N, h)) :
    {{(THL_{p}(A, N), Bool.and(Bool.or(False{{}}, True{{}}), _)) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}
  {{==}}

def RTL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_putk(FD.array__thaw(U32, D), X, THL_{p}(A, N)) == (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, q, r)), (THL_{p}(A, N), U32.mul(N, {RS}))) : Array<U32> & (T.{p}_Seq & U32)}}
def BYL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTL_{p}(A, N, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, ENCL_{p}(A, N)) : +List<U32>}}
def PFL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{FD.array__perfect(U32, dd, PUTL_{p}(A, N, dd, D, q, r)) == {TRUE}}}

# The runtime's write, with its validity check.
def putk_rt_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +rtb: RTN_{p}(U32.is_eq(N, 0), A, N, dd, D, X, q, r)) -> RTL_{p}(A, N, dd, D, X, q, r):
  %Equal.sym(T.{p}_Seq & Bool, T.{p}_valid(THL_{p}(A, N)), (THL_{p}(A, N), True{{}}), valid_{p}(A, N, h)) :
    {{T.{p}_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, q, r)), (THL_{p}(A, N), U32.mul(N, {RS}))) : Array<U32> & (T.{p}_Seq & U32)}}
  %Equal.sym(Array<U32> & T.{p}_Seq, T.{p}_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), {TH}), (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, q, r)), THL_{p}(A, N)), rtb) :
    {{T.{p}_ptn_fin(N, _) == (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, q, r)), (THL_{p}(A, N), U32.mul(N, {RS}))) : Array<U32> & (T.{p}_Seq & U32)}}
  {{==}}

# putx: the runtime writer at X = 4 q + r is the model PUTL, whose bytes splice the list's bytes
# into D's (its records write their data bytes only), and whose tree is perfect.
def putx_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_{p}(A, N)))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt(LL_{p}(A, N), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(LL_{p}(A, N)) : +List<U32>}})
    -> DK.P2(RTL_{p}(A, N, dd, D, X, q, r), DK.P2(BYL_{p}(A, N, dd, D, q, r), PFL_{p}(A, N, dd, D, q, r))):
  +b = U32.is_eq(N, 0)
  +g = ptnz_{p}(A, N, b, {{==}}, h, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
  +rtb = PA(RTN_{p}(b, A, N, dd, D, X, q, r), BYN_{p}(b, A, N, dd, D, q, r), g)
  +byb = PB(RTN_{p}(b, A, N, dd, D, X, q, r), BYN_{p}(b, A, N, dd, D, q, r), g)
  +by = Equal.trans(+List<U32>, UA.BYT(PUTL_{p}(A, N, dd, D, q, r)), UW.SPL(UA.BYT(D), {X0}, F.flat(CHW_{p}(U32.to_nat(N), A, 0n))), UW.SPL(UA.BYT(D), {X0}, ENCL_{p}(A, N)), byb,
    Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(UA.BYT(D), {X0}, z), F.flat(CHW_{p}(U32.to_nat(N), A, 0n)), ENCL_{p}(A, N), flatW_{p}(U32.to_nat(N), A, 0n)))
  (putk_rt_{p}(A, N, h, dd, D, X, q, r, rtb), (by, pfLb_{p}(b, A, N, dd, D, q, r, pf)))

# ---- sizes ----

# The runtime's size pass.
def sizex_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{T.{p}_size(THL_{p}(A, N)) == (THL_{p}(A, N), U32.mul(N, {RS})) : T.{p}_Seq & U32}}:
  +d = TDM_{p}(A)
  %Equal.sym(Array<T.{R}> & U32, Array.size(T.{R}, {TH}), ({TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.{R}, d, A, okl_pf_{p}(A, N, h))) :
    {{T.{p}_szf(N, _) == (THL_{p}(A, N), U32.mul(N, {RS})) : T.{p}_Seq & U32}}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{{}}, le_cap_{p}(A, N, h)) :
    {{(THL_{p}(A, N), O.pick(_, U32.mul(N, {RS}), 2147483648)) == (THL_{p}(A, N), U32.mul(N, {RS})) : T.{p}_Seq & U32}}
  {{==}}

# szx: the size the writer returns is the list's byte count, when the list lies in the tree.
def szx_{p}(+A: {TRR}, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL_{p}(A, N)))), VB.pw(dd)) == {TRUE}}}) -> {{U32.to_nat(U32.mul(N, {RS})) == LL_{p}(A, N) : Nat}}:
  VRX.mulq(dd, N, U32.to_nat(N), {RS}, {Wn}, {{==}}, {{==}}, hd,
    FD.nat__le_trans(LL_{p}(A, N), Nat.add({X0}, LL_{p}(A, N)), VB.pw(2n+dd), Order.left_below_sum({X0}, LL_{p}(A, N)), VRX.xend(q, r, LL_{p}(A, N), dd, hl)))
'''


def spec_x_text(p, R, W, LIM, sch):
    Wn = f'{W}n'
    TRR = f'FD.array__Tree<T.{R}>'
    LSCH = f'S.ListOf{{{sch}, U32.to_nat({LIM})}}'
    RWA = f'RWA_{p}(U32.to_nat(N), A, 0n)'
    return f'''
# ---- {p}: the spec side ----

# The value of the list: the records' values.
def VALL_{p}(+A: {TRR}, +N: U32) -> S.Value: S.Sequence{{ITW_{p}(U32.to_nat(N), A, 0n)}}

def len_encl_{p}(+A: {TRR}, +N: U32) -> {{List.length(&2, U32, ENCL_{p}(A, N)) == LL_{p}(A, N) : Nat}}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs({RWA})), F.wlen({RWA}), VS.len_limbs({RWA})) : {{_ == LL_{p}(A, N) : Nat}}
  %Equal.sym(Nat, F.wlen({RWA}), A.quad(List.length(&2, U32, {RWA})), VS.wlen_quad({RWA})) : {{_ == LL_{p}(A, N) : Nat}}
  %Equal.sym(Nat, List.length(&2, U32, {RWA}), FD.spec_common__length(U32, {RWA}), VMR.len_eq({RWA})) : {{A.quad(_) == LL_{p}(A, N) : Nat}}
  %Equal.sym(Nat, VF.slen({RWA}), Nat.mul(U32.to_nat(N), {Wn}), lenW_{p}(U32.to_nat(N), A, 0n)) : {{A.quad(_) == LL_{p}(A, N) : Nat}}
  {{==}}

# encx_spec: the list's value has its bytes as one variable part, when they fit a tree of depth dx < 30.
def encx_spec_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dx: Nat, +hdx: {{Nat.is_lt(dx, 30n) == {TRUE}}},
    +hL: {{Nat.is_le(LL_{p}(A, N), A.quad(VB.pw(dx))) == {TRUE}}})
    -> {{Codec.parts(VALL_{p}(A, N), {LSCH}) == Some{{[S.Variable{{ENCL_{p}(A, N)}}]}} : Maybe<&2, +List<S.Part>>}}:
  +hlim = FD.logic__subst(Bool, z => {{z == {TRUE}}}, U32.is_le(N, {LIM}), Nat.is_le(U32.to_nat(N), U32.to_nat({LIM})), VU.le_u32(N, {LIM}), okl_lim_{p}(A, N, h))
  +fit = FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, LL_{p}(A, N), List.length(&2, U32, ENCL_{p}(A, N)), Equal.sym(Nat, List.length(&2, U32, ENCL_{p}(A, N)), LL_{p}(A, N), len_encl_{p}(A, N)),
    VBZ.fitq(dx, LL_{p}(A, N), hL, hdx))
  lpart_{p}(U32.to_nat(N), A, hlim, fit)
'''


# ---- byte lists (O.Words with a bound) -----------------------------------------------------------
# The encoder window of a ByteList[LIM] field, on var_plist_sub's O.Words template (putw_any) with the
# list's validity check O.words_ok(o, 0, LIM, False, 1), over its decoder window (var_vlist's big_vvlb_<p>).
BLISTS = [('bl32', 'Schema70', 32)]


def bl_file(p):
    return ROOT / f'proofs/obj/big_encx_{p}.bend'


def bl_text(p, X, LIM):
    import var_plist_sub as VPS
    import var_win as VW
    valid = f"""
def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {{OKT(dw, T, N) == True{{}} : Bool}})
    -> {{T.{p}_valid(O.Words{{FD.array__thaw(U32, T), N}}) == (O.Words{{FD.array__thaw(U32, T), N}}, True{{}}) : O.Words & Bool}}:
  %Equal.sym(Bool, U32.is_le(N, {LIM}), True{{}}, ok_ex(dw, T, N, h)) :
    {{O.wk_cap(Bool.and(Bool.and(U32.is_le(0, N), Bool.or(False{{}}, _)), O.unit_ok(1, N)), N, Array.size(U32, FD.array__thaw(U32, T))) == (O.Words{{FD.array__thaw(U32, T), N}}, True{{}}) : O.Words & Bool}}
  wok(dw, T, N, 1, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h), {{==}})
"""
    body = VPS.ENCX.replace('@PRE', '').replace('@VALID', valid).replace('@EXTRA', f'U32.is_le(N, {LIM})').replace('@OKDOC', f', at most {LIM} bytes')
    body = body.replace('@CHK', 'ok_ex(dw, T, N, hok)').replace('@X(', f'{X}(').replace('@p_', f'{p}_')
    L = VW.HEADX + ['import ./venc.bend as VE', 'import ./vbenc.bend as VBE', 'import ./vbytes.bend as VYS', 'import ./vua.bend as UA',
                    'import ./vuw.bend as UWW', 'import ./vuwd.bend as VWD', 'import ../compact/reads.bend as RD',
                    f'import ./big_vvlb_{p}.bend as W', '', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                    f'# ByteList[{LIM}] (T.{p}_*) in the encoder-window interface: the list written at any byte position',
                    '# X = 4 q + r of a perfect tree D of depth dd < 29 (vuwd.putw_any / putw_any_bytes; var_plist_sub.ENCX).', '']
    return '\n'.join(L) + body


LHEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
         'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/nat_bytes.bend as N', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
         'import ./spec_fixed.bend as F', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
         'import ./vmr.bend as VMR', 'import ./vfix.bend as VF', 'import ./vua.bend as UA', 'import ./vuw.bend as UW', 'import ./vuwd.bend as WD',
         'import ./vrl.bend as VRL', 'import ./vbsize.bend as VBZ', 'import ./vrecx.bend as VRX', 'import ./encx_recs.bend as ERC', 'import ./dk.bend as DK']

COMMON = """def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:
  (+a, +b) = p
  a
def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:
  (+a, +b) = p
  b
def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case True{}: {==}
    case False{}: h
def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case True{}: h
    case False{}: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
"""


def list_module(g, names, parent, field):
    import var_rlist as VRG
    import var_rlist_enc as EN
    I = VRG.info(g, names, parent, field)
    p, R, RS, W, LIM = I['p'], I['R'], I['RS'], I['W'], I['LIM']
    nd = VL.SL.walk(g, I['rt'], iter(range(100000)))
    sp = EN.spec_list_text(p, R, RS, W, LIM, nd.sch)
    sp = sp[:sp.index('\n# the run of record j lies')] + '\n'
    L = LHEAD + ['', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                 f'# The encoder window of {p} (a list of fixed records) at any byte position (see the generator).', '', COMMON]
    L.append(obj_text(VL, EN, g, I['rt'], (nd.val, nd.sch, nd.proof)))
    L.append(f"def EL_{p}(+A: FD.array__Tree<T.{R}>, +j: Nat) -> T.{R}: VRL.mget(T.{R}, FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), j), T.{R}_default())")
    L.append(sp)
    lt = loop_text(p, R, RS, W, LIM)
    lt = lt.replace(f"def EL_{p}(+A: FD.array__Tree<T.{R}>, +j: Nat) -> T.{R}: VRL.mget(T.{R}, FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), j), T.{R}_default())\n", '')
    L.append(lt)
    L.append(spec_x_text(p, R, W, LIM, nd.sch))
    return p, '\n'.join(L) + '\n'


def main():
    out = {OUT: module_text()}
    g, names = layout()
    for parent, field in LISTS:
        p, t = list_module(g, names, parent, field)
        out[lfile(p)] = t
    if '--no-big' not in sys.argv:
        for p, X, LIM in BLISTS:
            out[bl_file(p)] = bl_text(p, X, LIM)
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
