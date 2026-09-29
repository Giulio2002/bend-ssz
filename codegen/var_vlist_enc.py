#!/usr/bin/env python3
"""The encoders of the lists of variable-size elements at any byte position of an output tree:
the list of transactions (List[ByteList[2^30], 2^20], codegen/var_vlist.py's list, writer side),
and (GLISTS, glist_text) the generic progressive lists and vectors of such elements, parametric in
the element's encoder window (see GLISTS).

    python3 codegen/var_vlist_enc.py [--check] [--no-big]

proofs/obj/big_encx_l1048576_bl1073741824.bend (BIG: the 2^30 element limit is compared
as the window modules do). The list object is Seq{am(t), N} for a Data mirror tree t of
its boxed elements (the mirrors of proofs/obj/root_types.bend, copied here by name from
that generated file so this module does not import it: WMr, MB, th/fz, am, amswap,
amset, amswap_back, xat); every element i < N is MSome{WMr{T_i, N_i}} with T_i a perfect
tree of depth < 28 holding its N_i bytes and zero past them (EOK). The runtime's validity
loop va is evaluated by induction on its counter (va_go).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def _unlit(text):
    """a module's text as before any light split (codegen/light_split.py: unlight), for parsing"""
    import light_split
    t = light_split.unlight(text)
    return t.rstrip('\n') + '\n\n'

OUT = ROOT / 'proofs/obj/big_encx_l1048576_bl1073741824.bend'
RT = ROOT / 'proofs/obj/root_types.bend'
P = 'l1048576_bl1073741824'
E = 'bl1073741824'
LIM = '1073741824'
LIML = '1048576'

COPY = ['WMr', 'th_w', 'fz_w', 'fzth_w', 'MB', f'th_{E}_bx', f'fz_{E}_bx', f'fzth_{E}_bx', f'am_{P}', f'amsize_{P}',
        f'amswap_go_{P}', f'amswap_{P}', f'amset_{P}', f'amswap_back_{P}', f'xat_{P}', f'nth_{P}']


def blocks(text):
    """{name: text} of the top-level def / law / type blocks."""
    out, cur, name = {}, [], None
    for l in text.split('\n'):
        m = re.match(r'(?:def|law|type) (\w+)', l)
        if m or (l and not l[0].isspace() and not l.startswith('#')):
            if name:
                out.setdefault(name, []).extend(cur)
            name, cur = (m.group(1) if m else None), [l]
        else:
            cur.append(l)
    if name:
        out.setdefault(name, []).extend(cur)
    return {k: '\n'.join(v).rstrip('\n') for k, v in out.items()}


HEAD = ['import Base', 'import ../compact/found.bend as F', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S', 'import ../compact/arith.bend as A',
        'import ../compact/reads.bend as RD', 'import ../../proofs/nat_order.bend as Order', 'import ./amap.bend as AM',
        'import ./mtree_defs.bend as MD', 'import ./vspec.bend as VS', 'import ./vbuf.bend as VB', 'import ./vu32.bend as VU',
        'import ./vcopy.bend as VC', 'import ./vdepth.bend as VD', 'import ./vbytes.bend as VY', 'import ./vlist.bend as VL',
        'import ./venc.bend as VE', 'import ./vbenc.bend as VBE', 'import ./spec_fixed.bend as FX',
        'import ./vbrt.bend as VBR', 'import ./vua.bend as UA', 'import ./vuw.bend as UW',
        'import ./vvle.bend as VE2', 'import ./vvl.bend as VVL', 'import ./vrej.bend as VR', 'import ../../src/primitives.bend as I', 'import ./vdig.bend as VG',
        'import ./dk.bend as DK', 'import ./vfix.bend as VF', 'import ./big_vvlu.bend as VVU', 'import ./vbspec.bend as VZ', 'import ../../spec/nat_bytes.bend as N', 'import ./vuwd.bend as WD', 'import ./vbsize.bend as VBZ', 'import ./vfits.bend as VFT', 'import ../../spec/codec.bend as Codec',
        'import ../../spec/layout.bend as Layout', 'import ../../spec/fulu_schemas.bend as Spec', 'import ../../spec/primitives.bend as SP', 'import ../../proofs/nat_bytes.bend as Digits']

TEMPLATE = ROOT / 'codegen/vvle_list.bend.in'


# ==== generic / progressive / Vector lists of variable-size elements, parametric in the element's encoder window ====
# The template above with its element part (the list of transactions' byte-list elements) replaced by
# an element module EM in the encoder-window interface of codegen/var_plist_sub.py's ENCX (mirror type
# EM.<mirror>, TH, OK, ENC, VAL, SZ, PUTX(m, dd, D, q, r), PADB, putx, putx_bytes, pfx, szx, sizex,
# encx_spec) that also exports validx(m, hok): {T.<E>_valid(TH(m)) == (TH(m), True{})} and
# domx(m, hok): {SP.bytes_domain(ENC(m)) == True{}}. The boxed elements' mirrors are MB<EM.mirror>;
# the array lemmas (am, amswap, ...) are copied from the source file's list of the same element kind
# (root_gtypes2.bend), renamed. Modes: 'list' (List[E, LIML]), 'prog' (ProgressiveList[E]), 'vec'
# (Vector[E, n]). Each module ends with the list itself in the same interface (MW{t, N}), so a list
# can be the element of another (pl_pl_Gc465214E502).

