import Base
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vcopy.bend as VC
import ./vbytes.bend as VY
import ./vbenc.bend as VBE
import ./vua.bend as UA
import ./vuw_bits.bend as UWB
import ./vuw.bend as UW
import ./vuw1.bend as UB1
import ./vuw2.bend as UB2
import ./vuw3.bend as UB3
import ./vuwp1.bend as UP1
import ./vuwp2.bend as UP2
import ./vuwp3.bend as UP3
import ./vuwf1.bend as UF1
import ./vuwf2.bend as UF2
import ./vuwf3.bend as UF3
import ./vbrt.bend as VR
import ../../types/fulu_obj.bend as T
import ./var_bytes_fix.bend as VBF

# The unaligned write layer's dispatch: the runtime's writers at ANY byte position
# X = 4 q + r (r < 4, symbolic), each the model of its case (the aligned runs of
# vbuf/vfix at r = 0, the models of vuw at r = 1, 2, 3), and the model's bytes the
# splice UW.SPL(BYT(D), 4 q + r, bytes) when the bytes there were zero.
#   PWM / putw_any / putw_any_bytes   O.put_words of n bytes held in T
#   W32X / w32_any / w32_any_bytes    O.w32
#   W64X / w64_any / w64_any_bytes    O.w64 (T.u64_put)
#   B20X / b20_any / b20_any_bytes    T.b20_put

# ---- O.put_words ------------------------------------------------------------------------------

def PWM(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32) -> FD.array__Tree<U32>:
  match r:
    case 0n: VB.mone(VC.NW(n), 0n, q, dd, D, T)
    case 1n: UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 2n: UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 3n: UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 4n+t: D

# The aligned copy, its partial last word's zero taken from the zero window.
def pwa2(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hzw: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(P), 0n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>},
    +b: Bool, +eb: {U32.is_eq(VY.RM(n), 0) == b : Bool})
    -> {O.pw_al_tail(b, VC.nwu(n), U32.shrn(p, 2n), O.acopy(O.pick(b, VC.nwu(n), U32.sub(VC.nwu(n), 1)), 0, U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), FD.array__thaw(U32, T)) : Array<U32> & Array<U32>}:
  match b:
    case True{}: VB.acopy_ok(VC.nwu(n), 0, U32.shrn(p, 2n), 0n, P, dd, dw, D, T, {==}, eP, hdd, hdw, hsrc, hdst, pfD, pfT)
    case False{}:
      +QL = VY.QL(n)
      +eNQ = VY.nw_q(n, k, hk, hy, eb)
      +hm = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(VY.QL(n)), 4n), A.quad(z)) == True{} : Bool}, 1n+VY.QL(n), VC.NW(n), Equal.sym(Nat, VC.NW(n), 1n+VY.QL(n), eNQ),
        FD.logic__subst(Nat, z => {Nat.is_le(z, 4n+A.quad(VY.QL(n))) == True{} : Bool}, 4n+A.quad(VY.QL(n)), Nat.add(A.quad(VY.QL(n)), 4n), FD.nat__add_comm(4n, A.quad(VY.QL(n))), FD.nat__le_refl(4n+A.quad(VY.QL(n)))))
      +hd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, P), VB.pw(dd)) == True{} : Bool}, VC.NW(n), 1n+VY.QL(n), eNQ, hdst)
      +hl = FD.nat__succ_le_lt(Nat.add(VY.QL(n), P), VB.pw(dd), hd1)
      +hz0 = UW.zslot_g(dd, D, P, 0n, A.quad(VC.NW(n)), VY.QL(n), A.quad(VY.QL(n)), pfD, hzw, {==}, hm, hl)
      VBE.pw_part(dd, dw, D, T, p, P, n, k, pfD, pfT, hdd, hdw, eP, hk, hy, hsrc, hdst, hz0, eb)

