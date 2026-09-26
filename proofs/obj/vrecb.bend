import Base
import ../../types/generic_obj.bend as T
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vbrt.bend as VR
import ./vdepth.bend as VD
import ./vu32.bend as VU
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as UWD
import ./vuwb.bend as VWB
import ./vrecx.bend as VRX
import ./vrl.bend as VRL
import ./vuwl_u8.bend as W8
import ./vuwl_u16.bend as W16
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/primitives.bend as SP
import ../../spec/codec.bend as Codec
import ../word_facts.bend as WF
import ./vu8.bend as U8
import ./vfx_u16.bend as FXB
import ./pb_min.bend as PBM

# Byte-granular positions and the sub-word leaf writers at a byte position P (hand-written; for
# codegen/var_rec_enc.py's records with uint8 / uint16 fields). A byte position P is the word
# position 4 QP(P) + RP(P) (vuwb.dm4); the leaves are vuwl_u8.W8X / vuwl_u16.W16X there; a record
# of R bytes j of a run at P0 is at pos(j, R, P0) = j R + P0 (vrl.pos).

def QP(+P: Nat) -> Nat: VD.s_rng(2n, P)
def RP(+P: Nat) -> Nat: VWB.MOD4(P)

def eqp(+P: Nat) -> {Nat.add(A.quad(QP(P)), RP(P)) == P : Nat}: VWB.dm4(P)

# The room of m bytes at P, P + m <= 4 2^dd, as the leaves state it.
def roomp(+P: Nat, +m: Nat, +dd: Nat, +h: {Nat.is_le(Nat.add(P, m), A.quad(VB.pw(dd))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(QP(P), UWD.NWN(Nat.add(RP(P), m))), VB.pw(dd)) == True{} : Bool}:
  +q = QP(P)
  +r = RP(P)
  +e2 = Equal.trans(Nat, Nat.add(A.quad(q), Nat.add(r, m)), Nat.add(Nat.add(A.quad(q), r), m), Nat.add(P, m),
    Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), r), m), Nat.add(A.quad(q), Nat.add(r, m)), FD.nat__add_assoc(A.quad(q), r, m)),
    Equal.cong(Nat, Nat, z => Nat.add(z, m), Nat.add(A.quad(q), r), P, eqp(P)))
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(UWD.NWN(z), VB.pw(dd)) == True{} : Bool}, Nat.add(P, m), Nat.add(A.quad(q), Nat.add(r, m)),
    Equal.sym(Nat, Nat.add(A.quad(q), Nat.add(r, m)), Nat.add(P, m), e2), VRX.nwn_le(Nat.add(P, m), VB.pw(dd), h))
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, UWD.NWN(Nat.add(A.quad(q), Nat.add(r, m))), Nat.add(q, UWD.NWN(Nat.add(r, m))),
    VRX.nwn_quad(q, Nat.add(r, m)), h2)

# P <= |BYT D| when P + m bytes fit the tree.
def hxb(+P: Nat, +m: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(P, m), A.quad(VB.pw(dd))) == True{} : Bool})
    -> {Nat.is_le(P, List.length(&2, U32, UA.BYT(D))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(P, z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)),
    Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), VR.lenS(dd, D, pf)),
    FD.nat__le_trans(P, Nat.add(P, m), A.quad(VB.pw(dd)), FD.nat__le_add_right(P, m), h))

def zmove(+P: Nat, +m: Nat, +D: FD.array__Tree<U32>, +hz: {VS.bt(m, VS.bdr(P, UA.BYT(D))) == UW.ZB(m) : +List<U32>})
    -> {VS.bt(m, VS.bdr(Nat.add(A.quad(QP(P)), RP(P)), UA.BYT(D))) == UW.ZB(m) : +List<U32>}:
  FD.logic__subst(Nat, z => {VS.bt(m, VS.bdr(z, UA.BYT(D))) == UW.ZB(m) : +List<U32>}, P, Nat.add(A.quad(QP(P)), RP(P)), Equal.sym(Nat, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P)), hz)

