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
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluBytes20_encode_ssz_generated.bend as FuluBytes20_e
import ./var_bytes_fix.bend as VBF
import ./vdepth.bend as VD
import ../compact/buf.bend as BF

# The unaligned write layer's dispatch: the runtime's writers at ANY byte position
# X = 4 q + r (r < 4, symbolic), each the model of its case (the aligned runs of
# vbuf/vfix at r = 0, the models of vuw at r = 1, 2, 3), and the model's bytes the
# splice UW.SPL(BYT(D), 4 q + r, bytes) when the bytes there were zero.
#   PWM / putw_any / putw_any_bytes   O.put_words of n bytes held in T
#   W32X / w32_any / w32_any_bytes    O.w32
#   W64X / w64_any / w64_any_bytes    O.w64 (T.u64_put)
#   B20X / b20_any / b20_any_bytes    T.b20_put
# Room is tight: q + NWN(r + m) <= 2^dd words for a value of m bytes (no word past the
# value's own). put_words's bytes are the n data bytes then PADB(r, n) zeros to the end of
# its last word (the source's tail bytes, zero by its storage check htz); its runtime
# lemma splits on n & 3 and r: a carry word inside the value (c1_*: the loose form
# putw_loose) or none (c2_*<s>: the open model, vuwp<s>.putwu_o). *_perfect: the models
# are perfect trees.

# The words a value of x bytes at byte r of a word spans (ceil((r + x) / 4) for r + x),
# and the zero bytes after m data bytes at byte r up to the end of the last of them.
def NWN(+x: Nat) -> Nat: VD.s_rng(2n, 3n+x)
def PADB(+r: Nat, +m: Nat) -> Nat: Nat.sub(Nat.sub(A.quad(NWN(Nat.add(r, m))), r), m)

# q + (1 + K) <= P: K + q < P.
def le_q(+q: Nat, +K: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(q, 1n+K), P) == True{} : Bool}) -> {Nat.is_lt(Nat.add(K, q), P) == True{} : Bool}:
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(q, 1n+K), Nat.add(1n+K, q), FD.nat__add_comm(q, 1n+K), h)
  FD.nat__succ_le_lt(Nat.add(K, q), P, h2)

# ---- O.put_words ------------------------------------------------------------------------------

def PWM(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32) -> FD.array__Tree<U32>:
  match r:
    case 0n: VB.mone(VC.NW(n), 0n, q, dd, D, T)
    case 1n: UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 2n: UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 3n: UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)
    case 4n+t: D

# The aligned copy, its partial last word's zero taken from the zero window.
def pwa2U(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
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
      +eNQ = VY.nw_qU(n, hy, eb)
      +hm = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(VY.QL(n)), 4n), A.quad(z)) == True{} : Bool}, 1n+VY.QL(n), VC.NW(n), Equal.sym(Nat, VC.NW(n), 1n+VY.QL(n), eNQ),
        FD.logic__subst(Nat, z => {Nat.is_le(z, 4n+A.quad(VY.QL(n))) == True{} : Bool}, 4n+A.quad(VY.QL(n)), Nat.add(A.quad(VY.QL(n)), 4n), FD.nat__add_comm(4n, A.quad(VY.QL(n))), FD.nat__le_refl(4n+A.quad(VY.QL(n)))))
      +hd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, P), VB.pw(dd)) == True{} : Bool}, VC.NW(n), 1n+VY.QL(n), eNQ, hdst)
      +hl = FD.nat__succ_le_lt(Nat.add(VY.QL(n), P), VB.pw(dd), hd1)
      +hz0 = UW.zslot_g(dd, D, P, 0n, A.quad(VC.NW(n)), VY.QL(n), A.quad(VY.QL(n)), pfD, hzw, {==}, hm, hl)
      VBE.pw_partU(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, eP, hy, hsrc, hdst, hz0, eb)

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
  pwa2U(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hzw, b, eb)

def pwn2U(+dd: Nat, +dw: Nat, +D: FD.array__Tree<U32>, +T: FD.array__Tree<U32>, +p: U32, +P: Nat, +n: U32,
    +pfD: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hp3: {U32.and(p, 3) == 0 : U32}, +eP: {U32.to_nat(U32.shrn(p, 2n)) == P : Nat}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
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
          pwa2U(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, hy, hsrc, hdst, hzw, U32.is_eq(VY.RM(n), 0), {==})) :
        {O.put_fin(n, _) == (FD.array__thaw(U32, VB.mone(VC.NW(n), 0n, P, dd, D, T)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
      {==}

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
  pwn2U(dd, dw, D, T, p, P, n, pfD, pfT, hdd, hdw, hp3, eP, VC.hyU(n, k, hk, hy), hsrc, hdst, hzw, z, ez)

def putw_u1U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      UP1.putwu(dd, D, X, q, dw, T, n, e, eb, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.nw_posU(n, hy, eb), hsrc,
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(VC.NW(n), q), {==}, hl), hz, pf, pfT)

def putw_u1(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putw_u1U(b, dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, eb)

def putw_u2U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      UP2.putwu(dd, D, X, q, dw, T, n, e, eb, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.nw_posU(n, hy, eb), hsrc,
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(VC.NW(n), q), {==}, hl), hz, pf, pfT)

def putw_u2(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putw_u2U(b, dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, eb)

def putw_u3U(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b:
    case True{}:
      %Equal.sym(U32, n, 0, FD.u32alg__eq_of(n, 0, eb)) :
        {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), _}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(_), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), _}) : Array<U32> & O.Words}
      {==}
    case False{}:
      UP3.putwu(dd, D, X, q, dw, T, n, e, eb, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.nw_posU(n, hy, eb), hsrc,
        FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(VC.NW(n), q), Nat.add(VC.NW(n), q), {==}, hl), hz, pf, pfT)

def putw_u3(+b: Bool, +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>}, +eb: {U32.is_eq(n, 0) == b : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, UW.SWc(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putw_u3U(b, dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz, eb)

# O.put_words at any byte position X = 4 q + r, with room for the carry word (the loose form).
def putw_looseU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match r:
    case 0n:
      pwn2U(dd, dw, D, T, X, q, n, pf, pfT, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.ua_3(X, q, 0n, 0, {==}, e, {==}), UW.ua_q(X, q, 0n, e, {==}), hy,
        FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), Nat.add(VC.NW(n), 0n), Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))), hsrc),
        FD.nat__lt_le(Nat.add(VC.NW(n), q), VB.pw(dd), hl), hz, U32.is_eq(n, 0), {==})
    case 1n: putw_u1U(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, hl, pf, pfT, hz, {==})
    case 2n: putw_u2U(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, hl, pf, pfT, hz, {==})
    case 3n: putw_u3U(U32.is_eq(n, 0), dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, hl, pf, pfT, hz, {==})
    case 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))

def putw_loose(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putw_looseU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz)

def putw_loose_bytesU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
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

def putw_loose_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_lt(Nat.add(VC.NW(n), q), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hz: {VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : +List<U32>})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T)))) : +List<U32>}:
  putw_loose_bytesU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, hz)

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
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, 4n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w32(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W32X(r, dd, D, q, x)) : Array<U32>}:
  match r:
    case 0n:
      %Equal.sym(U32, U32.and(X, 3), 0, UW.ua_3(X, q, 0n, 0, {==}, e, {==})) : {O.w32_pick(U32.is_eq(_, 0), FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W32X(0n, dd, D, q, x)) : Array<U32>}
      VB.set_n(dd, D, U32.shrn(X, 2n), q, x, UW.ua_q(X, q, 0n, e, {==}), FD.nat__lt_trans(dd, 29n, 32n, hd, {==}), le_q(q, 0n, VB.pw(dd), hl), pf)
    case 1n: UW.w32u_rt(1, 1n, {==}, {==}, {==}, dd, D, X, q, x, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), le_q(q, 1n, VB.pw(dd), hl), pf)
    case 2n: UW.w32u_rt(2, 2n, {==}, {==}, {==}, dd, D, X, q, x, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), le_q(q, 1n, VB.pw(dd), hl), pf)
    case 3n: UW.w32u_rt(3, 3n, {==}, {==}, {==}, dd, D, X, q, x, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), le_q(q, 1n, VB.pw(dd), hl), pf)
    case 4n+ +t: Empty.absurd({O.w32(FD.array__thaw(U32, D), X, x) == FD.array__thaw(U32, W32X(4n+t, dd, D, q, x)) : Array<U32>}, FD.nat__lt_zero_absurd(t, hr))

# Its bytes: x's limbs at X, when the four bytes there were zero.
def w32_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +x: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, 4n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(4n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(4n) : +List<U32>})
    -> {UA.BYT(W32X(r, dd, D, q, x)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), I.limb(x)) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(W32X(0n, dd, D, q, x)) == UW.SPL(UA.BYT(D), _, I.limb(x)) : +List<U32>}
      UW.updv_bytes([x], dd, D, q, pf, hl)
    case 1n: UB1.w32b(x, dd, D, q, pf, le_q(q, 1n, VB.pw(dd), hl), hz)
    case 2n: UB2.w32b(x, dd, D, q, pf, le_q(q, 1n, VB.pw(dd), hl), hz)
    case 3n: UB3.w32b(x, dd, D, q, pf, le_q(q, 1n, VB.pw(dd), hl), hz)
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
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, 8n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {O.w64(FD.array__thaw(U32, D), X, O.U64{lo, hi}) == FD.array__thaw(U32, W64X(r, dd, D, q, lo, hi)) : Array<U32>}:
  match r:
    case 0n: VBF.put_u64(dd, D, X, q, FD.logic__subst(Nat, z => {U32.to_nat(X) == z : Nat}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), e), hd, pf, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 2n), Nat.add(2n, q), FD.nat__add_comm(q, 2n), hl), lo, hi)
    case 1n: UW.w64u_rt(1, 1n, {==}, {==}, {==}, dd, D, X, q, lo, hi, e, hd, le_q(q, 2n, VB.pw(dd), hl), pf)
    case 2n: UW.w64u_rt(2, 2n, {==}, {==}, {==}, dd, D, X, q, lo, hi, e, hd, le_q(q, 2n, VB.pw(dd), hl), pf)
    case 3n: UW.w64u_rt(3, 3n, {==}, {==}, {==}, dd, D, X, q, lo, hi, e, hd, le_q(q, 2n, VB.pw(dd), hl), pf)
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
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, 8n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(8n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(8n) : +List<U32>})
    -> {UA.BYT(W64X(r, dd, D, q, lo, hi)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), FX.limbs([lo, hi])) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(W64X(0n, dd, D, q, lo, hi)) == UW.SPL(UA.BYT(D), _, FX.limbs([lo, hi])) : +List<U32>}
      UW.updv_bytes([lo, hi], dd, D, q, pf, hl)
    case 1n: w64b1(dd, D, q, lo, hi, le_q(q, 2n, VB.pw(dd), hl), pf, hz)
    case 2n: w64b2(dd, D, q, lo, hi, le_q(q, 2n, VB.pw(dd), hl), pf, hz)
    case 3n: w64b3(dd, D, q, lo, hi, le_q(q, 2n, VB.pw(dd), hl), pf, hz)
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
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, 20n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(20n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(20n) : +List<U32>})
    -> {FuluBytes20_e.b20_put(FD.array__thaw(U32, D), X, FuluBytes20_d.Bytes20{w0, w1, w2, w3, w4}) == FD.array__thaw(U32, B20X(r, dd, D, q, w0, w1, w2, w3, w4)) : Array<U32>}:
  match r:
    case 0n: VBF.put_b20(dd, D, X, q, FD.logic__subst(Nat, z => {U32.to_nat(X) == z : Nat}, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q)), e), hd, pf, FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, 5n), Nat.add(5n, q), FD.nat__add_comm(q, 5n), hl), w0, w1, w2, w3, w4)
    case 1n: UF1.putu_b20(dd, D, X, q, w0, w1, w2, w3, w4, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), le_q(q, 5n, VB.pw(dd), hl), pf, hz)
    case 2n: UF2.putu_b20(dd, D, X, q, w0, w1, w2, w3, w4, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), le_q(q, 5n, VB.pw(dd), hl), pf, hz)
    case 3n: UF3.putu_b20(dd, D, X, q, w0, w1, w2, w3, w4, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), le_q(q, 5n, VB.pw(dd), hl), pf, hz)
    case 4n+ +t: Empty.absurd({FuluBytes20_e.b20_put(FD.array__thaw(U32, D), X, FuluBytes20_d.Bytes20{w0, w1, w2, w3, w4}) == FD.array__thaw(U32, B20X(4n+t, dd, D, q, w0, w1, w2, w3, w4)) : Array<U32>}, FD.nat__lt_zero_absurd(t, hr))

def b20_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, 20n))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool},
    +hz: {VS.bt(20n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(20n) : +List<U32>})
    -> {UA.BYT(B20X(r, dd, D, q, w0, w1, w2, w3, w4)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), FX.limbs([w0, w1, w2, w3, w4])) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(B20X(0n, dd, D, q, w0, w1, w2, w3, w4)) == UW.SPL(UA.BYT(D), _, FX.limbs([w0, w1, w2, w3, w4])) : +List<U32>}
      UW.updv_bytes([w0, w1, w2, w3, w4], dd, D, q, pf, hl)
    case 1n: UB1.swcb([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), le_q(q, 5n, VB.pw(dd), hl)), hz)
    case 2n: UB2.swcb([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), le_q(q, 5n, VB.pw(dd), hl)), hz)
    case 3n: UB3.swcb([w0, w1, w2, w3, w4], dd, D, q, pf, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(dd)) == True{} : Bool}, Nat.add(5n, q), Nat.add(q, 5n), FD.nat__add_comm(5n, q), le_q(q, 5n, VB.pw(dd), hl)), hz)
    case 4n+ +t: Empty.absurd({UA.BYT(B20X(4n+t, dd, D, q, w0, w1, w2, w3, w4)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), FX.limbs([w0, w1, w2, w3, w4])) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))

# ---- the models are perfect trees ----------------------------------------------------------------

def pwm_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +T: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, PWM(r, dd, D, q, T, n)) == True{} : Bool}:
  match r:
    case 0n: VB.mone_perfect(VC.NW(n), 0n, q, dd, D, T, pf)
    case 1n: UW.swc_perfect(1, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0, pf)
    case 2n: UW.swc_perfect(2, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0, pf)
    case 3n: UW.swc_perfect(3, VS.wtake(VC.NW(n), UW.SLW(T)), dd, D, q, 0, pf)
    case 4n+ +t: pf

def w32x_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +x: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, W32X(r, dd, D, q, x)) == True{} : Bool}:
  match r:
    case 0n: FD.array__upd_perfect(U32, dd, D, q, x, pf)
    case 1n: UW.w32m_perfect(1, dd, D, q, x, pf)
    case 2n: UW.w32m_perfect(2, dd, D, q, x, pf)
    case 3n: UW.w32m_perfect(3, dd, D, q, x, pf)
    case 4n+ +t: pf

