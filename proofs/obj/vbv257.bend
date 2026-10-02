import Base
import ../../src/obj.bend as O
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vbrt.bend as VR
import ./vua.bend as UA
import ./vuw.bend as UW
import ./vuw1_generated.bend as UB1
import ./vuw2_generated.bend as UB2
import ./vuw3_generated.bend as UB3
import ./vuwd.bend as UWD
import ./vuwb.bend as VWB
import ../../types/bitvector_257_def_generated.bend as bitvector_257_d
import ../../types/bitvector_257_encode_ssz_generated.bend as bitvector_257_e
import ./vuw_bits_generated.bend as UWB
import ./vbenc.bend as VBE
import ../../src/primitives.bend as I
import ./vuwg_bv256_generated.bend as G256
import ./vuwg_bv257_generated.bend as G257
import ./vuwl_u8_generated.bend as W8
import ./vbitb.bend as VBB
import ./vrecx.bend as VRX
import ./vrecb.bend as VRB

# Bitvector[257] (33 bytes) written data-only at any byte position X = 4 q + r: only its 33 bytes are
# zero beforehand (the bytes after it may already hold data), its last word below 256. The model is
# the Bitvector[256] of its first eight words (vuwg_bv256) and then its last byte (vuwl_u8.W8X at
# X + 32); the runtime's T.bv257_put is that model: at an aligned X directly (its word 8 OR-ed), at an
# unaligned one through vuwg_bv257's open model SWo, whose last word ORs the byte onto the eight words'
# carry (orsm: the byte OR-ed onto an OR-if-nonzero is one OR). Hand-written; d0 / d1 / d2 are
# vuwg_bv257's gput0 / gputu1 / gputu2 with the zeros needed only in the 33 bytes.

# ---- OR facts ----
def bor3(+a: Bool, +b: Bool, +c: Bool) -> {Bool.or(Bool.or(a, b), c) == Bool.or(a, Bool.or(c, b)) : Bool}:
  match a b c:
    case False{} False{} False{}: {==}
    case False{} False{} True{}: {==}
    case False{} True{} False{}: {==}
    case False{} True{} True{}: {==}
    case True{} False{} False{}: {==}
    case True{} False{} True{}: {==}
    case True{} True{} False{}: {==}
    case True{} True{} True{}: {==}

law wor3:
  for +n: Nat
  for +x: Word(n)
  for +y: Word(n)
  for +z: Word(n)
  {Word.or(n, Word.or(n, x, y), z) == Word.or(n, x, Word.or(n, z, y)) : Word(n)}
def wor3(n, x, y, z):
  match n:
    case 0n: {==}
    case 1n+ +p:
      match x y z:
        case WCon{+a, +xt} WCon{+b, +yt} WCon{+c, +zt}:
          Equal.trans(Word(1n+p), WCon{Bool.or(Bool.or(a, b), c), Word.or(p, Word.or(p, xt, yt), zt)}, WCon{Bool.or(a, Bool.or(c, b)), Word.or(p, Word.or(p, xt, yt), zt)},
            WCon{Bool.or(a, Bool.or(c, b)), Word.or(p, xt, Word.or(p, zt, yt))},
            Equal.cong(Bool, Word(1n+p), h => WCon{h, Word.or(p, Word.or(p, xt, yt), zt)}, Bool.or(Bool.or(a, b), c), Bool.or(a, Bool.or(c, b)), bor3(a, b, c)),
            Equal.cong(Word(p), Word(1n+p), t => WCon{Bool.or(a, Bool.or(c, b)), t}, Word.or(p, Word.or(p, xt, yt), zt), Word.or(p, xt, Word.or(p, zt, yt)), wor3(p, xt, yt, zt)))

def or3(+s: U32, +c: U32, +a: U32) -> {U32.or(U32.or(s, c), a) == U32.or(s, U32.or(a, c)) : U32}:
  match s c a:
    case U32{+x} U32{+y} U32{+z}: Equal.cong(Word(32n), U32, w => U32{w}, Word.or(32n, Word.or(32n, x, y), z), Word.or(32n, x, Word.or(32n, z, y)), wor3(32n, x, y, z))

# ---- a word updated twice, and its slot after an update ----
law tupd2:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +j: Nat
  for +v: U32
  for +w: U32
  for +b: Bool
  {FD.array__tupd(U32, d, FD.array__tupd(U32, d, t, j, v, b), j, w, b) == FD.array__tupd(U32, d, t, j, w, b) : FD.array__Tree<U32>}
def tupd2(d, t, j, v, w, b):
  match d t b:
    case 0n FD.TLeaf{+x} _: {==}
    case 0n FD.TNode{+l, +r} _: {==}
    case 1n+ +p FD.TLeaf{+x} _: {==}
    case 1n+ +p FD.TNode{+l, +r} True{}:
      Equal.cong(FD.array__Tree<U32>, FD.array__Tree<U32>, z => FD.TNode{z, r}, FD.array__tupd(U32, p, FD.array__tupd(U32, p, l, j, v, FD.array__ndec(p, j)), j, w, FD.array__ndec(p, j)),
        FD.array__tupd(U32, p, l, j, w, FD.array__ndec(p, j)), tupd2(p, l, j, v, w, FD.array__ndec(p, j)))
    case 1n+ +p FD.TNode{+l, +r} False{}:
      Equal.cong(FD.array__Tree<U32>, FD.array__Tree<U32>, z => FD.TNode{l, z}, FD.array__tupd(U32, p, FD.array__tupd(U32, p, r, Nat.sub(j, FD.spec_common__pow2(p)), v, FD.array__ndec(p, Nat.sub(j, FD.spec_common__pow2(p)))), Nat.sub(j, FD.spec_common__pow2(p)), w, FD.array__ndec(p, Nat.sub(j, FD.spec_common__pow2(p)))),
        FD.array__tupd(U32, p, r, Nat.sub(j, FD.spec_common__pow2(p)), w, FD.array__ndec(p, Nat.sub(j, FD.spec_common__pow2(p)))), tupd2(p, r, Nat.sub(j, FD.spec_common__pow2(p)), v, w, FD.array__ndec(p, Nat.sub(j, FD.spec_common__pow2(p)))))

