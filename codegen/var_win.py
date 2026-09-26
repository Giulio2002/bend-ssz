#!/usr/bin/env python3
"""Window laws for nesting: a type read at a symbolic word-aligned window
(byte offset off = 4 i, length len) of a buffer.

    python3 codegen/var_win.py [--check] [--no-big]

Every window module proofs/obj/<big_>var_win_<X>.bend exports the same
interface, so that a container whose variable field is X is proved from it:

    CHKw(t, i, off, len)   the Bool of X's validator on the window;
    ok_evalw               T.<X>_ok(BF(t, n), off, len) == (BF(t, n), CHKw(..));
    OBJw(t, i, off, len)   the object the reader builds when CHKw holds;
    readw                  T.<X>_read(BF(t, n), off, len) == (BF(t, n), OBJw(..));
    VALw(t, i, len)        its spec value;
    specw                  CHKw holds: the spec parts of VALw are one variable
                           part, the window's bytes VR.WB(t, i, len);
    invw                   every value whose spec parts are that variable part
                           passes the checks: CHKw(t, i, off, len) = True;

for every perfect word tree t of depth d < 28 with 4 i + len <= 4 2^d. Kinds:
bit lists (var_win_bits<N>), and containers of fixed word-aligned fields
around one variable field that is a bit list or such a container (boxed or
not). For the containers the generator also writes the top-level codec laws
(the window at offset 0 of the whole buffer): proofs/obj/<big_>var_win_<X>_top.bend
(ok_eval, decode_accept, decode_none, decode_spec, decode_reject) and _unique.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import schema  # noqa: E402
import var_laws as VL  # noqa: E402

ROOT = VL.ROOT
# Containers, in dependency order (children first).
WIN = ['Attestation', 'AggregateAndProof', 'SignedAggregateAndProof']


def ceil_log2(x):
    return max(0, (x - 1).bit_length())


HEAD = list(VL.DEC_HEAD) + ['import ./spec_bits.bend as FB', 'import ./vfits.bend as VFT', 'import ./vlist.bend as VLS',
                            'import ./vbitl.bend as VBL', 'import ./vbyte.bend as VY', 'import ./vbrt.bend as VR',
                            'import ./vbitc.bend as VBC', 'import ./vrej.bend as VRJ', 'import ./vnest.bend as VN', 'import ./dk.bend as DK',
                            'import ../../spec/bitfields.bend as Bits', 'import ../../spec/bit_packing.bend as Bp']

COMMON = r"""
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)

def hlen(+d: Nat, +i: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw)

# The payload of a one-part variable list.
def varpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Variable{+xs}, t}: xs
    case _: []

def var_inj(+a: +List<U32>, +b: +List<U32>, +e: {Some{[S.Variable{a}]} == Some{[S.Variable{b}]} : Maybe<&2, +List<S.Part>>}) -> {a == b : +List<U32>}:
  Equal.cong(+List<S.Part>, +List<U32>, z => varpay(z), [S.Variable{a}], [S.Variable{b}], FD.logic__some_inj(+List<S.Part>, [S.Variable{a}], [S.Variable{b}], e))
"""

BITS = r"""
def V(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> U32: VR.VX(t, VR.XN(off, len))
def M1(+len: U32) -> Nat: U32.to_nat(U32.sub(len, 1))
def BD(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> Nat: Nat.add(Nat.mul(8n, M1(len)), U32.to_nat(O.high_bit(V(t, off, len))))

def chk1(a: Bool, +t: FD.array__Tree<U32>, +off: U32, +len: U32) -> Bool:
  match a:
    case False{}: False{}
    case True{}: O.bsel(U32.is_eq(V(t, off, len), 0), False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N))))

# A bit list's window: non-empty, a non-zero last byte, at most @N bits.
def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> Bool: chk1(U32.is_lt(0, len), t, off, len)

