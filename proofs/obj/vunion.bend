import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuwd.bend as WD
import ./vrecx.bend as VRX
import ./vcont.bend as VCN
import ./vuwl_u8_generated.bend as W8
import ./dk.bend as DK

# A union's step at X = 4 q + r (hand-written; for codegen/var_cont_enc.py's unions): the runtime
# writes the selector byte s with O.w8 at X (vuwl_u8.W8X), then the arm's put at X + 1, whose word
# position is 4 AQ(q, r) + AR(r). The union's bytes are Con{s, ENC_arm}; the zeros after them are the
# arm's (padsh: PADB(AR(r), E) = PADB(r, 1 + E)). Its spec side: the selector byte then the arm's
# bytes, one variable part (Codec.tagged).

def AQ(+q: Nat, r: Nat) -> Nat:
  match r:
    case 0n: q
    case 1n: q
    case 2n: q
    case 3n: 1n+q
    case 4n+t: q
def AR(r: Nat) -> Nat:
  match r:
    case 0n: 1n
    case 1n: 2n
    case 2n: 3n
    case 3n: 0n
    case 4n+t: 0n

def X0(+q: Nat, +r: Nat) -> Nat: Nat.add(A.quad(q), r)

# The arm's position: 1 + X0.
def apos(+q: Nat, +r: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}) -> {Nat.add(A.quad(AQ(q, r)), AR(r)) == 1n+X0(q, r) : Nat}:
  match r:
    case 0n: FD.nat__add_succ(A.quad(q), 0n)
    case 1n: FD.nat__add_succ(A.quad(q), 1n)
    case 2n: FD.nat__add_succ(A.quad(q), 2n)
    case 3n:
      Equal.trans(Nat, Nat.add(A.quad(1n+q), 0n), A.quad(1n+q), 1n+Nat.add(A.quad(q), 3n), FD.nat__add_zero(A.quad(1n+q)),
        Equal.cong(Nat, Nat, z => 1n+z, 3n+A.quad(q), Nat.add(A.quad(q), 3n), FD.nat__add_comm(3n, A.quad(q))))
    case 4n+ +t: Empty.absurd({Nat.add(A.quad(AQ(q, 4n+t)), AR(4n+t)) == 1n+X0(q, 4n+t) : Nat}, FD.nat__lt_zero_absurd(t, hr))

def ar_lt(+r: Nat) -> {Nat.is_lt(AR(r), 4n) == True{} : Bool}:
  match r:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +t: {==}

# The arm's room from the union's (its E bytes after the selector).
def aroom(+q: Nat, +r: Nat, +E: Nat, +dd: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(AQ(q, r), WD.NWN(Nat.add(AR(r), E))), VB.pw(dd)) == True{} : Bool}:
  match r:
    case 0n: hl
    case 1n: hl
    case 2n: hl
    case 3n:
      FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 1n+WD.NWN(E)), 1n+Nat.add(q, WD.NWN(E)), FD.nat__add_succ(q, WD.NWN(E)), hl)
    case 4n+ +t: Empty.absurd({Nat.is_le(Nat.add(AQ(q, 4n+t), WD.NWN(Nat.add(AR(4n+t), E))), VB.pw(dd)) == True{} : Bool}, FD.nat__lt_zero_absurd(t, hr))

# The selector's room.
def sroom(+q: Nat, +r: Nat, +E: Nat, +dd: Nat, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(q, WD.NWN(Nat.add(r, 1n))), Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd),
    Order.add_left(q, WD.NWN(Nat.add(r, 1n)), WD.NWN(Nat.add(r, 1n+E)),
      VRX.nwn_mono(Nat.add(r, 1n), Nat.add(r, 1n+E), Order.add_left(r, 1n, 1n+E, FD.nat__zero_le(E)))), hl)