def pwn2(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32, +k: Nat,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +hsrc: {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(dw)) == True{} : Bool},
    +hdst: {Nat.is_le(Nat.add(VC.NW(n), P), VB.pw(dd)) == True{} : Bool},
    +hzw: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(P), 0n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>},
    +z: Bool, +ez: {U32.is_eq(n, 0) == z : Bool})
    -> {O.put_fin(n, O.pw_empty(z, U32.and(p, 3), n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
        == (FD.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match z:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, ez)) :
        {(FD.array__thaw(U32, D), O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, VB.mone(VC.NW(_), 0n, P, dd, D, T)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}
    case False{}:
      %Equal.sym(U32, U32.and(p, 3), 0, hp3) :
        {O.put_fin(n, O.pw_go(U32.is_eq(_, 0), _, n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)))
          == (FD.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      %Equal.sym(Array<U32> & Array<U32>, O.pw_aligned(n, VC.nwu(n), U32.shrn(p, 2n), FD.array__thaw(U32, D), FD.array__thaw(U32, T)),
          (FD.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), FD.array__thaw(U32, T)),
          pwa2(dd, dw, D, T, p, P, n, k, pfD, pfT, hdd, hdw, hp3, eP, hk, hy, hsrc, hdst, hzw, U32.is_eq(VY.RM(n), 0), {==})) :
        {O.put_fin(n, _) == (FD.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}

def putw_u1(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      UP1.putwu(dd, D, X, q, dw, T, n, e, eb, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.nw_pos(n, k, hk, hy, eb), hsrc,
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(VC.NW(n), q), {==}, hl), hz, pf, pfT)

def putw_u2(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      UP2.putwu(dd, D, X, q, dw, T, n, e, eb, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.nw_pos(n, k, hk, hy, eb), hsrc,
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(VC.NW(n), q), {==}, hl), hz, pf, pfT)

def putw_u3(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      UP3.putwu(dd, D, X, q, dw, T, n, e, eb, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.nw_pos(n, k, hk, hy, eb), hsrc,
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(VC.NW(n), q), {==}, hl), hz, pf, pfT)

# O.put_words at any byte position X = 4 q + r.
def putw_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match r:
    case 0n:
      pwn2(dd, dw, D, T, X, q, n, k, pf, pfT, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.ua_3(X, q, 0n, 0, {==}, e, {==}), UW.ua_q(X, q, 0n, e, {==}), hk, hy,
        FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), Nat.add(VC.NW(n), 0n), Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))), hsrc),
        FD.nat__lt_le(Nat.add(VC.NW(n), q), VB.pw(dd), hl), hz, U32.is_eq(n, 0), {==})
    case 1n: putw_u1(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, k, e, hd, hdw, hk, hy, hsrc, hl, pf, pfT, hz, {==})
    case 2n: putw_u2(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, k, e, hd, hdw, hk, hy, hsrc, hl, pf, pfT, hz, {==})
    case 3n: putw_u3(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, k, e, hd, hdw, hk, hy, hsrc, hl, pf, pfT, hz, {==})
    case 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))

