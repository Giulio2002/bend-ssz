import Base
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../compact/found_generated.bend as FD
import ../compact/arith.bend as A
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../spec/fulu_schemas.bend as Spec
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vmr_generated.bend as VMR
import ./vuw.bend as UW
import ./vcont.bend as VCN
import ./arr_vec_generated.bend as AV
import ./schema_shapes_generated.bend as SH
import ./vfxg_generated.bend as VXG

# The spec side of var_cont_enc's FixW fields (hand-written; for codegen/var_cont_enc.py's iface_text):
# a word vector held as a storage tree TB (its first W words: the parts of the vector's value over them are
# its bytes, arr_vec's vparts8 / vpartsu2), and SyncCommittee (its pubkeys' tree and the aggregate's words,
# vfxg.sc_parts), each with its bytes as the writer states them (VCN.PC of the bytes of vuwv_<p>).

# the first W words of TB: W of them, 4 W bytes
def lenW(+dB: Nat, +TB: FD.array__Tree<U32>, +W: Nat, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool},
    +hrB: {Nat.is_le(W, VB.pw(dB)) == True{} : Bool}) -> {List.length(&2, U32, VS.wtake(W, UW.SLW(TB))) == W : Nat}:
  UW.len_take(W, UW.SLW(TB), FD.logic__subst(Nat, z => {Nat.is_le(W, z) == True{} : Bool}, VB.pw(dB), VB.len(UW.SLW(TB)),
    Equal.sym(Nat, VB.len(UW.SLW(TB)), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)), hrB))

def slenW(+dB: Nat, +TB: FD.array__Tree<U32>, +W: Nat, +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool},
    +hrB: {Nat.is_le(W, VB.pw(dB)) == True{} : Bool}) -> {FD.spec_common__length(U32, VS.wtake(W, UW.SLW(TB))) == W : Nat}:
  Equal.trans(Nat, FD.spec_common__length(U32, VS.wtake(W, UW.SLW(TB))), List.length(&2, U32, VS.wtake(W, UW.SLW(TB))), W,
    Equal.sym(Nat, List.length(&2, U32, VS.wtake(W, UW.SLW(TB))), FD.spec_common__length(U32, VS.wtake(W, UW.SLW(TB))), VMR.len_eq(VS.wtake(W, UW.SLW(TB)))),
    lenW(dB, TB, W, pfB, hrB))

def wlenW(+dB: Nat, +TB: FD.array__Tree<U32>, +W: Nat, +Sz: Nat, +eS: {Nat.is_eq(A.quad(W), Sz) == True{} : Bool},
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(W, VB.pw(dB)) == True{} : Bool})
    -> {FX.wlen(VS.wtake(W, UW.SLW(TB))) == Sz : Nat}:
  Equal.trans(Nat, FX.wlen(VS.wtake(W, UW.SLW(TB))), A.quad(List.length(&2, U32, VS.wtake(W, UW.SLW(TB)))), Sz, VS.wlen_quad(VS.wtake(W, UW.SLW(TB))),
    Equal.trans(Nat, A.quad(List.length(&2, U32, VS.wtake(W, UW.SLW(TB)))), A.quad(W), Sz,
      Equal.cong(Nat, Nat, z => A.quad(z), List.length(&2, U32, VS.wtake(W, UW.SLW(TB))), W, lenW(dB, TB, W, pfB, hrB)),
      FD.nat__eq_from_is_eq(A.quad(W), Sz, eS)))

def lenB(+dB: Nat, +TB: FD.array__Tree<U32>, +W: Nat, +Sz: Nat, +eS: {Nat.is_eq(A.quad(W), Sz) == True{} : Bool},
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(W, VB.pw(dB)) == True{} : Bool})
    -> {List.length(&2, U32, FX.limbs(VS.wtake(W, UW.SLW(TB)))) == Sz : Nat}:
  Equal.trans(Nat, List.length(&2, U32, FX.limbs(VS.wtake(W, UW.SLW(TB)))), FX.wlen(VS.wtake(W, UW.SLW(TB))), Sz,
    VS.len_limbs(VS.wtake(W, UW.SLW(TB))), wlenW(dB, TB, W, Sz, eS, pfB, hrB))