def w64x_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +lo: U32, +hi: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, W64X(r, dd, D, q, lo, hi)) == True{} : Bool}:
  match r:
    case 0n: VF.updv_perfect([lo, hi], dd, D, q, pf)
    case 1n: UW.w32m_perfect(1, dd, UW.W32M(1, dd, D, q, lo), 1n+q, hi, UW.w32m_perfect(1, dd, D, q, lo, pf))
    case 2n: UW.w32m_perfect(2, dd, UW.W32M(2, dd, D, q, lo), 1n+q, hi, UW.w32m_perfect(2, dd, D, q, lo, pf))
    case 3n: UW.w32m_perfect(3, dd, UW.W32M(3, dd, D, q, lo), 1n+q, hi, UW.w32m_perfect(3, dd, D, q, lo, pf))
    case 4n+ +t: pf

def b20x_perfect(+r: Nat, +dd: Nat, +D: FD.array__Tree<U32>, +q: Nat, +w0: U32, +w1: U32, +w2: U32, +w3: U32, +w4: U32, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool})
    -> {FD.array__perfect(U32, dd, B20X(r, dd, D, q, w0, w1, w2, w3, w4)) == True{} : Bool}:
  match r:
    case 0n: VF.updv_perfect([w0, w1, w2, w3, w4], dd, D, q, pf)
    case 1n: UW.swc_perfect(1, [w0, w1, w2, w3, w4], dd, D, q, 0, pf)
    case 2n: UW.swc_perfect(2, [w0, w1, w2, w3, w4], dd, D, q, 0, pf)
    case 3n: UW.swc_perfect(3, [w0, w1, w2, w3, w4], dd, D, q, 0, pf)
    case 4n+ +t: pf

# ---- the tight put_words: arithmetic of n = 4 Q + R -----------------------------------------------

def RR(+n: U32) -> Nat: U32.to_nat(U32.and(n, 3))

# K + (x + y) == x + (K + y)
def sh(+K: Nat, +x: Nat, +y: Nat) -> {Nat.add(K, Nat.add(x, y)) == Nat.add(x, Nat.add(K, y)) : Nat}:
  Equal.trans(Nat, Nat.add(K, Nat.add(x, y)), Nat.add(Nat.add(K, x), y), Nat.add(x, Nat.add(K, y)),
    Equal.sym(Nat, Nat.add(Nat.add(K, x), y), Nat.add(K, Nat.add(x, y)), FD.nat__add_assoc(K, x, y)),
    Equal.trans(Nat, Nat.add(Nat.add(K, x), y), Nat.add(Nat.add(x, K), y), Nat.add(x, Nat.add(K, y)),
      Equal.cong(Nat, Nat, z => Nat.add(z, y), Nat.add(K, x), Nat.add(x, K), FD.nat__add_comm(K, x)),
      FD.nat__add_assoc(x, K, y)))

# (4 Q + c) / 4 rounded down, twice halved: Q + c / 4.
law nq:
  for +Q: Nat
  for +c: Nat
  {VD.s_rng(2n, Nat.add(A.quad(Q), c)) == Nat.add(Q, VD.s_rng(2n, c)) : Nat}
def nq(Q, c):
  match Q:
    case 0n: {==}
    case 1n+ +P: Equal.cong(Nat, Nat, z => 1n+z, VD.s_rng(2n, Nat.add(A.quad(P), c)), Nat.add(P, VD.s_rng(2n, c)), nq(P, c))

# (c + x) - x == c
def subq(+c: Nat, +x: Nat) -> {Nat.sub(Nat.add(c, x), x) == c : Nat}:
  %FD.nat__add_comm(x, c) : {Nat.sub(_, x) == c : Nat}
  FD.nat__add_sub_cancel(x, c)

# NW(n) = Q + (3 + R) / 4
def nw_qrU(+n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool})
    -> {VC.NW(n) == Nat.add(VY.QL(n), VD.s_rng(2n, 3n+RR(n))) : Nat}:
  +RHS = Nat.add(VY.QL(n), VD.s_rng(2n, 3n+RR(n)))
  %Equal.sym(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), VC.eNWu(n, hy)) : {_ == RHS : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(A.quad(VY.QL(n)), RR(n)), VC.split4(n)) : {VD.s_rng(2n, 3n+_) == RHS : Nat}
  %Equal.sym(Nat, Nat.add(3n, Nat.add(A.quad(VY.QL(n)), RR(n))), Nat.add(A.quad(VY.QL(n)), Nat.add(3n, RR(n))), sh(3n, A.quad(VY.QL(n)), RR(n))) : {VD.s_rng(2n, _) == RHS : Nat}
  nq(VY.QL(n), 3n+RR(n))

def nw_qr(+n: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool})
    -> {VC.NW(n) == Nat.add(VY.QL(n), VD.s_rng(2n, 3n+RR(n))) : Nat}:
  nw_qrU(n, VC.hyU(n, k, hk, hy))

# NWN(r + n) = Q + (3 + r + R) / 4
def nwn_qr(+n: U32, +r: Nat) -> {NWN(Nat.add(r, U32.to_nat(n))) == Nat.add(VY.QL(n), VD.s_rng(2n, 3n+Nat.add(r, RR(n)))) : Nat}:
  +RHS = Nat.add(VY.QL(n), VD.s_rng(2n, 3n+Nat.add(r, RR(n))))
  +qQ = A.quad(VY.QL(n))
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(qQ, RR(n)), VC.split4(n)) : {VD.s_rng(2n, 3n+Nat.add(r, _)) == RHS : Nat}
  %Equal.sym(Nat, Nat.add(r, Nat.add(qQ, RR(n))), Nat.add(qQ, Nat.add(r, RR(n))), sh(r, qQ, RR(n))) : {VD.s_rng(2n, 3n+_) == RHS : Nat}
  %Equal.sym(Nat, Nat.add(3n, Nat.add(qQ, Nat.add(r, RR(n)))), Nat.add(qQ, Nat.add(3n, Nat.add(r, RR(n)))), sh(3n, qQ, Nat.add(r, RR(n)))) : {VD.s_rng(2n, _) == RHS : Nat}
  nq(VY.QL(n), 3n+Nat.add(r, RR(n)))

# n = 4 Q + R
def n_qr(+n: U32, +R: Nat, +eR: {RR(n) == R : Nat}) -> {U32.to_nat(n) == Nat.add(A.quad(VY.QL(n)), R) : Nat}:
  Equal.trans(Nat, U32.to_nat(n), Nat.add(A.quad(VY.QL(n)), RR(n)), Nat.add(A.quad(VY.QL(n)), R), VC.split4(n),
    Equal.cong(Nat, Nat, z => Nat.add(A.quad(VY.QL(n)), z), RR(n), R, eR))

# The source's words written: the n data bytes, then zeros to the end of the last word (R = 0).
def key0U(+n: U32, +T: FD.array__Tree<U32>, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +eR: {RR(n) == 0n : Nat})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +eNW = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
    Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
  +eN = Equal.trans(Nat, U32.to_nat(n), Nat.add(qQ, 0n), qQ, n_qr(n, 0n, eR), FD.nat__add_zero(qQ))
  %Equal.sym(Nat, VC.NW(n), Q, eNW) : {FX.limbs(VS.wtake(_, SL)) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(_), U32.to_nat(n)))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(n), qQ, eN) : {FX.limbs(VS.wtake(Q, SL)) == List.append(&2, U32, VS.bt(_, FX.limbs(SL)), UW.ZB(Nat.sub(qQ, _))) : +List<U32>}
  %Equal.sym(Nat, Nat.sub(qQ, qQ), 0n, FD.nat__sub_self(qQ)) : {FX.limbs(VS.wtake(Q, SL)) == List.append(&2, U32, VS.bt(qQ, FX.limbs(SL)), UW.ZB(_)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, VS.bt(qQ, FX.limbs(SL)), []), VS.bt(qQ, FX.limbs(SL)), VS.app_nil(VS.bt(qQ, FX.limbs(SL)))) : {FX.limbs(VS.wtake(Q, SL)) == _ : +List<U32>}
  Equal.sym(+List<U32>, VS.bt(qQ, FX.limbs(SL)), FX.limbs(VS.wtake(Q, SL)), VS.bt_limbs(Q, SL))

def key0(+n: U32, +T: FD.array__Tree<U32>, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool},
    +eR: {RR(n) == 0n : Nat})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  key0U(n, T, VC.hyU(n, k, hk, hy), eR)

# The source's words written: the n data bytes, then zeros to the end of the last word (R = 1).
def key1U(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +eR: {RR(n) == 1n : Nat}, +ht: {U32.shrn(VB.slot(T, VY.QL(n)), 8n) == 0 : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +x = FD.flat__nthc(UW.SLW(T), VY.QL(n))
  +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
  +eNW = VY.nw_qU(n, hy, hb)
  +eN = n_qr(n, 1n, eR)
  +hQ = FD.logic__subst(Nat, z => {Nat.is_lt(VY.QL(n), z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)),
    FD.nat__succ_le_lt(Q, VB.pw(dw), FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), 1n+Q, eNW, hsrc)))
  +eW = UW.wdr_con(SL, Q, hQ)
  +eE = Equal.trans(Nat, Nat.sub(A.quad(1n+Q), Nat.add(qQ, 1n)), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n,
    Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), Nat.add(qQ, 1n), Nat.add(1n, qQ), FD.nat__add_comm(qQ, 1n)), subq(3n, qQ))
  +eT1 = Equal.trans(Nat, Nat.add(Q, 1n), 1n+Nat.add(Q, 0n), 1n+Q, FD.nat__add_succ(Q, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)))
  +eTK = FD.logic__subst(Nat, z => {VS.wtake(z, SL) == VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL))) : List<&2, U32>}, Nat.add(Q, 1n), 1n+Q, eT1, VF.take_split(Q, 1n, SL))
  +A0 = FX.limbs(VS.wtake(Q, SL))
  %Equal.sym(Nat, VC.NW(n), 1n+Q, eNW) : {FX.limbs(VS.wtake(_, SL)) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(_), U32.to_nat(n)))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(qQ, 1n), eN) : {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, VS.bt(_, FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(1n+Q), _))) : +List<U32>}
  %Equal.sym(Nat, Nat.sub(A.quad(1n+Q), Nat.add(qQ, 1n)), 3n, eE) : {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, VS.bt(Nat.add(qQ, 1n), FX.limbs(SL)), UW.ZB(_)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(qQ, 1n), FX.limbs(SL)), List.append(&2, U32, A0, VS.bt(1n, FX.limbs(VB.wdr(Q, SL)))), VY.bt_split(Q, 1n, SL, FD.nat__lt_le(Q, VB.len(SL), hQ))) :
    {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, _, UW.ZB(3n)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n+Q, SL), VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL))), eTK) :
    {FX.limbs(_) == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(1n, FX.limbs(VB.wdr(Q, SL)))), UW.ZB(3n)) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL)))), List.append(&2, U32, A0, FX.limbs(VS.wtake(1n, VB.wdr(Q, SL)))), VF.limbs_app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL)))) :
    {_ == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(1n, FX.limbs(VB.wdr(Q, SL)))), UW.ZB(3n)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(Q, SL), Con{x, VB.wdr(1n+Q, SL)}, eW) :
    {List.append(&2, U32, A0, FX.limbs(VS.wtake(1n, _))) == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(1n, FX.limbs(_))), UW.ZB(3n)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, A0, VS.bt(1n, I.limb(x))), [0, 0, 0]), List.append(&2, U32, A0, List.append(&2, U32, VS.bt(1n, I.limb(x)), [0, 0, 0])),
      VS.app_assoc(A0, VS.bt(1n, I.limb(x)), [0, 0, 0])) :
    {List.append(&2, U32, A0, List.append(&2, U32, I.limb(x), [])) == _ : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, A0, z), List.append(&2, U32, I.limb(x), []), List.append(&2, U32, VS.bt(1n, I.limb(x)), [0, 0, 0]),
    Equal.trans(+List<U32>, List.append(&2, U32, I.limb(x), []), I.limb(x), List.append(&2, U32, VS.bt(1n, I.limb(x)), [0, 0, 0]), VS.app_nil(I.limb(x)), UWB.tzl1(x, ht)))

def key1(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +eR: {RR(n) == 1n : Nat}, +ht: {U32.shrn(VB.slot(T, VY.QL(n)), 8n) == 0 : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  key1U(n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc, eR, ht)

# The source's words written: the n data bytes, then zeros to the end of the last word (R = 2).
def key2U(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +eR: {RR(n) == 2n : Nat}, +ht: {U32.shrn(VB.slot(T, VY.QL(n)), 16n) == 0 : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +x = FD.flat__nthc(UW.SLW(T), VY.QL(n))
  +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
  +eNW = VY.nw_qU(n, hy, hb)
  +eN = n_qr(n, 2n, eR)
  +hQ = FD.logic__subst(Nat, z => {Nat.is_lt(VY.QL(n), z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)),
    FD.nat__succ_le_lt(Q, VB.pw(dw), FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), 1n+Q, eNW, hsrc)))
  +eW = UW.wdr_con(SL, Q, hQ)
  +eE = Equal.trans(Nat, Nat.sub(A.quad(1n+Q), Nat.add(qQ, 2n)), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n,
    Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), Nat.add(qQ, 2n), Nat.add(2n, qQ), FD.nat__add_comm(qQ, 2n)), subq(2n, qQ))
  +eT1 = Equal.trans(Nat, Nat.add(Q, 1n), 1n+Nat.add(Q, 0n), 1n+Q, FD.nat__add_succ(Q, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)))
  +eTK = FD.logic__subst(Nat, z => {VS.wtake(z, SL) == VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL))) : List<&2, U32>}, Nat.add(Q, 1n), 1n+Q, eT1, VF.take_split(Q, 1n, SL))
  +A0 = FX.limbs(VS.wtake(Q, SL))
  %Equal.sym(Nat, VC.NW(n), 1n+Q, eNW) : {FX.limbs(VS.wtake(_, SL)) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(_), U32.to_nat(n)))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(qQ, 2n), eN) : {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, VS.bt(_, FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(1n+Q), _))) : +List<U32>}
  %Equal.sym(Nat, Nat.sub(A.quad(1n+Q), Nat.add(qQ, 2n)), 2n, eE) : {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, VS.bt(Nat.add(qQ, 2n), FX.limbs(SL)), UW.ZB(_)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(qQ, 2n), FX.limbs(SL)), List.append(&2, U32, A0, VS.bt(2n, FX.limbs(VB.wdr(Q, SL)))), VY.bt_split(Q, 2n, SL, FD.nat__lt_le(Q, VB.len(SL), hQ))) :
    {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, _, UW.ZB(2n)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n+Q, SL), VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL))), eTK) :
    {FX.limbs(_) == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(2n, FX.limbs(VB.wdr(Q, SL)))), UW.ZB(2n)) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL)))), List.append(&2, U32, A0, FX.limbs(VS.wtake(1n, VB.wdr(Q, SL)))), VF.limbs_app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL)))) :
    {_ == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(2n, FX.limbs(VB.wdr(Q, SL)))), UW.ZB(2n)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(Q, SL), Con{x, VB.wdr(1n+Q, SL)}, eW) :
    {List.append(&2, U32, A0, FX.limbs(VS.wtake(1n, _))) == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(2n, FX.limbs(_))), UW.ZB(2n)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, A0, VS.bt(2n, I.limb(x))), [0, 0]), List.append(&2, U32, A0, List.append(&2, U32, VS.bt(2n, I.limb(x)), [0, 0])),
      VS.app_assoc(A0, VS.bt(2n, I.limb(x)), [0, 0])) :
    {List.append(&2, U32, A0, List.append(&2, U32, I.limb(x), [])) == _ : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, A0, z), List.append(&2, U32, I.limb(x), []), List.append(&2, U32, VS.bt(2n, I.limb(x)), [0, 0]),
    Equal.trans(+List<U32>, List.append(&2, U32, I.limb(x), []), I.limb(x), List.append(&2, U32, VS.bt(2n, I.limb(x)), [0, 0]), VS.app_nil(I.limb(x)), UWB.tzl2(x, ht)))

