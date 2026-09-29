#!/usr/bin/env python3
"""Window laws for nesting: a type read at a symbolic word-aligned window
(byte offset off = 4 i, length len) of a buffer.

    python3 codegen/var_win.py [--check]

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
import zeros_dispatch as ZD  # noqa: E402
import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

ROOT = VL.ROOT
# Containers, in dependency order (children first).
WIN = ['Attestation', 'AggregateAndProof', 'SignedAggregateAndProof']
# Containers with a byte-offset window module (proofs/obj/vua_win.bend's interface).
WINX = ['PendingAttestation', 'Attestation', 'DataColumnsByRootIdentifier', 'IndexedAttestation']


def ceil_log2(x):
    return max(0, (x - 1).bit_length())


# ---- the deep laws (any tree depth d < 31): the word-aligned windows carry hw32, the window's end below 2^32
HWI = '{Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}'
HW32I = '{Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool}'


def deep_i(text):
    import deep
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)').replace('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd')
    return deep.thread(text, HWI, HW32I)


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
  VR.eXNw(off, i, len, M1(len), eo, hw32, e1)

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

# 31 + len <= 2^@KB: the checks bound the length (whatever the buffer's depth).
def hyB(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), VB.pw(@KBn)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(len), Nat.add(31n, @BMAXn), VB.pw(@KBn), Order.add_left(31n, U32.to_nat(len), @BMAXn, hb), {==})

def hWZ(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(@Kn)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
    VC.wz_le(len, @KBn, {==}, hyB(len, hb)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(len), @YMAXn, Order.add_left(31n, U32.to_nat(len), @BMAXn, hb))),
      {==}))

def hdzK(+d: Nat, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hL: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(len), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(len), @Kn, hWZ(len, hb))

# The list storage has room for the words.
def hrgB(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(len), 0n), VB.pw(VLS.DZ(len))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), FD.nat__add_zero(VC.NW(len))) : {Nat.is_le(_, VB.pw(VLS.DZ(len))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VLS.DZ(len)), O.pow2n(VLS.DZ(len)), VD.s_pow2_eq(VLS.DZ(len))) : {Nat.is_le(VC.NW(len), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(len), U32.to_nat(VC.WZ(len)), O.pow2n(VLS.DZ(len)), VC.nw_le_wz(len, @KBn, {==}, hyB(len, hb)), VD.wd_cover(VC.WZ(len), @Kn, {==}, hWZ(len, hb)))
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
  +hb = hB(t, off, len, e1, cC(t, off, len, h1, cB(t, off, len, h1)))
  +hz = hdzK(d, len, hd, hL, hb)
  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)
  %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)), VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, hd31), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
    {O.bits_from(len, off, _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwHB(d, len, i, @KBn, {==}, hyB(len, hb), hw), hrgB(len, hb))) :
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


# the word-aligned bit-list window as it was (d < 28): the byte-offset windows are derived from it
# (bitsx_text) until they carry the deep bounds too
BITS0 = r"""
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
    return ZD.zeros_at_text(KK)


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
    return ROOT / f'proofs/obj/{"" if big_bits(b) else ""}var_win_{b.name}.bend'


def bits_text(b):
    body = BITS.replace('@ZEROS', '\n' + zeros_at_text(b.K))
    body = body.replace('@ABSURDV', absurd_cases('BitsValue', '{CHKw(t, i, off, len) == True{} : Bool}'))
    for k, v in [('@BMAXn', f'{b.BMAX}n'), ('@YMAXn', f'{b.YMAX}n'), ('@Cn', f'{b.C}n'), ('@Kn', f'{b.K}n'), ('@KBn', f'{ceil_log2(b.YMAX)}n'), ('@LIMN', b.limn),
                 ('@SCH', b.sch), ('@N', str(b.N)), ('@p_', f'{b.p}_')]:
        body = body.replace(k, v)
    L = HEAD + ['', '# GENERATED by codegen/var_win.py. Do not edit.',
                f'# BitList[{b.N}] at a word-aligned window: the window interface of codegen/var_win.py.', '']
    return deep_i('\n'.join(L) + COMMON + body)


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
  VF.off_add_lt(off, c, i, k, eo, ec,
    FD.nat__le_lt_trans(A.quad(Nat.add(k, i)), Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n),
      winb(k, i, len, Nat.add(A.quad(i), U32.to_nat(len)), FD.nat__le_trans(A.quad(k), {FS}n, U32.to_nat(len), hkF, leF(len, ha)), FD.nat__le_refl(Nat.add(A.quad(i), U32.to_nat(len)))), hw32))

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

# ... and ends below 2^32.
def hwc32({CW}, {HA}) -> {{Nat.is_lt(Nat.add(A.quad(JW(i)), U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{{}} : Bool}}:
  %Equal.sym(Nat, A.quad(Nat.add({H}n, i)), Nat.add(A.quad({H}n), A.quad(i)), VF.quad_add({H}n, i)) : {{Nat.is_lt(Nat.add(_, U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{{}} : Bool}}
  %FD.nat__add_comm(A.quad(i), A.quad({H}n)) : {{Nat.is_lt(Nat.add(_, U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), {FS}n), U32.to_nat(LLw(len))), Nat.add(A.quad(i), Nat.add({FS}n, U32.to_nat(LLw(len)))), FD.nat__add_assoc(A.quad(i), {FS}n, U32.to_nat(LLw(len)))) :
    {{Nat.is_lt(_, FD.spec_common__pow2(32n)) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)) : {{Nat.is_lt(Nat.add(A.quad(i), _), FD.spec_common__pow2(32n)) == True{{}} : Bool}}
  hw32

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
          CH.ok_evalw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf)) :
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
            w(f'      VT.rdd_{ft.p}(d, t, n, U32.add(off, {f["c"]}), Nat.add({k}n, i), eoc({CWA}, {k}n, {f["c"]}, {{==}}, {{==}}, ha), hd, pf, {hb})) :')
            w(f'    {{{Tn}_rd{j + 1}({args}, _) == {RHS} : {TY}}}')
        else:
            base = x.rdf[:-3] if x.boxed else x.rdf
            cur = f'T.{base}_read(BF(t, n), OWc(off), LLw(len))'
            w(f'  %Equal.sym(B.Buf & {chrep}, {cur}, (BF(t, n), {CHOBJ}),')
            w(f'      CH.readw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc)) :')
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
            return (f'VS.chain_fixed({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, {nodes[i]["proof"]}, {cat(i + 1)})')
        return (f'VS.chain_var({vals[i]}, {items(i + 1)}, {schs[i]}, {chain(i + 1)}, {Y}, {rest}, '
                f'CH.specw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc), {cat(i + 1)})')
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
  VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw32))

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
    return deep_i('\n'.join(L) + '\n')


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
  +hc = CH.invw(d, t, n, JW(i), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hv, eh2)
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
  W.ok_evalw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf)

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
  %Equal.sym(B.Buf & @Tn, @Tn_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)), W.readw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, hchk)) :
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
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.@N(), VAL(t, n)) : {_ == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VAL(t, n), Spec.@N()), Some{[S.Variable{VW(t, n)}]}, W.specw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, hchk)) :
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
        Equal.sym(Bool, CHK(t, n), True{}, W.invw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, S.Sequence{items}, agg_var(Codec.parts(items, @CHAIN), VW(t, n), e))), hchk))
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


def top_text(x, wmod, kids, deep=False):
    """deep: the window module carries the deep bounds (d < 31, hw32); other generators' windows are d < 28."""
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
    if not deep:
        return '\n'.join(L) + body.replace('Nat.is_lt(d, 31n)', 'Nat.is_lt(d, 28n)').replace(', hd, hn, VB.u32_lt(n), pf', ', hd, hn, pf')
    return deep_i('\n'.join(L) + body)


def unique_text(x, top):
    return VL.unique_text(None, x.n, top, 31).replace('GENERATED by codegen/var_laws.py', 'GENERATED by codegen/var_win.py')


# ---- byte-offset windows (the interface of proofs/obj/vua_win.bend) ---------------------------

HEADX = HEAD + ['import ./vua_win.bend as UW', 'import ./vua_ct.bend as UCT']

COMMONX = r"""
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)

def hlen(+d: Nat, +x: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw)

# The payload of a one-part variable list.
def varpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Variable{+xs}, t}: xs
    case _: []

def var_inj(+a: +List<U32>, +b: +List<U32>, +e: {Some{[S.Variable{a}]} == Some{[S.Variable{b}]} : Maybe<&2, +List<S.Part>>}) -> {a == b : +List<U32>}:
  Equal.cong(+List<S.Part>, +List<U32>, z => varpay(z), [S.Variable{a}], [S.Variable{b}], FD.logic__some_inj(+List<S.Part>, [S.Variable{a}], [S.Variable{b}], e))
"""


def to_bytes_window(s):
    """The word-aligned window text (index i, off = 4 i) at a byte position x."""
    for a, b in [
            ('+i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}', '+x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}'),
            ('Nat.add(A.quad(i), ', 'Nat.add(x, '),
            ('VR.eXN(d, off, i, ', 'UW.eXN(d, off, x, '),
            ('FD.nat__lt_add_left(M1(len), 1n+M1(len), A.quad(i), ', 'FD.nat__lt_add_left(M1(len), 1n+M1(len), x, '),
            ('VR.WB(t, i, ', 'UW.WX(t, x, '), ('VR.lastWB(d, t, i, ', 'UW.lastWX(d, t, x, '), ('VR.domWB(t, i, ', 'UW.domWX(t, x, '),
            ('VR.lenWB(d, t, i, ', 'UW.lenWX(d, t, x, '),
            ('+t: FD.array__Tree<U32>, +i: Nat, +off: U32', '+t: FD.array__Tree<U32>, +x: Nat, +off: U32'),
            ('(t, i, off, len', '(t, x, off, len'), ('(d, t, n, i, off, len', '(d, t, n, x, off, len'), ('(d, t, i, off, len', '(d, t, x, off, len'),
            ('(d, i, off, len', '(d, x, off, len'), ('hlen(d, i, len, hw)', 'hlen(d, x, len, hw)'),
            ('+t: FD.array__Tree<U32>, +i: Nat, +len: U32', '+t: FD.array__Tree<U32>, +x: Nat, +len: U32'), ('VALw(t, i, len)', 'VALw(t, x, len)')]:
        s = s.replace(a, b)
    return s


HWX = '{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}'
HW32X = '{Nat.is_lt(Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool}'
XIFACE = ['ok_evalw', 'readw', 'specw', 'invw']


def deep_x(text, names=XIFACE):
    """The byte-offset window text at any depth d < 31 (hw32: the window's end below 2^32), plus the
    interface as it was (d < 28, no hw32) under the old names for the callers not yet deep."""
    import deep
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)').replace('FD.nat__lt_trans(d, 28n, 31n, hd, {==})', 'hd')
    text = deep.thread(text, HWX, HW32X)
    return deep.compat(text, names, HWX, HW32X, 'Nat.add(x, U32.to_nat(len))')


def bitsx_deep_body(b):
    body = to_bytes_window(BITS).replace('VR.eXNw(off, i, ', 'UW.eXNw(off, x, ')
    obj_old = """def OBJw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}"""
    obj_new = """def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), NB(t, off, len)), NB(t, off, len)}"""
    assert obj_old in body, 'OBJw'
    body = body.replace(obj_old, obj_new)
    body = body.replace('OBJw(t, x, off, len)', 'OBJw(d, t, x, off, len)')
    ci_old = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwHB(d, len, i, @KBn, {==}, hyB(len, hb), hw), hrgB(len, hb))) :"""
    ci_new = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}),
      UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), @KBn, pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,
        UW.hsxB(d, off, x, len, eo, @KBn, {==}, hyB(len, hb), hw), hrgB(len, hb), {==}, hyB(len, hb))) :"""
    assert ci_old in body, 'copy_in'
    return body.replace(ci_old, ci_new)


def bitsx_text(b, deep=False):
    if deep:
        return deep_x(_bitsx_text(b, bitsx_deep_body(b)))
    return _bitsx_text(b, None)


def _bitsx_text(b, dbody):
    if dbody is not None:
        body = dbody
    else:
        body = _bitsx_old_body()
    body = body.replace('@ZEROS', '\n' + zeros_at_text(b.K))
    body = body.replace('@ABSURDV', absurd_cases('BitsValue', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    for k, v in [('@BMAXn', f'{b.BMAX}n'), ('@YMAXn', f'{b.YMAX}n'), ('@Cn', f'{b.C}n'), ('@KBn', f'{ceil_log2(b.YMAX)}n'), ('@Kn', f'{b.K}n'), ('@LIMN', b.limn),
                 ('@SCH', b.sch), ('@N', str(b.N)), ('@p_', f'{b.p}_')]:
        body = body.replace(k, v)
    assert 'A.quad(i)' not in body and 'VR.WB(' not in body, 'leftover word index'
    L = HEADX + ['', '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# BitList[{b.N}] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + COMMONX + body


def _bitsx_old_body():
    body = to_bytes_window(BITS0)
    obj_old = """def OBJw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}"""
    obj_new = """def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), NB(t, off, len)), NB(t, off, len)}"""
    assert obj_old in body, 'OBJw'
    body = body.replace(obj_old, obj_new)
    body = body.replace('OBJw(t, x, off, len)', 'OBJw(d, t, x, off, len)')
    ci_old = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwH(d, len, i, hd, hw), VLS.hrg(d, len, hd, hL))) :"""
    ci_new = """  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}),
      UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,
        UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))) :"""
    assert ci_old in body, 'copy_in'
    return body.replace(ci_old, ci_new)


def bitsx_fname(b):
    return ROOT / f'proofs/obj/{"" if big_bits(b) else ""}var_winx_{b.name}.bend'


def posx(c):
    return 'x' if c == 0 else f'{c}n+x'


def contx_text(g, x, chmod, CSCH, chrep):
    """Byte-offset window module of container x (the interface of
    proofs/obj/vua_win.bend) whose variable field is read by the child byte
    window module chmod (alias CH)."""
    n, FS, H, po = x.n, x.FS, x.H, x.po
    P = 4 * po
    Tn = f'T.{n}'
    CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
          '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
          '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    HA = f'+ha: {{U32.is_le({FS}, len) == True{{}} : Bool}}'
    PW = 'A.quad(VB.pw(d))'
    kids = [f['sk'] for f in x.fields]
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vua_fix.bend as VTX', f'import ./{chmod} as CH', 'import ../../proofs/decode_shape.bend as DS',
                 'import ../../proofs/decode_facts.bend as DF', '', '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# {n} at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    w = L.append
    w(COMMONX)
    CHK_child = 'CH.CHKw(t, JW(x), OWc(off), LLw(len))'
    w(f"""def SPOw(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, Nat.add({P}n, x))