def sus(+dd: Nat, +D: FD.array__Tree<U32>, +j: Nat, +v: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {VB.slot(FD.array__upd(U32, dd, D, j, v), j) == v : U32}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, VB.pw(dd), FD.spec_common__length(U32, FD.array__slots(U32, D)),
    Equal.sym(Nat, FD.spec_common__length(U32, FD.array__slots(U32, D)), VB.pw(dd), FD.array__slots_length(U32, dd, D, pf)), hj)
  Equal.trans(U32, FD.flat__nthc(FD.array__slots(U32, FD.array__upd(U32, dd, D, j, v)), j), FD.flat__nthc(FD.spec_common__update(U32, FD.array__slots(U32, D), j, v), j), v,
    Equal.cong(List<&2, U32>, U32, z => FD.flat__nthc(z, j), FD.array__slots(U32, FD.array__upd(U32, dd, D, j, v)), FD.spec_common__update(U32, FD.array__slots(U32, D), j, v),
      FD.array__upd_slots(U32, dd, D, j, v, hj, pf)),
    FD.flat__nthc_same(FD.array__slots(U32, D), j, v, hl))

# a byte OR-ed onto an OR-if-nonzero at the same word is one OR of both
def orsb(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +j: Nat, +c: U32, +a: U32, +eb: {U32.is_eq(c, 0) == b : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {UW.ORW(dd, UW.ORSb(b, dd, D, j, c), j, a) == UW.ORW(dd, D, j, U32.or(a, c)) : FD.array__Tree<U32>}:
  match b:
    case True{}:
      %Equal.sym(U32, c, 0, FD.u32alg__eq_of(c, 0, eb)) : {UW.ORW(dd, D, j, a) == UW.ORW(dd, D, j, U32.or(a, _)) : FD.array__Tree<U32>}
      Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORW(dd, D, j, z), a, U32.or(a, 0), Equal.sym(U32, U32.or(a, 0), a, UWB.or0r(a)))
    case False{}:
      +s = VB.slot(D, j)
      +D1 = FD.array__upd(U32, dd, D, j, U32.or(s, c))
      +e1 = Equal.cong(U32, FD.array__Tree<U32>, z => FD.array__upd(U32, dd, D1, j, U32.or(z, a)), VB.slot(D1, j), U32.or(s, c), sus(dd, D, j, U32.or(s, c), pf, hj))
      +e2 = tupd2(dd, D, j, U32.or(s, c), U32.or(U32.or(s, c), a), FD.array__ndec(dd, j))
      +e3 = Equal.cong(U32, FD.array__Tree<U32>, z => FD.array__upd(U32, dd, D, j, z), U32.or(U32.or(s, c), a), U32.or(s, U32.or(a, c)), or3(s, c, a))
      Equal.trans(FD.array__Tree<U32>, FD.array__upd(U32, dd, D1, j, U32.or(VB.slot(D1, j), a)), FD.array__upd(U32, dd, D1, j, U32.or(U32.or(s, c), a)), FD.array__upd(U32, dd, D, j, U32.or(s, U32.or(a, c))), e1,
        Equal.trans(FD.array__Tree<U32>, FD.array__upd(U32, dd, D1, j, U32.or(U32.or(s, c), a)), FD.array__upd(U32, dd, D, j, U32.or(U32.or(s, c), a)), FD.array__upd(U32, dd, D, j, U32.or(s, U32.or(a, c))), e2, e3))
def orsm(+dd: Nat, +D: FD.array__Tree<U32>, +j: Nat, +c: U32, +a: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_lt(j, VB.pw(dd)) == True{} : Bool})
    -> {UW.ORW(dd, UW.ORS(dd, D, j, c), j, a) == UW.ORW(dd, D, j, U32.or(a, c)) : FD.array__Tree<U32>}:
  orsb(U32.is_eq(c, 0), dd, D, j, c, a, {==}, pf, hj)