# The zeros after the arm are the union's.
def padsh(+r: Nat, +E: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}) -> {WD.PADB(AR(r), E) == WD.PADB(r, 1n+E) : Nat}:
  match r:
    case 0n: FD.lru_subtraction_bounds__cancel_left(1n+E, WD.PADB(1n, E), WD.PADB(0n, 1n+E), Equal.trans(Nat, Nat.add(1n+E, WD.PADB(1n, E)), A.quad(WD.NWN(1n+E)), Nat.add(1n+E, WD.PADB(0n, 1n+E)), VCN.padb_id(1n, E), Equal.sym(Nat, Nat.add(1n+E, WD.PADB(0n, 1n+E)), A.quad(WD.NWN(1n+E)), VCN.padb_id(0n, 1n+E))))
    case 1n: FD.lru_subtraction_bounds__cancel_left(2n+E, WD.PADB(2n, E), WD.PADB(1n, 1n+E), Equal.trans(Nat, Nat.add(2n+E, WD.PADB(2n, E)), A.quad(WD.NWN(2n+E)), Nat.add(2n+E, WD.PADB(1n, 1n+E)), VCN.padb_id(2n, E), Equal.sym(Nat, Nat.add(2n+E, WD.PADB(1n, 1n+E)), A.quad(WD.NWN(2n+E)), VCN.padb_id(1n, 1n+E))))
    case 2n: FD.lru_subtraction_bounds__cancel_left(3n+E, WD.PADB(3n, E), WD.PADB(2n, 1n+E), Equal.trans(Nat, Nat.add(3n+E, WD.PADB(3n, E)), A.quad(WD.NWN(3n+E)), Nat.add(3n+E, WD.PADB(2n, 1n+E)), VCN.padb_id(3n, E), Equal.sym(Nat, Nat.add(3n+E, WD.PADB(2n, 1n+E)), A.quad(WD.NWN(3n+E)), VCN.padb_id(2n, 1n+E))))
    case 3n:
      +p0 = WD.PADB(3n, 1n+E)
      +p1 = WD.PADB(0n, E)
      +e0 = FD.lru_subtraction_bounds__cancel_left(4n, Nat.add(E, p0), A.quad(WD.NWN(E)), VCN.padb_id(3n, 1n+E))
      Equal.sym(Nat, p0, p1, FD.lru_subtraction_bounds__cancel_left(E, p0, p1, Equal.trans(Nat, Nat.add(E, p0), A.quad(WD.NWN(E)), Nat.add(E, p1), e0, Equal.sym(Nat, Nat.add(E, p1), A.quad(WD.NWN(E)), VCN.padb_id(0n, E)))))
    case 4n+ +t: Empty.absurd({WD.PADB(AR(4n+t), E) == WD.PADB(4n+t, 1n+E) : Nat}, FD.nat__lt_zero_absurd(t, hr))

# ---- the selector write -----------------------------------------------------------------------------

def DS(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat, +s: U32) -> FD.array__Tree<U32>: W8.W8X(r, dd, D, q, s)

def sel_rtW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +s: U32, +E: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat},
    +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w8(FD.array__thaw(U32, D), X, s) == FD.array__thaw(U32, DS(dd, D, q, r, s)) : Array<U32>}:
  W8.w8_anyW(dd, D, X, q, r, s, e, hr, hd, sroom(q, r, E, dd, hl), pf)

def sel_rt(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +s: U32, +E: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat},
    +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w8(FD.array__thaw(U32, D), X, s) == FD.array__thaw(U32, DS(dd, D, q, r, s)) : Array<U32>}:
  sel_rtW(dd, D, X, q, r, s, E, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf)

def sel_pf(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat, +s: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, DS(dd, D, q, r, s)) == True{} : Bool}:
  W8.w8x_perfect(r, dd, D, q, s, pf)