def LLw(+len: U32) -> U32: U32.sub(len, {FS})
def OWc(+off: U32) -> U32: U32.add(off, {FS})
def JW(+x: Nat) -> Nat: Nat.add({FS}n, x)

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{{}}: False{{}}
    case True{{}}:
      match b:
        case False{{}}: False{{}}
        case True{{}}: c

def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  chk3(U32.is_le({FS}, len), U32.is_eq(SPOw(t, x), {FS}), {CHK_child})

def leF(+len: U32, {HA}) -> {{Nat.is_le({FS}n, U32.to_nat(len)) == True{{}} : Bool}}:
  FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, U32.is_le({FS}, len), Nat.is_le({FS}n, U32.to_nat(len)), VU.le_u32({FS}, len), ha)

def enF(+len: U32, {HA}) -> {{Nat.add({FS}n, U32.to_nat(LLw(len))) == U32.to_nat(len) : Nat}}:
  %Equal.sym(Nat, U32.to_nat(LLw(len)), Nat.sub(U32.to_nat(len), {FS}n), FD.u32__sub_nat(len, {FS}, leF(len, ha))) : {{Nat.add({FS}n, _) == U32.to_nat(len) : Nat}}
  FD.nat__sub_add(U32.to_nat(len), {FS}n, leF(len, ha))

# off + c at position c + x, for c <= {FS}.
def eoc({CW}, +c: U32, +k: Nat, +ec: {{U32.to_nat(c) == k : Nat}}, +hkF: {{Nat.is_le(k, {FS}n) == True{{}} : Bool}}, {HA})
    -> {{U32.to_nat(U32.add(off, c)) == Nat.add(k, x) : Nat}}:
  +hk = FD.nat__le_trans(k, {FS}n, U32.to_nat(len), hkF, leF(len, ha))
  +h = FD.nat__le_lt_trans(Nat.add(k, x), Nat.add(U32.to_nat(len), x), FD.spec_common__pow2(32n), Order.add_right(k, U32.to_nat(len), x, hk),
    FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{{}} : Bool}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32))
  %ec : {{U32.to_nat(U32.add(off, c)) == Nat.add(_, x) : Nat}}
  VB.add_lt32(off, c, x, eo,
    FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(z, x), FD.spec_common__pow2(32n)) == True{{}} : Bool}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), h))

# Room for s bytes at c + x, for c + s <= {FS}.
def roomF({CW}, {HA}, +c: Nat, +s: Nat, +hc: {{Nat.is_le(Nat.add(c, s), {FS}n) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(Nat.add(c, x), s), {PW}) == True{{}} : Bool}}:
  UR.roomf(x, U32.to_nat(len), c, s, {PW}, hw, FD.nat__le_trans(Nat.add(c, s), {FS}n, U32.to_nat(len), hc, leF(len, ha)))

# The child's window: ({FS} + x) + (len - {FS}) <= 4 2^d.
def hwc({CW}, {HA}) -> {{Nat.is_le(Nat.add(JW(x), U32.to_nat(LLw(len))), {PW}) == True{{}} : Bool}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(z, {PW}) == True{{}} : Bool}}, Nat.add(x, Nat.add({FS}n, U32.to_nat(LLw(len)))), Nat.add({FS}n, Nat.add(x, U32.to_nat(LLw(len)))),
    FD.lru_nat_algebra__add_swap(x, {FS}n, U32.to_nat(LLw(len))),
    FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), {PW}) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({FS}n, U32.to_nat(LLw(len))), Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)), hw))

# ... and ends below 2^32.
def hwc32({CW}, {HA}) -> {{Nat.is_lt(Nat.add(JW(x), U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{{}} : Bool}}:
  FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{{}} : Bool}}, Nat.add(x, Nat.add({FS}n, U32.to_nat(LLw(len)))), Nat.add({FS}n, Nat.add(x, U32.to_nat(LLw(len)))),
    FD.lru_nat_algebra__add_swap(x, {FS}n, U32.to_nat(LLw(len))),
    FD.logic__subst(Nat, z => {{Nat.is_lt(Nat.add(x, z), FD.spec_common__pow2(32n)) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({FS}n, U32.to_nat(LLw(len))), Equal.sym(Nat, Nat.add({FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)), hw32))

def eoF({CW}, {HA}) -> {{U32.to_nat(OWc(off)) == JW(x) : Nat}}:
  eoc({CWA}, {FS}, {FS}n, {{==}}, {{==}}, ha)

# ---- the validator ----------------------------------------------------------------------------

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {{{Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}}:
  match ok:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def okc0({CW}, {HA}, +b: Bool, +eb: {{U32.is_eq(SPOw(t, x), {FS}) == b : Bool}})
    -> {{{Tn}_c0(b, BF(t, n), off, len, SPOw(t, x)) == (BF(t, n), chk3(True{{}}, b, {CHK_child})) : B.Buf & Bool}}:
  match b:
    case False{{}}: {{==}}
    case True{{}}:
      +epo = FD.u32alg__eq_of(SPOw(t, x), {FS}, eb)
      %Equal.sym(U32, SPOw(t, x), {FS}, epo) :
        {{{Tn}_v1(off, len, _, T.{x.okf}_ok(BF(t, n), U32.add(off, _), U32.sub(len, _))) == (BF(t, n), {CHK_child}) : B.Buf & Bool}}
      %Equal.sym(B.Buf & Bool, T.{x.okf}_ok(BF(t, n), OWc(off), LLw(len)), (BF(t, n), {CHK_child}),
          CH.ok_evalwD(d, t, n, JW(x), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf)) :
        {{{Tn}_v1(off, len, {FS}, _) == (BF(t, n), {CHK_child}) : B.Buf & Bool}}
      c1_id({CHK_child}, BF(t, n), off, len, {FS})

def rdpo({CW}, {HA}) -> {{B.read32(BF(t, n), U32.add(off, {P})) == (BF(t, n), SPOw(t, x)) : B.Buf & U32}}:
  UR.rwx(d, t, n, U32.add(off, {P}), Nat.add({P}n, x), eoc({CWA}, {P}, {P}n, {{==}}, {{==}}, ha), FD.nat__lt_trans(d, 28n, 31n, hd, {{==}}), pf,
    roomF({CWA}, ha, {P}n, 4n, {{==}}))

def okl({CW}, +a: Bool, +ea: {{U32.is_le({FS}, len) == a : Bool}})
    -> {{{Tn}_ok_len(a, BF(t, n), off, len) == (BF(t, n), chk3(a, U32.is_eq(SPOw(t, x), {FS}), {CHK_child})) : B.Buf & Bool}}:
  match a:
    case False{{}}: {{==}}
    case True{{}}:
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, {P})), (BF(t, n), SPOw(t, x)), rdpo({CWA}, ea)) :
        {{{Tn}_v0(off, len, _) == (BF(t, n), chk3(True{{}}, U32.is_eq(SPOw(t, x), {FS}), {CHK_child})) : B.Buf & Bool}}
      okc0({CWA}, ea, U32.is_eq(SPOw(t, x), {FS}), {{==}})

# The validator on the window returns the buffer and CHKw.
def ok_evalw({CW}) -> {{{Tn}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}}:
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
""")
    # ---- the reader ----
    CHOBJ = 'CH.OBJw(d, t, JW(x), OWc(off), LLw(len))'
    objs = []
    for f in x.fields:
        if f['kind'] == 'fix':
            objs.append(f['ft'].obj([f'UR.RWN(t, {posx(f["c"] + 4 * j)})' for j in range(f['ft'].W)]))
        else:
            objs.append(f'O.BSome{{{CHOBJ}, O.BNone{{}}}}' if x.boxed else CHOBJ)
    OBJ = f'{Tn}{{' + ', '.join(objs) + '}'
    RHS = '(BF(t, n), OBJw(d, t, x, off, len))'
    TY = f'B.Buf & {Tn}'
    w(f'def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {Tn}: {OBJ}')
    w('')
    w(f'def rd_go({CW}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}}, +hc: {{{CHK_child} == True{{}} : Bool}})')
    w(f'    -> {{{Tn}_read(BF(t, n), off, len) == {RHS} : {TY}}}:')
    w(f'  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, {P})), (BF(t, n), SPOw(t, x)), rdpo({CWA}, ha)) :')
    w(f'    {{{Tn}_rd0(off, len, _) == {RHS} : {TY}}}')

    def read_term(f, o):
        if f['kind'] == 'fix':
            ft = f['ft']
            return f'T.{ft.p}_read(BF(t, n), U32.add(off, {f["c"]}), {ft.size})'
        return f'T.{x.rdf}_read(BF(t, n), U32.add(off, {o}), U32.sub(len, {o}))'
    w(f'  %Equal.sym(U32, SPOw(t, x), {FS}, epo) :')
    w(f'    {{{Tn}_rd1(off, len, _, {read_term(x.fields[0], "_")}) == {RHS} : {TY}}}')
    for j, f in enumerate(x.fields):
        args = ', '.join(['off', 'len', f'{FS}'] + objs[:j])
        if f['kind'] == 'fix':
            ft = f['ft']
            c = f['c']
            w(f'  %Equal.sym(B.Buf & {ft.rep()}, {read_term(f, FS)}, (BF(t, n), {objs[j]}),')
            w(f'      VTX.rdxd_{ft.p}(d, t, n, U32.add(off, {c}), {posx(c)}, eoc({CWA}, {c}, {c}n, {{==}}, {{==}}, ha), hd, pf,')
            w(f'        roomF({CWA}, ha, {c}n, {ft.size}n, {{==}}))) :')
            w(f'    {{{Tn}_rd{j + 1}({args}, _) == {RHS} : {TY}}}')
        else:
            base = x.rdf[:-3] if x.boxed else x.rdf
            cur = f'T.{base}_read(BF(t, n), OWc(off), LLw(len))'
            w(f'  %Equal.sym(B.Buf & {chrep}, {cur}, (BF(t, n), {CHOBJ}),')
            w(f'      CH.readwD(d, t, n, JW(x), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc)) :')
            hole = f'T.{x.rdf}_rd(_)' if x.boxed else '_'
            w(f'    {{{Tn}_rd{j + 1}({args}, {hole}) == {RHS} : {TY}}}')
    w('  {==}')
    w(f"""
# The reader on the window, when the checks hold.
def readw({CW}, +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{{Tn}_read(BF(t, n), off, len) == {RHS} : {TY}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, x), {FS})
  +c = {CHK_child}
  rd_go({CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, x), {FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))
""")
    # ---- the spec side ----
    nodes = VL.field_nodes(g, x, lambda k: f'UR.RWN(t, {posx(4 * k)})')
    vi = [f['kind'] for f in x.fields].index('var')
    Y = 'UW.WX(t, JW(x), U32.to_nat(LLw(len)))'
    vals, schs, parts = [], [], []
    for f, nd in zip(x.fields, nodes):
        if f['kind'] == 'fix':
            vals.append(nd['val'])
            schs.append(nd['sch'])
            parts.append(f'S.Fixed{{F.limbs([{", ".join(nd["words"])}])}}')
        else:
            vals.append('CH.VALw(t, JW(x), LLw(len))')
            schs.append(CSCH)
            parts.append(f'S.Variable{{{Y}}}')

    def items(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{vals[i]}, {items(i + 1)}}}'

    # definitions per step: the fixed fields' values as small refs (FVc<i>), their parts facts as lemmas (fxc<i>)
    svals = [f'FVc{i}(t, x)' if f['kind'] == 'fix' else v for i, (f, v) in enumerate(zip(x.fields, vals))]

    def sitems(i):
        return 'S.EmptyItems{}' if i == len(vals) else f'S.Items{{{svals[i]}, {sitems(i + 1)}}}'

    def chain(i):
        return 'S.End{}' if i == len(vals) else f'S.Chain{{{schs[i]}, {chain(i + 1)}}}'

    def cat(i):
        if i == len(vals):
            return '{==}'
        rest = '[' + ', '.join(parts[i + 1:]) + ']'
        if x.fields[i]['kind'] == 'fix':
            return (f'gcf_({svals[i]}, {sitems(i + 1)}, {schs[i]}, {chain(i + 1)}, F.limbs([{", ".join(nodes[i]["words"])}]), '
                    f'{rest}, fxc{i}(t, x), {cat(i + 1)})')
        return (f'gcv_({svals[i]}, {sitems(i + 1)}, {schs[i]}, {chain(i + 1)}, {Y}, {rest}, '
                f'CH.specwD(d, t, n, JW(x), OWc(off), LLw(len), eoF({CWA}, ha), hd, hwc({CWA}, ha), hwc32({CWA}, ha), pf, hc), {cat(i + 1)})')
    PRE = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[:vi]) + ']'
    POST = '[' + ', '.join('[' + ', '.join(nd['words']) + ']' for nd in nodes[vi + 1:]) + ']'
    hdr = []
    for f, nd in zip(x.fields, nodes):
        hdr += nd['words'] if f['kind'] == 'fix' else [str(FS)]
    HDR = '[' + ', '.join(hdr) + ']'
    HDRh = '[' + ', '.join(h if k != po else '_' for k, h in enumerate(hdr)) + ']'
    ENCR = f'List.append(&2, U32, List.append(&2, U32, F.flat({PRE}), List.append(&2, U32, N.digits(4n, VS.FSZ({PRE}, {POST})), F.flat({POST}))), {Y})'
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    M = 'Maybe<&2, +List<U32>>'
    LLn = 'U32.to_nat(LLw(len))'
    TXL = '+t: FD.array__Tree<U32>, +x: Nat, +len: U32'
    FXR = lambda i: f'Some{{[S.Fixed{{F.limbs([{", ".join(nodes[i]["words"])}])}}]}} : {MP}'
    fxdefs = ''.join(f'def FVc{i}(+t: FD.array__Tree<U32>, +x: Nat) -> S.Value: {vals[i]}\n\n'
                     f'def fvq{i}(+t: FD.array__Tree<U32>, +x: Nat) -> {{{vals[i]} == FVc{i}(t, x) : S.Value}}:\n  {{==}}\n\n'
                     f'def fxc{i}(+t: FD.array__Tree<U32>, +x: Nat) -> {{Codec.parts(FVc{i}(t, x), {schs[i]}) == {FXR(i)}}}:\n'
                     f'  %fvq{i}(t, x) : {{Codec.parts(_, {schs[i]}) == {FXR(i)}}}\n'
                     f'  {nodes[i]["proof"]}\n\n' for i, f in enumerate(x.fields) if f['kind'] == 'fix')
    LH = 'LHc(t, x, len)'
    SMALL = (f'def ITc({TXL}) -> S.Value: {sitems(0)}\n\n'
             f'def PSc({TXL}) -> +List<S.Part>: VS.fpv({PRE}, {Y}, {POST})\n\n'
             f'def ENCc({TXL}) -> +List<U32>: {ENCR}\n\n'
             f'def LHc({TXL}) -> +List<U32>: List.append(&2, U32, F.limbs({HDR}), {Y})\n\n')
    w(f"""def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{{{items(0)}}}

