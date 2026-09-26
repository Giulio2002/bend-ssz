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

proofs/obj/big_encx_<p>.bend (generated, big) for the lists of SUBLISTS, whose records have uint8 /
uint16 fields: the list in var_plist_sub's encoder-window interface, its records written byte by
byte at any byte position (hand-written helpers: proofs/obj/vrecb.bend; see sub_text).
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))

import var_laws as VL  # noqa: E402

OUT = ROOT / 'proofs/obj/encx_recs.bend'
RECS = ['Withdrawal', 'SyncAggregate', 'BeaconBlockHeader', 'Fork', 'Checkpoint', 'Eth1Data', 'HistoricalSummary', 'PendingDeposit',
        'PendingPartialWithdrawal', 'PendingConsolidation',
        # BeaconBlockBody's and ExecutionRequests' records
        'AttestationData', 'DepositRequest', 'WithdrawalRequest', 'ConsolidationRequest', 'SignedVoluntaryExit', 'SignedBLSToExecutionChange',
        'SignedBeaconBlockHeader', 'DepositData']
# the word-vector leaves written by their own modules (codegen/var_uwv.py's vuwv_<p>)
VLEAVES = ('b32', 'u256', 'b48', 'b96', 'bv512', 'bv64', 'b4')
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
    if P in VLEAVES:
        return f'V_{P}.PX_{P}', f'V_{P}.{P}_any', f'V_{P}.{P}_any_bytes', f'V_{P}.{P}x_perfect', True
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
    used = []
    for n, ft in order(g, names, RECS):
        for c, k in ft.kids:
            if k.kind != 'container' and k.kind != 'u64' and k.p in VLEAVES and k.p not in used:
                used.append(k.p)
    L = HEAD + [f'import ./vuwv_{P}.bend as V_{P}' for P in used] + ['', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                '# Encoder windows of fixed-size containers at any byte position (see the generator).', '',
                'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b', '']
    for n, ft in order(g, names, RECS):
        L.append(rec_text(n, ft))
    return '\n'.join(L) + '\n'


# ---- lists of fixed records ----------------------------------------------------------------------

LISTS = [('ExecutionPayload', 'withdrawals'), ('BeaconState', 'eth1_data_votes'), ('BeaconState', 'historical_summaries'),
         ('BeaconState', 'pending_deposits'), ('BeaconState', 'pending_partial_withdrawals'), ('BeaconState', 'pending_consolidations'),
         ('ExecutionRequests', 'deposits'), ('ExecutionRequests', 'withdrawals'), ('ExecutionRequests', 'consolidations'),
         ('BeaconBlockBody', 'voluntary_exits'), ('BeaconBlockBody', 'bls_to_execution_changes')]


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



# ---- BeaconState's packed lists in encx form (var_plist_sub.ENCX over codec-var's windows big_var_winx_<p>) ----

def _wvalid(p, unit, hu):
    return f"""
def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {{OKT(dw, T, N) == True{{}} : Bool}})
    -> {{T.{p}_valid(O.Words{{FD.array__thaw(U32, T), N}}) == (O.Words{{FD.array__thaw(U32, T), N}}, True{{}}) : O.Words & Bool}}:
  wok(dw, T, N, {unit}, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h), {hu})
"""


def _flist_kinds():
    u64x = 'Bool.and(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N))'
    b32c1 = 'Nat.is_le(U32.to_nat(N), U32.to_nat(536870912))'
    b32c2 = 'U32.is_eq(U32.and(N, 31), 0)'
    b32x = f'Bool.and({b32c1}, Bool.and({b32c2}, W.CHKw(T, 0n, 0, N)))'
    p64, p8, p32 = 'l1099511627776_u64', 'l1099511627776_u8', 'l16777216_b32'
    return {
        p64: dict(X='Spec.Schema79()', EXTRA=u64x, OKDOC=', a multiple of 8',
                  CHK='FD.logic__and_right(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N), ok_ex(dw, T, N, hok))',
                  VALID=_wvalid(p64, 8, 'FD.logic__and_left(U32.is_eq(U32.and(N, 7), 0), W.CHKw(T, 0n, 0, N), ok_ex(dw, T, N, h))')),
        p8: dict(X='Spec.Schema82()', EXTRA='W.CHKw(T, 0n, 0, N)', OKDOC='', CHK='ok_ex(dw, T, N, hok)', VALID=_wvalid(p8, 1, '{==}')),
        p32: dict(X='S.ListOf{S.ByteVector{32n}, U32.to_nat(16777216)}', EXTRA=b32x, OKDOC=', at most 536870912 bytes, a multiple of 32',
                  CHK=f'FD.logic__and_right({b32c2}, W.CHKw(T, 0n, 0, N), FD.logic__and_right({b32c1}, Bool.and({b32c2}, W.CHKw(T, 0n, 0, N)), ok_ex(dw, T, N, hok)))',
                  VALID=f"""
def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {{OKT(dw, T, N) == True{{}} : Bool}})
    -> {{T.{p32}_valid(O.Words{{FD.array__thaw(U32, T), N}}) == (O.Words{{FD.array__thaw(U32, T), N}}, True{{}}) : O.Words & Bool}}:
  +ex = ok_ex(dw, T, N, h)
  +hdw = ok_hd(dw, T, N, h)
  +hN = ok_hN(dw, T, N, h)
  VBE.words_ok_b(dw, T, N, 0, 536870912, VLS.KK(dw), ok_pf(dw, T, N, h), FD.nat__lt_trans(dw, 28n, 31n, hdw, {{==}}), VLS.kk_lt(dw, hdw), VLS.hyn(dw, N, hN),
    FD.nat__zero_le(U32.to_nat(N)), FD.logic__and_left({b32c1}, Bool.and({b32c2}, W.CHKw(T, 0n, 0, N)), ex), hsrc(dw, N, hdw, hN), ok_tz(dw, T, N, h), 32,
    FD.logic__and_left({b32c2}, W.CHKw(T, 0n, 0, N), FD.logic__and_right({b32c1}, Bool.and({b32c2}, W.CHKw(T, 0n, 0, N)), ex)))
"""),
        # BeaconBlockBody's blob_kzg_commitments: at most 4096 commitments of 48 bytes (codec-var's var_winx_l4096_b48)
        'l4096_b48': dict(X='S.ListOf{S.ByteVector{48n}, U32.to_nat(4096)}', WIN='var_winx_l4096_b48',
                          EXTRA=f'Bool.and(U32.is_le(N, 196608), Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)))',
                          OKDOC=', at most 196608 bytes, a multiple of 48',
                          CHK='FD.logic__and_right(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N), FD.logic__and_right(U32.is_le(N, 196608), '
                              'Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)), ok_ex(dw, T, N, hok)))',
                          VALID=f"""
def valid(+dw: Nat, +T: FD.array__Tree<U32>, +N: U32, +h: {{OKT(dw, T, N) == True{{}} : Bool}})
    -> {{T.l4096_b48_valid(O.Words{{FD.array__thaw(U32, T), N}}) == (O.Words{{FD.array__thaw(U32, T), N}}, True{{}}) : O.Words & Bool}}:
  +ex = ok_ex(dw, T, N, h)
  %Equal.sym(Bool, U32.is_le(N, 196608), True{{}}, FD.logic__and_left(U32.is_le(N, 196608), Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)), ex)) :
    {{O.wk_cap(Bool.and(Bool.and(U32.is_le(0, N), Bool.or(False{{}}, _)), O.unit_ok(48, N)), N, Array.size(U32, FD.array__thaw(U32, T))) == (O.Words{{FD.array__thaw(U32, T), N}}, True{{}}) : O.Words & Bool}}
  wok(dw, T, N, 48, ok_pf(dw, T, N, h), ok_hd(dw, T, N, h), ok_hN(dw, T, N, h), ok_tz(dw, T, N, h),
    FD.logic__and_left(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N), FD.logic__and_right(U32.is_le(N, 196608), Bool.and(U32.is_eq(U32.mod(N, 48), 0), W.CHKw(T, 0n, 0, N)), ex)))
"""),
    }


FLISTS = ['l1099511627776_u64', 'l1099511627776_u8', 'l16777216_b32', 'l4096_b48']


def flist_text(p):
    import var_plist_sub as VPS
    import var_win as VW
    kd = _flist_kinds()[p]
    body = VPS.ENCX.replace('@PRE', '').replace('@VALID', kd['VALID']).replace('@EXTRA', kd['EXTRA']).replace('@OKDOC', kd['OKDOC']).replace('@CHK', kd['CHK'])
    body = body.replace('Spec.@X()', kd['X']).replace('@p_', f'{p}_')
    assert '@' not in body.replace('&2', ''), [ln for ln in body.split('\n') if '@' in ln.replace('&2', '')][:3]
    L = VW.HEADX + ['import ./venc.bend as VE', 'import ./vbenc.bend as VBE', 'import ./vbytes.bend as VYS', 'import ./vua.bend as UA',
                    'import ./vuw.bend as UWW', 'import ./vuwd.bend as VWD', 'import ../compact/reads.bend as RD',
                    f'import ./{kd.get("WIN", "big_var_winx_" + p)}.bend as W', '', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                    f'# {p} (T.{p}_*) in the encoder-window interface: the list written at any byte position',
                    '# X = 4 q + r of a perfect tree D of depth dd < 29 (vuwd.putw_any / putw_any_bytes; var_plist_sub.ENCX).', '']
    return '\n'.join(L) + body


# ---- fixed records with fields at any byte offset (Validator: 121 bytes, a one-byte bool) --------------
# Each field is written by the runtime at Xc = X + c, placed at the word position 4 QX(Xc) + RX(Xc)
# (vpiece.ppos / proom, vcont.vpos / croom, vcopy.split4), its bytes spliced at X0 + c of the record's
# region (vuw.inv_init / inv_zero / inv_step).

URECS = ['Validator']


def urec_file(n):
    return ROOT / f'proofs/obj/encx_{n}.bend'


def _uleaf(fs, f, k):
    """(words, object term, model(r, dd, D, q), rt(D, X, q, r, e, hr, hd, hl, pf), by(.., hz), perfect(r, dd, D, q, pf), bytes, runtime prefix, m)."""
    if fs.kind == 'u64':
        ws = [f'{f}_lo', f'{f}_hi']
        W = ', '.join(ws)
        return dict(ws=ws, obj=f'O.U64{{{W}}}', model=lambda r, dd, D, q: f'WD.W64X({r}, {dd}, {D}, {q}, {W})',
                    rt=lambda D, X, q, r: f'WD.w64_any(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf)',
                    by=lambda D, X, q, r: f'WD.w64_any_bytes(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf, @hz)',
                    pf=lambda r, D, q, p: f'WD.w64x_perfect({r}, dd, {D}, {q}, {W}, {p})', Y=f'FX.limbs([{W}])', put='u64', m=8)
    if fs.kind == 'bool':
        return dict(ws=[f], obj=f, model=lambda r, dd, D, q: f'PBo({f}, {r}, {dd}, {D}, {q})',
                    rt=lambda D, X, q, r: f'bool_any(dd, {D}, {X}, {q}, {r}, {f}, @e, @hr, hd, @hl, @pf)',
                    by=lambda D, X, q, r: f'bool_any_bytes(dd, {D}, {X}, {q}, {r}, {f}, @e, @hr, hd, @hl, @pf, @hz)',
                    pf=lambda r, D, q, p: f'boolx_perfect({f}, {r}, dd, {D}, {q}, {p})', Y=f'[BB({f})]', put='bool', m=1)
    p = fs.p
    N = fs.fsize // 4
    ws = [f'{f}_{j}' for j in range(N)]
    W = ', '.join(ws)
    a = f'V_{p}'
    return dict(ws=ws, obj=f'T.{fs.rep}{{{W}}}', model=lambda r, dd, D, q: f'{a}.PX_{p}({r}, {dd}, {D}, {q}, {W})',
                rt=lambda D, X, q, r: f'{a}.{p}_any(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf, @hz)',
                by=lambda D, X, q, r: f'{a}.{p}_any_bytes(dd, {D}, {X}, {q}, {r}, {W}, @e, @hr, hd, @hl, @pf, @hz)',
                pf=lambda r, D, q, p_: f'{a}.{p}x_perfect({r}, dd, {D}, {q}, {W}, {p_})', Y=f'FX.limbs([{W}])', put=p, m=fs.fsize, mod=f'import ./vuwv_{p}.bend as {a}')


UREC_PRE = """
# ---- the one-byte bool: True writes 1 (vuwl_u8's w8 at any X), False leaves the (zero) byte ----
def BB(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0
def PBo(b: Bool, +r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat) -> FD.array__Tree<U32>:
  match b:
    case True{}: W8.W8X(r, dd, D, q, 1)
    case False{}: D
def boolx_perfect(+b: Bool, +r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PBo(b, r, dd, D, q)) == True{} : Bool}:
  match b:
    case True{}: W8.w8x_perfect(r, dd, D, q, 1, pf)
    case False{}: pf
def bool_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +b: Bool, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {T.bool_put(FD.array__thaw(U32, D), X, b) == FD.array__thaw(U32, PBo(b, r, dd, D, q)) : Array<U32>}:
  match b:
    case True{}: W8.w8_any(dd, D, X, q, r, 1, e, hr, hd, hl, pf)
    case False{}: {==}
def bool_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +b: Bool, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(1n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(1n) : +List<U32>})
    -> {UA.BYT(PBo(b, r, dd, D, q)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), [BB(b)]) : +List<U32>}:
  match b:
    case True{}: W8.w8_any_bytes(dd, D, X, q, r, 1, e, hr, hd, hl, pf, hz)
    case False{}: UW.inv_init(UA.BYT(D), Nat.add(A.quad(q), r), 1n, [0], hz, {==})
"""