# The values: a vector of Bytes32 / uint64 over TB's first W words.
def VV8(+W: Nat, +TB: FD.array__Tree<U32>) -> S.Value: S.Sequence{AV.ch8(VS.wtake(W, UW.SLW(TB)))}
def VU2(+W: Nat, +TB: FD.array__Tree<U32>) -> S.Value: S.Sequence{AV.chu2(VS.wtake(W, UW.SLW(TB)))}

# A vector of k Bytes32 over TB's first W words: one fixed part, the S bytes.
def wv8(+s: S.Schema, +dB: Nat, +TB: FD.array__Tree<U32>, +k: Nat, +W: Nat, +Sz: Nat,
    +hs: {SH.is_Vector(s) == True{} : Bool}, +he: {SH.Vector_element(s) == S.ByteVector{32n} : S.Schema}, +hk: {Nat.is_eq(SH.Vector_length(s), k) == True{} : Bool},
    +hk0: {Nat.is_lt(0n, k) == True{} : Bool}, +hL: {Nat.is_eq(AV.m8(k), W) == True{} : Bool}, +eS: {Nat.is_eq(A.quad(W), Sz) == True{} : Bool},
    +hf: {N.fits(4n, Nat.add(Sz, 0n)) == True{} : Bool},
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(W, VB.pw(dB)) == True{} : Bool})
    -> {Codec.parts(VV8(W, TB), s) == Some{[S.Fixed{VCN.PC(Sz, FX.limbs(VS.wtake(W, UW.SLW(TB))))}]} : Maybe<&2, +List<S.Part>>}:
  +ws = VS.wtake(W, UW.SLW(TB))
  +h = AV.vparts8(s, ws, k, W, Sz, hs, he, hk, hk0, slenW(dB, TB, W, pfB, hrB), hL, wlenW(dB, TB, W, Sz, eS, pfB, hrB), hf)
  FD.logic__subst(+List<U32>, z => {Codec.parts(VV8(W, TB), s) == Some{[S.Fixed{z}]} : Maybe<&2, +List<S.Part>>}, FX.limbs(ws), VCN.PC(Sz, FX.limbs(ws)),
    Equal.sym(+List<U32>, VCN.PC(Sz, FX.limbs(ws)), FX.limbs(ws), VCN.pc_id(Sz, FX.limbs(ws), lenB(dB, TB, W, Sz, eS, pfB, hrB))), h)

# A vector of k uint64 over TB's first W words.
def wvu2(+s: S.Schema, +dB: Nat, +TB: FD.array__Tree<U32>, +k: Nat, +W: Nat, +Sz: Nat,
    +hs: {SH.is_Vector(s) == True{} : Bool}, +he: {SH.Vector_element(s) == S.Unsigned{P.U64{}} : S.Schema}, +hk: {Nat.is_eq(SH.Vector_length(s), k) == True{} : Bool},
    +hk0: {Nat.is_lt(0n, k) == True{} : Bool}, +hL: {Nat.is_eq(AV.m2(k), W) == True{} : Bool}, +eS: {Nat.is_eq(A.quad(W), Sz) == True{} : Bool},
    +hf: {N.fits(4n, Nat.add(Sz, 0n)) == True{} : Bool},
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(W, VB.pw(dB)) == True{} : Bool})
    -> {Codec.parts(VU2(W, TB), s) == Some{[S.Fixed{VCN.PC(Sz, FX.limbs(VS.wtake(W, UW.SLW(TB))))}]} : Maybe<&2, +List<S.Part>>}:
  +ws = VS.wtake(W, UW.SLW(TB))
  +h = AV.vpartsu2(s, ws, k, W, Sz, hs, he, hk, hk0, slenW(dB, TB, W, pfB, hrB), hL, wlenW(dB, TB, W, Sz, eS, pfB, hrB), hf)
  FD.logic__subst(+List<U32>, z => {Codec.parts(VU2(W, TB), s) == Some{[S.Fixed{z}]} : Maybe<&2, +List<S.Part>>}, FX.limbs(ws), VCN.PC(Sz, FX.limbs(ws)),
    Equal.sym(+List<U32>, VCN.PC(Sz, FX.limbs(ws)), FX.limbs(ws), VCN.pc_id(Sz, FX.limbs(ws), lenB(dB, TB, W, Sz, eS, pfB, hrB))), h)

