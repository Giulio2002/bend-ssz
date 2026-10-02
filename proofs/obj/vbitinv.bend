import Base
import ../../src/obj.bend as O
import ../../spec/primitives.bend as SP
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../compact/reads.bend as RD
import ../../proofs/nat_order.bend as Order
import ./bitlist_pack_generated.bend as BK
import ./words_spec.bend as WS
import ./mtree_run.bend as MR
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vdepth.bend as VD
import ./vfix.bend as VF
import ./dk.bend as DK
import ./vbitenc.bend as VBT
import ./vbitdl.bend as DL
import ./var_bits_enc_bw_generated.bend as BW
import ./var_bits_enc_pad_generated.bend as PAD

# The object invariant of the bit-list root laws (bitlist_obj wfb1) gives the
# encoder's DL.HZ: BK.zt(slots T, K) (the bits of the last byte past K zero) and
# the zero bytes of the last chunk Q past the byte count e32(Q) + R make the bits
# K mod 32 .. 31 of word K / 32 zero.

# zw at word q from zt at 32 q + s, s <= 31 (the converse of VBT.zt_at).
def zw_head(+x: U32, +rest: List<&2, U32>, +s: Nat, +hs: {Nat.is_le(s, 31n) == True{} : Bool}, +hz: {BK.zt(Con{x, rest}, s) == True{} : Bool})
    -> {BK.zw(s, x) == True{} : Bool}:
  match s:
    case 0n: hz
    case 1n: hz
    case 2n: hz
    case 3n: hz
    case 4n: hz
    case 5n: hz
    case 6n: hz
    case 7n: hz
    case 8n: hz
    case 9n: hz
    case 10n: hz
    case 11n: hz
    case 12n: hz
    case 13n: hz
    case 14n: hz
    case 15n: hz
    case 16n: hz
    case 17n: hz
    case 18n: hz
    case 19n: hz
    case 20n: hz
    case 21n: hz
    case 22n: hz
    case 23n: hz
    case 24n: hz
    case 25n: hz
    case 26n: hz
    case 27n: hz
    case 28n: hz
    case 29n: hz
    case 30n: hz
    case 31n: hz
    case 32n+ +p: Empty.absurd({BK.zw(32n+p, x) == True{} : Bool}, F.logic__false_true(hs))

law zw_at:
  for +W: List<&2, U32>
  for +q: Nat
  for +s: Nat
  for +hs: {Nat.is_le(s, 31n) == True{} : Bool}
  for +hq: {Nat.is_lt(q, VB.len(W)) == True{} : Bool}
  for +hz: {BK.zt(W, Nat.add(VBT.m32(q), s)) == True{} : Bool}
  {BK.zw(s, F.flat__nthc(W, q)) == True{} : Bool}
def zw_at(W, q, s, hs, hq, hz):
  match W q:
    case Nil{} _: Empty.absurd({BK.zw(s, F.flat__nthc([], q)) == True{} : Bool}, F.nat__lt_zero_absurd(q, hq))
    case Con{+x, +rest} 0n: zw_head(x, rest, s, hs, hz)
    case Con{+x, +rest} 1n+ +p: zw_at(rest, p, s, hs, hq, hz)

law x8e8:
  for +k: Nat
  {VS.x8(k) == O.e8(k) : Nat}
def x8e8(k):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %x8e8(p) : {8n+VS.x8(p) == 8n+_ : Nat}
      {==}

# Chunk and offset of a byte count are unique (offsets 1..32).
def UQ(+Q1: Nat, +R1: Nat, +Q2: Nat, +R2: Nat) -> Data: DK.P2({Q1 == Q2 : Nat}, {R1 == R2 : Nat})