def urec_text(n):
    import generate as G
    g, names = layout()
    s = g.shape(names[n])
    F = s.fields
    hoff, L = G.container_layout(F)
    Ln = f'{L}n'
    lv = [_uleaf(fs, f, k) for k, (f, fs) in enumerate(F)]
    ws = [w for x in lv for w in x['ws']]
    WSIG = ', '.join(f'+{w}: Bool' if (fs.kind == 'bool') else f'+{w}: U32' for x, (f, fs) in zip(lv, F) for w in x['ws'])
    WA = ', '.join(ws)
    OBJ = f'T.{n}{{' + ', '.join(x['obj'] for x in lv) + '}'
    X0 = 'Nat.add(A.quad(q), r)'
    QC = lambda c: f'VCN.QX(U32.add(X, {c}))'  # noqa: E731
    RC = lambda c: f'VCN.RX(U32.add(X, {c}))'  # noqa: E731

    def tree(i):
        t = 'D'
        for j in range(i):
            t = lv[j]['model'](RC(hoff[j]), 'dd', t, QC(hoff[j]))
        return t
    BYTES = 'List.append(&2, U32, ' + ', List.append(&2, U32, '.join(x['Y'] for x in lv[:-1]) + ', ' + lv[-1]['Y'] + ')' * (len(lv) - 1)
    out = [UREC_PRE]
    w = out.append
    w(f'# ---- {n}: {len(F)} fields, {L} bytes ----')
    w(f'def PX_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32) -> {TR}: {tree(len(F))}')
    pfs = 'pf'
    for i in range(len(F)):
        pfs = lv[i]['pf'](RC(hoff[i]), tree(i), QC(hoff[i]), pfs)
    w(f'def pf_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})')
    w(f'    -> {{FD.array__perfect(U32, dd, PX_{n}({WA}, dd, D, X)) == {TRUE}}}:')
    w(f'  {pfs}')
    w(f'def BY_{n}({WSIG}) -> +List<U32>: {BYTES}')
    RT = f'{{T.{n}_put(FD.array__thaw(U32, D), X, {OBJ}) == FD.array__thaw(U32, PX_{n}({WA}, dd, D, X)) : Array<U32>}}'
    BY = f'{{UA.BYT(PX_{n}({WA}, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, BY_{n}({WA})) : +List<U32>}}'
    w(f'''def RTR_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32) -> Data: {RT}
def BYR_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {BY}
def lenb_{n}({WSIG}) -> {{List.length(&2, U32, BY_{n}({WA})) == {Ln} : Nat}}: {{==}}
''')

    def put_expr(i, inner):
        return f'T.{lv[i]["put"]}_put({inner}, U32.add(X, {hoff[i]}), {lv[i]["obj"]})'
    rts = []
    body = [f'''# T.{n}_put at X = 4 q + r writes the value's {L} bytes (BY_{n}) into the zero bytes there.
def putx_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {Ln}))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({Ln}, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({Ln}) : +List<U32>}})
    -> DK.P2(RTR_{n}({WA}, dd, D, X), BYR_{n}({WA}, dd, D, X, q, r)):
  +hX = VRX.xstart(q, r, {Ln}, dd, D, pf, hl)
  +I0 = UW.inv_init(UA.BYT(D), {X0}, {Ln}, UW.ZB({Ln}), hz, {{==}})''']
    b = body.append
    E = f'UW.ZB({Ln})'
    pf_cur = 'pf'
    for i, (f, fs) in enumerate(F):
        c, m, x = hoff[i], lv[i]['m'], lv[i]
        Di, Dn = tree(i), tree(i + 1)
        Xc = f'U32.add(X, {c})'
        pos = f'Nat.add(A.quad({QC(c)}), {RC(c)})'
        b(f'  +pp{i} = VP.ppos(X, {c}, {c}n, q, r, {Ln}, {m}n, dd, e, {{==}}, hd, {{==}}, hl)')
        b(f'  +hl{i} = VP.proom(X, {c}, {c}n, q, r, {Ln}, {m}n, dd, e, {{==}}, hd, {{==}}, hl)')
        b(f'  +z{i} = UW.inv_zero(UA.BYT(D), {X0}, {Ln}, {E}, {c}n, {m}n, UA.BYT({Di}), hX, I{i}, {{==}}, {{==}}, {{==}})')
        b(f'  +hz{i} = FD.logic__subst(Nat, zz => {{VS.bt({m}n, VS.bdr(zz, UA.BYT({Di}))) == UW.ZB({m}n) : +List<U32>}}, Nat.add({X0}, {c}n), {pos}, pp{i}, z{i})')
        sub = lambda t: t.replace('@e', f'VC.split4({Xc})').replace('@hr', f'VCN.rx_lt({Xc})').replace('@hl', f'hl{i}').replace('@pf', pf_cur).replace('@hz', f'hz{i}')  # noqa: E731
        b(f'  +rt{i} = {sub(x["rt"](Di, Xc, QC(c), RC(c)))}')
        b(f'  +by{i} = {sub(x["by"](Di, Xc, QC(c), RC(c)))}')
        Y = x['Y']
        b(f'  +hop{i} = FD.logic__subst(Nat, zz => {{UA.BYT({Dn}) == UW.SPL(UA.BYT({Di}), zz, {Y}) : +List<U32>}}, {pos}, Nat.add({X0}, {c}n), Equal.sym(Nat, Nat.add({X0}, {c}n), {pos}, pp{i}), by{i})')
        rr = L - c - m
        b(f'  +I{i + 1} = UW.inv_step(UA.BYT(D), {X0}, {Ln}, {E}, {c}n, {Y}, {rr}n, UA.BYT({Di}), UA.BYT({Dn}), hX, I{i}, hop{i}, {{==}}, {{==}})')
        E = f'UW.SPL({E}, {c}n, {Y})'
        rts.append((i, Di, Dn))
        pf_cur = x['pf'](RC(c), Di, QC(c), pf_cur)
    b(f'  +byf = FD.logic__subst(+List<U32>, zz => {{UA.BYT(PX_{n}({WA}, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VS.bt({Ln}, {E}), BY_{n}({WA}), {{==}}, I{len(F)})')
    b(f'  (rt_{n}({WA}, dd, D, X, {", ".join(f"rt{i}" for i in range(len(F)))}), byf)')

    def outer(i, hole):
        t = hole
        for j in range(i + 1, len(F)):
            t = put_expr(j, t)
        return t
    RTP = [f'+rt{i}: {{{put_expr(i, f"FD.array__thaw(U32, {Di})")} == FD.array__thaw(U32, {Dn}) : Array<U32>}}' for i, Di, Dn in rts]
    w(f'def rt_{n}({WSIG}, +dd: Nat, +D: {TR}, +X: U32,\n    ' + ',\n    '.join(RTP) + f')\n    -> {RT}:')
    for i, Di, Dn in rts:
        w(f'  %Equal.sym(Array<U32>, {put_expr(i, f"FD.array__thaw(U32, {Di})")}, FD.array__thaw(U32, {Dn}), rt{i}) :')
        w(f'    {{{outer(i, "_")} == FD.array__thaw(U32, PX_{n}({WA}, dd, D, X)) : Array<U32>}}')
    w('  {==}')
    w('')
    out += body
    mods = []
    for x in lv:
        if x.get('mod') and x['mod'] not in mods:
            mods.append(x['mod'])
    Lh = HEAD + ['import ./vcont.bend as VCN', 'import ./vcopy.bend as VC', 'import ./vpiece.bend as VP', 'import ./vuwl_u8.bend as W8'] + mods + [
        '', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
        f'# {n} ({L} bytes, fields at any byte offset) written at any byte position X = 4 q + r (see the generator).', '',
        'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
        'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b']
    return '\n'.join(Lh) + '\n' + '\n'.join(out) + '\n'

# ---- the Validator list (List[Validator, 2^40]): records of 121 bytes at byte stride 121 ------------------
# Record j is written at Xj = X + 121 j (U32.add(X, U32.mul(i, 121))) by encx_Validator.putx_Validator at
# (QX(Xj), RX(Xj)); its bytes are spliced at X0 + 121 j (vcont.vpos / croom, vrecx.znext / spl_catx).
# The list's value: its records' values (spec_rec_Validator), one variable part (Spec.Schema78).

VLIST = 'l1099511627776_Validator'