def key2(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +eR: {RR(n) == 2n : Nat}, +ht: {U32.shrn(VB.slot(T, VY.QL(n)), 16n) == 0 : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  key2U(n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc, eR, ht)

# The source's words written: the n data bytes, then zeros to the end of the last word (R = 3).
def key3U(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +eR: {RR(n) == 3n : Nat}, +ht: {U32.shrn(VB.slot(T, VY.QL(n)), 24n) == 0 : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +x = FD.flat__nthc(UW.SLW(T), VY.QL(n))
  +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
  +eNW = VY.nw_qU(n, hy, hb)
  +eN = n_qr(n, 3n, eR)
  +hQ = FD.logic__subst(Nat, z => {Nat.is_lt(VY.QL(n), z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)),
    FD.nat__succ_le_lt(Q, VB.pw(dw), FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), 1n+Q, eNW, hsrc)))
  +eW = UW.wdr_con(SL, Q, hQ)
  +eE = Equal.trans(Nat, Nat.sub(A.quad(1n+Q), Nat.add(qQ, 3n)), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n,
    Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_comm(qQ, 3n)), subq(1n, qQ))
  +eT1 = Equal.trans(Nat, Nat.add(Q, 1n), 1n+Nat.add(Q, 0n), 1n+Q, FD.nat__add_succ(Q, 0n), Equal.cong(Nat, Nat, z => 1n+z, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)))
  +eTK = FD.logic__subst(Nat, z => {VS.wtake(z, SL) == VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL))) : List<&2, U32>}, Nat.add(Q, 1n), 1n+Q, eT1, VF.take_split(Q, 1n, SL))
  +A0 = FX.limbs(VS.wtake(Q, SL))
  %Equal.sym(Nat, VC.NW(n), 1n+Q, eNW) : {FX.limbs(VS.wtake(_, SL)) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(_), U32.to_nat(n)))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(qQ, 3n), eN) : {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, VS.bt(_, FX.limbs(SL)), UW.ZB(Nat.sub(A.quad(1n+Q), _))) : +List<U32>}
  %Equal.sym(Nat, Nat.sub(A.quad(1n+Q), Nat.add(qQ, 3n)), 1n, eE) : {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, VS.bt(Nat.add(qQ, 3n), FX.limbs(SL)), UW.ZB(_)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(qQ, 3n), FX.limbs(SL)), List.append(&2, U32, A0, VS.bt(3n, FX.limbs(VB.wdr(Q, SL)))), VY.bt_split(Q, 3n, SL, FD.nat__lt_le(Q, VB.len(SL), hQ))) :
    {FX.limbs(VS.wtake(1n+Q, SL)) == List.append(&2, U32, _, UW.ZB(1n)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n+Q, SL), VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL))), eTK) :
    {FX.limbs(_) == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(3n, FX.limbs(VB.wdr(Q, SL)))), UW.ZB(1n)) : +List<U32>}
  %Equal.sym(+List<U32>, FX.limbs(VF.app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL)))), List.append(&2, U32, A0, FX.limbs(VS.wtake(1n, VB.wdr(Q, SL)))), VF.limbs_app(VS.wtake(Q, SL), VS.wtake(1n, VB.wdr(Q, SL)))) :
    {_ == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(3n, FX.limbs(VB.wdr(Q, SL)))), UW.ZB(1n)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(Q, SL), Con{x, VB.wdr(1n+Q, SL)}, eW) :
    {List.append(&2, U32, A0, FX.limbs(VS.wtake(1n, _))) == List.append(&2, U32, List.append(&2, U32, A0, VS.bt(3n, FX.limbs(_))), UW.ZB(1n)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, A0, VS.bt(3n, I.limb(x))), [0]), List.append(&2, U32, A0, List.append(&2, U32, VS.bt(3n, I.limb(x)), [0])),
      VS.app_assoc(A0, VS.bt(3n, I.limb(x)), [0])) :
    {List.append(&2, U32, A0, List.append(&2, U32, I.limb(x), [])) == _ : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, A0, z), List.append(&2, U32, I.limb(x), []), List.append(&2, U32, VS.bt(3n, I.limb(x)), [0]),
    Equal.trans(+List<U32>, List.append(&2, U32, I.limb(x), []), I.limb(x), List.append(&2, U32, VS.bt(3n, I.limb(x)), [0]), VS.app_nil(I.limb(x)), UWB.tzl3(x, ht)))

def key3(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +eR: {RR(n) == 3n : Nat}, +ht: {U32.shrn(VB.slot(T, VY.QL(n)), 24n) == 0 : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  key3U(n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc, eR, ht)

# ---- zero windows, splices ------------------------------------------------------------------------

def zpre(+a: Nat, +b: Nat, +L: +List<U32>, +h: {VS.bt(Nat.add(a, b), L) == UW.ZB(Nat.add(a, b)) : +List<U32>})
    -> {VS.bt(a, L) == UW.ZB(a) : +List<U32>}:
  Equal.trans(+List<U32>, VS.bt(a, L), VS.bt(a, VS.bt(Nat.add(a, b), L)), UW.ZB(a),
    Equal.sym(+List<U32>, VS.bt(a, VS.bt(Nat.add(a, b), L)), VS.bt(a, L), VS.bt_bt(a, b, L)),
    Equal.trans(+List<U32>, VS.bt(a, VS.bt(Nat.add(a, b), L)), VS.bt(a, UW.ZB(Nat.add(a, b))), UW.ZB(a),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(a, z), VS.bt(Nat.add(a, b), L), UW.ZB(Nat.add(a, b)), h),
      UW.zb_win(0n, a, Nat.add(a, b), Order.below_sum(a, b))))

def zsuf(+a: Nat, +b: Nat, +L: +List<U32>, +h: {VS.bt(Nat.add(a, b), L) == UW.ZB(Nat.add(a, b)) : +List<U32>})
    -> {VS.bt(b, VS.bdr(a, L)) == UW.ZB(b) : +List<U32>}:
  Equal.trans(+List<U32>, VS.bt(b, VS.bdr(a, L)), VS.bt(b, VS.bdr(a, VS.bt(Nat.add(a, b), L))), UW.ZB(b),
    UW.bt_bdr_bt(b, a, Nat.add(a, b), L, FD.nat__le_refl(Nat.add(a, b))),
    Equal.trans(+List<U32>, VS.bt(b, VS.bdr(a, VS.bt(Nat.add(a, b), L))), VS.bt(b, VS.bdr(a, UW.ZB(Nat.add(a, b)))), UW.ZB(b),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(b, VS.bdr(a, z)), VS.bt(Nat.add(a, b), L), UW.ZB(Nat.add(a, b)), h),
      UW.zb_win(a, b, Nat.add(a, b), FD.nat__le_refl(Nat.add(a, b)))))

law zb_app:
  for +a: Nat
  for +b: Nat
  {List.append(&2, U32, UW.ZB(a), UW.ZB(b)) == UW.ZB(Nat.add(a, b)) : +List<U32>}
def zb_app(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p: Equal.cong(+List<U32>, +List<U32>, z => Con{0, z}, List.append(&2, U32, UW.ZB(p), UW.ZB(b)), UW.ZB(Nat.add(p, b)), zb_app(p, b))

# A splice of Y is one of Y and p zeros when the p bytes after Y's were zero.
def spl_ext(+B: +List<U32>, +X: Nat, +Y: +List<U32>, +p: Nat, +hz: {VS.bt(p, VS.bdr(Nat.add(X, List.length(&2, U32, Y)), B)) == UW.ZB(p) : +List<U32>})
    -> {UW.SPL(B, X, Y) == UW.SPL(B, X, List.append(&2, U32, Y, UW.ZB(p))) : +List<U32>}:
  +Ly = List.length(&2, U32, Y)
  +P0 = Nat.add(X, List.length(&2, U32, Y))
  +R1 = VS.bdr(Nat.add(Nat.add(X, List.length(&2, U32, Y)), p), B)
  +e1 = Equal.trans(+List<U32>, VS.bdr(P0, B), List.append(&2, U32, VS.bt(p, VS.bdr(P0, B)), VS.bdr(p, VS.bdr(P0, B))), List.append(&2, U32, UW.ZB(p), R1),
    Equal.sym(+List<U32>, List.append(&2, U32, VS.bt(p, VS.bdr(P0, B)), VS.bdr(p, VS.bdr(P0, B))), VS.bdr(P0, B), UW.bt_bdr_split(p, VS.bdr(P0, B))),
    Equal.trans(+List<U32>, List.append(&2, U32, VS.bt(p, VS.bdr(P0, B)), VS.bdr(p, VS.bdr(P0, B))), List.append(&2, U32, UW.ZB(p), VS.bdr(p, VS.bdr(P0, B))), List.append(&2, U32, UW.ZB(p), R1),
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, z, VS.bdr(p, VS.bdr(P0, B))), VS.bt(p, VS.bdr(P0, B)), UW.ZB(p), hz),
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, UW.ZB(p), z), VS.bdr(p, VS.bdr(P0, B)), R1, Equal.sym(+List<U32>, R1, VS.bdr(p, VS.bdr(P0, B)), UW.bdr_add(P0, p, B)))))
  +eLen = Equal.trans(Nat, Nat.add(Nat.add(X, Ly), p), Nat.add(X, Nat.add(Ly, p)), Nat.add(X, List.length(&2, U32, List.append(&2, U32, Y, UW.ZB(p)))),
    FD.nat__add_assoc(X, Ly, p),
    Equal.cong(Nat, Nat, z => Nat.add(X, z), Nat.add(Ly, p), List.length(&2, U32, List.append(&2, U32, Y, UW.ZB(p))),
      Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y, UW.ZB(p))), Nat.add(Ly, p),
        Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, Y, UW.ZB(p))), Nat.add(Ly, List.length(&2, U32, UW.ZB(p))), Nat.add(Ly, p),
          VS.len_app(Y, UW.ZB(p)), Equal.cong(Nat, Nat, z => Nat.add(Ly, z), List.length(&2, U32, UW.ZB(p)), p, UW.len_zb(p))))))
  %Equal.sym(+List<U32>, VS.bdr(P0, B), List.append(&2, U32, UW.ZB(p), R1), e1) :
    {List.append(&2, U32, VS.bt(X, B), List.append(&2, U32, Y, _)) == UW.SPL(B, X, List.append(&2, U32, Y, UW.ZB(p))) : +List<U32>}
  %eLen :
    {List.append(&2, U32, VS.bt(X, B), List.append(&2, U32, Y, List.append(&2, U32, UW.ZB(p), R1))) == List.append(&2, U32, VS.bt(X, B), List.append(&2, U32, List.append(&2, U32, Y, UW.ZB(p)), VS.bdr(_, B))) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, VS.bt(X, B), z), List.append(&2, U32, Y, List.append(&2, U32, UW.ZB(p), R1)), List.append(&2, U32, List.append(&2, U32, Y, UW.ZB(p)), R1),
    Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, Y, UW.ZB(p)), R1), List.append(&2, U32, Y, List.append(&2, U32, UW.ZB(p), R1)), VS.app_assoc(Y, UW.ZB(p), R1)))

# ---- the tight put_words: a carry word inside the value (r + n > 4 NW) ------------------------------

def c1_rtU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +p: Nat, +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(r, U32.to_nat(n))) == 1n+VC.NW(n) : Nat}, +eP: {PADB(r, U32.to_nat(n)) == Nat.add(E, p) : Nat},
    +eNE: {Nat.add(U32.to_nat(n), E) == A.quad(VC.NW(n)) : Nat})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), r)
  +hl2 = le_q(q, NW, VB.pw(dd), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(r, N)), 1n+NW, eNWN, hl))
  +eWin = Equal.trans(Nat, Nat.add(N, PADB(r, N)), Nat.add(N, Nat.add(E, p)), Nat.add(A.quad(NW), p),
    Equal.cong(Nat, Nat, z => Nat.add(N, z), PADB(r, N), Nat.add(E, p), eP),
    Equal.trans(Nat, Nat.add(N, Nat.add(E, p)), Nat.add(Nat.add(N, E), p), Nat.add(A.quad(NW), p),
      Equal.sym(Nat, Nat.add(Nat.add(N, E), p), Nat.add(N, Nat.add(E, p)), FD.nat__add_assoc(N, E, p)),
      Equal.cong(Nat, Nat, z => Nat.add(z, p), Nat.add(N, E), A.quad(NW), eNE)))
  +hzW = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(X0, B)) == UW.ZB(z) : +List<U32>}, Nat.add(N, PADB(r, N)), Nat.add(A.quad(NW), p), eWin, hz)
  +hz2 = zpre(A.quad(NW), p, VS.bdr(X0, B), hzW)
  putw_looseU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, hy, hsrc, hl2, pf, pfT, hz2)

def c1_rt(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +p: Nat, +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(r, U32.to_nat(n))) == 1n+VC.NW(n) : Nat}, +eP: {PADB(r, U32.to_nat(n)) == Nat.add(E, p) : Nat},
    +eNE: {Nat.add(U32.to_nat(n), E) == A.quad(VC.NW(n)) : Nat})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  c1_rtU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, pf, pfT, p, E, hl, hz, eNWN, eP, eNE)