def e32_gt(+p: Nat, +R1: Nat, +R2: Nat, +e: {R1 == Nat.add(WS.e32(1n+p), R2) : Nat},
    +h1: {Nat.is_le(R1, 32n) == True{} : Bool}, +h2: {Nat.is_lt(0n, R2) == True{} : Bool}) -> Empty:
  +h3 = F.logic__subst(Nat, z => {Nat.is_le(z, 32n) == True{} : Bool}, R1, Nat.add(WS.e32(1n+p), R2), e, h1)
  +h4 = F.nat__le_trans(R2, Nat.add(WS.e32(p), R2), 0n, A.le_skip(WS.e32(p), R2), h3)
  F.logic__false_true(F.nat__lt_le_trans(0n, R2, 0n, h2, h4))

def uq1(+Q1: Nat, +R1: Nat, +Q2: Nat, +R2: Nat, +u: UQ(Q1, R1, Q2, R2)) -> {Q1 == Q2 : Nat}:
  (+a, +b) = u
  a

def uq2(+Q1: Nat, +R1: Nat, +Q2: Nat, +R2: Nat, +u: UQ(Q1, R1, Q2, R2)) -> {R1 == R2 : Nat}:
  (+a, +b) = u
  b

def pd(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

def pd32(+n: Nat) -> Nat: pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(pd(n))))))))))))))))))))))))))))))))

law e32_uniq:
  for +Q1: Nat
  for +R1: Nat
  for +Q2: Nat
  for +R2: Nat
  for +e: {Nat.add(WS.e32(Q1), R1) == Nat.add(WS.e32(Q2), R2) : Nat}
  for +a1: {Nat.is_lt(0n, R1) == True{} : Bool}
  for +b1: {Nat.is_le(R1, 32n) == True{} : Bool}
  for +a2: {Nat.is_lt(0n, R2) == True{} : Bool}
  for +b2: {Nat.is_le(R2, 32n) == True{} : Bool}
  UQ(Q1, R1, Q2, R2)
def e32_uniq(Q1, R1, Q2, R2, e, a1, b1, a2, b2):
  match Q1 Q2:
    case 0n 0n: ({==}, e)
    case 0n 1n+ +p: Empty.absurd(UQ(0n, R1, 1n+p, R2), e32_gt(p, R1, R2, e, b1, a2))
    case 1n+ +p 0n: Empty.absurd(UQ(1n+p, R1, 0n, R2), e32_gt(p, R2, R1, Equal.sym(Nat, Nat.add(WS.e32(1n+p), R1), R2, e), b2, a1))
    case 1n+ +p 1n+ +p2:
      +e2 = Equal.cong(Nat, Nat, z => pd32(z), Nat.add(WS.e32(1n+p), R1), Nat.add(WS.e32(1n+p2), R2), e)
      +u = e32_uniq(p, R1, p2, R2, e2, a1, b1, a2, b2)
      (Equal.cong(Nat, Nat, z => 1n+z, p, p2, uq1(p, R1, p2, R2, u)), uq2(p, R1, p2, R2, u))