def putw_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(PWM(0n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), _, FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))) : +List<U32>}
      UW.mone_bytes(VC.NW(n), 0n, q, dd, D, dw, T, pf, pfT, FD.nat__lt_le(Nat.add(VC.NW(n), q), VB.pw(dd), hl), hsrc)
    case 1n:
      +eL = UW.len_take(VC.NW(n), UW.SLW(T), FD.logic__subst(Nat, z => {Nat.is_le(VC.NW(n), z) == True{} : Bool}, VB.pw(dw), VB.len(UW.SLW(T)), Equal.sym(Nat, VB.len(UW.SLW(T)), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc))
      +hr1 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eL),
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl))
      UB1.swcb(VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, pf, hr1, FD.logic__subst(Nat, z => {VS.bt(A.quad(z), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(A.quad(z)) : +List<U32>}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eL), hz))
    case 2n:
      +eL = UW.len_take(VC.NW(n), UW.SLW(T), FD.logic__subst(Nat, z => {Nat.is_le(VC.NW(n), z) == True{} : Bool}, VB.pw(dw), VB.len(UW.SLW(T)), Equal.sym(Nat, VB.len(UW.SLW(T)), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc))
      +hr1 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eL),
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl))
      UB2.swcb(VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, pf, hr1, FD.logic__subst(Nat, z => {VS.bt(A.quad(z), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(A.quad(z)) : +List<U32>}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eL), hz))
    case 3n:
      +eL = UW.len_take(VC.NW(n), UW.SLW(T), FD.logic__subst(Nat, z => {Nat.is_le(VC.NW(n), z) == True{} : Bool}, VB.pw(dw), VB.len(UW.SLW(T)), Equal.sym(Nat, VB.len(UW.SLW(T)), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc))
      +hr1 = FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eL),
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(q, VC.NW(n)), FD.nat__add_comm(VC.NW(n), q), hl))
      UB3.swcb(VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, pf, hr1, FD.logic__subst(Nat, z => {VS.bt(A.quad(z), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(A.quad(z)) : +List<U32>}, VC.NW(n), List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), Equal.sym(Nat, List.length(&2, U32, VS.wtake(VC.NW(n), UW.SLW(T))), VC.NW(n), eL), hz))
    case 4n+ +t: Empty.absurd({UA.BYT(PWM(4n+t, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))

# ---- O.w32 ------------------------------------------------------------------------------------

def W32X(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +x: U32) -> FD.array__Tree<U32>:
  match r:
    case 0n: FD.array__upd(U32, dd, D, q, x)
    case 1n: UW.W32M(1, dd, D, q, x)
    case 2n: UW.W32M(2, dd, D, q, x)
    case 3n: UW.W32M(3, dd, D, q, x)
    case 4n+t: D

# O.w32 at any byte position X = 4 q + r.
def w32_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(1n+q, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w32(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W32X(r, dd, D, q, x)) : Array<U32>}:
  match r:
    case 0n:
      %Equal.sym(U32, U32.and(X, 3), 0, UW.ua_3(X, q, 0n, 0, {==}, e, {==})) : {O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W32X(0n, dd, D, q, x)) : Array<U32>}
      VB.set_n(dd, D, U32.shrn(X, 2n), q, x, UW.ua_q(X, q, 0n, e, {==}), FD.nat__lt_trans(dd, 29n, 32n, hd, {==}), FD.nat__lt_trans(q, 1n+q, VB.pw(dd), FD.nat__lt_succ(q), hl), pf)
    case 1n: UW.w32u_rt(1, 1n, {==}, {==}, {==}, dd, D, X, q, x, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf)
    case 2n: UW.w32u_rt(2, 2n, {==}, {==}, {==}, dd, D, X, q, x, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf)
    case 3n: UW.w32u_rt(3, 3n, {==}, {==}, {==}, dd, D, X, q, x, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf)
    case 4n+ +t: Empty.absurd({O.w32(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W32X(4n+t, dd, D, q, x)) : Array<U32>}, FD.nat__lt_zero_absurd(t, hr))

# Its bytes: x's limbs at X, when the four bytes there were zero.
def w32_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(1n+q, VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(4n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(4n) : +List<U32>})
    -> {UA.BYT(W32X(r, dd, D, q, x)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), I.limb(x)) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(W32X(0n, dd, D, q, x)) == UW.SPL(UA.BYT(D), _, I.limb(x)) : +List<U32>}
      UW.updv_bytes([x], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, 1n+q, Nat.add(q, 1n),
        Equal.sym(Nat, Nat.add(q, 1n), 1n+q, Equal.trans(Nat, Nat.add(q, 1n), 1n+Nat.add(q, 0n), 1n+q, FD.nat__add_succ(q, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(q, 0n), q, FD.nat__add_zero(q)))),
        FD.nat__lt_le(1n+q, VB.pw(dd), hl)))
    case 1n: UB1.w32b(x, dd, D, q, pf, hl, hz)
    case 2n: UB2.w32b(x, dd, D, q, pf, hl, hz)
    case 3n: UB3.w32b(x, dd, D, q, pf, hl, hz)
    case 4n+ +t: Empty.absurd({UA.BYT(W32X(4n+t, dd, D, q, x)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), I.limb(x)) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))