def fitw({CW}, {HA}) -> {{N.fits(4n, Nat.add(VS.FSZ({PRE}, {POST}), List.length(&2, U32, {Y}))) == True{{}} : Bool}}:
  %Equal.sym(Nat, List.length(&2, U32, {Y}), {LLn}, UW.lenWX(d, t, JW(x), {LLn}, pf, hwc({CWA}, ha))) : {{N.fits(4n, Nat.add({FS}n, _)) == True{{}} : Bool}}
  %Equal.sym(Nat, Nat.add({FS}n, {LLn}), U32.to_nat(len), enF(len, ha)) : {{N.fits(4n, _) == True{{}} : Bool}}
  VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(x, U32.to_nat(len)), hw32))

# The window's bytes: the header words' limbs, then the child's window.
def limw({CW}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}})
    -> {{List.append(&2, U32, F.limbs({HDR}), {Y}) == {WBL} : +List<U32>}}:
  +hw2 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), {PW}) == True{{}} : Bool}}, U32.to_nat(len), Nat.add({FS}n, {LLn}), Equal.sym(Nat, Nat.add({FS}n, {LLn}), U32.to_nat(len), enF(len, ha)), hw)
  %enF(len, ha) : {{List.append(&2, U32, F.limbs({HDR}), {Y}) == UW.WX(t, x, _) : +List<U32>}}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad({H}n), {LLn})), List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), UW.WX(t, Nat.add(A.quad({H}n), x), {LLn})),
      UW.headWX(d, t, x, {H}n, {LLn}, pf, hw2)) :
    {{List.append(&2, U32, F.limbs({HDR}), {Y}) == _ : +List<U32>}}
  %epo : {{List.append(&2, U32, F.limbs({HDRh}), {Y}) == List.append(&2, U32, F.limbs(UR.RWS({H}n, t, x)), {Y}) : +List<U32>}}
  {{==}}

# Definitions per step: a container's parts one step down and one field before the rest, over opaque values
# (a conversion that is not a syntactic match would evaluate the fields' parts).
def gcv_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +y: +List<U32>, +rest: +List<S.Part>,
    +ea: {{Codec.parts(v, s) == Some{{[S.Variable{{y}}]}} : Maybe<&2, +List<S.Part>>}}, +eb: {{Codec.parts(vs, rs) == Some{{rest}} : Maybe<&2, +List<S.Part>>}})
    -> {{Codec.parts(S.Items{{v, vs}}, S.Chain{{s, rs}}) == Some{{S.Variable{{y}} <> rest}} : Maybe<&2, +List<S.Part>>}}:
  VS.cat_var(Codec.parts(v, s), y, Codec.parts(vs, rs), rest, ea, eb)

def gcf_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +xs: +List<U32>, +rest: +List<S.Part>,
    +ea: {{Codec.parts(v, s) == Some{{[S.Fixed{{xs}}]}} : Maybe<&2, +List<S.Part>>}}, +eb: {{Codec.parts(vs, rs) == Some{{rest}} : Maybe<&2, +List<S.Part>>}})
    -> {{Codec.parts(S.Items{{v, vs}}, S.Chain{{s, rs}}) == Some{{S.Fixed{{xs}} <> rest}} : Maybe<&2, +List<S.Part>>}}:
  F.cat_fixed(Codec.parts(v, s), xs, Codec.parts(vs, rs), rest, ea, eb)

"""
    + fxdefs + SMALL + f"""def vwc(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {{S.Sequence{{ITc(t, x, len)}} == VALw(t, x, len) : S.Value}}:
  {{==}}

def lct(+it: S.Value) -> {{Codec.aggregate(Codec.parts(it, {chain(0)}), None{{}}) == Codec.parts(S.Sequence{{it}}, Spec.{n}()) : {MP}}}:
  {{==}}

def aggS(+xs: +List<S.Part>, +w: Maybe<&2, Nat>) -> {{Codec.one(Layout.encoding(xs), w) == Codec.aggregate(Some{{xs}}, w) : {MP}}}:
  {{==}}

def limwS({CW}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}}) -> {{{LH} == {WBL} : +List<U32>}}:
  limw({CWA}, ha, epo)

def catS({CW}, {HA}, +hc: {{{CHK_child} == True{{}} : Bool}}) -> {{Codec.parts(ITc(t, x, len), {chain(0)}) == Some{{PSc(t, x, len)}} : {MP}}}:
  {cat(0)}

def encS({CW}, {HA}) -> {{Layout.encoding(PSc(t, x, len)) == Some{{ENCc(t, x, len)}} : {M}}}:
  VBC.enc_fpvb({PRE}, {Y}, {POST}, UW.domWX(t, JW(x), {LLn}), fitw({CWA}, ha))

def specg({CW}, {HA}, +epo: {{SPOw(t, x) == {FS} : U32}}, +hc: {{{CHK_child} == True{{}} : Bool}})
    -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}:
  %limwS({CWA}, ha, epo) : {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{_}}]}} : {MP}}}
  %vwc(t, x, len) : {{Codec.parts(_, Spec.{n}()) == Some{{[S.Variable{{{LH}}}]}} : {MP}}}
  %lct(ITc(t, x, len)) : {{_ == Some{{[S.Variable{{{LH}}}]}} : {MP}}}
  %Equal.sym({MP}, Codec.parts(ITc(t, x, len), {chain(0)}), Some{{PSc(t, x, len)}}, catS({CWA}, ha, hc)) :
    {{Codec.aggregate(_, None{{}}) == Some{{[S.Variable{{{LH}}}]}} : {MP}}}
  %aggS(PSc(t, x, len), None{{}}) : {{_ == Some{{[S.Variable{{{LH}}}]}} : {MP}}}
  %Equal.sym({M}, Layout.encoding(PSc(t, x, len)), Some{{ENCc(t, x, len)}}, encS({CWA}, ha)) :
    {{Codec.one(_, None{{}}) == Some{{[S.Variable{{{LH}}}]}} : {MP}}}
  {{==}}

# The spec parts of the value: one variable part, the window's bytes.
def specw({CW}, +hchk: {{CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{Codec.parts(VALw(t, x, len), Spec.{n}()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}:
  +a = U32.is_le({FS}, len)
  +b = U32.is_eq(SPOw(t, x), {FS})
  +c = {CHK_child}
  specg({CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, x), {FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))
""")
    inv = inv_text(x, CW, CWA, CHK_child, CSCH, kids, Y, WBL).replace('CH.invw(', 'CH.invwD(')
    RF = FS - P - 4
    for a, b in [('CHKw(t, i, off, len)', 'CHKw(t, x, off, len)'),
                 ('VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)', 'UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)'),
                 (f'+W2 = VR.WB(t, i, Nat.add({FS}n, lY))', f'+W2 = UW.WX(t, x, Nat.add({FS}n, lY))'),
                 ('z => VR.WB(t, i, z)', 'z => UW.WX(t, x, z)'),
                 ('Nat.add(A.quad(i), z)', 'Nat.add(x, z)'),
                 (f'VWN.byteW(d, t, i, {po}n, Nat.add({RF}n, lY), pf, hw2)', f'UW.byteWX(d, t, x, {P}n, Nat.add({RF}n, lY), pf, hw2)'),
                 ('SPOw(t, i)', 'SPOw(t, x)'),
                 (f'VWN.tailW(t, i, {H}n, lY)', f'UW.tailWX(t, x, {FS}n, lY)'),
                 ('VR.WB(t, JW(i), ', 'UW.WX(t, JW(x), '), ('JW(i)', 'JW(x)'),
                 ('def chk_t(+t: FD.array__Tree<U32>, +i: Nat,', 'def chk_t(+t: FD.array__Tree<U32>, +x: Nat,'), ('chk_t(t, i, ', 'chk_t(t, x, ')]:
        assert a in inv or a in ('Nat.add(A.quad(i), z)',), a
        inv = inv.replace(a, b)
    w(inv)
    text = '\n'.join(L) + '\n'
    for bad in ['A.quad(i)', 'VR.WB(', '(t, i,', 'JW(i)']:
        assert bad not in text, bad
    return deep_x(text)


# A List[uint64, N] at a window at any byte offset (the runtime prefix @p_, limit @N).
LISTX = r"""
def v8() -> Word(31n): FD.spec_numeric__from_nat(31n, 8n)
def CQ(+len: U32) -> Nat: U32.to_nat(U32.div(len, 8))

# Whole elements, at most @N.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), @N))

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  {==}

def eLc(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {U32.to_nat(len) == VS.x8(CQ(len)) : Nat}:
  %VC.x8_mul(CQ(len)) : {U32.to_nat(len) == _ : Nat}
  Pair.fst({U32.to_nat(len) == Nat.mul(CQ(len), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool},
    VU.whole_t(len, 8, @N, v8(), {==}, {==}, {==}, hc))

def hcL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool}:
  Pair.snd({U32.to_nat(len) == Nat.mul(CQ(len), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool},
    VU.whole_t(len, 8, @N, v8(), {==}, {==}, {==}, hc))
@ZEROS
def hWZ(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hL: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(@Kn)) == True{} : Bool}:
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(U32.to_nat(@N))) == True{} : Bool}, VS.x8(CQ(len)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), VS.x8(CQ(len)), eLc(t, x, off, len, hc)),
    VS.x8_mono(CQ(len), U32.to_nat(@N), hcL(t, x, off, len, hc)))
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
    VC.wz_le(len, VLS.KK(d), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n, VC.rng_mono(2n, VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N))), Order.add_left(31n, U32.to_nat(len), VS.x8(U32.to_nat(@N)), hx))),
      {==}))

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Words: O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & O.Words}:
  +hL = hlen(d, x, len, hw)
  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))
  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{VS.uitems(CQ(len), UR.RWS(Nat.double(CQ(len)), t, x))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +k = CQ(len)
  +W = UR.RWS(Nat.double(k), t, x)
  +el = Equal.trans(Nat, U32.to_nat(len), VS.x8(k), VB.d3(k), eLc(t, x, off, len, hchk), VB.x8_d3(k))
  %Equal.sym(Nat, U32.to_nat(len), VB.d3(k), el) : {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{UW.WX(t, x, _)}]} : Maybe<&2, +List<S.Part>>}
  %UR.rws_bytes(Nat.double(k), d, t, x, pf, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), VB.d3(k), el, hw)) :
    {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{_}]} : Maybe<&2, +List<S.Part>>}
  %UR.wtake_rws(Nat.double(k), t, x) : {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{F.limbs(_)}]} : Maybe<&2, +List<S.Part>>}
  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), {==},
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.double(k), z) == True{} : Bool}, Nat.double(k), VB.len(W), Equal.sym(Nat, VB.len(W), Nat.double(k), UR.rws_len(Nat.double(k), t, x)), FD.nat__le_refl(Nat.double(k))))

# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

def ivf(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +c: Nat, +hk: {Nat.is_le(c, U32.to_nat(@N)) == True{} : Bool},
    +ys: +List<U32>, +ly: {List.length(&2, U32, ys) == VS.x8(c) : Nat}, +ey: {ys == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), VS.x8(c),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, ys), VS.x8(c),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), ys, Equal.sym(+List<U32>, ys, UW.WX(t, x, U32.to_nat(len)), ey)), ly))
  VU.whole_i(len, 8, @N, v8(), {==}, {==}, {==}, c, Equal.trans(Nat, U32.to_nat(len), VS.x8(c), Nat.mul(c, 8n), el, Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c))), hk)

def ivm4(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +hk: {Nat.is_le(Codec.count(its), U32.to_nat(@N)) == True{} : Bool},
    +ps: +List<S.Part>, +em3: {Codec.parts(its, S.Repeat{@EL}) == Some{ps} : Maybe<&2, +List<S.Part>>},
    +m4: Maybe<&2, +List<U32>>, +em4: {Layout.encoding(ps) == m4 : Maybe<&2, +List<U32>>},
    +e: {Codec.one(m4, None{}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m4:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case Some{+ys}:
      +lys = Equal.trans(Nat, List.length(&2, U32, ys), Layout.fixed_size(ps), VS.x8(Codec.count(its)),
        VS.enc_len(ps, ys, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)), em4),
        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)))
      ivf(d, t, x, off, len, hw, pf, Codec.count(its), hk, ys, lys, var_inj(ys, UW.WX(t, x, U32.to_nat(len)), e))