# ---- the leaves at a byte position ----------------------------------------------------------------

def W8P(+dd: Nat, +D: FD.array__Tree<U32>, +P: Nat, +x: U32) -> FD.array__Tree<U32>: W8.W8X(RP(P), dd, D, QP(P), x)
def W16P(+dd: Nat, +D: FD.array__Tree<U32>, +P: Nat, +x: U32) -> FD.array__Tree<U32>: W16.W16X(RP(P), dd, D, QP(P), x)

def w8p_perfect(+dd: Nat, +D: FD.array__Tree<U32>, +P: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, W8P(dd, D, P, x)) == True{} : Bool}:
  W8.w8x_perfect(RP(P), dd, D, QP(P), x, pf)
def w16p_perfect(+dd: Nat, +D: FD.array__Tree<U32>, +P: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, W16P(dd, D, P, x)) == True{} : Bool}:
  W16.w16x_perfect(RP(P), dd, D, QP(P), x, pf)

def w8p_rt(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +P: Nat, +x: U32, +e: {U32.to_nat(X) == P : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P, 1n), A.quad(VB.pw(dd))) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {T.u8_put(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W8P(dd, D, P, x)) : Array<U32>}:
  W8.w8_any(dd, D, X, QP(P), RP(P), x, Equal.trans(Nat, U32.to_nat(X), P, Nat.add(A.quad(QP(P)), RP(P)), e, Equal.sym(Nat, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P))),
    VWB.m4lt(P), hd, roomp(P, 1n, dd, hb), pf)
def w16p_rt(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +P: Nat, +x: U32, +e: {U32.to_nat(X) == P : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P, 2n), A.quad(VB.pw(dd))) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {T.u16_put(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W16P(dd, D, P, x)) : Array<U32>}:
  W16.w16_any(dd, D, X, QP(P), RP(P), x, Equal.trans(Nat, U32.to_nat(X), P, Nat.add(A.quad(QP(P)), RP(P)), e, Equal.sym(Nat, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P))),
    VWB.m4lt(P), hd, roomp(P, 2n, dd, hb), pf)

def w8p_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +P: Nat, +x: U32, +e: {U32.to_nat(X) == P : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P, 1n), A.quad(VB.pw(dd))) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(1n, VS.bdr(P, UA.BYT(D))) == UW.ZB(1n) : +List<U32>})
    -> {UA.BYT(W8P(dd, D, P, x)) == UW.SPL(UA.BYT(D), P, [U32.and(x, 255)]) : +List<U32>}:
  FD.logic__subst(Nat, z => {UA.BYT(W8P(dd, D, P, x)) == UW.SPL(UA.BYT(D), z, [U32.and(x, 255)]) : +List<U32>}, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P),
    W8.w8_any_bytes(dd, D, X, QP(P), RP(P), x, Equal.trans(Nat, U32.to_nat(X), P, Nat.add(A.quad(QP(P)), RP(P)), e, Equal.sym(Nat, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P))),
      VWB.m4lt(P), hd, roomp(P, 1n, dd, hb), pf, zmove(P, 1n, D, hz)))