def hz_pos(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat, +Q: Nat, +R: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hqs: {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool},
    +hzt: {BK.zt(F.array__slots(U32, T), U32.to_nat(K)) == True{} : Bool},
    +hnb: {U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(Q), R) : Nat},
    +hR0: {Nat.is_lt(0n, R) == True{} : Bool}, +hR32: {Nat.is_le(R, 32n) == True{} : Bool},
    +hpad: {WS.bdrop(R, WS.cb(F.array__slots(U32, T), Nat.add(Q, 0n))) == SP.zero_bytes(Nat.sub(32n, R)) : +List<U32>},
    +hr: {Nat.is_lt(0n, DL.RK(K)) == True{} : Bool})
    -> {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool}:
  +q = VBT.QK(K)
  +j = VBT.JK(K)
  +b = VBT.BKk(K)
  +r = DL.RK(K)
  +S = F.array__slots(U32, T)
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +hj = F.nat__le_lt_trans(j, 3n, 4n, RD.and_le(VBT.PDK(K), 3), {==})
  +hb = F.nat__le_lt_trans(b, 7n, 8n, RD.and_le(K, 7), {==})
  +cf = BW.cfj(j, b, hj, hb)
  +cE = DL.p1(DL.TE(j, b), DL.TF(j, b), DL.p2(DL.TD(j), DL.CE(j, b), DL.p2(DL.TC(j, b), DL.CD(j, b), DL.p2(DL.TB(b), DL.CC(j, b), DL.p2(DL.TA(j, b), DL.CB(j, b), cf)))))
  +c = Nat.add(j, BW.CWr(b))
  # zw at word q, from zt at K = 32 q + r
  +hzt2 = F.logic__subst(Nat, z => {BK.zt(S, z) == True{} : Bool}, U32.to_nat(K), Nat.add(VBT.m32(q), r), VBT.Ka(K, kb, hkb, hK, j, b, {==}, {==}), hzt)
  +hqS = F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), F.array__slots_length(U32, dw, T, pfT)), hqs)
  +hzw = zw_at(S, q, r, cE, hqS, hzt2)
  # the byte count: 4 q + c, q = 8 q8 + i
  +enb = Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(A.quad(q), Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n)))), Nat.add(A.quad(q), c),
    VBT.Fnb(K, kb, hkb, hK, j, b, Nat.add(j, VD.s_rng(3n, Nat.add(b, 7n))), {==}, {==}, {==}),
    Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), Nat.add(j, z)), VD.s_rng(3n, Nat.add(b, 7n)), BW.CWr(b), PAD.cwb(b, hb)))
  +x = U32.shrn(VBT.PDK(K), 2n)
  +q8 = U32.to_nat(U32.shrn(x, 3n))
  +i = U32.to_nat(U32.and(x, 7))
  +hi = F.nat__le_lt_trans(i, 7n, 8n, RD.and_le(x, 7), {==})
  +eq = Equal.trans(Nat, q, Nat.add(VS.x8(q8), i), Nat.add(O.e8(q8), i), VB.split8(x), Equal.cong(Nat, Nat, z => Nat.add(z, i), VS.x8(q8), O.e8(q8), x8e8(q8)))
  +enb2 = Equal.trans(Nat, Nat.add(WS.e32(Q), R), U32.to_nat(O.bits_nbytes(K)), Nat.add(WS.e32(q8), Nat.add(A.quad(i), c)), Equal.sym(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(WS.e32(Q), R), hnb),
    Equal.trans(Nat, U32.to_nat(O.bits_nbytes(K)), Nat.add(A.quad(q), c), Nat.add(WS.e32(q8), Nat.add(A.quad(i), c)), enb,
      Equal.trans(Nat, Nat.add(A.quad(q), c), Nat.add(A.quad(Nat.add(O.e8(q8), i)), c), Nat.add(WS.e32(q8), Nat.add(A.quad(i), c)),
        Equal.cong(Nat, Nat, z => Nat.add(A.quad(z), c), q, Nat.add(O.e8(q8), i), eq),
        Equal.trans(Nat, Nat.add(A.quad(Nat.add(O.e8(q8), i)), c), Nat.add(Nat.add(A.quad(O.e8(q8)), A.quad(i)), c), Nat.add(WS.e32(q8), Nat.add(A.quad(i), c)),
          Equal.cong(Nat, Nat, z => Nat.add(z, c), A.quad(Nat.add(O.e8(q8), i)), Nat.add(A.quad(O.e8(q8)), A.quad(i)), Equal.sym(Nat, Nat.add(A.quad(O.e8(q8)), A.quad(i)), A.quad(Nat.add(O.e8(q8), i)), VF.quad_add(O.e8(q8), i))),
          F.nat__add_assoc(A.quad(O.e8(q8)), A.quad(i), c)))))
  # the offset of word q's byte c in chunk q8 is 4 i + c, in 1..32
  +hc = PAD.cib(j, b, i, hj, hb, hi)
  +u = e32_uniq(Q, R, q8, Nat.add(A.quad(i), c), enb2, hR0, hR32, F.nat__lt_le_trans(0n, c, Nat.add(A.quad(i), c), PAD.cpos(j, b, hj, hb, hr), A.le_skip(A.quad(i), c)), hc)
  +eQ = uq1(Q, R, q8, Nat.add(A.quad(i), c), u)
  +eR = uq2(Q, R, q8, Nat.add(A.quad(i), c), u)
  +hpad2 = F.logic__subst(Nat, z => {WS.bdrop(z, WS.cb(S, Nat.add(q8, 0n))) == SP.zero_bytes(Nat.sub(32n, z)) : +List<U32>}, R, Nat.add(A.quad(i), c), eR,
    F.logic__subst(Nat, z => {WS.bdrop(R, WS.cb(S, Nat.add(z, 0n))) == SP.zero_bytes(Nat.sub(32n, R)) : +List<U32>}, Q, q8, eQ, hpad))
  +eW = Equal.trans(Nat, q, Nat.add(O.e8(q8), i), Nat.add(O.e8(Nat.add(q8, 0n)), i), eq,
    Equal.cong(Nat, Nat, z => Nat.add(O.e8(z), i), q8, Nat.add(q8, 0n), Equal.sym(Nat, Nat.add(q8, 0n), q8, F.nat__add_zero(q8))))
  +hzw2 = F.logic__subst(Nat, z => {BK.zw(r, F.flat__nthc(S, z)) == True{} : Bool}, q, Nat.add(O.e8(Nat.add(q8, 0n)), i), eW, hzw)
  +d = PAD.hzd(j, b, i, S, q8, hj, hb, hi, hzw2, hpad2)
  F.logic__subst(Nat, z => {DL.HZ(r, F.flat__nthc(S, z)) == True{} : Bool}, Nat.add(O.e8(Nat.add(q8, 0n)), i), q, Equal.sym(Nat, q, Nat.add(O.e8(Nat.add(q8, 0n)), i), eW), d)

