import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../types/primitive.bend as P
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/obj/spec_fixed.bend as F
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/root_types.bend as RT
import ../proofs/obj/big_var_win_Attestation.bend as WT
import ../proofs/obj/big_var_win_AggregateAndProof.bend as WA
import ../proofs/obj/big_var_win_SignedAggregateAndProof.bend as WS
import ./e2e_attw.bend as ATW

# The AggregateAndProof a word-aligned window reader builds (off = 4 i) views as the value the codec reads there.
def aap_w(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {WA.CHKw(t, i, off, len) == True{} : Bool})
    -> {RT.v_AggregateAndProof(WA.OBJw(t, i, off, len)) == WA.VALw(t, i, len) : S.Value}:
  +a = U32.is_le(108, len)
  +b = U32.is_eq(WA.SPOw(t, i), 108)
  +c = WT.CHKw(t, WA.JW(i), WA.OWc(off), WA.LLw(len))
  +ha = WA.ch_a(a, b, c, hchk)
  +hc = WA.ch_c(a, b, c, hchk)
  +e1 = ATW.att_w(d, t, WA.JW(i), WA.OWc(off), WA.LLw(len), WA.eoF(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), hd, WA.hwc(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), WA.hwc32(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), pf, hc)
  Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{S.UnsignedValue{P.UInt{VB.slot(t, Nat.add(0n, i)), VB.slot(t, Nat.add(1n, i)), 0, 0, 0, 0, 0, 0}}, S.Items{z, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(3n, i)), VB.slot(t, Nat.add(4n, i)), VB.slot(t, Nat.add(5n, i)), VB.slot(t, Nat.add(6n, i)), VB.slot(t, Nat.add(7n, i)), VB.slot(t, Nat.add(8n, i)), VB.slot(t, Nat.add(9n, i)), VB.slot(t, Nat.add(10n, i)), VB.slot(t, Nat.add(11n, i)), VB.slot(t, Nat.add(12n, i)), VB.slot(t, Nat.add(13n, i)), VB.slot(t, Nat.add(14n, i)), VB.slot(t, Nat.add(15n, i)), VB.slot(t, Nat.add(16n, i)), VB.slot(t, Nat.add(17n, i)), VB.slot(t, Nat.add(18n, i)), VB.slot(t, Nat.add(19n, i)), VB.slot(t, Nat.add(20n, i)), VB.slot(t, Nat.add(21n, i)), VB.slot(t, Nat.add(22n, i)), VB.slot(t, Nat.add(23n, i)), VB.slot(t, Nat.add(24n, i)), VB.slot(t, Nat.add(25n, i)), VB.slot(t, Nat.add(26n, i))])}, S.EmptyItems{}}}}}, RT.v_Attestation(WT.OBJw(t, WA.JW(i), WA.OWc(off), WA.LLw(len))), WT.VALw(t, WA.JW(i), WA.LLw(len)), e1)

# The SignedAggregateAndProof a word-aligned window reader builds (off = 4 i) views as the value the codec reads there.
def saap_w(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hw32: {Nat.is_lt(Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {WS.CHKw(t, i, off, len) == True{} : Bool})
    -> {RT.v_SignedAggregateAndProof(WS.OBJw(t, i, off, len)) == WS.VALw(t, i, len) : S.Value}:
  +a = U32.is_le(100, len)
  +b = U32.is_eq(WS.SPOw(t, i), 100)
  +c = WA.CHKw(t, WS.JW(i), WS.OWc(off), WS.LLw(len))
  +ha = WS.ch_a(a, b, c, hchk)
  +hc = WS.ch_c(a, b, c, hchk)
  +e1 = aap_w(d, t, WS.JW(i), WS.OWc(off), WS.LLw(len), WS.eoF(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), hd, WS.hwc(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), WS.hwc32(d, t, 0, i, off, len, eo, hd, hw, hw32, pf, ha), pf, hc)
  Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{z, S.Items{S.BytesValue{F.limbs([VB.slot(t, Nat.add(1n, i)), VB.slot(t, Nat.add(2n, i)), VB.slot(t, Nat.add(3n, i)), VB.slot(t, Nat.add(4n, i)), VB.slot(t, Nat.add(5n, i)), VB.slot(t, Nat.add(6n, i)), VB.slot(t, Nat.add(7n, i)), VB.slot(t, Nat.add(8n, i)), VB.slot(t, Nat.add(9n, i)), VB.slot(t, Nat.add(10n, i)), VB.slot(t, Nat.add(11n, i)), VB.slot(t, Nat.add(12n, i)), VB.slot(t, Nat.add(13n, i)), VB.slot(t, Nat.add(14n, i)), VB.slot(t, Nat.add(15n, i)), VB.slot(t, Nat.add(16n, i)), VB.slot(t, Nat.add(17n, i)), VB.slot(t, Nat.add(18n, i)), VB.slot(t, Nat.add(19n, i)), VB.slot(t, Nat.add(20n, i)), VB.slot(t, Nat.add(21n, i)), VB.slot(t, Nat.add(22n, i)), VB.slot(t, Nat.add(23n, i)), VB.slot(t, Nat.add(24n, i))])}, S.EmptyItems{}}}}, RT.v_AggregateAndProof(WA.OBJw(t, WS.JW(i), WS.OWc(off), WS.LLw(len))), WA.VALw(t, WS.JW(i), WS.LLw(len)), e1)