def sel_byW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +s: U32, +E: Nat, +p: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat},
    +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(1n+Nat.add(E, p), VS.bdr(X0(q, r), UA.BYT(D))) == UW.ZB(1n+Nat.add(E, p)) : +List<U32>})
    -> {UA.BYT(DS(dd, D, q, r, s)) == UW.SPL(UA.BYT(D), X0(q, r), [U32.and(s, 255)]) : +List<U32>}:
  W8.w8_any_bytesW(dd, D, X, q, r, s, e, hr, hd, sroom(q, r, E, dd, hl), pf, VRX.zhead(1n, Nat.add(E, p), VS.bdr(X0(q, r), UA.BYT(D)), hz))

# ---- the arm's hypotheses -----------------------------------------------------------------------------

def sel_by(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +s: U32, +E: Nat, +p: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat},
    +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(1n+Nat.add(E, p), VS.bdr(X0(q, r), UA.BYT(D))) == UW.ZB(1n+Nat.add(E, p)) : +List<U32>})
    -> {UA.BYT(DS(dd, D, q, r, s)) == UW.SPL(UA.BYT(D), X0(q, r), [U32.and(s, 255)]) : +List<U32>}:
  sel_byW(dd, D, X, q, r, s, E, p, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, hz)

# Its position: X + 1 is at 4 AQ + AR.
def arm_eW(+dd: Nat, +X: U32, +q: Nat, +r: Nat, +E: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool}, +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, 1n+E)), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, 1)) == Nat.add(A.quad(AQ(q, r)), AR(r)) : Nat}:
  +hb = FD.nat__le_lt_trans(1n+X0(q, r), 1n+Nat.add(X0(q, r), E), FD.spec_common__pow2(32n), FD.nat__le_add_right(X0(q, r), E),
    FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(X0(q, r), 1n+E), 1n+Nat.add(X0(q, r), E), FD.nat__add_succ(X0(q, r), E),
      FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(A.quad(q), Nat.add(r, 1n+E)), Nat.add(X0(q, r), 1n+E),
        Equal.sym(Nat, Nat.add(X0(q, r), 1n+E), Nat.add(A.quad(q), Nat.add(r, 1n+E)), FD.nat__add_assoc(A.quad(q), r, 1n+E)), hl32)))
  Equal.trans(Nat, U32.to_nat(U32.add(X, 1)), 1n+X0(q, r), Nat.add(A.quad(AQ(q, r)), AR(r)), VB.add_lt32(X, 1, X0(q, r), e, hb),
    Equal.sym(Nat, Nat.add(A.quad(AQ(q, r)), AR(r)), 1n+X0(q, r), apos(q, r, hr)))

def arm_e(+dd: Nat, +X: U32, +q: Nat, +r: Nat, +E: Nat, +e: {U32.to_nat(X) == X0(q, r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, 1n+E))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, 1)) == Nat.add(A.quad(AQ(q, r)), AR(r)) : Nat}:
  +hb = FD.nat__le_trans(1n+X0(q, r), 1n+Nat.add(X0(q, r), E), A.quad(VB.pw(dd)), FD.nat__le_add_right(X0(q, r), E),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == True{} : Bool}, Nat.add(X0(q, r), 1n+E), 1n+Nat.add(X0(q, r), E), FD.nat__add_succ(X0(q, r), E),
      VRX.xend(q, r, 1n+E, dd, hl)))
  Equal.trans(Nat, U32.to_nat(U32.add(X, 1)), 1n+X0(q, r), Nat.add(A.quad(AQ(q, r)), AR(r)), VB.add_le_at(X, 1, X0(q, r), 2n+dd, e, hd, hb),
    Equal.sym(Nat, Nat.add(A.quad(AQ(q, r)), AR(r)), 1n+X0(q, r), apos(q, r, hr)))

