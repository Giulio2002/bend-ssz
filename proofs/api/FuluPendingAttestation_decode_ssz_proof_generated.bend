import Base
import ../../src/buffer.bend as P0_B
import ../../types/FuluPendingAttestation_def_generated.bend as FuluPendingAttestation_d
import ../../types/FuluPendingAttestation_decode_ssz_generated.bend as FuluPendingAttestation_r
import ../slop/offsets/fulu_PendingAttestation_first_offset_generated.bend as P0_PRV
import ../../src/buffer.bend as P1_B
import ../../src/obj.bend as P1_O
import ../../types/schema.bend as P1_S
import ../../types/primitive.bend as P1_P
import ../compact/found_generated.bend as P1_FD
import ../compact/arith.bend as P1_A
import ../../proofs/nat_order.bend as P1_Order
import ../../spec/primitives.bend as P1_SP
import ../../spec/layout.bend as P1_Layout
import ../../spec/codec.bend as P1_Codec
import ../../spec/decoding_relation.bend as P1_Decoding
import ../../spec/nat_bytes.bend as P1_N
import ../../spec/fulu_schemas.bend as P1_Spec
import ../obj/spec_fixed.bend as P1_F
import ../obj/vspec.bend as P1_VS
import ../obj/vbuf.bend as P1_VB
import ../obj/vu32.bend as P1_VU
import ../obj/vcopy.bend as P1_VC
import ../obj/vdepth.bend as P1_VD
import ../obj/vfix.bend as P1_VF
import ../obj/var_fix_types_generated.bend as P1_VT
import ../obj/spec_bits_generated.bend as P1_FB
import ../obj/vfits.bend as P1_VFT
import ../obj/vlist.bend as P1_VLS
import ../obj/vbitl.bend as P1_VBL
import ../obj/vbyte_generated.bend as P1_VY
import ../obj/vbrt.bend as P1_VR
import ../obj/vbitc.bend as P1_VBC
import ../../spec/bitfields.bend as P1_Bits
import ../../spec/bit_packing.bend as P1_Bp
import ../../proofs/obj/decode_window_library_generated.bend as P1_DWL
import ../../proofs/obj/decode_window_FuluPendingAttestation_generated.bend as P1_DW_FuluPendingAttestation
import ../obj/var_bitc_PendingAttestation_generated.bend as P1_PRV
import ../../types/schema.bend as P2_S
import ../../spec/decoding_relation.bend as P2_Decoding
import ../../spec/fulu_schemas.bend as P2_Spec
import ../compact/found_generated.bend as P2_F
import ../compact/arith.bend as P2_A
import ../obj/vbuf.bend as P2_VB
import ../obj/var_bitc_PendingAttestation_generated.bend as P2_DC
import ../../proofs/decode_unique.bend as P2_DCO
import ../obj/var_bitc_PendingAttestation_unique_generated.bend as P2_PRV
import ../../src/buffer.bend as P3_B
import ../../src/obj.bend as P3_O
import ../../types/schema.bend as P3_S
import ../../types/primitive.bend as P3_P
import ../compact/found_generated.bend as P3_FD
import ../compact/arith.bend as P3_A
import ../../proofs/nat_order.bend as P3_Order
import ../../spec/primitives.bend as P3_SP
import ../../spec/layout.bend as P3_Layout
import ../../spec/codec.bend as P3_Codec
import ../../spec/decoding_relation.bend as P3_Decoding
import ../../spec/nat_bytes.bend as P3_N
import ../../spec/fulu_schemas.bend as P3_Spec
import ../obj/spec_fixed.bend as P3_F
import ../obj/vspec.bend as P3_VS
import ../obj/vbuf.bend as P3_VB
import ../obj/vu32.bend as P3_VU
import ../obj/vcopy.bend as P3_VC
import ../obj/vdepth.bend as P3_VD
import ../obj/vfix.bend as P3_VF
import ../obj/var_fix_types_generated.bend as P3_VT
import ../obj/spec_bits_generated.bend as P3_FB
import ../obj/vfits.bend as P3_VFT
import ../obj/vlist.bend as P3_VLS
import ../obj/vbitl.bend as P3_VBL
import ../obj/vbyte_generated.bend as P3_VY
import ../obj/vbrt.bend as P3_VR
import ../obj/vbitc.bend as P3_VBC
import ../../spec/bitfields.bend as P3_Bits
import ../../spec/bit_packing.bend as P3_Bp
import ../obj/vrej.bend as P3_VRJ
import ../obj/vnest.bend as P3_VN
import ../obj/dk.bend as P3_DK
import ../../proofs/decode_shape.bend as P3_DS
import ../../proofs/decode_facts.bend as P3_DF
import ../obj/var_bitc_PendingAttestation_generated.bend as P3_DC
import ../obj/var_bitc_PendingAttestation_rej_generated.bend as P3_PRV
import ../../src/buffer.bend as P4_B
import ../../src/obj.bend as P4_O
import ../slop/validity/fulu_PendingAttestation_bitops_bits2048_generated.bend as P4_PRV
import ../../src/buffer.bend as P5_B
import ../../src/obj.bend as P5_O
import ../slop/validity/fulu_PendingAttestation_decode_checked_generated.bend as P5_PRV
import ../../src/buffer.bend as P6_B
import ../../src/obj.bend as P6_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_bad_aggregation_bits_nodelim_generated.bend as P6_PRV
import ../../src/buffer.bend as P7_B
import ../../src/obj.bend as P7_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_bad_aggregation_bits_over_generated.bend as P7_PRV
import ../../src/buffer.bend as P8_B
import ../../src/obj.bend as P8_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_bad_off_minus_generated.bend as P8_PRV
import ../../src/buffer.bend as P9_B
import ../../src/obj.bend as P9_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_bad_off_plus_generated.bend as P9_PRV
import ../../src/buffer.bend as P10_B
import ../../src/obj.bend as P10_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_ok_aggregation_bits_n1_generated.bend as P10_PRV
import ../../src/buffer.bend as P11_B
import ../../src/obj.bend as P11_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_ok_default_generated.bend as P11_PRV
import ../../src/buffer.bend as P12_B
import ../../src/obj.bend as P12_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_ok_fixed_generated.bend as P12_PRV
import ../../src/buffer.bend as P13_B
import ../../src/obj.bend as P13_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_ok_wide_generated.bend as P13_PRV
import ../../src/buffer.bend as P14_B
import ../../src/obj.bend as P14_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_rt_fixed_generated.bend as P14_PRV
import ../../src/buffer.bend as P15_B
import ../../src/obj.bend as P15_O
import ../slop/validity/fulu_PendingAttestation_decode_literal_rt_wide_generated.bend as P15_PRV
import ../../src/buffer.bend as P16_B
import ../../src/obj.bend as P16_O
import ../obj/decode_window_library_generated.bend as P16_DWL
import ../slop/offsets/PendingAttestation_generated.bend as P16_PRV

