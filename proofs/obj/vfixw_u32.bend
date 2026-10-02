import Base
import ../../types/schema.bend as S
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vuw.bend as UW
import ./vcont.bend as VCN
import ./vcopy.bend as VC
import ./arr_vec_generated.bend as AV
import ./vfits.bend as VFT
import ./vfixw_spec.bend as FWS
import ./schema_shapes_generated.bend as SH
import ../../types/primitive.bend as P

# vfixw_spec's word vectors at the packed vectors' literal-free sizes (vuwv_v8192_b32, ..: S = 2^E bytes, a
# U32 constant; W = VC.NW(S) words; the bytes' count U32.to_nat(S)). A closed Nat of S or W is unary to the
# checker (2^21 overflows its stack), so the sizes are never evaluated: the byte count's relation to the words
# is the vuwv module's eK, its bound its eS (S = pw(E)), and the four-byte fit vfits.fits4 at the exponent.

# pw is pow2 (a variable exponent: nothing evaluates)
def pwq(+d: Nat) -> {VB.pw(d) == FD.spec_common__pow2(d) : Nat}: {==}

# S fits in four bytes (S = pw(E), E < 32), as vfixw_spec's hf states it
def fitS(+S: U32, +E: Nat, +eS: {U32.to_nat(S) == VB.pw(E) : Nat}, +hE: {Nat.is_lt(E, 32n) == True{} : Bool})
    -> {N.fits(4n, Nat.add(U32.to_nat(S), 0n)) == True{} : Bool}:
  +P = FD.spec_common__pow2(E)
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, P, U32.to_nat(S),
    Equal.sym(Nat, U32.to_nat(S), P, Equal.trans(Nat, U32.to_nat(S), VB.pw(E), P, eS, pwq(E))), FD.nat__le_refl(P))
  FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(S), Nat.add(U32.to_nat(S), 0n),
    Equal.sym(Nat, Nat.add(U32.to_nat(S), 0n), U32.to_nat(S), FD.nat__add_zero(U32.to_nat(S))), VFT.fits4(E, U32.to_nat(S), hx, hE))

# 4 W = S, as vfixw_spec's eS states it
def eqS(+S: U32, +eK: {U32.to_nat(S) == A.quad(VC.NW(S)) : Nat}) -> {Nat.is_eq(A.quad(VC.NW(S)), U32.to_nat(S)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_eq(z, U32.to_nat(S)) == True{} : Bool}, U32.to_nat(S), A.quad(VC.NW(S)), eK, FD.nat__is_eq_refl(U32.to_nat(S)))

# A vector of k Bytes32 over TB's first VC.NW(S) words: one fixed part, its U32.to_nat(S) bytes.
def wv8u(+s: S.Schema, +dB: Nat, +TB: FD.array__Tree<U32>, +k: Nat, +S: U32, +E: Nat,
    +hs: {SH.is_Vector(s) == True{} : Bool}, +he: {SH.Vector_element(s) == S.ByteVector{32n} : S.Schema}, +hk: {Nat.is_eq(SH.Vector_length(s), k) == True{} : Bool},
    +hk0: {Nat.is_lt(0n, k) == True{} : Bool}, +hL: {Nat.is_eq(AV.m8(k), VC.NW(S)) == True{} : Bool},
    +eK: {U32.to_nat(S) == A.quad(VC.NW(S)) : Nat}, +eS: {U32.to_nat(S) == VB.pw(E) : Nat}, +hE: {Nat.is_lt(E, 32n) == True{} : Bool},
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(VC.NW(S), VB.pw(dB)) == True{} : Bool})
    -> {Codec.parts(FWS.VV8(VC.NW(S), TB), s) == Some{[S.Fixed{VCN.PC(U32.to_nat(S), FX.limbs(VS.wtake(VC.NW(S), UW.SLW(TB))))}]} : Maybe<&2, +List<S.Part>>}:
  FWS.wv8(s, dB, TB, k, VC.NW(S), U32.to_nat(S), hs, he, hk, hk0, hL, eqS(S, eK), fitS(S, E, eS, hE), pfB, hrB)

# A vector of k uint64 over TB's first VC.NW(S) words.
def wvu2u(+s: S.Schema, +dB: Nat, +TB: FD.array__Tree<U32>, +k: Nat, +S: U32, +E: Nat,
    +hs: {SH.is_Vector(s) == True{} : Bool}, +he: {SH.Vector_element(s) == S.Unsigned{P.U64{}} : S.Schema}, +hk: {Nat.is_eq(SH.Vector_length(s), k) == True{} : Bool},
    +hk0: {Nat.is_lt(0n, k) == True{} : Bool}, +hL: {Nat.is_eq(AV.m2(k), VC.NW(S)) == True{} : Bool},
    +eK: {U32.to_nat(S) == A.quad(VC.NW(S)) : Nat}, +eS: {U32.to_nat(S) == VB.pw(E) : Nat}, +hE: {Nat.is_lt(E, 32n) == True{} : Bool},
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(VC.NW(S), VB.pw(dB)) == True{} : Bool})
    -> {Codec.parts(FWS.VU2(VC.NW(S), TB), s) == Some{[S.Fixed{VCN.PC(U32.to_nat(S), FX.limbs(VS.wtake(VC.NW(S), UW.SLW(TB))))}]} : Maybe<&2, +List<S.Part>>}:
  FWS.wvu2(s, dB, TB, k, VC.NW(S), U32.to_nat(S), hs, he, hk, hk0, hL, eqS(S, eK), fitS(S, E, eS, hE), pfB, hrB)
