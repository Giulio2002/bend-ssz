import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/primitives.bend as SP
import ../compact/found.bend as F
import ./bitlist_pack.bend as BK
import ./bitlist_rep.bend as BO
import ./words_spec.bend as WS
import ./vbuf.bend as VB
import ./vbitenc.bend as VBT
import ./vbitdl.bend as DL
import ./vbitinv.bend as VI
import ../../proofs/nat_order.bend as Order
import ../compact/reads.bend as RD
import ./var_bits_enc_bw.bend as BW

# The bit-list root laws' representation facts (bitlist_obj rep_bits: wfb and the
# limit) of an object O.Bits{thaw(T), K} give the encoder's hypotheses: K <= N,
# and DL.HZ at word K / 32.

def OB(+T: F.array__Tree<U32>, +K: U32) -> O.Bits: O.Bits{F.array__thaw(U32, T), K}

def rep_N(+T: F.array__Tree<U32>, +K: U32, +N: Nat, +rep: BO.rep_bits(OB(T, K), S.BitList{N}))
    -> {Nat.is_le(U32.to_nat(K), N) == True{} : Bool}:
  (+wf, +r1) = rep
  (+hl, +hc) = r1
  hl

def bws(o: O.Bits) -> F.array__Tree<U32>:
  match o:
    case O.Bits{ws, +k}: F.array__freeze(U32, ws)

def eT_of(+T: F.array__Tree<U32>, +K: U32, +t: F.array__Tree<U32>, +K2: U32, +eo: {OB(T, K) == O.Bits{F.array__thaw(U32, t), K2} : O.Bits}) -> {T == t : F.array__Tree<U32>}:
  Equal.trans(F.array__Tree<U32>, T, F.array__freeze(U32, F.array__thaw(U32, T)), t, Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, T)), T, F.array__freeze_thaw(U32, T)),
    Equal.trans(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, T)), F.array__freeze(U32, F.array__thaw(U32, t)), t,
      Equal.cong(O.Bits, F.array__Tree<U32>, bws, OB(T, K), O.Bits{F.array__thaw(U32, t), K2}, eo), F.array__freeze_thaw(U32, t)))

def eK_of(+T: F.array__Tree<U32>, +K: U32, +t: F.array__Tree<U32>, +K2: U32, +eo: {OB(T, K) == O.Bits{F.array__thaw(U32, t), K2} : O.Bits}) -> {K == K2 : U32}:
  Equal.cong(O.Bits, U32, BO.blen, OB(T, K), O.Bits{F.array__thaw(U32, t), K2}, eo)

def add_z(+a: Nat, +r: Nat, +e: {Nat.add(a, r) == 0n : Nat}) -> {r == 0n : Nat}:
  match a:
    case 0n: e
    case 1n+ +p: Empty.absurd({r == 0n : Nat}, F.logic__false_true(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 1n+Nat.add(p, r), 0n, e)))

# An empty bit list: the delimiter goes to bit 0 of word 0.
def hz_zero(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat,
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool}, +e0: {U32.to_nat(K) == 0n : Nat})
    -> VI.INV(dw, T, K):
  +hK = F.nat__le_trans(Nat.add(U32.to_nat(K), 8n), Nat.add(N, 8n), O.pow2n(kb), Order.add_right(U32.to_nat(K), N, 8n, hN), hNk)
  +eK = VBT.Ka(K, kb, hkb, hK, VBT.JK(K), VBT.BKk(K), {==}, {==})
  +er = add_z(VBT.m32(VBT.QK(K)), DL.RK(K), Equal.trans(Nat, Nat.add(VBT.m32(VBT.QK(K)), DL.RK(K)), U32.to_nat(K), 0n, Equal.sym(Nat, U32.to_nat(K), Nat.add(VBT.m32(VBT.QK(K)), DL.RK(K)), eK), e0))
  %Equal.sym(Nat, DL.RK(K), 0n, er) : {DL.HZ(_, VB.slot(T, VBT.QK(K))) == True{} : Bool}
  {==}

def rep_hz(+dw: Nat, +T: F.array__Tree<U32>, +K: U32, +kb: Nat, +N: Nat,
    +pfT: {F.array__perfect(U32, dw, T) == True{} : Bool},
    +hkb: {Nat.is_lt(kb, 33n) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(K), N) == True{} : Bool},
    +hNk: {Nat.is_le(Nat.add(N, 8n), O.pow2n(kb)) == True{} : Bool},
    +hqs: {Nat.is_lt(VBT.QK(K), VB.pw(dw)) == True{} : Bool},
    +wf: BO.wfb(OB(T, K)))
    -> VI.INV(dw, T, K):
  match wf:
    case Inl{+a}:
      (+t, +a1) = a
      (+dw2, +a2) = a1
      (+K2, +a3) = a2
      (+eo, +a4) = a3
      (+pf2, +a5) = a4
      (+hd2, +e0) = a5
      +eK = eK_of(T, K, t, K2, eo)
      hz_zero(dw, T, K, kb, N, hkb, hN, hNk, F.logic__subst(U32, z => {U32.to_nat(z) == 0n : Nat}, K2, K, Equal.sym(U32, K, K2, eK), e0))
    case Inr{+b}:
      (+t, +b1) = b
      (+dw2, +b2) = b1
      (+K2, +b3) = b2
      (+Q, +b4) = b3
      (+R, +b5) = b4
      (+eo, +b6) = b5
      (+pf2, +b7) = b6
      (+hd2, +b8) = b7
      (+hnb, +b9) = b8
      (+hR0, +b10) = b9
      (+hR32, +b11) = b10
      (+hcq, +b12) = b11
      (+hpad, +b13) = b12
      (+hzt, +b14) = b13
      (+hbc, +hlen) = b14
      +eT = eT_of(T, K, t, K2, eo)
      +eK = eK_of(T, K, t, K2, eo)
      +hzt2 = F.logic__subst(F.array__Tree<U32>, z => {BK.zt(F.array__slots(U32, z), U32.to_nat(K)) == True{} : Bool}, t, T, Equal.sym(F.array__Tree<U32>, T, t, eT),
        F.logic__subst(U32, z => {BK.zt(F.array__slots(U32, t), U32.to_nat(z)) == True{} : Bool}, K2, K, Equal.sym(U32, K, K2, eK), hzt))
      +hnb2 = F.logic__subst(U32, z => {U32.to_nat(O.bits_nbytes(z)) == Nat.add(WS.e32(Q), R) : Nat}, K2, K, Equal.sym(U32, K, K2, eK), hnb)
      +hpad2 = F.logic__subst(F.array__Tree<U32>, z => {WS.bdrop(R, WS.cb(F.array__slots(U32, z), Nat.add(Q, 0n))) == SP.zero_bytes(Nat.sub(32n, R)) : +List<U32>}, t, T, Equal.sym(F.array__Tree<U32>, T, t, eT), hpad)
      VI.hz_inv(dw, T, K, kb, N, Q, R, pfT, hkb, hN, hNk, hqs, hzt2, hnb2, hR0, hR32, hpad2)