# (list prefix, element runtime prefix, mode, count (limit / vector length / None), element encx module,
#  element schema, source file, source list prefix, source element prefix)
GLISTS = [
    ('pl_Gc465214E502', 'Gc465214E502', 'prog', None, 'big_encx_Gc465214E502_iface.bend', 'Spec.Gc465214E502()',
     'root_gtypes2.bend', 'pl_Gc465214E502', 'Gc465214E502'),
    ('pl_Gp66304057C3', 'Gp66304057C3', 'prog', None, 'big_encx_Gp66304057C3_iface.bend', 'Spec.Gp66304057C3()',
     'root_gtypes2.bend', 'pl_Gp66304057C3', 'Gp66304057C3'),
    ('v2_Gc465214E502', 'Gc465214E502', 'vec', 2, 'big_encx_Gc465214E502_iface.bend', 'Spec.Gc465214E502()',
     'root_gtypes2.bend', 'pl_Gc465214E502', 'Gc465214E502'),
    ('pl_pl_Gc465214E502', 'pl_Gc465214E502', 'prog', None, 'big_encx_pl_Gc465214E502.bend', 'S.ProgressiveList{Spec.Gc465214E502()}',
     'root_gtypes2.bend', 'pl_pl_Gc465214E502', 'pl_Gc465214E502'),
    # Fulu (types/fulu_obj.bend): BeaconBlockBody's lists of containers, mirrors from root_types.bend
    ('l1_AttesterSlashing', 'AttesterSlashing', 'list', 1, 'big_encx_AttesterSlashing_iface.bend', 'Spec.Schema47()',
     'root_types.bend', 'l1_AttesterSlashing', 'AttesterSlashing', 'Spec.Schema98()', True),
    ('l8_Attestation', 'Attestation', 'list', 8, 'big_encx_Attestation_iface.bend', 'Spec.Schema40()',
     'root_types.bend', 'l8_Attestation', 'Attestation', 'Spec.Schema99()', True),
]

GHEAD = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T').replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
         for x in HEAD]


def gfile(p):
    return ROOT / f'proofs/obj/big_encx_{p}.bend'


def section(txt, start, end):
    i = txt.index(start)
    j = txt.index(end, i)
    return i, j


def repl(txt, start, end, new):
    i, j = section(txt, start, end)
    return txt[:i] + new + txt[j:]


GELEM = r"""# An element's facts: the element's encoder window's OK.
def EOK(+m: MB<@EW>) -> Bool:
  match m:
    case MNone{}: False{}
    case MSome{+w}: EM.OK(w)

"""

GNEYE = r"""# An element's byte count, bytes and value.
def NE(+m: MB<@EW>) -> U32:
  match m:
    case MNone{}: 0
    case MSome{+w}: EM.SZ(w)
def YE(+m: MB<@EW>) -> +List<U32>:
  match m:
    case MNone{}: []
    case MSome{+w}: EM.ENC(w)
def EV(+m: MB<@EW>) -> S.Value:
  match m:
    case MNone{}: S.EmptyItems{}
    case MSome{+w}: EM.VAL(w)

"""

GBXSIZE = r"""# One element's boxed size, when its facts hold.
def bxsize(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {T.@E_bx_size(th_@E_bx(m)) == (th_@E_bx(m), NE(m)) : O.Boxed<@EO> & U32}:
  match m:
    case MNone{}: Empty.absurd({T.@E_bx_size(th_@E_bx(MNone{})) == (th_@E_bx(MNone{}), NE(MNone{})) : O.Boxed<@EO> & U32}, F.logic__false_true(h))
    case MSome{+w}:
      %Equal.sym(@EO & U32, T.@E_size(EM.TH(w)), (EM.TH(w), EM.SZ(w)), EM.sizex(w, h)) :
        {T.@E_bx_size_back(_) == (O.BSome{EM.TH(w), O.BNone{}}, EM.SZ(w)) : O.Boxed<@EO> & U32}
      {==}

"""

GBXVALID = r"""def bxvalid(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {T.@E_bx_valid(th_@E_bx(m)) == (th_@E_bx(m), True{}) : O.Boxed<@EO> & Bool}:
  match m:
    case MNone{}: Empty.absurd({T.@E_bx_valid(th_@E_bx(MNone{})) == (th_@E_bx(MNone{}), True{}) : O.Boxed<@EO> & Bool}, F.logic__false_true(h))
    case MSome{+w}:
      %Equal.sym(@EO & Bool, T.@E_valid(EM.TH(w)), (EM.TH(w), True{}), EM.validx(w, h)) :
        {T.@E_bx_va_back(_) == (O.BSome{EM.TH(w), O.BNone{}}, True{}) : O.Boxed<@EO> & Bool}
      {==}

"""