def w16p_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +P: Nat, +x: U32, +e: {U32.to_nat(X) == P : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P, 2n), A.quad(VB.pw(dd))) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(2n, VS.bdr(P, UA.BYT(D))) == UW.ZB(2n) : +List<U32>})
    -> {UA.BYT(W16P(dd, D, P, x)) == UW.SPL(UA.BYT(D), P, [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) : +List<U32>}:
  FD.logic__subst(Nat, z => {UA.BYT(W16P(dd, D, P, x)) == UW.SPL(UA.BYT(D), z, [U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) : +List<U32>}, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P),
    W16.w16_any_bytes(dd, D, X, QP(P), RP(P), x, Equal.trans(Nat, U32.to_nat(X), P, Nat.add(A.quad(QP(P)), RP(P)), e, Equal.sym(Nat, Nat.add(A.quad(QP(P)), RP(P)), P, eqp(P))),
      VWB.m4lt(P), hd, roomp(P, 2n, dd, hb), pf, zmove(P, 2n, D, hz)))

# ---- fields of a record at P ----------------------------------------------------------------------

# A field of m bytes at byte c of a record of L bytes at P (c + m <= L): its end, and its start, in the tree.
def froomb(+P: Nat, +c: Nat, +m: Nat, +L: Nat, +Q: Nat, +hb: {Nat.is_le(Nat.add(P, L), Q) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(c, m), L) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(c, P), m), Q) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(c, P), m), Nat.add(c, Nat.add(P, m)), Nat.add(P, Nat.add(c, m)), FD.nat__add_assoc(c, P, m), FD.lru_nat_algebra__add_swap(c, P, m))
  FD.logic__subst(Nat, z => {Nat.is_le(z, Q) == True{} : Bool}, Nat.add(P, Nat.add(c, m)), Nat.add(Nat.add(c, P), m), Equal.sym(Nat, Nat.add(Nat.add(c, P), m), Nat.add(P, Nat.add(c, m)), e),
    FD.nat__le_trans(Nat.add(P, Nat.add(c, m)), Nat.add(P, L), Q, Order.add_left(P, Nat.add(c, m), L, hc), hb))
def fltb(+P: Nat, +c: Nat, +L: Nat, +Q: Nat, +hb: {Nat.is_le(Nat.add(P, L), Q) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(c, 1n), L) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(c, P), Q) == True{} : Bool}:
  +x = Nat.add(c, P)
  FD.nat__lt_le_trans(x, Nat.add(x, 1n), Q,
    FD.logic__subst(Nat, z => {Nat.is_lt(x, z) == True{} : Bool}, 1n+x, Nat.add(x, 1n), Equal.sym(Nat, Nat.add(x, 1n), 1n+x, FD.nat__add_comm(x, 1n)), FD.nat__lt_succ(x)),
    froomb(P, c, 1n, L, Q, hb, hc))

# The field's position in the tree, from the record's: U32.add(X, c) is at c + P.
def fposb(+dd: Nat, +X: U32, +c: U32, +P: Nat, +L: Nat, +e: {U32.to_nat(X) == P : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P, L), A.quad(VB.pw(dd))) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(U32.to_nat(c), 1n), L) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, c)) == Nat.add(U32.to_nat(c), P) : Nat}:
  VB.add_at(X, c, P, 2n+dd, e, FD.nat__lt_trans(2n+dd, 31n, 32n, hd, {==}), fltb(P, U32.to_nat(c), L, A.quad(VB.pw(dd)), hb, hc))

# c + P = P + c (the region invariant's position)
def pcx(+P: Nat, +c: Nat) -> {Nat.add(c, P) == Nat.add(P, c) : Nat}: FD.nat__add_comm(c, P)

# ---- runs of records ----------------------------------------------------------------------------

# Record j of R bytes at pos(j, R, P0) = j R + P0; the next one R bytes on.
def pnext(+j: Nat, +R: Nat, +P0: Nat) -> {VRL.pos(1n+j, R, P0) == Nat.add(VRL.pos(j, R, P0), R) : Nat}:
  +M = Nat.mul(j, R)
  Equal.trans(Nat, Nat.add(Nat.add(R, M), P0), Nat.add(R, Nat.add(M, P0)), Nat.add(Nat.add(M, P0), R), FD.nat__add_assoc(R, M, P0), FD.nat__add_comm(R, Nat.add(M, P0)))