def c1_bytesU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +p: Nat, +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(r, U32.to_nat(n))) == 1n+VC.NW(n) : Nat}, +eP: {PADB(r, U32.to_nat(n)) == Nat.add(E, p) : Nat},
    +eNE: {Nat.add(U32.to_nat(n), E) == A.quad(VC.NW(n)) : Nat},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(E)) : +List<U32>})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(r, U32.to_nat(n))))) : +List<U32>}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), r)
  +hl2 = le_q(q, NW, VB.pw(dd), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(r, N)), 1n+NW, eNWN, hl))
  +eWin = Equal.trans(Nat, Nat.add(N, PADB(r, N)), Nat.add(N, Nat.add(E, p)), Nat.add(A.quad(NW), p),
    Equal.cong(Nat, Nat, z => Nat.add(N, z), PADB(r, N), Nat.add(E, p), eP),
    Equal.trans(Nat, Nat.add(N, Nat.add(E, p)), Nat.add(Nat.add(N, E), p), Nat.add(A.quad(NW), p),
      Equal.sym(Nat, Nat.add(Nat.add(N, E), p), Nat.add(N, Nat.add(E, p)), FD.nat__add_assoc(N, E, p)),
      Equal.cong(Nat, Nat, z => Nat.add(z, p), Nat.add(N, E), A.quad(NW), eNE)))
  +hzW = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(X0, B)) == UW.ZB(z) : +List<U32>}, Nat.add(N, PADB(r, N)), Nat.add(A.quad(NW), p), eWin, hz)
  +hz2 = zpre(A.quad(NW), p, VS.bdr(X0, B), hzW)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +DT = VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))
  +b0 = putw_loose_bytesU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, hy, hsrc, hl2, pf, pfT, hz2)
  +eLW = Equal.trans(Nat, List.length(&2, U32, FX.limbs(W)), A.quad(List.length(&2, U32, W)), A.quad(NW), UW.len_limbs_q(W),
    Equal.cong(Nat, Nat, z => A.quad(z), List.length(&2, U32, W), NW, UW.len_take(NW, UW.SLW(T), FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(UW.SLW(T)), Equal.sym(Nat, VB.len(UW.SLW(T)), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc))))
  +hze = FD.logic__subst(Nat, z => {VS.bt(p, VS.bdr(Nat.add(X0, z), B)) == UW.ZB(p) : +List<U32>}, A.quad(NW), List.length(&2, U32, FX.limbs(W)), Equal.sym(Nat, List.length(&2, U32, FX.limbs(W)), A.quad(NW), eLW),
    FD.logic__subst(+List<U32>, z => {VS.bt(p, z) == UW.ZB(p) : +List<U32>}, VS.bdr(A.quad(NW), VS.bdr(X0, B)), VS.bdr(Nat.add(X0, A.quad(NW)), B), Equal.sym(+List<U32>, VS.bdr(Nat.add(X0, A.quad(NW)), B), VS.bdr(A.quad(NW), VS.bdr(X0, B)), UW.bdr_add(X0, A.quad(NW), B)),
      zsuf(A.quad(NW), p, VS.bdr(X0, B), hzW)))
  +b1 = spl_ext(B, X0, FX.limbs(W), p, hze)
  +eD = Equal.trans(+List<U32>, List.append(&2, U32, FX.limbs(W), UW.ZB(p)), List.append(&2, U32, List.append(&2, U32, DT, UW.ZB(E)), UW.ZB(p)), List.append(&2, U32, DT, UW.ZB(PADB(r, N))),
    Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, z, UW.ZB(p)), FX.limbs(W), List.append(&2, U32, DT, UW.ZB(E)), eK),
    Equal.trans(+List<U32>, List.append(&2, U32, List.append(&2, U32, DT, UW.ZB(E)), UW.ZB(p)), List.append(&2, U32, DT, List.append(&2, U32, UW.ZB(E), UW.ZB(p))), List.append(&2, U32, DT, UW.ZB(PADB(r, N))),
      VS.app_assoc(DT, UW.ZB(E), UW.ZB(p)),
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, DT, z), List.append(&2, U32, UW.ZB(E), UW.ZB(p)), UW.ZB(PADB(r, N)),
        Equal.trans(+List<U32>, List.append(&2, U32, UW.ZB(E), UW.ZB(p)), UW.ZB(Nat.add(E, p)), UW.ZB(PADB(r, N)), zb_app(E, p),
          Equal.cong(Nat, +List<U32>, z => UW.ZB(z), Nat.add(E, p), PADB(r, N), Equal.sym(Nat, PADB(r, N), Nat.add(E, p), eP))))))
  Equal.trans(+List<U32>, UA.BYT(PWM(r, dd, D, q, T, n)), UW.SPL(B, X0, FX.limbs(W)), UW.SPL(B, X0, List.append(&2, U32, DT, UW.ZB(PADB(r, N)))), b0,
    Equal.trans(+List<U32>, UW.SPL(B, X0, FX.limbs(W)), UW.SPL(B, X0, List.append(&2, U32, FX.limbs(W), UW.ZB(p))), UW.SPL(B, X0, List.append(&2, U32, DT, UW.ZB(PADB(r, N)))), b1,
      Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(B, X0, z), List.append(&2, U32, FX.limbs(W), UW.ZB(p)), List.append(&2, U32, DT, UW.ZB(PADB(r, N))), eD)))

def c1_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +p: Nat, +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(r, U32.to_nat(n))) == 1n+VC.NW(n) : Nat}, +eP: {PADB(r, U32.to_nat(n)) == Nat.add(E, p) : Nat},
    +eNE: {Nat.add(U32.to_nat(n), E) == A.quad(VC.NW(n)) : Nat},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(E)) : +List<U32>})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(r, U32.to_nat(n))))) : +List<U32>}:
  c1_bytesU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, pf, pfT, p, E, hl, hz, eNWN, eP, eNE, eK)

# ---- the tight put_words at byte 1: no carry word (r + n <= 4 NW), the open model --------------------

def c2_rt1(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(1n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(1n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(1n, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(1n, U32.to_nat(n))) == VC.NW(n) : Nat}, +eNW1: {VC.NW(n) == 1n+VY.QL(n) : Nat},
    +eL: {Nat.add(U32.to_nat(n), PADB(1n, U32.to_nat(n))) == Nat.add(3n, A.quad(VY.QL(n))) : Nat},
    +hc0: {O.shr_over(FD.flat__nthc(UW.SLW(T), VY.QL(n)), 1) == 0 : U32},
    +hn: {U32.is_eq(n, 0) == False{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(1n, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), 1n)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +P = PADB(1n, U32.to_nat(n))
  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc)
  +hLQ = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, NW, 1n+Q, eNW1, hLS)
  +eC = Equal.trans(U32, UW.CRY(1, W, 0), UW.CRY(1, VS.wtake(1n+Q, SL), 0), 0, Equal.cong(Nat, U32, z => UW.CRY(1, VS.wtake(z, SL), 0), NW, 1n+Q, eNW1), Equal.trans(U32, UW.CRY(1, VS.wtake(1n+Q, SL), 0), O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 1), 0, UW.cry_take(1, Q, 0n, SL, 0, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(SL)) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), FD.nat__succ_le_lt(Q, VB.len(SL), hLQ))), Equal.trans(U32, O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 1), O.shr_over(FD.flat__nthc(SL, Q), 1), 0, Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(SL, z), 1), Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), hc0)))
  +eSW = Equal.trans(FD.array__Tree<U32>, UW.SWc(1, W, dd, D, q, 0), UW.ORS(dd, UW.SWo(1, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), UW.CRY(1, W, 0)), UW.SWo(1, W, dd, D, q, 0),
    UW.swc_swo(1, W, dd, D, q, 0),
    Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo(1, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), z), UW.CRY(1, W, 0), 0, eC))
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, NW), Nat.add(NW, q), FD.nat__add_comm(q, NW),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(1n, N)), NW, eNWN, hl))
  +hL = Equal.trans(Nat, Nat.add(Nat.add(N, P), 1n), Nat.add(Nat.add(3n, qQ), 1n), A.quad(NW),
    Equal.cong(Nat, Nat, z => Nat.add(z, 1n), Nat.add(N, P), Nat.add(3n, qQ), eL),
    Equal.trans(Nat, Nat.add(Nat.add(3n, qQ), 1n), A.quad(1n+Q), A.quad(NW),
      Equal.cong(Nat, Nat, z => 3n+z, Nat.add(qQ, 1n), Nat.add(1n, qQ), FD.nat__add_comm(qQ, 1n)),
      Equal.cong(Nat, Nat, z => A.quad(z), 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNW1))))
  +hc = Equal.cong(U32, Bool, z => U32.is_eq(z, 0), UW.CRY(1, W, 0), 0, eC)
  %Equal.sym(FD.array__Tree<U32>, UW.SWc(1, W, dd, D, q, 0), UW.SWo(1, W, dd, D, q, 0), eSW) :
    {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, _), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
  UP1.putwu_o(dd, D, X, q, dw, T, n, e, hn, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, VY.FD_le1(NW, Q, eNW1), hsrc, hl2, Nat.add(N, P), hL, hz, hc, pf, pfT)

def c2_bytes1(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 1n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(1n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(1n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 1n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(1n, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(1n, U32.to_nat(n))) == VC.NW(n) : Nat}, +eNW1: {VC.NW(n) == 1n+VY.QL(n) : Nat},
    +eL: {Nat.add(U32.to_nat(n), PADB(1n, U32.to_nat(n))) == Nat.add(3n, A.quad(VY.QL(n))) : Nat},
    +hc0: {O.shr_over(FD.flat__nthc(UW.SLW(T), VY.QL(n)), 1) == 0 : U32},
    +hPE: {Nat.is_le(PADB(1n, U32.to_nat(n)), E) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(E)) : +List<U32>})
    -> {UA.BYT(PWM(1n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 1n), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(1n, U32.to_nat(n))))) : +List<U32>}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), 1n)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +P = PADB(1n, U32.to_nat(n))
  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc)
  +hLQ = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, NW, 1n+Q, eNW1, hLS)
  +eC = Equal.trans(U32, UW.CRY(1, W, 0), UW.CRY(1, VS.wtake(1n+Q, SL), 0), 0, Equal.cong(Nat, U32, z => UW.CRY(1, VS.wtake(z, SL), 0), NW, 1n+Q, eNW1), Equal.trans(U32, UW.CRY(1, VS.wtake(1n+Q, SL), 0), O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 1), 0, UW.cry_take(1, Q, 0n, SL, 0, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(SL)) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), FD.nat__succ_le_lt(Q, VB.len(SL), hLQ))), Equal.trans(U32, O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 1), O.shr_over(FD.flat__nthc(SL, Q), 1), 0, Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(SL, z), 1), Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), hc0)))
  +eSW = Equal.trans(FD.array__Tree<U32>, UW.SWc(1, W, dd, D, q, 0), UW.ORS(dd, UW.SWo(1, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), UW.CRY(1, W, 0)), UW.SWo(1, W, dd, D, q, 0),
    UW.swc_swo(1, W, dd, D, q, 0),
    Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo(1, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), z), UW.CRY(1, W, 0), 0, eC))
  +x0 = FD.flat__nthc(UW.SLW(T), 0n)
  +R1 = VB.wdr(1n, UW.SLW(T))
  +eS = UW.wdr_con(SL, 0n, FD.nat__lt_le_trans(0n, 1n+Q, VB.len(SL), {==}, hLQ))
  +hQR = FD.logic__subst(List<&2, U32>, z => {Nat.is_le(1n+Q, VB.len(z)) == True{} : Bool}, SL, Con{x0, R1}, eS, hLQ)
  +eLt = UW.len_take(Q, R1, hQR)
  +eWc = Equal.trans(List<&2, U32>, W, VS.wtake(1n+Q, SL), Con{x0, VS.wtake(Q, R1)},
    Equal.cong(Nat, List<&2, U32>, z => VS.wtake(z, SL), NW, 1n+Q, eNW1),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n+Q, z), SL, Con{x0, R1}, eS))
  +hr1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, 1n+z), VB.pw(dd)) == True{} : Bool}, Q, List.length(&2, U32, VS.wtake(Q, R1)), Equal.sym(Nat, List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(1n, N)), 1n+Q, Equal.trans(Nat, NWN(Nat.add(1n, N)), NW, 1n+Q, eNWN, eNW1), hl))
  +hz1 = FD.logic__subst(Nat, z => {VS.bt(Nat.add(3n, A.quad(z)), VS.bdr(X0, B)) == UW.ZB(Nat.add(3n, A.quad(z))) : +List<U32>}, Q, List.length(&2, U32, VS.wtake(Q, R1)), Equal.sym(Nat, List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt),
    FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(X0, B)) == UW.ZB(z) : +List<U32>}, Nat.add(N, P), Nat.add(3n, qQ), eL, hz))
  +sw = UB1.swcbo(x0, VS.wtake(Q, R1), dd, D, q, pf, hr1, hz1)
  +hNL = FD.nat__le_trans(N, A.quad(NW), List.length(&2, U32, FX.limbs(SL)), hN,
    FD.logic__subst(Nat, z => {Nat.is_le(A.quad(NW), z) == True{} : Bool}, A.quad(VB.len(SL)), List.length(&2, U32, FX.limbs(SL)), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL)), A.quad(VB.len(SL)), UW.len_limbs_v(SL)), UW.quad_le(NW, VB.len(SL), hLS)))
  +eLDT = VS.bt_len(N, FX.limbs(SL), hNL)
  +eDat = Equal.trans(+List<U32>, VS.bt(Nat.add(3n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)})), VS.bt(Nat.add(3n, qQ), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(Nat, +List<U32>, z => VS.bt(Nat.add(3n, A.quad(z)), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt), Equal.trans(+List<U32>, VS.bt(Nat.add(3n, qQ), FX.limbs(Con{x0, VS.wtake(Q, R1)})), VS.bt(Nat.add(3n, qQ), FX.limbs(W)), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(List<&2, U32>, +List<U32>, z => VS.bt(Nat.add(3n, qQ), FX.limbs(z)), Con{x0, VS.wtake(Q, R1)}, W, Equal.sym(List<&2, U32>, W, Con{x0, VS.wtake(Q, R1)}, eWc)), Equal.trans(+List<U32>, VS.bt(Nat.add(3n, qQ), FX.limbs(W)), VS.bt(Nat.add(3n, qQ), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(+List<U32>, +List<U32>, z => VS.bt(Nat.add(3n, qQ), z), FX.limbs(W), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E)), eK), Equal.trans(+List<U32>, VS.bt(Nat.add(3n, qQ), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), VS.bt(Nat.add(N, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(Nat, +List<U32>, z => VS.bt(z, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), Nat.add(3n, qQ), Nat.add(N, P), Equal.sym(Nat, Nat.add(N, P), Nat.add(3n, qQ), eL)), Equal.trans(+List<U32>, VS.bt(Nat.add(N, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), VS.bt(P, UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))) == List.append(&2, U32, VS.bt(N, FX.limbs(SL)), VS.bt(P, UW.ZB(E))) : +List<U32>}, List.length(&2, U32, VS.bt(N, FX.limbs(SL))), N, eLDT, UW.bt_app_len(VS.bt(N, FX.limbs(SL)), P, UW.ZB(E))), Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, VS.bt(N, FX.limbs(SL)), z), VS.bt(P, UW.ZB(E)), UW.ZB(P), UW.zb_win(0n, P, E, hPE)))))))
  Equal.trans(+List<U32>, UA.BYT(UW.SWc(1, W, dd, D, q, 0)), UA.BYT(UW.SWo(1, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0)), UW.SPL(B, X0, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P))),
    Equal.cong(FD.array__Tree<U32>, +List<U32>, z => UA.BYT(z), UW.SWc(1, W, dd, D, q, 0), UW.SWo(1, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0),
      Equal.trans(FD.array__Tree<U32>, UW.SWc(1, W, dd, D, q, 0), UW.SWo(1, W, dd, D, q, 0), UW.SWo(1, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0), eSW,
        Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(1, z, dd, D, q, 0), W, Con{x0, VS.wtake(Q, R1)}, eWc))),
    Equal.trans(+List<U32>, UA.BYT(UW.SWo(1, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0)), UW.SPL(B, X0, VS.bt(Nat.add(3n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)}))), UW.SPL(B, X0, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P))), sw,
      Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(B, X0, z), VS.bt(Nat.add(3n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), eDat)))