GPUT = r"""# The output tree after the element's boxed write at X = 4 q + r.
def PWE(+m: MB<@EW>, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat) -> F.array__Tree<U32>:
  match m:
    case MNone{}: D
    case MSome{+w}: EM.PUTX(w, dd, D, q, r)

# Its footprint: the element's bytes and the zeros to the end of the last word.
def FPE(+r: Nat, +m: MB<@EW>) -> Nat: Nat.add(U32.to_nat(NE(m)), WD.PADB(r, U32.to_nat(NE(m))))

def bxput(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, U32.to_nat(NE(m))))), VB.pw(dd)) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(FPE(r, m), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(FPE(r, m)) : +List<U32>})
    -> {T.@E_bx_putk(F.array__thaw(U32, D), X, th_@E_bx(m)) == (F.array__thaw(U32, PWE(m, dd, D, q, r)), (th_@E_bx(m), NE(m))) : Array<U32> & (O.Boxed<@EO> & U32)}:
  match m:
    case MNone{}: Empty.absurd({T.@E_bx_putk(F.array__thaw(U32, D), X, th_@E_bx(MNone{})) == (F.array__thaw(U32, PWE(MNone{}, dd, D, q, r)), (th_@E_bx(MNone{}), NE(MNone{}))) : Array<U32> & (O.Boxed<@EO> & U32)}, F.logic__false_true(h))
    case MSome{+w}:
      +es = EM.szx(w, h)
      +hl2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hl)
      +hz2 = F.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hz)
      %Equal.sym(Array<U32> & (@EO & U32), T.@E_putk(F.array__thaw(U32, D), X, EM.TH(w)), (F.array__thaw(U32, EM.PUTX(w, dd, D, q, r)), (EM.TH(w), EM.SZ(w))),
          EM.putx(w, dd, D, X, q, r, e, hr, hd, pf, hl2, hz2, h)) :
        {T.@E_bx_pk_back(_) == (F.array__thaw(U32, EM.PUTX(w, dd, D, q, r)), (O.BSome{EM.TH(w), O.BNone{}}, EM.SZ(w))) : Array<U32> & (O.Boxed<@EO> & U32)}
      {==}

def bxput_bytes(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, U32.to_nat(NE(m))))), VB.pw(dd)) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(FPE(r, m), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(FPE(r, m)) : +List<U32>})
    -> {UA.BYT(PWE(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(YE(m), UW.ZB(WD.PADB(r, U32.to_nat(NE(m)))))) : +List<U32>}:
  match m:
    case MNone{}: Empty.absurd({UA.BYT(PWE(MNone{}, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(YE(MNone{}), UW.ZB(WD.PADB(r, U32.to_nat(NE(MNone{})))))) : +List<U32>}, F.logic__false_true(h))
    case MSome{+w}:
      +es = EM.szx(w, h)
      +hl2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hl)
      +hz2 = F.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es, hz)
      F.logic__subst(Nat, z => {UA.BYT(EM.PUTX(w, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(EM.ENC(w), UW.ZB(WD.PADB(r, z)))) : +List<U32>},
        VE2.LEN(EM.ENC(w)), U32.to_nat(EM.SZ(w)), Equal.sym(Nat, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), es), EM.putx_bytes(w, dd, D, X, q, r, e, hr, hd, pf, hl2, hz2, h))

"""

GLENYE = r"""def len_ye(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {VE2.LEN(YE(m)) == U32.to_nat(NE(m)) : Nat}:
  match m:
    case MNone{}: Empty.absurd({VE2.LEN(YE(MNone{})) == U32.to_nat(NE(MNone{})) : Nat}, F.logic__false_true(h))
    case MSome{+w}: Equal.sym(Nat, U32.to_nat(EM.SZ(w)), VE2.LEN(EM.ENC(w)), EM.szx(w, h))

"""

GPWEPF = r"""def pwe_perfect(+m: MB<@EW>, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool})
    -> {F.array__perfect(U32, dd, PWE(m, dd, D, q, r)) == True{} : Bool}:
  match m:
    case MNone{}: pf
    case MSome{+w}: EM.pfx(w, dd, D, q, r, pf)

"""

GDOM = r"""def dom_ye(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {SP.bytes_domain(YE(m)) == True{} : Bool}:
  match m:
    case MNone{}: {==}
    case MSome{+w}: EM.domx(w, h)

# One element's spec parts: its bytes, one variable part.
def el_parts(+m: MB<@EW>, +h: {EOK(m) == True{} : Bool}) -> {Codec.parts(EV(m), @ESCH) == Some{[S.Variable{YE(m)}]} : Maybe<&2, +List<S.Part>>}:
  match m:
    case MNone{}: Empty.absurd({Codec.parts(EV(MNone{}), @ESCH) == Some{[S.Variable{YE(MNone{})}]} : Maybe<&2, +List<S.Part>>}, F.logic__false_true(h))
    case MSome{+w}: EM.encx_spec(w, h)

"""

GVALIDGO = r"""def valid_go(+k: Nat, +W: List<&2, MB<@EW>>, +i: Nat, +hok: {EOKS(k, W, i) == True{} : Bool}) -> {Layout.bytes_valid(VVL.VP(YS(k, W, i))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      +x = xat_@P(W, i)
      VVL.vp_valid(YE(x), YS(q, W, 1n+i), dom_ye(x, and_l(EOK(x), EOKS(q, W, 1n+i), hok)), valid_go(q, W, 1n+i, and_r(EOK(x), EOKS(q, W, 1n+i), hok)))

"""

GBCATDOM = r"""def bcat_dom(+k: Nat, +W: List<&2, MB<@EW>>, +i: Nat, +hok: {EOKS(k, W, i) == True{} : Bool}) -> {SP.bytes_domain(VR.bcat(YS(k, W, i))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      +x = xat_@P(W, i)
      app_dom(YE(x), VR.bcat(YS(q, W, 1n+i)), dom_ye(x, and_l(EOK(x), EOKS(q, W, 1n+i), hok)), bcat_dom(q, W, 1n+i, and_r(EOK(x), EOKS(q, W, 1n+i), hok)))

# The list's bytes are bytes.
def domx(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKL(t, N) == True{} : Bool}) -> {SP.bytes_domain(ENCL(t, N)) == True{} : Bool}:
  app_dom(VVL.OFFS(YSN(t, N), A.quad(U32.to_nat(N))), VR.bcat(YSN(t, N)), offs_dom(YSN(t, N), A.quad(U32.to_nat(N))), bcat_dom(U32.to_nat(N), SL(t), 0n, okl_e(t, N, h)))
"""