# GENERATED by object_api_facade_proofs (codegen). Do not edit.
# FuluPendingAttestation (PendingAttestation): its decode_ssz laws in the object API's terms, each discharged by its proving law.

def FuluPendingAttestation__decode_first_offset__PendingAttestation_decode_first_offset(buf: P0_B.Buf, +off: U32, +len: U32, b2: P0_B.Buf, +o0: U32, hlen: {U32.is_le(148, len) == True{} : Bool}, e: {P0_B.read32(buf, (off + 0 : U32)) == (b2, o0) : P0_B.Buf & U32}, hne: {U32.is_eq(o0, 148) == False{} : Bool}) -> {FuluPendingAttestation_r.PendingAttestation_ok(buf, off, len) == (b2, False{}) : P0_B.Buf & Bool}:
  P0_PRV.PendingAttestation_decode_first_offset(buf, off, len, b2, o0, hlen, e, hne)

def FuluPendingAttestation__ok_eval__ok_eval(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}) -> {FuluPendingAttestation_r.PendingAttestation_ok(P1_PRV.BF(t, n), 0, n) == (P1_PRV.BF(t, n), P1_PRV.CHK(t, n)) : P1_B.Buf & Bool}:
  P1_PRV.ok_eval(d, t, n, pf, hd, hn)