# ---- the runtime at each byte phase (vuwg_bv257's, the zeros only in the 33 bytes) ----
def d0W(+dd: Nat, +D: FD.array__Tree<U32>, +pos: U32, +P: Nat, +e: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(9n, P), VB.pw(dd)) == True{} : Bool}, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(P), 0n), UA.BYT(D))) == UW.ZB(33n) : +List<U32>})
    -> {bitvector_257_e.bv257_put(FD.array__thaw(U32, D), pos, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, UW.ORW(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P), 8n+P, w8)) : Array<U32>}:
  +eq = VF.al_q(pos, P, e)
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hdd, {==})
  +hbc = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(9n, P), Nat.add(P, 9n), FD.nat__add_comm(9n, P), hb)
  +hl = FD.nat__le_trans(Nat.add(P, 8n), Nat.add(P, 9n), VB.pw(dd), Order.add_left(P, 8n, 9n, {==}), hbc)
  +as = UW.as2_updv([w0, w1, w2, w3, w4, w5, w6, w7], [0, 1, 2, 3, 4, 5, 6, 7], dd, D, U32.shrn(pos, 2n), P, 0n, eq, {==}, hdd, pf, hl)
  +hL = UWD.le_q(P, 8n, VB.pw(dd), hbc)
  +eqL = VB.add_at(U32.shrn(pos, 2n), 8, P, dd, eq, hd32, hL)
  +pfv = VF.updv_perfect([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P, pf)
  %Equal.sym(U32, U32.and(pos, 3), 0, VF.al_3(pos, P, e)) :
    {bitvector_257_e.bv257_pwd(U32.is_eq(_, 0), _, FD.array__thaw(U32, D), U32.shrn(pos, 2n), w0, w1, w2, w3, w4, w5, w6, w7, w8) == FD.array__thaw(U32, UW.ORW(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P), 8n+P, w8)) : Array<U32>}
  %Equal.sym(Array<U32>, UW.AS2([w0, w1, w2, w3, w4, w5, w6, w7], [0, 1, 2, 3, 4, 5, 6, 7], FD.array__thaw(U32, D), U32.shrn(pos, 2n)), FD.array__thaw(U32, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P)),
      Equal.trans(Array<U32>, UW.AS2([w0, w1, w2, w3, w4, w5, w6, w7], [0, 1, 2, 3, 4, 5, 6, 7], FD.array__thaw(U32, D), U32.shrn(pos, 2n)), FD.array__thaw(U32, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, Nat.add(0n, P))), FD.array__thaw(U32, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P)), as,
        Equal.cong(Nat, Array<U32>, z => FD.array__thaw(U32, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, z)), Nat.add(0n, P), P, {==}))) :
    {O.or_word(_, U32.add(U32.shrn(pos, 2n), 8), w8) == FD.array__thaw(U32, UW.ORW(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P), 8n+P, w8)) : Array<U32>}
  UW.orw_rt(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P), U32.add(U32.shrn(pos, 2n), 8), 8n+P, w8, eqL, hd32, hL, pfv)

def d0(+dd: Nat, +D: FD.array__Tree<U32>, +pos: U32, +P: Nat, +e: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(9n, P), VB.pw(dd)) == True{} : Bool}, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(P), 0n), UA.BYT(D))) == UW.ZB(33n) : +List<U32>})
    -> {bitvector_257_e.bv257_put(FD.array__thaw(U32, D), pos, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, UW.ORW(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, P), 8n+P, w8)) : Array<U32>}:
  d0W(dd, D, pos, P, e, FD.nat__lt_trans(dd, 29n, 31n, hdd, {==}), pf, hb, w0, w1, w2, w3, w4, w5, w6, w7, w8, hz)