# Its zero window (its E bytes and its zeros), after the selector write.
def arm_hz(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +r: Nat, +s: U32, +E: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hX: {Nat.is_le(X0(q, r), List.length(&2, U32, UA.BYT(D))) == True{} : Bool},
    +by: {UA.BYT(DS(dd, D, q, r, s)) == UW.SPL(UA.BYT(D), X0(q, r), [U32.and(s, 255)]) : +List<U32>},
    +hz: {VS.bt(1n+Nat.add(E, WD.PADB(r, 1n+E)), VS.bdr(X0(q, r), UA.BYT(D))) == UW.ZB(1n+Nat.add(E, WD.PADB(r, 1n+E))) : +List<U32>})
    -> {VS.bt(Nat.add(E, WD.PADB(AR(r), E)), VS.bdr(Nat.add(A.quad(AQ(q, r)), AR(r)), UA.BYT(DS(dd, D, q, r, s)))) == UW.ZB(Nat.add(E, WD.PADB(AR(r), E))) : +List<U32>}:
  +Xn = Nat.add(A.quad(AQ(q, r)), AR(r))
  +eXn = Equal.trans(Nat, Xn, 1n+X0(q, r), Nat.add(X0(q, r), 1n), apos(q, r, hr), FD.nat__add_comm(1n, X0(q, r)))
  +z = VRX.znext(UA.BYT(D), X0(q, r), [U32.and(s, 255)], Xn, 1n, Nat.add(E, WD.PADB(r, 1n+E)), UA.BYT(DS(dd, D, q, r, s)), hX, {==}, eXn, by, hz)
  FD.logic__subst(Nat, zz => {VS.bt(Nat.add(E, zz), VS.bdr(Xn, UA.BYT(DS(dd, D, q, r, s)))) == UW.ZB(Nat.add(E, zz)) : +List<U32>}, WD.PADB(r, 1n+E), WD.PADB(AR(r), E),
    Equal.sym(Nat, WD.PADB(AR(r), E), WD.PADB(r, 1n+E), padsh(r, E, hr)), z)

# The union's bytes: the selector then the arm's bytes and zeros.
def ubytes(+dd: Nat, +D: FD.array__Tree<U32>, +D2: FD.array__Tree<U32>, +q: Nat, +r: Nat, +s: U32, +Y: +List<U32>, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hX: {Nat.is_le(X0(q, r), List.length(&2, U32, UA.BYT(D))) == True{} : Bool},
    +by: {UA.BYT(DS(dd, D, q, r, s)) == UW.SPL(UA.BYT(D), X0(q, r), [U32.and(s, 255)]) : +List<U32>},
    +by2: {UA.BYT(D2) == UW.SPL(UA.BYT(DS(dd, D, q, r, s)), Nat.add(A.quad(AQ(q, r)), AR(r)), List.append(&2, U32, Y, UW.ZB(WD.PADB(AR(r), List.length(&2, U32, Y))))) : +List<U32>})
    -> {UA.BYT(D2) == UW.SPL(UA.BYT(D), X0(q, r), List.append(&2, U32, Con{U32.and(s, 255), Y}, UW.ZB(WD.PADB(r, List.length(&2, U32, Con{U32.and(s, 255), Y}))))) : +List<U32>}:
  +E = List.length(&2, U32, Y)
  +Z = List.append(&2, U32, Y, UW.ZB(WD.PADB(AR(r), E)))
  +Xn = Nat.add(A.quad(AQ(q, r)), AR(r))
  +eXn = Equal.trans(Nat, Xn, 1n+X0(q, r), Nat.add(X0(q, r), 1n), apos(q, r, hr), FD.nat__add_comm(1n, X0(q, r)))
  +b3 = Equal.trans(+List<U32>, UA.BYT(D2), UW.SPL(UA.BYT(DS(dd, D, q, r, s)), Xn, Z), UW.SPL(UA.BYT(D), X0(q, r), Con{U32.and(s, 255), Z}), by2,
    VRX.spl_catx(UA.BYT(D), X0(q, r), [U32.and(s, 255)], Z, Xn, UA.BYT(DS(dd, D, q, r, s)), hX, eXn, by))
  FD.logic__subst(Nat, zz => {UA.BYT(D2) == UW.SPL(UA.BYT(D), X0(q, r), Con{U32.and(s, 255), List.append(&2, U32, Y, UW.ZB(zz))}) : +List<U32>}, WD.PADB(AR(r), E), WD.PADB(r, 1n+E), padsh(r, E, hr), b3)