def eX(+d: Nat, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat})
    -> {U32.to_nat(VR.XN(off, len)) == Nat.add(A.quad(i), M1(len)) : Nat}:
  VR.eXN(d, off, i, len, M1(len), eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hw, e1)

def hi(+d: Nat, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat})
    -> {Nat.is_lt(VR.QX(VR.XN(off, len)), VB.pw(d)) == True{} : Bool}:
  VR.hiX(d, VR.XN(off, len), Nat.add(A.quad(i), M1(len)), eX(d, i, off, len, eo, hd, hw, e1),
    FD.nat__lt_le_trans(Nat.add(A.quad(i), M1(len)), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)),
      FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(i), M1(len)), Nat.add(A.quad(i), z)) == True{} : Bool}, 1n+M1(len), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+M1(len), e1),
        FD.nat__lt_add_left(M1(len), 1n+M1(len), A.quad(i), FD.nat__lt_succ(M1(len)))), hw))

def okA(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +a: Bool, +ea: {U32.is_lt(0, len) == a : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), chk1(a, t, off, len)) : B.Buf & Bool}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_lt(0, len), False{}, ea) : {O.bitlist_nz(_, BF(t, n), off, len, @N, False{}) == (BF(t, n), False{}) : B.Buf & Bool}
      {==}
    case True{}:
      +e1 = VR.e1n(len, VR.pos1(len, ea))
      %Equal.sym(Bool, U32.is_lt(0, len), True{}, ea) : {O.bitlist_nz(_, BF(t, n), off, len, @N, False{}) == (BF(t, n), chk1(True{}, t, off, len)) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)),
          VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
        {O.bitlist_pick(len, @N, False{}, _) == (BF(t, n), chk1(True{}, t, off, len)) : B.Buf & Bool}
      {==}

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, i, off, len)) : B.Buf & Bool}:
  okA(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_lt(0, len), {==})

def cA(+a: Bool, +t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(a, t, off, len) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def bselF(+c: Bool, +y: Bool, +h: {O.bsel(c, False{}, y) == True{} : Bool}) -> {c == False{} : Bool}:
  match c:
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(h))
    case False{}: {==}

def c1(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +h: {CHKw(t, i, off, len) == True{} : Bool}) -> {chk1(True{}, t, off, len) == True{} : Bool}:
  FD.logic__subst(Bool, z => {chk1(z, t, off, len) == True{} : Bool}, U32.is_lt(0, len), True{}, cA(U32.is_lt(0, len), t, off, len, h), h)

def cB(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(True{}, t, off, len) == True{} : Bool}) -> {U32.is_eq(V(t, off, len), 0) == False{} : Bool}:
  bselF(U32.is_eq(V(t, off, len), 0), O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N))), h)

def cC(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(True{}, t, off, len) == True{} : Bool}, +nz: {U32.is_eq(V(t, off, len), 0) == False{} : Bool})
    -> {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(V(t, off, len), 0), False{}, nz, h)

def cE(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +h: {CHKw(t, i, off, len) == True{} : Bool}) -> {U32.to_nat(len) == 1n+M1(len) : Nat}:
  VR.e1n(len, VR.pos1(len, cA(U32.is_lt(0, len), t, off, len, h)))

def hB(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat}, +bd: {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}:
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, M1(len)), VS.x8(M1(len)), VR.mul8(M1(len)), bd)
  +h8 = FD.nat__le_trans(VS.x8(M1(len)), Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), Nat.add(VS.x8(@Cn), 7n), FD.nat__le_add_right(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))),
    FD.nat__le_trans(Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N), Nat.add(VS.x8(@Cn), 7n), bd1, {==}))
  %Equal.sym(Nat, U32.to_nat(len), 1n+M1(len), e1) : {Nat.is_le(_, @BMAXn) == True{} : Bool}
  VR.x8_inv(M1(len), @Cn, h8)

def hdzK(+d: Nat, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hL: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(len), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(len), @Kn,
    FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
      VC.wz_le(len, VLS.KK(d), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL)),
      FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
        Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(len), @YMAXn, Order.add_left(31n, U32.to_nat(len), @BMAXn, hb))),
        {==})))