def d1(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 1n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(9n+i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +vt: {U32.shrn(w8, 8n) == 0 : U32},
    +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(i), 1n), UA.BYT(U))) == UW.ZB(33n) : +List<U32>})
    -> {bitvector_257_e.bv257_put(FD.array__thaw(U32, U), pos, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}:
  +e3 = UW.ua_3(pos, i, 1n, 1, {==}, e, {==})
  +eq = UW.ua_q(pos, i, 1n, e, {==})
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hi0 = FD.nat__lt_le_trans(i, 9n+i, VB.pw(dd), FD.nat__le_lt_succ(i, 8n+i, Order.left_below_sum(8n, i)), hl)
  +eq0 = VB.add_at(U32.shrn(pos, 2n), 0, i, dd, eq, hd32, hi0)
  +D1 = UW.ORW(dd, U, i, U32.mul(w0, 256))
  +pf1 = UW.orw_perfect(dd, U, i, U32.mul(w0, 256), pf)
  +hc = UWB.tzc11(w8, vt)
  +X0 = Nat.add(A.quad(i), 1n)
  +B = UA.BYT(U)
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, 3n), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, 3n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), 1n, 3n)))
  +zU = Equal.trans(+List<U32>, VS.bt(28n, VS.bdr(4n+A.quad(i), B)), VS.bt(28n, VS.bdr(3n, VS.bdr(X0, B))), UW.ZB(28n),
    Equal.trans(+List<U32>, VS.bt(28n, VS.bdr(4n+A.quad(i), B)), VS.bt(28n, VS.bdr(Nat.add(X0, 3n), B)), VS.bt(28n, VS.bdr(3n, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt(28n, VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, 3n), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(28n, z), VS.bdr(Nat.add(X0, 3n), B), VS.bdr(3n, VS.bdr(X0, B)), UW.bdr_add(X0, 3n, B))),
    Equal.trans(+List<U32>, VS.bt(28n, VS.bdr(3n, VS.bdr(X0, B))), VS.bt(28n, VS.bdr(3n, VS.bt(33n, VS.bdr(X0, B)))), UW.ZB(28n),
      UW.bt_bdr_bt(28n, 3n, 33n, VS.bdr(X0, B), {==}),
      FD.logic__subst(+List<U32>, z => {VS.bt(28n, VS.bdr(3n, z)) == UW.ZB(28n) : +List<U32>}, UW.ZB(33n), VS.bt(33n, VS.bdr(X0, B)),
        Equal.sym(+List<U32>, VS.bt(33n, VS.bdr(X0, B)), UW.ZB(33n), hz), UW.zb_win(3n, 28n, 33n, {==}))))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), U32.mul(w0, 256)), pf, hi0)
  +hzr = FD.logic__subst(+List<U32>, z => {VS.bt(28n, z) == UW.ZB(28n) : +List<U32>}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(D1)),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(D1)), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hlr = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(7n, 1n+i), Nat.add(1n+i, 7n), FD.nat__add_comm(7n, 1n+i),
    FD.nat__le_trans(Nat.add(7n, 1n+i), 9n+i, VB.pw(dd), Order.left_below_sum(1n, 8n+i), hl))
  +rs0 = UW.rs2_swo(1, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], dd, D1, U32.shrn(pos, 2n), i, 1n, w0, eq, {==}, hd, pf1, hlr, hzr)
  +SW1 = UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, D1, 1n+i, O.shr_over(w0, 1))
  +rs = Equal.trans(Array<U32>, UW.RS2(1, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], FD.array__thaw(U32, D1), U32.shrn(pos, 2n), w0), FD.array__thaw(U32, UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, D1, Nat.add(1n, i), O.shr_over(w0, 1))), FD.array__thaw(U32, SW1), rs0,
    Equal.cong(Nat, Array<U32>, z => FD.array__thaw(U32, UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, D1, z, O.shr_over(w0, 1))), Nat.add(1n, i), 1n+i, {==}))
  +hL = FD.nat__succ_le_lt(8n+i, VB.pw(dd), hl)
  +eqL = FD.logic__subst(Nat, z => {U32.to_nat(U32.add(U32.shrn(pos, 2n), 8)) == z : Nat}, Nat.add(8n, i), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), {==}, VB.add_at(U32.shrn(pos, 2n), 8, i, dd, eq, hd32, hL))
  +hLx = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, 8n+i, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), {==}, hL)
  +pfS = UW.swo_perfect(1, [w1, w2, w3, w4, w5, w6, w7], dd, D1, 1n+i, O.shr_over(w0, 1), pf1)
  +eL = UW.orw_rt(dd, SW1, U32.add(U32.shrn(pos, 2n), 8), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1))), eqL, hd32, hLx, pfS)
  %Equal.sym(U32, U32.and(pos, 3), 1, e3) : {bitvector_257_e.bv257_pwd(U32.is_eq(_, 0), U32.and(pos, 3), FD.array__thaw(U32, U), U32.shrn(pos, 2n), w0, w1, w2, w3, w4, w5, w6, w7, w8) == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(U32, U32.and(pos, 3), 1, e3) : {bitvector_257_e.bv257_pwd(U32.is_eq(1, 0), _, FD.array__thaw(U32, U), U32.shrn(pos, 2n), w0, w1, w2, w3, w4, w5, w6, w7, w8) == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, U), U32.add(U32.shrn(pos, 2n), 0), U32.mul(w0, 256)), FD.array__thaw(U32, D1), UW.orw_rt(dd, U, U32.add(U32.shrn(pos, 2n), 0), i, U32.mul(w0, 256), eq0, hd32, hi0, pf)) :
    {O.or_skip(O.or_word(UW.RS2(1, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], _, U32.shrn(pos, 2n), w0), U32.add(U32.shrn(pos, 2n), 8), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 24n)) == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, UW.RS2(1, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], FD.array__thaw(U32, D1), U32.shrn(pos, 2n), w0), FD.array__thaw(U32, SW1), rs) :
    {O.or_skip(O.or_word(_, U32.add(U32.shrn(pos, 2n), 8), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 24n)) == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, SW1), U32.add(U32.shrn(pos, 2n), 8), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), FD.array__thaw(U32, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1))))), eL) :
    {O.or_skip(_, U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 24n)) == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_skip(FD.array__thaw(U32, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1))))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 24n)), FD.array__thaw(U32, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1))))), UW.orskip0(dd, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 24n), hc)) :
    {_ == FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  Equal.cong(FD.array__Tree<U32>, Array<U32>, z => FD.array__thaw(U32, z), UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7, w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)),
    Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), UW.ORW(dd, UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7, w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)),
      Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORW(dd, UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, z), 1n+i, O.shr_over(w0, 1)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), U32.mul(w0, 256), U32.or(O.shl_bytes(w0, 1), 0),
        Equal.sym(U32, U32.or(U32.mul(w0, 256), 0), U32.mul(w0, 256), UWB.or0r(U32.mul(w0, 256)))),
      Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), UW.SWo(1, List.append(&2, U32, [w1, w2, w3, w4, w5, w6, w7], [w8]), dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)), UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7, w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)),
        Equal.sym(FD.array__Tree<U32>, UW.SWo(1, List.append(&2, U32, [w1, w2, w3, w4, w5, w6, w7], [w8]), dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)), UW.ORW(dd, UW.SWo(1, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 1), UW.CRY(1, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 1)))), UW.swo_app(1, [w1, w2, w3, w4, w5, w6, w7], [w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1))),
        Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(1, z, dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 1), 0)), 1n+i, O.shr_over(w0, 1)), List.append(&2, U32, [w1, w2, w3, w4, w5, w6, w7], [w8]), [w1, w2, w3, w4, w5, w6, w7, w8], {==}))))

