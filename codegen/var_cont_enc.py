#!/usr/bin/env python3
"""Encoder windows of variable-size CONTAINERS at any byte position X = 4 q + r.

    python3 codegen/var_cont_enc.py [--check] [--no-big]

For each container C of CONTS, proofs/obj/big_encx_<C>.bend (generated):

  the object OBJ, built from its fields' objects (Data leaves) and its children's mirrors
  (the encoder windows' own: big_encx_bl32's MW, the transactions list's (t, N), a record
  list's (A, N), a fixed byte vector's tree);
  M<k>                    the output tree after the k-th write of the runtime's put chain
                          (codegen/generate.py's emit_fieldset / emit_wide order: per group,
                          its checked writers `putk` and variable fields `putv` (offset word,
                          then the child), then its Data fields, innermost first);
  rt_<g>, rt_C            the runtime's chain, from each write's fact (cong steps);
  putx                    DK.P2( T.C_putn(thaw D, X, OBJ) == (thaw PUTC, (OBJ, SZC)),
                                 DK.P2( BYT(PUTC) == SPL(BYT D, 4 q + r, AP(ENCC, ZB(PADB(r, L)))),
                                        PUTC perfect ) )
                          when the L + PADB(r, L) bytes at X are zero, the L bytes fit the tree,
                          and the children's objects are valid.

The bytes follow the container's region as a list of pieces (proofs/obj/vcont.bend): its fixed
fields and offsets in byte order, its variable fields, the trailing zeros; each write turns one
zero piece into its bytes (reg_put / reg_putc), and each writer's zero window comes from the
pieces not yet written (reg_zero). Positions: vrecx.fpos/froom for the fixed part, vcont.vpos /
croom / padfit / cnext for the variable part (the running cursor).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))

import generate as G  # noqa: E402
import schema  # noqa: E402

CONTS = ['ExecutionPayload', 'ExecutionPayloadHeader', 'ExecutionRequests', 'Attestation']
TR = 'FD.array__Tree<U32>'
TRUE = 'True{} : Bool'
GROUP = G.GROUP


def out_file(C):
    return ROOT / f'proofs/obj/big_encx_{C}.bend'


# ---- leaves -----------------------------------------------------------------------------------------

class Leaf:
    """A Data leaf written at any X by its dispatch lemma (vuwd, vuwv_<p>)."""

    def __init__(self, p, ctor, W, mod, model, rt, by, pf, rt_hz, rec=None, sub=0):
        self.p, self.ctor, self.W, self.mod = p, ctor, W, mod
        self.sub = sub    # a sub-word leaf (uint8 / uint16: its byte count), a piece at any byte (vpiece)
        self.model, self.rt, self.by, self.pf, self.rt_hz = model, rt, by, pf, rt_hz
        self.rec = rec    # a fixed record of codegen/var_rec_enc.py's RECS: its field tree (var_laws.FT)


# the fixed records written by codegen/var_rec_enc.py (proofs/obj/encx_recs.bend), by name: their field trees
_RECFT = None


def rec_ft(n):
    global _RECFT
    if _RECFT is None:
        import var_rec_enc as VRE
        g, names = VRE.layout()
        _RECFT = {m: ft for m, ft in VRE.order(g, names, VRE.RECS)}
    return _RECFT.get(n)


# the packed byte vectors of fixed size written like the fixwords (codegen/var_uwv.py's FWORDS: vuwv_<p>)
FIXW_PACKED = ('v4_b32', 'v6_b32', 'v7_b32')


def is_fixw(fs):
    return fs.fixed and (fs.kind == 'fixwords' or (fs.kind == 'packed' and fs.p in FIXW_PACKED))


# ---- FixW: the fixed non-Data fields written by a checked writer T.<p>_putk returning size 0 ----------------
# (the fixwords / packed word vectors, SyncCommittee, a boxed fixed record); the rt_* put step and putx_text's
# fixw branch read these fields.

class FixW:
    def __init__(self, f, fs):
        self.f, self.fs, self.p = f, fs, fs.p
        self.text = ''
        if fs.kind == 'container' and fs.p == 'SyncCommittee':
            ws = [f'{f}_a{j}' for j in range(12)]
            A_ = ', '.join(ws)
            a = 'V_SyncCommittee'
            self.mod = f'import ./vuwv_SyncCommittee.bend as {a}'
            self.params = [f'+dB_{f}: Nat', f'+TB_{f}: {TR}'] + [f'+{w}: U32' for w in ws]
            self.oargs = [f'dB_{f}', f'TB_{f}'] + ws
            self.hyps = [f'+pfB_{f}: {{FD.array__perfect(U32, dB_{f}, TB_{f}) == {TRUE}}}', f'+hdB_{f}: {{Nat.is_lt(dB_{f}, 31n) == {TRUE}}}',
                         f'+hrB_{f}: {{Nat.is_le(6144n, VB.pw(dB_{f})) == {TRUE}}}']
            self.hargs = [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}']
            self.obj = f'T.SyncCommittee{{O.Words{{FD.array__thaw(U32, TB_{f}), 24576}}, T.Bytes48{{{A_}}}}}'
            self.vt = 'T.SyncCommittee'
            self.model = lambda r, D, q: f'{a}.PX_SyncCommittee({r}, dd, {D}, {q}, TB_{f}, {A_})'
            self.pf = lambda r, D, q, pf: f'{a}.SyncCommitteex_perfect({r}, dd, {D}, {q}, TB_{f}, {A_}, {pf})'
            args = lambda D, X, q, r, e, hr, hl, pf, hz: f'dd, {D}, {X}, {q}, {r}, dB_{f}, TB_{f}, {A_}, {e}, {hr}, hd, {hl}, {pf}, pfB_{f}, hdB_{f}, hrB_{f}, {hz}'  # noqa: E731
            self.rt = lambda *x: f'{a}.SyncCommittee_any({args(*x)})'
            self.by = lambda *x: f'{a}.SyncCommittee_any_bytes({args(*x)})'
            self.Y = f'List.append(&2, U32, VS.bt(U32.to_nat(24576), FX.limbs(UW.SLW(TB_{f}))), FX.limbs([{A_}]))'
            self.hY = f'{a}.SyncCommittee_len(dB_{f}, TB_{f}, {A_}, pfB_{f}, hrB_{f})'
        elif fs.kind == 'box' and rec_ft(fs.p[:-3]) is not None:
            R = fs.p[:-3]
            ft = rec_ft(R)
            ws = [f'{f}_w{j}' for j in range(ft.W)]
            W = ', '.join(ws)
            v = ft.obj(ws)
            self.mod = 'import ./encx_recs.bend as ER'
            self.params = [f'+{w}: U32' for w in ws]
            self.oargs = ws
            self.hyps, self.hargs = [], []
            self.obj = f'O.BSome{{{v}, O.BNone{{}}}}'
            self.vt = f'O.Boxed<T.{R}>'
            self.model = lambda r, D, q: f'ER.PX_{R}({W}, dd, {D}, {q}, {r})'
            self.pf = lambda r, D, q, pf: f'ER.pf_{R}({W}, dd, {D}, {q}, {r}, {pf})'
            args = lambda D, X, q, r, e, hr, hl, pf, hz: f'{W}, dd, {D}, {X}, {q}, {r}, {e}, {hr}, hd, {hl}, {pf}, {hz}'  # noqa: E731
            self.rt = lambda *x: f'bxrt_{f}({args(*x)})'
            self.by = lambda *x: f'PB(ER.RT_{R}({W}, dd, {x[0]}, {x[1]}, {x[2]}, {x[3]}), ER.BY_{R}({W}, dd, {x[0]}, {x[2]}, {x[3]}), ER.putx_{R}({args(*x)}))'
            self.Y = f'FX.limbs([{W}])'
            self.hY = '{==}'
            X0 = 'Nat.add(A.quad(q), r)'
            TY = f'Array<U32> & ({self.vt} & U32)'
            self.text = f'''
# ---- {f}: the boxed {R}, its runtime writer T.{fs.p}_putk (encx_recs.putx_{R}; its check is True) ----
def bxrt_{f}({", ".join(self.params)}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {4 * ft.W}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({4 * ft.W}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({4 * ft.W}n) : +List<U32>}})
    -> {{T.{fs.p}_putk(FD.array__thaw(U32, D), X, {self.obj}) == (FD.array__thaw(U32, ER.PX_{R}({W}, dd, D, q, r)), ({self.obj}, 0)) : {TY}}}:
  +g = ER.putx_{R}({W}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
  +rt = PA(ER.RT_{R}({W}, dd, D, X, q, r), ER.BY_{R}({W}, dd, D, q, r), g)
  Equal.cong(Array<U32>, {TY}, z => (z, ({self.obj}, 0)), T.{R}_put(FD.array__thaw(U32, D), X, {v}), FD.array__thaw(U32, ER.PX_{R}({W}, dd, D, q, r)), rt)
'''
        else:
            nW = fs.fsize // 4
            a = f'V_{fs.p}'
            self.mod = f'import ./vuwv_{fs.p}.bend as {a}'
            self.params = [f'+dB_{f}: Nat', f'+TB_{f}: {TR}']
            self.oargs = [f'dB_{f}', f'TB_{f}']
            self.hyps = [f'+pfB_{f}: {{FD.array__perfect(U32, dB_{f}, TB_{f}) == {TRUE}}}', f'+hdB_{f}: {{Nat.is_lt(dB_{f}, 31n) == {TRUE}}}',
                         f'+hrB_{f}: {{Nat.is_le({nW}n, VB.pw(dB_{f})) == {TRUE}}}']
            self.hargs = [f'pfB_{f}', f'hdB_{f}', f'hrB_{f}']
            self.obj = f'O.Words{{FD.array__thaw(U32, TB_{f}), {fs.fsize}}}'
            self.vt = 'O.Words'
            self.model = lambda r, D, q: f'{a}.PX_{fs.p}({r}, dd, {D}, {q}, TB_{f})'
            self.pf = lambda r, D, q, pf: f'{a}.{fs.p}x_perfect({r}, dd, {D}, {q}, TB_{f}, {pf})'
            args = lambda D, X, q, r, e, hr, hl, pf, hz: f'dd, {D}, {X}, {q}, {r}, dB_{f}, TB_{f}, {e}, {hr}, hd, {hl}, {pf}, pfB_{f}, hdB_{f}, hrB_{f}, {hz}'  # noqa: E731
            self.rt = lambda *x: f'{a}.{fs.p}_any({args(*x)})'
            self.by = lambda *x: f'{a}.{fs.p}_any_bytes({args(*x)})'
            self.Y = f'FX.limbs(VS.wtake({nW}n, UW.SLW(TB_{f})))'
            h64 = (f'FD.logic__subst(Nat, zz => {{Nat.is_le({nW}n, zz) == {TRUE}}}, VB.pw(dB_{f}), List.length(&2, U32, UW.SLW(TB_{f})), '
                   f'Equal.sym(Nat, List.length(&2, U32, UW.SLW(TB_{f})), VB.pw(dB_{f}), Equal.trans(Nat, List.length(&2, U32, UW.SLW(TB_{f})), '
                   f'FD.spec_common__length(U32, UW.SLW(TB_{f})), VB.pw(dB_{f}), VMR.len_eq(UW.SLW(TB_{f})), FD.array__slots_length(U32, dB_{f}, TB_{f}, pfB_{f}))), hrB_{f})')
            self.hY = f'VCN.len_wt({nW}n, UW.SLW(TB_{f}), {h64})'
        self.rtype = f'Array<U32> & ({self.vt} & U32)'


def is_fixw_ext(fs):
    """is_fixw, and the fixed non-Data fields with a FixW entry: SyncCommittee, a boxed record of var_rec_enc."""
    return is_fixw(fs) or (fs.fixed and not fs.data and ((fs.kind == 'container' and fs.p == 'SyncCommittee')
                                                        or (fs.kind == 'box' and fs.p.endswith('_bx') and rec_ft(fs.p[:-3]) is not None)))

def leaf_of(fs):
    if fs.kind in ('u8', 'u16'):
        m = 1 if fs.kind == 'u8' else 2
        return Leaf(fs.p, 'U32', 0, 'import ./vpiece.bend as VPC', f'VPC.P{8 * m}', f'VPC.u{8 * m}piece', None, f'VPC.p{8 * m}_perfect', False, sub=m)
    if fs.kind == 'u64':
        return Leaf('u64', 'O.U64', 2, None, 'WD.W64X', 'WD.w64_any', 'WD.w64_any_bytes', 'WD.w64x_perfect', False)
    if fs.p == 'b20':
        return Leaf('b20', 'T.Bytes20', 5, None, 'WD.B20X', 'WD.b20_any', 'WD.b20_any_bytes', 'WD.b20x_perfect', True)
    if fs.p in ('b32', 'u256', 'b48', 'b96', 'bv512', 'bv64'):
        a = f'V_{fs.p}'
        return Leaf(fs.p, f'T.{fs.rep}', fs.fsize // 4, f'import ./vuwv_{fs.p}.bend as {a}', f'{a}.PX_{fs.p}', f'{a}.{fs.p}_any',
                    f'{a}.{fs.p}_any_bytes', f'{a}.{fs.p}x_perfect', True)
    if fs.kind == 'container' and rec_ft(fs.p) is not None:
        return Leaf(fs.p, f'T.{fs.p}', fs.fsize // 4, 'import ./encx_recs.bend as ER', f'ER.PX_{fs.p}', f'ER.putx_{fs.p}', None,
                    f'ER.pf_{fs.p}', True, rec=rec_ft(fs.p))
    raise SystemExit(f'no leaf writer for {fs.kind}/{fs.p}')


def rec_leaf_text(lf):
    """A fixed record's writer on the object: nested matches exposing its words, then encx_recs' lemmas."""
    import var_rlist_enc as EN
    p = lf.p
    words = []
    ls, ind = EN.nest(lf.rec, 'o', words, 2)
    body = '\n'.join(ls)
    pad = ' ' * ind
    WA = ', '.join(words)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * lf.W
    return f'''
# ---- {p}: its writer on the object (the record's words; proofs/obj/encx_recs.bend) ----
def RW_{p}(o: {lf.ctor}) -> List<&2, U32>:
{body}
{pad}[{WA}]
def PXo_{p}(o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
{body}
{pad}ER.PX_{p}({WA}, dd, D, q, r)
def pfo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PXo_{p}(o, dd, D, q, r)) == {TRUE}}}:
{body}
{pad}ER.pf_{p}({WA}, dd, D, q, r, pf)
def RTo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_{p}(o, dd, D, q, r)) : Array<U32>}}
def BYo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PXo_{p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, FX.limbs(RW_{p}(o))) : +List<U32>}}
def putxo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {B}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({B}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({B}n) : +List<U32>}})
    -> DK.P2(RTo_{p}(o, dd, D, X, q, r), BYo_{p}(o, dd, D, q, r)):
{body}
{pad}ER.putx_{p}({WA}, dd, D, X, q, r, e, hr, hd, hl, pf, hz)
def lenb_{p}(+o: {lf.ctor}) -> {{VCN.LN(FX.limbs(RW_{p}(o))) == {B}n : Nat}}:
{body}
{pad}{{==}}
'''


def leaf_text(lf):
    if lf.rec is not None:
        return rec_leaf_text(lf)
    p, W = lf.p, lf.W
    ws = [f'w{i}' for i in range(W)]
    pat = f'{lf.ctor}{{' + ', '.join('+' + w for w in ws) + '}'
    WA = ', '.join(ws)
    X0 = 'Nat.add(A.quad(q), r)'
    B = 4 * W
    hz = ', hz' if lf.rt_hz else ''
    return f'''
# ---- {p}: its writer on the object ----
def RW_{p}(o: {lf.ctor}) -> List<&2, U32>:
  match o:
    case {pat}: [{WA}]
def PXo_{p}(o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
  match o:
    case {pat}: {lf.model}(r, dd, D, q, {WA})
def pfo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, PXo_{p}(o, dd, D, q, r)) == {TRUE}}}:
  match o:
    case {pat}: {lf.pf}(r, dd, D, q, {WA}, pf)
def RTo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{p}_put(FD.array__thaw(U32, D), X, o) == FD.array__thaw(U32, PXo_{p}(o, dd, D, q, r)) : Array<U32>}}
def BYo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PXo_{p}(o, dd, D, q, r)) == UW.SPL(UA.BYT(D), {X0}, FX.limbs(RW_{p}(o))) : +List<U32>}}
def putxo_{p}(+o: {lf.ctor}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, {B}n))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt({B}n, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({B}n) : +List<U32>}})
    -> DK.P2(RTo_{p}(o, dd, D, X, q, r), BYo_{p}(o, dd, D, q, r)):
  match o:
    case {pat}: ({lf.rt}(dd, D, X, q, r, {WA}, e, hr, hd, hl, pf{hz}), {lf.by}(dd, D, X, q, r, {WA}, e, hr, hd, hl, pf, hz))
def lenb_{p}(+o: {lf.ctor}) -> {{VCN.LN(FX.limbs(RW_{p}(o))) == {B}n : Nat}}:
  match o:
    case {pat}: {{==}}
'''


# ---- children (variable fields) -----------------------------------------------------------------------

class Child:
    """A variable field's encoder window, adapted: its mirror parameters and facts, object, bytes,
    byte count, writer model and laws, returned size."""

    def __init__(self, f, fs):
        self.f, self.fs, self.p = f, fs, fs.p
        if fs.kind == 'bytelist' and fs.p == 'bl32':
            m = f'm_{f}'
            self.mod = 'import ./big_encx_bl32.bend as EB'
            self.params = [f'+{m}: EB.MW']
            self.hyps = [f'+hok_{f}: {{EB.OK({m}) == {TRUE}}}']
            self.oargs = [m]
            self.hargs = [f'hok_{f}']
            self.obj = f'EB.TH({m})'
            self.vt = 'O.Words'
            self.enc = f'EB.ENC({m})'
            self.len = f'List.length(&2, U32, EB.ENC({m}))'
            self.sz = f'EB.SZ({m})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'EB.PUTX({m}, {dd}, {D}, {q}, {r})'
            self.hY = '{==}'
        elif fs.kind == 'seq' and fs.p == 'l1048576_bl1073741824':
            t, N = f't_{f}', f'N_{f}'
            self.mod = 'import ./big_encx_l1048576_bl1073741824.bend as ET'
            self.params = [f'+{t}: FD.array__Tree<ET.MB<ET.WMr>>', f'+{N}: U32']
            self.hyps = [f'+h_{f}: {{ET.OKL({t}, {N}) == {TRUE}}}']
            self.oargs = [t, N]
            self.hargs = [f'h_{f}']
            self.obj = f'ET.THL({t}, {N})'
            self.vt = f'T.{fs.p}_Seq'
            self.enc = f'ET.ENCL({t}, {N})'
            self.len = f'ET.LL({t}, {N})'
            self.sz = f'ET.SZW({t}, {N})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'ET.PUTL({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            self.hY = f'ET.len_encl({t}, {N})'
        elif fs.kind == 'seq' and fs.p.startswith('l') and '_' in fs.p and fs.p not in STD_CHILDREN():
            A_, N = f'A_{f}', f'N_{f}'
            p = fs.p
            R = p.split('_', 1)[1]
            self.mod = f'import ./encx_{p}.bend as EW_{p}'
            a = f'EW_{p}'
            self.params = [f'+{A_}: FD.array__Tree<T.{R}>', f'+{N}: U32']
            self.hyps = [f'+h_{f}: {{{a}.OKL_{p}({A_}, {N}) == {TRUE}}}']
            self.oargs = [A_, N]
            self.hargs = [f'h_{f}']
            self.obj = f'{a}.THL_{p}({A_}, {N})'
            self.vt = f'T.{p}_Seq'
            self.enc = f'{a}.ENCL_{p}({A_}, {N})'
            self.len = f'{a}.LL_{p}({A_}, {N})'
            rs = re.search(r'\(n \* (\d+) : U32\)', fn_body(f'{p}_ptn_fin')).group(1)
            self.sz = f'U32.mul({N}, {rs})'
            self.pad = False
            self.model = lambda dd, D, X, q, r: f'{a}.PUTL_{p}({A_}, {N}, {dd}, {D}, {q}, {r})'
            self.hY = f'{a}.len_encl_{p}({A_}, {N})'
            self.alias = a
        elif fs.p in STD_CHILDREN():
            # a child in var_plist_sub's encoder-window interface (codegen/encx_children.py)
            c = STD_CHILDREN()[fs.p]
            a = f'EX_{fs.p}'
            m = f'm_{f}'
            self.mod = f'import ./{c["file"]} as {a}'
            self.params = [f'+{m}: {a}.{c["mirror"]}']
            self.hyps = [f'+hok_{f}: {{{a}.OK({m}) == {TRUE}}}']
            self.oargs = [m]
            self.hargs = [f'hok_{f}']
            self.obj = f'{a}.TH({m})'
            self.vt = c['obj']
            self.enc = f'{a}.ENC({m})'
            self.len = f'List.length(&2, U32, {a}.ENC({m}))'
            self.sz = f'{a}.SZ({m})'
            self.pad = True
            self.model = lambda dd, D, X, q, r: f'{a}.PUTX({m}, {dd}, {D}, {q}, {r})'
            self.hY = '{==}'
            self.alias = a
            self.std = True
        else:
            raise SystemExit(f'no child window for {fs.kind}/{fs.p}')

    def putx(self, dd, D, X, q, r, e, hr, hd, hl, pf, hz):
        """(runtime fact, bytes fact, perfect fact) terms."""
        f, p = self.f, self.p
        if p == 'bl32':
            m = f'm_{f}'
            a = f'{m}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {pf}, {hl}, {hz}, hok_{f}'
            return f'EB.putx({a})', f'EB.putx_bytes({a})', f'EB.pfx({m}, {dd}, {D}, {q}, {r}, {pf})', None
        if getattr(self, 'std', False):
            m, al = f'm_{f}', self.alias
            a = f'{m}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {pf}, {hl}, {hz}, hok_{f}'
            return f'{al}.putx({a})', f'{al}.putx_bytes({a})', f'{al}.pfx({m}, {dd}, {D}, {q}, {r}, {pf})', None
        t, N = self.oargs
        if p == 'l1048576_bl1073741824':
            g = f'ET.putx({t}, {N}, h_{f}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {hl}, {pf}, {hz})'
            b = f'U32.is_eq({N}, 0)'
            RT = f'ET.RTL({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            BY = f'ET.BYLb({b}, {t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            PF = f'ET.PFLb({b}, {t}, {N}, {dd}, {D}, {X}, {q}, {r})'
            return g, (RT, BY, PF), None, 'P3'
        a = self.alias
        g = f'{a}.putx_{p}({t}, {N}, h_{f}, {dd}, {D}, {X}, {q}, {r}, {e}, {hr}, {hd}, {hl}, {pf}, {hz})'
        RT = f'{a}.RTL_{p}({t}, {N}, {dd}, {D}, {X}, {q}, {r})'
        BY = f'{a}.BYL_{p}({t}, {N}, {dd}, {D}, {q}, {r})'
        PF = f'{a}.PFL_{p}({t}, {N}, {dd}, {D}, {q}, {r})'
        return g, (RT, BY, PF), None, 'P3'

    def szx(self, qc, rc, dd, hd, hlc):
        f, p = self.f, self.p
        if p == 'bl32':
            return f'EB.szx(m_{f}, hok_{f})'
        if getattr(self, 'std', False):
            return f'{self.alias}.szx(m_{f}, hok_{f})'
        t, N = self.oargs
        if p == 'l1048576_bl1073741824':
            hb = (f'FD.nat__le_trans(ET.LL({t}, {N}), A.quad(VB.pw({dd})), VB.pw(30n), VCN.pc_end({qc}, {rc}, ET.LL({t}, {N}), {dd}, ET.LL({t}, {N}), '
                  f'FD.nat__le_refl(ET.LL({t}, {N})), {hlc}), FD.nat__pow2_mono(2n+{dd}, 30n, FD.nat__lt_succ_le({dd}, 28n, {hd})))')
            return f'ET.szx({t}, {N}, h_{f}, 30n, {{==}}, {hb})'
        a = self.alias
        return f'{a}.szx_{p}({t}, {N}, {qc}, {rc}, {dd}, {hd}, {hlc})'


# ---- the runtime's source ---------------------------------------------------------------------------

SRC = None
SRC_FILE = 'types/fulu_obj.bend'
_STD = None


def STD_CHILDREN():
    """The children in the encoder-window interface (codegen/encx_children.py), by runtime prefix;
    bl32 keeps its own branch."""
    global _STD
    if _STD is None:
        import encx_children as EC
        _STD = {p: c for p, c in EC.CHILDREN.items() if p != 'bl32'}
    return _STD


def src():
    global SRC
    if SRC is None:
        SRC = (ROOT / SRC_FILE).read_text()
    return SRC


def fn_body(name):
    m = re.search(rf'^def {re.escape(name)}\(.*?(?=^def |\Z)', src(), re.M | re.S)
    if not m:
        raise SystemExit(f'no runtime def {name}')
    return m.group(0)


def fn_params(name):
    """The parameter names of a runtime def, in order."""
    m = re.search(rf'^def {re.escape(name)}\((.*?)\) ->', src(), re.M)
    if not m:
        raise SystemExit(f'no runtime def {name}')
    ps = []
    d = 0
    cur = ''
    for ch in m.group(1):
        if ch in '<({':
            d += 1
        elif ch in '>)}':
            d -= 1
        if ch == ',' and d == 0:
            ps.append(cur)
            cur = ''
        else:
            cur += ch
    ps.append(cur)
    return [x.split(':')[0].strip().lstrip('+~-') for x in ps]


# ---- the container --------------------------------------------------------------------------------------

class Cont:
    def __init__(self, g, names, C):
        self.C = C
        self.t = names[C]
        self.s = g.shape(self.t)
        self.p = self.s.p
        F = self.s.fields
        self.F = F
        self.hoff, self.fixed = G.container_layout(F)
        self.wide = len(F) > GROUP
        self.leaves = {}
        self.children = {}
        self.fixw = {}
        for i, (f, fs) in enumerate(F):
            if fs.fixed and fs.data:
                lf = leaf_of(fs)
                self.leaves.setdefault(lf.p, lf)
            elif is_fixw_ext(fs):
                self.fixw[f] = FixW(f, fs)
            elif not fs.fixed:
                self.children[f] = Child(f, fs)
            else:
                raise SystemExit(f'field {f}: {fs.kind} not supported')


def generate_cont(g, names, C):
    K = Cont(g, names, C)
    F, hoff, FIX, p = K.F, K.hoff, K.fixed, K.p
    names_ = [f for f, _ in F]
    fsd = dict(F)
    # ---- parameters and the object ----
    OP, OA, HP, HA = [], [], [], []
    OBJF = {}
    for i, (f, fs) in enumerate(F):
        if fs.fixed and fs.data:
            OP.append(f'+{f}: {leaf_of(fs).ctor}')
            OA.append(f)
            OBJF[f] = f
        elif f in K.fixw:
            fw = K.fixw[f]
            OP += fw.params
            OA += fw.oargs
            HP += fw.hyps
            HA += fw.hargs
            OBJF[f] = fw.obj
        else:
            ch = K.children[f]
            OP += ch.params
            OA += ch.oargs
            HP += ch.hyps
            HA += ch.hargs
            OBJF[f] = ch.obj
    # the runtime's check of the sub-word leaves, folded into the returned size (c .|. O.pz(V)): V is a hypothesis
    K.pz = None
    if not K.wide and any(fs.fixed and fs.data for _, fs in F):
        npw = sum(1 for _, fs in F if not fs.fixed)
        if npw:
            b_ = fn_body(f'{p}_pw{npw - 1}')
            j_ = b_.find('O.pz(')
            if j_ >= 0:
                d_, k_ = 0, j_ + len('O.pz(')
                for k_ in range(j_ + len('O.pz('), len(b_)):
                    if b_[k_] == '(':
                        d_ += 1
                    elif b_[k_] == ')':
                        if d_ == 0:
                            break
                        d_ -= 1
                K.pz = re.sub(r'(?<![\w.])([a-z_]\w*)\(', r'T.\1(', b_[j_ + len('O.pz('):k_])
                HP.append(f'+hpz: {{{K.pz} == {TRUE}}}')
                HA.append('hpz')
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS, HAS = ', '.join(HP), ', '.join(HA)
    if K.wide:
        groups = [(k // GROUP, list(range(k, min(k + GROUP, len(F))))) for k in range(0, len(F), GROUP)]
    else:
        groups = [(None, list(range(len(F))))]

    def gname(gk):
        return p if gk is None else f'{p}_g{gk}'

    def grec(gk, idx):
        return f'T.{gname(gk)}{{' + ', '.join(OBJF[names_[i]] for i in idx) + '}'
    if K.wide:
        OBJ = f'T.{C}{{' + ', '.join(grec(gk, idx) for gk, idx in groups) + '}'
    else:
        OBJ = grec(None, groups[0][1])
    X0 = 'Nat.add(A.quad(q), r)'
    MA = f'{OAS}, dd, D, X, q, r'
    MP = f'{OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat'
    # ---- the pieces ----
    pieces = []   # (kind, field, size term)
    fidx = {}
    for i, (f, fs) in enumerate(F):
        fidx[f] = len(pieces)
        pieces.append(('fix' if fs.fixed else 'off', f, f'{fs.fsize}n' if fs.fixed else '4n'))
    var = [f for f, fs in F if not fs.fixed]
    vidx = {}
    for f in var:
        vidx[f] = len(pieces)
        pieces.append(('var', f, K.children[f].len))
    PT = f'WD.PADB(r, LLC({MA}))'
    pieces.append(('pad', None, PT))
    ks_all = [K.children[f].len for f in var]
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    FS = '[' + ', '.join(sz for k, f, sz in pieces if k in ('fix', 'off')) + ']'
    state = [f'UW.ZB({sz})' for _, _, sz in pieces]
    # ---- the runtime's writes, in order ----
    events = []    # dict(kind, field, ...)
    cur_terms = {}

    def group_events(gk, idx, cur0):
        Fg = [(names_[i], F[i][1]) for i in idx]
        varg = [i for i in idx if not F[i][1].fixed]
        ling = [i for i in idx if not F[i][1].data]
        psteps = [('putv', i) for i in varg] + [('put', i) for i in ling if i not in varg]
        cur = cur0
        for kind_, i in psteps:
            f = names_[i]
            if kind_ == 'putv':
                events.append(dict(kind='off', field=f, cur=cur, hoff=hoff[i]))
                events.append(dict(kind='var', field=f, cur=cur))
                cur_terms[f] = cur
                cur = f'O.padd({cur}, {K.children[f].sz})'
            else:
                events.append(dict(kind='fixw', field=f, hoff=hoff[i]))
        if K.pz is not None and psteps:
            cur = f'({cur} .|. O.pz({K.pz}) : U32)'
        for i in idx:
            if F[i][1].fixed and F[i][1].data:
                events.append(dict(kind='leaf', field=names_[i], hoff=hoff[i]))
        return psteps, cur
    GI = []
    cur = f'{FIX}'
    for gk, idx in groups:
        st, cur2 = group_events(gk, idx, cur)
        GI.append((gk, idx, st, cur))
        cur = cur2
    SZC = cur
    # the models
    L = []
    w = L.append
    for lf in K.leaves.values():
        if not lf.sub:
            w(leaf_text(lf))
    for fw in K.fixw.values():
        if fw.text:
            w(fw.text)
    w(f'''
# ---- {C}: the object, its bytes and byte count ----
def OBJC({OPS}) -> T.{C}: {OBJ}
def LLC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Nat: Nat.add({FIX}n, VCN.SUM({KS(ks_all)}))
def SZC({OPS}) -> U32: {SZC}
''')
    if K.pz is not None:
        core = SZC[1:SZC.index(f' .|. O.pz(')]
        w(f'''# the returned size, the leaves valid
def szpz({OPS}, +hpz: {{{K.pz} == {TRUE}}}) -> {{SZC({OAS}) == {core} : U32}}:
  Equal.trans(U32, U32.or({core}, O.pz({K.pz})), U32.or({core}, 0), {core}, Equal.cong(Bool, U32, zb => U32.or({core}, O.pz(zb)), {K.pz}, True{{}}, hpz), UWB.or0r({core}))
''')
    # models M0..Mn
    w(f'def M0({MP}) -> {TR}: D')
    trees = ['D']
    ev_q = {}
    for k, ev in enumerate(events):
        prev = f'M{k}({MA})'
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf' and leaf_of(fs).sub:
            mdl = f'{leaf_of(fs).model}(dd, {prev}, X, {ev["hoff"]}, {f})'
        elif ev['kind'] == 'off' and ev['hoff'] % 4:
            Xc = f'U32.add(X, {ev["hoff"]})'
            mdl = f'WD.W32X(VCN.RX({Xc}), dd, {prev}, VCN.QX({Xc}), {ev["cur"]})'
        elif ev['kind'] == 'leaf':
            lf = leaf_of(fs)
            kw = ev['hoff'] // 4
            mdl = f'PXo_{lf.p}({f}, dd, {prev}, Nat.add({kw}n, q), r)'
        elif ev['kind'] == 'fixw':
            kw = ev['hoff'] // 4
            mdl = K.fixw[f].model('r', prev, f'Nat.add({kw}n, q)')
        elif ev['kind'] == 'off':
            kw = ev['hoff'] // 4
            mdl = f'WD.W32X(r, dd, {prev}, Nat.add({kw}n, q), {ev["cur"]})'
        else:
            Xc = f'U32.add(X, {ev["cur"]})'
            mdl = K.children[f].model('dd', prev, Xc, f'VCN.QX({Xc})', f'VCN.RX({Xc})')
        w(f'def M{k + 1}({MP}) -> {TR}: {mdl}')
    NE = len(events)
    w(f'def PUTC({MP}) -> {TR}: M{NE}({MA})')
    return K, L, events, GI, OBJ, OBJF, OP, OA, HP, HA, pieces, fidx, vidx, var, ks_all, PT, FS, groups, SZC


def module_text(g, names, C):
    K, L, events, GI, OBJ, OBJF, OP, OA, HP, HA, pieces, fidx, vidx, var, ks_all, PT, FS, groups, SZC = generate_cont(g, names, C)
    F, hoff, FIX, p = K.F, K.hoff, K.fixed, K.p
    names_ = [f for f, _ in F]
    fsd = dict(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS, HAS = ', '.join(HP), ', '.join(HA)
    MA = f'{OAS}, dd, D, X, q, r'
    MP = f'{OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat'
    X0 = 'Nat.add(A.quad(q), r)'
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    w = L.append
    Mk = lambda k: f'M{k}({MA})'
    TH = lambda k: f'FD.array__thaw(U32, {Mk(k)})'
    # ---- the putv facts, per variable field ----
    for f in var:
        ch = K.children[f]
        V = ch.obj
        RT = f'Array<U32> & ({ch.vt} & U32)'
        w(f'''
# {f}: its offset word, then its bytes (T.{ch.p}_putv).
def putv_{f}({', '.join(ch.params)}, +D: {TR}, +D1: {TR}, +D2: {TR}, +X: U32, +hoff: U32, +cur: U32,
    +e1: {{O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur) == FD.array__thaw(U32, D1) : Array<U32>}},
    +e2: {{T.{ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), {V}) == (FD.array__thaw(U32, D2), ({V}, {ch.sz})) : {RT}}})
    -> {{T.{ch.p}_putv(FD.array__thaw(U32, D), X, hoff, cur, {V}) == (FD.array__thaw(U32, D2), ({V}, O.padd(cur, {ch.sz}))) : {RT}}}:
  Equal.trans({RT}, T.{ch.p}_pvb(cur, T.{ch.p}_putk(O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur), U32.add(X, cur), {V})),
    T.{ch.p}_pvb(cur, T.{ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), {V})), (FD.array__thaw(U32, D2), ({V}, O.padd(cur, {ch.sz}))),
    Equal.cong(Array<U32>, {RT}, z => T.{ch.p}_pvb(cur, T.{ch.p}_putk(z, U32.add(X, cur), {V})), O.w32(FD.array__thaw(U32, D), U32.add(X, hoff), cur), FD.array__thaw(U32, D1), e1),
    Equal.cong({RT}, {RT}, z => T.{ch.p}_pvb(cur, z), T.{ch.p}_putk(FD.array__thaw(U32, D1), U32.add(X, cur), {V}), (FD.array__thaw(U32, D2), ({V}, {ch.sz})), e2))
''')
    # ---- the runtime chain: facts per write ----
    def fact(k, ev):
        """(inner lhs, rhs) of write k (runtime term on tree M_k)."""
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf':
            return f'T.{leaf_of(fs).p}_put({TH(k)}, U32.add(X, {ev["hoff"]}), {f})', TH(k + 1), 'Array<U32>'
        if ev['kind'] == 'fixw':
            o = OBJF[f]
            return f'T.{fs.p}_putk({TH(k)}, U32.add(X, {ev["hoff"]}), {o})', f'({TH(k + 1)}, ({o}, 0))', K.fixw[f].rtype
        if ev['kind'] == 'off':
            return f'O.w32({TH(k)}, U32.add(X, {ev["hoff"]}), {ev["cur"]})', TH(k + 1), 'Array<U32>'
        ch = K.children[f]
        return f'T.{ch.p}_putk({TH(k)}, U32.add(X, {ev["cur"]}), {ch.obj})', f'({TH(k + 1)}, ({ch.obj}, {ch.sz}))', f'Array<U32> & ({ch.vt} & U32)'
    FACTP = []
    for k, ev in enumerate(events):
        lhs, rhs, ty = fact(k, ev)
        FACTP.append(f'+f{k}: {{{lhs} == {rhs} : {ty}}}')
    FPS = ',\n    '.join(FACTP)
    FAS = ', '.join(f'f{k}' for k in range(len(events)))
    # chain builder
    def chain(ty, steps, start, end):
        """steps: [(ctx lambda body with z, inner lhs, inner rhs, inner type, proof, term after)]"""
        if not steps:
            return '{==}'
        terms = [start] + [s[5] for s in steps]
        def go(j):
            ctx, lhs, rhs, ity, prf, after = steps[j]
            e = f'Equal.cong({ity}, {ty}, z => {ctx}, {lhs}, {rhs}, {prf})'
            if j == len(steps) - 1:
                return e
            return f'Equal.trans({ty}, {terms[j]}, {terms[j + 1]}, {end}, {e}, {go(j + 1)})'
        return go(0)
    # per group: runtime lemma
    evk = {}  # event index by (kind, field)
    for k, ev in enumerate(events):
        evk[(ev['kind'], ev['field'])] = k
    GRT = []
    k0 = 0
    for gi, (gk, idx, psteps, cur0) in enumerate(GI):
        gp = p if gk is None else f'{p}_g{gk}'
        gobj = f'T.{gp}{{' + ', '.join(OBJF[names_[i]] for i in idx) + '}'
        data_only = not psteps
        nev = sum(1 for ev in events if ev['field'] in [names_[i] for i in idx])
        kA, kB = k0, k0 + nev
        k0 = kB
        steps = []
        if data_only:
            RTg = 'Array<U32>'
            start = f'T.{gp}_put({TH(kA)}, X, {cur0}, {gobj})' if K.wide else None
            curterm = None
        else:
            RTg = f'Array<U32> & (T.{gp} & U32)'
            start = f'T.{gp}_put({TH(kA)}, X, {cur0}, {gobj})' if K.wide else f'T.{gp}_putn({TH(kA)}, X, {gobj})'
        # the chain steps
        held = lambda i_ex, reps: [reps.get(names_[i], OBJF[names_[i]]) for i in idx if i != i_ex]
        cur = cur0
        reps = {}
        kk = kA
        for s, (kind_, i) in enumerate(psteps):
            f = names_[i]
            pw = f'T.{gp}_pw{s}'
            pnames = fn_params(f'{gp}_pw{s}')
            if kind_ == 'putv':
                ch = K.children[f]
                args = ['X'] + held(i, reps)
                ctx = f'{pw}({", ".join(args)}, z)'
                lhs = f'T.{ch.p}_putv({TH(kk)}, X, {hoff[i]}, {cur}, {ch.obj})'
                ncur = f'O.padd({cur}, {ch.sz})'
                rhs = f'({TH(kk + 2)}, ({ch.obj}, {ncur}))'
                ity = f'Array<U32> & ({ch.vt} & U32)'
                prf = f'putv_{f}({", ".join(ch.oargs)}, {Mk(kk)}, {Mk(kk + 1)}, {Mk(kk + 2)}, X, {hoff[i]}, {cur}, f{kk}, f{kk + 1})'
                steps.append((ctx, lhs, rhs, ity, prf, f'{pw}({", ".join(args)}, {rhs})'))
                cur = ncur
                kk += 2
            else:
                fs = fsd[f]
                args = ['X', cur] + held(i, reps)
                ctx = f'{pw}({", ".join(args)}, z)'
                o = OBJF[f]
                lhs = f'T.{fs.p}_putk({TH(kk)}, U32.add(X, {hoff[i]}), {o})'
                rhs = f'({TH(kk + 1)}, ({o}, 0))'
                steps.append((ctx, lhs, rhs, K.fixw[f].rtype, f'f{kk}', f'{pw}({", ".join(args)}, {rhs})'))
                cur = f'({cur} .|. 0 : U32)'
                kk += 1
        if K.pz is not None and psteps:
            cur = f'({cur} .|. O.pz({K.pz}) : U32)'
        # the Data fields, innermost first
        dat = [i for i in idx if F[i][1].fixed and F[i][1].data]

        def fw(expr, j0):
            for i in dat[j0:]:
                expr = f'T.{leaf_of(fsd[names_[i]]).p}_put({expr}, U32.add(X, {hoff[i]}), {names_[i]})'
            return expr
        for j, i in enumerate(dat):
            f = names_[i]
            lhs, rhs, ity = fact(kk, events[kk])
            inner = fw('z', j + 1)
            if data_only:
                ctx = inner
                after = fw(rhs, j + 1)
            else:
                ctx = f'({inner}, ({gobj}, {cur}))'
                after = f'({fw(rhs, j + 1)}, ({gobj}, {cur}))'
            steps.append((ctx, lhs, rhs, ity, f'f{kk}', after))
            kk += 1
        assert kk == kB, (gk, kk, kB)
        end = TH(kB) if data_only else f'({TH(kB)}, ({gobj}, {cur}))'
        if start is None:
            start = f'T.{gp}_put({TH(kA)}, X, {gobj})'
        GRT.append((gk, gp, kA, kB, RTg, start, end, cur, gobj, data_only))
        w(f'''
# the runtime's {gp} writes, from its writes' facts
def rt_{gp.replace(p, "G") if gk is not None else "C"}({MP},
    {FPS})
    -> {{{start} == {end} : {RTg}}}:
  {chain(RTg, steps, start, end)}
''')
    # the whole container (wide): putn through the groups
    RTC = f'Array<U32> & (T.{C} & U32)'
    START = f'T.{p}_putn({TH(0)}, X, {OBJ})'
    ENDC = f'({TH(len(events))}, ({OBJ}, {SZC}))'
    if K.wide:
        lin = [x for x in GRT if not x[9]]
        steps = []
        gmap = {x[0]: x for x in GRT}
        allg = [x[0] for x in GRT]
        # putn: the Data groups before the first linear group, then pw0(...)
        first = lin[0]
        assert all(not gmap[gk][9] or gk > first[0] for gk in allg), 'Data groups before the first linear group'
        for j, x in enumerate(lin):
            gk, gp, kA, kB, RTg, start, end, cur, gobj, _ = x
            heldg = [gmap[g2][8] for g2 in allg if g2 != gk]
            if j == 0:
                ctx = f'T.{p}_pw0(X, {", ".join(heldg)}, z)'
            else:
                ctx = f'T.{p}_pw{j}(X, {", ".join(heldg)}, z)'
            nm = 'G' + gp[len(p):]
            prf = f'rt_{nm}({MA}, {FAS})'
            after = f'{ctx.replace("z)", end + ")")}'
            steps.append((ctx, start, end, RTg, prf, after))
            # Data groups after this one (before the next linear one)
            nxt = lin[j + 1][0] if j + 1 < len(lin) else None
            for g2 in allg:
                y = gmap[g2]
                if y[9] and g2 > gk and (nxt is None or g2 < nxt):
                    ctx2 = f'(z, ({OBJ}, {cur}))'
                    nm2 = 'G' + y[1][len(p):]
                    steps.append((ctx2, y[5], y[6], 'Array<U32>', f'rt_{nm2}({MA}, {FAS})', f'({y[6]}, ({OBJ}, {cur}))'))
        chain_rt = chain(RTC, steps, START, ENDC)
    else:
        chain_rt = f'rt_C({MA}, {FAS})'
    w(f'''
# the runtime's put of {C} at X
def rt_all({MP},
    {FPS})
    -> {{{START} == {ENDC} : {RTC}}}:
  {chain_rt}
''')
    return L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC


def K_fixed_count(pieces):
    return sum(1 for k, _, _ in pieces if k in ('fix', 'off'))


def putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC):
    F, FIX = K.F, K.fixed
    fsd = dict(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS = ', '.join(HP)
    MA = f'{OAS}, dd, D, X, q, r'
    X0 = 'Nat.add(A.quad(q), r)'
    LLv = f'LLC({MA})'
    Mk = lambda k: f'M{k}({MA})'
    BY = lambda k: f'UA.BYT({Mk(k)})'
    KS = lambda ks: '[' + ', '.join(ks) + ']'
    st = [f'UW.ZB({sz})' for _, _, sz in pieces]
    L = []
    w = L.append
    ls = []
    a = ls.append
    PTr = f'WD.PADB(r, {LLv})'
    MS = f'VCN.APPN({FS}, VCN.APPN({KS(ks_all)}, [{PTr}]))'
    a(f'+hX = VRX.xstart(q, r, {LLv}, dd, D, pf, hl)')
    a(f'+hz0 = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({X0}, UA.BYT(D))) == UW.ZB(zz) : +List<U32>}}, Nat.add({LLv}, {PTr}), VCN.SUM({MS}), '
      f'Equal.sym(Nat, VCN.SUM({MS}), Nat.add({LLv}, {PTr}), VCN.sum_region({FS}, {KS(ks_all)}, {PTr})), hz)')
    a(f'+I0 = VCN.reg_init(UA.BYT(D), {X0}, {MS}, hz0)')
    a('+pf0 = pf')
    facts = []
    curs = {}
    enc_of = {}
    szx_of = {}
    ec_of = {}
    vj = {f: j for j, f in enumerate(var)}
    nfix = K_fixed_count(pieces)
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        kind = ev['kind']
        UBk, UBn = BY(k), BY(k + 1)
        if (kind == 'leaf' and leaf_of(fs).sub) or (kind == 'off' and ev['hoff'] % 4):
            i = fidx[f]
            c = ev['hoff']
            size = 4 if kind == 'off' else leaf_of(fs).sub
            pre = '[' + ', '.join(st[:i]) + ']'
            post = '[' + ', '.join(st[i + 1:]) + ']'
            Xc = f'U32.add(X, {c})'
            rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
            hk = f'FD.nat__le_trans(Nat.add({c}n, {size}n), {FIX}n, {LLv}, {{==}}, Order.below_sum({FIX}n, VCN.SUM({KS(ks_all)})))'
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
            if kind == 'leaf':
                lf = leaf_of(fs)
                m = lf.sub
                a(f'+g{k} = {lf.rt}(dd, {Mk(k)}, X, {c}, {c}n, q, r, {LLv}, {f}, e, {{==}}, hd, {hk}, hl, pf{k}, z{k})')
                Y = f'[U32.and({f}, 255)]' if m == 1 else f'[U32.and({f}, 255), U32.and(U32.shrn({f}, 8n), 255)]'
                RT_ = f'{{T.{fs.p}_put(FD.array__thaw(U32, {Mk(k)}), {Xc}, {f}) == FD.array__thaw(U32, {lf.model}(dd, {Mk(k)}, X, {c}, {f})) : Array<U32>}}'
                BY_ = f'{{UA.BYT({lf.model}(dd, {Mk(k)}, X, {c}, {f})) == UW.SPL(UA.BYT({Mk(k)}), Nat.add({X0}, {c}n), {Y}) : +List<U32>}}'
                a(f'+rt{k} = PA({RT_}, {BY_}, g{k})')
                a(f'+by{k} = PB({RT_}, {BY_}, g{k})')
                a(f'+pf{k + 1} = {lf.pf}(dd, {Mk(k)}, X, {c}, {f}, pf{k})')
            else:
                cur = ev['cur']
                QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
                pos = f'Nat.add(A.quad({QX}), {RX})'
                a(f'+ep{k} = VPC.ppos(X, {c}, {c}n, q, r, {LLv}, 4n, dd, e, {{==}}, hd, {hk}, hl)')
                a(f'+hl{k} = VPC.proom(X, {c}, {c}n, q, r, {LLv}, 4n, dd, e, {{==}}, hd, {hk}, hl)')
                a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt(4n, VS.bdr(zz, {UBk})) == UW.ZB(4n) : +List<U32>}}, Nat.add({X0}, {c}n), {pos}, ep{k}, z{k})')
                a(f'+rt{k} = WD.w32_any(dd, {Mk(k)}, {Xc}, {QX}, {RX}, {cur}, VC.split4({Xc}), VCN.rx_lt({Xc}), hd, hl{k}, pf{k})')
                a(f'+bw{k} = WD.w32_any_bytes(dd, {Mk(k)}, {Xc}, {QX}, {RX}, {cur}, VC.split4({Xc}), VCN.rx_lt({Xc}), hd, hl{k}, pf{k}, hz{k})')
                Y = f'I.limb({cur})'
                a(f'+by{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, Nat.add({X0}, {c}n), Equal.sym(Nat, Nat.add({X0}, {c}n), {pos}, ep{k}), bw{k})')
                a(f'+pf{k + 1} = WD.w32x_perfect({RX}, dd, {Mk(k)}, {QX}, {cur}, pf{k})')
            a(f'+I{k + 1} = VCN.reg_put0(UA.BYT(D), {X0}, {pre}, {size}n, {post}, {Y}, {UBk}, {UBn}, hX, I{k}, {{==}}, by{k})')
            st[i] = Y
            facts.append(f'rt{k}')
            continue
        if kind in ('leaf', 'fixw', 'off'):
            i = fidx[f]
            c = ev['hoff']
            kw = c // 4
            size = 4 if kind == 'off' else fs.fsize
            pre = '[' + ', '.join(st[:i]) + ']'
            post = '[' + ', '.join(st[i + 1:]) + ']'
            pos = f'Nat.add(A.quad(Nat.add({kw}n, q)), r)'
            rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {size}n, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({size}n, VS.bdr(zz, {UBk})) == UW.ZB({size}n) : +List<U32>}}, {rel}, {pos}, VRX.fpx(q, r, {kw}n), z{k})')
            a(f'+ep{k} = VRX.fpos(X, q, r, {kw}n, {c}, {LLv}, dd, e, {{==}}, hd, {{==}}, hl)')
            a(f'+hl{k} = VRX.froom(q, r, dd, {kw}n, {size}n, {LLv}, FD.nat__le_trans(Nat.add(A.quad({kw}n), {size}n), {FIX}n, {LLv}, {{==}}, Order.below_sum({FIX}n, VCN.SUM({KS(ks_all)}))), hl)')
            Xc = f'U32.add(X, {c})'
            qk = f'Nat.add({kw}n, q)'
            if kind == 'leaf':
                lf = leaf_of(fs)
                a(f'+g{k} = putxo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, r, ep{k}, hr, hd, hl{k}, pf{k}, hz{k})')
                a(f'+rt{k} = PA(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, r), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, r), g{k})')
                a(f'+by{k} = PB(RTo_{lf.p}({f}, dd, {Mk(k)}, {Xc}, {qk}, r), BYo_{lf.p}({f}, dd, {Mk(k)}, {qk}, r), g{k})')
                Y = f'FX.limbs(RW_{lf.p}({f}))'
                hY = f'lenb_{lf.p}({f})'
                a(f'+pf{k + 1} = pfo_{lf.p}({f}, dd, {Mk(k)}, {qk}, r, pf{k})')
                piece = f'VCN.PC({size}n, {Y})'
                reg = 'reg_putc0'
            elif kind == 'fixw':
                fw = K.fixw[f]
                xs = (Mk(k), Xc, qk, 'r', f'ep{k}', 'hr', f'hl{k}', f'pf{k}', f'hz{k}')
                a(f'+rt{k} = {fw.rt(*xs)}')
                a(f'+by{k} = {fw.by(*xs)}')
                Y = fw.Y
                hY = fw.hY
                a(f'+pf{k + 1} = {fw.pf("r", Mk(k), qk, f"pf{k}")}')
                piece = f'VCN.PC({size}n, {Y})'
                reg = 'reg_putc0'
            else:
                cur = ev['cur']
                a(f'+rt{k} = WD.w32_any(dd, {Mk(k)}, {Xc}, {qk}, r, {cur}, ep{k}, hr, hd, hl{k}, pf{k})')
                a(f'+by{k} = WD.w32_any_bytes(dd, {Mk(k)}, {Xc}, {qk}, r, {cur}, ep{k}, hr, hd, hl{k}, pf{k}, hz{k})')
                Y = f'I.limb({cur})'
                hY = '{==}'
                a(f'+pf{k + 1} = WD.w32x_perfect(r, dd, {Mk(k)}, {qk}, {cur}, pf{k})')
                piece = Y
                reg = 'reg_put0'
            a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, VRX.fpx(q, r, {kw}n)), by{k})')
            a(f'+I{k + 1} = VCN.{reg}(UA.BYT(D), {X0}, {pre}, {size}n, {post}, {Y}, {UBk}, {UBn}, hX, I{k}, {hY}, hop{k})')
            st[i] = piece
            facts.append(f'rt{k}')
            continue
        # a variable field
        ch = K.children[f]
        j = vj[f]
        i = vidx[f]
        cur = ev['cur']
        ks_j = ks_all[:j]
        rest = ks_all[j + 1:]
        Lj = ch.len
        aj = f'Nat.add({FIX}n, VCN.SUM({KS(ks_j)}))'
        Xc = f'U32.add(X, {cur})'
        QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
        if j == 0:
            a(f'+ec{k} = VCN.EQN(U32.to_nat({cur}), {aj}, {{==}})')
        else:
            fp = var[j - 1]
            pa = f'Nat.add(Nat.add({FIX}n, VCN.SUM({KS(ks_all[:j - 1])})), {ks_all[j - 1]})'
            a(f'+ec{k} = VCN.cnext({curs[fp]}, {K.children[fp].sz}, {FIX}n, {KS(ks_all[:j - 1])}, {ks_all[j - 1]}, dd, hd, {ec_of[fp]}, {szx_of[fp]}, '
              f'VCN.pc_end(q, r, {LLv}, dd, {pa}, VCN.pc_room({FIX}n, {KS(ks_all[:j - 1])}, {ks_all[j - 1]}, {KS(ks_all[j:])}), hl))')
        ec_of[f] = f'ec{k}'
        curs[f] = cur
        a(f'+hk{k} = VCN.pc_room({FIX}n, {KS(ks_j)}, {Lj}, {KS(rest)})')
        a(f'+ha{k} = FD.nat__le_trans({aj}, Nat.add({aj}, {Lj}), {LLv}, Order.below_sum({aj}, {Lj}), hk{k})')
        a(f'+ep{k} = VCN.vpos(X, {cur}, {aj}, q, r, {LLv}, dd, e, ec{k}, hd, ha{k}, hl)')
        a(f'+hlc{k} = VCN.croom({Xc}, q, r, {aj}, {Lj}, {LLv}, dd, ep{k}, hk{k}, hl)')
        fw = st[:nfix]
        ps = '[' + ', '.join(enc_of[x] for x in var[:j]) + ']'
        pre = f'VCN.LAP([{", ".join(fw)}], VCN.PCL({KS(ks_j)}, {ps}))'
        post = '[' + ', '.join(st[i + 1:]) + ']'
        rel = f'Nat.add({X0}, VCN.LN(VCN.CAT({pre})))'
        pos = f'Nat.add(A.quad({QX}), {RX})'
        a(f'+epc{k} = Equal.trans(Nat, {rel}, Nat.add({X0}, {aj}), {pos}, Equal.cong(Nat, Nat, zz => Nat.add({X0}, zz), VCN.LN(VCN.CAT({pre})), {aj}, '
          f'VCN.eposv([{", ".join(fw)}], {ps}, {KS(ks_j)})), '
          f'Equal.trans(Nat, Nat.add({X0}, {aj}), U32.to_nat({Xc}), {pos}, Equal.sym(Nat, U32.to_nat({Xc}), Nat.add({X0}, {aj}), ep{k}), VC.split4({Xc})))')
        if ch.pad:
            pc = f'WD.PADB({RX}, {Lj})'
            MSr = f'VCN.APPN({KS(rest)}, [{PTr}])'
            a(f'+hp{k} = VCN.zbs_pre({MSr}, {pc}, VCN.padfit({Xc}, q, r, {aj}, {Lj}, {LLv}, VCN.SUM({MSr}), ep{k}, hk{k}, '
              f'VCN.pc_after({FIX}n, {KS(ks_j)}, {Lj}, {KS(rest)}, {PTr})))')
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {pc}, {UBk}, hX, I{k}, hp{k})')
            win = f'Nat.add({Lj}, {pc})'
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({win}, VS.bdr(zz, {UBk})) == UW.ZB({win}) : +List<U32>}}, {rel}, {pos}, epc{k}, z{k})')
        else:
            a(f'+z{k} = VCN.reg_zero(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, 0n, {UBk}, hX, I{k}, {{==}})')
            a(f'+z{k}b = FD.logic__subst(Nat, zz => {{VS.bt(zz, VS.bdr({rel}, {UBk})) == UW.ZB(zz) : +List<U32>}}, Nat.add({Lj}, 0n), {Lj}, FD.nat__add_zero({Lj}), z{k})')
            a(f'+hz{k} = FD.logic__subst(Nat, zz => {{VS.bt({Lj}, VS.bdr(zz, {UBk})) == UW.ZB({Lj}) : +List<U32>}}, {rel}, {pos}, epc{k}, z{k}b)')
        g, parts, pfx, kind_ = ch.putx('dd', Mk(k), Xc, QX, RX, f'VC.split4({Xc})', f'VCN.rx_lt({Xc})', 'hd', f'hlc{k}', f'pf{k}', f'hz{k}')
        if kind_ is None:
            a(f'+rt{k} = {g}')
            a(f'+by{k} = {parts}')
            a(f'+pf{k + 1} = {pfx}')
        else:
            RT, BYt, PF = parts
            a(f'+g{k} = {g}')
            a(f'+rt{k} = PA({RT}, DK.P2({BYt}, {PF}), g{k})')
            a(f'+g{k}b = PB({RT}, DK.P2({BYt}, {PF}), g{k})')
            a(f'+by{k} = PA({BYt}, {PF}, g{k}b)')
            a(f'+pf{k + 1} = PB({BYt}, {PF}, g{k}b)')
        Y = f'VCN.AP({ch.enc}, UW.ZB(WD.PADB({RX}, {Lj})))' if ch.pad else ch.enc
        a(f'+hop{k} = FD.logic__subst(Nat, zz => {{{UBn} == UW.SPL({UBk}, zz, {Y}) : +List<U32>}}, {pos}, {rel}, Equal.sym(Nat, {rel}, {pos}, epc{k}), by{k})')
        if ch.pad:
            a(f'+I{k + 1} = VCN.reg_putc(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {ch.enc}, WD.PADB({RX}, {Lj}), {UBk}, {UBn}, hX, I{k}, {ch.hY}, hp{k}, hop{k})')
        else:
            a(f'+I{k + 1} = VCN.reg_putc0(UA.BYT(D), {X0}, {pre}, {Lj}, {post}, {ch.enc}, {UBk}, {UBn}, hX, I{k}, {ch.hY}, hop{k})')
        a(f'+sz{k} = {ch.szx(QX, RX, "dd", "hd", f"hlc{k}")}')
        szx_of[f] = f'sz{k}'
        enc_of[f] = ch.enc
        st[i] = f'VCN.PC({Lj}, {ch.enc})'
        facts.append(f'rt{k}')
    n = len(events)
    EP = '[' + ', '.join(st[:-1]) + ']'
    ENCC = f'VCN.CAT({EP})'
    a(f'+ef = Equal.trans(+List<U32>, VCN.CAT(VCN.LAP({EP}, [UW.ZB({PTr})])), VCN.AP({ENCC}, VCN.CAT([UW.ZB({PTr})])), VCN.AP({ENCC}, UW.ZB({PTr})), '
      f'VCN.cat_lap({EP}, [UW.ZB({PTr})]), Equal.cong(+List<U32>, +List<U32>, zz => VCN.AP({ENCC}, zz), VCN.AP(UW.ZB({PTr}), []), UW.ZB({PTr}), VS.app_nil(UW.ZB({PTr}))))')
    a(f'+byf = FD.logic__subst(+List<U32>, zz => {{{BY(n)} == UW.SPL(UA.BYT(D), {X0}, zz) : +List<U32>}}, VCN.CAT(VCN.LAP({EP}, [UW.ZB({PTr})])), VCN.AP({ENCC}, UW.ZB({PTr})), ef, I{n})')
    fl = var[-1]
    ksl = ks_all[:-1]
    pa = f'Nat.add(Nat.add({FIX}n, VCN.SUM({KS(ksl)})), {ks_all[-1]})'
    a(f'+szf = VCN.cnext({curs[fl]}, {K.children[fl].sz}, {FIX}n, {KS(ksl)}, {ks_all[-1]}, dd, hd, {ec_of[fl]}, {szx_of[fl]}, '
      f'VCN.pc_end(q, r, {LLv}, dd, {pa}, VCN.pc_room({FIX}n, {KS(ksl)}, {ks_all[-1]}, []), hl))')
    if K.pz is not None:
        a(f'+szf = FD.logic__subst(U32, zz => {{U32.to_nat(zz) == LLC({MA}) : Nat}}, {SZC[1:SZC.index(" .|. O.pz(")]}, SZC({OAS}), Equal.sym(U32, SZC({OAS}), {SZC[1:SZC.index(" .|. O.pz(")]}, szpz({OAS}, hpz)), szf)')
    body = '\n  '.join(ls)
    w(f'''
def ENCC({OPS}) -> +List<U32>: {ENCC}
def RTC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{K.p}_putn(FD.array__thaw(U32, D), X, OBJC({OAS})) == (FD.array__thaw(U32, PUTC({MA})), (OBJC({OAS}), SZC({OAS}))) : Array<U32> & (T.{K.C} & U32)}}
def BYC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(PUTC({MA})) == UW.SPL(UA.BYT(D), {X0}, VCN.AP(ENCC({OAS}), UW.ZB(WD.PADB(r, LLC({MA}))))) : +List<U32>}}
def PFC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {{FD.array__perfect(U32, dd, PUTC({MA})) == {TRUE}}}
def SZXC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data: {{U32.to_nat(SZC({OAS})) == LLC({MA}) : Nat}}

# The four facts as one (built from variables, so no fact's proof term enters another's type).
def mk4({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +a: RTC({MA}), +b: BYC({MA}), +c: PFC({MA}), +d: SZXC({MA}))
    -> DK.P2(RTC({MA}), DK.P2(BYC({MA}), DK.P2(PFC({MA}), SZXC({MA})))):
  (a, (b, (c, d)))

# putx: the runtime's writer of {K.C} at X = 4 q + r is the model PUTC, whose bytes splice the
# container's bytes (and the zeros to the end of the last word) into D's, whose tree is perfect,
# and whose returned size is the byte count.
def putx({OPS}, {HPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == {X0} : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LLC({MA})))), VB.pw(dd)) == {TRUE}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}},
    +hz: {{VS.bt(Nat.add(LLC({MA}), WD.PADB(r, LLC({MA}))), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(Nat.add(LLC({MA}), WD.PADB(r, LLC({MA})))) : +List<U32>}})
    -> DK.P2(RTC({MA}), DK.P2(BYC({MA}), DK.P2(PFC({MA}), SZXC({MA})))):
  {body}
  mk4({MA}, rt_all({MA}, {", ".join(facts)}), byf, pf{n}, szf)
''')
    return L


# ==== the container in the encoder-window interface, with its spec side (a separate module) ============
# proofs/obj/big_encx_<C>_iface.bend imports the container's writer module (as K) and states the
# container in codegen/var_plist_sub.py's ENCX interface: the mirror MW of the writer's parameters, OK
# (the writer's hypotheses as Bools, and the bytes within 2^30), TH, ENC, VAL, SZ, PUTX (at
# XQ(q, r) = U32.from_nat(4 q + r)), PADB, and the laws putx, putx_bytes, szx, encx_spec, domx, and
# pfx / sizex where the children allow. The value is the sequence of the field values (a fixed
# field's value read back from its words: spec_laws.walk; a byte vector held in a words tree:
# vconts.bvw; a child's VAL); its parts are the fields' parts (F.cat_fixed / VS.cat_var), their
# layout the offsets the writer writes (vua_lay.hdr_fp over the running offsets vconts.pstep),
# its encoding the writer's bytes ENCC (the pieces' cells, vcont.pc_id).

def spec_schema(C, generic):
    """(names text, [field schema texts]) of container C, as its spec states it (qualified by Spec.)."""
    fn = ROOT / ('proofs/obj/generic_specs.bend' if generic else 'spec/fulu_schemas.bend')
    src_ = fn.read_text()
    name = C
    while True:
        m = re.search(rf'^def {name}\(\) -> [ST]\.Schema: (.*)$', src_, re.M)
        body = m.group(1).strip()
        mm = re.fullmatch(r'(\w+)\(\)', body)
        if not mm:
            break
        name = mm.group(1)
    body = re.sub(r'\bT\.', 'S.', body)
    m = re.fullmatch(r'S\.(Container|ProgressiveContainer)\{(.*)\}', body)
    import var_winb as WB
    top = WB.split_top(m.group(2))
    names_txt, ch = top[0].strip(), top[1].strip()
    kids = []
    while ch != 'S.End{}':
        a, b = WB.split_top(ch[len('S.Chain{'):-1])
        kids.append(a.strip())
        ch = b.strip()
    q = lambda s: re.sub(r'(?<![\w.])([A-Za-z]\w*)\(\)', r'Spec.\1()', s)
    return names_txt, [q(k) for k in kids], m.group(1)


def split_list(txt):
    import var_winb as WB
    assert txt.startswith('[') and txt.endswith(']')
    return [x.strip() for x in WB.split_top(txt[1:-1])]


def iface_text(C, generic=False):
    global SRC, SRC_FILE
    import spec_laws as SLW
    if generic:
        import generic as GN
        names = {n: t for n, t, err in GN.inventory_all() if err is None}
        if SRC_FILE != 'types/generic_obj.bend':
            SRC, SRC_FILE = None, 'types/generic_obj.bend'
    else:
        names = schema.load(ROOT / 'codegen/fulu.yaml')
        if SRC_FILE != 'types/fulu_obj.bend':
            SRC, SRC_FILE = None, 'types/fulu_obj.bend'
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC = module_text(g, names, C)
    LP = putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC)
    txt = '\n'.join(LP)
    ENCCB = re.search(r'^def ENCC\(.*?\) -> \+List<U32>: VCN\.CAT\((\[.*\])\)$', txt, re.M).group(1)
    EP = [re.sub(r'(?<![\w.])(RW_\w+)\(', r'K.\1(', x) for x in split_list(ENCCB)]
    nv = len(var)
    fw, vw = EP[:len(EP) - nv], EP[len(EP) - nv:]
    F, FIX = K.F, K.fixed
    fsd = dict(F)
    tfs = dict(K.t.fields)
    names_txt, kids, kind = spec_schema(C, generic)
    assert len(kids) == len(F)
    OPS, OAS = ', '.join(OP), ', '.join(OA)
    HPS, HAS = ', '.join(HP), ', '.join(HA)
    TRUE_ = TRUE
    # the writer's hypotheses as Bools
    conj = []
    for h in HP:
        m = re.fullmatch(r'\+(\w+): \{(.*) == True\{\} : Bool\}', h)
        conj.append((m.group(1), m.group(2)))
    Kq = lambda s: re.sub(r'(?<![\w.])(OBJC|ENCC|SZC|PUTC|LLC|RW_\w+|PXo_\w+|pfo_\w+|lenb_\w+|putx)\(', r'K.\1(', s)
    # ---- the fields: value, schema, part, parts proof, bytes proof ----
    fields = []    # dict(kind, f, val, sch, part, prf, dom)
    lvs = {}
    L2 = []
    w = L2.append
    curs = {ev['field']: ev['cur'] for ev in events if ev['kind'] == 'var'}
    for i, (f, fs) in enumerate(F):
        sch = kids[i]
        if fs.fixed and fs.data and leaf_of(fs).sub:
            m_ = leaf_of(fs).sub
            Y = f'[U32.and({f}, 255)]' if m_ == 1 else f'[U32.and({f}, 255), U32.and(U32.shrn({f}, 8n), 255)]'
            fields.append(dict(kind='fix', f=f, val=f'VRB.UV{8 * m_}({f})', sch=sch, part=f'S.Fixed{{{Y}}}', bytes=Y,
                               prf=f'VRB.prt{8 * m_}({f})', psch=f'S.Unsigned{{P.U{8 * m_}{{}}}}'))
        elif fs.fixed and fs.data:
            lf = leaf_of(fs)
            if lf.p not in lvs:
                nd = SLW.walk(g, tfs[f], iter(range(1000000)))
                ren = {x: f'w{j}' for j, x in enumerate(nd.words)}
                sub = lambda s: re.sub(r'\bx(\d+)\b', lambda mm: ren[mm.group(0)], s)
                fx = lambda s: re.sub(r'(?<![\w.])F\.', 'FX.', s)
                ws = [f'w{j}' for j in range(lf.W)]
                pat = f'{lf.ctor}{{' + ', '.join('+' + x for x in ws) + '}'
                B = 4 * lf.W
                if lf.rec is not None:
                    # a fixed record: nested matches expose its words (var_rlist_enc.nest), named as walk names them
                    import var_rlist_enc as EN
                    words = []
                    ls, ind = EN.nest(lf.rec, 'o', words, 2)
                    assert words == nd.words, (words[:4], nd.words[:4])
                    bodyn = '\n'.join(ls)
                    padn = ' ' * ind
                    w(f'''
# ---- {lf.p}: its value, read back from its words, and its parts (a fixed record) ----
def LV_{lf.p}(o: {lf.ctor}) -> S.Value:
{bodyn}
{padn}{fx(nd.val)}
def lvp_{lf.p}(+o: {lf.ctor}) -> {{Codec.parts(LV_{lf.p}(o), {fx(nd.sch)}) == Some{{[S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}(o)))}}]}} : Maybe<&2, +List<S.Part>>}}:
{bodyn}
{padn}CS.pcfix(LV_{lf.p}({fx(nd.obj)}), {fx(nd.sch)}, FX.limbs([{", ".join(nd.words)}]), {B}n, {{==}}, {fx(nd.proof)})
''')
                else:
                    w(f'''
# ---- {lf.p}: its value, read back from its words, and its parts ----
def LV_{lf.p}(o: {lf.ctor}) -> S.Value:
  match o:
    case {pat}: {fx(sub(nd.val))}
def lvp_{lf.p}(+o: {lf.ctor}) -> {{Codec.parts(LV_{lf.p}(o), {fx(nd.sch)}) == Some{{[S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}(o)))}}]}} : Maybe<&2, +List<S.Part>>}}:
  match o:
    case {pat}: CS.pcfix(LV_{lf.p}({lf.ctor}{{{", ".join(ws)}}}), {fx(nd.sch)}, FX.limbs([{", ".join(ws)}]), {B}n, {{==}}, {fx(sub(nd.proof))})
''')
                lvs[lf.p] = (fx(nd.sch), B)
                assert fx(nd.sch) == sch or True
            lsch, B = lvs[lf.p]
            part = f'S.Fixed{{VCN.PC({B}n, FX.limbs(K.RW_{lf.p}({f})))}}'
            fields.append(dict(kind='fix', f=f, val=f'LV_{lf.p}({f})', sch=sch, part=part, bytes=f'VCN.PC({B}n, FX.limbs(K.RW_{lf.p}({f})))',
                               prf=f'lvp_{lf.p}({f})', psch=lsch))
        elif fs.fixed and fs.kind == 'fixwords':
            nW = fs.fsize // 4
            by = f'VCN.PC(A.quad({nW}n), CS.WT({nW}n, TB_{f}))'
            fields.append(dict(kind='fix', f=f, val=f'S.BytesValue{{CS.WT({nW}n, TB_{f})}}', sch=sch, part=f'S.Fixed{{{by}}}', bytes=by,
                               prf=f'CS.bvw({nW}n, dB_{f}, TB_{f}, OKA_pfB_{f}, OKA_hrB_{f}, {{==}}, {{==}})', psch=f'S.ByteVector{{A.quad({nW}n)}}'))
        else:
            ch = K.children[f]
            d = dict(kind='var', f=f, sch=sch, enc=ch.enc, sz=ch.sz, cur=curs[f])
            if ch.p == 'bl32' or getattr(ch, 'std', False):
                a = 'EB' if ch.p == 'bl32' else ch.alias
                m_ = f'm_{f}'
                d.update(val=f'{a}.VAL({m_})', prf=f'{a}.encx_spec({m_}, OKA_hok_{f})', szx=f'{a}.szx({m_}, OKA_hok_{f})', pfx=f'{a}.pfx({m_}, dd, @D, @Q, @R, @PF)')
            elif ch.p == 'l1048576_bl1073741824':
                t_, N_ = ch.oargs
                d.update(val=f'ET.VALL({t_}, {N_})', prf=f'ET.encx_spec({t_}, {N_}, OKA_h_{f}, k, CS.hk30(k, ek), @HLL)',
                         szx=f'Equal.trans(Nat, U32.to_nat(ET.SZW({t_}, {N_})), ET.LL({t_}, {N_}), LY.LN(ET.ENCL({t_}, {N_})), ET.szx({t_}, {N_}, OKA_h_{f}, 2n+k, CS.ek2(k, ek), @HLL), Equal.sym(Nat, LY.LN(ET.ENCL({t_}, {N_})), ET.LL({t_}, {N_}), ET.len_encl({t_}, {N_})))',
                         pfx=None, LL=f'ET.LL({t_}, {N_})', hY=f'ET.len_encl({t_}, {N_})')
            else:
                A_, N_ = ch.oargs
                a, p = ch.alias, ch.p
                d.update(val=f'{a}.VALL_{p}({A_}, {N_})', prf=f'{a}.encx_spec_{p}({A_}, {N_}, OKA_h_{f}, k, CS.hk30(k, ek), @HLL)',
                         szx=f'Equal.trans(Nat, U32.to_nat({ch.sz}), {a}.LL_{p}({A_}, {N_}), LY.LN({ch.enc}), {a}.szx_{p}({A_}, {N_}, 0n, 0n, k, CS.hk29(k, ek), VRX.nwn_le({a}.LL_{p}({A_}, {N_}), VB.pw(k), @HLL)), Equal.sym(Nat, LY.LN({ch.enc}), {a}.LL_{p}({A_}, {N_}), {a}.len_encl_{p}({A_}, {N_})))',
                         pfx=f'{a}.pfLb_{p}(U32.is_eq({N_}, 0), {A_}, {N_}, dd, @D, @Q, @R, @PF)', LL=f'{a}.LL_{p}({A_}, {N_})', hY=f'{a}.len_encl_{p}({A_}, {N_})')
            d['part'] = f'S.Variable{{{ch.enc}}}'
            d['bytes'] = ch.enc
            fields.append(d)
    n = len(fields)
    PS = '[' + ', '.join(x['part'] for x in fields) + ']'
    VV = [x for x in fields if x['kind'] == 'var']
    OS = '[' + ', '.join(x['cur'] for x in VV) + ']'
    # the running offsets o_j and the bound's chain
    os_ = [f'{FIX}n']
    for x in VV:
        os_.append(f'Nat.add({os_[-1]}, LY.LN({x["enc"]}))')
    END = os_[-1]
    SCH = f'Spec.{C}()'
    NAMESCH = f'S.{kind}{{{names_txt}, ' + ''.join(f'S.Chain{{{k}, ' for k in kids) + 'S.End{}' + '}' * len(kids)
    if kind == 'ProgressiveContainer':
        NAMESCH = None   # (not yet)

    def items(i):
        return 'S.EmptyItems{}' if i == n else f'S.Items{{{fields[i]["val"]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == n else f'S.Chain{{{kids[i]}, {chain(i + 1)}}}'

    # the OK conjuncts: the writer's hypotheses, then the bound
    CJ = [c for _, c in conj] + [f'Nat.is_le({END}, A.quad(VB.pw(28n)))']
    CN = [nm for nm, _ in conj] + ['bnd']

    def conjt(i):
        return CJ[i] if i == len(CJ) - 1 else f'Bool.and({CJ[i]}, {conjt(i + 1)})'
    acc = []
    for i in range(len(CJ) - 1):
        src_ = 'h' if i == 0 else f'okr{i}({OAS}, h)'
        acc.append(f'def okr{i + 1}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{conjt(i + 1)} == {TRUE_}}}: and_r({CJ[i]}, {conjt(i + 1)}, {src_})')
    for i in range(len(CJ)):
        src_ = 'h' if i == 0 else f'okr{i}({OAS}, h)'
        if i == len(CJ) - 1:
            acc.append(f'def ok_{CN[i]}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{CJ[i]} == {TRUE_}}}: {src_}')
        else:
            acc.append(f'def ok_{CN[i]}({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{CJ[i]} == {TRUE_}}}: and_l({CJ[i]}, {conjt(i + 1)}, {src_})')
    OKA = lambda s: re.sub(r'OKA_(\w+)', lambda mm: f'ok_{mm.group(1)}({OAS}, h)', s)
    HA2 = ', '.join(f'ok_{nm}({OAS}, h)' for nm, _ in conj)
    ENCCt = f'K.ENCC({OAS})'
    w(f'''
# ---- {C}: its value, parts, layout, and bytes ----

def OKT({OPS}) -> Bool: {conjt(0)}
{chr(10).join(acc)}

def VALC({OPS}) -> S.Value: S.Sequence{{{items(0)}}}
def PSC({OPS}) -> +List<S.Part>: {PS}
def OSC({OPS}) -> +List<U32>: {OS}
def ENDC({OPS}) -> Nat: {END}

# the bound with its exponent symbolic (k = 28)
def okbk({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{Nat.is_le(ENDC({OAS}), A.quad(VB.pw(k))) == {TRUE_}}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(ENDC({OAS}), A.quad(VB.pw(z))) == {TRUE_}}}, 28n, k, Equal.sym(Nat, k, 28n, ek), ok_bnd({OAS}, h))
''')
    # the bounds o_{j+1} <= 4 2^k, j = n_v .. 1
    Q = 'A.quad(VB.pw(k))'
    hb = {len(VV): f'okbk({OAS}, h, k, ek)'}
    for j in range(len(VV) - 1, 0, -1):
        hb[j] = f'CS.lel({os_[j]}, LY.LN({VV[j]["enc"]}), {Q}, {hb[j + 1]})'
    HLL = {j: f'CS.ler({os_[j]}, LY.LN({VV[j]["enc"]}), {Q}, {hb[j + 1]})' for j in range(len(VV))}
    # LL-form bound for ET / EW children: LL <= 4 2^k
    for j, x in enumerate(VV):
        if 'LL' in x:
            HLL[j] = f'FD.logic__subst(Nat, z => {{Nat.is_le(z, {Q}) == {TRUE_}}}, LY.LN({x["enc"]}), {x["LL"]}, {x["hY"]}, {HLL[j]})'
    for j, x in enumerate(VV):
        for key in ('prf', 'szx'):
            x[key] = x[key].replace('@HLL', HLL[j])
    # the offsets: to_nat(cur_j) == o_j
    eo = ['{==}']
    for j, x in enumerate(VV):
        eo.append(f'CS.pstep({x["cur"]}, {x["sz"]}, {os_[j]}, LY.LN({x["enc"]}), k, CS.hk29(k, ek), {eo[j]}, {x["szx"]}, {hb[j + 1]})')
    OKO = '(' + ', ('.join(eo[j] for j in range(len(VV))) + ', Unit{}' + ')' * len(VV) if VV else 'Unit{}'
    # the parts of the items
    def cat(i):
        if i == n:
            return '{==}'
        x = fields[i]
        rest = '[' + ', '.join(y['part'] for y in fields[i + 1:]) + ']'
        fn_ = 'FX.cat_fixed' if x['kind'] == 'fix' else 'VS.cat_var'
        return (f'{fn_}(Codec.parts({x["val"]}, {x["sch"]}), {x["bytes"]}, Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest},\n    {OKA(x["prf"])}, {cat(i + 1)})')
    # bytes_valid(PS): each part's bytes are bytes
    def bv(i):
        if i == n:
            return '{==}'
        x = fields[i]
        rest = '[' + ', '.join(y['part'] for y in fields[i + 1:]) + ']'
        dm = 'CS.domf' if x['kind'] == 'fix' else 'CS.domv'
        sch_ = x.get('psch', x['sch']) if x['kind'] == 'fix' else x['sch']
        return (f'FD.logic__and_intro(SP.bytes_domain({x["bytes"]}), Layout.bytes_valid({rest}), {dm}({x["val"]}, {sch_}, {x["bytes"]}, {{==}}, {OKA(x["prf"])}),\n    {bv(i + 1)})')
    # the variable pieces' cells are their bytes
    rw = []
    for j, x in enumerate(VV):
        k0 = len(fw) + j
        cells = [(f'_' if jj == j else (y['enc'] if jj < j else vw[jj])) for jj, y in enumerate(VV)]
        hY = x.get('hY', '{==}')
        ch = K.children[x['f']]
        rw.append(f'  %Equal.sym(+List<U32>, {vw[j]}, {x["enc"]}, VCN.pc_id({ch.len}, {x["enc"]}, {hY})) :\n    {{VCN.AP(VCN.CAT([{", ".join(fw)}]), VCN.CAT([{", ".join(cells)}])) == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}')
    if getattr(K, 'pz', None) is not None:
        SZCORE = SZC[1:SZC.index(' .|. O.pz(')]
        ESZ = f'K.szpz({OAS}, ok_hpz({OAS}, h))'
    else:
        SZCORE, ESZ = SZC, f'eSZ({OAS}, Unit{{}})'
    w(f'''
def partsC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}})
    -> {{Codec.parts({items(0)}, {chain(0)}) == Some{{PSC({OAS})}} : Maybe<&2, +List<S.Part>>}}:
  {cat(0)}

def validC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{Layout.bytes_valid(PSC({OAS})) == {TRUE_}}}:
  {bv(0)}

# the offsets the writer writes are the layout's
def okoC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> LY.OKO(PSC({OAS}), {FIX}n, OSC({OAS})):
  {OKO}

# the returned size is the bytes' end
def eSZ({OPS}, +u: Unit) -> {{K.SZC({OAS}) == {SZC} : U32}}: {{==}}
def szC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}}) -> {{U32.to_nat(K.SZC({OAS})) == ENDC({OAS}) : Nat}}:
  FD.logic__subst(U32, z => {{U32.to_nat(z) == ENDC({OAS}) : Nat}}, {SZCORE}, K.SZC({OAS}), Equal.sym(U32, K.SZC({OAS}), {SZCORE}, {ESZ}),
    {eo[-1]})

# the writer's bytes: the fixed region (the layout's header), then the payloads
def eENC({OPS}, +u: Unit) -> {{{ENCCt} == VCN.CAT([{", ".join(EP)}]) : +List<U32>}}: {{==}}
def eLLC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> {{K.LLC({OAS}, dd, D, X, q, r) == Nat.add({FIX}n, VCN.SUM([{", ".join(K.children[x["f"]].len for x in VV)}])) : Nat}}: {{==}}
def cellsC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{{ENCCt} == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}:
  %Equal.sym(+List<U32>, {ENCCt}, VCN.CAT([{", ".join(EP)}]), eENC({OAS}, Unit{{}})) :
    {{_ == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}
  %Equal.sym(+List<U32>, VCN.CAT([{", ".join(EP)}]), VCN.AP(VCN.CAT([{", ".join(fw)}]), VCN.CAT([{", ".join(vw)}])), VCN.cat_lap([{", ".join(fw)}], [{", ".join(vw)}])) :
    {{_ == VCN.AP(VCN.CAT([{", ".join(fw)}]), Layout.payloads(PSC({OAS}))) : +List<U32>}}
''' + '\n'.join(rw) + '\n  {==}\n' + f'''
def encE({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}})
    -> {{Layout.encoding(PSC({OAS})) == Some{{{ENCCt}}} : Maybe<&2, +List<U32>>}}:
  +FP = LY.HDRW(PSC({OAS}), OSC({OAS}))
  +PAY = Layout.payloads(PSC({OAS}))
  +hf = LY.hdr_fp(PSC({OAS}), {FIX}n, OSC({OAS}), okoC({OAS}, h, k, ek))
  +fit = CS.fitc({FIX}n, PAY, ENDC({OAS}), k, ek, LY.lay_end(PSC({OAS}), {FIX}n), okbk({OAS}, h, k, ek))
  +e1 = LY.enc_genL(PSC({OAS}), {FIX}n, FP, PAY, {{==}}, hf, {{==}}, validC({OAS}, h, k, ek), fit)
  FD.logic__subst(+List<U32>, z => {{Layout.encoding(PSC({OAS})) == Some{{z}} : Maybe<&2, +List<U32>>}}, VCN.AP(FP, PAY), {ENCCt},
    Equal.sym(+List<U32>, {ENCCt}, VCN.AP(FP, PAY), cellsC({OAS}, h)), e1)

# encx_spec, on the parameters
def specC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +k: Nat, +ek: {{k == 28n : Nat}})
    -> {{Codec.parts(VALC({OAS}), {SCH}) == Some{{[S.Variable{{{ENCCt}}}]}} : Maybe<&2, +List<S.Part>>}}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts({items(0)}, {chain(0)}), Some{{PSC({OAS})}}, partsC({OAS}, h, k, ek)) :
    {{Codec.aggregate(_, None{{}}) == Some{{[S.Variable{{{ENCCt}}}]}} : Maybe<&2, +List<S.Part>>}}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(PSC({OAS})), Some{{{ENCCt}}}, encE({OAS}, h, k, ek)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{{ENCCt}}}]}} : Maybe<&2, +List<S.Part>>}}
  {{==}}

# the writer's byte count
def lenC({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> {{List.length(&2, U32, {ENCCt}) == K.LLC({OAS}, dd, D, X, q, r) : Nat}}:
  +SL = Nat.add({FIX}n, VCN.SUM([{", ".join(K.children[x["f"]].len for x in VV)}]))
  +e1 = FD.logic__subst(+List<U32>, z => {{List.length(&2, U32, z) == SL : Nat}}, VCN.CAT([{", ".join(EP)}]), {ENCCt}, Equal.sym(+List<U32>, {ENCCt}, VCN.CAT([{", ".join(EP)}]), eENC({OAS}, Unit{{}})),
    VCN.eposv([{", ".join(fw)}], [{", ".join(x["enc"] for x in VV)}], [{", ".join(K.children[x["f"]].len for x in VV)}]))
  Equal.trans(Nat, List.length(&2, U32, {ENCCt}), SL, K.LLC({OAS}, dd, D, X, q, r), e1, Equal.sym(Nat, K.LLC({OAS}, dd, D, X, q, r), SL, eLLC({OAS}, dd, D, X, q, r)))
def lenE({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{List.length(&2, U32, {ENCCt}) == ENDC({OAS}) : Nat}}:
  +PAY = Layout.payloads(PSC({OAS}))
  +FP = LY.HDRW(PSC({OAS}), OSC({OAS}))
  +e1 = Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), {ENCCt}, VCN.AP(VCN.CAT([{", ".join(fw)}]), PAY), cellsC({OAS}, h))
  +e2 = VS.len_app(VCN.CAT([{", ".join(fw)}]), PAY)
  +e3 = Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, PAY)), List.length(&2, U32, FP), {FIX}n,
    Equal.trans(Nat, List.length(&2, U32, FP), List.length(&2, U32, Layout.fixed_parts(PSC({OAS}), {FIX}n)), {FIX}n,
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), FP, Layout.fixed_parts(PSC({OAS}), {FIX}n), Equal.sym(+List<U32>, Layout.fixed_parts(PSC({OAS}), {FIX}n), FP, LY.hdr_fp(PSC({OAS}), {FIX}n, OSC({OAS}), okoC({OAS}, h, 28n, {{==}})))),
      LY.lay_len(PSC({OAS}), {FIX}n)))
  Equal.trans(Nat, List.length(&2, U32, {ENCCt}), Nat.add({FIX}n, List.length(&2, U32, PAY)), ENDC({OAS}),
    Equal.trans(Nat, List.length(&2, U32, {ENCCt}), Nat.add(List.length(&2, U32, FP), List.length(&2, U32, PAY)), Nat.add({FIX}n, List.length(&2, U32, PAY)),
      Equal.trans(Nat, List.length(&2, U32, {ENCCt}), List.length(&2, U32, VCN.AP(FP, PAY)), Nat.add(List.length(&2, U32, FP), List.length(&2, U32, PAY)), e1, e2), e3),
    LY.lay_end(PSC({OAS}), {FIX}n))
''')
    # ---- the interface ----
    MWF = ', '.join(x.lstrip('+') for x in OP)
    MP = 'MW{' + ', '.join('+' + a for a in OA) + '}'
    MA = f'{OAS}, dd, D, XQ(q, r), q, r'
    ifc = f'''
# ==== {C} in the encoder-window interface ====

type MW is Data:
  MW{{{MWF}}}

def TH(m: MW) -> T.{C}:
  match m:
    case {MP}: K.OBJC({OAS})
def OK(m: MW) -> Bool:
  match m:
    case {MP}: OKT({OAS})
def ENC(m: MW) -> +List<U32>:
  match m:
    case {MP}: {ENCCt}
def VAL(m: MW) -> S.Value:
  match m:
    case {MP}: VALC({OAS})
def SZ(m: MW) -> U32:
  match m:
    case {MP}: K.SZC({OAS})
def XQ(+q: Nat, +r: Nat) -> U32: U32.from_nat(Nat.add(A.quad(q), r))
def PUTX(m: MW, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> {TR}:
  match m:
    case {MP}: K.PUTC({MA})
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, List.length(&2, U32, ENC(m)))

def RTX({OPS}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat) -> Data:
  {{T.{K.p}_putk(FD.array__thaw(U32, D), X, K.OBJC({OAS})) == (FD.array__thaw(U32, K.PUTC({MA})), (K.OBJC({OAS}), K.SZC({OAS}))) : Array<U32> & (T.{C} & U32)}}
def BYX({OPS}, +dd: Nat, +D: {TR}, +q: Nat, +r: Nat) -> Data:
  {{UA.BYT(K.PUTC({MA})) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VCN.AP({ENCCt}, UW.ZB(WD.PADB(r, List.length(&2, U32, {ENCCt}))))) : +List<U32>}}

def go({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat,
    +e: {{U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}}, +hr: {{Nat.is_lt(r, 4n) == {TRUE_}}}, +hd: {{Nat.is_lt(dd, 29n) == {TRUE_}}}, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE_}}},
    +hl: {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, {ENCCt})))), VB.pw(dd)) == {TRUE_}}},
    +hz: {{VS.bt(Nat.add(List.length(&2, U32, {ENCCt}), WD.PADB(r, List.length(&2, U32, {ENCCt}))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, {ENCCt}), WD.PADB(r, List.length(&2, U32, {ENCCt})))) : +List<U32>}})
    -> DK.P2(RTX({OAS}, dd, D, X, q, r), BYX({OAS}, dd, D, q, r)):
  +LLv = K.LLC({OAS}, dd, D, XQ(q, r), q, r)
  +el = lenC({OAS}, dd, D, XQ(q, r), q, r)
  +hl2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == {TRUE_}}}, List.length(&2, U32, {ENCCt}), LLv, el, hl)
  +hz2 = FD.logic__subst(Nat, z => {{VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}}, List.length(&2, U32, {ENCCt}), LLv, el, hz)
  +ex = CS.exq(X, q, r, LLv, dd, e, hd, hl2)
  +e2 = FD.logic__subst(U32, z => {{U32.to_nat(z) == Nat.add(A.quad(q), r) : Nat}}, X, XQ(q, r), ex, e)
  +g = K.putx({OAS}, {HA2}, dd, D, XQ(q, r), q, r, e2, hr, hd, hl2, pf, hz2)
  +rt = K.putk_bridge({MA}, PA(K.RTC({MA}), DK.P2(K.BYC({MA}), DK.P2(K.PFC({MA}), K.SZXC({MA}))), g))
  +g2 = PB(K.RTC({MA}), DK.P2(K.BYC({MA}), DK.P2(K.PFC({MA}), K.SZXC({MA}))), g)
  +by = PA(K.BYC({MA}), DK.P2(K.PFC({MA}), K.SZXC({MA})), g2)
  +rt2 = FD.logic__subst(U32, z => {{T.{K.p}_putk(FD.array__thaw(U32, D), z, K.OBJC({OAS})) == (FD.array__thaw(U32, K.PUTC({MA})), (K.OBJC({OAS}), K.SZC({OAS}))) : Array<U32> & (T.{C} & U32)}},
    XQ(q, r), X, Equal.sym(U32, X, XQ(q, r), ex), rt)
  +by2 = FD.logic__subst(Nat, z => {{UA.BYT(K.PUTC({MA})) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VCN.AP({ENCCt}, UW.ZB(WD.PADB(r, z)))) : +List<U32>}},
    LLv, List.length(&2, U32, {ENCCt}), Equal.sym(Nat, List.length(&2, U32, {ENCCt}), LLv, el), by)
  (rt2, by2)
'''
    HYPS = '''  for +m: MW
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
'''.replace('@TR', TR)
    ifc += f'''
# ---- the interface's laws ----------------------------------------------------------------------

law putx:
{HYPS}  {{T.{K.p}_putk(FD.array__thaw(U32, D), X, TH(m)) == (FD.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : Array<U32> & (T.{C} & U32)}}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case {MP}: PA(RTX({OAS}, dd, D, X, q, r), BYX({OAS}, dd, D, q, r), go({OAS}, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law putx_bytes:
{HYPS}  {{UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case {MP}: PB(RTX({OAS}, dd, D, X, q, r), BYX({OAS}, dd, D, q, r), go({OAS}, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law szx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}}
def szx(m, hok):
  match m:
    case {MP}: Equal.trans(Nat, U32.to_nat(K.SZC({OAS})), ENDC({OAS}), List.length(&2, U32, {ENCCt}), szC({OAS}, hok, 28n, {{==}}), Equal.sym(Nat, List.length(&2, U32, {ENCCt}), ENDC({OAS}), lenE({OAS}, hok)))

law encx_spec:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{Codec.parts(VAL(m), {SCH}) == Some{{[S.Variable{{ENC(m)}}]}} : Maybe<&2, +List<S.Part>>}}
def encx_spec(m, hok):
  match m:
    case {MP}: specC({OAS}, hok, 28n, {{==}})

law domx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{SP.bytes_domain(ENC(m)) == True{{}} : Bool}}
def domx(m, hok):
  match m:
    case {MP}: CS.domv(VALC({OAS}), {SCH}, {ENCCt}, {{==}}, specC({OAS}, hok, 28n, {{==}}))
'''
    # ---- pfx: the writer's tree is perfect, write by write (when every child's is) ----
    MAk = f'{OAS}, dd, D, XQ(q, r), q, r'
    Mk = lambda k: f'K.M{k}({MAk})'
    pfs, okpf = 'pf', True
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf' and leaf_of(fs).sub:
            pfs = f'{leaf_of(fs).pf}(dd, {Mk(k)}, XQ(q, r), {ev["hoff"]}, {f}, {pfs})'
        elif ev['kind'] == 'off' and ev['hoff'] % 4:
            Xc_ = f'U32.add(XQ(q, r), {ev["hoff"]})'
            pfs = f'WD.w32x_perfect(VCN.RX({Xc_}), dd, {Mk(k)}, VCN.QX({Xc_}), {ev["cur"]}, {pfs})'
        elif ev['kind'] == 'leaf':
            pfs = f'K.pfo_{leaf_of(fs).p}({f}, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), r, {pfs})'
        elif ev['kind'] == 'fixw':
            pfs = K.fixw[f].pf('r', Mk(k), f'Nat.add({ev["hoff"] // 4}n, q)', pfs)
        elif ev['kind'] == 'off':
            pfs = f'WD.w32x_perfect(r, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), {ev["cur"]}, {pfs})'
        else:
            x = [y for y in fields if y['f'] == f][0]
            if not x.get('pfx'):
                okpf = False
                break
            Xc = f'U32.add(XQ(q, r), {ev["cur"]})'
            pfs = x['pfx'].replace('@D', Mk(k)).replace('@Q', f'VCN.QX({Xc})').replace('@R', f'VCN.RX({Xc})').replace('@PF', pfs)
    # ---- sizex: the runtime's size pass, child by child (narrow containers whose children state it) ----
    szx_ok = not K.wide
    RTS = ''
    if szx_ok:
        def rq(t):
            return re.sub(r'(?<![\w.])(?!(?:True|False|Some|None|Con|Nil)\b)([A-Za-z_]\w*)(?=[({])', r'T.\1', t)
        cs = {}
        for x in VV:
            ch = K.children[x['f']]
            if ch.p == 'bl32' or getattr(ch, 'std', False):
                a = 'EB' if ch.p == 'bl32' else ch.alias
                cs[ch.p] = (f'{a}.sizex(m_{x["f"]}, @HOK)', ch.vt, ch.obj, ch.sz, f'ok_hok_{x["f"]}', f'{a}.validx(m_{x["f"]}, @HOK)')
            elif ch.p == 'l1048576_bl1073741824':
                szx_ok = False
            else:
                A_, N_ = ch.oargs
                cs[ch.p] = (f'{ch.alias}.sizex_{ch.p}({A_}, {N_}, @HOK)', ch.vt, ch.obj, ch.sz, f'ok_h_{x["f"]}', f'{ch.alias}.valid_{ch.p}({A_}, {N_}, @HOK)')
    def chain_rt(entry, lawname, result_t, final_rhs, pair_second):
        """The runtime's pass `entry` (size / valid) over the children, each child's call rewritten by its law."""
        body_ = fn_body(f'{K.p}_{entry}')
        mm = re.search(r'case (\w+)\{([^}]*)\}: (.*)$', body_, re.M)
        pv = [v.strip().lstrip('+') for v in mm.group(2).split(',')]
        sub = dict(zip(pv, [OBJF[f] for f, _ in F]))

        def subst(t, d):
            return re.sub(r'(?<![\w.])([A-Za-z_]\w*)\b(?![({])', lambda z: d.get(z.group(1), z.group(1)), t)
        cur = rq(subst(mm.group(3).strip(), sub))
        steps = []
        if entry == 'valid' and getattr(K, 'pz', None) is not None and K.pz in cur:
            steps.append(f'  %Equal.sym(Bool, {K.pz}, True{{}}, ok_hpz({OAS}, h)) :\n    {{{cur.replace(K.pz, "_", 1)} == {final_rhs} : {result_t}}}')
            cur = cur.replace(K.pz, 'True{}', 1)
        while True:
            m2 = re.fullmatch(r'T\.(\w+_(?:sz|va)\d+)\((.*)\)', cur)
            if not m2:
                break
            fname, args = m2.group(1), [a.strip() for a in __import__('var_winb').split_top(m2.group(2))]
            last = args[-1]
            m3 = re.fullmatch(rf'T\.(\w+)_{entry}\((.*)\)', last)
            if not m3 or m3.group(1) not in cs:
                return None
            cp, V = m3.group(1), m3.group(2)
            vt, SZj, hokn = cs[cp][1], cs[cp][3], cs[cp][4]
            prf = cs[cp][0] if entry == 'size' else cs[cp][5]
            second = SZj if entry == 'size' else 'True{}'
            ctx = f'T.{fname}(' + ', '.join(args[:-1] + ['_']) + ')'
            steps.append(f'  %Equal.sym({vt} & {pair_second}, {last}, ({V}, {second}), {prf.replace("@HOK", f"{hokn}({OAS}, h)")}) :\n    {{{ctx} == {final_rhs} : {result_t}}}')
            fb = fn_body(fname)
            params = fn_params(fname)
            d = dict(zip(params, args[:-1] + [None]))
            m4 = re.search(r'\((\+?\w+), \+?(\w+)\) = pair\n\s*(.*)$', fb, re.S)
            d[m4.group(1).lstrip('+')] = V
            d[m4.group(2)] = second
            nxt = m4.group(3).strip().split('\n')[0].strip()
            cur = rq(subst(nxt, {k_: v_ for k_, v_ in d.items() if v_ is not None}))
        return '\n'.join(steps) + '\n  {==}'
    RTV = None
    if szx_ok:
        RTV = chain_rt('valid', 'validx', f'T.{C} & Bool', f'(K.OBJC({OAS}), True{{}})', 'Bool')
    if szx_ok:
        body_ = fn_body(f'{K.p}_size')
        mm = re.search(r'case (\w+)\{([^}]*)\}: (.*)$', body_, re.M)
        pv = [v.strip().lstrip('+') for v in mm.group(2).split(',')]
        sub = dict(zip(pv, [OBJF[f] for f, _ in F]))

        def subst(t, d):
            return re.sub(r'(?<![\w.])([A-Za-z_]\w*)\b(?![({])', lambda z: d.get(z.group(1), z.group(1)), t)
        cur = rq(subst(mm.group(3).strip(), sub))
        steps = []
        if getattr(K, 'pz', None) is not None:
            core_ = SZC[1:SZC.index(' .|. O.pz(')]
            steps.append(f'  %Equal.sym(U32, K.SZC({OAS}), {core_}, K.szpz({OAS}, ok_hpz({OAS}, h))) :\n    {{T.{K.p}_size(K.OBJC({OAS})) == (K.OBJC({OAS}), _) : T.{C} & U32}}')
        while True:
            m2 = re.fullmatch(r'T\.(\w+_sz\d+)\((.*)\)', cur)
            if not m2:
                break
            fname, args = m2.group(1), [a.strip() for a in __import__('var_winb').split_top(m2.group(2))]
            last = args[-1]
            m3 = re.fullmatch(r'T\.(\w+)_size\((.*)\)', last)
            cp, V = m3.group(1), m3.group(2)
            if cp not in cs:
                szx_ok = False
                break
            sz_prf, vt, _, SZj, hokn, _v = cs[cp]
            ctx = f'T.{fname}(' + ', '.join(args[:-1] + ['_']) + ')'
            SZR = SZC[1:SZC.index(' .|. O.pz(')] if getattr(K, 'pz', None) is not None else f'K.SZC({OAS})'
            steps.append(f'  %Equal.sym({vt} & U32, {last}, ({V}, {SZj}), {sz_prf.replace("@HOK", f"{hokn}({OAS}, h)")}) :\n    {{{ctx} == (K.OBJC({OAS}), {SZR}) : T.{C} & U32}}')
            fb = fn_body(fname)
            params = fn_params(fname)
            d = dict(zip(params, args[:-1] + [None]))
            m4 = re.search(r'\((\+?\w+), \+?(\w+)\) = pair\n\s*(.*)$', fb, re.S)
            d[m4.group(1).lstrip('+')] = V
            d[m4.group(2)] = SZj
            nxt = m4.group(3).strip().split('\n')[0].strip()
            cur = rq(subst(nxt, {k_: v_ for k_, v_ in d.items() if v_ is not None}))
        if szx_ok:
            RTS = '\n'.join(steps) + '\n  {==}'
    body = '\n'.join(L2)
    body = OKA(body)
    okpf = True
    pfs = f'K.pfC({OAS}, dd, D, XQ(q, r), q, r, pf)'
    if okpf:
        ifc += f'''
law pfx:
  for +m: MW
  for +dd: Nat
  for +D: {TR}
  for +q: Nat
  for +r: Nat
  for +pf: {{FD.array__perfect(U32, dd, D) == True{{}} : Bool}}
  {{FD.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{{}} : Bool}}
def pfx(m, dd, D, q, r, pf):
  match m:
    case {MP}: {pfs}
'''
    if szx_ok:
        ifc += f'''
def sizeC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{T.{K.p}_size(K.OBJC({OAS})) == (K.OBJC({OAS}), K.SZC({OAS})) : T.{C} & U32}}:
{RTS}

law sizex:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{T.{K.p}_size(TH(m)) == (TH(m), SZ(m)) : T.{C} & U32}}
def sizex(m, hok):
  match m:
    case {MP}: sizeC({OAS}, hok)
'''.replace('@H', 'h')
    if RTV is not None:
        ifc += f'''
def rvalidC({OPS}, +h: {{OKT({OAS}) == {TRUE_}}}) -> {{T.{K.p}_valid(K.OBJC({OAS})) == (K.OBJC({OAS}), True{{}}) : T.{C} & Bool}}:
{RTV}

law validx:
  for +m: MW
  for +hok: {{OK(m) == True{{}} : Bool}}
  {{T.{K.p}_valid(TH(m)) == (TH(m), True{{}}) : T.{C} & Bool}}
def validx(m, hok):
  match m:
    case {MP}: rvalidC({OAS}, hok)
'''
    return body + ifc


IHEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
         'import ../../types/schema.bend as S', 'import ../../types/primitive.bend as P', 'import ../../spec/codec.bend as Codec',
         'import ../../spec/layout.bend as Layout', 'import ../../spec/primitives.bend as SP', 'import ../../spec/fulu_schemas.bend as Spec',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
         'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
         'import ./vuwd.bend as WD', 'import ./vcopy.bend as VC', 'import ./vrecx.bend as VRX', 'import ./vcont.bend as VCN', 'import ./vua_lay.bend as LY',
         'import ./vconts.bend as CS', 'import ./spec_bits.bend as FB', 'import ./dk.bend as DK']


def iface_file(C):
    return ROOT / f'proofs/obj/big_encx_{C}_iface.bend'


def iface_full(C, generic=False):
    body = iface_text(C, generic)
    main = (out_file(C) if not generic else gfile_c(C)).name
    heads = full_text(C, generic).split('\n')
    mods = [l for l in heads if l.startswith('import ./') and (' as E' in l or ' as V_' in l or l.endswith(' as VPC'))]
    hd = IHEAD
    if generic:
        hd = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec') for x in hd]
    if 'VRB.' in body:
        mods.append('import ./vrecb.bend as VRB')
    head = hd + mods + [f'import ./{main} as K', '', '# GENERATED by codegen/var_cont_enc.py. Do not edit.',
                        f'# {C} in the encoder-window interface, with its spec side (see the generator: iface_text).', '',
                        'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                        'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b',
                        'def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}: FD.logic__and_left(a, b, h)',
                        'def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}: FD.logic__and_right(a, b, h)']
    return '\n'.join(head) + '\n' + body


HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../src/primitives.bend as I', 'import ../../types/fulu_obj.bend as T',
        'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ../../proofs/nat_order.bend as Order',
        'import ./spec_fixed.bend as FX', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
        'import ./vuwd.bend as WD', 'import ./vcopy.bend as VC', 'import ./vrecx.bend as VRX', 'import ./vcont.bend as VCN', 'import ./vmr.bend as VMR', 'import ./dk.bend as DK']


# The generic containers (types/generic_obj.bend, proofs/obj/generic_specs.bend) written by this generator:
# every child in the encoder-window interface, every fixed piece word-aligned (so far).
GCONTS = ['Gp4B0CA2906A', 'Gc465214E502', 'Gp66304057C3', 'Gp8A7851175B', 'Gc221EC01D83']
# the containers written in the encoder-window interface with their spec side (iface_text): (name, generic)
ICONTS = [('Gp4B0CA2906A', True), ('ExecutionPayload', False), ('ExecutionPayloadHeader', False), ('Gc465214E502', True), ('Gp66304057C3', True),
          ('Gp8A7851175B', True), ('Gc221EC01D83', True), ('ExecutionRequests', False), ('Attestation', False)]


def gfile_c(C):
    return ROOT / f'proofs/obj/big_encx_{C}.bend'


def full_text(C, generic=False):
    global SRC, SRC_FILE
    if generic:
        import generic as GN
        names = {n: t for n, t, err in GN.inventory_all() if err is None}
        g = G.Gen()
        if SRC_FILE != 'types/generic_obj.bend':
            SRC, SRC_FILE = None, 'types/generic_obj.bend'
    else:
        g, names = G.Gen(), schema.load(ROOT / 'codegen/fulu.yaml')
        if SRC_FILE != 'types/fulu_obj.bend':
            SRC, SRC_FILE = None, 'types/fulu_obj.bend'
    for n, t in names.items():
        g.shape(t)
    L, K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJ, OBJF, OP, OA, HP, HA, SZC = module_text(g, names, C)
    L += putx_text(K, events, pieces, fidx, vidx, var, ks_all, PT, FS, OBJF, OP, OA, HP, HA, SZC)
    mods = []
    for lf in K.leaves.values():
        if lf.mod and lf.mod not in mods:
            mods.append(lf.mod)
    for f, fw in K.fixw.items():
        if fw.mod not in mods:
            mods.append(fw.mod)
    for ch in K.children.values():
        if ch.mod not in mods:
            mods.append(ch.mod)
    if any(ev['kind'] == 'off' and ev['hoff'] % 4 for ev in events) and 'import ./vpiece.bend as VPC' not in mods:
        mods.append('import ./vpiece.bend as VPC')
    if getattr(K, 'pz', None) is not None:
        mods.append('import ./vuw_bits.bend as UWB')
    hd = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T') for x in HEAD] if generic else HEAD
    head = hd + mods + ['', '# GENERATED by codegen/var_cont_enc.py. Do not edit.',
                          f'# {C} in the encoder-window interface: written at any byte position X = 4 q + r (see the generator).', '',
                          'def PA(-A: Data, -B: Data, +p: DK.P2(A, B)) -> A:', '  (+a, +b) = p', '  a',
                          'def PB(-A: Data, -B: Data, +p: DK.P2(A, B)) -> B:', '  (+a, +b) = p', '  b']
    OPS_, OAS_ = ', '.join(OP), ', '.join(OA)
    MA_ = f'{OAS_}, dd, D, X, q, r'
    L.append(f'''
# The container's checked writer T.{K.p}_putk is its putn (one definitional step): the writer's fact
# as a parent's putv states it.
def putk_bridge({OPS_}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +h: RTC({MA_}))
    -> {{T.{K.p}_putk(FD.array__thaw(U32, D), X, OBJC({OAS_})) == (FD.array__thaw(U32, PUTC({MA_})), (OBJC({OAS_}), SZC({OAS_}))) : Array<U32> & (T.{C} & U32)}}:
  h''')
    L.append(pfc_text(K, events, OP, OA, C))
    return '\n'.join(head) + '\n' + '\n'.join(L) + '\n'


def pfc_text(K, events, OP, OA, C):
    """pfC: the writer's tree is perfect, with no hypothesis (the writes' perfect lemmas in order)."""
    OPS_, OAS_ = ', '.join(OP), ', '.join(OA)
    MA_ = f'{OAS_}, dd, D, X, q, r'
    fsd = dict(K.F)
    Mk = lambda k: f'M{k}({MA_})'
    pfs = 'pf'
    pre = ''
    for k, ev in enumerate(events):
        f = ev['field']
        fs = fsd[f]
        if ev['kind'] == 'leaf' and leaf_of(fs).sub:
            pfs = f'{leaf_of(fs).pf}(dd, {Mk(k)}, X, {ev["hoff"]}, {f}, {pfs})'
        elif ev['kind'] == 'off' and ev['hoff'] % 4:
            Xc_ = f'U32.add(X, {ev["hoff"]})'
            pfs = f'WD.w32x_perfect(VCN.RX({Xc_}), dd, {Mk(k)}, VCN.QX({Xc_}), {ev["cur"]}, {pfs})'
        elif ev['kind'] == 'leaf':
            pfs = f'pfo_{leaf_of(fs).p}({f}, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), r, {pfs})'
        elif ev['kind'] == 'fixw':
            pfs = f'V_{fs.p}.{fs.p}x_perfect(r, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), TB_{f}, {pfs})'
        elif ev['kind'] == 'off':
            pfs = f'WD.w32x_perfect(r, dd, {Mk(k)}, Nat.add({ev["hoff"] // 4}n, q), {ev["cur"]}, {pfs})'
        else:
            ch = K.children[f]
            Xc = f'U32.add(X, {ev["cur"]})'
            QX, RX = f'VCN.QX({Xc})', f'VCN.RX({Xc})'
            if ch.p == 'bl32' or getattr(ch, 'std', False):
                a = 'EB' if ch.p == 'bl32' else ch.alias
                pfs = f'{a}.pfx(m_{f}, dd, {Mk(k)}, {QX}, {RX}, {pfs})'
            elif ch.p == 'l1048576_bl1073741824':
                t_, N_ = ch.oargs
                pfs = f'etpflb(U32.is_eq({N_}, 0), {t_}, {N_}, dd, {Mk(k)}, {Xc}, {QX}, {RX}, {pfs})'
                P = ch.p
                pre = f'''
# the transactions list's writer: its tree is perfect
law etwlm:
  for +k: Nat
  for +W: List<&2, ET.MB<ET.WMr>>
  for +s: Nat
  for +cur: U32
  for +dd: Nat
  for +D: {TR}
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}}
  {{FD.array__perfect(U32, dd, ET.WLM(k, W, s, cur, dd, D, X, q, r)) == {TRUE}}}
def etwlm(k, W, s, cur, dd, D, X, q, r, pf):
  match k:
    case 0n: pf
    case 1n+ +j:
      etwlm(j, W, 1n+s, O.padd(cur, ET.NE(ET.xat_{P}(W, s))), dd, ET.PWE(ET.xat_{P}(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), ET.QX(U32.add(X, cur)), ET.RX(U32.add(X, cur))), X, q, r,
        ET.pwe_perfect(ET.xat_{P}(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), ET.QX(U32.add(X, cur)), ET.RX(U32.add(X, cur)), WD.w32x_perfect(r, dd, D, Nat.add(s, q), cur, pf)))
def etpflb(+b: Bool, +t: FD.array__Tree<ET.MB<ET.WMr>>, +N: U32, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}})
    -> {{FD.array__perfect(U32, dd, ET.PUTLb(b, t, N, dd, D, X, q, r)) == {TRUE}}}:
  match b:
    case True{{}}: pf
    case False{{}}: etwlm(U32.to_nat(N), ET.SL(t), 0n, U32.mul(4, N), dd, D, X, q, r, pf)
'''
            else:
                A_, N_ = ch.oargs
                pfs = f'{ch.alias}.pfLb_{ch.p}(U32.is_eq({N_}, 0), {A_}, {N_}, dd, {Mk(k)}, {QX}, {RX}, {pfs})'
    return pre + f'''
# pfC: the writer's tree is perfect (no hypothesis).
def pfC({OPS_}, +dd: Nat, +D: {TR}, +X: U32, +q: Nat, +r: Nat, +pf: {{FD.array__perfect(U32, dd, D) == {TRUE}}}) -> PFC({MA_}):
  {pfs}'''


def main():
    out = {}
    if '--no-big' not in sys.argv:
        for C in CONTS:
            out[out_file(C)] = full_text(C)
        for C in GCONTS:
            out[gfile_c(C)] = full_text(C, generic=True)
        for C, gen in ICONTS:
            out[iface_file(C)] = iface_full(C, gen)
    if '--check' in sys.argv:
        stale = [str(q.relative_to(ROOT)) for q, t in out.items() if not q.exists() or q.read_text() != t]
        if stale:
            print('stale generated container encoder windows: ' + ', '.join(stale))
            sys.exit(1)
        print('generated container encoder windows are current')
        return
    for q, t in out.items():
        q.write_text(t)
    print(', '.join(str(q.relative_to(ROOT)) for q in out))


if __name__ == '__main__':
    main()