def FuluPendingAttestation__decode_accept__decode_accept(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> {FuluPendingAttestation_r.PendingAttestation_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), Some{P1_PRV.OBJ(t, n)}) : P1_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P1_PRV.decode_accept(d, t, n, pf, hd, hn, hchk)

def FuluPendingAttestation__decode_spec__decode_spec(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == True{} : Bool}) -> P1_Decoding.decodes(P1_Spec.PendingAttestation(), P1_PRV.VW(t, n), P1_PRV.VAL(t, n)):
  P1_PRV.decode_spec(d, t, n, pf, hd, hn, hchk)

def FuluPendingAttestation__decode_unique__decode_unique(+d: Nat, +t: P2_F.array__Tree<U32>, +n: U32, +pf: {P2_F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P2_A.quad(P2_VB.pw(d))) == True{} : Bool}, +hchk: {P2_DC.CHK(t, n) == True{} : Bool}, +v: P2_S.Value, spec: P2_Decoding.decodes(P2_Spec.PendingAttestation(), P2_DC.VW(t, n), v)) -> {v == P2_DC.VAL(t, n) : P2_S.Value}:
  P2_PRV.decode_unique(d, t, n, pf, hd, hn, hchk, v, spec)

def FuluPendingAttestation__decode_reject__decode_reject(+d: Nat, +t: P3_FD.array__Tree<U32>, +n: U32, +pf: {P3_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P3_A.quad(P3_VB.pw(d))) == True{} : Bool}, +hchk: {P3_DC.CHK(t, n) == False{} : Bool}) -> P3_Decoding.outside_image(P3_Spec.PendingAttestation(), P3_DC.VW(t, n)):
  P3_PRV.decode_reject(d, t, n, pf, hd, hn, hchk)