# ---- the tight put_words at byte 2: no carry word (r + n <= 4 NW), the open model --------------------

def c2_rt2(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(2n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(2n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(2n, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(2n, U32.to_nat(n))) == VC.NW(n) : Nat}, +eNW1: {VC.NW(n) == 1n+VY.QL(n) : Nat},
    +eL: {Nat.add(U32.to_nat(n), PADB(2n, U32.to_nat(n))) == Nat.add(2n, A.quad(VY.QL(n))) : Nat},
    +hc0: {O.shr_over(FD.flat__nthc(UW.SLW(T), VY.QL(n)), 2) == 0 : U32},
    +hn: {U32.is_eq(n, 0) == False{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(2n, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), 2n)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +P = PADB(2n, U32.to_nat(n))
  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc)
  +hLQ = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, NW, 1n+Q, eNW1, hLS)
  +eC = Equal.trans(U32, UW.CRY(2, W, 0), UW.CRY(2, VS.wtake(1n+Q, SL), 0), 0, Equal.cong(Nat, U32, z => UW.CRY(2, VS.wtake(z, SL), 0), NW, 1n+Q, eNW1), Equal.trans(U32, UW.CRY(2, VS.wtake(1n+Q, SL), 0), O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 2), 0, UW.cry_take(2, Q, 0n, SL, 0, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(SL)) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), FD.nat__succ_le_lt(Q, VB.len(SL), hLQ))), Equal.trans(U32, O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 2), O.shr_over(FD.flat__nthc(SL, Q), 2), 0, Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(SL, z), 2), Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), hc0)))
  +eSW = Equal.trans(FD.array__Tree<U32>, UW.SWc(2, W, dd, D, q, 0), UW.ORS(dd, UW.SWo(2, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), UW.CRY(2, W, 0)), UW.SWo(2, W, dd, D, q, 0),
    UW.swc_swo(2, W, dd, D, q, 0),
    Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo(2, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), z), UW.CRY(2, W, 0), 0, eC))
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, NW), Nat.add(NW, q), FD.nat__add_comm(q, NW),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(2n, N)), NW, eNWN, hl))
  +hL = Equal.trans(Nat, Nat.add(Nat.add(N, P), 2n), Nat.add(Nat.add(2n, qQ), 2n), A.quad(NW),
    Equal.cong(Nat, Nat, z => Nat.add(z, 2n), Nat.add(N, P), Nat.add(2n, qQ), eL),
    Equal.trans(Nat, Nat.add(Nat.add(2n, qQ), 2n), A.quad(1n+Q), A.quad(NW),
      Equal.cong(Nat, Nat, z => 2n+z, Nat.add(qQ, 2n), Nat.add(2n, qQ), FD.nat__add_comm(qQ, 2n)),
      Equal.cong(Nat, Nat, z => A.quad(z), 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNW1))))
  +hc = Equal.cong(U32, Bool, z => U32.is_eq(z, 0), UW.CRY(2, W, 0), 0, eC)
  %Equal.sym(FD.array__Tree<U32>, UW.SWc(2, W, dd, D, q, 0), UW.SWo(2, W, dd, D, q, 0), eSW) :
    {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, _), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
  UP2.putwu_o(dd, D, X, q, dw, T, n, e, hn, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, VY.FD_le1(NW, Q, eNW1), hsrc, hl2, Nat.add(N, P), hL, hz, hc, pf, pfT)

def c2_bytes2(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 2n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(2n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(2n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 2n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(2n, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(2n, U32.to_nat(n))) == VC.NW(n) : Nat}, +eNW1: {VC.NW(n) == 1n+VY.QL(n) : Nat},
    +eL: {Nat.add(U32.to_nat(n), PADB(2n, U32.to_nat(n))) == Nat.add(2n, A.quad(VY.QL(n))) : Nat},
    +hc0: {O.shr_over(FD.flat__nthc(UW.SLW(T), VY.QL(n)), 2) == 0 : U32},
    +hPE: {Nat.is_le(PADB(2n, U32.to_nat(n)), E) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(E)) : +List<U32>})
    -> {UA.BYT(PWM(2n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 2n), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(2n, U32.to_nat(n))))) : +List<U32>}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), 2n)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +P = PADB(2n, U32.to_nat(n))
  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc)
  +hLQ = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, NW, 1n+Q, eNW1, hLS)
  +eC = Equal.trans(U32, UW.CRY(2, W, 0), UW.CRY(2, VS.wtake(1n+Q, SL), 0), 0, Equal.cong(Nat, U32, z => UW.CRY(2, VS.wtake(z, SL), 0), NW, 1n+Q, eNW1), Equal.trans(U32, UW.CRY(2, VS.wtake(1n+Q, SL), 0), O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 2), 0, UW.cry_take(2, Q, 0n, SL, 0, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(SL)) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), FD.nat__succ_le_lt(Q, VB.len(SL), hLQ))), Equal.trans(U32, O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 2), O.shr_over(FD.flat__nthc(SL, Q), 2), 0, Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(SL, z), 2), Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), hc0)))
  +eSW = Equal.trans(FD.array__Tree<U32>, UW.SWc(2, W, dd, D, q, 0), UW.ORS(dd, UW.SWo(2, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), UW.CRY(2, W, 0)), UW.SWo(2, W, dd, D, q, 0),
    UW.swc_swo(2, W, dd, D, q, 0),
    Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo(2, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), z), UW.CRY(2, W, 0), 0, eC))
  +x0 = FD.flat__nthc(UW.SLW(T), 0n)
  +R1 = VB.wdr(1n, UW.SLW(T))
  +eS = UW.wdr_con(SL, 0n, FD.nat__lt_le_trans(0n, 1n+Q, VB.len(SL), {==}, hLQ))
  +hQR = FD.logic__subst(List<&2, U32>, z => {Nat.is_le(1n+Q, VB.len(z)) == True{} : Bool}, SL, Con{x0, R1}, eS, hLQ)
  +eLt = UW.len_take(Q, R1, hQR)
  +eWc = Equal.trans(List<&2, U32>, W, VS.wtake(1n+Q, SL), Con{x0, VS.wtake(Q, R1)},
    Equal.cong(Nat, List<&2, U32>, z => VS.wtake(z, SL), NW, 1n+Q, eNW1),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n+Q, z), SL, Con{x0, R1}, eS))
  +hr1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, 1n+z), VB.pw(dd)) == True{} : Bool}, Q, List.length(&2, U32, VS.wtake(Q, R1)), Equal.sym(Nat, List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(2n, N)), 1n+Q, Equal.trans(Nat, NWN(Nat.add(2n, N)), NW, 1n+Q, eNWN, eNW1), hl))
  +hz1 = FD.logic__subst(Nat, z => {VS.bt(Nat.add(2n, A.quad(z)), VS.bdr(X0, B)) == UW.ZB(Nat.add(2n, A.quad(z))) : +List<U32>}, Q, List.length(&2, U32, VS.wtake(Q, R1)), Equal.sym(Nat, List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt),
    FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(X0, B)) == UW.ZB(z) : +List<U32>}, Nat.add(N, P), Nat.add(2n, qQ), eL, hz))
  +sw = UB2.swcbo(x0, VS.wtake(Q, R1), dd, D, q, pf, hr1, hz1)
  +hNL = FD.nat__le_trans(N, A.quad(NW), List.length(&2, U32, FX.limbs(SL)), hN,
    FD.logic__subst(Nat, z => {Nat.is_le(A.quad(NW), z) == True{} : Bool}, A.quad(VB.len(SL)), List.length(&2, U32, FX.limbs(SL)), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL)), A.quad(VB.len(SL)), UW.len_limbs_v(SL)), UW.quad_le(NW, VB.len(SL), hLS)))
  +eLDT = VS.bt_len(N, FX.limbs(SL), hNL)
  +eDat = Equal.trans(+List<U32>, VS.bt(Nat.add(2n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)})), VS.bt(Nat.add(2n, qQ), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(Nat, +List<U32>, z => VS.bt(Nat.add(2n, A.quad(z)), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt), Equal.trans(+List<U32>, VS.bt(Nat.add(2n, qQ), FX.limbs(Con{x0, VS.wtake(Q, R1)})), VS.bt(Nat.add(2n, qQ), FX.limbs(W)), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(List<&2, U32>, +List<U32>, z => VS.bt(Nat.add(2n, qQ), FX.limbs(z)), Con{x0, VS.wtake(Q, R1)}, W, Equal.sym(List<&2, U32>, W, Con{x0, VS.wtake(Q, R1)}, eWc)), Equal.trans(+List<U32>, VS.bt(Nat.add(2n, qQ), FX.limbs(W)), VS.bt(Nat.add(2n, qQ), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(+List<U32>, +List<U32>, z => VS.bt(Nat.add(2n, qQ), z), FX.limbs(W), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E)), eK), Equal.trans(+List<U32>, VS.bt(Nat.add(2n, qQ), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), VS.bt(Nat.add(N, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(Nat, +List<U32>, z => VS.bt(z, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), Nat.add(2n, qQ), Nat.add(N, P), Equal.sym(Nat, Nat.add(N, P), Nat.add(2n, qQ), eL)), Equal.trans(+List<U32>, VS.bt(Nat.add(N, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), VS.bt(P, UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))) == List.append(&2, U32, VS.bt(N, FX.limbs(SL)), VS.bt(P, UW.ZB(E))) : +List<U32>}, List.length(&2, U32, VS.bt(N, FX.limbs(SL))), N, eLDT, UW.bt_app_len(VS.bt(N, FX.limbs(SL)), P, UW.ZB(E))), Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, VS.bt(N, FX.limbs(SL)), z), VS.bt(P, UW.ZB(E)), UW.ZB(P), UW.zb_win(0n, P, E, hPE)))))))
  Equal.trans(+List<U32>, UA.BYT(UW.SWc(2, W, dd, D, q, 0)), UA.BYT(UW.SWo(2, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0)), UW.SPL(B, X0, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P))),
    Equal.cong(FD.array__Tree<U32>, +List<U32>, z => UA.BYT(z), UW.SWc(2, W, dd, D, q, 0), UW.SWo(2, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0),
      Equal.trans(FD.array__Tree<U32>, UW.SWc(2, W, dd, D, q, 0), UW.SWo(2, W, dd, D, q, 0), UW.SWo(2, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0), eSW,
        Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(2, z, dd, D, q, 0), W, Con{x0, VS.wtake(Q, R1)}, eWc))),
    Equal.trans(+List<U32>, UA.BYT(UW.SWo(2, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0)), UW.SPL(B, X0, VS.bt(Nat.add(2n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)}))), UW.SPL(B, X0, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P))), sw,
      Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(B, X0, z), VS.bt(Nat.add(2n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), eDat)))

# ---- the tight put_words at byte 3: no carry word (r + n <= 4 NW), the open model --------------------

def c2_rt3(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(3n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(3n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(3n, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(3n, U32.to_nat(n))) == VC.NW(n) : Nat}, +eNW1: {VC.NW(n) == 1n+VY.QL(n) : Nat},
    +eL: {Nat.add(U32.to_nat(n), PADB(3n, U32.to_nat(n))) == Nat.add(1n, A.quad(VY.QL(n))) : Nat},
    +hc0: {O.shr_over(FD.flat__nthc(UW.SLW(T), VY.QL(n)), 3) == 0 : U32},
    +hn: {U32.is_eq(n, 0) == False{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(3n, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), 3n)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +P = PADB(3n, U32.to_nat(n))
  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc)
  +hLQ = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, NW, 1n+Q, eNW1, hLS)
  +eC = Equal.trans(U32, UW.CRY(3, W, 0), UW.CRY(3, VS.wtake(1n+Q, SL), 0), 0, Equal.cong(Nat, U32, z => UW.CRY(3, VS.wtake(z, SL), 0), NW, 1n+Q, eNW1), Equal.trans(U32, UW.CRY(3, VS.wtake(1n+Q, SL), 0), O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 3), 0, UW.cry_take(3, Q, 0n, SL, 0, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(SL)) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), FD.nat__succ_le_lt(Q, VB.len(SL), hLQ))), Equal.trans(U32, O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 3), O.shr_over(FD.flat__nthc(SL, Q), 3), 0, Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(SL, z), 3), Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), hc0)))
  +eSW = Equal.trans(FD.array__Tree<U32>, UW.SWc(3, W, dd, D, q, 0), UW.ORS(dd, UW.SWo(3, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), UW.CRY(3, W, 0)), UW.SWo(3, W, dd, D, q, 0),
    UW.swc_swo(3, W, dd, D, q, 0),
    Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo(3, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), z), UW.CRY(3, W, 0), 0, eC))
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, NW), Nat.add(NW, q), FD.nat__add_comm(q, NW),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(3n, N)), NW, eNWN, hl))
  +hL = Equal.trans(Nat, Nat.add(Nat.add(N, P), 3n), Nat.add(Nat.add(1n, qQ), 3n), A.quad(NW),
    Equal.cong(Nat, Nat, z => Nat.add(z, 3n), Nat.add(N, P), Nat.add(1n, qQ), eL),
    Equal.trans(Nat, Nat.add(Nat.add(1n, qQ), 3n), A.quad(1n+Q), A.quad(NW),
      Equal.cong(Nat, Nat, z => 1n+z, Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_comm(qQ, 3n)),
      Equal.cong(Nat, Nat, z => A.quad(z), 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNW1))))
  +hc = Equal.cong(U32, Bool, z => U32.is_eq(z, 0), UW.CRY(3, W, 0), 0, eC)
  %Equal.sym(FD.array__Tree<U32>, UW.SWc(3, W, dd, D, q, 0), UW.SWo(3, W, dd, D, q, 0), eSW) :
    {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, _), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}
  UP3.putwu_o(dd, D, X, q, dw, T, n, e, hn, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, VY.FD_le1(NW, Q, eNW1), hsrc, hl2, Nat.add(N, P), hL, hz, hc, pf, pfT)