# ---- O.w64 ------------------------------------------------------------------------------------

def W64X(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +lo: U32, +hi: U32) -> FD.array__Tree<U32>:
  match r:
    case 0n: VF.updv([lo, hi], dd, D, q)
    case 1n: UW.W32M(1, dd, UW.W32M(1, dd, D, q, lo), 1n+q, hi)
    case 2n: UW.W32M(2, dd, UW.W32M(2, dd, D, q, lo), 1n+q, hi)
    case 3n: UW.W32M(3, dd, UW.W32M(3, dd, D, q, lo), 1n+q, hi)
    case 4n+t: D

# O.w64 at any byte position X = 4 q + r.
def w64_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +lo: U32, +hi: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(Nat.add(2n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w64(FD.array__thaw(U32, D), X, O.U64{lo, hi}) == FD.array__thaw(U32, W64X(r, dd, D, q, lo, hi)) : Array<U32>}:
  match r:
    case 0n: VBF.put_u64(dd, D, X, q, FD.logic__subst(Nat, z => {U32.to_nat(X) == z : Nat}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), e), hd, pf, FD.nat__lt_le(Nat.add(2n, q), VB.pw(dd), hl), lo, hi)
    case 1n: UW.w64u_rt(1, 1n, {==}, {==}, {==}, dd, D, X, q, lo, hi, e, hd, hl, pf)
    case 2n: UW.w64u_rt(2, 2n, {==}, {==}, {==}, dd, D, X, q, lo, hi, e, hd, hl, pf)
    case 3n: UW.w64u_rt(3, 3n, {==}, {==}, {==}, dd, D, X, q, lo, hi, e, hd, hl, pf)
    case 4n+ +t: Empty.absurd({O.w64(FD.array__thaw(U32, D), X, O.U64{lo, hi}) == FD.array__thaw(U32, W64X(4n+t, dd, D, q, lo, hi)) : Array<U32>}, FD.nat__lt_zero_absurd(t, hr))