def FuluPendingAttestation__decode_none__decode_none(+d: Nat, +t: P1_FD.array__Tree<U32>, +n: U32, +pf: {P1_FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), P1_A.quad(P1_VB.pw(d))) == True{} : Bool}, +hchk: {P1_PRV.CHK(t, n) == False{} : Bool}) -> {FuluPendingAttestation_r.PendingAttestation_decode(P1_PRV.BF(t, n), n) == (P1_PRV.BF(t, n), None{}) : P1_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P1_PRV.decode_none(d, t, n, pf, hd, hn, hchk)

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vbits_clear_0() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(0, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967294), 1, 4294967295), 0} : P4_O.Bits}:
  P4_PRV.PendingAttestation_decode_vbits_clear_0()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vbits_clear_9() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(9, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294966783), 1, 4294967295), 9} : P4_O.Bits}:
  P4_PRV.PendingAttestation_decode_vbits_clear_9()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vbits_clear_33() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(33, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967293), 33} : P4_O.Bits}:
  P4_PRV.PendingAttestation_decode_vbits_clear_33()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vbits_clear_40() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(40, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967039), 40} : P4_O.Bits}:
  P4_PRV.PendingAttestation_decode_vbits_clear_40()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vbits_clear_63() -> {Pair.snd(P4_B.Buf, P4_O.Bits, P4_O.bits_clear(63, (P4_B.empty(), P4_O.Words{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 4294967295), 64}))) == P4_O.Bits{Array.set(U32, Array.set(U32, Array.new(U32, 1n, 0), 0, 4294967295), 1, 2147483647), 63} : P4_O.Bits}:
  P4_PRV.PendingAttestation_decode_vbits_clear_63()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_limit() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_dchw(4294967265, 4294967265, (P5_B.empty(), 1073741824))) == None{} : Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_limit()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_nmax_wrap(buf: P5_B.Buf) -> {FuluPendingAttestation_r.PendingAttestation_dchw(4294967295, 4294967295, (buf, 0)) == (buf, None{}) : P5_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_nmax_wrap(buf)

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_nmax_above(buf: P5_B.Buf) -> {FuluPendingAttestation_r.PendingAttestation_dchw(4294967265, 4294967295, (buf, 1073741824)) == (buf, None{}) : P5_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_nmax_above(buf)

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_nmax_at(buf: P5_B.Buf) -> {FuluPendingAttestation_r.PendingAttestation_dchw(4294967264, 4294967264, (buf, 1073741816)) == FuluPendingAttestation_r.PendingAttestation_dgo(True{}, buf, 4294967264) : P5_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_nmax_at(buf)

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_at_2pow31(buf: P5_B.Buf) -> {FuluPendingAttestation_r.PendingAttestation_dchw(2147483648, 2147483648, (buf, 536870912)) == FuluPendingAttestation_r.PendingAttestation_dgo(True{}, buf, 2147483648) : P5_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_at_2pow31(buf)

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_accept() -> {P5_PRV.is_some(Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_dchw(149, 149, (P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 38))), Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode_checked(P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 149))) == (True{}, True{}) : Bool & Bool}:
  P5_PRV.PendingAttestation_decode_vchecked_accept()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_window() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_dchw(149, 148, (P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 38))) == None{} : Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_window()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_storage() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_dchw(149, 149, (P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 37))) == None{} : Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_storage()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_short() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode_checked(P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 148}, 149)) == None{} : Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_short()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_real() -> {Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode_checked(P5_B.Buf{Array.set(U32, Array.new(U32, 0n, 0), 0, 148), 149}, 149)) == None{} : Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_real()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_budget_agree(buf: P5_B.Buf, +size: U32, +budget: U32, +h: {Bool.and(U32.is_lt(FuluPendingAttestation_r.PendingAttestation_dcost(size), 4294967295), U32.is_le(FuluPendingAttestation_r.PendingAttestation_dcost(size), budget)) == True{} : Bool}) -> {FuluPendingAttestation_r.PendingAttestation_decode_checked_budget(buf, size, budget) == FuluPendingAttestation_r.PendingAttestation_decode_checked(buf, size) : P5_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P5_PRV.PendingAttestation_decode_vchecked_budget_agree(buf, size, budget, h)

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vchecked_budget_accept() -> {P5_PRV.is_some(Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode_checked_budget(P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 149, 4294967295)), Pair.snd(P5_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode_checked(P5_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 149))) == (True{}, True{}) : Bool & Bool}:
  P5_PRV.PendingAttestation_decode_vchecked_budget_accept()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_bad_aggregation_bits_nodelim() -> {P6_PRV.some1(Pair.snd(P6_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P6_B.Buf{Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 149}, 149))) == False{} : Bool}:
  P6_PRV.PendingAttestation_decode_vlit_bad_aggregation_bits_nodelim()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_bad_aggregation_bits_over() -> {P7_PRV.some1(Pair.snd(P7_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P7_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 7n, 0), 0, 148), 101, 2), 405}, 405))) == False{} : Bool}:
  P7_PRV.PendingAttestation_decode_vlit_bad_aggregation_bits_over()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_bad_off_minus() -> {P8_PRV.some1(Pair.snd(P8_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P8_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 147), 37, 1), 149}, 149))) == False{} : Bool}:
  P8_PRV.PendingAttestation_decode_vlit_bad_off_minus()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_bad_off_plus() -> {P9_PRV.some1(Pair.snd(P9_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P9_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 149), 37, 1), 150}, 150))) == False{} : Bool}:
  P9_PRV.PendingAttestation_decode_vlit_bad_off_plus()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_ok_aggregation_bits_n1() -> {P10_PRV.some1(Pair.snd(P10_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P10_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 3), 149}, 149))) == True{} : Bool}:
  P10_PRV.PendingAttestation_decode_vlit_ok_aggregation_bits_n1()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_ok_default() -> {P11_PRV.some1(Pair.snd(P11_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P11_B.Buf{Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 37, 1), 149}, 149))) == True{} : Bool}:
  P11_PRV.PendingAttestation_decode_vlit_ok_default()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_ok_fixed() -> {P12_PRV.some1(Pair.snd(P12_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P12_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 1, 4), 2, 5), 3, 6), 4, 7), 5, 8), 6, 9), 7, 10), 8, 11), 9, 12), 10, 13), 11, 14), 12, 15), 13, 16), 14, 17), 15, 18), 16, 19), 17, 20), 18, 21), 19, 22), 20, 23), 21, 24), 22, 25), 23, 26), 24, 27), 25, 28), 26, 29), 27, 30), 28, 31), 29, 32), 30, 33), 31, 34), 32, 35), 33, 36), 34, 37), 35, 38), 36, 39), 37, 1), 149}, 149))) == True{} : Bool}:
  P12_PRV.PendingAttestation_decode_vlit_ok_fixed()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_ok_wide() -> {P13_PRV.some1(Pair.snd(P13_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P13_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 1, 4), 2, 5), 3, 6), 4, 7), 5, 8), 6, 9), 7, 10), 8, 11), 9, 12), 10, 13), 11, 14), 12, 15), 13, 16), 14, 17), 15, 18), 16, 19), 17, 20), 18, 21), 19, 22), 20, 23), 21, 24), 22, 25), 23, 26), 24, 27), 25, 28), 26, 29), 27, 30), 28, 31), 29, 32), 30, 33), 31, 34), 32, 35), 33, 36), 34, 37), 35, 38), 36, 39), 37, 53), 149}, 149))) == True{} : Bool}:
  P13_PRV.PendingAttestation_decode_vlit_ok_wide()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_rt_fixed() -> {P14_PRV.rtc38(P14_PRV.rt(Pair.snd(P14_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P14_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 1, 4), 2, 5), 3, 6), 4, 7), 5, 8), 6, 9), 7, 10), 8, 11), 9, 12), 10, 13), 11, 14), 12, 15), 13, 16), 14, 17), 15, 18), 16, 19), 17, 20), 18, 21), 19, 22), 20, 23), 21, 24), 22, 25), 23, 26), 24, 27), 25, 28), 26, 29), 27, 30), 28, 31), 29, 32), 30, 33), 31, 34), 32, 35), 33, 36), 34, 37), 35, 38), 36, 39), 37, 1), 149}, 149)))) == (149, (148, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, 1)))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))}:
  P14_PRV.PendingAttestation_decode_vlit_rt_fixed()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_vlit_rt_wide() -> {P15_PRV.rtc38(P15_PRV.rt(Pair.snd(P15_B.Buf, Maybe<&1, FuluPendingAttestation_d.PendingAttestation>, FuluPendingAttestation_r.PendingAttestation_decode(P15_B.Buf{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 6n, 0), 0, 148), 1, 4), 2, 5), 3, 6), 4, 7), 5, 8), 6, 9), 7, 10), 8, 11), 9, 12), 10, 13), 11, 14), 12, 15), 13, 16), 14, 17), 15, 18), 16, 19), 17, 20), 18, 21), 19, 22), 20, 23), 21, 24), 22, 25), 23, 26), 24, 27), 25, 28), 26, 29), 27, 30), 28, 31), 29, 32), 30, 33), 31, 34), 32, 35), 33, 36), 34, 37), 35, 38), 36, 39), 37, 53), 149}, 149)))) == (149, (148, (4, (5, (6, (7, (8, (9, (10, (11, (12, (13, (14, (15, (16, (17, (18, (19, (20, (21, (22, (23, (24, (25, (26, (27, (28, (29, (30, (31, (32, (33, (34, (35, (36, (37, (38, (39, 53)))))))))))))))))))))))))))))))))))))) : U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32 & (U32))))))))))))))))))))))))))))))))))))))}:
  P15_PRV.PendingAttestation_decode_vlit_rt_wide()

def FuluPendingAttestation__decode_offsets__PendingAttestation_decode_build(buf: P16_B.Buf, +size: U32, b2: P16_B.Buf, e: {FuluPendingAttestation_r.PendingAttestation_ok(buf, 0, size) == (b2, True{}) : P16_B.Buf & Bool}, hwin: {U32.is_le(size, P16_DWL.bsz(buf)) == True{} : Bool}) -> {FuluPendingAttestation_r.PendingAttestation_decode(buf, size) == FuluPendingAttestation_r.PendingAttestation_some(FuluPendingAttestation_r.PendingAttestation_build(b2, size)) : P16_B.Buf & Maybe<&1, FuluPendingAttestation_d.PendingAttestation>}:
  P16_PRV.PendingAttestation_decode_build(buf, size, b2, e, hwin)