@ZEROS
def NB(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> U32: U32.add(U32.mul(8, U32.sub(len, 1)), O.high_bit(V(t, off, len)))
def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, i, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}:
  +e1 = cE(t, i, off, len, hchk)
  +h1 = c1(t, i, off, len, hchk)
  +hL = hlen(d, i, len, hw)
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})
  +hz = hdzK(d, len, hd, hL, hB(t, off, len, e1, cC(t, off, len, h1, cB(t, off, len, h1))))
  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)
  %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)), VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, hd31), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
    {O.bits_from(len, off, _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwH(d, len, i, hd, hw), VLS.hrg(d, len, hd, hL))) :
    {O.bits_clear(NB(t, off, len), _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  {==}

def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: S.BitsValue{VBL.bl(VR.WB(t, i, U32.to_nat(len)))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, i, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), @SCH) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +e1 = cE(t, i, off, len, hchk)
  +h1 = c1(t, i, off, len, hchk)
  +nz = cB(t, off, len, h1)
  +bd = cC(t, off, len, h1, nz)
  +m = M1(len)
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +lw = VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1, eX(d, i, off, len, eo, hd, hw, e1))
  +nzl = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, V(t, off, len), VBL.lastb(W1), Equal.sym(U32, VBL.lastb(W1), V(t, off, len), lw), nz)
  +dom = VR.domWB(t, i, 1n+m)
  +len1 = Equal.trans(Nat, List.length(&2, Bool, VBL.bl(W1)), VBL.blen(W1), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), VBL.bl_len(W1, dom, nzl),
    Equal.trans(Nat, VBL.blen(W1), Nat.add(VS.x8(m), VY.hb(VBL.lastb(W1))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))),
      VR.blen_m(W1, m, VR.lenWB(d, t, i, 1n+m, pf, hw1)),
      Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.lastb(W1), V(t, off, len), lw)))
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, m), VS.x8(m), VR.mul8(m), bd)
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), List.length(&2, Bool, VBL.bl(W1)),
    Equal.sym(Nat, List.length(&2, Bool, VBL.bl(W1)), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), len1), bd1)
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) :
    {Codec.parts(S.BitsValue{VBL.bl(VR.WB(t, i, _))}, @SCH) == Some{[S.Variable{VR.WB(t, i, _)}]} : Maybe<&2, +List<S.Part>>}
  VBC.bl_parts(W1, @LIMN, dom, nzl, hl)

# ---- every bit-list value of the window's bytes passes the checks ----------------------------

def m1e(+len: U32, +m: Nat, +e1: {U32.to_nat(len) == 1n+m : Nat}) -> {M1(len) == m : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), FD.nat__zero_le(m))
  %Equal.sym(Nat, M1(len), Nat.sub(U32.to_nat(len), 1n), FD.u32__sub_nat(len, 1, h1)) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) : {Nat.sub(_, 1n) == m : Nat}
  FD.nat__add_sub_cancel(1n, m)

def chk_true(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +m: Nat, +e1: {U32.to_nat(len) == 1n+m : Nat},
    +nz: {U32.is_eq(V(t, off, len), 0) == False{} : Bool}, +bd: {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  +ea = FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), {==})
  %Equal.sym(Bool, U32.is_lt(0, len), True{}, FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(0n, U32.to_nat(len)), U32.is_lt(0, len), Equal.sym(Bool, U32.is_lt(0, len), Nat.is_lt(0n, U32.to_nat(len)), VR.lt_u32(0, len)), ea)) :
    {chk1(_, t, off, len) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(V(t, off, len), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N)))) == True{} : Bool}
  bd