def d2(+dd: Nat, +U: FD.array__Tree<U32>, +pos: U32, +i: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +e: {U32.to_nat(pos) == Nat.add(A.quad(i), 2n) : Nat}, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +hl: {Nat.is_le(9n+i, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, U) == True{} : Bool}, +vt: {U32.shrn(w8, 8n) == 0 : U32},
    +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(i), 2n), UA.BYT(U))) == UW.ZB(33n) : +List<U32>})
    -> {bitvector_257_e.bv257_put(FD.array__thaw(U32, U), pos, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}:
  +e3 = UW.ua_3(pos, i, 2n, 2, {==}, e, {==})
  +eq = UW.ua_q(pos, i, 2n, e, {==})
  +hd32 = FD.nat__lt_trans(dd, 31n, 32n, hd, {==})
  +hi0 = FD.nat__lt_le_trans(i, 9n+i, VB.pw(dd), FD.nat__le_lt_succ(i, 8n+i, Order.left_below_sum(8n, i)), hl)
  +eq0 = VB.add_at(U32.shrn(pos, 2n), 0, i, dd, eq, hd32, hi0)
  +D1 = UW.ORW(dd, U, i, U32.mul(w0, 65536))
  +pf1 = UW.orw_perfect(dd, U, i, U32.mul(w0, 65536), pf)
  +hc = UWB.tzc21(w8, vt)
  +X0 = Nat.add(A.quad(i), 2n)
  +B = UA.BYT(U)
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, 2n), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, 2n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), 2n, 2n)))
  +zU = Equal.trans(+List<U32>, VS.bt(28n, VS.bdr(4n+A.quad(i), B)), VS.bt(28n, VS.bdr(2n, VS.bdr(X0, B))), UW.ZB(28n),
    Equal.trans(+List<U32>, VS.bt(28n, VS.bdr(4n+A.quad(i), B)), VS.bt(28n, VS.bdr(Nat.add(X0, 2n), B)), VS.bt(28n, VS.bdr(2n, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt(28n, VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, 2n), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(28n, z), VS.bdr(Nat.add(X0, 2n), B), VS.bdr(2n, VS.bdr(X0, B)), UW.bdr_add(X0, 2n, B))),
    Equal.trans(+List<U32>, VS.bt(28n, VS.bdr(2n, VS.bdr(X0, B))), VS.bt(28n, VS.bdr(2n, VS.bt(33n, VS.bdr(X0, B)))), UW.ZB(28n),
      UW.bt_bdr_bt(28n, 2n, 33n, VS.bdr(X0, B), {==}),
      FD.logic__subst(+List<U32>, z => {VS.bt(28n, VS.bdr(2n, z)) == UW.ZB(28n) : +List<U32>}, UW.ZB(33n), VS.bt(33n, VS.bdr(X0, B)),
        Equal.sym(+List<U32>, VS.bt(33n, VS.bdr(X0, B)), UW.ZB(33n), hz), UW.zb_win(2n, 28n, 33n, {==}))))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), U32.mul(w0, 65536)), pf, hi0)
  +hzr = FD.logic__subst(+List<U32>, z => {VS.bt(28n, z) == UW.ZB(28n) : +List<U32>}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(D1)),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(D1)), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hlr = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(7n, 1n+i), Nat.add(1n+i, 7n), FD.nat__add_comm(7n, 1n+i),
    FD.nat__le_trans(Nat.add(7n, 1n+i), 9n+i, VB.pw(dd), Order.left_below_sum(1n, 8n+i), hl))
  +rs0 = UW.rs2_swo(2, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], dd, D1, U32.shrn(pos, 2n), i, 1n, w0, eq, {==}, hd, pf1, hlr, hzr)
  +SW1 = UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, D1, 1n+i, O.shr_over(w0, 2))
  +rs = Equal.trans(Array<U32>, UW.RS2(2, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], FD.array__thaw(U32, D1), U32.shrn(pos, 2n), w0), FD.array__thaw(U32, UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, D1, Nat.add(1n, i), O.shr_over(w0, 2))), FD.array__thaw(U32, SW1), rs0,
    Equal.cong(Nat, Array<U32>, z => FD.array__thaw(U32, UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, D1, z, O.shr_over(w0, 2))), Nat.add(1n, i), 1n+i, {==}))
  +hL = FD.nat__succ_le_lt(8n+i, VB.pw(dd), hl)
  +eqL = FD.logic__subst(Nat, z => {U32.to_nat(U32.add(U32.shrn(pos, 2n), 8)) == z : Nat}, Nat.add(8n, i), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), {==}, VB.add_at(U32.shrn(pos, 2n), 8, i, dd, eq, hd32, hL))
  +hLx = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, 8n+i, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), {==}, hL)
  +pfS = UW.swo_perfect(2, [w1, w2, w3, w4, w5, w6, w7], dd, D1, 1n+i, O.shr_over(w0, 2), pf1)
  +eL = UW.orw_rt(dd, SW1, U32.add(U32.shrn(pos, 2n), 8), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2))), eqL, hd32, hLx, pfS)
  %Equal.sym(U32, U32.and(pos, 3), 2, e3) : {bitvector_257_e.bv257_pwd(U32.is_eq(_, 0), U32.and(pos, 3), FD.array__thaw(U32, U), U32.shrn(pos, 2n), w0, w1, w2, w3, w4, w5, w6, w7, w8) == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(U32, U32.and(pos, 3), 2, e3) : {bitvector_257_e.bv257_pwd(U32.is_eq(2, 0), _, FD.array__thaw(U32, U), U32.shrn(pos, 2n), w0, w1, w2, w3, w4, w5, w6, w7, w8) == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, U), U32.add(U32.shrn(pos, 2n), 0), U32.mul(w0, 65536)), FD.array__thaw(U32, D1), UW.orw_rt(dd, U, U32.add(U32.shrn(pos, 2n), 0), i, U32.mul(w0, 65536), eq0, hd32, hi0, pf)) :
    {O.or_skip(O.or_word(UW.RS2(2, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], _, U32.shrn(pos, 2n), w0), U32.add(U32.shrn(pos, 2n), 8), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 16n)) == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, UW.RS2(2, [w1, w2, w3, w4, w5, w6, w7], [1, 2, 3, 4, 5, 6, 7], FD.array__thaw(U32, D1), U32.shrn(pos, 2n), w0), FD.array__thaw(U32, SW1), rs) :
    {O.or_skip(O.or_word(_, U32.add(U32.shrn(pos, 2n), 8), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 16n)) == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_word(FD.array__thaw(U32, SW1), U32.add(U32.shrn(pos, 2n), 8), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), FD.array__thaw(U32, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2))))), eL) :
    {O.or_skip(_, U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 16n)) == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  %Equal.sym(Array<U32>, O.or_skip(FD.array__thaw(U32, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2))))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 16n)), FD.array__thaw(U32, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2))))), UW.orskip0(dd, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), U32.add(U32.shrn(pos, 2n), 9), U32.shrn(w8, 16n), hc)) :
    {_ == FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, U, i, 0)) : Array<U32>}
  Equal.cong(FD.array__Tree<U32>, Array<U32>, z => FD.array__thaw(U32, z), UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7, w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)),
    Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, SW1, Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), UW.ORW(dd, UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7, w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)),
      Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORW(dd, UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, z), 1n+i, O.shr_over(w0, 2)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), U32.mul(w0, 65536), U32.or(O.shl_bytes(w0, 2), 0),
        Equal.sym(U32, U32.or(U32.mul(w0, 65536), 0), U32.mul(w0, 65536), UWB.or0r(U32.mul(w0, 65536)))),
      Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), UW.SWo(2, List.append(&2, U32, [w1, w2, w3, w4, w5, w6, w7], [w8]), dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)), UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7, w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)),
        Equal.sym(FD.array__Tree<U32>, UW.SWo(2, List.append(&2, U32, [w1, w2, w3, w4, w5, w6, w7], [w8]), dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)), UW.ORW(dd, UW.SWo(2, [w1, w2, w3, w4, w5, w6, w7], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)), Nat.add(List.length(&2, U32, [w1, w2, w3, w4, w5, w6, w7]), 1n+i), U32.or(O.shl_bytes(w8, 2), UW.CRY(2, [w1, w2, w3, w4, w5, w6, w7], O.shr_over(w0, 2)))), UW.swo_app(2, [w1, w2, w3, w4, w5, w6, w7], [w8], dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2))),
        Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(2, z, dd, UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, 2), 0)), 1n+i, O.shr_over(w0, 2)), List.append(&2, U32, [w1, w2, w3, w4, w5, w6, w7], [w8]), [w1, w2, w3, w4, w5, w6, w7, w8], {==}))))