def w64b1(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +lo: U32, +hi: U32, +hl: {Nat.is_lt(Nat.add(2n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(8n, VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(8n) : +List<U32>})
    -> {UA.BYT(UW.W32M(1, dd, UW.W32M(1, dd, D, q, lo), 1n+q, hi)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), FX.limbs([lo, hi])) : +List<U32>}:
  +hl1 = FD.nat__lt_trans(1n+q, 2n+q, VB.pw(dd), FD.nat__lt_succ(1n+q), hl)
  +hX = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), 1n), z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), VR.lenS(dd, D, pf)),
    UW.room_q(0n, q, 2n, 1n, dd, hl, {==}, {==}))
  +I0 = UW.inv_init(UA.BYT(D), Nat.add(A.quad(q), 1n), 8n, UW.ZB(8n), hz, {==})
  +z1 = UW.inv_zero(UA.BYT(D), Nat.add(A.quad(q), 1n), 8n, UW.ZB(8n), 0n, 4n, UA.BYT(D), hX, I0, {==}, {==}, {==})
  +z1b = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(z, UA.BYT(D))) == UW.ZB(4n) : +List<U32>}, Nat.add(Nat.add(A.quad(q), 1n), 0n), Nat.add(A.quad(q), 1n), FD.nat__add_zero(Nat.add(A.quad(q), 1n)), z1)
  +o1 = FD.logic__subst(Nat, z => {UA.BYT(UW.W32M(1, dd, D, q, lo)) == UW.SPL(UA.BYT(D), z, I.limb(lo)) : +List<U32>}, Nat.add(A.quad(q), 1n), Nat.add(Nat.add(A.quad(q), 1n), 0n), Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), 1n), 0n), Nat.add(A.quad(q), 1n), FD.nat__add_zero(Nat.add(A.quad(q), 1n))),
    UB1.w32b(lo, dd, D, q, pf, hl1, z1b))
  +I1 = UW.inv_step(UA.BYT(D), Nat.add(A.quad(q), 1n), 8n, UW.ZB(8n), 0n, I.limb(lo), 4n, UA.BYT(D), UA.BYT(UW.W32M(1, dd, D, q, lo)), hX, I0, o1, {==}, {==})
  +z2 = UW.inv_zero(UA.BYT(D), Nat.add(A.quad(q), 1n), 8n, UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, 4n, UA.BYT(UW.W32M(1, dd, D, q, lo)), hX, I1, {==}, {==}, {==})
  +ep = UW.pos_eq(1n, q, 1n)
  +z2b = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(z, UA.BYT(UW.W32M(1, dd, D, q, lo)))) == UW.ZB(4n) : +List<U32>}, Nat.add(Nat.add(A.quad(q), 1n), 4n), Nat.add(A.quad(1n+q), 1n), Equal.sym(Nat, Nat.add(A.quad(1n+q), 1n), Nat.add(Nat.add(A.quad(q), 1n), 4n), ep), z2)
  +o2 = FD.logic__subst(Nat, z => {UA.BYT(UW.W32M(1, dd, UW.W32M(1, dd, D, q, lo), 1n+q, hi)) == UW.SPL(UA.BYT(UW.W32M(1, dd, D, q, lo)), z, I.limb(hi)) : +List<U32>}, Nat.add(A.quad(1n+q), 1n), Nat.add(Nat.add(A.quad(q), 1n), 4n), ep,
    UB1.w32b(hi, dd, UW.W32M(1, dd, D, q, lo), 1n+q, UW.w32m_perfect(1, dd, D, q, lo, pf), hl, z2b))
  +I2 = UW.inv_step(UA.BYT(D), Nat.add(A.quad(q), 1n), 8n, UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, I.limb(hi), 0n, UA.BYT(UW.W32M(1, dd, D, q, lo)), UA.BYT(UW.W32M(1, dd, UW.W32M(1, dd, D, q, lo), 1n+q, hi)), hX, I1, o2, {==}, {==})
  Equal.trans(+List<U32>, UA.BYT(UW.W32M(1, dd, UW.W32M(1, dd, D, q, lo), 1n+q, hi)), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), VS.bt(8n, UW.SPL(UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, I.limb(hi)))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), FX.limbs([lo, hi])), I2, {==})