GIFACE = r"""
# ==== @P in the encoder-window interface (codegen/var_plist_sub.py's ENCX, with validx and domx) ====

# The writer loop's tree is perfect.
law wlm_pf:
  for +k: Nat
  for +W: List<&2, MB<@EW>>
  for +s: Nat
  for +cur: U32
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, WLM(k, W, s, cur, dd, D, X, q, r)) == True{} : Bool}
def wlm_pf(k, W, s, cur, dd, D, X, q, r, pf):
  match k:
    case 0n: pf
    case 1n+ +j:
      wlm_pf(j, W, 1n+s, O.padd(cur, NE(xat_@P(W, s))), dd, PWE(xat_@P(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), QX(U32.add(X, cur)), RX(U32.add(X, cur))), X, q, r,
        pwe_perfect(xat_@P(W, s), dd, WD.W32X(r, dd, D, Nat.add(s, q), cur), QX(U32.add(X, cur)), RX(U32.add(X, cur)), WD.w32x_perfect(r, dd, D, Nat.add(s, q), cur, pf)))

def pflb(+b: Bool, +t: F.array__Tree<MB<@EW>>, +N: U32, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool})
    -> PFLb(b, t, N, dd, D, X, q, r):
  match b:
    case True{}: pf
    case False{}: wlm_pf(U32.to_nat(N), SL(t), 0n, U32.mul(4, N), dd, D, X, q, r, pf)

# The object's Data mirror: the tree t of the boxed elements' mirrors, and the count N.
type MW is Data:
  MW{t: F.array__Tree<MB<@EW>>, N: U32}

def TH(m: MW) -> T.@P_Seq:
  match m:
    case MW{+t, +N}: THL(t, N)
# A valid object: the list's facts, and its bytes within 2^30.
def OKT(+t: F.array__Tree<MB<@EW>>, +N: U32) -> Bool: Bool.and(OKL(t, N), Nat.is_le(LL(t, N), A.quad(VB.pw(28n))))
def OK(m: MW) -> Bool:
  match m:
    case MW{+t, +N}: OKT(t, N)
def ENC(m: MW) -> +List<U32>:
  match m:
    case MW{+t, +N}: ENCL(t, N)
def VAL(m: MW) -> S.Value:
  match m:
    case MW{+t, +N}: VALL(t, N)
def SZ(m: MW) -> U32:
  match m:
    case MW{+t, +N}: SZS(t, N)
# the writer's model at the byte X = 4 q + r, as a U32
def XQ(+q: Nat, +r: Nat) -> U32: U32.from_nat(Nat.add(A.quad(q), r))
def PUTX(m: MW, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat) -> F.array__Tree<U32>:
  match m:
    case MW{+t, +N}: PUTL(t, N, dd, D, XQ(q, r), q, r)
def PADB(+r: Nat, m: MW) -> Nat: WD.PADB(r, VE2.LEN(ENC(m)))

def ok_l(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}) -> {OKL(t, N) == True{} : Bool}:
  and_l(OKL(t, N), Nat.is_le(LL(t, N), A.quad(VB.pw(28n))), h)
def ok_b(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_le(LL(t, N), A.quad(VB.pw(28n))) == True{} : Bool}:
  and_r(OKL(t, N), Nat.is_le(LL(t, N), A.quad(VB.pw(28n))), h)
# (the bound with its exponent symbolic, k = 28: a literal 2^30 in a conversion would be expanded)
def ok_bk(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {Nat.is_le(LL(t, N), A.quad(VB.pw(k))) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(LL(t, N), A.quad(VB.pw(z))) == True{} : Bool}, 28n, k, Equal.sym(Nat, k, 28n, ek), ok_b(t, N, h))
def ek2(+k: Nat, +ek: {k == 28n : Nat}) -> {2n+k == 30n : Nat}: Equal.cong(Nat, Nat, z => 2n+z, k, 28n, ek)
def hk30(+k: Nat, +ek: {k == 28n : Nat}) -> {Nat.is_lt(k, 30n) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, 30n) == True{} : Bool}, 28n, k, Equal.sym(Nat, k, 28n, ek), {==})
def szsk(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZS(t, N)) == LL(t, N) : Nat}:
  szs(t, N, ok_l(t, N, h), 2n+k, ek2(k, ek), ok_bk(t, N, k, ek, h))
def szwk(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool}) -> {U32.to_nat(SZW(t, N)) == LL(t, N) : Nat}:
  szl(t, N, ok_l(t, N, h), 2n+k, ek2(k, ek), ok_bk(t, N, k, ek, h))
def speck(+t: F.array__Tree<MB<@EW>>, +N: U32, +k: Nat, +ek: {k == 28n : Nat}, +h: {OKT(t, N) == True{} : Bool})
    -> {Codec.parts(VALL(t, N), @LSCH) == Some{[S.Variable{ENCL(t, N)}]} : Maybe<&2, +List<S.Part>>}:
  specl(t, N, ok_l(t, N, h), k, hk30(k, ek), ok_bk(t, N, k, ek, h))

# The returned size of the writer is the size pass's.
def eqsz(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}) -> {SZW(t, N) == SZS(t, N) : U32}:
  F.u32__injective(SZW(t, N), SZS(t, N), Equal.trans(Nat, U32.to_nat(SZW(t, N)), LL(t, N), U32.to_nat(SZS(t, N)), szwk(t, N, 28n, {==}, h),
    Equal.sym(Nat, U32.to_nat(SZS(t, N)), LL(t, N), szsk(t, N, 28n, {==}, h))))

# The runtime's X is XQ(q, r).
def exq(+X: U32, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {X == XQ(q, r) : U32}:
  +X0 = Nat.add(A.quad(q), r)
  +E = A.quad(Nat.add(q, WD.NWN(Nat.add(r, L))))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(X0, z) == True{} : Bool}, Nat.add(X0, Nat.add(L, WD.PADB(r, L))), E, e_end(q, r, L), Order.below_sum(X0, Nat.add(L, WD.PADB(r, L))))
  +h2 = F.nat__le_trans(X0, E, VB.pw(30n), h1, F.nat__le_trans(E, A.quad(VB.pw(dd)), VB.pw(30n), UW.quad_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd), hl), q30(dd, hd)))
  F.u32__injective(X, XQ(q, r), Equal.trans(Nat, U32.to_nat(X), X0, U32.to_nat(XQ(q, r)), e, Equal.sym(Nat, U32.to_nat(XQ(q, r)), X0, F.u32__to_nat_from_nat(X0, 31n, {==}, b31n(X0, h2)))))

# exq at any output depth dd < 31: X0 = to_nat X is below 2^32 anyway.
def exqW(+X: U32, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {X == XQ(q, r) : U32}:
  +X0 = Nat.add(A.quad(q), r)
  +hx = F.logic__subst(Nat, z => {Nat.is_lt(z, F.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(X), X0, e, VB.u32_lt(X))
  F.u32__injective(X, XQ(q, r), Equal.trans(Nat, U32.to_nat(X), X0, U32.to_nat(XQ(q, r)), e, Equal.sym(Nat, U32.to_nat(XQ(q, r)), X0, F.u32__to_nat_from_nat(X0, 32n, {==}, hx))))

def hlx(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, VE2.LEN(ENCL(t, N))))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, LL(t, N)))), VB.pw(dd)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, z))), VB.pw(dd)) == True{} : Bool}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hl)
def hlx32(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, VE2.LEN(ENCL(t, N)))), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, LL(t, N))), F.spec_common__pow2(32n)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, z)), F.spec_common__pow2(32n)) == True{} : Bool}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hl32)
def hlx31(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +dd: Nat, +hs31: {Nat.is_lt(VE2.LEN(ENCL(t, N)), VB.pw(31n)) == True{} : Bool})
    -> {Nat.is_lt(LL(t, N), VB.pw(31n)) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(31n)) == True{} : Bool}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hs31)
def hzx(+t: F.array__Tree<MB<@EW>>, +N: U32, +q: Nat, +r: Nat, +D: F.array__Tree<U32>,
    +hz: {VS.bt(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N)))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N))))) : +List<U32>})
    -> {VS.bt(Nat.add(LL(t, N), WD.PADB(r, LL(t, N))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(LL(t, N), WD.PADB(r, LL(t, N)))) : +List<U32>}:
  F.logic__subst(Nat, z => {VS.bt(Nat.add(z, WD.PADB(r, z)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(z, WD.PADB(r, z))) : +List<U32>}, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N), hz)

def RTX(+t: F.array__Tree<MB<@EW>>, +N: U32, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat) -> Data:
  {T.@P_putk(F.array__thaw(U32, D), X, THL(t, N)) == (F.array__thaw(U32, PUTL(t, N, dd, D, XQ(q, r), q, r)), (THL(t, N), SZS(t, N))) : Array<U32> & (T.@P_Seq & U32)}
def BYX(+t: F.array__Tree<MB<@EW>>, +N: U32, +dd: Nat, +D: F.array__Tree<U32>, +q: Nat, +r: Nat) -> Data:
  {UA.BYT(PUTL(t, N, dd, D, XQ(q, r), q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(ENCL(t, N), UW.ZB(WD.PADB(r, VE2.LEN(ENCL(t, N)))))) : +List<U32>}

def go(+t: F.array__Tree<MB<@EW>>, +N: U32, +h: {OKT(t, N) == True{} : Bool}, +dd: Nat, +D: F.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {F.array__perfect(U32, dd, D) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, VE2.LEN(ENCL(t, N))))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N)))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(VE2.LEN(ENCL(t, N)), WD.PADB(r, VE2.LEN(ENCL(t, N))))) : +List<U32>})
    -> DK.P2(RTX(t, N, dd, D, X, q, r), BYX(t, N, dd, D, q, r)):
  +hl2 = hlx(t, N, q, r, dd, hl)
  +ex = exq(X, q, r, LL(t, N), dd, e, hd, hl2)
  +e2 = F.logic__subst(U32, z => {U32.to_nat(z) == Nat.add(A.quad(q), r) : Nat}, X, XQ(q, r), ex, e)
  +b = U32.is_eq(N, 0)
  +g = putl(t, N, ok_l(t, N, h), dd, D, XQ(q, r), q, r, e2, hr, hd, hl2, pf, hzx(t, N, q, r, D, hz))
  +rt = PA(RTL(t, N, dd, D, XQ(q, r), q, r), DK.P2(BYLb(b, t, N, dd, D, XQ(q, r), q, r), PFLb(b, t, N, dd, D, XQ(q, r), q, r)), g)
  +g2 = PB(RTL(t, N, dd, D, XQ(q, r), q, r), DK.P2(BYLb(b, t, N, dd, D, XQ(q, r), q, r), PFLb(b, t, N, dd, D, XQ(q, r), q, r)), g)
  +by = PA(BYLb(b, t, N, dd, D, XQ(q, r), q, r), PFLb(b, t, N, dd, D, XQ(q, r), q, r), g2)
  +rt2 = F.logic__subst(U32, z => {T.@P_putk(F.array__thaw(U32, D), z, THL(t, N)) == (F.array__thaw(U32, PUTL(t, N, dd, D, XQ(q, r), q, r)), (THL(t, N), SZW(t, N))) : Array<U32> & (T.@P_Seq & U32)},
    XQ(q, r), X, Equal.sym(U32, X, XQ(q, r), ex), rt)
  +rt3 = F.logic__subst(U32, z => {T.@P_putk(F.array__thaw(U32, D), X, THL(t, N)) == (F.array__thaw(U32, PUTL(t, N, dd, D, XQ(q, r), q, r)), (THL(t, N), z)) : Array<U32> & (T.@P_Seq & U32)},
    SZW(t, N), SZS(t, N), eqsz(t, N, h), rt2)
  +by2 = F.logic__subst(Nat, z => {UA.BYT(PUTL(t, N, dd, D, XQ(q, r), q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), VE2.APP(ENCL(t, N), UW.ZB(WD.PADB(r, z)))) : +List<U32>},
    LL(t, N), VE2.LEN(ENCL(t, N)), Equal.sym(Nat, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N)), by)
  (rt3, by2)

# ---- the interface's laws ----------------------------------------------------------------------

law putx:
  for +m: MW
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {T.@P_putk(F.array__thaw(U32, D), X, TH(m)) == (F.array__thaw(U32, PUTX(m, dd, D, q, r)), (TH(m), SZ(m))) : Array<U32> & (T.@P_Seq & U32)}
def putx(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+t, +N}: PA(RTX(t, N, dd, D, X, q, r), BYX(t, N, dd, D, q, r), go(t, N, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law putx_bytes:
  for +m: MW
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +X: U32
  for +q: Nat
  for +r: Nat
  for +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  for +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  for +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, List.length(&2, U32, ENC(m))))), VB.pw(dd)) == True{} : Bool}
  for +hz: {VS.bt(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(List.length(&2, U32, ENC(m)), PADB(r, m))) : +List<U32>}
  for +hok: {OK(m) == True{} : Bool}
  {UA.BYT(PUTX(m, dd, D, q, r)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, ENC(m), UW.ZB(PADB(r, m)))) : +List<U32>}
def putx_bytes(m, dd, D, X, q, r, e, hr, hd, pf, hl, hz, hok):
  match m:
    case MW{+t, +N}: PB(RTX(t, N, dd, D, X, q, r), BYX(t, N, dd, D, q, r), go(t, N, hok, dd, D, X, q, r, e, hr, hd, pf, hl, hz))

law pfx:
  for +m: MW
  for +dd: Nat
  for +D: F.array__Tree<U32>
  for +q: Nat
  for +r: Nat
  for +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}
  {F.array__perfect(U32, dd, PUTX(m, dd, D, q, r)) == True{} : Bool}
def pfx(m, dd, D, q, r, pf):
  match m:
    case MW{+t, +N}: pflb(U32.is_eq(N, 0), t, N, dd, D, XQ(q, r), q, r, pf)

law szx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {U32.to_nat(SZ(m)) == List.length(&2, U32, ENC(m)) : Nat}
def szx(m, hok):
  match m:
    case MW{+t, +N}: Equal.trans(Nat, U32.to_nat(SZS(t, N)), LL(t, N), VE2.LEN(ENCL(t, N)), szsk(t, N, 28n, {==}, hok), Equal.sym(Nat, VE2.LEN(ENCL(t, N)), LL(t, N), len_encl(t, N)))

law sizex:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@P_size(TH(m)) == (TH(m), SZ(m)) : T.@P_Seq & U32}
def sizex(m, hok):
  match m:
    case MW{+t, +N}: sizel(t, N, ok_l(t, N, hok))

law validx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {T.@P_valid(TH(m)) == (TH(m), True{}) : T.@P_Seq & Bool}
def validx(m, hok):
  match m:
    case MW{+t, +N}: valid_l(t, N, ok_l(t, N, hok))

law domx:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {SP.bytes_domain(ENC(m)) == True{} : Bool}
def domx(m, hok):
  match m:
    case MW{+t, +N}: domxl(t, N, ok_l(t, N, hok))

law encx_spec:
  for +m: MW
  for +hok: {OK(m) == True{} : Bool}
  {Codec.parts(VAL(m), @LSCH) == Some{[S.Variable{ENC(m)}]} : Maybe<&2, +List<S.Part>>}
def encx_spec(m, hok):
  match m:
    case MW{+t, +N}: speck(t, N, 28n, {==}, hok)
"""