# ---- the spec side ----------------------------------------------------------------------------------

def tag_v(+s: U32, +v: S.Value, +sc: S.Schema, +xs: +List<U32>, +h: {Codec.parts(v, sc) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>})
    -> {Codec.tagged(s, Codec.parts(v, sc)) == Some{[S.Variable{Con{s, xs}}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(v, sc), Some{[S.Variable{xs}]}, h) : {Codec.tagged(s, _) == Some{[S.Variable{Con{s, xs}}]} : Maybe<&2, +List<S.Part>>}
  {==}
def tag_f(+s: U32, +v: S.Value, +sc: S.Schema, +xs: +List<U32>, +h: {Codec.parts(v, sc) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>})
    -> {Codec.tagged(s, Codec.parts(v, sc)) == Some{[S.Variable{Con{s, xs}}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(v, sc), Some{[S.Fixed{xs}]}, h) : {Codec.tagged(s, _) == Some{[S.Variable{Con{s, xs}}]} : Maybe<&2, +List<S.Part>>}
  {==}

# aroom's arm region below 2^32 (from the union's region, 1 + E bytes at X0).
def aroom32(+q: Nat, +r: Nat, +E: Nat, +dd: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hl32: {Nat.is_lt(Nat.add(A.quad(q), Nat.add(r, 1n+E)), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(AQ(q, r)), Nat.add(AR(r), E)), FD.spec_common__pow2(32n)) == True{} : Bool}:
  +e1 = Equal.trans(Nat, Nat.add(A.quad(AQ(q, r)), Nat.add(AR(r), E)), Nat.add(Nat.add(A.quad(AQ(q, r)), AR(r)), E), Nat.add(1n+X0(q, r), E),
    Equal.sym(Nat, Nat.add(Nat.add(A.quad(AQ(q, r)), AR(r)), E), Nat.add(A.quad(AQ(q, r)), Nat.add(AR(r), E)), FD.nat__add_assoc(A.quad(AQ(q, r)), AR(r), E)),
    Equal.cong(Nat, Nat, z => Nat.add(z, E), Nat.add(A.quad(AQ(q, r)), AR(r)), 1n+X0(q, r), apos(q, r, hr)))
  +e2 = Equal.trans(Nat, Nat.add(1n+X0(q, r), E), Nat.add(X0(q, r), 1n+E), Nat.add(A.quad(q), Nat.add(r, 1n+E)),
    Equal.sym(Nat, Nat.add(X0(q, r), 1n+E), Nat.add(1n+X0(q, r), E), FD.nat__add_succ(X0(q, r), E)),
    FD.nat__add_assoc(A.quad(q), r, 1n+E))
  FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(A.quad(q), Nat.add(r, 1n+E)), Nat.add(A.quad(AQ(q, r)), Nat.add(AR(r), E)),
    Equal.sym(Nat, Nat.add(A.quad(AQ(q, r)), Nat.add(AR(r), E)), Nat.add(A.quad(q), Nat.add(r, 1n+E)), Equal.trans(Nat, Nat.add(A.quad(AQ(q, r)), Nat.add(AR(r), E)), Nat.add(1n+X0(q, r), E), Nat.add(A.quad(q), Nat.add(r, 1n+E)), e1, e2)), hl32)

# aroom's arm of E bytes (the union's 1 + E below 2^31).
def aroom31(+q: Nat, +r: Nat, +E: Nat, +dd: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hs31: {Nat.is_lt(1n+E, VB.pw(31n)) == True{} : Bool}) -> {Nat.is_lt(E, VB.pw(31n)) == True{} : Bool}:
  FD.nat__lt_trans(E, 1n+E, VB.pw(31n), FD.nat__lt_succ(E), hs31)