def c2_bytes3(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 3n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +E: Nat, +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(3n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(3n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 3n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(3n, U32.to_nat(n)))) : +List<U32>},
    +eNWN: {NWN(Nat.add(3n, U32.to_nat(n))) == VC.NW(n) : Nat}, +eNW1: {VC.NW(n) == 1n+VY.QL(n) : Nat},
    +eL: {Nat.add(U32.to_nat(n), PADB(3n, U32.to_nat(n))) == Nat.add(1n, A.quad(VY.QL(n))) : Nat},
    +hc0: {O.shr_over(FD.flat__nthc(UW.SLW(T), VY.QL(n)), 3) == 0 : U32},
    +hPE: {Nat.is_le(PADB(3n, U32.to_nat(n)), E) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(E)) : +List<U32>})
    -> {UA.BYT(PWM(3n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 3n), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(3n, U32.to_nat(n))))) : +List<U32>}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +Q = VY.QL(n)
  +qQ = A.quad(VY.QL(n))
  +SL = UW.SLW(T)
  +B = UA.BYT(D)
  +X0 = Nat.add(A.quad(q), 3n)
  +W = VS.wtake(VC.NW(n), UW.SLW(T))
  +P = PADB(3n, U32.to_nat(n))
  +hLS = FD.logic__subst(Nat, z => {Nat.is_le(NW, z) == True{} : Bool}, VB.pw(dw), VB.len(SL), Equal.sym(Nat, VB.len(SL), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hsrc)
  +hLQ = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.len(SL)) == True{} : Bool}, NW, 1n+Q, eNW1, hLS)
  +eC = Equal.trans(U32, UW.CRY(3, W, 0), UW.CRY(3, VS.wtake(1n+Q, SL), 0), 0, Equal.cong(Nat, U32, z => UW.CRY(3, VS.wtake(z, SL), 0), NW, 1n+Q, eNW1), Equal.trans(U32, UW.CRY(3, VS.wtake(1n+Q, SL), 0), O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 3), 0, UW.cry_take(3, Q, 0n, SL, 0, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.len(SL)) == True{} : Bool}, Q, Nat.add(Q, 0n), Equal.sym(Nat, Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), FD.nat__succ_le_lt(Q, VB.len(SL), hLQ))), Equal.trans(U32, O.shr_over(FD.flat__nthc(SL, Nat.add(Q, 0n)), 3), O.shr_over(FD.flat__nthc(SL, Q), 3), 0, Equal.cong(Nat, U32, z => O.shr_over(FD.flat__nthc(SL, z), 3), Nat.add(Q, 0n), Q, FD.nat__add_zero(Q)), hc0)))
  +eSW = Equal.trans(FD.array__Tree<U32>, UW.SWc(3, W, dd, D, q, 0), UW.ORS(dd, UW.SWo(3, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), UW.CRY(3, W, 0)), UW.SWo(3, W, dd, D, q, 0),
    UW.swc_swo(3, W, dd, D, q, 0),
    Equal.cong(U32, FD.array__Tree<U32>, z => UW.ORS(dd, UW.SWo(3, W, dd, D, q, 0), Nat.add(List.length(&2, U32, W), q), z), UW.CRY(3, W, 0), 0, eC))
  +x0 = FD.flat__nthc(UW.SLW(T), 0n)
  +R1 = VB.wdr(1n, UW.SLW(T))
  +eS = UW.wdr_con(SL, 0n, FD.nat__lt_le_trans(0n, 1n+Q, VB.len(SL), {==}, hLQ))
  +hQR = FD.logic__subst(List<&2, U32>, z => {Nat.is_le(1n+Q, VB.len(z)) == True{} : Bool}, SL, Con{x0, R1}, eS, hLQ)
  +eLt = UW.len_take(Q, R1, hQR)
  +eWc = Equal.trans(List<&2, U32>, W, VS.wtake(1n+Q, SL), Con{x0, VS.wtake(Q, R1)},
    Equal.cong(Nat, List<&2, U32>, z => VS.wtake(z, SL), NW, 1n+Q, eNW1),
    Equal.cong(List<&2, U32>, List<&2, U32>, z => VS.wtake(1n+Q, z), SL, Con{x0, R1}, eS))
  +hr1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, 1n+z), VB.pw(dd)) == True{} : Bool}, Q, List.length(&2, U32, VS.wtake(Q, R1)), Equal.sym(Nat, List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(3n, N)), 1n+Q, Equal.trans(Nat, NWN(Nat.add(3n, N)), NW, 1n+Q, eNWN, eNW1), hl))
  +hz1 = FD.logic__subst(Nat, z => {VS.bt(Nat.add(1n, A.quad(z)), VS.bdr(X0, B)) == UW.ZB(Nat.add(1n, A.quad(z))) : +List<U32>}, Q, List.length(&2, U32, VS.wtake(Q, R1)), Equal.sym(Nat, List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt),
    FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(X0, B)) == UW.ZB(z) : +List<U32>}, Nat.add(N, P), Nat.add(1n, qQ), eL, hz))
  +sw = UB3.swcbo(x0, VS.wtake(Q, R1), dd, D, q, pf, hr1, hz1)
  +hNL = FD.nat__le_trans(N, A.quad(NW), List.length(&2, U32, FX.limbs(SL)), hN,
    FD.logic__subst(Nat, z => {Nat.is_le(A.quad(NW), z) == True{} : Bool}, A.quad(VB.len(SL)), List.length(&2, U32, FX.limbs(SL)), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL)), A.quad(VB.len(SL)), UW.len_limbs_v(SL)), UW.quad_le(NW, VB.len(SL), hLS)))
  +eLDT = VS.bt_len(N, FX.limbs(SL), hNL)
  +eDat = Equal.trans(+List<U32>, VS.bt(Nat.add(1n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)})), VS.bt(Nat.add(1n, qQ), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(Nat, +List<U32>, z => VS.bt(Nat.add(1n, A.quad(z)), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.length(&2, U32, VS.wtake(Q, R1)), Q, eLt), Equal.trans(+List<U32>, VS.bt(Nat.add(1n, qQ), FX.limbs(Con{x0, VS.wtake(Q, R1)})), VS.bt(Nat.add(1n, qQ), FX.limbs(W)), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(List<&2, U32>, +List<U32>, z => VS.bt(Nat.add(1n, qQ), FX.limbs(z)), Con{x0, VS.wtake(Q, R1)}, W, Equal.sym(List<&2, U32>, W, Con{x0, VS.wtake(Q, R1)}, eWc)), Equal.trans(+List<U32>, VS.bt(Nat.add(1n, qQ), FX.limbs(W)), VS.bt(Nat.add(1n, qQ), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(+List<U32>, +List<U32>, z => VS.bt(Nat.add(1n, qQ), z), FX.limbs(W), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E)), eK), Equal.trans(+List<U32>, VS.bt(Nat.add(1n, qQ), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), VS.bt(Nat.add(N, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), Equal.cong(Nat, +List<U32>, z => VS.bt(z, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), Nat.add(1n, qQ), Nat.add(N, P), Equal.sym(Nat, Nat.add(N, P), Nat.add(1n, qQ), eL)), Equal.trans(+List<U32>, VS.bt(Nat.add(N, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), VS.bt(P, UW.ZB(E))), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), FD.logic__subst(Nat, z => {VS.bt(Nat.add(z, P), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(E))) == List.append(&2, U32, VS.bt(N, FX.limbs(SL)), VS.bt(P, UW.ZB(E))) : +List<U32>}, List.length(&2, U32, VS.bt(N, FX.limbs(SL))), N, eLDT, UW.bt_app_len(VS.bt(N, FX.limbs(SL)), P, UW.ZB(E))), Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, VS.bt(N, FX.limbs(SL)), z), VS.bt(P, UW.ZB(E)), UW.ZB(P), UW.zb_win(0n, P, E, hPE)))))))
  Equal.trans(+List<U32>, UA.BYT(UW.SWc(3, W, dd, D, q, 0)), UA.BYT(UW.SWo(3, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0)), UW.SPL(B, X0, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P))),
    Equal.cong(FD.array__Tree<U32>, +List<U32>, z => UA.BYT(z), UW.SWc(3, W, dd, D, q, 0), UW.SWo(3, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0),
      Equal.trans(FD.array__Tree<U32>, UW.SWc(3, W, dd, D, q, 0), UW.SWo(3, W, dd, D, q, 0), UW.SWo(3, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0), eSW,
        Equal.cong(List<&2, U32>, FD.array__Tree<U32>, z => UW.SWo(3, z, dd, D, q, 0), W, Con{x0, VS.wtake(Q, R1)}, eWc))),
    Equal.trans(+List<U32>, UA.BYT(UW.SWo(3, Con{x0, VS.wtake(Q, R1)}, dd, D, q, 0)), UW.SPL(B, X0, VS.bt(Nat.add(1n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)}))), UW.SPL(B, X0, List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P))), sw,
      Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(B, X0, z), VS.bt(Nat.add(1n, A.quad(List.length(&2, U32, VS.wtake(Q, R1)))), FX.limbs(Con{x0, VS.wtake(Q, R1)})), List.append(&2, U32, VS.bt(N, FX.limbs(SL)), UW.ZB(P)), eDat)))

# ---- the tight put_words at an aligned position -------------------------------------------------

def r0_rtU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 0n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(0n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n)))) : +List<U32>}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(0n, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +eNW = VC.eNWu(n, hy)
  +hdst = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, NW), Nat.add(NW, q), FD.nat__add_comm(q, NW),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(0n, N)), NW, Equal.sym(Nat, NW, NWN(Nat.add(0n, N)), eNW), hl))
  +eP0 = Equal.trans(Nat, PADB(0n, N), Nat.sub(Nat.sub(A.quad(NW), 0n), N), Nat.sub(A.quad(NW), N),
    Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 0n), N), NWN(Nat.add(0n, N)), NW, Equal.sym(Nat, NW, NWN(Nat.add(0n, N)), eNW)),
    Equal.cong(Nat, Nat, z => Nat.sub(z, N), Nat.sub(A.quad(NW), 0n), A.quad(NW), FD.nat__sub_zero(A.quad(NW))))
  +eWin = Equal.trans(Nat, Nat.add(N, PADB(0n, N)), Nat.add(N, Nat.sub(A.quad(NW), N)), A.quad(NW),
    Equal.cong(Nat, Nat, z => Nat.add(N, z), PADB(0n, N), Nat.sub(A.quad(NW), N), eP0), FD.nat__sub_add(A.quad(NW), N, hN))
  +hzw = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, Nat.add(N, PADB(0n, N)), A.quad(NW), eWin, hz)
  pwn2U(dd, dw, D, T, X, q, n, pf, pfT, FD.nat__lt_trans(dd, 29n, 31n, hd, {==}), hdw, UW.ua_3(X, q, 0n, 0, {==}, e, {==}), UW.ua_q(X, q, 0n, e, {==}), hy,
    FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, VC.NW(n), Nat.add(VC.NW(n), 0n), Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))), hsrc),
    hdst, hzw, U32.is_eq(n, 0), {==})

def r0_rt(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 0n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(0n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n)))) : +List<U32>}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(0n, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  r0_rtU(dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, pf, pfT, hl, hz, hN)

def r0_bytesU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 0n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(0n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n)))) : +List<U32>}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>})
    -> {UA.BYT(PWM(0n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(0n, U32.to_nat(n))))) : +List<U32>}:
  +N = U32.to_nat(n)
  +NW = VC.NW(n)
  +eNW = VC.eNWu(n, hy)
  +hdst = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, NW), Nat.add(NW, q), FD.nat__add_comm(q, NW),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{} : Bool}, NWN(Nat.add(0n, N)), NW, Equal.sym(Nat, NW, NWN(Nat.add(0n, N)), eNW), hl))
  +eP0 = Equal.trans(Nat, PADB(0n, N), Nat.sub(Nat.sub(A.quad(NW), 0n), N), Nat.sub(A.quad(NW), N),
    Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 0n), N), NWN(Nat.add(0n, N)), NW, Equal.sym(Nat, NW, NWN(Nat.add(0n, N)), eNW)),
    Equal.cong(Nat, Nat, z => Nat.sub(z, N), Nat.sub(A.quad(NW), 0n), A.quad(NW), FD.nat__sub_zero(A.quad(NW))))
  +eWin = Equal.trans(Nat, Nat.add(N, PADB(0n, N)), Nat.add(N, Nat.sub(A.quad(NW), N)), A.quad(NW),
    Equal.cong(Nat, Nat, z => Nat.add(N, z), PADB(0n, N), Nat.sub(A.quad(NW), N), eP0), FD.nat__sub_add(A.quad(NW), N, hN))
  +hzw = FD.logic__subst(Nat, z => {VS.bt(z, VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(z) : +List<U32>}, Nat.add(N, PADB(0n, N)), A.quad(NW), eWin, hz)
  +DT = VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T)))
  %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {UA.BYT(PWM(0n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), _, List.append(&2, U32, DT, UW.ZB(PADB(0n, N)))) : +List<U32>}
  %Equal.sym(Nat, PADB(0n, N), Nat.sub(A.quad(NW), N), eP0) : {UA.BYT(PWM(0n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), A.quad(q), List.append(&2, U32, DT, UW.ZB(_))) : +List<U32>}
  %eK : {UA.BYT(PWM(0n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), A.quad(q), _) : +List<U32>}
  UW.mone_bytes(VC.NW(n), 0n, q, dd, D, dw, T, pf, pfT, hdst, hsrc)

def r0_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), 0n) : Nat}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(0n, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(0n, U32.to_nat(n)))) : +List<U32>}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VC.NW(n))) == True{} : Bool},
    +eK: {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>})
    -> {UA.BYT(PWM(0n, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 0n), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(0n, U32.to_nat(n))))) : +List<U32>}:
  r0_bytesU(dd, D, X, q, dw, T, n, e, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, pf, pfT, hl, hz, hN, eK)