# SyncCommittee: its pubkeys (TB's first 6144 words) and aggregate pubkey (a0 .. a11): one fixed part, the writer's bytes.
def SCV(+TB: FD.array__Tree<U32>, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32, +a8: U32, +a9: U32, +a10: U32, +a11: U32) -> S.Value:
  S.Sequence{S.Items{S.Sequence{AV.ch12(VS.wtake(6144n, UW.SLW(TB)))}, S.Items{S.BytesValue{FX.limbs([a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])}, S.EmptyItems{}}}}
def SCB(+TB: FD.array__Tree<U32>, +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32, +a8: U32, +a9: U32, +a10: U32, +a11: U32) -> +List<U32>:
  List.append(&2, U32, VS.bt(U32.to_nat(24576), FX.limbs(UW.SLW(TB))), FX.limbs([a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11]))

def scp(+s: S.Schema, +es: {s == Spec.SyncCommittee() : S.Schema}, +dB: Nat, +TB: FD.array__Tree<U32>,
    +a0: U32, +a1: U32, +a2: U32, +a3: U32, +a4: U32, +a5: U32, +a6: U32, +a7: U32, +a8: U32, +a9: U32, +a10: U32, +a11: U32,
    +pfB: {FD.array__perfect(U32, dB, TB) == True{} : Bool}, +hrB: {Nat.is_le(6144n, VB.pw(dB)) == True{} : Bool},
    +hL: {List.length(&2, U32, SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11)) == 24624n : Nat})
    -> {Codec.parts(SCV(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11), s) == Some{[S.Fixed{VCN.PC(24624n, SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11))}]} : Maybe<&2, +List<S.Part>>}:
  +SL = UW.SLW(TB)
  +ws = VS.wtake(6144n, SL)
  +G = FX.limbs([a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])
  +h = VXG.sc_parts(s, es, ws, 6144n, 24576n, 24624n, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, slenW(dB, TB, 6144n, pfB, hrB), {==}, {==}, {==}, {==}, {==})
  +eK = FD.nat__eq_from_is_eq(U32.to_nat(24576), A.quad(6144n), {==})
  +eb = FD.logic__subst(Nat, z => {VS.bt(z, FX.limbs(SL)) == FX.limbs(ws) : +List<U32>}, A.quad(6144n), U32.to_nat(24576), Equal.sym(Nat, U32.to_nat(24576), A.quad(6144n), eK), VS.bt_limbs(6144n, SL))
  +h2 = FD.logic__subst(+List<U32>, z => {Codec.parts(SCV(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11), s) == Some{[S.Fixed{List.append(&2, U32, z, G)}]} : Maybe<&2, +List<S.Part>>},
    FX.limbs(ws), VS.bt(U32.to_nat(24576), FX.limbs(SL)), Equal.sym(+List<U32>, VS.bt(U32.to_nat(24576), FX.limbs(SL)), FX.limbs(ws), eb), h)
  FD.logic__subst(+List<U32>, z => {Codec.parts(SCV(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11), s) == Some{[S.Fixed{z}]} : Maybe<&2, +List<S.Part>>},
    SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11), VCN.PC(24624n, SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11)),
    Equal.sym(+List<U32>, VCN.PC(24624n, SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11)), SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11),
      VCN.pc_id(24624n, SCB(TB, a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11), hL)), h2)