def w64b2(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +lo: U32, +hi: U32, +hl: {Nat.is_lt(Nat.add(2n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(8n, VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(8n) : +List<U32>})
    -> {UA.BYT(UW.W32M(2, dd, UW.W32M(2, dd, D, q, lo), 1n+q, hi)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), FX.limbs([lo, hi])) : +List<U32>}:
  +hl1 = FD.nat__lt_trans(1n+q, 2n+q, VB.pw(dd), FD.nat__lt_succ(1n+q), hl)
  +hX = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), 2n), z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), VR.lenS(dd, D, pf)),
    UW.room_q(0n, q, 2n, 2n, dd, hl, {==}, {==}))
  +I0 = UW.inv_init(UA.BYT(D), Nat.add(A.quad(q), 2n), 8n, UW.ZB(8n), hz, {==})
  +z1 = UW.inv_zero(UA.BYT(D), Nat.add(A.quad(q), 2n), 8n, UW.ZB(8n), 0n, 4n, UA.BYT(D), hX, I0, {==}, {==}, {==})
  +z1b = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(z, UA.BYT(D))) == UW.ZB(4n) : +List<U32>}, Nat.add(Nat.add(A.quad(q), 2n), 0n), Nat.add(A.quad(q), 2n), FD.nat__add_zero(Nat.add(A.quad(q), 2n)), z1)
  +o1 = FD.logic__subst(Nat, z => {UA.BYT(UW.W32M(2, dd, D, q, lo)) == UW.SPL(UA.BYT(D), z, I.limb(lo)) : +List<U32>}, Nat.add(A.quad(q), 2n), Nat.add(Nat.add(A.quad(q), 2n), 0n), Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), 2n), 0n), Nat.add(A.quad(q), 2n), FD.nat__add_zero(Nat.add(A.quad(q), 2n))),
    UB2.w32b(lo, dd, D, q, pf, hl1, z1b))
  +I1 = UW.inv_step(UA.BYT(D), Nat.add(A.quad(q), 2n), 8n, UW.ZB(8n), 0n, I.limb(lo), 4n, UA.BYT(D), UA.BYT(UW.W32M(2, dd, D, q, lo)), hX, I0, o1, {==}, {==})
  +z2 = UW.inv_zero(UA.BYT(D), Nat.add(A.quad(q), 2n), 8n, UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, 4n, UA.BYT(UW.W32M(2, dd, D, q, lo)), hX, I1, {==}, {==}, {==})
  +ep = UW.pos_eq(1n, q, 2n)
  +z2b = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(z, UA.BYT(UW.W32M(2, dd, D, q, lo)))) == UW.ZB(4n) : +List<U32>}, Nat.add(Nat.add(A.quad(q), 2n), 4n), Nat.add(A.quad(1n+q), 2n), Equal.sym(Nat, Nat.add(A.quad(1n+q), 2n), Nat.add(Nat.add(A.quad(q), 2n), 4n), ep), z2)
  +o2 = FD.logic__subst(Nat, z => {UA.BYT(UW.W32M(2, dd, UW.W32M(2, dd, D, q, lo), 1n+q, hi)) == UW.SPL(UA.BYT(UW.W32M(2, dd, D, q, lo)), z, I.limb(hi)) : +List<U32>}, Nat.add(A.quad(1n+q), 2n), Nat.add(Nat.add(A.quad(q), 2n), 4n), ep,
    UB2.w32b(hi, dd, UW.W32M(2, dd, D, q, lo), 1n+q, UW.w32m_perfect(2, dd, D, q, lo, pf), hl, z2b))
  +I2 = UW.inv_step(UA.BYT(D), Nat.add(A.quad(q), 2n), 8n, UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, I.limb(hi), 0n, UA.BYT(UW.W32M(2, dd, D, q, lo)), UA.BYT(UW.W32M(2, dd, UW.W32M(2, dd, D, q, lo), 1n+q, hi)), hX, I1, o2, {==}, {==})
  Equal.trans(+List<U32>, UA.BYT(UW.W32M(2, dd, UW.W32M(2, dd, D, q, lo), 1n+q, hi)), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), VS.bt(8n, UW.SPL(UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, I.limb(hi)))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), FX.limbs([lo, hi])), I2, {==})