def INV(+dw: Nat, +T: F.array__Tree<U32>, +K: U32) -> Data: {DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K))) == True{} : Bool}

def hz_case(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat, +Q: Nat, +R: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hqs: {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool},
    +hzt: {BK.zt(F.array__slots(U32, T), U32.to_nat(K)) == True{} : Bool},
    +hnb: {U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(Q), R) : Nat},
    +hR0: {Nat.is_lt(0n, R) == True{} : Bool}, +hR32: {Nat.is_le(R, 32n) == True{} : Bool},
    +hpad: {WS.bdrop(R, WS.cb(F.array__slots(U32, T), Nat.add(Q, 0n))) == SP.zero_bytes(Nat.sub(32n, R)) : +List<U32>},
    +r0: Nat, +er: {DL.RK(K) == r0 : Nat})
    -> INV(dw, T, K):
  match r0:
    case 0n:
      %Equal.sym(Nat, DL.RK(K), 0n, er) : {DL.HZ(_, VB.slot(T, VBT.QK(K))) == True{} : Bool}
      {==}
    case 1n+ +p:
      hz_pos(dw, T, K, kb, N, Q, R, pfT, hkb, hN, hNk, hqs, hzt, hnb, hR0, hR32, hpad,
        F.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+p, DL.RK(K), Equal.sym(Nat, DL.RK(K), 1n+p, er), {==}))

# The root laws' invariant gives the encoder's.
def hz_inv(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat, +Q: Nat, +R: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool},
    +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hqs: {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool},
    +hzt: {BK.zt(F.array__slots(U32, T), U32.to_nat(K)) == True{} : Bool},
    +hnb: {U32.to_nat(O.bits_nbytes(K)) == Nat.add(WS.e32(Q), R) : Nat},
    +hR0: {Nat.is_lt(0n, R) == True{} : Bool}, +hR32: {Nat.is_le(R, 32n) == True{} : Bool},
    +hpad: {WS.bdrop(R, WS.cb(F.array__slots(U32, T), Nat.add(Q, 0n))) == SP.zero_bytes(Nat.sub(32n, R)) : +List<U32>})
    -> INV(dw, T, K):
  hz_case(dw, T, K, kb, N, Q, R, pfT, hkb, hN, hNk, hqs, hzt, hnb, hR0, hR32, hpad, DL.RK(K), {==})