def ivm3(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +hk: {Nat.is_le(Codec.count(its), U32.to_nat(@N)) == True{} : Bool},
    +m3: Maybe<&2, +List<S.Part>>, +em3: {Codec.parts(its, S.Repeat{@EL}) == m3 : Maybe<&2, +List<S.Part>>},
    +e: {Codec.aggregate(m3, None{}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m3:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case Some{+ps}: ivm4(d, t, x, off, len, hw, pf, its, hk, ps, em3, Layout.encoding(ps), {==}, e)

def ivb(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +b2: Bool, +eb2: {Nat.is_le(Codec.count(its), U32.to_nat(@N)) == b2 : Bool},
    +e: {Codec.require(b2, Codec.aggregate(Codec.parts(its, S.Repeat{@EL}), None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match b2:
    case False{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case True{}: ivm3(d, t, x, off, len, hw, pf, its, eb2, Codec.parts(its, S.Repeat{@EL}), {==}, e)

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match v:
    case S.Sequence{+its}: ivb(d, t, x, off, len, hw, pf, its, Nat.is_le(Codec.count(its), U32.to_nat(@N)), {==}, e)
@ABSURDV
"""


LISTX_DEEP_BOUNDS = r"""
# 31 + len <= 2^@KB: the checks bound the length (whatever the buffer's depth).
def hyN(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N)))) == True{} : Bool}:
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(U32.to_nat(@N))) == True{} : Bool}, VS.x8(CQ(len)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), VS.x8(CQ(len)), eLc(t, x, off, len, hc)),
    VS.x8_mono(CQ(len), U32.to_nat(@N), hcL(t, x, off, len, hc)))
  Order.add_left(31n, U32.to_nat(len), VS.x8(U32.to_nat(@N)), hx)

def hyL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), VB.pw(@KBn)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N))), VB.pw(@KBn), hyN(t, x, off, len, hc), {==})

def hWZ(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(@Kn)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
    VC.wz_le(len, @KBn, {==}, hyL(t, x, off, len, hc)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n, VC.rng_mono(2n, VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N))), hyN(t, x, off, len, hc))),
      {==}))