def vlist_text():
    import generate as G
    p, R, RS = VLIST, 'Validator', 121
    g, names = layout()
    F_ = g.shape(names[R]).fields
    ups = []          # (field, words) in putx_Validator's order
    for f, fs in F_:
        if fs.kind == 'u64':
            ups.append((f, fs, [f'{f}_lo', f'{f}_hi']))
        elif fs.kind == 'bool':
            ups.append((f, fs, [f]))
        else:
            ups.append((f, fs, [f'{f}_{j}' for j in range(fs.fsize // 4)]))
    WA = ', '.join(w for _, _, ws in ups for w in ws)
    lines = ['  match o:', '    case T.Validator{' + ', '.join(f'+o{k}' if fs.kind != 'bool' else f'+{f}' for k, (f, fs, _) in enumerate(ups)) + '}:']
    ind = 6
    for k, (f, fs, ws) in enumerate(ups):
        if fs.kind == 'bool':
            continue
        ctor = 'O.U64' if fs.kind == 'u64' else f'T.{fs.rep}'
        lines.append(' ' * ind + f'match o{k}:')
        lines.append(' ' * (ind + 2) + f'case {ctor}{{' + ', '.join('+' + w for w in ws) + '}:')
        ind += 4
    NEST = '\n'.join(lines)
    PAD = ' ' * ind
    xs = [w for f, fs, ws in ups[:3] for w in ws]
    bv = ups[3][2][0]
    es = [w for f, fs, ws in ups[4:] for w in ws]
    u = lambda a, b: f'S.UnsignedValue{{P.UInt{{{a}, {b}, 0, 0, 0, 0, 0, 0}}}}'  # noqa: E731
    items = [f'S.BytesValue{{F.limbs([{", ".join(ups[0][2])}])}}', f'S.BytesValue{{F.limbs([{", ".join(ups[1][2])}])}}', u(*ups[2][2]), f'S.BooleanValue{{{bv}}}'] + \
        [u(*ups[k][2]) for k in range(4, 8)]
    VAL = 'S.Sequence{' + ''.join(f'S.Items{{{it}, ' for it in items) + 'S.EmptyItems{}' + '}' * len(items) + '}'
    SPB = f'List.append(&2, U32, F.limbs([{", ".join(xs)}]), List.append(&2, U32, SP.boolean_encoding({bv}), F.limbs([{", ".join(es)}])))'
    BYV = f'EV.BY_{R}({WA})'
    TRR = f'FD.array__Tree<T.{R}>'
    TH = f'FD.array__thaw(T.{R}, A)'
    RTP = f'Array<U32> & Array<T.{R}>'
    X0 = 'Nat.add(A.quad(q), r)'
    S = f'{RS}n'
    XJ = f'U32.add(X, U32.mul(i, {RS}))'
    LLv = f'LL_{p}(A, N)'
    ENC = f'(CHV_{p}(U32.to_nat(N), A, 0n))'
    WSG = ', '.join(f'+{w}: Bool' if fs.kind == 'bool' else f'+{w}: U32' for f, fs, ws in ups for w in ws)
    ys = [f'F.limbs([{", ".join(ws)}])' if fs.kind != 'bool' else f'[EV.BB({ws[0]})]' for f, fs, ws in ups]
    dms = [f'F.domain_limbs([{", ".join(ws)}])' if fs.kind != 'bool' else f'domBB({ws[0]})' for f, fs, ws in ups]

    def dom(k):
        if k == len(ys) - 1:
            return dms[k]
        rest = ys[k + 1] if k + 1 == len(ys) - 1 else 'List.append(&2, U32, ' + ', List.append(&2, U32, '.join(ys[k + 1:-1]) + ', ' + ys[-1] + ')' * (len(ys) - k - 2)
        return f'PI.append_domain({ys[k]}, {rest}, {dms[k]}, {dom(k + 1)})'
    DOM = dom(0)
    rbeq_cases = '\n'.join(f'    case {c}{{}}: {{{{==}}}}'.replace('{{==}}', '{==}') for c in ('True', 'False'))
    return f'''
def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:
  (+a, +b) = p
  a
def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:
  (+a, +b) = p
  b
def and_l(+a: Bool, +b: Bool, +h: {{Bool.and(a, b) == {TRUE}}}) -> {{a == {TRUE}}}:
  match a:
    case True{{}}: {{==}}
    case False{{}}: h
def and_r(+a: Bool, +b: Bool, +h: {{Bool.and(a, b) == {TRUE}}}) -> {{b == {TRUE}}}:
  match a:
    case True{{}}: h
    case False{{}}: Empty.absurd({{b == {TRUE}}}, FD.logic__false_true(h))

# ---- {R}: the object's bytes, value and parts; its writer at any X ----

def RWB(o: T.{R}) -> +List<U32>:
{NEST}
{PAD}{BYV}
def RVV(o: T.{R}) -> S.Value:
{NEST}
{PAD}{VAL}

def rbeq({WSG}) -> {{{BYV} == {SPB} : +List<U32>}}:
  match {bv}:
{rbeq_cases}

def rparts(+o: T.{R}) -> {{Codec.parts(RVV(o), Spec.Schema58()) == Some{{[S.Fixed{{RWB(o)}}]}} : Maybe<&2, +List<S.Part>>}}:
{NEST}
{PAD}%Equal.sym(+List<U32>, {BYV}, {SPB}, rbeq({WA})) : {{Codec.parts({VAL}, Spec.Schema58()) == Some{{[S.Fixed{{_}}]}} : Maybe<&2, +List<S.Part>>}}
{PAD}SRV.{R}_spec_parts({", ".join(xs)}, {bv}, {", ".join(es)})

def domBB(+b: Bool) -> {{SP.bytes_domain([EV.BB(b)]) == {TRUE}}}:
  match b:
    case True{{}}: {{==}}
    case False{{}}: {{==}}
def rdom(+o: T.{R}) -> {{SP.bytes_domain(RWB(o)) == {TRUE}}}:
{NEST}
{PAD}{DOM}

def lenb(+o: T.{R}) -> {{List.length(&2, U32, RWB(o)) == {S} : Nat}}:
{NEST}
{PAD}EV.lenb_{R}({WA})

def PXo(o: T.{R}, +dd: Nat, +D: {TR}, +X: U32) -> {TR}:
{NEST}
{PAD}EV.PX_{R}({WA}, dd, D, X)
def pfo(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}}) -> {{FD.array__perfect(U32, dd, PXo(o, dd, D, X)) == {TRUE}}}:
{NEST}
{PAD}EV.pf_{R}({WA}, dd, D, X, pf)
def RTo(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32) -> Data:
  {{T.{R}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo(o, dd, D, X)) : Array<U32>}}
def BYo(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PXo(o, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, RWB(o)) : +List<U32>}}
def putxo(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {S}))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({S}, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({S}) : +List<U32>}})
    -> DK.P2(RTo(o, dd, D, X), BYo(o, dd, D, X, q, r)):
{NEST}
{PAD}EV.putx_{R}({WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)

# ---- positions at byte stride S ----

def bmul(+dd: Nat, +i: U32, +j: Nat, +Su: U32, +S: Nat, +eS: {{U32.to_nat(Su) == S : Nat}}, +ei: {{U32.to_nat(i) == j : Nat}},
    +hdd: {{Nat.is_lt(dd, 29n) == {TRUE}}}, +hm: {{Nat.is_le(Nat.mul(j, S), VB.pw(2n+dd)) == {TRUE}}})
    -> {{U32.to_nat(U32.mul(i, Su)) == Nat.mul(j, S) : Nat}}:
  +P2 = VB.pw(2n+dd)
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, U32.to_nat(Su)), Nat.mul(j, S),
    Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Su)), U32.to_nat(i), j, ei), Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Su), S, eS))
  Equal.trans(Nat, U32.to_nat(U32.mul(i, Su)), Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, S),
    VU.mul_le(i, Su, FD.u32__pow2u(2n+dd), FD.logic__subst(Nat, z => {{Nat.is_le(Nat.mul(U32.to_nat(i), U32.to_nat(Su)), z) == {TRUE}}}, P2, U32.to_nat(FD.u32__pow2u(2n+dd)),
      Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(2n+dd)), P2, FD.u32__pow2u_value(2n+dd, FD.nat__lt_trans(2n+dd, 31n, 32n, hdd, {{==}}))),
      FD.logic__subst(Nat, z => {{Nat.is_le(z, P2) == {TRUE}}}, Nat.mul(j, S), Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Su)), Nat.mul(j, S), em), hm))),
    em)

def YB(+j: Nat, +q: Nat, +r: Nat) -> Nat: Nat.add({X0}, Nat.mul(j, {S}))

# record j of a run of LT bytes at X (records j .. j + k inside it): its position, and its room
def spos(+X: U32, +i: U32, +j: Nat, +k: Nat, +q: Nat, +r: Nat, +LT: Nat, +dd: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +ei: {{U32.to_nat(i) == j : Nat}},
    +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}}, +hj: {{Nat.is_le(Nat.mul(Nat.add(1n+k, j), {S}), LT) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == {TRUE}}})
    -> {{U32.to_nat({XJ}) == YB(j, q, r) : Nat}}:
  +h1 = FD.nat__le_trans(Nat.mul(j, {S}), Nat.mul(Nat.add(1n+k, j), {S}), LT,
    VRL.mul_mono(j, Nat.add(1n+k, j), {S}, FD.nat__le_trans(j, Nat.add(k, j), 1n+Nat.add(k, j), Order.left_below_sum(k, j), Order.left_below_sum(1n, Nat.add(k, j)))), hj)
  +hm = FD.nat__le_trans(Nat.mul(j, {S}), LT, VB.pw(2n+dd), h1,
    FD.nat__le_trans(LT, Nat.add({X0}, LT), VB.pw(2n+dd), Order.left_below_sum({X0}, LT), VRX.xend(q, r, LT, dd, hl)))
  VCN.vpos(X, U32.mul(i, {RS}), Nat.mul(j, {S}), q, r, LT, dd, e, bmul(dd, i, j, {RS}, {S}, {{==}}, ei, hd, hm), hd, h1, hl)

def sroom(+Xj: U32, +j: Nat, +k: Nat, +q: Nat, +r: Nat, +LT: Nat, +dd: Nat, +ep: {{U32.to_nat(Xj) == YB(j, q, r) : Nat}},
    +hj: {{Nat.is_le(Nat.mul(Nat.add(1n+k, j), {S}), LT) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == {TRUE}}})
    -> {{Nat.is_le(Nat.add(VCN.QX(Xj), WD.NWN(Nat.add(VCN.RX(Xj), {S}))), VB.pw(dd)) == {TRUE}}}:
  +h1 = FD.nat__le_trans(Nat.mul(1n+j, {S}), Nat.mul(Nat.add(1n+k, j), {S}), LT, VRL.mul_mono(1n+j, Nat.add(1n+k, j), {S}, Order.left_below_sum(k, j)), hj)
  +h2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, LT) == {TRUE}}}, Nat.add({S}, Nat.mul(j, {S})), Nat.add(Nat.mul(j, {S}), {S}), FD.nat__add_comm({S}, Nat.mul(j, {S})), h1)
  VCN.croom(Xj, q, r, Nat.mul(j, {S}), {S}, LT, dd, ep, h2, hl)

def ynext(+j: Nat, +q: Nat, +r: Nat) -> {{YB(1n+j, q, r) == Nat.add(YB(j, q, r), {S}) : Nat}}:
  Equal.trans(Nat, Nat.add({X0}, Nat.add({S}, Nat.mul(j, {S}))), Nat.add({X0}, Nat.add(Nat.mul(j, {S}), {S})), Nat.add(Nat.add({X0}, Nat.mul(j, {S})), {S}),
    Equal.cong(Nat, Nat, z => Nat.add({X0}, z), Nat.add({S}, Nat.mul(j, {S})), Nat.add(Nat.mul(j, {S}), {S}), FD.nat__add_comm({S}, Nat.mul(j, {S}))),
    Equal.sym(Nat, Nat.add(Nat.add({X0}, Nat.mul(j, {S})), {S}), Nat.add({X0}, Nat.add(Nat.mul(j, {S}), {S})), FD.nat__add_assoc({X0}, Nat.mul(j, {S}), {S})))

# ---- {p}: the object's records, their bytes and values ----

def EL_{p}(+A: {TRR}, +j: Nat) -> T.{R}: VRL.mget(T.{R}, FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), j), T.{R}_default())
def AG_{p}(+A: {TRR}, +i: U32) -> Array<T.{R}> & T.{R}: Array.get(T.{R}, {TH}, i)

def ITV_{p}(c: Nat, +A: {TRR}, +j: Nat) -> S.Value:
  match c:
    case 0n: S.EmptyItems{{}}
    case 1n+q: S.Items{{RVV(EL_{p}(A, j)), ITV_{p}(q, A, 1n+j)}}

def FPV_{p}(c: Nat, +A: {TRR}, +j: Nat) -> +List<S.Part>:
  match c:
    case 0n: []
    case 1n+q: S.Fixed{{RWB(EL_{p}(A, j))}} <> FPV_{p}(q, A, 1n+j)

def CHV_{p}(c: Nat, +A: {TRR}, +j: Nat) -> +List<U32>:
  match c:
    case 0n: []
    case 1n+q: List.append(&2, U32, RWB(EL_{p}(A, j)), CHV_{p}(q, A, 1n+j))

law cntV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  {{Codec.count(ITV_{p}(c, A, j)) == c : Nat}}
def cntV_{p}(c, A, j):
  match c:
    case 0n: {{==}}
    case 1n+ +q: FD.nat__succ_cong(Codec.count(ITV_{p}(q, A, 1n+j)), q, cntV_{p}(q, A, 1n+j))

law prtV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  {{Codec.parts(ITV_{p}(c, A, j), S.Repeat{{Spec.Schema58()}}) == Some{{FPV_{p}(c, A, j)}} : Maybe<&2, +List<S.Part>>}}
def prtV_{p}(c, A, j):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      F.cat_fixed(Codec.parts(RVV(EL_{p}(A, j)), Spec.Schema58()), RWB(EL_{p}(A, j)), Codec.parts(ITV_{p}(q, A, 1n+j), S.Repeat{{Spec.Schema58()}}),
        FPV_{p}(q, A, 1n+j), rparts(EL_{p}(A, j)), prtV_{p}(q, A, 1n+j))

law fsV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  {{Layout.fixed_size(FPV_{p}(c, A, j)) == Nat.mul(c, {S}) : Nat}}
def fsV_{p}(c, A, j):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      %Equal.sym(Nat, List.length(&2, U32, RWB(EL_{p}(A, j))), {S}, lenb(EL_{p}(A, j))) :
        {{Nat.add(_, Layout.fixed_size(FPV_{p}(q, A, 1n+j))) == Nat.mul(1n+q, {S}) : Nat}}
      Equal.cong(Nat, Nat, z => Nat.add({S}, z), Layout.fixed_size(FPV_{p}(q, A, 1n+j)), Nat.mul(q, {S}), fsV_{p}(q, A, 1n+j))

law fpV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  for +o: Nat
  {{Layout.fixed_parts(FPV_{p}(c, A, j), o) == CHV_{p}(c, A, j) : +List<U32>}}
def fpV_{p}(c, A, j, o):
  match c:
    case 0n: {{==}}
    case 1n+ +q: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, RWB(EL_{p}(A, j)), z), Layout.fixed_parts(FPV_{p}(q, A, 1n+j), o), CHV_{p}(q, A, 1n+j), fpV_{p}(q, A, 1n+j, o))

law payV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  {{Layout.payloads(FPV_{p}(c, A, j)) == [] : +List<U32>}}
def payV_{p}(c, A, j):
  match c:
    case 0n: {{==}}
    case 1n+ +q: payV_{p}(q, A, 1n+j)

law validV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  {{Layout.bytes_valid(FPV_{p}(c, A, j)) == {TRUE}}}
def validV_{p}(c, A, j):
  match c:
    case 0n: {{==}}
    case 1n+ +q: FD.logic__and_intro(SP.bytes_domain(RWB(EL_{p}(A, j))), Layout.bytes_valid(FPV_{p}(q, A, 1n+j)), rdom(EL_{p}(A, j)), validV_{p}(q, A, 1n+j))

law lenV_{p}:
  for +c: Nat
  for +A: {TRR}
  for +j: Nat
  {{List.length(&2, U32, (CHV_{p}(c, A, j))) == Nat.mul(c, {S}) : Nat}}
def lenV_{p}(c, A, j):
  match c:
    case 0n: {{==}}
    case 1n+ +q:
      +Y = RWB(EL_{p}(A, j))
      +Rs = CHV_{p}(q, A, 1n+j)
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, Y, Rs)), Nat.add(List.length(&2, U32, Y), List.length(&2, U32, Rs)), Nat.add({S}, Nat.mul(q, {S})),
        VS.len_app(Y, Rs),
        Equal.trans(Nat, Nat.add(List.length(&2, U32, Y), List.length(&2, U32, Rs)), Nat.add({S}, List.length(&2, U32, Rs)), Nat.add({S}, Nat.mul(q, {S})),
          Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, Rs)), List.length(&2, U32, Y), {S}, lenb(EL_{p}(A, j))),
          Equal.cong(Nat, Nat, z => Nat.add({S}, z), List.length(&2, U32, Rs), Nat.mul(q, {S}), lenV_{p}(q, A, 1n+j))))

# ---- {p}: the write loop at X = 4 q + r (record j at byte X + {RS} j) ----

# the records j, j + 1, ..., j + k of A (index i = j) written from X + {RS} j on
def WX_{p}(k: Nat, +i: U32, +j: Nat, +dd: Nat, D: {TR}, +X: U32, +A: {TRR}) -> {TR}:
  match k:
    case 0n: PXo(EL_{p}(A, j), dd, D, {XJ})
    case 1n+p: WX_{p}(p, U32.add(i, 1), 1n+j, dd, PXo(EL_{p}(A, j), dd, D, {XJ}), X, A)

law pfWX_{p}:
  for +k: Nat
  for +i: U32
  for +j: Nat
  for +dd: Nat
  for +D: {TR}
  for +X: U32
  for +A: {TRR}
  for +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}}
  {{FD.array__perfect(U32, dd, WX_{p}(k, i, j, dd, D, X, A)) == {TRUE}}}
def pfWX_{p}(k, i, j, dd, D, X, A, pf):
  match k:
    case 0n: pfo(EL_{p}(A, j), dd, D, {XJ}, pf)
    case 1n+ +p: pfWX_{p}(p, U32.add(i, 1), 1n+j, dd, PXo(EL_{p}(A, j), dd, D, {XJ}), X, A, pfo(EL_{p}(A, j), dd, D, {XJ}, pf))

def RTK_{p}(k: Nat, +i: U32, +j: Nat, +X: U32, +dd: Nat, +D: {TR}, +A: {TRR}) -> Data:
  {{T.{p}_pt(k, i, X, FD.array__thaw(U32, D), ({TH}, EL_{p}(A, j))) == (FD.array__thaw(U32, WX_{p}(k, i, j, dd, D, X, A)), {TH}) : {RTP}}}
def BYK_{p}(k: Nat, +i: U32, +j: Nat, +q: Nat, +r: Nat, +dd: Nat, +D: {TR}, +X: U32, +A: {TRR}) -> Data:
  {{UA.BYT(WX_{p}(k, i, j, dd, D, X, A)) == UW.SPL(UA.BYT(D), YB(j, q, r), (CHV_{p}(1n+k, A, j))) : +List<U32>}}

# record j's write: its runtime fact, its bytes at YB(j), its perfect tree, its start in the bytes
def one(+o: T.{R}, +i: U32, +j: Nat, +k: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: {TR}, +LT: Nat,
    +ei: {{U32.to_nat(i) == j : Nat}}, +e: {{U32.to_nat(X) == {X0} : Nat}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +pfD: {{FD.array__perfect(U32, dd, D) == {TRUE}}}, +hj: {{Nat.is_le(Nat.mul(Nat.add(1n+k, j), {S}), LT) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == {TRUE}}},
    +hz: {{VS.bt({S}, VS.bdr(YB(j, q, r), UA.BYT(D))) == UW.ZB({S}) : +List<U32>}})
    -> DK.P2(RTo(o, dd, D, {XJ}), DK.P2({{UA.BYT(PXo(o, dd, D, {XJ})) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}},
         {{Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == {TRUE}}})):
  +Xj = {XJ}
  +ep = spos(X, i, j, k, q, r, LT, dd, e, ei, hd, hj, hl)
  +hlj = sroom(Xj, j, k, q, r, LT, dd, ep, hj, hl)
  +pj = Nat.add(A.quad(VCN.QX(Xj)), VCN.RX(Xj))
  +epj = Equal.trans(Nat, YB(j, q, r), U32.to_nat(Xj), pj, Equal.sym(Nat, U32.to_nat(Xj), YB(j, q, r), ep), VC.split4(Xj))
  +hzj = FD.logic__subst(Nat, z => {{VS.bt({S}, VS.bdr(z, UA.BYT(D))) == UW.ZB({S}) : +List<U32>}}, YB(j, q, r), pj, epj, hz)
  +g = putxo(o, dd, D, Xj, VCN.QX(Xj), VCN.RX(Xj), VC.split4(Xj), VCN.rx_lt(Xj), hd, hlj, pfD, hzj)
  +rt = PA(RTo(o, dd, D, Xj), BYo(o, dd, D, Xj, VCN.QX(Xj), VCN.RX(Xj)), g)
  +by = PB(RTo(o, dd, D, Xj), BYo(o, dd, D, Xj, VCN.QX(Xj), VCN.RX(Xj)), g)
  +by2 = FD.logic__subst(Nat, z => {{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), z, RWB(o)) : +List<U32>}}, pj, YB(j, q, r), Equal.sym(Nat, YB(j, q, r), pj, epj), by)
  +hX = FD.logic__subst(Nat, z => {{Nat.is_le(z, List.length(&2, U32, UA.BYT(D))) == {TRUE}}}, pj, YB(j, q, r), Equal.sym(Nat, YB(j, q, r), pj, epj),
    VRX.xstart(VCN.QX(Xj), VCN.RX(Xj), {S}, dd, D, pfD, hlj))
  (rt, (by2, hX))

# The loop from record j (index i) on, k + 1 records, into LT bytes at X whose last k + 1 records' bytes are zero.
def ptx_{p}(k: Nat, +i: U32, +j: Nat, +X: U32, +q: Nat, +r: Nat, +dd: Nat, +D: {TR}, +da: Nat, +A: {TRR}, +LT: Nat,
    +ei: {{U32.to_nat(i) == j : Nat}}, +e: {{U32.to_nat(X) == {X0} : Nat}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +pfD: {{FD.array__perfect(U32, dd, D) == {TRUE}}}, +hj: {{Nat.is_le(Nat.mul(Nat.add(1n+k, j), {S}), LT) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LT))), VB.pw(dd)) == {TRUE}}},
    +hz: {{VS.bt(Nat.mul(1n+k, {S}), VS.bdr(YB(j, q, r), UA.BYT(D))) == UW.ZB(Nat.mul(1n+k, {S})) : +List<U32>}},
    +pfA: {{FD.array__perfect(T.{R}, da, A) == {TRUE}}}, +hda: {{Nat.is_lt(da, 31n) == {TRUE}}}, +hk: {{Nat.is_lt(Nat.add(k, j), VB.pw(da)) == {TRUE}}})
    -> DK.P2(RTK_{p}(k, i, j, X, dd, D, A), BYK_{p}(k, i, j, q, r, dd, D, X, A)):
  match k:
    case 0n:
      +o = EL_{p}(A, j)
      +Xj = {XJ}
      +g = one(o, i, j, 0n, X, q, r, dd, D, LT, ei, e, hd, pfD, hj, hl, hz)
      +rt = PA(RTo(o, dd, D, Xj), DK.P2({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}}, {{Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == {TRUE}}}), g)
      +gb = PB(RTo(o, dd, D, Xj), DK.P2({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}}, {{Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == {TRUE}}}), g)
      +by = PA({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(UA.BYT(D), YB(j, q, r), RWB(o)) : +List<U32>}}, {{Nat.is_le(YB(j, q, r), List.length(&2, U32, UA.BYT(D))) == {TRUE}}}, gb)
      +D1 = PXo(o, dd, D, Xj)
      +Y = RWB(o)
      +rt0 = Equal.cong(Array<U32>, {RTP}, z => (z, {TH}), T.{R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +by0 = FD.logic__subst(+List<U32>, z => {{UA.BYT(D1) == UW.SPL(UA.BYT(D), YB(j, q, r), z) : +List<U32>}}, Y, List.append(&2, U32, Y, []),
        Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)), by)
      (rt0, by0)
    case 1n+ +p:
      +o = EL_{p}(A, j)
      +Xj = {XJ}
      +bm = Nat.mul(1n+p, {S})
      +B0 = UA.BYT(D)
      +Yj = YB(j, q, r)
      +hz0 = VRX.zhead({S}, bm, VS.bdr(Yj, B0), hz)
      +g = one(o, i, j, 1n+p, X, q, r, dd, D, LT, ei, e, hd, pfD, hj, hl, hz0)
      +rt = PA(RTo(o, dd, D, Xj), DK.P2({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}}, {{Nat.is_le(Yj, List.length(&2, U32, B0)) == {TRUE}}}), g)
      +gb = PB(RTo(o, dd, D, Xj), DK.P2({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}}, {{Nat.is_le(Yj, List.length(&2, U32, B0)) == {TRUE}}}), g)
      +by = PA({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}}, {{Nat.is_le(Yj, List.length(&2, U32, B0)) == {TRUE}}}, gb)
      +hX = PB({{UA.BYT(PXo(o, dd, D, Xj)) == UW.SPL(B0, Yj, RWB(o)) : +List<U32>}}, {{Nat.is_le(Yj, List.length(&2, U32, B0)) == {TRUE}}}, gb)
      +D1 = PXo(o, dd, D, Xj)
      +pf1 = pfo(o, dd, D, Xj, pfD)
      +Y = RWB(o)
      +ey = ynext(j, q, r)
      +z1 = VRX.znext(B0, Yj, Y, YB(1n+j, q, r), {S}, bm, UA.BYT(D1), hX, lenb(o), ey, by, hz)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hi1 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(da)) == {TRUE}}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
      +hx = FD.logic__subst(Nat, z => {{FD.spec_common__nth(T.{R}, FD.array__slots(T.{R}, A), z) == Some{{EL_{p}(A, 1n+j)}} : Maybe<&2, T.{R}>}}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
        VRL.nth_get(T.{R}, FD.array__slots(T.{R}, A), 1n+j, T.{R}_default(), FD.array__len_lt(T.{R}, da, A, 1n+j, pfA, h1)))
      +eg = FD.array__get(T.{R}, da, A, U32.add(i, 1), EL_{p}(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)
      +hj2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.mul(1n+z, {S}), LT) == {TRUE}}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hk2 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(da)) == {TRUE}}}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      +ih = ptx_{p}(p, U32.add(i, 1), 1n+j, X, q, r, dd, D1, da, A, LT, ei1, e, hd, pf1, hj2, hl, z1, pfA, hda, hk2)
      +rt2 = PA(RTK_{p}(p, U32.add(i, 1), 1n+j, X, dd, D1, A), BYK_{p}(p, U32.add(i, 1), 1n+j, q, r, dd, D1, X, A), ih)
      +by2 = PB(RTK_{p}(p, U32.add(i, 1), 1n+j, X, dd, D1, A), BYK_{p}(p, U32.add(i, 1), 1n+j, q, r, dd, D1, X, A), ih)
      +ea = Equal.cong(Array<U32>, {RTP}, z => T.{p}_pt(p, U32.add(i, 1), X, z, AG_{p}(A, U32.add(i, 1))), T.{R}_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +eb = Equal.cong(Array<T.{R}> & T.{R}, {RTP}, z => T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), z), AG_{p}(A, U32.add(i, 1)), ({TH}, EL_{p}(A, 1n+j)), eg)
      +rt3 = Equal.trans({RTP}, T.{p}_pt(p, U32.add(i, 1), X, T.{R}_put(FD.array__thaw(U32, D), Xj, o), AG_{p}(A, U32.add(i, 1))), T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_{p}(A, U32.add(i, 1))),
        (FD.array__thaw(U32, WX_{p}(p, U32.add(i, 1), 1n+j, dd, D1, X, A)), {TH}), ea,
        Equal.trans({RTP}, T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG_{p}(A, U32.add(i, 1))), T.{p}_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), ({TH}, EL_{p}(A, 1n+j))),
          (FD.array__thaw(U32, WX_{p}(p, U32.add(i, 1), 1n+j, dd, D1, X, A)), {TH}), eb, rt2))
      +rest = (CHV_{p}(1n+p, A, 1n+j))
      +eXn = Equal.trans(Nat, YB(1n+j, q, r), Nat.add(Yj, {S}), Nat.add(Yj, VRX.LN(Y)), ey,
        Equal.cong(Nat, Nat, z => Nat.add(Yj, z), {S}, VRX.LN(Y), Equal.sym(Nat, VRX.LN(Y), {S}, lenb(o))))
      +by3 = Equal.trans(+List<U32>, UA.BYT(WX_{p}(p, U32.add(i, 1), 1n+j, dd, D1, X, A)), UW.SPL(UA.BYT(D1), YB(1n+j, q, r), rest), UW.SPL(B0, Yj, VRX.AP(Y, rest)), by2,
        VRX.spl_catx(B0, Yj, Y, rest, YB(1n+j, q, r), UA.BYT(D1), hX, eXn, by))
      (rt3, by3)

# ---- {p}: the list's encoder window ----

def TDM_{p}(t: {TRR}) -> Nat:
  match t:
    case FD.TLeaf{{x}}: 0n
    case FD.TNode{{l, r}}: 1n+TDM_{p}(l)

# The list object Seq{{thaw(A), N}} and its facts: a perfect tree of depth < 31 holding the N records (no bound past U32).
def THL_{p}(+A: {TRR}, +N: U32) -> T.{p}_Seq: T.{p}_Seq{{{TH}, N}}
def OKL_{p}(+A: {TRR}, +N: U32) -> Bool:
  Bool.and(Nat.is_lt(TDM_{p}(A), 31n), Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A)))))
def okl_d_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{Nat.is_lt(TDM_{p}(A), 31n) == {TRUE}}}:
  and_l(Nat.is_lt(TDM_{p}(A), 31n), Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A)))), h)
def okl_1_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}})
    -> {{Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A)))) == {TRUE}}}:
  and_r(Nat.is_lt(TDM_{p}(A), 31n), Bool.and(FD.array__perfect(T.{R}, TDM_{p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A)))), h)
def okl_pf_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{FD.array__perfect(T.{R}, TDM_{p}(A), A) == {TRUE}}}:
  and_l(FD.array__perfect(T.{R}, TDM_{p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), okl_1_{p}(A, N, h))
def okl_n_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))) == {TRUE}}}:
  and_r(FD.array__perfect(T.{R}, TDM_{p}(A), A), Nat.is_le(U32.to_nat(N), VB.pw(TDM_{p}(A))), okl_1_{p}(A, N, h))

# N <= 2^d as the runtime compares it.
def le_cap_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{U32.is_le(N, FD.u32__pow2u(TDM_{p}(A))) == {TRUE}}}:
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(TDM_{p}(A))), Nat.is_le(U32.to_nat(N), U32.to_nat(FD.u32__pow2u(TDM_{p}(A)))), VU.le_u32(N, FD.u32__pow2u(TDM_{p}(A)))) : {{_ == {TRUE}}}
  %Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(TDM_{p}(A))), VB.pw(TDM_{p}(A)), FD.u32__pow2u_value(TDM_{p}(A), FD.nat__lt_trans(TDM_{p}(A), 31n, 32n, okl_d_{p}(A, N, h), {{==}}))) : {{Nat.is_le(U32.to_nat(N), _) == {TRUE}}}
  okl_n_{p}(A, N, h)

# The list's bytes, their count, and the writer's model.
def LL_{p}(+A: {TRR}, +N: U32) -> Nat: Nat.mul(U32.to_nat(N), {S})
def ENCL_{p}(+A: {TRR}, +N: U32) -> +List<U32>: {ENC}
def PUTLb_{p}(b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32) -> {TR}:
  match b:
    case True{{}}: D
    case False{{}}: WX_{p}(U32.to_nat(U32.sub(N, 1)), 0, 0n, dd, D, X, A)
def PUTL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32) -> {TR}: PUTLb_{p}(U32.is_eq(N, 0), A, N, dd, D, X)
def pfLb_{p}(+b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PUTLb_{p}(b, A, N, dd, D, X)) == {TRUE}}}:
  match b:
    case True{{}}: pf
    case False{{}}: pfWX_{p}(U32.to_nat(U32.sub(N, 1)), 0, 0n, dd, D, X, A, pf)

def RTN_{p}(+b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32) -> Data:
  {{T.{p}_pt_nz(b, X, N, FD.array__thaw(U32, D), {TH}) == (FD.array__thaw(U32, PUTLb_{p}(b, A, N, dd, D, X)), THL_{p}(A, N)) : Array<U32> & T.{p}_Seq}}
def BYN_{p}(+b: Bool, +A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTLb_{p}(b, A, N, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, {ENC}) : +List<U32>}}

# The writer's non-empty test, and its loop.
def ptnz_{p}(+A: {TRR}, +N: U32, +b: Bool, +eb: {{U32.is_eq(N, 0) == b : Bool}}, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {LLv}))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({LLv}, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({LLv}) : +List<U32>}})
    -> DK.P2(RTN_{p}(b, A, N, dd, D, X), BYN_{p}(b, A, N, dd, D, X, q, r)):
  match b:
    case True{{}}:
      +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, 0, FD.u32alg__eq_of(N, 0, eb))
      ({{==}}, FD.logic__subst(Nat, z => {{UA.BYT(D) == UW.SPL(UA.BYT(D), {X0}, (CHV_{p}(z, A, 0n))) : +List<U32>}}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, eN),
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
      +hj = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.mul(z, {S}), {LLv}) == {TRUE}}}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), FD.nat__le_refl({LLv}))
      +hz1 = FD.logic__subst(Nat, z => {{VS.bt(Nat.mul(z, {S}), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(Nat.mul(z, {S})) : +List<U32>}}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hz)
      +hz2 = FD.logic__subst(Nat, z => {{VS.bt(Nat.mul(1n+k, {S}), VS.bdr(z, UA.BYT(D))) == UW.ZB(Nat.mul(1n+k, {S})) : +List<U32>}}, {X0}, YB(0n, q, r), Equal.sym(Nat, YB(0n, q, r), {X0}, FD.nat__add_zero({X0})), hz1)
      +hk = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(da)) == {TRUE}}}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {{Nat.is_lt(k, z) == {TRUE}}}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      +eg0 = FD.array__get(T.{R}, da, A, 0, EL_{p}(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.{R}, FD.array__slots(T.{R}, A), 0n, T.{R}_default(), FD.array__len_lt(T.{R}, da, A, 0n, pfA, h0)), pfA)
      +g = ptx_{p}(k, 0, 0n, X, q, r, dd, D, da, A, {LLv}, {{==}}, e, hd, pf, hj, hl, hz2, pfA, hda, hk)
      +rt = PA(RTK_{p}(k, 0, 0n, X, dd, D, A), BYK_{p}(k, 0, 0n, q, r, dd, D, X, A), g)
      +by = PB(RTK_{p}(k, 0, 0n, X, dd, D, A), BYK_{p}(k, 0, 0n, q, r, dd, D, X, A), g)
      +by1 = FD.logic__subst(Nat, z => {{UA.BYT(WX_{p}(k, 0, 0n, dd, D, X, A)) == UW.SPL(UA.BYT(D), z, (CHV_{p}(1n+k, A, 0n))) : +List<U32>}}, YB(0n, q, r), {X0}, FD.nat__add_zero({X0}), by)
      +ea = Equal.cong(Array<T.{R}> & T.{R}, Array<U32> & T.{p}_Seq, z => T.{p}_pt_fin(N, T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), z)), Array.get(T.{R}, {TH}, 0), ({TH}, EL_{p}(A, 0n)), eg0)
      +eb2 = Equal.cong({RTP}, Array<U32> & T.{p}_Seq, z => T.{p}_pt_fin(N, z), T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), ({TH}, EL_{p}(A, 0n))), (FD.array__thaw(U32, WX_{p}(k, 0, 0n, dd, D, X, A)), {TH}), rt)
      (Equal.trans(Array<U32> & T.{p}_Seq, T.{p}_pt_fin(N, T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), Array.get(T.{R}, {TH}, 0))), T.{p}_pt_fin(N, T.{p}_pt(k, 0, X, FD.array__thaw(U32, D), ({TH}, EL_{p}(A, 0n)))),
         T.{p}_pt_fin(N, (FD.array__thaw(U32, WX_{p}(k, 0, 0n, dd, D, X, A)), {TH})), ea, eb2),
       FD.logic__subst(Nat, z => {{UA.BYT(WX_{p}(k, 0, 0n, dd, D, X, A)) == UW.SPL(UA.BYT(D), {X0}, (CHV_{p}(z, A, 0n))) : +List<U32>}}, 1n+k, c, e1, by1))

# The runtime's validity check of the list (no bound on N past the storage's size).
def valid_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}) -> {{T.{p}_valid(THL_{p}(A, N)) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}:
  +d = TDM_{p}(A)
  %Equal.sym(Array<T.{R}> & U32, Array.size(T.{R}, {TH}), ({TH}, FD.u32__pow2u(d)), FD.array__size_thaw(T.{R}, d, A, okl_pf_{p}(A, N, h))) :
    {{T.{p}_va_cap(Bool.or(True{{}}, U32.is_le(N, 0)), N, _) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(d)), True{{}}, le_cap_{p}(A, N, h)) :
    {{(THL_{p}(A, N), Bool.and(Bool.or(True{{}}, U32.is_le(N, 0)), _)) == (THL_{p}(A, N), True{{}}) : T.{p}_Seq & Bool}}
  {{==}}

def RTL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_putk(FD.array__thaw(U32, D), X, THL_{p}(A, N)) == (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, X)), (THL_{p}(A, N), U32.mul(N, {RS}))) : Array<U32> & (T.{p}_Seq & U32)}}
def BYL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTL_{p}(A, N, dd, D, X)) == UW.SPL(UA.BYT(D), {X0}, ENCL_{p}(A, N)) : +List<U32>}}
def PFL_{p}(+A: {TRR}, +N: U32, +dd: Nat, +D: {TR}, +X: U32) -> Data:
  {{FD.array__perfect(U32, dd, PUTL_{p}(A, N, dd, D, X)) == {TRUE}}}

# The runtime's write, with its validity check.
def putk_rt_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +rtb: RTN_{p}(U32.is_eq(N, 0), A, N, dd, D, X)) -> RTL_{p}(A, N, dd, D, X, q, r):
  %Equal.sym(T.{p}_Seq & Bool, T.{p}_valid(THL_{p}(A, N)), (THL_{p}(A, N), True{{}}), valid_{p}(A, N, h)) :
    {{T.{p}_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, X)), (THL_{p}(A, N), U32.mul(N, {RS}))) : Array<U32> & (T.{p}_Seq & U32)}}
  %Equal.sym(Array<U32> & T.{p}_Seq, T.{p}_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), {TH}), (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, X)), THL_{p}(A, N)), rtb) :
    {{T.{p}_ptn_fin(N, _) == (FD.array__thaw(U32, PUTL_{p}(A, N, dd, D, X)), (THL_{p}(A, N), U32.mul(N, {RS}))) : Array<U32> & (T.{p}_Seq & U32)}}
  {{==}}

# putx: the runtime writer at X = 4 q + r is the model PUTL, whose bytes splice the list's bytes
# into D's (its records write their data bytes only), and whose tree is perfect.
def putx_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {LLv}))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({LLv}, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({LLv}) : +List<U32>}})
    -> DK.P2(RTL_{p}(A, N, dd, D, X, q, r), DK.P2(BYL_{p}(A, N, dd, D, X, q, r), PFL_{p}(A, N, dd, D, X))):
  +b = U32.is_eq(N, 0)
  +g = ptnz_{p}(A, N, b, {{==}}, h, dd, D, X, q, r, e, hd, hl, pf, hz)
  +rtb = PA(RTN_{p}(b, A, N, dd, D, X), BYN_{p}(b, A, N, dd, D, X, q, r), g)
  +byb = PB(RTN_{p}(b, A, N, dd, D, X), BYN_{p}(b, A, N, dd, D, X, q, r), g)
  (putk_rt_{p}(A, N, h, dd, D, X, q, r, rtb), (byb, pfLb_{p}(b, A, N, dd, D, X, pf)))

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
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {LLv}))), VB.pw(dd)) == {TRUE}}}) -> {{U32.to_nat(U32.mul(N, {RS})) == {LLv} : Nat}}:
  bmul(dd, N, U32.to_nat(N), {RS}, {S}, {{==}}, {{==}}, hd,
    FD.nat__le_trans({LLv}, Nat.add({X0}, {LLv}), VB.pw(2n+dd), Order.left_below_sum({X0}, {LLv}), VRX.xend(q, r, {LLv}, dd, hl)))

# ---- {p}: the spec side ----

# The value of the list: the records' values.
def VALL_{p}(+A: {TRR}, +N: U32) -> S.Value: S.Sequence{{ITV_{p}(U32.to_nat(N), A, 0n)}}

def len_encl_{p}(+A: {TRR}, +N: U32) -> {{List.length(&2, U32, ENCL_{p}(A, N)) == {LLv} : Nat}}: lenV_{p}(U32.to_nat(N), A, 0n)

# encx_spec: the list's value has its bytes as one variable part, when they fit a tree of depth dx < 30.
def encx_spec_{p}(+A: {TRR}, +N: U32, +h: {{OKL_{p}(A, N) == {TRUE}}}, +dx: Nat, +hdx: {{Nat.is_lt(dx, 30n) == {TRUE}}},
    +hL: {{Nat.is_le({LLv}, A.quad(VB.pw(dx))) == {TRUE}}})
    -> {{Codec.parts(VALL_{p}(A, N), Spec.Schema78()) == Some{{[S.Variable{{ENCL_{p}(A, N)}}]}} : Maybe<&2, +List<S.Part>>}}:
  +c = U32.to_nat(N)
  +fit = FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, {LLv}, List.length(&2, U32, (CHV_{p}(c, A, 0n))), Equal.sym(Nat, List.length(&2, U32, (CHV_{p}(c, A, 0n))), {LLv}, len_encl_{p}(A, N)),
    VBZ.fitq(dx, {LLv}, hL, hdx))
  %Equal.sym(Nat, Codec.count(ITV_{p}(c, A, 0n)), c, cntV_{p}(c, A, 0n)) :
    {{Codec.require(Nat.is_le(_, Nat.mul(U32.to_nat(1073741824), 1024n)), Codec.aggregate(Codec.parts(ITV_{p}(c, A, 0n), S.Repeat{{Spec.Schema58()}}), None{{}})) == Some{{[S.Variable{{(CHV_{p}(c, A, 0n))}}]}} : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(Bool, Nat.is_le(c, Nat.mul(U32.to_nat(1073741824), 1024n)), True{{}}, V40.u32le40(N)) :
    {{Codec.require(_, Codec.aggregate(Codec.parts(ITV_{p}(c, A, 0n), S.Repeat{{Spec.Schema58()}}), None{{}})) == Some{{[S.Variable{{(CHV_{p}(c, A, 0n))}}]}} : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(ITV_{p}(c, A, 0n), S.Repeat{{Spec.Schema58()}}), Some{{FPV_{p}(c, A, 0n)}}, prtV_{p}(c, A, 0n)) :
    {{Codec.require(True{{}}, Codec.aggregate(_, None{{}})) == Some{{[S.Variable{{(CHV_{p}(c, A, 0n))}}]}} : Maybe<&2, +List<S.Part>>}}
  +M = Nat.mul(c, {S})
  +fit2 = FD.logic__subst(Nat, z => {{N.fits(4n, z) == {TRUE}}}, List.length(&2, U32, CHV_{p}(c, A, 0n)), Nat.add(M, 0n),
    Equal.trans(Nat, List.length(&2, U32, CHV_{p}(c, A, 0n)), M, Nat.add(M, 0n), lenV_{p}(c, A, 0n), Equal.sym(Nat, Nat.add(M, 0n), M, FD.nat__add_zero(M))), fit)
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(FPV_{p}(c, A, 0n)), Some{{List.append(&2, U32, CHV_{p}(c, A, 0n), [])}},
      VMV.enc_gen(FPV_{p}(c, A, 0n), M, CHV_{p}(c, A, 0n), [], fsV_{p}(c, A, 0n), fpV_{p}(c, A, 0n, M), payV_{p}(c, A, 0n), validV_{p}(c, A, 0n), fit2)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{(CHV_{p}(c, A, 0n))}}]}} : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(+List<U32>, List.append(&2, U32, CHV_{p}(c, A, 0n), []), CHV_{p}(c, A, 0n), VS.app_nil(CHV_{p}(c, A, 0n))) :
    {{Codec.one(Some{{_}}, None{{}}) == Some{{[S.Variable{{(CHV_{p}(c, A, 0n))}}]}} : Maybe<&2, +List<S.Part>>}}
  {{==}}
'''


def vlist_module():
    L = LHEAD + ['import ./vcont.bend as VCN', 'import ./vcopy.bend as VC', 'import ./big_vu40.bend as V40', 'import ./encx_Validator.bend as EV',
                 'import ./spec_rec_Validator.bend as SRV', 'import ./vmv.bend as VMV', 'import ../../proofs/primitive_invariants.bend as PI', '', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                 f'# The encoder window of {VLIST} (records of 121 bytes at any byte phase) at any byte position (see the generator).', '']
    return '\n'.join(L) + vlist_text()

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


# ---- lists of records with sub-word fields (uint8 / uint16), byte-granular -----------------------
# The generic lists l10_GpF350A3C486 (List[{uint8}, 10]) and pl_Gc4ED9619F50 (ProgressiveList[{uint16,
# uint16}]) in the encoder-window interface of var_plist_sub.ENCX (mirror MW{da, A, N}: the record tree A
# of depth da holding the list's N records). A record's fields are written by the sub-word leaves at a
# byte position P (vrecb.W8P / W16P over vuwl_u8.W8X / vuwl_u16.W16X at 4 QP(P) + RP(P)); its bytes are
# its fields' bytes (byte lists: [x & 255], [x & 255, (x >> 8) & 255]), its value is read back from them
# (vrecb.UV8 / UV16), so its parts are its bytes with no validity assumption. Record j of the list is at
# byte P0 + RS j (vrl.pos; vrecb.posb, rroomb, pnext), its bytes splice into the zero window there
# (vrecx.zhead, znext, spl_catx), and the list's validity check is modeled by VOK (the records'
# T.R_valid), proved by the loop vax.

SUBLISTS = [('pl_Gc4ED9619F50', 'Gc4ED9619F50', None), ('l10_GpF350A3C486', 'GpF350A3C486', 10)]


def sub_file(p):
    return ROOT / f'proofs/obj/big_encx_{p}.bend'


def sub_fields(R):
    """The record's fields [(name, byte offset, 'u8' | 'u16')] from the runtime type and var_rlist_sub.RECS."""
    import re
    import var_rlist_sub as VRS
    src = (ROOT / 'types/generic_obj.bend').read_text()
    m = re.search(rf'^type {R} is Data:\n  {R}\{{([^}}]*)\}}', src, re.M)
    names = [f.split(':')[0].strip() for f in m.group(1).split(',')]
    RS, sch, fl = VRS.RECS[R]
    assert len(names) == len(fl)
    return RS, sch, [(nm, c, 'u8' if sz == 1 else 'u16') for nm, (c, sz, *_rest) in zip(names, fl)]


SUBHEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/generic_obj.bend as T', 'import ../../types/schema.bend as S',
           'import ../../types/primitive.bend as P', 'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A',
           'import ../../proofs/nat_order.bend as Order', 'import ../../spec/primitives.bend as SP', 'import ../../spec/layout.bend as Layout',
           'import ../../spec/codec.bend as Codec', 'import ../../spec/nat_bytes.bend as N', 'import ./spec_fixed.bend as F',
           'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU', 'import ./vua.bend as UA',
           'import ./vuw.bend as UW', 'import ./vuwd.bend as WD', 'import ./vrl.bend as VRL', 'import ./vrecx.bend as VRX',
           'import ./vrecb.bend as VRB', 'import ./vfits.bend as VFT', 'import ./vmv.bend as VMV', 'import ./sub_pack.bend as SP2',
           'import ./dk.bend as DK']


def sub_rec_text(R, RS, sch, fields):
    """The record R at a byte position P: its bytes RB, model PR, perfect, the runtime's T.R_put, value, parts."""
    TR = 'FD.array__Tree<U32>'
    pat = f'T.{R}{{' + ', '.join(f'+{nm}' for nm, c, k in fields) + '}'

    def by(nm, k):
        return [f'U32.and({nm}, 255)'] + ([f'U32.and(U32.shrn({nm}, 8n), 255)'] if k == 'u16' else [])
    ys = [by(nm, k) for nm, c, k in fields]
    RB = '[' + ', '.join(sum(ys, [])) + ']'
    ms = [len(y) for y in ys]
    W = {'u8': 'VRB.W8P', 'u16': 'VRB.W16P'}
    PFW = {'u8': 'VRB.w8p_perfect', 'u16': 'VRB.w16p_perfect'}
    RTW = {'u8': 'VRB.w8p_rt', 'u16': 'VRB.w16p_rt'}
    BYW = {'u8': 'VRB.w8p_bytes', 'u16': 'VRB.w16p_bytes'}
    PUT = {'u8': 'T.u8_put', 'u16': 'T.u16_put'}

    def pos(c):
        return f'Nat.add({c}n, P)'

    def tree(i):
        t = 'D'
        for nm, c, k in fields[:i]:
            t = f'{W[k]}(dd, {t}, {pos(c)}, {nm})'
        return t
    n = len(fields)
    pfs = 'pf'
    for i, (nm, c, k) in enumerate(fields):
        pfs = f'{PFW[k]}(dd, {tree(i)}, {pos(c)}, {nm}, {pfs})'
    uv = {'u8': 'VRB.UV8', 'u16': 'VRB.UV16'}
    items = 'S.EmptyItems{}'
    for nm, c, k in reversed(fields):
        items = f'S.Items{{{uv[k]}({nm}), {items}}}'
    L = []
    w = L.append
    w(f'''
# ---- the record {R} ({RS} bytes) at a byte position P ----

def RB_{R}(o: T.{R}) -> +List<U32>:
  match o:
    case {pat}: {RB}
def lenr_{R}(+o: T.{R}) -> {{List.length(&2, U32, RB_{R}(o)) == {RS}n : Nat}}:
  match o:
    case {pat}: {{==}}
def PR_{R}(o: T.{R}, +dd: Nat, +D: {TR}, +P: Nat) -> {TR}:
  match o:
    case {pat}: {tree(n)}
def pfr_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +P: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PR_{R}(o, dd, D, P)) == {TRUE}}}:
  match o:
    case {pat}: {pfs}

def RTR_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +P: Nat) -> Data:
  {{T.{R}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PR_{R}(o, dd, D, P)) : Array<U32>}}
def BYR_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +P: Nat) -> Data:
  {{UA.BYT(PR_{R}(o, dd, D, P)) == UW.SPL(UA.BYT(D), P, RB_{R}(o)) : +List<U32>}}

# T.{R}_put at X (byte P) writes the record's bytes into the {RS} zero bytes there.
def putr_{R}(+o: T.{R}, +dd: Nat, +D: {TR}, +X: U32, +P: Nat, +e: {{U32.to_nat(X) == P : Nat}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hb: {{Nat.is_le(Nat.add(P, {RS}n), A.quad(VB.pw(dd))) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({RS}n, VS.bdr(P, UA.BYT(D))) == UW.ZB({RS}n) : +List<U32>}})
    -> DK.P2(RTR_{R}(o, dd, D, X, P), BYR_{R}(o, dd, D, P)):
  match o:
    case {pat}:
      +B = UA.BYT(D)
      +hX = VRB.hxb(P, {RS}n, dd, D, pf, hb)''')
    pf_cur = 'pf'
    acc = []  # the bytes written so far
    for i, (nm, c, k) in enumerate(fields):
        m = ms[i]
        Di, Dn = tree(i), tree(i + 1)
        Pi = pos(c)
        Xi = f'U32.add(X, {c})'
        w(f'      +ep{i} = VRB.fposb(dd, X, {c}, P, {RS}n, e, hd, hb, {{==}})')
        w(f'      +hb{i} = VRB.froomb(P, {c}n, {m}n, {RS}n, A.quad(VB.pw(dd)), hb, {{==}})')
        rest = RS - c - m
        if i == 0:
            zsrc = 'hz'
        else:
            A0 = '[' + ', '.join(acc) + ']'
            w(f'      +z{i}a = VRX.znext(B, P, {A0}, {Pi}, {c}n, {RS - c}n, UA.BYT({Di}), hX, {{==}}, VRB.pcx(P, {c}n), E{i}, hz)')
            zsrc = f'z{i}a'
        if rest > 0:
            Lz = f'UA.BYT({Di})' if i else 'B'
            w(f'      +hz{i} = VRX.zhead({m}n, {rest}n, VS.bdr({Pi}, {Lz}), {zsrc})')
        else:
            w(f'      +hz{i} = {zsrc}')
        w(f'      +rt{i} = {RTW[k]}(dd, {Di}, {Xi}, {Pi}, {nm}, ep{i}, hd, hb{i}, {pf_cur})')
        w(f'      +by{i} = {BYW[k]}(dd, {Di}, {Xi}, {Pi}, {nm}, ep{i}, hd, hb{i}, {pf_cur}, hz{i})')
        Y = '[' + ', '.join(ys[i]) + ']'
        if i == 0:
            w(f'      +E1 = by0')
        else:
            A0 = '[' + ', '.join(acc) + ']'
            w(f'      +E{i + 1} = Equal.trans(+List<U32>, UA.BYT({Dn}), UW.SPL(UA.BYT({Di}), {Pi}, {Y}), UW.SPL(B, P, VRX.AP({A0}, {Y})), by{i},')
            w(f'        VRX.spl_catx(B, P, {A0}, {Y}, {Pi}, UA.BYT({Di}), hX, VRB.pcx(P, {c}n), E{i}))')
        acc += ys[i]
        pf_cur = f'{PFW[k]}(dd, {Di}, {Pi}, {nm}, {pf_cur})'

    # the runtime: rewrite the innermost put first
    def rt_goal_after(i):
        """the runtime expression with the first i puts already replaced by the model tree D_i."""
        t = f'FD.array__thaw(U32, {tree(i)})'
        for nm, c, k in fields[i:]:
            t = f'{PUT[k]}({t}, U32.add(X, {c}), {nm})'
        return t
    w(f'      +rtf = rtc_{R}(dd, D, X, P, {", ".join(nm for nm, c, k in fields)}, {", ".join(f"rt{i}" for i in range(n))})')
    w(f'      (rtf, E{n})')
    # the runtime chain lemma
    RTP = []
    for i, (nm, c, k) in enumerate(fields):
        RTP.append(f'+rt{i}: {{{PUT[k]}(FD.array__thaw(U32, {tree(i)}), U32.add(X, {c}), {nm}) == FD.array__thaw(U32, {tree(i + 1)}) : Array<U32>}}')
    sig = ', '.join(f'+{nm}: U32' for nm, c, k in fields)
    C = [f'def rtc_{R}(+dd: Nat, +D: {TR}, +X: U32, +P: Nat, {sig},\n    ' + ',\n    '.join(RTP) +
         f')\n    -> {{{rt_goal_after(0)} == FD.array__thaw(U32, {tree(n)}) : Array<U32>}}:']
    for i, (nm, c, k) in enumerate(fields[:-1]):
        lhs = f'{PUT[k]}(FD.array__thaw(U32, {tree(i)}), U32.add(X, {c}), {nm})'
        hole = '_'
        for nm2, c2, k2 in fields[i + 1:]:
            hole = f'{PUT[k2]}({hole}, U32.add(X, {c2}), {nm2})'
        C.append(f'  %Equal.sym(Array<U32>, {lhs}, FD.array__thaw(U32, {tree(i + 1)}), rt{i}) :')
        C.append(f'    {{{hole} == FD.array__thaw(U32, {tree(n)}) : Array<U32>}}')
    C.append(f'  rt{n - 1}')
    text = '\n'.join(L)
    cut = text.index(f'\n# T.{R}_put at X (byte P)')
    text = text[:cut].rstrip('\n') + '\n\n' + '\n'.join(C) + '\n' + text[cut:]
    # the value and its parts
    chain = sch[sch.index('S.Chain'):]
    chain = chain[:len(chain) - (len(chain) - chain.rfind('S.End{}') - len('S.End{}'))]
    chain += '}' * (len(fields) - 1)
    fsch = {'u8': 'S.Unsigned{P.U8{}}', 'u16': 'S.Unsigned{P.U16{}}'}
    prt = {'u8': 'VRB.prt8', 'u16': 'VRB.prt16'}
    dom = {'u8': 'VRB.dom8', 'u16': 'VRB.dom16'}

    def chain_from(i):
        t = 'S.End{}'
        for nm, c, k in reversed(fields[i:]):
            t = f'S.Chain{{{fsch[k]}, {t}}}'
        return t

    def items_from(i):
        t = 'S.EmptyItems{}'
        for nm, c, k in reversed(fields[i:]):
            t = f'S.Items{{{uv[k]}({nm}), {t}}}'
        return t

    def cat(i):
        if i == n:
            return '{==}'
        nm, c, k = fields[i]
        Y = '[' + ', '.join(ys[i]) + ']'
        restp = '[' + ', '.join(f'S.Fixed{{[{", ".join(ys[j])}]}}' for j in range(i + 1, n)) + ']'
        return (f'F.cat_fixed(Codec.parts({uv[k]}({nm}), {fsch[k]}), {Y}, Codec.parts({items_from(i + 1)}, {chain_from(i + 1)}), {restp},\n'
                f'        {prt[k]}({nm}), {cat(i + 1)})')
    PL = '[' + ', '.join(f'S.Fixed{{[{", ".join(ys[j])}]}}' for j in range(n)) + ']'

    def domc(i):
        nm, c, k = fields[i]
        Y = '[' + ', '.join(ys[i]) + ']'
        if i == n - 1:
            return f'SP2.bd_app({Y}, [], {dom[k]}({nm}), {{==}})'
        tail = '[' + ', '.join(sum(ys[i + 1:], [])) + ']'
        return f'SP2.bd_app({Y}, {tail}, {dom[k]}({nm}), {domc(i + 1)})'
    text += f'''

def RV_{R}(o: T.{R}) -> S.Value:
  match o:
    case {pat}: S.Sequence{{{items}}}

# Its parts: its bytes, one fixed part.
def RPRF_{R}(+o: T.{R}) -> {{Codec.parts(RV_{R}(o), {sch}) == Some{{[S.Fixed{{RB_{R}(o)}}]}} : Maybe<&2, +List<S.Part>>}}:
  match o:
    case {pat}:
      %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts({items}, {chain_from(0)}), Some{{{PL}}},
        {cat(0)}) :
        {{Codec.aggregate(_, Some{{{RS}n}}) == Some{{[S.Fixed{{{RB}}}]}} : Maybe<&2, +List<S.Part>>}}
      SP2.agg({PL}, {RS}n, {RS}n, {{==}}, {domc(0)}, {{==}}, {{==}})

def domr_{R}(+o: T.{R}) -> {{SP.bytes_domain(RB_{R}(o)) == {TRUE}}}:
  match o:
    case {pat}: {domc(0)}
'''
    return text


def ok_chain(name, args, sig, cs):
    """Accessors of a conjunction Bool.and(c0, Bool.and(c1, ... c{n-1})): {name}_i(args, h) -> {c_i == True}."""
    def conj(i):
        return cs[i] if i == len(cs) - 1 else f'Bool.and({cs[i]}, {conj(i + 1)})'
    L = []
    for i in range(len(cs) - 1):
        src = 'h' if i == 0 else f'{name}_r{i}({args}, h)'
        L.append(f'def {name}_r{i + 1}({sig}, +h: {{{conj(0)} == {TRUE}}}) -> {{{conj(i + 1)} == {TRUE}}}:')
        L.append(f'  and_r({cs[i]}, {conj(i + 1)}, {src})')
    for i in range(len(cs)):
        src = 'h' if i == 0 else f'{name}_r{i}({args}, h)'
        if i == len(cs) - 1:
            L.append(f'def {name}_{i}({sig}, +h: {{{conj(0)} == {TRUE}}}) -> {{{cs[i]} == {TRUE}}}: {src}')
        else:
            L.append(f'def {name}_{i}({sig}, +h: {{{conj(0)} == {TRUE}}}) -> {{{cs[i]} == {TRUE}}}:')
            L.append(f'  and_l({cs[i]}, {conj(i + 1)}, {src})')
    return conj(0), '\n'.join(L)


SUBLIST = r"""
# ---- @p: the list's bytes, value and parts ----

def EL(+A: @TRR, +j: Nat) -> T.@R: VRL.mget(T.@R, FD.spec_common__nth(T.@R, FD.array__slots(T.@R, A), j), T.@R_default())

# the records j, j + 1, ..., j + c - 1: their bytes, values, parts, and the runtime's validity of each
def RBS(c: Nat, +A: @TRR, +j: Nat) -> +List<U32>:
  match c:
    case 0n: []
    case 1n+p: VRX.AP(RB_@R(EL(A, j)), RBS(p, A, 1n+j))
def ITS(c: Nat, +A: @TRR, +j: Nat) -> S.Value:
  match c:
    case 0n: S.EmptyItems{}
    case 1n+p: S.Items{RV_@R(EL(A, j)), ITS(p, A, 1n+j)}
def BPS(c: Nat, +A: @TRR, +j: Nat) -> +List<S.Part>:
  match c:
    case 0n: []
    case 1n+p: Con{S.Fixed{RB_@R(EL(A, j))}, BPS(p, A, 1n+j)}
def VOK(c: Nat, +A: @TRR, +j: Nat) -> Bool:
  match c:
    case 0n: True{}
    case 1n+p: Bool.and(T.@R_valid(EL(A, j)), VOK(p, A, 1n+j))

law len_rbs:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {List.length(&2, U32, RBS(c, A, j)) == Nat.mul(c, @RSn) : Nat}
def len_rbs(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p:
      %len_rbs(p, A, 1n+j) :
        {List.length(&2, U32, VRX.AP(RB_@R(EL(A, j)), RBS(p, A, 1n+j))) == Nat.add(@RSn, _) : Nat}
      %lenr_@R(EL(A, j)) :
        {List.length(&2, U32, VRX.AP(RB_@R(EL(A, j)), RBS(p, A, 1n+j))) == Nat.add(_, List.length(&2, U32, RBS(p, A, 1n+j))) : Nat}
      VRX.len_app(RB_@R(EL(A, j)), RBS(p, A, 1n+j))

law dom_rbs:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {SP.bytes_domain(RBS(c, A, j)) == True{} : Bool}
def dom_rbs(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: SP2.bd_app(RB_@R(EL(A, j)), RBS(p, A, 1n+j), domr_@R(EL(A, j)), dom_rbs(p, A, 1n+j))

law cnt_its:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {Codec.count(ITS(c, A, j)) == c : Nat}
def cnt_its(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: FD.nat__succ_cong(Codec.count(ITS(p, A, 1n+j)), p, cnt_its(p, A, 1n+j))

law bps_all:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {SP2.allfx(BPS(c, A, j)) == True{} : Bool}
def bps_all(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: bps_all(p, A, 1n+j)

law bps_cat:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {SP2.fcat(BPS(c, A, j)) == RBS(c, A, j) : +List<U32>}
def bps_cat(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, RB_@R(EL(A, j)), z), SP2.fcat(BPS(p, A, 1n+j)), RBS(p, A, 1n+j), bps_cat(p, A, 1n+j))

law prt_its:
  for +c: Nat
  for +A: @TRR
  for +j: Nat
  {Codec.parts(ITS(c, A, j), S.Repeat{@SCH}) == Some{BPS(c, A, j)} : Maybe<&2, +List<S.Part>>}
def prt_its(c, A, j):
  match c:
    case 0n: {==}
    case 1n+ +p:
      F.cat_fixed(Codec.parts(RV_@R(EL(A, j)), @SCH), RB_@R(EL(A, j)), Codec.parts(ITS(p, A, 1n+j), S.Repeat{@SCH}), BPS(p, A, 1n+j),
        RPRF_@R(EL(A, j)), prt_its(p, A, 1n+j))

# ---- @p: the runtime's validity check ----

def AG(+A: @TRR, +i: U32) -> Array<T.@R> & T.@R: Array.get(T.@R, @TH, i)

# get i+1 of the records' array, i = j and 1 + j < 2^da
def geti(+i: U32, +j: Nat, +da: Nat, +A: @TRR, +ei: {U32.to_nat(i) == j : Nat}, +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool},
    +hda: {Nat.is_lt(da, 31n) == True{} : Bool}, +h1: {Nat.is_lt(1n+j, VB.pw(da)) == True{} : Bool})
    -> {AG(A, U32.add(i, 1)) == (@TH, EL(A, 1n+j)) : Array<T.@R> & T.@R}:
  +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
  +hi1 = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(da)) == True{} : Bool}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1), h1)
  +hx = FD.logic__subst(Nat, z => {FD.spec_common__nth(T.@R, FD.array__slots(T.@R, A), z) == Some{EL(A, 1n+j)} : Maybe<&2, T.@R>}, 1n+j, U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+j, ei1),
    VRL.nth_get(T.@R, FD.array__slots(T.@R, A), 1n+j, T.@R_default(), FD.array__len_lt(T.@R, da, A, 1n+j, pfA, h1)))
  FD.array__get(T.@R, da, A, U32.add(i, 1), EL(A, 1n+j), VB.lt32(da, hda), hi1, hx, pfA)

def get0(+da: Nat, +A: @TRR, +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool}, +hda: {Nat.is_lt(da, 31n) == True{} : Bool},
    +h0: {Nat.is_lt(0n, VB.pw(da)) == True{} : Bool})
    -> {AG(A, 0) == (@TH, EL(A, 0n)) : Array<T.@R> & T.@R}:
  FD.array__get(T.@R, da, A, 0, EL(A, 0n), VB.lt32(da, hda), h0, VRL.nth_get(T.@R, FD.array__slots(T.@R, A), 0n, T.@R_default(), FD.array__len_lt(T.@R, da, A, 0n, pfA, h0)), pfA)

# The validity loop from record j (index i) on, k + 1 records, all valid.
def vax(k: Nat, +i: U32, +j: Nat, +da: Nat, +A: @TRR, +ei: {U32.to_nat(i) == j : Nat}, +h: {VOK(1n+k, A, j) == True{} : Bool},
    +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool}, +hda: {Nat.is_lt(da, 31n) == True{} : Bool}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == True{} : Bool})
    -> {T.@p_va(k, i, True{}, (@TH, EL(A, j))) == (@TH, True{}) : Array<T.@R> & Bool}:
  match k:
    case 0n:
      %Equal.sym(Bool, T.@R_valid(EL(A, j)), True{}, and_l(T.@R_valid(EL(A, j)), VOK(0n, A, 1n+j), h)) : {(@TH, _) == (@TH, True{}) : Array<T.@R> & Bool}
      {==}
    case 1n+ +p:
      +hv = and_l(T.@R_valid(EL(A, j)), VOK(1n+p, A, 1n+j), h)
      +hr = and_r(T.@R_valid(EL(A, j)), VOK(1n+p, A, 1n+j), h)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      %Equal.sym(Bool, T.@R_valid(EL(A, j)), True{}, hv) : {T.@p_va(p, U32.add(i, 1), _, AG(A, U32.add(i, 1))) == (@TH, True{}) : Array<T.@R> & Bool}
      %Equal.sym(Array<T.@R> & T.@R, AG(A, U32.add(i, 1)), (@TH, EL(A, 1n+j)), geti(i, j, da, A, ei, pfA, hda, h1)) : {T.@p_va(p, U32.add(i, 1), True{}, _) == (@TH, True{}) : Array<T.@R> & Bool}
      vax(p, U32.add(i, 1), 1n+j, da, A, ei1, hr, pfA, hda, hk2)

# ---- @p: the write loop (record j at byte P0 + @RS j) ----

def WX(k: Nat, +j: Nat, +dd: Nat, D: @TR, +P0: Nat, +A: @TRR) -> @TR:
  match k:
    case 0n: PR_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0))
    case 1n+p: WX(p, 1n+j, dd, PR_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0)), P0, A)

law pfWX:
  for +k: Nat
  for +j: Nat
  for +dd: Nat
  for +D: @TR
  for +P0: Nat
  for +A: @TRR
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, WX(k, j, dd, D, P0, A)) == True{} : Bool}
def pfWX(k, j, dd, D, P0, A, pf):
  match k:
    case 0n: pfr_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0), pf)
    case 1n+ +p: pfWX(p, 1n+j, dd, PR_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0)), P0, A, pfr_@R(EL(A, j), dd, D, VRL.pos(j, @RSn, P0), pf))

def RTK(k: Nat, +i: U32, +j: Nat, +X: U32, +P0: Nat, +dd: Nat, +D: @TR, +A: @TRR) -> Data:
  {T.@p_pt(k, i, X, FD.array__thaw(U32, D), (@TH, EL(A, j))) == (FD.array__thaw(U32, WX(k, j, dd, D, P0, A)), @TH) : @RTP}
def BYK(k: Nat, +j: Nat, +P0: Nat, +dd: Nat, +D: @TR, +A: @TRR) -> Data:
  {UA.BYT(WX(k, j, dd, D, P0, A)) == UW.SPL(UA.BYT(D), VRL.pos(j, @RSn, P0), RBS(1n+k, A, j)) : +List<U32>}

# The loop from record j (index i) on, k + 1 records, into LT bytes at X (byte P0) whose last k + 1 records' bytes are zero.
def ptx(k: Nat, +i: U32, +j: Nat, +X: U32, +P0: Nat, +dd: Nat, +D: @TR, +da: Nat, +A: @TRR, +LT: Nat,
    +ei: {U32.to_nat(i) == j : Nat}, +e: {U32.to_nat(X) == P0 : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), @RSn), LT) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P0, LT), A.quad(VB.pw(dd))) == True{} : Bool},
    +hz: {VS.bt(Nat.mul(1n+k, @RSn), VS.bdr(VRL.pos(j, @RSn, P0), UA.BYT(D))) == UW.ZB(Nat.mul(1n+k, @RSn)) : +List<U32>},
    +pfA: {FD.array__perfect(T.@R, da, A) == True{} : Bool}, +hda: {Nat.is_lt(da, 31n) == True{} : Bool}, +hk: {Nat.is_lt(Nat.add(k, j), VB.pw(da)) == True{} : Bool})
    -> DK.P2(RTK(k, i, j, X, P0, dd, D, A), BYK(k, j, P0, dd, D, A)):
  match k:
    case 0n:
      +o = EL(A, j)
      +Pj = VRL.pos(j, @RSn, P0)
      +Xj = U32.add(X, U32.mul(i, @RS))
      +hbj = VRB.rroomb(j, 0n, @RSn, P0, LT, A.quad(VB.pw(dd)), hj, hb)
      +ej = VRB.posb(dd, X, i, j, @RS, @RSn, P0, {==}, e, ei, hd, hbj)
      +g = putr_@R(o, dd, D, Xj, Pj, ej, hd, hbj, pfD, hz)
      +rt = PA(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +by = PB(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +D1 = PR_@R(o, dd, D, Pj)
      +Y = RB_@R(o)
      +rt0 = Equal.cong(Array<U32>, @RTP, z => (z, @TH), T.@R_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +by0 = FD.logic__subst(+List<U32>, z => {UA.BYT(D1) == UW.SPL(UA.BYT(D), Pj, z) : +List<U32>}, Y, List.append(&2, U32, Y, []),
        Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)), by)
      (rt0, by0)
    case 1n+ +p:
      +o = EL(A, j)
      +Pj = VRL.pos(j, @RSn, P0)
      +Xj = U32.add(X, U32.mul(i, @RS))
      +hbj = VRB.rroomb(j, 1n+p, @RSn, P0, LT, A.quad(VB.pw(dd)), hj, hb)
      +ej = VRB.posb(dd, X, i, j, @RS, @RSn, P0, {==}, e, ei, hd, hbj)
      +bm = Nat.mul(1n+p, @RSn)
      +B0 = UA.BYT(D)
      +hz0 = VRX.zhead(@RSn, bm, VS.bdr(Pj, B0), hz)
      +g = putr_@R(o, dd, D, Xj, Pj, ej, hd, hbj, pfD, hz0)
      +rt = PA(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +by = PB(RTR_@R(o, dd, D, Xj, Pj), BYR_@R(o, dd, D, Pj), g)
      +D1 = PR_@R(o, dd, D, Pj)
      +pf1 = pfr_@R(o, dd, D, Pj, pfD)
      +Y = RB_@R(o)
      +hX = VRB.hxb(Pj, @RSn, dd, D, pfD, hbj)
      +ey = VRB.pnext(j, @RSn, P0)
      +z1 = VRX.znext(B0, Pj, Y, VRL.pos(1n+j, @RSn, P0), @RSn, bm, UA.BYT(D1), hX, lenr_@R(o), ey, by, hz)
      +h1 = FD.nat__le_lt_trans(1n+j, 1n+Nat.add(p, j), VB.pw(da), Order.left_below_sum(p, j), hk)
      +ei1 = VB.add_le_at(i, 1, j, da, ei, hda, FD.nat__lt_le(1n+j, VB.pw(da), h1))
      +eg = geti(i, j, da, A, ei, pfA, hda, h1)
      +hj2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(1n+z, @RSn), LT) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hj)
      +hk2 = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, 1n+Nat.add(p, j), Nat.add(p, 1n+j), Equal.sym(Nat, Nat.add(p, 1n+j), 1n+Nat.add(p, j), FD.nat__add_succ(p, j)), hk)
      +ih = ptx(p, U32.add(i, 1), 1n+j, X, P0, dd, D1, da, A, LT, ei1, e, hd, pf1, hj2, hb, z1, pfA, hda, hk2)
      +rt2 = PA(RTK(p, U32.add(i, 1), 1n+j, X, P0, dd, D1, A), BYK(p, 1n+j, P0, dd, D1, A), ih)
      +by2 = PB(RTK(p, U32.add(i, 1), 1n+j, X, P0, dd, D1, A), BYK(p, 1n+j, P0, dd, D1, A), ih)
      +ea = Equal.cong(Array<U32>, @RTP, z => T.@p_pt(p, U32.add(i, 1), X, z, AG(A, U32.add(i, 1))), T.@R_put(FD.array__thaw(U32, D), Xj, o), FD.array__thaw(U32, D1), rt)
      +eb = Equal.cong(Array<T.@R> & T.@R, @RTP, z => T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), z), AG(A, U32.add(i, 1)), (@TH, EL(A, 1n+j)), eg)
      +rt3 = Equal.trans(@RTP, T.@p_pt(p, U32.add(i, 1), X, T.@R_put(FD.array__thaw(U32, D), Xj, o), AG(A, U32.add(i, 1))), T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG(A, U32.add(i, 1))),
        (FD.array__thaw(U32, WX(p, 1n+j, dd, D1, P0, A)), @TH), ea,
        Equal.trans(@RTP, T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), AG(A, U32.add(i, 1))), T.@p_pt(p, U32.add(i, 1), X, FD.array__thaw(U32, D1), (@TH, EL(A, 1n+j))),
          (FD.array__thaw(U32, WX(p, 1n+j, dd, D1, P0, A)), @TH), eb, rt2))
      +rest = RBS(1n+p, A, 1n+j)
      +eXn = Equal.trans(Nat, VRL.pos(1n+j, @RSn, P0), Nat.add(Pj, @RSn), Nat.add(Pj, VRX.LN(Y)), ey,
        Equal.cong(Nat, Nat, z => Nat.add(Pj, z), @RSn, VRX.LN(Y), Equal.sym(Nat, VRX.LN(Y), @RSn, lenr_@R(o))))
      +by3 = Equal.trans(+List<U32>, UA.BYT(WX(p, 1n+j, dd, D1, P0, A)), UW.SPL(UA.BYT(D1), VRL.pos(1n+j, @RSn, P0), rest), UW.SPL(B0, Pj, VRX.AP(Y, rest)), by2,
        VRX.spl_catx(B0, Pj, Y, rest, VRL.pos(1n+j, @RSn, P0), UA.BYT(D1), hX, eXn, by))
      (rt3, by3)

# ---- @p: the encoder-window interface ----

# The object's Data mirror: the tree A of depth da holding the N records.
type MW is Data:
  MW{da: Nat, A: @TRR, N: U32}

def TH(m: MW) -> T.@p_Seq:
  match m:
    case MW{+da, +A, +N}: T.@p_Seq{@TH, N}

# A valid object: a perfect tree of depth < 28 with room for the N records, whose @RS N bytes fit
# 4 2^da@OKDOC, and whose records pass the runtime's check.
@OKDEFS
def OK(m: MW) -> Bool:
  match m:
    case MW{+da, +A, +N}: OKT(da, A, N)

def ENC(m: MW) -> +List<U32>:
  match m:
    case MW{+da, +A, +N}: RBS(U32.to_nat(N), A, 0n)
def VAL(m: MW) -> S.Value:
  match m:
    case MW{+da, +A, +N}: S.Sequence{ITS(U32.to_nat(N), A, 0n)}
def SZ(m: MW) -> U32:
  match m:
    case MW{+da, +A, +N}: U32.mul(N, @RS)
def PUTLb(b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +P0: Nat) -> @TR:
  match b:
    case True{}: D
    case False{}: WX(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, P0, A)
def PUTX(m: MW, +dd: Nat, +D: @TR, +q: Nat, +r: Nat) -> @TR:
  match m:
    case MW{+da, +A, +N}: PUTLb(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r))
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, List.length(&2, U32, ENC(m)))

def pfLb(+b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +P0: Nat, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PUTLb(b, A, N, dd, D, P0)) == True{} : Bool}:
  match b:
    case True{}: pf
    case False{}: pfWX(U32.to_nat(U32.sub(N, 1)), 0n, dd, D, P0, A, pf)

# N <= 2^da as the runtime compares it.
def le_cap(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {U32.is_le(N, FD.u32__pow2u(da)) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(da)), Nat.is_le(U32.to_nat(N), U32.to_nat(FD.u32__pow2u(da))), VU.le_u32(N, FD.u32__pow2u(da))) : {_ == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(da)), VB.pw(da), FD.u32__pow2u_value(da, FD.nat__lt_trans(da, 28n, 32n, ok_0(da, A, N, h), {==}))) : {Nat.is_le(U32.to_nat(N), _) == True{} : Bool}
  ok_2(da, A, N, h)
def hda31(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {Nat.is_lt(da, 31n) == True{} : Bool}:
  FD.nat__lt_trans(da, 28n, 31n, ok_0(da, A, N, h), {==})

# The runtime's validity check.
def vnz(+da: Nat, +A: @TRR, +N: U32, +b: Bool, +eb: {U32.is_eq(N, 0) == b : Bool}, +h: {OKT(da, A, N) == True{} : Bool})
    -> {T.@p_va_fin(N, True{}, T.@p_va_nz(b, N, @TH)) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}:
  match b:
    case True{}: {==}
    case False{}:
      +c = U32.to_nat(N)
      +pfA = ok_1(da, A, N, h)
      +hca = ok_2(da, A, N, h)
      +h1 = VRL.cposu(N, c, {==}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hv = FD.logic__subst(Nat, z => {VOK(z, A, 0n) == True{} : Bool}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), ok_@VI(da, A, N, h))
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      %Equal.sym(Array<T.@R> & T.@R, AG(A, 0), (@TH, EL(A, 0n)), get0(da, A, pfA, hda31(da, A, N, h), h0)) :
        {T.@p_va_fin(N, True{}, T.@p_va(k, 0, True{}, _)) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
      %Equal.sym(Array<T.@R> & Bool, T.@p_va(k, 0, True{}, (@TH, EL(A, 0n))), (@TH, True{}), vax(k, 0, 0n, da, A, {==}, hv, pfA, hda31(da, A, N, h), hk)) :
        {T.@p_va_fin(N, True{}, _) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
      {==}

def valid(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}) -> {T.@p_valid(T.@p_Seq{@TH, N}) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}:
  %Equal.sym(Array<T.@R> & U32, Array.size(T.@R, @TH), (@TH, FD.u32__pow2u(da)), FD.array__size_thaw(T.@R, da, A, ok_1(da, A, N, h))) :
    {T.@p_va_cap(@OKARG, N, _) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
@LIMRW  %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(da)), True{}, le_cap(da, A, N, h)) :
    {T.@p_va_go(Bool.and(@OKARG1, _), N, @TH) == (T.@p_Seq{@TH, N}, True{}) : T.@p_Seq & Bool}
  vnz(da, A, N, U32.is_eq(N, 0), {==}, h)

def RTN(+b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +P0: Nat) -> Data:
  {T.@p_pt_nz(b, X, N, FD.array__thaw(U32, D), @TH) == (FD.array__thaw(U32, PUTLb(b, A, N, dd, D, P0)), T.@p_Seq{@TH, N}) : Array<U32> & T.@p_Seq}
def BYN(+b: Bool, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +P0: Nat) -> Data:
  {UA.BYT(PUTLb(b, A, N, dd, D, P0)) == UW.SPL(UA.BYT(D), P0, RBS(U32.to_nat(N), A, 0n)) : +List<U32>}

# The writer's non-empty test, and its loop.
def ptnz(+da: Nat, +A: @TRR, +N: U32, +b: Bool, +eb: {U32.is_eq(N, 0) == b : Bool}, +h: {OKT(da, A, N) == True{} : Bool}, +dd: Nat, +D: @TR, +X: U32, +P0: Nat,
    +e: {U32.to_nat(X) == P0 : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P0, Nat.mul(U32.to_nat(N), @RSn)), A.quad(VB.pw(dd))) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(Nat.mul(U32.to_nat(N), @RSn), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.mul(U32.to_nat(N), @RSn)) : +List<U32>})
    -> DK.P2(RTN(b, A, N, dd, D, X, P0), BYN(b, A, N, dd, D, P0)):
  match b:
    case True{}:
      +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, 0, FD.u32alg__eq_of(N, 0, eb))
      ({==}, FD.logic__subst(Nat, z => {UA.BYT(D) == UW.SPL(UA.BYT(D), P0, RBS(z, A, 0n)) : +List<U32>}, 0n, U32.to_nat(N), Equal.sym(Nat, U32.to_nat(N), 0n, eN),
        Equal.sym(+List<U32>, UW.SPL(UA.BYT(D), P0, []), UA.BYT(D), VRX.spl_nil(UA.BYT(D), P0))))
    case False{}:
      +c = U32.to_nat(N)
      +LL = Nat.mul(c, @RSn)
      +pfA = ok_1(da, A, N, h)
      +hda = hda31(da, A, N, h)
      +hca = ok_2(da, A, N, h)
      +h1 = VRL.cposu(N, c, {==}, eb)
      +k = U32.to_nat(U32.sub(N, 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(N, 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +hj = FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(z, @RSn), LL) == True{} : Bool}, c, Nat.add(1n+k, 0n),
        Equal.trans(Nat, c, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, 1n+k, c, e1), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k))), FD.nat__le_refl(LL))
      +hz2 = FD.logic__subst(Nat, z => {VS.bt(Nat.mul(z, @RSn), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.mul(z, @RSn)) : +List<U32>}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hz)
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(da)) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(da), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, 1n+k, c, e1, FD.nat__lt_succ(k)), hca))
      +h0 = FD.nat__lt_le_trans(0n, c, VB.pw(da), FD.nat__succ_le_lt(0n, c, h1), hca)
      +eg0 = get0(da, A, pfA, hda, h0)
      +g = ptx(k, 0, 0n, X, P0, dd, D, da, A, LL, {==}, e, hd, pf, hj, hb, hz2, pfA, hda, hk)
      +rt = PA(RTK(k, 0, 0n, X, P0, dd, D, A), BYK(k, 0n, P0, dd, D, A), g)
      +by = PB(RTK(k, 0, 0n, X, P0, dd, D, A), BYK(k, 0n, P0, dd, D, A), g)
      +ea = Equal.cong(Array<T.@R> & T.@R, Array<U32> & T.@p_Seq, z => T.@p_pt_fin(N, T.@p_pt(k, 0, X, FD.array__thaw(U32, D), z)), AG(A, 0), (@TH, EL(A, 0n)), eg0)
      +eb2 = Equal.cong(@RTP, Array<U32> & T.@p_Seq, z => T.@p_pt_fin(N, z), T.@p_pt(k, 0, X, FD.array__thaw(U32, D), (@TH, EL(A, 0n))), (FD.array__thaw(U32, WX(k, 0n, dd, D, P0, A)), @TH), rt)
      (Equal.trans(Array<U32> & T.@p_Seq, T.@p_pt_fin(N, T.@p_pt(k, 0, X, FD.array__thaw(U32, D), AG(A, 0))), T.@p_pt_fin(N, T.@p_pt(k, 0, X, FD.array__thaw(U32, D), (@TH, EL(A, 0n)))),
         T.@p_pt_fin(N, (FD.array__thaw(U32, WX(k, 0n, dd, D, P0, A)), @TH)), ea, eb2),
       FD.logic__subst(Nat, z => {UA.BYT(WX(k, 0n, dd, D, P0, A)) == UW.SPL(UA.BYT(D), P0, RBS(z, A, 0n)) : +List<U32>}, 1n+k, c, e1, by))

# The hypotheses of the interface, on the mirror's pieces.
def hbx(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +q: Nat, +r: Nat,
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(MW{da, A, N}))))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), Nat.mul(U32.to_nat(N), @RSn)), A.quad(VB.pw(dd))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), z), A.quad(VB.pw(dd))) == True{} : Bool}, List.length(&2, U32, ENC(MW{da, A, N})), Nat.mul(U32.to_nat(N), @RSn),
    len_rbs(U32.to_nat(N), A, 0n), VRX.xend(q, r, List.length(&2, U32, ENC(MW{da, A, N})), dd, hl))
def hzx(+da: Nat, +A: @TRR, +N: U32, +r: Nat, +P0: Nat, +D: @TR,
    +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N})), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N}))) : +List<U32>})
    -> {VS.bt(Nat.mul(U32.to_nat(N), @RSn), VS.bdr(P0, UA.BYT(D))) == UW.ZB(Nat.mul(U32.to_nat(N), @RSn)) : +List<U32>}:
  FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(P0, UA.BYT(D))) == UW.ZB(z) : +List<U32>}, List.length(&2, U32, ENC(MW{da, A, N})), Nat.mul(U32.to_nat(N), @RSn),
    len_rbs(U32.to_nat(N), A, 0n), WD.zpre(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N}), VS.bdr(P0, UA.BYT(D)), hz))

def RTX(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +P0: Nat) -> Data:
  {T.@p_putk(FD.array__thaw(U32, D), X, T.@p_Seq{@TH, N}) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, U32.mul(N, @RS))) : Array<U32> & (T.@p_Seq & U32)}

def putk_rt(+da: Nat, +A: @TRR, +N: U32, +h: {OKT(da, A, N) == True{} : Bool}, +dd: Nat, +D: @TR, +X: U32, +P0: Nat,
    +rtb: RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0)) -> RTX(da, A, N, dd, D, X, P0):
  %Equal.sym(T.@p_Seq & Bool, T.@p_valid(T.@p_Seq{@TH, N}), (T.@p_Seq{@TH, N}, True{}), valid(da, A, N, h)) :
    {T.@p_pk(FD.array__thaw(U32, D), X, _) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, U32.mul(N, @RS))) : Array<U32> & (T.@p_Seq & U32)}
  %Equal.sym(Array<U32> & T.@p_Seq, T.@p_pt_nz(U32.is_eq(N, 0), X, N, FD.array__thaw(U32, D), @TH), (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), T.@p_Seq{@TH, N}), rtb) :
    {T.@p_ptn_fin(N, _) == (FD.array__thaw(U32, PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), (T.@p_Seq{@TH, N}, U32.mul(N, @RS))) : Array<U32> & (T.@p_Seq & U32)}
  {==}

def go(+da: Nat, +A: @TRR, +N: U32, +dd: Nat, +D: @TR, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(MW{da, A, N}))))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N})), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(MW{da, A, N})), PADB(r, MW{da, A, N}))) : +List<U32>},
    +h: {OKT(da, A, N) == True{} : Bool})
    -> DK.P2(RTN(U32.is_eq(N, 0), A, N, dd, D, X, Nat.add(A.quad(q), r)), BYN(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r))):
  ptnz(da, A, N, U32.is_eq(N, 0), {==}, h, dd, D, X, Nat.add(A.quad(q), r), e, hd, hbx(da, A, N, dd, q, r, hl), pf, hzx(da, A, N, r, Nat.add(A.quad(q), r), D, hz))

# ---- the interface's laws ----------------------------------------------------------------------

law putx:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_putk(FD.array__thaw(U32, D), X, TH(m)) == (FD.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : Array<U32> & (T.@p_Seq & U32)}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+da, +A, +N}:
      +P0 = Nat.add(A.quad(q), r)
      +g = go(da, A, N, dd, D, X, q, r, e, hd, pf, hl, hz, hok)
      putk_rt(da, A, N, hok, dd, D, X, P0, PA(RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0), BYN(U32.is_eq(N, 0), A, N, dd, D, P0), g))

law putx_bytes:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+da, +A, +N}:
      +P0 = Nat.add(A.quad(q), r)
      +g = go(da, A, N, dd, D, X, q, r, e, hd, pf, hl, hz, hok)
      +E = RBS(U32.to_nat(N), A, 0n)
      Equal.trans(+List<U32>, UA.BYT(PUTLb(U32.is_eq(N, 0), A, N, dd, D, P0)), UW.SPL(UA.BYT(D), P0, E), UW.SPL(UA.BYT(D), P0, List.append(&2, U32, E, UW.ZB(PADB(r, MW{da, A, N})))),
        PB(RTN(U32.is_eq(N, 0), A, N, dd, D, X, P0), BYN(U32.is_eq(N, 0), A, N, dd, D, P0), g),
        VRB.spl_pad(UA.BYT(D), P0, E, List.length(&2, U32, E), PADB(r, MW{da, A, N}), {==}, hz))

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: @TR
  for +q: Nat
  for +r: Nat
  for +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}
  {FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{} : Bool}
def pfx(m, dd, D, q, r, pf):
  match m:
    case MW{+da, +A, +N}: pfLb(U32.is_eq(N, 0), A, N, dd, D, Nat.add(A.quad(q), r), pf)

law szx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}
def szx(m, hok):
  match m:
    case MW{+da, +A, +N}:
      +Q = A.quad(VB.pw(da))
      +hp = FD.u32__pow2u_value(2n+da, FD.nat__lt_trans(2n+da, 30n, 32n, ok_0(da, A, N, hok), {==}))
      Equal.trans(Nat, U32.to_nat(U32.mul(N, @RS)), Nat.mul(U32.to_nat(N), @RSn), List.length(&2, U32, RBS(U32.to_nat(N), A, 0n)),
        VU.mul_le(N, @RS, FD.u32__pow2u(2n+da), FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(N), @RSn), z) == True{} : Bool}, Q, U32.to_nat(FD.u32__pow2u(2n+da)),
          Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(2n+da)), Q, hp), ok_3(da, A, N, hok))),
        Equal.sym(Nat, List.length(&2, U32, RBS(U32.to_nat(N), A, 0n)), Nat.mul(U32.to_nat(N), @RSn), len_rbs(U32.to_nat(N), A, 0n)))

law sizex:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@p_size(TH(m)) == (TH(m), SZ(m)) : T.@p_Seq & U32}
def sizex(m, hok):
  match m:
    case MW{+da, +A, +N}:
      %Equal.sym(Array<T.@R> & U32, Array.size(T.@R, @TH), (@TH, FD.u32__pow2u(da)), FD.array__size_thaw(T.@R, da, A, ok_1(da, A, N, hok))) :
        {T.@p_szf(N, _) == (T.@p_Seq{@TH, N}, U32.mul(N, @RS)) : T.@p_Seq & U32}
      %Equal.sym(Bool, U32.is_le(N, FD.u32__pow2u(da)), True{}, le_cap(da, A, N, hok)) :
        {(T.@p_Seq{@TH, N}, O.pick(_, U32.mul(N, @RS), 2147483648)) == (T.@p_Seq{@TH, N}, U32.mul(N, @RS)) : T.@p_Seq & U32}
      {==}

law encx_spec:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Codec.parts(VAL(m), @LSCH) == Some{[S.Variable{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def encx_spec(m, hok):
  match m:
    case MW{+da, +A, +N}:
      +c = U32.to_nat(N)
      +FS = Nat.mul(c, @RSn)
      +Y = RBS(c, A, 0n)
      +ha = bps_all(c, A, 0n)
      +cat = bps_cat(c, A, 0n)
      +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, FS, Nat.add(FS, 0n), Equal.sym(Nat, Nat.add(FS, 0n), FS, FD.nat__add_zero(FS)),
        VFT.fits4(2n+da, FS, ok_3(da, A, N, hok), FD.nat__lt_trans(da, 28n, 30n, ok_0(da, A, N, hok), {==})))
      +hs = Equal.trans(Nat, Layout.fixed_size(BPS(c, A, 0n)), List.length(&2, U32, SP2.fcat(BPS(c, A, 0n))), FS, SP2.fsz(BPS(c, A, 0n), ha),
        Equal.trans(Nat, List.length(&2, U32, SP2.fcat(BPS(c, A, 0n))), List.length(&2, U32, Y), FS, Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), SP2.fcat(BPS(c, A, 0n)), Y, cat), len_rbs(c, A, 0n)))
      +hfp = Equal.trans(+List<U32>, Layout.fixed_parts(BPS(c, A, 0n), FS), SP2.fcat(BPS(c, A, 0n)), Y, SP2.fxp(BPS(c, A, 0n), FS, ha), cat)
      +hv = SP2.bvl(BPS(c, A, 0n), ha, FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == True{} : Bool}, Y, SP2.fcat(BPS(c, A, 0n)), Equal.sym(+List<U32>, SP2.fcat(BPS(c, A, 0n)), Y, cat), dom_rbs(c, A, 0n)))
@SPECRW      %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(ITS(c, A, 0n), S.Repeat{@SCH}), Some{BPS(c, A, 0n)}, prt_its(c, A, 0n)) :
        {@AGG(Codec.aggregate(_, None{})) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(BPS(c, A, 0n)), Some{List.append(&2, U32, Y, [])},
          VMV.enc_gen(BPS(c, A, 0n), FS, Y, [], hs, hfp, SP2.pay0(BPS(c, A, 0n), ha), hv, fit)) :
        {Codec.one(_, None{}) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) : {Codec.one(Some{_}, None{}) == Some{[S.Variable{Y}]} : Maybe<&2, +List<S.Part>>}
      {==}
"""


def sub_text(p, R, LIM):
    RS, sch, fields = sub_fields(R)
    TRR = f'FD.array__Tree<T.{R}>'
    TH = f'FD.array__thaw(T.{R}, A)'
    cs = ['Nat.is_lt(da, 28n)', f'FD.array__perfect(T.{R}, da, A)', 'Nat.is_le(U32.to_nat(N), VB.pw(da))',
          f'Nat.is_le(Nat.mul(U32.to_nat(N), {RS}n), A.quad(VB.pw(da)))']
    if LIM:
        cs.append(f'U32.is_le(N, {LIM})')
    cs.append('VOK(U32.to_nat(N), A, 0n)')
    sig = f'+da: Nat, +A: {TRR}, +N: U32'
    conj, acc = ok_chain('ok', 'da, A, N', sig, cs)
    okdefs = f'def OKT({sig}) -> Bool:\n  {conj}\n{acc}'
    if LIM:
        LSCH = f'S.ListOf{{{sch}, {LIM}n}}'
        okarg = f'Bool.or(False{{}}, U32.is_le(N, {LIM}))'
        okarg1 = 'Bool.or(False{}, True{})'
        limrw = (f'  %Equal.sym(Bool, U32.is_le(N, {LIM}), True{{}}, ok_4(da, A, N, h)) :\n'
                 f'    {{T.@p_va_go(Bool.and(Bool.or(False{{}}, _), U32.is_le(N, FD.u32__pow2u(da))), N, @TH) == (T.@p_Seq{{@TH, N}}, True{{}}) : T.@p_Seq & Bool}}\n')
        specrw = (f'      +hlim = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le(N, {LIM}), Nat.is_le(U32.to_nat(N), U32.to_nat({LIM})), VU.le_u32(N, {LIM}), ok_4(da, A, N, hok))\n'
                  f'      %Equal.sym(Nat, Codec.count(ITS(c, A, 0n)), c, cnt_its(c, A, 0n)) :\n'
                  f'        {{Codec.require(Nat.is_le(_, {LIM}n), Codec.aggregate(Codec.parts(ITS(c, A, 0n), S.Repeat{{@SCH}}), None{{}})) == Some{{[S.Variable{{Y}}]}} : Maybe<&2, +List<S.Part>>}}\n'
                  f'      %Equal.sym(Bool, Nat.is_le(c, {LIM}n), True{{}}, hlim) :\n'
                  f'        {{Codec.require(_, Codec.aggregate(Codec.parts(ITS(c, A, 0n), S.Repeat{{@SCH}}), None{{}})) == Some{{[S.Variable{{Y}}]}} : Maybe<&2, +List<S.Part>>}}\n')
        agg = 'Codec.require(True{}, @)'
        okdoc = f', at most {LIM} records'
        vi = 5
    else:
        LSCH = f'S.ProgressiveList{{{sch}}}'
        okarg, okarg1, limrw, specrw, agg, okdoc, vi = 'True{}', 'True{}', '', '', '@', '', 4
    body = SUBLIST
    body = body.replace('@SPECRW', specrw).replace('@LIMRW', limrw).replace('@OKDEFS', okdefs)
    AGG_open, AGG_close = agg.split('@')
    body = body.replace('@AGG(Codec.aggregate(_, None{}))', AGG_open + 'Codec.aggregate(_, None{})' + AGG_close)
    body = (body.replace('@OKARG1', okarg1).replace('@OKARG', okarg).replace('@OKDOC', okdoc).replace('@VI', str(vi))
            .replace('@LSCH', LSCH).replace('@SCH', sch).replace('@TRR', TRR).replace('@TR', 'FD.array__Tree<U32>').replace('@TH', TH)
            .replace('@RTP', f'Array<U32> & Array<T.{R}>').replace('@RSn', f'{RS}n').replace('@RS', str(RS)).replace('@p', p).replace('@R', R))
    L = SUBHEAD + ['', '# GENERATED by codegen/var_rec_enc.py. Do not edit.',
                   f'# {p} (a list of {R} records, {RS} bytes each) in the encoder-window interface, written at any byte',
                   '# position X = 4 q + r of a perfect tree D of depth dd < 29 (see the generator).', '', COMMON]
    return '\n'.join(L) + sub_rec_text(R, RS, sch, fields) + body


def main():
    out = {OUT: module_text()}
    g, names = layout()
    for parent, field in LISTS:
        p, t = list_module(g, names, parent, field)
        out[lfile(p)] = t
    if '--no-big' not in sys.argv:
        for p, X, LIM in BLISTS:
            out[bl_file(p)] = bl_text(p, X, LIM)
        for p, R, LIM in SUBLISTS:
            out[sub_file(p)] = sub_text(p, R, LIM)
        for p in FLISTS:
            out[bl_file(p)] = flist_text(p)
    for n in URECS:
        out[urec_file(n)] = urec_text(n)
    out[lfile(VLIST)] = vlist_module()
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