def inv_t(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +bits: +List<Bool>, +hb: {Nat.is_le(List.length(&2, Bool, bits), @LIMN) == True{} : Bool}, +pk: {VBL.P(bits) == VR.WB(t, i, U32.to_nat(len)) : +List<U32>},
    +fs: VBL.IF(bits)) -> {CHKw(t, i, off, len) == True{} : Bool}:
  (+l, +r) = fs
  (+nz0, +ln) = r
  +m = VBL.mcnt(bits)
  +WL = VR.WB(t, i, U32.to_nat(len))
  +e1 = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WL), 1n+m, Equal.sym(Nat, List.length(&2, U32, WL), U32.to_nat(len), VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, WL), List.length(&2, U32, VBL.P(bits)), 1n+m,
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), WL, VBL.P(bits), Equal.sym(+List<U32>, VBL.P(bits), WL, pk)), l))
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +m1 = m1e(len, m, e1)
  +e1m = Equal.trans(Nat, U32.to_nat(len), 1n+m, 1n+M1(len), e1, Equal.cong(Nat, Nat, z => 1n+z, m, M1(len), Equal.sym(Nat, M1(len), m, m1)))
  +lw = VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1,
    FD.logic__subst(Nat, z => {U32.to_nat(VR.XN(off, len)) == Nat.add(A.quad(i), z) : Nat}, M1(len), m, m1, eX(d, i, off, len, eo, hd, hw, e1m)))
  +eW = Equal.trans(+List<U32>, VBL.P(bits), WL, W1, pk, Equal.cong(Nat, +List<U32>, z => VR.WB(t, i, z), U32.to_nat(len), 1n+m, e1))
  +eV = Equal.trans(U32, VBL.nthb(VBL.P(bits), m), VBL.nthb(W1, m), V(t, off, len), Equal.cong(+List<U32>, U32, z => VBL.nthb(z, m), VBL.P(bits), W1, eW),
    Equal.trans(U32, VBL.nthb(W1, m), VBL.lastb(W1), V(t, off, len), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(W1, m), VR.last_len(W1, m, VR.lenWB(d, t, i, 1n+m, pf, hw1))), lw))
  +nz = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, VBL.nthb(VBL.P(bits), m), V(t, off, len), eV, nz0)
  +lnV = Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), VY.hb(VBL.nthb(VBL.P(bits), m))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), ln,
    Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.nthb(VBL.P(bits), m), V(t, off, len), eV))
  +eBD = Equal.trans(Nat, BD(t, off, len), Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), Nat.mul(8n, M1(len)), VS.x8(M1(len)), VR.mul8(M1(len))),
    Equal.cong(Nat, Nat, z => Nat.add(VS.x8(z), U32.to_nat(O.high_bit(V(t, off, len)))), M1(len), m, m1))
  +bd = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, List.length(&2, Bool, bits), BD(t, off, len),
    Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), BD(t, off, len), lnV, Equal.sym(Nat, BD(t, off, len), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), eBD)), hb)
  chk_true(t, i, off, len, m, e1, nz, bd)