# ---- the model: the first eight words as Bitvector[256], then the last byte ----
def PXD(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32) -> FD.array__Tree<U32>:
  W8.W8X(r, dd, G256.PX_bv256(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7), Nat.add(8n, q), w8)
def pxd_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PXD(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)) == True{} : Bool}:
  W8.w8x_perfect(r, dd, G256.PX_bv256(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7), Nat.add(8n, q), w8, G256.bv256x_perfect(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, pf))

# T.bv257_put at X = 4 q + r is the model.
def bv257d_anyW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 33n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +e8: {U32.is_lt(w8, 256) == True{} : Bool}, +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(33n) : +List<U32>})
    -> {bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, PXD(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)) : Array<U32>}:
  match r:
    case 0n:
      +h9 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 9n), Nat.add(9n, q), FD.nat__add_comm(q, 9n), hl)
      +e0 = FD.logic__subst(Nat, z => {U32.to_nat(X) == z : Nat}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), e)
      +g = d0W(dd, D, X, q, e0, hd, pf, h9, w0, w1, w2, w3, w4, w5, w6, w7, w8, hz)
      Equal.trans(Array<U32>, bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}), FD.array__thaw(U32, UW.ORW(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q), 8n+q, w8)),
        FD.array__thaw(U32, PXD(0n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)), g,
        Equal.cong(U32, Array<U32>, z => FD.array__thaw(U32, UW.ORW(dd, VF.updv([w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q), 8n+q, z)), w8, U32.and(w8, 255),
          Equal.sym(U32, U32.and(w8, 255), w8, VBB.ea(w8, e8))))
    case 1n:
      +vt = VBB.z8(w8, e8)
      +h9 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 9n), Nat.add(9n, q), FD.nat__add_comm(q, 9n), hl)
      +hj = FD.nat__succ_le_lt(8n+q, VB.pw(dd), h9)
      +g = d1(dd, D, X, q, w0, w1, w2, w3, w4, w5, w6, w7, w8, e, hd, h9, pf, vt, hz)
      +m = orsm(dd, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, UW.CRY(1, [w0, w1, w2, w3, w4, w5, w6, w7], 0), VWB.SHB(U32.and(w8, 255), 1n), UW.swo_perfect(1, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0, pf), hj)
      +ea = Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORW(dd, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(z, 1n), UW.CRY(1, [w0, w1, w2, w3, w4, w5, w6, w7], 0))), U32.and(w8, 255), w8, VBB.ea(w8, e8))
      Equal.trans(Array<U32>, bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}), FD.array__thaw(U32, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0)),
        FD.array__thaw(U32, PXD(1n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)), g,
        Equal.cong(FD.array__Tree<U32>, Array<U32>, z => FD.array__thaw(U32, z), UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0), PXD(1n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8),
          Equal.sym(FD.array__Tree<U32>, PXD(1n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8), UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0),
            Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, UW.ORS(dd, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, UW.CRY(1, [w0, w1, w2, w3, w4, w5, w6, w7], 0)), 8n+q, VWB.SHB(U32.and(w8, 255), 1n)), UW.ORW(dd, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(U32.and(w8, 255), 1n), UW.CRY(1, [w0, w1, w2, w3, w4, w5, w6, w7], 0))),
              UW.ORW(dd, UW.SWo(1, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(w8, 1n), UW.CRY(1, [w0, w1, w2, w3, w4, w5, w6, w7], 0))), m, ea))))
    case 2n:
      +vt = VBB.z8(w8, e8)
      +h9 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 9n), Nat.add(9n, q), FD.nat__add_comm(q, 9n), hl)
      +hj = FD.nat__succ_le_lt(8n+q, VB.pw(dd), h9)
      +g = d2(dd, D, X, q, w0, w1, w2, w3, w4, w5, w6, w7, w8, e, hd, h9, pf, vt, hz)
      +m = orsm(dd, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, UW.CRY(2, [w0, w1, w2, w3, w4, w5, w6, w7], 0), VWB.SHB(U32.and(w8, 255), 2n), UW.swo_perfect(2, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0, pf), hj)
      +ea = Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORW(dd, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(z, 2n), UW.CRY(2, [w0, w1, w2, w3, w4, w5, w6, w7], 0))), U32.and(w8, 255), w8, VBB.ea(w8, e8))
      Equal.trans(Array<U32>, bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}), FD.array__thaw(U32, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0)),
        FD.array__thaw(U32, PXD(2n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)), g,
        Equal.cong(FD.array__Tree<U32>, Array<U32>, z => FD.array__thaw(U32, z), UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0), PXD(2n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8),
          Equal.sym(FD.array__Tree<U32>, PXD(2n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8), UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0),
            Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, UW.ORS(dd, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, UW.CRY(2, [w0, w1, w2, w3, w4, w5, w6, w7], 0)), 8n+q, VWB.SHB(U32.and(w8, 255), 2n)), UW.ORW(dd, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(U32.and(w8, 255), 2n), UW.CRY(2, [w0, w1, w2, w3, w4, w5, w6, w7], 0))),
              UW.ORW(dd, UW.SWo(2, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(w8, 2n), UW.CRY(2, [w0, w1, w2, w3, w4, w5, w6, w7], 0))), m, ea))))
    case 3n:
      +vt = VBB.z8(w8, e8)
      +h9 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 9n), Nat.add(9n, q), FD.nat__add_comm(q, 9n), hl)
      +hj = FD.nat__succ_le_lt(8n+q, VB.pw(dd), h9)
      +g = G257.gputu3_bv257(dd, D, X, q, w0, w1, w2, w3, w4, w5, w6, w7, w8, e, hd, h9, pf, vt, hz)
      +m = orsm(dd, UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, UW.CRY(3, [w0, w1, w2, w3, w4, w5, w6, w7], 0), VWB.SHB(U32.and(w8, 255), 3n), UW.swo_perfect(3, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0, pf), hj)
      +ea = Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORW(dd, UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(z, 3n), UW.CRY(3, [w0, w1, w2, w3, w4, w5, w6, w7], 0))), U32.and(w8, 255), w8, VBB.ea(w8, e8))
      Equal.trans(Array<U32>, bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}), FD.array__thaw(U32, UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0)),
        FD.array__thaw(U32, PXD(3n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)), g,
        Equal.cong(FD.array__Tree<U32>, Array<U32>, z => FD.array__thaw(U32, z), UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0), PXD(3n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8),
          Equal.sym(FD.array__Tree<U32>, PXD(3n, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8), UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7, w8], dd, D, q, 0),
            Equal.trans(FD.array__Tree<U32>, UW.ORW(dd, UW.ORS(dd, UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, UW.CRY(3, [w0, w1, w2, w3, w4, w5, w6, w7], 0)), 8n+q, VWB.SHB(U32.and(w8, 255), 3n)), UW.ORW(dd, UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(U32.and(w8, 255), 3n), UW.CRY(3, [w0, w1, w2, w3, w4, w5, w6, w7], 0))),
              UW.ORW(dd, UW.SWo(3, [w0, w1, w2, w3, w4, w5, w6, w7], dd, D, q, 0), 8n+q, U32.or(VWB.SHB(w8, 3n), UW.CRY(3, [w0, w1, w2, w3, w4, w5, w6, w7], 0))), m, ea))))
    case 4n+ +t: Empty.absurd({bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, PXD(4n+t, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)) : Array<U32>}, FD.nat__lt_zero_absurd(t, hr))

