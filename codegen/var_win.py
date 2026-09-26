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


# ---- containers: fixed fields around one variable field (a bit list or a window container) -------

class WName:
    def __init__(self, g, n, t, src, kids):
        self.n, self.t = n, t
        self.fields = []
        pos = 0
        var = None
        for (fname, ft), k in zip(t.fields, kids):
            if ft.fixed():
                f = VL.FT(g, ft)
                self.fields.append({'kind': 'fix', 'name': fname, 'ft': f, 'c': pos, 'k': pos // 4, 't': ft, 'sk': k})
                pos += f.size
            else:
                assert var is None
                var = {'kind': 'var', 'name': fname, 'c': pos, 'k': pos // 4, 't': ft, 'sk': k}
                self.fields.append(var)
                pos += 4
        self.var = var
        self.FS, self.H, self.po = pos, pos // 4, var['k']
        # the runtime's reader and validator of the variable field
        m = re.search(rf'def {n}_c0\(ok: Bool, buf: B\.Buf, \+off: U32, \+len: U32, \+o0: U32\) -> B\.Buf & Bool:\n  match ok:\n    case True\{{\}}: {n}_v1\(off, len, o0, (\w+)_ok\(buf', src)
        self.okf = m.group(1)
        m = re.search(r'(\w+)_read\(buf, \(off \+ o_' + var['name'] + r' : U32\)', src)
        self.rdf = m.group(1)
        self.boxed = self.rdf.endswith('_bx')


def cont_text(g, x, ch, chmod, CSCH, chrep, bits):
    """Window module of container x whose variable field is read by the child
    window module chmod (alias CH); CSCH is the child's spec schema term."""
    n, FS, H, po = x.n, x.FS, x.H, x.po
    Tn = f'T.{n}'
    CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},\n'
          '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
          '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    CWA = 'd, t, n, i, off, len, eo, hd, hw, pf'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    kids = [f['sk'] for f in x.fields]
    L = HEAD + ['import ./vwin.bend as VWN', f'import ./{chmod} as CH', 'import ../../proofs/decode_shape.bend as DS',
                'import ../../proofs/decode_facts.bend as DF', '', '# GENERATED by codegen/var_win.py. Do not edit.',
                f'# {n} at a word-aligned window: the window interface of codegen/var_win.py.', '']
    w = L.append
    w(COMMON)
    CHK_child = 'CH.CHKw(t, JW(i), OWc(off), LLw(len))'
    w(f'''def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add({po}n, i))
def LLw(+len: U32) -> U32: U32.sub(len, {FS})
def OWc(+off: U32) -> U32: U32.add(off, {FS})
def JW(+i: Nat) -> Nat: Nat.add({H}n, i)

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{{}}: False{{}}
    case True{{}}:
      match b:
        case False{{}}: False{{}}
        case True{{}}: c

def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> Bool:
  chk3(U32.is_le({FS}, len), U32.is_eq(SPOw(t, i), {FS}), {CHK_child})

def leF(+len: U32, {HA}) -> {{Nat.is_le({FS}n, U32.to_nat(len)) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le({FS}, len), Nat.is_le({FS}n, U32.to_nat(len)), VU.le_u32({FS}, len), ha)

def enF(+len: U32, {HA}) -> {{Nat.add({FS}n, U32.to_nat(LLw(len))) == U32.to_nat(len) : Nat}}:
  %Equal.sym(Nat, U32.to_nat(LLw(len)), Nat.sub(U32.to_nat(len), {FS}n), FD.u32__sub_nat(len, {FS}, leF(len, ha))) : {{Nat.add({FS}n, _) == U32.to_nat(len) : Nat}}
  FD.nat__sub_add(U32.to_nat(len), {FS}n, leF(len, ha))

def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {{Nat.is_le(A.quad(k), U32.to_nat(len)) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{{}} : Bool}}) -> {{Nat.is_le(A.quad(Nat.add(k, i)), P) == True{{}} : Bool}}:
  %VF.quad_add(k, i) : {{Nat.is_le(_, P) == True{{}} : Bool}}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, P) == True{{}} : Bool}}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

def eoc({CW}, +k: Nat, +c: U32, +ec: {{U32.to_nat(c) == A.quad(k) : Nat}}, +hkF: {{Nat.is_le(A.quad(k), {FS}n) == True{{}} : Bool}}, {HA})
    -> {{U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}}:
  VF.off_add(off, c, i, k, 2n+d, eo, ec, FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}),
    winb(k, i, len, A.quad(VB.pw(d)), FD.nat__le_trans(A.quad(k), {FS}n, U32.to_nat(len), hkF, leF(len, ha)), hw))

def hHi({CW}, {HA}) -> {{Nat.is_le(Nat.add({H}n, i), VB.pw(d)) == True{{}} : Bool}}:
  VC.quad_inv(Nat.add({H}n, i), VB.pw(d), winb({H}n, i, len, A.quad(VB.pw(d)), leF(len, ha), hw))

def hiw({CW}, +k: Nat, +hk: {{Nat.is_lt(k, {H}n) == True{{}} : Bool}}, {HA}) -> {{Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{{}} : Bool}}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add({H}n, i), VB.pw(d), VB.lt_kk(k, {H}n, i, hk), hHi({CWA}, ha))

# The child's window: 4 (H + i) + (len - {FS}) <= 4 2^d.
def hwc({CW}, {HA}) -> {{Nat.is_le(Nat.add(A.quad(JW(i)), U32.to_nat(LLw(len))), A.quad(VB.pw(d))) == True{{}} : Bool}}:
  %Equal.sym(Nat, A.quad(Nat.add({H}n, i)), Nat.add(A.quad({H}n), A.quad(i)), VF.quad_add({H}n, i)) : {{Nat.is_le(Nat.add(_, U32.to_nat(LLw(len))), A.quad(VB.pw(d))) == True{{}} : Bool}}
  %FD.nat__add_comm(A.quad(i), A.quad({H}n)) : {{Nat.is_le(Nat.add(_, U32.to_nat(LLw(len))), A.quad(VB.pw(d))) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), {FS}n), U32.to_nat(LLw(len))), Nat.add(A.quad(i), Nat.add({FS}n, U32.to_nat(LLw(len)))), FD.nat__add_assoc(A.quad(i), {FS}n, U32.to_nat(LLw(len)))) :
    {{Nat.is_le(_, A.quad(VB.pw(d))) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)) : {{Nat.is_le(Nat.add(A.quad(i), _), A.quad(VB.pw(d))) == True{{}} : Bool}}
  hw

def eoF({CW}, {HA}) -> {{U32.to_nat(OWc(off)) == A.quad(JW(i)) : Nat}}:
  eoc({CWA}, {H}n, {FS}, {{==}}, {{==}}, ha)

# ---- the validator ----------------------------------------------------------------------------

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {{{Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}}:
  match ok:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def okc0({CW}, {HA}, +b: Bool, +eb: {{U32.is_eq(SPOw(t, i), {FS}) == b : Bool}})
    -> {{{Tn}_c0(b, BF(t, n), off, len, SPOw(t, i)) == (BF(t, n), chk3(True{{}}, b, {CHK_child})) : B.Buf & Bool}}:
  match b:
    case False{{}}: {{==}}
    case True{{}}:
      +epo = FD.u32alg__eq_of(SPOw(t, i), {FS}, eb)
      %Equal.sym(U32, SPOw(t, i), {FS}, epo) :
        {{{Tn}_v1(off, len, _, T.{x.okf}_ok(BF(t, n), U32.add(off, _), U32.sub(len, _))) == (BF(t, n), {CHK_child}) : B.Buf & Bool}}
      %Equal.sym(B.Buf & Bool, T.{x.okf}_ok(BF(t, n), OWc(off), LLw(len)), (BF(t, n), {CHK_child}),
          CH.ok_evalw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), pf)) :
        {{{Tn}_v1(off, len, {FS}, _) == (BF(t, n), {CHK_child}) : B.Buf & Bool}}
      c1_id({CHK_child}, BF(t, n), off, len, {FS})

def okl({CW}, +a: Bool, +ea: {{U32.is_le({FS}, len) == a : Bool}})
    -> {{{Tn}_ok_len(a, BF(t, n), off, len) == (BF(t, n), chk3(a, U32.is_eq(SPOw(t, i), {FS}), {CHK_child})) : B.Buf & Bool}}:
  match a:
    case False{{}}: {{==}}
    case True{{}}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, {4 * po})), (VF.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, {4 * po}), Nat.add({po}n, i), eoc({CWA}, {po}n, {4 * po}, {{==}}, {{==}}, ea),
            VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {{==}})), hiw({CWA}, {po}n, {{==}}, ea), pf)) :
        {{{Tn}_v0(off, len, _) == (BF(t, n), chk3(True{{}}, U32.is_eq(SPOw(t, i), {FS}), {CHK_child})) : B.Buf & Bool}}
      okc0({CWA}, ea, U32.is_eq(SPOw(t, i), {FS}), {{==}})

# The validator on the window returns the buffer and CHKw.
def ok_evalw({CW}) -> {{{Tn}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, i, off, len)) : B.Buf & Bool}}:
  okl({CWA}, U32.is_le({FS}, len), {{==}})

def ch_a(+a: Bool, +b: Bool, +c: Bool, +h: {{chk3(a, b, c) == True{{}} : Bool}}) -> {{a == True{{}} : Bool}}:
  match a:
    case False{{}}: h
    case True{{}}: {{==}}

def ch_b(+a: Bool, +b: Bool, +c: Bool, +h: {{chk3(a, b, c) == True{{}} : Bool}}) -> {{b == True{{}} : Bool}}:
  match a b:
    case False{{}} _: Empty.absurd({{b == True{{}} : Bool}}, FD.logic__false_true(h))
    case True{{}} False{{}}: h
    case True{{}} True{{}}: {{==}}

def ch_c(+a: Bool, +b: Bool, +c: Bool, +h: {{chk3(a, b, c) == True{{}} : Bool}}) -> {{c == True{{}} : Bool}}:
  match a b:
    case False{{}} _: Empty.absurd({{c == True{{}} : Bool}}, FD.logic__false_true(h))
    case True{{}} False{{}}: Empty.absurd({{c == True{{}} : Bool}}, FD.logic__false_true(h))
    case True{{}} True{{}}: h
''')
    # ---- the reader ----
    CHOBJ = f'CH.OBJw(t, JW(i), OWc(off), LLw(len))'
    objs = []
    for f in x.fields:
        if f['kind'] == 'fix':
            objs.append(f['ft'].obj([f'VB.slot(t, Nat.add({f["k"] + j}n, i))' for j in range(f['ft'].W)]))
        else:
            objs.append(f'O.BSome{{{CHOBJ}, O.BNone{{}}}}' if x.boxed else CHOBJ)
    OBJ = f'{Tn}{{' + ', '.join(objs) + '}'
    RHS = '(BF(t, n), OBJw(t, i, off, len))'
    TY = f'B.Buf & {Tn}'
    w(f'def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> {Tn}: {OBJ}')
    w('')
    w(f'def rd_go({CW}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}}, +hc: {{{CHK_child} == True{{}} : Bool}})')
    w(f'    -> {{{Tn}_read(BF(t, n), off, len) == {RHS} : {TY}}}:')
    w(f'  +hH = hHi({CWA}, ha)')
    w(f'  %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, {4 * po})), (VF.BF(t, n), SPOw(t, i)),')
    w(f'      VF.rd32a(d, t, n, U32.add(off, {4 * po}), Nat.add({po}n, i), eoc({CWA}, {po}n, {4 * po}, {{==}}, {{==}}, ha),')
    w(f'        VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {{==}})), hiw({CWA}, {po}n, {{==}}, ha), pf)) :')
    w(f'    {{{Tn}_rd0(off, len, _) == {RHS} : {TY}}}')

    def read_term(f, o):
        if f['kind'] == 'fix':
            ft = f['ft']
            return f'T.{ft.p}_read(BF(t, n), U32.add(off, {f["c"]}), {ft.size})'
        return f'T.{x.rdf}_read(BF(t, n), U32.add(off, {o}), U32.sub(len, {o}))'
    w(f'  %Equal.sym(U32, SPOw(t, i), {FS}, epo) :')
    w(f'    {{{Tn}_rd1(off, len, _, {read_term(x.fields[0], "_")}) == {RHS} : {TY}}}')
    for j, f in enumerate(x.fields):
        args = ', '.join(['off', 'len', f'{FS}'] + objs[:j])
        if f['kind'] == 'fix':
            ft = f['ft']
            k = f['k']
            hb = f'FD.nat__le_trans(Nat.add({ft.W}n, Nat.add({k}n, i)), Nat.add({H}n, i), VB.pw(d), Order.left_below_sum({H - ft.W - k}n, Nat.add({ft.W}n, Nat.add({k}n, i))), hH)'
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {read_term(f, FS)}, (BF(t, n), {objs[j]}),')
            w(f'      VT.rd_{ft.p}(d, t, n, U32.add(off, {f["c"]}), Nat.add({k}n, i), eoc({CWA}, {k}n, {f["c"]}, {{==}}, {{==}}, ha), FD.nat__lt_trans(d, 28n, 29n, hd, {{==}}), pf, {hb})) :')
            w(f'    {{{Tn}_rd{j + 1}({args}, _) == {RHS} : {TY}}}')
        else:
            base = x.rdf[:-3] if x.boxed else x.rdf
            cur = f'T.{base}_read(BF(t, n), OWc(off), LLw(len))'
            w(f'  %Equal.sym(B.Buf & {chrep}, {cur}, (BF(t, n), {CHOBJ}),')
            w(f'      CH.readw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), pf, hc)) :')
            hole = f'T.{x.rdf}_rd(_)' if x.boxed else '_'
            w(f'    {{{Tn}_rd{j + 1}({args}, {hole}) == {RHS} : {TY}}}')
    w('  {==}')
    w(f'''
# The reader on the window, when the checks hold.
def readw({CW}, +hchk: {{CHKw(t, i, off, len) == True{{}} : Bool}}) -> {{{Tn}_read(BF(t, n), off, len) == {RHS} : {TY}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, i), {FS})
  +c = {CHK_child}
  rd_go({CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, i), {FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))
''')
    # ---- the spec side ----
    nodes = VL.field_nodes(g, x, lambda k: f'VB.slot(t, Nat.add({k}n, i))')
    vi = [f['kind'] for f in x.fields].index('var')
    Y = 'VR.WB(t, JW(i), U32.to_nat(LLw(len)))'
    vals, schs, parts = [], [], []
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append('CH.VALw(t, JW(i), LLw(len))')
            schs.append(CSCH)
            parts.append(f'S.Variable{{{Y}}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if x.fields[i]['kind'] == 'fix':
            return (f'F.cat_fixed(Codec.parts({vals[i]}, {schs[i]}), F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.cat_var(Codec.parts({vals[i]}, {schs[i]}), {Y}, Codec.parts({items(i + 1)}, {chain(i + 1)}), {rest}, '
                f'CH.specw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), pf, hc), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(FS)]
    HDR = '[' + ', '.join(hdr) + ']'
    HDRh = '[' + ', '.join(h if k != po else '_' for k, h in enumerate(hdr)) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {Y})'
    WBL = 'VR.WB(t, i, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    s = 'FD.array__slots(U32, t)'
    w(f'''def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: S.Sequence{{{items(0)}}}

def fitw({CW}, {HA}) -> {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {Y}))) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {Y}), U32.to_nat(LLw(len)), VR.lenWB(d, t, JW(i), U32.to_nat(LLw(len)), pf, hwc({CWA}, ha))) : {{N.fits(4n, Nat.add({FS}n, _)) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)) : {{N.fits(4n, _) == True{{}} : Bool}}
  VFT.fits4(2n+d, U32.to_nat(len), hlen(d, i, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}))

# The window's bytes: the header words' limbs, then the child's window.
def limw({CW}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}})
    -> {{List.append(&2, U32, F.limbs({HDR}), {Y}) == {WBL} : +List<U32>}}:
  +hh = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add({H}n, i), z) == True{{}} : Bool}}, VB.pw(d), VB.len({s}), Equal.sym(Nat, VB.len({s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hHi({CWA}, ha))
  %enF(len, ha) : {{List.append(&2, U32, F.limbs({HDR}), {Y}) == VR.WB(t, i, _) : +List<U32>}}
  %Equal.sym(+List<U32>, VR.WB(t, i, Nat.add(A.quad({H}n), U32.to_nat(LLw(len)))), List.append(&2, U32, F.limbs(VF.app(VF.wpre({H}n, i, {s}), [])), VR.WB(t, Nat.add({H}n, i), U32.to_nat(LLw(len)))),
      VWN.splitW(t, i, {H}n, U32.to_nat(LLw(len)), hh)) :
    {{List.append(&2, U32, F.limbs({HDR}), {Y}) == _ : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({HDRh}), {Y}) == List.append(&2, U32, F.limbs(VF.app(VF.wpre({H}n, i, {s}), [])), {Y}) : +List<U32>}}
  {{==}}

def specg({CW}, {HA}, +epo: {{SPOw(t, i) == {FS} : U32}}, +hc: {{{CHK_child} == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}:
  +dom = VR.domWB(t, JW(i), U32.to_nat(LLw(len)))
  %limw({CWA}, ha, epo) :
    {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  %Equal.sym({MP}, Codec.parts({items(0)}, {chain(0)}), Some{{[{', '.join(parts)}]}},
      {cat(0)}) :
    {{Codec.aggregate(_, None{{}}) == Some{{[S.Variable{{List.append(&2, U32, F.limbs({HDR}), {Y})}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(VS.fpv({PRE}, {Y}, {POST})), Some{{{ENCR}}}, VBC.enc_fpvb({PRE}, {Y}, {POST}, dom, fitw({CWA}, ha))) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{List.append(&2, U32, F.limbs({HDR}), {Y})}}]}} : {MP}}}
  {{==}}

# The spec parts of the value: one variable part, the window's bytes.
def specw({CW}, +hchk: {{CHKw(t, i, off, len) == True{{}} : Bool}}) -> {{Codec.parts(VALw(t, i, len), Spec.{n}()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, i), {FS})
  +c = {CHK_child}
  specg({CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, i), {FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))
''')
    w(inv_text(x, CW, CWA, CHK_child, CSCH, kids, Y, WBL))
    return '\n'.join(L) + '\n'


def inv_text(x, CW, CWA, CHK_child, CSCH, kids, Y, WBL):
    n, FS, H, po = x.n, x.FS, x.H, x.po
    P = 4 * po
    m = len(x.fields)
    vi = [f['kind'] for f in x.fields].index('var')
    L = []
    w = L.append
    MP = 'Maybe<&2, +List<S.Part>>'
    GOAL = '{CHKw(t, i, off, len) == True{} : Bool}'

    def absurd():
        return f'Empty.absurd({GOAL}, FD.logic__none_some(+List<S.Part>, [S.Variable{{{WBL}}}], e))'

    def match_value(var, keep, body):
        out = [f'  match {var}:']
        for c, args in VALUE_CTORS:
            if c == keep[0]:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in keep[1]) + f'}}: {body}')
            else:
                out.append(f'    case S.{c}{{' + ', '.join('+' + a for a in args) + f'}}: {absurd()}')
        return out

    def prefix(i):
        decl, args, parts = [], [], []
        for j, f in enumerate(x.fields[:i]):
            if f['kind'] == 'fix':
                decl += [f'+xs{j}: +List<U32>', f'+lx{j}: {{List.length(&2, U32, xs{j}) == {f["ft"].size}n : Nat}}']
                args += [f'xs{j}', f'lx{j}']
                parts.append(f'S.Fixed{{xs{j}}}')
            else:
                decl += ['+hv: S.Value', '+ys: +List<U32>', f'+eh: {{Codec.parts(hv, {CSCH}) == Some{{[S.Variable{{ys}}]}} : {MP}}}']
                args += ['hv', 'ys', 'eh']
                parts.append('S.Variable{ys}')
        return decl, args, parts

    def CC(parts, X):
        for pp in reversed(parts):
            X = f'Codec.concatenate(Some{{[{pp}]}}, {X})'
        return X

    def chain(i):
        return 'S.End{}' if i == m else f'S.Chain{{Spec.{kids[i]}(), {chain(i + 1)}}}'

    def E(parts, X):
        return f'{{Codec.aggregate({CC(parts, X)}, None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}'

    def sig(name, decl, extra):
        return f'def {name}({CW}, ' + ', '.join(decl + extra) + f') -> {GOAL}:'

    pre = list(range(vi))
    post = list(range(vi + 1, m))
    PRE = '[' + ', '.join(f'xs{j}' for j in pre) + ']'
    POST = '[' + ', '.join(f'xs{j}' for j in post) + ']'
    decl_m, args_m, parts_m = prefix(m)
    Pz = sum(x.fields[j]['ft'].size for j in pre)
    Qz = sum(x.fields[j]['ft'].size for j in post)
    ALL = ', '.join(args_m)
    OUT = f'VRJ.OUT({PRE}, ys, {POST})'

    def lens_eq(name, idx, total):
        w(f'def {name}(' + ', '.join(decl_m) + f') -> {{VRJ.lens([' + ', '.join(f'xs{j}' for j in idx) + f']) == {total}n : Nat}}:')
        cur = [f'List.length(&2, U32, xs{j})' for j in idx]
        for a, j in enumerate(idx):
            def term(c):
                tt = '0n'
                for q in reversed(c):
                    tt = f'Nat.add({q}, {tt})'
                return tt
            mot = cur[:a] + ['_'] + cur[a + 1:]
            w(f'  %Equal.sym(Nat, List.length(&2, U32, xs{j}), {x.fields[j]["ft"].size}n, lx{j}) : {{{term(mot)} == {total}n : Nat}}')
            cur[a] = f'{x.fields[j]["ft"].size}n'
        w('  {==}')
        w('')
    w('# ---- every value whose spec parts are the window\'s bytes passes the checks ------------------')
    w('')
    lens_eq('eP', pre, Pz)
    lens_eq('eQ', post, Qz)
    w(f'def fz_eq(' + ', '.join(decl_m) + f') -> {{VRJ.FZ({PRE}, {POST}) == {FS}n : Nat}}:')
    w(f'  %Equal.sym(Nat, VRJ.lens({PRE}), {Pz}n, eP({ALL})) : {{Nat.add(_, 4n+VRJ.lens({POST})) == {FS}n : Nat}}')
    w(f'  %Equal.sym(Nat, VRJ.lens({POST}), {Qz}n, eQ({ALL})) : {{Nat.add({Pz}n, 4n+_) == {FS}n : Nat}}')
    w('  {==}')
    w('')
    w(f'def f_off(' + ', '.join(decl_m) + f') -> {{VS.bt(4n, VS.bdr({P}n, {OUT})) == N.digits(4n, {FS}n) : +List<U32>}}:')
    w(f'  %eP({ALL}) : {{VS.bt(4n, VS.bdr(_, {OUT})) == N.digits(4n, Nat.add(_, 4n+{Qz}n)) : +List<U32>}}')
    w(f'  %eQ({ALL}) : {{VS.bt(4n, VS.bdr(VRJ.lens({PRE}), {OUT})) == N.digits(4n, Nat.add(VRJ.lens({PRE}), 4n+_)) : +List<U32>}}')
    w(f'  VRJ.out_off({PRE}, ys, {POST})')
    w('')
    w(f'def f_len(' + ', '.join(decl_m) + f') -> {{List.length(&2, U32, {OUT}) == Nat.add({FS}n, List.length(&2, U32, ys)) : Nat}}:')
    w(f'  %fz_eq({ALL}) : {{List.length(&2, U32, {OUT}) == Nat.add(_, List.length(&2, U32, ys)) : Nat}}')
    w(f'  VRJ.out_len({PRE}, ys, {POST})')
    w('')
    w(f'def f_tail(' + ', '.join(decl_m) + f') -> {{VS.bdr({FS}n, {OUT}) == ys : +List<U32>}}:')
    w(f'  %fz_eq({ALL}) : {{VS.bdr(_, {OUT}) == ys : +List<U32>}}')
    w(f'  VBC.out_tail({PRE}, ys, {POST})')
    w('')
    RF = FS - P - 4
    w(f'''def u32le(+a: U32, +b: U32, +h: {{Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{{}} : Bool}}) -> {{U32.is_le(a, b) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def subc(+n: U32, +k: U32, +y: Nat, +e: {{U32.to_nat(n) == Nat.add(U32.to_nat(k), y) : Nat}}) -> {{U32.to_nat(U32.sub(n, k)) == y : Nat}}:
  +le = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(k), z) == True{{}} : Bool}}, Nat.add(U32.to_nat(k), y), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e), FD.nat__le_add_right(U32.to_nat(k), y))
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, k)), Nat.sub(U32.to_nat(n), U32.to_nat(k)), FD.u32__sub_nat(n, k, le)) : {{_ == y : Nat}}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e) : {{Nat.sub(_, U32.to_nat(k)) == y : Nat}}
  FD.nat__add_sub_cancel(U32.to_nat(k), y)

def chk_t(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, {{HA_}}, +epo: {{SPOw(t, i) == {FS} : U32}}, +hc: {{{CHK_child} == True{{}} : Bool}})
    -> {GOAL}:
  %Equal.sym(Bool, U32.is_le({FS}, len), True{{}}, ha) : {{chk3(_, U32.is_eq(SPOw(t, i), {FS}), {CHK_child}) == True{{}} : Bool}}
  %Equal.sym(U32, SPOw(t, i), {FS}, epo) : {{chk3(True{{}}, U32.is_eq(_, {FS}), {CHK_child}) == True{{}} : Bool}}
  hc

def contra({CW}, {', '.join(decl_m)}, +eo2: {{{OUT} == {WBL} : +List<U32>}}) -> {GOAL}:
  +lY = List.length(&2, U32, ys)
  +elen = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, {WBL}), Nat.add({FS}n, lY), Equal.sym(Nat, List.length(&2, U32, {WBL}), U32.to_nat(len), VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, {WBL}), List.length(&2, U32, {OUT}), Nat.add({FS}n, lY),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), {WBL}, {OUT}, Equal.sym(+List<U32>, {OUT}, {WBL}, eo2)), f_len({ALL})))
  +hF = FD.logic__subst(Nat, z => {{Nat.is_le({FS}n, z) == True{{}} : Bool}}, Nat.add({FS}n, lY), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add({FS}n, lY), elen), FD.nat__le_add_right({FS}n, lY))
  +ha = u32le({FS}, len, hF)
  +eLL = subc(len, {FS}, lY, elen)
  +W2 = VR.WB(t, i, Nat.add({FS}n, lY))
  +eW = Equal.cong(Nat, +List<U32>, z => VR.WB(t, i, z), U32.to_nat(len), Nat.add({FS}n, lY), elen)
  +eo3 = Equal.trans(+List<U32>, {OUT}, {WBL}, W2, eo2, eW)
  # the offset word
  +hw2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({FS}n, lY), elen, hw)
  +b0 = VWN.byteW(d, t, i, {po}n, Nat.add({RF}n, lY), pf, hw2)
  +epo = VN.wordc(SPOw(t, i), {FS}, Equal.trans(+List<U32>, F.limbs([SPOw(t, i)]), VS.bt(4n, VS.bdr({P}n, W2)), N.digits(4n, {FS}n),
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr({P}n, W2)), F.limbs([SPOw(t, i)]), b0),
    Equal.trans(+List<U32>, VS.bt(4n, VS.bdr({P}n, W2)), VS.bt(4n, VS.bdr({P}n, {OUT})), N.digits(4n, {FS}n),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr({P}n, z)), W2, {OUT}, Equal.sym(+List<U32>, {OUT}, W2, eo3)), f_off({ALL}))))
  # the child's window
  +ty = Equal.trans(+List<U32>, ys, VS.bdr({FS}n, {OUT}), VR.WB(t, JW(i), U32.to_nat(LLw(len))),
    Equal.sym(+List<U32>, VS.bdr({FS}n, {OUT}), ys, f_tail({ALL})),
    Equal.trans(+List<U32>, VS.bdr({FS}n, {OUT}), VS.bdr({FS}n, W2), VR.WB(t, JW(i), U32.to_nat(LLw(len))),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr({FS}n, z), {OUT}, W2, eo3),
      Equal.trans(+List<U32>, VS.bdr({FS}n, W2), VR.WB(t, JW(i), lY), VR.WB(t, JW(i), U32.to_nat(LLw(len))), VWN.tailW(t, i, {H}n, lY),
        Equal.cong(Nat, +List<U32>, z => VR.WB(t, JW(i), z), lY, U32.to_nat(LLw(len)), Equal.sym(Nat, U32.to_nat(LLw(len)), lY, eLL)))))
  +eh2 = FD.logic__subst(+List<U32>, z => {{Codec.parts(hv, {CSCH}) == Some{{[S.Variable{{z}}]}} : {MP}}}, ys, VR.WB(t, JW(i), U32.to_nat(LLw(len))), ty, eh)
  +hc = CH.invw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), pf, hv, eh2)
  chk_t(t, i, off, len, ha, epo, hc)
''')
    PLIST = '[' + ', '.join(parts_m) + ']'
    b5 = f'Bool.and(Layout.bytes_valid({PLIST}), N.fits(4n, Nat.add(Layout.fixed_size({PLIST}), List.length(&2, U32, Layout.payloads({PLIST})))))'
    w(sig('fin', decl_m, ['+b5: Bool', f'+e: {{Codec.one(SP.optional(b5, {OUT}), None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}']))
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w(f'    case True{{}}: contra({CWA}, {ALL}, var_inj({OUT}, {WBL}, e))')
    w('')
    w(sig(f'st{m}', decl_m, ['+items: S.Value', '+e: ' + E(parts_m, 'Codec.parts(items, S.End{})')]))
    L.extend(match_value('items', ('EmptyItems', []), f'fin({CWA}, {ALL}, {b5}, e)'))
    w('')
    for i in reversed(range(m)):
        f = x.fields[i]
        decl, args, parts = prefix(i)
        A = ', '.join(args + [''])
        sch = f'Spec.{kids[i]}()'
        nxt = f'Codec.parts(r, {chain(i + 1)})'
        if f['kind'] == 'fix':
            z = f['ft'].size
            w(sig(f'fp{i}', decl, ['+ps: +List<S.Part>', f'hf: DF.single(Some{{{z}n}}, ps)', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            w('  match ps:')
            w(f'    case Nil{{}}: Empty.absurd({GOAL}, hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: st{i + 1}({CWA}, {A}xs, Equal.sym(Nat, {z}n, List.length(&2, U32, xs), FD.logic__some_inj(Nat, {z}n, List.length(&2, U32, xs), hf)), r, e)')
            w(f'    case Con{{S.Variable{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, {z}n, Equal.sym(Maybe<&2, Nat>, Some{{{z}n}}, None{{}}, hf)))')
            w(f'    case Con{{S.Fixed{{+xs}}, Con{{+h2, +t2}}}}: Empty.absurd({GOAL}, hf)')
            w(f'    case Con{{S.Variable{{+xs}}, Con{{+h2, +t2}}}}: Empty.absurd({GOAL}, hf)')
            w('')
            w(sig(f'fm{i}', decl, ['+mm: Maybe<&2, +List<S.Part>>', f'hf: DF.single_result(Some{{{z}n}}, mm)', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: fp{i}({CWA}, {A}ps, hf, r, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+r: S.Value', '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  fm{i}({CWA}, {A}Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), r, e)')
            w('')
        else:
            w(sig(f'vp{i}', decl, ['+h: S.Value', '+ps: +List<S.Part>', 'hf: DF.single(None{}, ps)',
                                   f'+em: {{Codec.parts(h, {CSCH}) == Some{{ps}} : {MP}}}', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(Some{{ps}}, {nxt})')]))
            w('  match ps:')
            w(f'    case Nil{{}}: Empty.absurd({GOAL}, hf)')
            w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
            w(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{i + 1}({CWA}, {A}h, ys, em, r, e)')
            w(f'    case Con{{S.Fixed{{+xs}}, Con{{+h2, +t2}}}}: Empty.absurd({GOAL}, hf)')
            w(f'    case Con{{S.Variable{{+xs}}, Con{{+h2, +t2}}}}: Empty.absurd({GOAL}, hf)')
            w('')
            w(sig(f'vm{i}', decl, ['+h: S.Value', '+mm: Maybe<&2, +List<S.Part>>', 'hf: DF.single_result(None{}, mm)',
                                   f'+em: {{Codec.parts(h, {CSCH}) == mm : {MP}}}', '+r: S.Value',
                                   '+e: ' + E(parts, f'Codec.concatenate(mm, {nxt})')]))
            w('  match mm:')
            w(f'    case None{{}}: {absurd()}')
            w(f'    case Some{{+ps}}: vp{i}({CWA}, {A}h, ps, hf, em, r, e)')
            w('')
            w(sig(f'fd{i}', decl, ['+h: S.Value', '+r: S.Value', '+e: ' + E(parts, f'Codec.concatenate(Codec.parts(h, {sch}), {nxt})')]))
            w(f'  vm{i}({CWA}, {A}h, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), {{==}}, r, e)')
            w('')
        w(sig(f'st{i}', decl, ['+items: S.Value', '+e: ' + E(parts, f'Codec.parts(items, {chain(i)})')]))
        L.extend(match_value('items', ('Items', ['h', 'r']), f'fd{i}({CWA}, {A}h, r, e)'))
        w('')
    w(f'# Every value whose spec parts are the window\'s bytes passes the checks.')
    w(f'def invw({CW}, +v: S.Value, +e: {{Codec.parts(v, Spec.{n}()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    L.extend(match_value('v', ('Sequence', ['items']), f'st0({CWA}, items, e)'))
    return '\n'.join(L).replace('{HA_}', f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}')


TOP = r"""
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: W.CHKw(t, 0n, 0, n)
def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> @Tn: W.OBJw(t, 0n, 0, n)
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: W.VALw(t, 0n, n)

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {@Tn_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  W.ok_evalw(d, t, n, 0n, 0, n, {==}, hd, hn, pf)

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {@Tn_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @Tn_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {@Tn_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {@Tn_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(B.Buf & @Tn, @Tn_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)), W.readw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, hchk)) :
    {@Tn_some(_) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
  {==}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  {@Tn_decode(BF(t, n), n) == (BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @Tn_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {@Tn_built(n, _) == (BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {@Tn_built(n, (BF(t, n), _)) == (BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of VAL(t, n).
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.@N(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VAL(t, n), Spec.@N()), Some{[S.Variable{VW(t, n)}]}, W.specw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, hchk)) :
    {Codec.bytes(_) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  {==}

def agg3(+r: Maybe<&2, +List<U32>>, +bs: +List<U32>, +e: {Codec.bytes(Codec.one(r, None{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.one(r, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}:
  match r:
    case None{}: Empty.absurd({Codec.one(None{}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ys}: Equal.cong(+List<U32>, Maybe<&2, +List<S.Part>>, z => Some{[S.Variable{z}]}, ys, bs, FD.logic__some_inj(+List<U32>, ys, bs, e))

def agg2(+ps: +List<S.Part>, +r: Maybe<&2, +List<U32>>, +er: {Layout.encoding(ps) == r : Maybe<&2, +List<U32>>}, +bs: +List<U32>,
    +e: {Codec.bytes(Codec.one(r, None{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.aggregate(Some{ps}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(ps), r, er) : {Codec.one(_, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}
  agg3(r, bs, e)

# A variable-size container's bytes are its one variable part.
def agg_var(+m: Maybe<&2, +List<S.Part>>, +bs: +List<U32>, +e: {Codec.bytes(Codec.aggregate(m, None{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.aggregate(m, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}:
  match m:
    case None{}: Empty.absurd({Codec.aggregate(None{}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ps}: agg2(ps, Layout.encoding(ps), {==}, bs, e)

def rej_v(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHK(t, n) == False{} : Bool},
    +v: S.Value, +e: {Codec.encoding_for_legal_type(Spec.@N(), v) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}) -> Empty:
  match v:
    case S.Sequence{+items}:
      FD.logic__true_false(Equal.trans(Bool, True{}, CHK(t, n), False{},
        Equal.sym(Bool, CHK(t, n), True{}, W.invw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, S.Sequence{items}, agg_var(Codec.parts(items, @CHAIN), VW(t, n), e))), hchk))
@ABSURD
# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.@N(), VW(t, n))
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => rej_v(d, t, n, pf, hd, hn, hchk, v, e)
"""


def top_text(x, wmod, kids):
    chain = 'S.End{}'
    for k in reversed(kids):
        chain = f'S.Chain{{Spec.{k}(), {chain}}}'
    ab = []
    for c, args in VALUE_CTORS:
        if c == 'Sequence':
            continue
        pat = f'S.{c}{{' + ', '.join('+' + a for a in args) + '}'
        ab.append(f'    case {pat}: FD.logic__none_some(+List<U32>, VW(t, n), e)')
    body = TOP.replace('@ABSURD', '\n'.join(ab) + '\n').replace('@CHAIN', chain).replace('@Tn', f'T.{x.n}').replace('@N(', f'{x.n}(')
    L = HEAD + [f'import ./{wmod} as W', '', '# GENERATED by codegen/var_win.py. Do not edit.',
                f'# {x.n}: the codec laws of the whole buffer, from its window laws ({wmod}).', '']
    return '\n'.join(L) + body


def unique_text(x, top):
    return VL.unique_text(None, x.n, top).replace('GENERATED by codegen/var_laws.py', 'GENERATED by codegen/var_win.py').replace(
        'for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}', 'for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}')


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
    src = (ROOT / 'types/fulu_obj.bend').read_text()
    mods = {}
    for b_n in list(out):
        pass
    for n in WIN:
        kids, _ = VL.spec_schemas(n)
        x = WName(g, n, names[n], src, kids)
        vf = x.var
        ft = vf['t']
        if ft.kind == 'bitlist':
            m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[vf['sk']])
            b = Bits(ft.size, g.shape(ft).p, f'Spec.{vf["sk"]}()', m.group(1))
            chf, chrep, big = bits_fname(b), 'O.Bits', big_bits(b)
        else:
            chf, chrep, big = mods[ft.name]
        big = big or False
        pre = 'big_' if big else ''
        wf = ROOT / f'proofs/obj/{pre}var_win_{n}.bend'
        mods[n] = (wf, f'T.{n}', big)
        if no_big and big:
            continue
        out[wf] = cont_text(g, x, None, chf.name, f'Spec.{vf["sk"]}()', chrep, None)
        if n not in VL.BITC:
            tf = ROOT / f'proofs/obj/{pre}var_win_{n}_top.bend'
            out[tf] = top_text(x, wf.name, kids)
            out[ROOT / f'proofs/obj/{pre}var_win_{n}_unique.bend'] = unique_text(x, tf.name)
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