def inv_b(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +bits: +List<Bool>, +b: Bool, +eb: {Nat.is_le(List.length(&2, Bool, bits), @LIMN) == b : Bool},
    +e: {Codec.one(Bits.encoding(b, List.append(&2, Bool, bits, [True{}])), None{}) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  match b:
    case False{}: Empty.absurd({CHKw(t, i, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{VR.WB(t, i, U32.to_nat(len))}], e))
    case True{}: inv_t(d, t, i, off, len, eo, hd, hw, pf, bits, eb, var_inj(VBL.P(bits), VR.WB(t, i, U32.to_nat(len)), e), VBL.inv(bits))

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  match v:
    case S.BitsValue{+bits}: inv_b(d, t, i, off, len, eo, hd, hw, pf, bits, Nat.is_le(List.length(&2, Bool, bits), @LIMN), {==}, e)
@ABSURDV
"""


def zeros_at_text(KK):
    L = [f'def zeros_at(+du: U32, +k: Nat, +e: {{U32.to_nat(du) == k : Nat}}, +hk: {{Nat.is_le(k, {KK}n) == True{{}} : Bool}})',
         '    -> {B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}:', '  match k:']
    for j in range(KK + 1):
        L.append(f'    case {j}n:')
        L.append(f'      %Equal.sym(U32, du, {j}, FD.u32__injective(du, {j}, e)) : {{B.zeros(_) == Array.new(U32, {j}n, 0) : Array<U32>}}')
        L.append('      {==}')
    L.append(f'    case {KK + 1}n+p: Empty.absurd({{B.zeros(du) == Array.new(U32, {KK + 1}n+p, 0) : Array<U32>}}, FD.logic__false_true(hk))')
    return '\n'.join(L) + '\n'


VALUE_CTORS = [('BooleanValue', ['b0']), ('UnsignedValue', ['u0']), ('BytesValue', ['xs0']), ('BitsValue', ['bs0']),
               ('Sequence', ['it0']), ('Items', ['hd0', 'tl0']), ('EmptyItems', []), ('Selected', ['sel0', 'sv0']), ('NullValue', [])]


def absurd_cases(keep, goal, e='e', target='[S.Variable{VR.WB(t, i, U32.to_nat(len))}]'):
    out = []
    for c, args in VALUE_CTORS:
        if c == keep:
            continue
        pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
        out.append(f'    case {pat}: Empty.absurd({goal}, FD.logic__none_some(+List<S.Part>, {target}, {e}))')
    return '\n'.join(out)


class Bits:
    """A bit list BitList[N] (runtime prefix p), and the schema term of its spec."""

    def __init__(self, N, p, sch, limn):
        self.N, self.p, self.sch, self.limn = N, p, sch, limn
        self.C = N // 8
        self.BMAX = self.C + 1
        self.YMAX = 31 + self.BMAX
        self.K = ceil_log2((self.YMAX >> 2) + 8)
        self.name = f'bits{N}'


def big_bits(b):
    return b.N >= 1 << 16


def bits_fname(b):
    return ROOT / f'proofs/obj/{"big_" if big_bits(b) else ""}var_win_{b.name}.bend'


def bits_text(b):
    body = BITS.replace('@ZEROS', '\n' + zeros_at_text(b.K))
    body = body.replace('@ABSURDV', absurd_cases('BitsValue', '{CHKw(t, i, off, len) == True{} : Bool}'))
    for k, v in [('@BMAXn', f'{b.BMAX}n'), ('@YMAXn', f'{b.YMAX}n'), ('@Cn', f'{b.C}n'), ('@Kn', f'{b.K}n'), ('@LIMN', b.limn),
                 ('@SCH', b.sch), ('@N', str(b.N)), ('@p_', f'{b.p}_')]:
        body = body.replace(k, v)
    L = HEAD + ['', '# GENERATED by codegen/var_win.py. Do not edit.',
                f'# BitList[{b.N}] at a word-aligned window: the window interface of codegen/var_win.py.', '']
    return '\n'.join(L) + COMMON + body


def spec_defs():
    src = (ROOT / 'spec/fulu_schemas.bend').read_text()
    return dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.*)$', src, re.M))


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    no_big = '--no-big' in sys.argv
    out = {}
    defs = spec_defs()
    # the bit lists of the containers
    for n in WIN:
        kids, _ = VL.spec_schemas(n)
        for (fname_, ft), k in zip(names[n].fields, kids):
            if ft.kind == 'bitlist':
                m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[k])
                b = Bits(ft.size, g.shape(ft).p, f'Spec.{k}()', m.group(1))
                if no_big and big_bits(b):
                    continue
                out[bits_fname(b)] = bits_text(b)
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_win_*.bend') if q.name.startswith(('var_win_', 'big_var_win_'))]
    orphans = sorted(str(q.relative_to(ROOT)) for q in mine if q not in out and not (no_big and q.name.startswith('big_')))
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t] + orphans
        if stale:
            print('stale generated window laws: ' + ', '.join(stale))
            sys.exit(1)
        print('generated window laws are current')
        return
    for q in orphans:
        (ROOT / q).unlink()
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