# Record j of records j + 1 + k <= LT / R of a run of LT bytes at P0: its end in the tree.
def rroomb(+j: Nat, +k: Nat, +R: Nat, +P0: Nat, +LT: Nat, +Q: Nat, +hj: {Nat.is_le(Nat.mul(Nat.add(1n+k, j), R), LT) == True{} : Bool},
    +hb: {Nat.is_le(Nat.add(P0, LT), Q) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VRL.pos(j, R, P0), R), Q) == True{} : Bool}:
  +M = Nat.mul(j, R)
  +e = Equal.trans(Nat, Nat.add(Nat.add(M, P0), R), Nat.add(M, Nat.add(P0, R)), Nat.add(P0, Nat.add(M, R)), FD.nat__add_assoc(M, P0, R), FD.lru_nat_algebra__add_swap(M, P0, R))
  +e2 = Equal.trans(Nat, Nat.add(Nat.add(M, P0), R), Nat.add(P0, Nat.add(M, R)), Nat.add(P0, Nat.add(R, M)), e,
    Equal.cong(Nat, Nat, z => Nat.add(P0, z), Nat.add(M, R), Nat.add(R, M), FD.nat__add_comm(M, R)))
  +h1 = FD.nat__le_trans(Nat.mul(1n+j, R), Nat.mul(Nat.add(1n+k, j), R), LT, VRL.mul_mono(1n+j, Nat.add(1n+k, j), R, Order.left_below_sum(k, j)), hj)
  FD.logic__subst(Nat, z => {Nat.is_le(z, Q) == True{} : Bool}, Nat.add(P0, Nat.add(R, M)), Nat.add(Nat.add(M, P0), R), Equal.sym(Nat, Nat.add(Nat.add(M, P0), R), Nat.add(P0, Nat.add(R, M)), e2),
    FD.nat__le_trans(Nat.add(P0, Nat.add(R, M)), Nat.add(P0, LT), Q, Order.add_left(P0, Nat.add(R, M), LT, h1), hb))

# The runtime's position of record j (index i), X + i R, is pos(j, R, P0).
def posb(+dd: Nat, +X: U32, +i: U32, +j: Nat, +Ru: U32, +R: Nat, +P0: Nat, +eR: {U32.to_nat(Ru) == R : Nat}, +e: {U32.to_nat(X) == P0 : Nat},
    +ei: {U32.to_nat(i) == j : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(VRL.pos(j, R, P0), R), A.quad(VB.pw(dd))) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, U32.mul(i, Ru))) == VRL.pos(j, R, P0) : Nat}:
  +hd2 = FD.nat__lt_trans(2n+dd, 31n, 32n, hd, {==})
  +Q = A.quad(VB.pw(dd))
  +hp = FD.nat__le_trans(VRL.pos(j, R, P0), Nat.add(VRL.pos(j, R, P0), R), Q, FD.nat__le_add_right(VRL.pos(j, R, P0), R), hb)
  +hmQ = FD.nat__le_trans(Nat.mul(j, R), VRL.pos(j, R, P0), Q, FD.nat__le_add_right(Nat.mul(j, R), P0), hp)
  +em = Equal.trans(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, U32.to_nat(Ru)), Nat.mul(j, R),
    Equal.cong(Nat, Nat, z => Nat.mul(z, U32.to_nat(Ru)), U32.to_nat(i), j, ei),
    Equal.cong(Nat, Nat, z => Nat.mul(j, z), U32.to_nat(Ru), R, eR))
  +e2 = Equal.trans(Nat, U32.to_nat(U32.mul(i, Ru)), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, R),
    VU.mul_le(i, Ru, FD.u32__pow2u(2n+dd),
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), z) == True{} : Bool}, Q, U32.to_nat(FD.u32__pow2u(2n+dd)),
        Equal.sym(Nat, U32.to_nat(FD.u32__pow2u(2n+dd)), Q, FD.u32__pow2u_value(2n+dd, hd2)),
        FD.logic__subst(Nat, z => {Nat.is_le(z, Q) == True{} : Bool}, Nat.mul(j, R), Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Equal.sym(Nat, Nat.mul(U32.to_nat(i), U32.to_nat(Ru)), Nat.mul(j, R), em), hmQ))),
    em)
  +e3 = VB.add_le_at(X, U32.mul(i, Ru), P0, 2n+dd, e, hd,
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, P0), Q) == True{} : Bool}, Nat.mul(j, R), U32.to_nat(U32.mul(i, Ru)), Equal.sym(Nat, U32.to_nat(U32.mul(i, Ru)), Nat.mul(j, R), e2), hp))
  Equal.trans(Nat, U32.to_nat(U32.add(X, U32.mul(i, Ru))), Nat.add(U32.to_nat(U32.mul(i, Ru)), P0), VRL.pos(j, R, P0), e3,
    Equal.cong(Nat, Nat, z => Nat.add(z, P0), U32.to_nat(U32.mul(i, Ru)), Nat.mul(j, R), e2))