def w64b3(+dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +lo: U32, +hi: U32, +hl: {Nat.is_lt(Nat.add(2n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(8n, VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(8n) : +List<U32>})
    -> {UA.BYT(UW.W32M(3, dd, UW.W32M(3, dd, D, q, lo), 1n+q, hi)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), FX.limbs([lo, hi])) : +List<U32>}:
  +hl1 = FD.nat__lt_trans(1n+q, 2n+q, VB.pw(dd), FD.nat__lt_succ(1n+q), hl)
  +hX = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(q), 3n), z) == True{} : Bool}, A.quad(VB.pw(dd)), List.length(&2, U32, UA.BYT(D)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(D)), A.quad(VB.pw(dd)), VR.lenS(dd, D, pf)),
    UW.room_q(0n, q, 2n, 3n, dd, hl, {==}, {==}))
  +I0 = UW.inv_init(UA.BYT(D), Nat.add(A.quad(q), 3n), 8n, UW.ZB(8n), hz, {==})
  +z1 = UW.inv_zero(UA.BYT(D), Nat.add(A.quad(q), 3n), 8n, UW.ZB(8n), 0n, 4n, UA.BYT(D), hX, I0, {==}, {==}, {==})
  +z1b = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(z, UA.BYT(D))) == UW.ZB(4n) : +List<U32>}, Nat.add(Nat.add(A.quad(q), 3n), 0n), Nat.add(A.quad(q), 3n), FD.nat__add_zero(Nat.add(A.quad(q), 3n)), z1)
  +o1 = FD.logic__subst(Nat, z => {UA.BYT(UW.W32M(3, dd, D, q, lo)) == UW.SPL(UA.BYT(D), z, I.limb(lo)) : +List<U32>}, Nat.add(A.quad(q), 3n), Nat.add(Nat.add(A.quad(q), 3n), 0n), Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), 3n), 0n), Nat.add(A.quad(q), 3n), FD.nat__add_zero(Nat.add(A.quad(q), 3n))),
    UB3.w32b(lo, dd, D, q, pf, hl1, z1b))
  +I1 = UW.inv_step(UA.BYT(D), Nat.add(A.quad(q), 3n), 8n, UW.ZB(8n), 0n, I.limb(lo), 4n, UA.BYT(D), UA.BYT(UW.W32M(3, dd, D, q, lo)), hX, I0, o1, {==}, {==})
  +z2 = UW.inv_zero(UA.BYT(D), Nat.add(A.quad(q), 3n), 8n, UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, 4n, UA.BYT(UW.W32M(3, dd, D, q, lo)), hX, I1, {==}, {==}, {==})
  +ep = UW.pos_eq(1n, q, 3n)
  +z2b = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(z, UA.BYT(UW.W32M(3, dd, D, q, lo)))) == UW.ZB(4n) : +List<U32>}, Nat.add(Nat.add(A.quad(q), 3n), 4n), Nat.add(A.quad(1n+q), 3n), Equal.sym(Nat, Nat.add(A.quad(1n+q), 3n), Nat.add(Nat.add(A.quad(q), 3n), 4n), ep), z2)
  +o2 = FD.logic__subst(Nat, z => {UA.BYT(UW.W32M(3, dd, UW.W32M(3, dd, D, q, lo), 1n+q, hi)) == UW.SPL(UA.BYT(UW.W32M(3, dd, D, q, lo)), z, I.limb(hi)) : +List<U32>}, Nat.add(A.quad(1n+q), 3n), Nat.add(Nat.add(A.quad(q), 3n), 4n), ep,
    UB3.w32b(hi, dd, UW.W32M(3, dd, D, q, lo), 1n+q, UW.w32m_perfect(3, dd, D, q, lo, pf), hl, z2b))
  +I2 = UW.inv_step(UA.BYT(D), Nat.add(A.quad(q), 3n), 8n, UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, I.limb(hi), 0n, UA.BYT(UW.W32M(3, dd, D, q, lo)), UA.BYT(UW.W32M(3, dd, UW.W32M(3, dd, D, q, lo), 1n+q, hi)), hX, I1, o2, {==}, {==})
  Equal.trans(+List<U32>, UA.BYT(UW.W32M(3, dd, UW.W32M(3, dd, D, q, lo), 1n+q, hi)), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), VS.bt(8n, UW.SPL(UW.SPL(UW.ZB(8n), 0n, I.limb(lo)), 4n, I.limb(hi)))), UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), FX.limbs([lo, hi])), I2, {==})