# The list storage has room for the words.
def hrgL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(len), 0n), VB.pw(VLS.DZ(len))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), FD.nat__add_zero(VC.NW(len))) : {Nat.is_le(_, VB.pw(VLS.DZ(len))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VLS.DZ(len)), O.pow2n(VLS.DZ(len)), VD.s_pow2_eq(VLS.DZ(len))) : {Nat.is_le(VC.NW(len), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(len), U32.to_nat(VC.WZ(len)), O.pow2n(VLS.DZ(len)), VC.nw_le_wz(len, @KBn, {==}, hyL(t, x, off, len, hc)), VD.wd_cover(VC.WZ(len), @Kn, {==}, hWZ(t, x, off, len, hc)))
"""


def listx_deep_text(N, p, sch, el, limn):
    """List[uint64, N] at a window at any byte offset, any depth d < 31: the storage's bounds come from the
    limit N (31 + 8 N <= 2^KB), never from the buffer's depth."""
    YMAX = 31 + 8 * N
    KB = ceil_log2(YMAX)
    K = ceil_log2((YMAX >> 2) + 8)
    # N = 2^pw: the closed bounds by proofs/obj/xbound.bend in powers of two (8 N = 2^(pw + 3)), never as
    # unary numbers (hyL, hWZ, specwD's fits counted a million steps each: 5 s per module); the storage
    # bound is then 2^(pw + 3) (one more than the least K, which only bounds the zero storage's depth)
    pw = N.bit_length() - 1
    xb = N == 1 << pw and pw >= 2 and pw + 3 < 31
    if xb:
        assert KB == pw + 4
        K = pw + 3
    assert KB < 31 and K < 31
    body = LISTX.replace('@ZEROS', '')
    body = _cut_def(body, 'hWZ')
    a = body.index('\ndef OBJw(')
    body = body[:a] + LISTX_DEEP_BOUNDS + body[a:]
    if xb:
        E5 = ', '.join(['{==}'] * 5)
        for a_, b_ in [('VB.pw(@KBn), hyN(t, x, off, len, hc), {==})',
                        f'VB.pw(@KBn), hyN(t, x, off, len, hc), XB.yle(@N, {pw}n, {pw + 2}n, @KBn, {E5}))'),
                       ('hyN(t, x, off, len, hc))),\n      {==}))',
                        f'hyN(t, x, off, len, hc))),\n      XB.wzb(@N, {pw}n, {pw + 2}n, @KBn, @Kn, {E5}, {{==}})))'),
                       ('  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), {==},',
                        f'  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), XB.fitb(@N, {pw}n, {pw + 2}n, {{==}}, {{==}}, {{==}}, {{==}}),')]:
            assert a_ in body, a_[:60]
            body = body.replace(a_, b_)
    for a_, b_ in [('  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))', '  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(t, x, off, len, hchk))'),
                   ('  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)',
                    '  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),\n'
                    '    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))'),
                   ('  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,\n'
                    '    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))',
                    '  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), @KBn, pf, hd, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,\n'
                    '    UW.hsxB(d, off, x, len, eo, @KBn, {==}, hyL(t, x, off, len, hchk), hw), hrgL(t, x, off, len, hchk), {==}, hyL(t, x, off, len, hchk))'),
                   ('  +hL = hlen(d, x, len, hw)\n', '')]:
        assert a_ in body, a_[:60]
        body = body.replace(a_, b_)
    body = body.replace('@ABSURDV', absurd_cases('Sequence', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    for k, v in [('@KBn', f'{KB}n'), ('@Kn', f'{K}n'), ('@LIMN', limn), ('@SCH', sch), ('@EL', el), ('@N', str(N)), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vvlz.bend as VZG'] + (['import ./xbound.bend as XB'] if xb else []) + ['', '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# List[uint64, {N}] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return deep_x('\n'.join(L) + COMMONX + body)


def listx_text(N, p, sch, el, limn):
    # the zero storage's depth from the window's bound (VLS.hdz29) and any depth's zero array (vvlz), as
    # for the 2^40 lists: no enumeration of the zero arrays up to the list's depth
    K = 29
    body = LISTX.replace('@ZEROS', '')
    body = _cut_def(body, 'hWZ')
    for a_, b_ in [('  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))', '  +hz = VLS.hdz29(d, len, hd, hL)'),
                   ('  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)',
                    '  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),\n'
                    '    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))')]:
        assert a_ in body, a_[:60]
        body = body.replace(a_, b_)
    body = body.replace('@ABSURDV', absurd_cases('Sequence', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    for k, v in [('@Kn', f'{K}n'), ('@LIMN', limn), ('@SCH', sch), ('@EL', el), ('@N', str(N)), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vvlz.bend as VZG', '', '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# List[uint64, {N}] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + COMMONX + body



def _cut_def(text, name):
    """text without the def `name` (up to the next blank line)."""
    a = text.index(f'\ndef {name}(')
    b = text.index('\n\n', a + 1)
    return text[:a] + text[b:]


HWNX = '{Nat.is_le(Nat.add(x, U32.to_nat(len)), U32.to_nat(VB.NMAX())) == True{} : Bool}'


def deep_xN(text, names=XIFACE):
    """The unbounded byte-offset windows (the 2^40 lists) at any depth d < 31: the window ends by NMAX
    (hwN), so 31 + len <= UMAX and the copy is VC's U chain; no power of two on the depth bounds the
    storage. The old interface (d < 28) stays under the old names (hwN from VB.hwNof)."""
    import deep
    reps = [
        ('  +hz = VLS.hdz29(d, len, hd, hL)', '  +hy = VC.hyW(x, len, hwN)\n  +hz = VC.dz30(len, hy)'),
        ('  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {==}), ez,\n'
         '    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))',
         '  UCT.copy_in_atU(d, t, n, off, len, VLS.DZ(len), pf, hd, FD.nat__le_lt_trans(VLS.DZ(len), 30n, 31n, hz, {==}), ez,\n'
         '    UW.hsxBU(d, off, x, len, eo, hy, hw), VC.hrgU(len, hy), hy)'),
        ('VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))',
         'VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(x, U32.to_nat(len)),\n'
         '        VB.le_n_lt32(Nat.add(x, U32.to_nat(len)), VB.NMAX(), hwN)))'),
        ('  +hL = hlen(d, x, len, hw)\n', ''),
    ]
    for a, b in reps:
        assert a in text, a[:70]
        text = text.replace(a, b)
    return deep_N(text, names)


def deep_N(text, names=XIFACE):
    """d < 31 and hwN (the window ends by NMAX) threaded, the old interface as wrappers (hwN from VB.hwNof)."""
    import deep
    text = text.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)')
    assert 'VLS.KK(' not in text and 'VLS.hrg(' not in text and 'UW.hsx(' not in text and '28n' not in text.replace('28n+x', ''), 'deep_N leftover'
    text = deep.thread(text, HWX, HWNX, hw32='hwN')
    return deep.compat(text, names, HWX, HWNX, 'Nat.add(x, U32.to_nat(len))', hw32='hwN',
                       hw32_term='VB.hwNof(d, Nat.add(x, U32.to_nat(len)), hd, hw)')


def listx40_text(p, sch, el, limn, deep=False):
    """List[uint64, 2^40] at a window at any byte offset: the runtime checks only
    whole elements (a U32 length cannot exceed the limit), so the count's bound
    is the length's (vu40: symbolic capacities, never evaluated)."""
    K = 29
    body = LISTX.replace('@ZEROS', '')
    body = body.replace('@ABSURDV', absurd_cases('Sequence', '{CHKw(t, x, off, len) == True{} : Bool}', target='[S.Variable{UW.WX(t, x, U32.to_nat(len))}]'))
    body = _cut_def(body, 'hWZ')
    body = _cut_def(body, 'eLc')
    body = _cut_def(body, 'hcL')
    body = _cut_def(body, 'ivf')
    reps = [
        ('# Whole elements, at most @N.\ndef CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), @N))',
         """# Whole elements (a U32 length is below the limit).
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{})

def eLc(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {U32.to_nat(len) == VS.x8(CQ(len)) : Nat}:
  %VC.x8_mul(CQ(len)) : {U32.to_nat(len) == _ : Nat}
  V40.whole_e(len, 8, v8(), {==}, {==}, {==}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{}, hc))

def hcL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(CQ(len), @LIMN) == True{} : Bool}:
  V40.u32le40(U32.div(len, 8))"""),
        ('  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))', '  +hz = VLS.hdz29(d, len, hd, hL)'),
        ('  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)',
         '  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),\n'
         '    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))'),
        ('  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), {==},',
         '  V40.list_u64_partsk(k, W, @LIMN, hcL(t, x, off, len, hchk),\n'
         '    FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(len), VS.x8(k), eLc(t, x, off, len, hchk),\n'
         '      VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))),'),
        ('U32.to_nat(@N)', '@LIMN'),
    ]
    for a, b in reps:
        assert a in body, a[:60]
        body = body.replace(a, b)
    ivf = """
def ivf(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +c: Nat, +hk: {Nat.is_le(c, @LIMN) == True{} : Bool},
    +ys: +List<U32>, +ly: {List.length(&2, U32, ys) == VS.x8(c) : Nat}, +ey: {ys == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), VS.x8(c),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, ys), VS.x8(c),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), ys, Equal.sym(+List<U32>, ys, UW.WX(t, x, U32.to_nat(len)), ey)), ly))
  +hc = FD.logic__subst(Nat, z => {Nat.is_le(c, z) == True{} : Bool}, VS.x8(c), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), VS.x8(c), el), V40.x8ge(c))
  +w = VU.whole_i(len, 8, len, v8(), {==}, {==}, {==}, c, Equal.trans(Nat, U32.to_nat(len), VS.x8(c), Nat.mul(c, 8n), el, Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c))), hc)
  FD.logic__and_intro(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), len), w), {==})
"""
    a = body.index('\ndef ivm4(')
    body = body[:a] + ivf + body[a:]
    for k, v in [('@Kn', f'{K}n'), ('@LIMN', limn), ('@SCH', sch), ('@EL', el), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    assert '@' not in body.replace('&2', ''), [l for l in body.splitlines() if '@' in l.replace('&2', '')][:3]
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vu40.bend as V40', 'import ./vvlz.bend as VZG', '', '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# List[uint64, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    text = '\n'.join(L) + COMMONX + body
    return deep_xN(text) if deep else text



LISTU8X40 = r"""
def v1() -> Word(31n): FD.spec_numeric__from_nat(31n, 1n)

# Whole elements: every length is (one-byte elements; a U32 length is below the limit).
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 1) * 1 : U32)), True{})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  {==}

# The checks hold for every window.
def chk(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {CHKw(t, x, off, len) == True{} : Bool}:
  +w = VU.whole_i(len, 1, len, v1(), {==}, {==}, {==}, U32.to_nat(len), PB.mul1(U32.to_nat(len)), FD.nat__le_refl(U32.to_nat(len)))
  FD.logic__and_intro(U32.is_eq(len, (U32.div(len, 1) * 1 : U32)), True{}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, 1) * 1 : U32)), U32.is_le(U32.div(len, 1), len), w), {==})

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Words: O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & O.Words}:
  +hL = hlen(d, x, len, hw)
  +hz = VLS.hdz29(d, len, hd, hL)
  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),
    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {==}), ez,
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{PB.it1(U32.to_nat(len), UW.WX(t, x, U32.to_nat(len)))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +Y = UW.WX(t, x, U32.to_nat(len))
  +hs = FD.logic__subst(Nat, z => {SP.byte_scope(z, Y) == True{} : Bool}, List.length(&2, U32, Y), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw),
    U8.dom_scope(Y, UW.domWX(t, x, U32.to_nat(len))))
  U8.listu8_parts(U32.to_nat(len), Y, @LIMN, V40.u32le40(len), hs, VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))

# Every value whose spec parts are the window's bytes passes the checks (every window does).
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  chk(t, x, off, len)
"""


def listu8x40_text(p, sch, limn, deep=False):
    """List[uint8, 2^40] at a window at any byte offset (BeaconState's participation lists)."""
    body = LISTU8X40
    for k, v in [('@LIMN', limn), ('@SCH', sch), ('@p_', f'{p}_')]:
        body = body.replace(k, v)
    L = HEADX + ['import ./vua_rd.bend as UR', 'import ./vu40.bend as V40', 'import ./vvlz.bend as VZG', 'import ./vu8.bend as U8',
                 'import ./pb_min.bend as PB', '', '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# List[uint8, 2^40] at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    text = '\n'.join(L) + COMMONX + body
    return deep_xN(text) if deep else text


# A container of two variable-size fields of one child type (AttesterSlashing):
# offsets at bytes 0 and 4, windows [O0, O1) and [O1, len).
ASX = r"""
def O0(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, x)
def O1(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, 4n+x)
def L0(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub(O1(t, x), O0(t, x))
def L1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> U32: U32.sub(len, O1(t, x))
def J0(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat(O0(t, x)), x)
def J1(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat(O1(t, x)), x)
def W0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> U32: U32.add(off, O0(t, x))
def W1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> U32: U32.add(off, O1(t, x))

def ck(a: Bool, b: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}: b

def RR(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len))
def D0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> Bool: CH.CHKw(t, J0(t, x), W0(t, x, off), L0(t, x))
def D1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: CH.CHKw(t, J1(t, x), W1(t, x, off), L1(t, x, len))

# The fixed part is there, the first offset is 8, the second lies between it
# and the end, and both windows pass the child's checks.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  ck(U32.is_le(8, len), ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))))

def ck_a(+a: Bool, +b: Bool, +h: {ck(a, b) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def ck_b(+a: Bool, +b: Bool, +h: {ck(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case False{}: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{}: h

def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

# ---- window facts -------------------------------------------------------------------------------

# A byte position c <= len of the window, as an offset: off + c at c + x.
def eoj(@CW, +o: U32, +h: {Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, o)) == Nat.add(U32.to_nat(o), x) : Nat}:
  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), A.quad(VB.pw(d)), Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))

# (o + x) + (e - o) = x + e.
def alg(+o: Nat, +x: Nat, +e: Nat, +h: {Nat.is_le(o, e) == True{} : Bool}) -> {Nat.add(Nat.add(o, x), Nat.sub(e, o)) == Nat.add(x, e) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.add(o, x), Nat.sub(e, o)), Nat.add(o, Nat.add(x, Nat.sub(e, o))), FD.nat__add_assoc(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.add(x, Nat.sub(e, o))), Nat.add(x, Nat.add(o, Nat.sub(e, o))), FD.lru_nat_algebra__add_swap(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.sub(e, o)), e, FD.nat__sub_add(e, o, h)) : {Nat.add(x, _) == Nat.add(x, e) : Nat}
  {==}

# The window [o, e) of the window: (o + x) + (e - o) <= 4 2^d.
def hwj(@CW, +o: U32, +e: U32, +h1: {Nat.is_le(U32.to_nat(o), U32.to_nat(e)) == True{} : Bool}, +h2: {Nat.is_le(U32.to_nat(e), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), A.quad(VB.pw(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(e, o)), Nat.sub(U32.to_nat(e), U32.to_nat(o)), FD.u32__sub_nat(e, o, h1)) : {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(o), x), Nat.sub(U32.to_nat(e), U32.to_nat(o))), Nat.add(x, U32.to_nat(e)), alg(U32.to_nat(o), x, U32.to_nat(e), h1)) :
    {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)

def room4(@CW, +c: Nat, +h: {Nat.is_le(Nat.add(c, 4n), U32.to_nat(len)) == True{} : Bool}) -> {Nat.is_le(Nat.add(Nat.add(c, x), 4n), A.quad(VB.pw(d))) == True{} : Bool}:
  UR.roomw(x, U32.to_nat(len), c, A.quad(VB.pw(d)), hw, h)

def rdo(@CW, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +h: {Nat.is_le(Nat.add(k, 4n), U32.to_nat(len)) == True{} : Bool})
    -> {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}:
  +hk = FD.nat__le_trans(k, Nat.add(k, 4n), U32.to_nat(len), Order.below_sum(k, 4n), h)
  +eoc = eoj(@CWA, c, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), hk))
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x), FD.logic__subst(Nat, z => {U32.to_nat(U32.add(off, c)) == Nat.add(z, x) : Nat}, U32.to_nat(c), k, ec, eoc),
    FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, room4(@CWA, k, h))

# ---- the validator ----------------------------------------------------------------------------

def c3_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32, +o1: U32) -> {T.@AS_c3(ok, buf, off, len, o0, o1) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def okc2(@CW, +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +dd: Bool, +ed: {D0(t, x, off) == dd : Bool})
    -> {T.@AS_c2(dd, BF(t, n), off, len, O0(t, x), O1(t, x)) == (BF(t, n), ck(dd, D1(t, x, off, len))) : B.Buf & Bool}:
  match dd:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & Bool, T.@C_ok(BF(t, n), W1(t, x, off), L1(t, x, len)), (BF(t, n), D1(t, x, off, len)),
          CH.ok_evalw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf)) :
        {T.@AS_v3(off, len, O0(t, x), O1(t, x), _) == (BF(t, n), D1(t, x, off, len)) : B.Buf & Bool}
      c3_id(D1(t, x, off, len), BF(t, n), off, len, O0(t, x), O1(t, x))

def okc1(@CW, +c: Bool, +ec: {RR(t, x, len) == c : Bool})
    -> {T.@AS_c1(c, BF(t, n), off, len, O0(t, x), O1(t, x)) == (BF(t, n), ck(c, ck(D0(t, x, off), D1(t, x, off, len)))) : B.Buf & Bool}:
  match c:
    case False{}: {==}
    case True{}:
      +h01 = le_nat(O0(t, x), O1(t, x), FD.logic__and_left(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), ec))
      +h1n = le_nat(O1(t, x), len, FD.logic__and_right(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), ec))
      %Equal.sym(B.Buf & Bool, T.@C_ok(BF(t, n), W0(t, x, off), L0(t, x)), (BF(t, n), D0(t, x, off)),
          CH.ok_evalw(d, t, n, J0(t, x), W0(t, x, off), L0(t, x), eoj(@CWA, O0(t, x), FD.nat__le_trans(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x)), U32.to_nat(len), h01, h1n)), hd,
            hwj(@CWA, O0(t, x), O1(t, x), h01, h1n), pf)) :
        {T.@AS_v2(off, len, O0(t, x), O1(t, x), _) == (BF(t, n), ck(True{}, ck(D0(t, x, off), D1(t, x, off, len)))) : B.Buf & Bool}
      okc2(@CWA, h01, h1n, D0(t, x, off), {==})

def okc0(@CW, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}, +b: Bool, +eb: {U32.is_eq(O0(t, x), 8) == b : Bool})
    -> {T.@AS_c0(b, BF(t, n), off, len, O0(t, x)) == (BF(t, n), ck(b, ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 4)), (BF(t, n), O1(t, x)), rdo(@CWA, 4, 4n, {==}, h8)) :
        {T.@AS_v1(off, len, O0(t, x), _) == (BF(t, n), ck(True{}, ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) : B.Buf & Bool}
      okc1(@CWA, RR(t, x, len), {==})

def okl(@CW, +a: Bool, +ea: {U32.is_le(8, len) == a : Bool})
    -> {T.@AS_ok_len(a, BF(t, n), off, len) == (BF(t, n), ck(a, ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      +h8 = le_nat(8, len, ea)
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 0)), (BF(t, n), O0(t, x)), rdo(@CWA, 0, 0n, {==}, FD.nat__le_trans(4n, 8n, U32.to_nat(len), {==}, h8))) :
        {T.@AS_v0(off, len, _) == (BF(t, n), ck(True{}, ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))))) : B.Buf & Bool}
      okc0(@CWA, h8, U32.is_eq(O0(t, x), 8), {==})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(@CW) -> {T.@AS_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  okl(@CWA, U32.is_le(8, len), {==})

# ---- the reader ---------------------------------------------------------------------------------

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@AS:
  T.@AS{O.BSome{CH.OBJw(d, t, J0(t, x), W0(t, x, off), L0(t, x)), O.BNone{}}, O.BSome{CH.OBJw(d, t, J1(t, x), W1(t, x, off), L1(t, x, len)), O.BNone{}}}

def rd_go(@CW, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +hk0: {D0(t, x, off) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool})
    -> {T.@AS_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}:
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 0)), (BF(t, n), O0(t, x)), rdo(@CWA, 0, 0n, {==}, FD.nat__le_trans(4n, 8n, U32.to_nat(len), {==}, h8))) :
    {T.@AS_rd0(off, len, _) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 4)), (BF(t, n), O1(t, x)), rdo(@CWA, 4, 4n, {==}, h8)) :
    {T.@AS_rd1(off, len, O0(t, x), _) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  %Equal.sym(B.Buf & T.@C, T.@C_read(BF(t, n), W0(t, x, off), L0(t, x)), (BF(t, n), CH.OBJw(d, t, J0(t, x), W0(t, x, off), L0(t, x))),
      CH.readw(d, t, n, J0(t, x), W0(t, x, off), L0(t, x), eoj(@CWA, O0(t, x), FD.nat__le_trans(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x)), U32.to_nat(len), h01, h1n)), hd,
        hwj(@CWA, O0(t, x), O1(t, x), h01, h1n), pf, hk0)) :
    {T.@AS_rd2(off, len, O0(t, x), O1(t, x), T.@C_bx_rd(_)) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  %Equal.sym(B.Buf & T.@C, T.@C_read(BF(t, n), W1(t, x, off), L1(t, x, len)), (BF(t, n), CH.OBJw(d, t, J1(t, x), W1(t, x, off), L1(t, x, len))),
      CH.readw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf, hk1)) :
    {T.@AS_rd3(off, len, O0(t, x), O1(t, x), O.BSome{CH.OBJw(d, t, J0(t, x), W0(t, x, off), L0(t, x)), O.BNone{}}, T.@C_bx_rd(_)) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  {==}

# The reader on the window, when the checks hold.
def readw(@CW, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {T.@AS_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}:
  +r1 = ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))
  +r2 = ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))
  +r3 = ck(D0(t, x, off), D1(t, x, off, len))
  +h1 = ck_b(U32.is_le(8, len), r1, hchk)
  +h2 = ck_b(U32.is_eq(O0(t, x), 8), r2, h1)
  +h3 = ck_b(RR(t, x, len), r3, h2)
  +hr = ck_a(RR(t, x, len), r3, h2)
  rd_go(@CWA, le_nat(8, len, ck_a(U32.is_le(8, len), r1, hchk)),
    le_nat(O0(t, x), O1(t, x), FD.logic__and_left(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    le_nat(O1(t, x), len, FD.logic__and_right(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    ck_a(D0(t, x, off), D1(t, x, off, len), h3), ck_b(D0(t, x, off), D1(t, x, off, len), h3))

# ---- the spec side ------------------------------------------------------------------------------

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:
  S.Sequence{S.Items{CH.VALw(t, J0(t, x), L0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}

def A0(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub(O1(t, x), 8)
def Y0(+t: FD.array__Tree<U32>, +x: Nat) -> +List<U32>: UW.WX(t, 8n+x, U32.to_nat(A0(t, x)))
def Y1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<U32>: UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len)))
def PL(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<S.Part>: [S.Variable{Y0(t, x)}, S.Variable{Y1(t, x, len)}]
def LS(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(PL(t, x, len), 8n), Layout.payloads(PL(t, x, len)))

# O1 = 8 + (O1 - 8)
def eO1(+t: FD.array__Tree<U32>, +x: Nat, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool})
    -> {U32.to_nat(O1(t, x)) == Nat.add(8n, U32.to_nat(A0(t, x))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(A0(t, x)), Nat.sub(U32.to_nat(O1(t, x)), 8n), FD.u32__sub_nat(O1(t, x), 8, h81)) : {U32.to_nat(O1(t, x)) == Nat.add(8n, _) : Nat}
  Equal.sym(Nat, Nat.add(8n, Nat.sub(U32.to_nat(O1(t, x)), 8n)), U32.to_nat(O1(t, x)), FD.nat__sub_add(U32.to_nat(O1(t, x)), 8n, h81))

# len = 8 + ((O1 - 8) + (len - O1))
def elen(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool},
    +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(len) == Nat.add(8n, Nat.add(U32.to_nat(A0(t, x)), U32.to_nat(L1(t, x, len)))) : Nat}:
  %FD.nat__add_assoc(8n, U32.to_nat(A0(t, x)), U32.to_nat(L1(t, x, len))) : {U32.to_nat(len) == _ : Nat}
  %Equal.sym(Nat, Nat.add(8n, U32.to_nat(A0(t, x))), U32.to_nat(O1(t, x)), Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, U32.to_nat(A0(t, x))), eO1(t, x, h81))) :
    {U32.to_nat(len) == Nat.add(_, U32.to_nat(L1(t, x, len))) : Nat}
  %Equal.sym(Nat, U32.to_nat(L1(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), FD.u32__sub_nat(len, O1(t, x), h1n)) :
    {U32.to_nat(len) == Nat.add(U32.to_nat(O1(t, x)), _) : Nat}
  Equal.sym(Nat, Nat.add(U32.to_nat(O1(t, x)), Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x)))), U32.to_nat(len), FD.nat__sub_add(U32.to_nat(len), U32.to_nat(O1(t, x)), h1n))

# The second window starts right after the first.
def eJ1(+t: FD.array__Tree<U32>, +x: Nat, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool})
    -> {Nat.add(U32.to_nat(A0(t, x)), 8n+x) == J1(t, x) : Nat}:
  %Equal.sym(Nat, Nat.add(U32.to_nat(A0(t, x)), 8n+x), Nat.add(8n, Nat.add(U32.to_nat(A0(t, x)), x)), FD.lru_nat_algebra__add_swap(U32.to_nat(A0(t, x)), 8n, x)) : {_ == J1(t, x) : Nat}
  %Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, U32.to_nat(A0(t, x))), eO1(t, x, h81)) : {Nat.add(8n, Nat.add(U32.to_nat(A0(t, x)), x)) == Nat.add(_, x) : Nat}
  {==}

def hw8(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(8n+x, U32.to_nat(A0(t, x))), A.quad(VB.pw(d))) == True{} : Bool}:
  hwj(@CWA, 8, O1(t, x), h81, h1n)

# The spec encoding of the two windows is the window.
def enc8(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +e0: {O0(t, x) == 8 : U32})
    -> {LS(t, x, len) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}:
  +a0 = U32.to_nat(A0(t, x))
  +a1 = U32.to_nat(L1(t, x, len))
  +el = elen(t, x, len, h81, h1n)
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(8n, Nat.add(a0, a1)), el, hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(8n, Nat.add(a0, a1)), el) : {LS(t, x, len) == UW.WX(t, x, _) : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(2n), Nat.add(a0, a1))), List.append(&2, U32, F.limbs(UR.RWS(2n, t, x)), UW.WX(t, Nat.add(A.quad(2n), x), Nat.add(a0, a1))),
      UW.headWX(d, t, x, 2n, Nat.add(a0, a1), pf, hw2)) :
    {LS(t, x, len) == _ : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, 8n+x, Nat.add(a0, a1)), List.append(&2, U32, Y0(t, x), UW.WX(t, Nat.add(a0, 8n+x), a1)), UW.splitWX(t, 8n+x, a0, a1)) :
    {LS(t, x, len) == List.append(&2, U32, F.limbs(UR.RWS(2n, t, x)), _) : +List<U32>}
  %Equal.sym(Nat, Nat.add(a0, 8n+x), J1(t, x), eJ1(t, x, h81)) :
    {LS(t, x, len) == List.append(&2, U32, F.limbs(UR.RWS(2n, t, x)), List.append(&2, U32, Y0(t, x), UW.WX(t, _, a1))) : +List<U32>}
  %Equal.sym(U32, O0(t, x), 8, e0) :
    {LS(t, x, len) == List.append(&2, U32, F.limbs([_, O1(t, x)]), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %VG.digits_limb(O1(t, x)) :
    {LS(t, x, len) == List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, _, [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, a0), eO1(t, x, h81)) :
    {LS(t, x, len) == List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, N.digits(4n, _), [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %Equal.sym(Nat, List.length(&2, U32, Y0(t, x)), a0, UW.lenWX(d, t, 8n+x, a0, pf, hw8(@CWA, h81, h1n))) :
    {List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, _)), [])), List.append(&2, U32, Y0(t, x), List.append(&2, U32, Y1(t, x, len), []))) ==
      List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, N.digits(4n, Nat.add(8n, a0)), [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y1(t, x, len), []), Y1(t, x, len), VS.app_nil(Y1(t, x, len))) :
    {List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, a0)), [])), List.append(&2, U32, Y0(t, x), _)) ==
      List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, N.digits(4n, Nat.add(8n, a0)), [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  {==}

# The payloads' length.
def lpay(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(len) == Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))) : Nat}:
  +a0 = U32.to_nat(A0(t, x))
  +a1 = U32.to_nat(L1(t, x, len))
  +hw1 = hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len)))
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y0(t, x), List.append(&2, U32, Y1(t, x, len), []))), Nat.add(List.length(&2, U32, Y0(t, x)), List.length(&2, U32, List.append(&2, U32, Y1(t, x, len), []))),
      VS.len_app(Y0(t, x), List.append(&2, U32, Y1(t, x, len), []))) : {U32.to_nat(len) == Nat.add(8n, _) : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y1(t, x, len), []), Y1(t, x, len), VS.app_nil(Y1(t, x, len))) : {U32.to_nat(len) == Nat.add(8n, Nat.add(List.length(&2, U32, Y0(t, x)), List.length(&2, U32, _))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, Y0(t, x)), a0, UW.lenWX(d, t, 8n+x, a0, pf, hw8(@CWA, h81, h1n))) : {U32.to_nat(len) == Nat.add(8n, Nat.add(_, List.length(&2, U32, Y1(t, x, len)))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, Y1(t, x, len)), a1, UW.lenWX(d, t, J1(t, x), a1, pf, hw1)) : {U32.to_nat(len) == Nat.add(8n, Nat.add(a0, _)) : Nat}
  elen(t, x, len, h81, h1n)

# Definitions per step: a container's parts one step down and one field before the rest, over opaque values
# (a conversion that is not a syntactic match would evaluate the fields' parts).
def gcv_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +y: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Variable{y} <> rest} : Maybe<&2, +List<S.Part>>}:
  VS.cat_var(Codec.parts(v, s), y, Codec.parts(vs, rs), rest, ea, eb)

def gcf_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +xs: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}:
  F.cat_fixed(Codec.parts(v, s), xs, Codec.parts(vs, rs), rest, ea, eb)

def vw0(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {S.Sequence{S.Items{CH.VALw(t, J0(t, x), L0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}} == VALw(t, x, len) : S.Value}:
  {==}

def j0e(+t: FD.array__Tree<U32>, +x: Nat) -> {Nat.add(U32.to_nat(O0(t, x)), x) == J0(t, x) : Nat}:
  {==}

def l0e(+t: FD.array__Tree<U32>, +x: Nat) -> {U32.sub(O1(t, x), O0(t, x)) == L0(t, x) : U32}:
  {==}

def e8x(+x: Nat) -> {8n+x == Nat.add(U32.to_nat(8), x) : Nat}:
  {==}

def a0e(+t: FD.array__Tree<U32>, +x: Nat) -> {A0(t, x) == U32.sub(O1(t, x), 8) : U32}:
  {==}

def lct2(+it: S.Value) -> {Codec.aggregate(Codec.parts(it, S.Chain{@SC, S.Chain{@SC, S.End{}}}), None{}) == Codec.parts(S.Sequence{it}, Spec.@AS()) : Maybe<&2, +List<S.Part>>}:
  {==}

def specg8(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +e0: {O0(t, x) == 8 : U32}, +hk0: {CH.CHKw(t, 8n+x, U32.add(off, 8), A0(t, x)) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(S.Sequence{S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +c0 = CH.specw(d, t, n, 8n+x, U32.add(off, 8), A0(t, x), eoj(@CWA, 8, FD.nat__le_trans(8n, U32.to_nat(O1(t, x)), U32.to_nat(len), h81, h1n)), hd, hw8(@CWA, h81, h1n), pf, hk0)
  +c1 = CH.specw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf, hk1)
  +hf = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(len), Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))), lpay(@CWA, h81, h1n),
    VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))
  %enc8(@CWA, h81, h1n, e0) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{_}]} : Maybe<&2, +List<S.Part>>}
  %lct2(S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}) : {_ == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}, S.Chain{@SC, S.Chain{@SC, S.End{}}}), Some{PL(t, x, len)},
      gcv_(CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}, @SC, S.Chain{@SC, S.End{}}, Y0(t, x), [S.Variable{Y1(t, x, len)}], c0,
        gcv_(CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}, @SC, S.End{}, Y1(t, x, len), [], c1, {==}))) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, SP.bytes_domain(Y0(t, x)), True{}, UW.domWX(t, 8n+x, U32.to_nat(A0(t, x)))) :
    {Codec.one(SP.optional(Bool.and(Bool.and(_, Bool.and(SP.bytes_domain(Y1(t, x, len)), True{})), N.fits(4n, Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))))), LS(t, x, len)), None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, SP.bytes_domain(Y1(t, x, len)), True{}, UW.domWX(t, J1(t, x), U32.to_nat(L1(t, x, len)))) :
    {Codec.one(SP.optional(Bool.and(Bool.and(True{}, Bool.and(_, True{})), N.fits(4n, Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))))), LS(t, x, len)), None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len))))), True{}, hf) :
    {Codec.one(SP.optional(Bool.and(True{}, _), LS(t, x, len)), None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  {==}

def specg(@CW, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}, +e0: {O0(t, x) == 8 : U32},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +hk0: {D0(t, x, off) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +h81 = FD.logic__subst(U32, z => {Nat.is_le(U32.to_nat(z), U32.to_nat(O1(t, x))) == True{} : Bool}, O0(t, x), 8, e0, h01)
  +hk08 = FD.logic__subst(U32, z => {CH.CHKw(t, Nat.add(U32.to_nat(z), x), U32.add(off, z), U32.sub(O1(t, x), z)) == True{} : Bool}, O0(t, x), 8, e0, hk0)
  %vw0(t, x, len) : {Codec.parts(_, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %j0e(t, x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, _, L0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %l0e(t, x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, Nat.add(U32.to_nat(O0(t, x)), x), _), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(U32, O0(t, x), 8, e0) :
    {Codec.parts(S.Sequence{S.Items{CH.VALw(t, Nat.add(U32.to_nat(_), x), U32.sub(O1(t, x), _)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %e8x(x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, _, U32.sub(O1(t, x), 8)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %a0e(t, x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, 8n+x, _), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  specg8(@CWA, h81, h1n, e0, hk08, hk1)

# The spec parts of the value: one variable part, the window's bytes.
def specw(@CW, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {Codec.parts(VALw(t, x, len), Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +r1 = ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))
  +r2 = ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))
  +r3 = ck(D0(t, x, off), D1(t, x, off, len))
  +h1 = ck_b(U32.is_le(8, len), r1, hchk)
  +h2 = ck_b(U32.is_eq(O0(t, x), 8), r2, h1)
  +h3 = ck_b(RR(t, x, len), r3, h2)
  +hr = ck_a(RR(t, x, len), r3, h2)
  specg(@CWA, le_nat(8, len, ck_a(U32.is_le(8, len), r1, hchk)), FD.u32alg__eq_of(O0(t, x), 8, ck_a(U32.is_eq(O0(t, x), 8), r2, h1)),
    le_nat(O0(t, x), O1(t, x), FD.logic__and_left(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    le_nat(O1(t, x), len, FD.logic__and_right(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    ck_a(D0(t, x, off), D1(t, x, off, len), h3), ck_b(D0(t, x, off), D1(t, x, off, len), h3))

# ---- every value whose spec parts are the window's bytes passes the checks ------------------------

def OUT2(+y0: +List<U32>, +y1: +List<U32>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts([S.Variable{y0}, S.Variable{y1}], 8n), Layout.payloads([S.Variable{y0}, S.Variable{y1}]))

def lOUT(+y0: +List<U32>, +y1: +List<U32>)
    -> {List.length(&2, U32, OUT2(y0, y1)) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, y0, List.append(&2, U32, y1, []))), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, List.append(&2, U32, y1, []))), VS.len_app(y0, List.append(&2, U32, y1, []))) :
    {Nat.add(8n, _) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, y1, []), y1, VS.app_nil(y1)) : {Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, _))) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  {==}

def chk_all(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}, +e0: {O0(t, x) == 8 : U32},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +hk0: {D0(t, x, off) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool}) -> {CHKw(t, x, off, len) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(8, len), True{}, u32le(8, len, h8)) :
    {ck(_, ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(O0(t, x), 8), True{}, FD.u32alg__eq_true(O0(t, x), 8, e0)) :
    {ck(True{}, ck(_, ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(O0(t, x), O1(t, x)), True{}, u32le(O0(t, x), O1(t, x), h01)) :
    {ck(True{}, ck(True{}, ck(Bool.and(_, U32.is_le(O1(t, x), len)), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(O1(t, x), len), True{}, u32le(O1(t, x), len, h1n)) :
    {ck(True{}, ck(True{}, ck(Bool.and(True{}, _), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, D0(t, x, off), True{}, hk0) : {ck(True{}, ck(True{}, ck(True{}, ck(_, D1(t, x, off, len))))) == True{} : Bool}
  hk1

def cn_en(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {U32.to_nat(len) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}:
  Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, OUT2(y0, y1)), Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), OUT2(y0, y1), Equal.sym(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq)), lOUT(y0, y1)))

def cn_w4(+y0: +List<U32>, +y1: +List<U32>) -> {VS.bt(4n, OUT2(y0, y1)) == [8, 0, 0, 0] : +List<U32>}:
  {==}

def cn_d1(+y0: +List<U32>, +y1: +List<U32>) -> {VS.bt(4n, VS.bdr(4n, OUT2(y0, y1))) == N.digits(4n, Nat.add(8n, List.length(&2, U32, y0))) : +List<U32>}:
  {==}

def cn_p8(+y0: +List<U32>, +y1: +List<U32>) -> {VS.bdr(8n, OUT2(y0, y1)) == List.append(&2, U32, y0, List.append(&2, U32, y1, [])) : +List<U32>}:
  {==}

def cn_b0(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}) -> {F.limbs([O0(t, x)]) == [8, 0, 0, 0] : +List<U32>}:
  +hP = FD.nat__le_trans(Nat.add(x, 8n), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, 8n, U32.to_nat(len), h8), hw)
  Equal.trans(+List<U32>, F.limbs([O0(t, x)]), UW.WX(t, x, 4n), [8, 0, 0, 0],
    UR.rwn_bytes(d, t, x, pf, FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, 8n), A.quad(VB.pw(d)), Order.add_left(x, 4n, 8n, {==}), hP)),
    Equal.trans(+List<U32>, UW.WX(t, x, 4n), VS.bt(4n, UW.WX(t, x, U32.to_nat(len))), [8, 0, 0, 0],
      Equal.sym(+List<U32>, VS.bt(4n, UW.WX(t, x, U32.to_nat(len))), UW.WX(t, x, 4n), UW.btWX(t, x, 4n, U32.to_nat(len), FD.nat__le_trans(4n, 8n, U32.to_nat(len), {==}, h8))),
      Equal.trans(+List<U32>, VS.bt(4n, UW.WX(t, x, U32.to_nat(len))), VS.bt(4n, OUT2(y0, y1)), [8, 0, 0, 0],
        Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), UW.WX(t, x, U32.to_nat(len)), OUT2(y0, y1), Equal.sym(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq)),
        cn_w4(y0, y1))))

def cn_b1(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}) -> {I.limb(O1(t, x)) == N.digits(4n, Nat.add(8n, List.length(&2, U32, y0))) : +List<U32>}:
  +D = N.digits(4n, Nat.add(8n, List.length(&2, U32, y0)))
  Equal.trans(+List<U32>, I.limb(O1(t, x)), F.limbs([O1(t, x)]), D, Equal.sym(+List<U32>, F.limbs([O1(t, x)]), I.limb(O1(t, x)), VS.app_nil(I.limb(O1(t, x)))),
    Equal.trans(+List<U32>, F.limbs([O1(t, x)]), UW.WX(t, 4n+x, 4n), D,
      UR.rwn_bytes(d, t, 4n+x, pf, UR.roomw(x, U32.to_nat(len), 4n, A.quad(VB.pw(d)), hw, h8)),
      Equal.trans(+List<U32>, UW.WX(t, 4n+x, 4n), VS.bt(4n, VS.bdr(4n, UW.WX(t, x, U32.to_nat(len)))), D,
        Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(4n, UW.WX(t, x, U32.to_nat(len)))), UW.WX(t, 4n+x, 4n), UW.subWX(t, x, 4n, 4n, U32.to_nat(len), h8)),
        Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(4n, UW.WX(t, x, U32.to_nat(len)))), VS.bt(4n, VS.bdr(4n, OUT2(y0, y1))), D,
          Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(4n, z)), UW.WX(t, x, U32.to_nat(len)), OUT2(y0, y1), Equal.sym(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq)),
          cn_d1(y0, y1)))))

def cn_ey0(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +le8y0: {Nat.is_le(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len)) == True{} : Bool})
    -> {y0 == UW.WX(t, 8n+x, List.length(&2, U32, y0)) : +List<U32>}:
  +ly0 = List.length(&2, U32, y0)
  Equal.trans(+List<U32>, y0, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), UW.WX(t, 8n+x, ly0),
    Equal.sym(+List<U32>, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), y0,
      Equal.trans(+List<U32>, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), VS.bt(ly0, List.append(&2, U32, y0, List.append(&2, U32, y1, []))), y0,
        Equal.cong(+List<U32>, +List<U32>, z => VS.bt(ly0, z), VS.bdr(8n, OUT2(y0, y1)), List.append(&2, U32, y0, List.append(&2, U32, y1, [])), cn_p8(y0, y1)),
        Equal.trans(+List<U32>, VS.bt(ly0, List.append(&2, U32, y0, List.append(&2, U32, y1, []))), VS.bt(ly0, y0), y0,
          VN.bt_app(ly0, y0, List.append(&2, U32, y1, []), FD.nat__le_refl(ly0)), UW.bt_self(y0)))),
    Equal.trans(+List<U32>, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), VS.bt(ly0, VS.bdr(8n, UW.WX(t, x, U32.to_nat(len)))), UW.WX(t, 8n+x, ly0),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(ly0, VS.bdr(8n, z)), OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq), UW.subWX(t, x, 8n, ly0, U32.to_nat(len), le8y0)))

def cn_ey1(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +en2: {U32.to_nat(len) == Nat.add(Nat.add(8n, List.length(&2, U32, y0)), List.length(&2, U32, y1)) : Nat})
    -> {y1 == UW.WX(t, Nat.add(Nat.add(8n, List.length(&2, U32, y0)), x), List.length(&2, U32, y1)) : +List<U32>}:
  +ly0 = List.length(&2, U32, y0)
  +ly1 = List.length(&2, U32, y1)
  +R1 = List.append(&2, U32, y1, [])
  Equal.trans(+List<U32>, y1, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
    Equal.sym(+List<U32>, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), y1,
      Equal.trans(+List<U32>, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), VS.bdr(ly0, VS.bdr(8n, OUT2(y0, y1))), y1, VN.bdr_add(8n, ly0, OUT2(y0, y1)),
        Equal.trans(+List<U32>, VS.bdr(ly0, VS.bdr(8n, OUT2(y0, y1))), VS.bdr(ly0, List.append(&2, U32, y0, R1)), y1,
          Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(ly0, z), VS.bdr(8n, OUT2(y0, y1)), List.append(&2, U32, y0, R1), cn_p8(y0, y1)),
          Equal.trans(+List<U32>, VS.bdr(ly0, List.append(&2, U32, y0, R1)), R1, y1, VS.bdr_app(y0, R1), VS.app_nil(y1))))),
    Equal.trans(+List<U32>, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), VS.bdr(Nat.add(8n, ly0), UW.WX(t, x, Nat.add(Nat.add(8n, ly0), ly1))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(Nat.add(8n, ly0), z), OUT2(y0, y1), UW.WX(t, x, Nat.add(Nat.add(8n, ly0), ly1)),
        Equal.trans(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), UW.WX(t, x, Nat.add(Nat.add(8n, ly0), ly1)), eq, Equal.cong(Nat, +List<U32>, z => UW.WX(t, x, z), U32.to_nat(len), Nat.add(Nat.add(8n, ly0), ly1), en2))),
      UW.tailWX(t, x, Nat.add(8n, ly0), ly1)))

def cn_e1(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}, +le8y0: {Nat.is_le(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(O1(t, x)) == Nat.add(8n, List.length(&2, U32, y0)) : Nat}:
  +h8 = FD.nat__le_trans(8n, Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), Order.below_sum(8n, List.length(&2, U32, y0)), le8y0)
  VG.digits_word(O1(t, x), Nat.add(8n, List.length(&2, U32, y0)),
    VFT.fits4(2n+d, Nat.add(8n, List.length(&2, U32, y0)), FD.nat__le_trans(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), A.quad(VB.pw(d)), le8y0, hlen(d, x, len, hw)), FD.nat__lt_trans(d, 28n, 30n, hd, {==})),
    cn_b1(@CWA, y0, y1, eq, h8))

def cn_hk0(@CW, +h0: S.Value, +y0: +List<U32>, +eh0: {Codec.parts(h0, @S) == Some{[S.Variable{y0}]} : Maybe<&2, +List<S.Part>>}, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +le8y0: {Nat.is_le(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len)) == True{} : Bool}, +e0: {O0(t, x) == 8 : U32},
    +e1: {U32.to_nat(O1(t, x)) == Nat.add(8n, List.length(&2, U32, y0)) : Nat},
    +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}) -> {D0(t, x, off) == True{} : Bool}:
  +ly0 = List.length(&2, U32, y0)
  +eL0 = Equal.trans(Nat, U32.to_nat(L0(t, x)), U32.to_nat(U32.sub(O1(t, x), 8)), ly0,
    Equal.cong(U32, Nat, z => U32.to_nat(U32.sub(O1(t, x), z)), O0(t, x), 8, e0),
    Equal.trans(Nat, U32.to_nat(U32.sub(O1(t, x), 8)), Nat.sub(U32.to_nat(O1(t, x)), 8n), ly0, FD.u32__sub_nat(O1(t, x), 8, h81),
      Equal.trans(Nat, Nat.sub(U32.to_nat(O1(t, x)), 8n), Nat.sub(Nat.add(8n, ly0), 8n), ly0, Equal.cong(Nat, Nat, z => Nat.sub(z, 8n), U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1),
        FD.nat__add_sub_cancel(8n, ly0))))
  +eJ0 = Equal.cong(U32, Nat, z => Nat.add(U32.to_nat(z), x), O0(t, x), 8, e0)
  +ew0 = Equal.trans(+List<U32>, y0, UW.WX(t, 8n+x, ly0), UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), cn_ey0(@CWA, y0, y1, eq, le8y0),
    Equal.sym(+List<U32>, UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), UW.WX(t, 8n+x, ly0),
      Equal.trans(+List<U32>, UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), UW.WX(t, 8n+x, U32.to_nat(L0(t, x))), UW.WX(t, 8n+x, ly0),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, z, U32.to_nat(L0(t, x))), J0(t, x), 8n+x, eJ0),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, 8n+x, z), U32.to_nat(L0(t, x)), ly0, eL0))))
  CH.invw(d, t, n, J0(t, x), W0(t, x, off), L0(t, x), eoj(@CWA, O0(t, x), FD.nat__le_trans(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x)), U32.to_nat(len), h01, h1n)), hd,
    hwj(@CWA, O0(t, x), O1(t, x), h01, h1n), pf, h0,
    FD.logic__subst(+List<U32>, z => {Codec.parts(h0, @S) == Some{[S.Variable{z}]} : Maybe<&2, +List<S.Part>>}, y0, UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), ew0, eh0))

def cn_hk1(@CW, +y0: +List<U32>, +h1: S.Value, +y1: +List<U32>, +eh1: {Codec.parts(h1, @S) == Some{[S.Variable{y1}]} : Maybe<&2, +List<S.Part>>}, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +en: {U32.to_nat(len) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat},
    +e1: {U32.to_nat(O1(t, x)) == Nat.add(8n, List.length(&2, U32, y0)) : Nat},
    +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool}) -> {D1(t, x, off, len) == True{} : Bool}:
  +ly0 = List.length(&2, U32, y0)
  +ly1 = List.length(&2, U32, y1)
  +en2 = Equal.trans(Nat, U32.to_nat(len), Nat.add(8n, Nat.add(ly0, ly1)), Nat.add(Nat.add(8n, ly0), ly1), en, Equal.sym(Nat, Nat.add(Nat.add(8n, ly0), ly1), Nat.add(8n, Nat.add(ly0, ly1)), FD.nat__add_assoc(8n, ly0, ly1)))
  +eL1 = Equal.trans(Nat, U32.to_nat(L1(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), ly1, FD.u32__sub_nat(len, O1(t, x), h1n),
    Equal.trans(Nat, Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), Nat.sub(Nat.add(Nat.add(8n, ly0), ly1), Nat.add(8n, ly0)), ly1,
      Equal.trans(Nat, Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), Nat.sub(U32.to_nat(len), Nat.add(8n, ly0)), Nat.sub(Nat.add(Nat.add(8n, ly0), ly1), Nat.add(8n, ly0)),
        Equal.cong(Nat, Nat, z => Nat.sub(U32.to_nat(len), z), U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1),
        Equal.cong(Nat, Nat, z => Nat.sub(z, Nat.add(8n, ly0)), U32.to_nat(len), Nat.add(Nat.add(8n, ly0), ly1), en2)),
      FD.nat__add_sub_cancel(Nat.add(8n, ly0), ly1)))
  +ew1 = Equal.trans(+List<U32>, y1, UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1), UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), cn_ey1(@CWA, y0, y1, eq, en2),
    Equal.sym(+List<U32>, UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
      Equal.trans(+List<U32>, UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), U32.to_nat(L1(t, x, len))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(z, x), U32.to_nat(L1(t, x, len))), U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(Nat.add(8n, ly0), x), z), U32.to_nat(L1(t, x, len)), ly1, eL1))))
  CH.invw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf, h1,
    FD.logic__subst(+List<U32>, z => {Codec.parts(h1, @S) == Some{[S.Variable{z}]} : Maybe<&2, +List<S.Part>>}, y1, UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), ew1, eh1))

# The two windows' shapes make every check pass.
def contra(@CW, +h0: S.Value, +y0: +List<U32>, +eh0: {Codec.parts(h0, @S) == Some{[S.Variable{y0}]} : Maybe<&2, +List<S.Part>>},
    +h1: S.Value, +y1: +List<U32>, +eh1: {Codec.parts(h1, @S) == Some{[S.Variable{y1}]} : Maybe<&2, +List<S.Part>>}, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +ly0 = List.length(&2, U32, y0)
  +ly1 = List.length(&2, U32, y1)
  +en = cn_en(@CWA, y0, y1, eq)
  +le8y0 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(8n, ly0), z) == True{} : Bool}, Nat.add(8n, Nat.add(ly0, ly1)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(8n, Nat.add(ly0, ly1)), en),
    Order.add_left(8n, ly0, Nat.add(ly0, ly1), FD.nat__le_add_right(ly0, ly1)))
  +h8 = FD.nat__le_trans(8n, Nat.add(8n, ly0), U32.to_nat(len), Order.below_sum(8n, ly0), le8y0)
  +e0 = VN.wordc(O0(t, x), 8, cn_b0(@CWA, y0, y1, eq, h8))
  +e1 = cn_e1(@CWA, y0, y1, eq, le8y0)
  +h81 = FD.logic__subst(Nat, z => {Nat.is_le(8n, z) == True{} : Bool}, Nat.add(8n, ly0), U32.to_nat(O1(t, x)), Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1), Order.below_sum(8n, ly0))
  +h1n = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, Nat.add(8n, ly0), U32.to_nat(O1(t, x)), Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1), le8y0)
  +h01 = FD.logic__subst(U32, z => {Nat.is_le(U32.to_nat(z), U32.to_nat(O1(t, x))) == True{} : Bool}, 8, O0(t, x), Equal.sym(U32, O0(t, x), 8, e0), h81)
  chk_all(t, x, off, len, h8, e0, h01, h1n, cn_hk0(@CWA, h0, y0, eh0, y1, eq, le8y0, e0, e1, h81, h1n, h01), cn_hk1(@CWA, y0, h1, y1, eh1, eq, en, e1, h1n))

@STAGES
"""


def asx_stages(sch):
    """The inversion stages of ASX's invw (two variable parts of schema sch)."""
    WBL = 'UW.WX(t, x, U32.to_nat(len))'
    MP = 'Maybe<&2, +List<S.Part>>'
    GOAL = '{CHKw(t, x, off, len) == True{} : Bool}'
    L = []
    w = L.append

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

    def CC(parts, X):
        for pp in reversed(parts):
            X = f'Codec.concatenate(Some{{[{pp}]}}, {X})'
        return X

    def E(parts, X):
        return f'{{Codec.aggregate({CC(parts, X)}, None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}'
    chains = [f'S.Chain{{{sch}, S.Chain{{{sch}, S.End{{}}}}}}', f'S.Chain{{{sch}, S.End{{}}}}', 'S.End{}']
    PL2 = '[S.Variable{y0}, S.Variable{y1}]'
    b5 = f'Bool.and(Layout.bytes_valid({PL2}), N.fits(4n, Nat.add(Layout.fixed_size({PL2}), List.length(&2, U32, Layout.payloads({PL2})))))'
    D0 = '+h0: S.Value, +y0: +List<U32>, +eh0: {Codec.parts(h0, ' + sch + ') == Some{[S.Variable{y0}]} : ' + MP + '}'
    D1 = '+h1: S.Value, +y1: +List<U32>, +eh1: {Codec.parts(h1, ' + sch + ') == Some{[S.Variable{y1}]} : ' + MP + '}'
    w(f'def fin(@CW, {D0}, {D1}, +b5: Bool, +e: {{Codec.one(SP.optional(b5, OUT2(y0, y1)), None{{}}) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    w('  match b5:')
    w(f'    case False{{}}: {absurd()}')
    w(f'    case True{{}}: contra(@CWA, h0, y0, eh0, h1, y1, eh1, var_inj(OUT2(y0, y1), {WBL}, e))')
    w('')
    w(f'def st2(@CW, {D0}, {D1}, +items: S.Value, +e: {E(["S.Variable{y0}", "S.Variable{y1}"], "Codec.parts(items, S.End{})")}) -> {GOAL}:')
    L.extend(match_value('items', ('EmptyItems', []), f'fin(@CWA, h0, y0, eh0, h1, y1, eh1, {b5}, e)'))
    w('')
    for i in (1, 0):
        prev = ['S.Variable{y0}'] if i == 1 else []
        pdecl = f'{D0}, ' if i == 1 else ''
        pargs = 'h0, y0, eh0, ' if i == 1 else ''
        nxt = f'Codec.parts(r, {chains[i + 1]})'
        w(f'def vp{i}(@CW, {pdecl}+h: S.Value, +ps: +List<S.Part>, hf: DF.single(None{{}}, ps), +em: {{Codec.parts(h, {sch}) == Some{{ps}} : {MP}}}, +r: S.Value,')
        w(f'    +e: {E(prev, f"Codec.concatenate(Some{{ps}}, {nxt})")}) -> {GOAL}:')
        w('  match ps:')
        w(f'    case Nil{{}}: Empty.absurd({GOAL}, hf)')
        w(f'    case Con{{S.Fixed{{+xs}}, Nil{{}}}}: Empty.absurd({GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))')
        w(f'    case Con{{S.Variable{{+ys}}, Nil{{}}}}: st{i + 1}(@CWA, {pargs}h, ys, em, r, e)')
        w(f'    case Con{{S.Fixed{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)')
        w(f'    case Con{{S.Variable{{+xs}}, Con{{+a2, +b2}}}}: Empty.absurd({GOAL}, hf)')
        w('')
        w(f'def vm{i}(@CW, {pdecl}+h: S.Value, +mm: {MP}, hf: DF.single_result(None{{}}, mm), +em: {{Codec.parts(h, {sch}) == mm : {MP}}}, +r: S.Value,')
        w(f'    +e: {E(prev, f"Codec.concatenate(mm, {nxt})")}) -> {GOAL}:')
        w('  match mm:')
        w(f'    case None{{}}: {absurd()}')
        w(f'    case Some{{+ps}}: vp{i}(@CWA, {pargs}h, ps, hf, em, r, e)')
        w('')
        w(f'def fd{i}(@CW, {pdecl}+h: S.Value, +r: S.Value, +e: {E(prev, f"Codec.concatenate(Codec.parts(h, {sch}), {nxt})")}) -> {GOAL}:')
        w(f'  vm{i}(@CWA, {pargs}h, Codec.parts(h, {sch}), DS.facts(h, {sch}, {{==}}), {{==}}, r, e)')
        w('')
        w(f'def st{i}(@CW, {pdecl}+items: S.Value, +e: {E(prev, f"Codec.parts(items, {chains[i]})")}) -> {GOAL}:')
        L.extend(match_value('items', ('Items', ['h', 'r']), f'fd{i}(@CWA, {pargs}h, r, e)'))
        w('')
    w("# Every value whose spec parts are the window's bytes passes the checks.")
    w(f'def invw(@CW, +v: S.Value, +e: {{Codec.parts(v, Spec.@AS()) == Some{{[S.Variable{{{WBL}}}]}} : {MP}}}) -> {GOAL}:')
    L.extend(match_value('v', ('Sequence', ['items']), 'st0(@CWA, items, e)'))
    return '\n'.join(L)


def asx_deep(text):
    """asx_text at any depth d < 31: offsets below 2^32 from hw32, the children's deep interface."""
    import deep
    P32 = 'FD.spec_common__pow2(32n)'
    reps = [
        ("""  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), A.quad(VB.pw(d)), Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))""",
         f"""  +hl = FD.nat__le_lt_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), {P32}, Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == True{{}} : Bool}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32))
  VB.add_lt32(off, o, x, eo, hl)"""),
        ('VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))',
         f'VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P32}, Order.left_below_sum(x, U32.to_nat(len)), hw32))'),
        ('VFT.fits4(2n+d, Nat.add(8n, List.length(&2, U32, y0)), FD.nat__le_trans(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), A.quad(VB.pw(d)), le8y0, hlen(d, x, len, hw)), FD.nat__lt_trans(d, 28n, 30n, hd, {==}))',
         f'VFT.fits4lt(Nat.add(8n, List.length(&2, U32, y0)), FD.nat__le_lt_trans(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), {P32}, le8y0,\n'
         f'      FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), {P32}, Order.left_below_sum(x, U32.to_nat(len)), hw32)))'),
    ]
    for a, b in reps:
        assert a in text, a[:70]
        text = text.replace(a, b)
    # hwj / hw8 with the window's end below 2^32
    a = text.index('\ndef hwj(')
    b = text.index('\n\n', a + 1)
    hwj = text[a:b]
    hwj32 = (hwj.replace('def hwj(', 'def hwj32(').replace('# ', '# ')
             .replace('Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), A.quad(VB.pw(d)))', f'Nat.is_lt(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), {P32})')
             .replace('{Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), A.quad(VB.pw(d))) == True{} : Bool}', f'{{Nat.is_lt(Nat.add(Nat.add(U32.to_nat(o), x), _), {P32}) == True{{}} : Bool}}')
             .replace('{Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}', f'{{Nat.is_lt(_, {P32}) == True{{}} : Bool}}')
             .replace('FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)',
                      f'FD.nat__le_lt_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), {P32}, Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw32)'))
    assert 'A.quad(VB.pw(d))' not in hwj32[hwj32.index('    -> '):], hwj32
    text = text[:b] + '\n' + hwj32 + text[b:]
    a = text.index('\ndef hw8(')
    b = text.index('\n\n', a + 1)
    hw8 = text[a:b]
    hw832 = (hw8.replace('def hw8(', 'def hw8_32(').replace('Nat.is_le(Nat.add(8n+x, U32.to_nat(A0(t, x))), A.quad(VB.pw(d)))', f'Nat.is_lt(Nat.add(8n+x, U32.to_nat(A0(t, x))), {P32})')
             .replace('hwj(', 'hwj32('))
    text = text[:b] + '\n' + hw832 + text[b:]
    # the children's deep interface
    pat = re.compile(r'CH\.(ok_evalw|readw|specw|invw)\(')
    out, i = [], 0
    while True:
        m = pat.search(text, i)
        if not m:
            out.append(text[i:])
            break
        a = m.end()
        b = deep._close(text, a)
        args = deep._split_args(text[a:b])
        h = args[8].strip()
        assert h.startswith(('hwj(', 'hw8(')), h
        h32 = h.replace('hwj(', 'hwj32(', 1) if h.startswith('hwj(') else h.replace('hw8(', 'hw8_32(', 1)
        args.insert(9, ' ' + h32)
        out.append(text[i:m.start()] + f'CH.{m.group(1)}D(' + ','.join(args) + ')')
        i = b + 1
    return deep_x(''.join(out))


def asx_text(n, c, chmod, sch):
    CW = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},\n'
          '    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},\n'
          '    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    CWA = 'd, t, n, x, off, len, eo, hd, hw, pf'
    body = ASX.replace('@STAGES', asx_stages(sch)).replace('@SC', f'Spec.{c}()').replace('@CWA', CWA).replace('@CW', CW).replace('@AS', n).replace('@C_', f'{c}_').replace('T.@C', f'T.{c}').replace('@S', sch)
    L = HEADX + ['import ../../src/primitives.bend as I', 'import ./vua_rd.bend as UR', f'import ./{chmod} as CH', 'import ./vdig.bend as VG',
                 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF', '',
                 '# GENERATED by codegen/var_win.py. Do not edit.',
                 f'# {n} at a window at any byte offset: the interface of proofs/obj/vua_win.bend.', '']
    return '\n'.join(L) + COMMONX + body


def main():
    VL.SL.EXACT = True   # the exact spec-parts proofs (codegen/spec_laws.py), before any walk
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    out = {}
    defs = spec_defs()
    # the bit lists of the containers
    for n in WIN:
        kids, _ = VL.spec_schemas(n)
        for (fname_, ft), k in zip(names[n].fields, kids):
            if ft.kind == 'bitlist':
                m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[k])
                b = Bits(ft.size, g.shape(ft).p, f'Spec.{k}()', m.group(1))
                out[bits_fname(b)] = bits_text(b)
    src = RR.mono_text('fulu')
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
        pre = '' if big else ''
        wf = ROOT / f'proofs/obj/{pre}var_win_{n}.bend'
        mods[n] = (wf, f'T.{n}', big)
        out[wf] = cont_text(g, x, None, chf.name, f'Spec.{vf["sk"]}()', chrep, None)
        if n not in VL.BITC:
            tf = ROOT / f'proofs/obj/{pre}var_win_{n}_top.bend'
            out[tf] = top_text(x, wf.name, kids, True)
            out[ROOT / f'proofs/obj/{pre}var_win_{n}_unique.bend'] = unique_text(x, tf.name)
    # byte-offset windows
    for n in WINX:
        kids, _ = VL.spec_schemas(n)
        x = WName(g, n, names[n], src, kids)
        vf = x.var
        ft = vf['t']
        if ft.kind == 'bitlist':
            m = re.fullmatch(r'T\.BitList\{(.*)\}', defs[vf['sk']])
            b = Bits(ft.size, g.shape(ft).p, f'Spec.{vf["sk"]}()', m.group(1))
            big = big_bits(b)
            chf, chtext, chrep = bitsx_fname(b), (lambda b=b: bitsx_text(b, deep=True)), 'O.Bits'
        else:
            assert ft.kind == 'list' and ft.elem.kind == 'uint' and ft.elem.size == 8
            m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[vf['sk']])
            big = ft.size >= 1 << 16
            p = g.shape(ft).p
            chf = ROOT / f'proofs/obj/{"" if big else ""}var_winx_{p}.bend'
            chtext = (lambda ft=ft, p=p, m=m, vf=vf: listx_deep_text(ft.size, p, f'Spec.{vf["sk"]}()', f'Spec.{m.group(1)}()', m.group(2)))
            chrep = 'O.Words'
        out[chf] = chtext()
        out[ROOT / f'proofs/obj/{"" if big else ""}var_winx_{n}.bend'] = contx_text(g, x, chf.name, f'Spec.{vf["sk"]}()', chrep)
    # List[uint64, 2^40] (BeaconState's balances, inactivity_scores)
    bkids, _ = VL.spec_schemas('BeaconState')
    bi = [f for f, _ in names['BeaconState'].fields].index('balances')
    bst, bsk = names['BeaconState'].fields[bi][1], bkids[bi]
    m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[bsk])
    out[ROOT / f'proofs/obj/var_winx_{g.shape(bst).p}.bend'] = listx40_text(g.shape(bst).p, f'Spec.{bsk}()', f'Spec.{m.group(1)}()', m.group(2), deep=True)
    bi = [f for f, _ in names['BeaconState'].fields].index('previous_epoch_participation')
    bst, bsk = names['BeaconState'].fields[bi][1], bkids[bi]
    m = re.fullmatch(r'T\.ListOf\{(Schema\d+)\(\), (.*)\}', defs[bsk])
    out[ROOT / f'proofs/obj/var_winx_{g.shape(bst).p}.bend'] = listu8x40_text(g.shape(bst).p, f'Spec.{bsk}()', m.group(2), deep=True)
    # two variable fields of one child (AttesterSlashing)
    kids, _ = VL.spec_schemas('AttesterSlashing')
    out[ROOT / 'proofs/obj/var_winx_AttesterSlashing.bend'] = asx_deep(asx_text('AttesterSlashing', 'IndexedAttestation', 'var_winx_IndexedAttestation.bend', f'Spec.{kids[0]}()'))
    # only files this generator wrote (var_rlist.py writes var_winx_* modules too)
    mine = [q for q in (ROOT / 'proofs/obj').glob('*var_win*.bend') if q.name.startswith(('var_win_', 'var_win_', 'var_winx_', 'var_winx_'))
            and '# GENERATED by codegen/var_win.py' in q.read_text()[:400]]
    orphans = sorted(str(q.relative_to(ROOT)) for q in mine if q not in out)
    out = RR.rewire_out(out)
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