# A splice of Y and then the p zeros after it.
def spl_pad(+B: +List<U32>, +X: Nat, +Y: +List<U32>, +a: Nat, +p: Nat, +eY: {List.length(&2, U32, Y) == a : Nat},
    +hz: {VS.bt(Nat.add(a, p), VS.bdr(X, B)) == UW.ZB(Nat.add(a, p)) : +List<U32>})
    -> {UW.SPL(B, X, Y) == UW.SPL(B, X, List.append(&2, U32, Y, UW.ZB(p))) : +List<U32>}:
  +z1 = UWD.zsuf(a, p, VS.bdr(X, B), hz)
  +z2 = FD.logic__subst(+List<U32>, w => {VS.bt(p, w) == UW.ZB(p) : +List<U32>}, VS.bdr(a, VS.bdr(X, B)), VS.bdr(Nat.add(X, a), B), Equal.sym(+List<U32>, VS.bdr(Nat.add(X, a), B), VS.bdr(a, VS.bdr(X, B)), UW.bdr_add(X, a, B)), z1)
  UWD.spl_ext(B, X, Y, p, FD.logic__subst(Nat, w => {VS.bt(p, VS.bdr(Nat.add(X, w), B)) == UW.ZB(p) : +List<U32>}, a, List.length(&2, U32, Y), Equal.sym(Nat, List.length(&2, U32, Y), a, eY), z2))

# ---- the fields' values and parts (bytes-derived: a field's value is read back from its bytes) ----

def UV8(+x: U32) -> S.Value: S.UnsignedValue{P.UInt{U32.and(x, 255), 0, 0, 0, 0, 0, 0, 0}}
def UV16(+x: U32) -> S.Value: S.UnsignedValue{P.UInt{PBM.v16of(U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)), 0, 0, 0, 0, 0, 0, 0}}

def prt8(+x: U32) -> {Codec.parts(UV8(x), S.Unsigned{P.U8{}}) == Some{[S.Fixed{[U32.and(x, 255)]}]} : Maybe<&2, +List<S.Part>>}:
  U8.u8p(U32.and(x, 255), WF.masked_byte_bound(x))
def prt16(+x: U32) -> {Codec.parts(UV16(x), S.Unsigned{P.U16{}}) == Some{[S.Fixed{[U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]}]} : Maybe<&2, +List<S.Part>>}:
  FXB.u16p(U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255), WF.masked_byte_bound(x), WF.masked_byte_bound(U32.shrn(x, 8n)))

def dom8(+x: U32) -> {SP.bytes_domain([U32.and(x, 255)]) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(U32.and(x, 255), 256), True{}, WF.masked_byte_bound(x)) : {Bool.and(_, True{}) == True{} : Bool}
  {==}
def dom16(+x: U32) -> {SP.bytes_domain([U32.and(x, 255), U32.and(U32.shrn(x, 8n), 255)]) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(U32.and(x, 255), 256), True{}, WF.masked_byte_bound(x)) : {Bool.and(_, Bool.and(U32.is_lt(U32.and(U32.shrn(x, 8n), 255), 256), True{})) == True{} : Bool}
  %Equal.sym(Bool, U32.is_lt(U32.and(U32.shrn(x, 8n), 255), 256), True{}, WF.masked_byte_bound(U32.shrn(x, 8n))) : {Bool.and(True{}, Bool.and(_, True{})) == True{} : Bool}
  {==}