def pwd_rtU(+b0: Bool, +b1: Bool,
    +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eb: {U32.and(n, 3) == U32{WCon{b0, WCon{b1, Word.zero(30n)}}} : U32})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  match b0 b1 r:
    case False{} False{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
r0_rtU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN)
    case False{} False{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 0n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 3n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(0n, qQ)), 3n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(0n, qQ), eNp), subq(3n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, Q, NW, Equal.sym(Nat, NW, Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(1n, N), 3n, Nat.add(EE, 3n), ePv, Equal.sym(Nat, Nat.add(EE, 3n), 3n, Equal.cong(Nat, Nat, z => Nat.add(z, 3n), EE, 0n, eE)))
      c1_rtU(dd, D, X, q, 1n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 3n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN))
    case False{} False{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 1n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 0n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), 2n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), Nat.add(0n, qQ)), 2n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 2n), z), N, Nat.add(0n, qQ), eNp), subq(2n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 1n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, Q, NW, Equal.sym(Nat, NW, Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(2n, N), 2n, Nat.add(EE, 2n), ePv, Equal.sym(Nat, Nat.add(EE, 2n), 2n, Equal.cong(Nat, Nat, z => Nat.add(z, 2n), EE, 0n, eE)))
      c1_rtU(dd, D, X, q, 2n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 2n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN))
    case False{} False{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 1n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 0n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), 1n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), Nat.add(0n, qQ)), 1n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 3n), z), N, Nat.add(0n, qQ), eNp), subq(1n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 1n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, Q, NW, Equal.sym(Nat, NW, Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(3n, N), 1n, Nat.add(EE, 1n), ePv, Equal.sym(Nat, Nat.add(EE, 1n), 1n, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), EE, 0n, eE)))
      c1_rtU(dd, D, X, q, 3n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 1n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN))
    case False{} False{} 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))
    case True{} False{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
r0_rtU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN)
    case True{} False{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 1n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 2n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(1n, qQ)), 2n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(1n, qQ), eNp), subq(2n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 1n), 2n), Nat.add(3n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 1n), PADB(1n, N)), Nat.add(Nat.add(qQ, 1n), 2n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(1n, N)), N, Nat.add(qQ, 1n), n_qr(n, 1n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 1n), z), PADB(1n, N), 2n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 1n), 2n), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_assoc(qQ, 1n, 2n), FD.nat__add_comm(qQ, 3n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 2n, PADB(1n, N), Equal.sym(Nat, PADB(1n, N), 2n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(2n, z) == True{} : Bool}, 3n, EE, Equal.sym(Nat, EE, 3n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(1n, qQ), eNp))
      c2_rt1(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc11(VB.slot(T, Q), ht), hn)
    case True{} False{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 1n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 1n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), 1n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), Nat.add(1n, qQ)), 1n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 2n), z), N, Nat.add(1n, qQ), eNp), subq(1n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 1n), 1n), Nat.add(2n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 1n), PADB(2n, N)), Nat.add(Nat.add(qQ, 1n), 1n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(2n, N)), N, Nat.add(qQ, 1n), n_qr(n, 1n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 1n), z), PADB(2n, N), 1n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 1n), 1n), Nat.add(qQ, 2n), Nat.add(2n, qQ), FD.nat__add_assoc(qQ, 1n, 1n), FD.nat__add_comm(qQ, 2n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 1n, PADB(2n, N), Equal.sym(Nat, PADB(2n, N), 1n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 3n, EE, Equal.sym(Nat, EE, 3n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(1n, qQ), eNp))
      c2_rt2(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc21(VB.slot(T, Q), ht), hn)
    case True{} False{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 1n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 1n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), 0n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), Nat.add(1n, qQ)), 0n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 3n), z), N, Nat.add(1n, qQ), eNp), subq(0n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(3n, N)), Nat.add(Nat.add(qQ, 1n), 0n), Nat.add(1n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(3n, N)), Nat.add(Nat.add(qQ, 1n), PADB(3n, N)), Nat.add(Nat.add(qQ, 1n), 0n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(3n, N)), N, Nat.add(qQ, 1n), n_qr(n, 1n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 1n), z), PADB(3n, N), 0n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 1n), 0n), Nat.add(qQ, 1n), Nat.add(1n, qQ), FD.nat__add_assoc(qQ, 1n, 0n), FD.nat__add_comm(qQ, 1n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 0n, PADB(3n, N), Equal.sym(Nat, PADB(3n, N), 0n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(0n, z) == True{} : Bool}, 3n, EE, Equal.sym(Nat, EE, 3n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(1n, qQ), eNp))
      c2_rt3(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc31(VB.slot(T, Q), ht), hn)
    case True{} False{} 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))
    case False{} True{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
r0_rtU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN)
    case False{} True{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 2n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 1n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(2n, qQ)), 1n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(2n, qQ), eNp), subq(1n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 2n), 1n), Nat.add(3n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 2n), PADB(1n, N)), Nat.add(Nat.add(qQ, 2n), 1n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(1n, N)), N, Nat.add(qQ, 2n), n_qr(n, 2n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 2n), z), PADB(1n, N), 1n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 2n), 1n), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_assoc(qQ, 2n, 1n), FD.nat__add_comm(qQ, 3n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 1n, PADB(1n, N), Equal.sym(Nat, PADB(1n, N), 1n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 2n, EE, Equal.sym(Nat, EE, 2n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(2n, qQ), eNp))
      c2_rt1(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc12(VB.slot(T, Q), ht), hn)
    case False{} True{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 1n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 2n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), 0n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), Nat.add(2n, qQ)), 0n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 2n), z), N, Nat.add(2n, qQ), eNp), subq(0n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 2n), 0n), Nat.add(2n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 2n), PADB(2n, N)), Nat.add(Nat.add(qQ, 2n), 0n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(2n, N)), N, Nat.add(qQ, 2n), n_qr(n, 2n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 2n), z), PADB(2n, N), 0n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 2n), 0n), Nat.add(qQ, 2n), Nat.add(2n, qQ), FD.nat__add_assoc(qQ, 2n, 0n), FD.nat__add_comm(qQ, 2n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 0n, PADB(2n, N), Equal.sym(Nat, PADB(2n, N), 0n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(0n, z) == True{} : Bool}, 2n, EE, Equal.sym(Nat, EE, 2n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(2n, qQ), eNp))
      c2_rt2(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc22(VB.slot(T, Q), ht), hn)
    case False{} True{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 2n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 2n), 2n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 2n, eR), FD.nat__add_comm(Q, 2n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), 3n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 2n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), Nat.add(2n, qQ)), 3n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(2n+Q), 3n), z), N, Nat.add(2n, qQ), eNp), subq(3n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 2n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(3n, N), 3n, Nat.add(EE, 1n), ePv, Equal.sym(Nat, Nat.add(EE, 1n), 3n, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), EE, 2n, eE)))
      c1_rtU(dd, D, X, q, 3n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 1n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN))
    case False{} True{} 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))
    case True{} True{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
r0_rtU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN)
    case True{} True{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 3n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 0n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(3n, qQ)), 0n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(3n, qQ), eNp), subq(0n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 3n), 0n), Nat.add(3n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 3n), PADB(1n, N)), Nat.add(Nat.add(qQ, 3n), 0n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(1n, N)), N, Nat.add(qQ, 3n), n_qr(n, 3n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 3n), z), PADB(1n, N), 0n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 3n), 0n), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_assoc(qQ, 3n, 0n), FD.nat__add_comm(qQ, 3n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 0n, PADB(1n, N), Equal.sym(Nat, PADB(1n, N), 0n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(0n, z) == True{} : Bool}, 1n, EE, Equal.sym(Nat, EE, 1n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(3n, qQ), eNp))
      c2_rt1(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc13(VB.slot(T, Q), ht), hn)
    case True{} True{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 2n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 2n), 2n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 3n, eR), FD.nat__add_comm(Q, 2n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(2n+Q), 2n), N), 3n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 2n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(2n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(2n+Q), 2n), Nat.add(3n, qQ)), 3n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(2n+Q), 2n), z), N, Nat.add(3n, qQ), eNp), subq(3n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 2n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(2n, N), 3n, Nat.add(EE, 2n), ePv, Equal.sym(Nat, Nat.add(EE, 2n), 3n, Equal.cong(Nat, Nat, z => Nat.add(z, 2n), EE, 1n, eE)))
      c1_rtU(dd, D, X, q, 2n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 2n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN))
    case True{} True{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 2n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 2n), 2n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 3n, eR), FD.nat__add_comm(Q, 2n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), 2n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 2n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), Nat.add(3n, qQ)), 2n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(2n+Q), 3n), z), N, Nat.add(3n, qQ), eNp), subq(2n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 2n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(3n, N), 2n, Nat.add(EE, 1n), ePv, Equal.sym(Nat, Nat.add(EE, 1n), 2n, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), EE, 1n, eE)))
      c1_rtU(dd, D, X, q, 3n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 1n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN))
    case True{} True{} 4n+ +t: Empty.absurd({O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(4n+t, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}, FD.nat__lt_zero_absurd(t, hr))

def pwd_rt(+b0: Bool, +b1: Bool,
    +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eb: {U32.and(n, 3) == U32{WCon{b0, WCon{b1, Word.zero(30n)}}} : U32})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  pwd_rtU(b0, b1, dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, htz, hz, eb)

def pwd_bytesU(+b0: Bool, +b1: Bool,
    +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eb: {U32.and(n, 3) == U32{WCon{b0, WCon{b1, Word.zero(30n)}}} : U32})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(r, U32.to_nat(n))))) : +List<U32>}:
  match b0 b1 r:
    case False{} False{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
r0_bytesU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN, eK)
    case False{} False{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 0n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 3n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(0n, qQ)), 3n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(0n, qQ), eNp), subq(3n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, Q, NW, Equal.sym(Nat, NW, Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(1n, N), 3n, Nat.add(EE, 3n), ePv, Equal.sym(Nat, Nat.add(EE, 3n), 3n, Equal.cong(Nat, Nat, z => Nat.add(z, 3n), EE, 0n, eE)))
      c1_bytesU(dd, D, X, q, 1n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 3n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN), eK)
    case False{} False{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 1n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 0n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), 2n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), Nat.add(0n, qQ)), 2n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 2n), z), N, Nat.add(0n, qQ), eNp), subq(2n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 1n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, Q, NW, Equal.sym(Nat, NW, Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(2n, N), 2n, Nat.add(EE, 2n), ePv, Equal.sym(Nat, Nat.add(EE, 2n), 2n, Equal.cong(Nat, Nat, z => Nat.add(z, 2n), EE, 0n, eE)))
      c1_bytesU(dd, D, X, q, 2n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 2n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN), eK)
    case False{} False{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +eNWq = Equal.trans(Nat, VC.NW(n), Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Q, nw_qrU(n, hy),
        Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+RR(n))), Nat.add(Q, 0n), Q, Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+z)), RR(n), 0n, eR), FD.nat__add_zero(Q)))
      +eK = key0U(n, T, hy, eR)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 0n), Nat.add(0n, qQ), n_qr(n, 0n, eR), FD.nat__add_comm(qQ, 0n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(Q), N), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(Q), N), Nat.sub(A.quad(Q), Nat.add(0n, qQ)), 0n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(Q), z), N, Nat.add(0n, qQ), eNp), subq(0n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(0n, qQ), N, Equal.sym(Nat, N, Nat.add(0n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, qQ), A.quad(z)) == True{} : Bool}, Q, NW, Equal.sym(Nat, NW, Q, eNWq), Order.add_right(0n, 0n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 1n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 0n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), 1n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), Nat.add(0n, qQ)), 1n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 3n), z), N, Nat.add(0n, qQ), eNp), subq(1n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 1n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, Q, NW, Equal.sym(Nat, NW, Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(3n, N), 1n, Nat.add(EE, 1n), ePv, Equal.sym(Nat, Nat.add(EE, 1n), 1n, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), EE, 0n, eE)))
      c1_bytesU(dd, D, X, q, 3n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 1n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN), eK)
    case False{} False{} 4n+ +t: Empty.absurd({UA.BYT(PWM(4n+t, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(4n+t, U32.to_nat(n))))) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))
    case True{} False{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
r0_bytesU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN, eK)
    case True{} False{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 1n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 2n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(1n, qQ)), 2n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(1n, qQ), eNp), subq(2n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 1n), 2n), Nat.add(3n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 1n), PADB(1n, N)), Nat.add(Nat.add(qQ, 1n), 2n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(1n, N)), N, Nat.add(qQ, 1n), n_qr(n, 1n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 1n), z), PADB(1n, N), 2n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 1n), 2n), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_assoc(qQ, 1n, 2n), FD.nat__add_comm(qQ, 3n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 2n, PADB(1n, N), Equal.sym(Nat, PADB(1n, N), 2n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(2n, z) == True{} : Bool}, 3n, EE, Equal.sym(Nat, EE, 3n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(1n, qQ), eNp))
      c2_bytes1(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc11(VB.slot(T, Q), ht), hPE, hN, eK)
    case True{} False{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 1n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 1n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), 1n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), Nat.add(1n, qQ)), 1n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 2n), z), N, Nat.add(1n, qQ), eNp), subq(1n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 1n), 1n), Nat.add(2n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 1n), PADB(2n, N)), Nat.add(Nat.add(qQ, 1n), 1n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(2n, N)), N, Nat.add(qQ, 1n), n_qr(n, 1n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 1n), z), PADB(2n, N), 1n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 1n), 1n), Nat.add(qQ, 2n), Nat.add(2n, qQ), FD.nat__add_assoc(qQ, 1n, 1n), FD.nat__add_comm(qQ, 2n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 1n, PADB(2n, N), Equal.sym(Nat, PADB(2n, N), 1n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 3n, EE, Equal.sym(Nat, EE, 3n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(1n, qQ), eNp))
      c2_bytes2(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc21(VB.slot(T, Q), ht), hPE, hN, eK)
    case True{} False{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 1n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 1n), Nat.add(1n, qQ), n_qr(n, 1n, eR), FD.nat__add_comm(qQ, 1n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(1n, qQ)), 3n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(1n, qQ), eNp), subq(3n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(1n, qQ), N, Equal.sym(Nat, N, Nat.add(1n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(1n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(1n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 1n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 1n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), 0n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 3n), Nat.add(1n, qQ)), 0n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 3n), z), N, Nat.add(1n, qQ), eNp), subq(0n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(3n, N)), Nat.add(Nat.add(qQ, 1n), 0n), Nat.add(1n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(3n, N)), Nat.add(Nat.add(qQ, 1n), PADB(3n, N)), Nat.add(Nat.add(qQ, 1n), 0n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(3n, N)), N, Nat.add(qQ, 1n), n_qr(n, 1n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 1n), z), PADB(3n, N), 0n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 1n), 0n), Nat.add(qQ, 1n), Nat.add(1n, qQ), FD.nat__add_assoc(qQ, 1n, 0n), FD.nat__add_comm(qQ, 1n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 0n, PADB(3n, N), Equal.sym(Nat, PADB(3n, N), 0n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(0n, z) == True{} : Bool}, 3n, EE, Equal.sym(Nat, EE, 3n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(1n, qQ), eNp))
      c2_bytes3(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc31(VB.slot(T, Q), ht), hPE, hN, eK)
    case True{} False{} 4n+ +t: Empty.absurd({UA.BYT(PWM(4n+t, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(4n+t, U32.to_nat(n))))) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))
    case False{} True{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
r0_bytesU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN, eK)
    case False{} True{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 2n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 1n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(2n, qQ)), 1n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(2n, qQ), eNp), subq(1n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 2n), 1n), Nat.add(3n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 2n), PADB(1n, N)), Nat.add(Nat.add(qQ, 2n), 1n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(1n, N)), N, Nat.add(qQ, 2n), n_qr(n, 2n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 2n), z), PADB(1n, N), 1n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 2n), 1n), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_assoc(qQ, 2n, 1n), FD.nat__add_comm(qQ, 3n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 1n, PADB(1n, N), Equal.sym(Nat, PADB(1n, N), 1n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 2n, EE, Equal.sym(Nat, EE, 2n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(2n, qQ), eNp))
      c2_bytes1(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc12(VB.slot(T, Q), ht), hPE, hN, eK)
    case False{} True{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 1n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 2n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), 0n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 2n), Nat.add(2n, qQ)), 0n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 2n), z), N, Nat.add(2n, qQ), eNp), subq(0n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 2n), 0n), Nat.add(2n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(2n, N)), Nat.add(Nat.add(qQ, 2n), PADB(2n, N)), Nat.add(Nat.add(qQ, 2n), 0n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(2n, N)), N, Nat.add(qQ, 2n), n_qr(n, 2n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 2n), z), PADB(2n, N), 0n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 2n), 0n), Nat.add(qQ, 2n), Nat.add(2n, qQ), FD.nat__add_assoc(qQ, 2n, 0n), FD.nat__add_comm(qQ, 2n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 0n, PADB(2n, N), Equal.sym(Nat, PADB(2n, N), 0n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(0n, z) == True{} : Bool}, 2n, EE, Equal.sym(Nat, EE, 2n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(2n, qQ), eNp))
      c2_bytes2(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc22(VB.slot(T, Q), ht), hPE, hN, eK)
    case False{} True{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 2n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 2n), Nat.add(2n, qQ), n_qr(n, 2n, eR), FD.nat__add_comm(qQ, 2n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(2n, qQ)), 2n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(2n, qQ), eNp), subq(2n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(2n, qQ), N, Equal.sym(Nat, N, Nat.add(2n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(2n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(2n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 2n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 2n), 2n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 2n, eR), FD.nat__add_comm(Q, 2n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), 3n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 2n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), Nat.add(2n, qQ)), 3n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(2n+Q), 3n), z), N, Nat.add(2n, qQ), eNp), subq(3n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 2n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(3n, N), 3n, Nat.add(EE, 1n), ePv, Equal.sym(Nat, Nat.add(EE, 1n), 3n, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), EE, 2n, eE)))
      c1_bytesU(dd, D, X, q, 3n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 1n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN), eK)
    case False{} True{} 4n+ +t: Empty.absurd({UA.BYT(PWM(4n+t, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(4n+t, U32.to_nat(n))))) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))
    case True{} True{} 0n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