def bv257d_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 33n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +e8: {U32.is_lt(w8, 256) == True{} : Bool}, +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(33n) : +List<U32>})
    -> {bitvector_257_e.bv257_put(FD.array__thaw(U32, D), X, bitvector_257_d.Bitvector257{w0, w1, w2, w3, w4, w5, w6, w7, w8}) == FD.array__thaw(U32, PXD(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)) : Array<U32>}:
  bv257d_anyW(dd, D, X, q, r, w0, w1, w2, w3, w4, w5, w6, w7, w8, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, e8, hz)

# the last byte's room: word 8 + q, from the 33 bytes' room
def hle(+q: Nat, +dd: Nat, +h: {Nat.is_le(Nat.add(q, 9n), VB.pw(dd)) == True{} : Bool}) -> {Nat.is_le(Nat.add(Nat.add(8n, q), 1n), VB.pw(dd)) == True{} : Bool}:
  +e1 = Equal.cong(Nat, Nat, z => 8n+z, Nat.add(q, 1n), Nat.add(1n, q), FD.nat__add_comm(q, 1n))
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 9n), Nat.add(Nat.add(8n, q), 1n),
    Equal.trans(Nat, Nat.add(q, 9n), Nat.add(9n, q), Nat.add(Nat.add(8n, q), 1n), FD.nat__add_comm(q, 9n), Equal.sym(Nat, Nat.add(Nat.add(8n, q), 1n), Nat.add(9n, q), e1)), h)