def glist_text(p, E, mode, cnt, emod, esch, src, sp, se, lsch=None, fulu=False):
    tmpl = TEMPLATE.read_text()
    t = tmpl
    t = repl(t, "# An element's storage facts", "# Elements i .. i + k - 1 of W.", GELEM)
    t = repl(t, "# An element's byte count and bytes.", "# The bytes of elements i .. i + k - 1.", GNEYE)
    t = repl(t, "# ---- one element's facts", "# ---- the mirror array", '')
    t = repl(t, "# One element's boxed size", "law sz_go:", GBXSIZE)
    t = repl(t, "def bxvalid(", "law va_go:", GBXVALID)
    t = repl(t, "def TE(", "# ---- arithmetic", GPUT)
    t = repl(t, "def len_ye(", "# padd of two small words", GLENYE)
    t = repl(t, "def pwe_perfect(", "def q30(", GPWEPF)
    t = repl(t, "def dom_ye(", "def parts_go(", GDOM)
    t = repl(t, "def valid_go(", "# encx_spec:", GVALIDGO)
    t = repl(t, "def bcat_dom(", "\n# The list's bytes are bytes.\ndef domx(", '')
    i = t.index("# The list's bytes are bytes.\ndef domx(")
    t = t[:i] + GBCATDOM
    t = t.replace('S.Items{S.BytesValue{YE(xat_@P(W, i))}, XI(q, W, 1n+i)}', 'S.Items{EV(xat_@P(W, i)), XI(q, W, 1n+i)}')
    t = t.replace('Codec.parts(S.BytesValue{YE(x)}, Spec.Schema60())', 'Codec.parts(EV(x), @ESCH)')
    t = t.replace('Spec.Schema60()', '@ESCH')
    t = t.replace('valid_go(n, W, 0n)', 'valid_go(n, W, 0n, okl_e(t, N, h))')
    # the interface-level lemmas keep their names free for the interface
    for a, b in [('def putx(', 'def putl('), ('def putxW(', 'def putlW('), ('def szx(', 'def szl('), ('def szxS(', 'def szlS('), ('def sizex(', 'def sizel('), ('def encx_spec(', 'def specl(')]:
        assert t.count(a) == 1, a
        t = t.replace(a, b)
    # the count check
    if mode == 'list':
        LIMC, VCAP = f'U32.is_le(N, {cnt})', f'Bool.or(False{{}}, U32.is_le(N, {cnt}))'
        LSCH = f'S.ListOf{{{esch}, {cnt}n}}'
    elif mode == 'prog':
        LIMC, VCAP, LSCH = 'True{}', 'True{}', f'S.ProgressiveList{{{esch}}}'
    else:
        LIMC, VCAP, LSCH = f'U32.is_eq(N, {cnt})', f'U32.is_eq(N, {cnt})', f'S.Vector{{{esch}, {cnt}n}}'
    LSCH = lsch or LSCH
    t = t.replace('U32.is_le(N, @LIML)', LIMC)
    vi, vj = section(t, 'def valid_l(', '# The list\'s bytes: the offsets')
    V = t[vi:vj]
    if mode == 'list':
        V = V.replace('Bool.or(False{}, ' + LIMC + ')', VCAP)
    elif mode == 'prog':
        V = V.replace(f'T.@P_va_cap(Bool.or(False{{}}, {LIMC}), N, _)', f'T.@P_va_cap({VCAP}, N, _)')
        a = V.index('  %Equal.sym(Bool, True{}, True{}, okl_lim(t, N, h))')
        b = V.index('  %Equal.sym(Bool, U32.is_le(N, F.u32__pow2u(d))')
        V = V[:a] + V[b:]
    else:
        V = V.replace(f'T.@P_va_cap(Bool.or(False{{}}, {LIMC}), N, _)', f'T.@P_va_cap({VCAP}, N, _)')
        V = V.replace(f'{{T.@P_va_go(Bool.and(Bool.or(False{{}}, _), U32.is_le(N, F.u32__pow2u(d))), N, AR(t))', '{T.@P_va_go(Bool.and(_, U32.is_le(N, F.u32__pow2u(d))), N, AR(t))')
    t = t[:vi] + V + t[vj:]
    si, sj = section(t, 'def specl(', 'def app_dom(')
    Sx = t[si:sj].replace('Spec.Schema73()', LSCH)
    if mode == 'prog':
        a = Sx.index('  +hcount = ')
        b = Sx.index('  +fit = ')
        Sx = Sx[:a] + Sx[b:]
        a = Sx.index('  %Equal.sym(Bool, Nat.is_le(Codec.count(')
        b = Sx.index('  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(XI(n, W, 0n)')
        Sx = Sx[:a] + Sx[b:]
        Sx = Sx.replace('Codec.require(True{}, ', '').replace('None{})) == Some{[S.Variable{ENCL(t, N)}]}', 'None{}) == Some{[S.Variable{ENCL(t, N)}]}')
    elif mode == 'vec':
        a = Sx.index('  +hcount = ')
        b = Sx.index('  +fit = ')
        Sx = Sx[:a] + f'''  +eN = Equal.cong(U32, Nat, z => U32.to_nat(z), N, {cnt}, F.u32alg__eq_of(N, {cnt}, okl_lim(t, N, h)))
  +hcount = F.logic__subst(Nat, z => {{Nat.is_eq(z, {cnt}n) == True{{}} : Bool}}, {cnt}n, Codec.count(XI(n, W, 0n)), Equal.sym(Nat, Codec.count(XI(n, W, 0n)), {cnt}n, Equal.trans(Nat, Codec.count(XI(n, W, 0n)), n, {cnt}n, count_go(n, W, 0n), eN)), {{==}})
''' + Sx[b:]
        a = Sx.index('  %Equal.sym(Bool, Nat.is_le(Codec.count(')
        b = Sx.index('  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(XI(n, W, 0n)')
        Sx = Sx[:a] + f'''  %Equal.sym(Bool, Nat.is_eq(Codec.count(XI(n, W, 0n)), {cnt}n), True{{}}, hcount) :
    {{Codec.require(Bool.and(Nat.is_lt(0n, {cnt}n), _), Codec.aggregate(Codec.parts(XI(n, W, 0n), S.Repeat{{@ESCH}}), None{{}})) == Some{{[S.Variable{{ENCL(t, N)}}]}} : Maybe<&2, +List<S.Part>>}}
''' + Sx[b:]
    t = t[:si] + Sx + t[sj:]
    t = t.replace('MB<WMr>', 'MB<@EW>').replace('O.Boxed<O.Words>', 'O.Boxed<@EO>')
    assert 'WMr' not in t and 'O.Words' not in t, [l for l in t.split('\n') if 'WMr' in l or 'O.Words' in l][:3]
    # the element module and the copied array lemmas
    es = _unlit((ROOT / 'proofs/obj' / emod).read_text())
    EW = 'EM.' + re.search(r'^type (\w+) is Data:', es, re.M).group(1)
    EO = 'O.Words' if E.startswith('bl') else (f'T.{E}_Seq' if E.startswith('pl_') or E.startswith('l') else f'T.{E}')
    bl = blocks(_unlit((ROOT / 'proofs/obj' / src).read_text()))
    names = ['MB', f'th_{se}_bx', f'am_{sp}', f'amsize_{sp}', f'amswap_go_{sp}', f'amswap_{sp}', f'amset_{sp}', f'amswap_back_{sp}', f'xat_{sp}', f'nth_{sp}']
    miss = [c for c in names if c not in bl]
    assert not miss, miss
    SEO = 'O.Words' if se.startswith('bl') else (f'T.{se}_Seq' if se.startswith('pl_') else f'T.{se}')
    cp = []
    for c in names:
        b = bl[c]
        b = re.sub(rf'\bM_{se}\b', '@EW', b).replace(f'th_{se}(', 'EM.TH(').replace(f'th_{se}_bx', f'th_{E}_bx')
        b = re.sub(rf'_{sp}\b', f'_{p}', b).replace(SEO, EO)
        cp.append(b)
    body = '\n'.join(cp) + '\n' + t + GIFACE
    body = body.replace('domx(+t:', 'domxl(+t:')
    body = (body.replace('@ESCH', esch).replace('@LSCH', LSCH).replace('@EW', EW).replace('@EO', EO).replace('@P', p).replace('@E', E)
            .replace('@LIML', str(cnt)).replace('@LIM', str(cnt)))
    assert '@' not in body.replace('&2', ''), [l for l in body.split('\n') if '@' in l.replace('&2', '')][:3]
    L = (HEAD if fulu else GHEAD) + [f'import ./{emod} as EM', '', '# GENERATED by codegen/var_vlist_enc.py. Do not edit.',
                 f'# {p}: a {"progressive list" if mode == "prog" else ("vector" if mode == "vec" else "list")} of {E} (boxed), writer side, in the encoder-window interface;',
                 f'# its elements through their encoder window {emod} (see the generator).', '',
                 f'# ---- mirrors of the boxed elements (copied from proofs/obj/{src}, renamed) ----']
    return '\n'.join(L) + '\n' + body