r0_bytesU(dd, D, X, q, dw, T, n, e, hd, hdw, hy, hsrc, pf, pfT, hl, hz, hN, eK)
    case True{} True{} 1n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(1n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), 1n+Q, nwn_qr(n, 1n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, RR(n)))), Nat.add(Q, 1n), 1n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(1n, z))), RR(n), 3n, eR), FD.nat__add_comm(Q, 1n)))
      +ePv = Equal.trans(Nat, PADB(1n, N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), 0n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 1n), N), NWN(Nat.add(1n, N)), 1n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(1n+Q), 1n), N), Nat.sub(Nat.sub(A.quad(1n+Q), 1n), Nat.add(3n, qQ)), 0n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(1n+Q), 1n), z), N, Nat.add(3n, qQ), eNp), subq(0n, qQ)))
      +eNWN0 = Equal.trans(Nat, NWN(Nat.add(1n, N)), 1n+Q, NW, eNWNb, Equal.sym(Nat, NW, 1n+Q, eNWq))
      +eL = Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 3n), 0n), Nat.add(3n, qQ),
      Equal.trans(Nat, Nat.add(N, PADB(1n, N)), Nat.add(Nat.add(qQ, 3n), PADB(1n, N)), Nat.add(Nat.add(qQ, 3n), 0n),
        Equal.cong(Nat, Nat, z => Nat.add(z, PADB(1n, N)), N, Nat.add(qQ, 3n), n_qr(n, 3n, eR)),
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(qQ, 3n), z), PADB(1n, N), 0n, ePv)),
      Equal.trans(Nat, Nat.add(Nat.add(qQ, 3n), 0n), Nat.add(qQ, 3n), Nat.add(3n, qQ), FD.nat__add_assoc(qQ, 3n, 0n), FD.nat__add_comm(qQ, 3n)))
      +hPE = FD.logic__subst(Nat, z => {Nat.is_le(z, EE) == True{} : Bool}, 0n, PADB(1n, N), Equal.sym(Nat, PADB(1n, N), 0n, ePv),
      FD.logic__subst(Nat, z => {Nat.is_le(0n, z) == True{} : Bool}, 1n, EE, Equal.sym(Nat, EE, 1n, eE), {==}))
      +hn = Equal.trans(Bool, U32.is_eq(n, 0), Nat.is_eq(N, 0n), False{}, VD.eq0(n), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), N, Nat.add(3n, qQ), eNp))
      c2_bytes1(dd, D, X, q, dw, T, n, e, hd, hdw, hsrc, pf, pfT, EE, hl, hz, eNWN0, eNWq, eL, UWB.tzc13(VB.slot(T, Q), ht), hPE, hN, eK)
    case True{} True{} 2n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(2n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), 2n+Q, nwn_qr(n, 2n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, RR(n)))), Nat.add(Q, 2n), 2n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(2n, z))), RR(n), 3n, eR), FD.nat__add_comm(Q, 2n)))
      +ePv = Equal.trans(Nat, PADB(2n, N), Nat.sub(Nat.sub(A.quad(2n+Q), 2n), N), 3n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 2n), N), NWN(Nat.add(2n, N)), 2n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(2n+Q), 2n), N), Nat.sub(Nat.sub(A.quad(2n+Q), 2n), Nat.add(3n, qQ)), 3n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(2n+Q), 2n), z), N, Nat.add(3n, qQ), eNp), subq(3n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(2n, N)), 2n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(2n, N), 3n, Nat.add(EE, 2n), ePv, Equal.sym(Nat, Nat.add(EE, 2n), 3n, Equal.cong(Nat, Nat, z => Nat.add(z, 2n), EE, 1n, eE)))
      c1_bytesU(dd, D, X, q, 2n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 2n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN), eK)
    case True{} True{} 3n:
      +N = U32.to_nat(n)
      +NW = VC.NW(n)
      +Q = VY.QL(n)
      +qQ = A.quad(VY.QL(n))
      +EE = Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n))
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      +hb = Equal.trans(Bool, U32.is_eq(VY.RM(n), 0), Nat.is_eq(U32.to_nat(VY.RM(n)), 0n), False{}, VD.eq0(VY.RM(n)), Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), RR(n), 3n, eR))
      +eNWq = VY.nw_qU(n, hy, hb)
      +eK = key3U(n, dw, T, pfT, hy, hsrc, eR, ht)
      +eNp = Equal.trans(Nat, N, Nat.add(qQ, 3n), Nat.add(3n, qQ), n_qr(n, 3n, eR), FD.nat__add_comm(qQ, 3n))
      +eE = Equal.trans(Nat, EE, Nat.sub(A.quad(1n+Q), N), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(z), N), NW, 1n+Q, eNWq),
        Equal.trans(Nat, Nat.sub(A.quad(1n+Q), N), Nat.sub(A.quad(1n+Q), Nat.add(3n, qQ)), 1n, Equal.cong(Nat, Nat, z => Nat.sub(A.quad(1n+Q), z), N, Nat.add(3n, qQ), eNp), subq(1n, qQ)))
      +hN = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(NW)) == True{} : Bool}, Nat.add(3n, qQ), N, Equal.sym(Nat, N, Nat.add(3n, qQ), eNp),
        FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(3n, qQ), A.quad(z)) == True{} : Bool}, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq), Order.add_right(3n, 4n, qQ, {==})))
      +eNWNb = Equal.trans(Nat, NWN(Nat.add(3n, N)), Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), 2n+Q, nwn_qr(n, 3n),
      Equal.trans(Nat, Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, RR(n)))), Nat.add(Q, 2n), 2n+Q,
        Equal.cong(Nat, Nat, z => Nat.add(Q, VD.s_rng(2n, 3n+Nat.add(3n, z))), RR(n), 3n, eR), FD.nat__add_comm(Q, 2n)))
      +ePv = Equal.trans(Nat, PADB(3n, N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), 2n,
      Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(z), 3n), N), NWN(Nat.add(3n, N)), 2n+Q, eNWNb),
      Equal.trans(Nat, Nat.sub(Nat.sub(A.quad(2n+Q), 3n), N), Nat.sub(Nat.sub(A.quad(2n+Q), 3n), Nat.add(3n, qQ)), 2n,
        Equal.cong(Nat, Nat, z => Nat.sub(Nat.sub(A.quad(2n+Q), 3n), z), N, Nat.add(3n, qQ), eNp), subq(2n, qQ)))
      +eNWN1 = Equal.trans(Nat, NWN(Nat.add(3n, N)), 2n+Q, 1n+NW, eNWNb, Equal.cong(Nat, Nat, z => 1n+z, 1n+Q, NW, Equal.sym(Nat, NW, 1n+Q, eNWq)))
      +eP = Equal.trans(Nat, PADB(3n, N), 2n, Nat.add(EE, 1n), ePv, Equal.sym(Nat, Nat.add(EE, 1n), 2n, Equal.cong(Nat, Nat, z => Nat.add(z, 1n), EE, 1n, eE)))
      c1_bytesU(dd, D, X, q, 3n, dw, T, n, e, hr, hd, hdw, hy, hsrc, pf, pfT, 1n, EE, hl, hz, eNWN1, eP, FD.nat__sub_add(A.quad(NW), N, hN), eK)
    case True{} True{} 4n+ +t: Empty.absurd({UA.BYT(PWM(4n+t, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), 4n+t), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(4n+t, U32.to_nat(n))))) : +List<U32>}, FD.nat__lt_zero_absurd(t, hr))

def pwd_bytes(+b0: Bool, +b1: Bool,
    +dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>},
    +eb: {U32.and(n, 3) == U32{WCon{b0, WCon{b1, Word.zero(30n)}}} : U32})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(r, U32.to_nat(n))))) : +List<U32>}:
  pwd_bytesU(b0, b1, dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, htz, hz, eb)

# The low two bits of a word, as the word's own bits.
def LB0(+n: U32) -> Bool:
  match n:
    case U32{WCon{+b0, WCon{+b1, +t}}}: b0
def LB1(+n: U32) -> Bool:
  match n:
    case U32{WCon{+b0, WCon{+b1, +t}}}: b1
def rmv(+n: U32) -> {U32.and(n, 3) == U32{WCon{LB0(n), WCon{LB1(n), Word.zero(30n)}}} : U32}:
  match n:
    case U32{WCon{+b0, WCon{+b1, +t}}}: Equal.sym(U32, U32{WCon{b0, WCon{b1, Word.zero(30n)}}}, U32.and(U32{WCon{b0, WCon{b1, t}}}, 3), BF.low_sel(b0, b1, t))

# O.put_words at any byte position X = 4 q + r: room for the value's own words only
# (q + NWN(r + n) <= 2^dd), zero bytes up to the end of its last word, and the source's
# bytes past n zero (its storage check).
def putw_anyU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  pwd_rtU(LB0(n), LB1(n), dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, hy, hsrc, hl, pf, pfT, htz, hz, rmv(n))

def putw_any(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>})
    -> {O.put_words(FD.array__thaw(U32, D), X, O.Words{FD.array__thaw(U32, T), n}) == (FD.array__thaw(U32, PWM(r, dd, D, q, T, n)), O.Words{FD.array__thaw(U32, T), n}) : Array<U32> & O.Words}:
  putw_anyU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, htz, hz)

# Its bytes: the n bytes, then zeros to the end of the last word written.
def putw_any_bytesU(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(r, U32.to_nat(n))))) : +List<U32>}:
  pwd_bytesU(LB0(n), LB1(n), dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, hy, hsrc, hl, pf, pfT, htz, hz, rmv(n))

def putw_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dw: Nat, +T: FD.array__Tree<U32>, +n: U32, +k: Nat,
    +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdw: {Nat.is_lt(dw, 31n) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, NWN(Nat.add(r, U32.to_nat(n)))), VB.pw(dd)) == True{} : Bool}, +pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +hz: {VS.bt(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n))), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add(U32.to_nat(n), PADB(r, U32.to_nat(n)))) : +List<U32>})
    -> {UA.BYT(PWM(r, dd, D, q, T, n)) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(PADB(r, U32.to_nat(n))))) : +List<U32>}:
  putw_any_bytesU(dd, D, X, q, r, dw, T, n, e, hr, hd, hdw, VC.hyU(n, k, hk, hy), hsrc, hl, pf, pfT, htz, hz)

# ---- the source's words written: the n data bytes, then zeros to the end of the last word -------

def keydU(+b0: Bool, +b1: Bool, +n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +eb: {U32.and(n, 3) == U32{WCon{b0, WCon{b1, Word.zero(30n)}}} : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  match b0 b1:
    case False{} False{}:
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{False{}, Word.zero(30n)}}}, eb)
      key0U(n, T, hy, eR)
    case True{} False{}:
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 8n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{False{}, Word.zero(30n)}}}, eb, htz))
      key1U(n, dw, T, pfT, hy, hsrc, eR, ht)
    case False{} True{}:
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 16n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{False{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      key2U(n, dw, T, pfT, hy, hsrc, eR, ht)
    case True{} True{}:
      +eR = Equal.cong(U32, Nat, z => U32.to_nat(z), U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb)
      +ht = FD.u32alg__eq_of(U32.shrn(VB.slot(T, VY.QL(n)), 24n), 0, FD.logic__subst(U32, z => {O.tail_zero(z, VB.slot(T, VY.QL(n))) == True{} : Bool}, U32.and(n, 3), U32{WCon{True{}, WCon{True{}, Word.zero(30n)}}}, eb, htz))
      key3U(n, dw, T, pfT, hy, hsrc, eR, ht)

def keyd(+b0: Bool, +b1: Bool, +n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool},
    +eb: {U32.and(n, 3) == U32{WCon{b0, WCon{b1, Word.zero(30n)}}} : U32})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  keydU(b0, b1, n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc, htz, eb)

def key_anyU(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  keydU(LB0(n), LB1(n), n, dw, T, pfT, hy, hsrc, htz, rmv(n))

def key_any(+n: U32, +dw: Nat, +T: FD.array__Tree<U32>, +k: Nat, +pfT: {FD.array__perfect(U32, dw, T) == True{} : Bool},
    +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(n), VB.pw(k)) == True{} : Bool}, +hsrc: {Nat.is_le(VC.NW(n), VB.pw(dw)) == True{} : Bool},
    +htz: {O.tail_zero(U32.and(n, 3), VB.slot(T, VY.QL(n))) == True{} : Bool})
    -> {FX.limbs(VS.wtake(VC.NW(n), UW.SLW(T))) == List.append(&2, U32, VS.bt(U32.to_nat(n), FX.limbs(UW.SLW(T))), UW.ZB(Nat.sub(A.quad(VC.NW(n)), U32.to_nat(n)))) : +List<U32>}:
  key_anyU(n, dw, T, pfT, VC.hyU(n, k, hk, hy), hsrc, htz)