def hl1f(+q: Nat, +r: Nat, +dd: Nat, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 33n))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(8n, q), UWD.NWN(Nat.add(r, 1n))), VB.pw(dd)) == True{} : Bool}:
  match r:
    case 0n: hle(q, dd, hl)
    case 1n: hle(q, dd, hl)
    case 2n: hle(q, dd, hl)
    case 3n: hle(q, dd, hl)
    case 4n+ +t: Empty.absurd({Nat.is_le(Nat.add(Nat.add(8n, q), UWD.NWN(Nat.add(4n+t, 1n))), VB.pw(dd)) == True{} : Bool}, FD.nat__lt_zero_absurd(t, hr))

# Its bytes: the 33 bytes at X (the eight words' limbs, then the last byte), when those were zero.
def bv257d_any_bytesW(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 33n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +e8: {U32.is_lt(w8, 256) == True{} : Bool}, +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(33n) : +List<U32>})
    -> {UA.BYT(PXD(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, FX.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), [U32.and(w8, 255)])) : +List<U32>}:
  +B = UA.BYT(D)
  +P = Nat.add(A.quad(q), r)
  +M = G256.PX_bv256(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7)
  +L8 = FX.limbs([w0, w1, w2, w3, w4, w5, w6, w7])
  +hl32 = FD.nat__le_trans(Nat.add(q, UWD.NWN(Nat.add(r, 32n))), Nat.add(q, UWD.NWN(Nat.add(r, 33n))), VB.pw(dd),
    Order.add_left(q, UWD.NWN(Nat.add(r, 32n)), UWD.NWN(Nat.add(r, 33n)), VRX.nwn_mono(Nat.add(r, 32n), Nat.add(r, 33n), Order.add_left(r, 32n, 33n, {==}))), hl)
  +hz32 = VRX.zhead(32n, 1n, VS.bdr(P, B), hz)
  +b1 = G256.bv256_any_bytesW(dd, D, X, q, r, w0, w1, w2, w3, w4, w5, w6, w7, e, hr, hd, hl32, pf, hz32)
  +hb = VRX.xend(q, r, 33n, dd, hl)
  +hX = VRB.hxb(P, 33n, dd, D, pf, hb)
  +z1 = VRX.znext(B, P, L8, Nat.add(32n, P), 32n, 1n, UA.BYT(M), hX, {==}, VRB.pcx(P, 32n), b1, hz)
  +e1 = VRB.fposbW(dd, X, 32, P, 33n, e, hd, hb, {==})
  +hl1 = hl1f(q, r, dd, hr, hl)
  +b2 = W8.w8_any_bytesW(dd, M, U32.add(X, 32), Nat.add(8n, q), r, w8, e1, hr, hd, hl1, G256.bv256x_perfect(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, pf), z1)
  Equal.trans(+List<U32>, UA.BYT(PXD(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)), UW.SPL(UA.BYT(M), Nat.add(32n, P), [U32.and(w8, 255)]), UW.SPL(B, P, List.append(&2, U32, L8, [U32.and(w8, 255)])), b2,
    VRX.spl_catx(B, P, L8, [U32.and(w8, 255)], Nat.add(32n, P), UA.BYT(M), hX, VRB.pcx(P, 32n), b1))

def bv257d_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +w5: U32, +w6: U32, +w7: U32, +w8: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 33n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +e8: {U32.is_lt(w8, 256) == True{} : Bool}, +hz: {VS.bt(33n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(33n) : +List<U32>})
    -> {UA.BYT(PXD(r, dd, D, q, w0, w1, w2, w3, w4, w5, w6, w7, w8)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, FX.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), [U32.and(w8, 255)])) : +List<U32>}:
  bv257d_any_bytesW(dd, D, X, q, r, w0, w1, w2, w3, w4, w5, w6, w7, w8, e, hr, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, e8, hz)

# The object's 33 bytes (the eight words' limbs, then the last byte).
def BYW(o: bitvector_257_d.Bitvector257) -> +List<U32>:
  match o:
    case bitvector_257_d.Bitvector257{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8}: List.append(&2, U32, FX.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), [U32.and(w8, 255)])