def main():
    nb = '--no-big' in sys.argv
    out = {}
    if not nb:
        bl = blocks(_unlit(RT.read_text()))
        missing = [c for c in COPY if c not in bl]
        assert not missing, missing
        L = HEAD + ['', '# GENERATED by codegen/var_vlist_enc.py. Do not edit.',
                    '# The list of transactions, writer side (see the generator\'s docstring).', '',
                    '# ---- mirrors of the boxed elements (copied from proofs/obj/root_types.bend) ----']
        L += [bl[c] for c in COPY]
        txt = '\n'.join(L) + '\n' + TEMPLATE.read_text().replace('@P', P).replace('@E', E).replace('@LIML', LIML).replace('@LIM', LIM)
        out[OUT] = txt
        for gl in GLISTS:
            if (ROOT / 'proofs/obj' / gl[4]).exists():
                out[gfile(gl[0])] = glist_text(*gl)
    import runtime_refs as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    import deep  # the dd < 31 twins (name+W; the old names wrap them at dd < 29); the list writer's own W: vvle_list.bend.in
    out = deep.dify_out(out, strict='--loose' not in sys.argv, skip={'q30', 'qk'}, post=deep.chain_posts(deep.hl32_pass(needed_only=True, derive={'hlx': 'hlx32'}), deep.hs31_pass(derive={'hlx': 'hlx31'}), lambda q, t, res: (__import__('okw').list_btwins(t), [])))
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale generated list encoder modules: ' + ', '.join(stale))
            sys.exit(1)
        print('generated list encoder modules are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print(', '.join(str(p.relative_to(ROOT)) for p in out) or 'nothing (--no-big)')


if __name__ == '__main__':
    main()