# Its bytes: the limbs of lo and hi at X, when the eight bytes there were zero.
def w64_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +lo: U32, +hi: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(Nat.add(2n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(8n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(8n) : +List<U32>})
    -> {UA.BYT(W64X(r, dd, D, q, lo, hi)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), FX.limbs([lo, hi])) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(W64X(0n, dd, D, q, lo, hi)) == UW.SPL(UA.BYT(D), _, FX.limbs([lo, hi])) : +List<U32>}
      UW.updv_bytes([lo, hi], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(2n, q), Nat.add(q, 2n), FD.nat__add_comm(2n, q), FD.nat__lt_le(Nat.add(2n, q), VB.pw(dd), hl)))
    case 1n: w64b1(dd, D, q, lo, hi, hl, pf, hz)
    case 2n: w64b2(dd, D, q, lo, hi, hl, pf, hz)
    case 3n: w64b3(dd, D, q, lo, hi, hl, pf, hz)
    case 4n+ +t: Empty.absurd({UA.BYT(W64X(4n+t, dd, D, q, lo, hi)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), FX.limbs([lo, hi])) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))

# ---- T.b20_put --------------------------------------------------------------------------------

def B20X(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32) -> FD.array__Tree<U32>:
  match r:
    case 0n: VF.updv([w0, w1, w2, w3, w4], dd, D, q)
    case 1n: UW.SWc(1, [w0, w1, w2, w3, w4], dd, D, q, 0)
    case 2n: UW.SWc(2, [w0, w1, w2, w3, w4], dd, D, q, 0)
    case 3n: UW.SWc(3, [w0, w1, w2, w3, w4], dd, D, q, 0)
    case 4n+t: D

# T.b20_put at any byte position X = 4 q + r (the unaligned writer stores into the zero words).
def b20_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(Nat.add(5n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(20n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(20n) : +List<U32>})
    -> {T.b20_put(FD.array__thaw(U32, D), X, T.Bytes20{w0, w1, w2, w3, w4}) == FD.array__thaw(U32, B20X(r, dd, D, q, w0, w1, w2, w3, w4)) : Array<U32>}:
  match r:
    case 0n: VBF.put_b20(dd, D, X, q, FD.logic__subst(Nat, z => {U32.to_nat(X) == z : Nat}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), e), hd, pf, FD.nat__lt_le(Nat.add(5n, q), VB.pw(dd), hl), w0, w1, w2, w3, w4)
    case 1n: UF1.putu_b20(dd, D, X, q, w0, w1, w2, w3, w4, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, hz)
    case 2n: UF2.putu_b20(dd, D, X, q, w0, w1, w2, w3, w4, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, hz)
    case 3n: UF3.putu_b20(dd, D, X, q, w0, w1, w2, w3, w4, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hl, pf, hz)
    case 4n+ +t: Empty.absurd({T.b20_put(FD.array__thaw(U32, D), X, T.Bytes20{w0, w1, w2, w3, w4}) == FD.array__thaw(U32, B20X(4n+t, dd, D, q, w0, w1, w2, w3, w4)) : Array<U32>}, FD.nat__lt_zero_absurd(t, hr))

def b20_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_lt(Nat.add(5n, q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(20n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(20n) : +List<U32>})
    -> {UA.BYT(B20X(r, dd, D, q, w0, w1, w2, w3, w4)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), FX.limbs([w0, w1, w2, w3, w4])) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(B20X(0n, dd, D, q, w0, w1, w2, w3, w4)) == UW.SPL(UA.BYT(D), _, FX.limbs([w0, w1, w2, w3, w4])) : +List<U32>}
      UW.updv_bytes([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), FD.nat__lt_le(Nat.add(5n, q), VB.pw(dd), hl)))
    case 1n: UB1.swcb([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), hl), hz)
    case 2n: UB2.swcb([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), hl), hz)
    case 3n: UB3.swcb([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), hl), hz)
    case 4n+ +t: Empty.absurd({UA.BYT(B20X(4n+t, dd, D, q, w0, w1, w2, w3, w4)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), FX.limbs([w0, w1, w2, w3, w4])) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))
