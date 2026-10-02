import Base
import ../src/buffer.bend as B
import ../src/obj.bend as O
import ../types/Fulu_bitvector_4_def_generated.bend as Fulu_bitvector_4_d
import ../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../types/uint64_decode_ssz_generated.bend as uint64_r
import ../types/FuluBytes32_decode_ssz_generated.bend as FuluBytes32_r
import ../types/FuluFork_def_generated.bend as FuluFork_d
import ../types/FuluFork_decode_ssz_generated.bend as FuluFork_r
import ../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../types/FuluBeaconBlockHeader_decode_ssz_generated.bend as FuluBeaconBlockHeader_r
import ../types/Fulu_vec_bytevec_32_8192_decode_ssz_generated.bend as Fulu_vec_bytevec_32_8192_r
import ../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../types/FuluEth1Data_decode_ssz_generated.bend as FuluEth1Data_r
import ../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../types/FuluCheckpoint_decode_ssz_generated.bend as FuluCheckpoint_r
import ../types/FuluSyncCommittee_def_generated.bend as FuluSyncCommittee_d
import ../types/FuluSyncCommittee_decode_ssz_generated.bend as FuluSyncCommittee_r
import ../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../types/FuluExecutionPayloadHeader_decode_ssz_generated.bend as FuluExecutionPayloadHeader_r
import ../types/Fulu_list_bytevec_32_16777216_decode_ssz_generated.bend as Fulu_list_bytevec_32_16777216_r
import ../types/Fulu_list_Eth1Data_2048_def_generated.bend as Fulu_list_Eth1Data_2048_d
import ../types/Fulu_list_Eth1Data_2048_decode_ssz_generated.bend as Fulu_list_Eth1Data_2048_r
import ../types/Fulu_list_Validator_1099511627776_def_generated.bend as Fulu_list_Validator_1099511627776_d
import ../types/Fulu_list_Validator_1099511627776_decode_ssz_generated.bend as Fulu_list_Validator_1099511627776_r
import ../types/Fulu_list_uint64_1099511627776_decode_ssz_generated.bend as Fulu_list_uint64_1099511627776_r
import ../types/Fulu_vec_bytevec_32_65536_decode_ssz_generated.bend as Fulu_vec_bytevec_32_65536_r
import ../types/Fulu_vec_uint64_8192_decode_ssz_generated.bend as Fulu_vec_uint64_8192_r
import ../types/Fulu_list_uint8_1099511627776_decode_ssz_generated.bend as Fulu_list_uint8_1099511627776_r
import ../types/Fulu_bitvector_4_decode_ssz_generated.bend as Fulu_bitvector_4_r
import ../types/Fulu_list_HistoricalSummary_16777216_def_generated.bend as Fulu_list_HistoricalSummary_16777216_d
import ../types/Fulu_list_HistoricalSummary_16777216_decode_ssz_generated.bend as Fulu_list_HistoricalSummary_16777216_r
import ../types/Fulu_list_PendingDeposit_134217728_def_generated.bend as Fulu_list_PendingDeposit_134217728_d
import ../types/Fulu_list_PendingDeposit_134217728_decode_ssz_generated.bend as Fulu_list_PendingDeposit_134217728_r
import ../types/Fulu_list_PendingPartialWithdrawal_134217728_def_generated.bend as Fulu_list_PendingPartialWithdrawal_134217728_d
import ../types/Fulu_list_PendingPartialWithdrawal_134217728_decode_ssz_generated.bend as Fulu_list_PendingPartialWithdrawal_134217728_r
import ../types/Fulu_list_PendingConsolidation_262144_def_generated.bend as Fulu_list_PendingConsolidation_262144_d
import ../types/Fulu_list_PendingConsolidation_262144_decode_ssz_generated.bend as Fulu_list_PendingConsolidation_262144_r
import ../types/Fulu_vec_uint64_64_decode_ssz_generated.bend as Fulu_vec_uint64_64_r
import ../types/FuluBeaconState_def_generated.bend as FuluBeaconState_d
import ../types/FuluBeaconState_decode_ssz_generated.bend as FuluBeaconState_r
import ../types/schema.bend as S
import ../types/primitive.bend as P
import ../proofs/compact/found_generated.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../spec/primitives.bend as SP
import ../spec/layout.bend as Layout
import ../spec/codec.bend as Codec
import ../spec/decoding_relation.bend as Decoding
import ../spec/nat_bytes.bend as N
import ../spec/fulu_schemas.bend as Spec
import ../proofs/obj/spec_fixed.bend as F
import ../proofs/obj/vspec.bend as VS
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vu32.bend as VU
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vfix.bend as VF
import ../proofs/obj/var_fix_types_generated.bend as VT
import ../proofs/obj/spec_bits_generated.bend as FB
import ../proofs/obj/vfits.bend as VFT
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/vbitl.bend as VBL
import ../proofs/obj/vbyte_generated.bend as VY
import ../proofs/obj/vbrt.bend as VR
import ../proofs/obj/vbitc.bend as VBC
import ../proofs/obj/vrej.bend as VRJ
import ../proofs/obj/vnest.bend as VN
import ../proofs/obj/dk.bend as DK
import ../spec/bitfields.bend as Bits
import ../spec/bit_packing.bend as Bp
import ../proofs/obj/vua_win.bend as UW
import ../proofs/obj/vua_ct.bend as UCT
import ../src/primitives.bend as I
import ../proofs/obj/vua_rd.bend as UR
import ../proofs/obj/vua_fix_generated.bend as VTX
import ../proofs/obj/vua_lay.bend as LY
import ../proofs/obj/vmv_generated.bend as VMV
import ../proofs/obj/vdig.bend as VG
import ../proofs/obj/vmr_generated.bend as VMR
import ../proofs/obj/vmul_generated.bend as VM
import ../proofs/obj/vrc_generated.bend as VRC
import ../proofs/decode_shape.bend as DS
import ../proofs/decode_facts.bend as DF
import ../proofs/obj/var_winx_l16777216_b32_generated.bend as CH0
import ../proofs/obj/var_winx_l2048_Eth1Data_generated.bend as CH1
import ../proofs/obj/var_winx_l1099511627776_Validator_generated.bend as CH2
import ../proofs/obj/var_winx_l1099511627776_u64_generated.bend as CH3
import ../proofs/obj/var_winx_l1099511627776_u8_generated.bend as CH4
import ../proofs/obj/var_winx_l1099511627776_u8_generated.bend as CH5
import ../proofs/obj/var_winx_l1099511627776_u64_generated.bend as CH6
import ../proofs/obj/var_bytesx_ExecutionPayloadHeader_generated.bend as CH7
import ../proofs/obj/var_winx_l16777216_HistoricalSummary_generated.bend as CH8
import ../proofs/obj/var_winx_l134217728_PendingDeposit_generated.bend as CH9
import ../proofs/obj/var_winx_l134217728_PendingPartialWithdrawal_generated.bend as CH10
import ../proofs/obj/var_winx_l262144_PendingConsolidation_generated.bend as CH11
import ../spec/schema.bend as SS
import ../proofs/obj/vadd.bend as VA
import ../proofs/obj/schema_shapes_generated.bend as SH
import ../proofs/obj/vfx_BeaconBlockHeader_generated.bend as FX_BeaconBlockHeader
import ../proofs/obj/vfx_Checkpoint_generated.bend as FX_Checkpoint
import ../proofs/obj/vfx_Eth1Data_generated.bend as FX_Eth1Data
import ../proofs/obj/vfx_Fork_generated.bend as FX_Fork
import ../proofs/obj/vfx_SyncCommittee_generated.bend as FX_SyncCommittee
import ../proofs/obj/vfx_b32_generated.bend as FX_b32
import ../proofs/obj/vfx_bv4_generated.bend as FX_bv4
import ../proofs/obj/vfx_u64_generated.bend as FX_u64
import ../proofs/obj/vfx_v64_u64_generated.bend as FX_v64_u64
import ../proofs/obj/vfx_v65536_b32_generated.bend as FX_v65536_b32
import ../proofs/obj/vfx_v8192_b32_generated.bend as FX_v8192_b32
import ../proofs/obj/vfx_v8192_u64_generated.bend as FX_v8192_u64
import ../proofs/obj/vbig.bend as VBG
import ../proofs/obj/vua.bend as UA
import ../proofs/obj/arr_copy_generated.bend as AC
import ../proofs/obj/var_winx_BeaconState_generated.bend as EW
import ./e2e_symdec_lib_generated.bend as SL

# GENERATED by beacon_state_symbolic_witness (codegen). Do not edit.
# FuluBeaconState: the check of the justification bits and of the payload header window over the tree of any word list that holds the skeleton's words

def add0(+y: Nat) -> {Nat.add(0n, y) == y : Nat}: {==}

def bits_gen(+d: Nat, +sl: List<&2, U32>, +x: Nat, +hx: {x == U32.to_nat(2687256) : Nat}, +fb: {FD.flat__nthc(sl, U32.to_nat(U32.shrn(2687256, 2n))) == 0 : U32}, +h: {Nat.is_lt(U32.to_nat(U32.shrn(2687256, 2n)), FD.spec_common__pow2(d)) == True{} : Bool})
    -> {FX_bv4.CHK(AC.segt(d, 0n, sl), x) == True{} : Bool}:
  Equal.trans(Bool, FX_bv4.CHK(AC.segt(d, 0n, sl), x), FX_bv4.CHKv(VR.VX(AC.segt(d, 0n, sl), 2687256)), True{}, Equal.cong(U32, Bool, z => FX_bv4.CHKv(z), FX_bv4.BX(AC.segt(d, 0n, sl), x), VR.VX(AC.segt(d, 0n, sl), 2687256), Equal.sym(U32, VR.VX(AC.segt(d, 0n, sl), 2687256), FX_bv4.BX(AC.segt(d, 0n, sl), x), FX_bv4.vx_bx(AC.segt(d, 0n, sl), 2687256, x, Equal.sym(Nat, x, U32.to_nat(2687256), hx)))),
    Equal.trans(Bool, FX_bv4.CHKv(VR.VX(AC.segt(d, 0n, sl), 2687256)), FX_bv4.CHKv(B.byte_sel(U32.and(2687256, 3), FD.flat__nthc(sl, U32.to_nat(U32.shrn(2687256, 2n))))), True{},
      Equal.cong(U32, Bool, z => FX_bv4.CHKv(B.byte_sel(U32.and(2687256, 3), z)), VB.slot(AC.segt(d, 0n, sl), VR.QX(2687256)), FD.flat__nthc(sl, U32.to_nat(U32.shrn(2687256, 2n))), SL.slot_seg(d, sl, VR.QX(2687256), h)),
      Equal.trans(Bool, FX_bv4.CHKv(B.byte_sel(U32.and(2687256, 3), FD.flat__nthc(sl, U32.to_nat(U32.shrn(2687256, 2n))))), FX_bv4.CHKv(B.byte_sel(U32.and(2687256, 3), 0)), True{},
        Equal.cong(U32, Bool, z => FX_bv4.CHKv(B.byte_sel(U32.and(2687256, 3), z)), FD.flat__nthc(sl, U32.to_nat(U32.shrn(2687256, 2n))), 0, fb), {==})))

def bits_true(+sl: List<&2, U32>, +fb: {FD.flat__nthc(sl, U32.to_nat(U32.shrn(2687256, 2n))) == 0 : U32}, +h: {Nat.is_lt(U32.to_nat(U32.shrn(2687256, 2n)), FD.spec_common__pow2(20n)) == True{} : Bool})
    -> {FX_bv4.CHK(AC.segt(20n, 0n, sl), Nat.add(0n, U32.to_nat(2687256))) == True{} : Bool}:
  bits_gen(20n, sl, Nat.add(0n, U32.to_nat(2687256)), add0(U32.to_nat(2687256)), fb, h)

def CHKhS(+len: U32, +p: U32) -> Bool: CH7.chk3(U32.is_le(584, len), U32.is_eq(p, 584), CH7.BLW(U32.sub(len, p)))

def spo_unf(+t: FD.array__Tree<U32>, +y: Nat) -> {CH7.SPOw(t, y) == UR.RWN(t, 436n+y) : U32}: {==}

def pos_rel(+a: U32, +cc: U32, +y: Nat, +hy: {y == U32.to_nat(a) : Nat}, +hk: {U32.to_nat(cc) == 436n : Nat}, +h: {Nat.is_lt(Nat.add(436n, U32.to_nat(a)), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {436n+y == U32.to_nat(U32.add(a, cc)) : Nat}:
  Equal.trans(Nat, 436n+y, Nat.add(U32.to_nat(cc), U32.to_nat(a)), U32.to_nat(U32.add(a, cc)),
    Equal.trans(Nat, 436n+y, Nat.add(436n, U32.to_nat(a)), Nat.add(U32.to_nat(cc), U32.to_nat(a)), Equal.cong(Nat, Nat, z => 436n+z, y, U32.to_nat(a), hy),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(a)), 436n, U32.to_nat(cc), Equal.sym(Nat, U32.to_nat(cc), 436n, hk))),
    Equal.sym(Nat, U32.to_nat(U32.add(a, cc)), Nat.add(U32.to_nat(cc), U32.to_nat(a)), VB.add_lt32k(a, cc, 436n, U32.to_nat(a), {==}, hk, h)))

def spo_gen(+sl: List<&2, U32>, +y: Nat, +hy: {y == U32.to_nat(2737225) : Nat}, +flo: {FD.flat__nthc(sl, U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))) == 149504 : U32}, +fhi: {FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))) == 0 : U32},
    +h: {Nat.is_lt(1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)), FD.spec_common__pow2(20n)) == True{} : Bool}, +hadd: {Nat.is_lt(Nat.add(436n, U32.to_nat(2737225)), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {CH7.SPOw(AC.segt(20n, 0n, sl), y) == 584 : U32}:
  Equal.trans(U32, CH7.SPOw(AC.segt(20n, 0n, sl), y), UR.RWN(AC.segt(20n, 0n, sl), 436n+y), 584, spo_unf(AC.segt(20n, 0n, sl), y),
    Equal.trans(U32, UR.RWN(AC.segt(20n, 0n, sl), 436n+y), UR.RWN(AC.segt(20n, 0n, sl), U32.to_nat(U32.add(2737225, 436))), 584,
      Equal.cong(Nat, U32, z => UR.RWN(AC.segt(20n, 0n, sl), z), 436n+y, U32.to_nat(U32.add(2737225, 436)), pos_rel(2737225, 436, y, hy, {==}, hadd)),
      Equal.trans(U32, UR.RWN(AC.segt(20n, 0n, sl), U32.to_nat(U32.add(2737225, 436))), UA.jn(1n, FD.flat__nthc(sl, U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))), FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)))), 584,
        Equal.trans(U32, UR.RWN(AC.segt(20n, 0n, sl), U32.to_nat(U32.add(2737225, 436))), UR.RWN(AC.segt(20n, 0n, sl), Nat.add(0n, U32.to_nat(U32.add(2737225, 436)))), UA.jn(1n, FD.flat__nthc(sl, U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))), FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)))),
          Equal.cong(Nat, U32, z => UR.RWN(AC.segt(20n, 0n, sl), z), U32.to_nat(U32.add(2737225, 436)), Nat.add(0n, U32.to_nat(U32.add(2737225, 436))), Equal.sym(Nat, Nat.add(0n, U32.to_nat(U32.add(2737225, 436))), U32.to_nat(U32.add(2737225, 436)), add0(U32.to_nat(U32.add(2737225, 436))))),
          SL.rd_off_u(20n, sl, 0n, U32.add(2737225, 436), 1n, {==}, {==}, {==}, h)),
        Equal.trans(U32, UA.jn(1n, FD.flat__nthc(sl, U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))), FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)))), UA.jn(1n, 149504, FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)))), 584, Equal.cong(U32, U32, z => UA.jn(1n, z, FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)))), FD.flat__nthc(sl, U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))), 149504, flo),
          Equal.trans(U32, UA.jn(1n, 149504, FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)))), UA.jn(1n, 149504, 0), 584, Equal.cong(U32, U32, z => UA.jn(1n, 149504, z), FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))), 0, fhi), {==})))))

def h7_unf(+t: FD.array__Tree<U32>, +x: Nat, +off: U32)
    -> {CH7.CHKw(t, EW.XJ7(t, x), EW.FJ7(off, t, x), EW.LJ7(t, x)) == CHKhS(U32.sub(EW.O8(t, x), EW.O7(t, x)), CH7.SPOw(t, Nat.add(U32.to_nat(EW.O7(t, x)), x))) : Bool}: {==}

def h7_true(+sl: List<&2, U32>, +e7: {EW.O7(AC.segt(20n, 0n, sl), 0n) == 2737225 : U32}, +e8: {EW.O8(AC.segt(20n, 0n, sl), 0n) == 2737812 : U32}, +flo: {FD.flat__nthc(sl, U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))) == 149504 : U32}, +fhi: {FD.flat__nthc(sl, 1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n))) == 0 : U32},
    +h: {Nat.is_lt(1n+U32.to_nat(U32.shrn(U32.add(2737225, 436), 2n)), FD.spec_common__pow2(20n)) == True{} : Bool}, +hadd: {Nat.is_lt(Nat.add(436n, U32.to_nat(2737225)), FD.spec_common__pow2(32n)) == True{} : Bool})
    -> {CH7.CHKw(AC.segt(20n, 0n, sl), EW.XJ7(AC.segt(20n, 0n, sl), 0n), EW.FJ7(0, AC.segt(20n, 0n, sl), 0n), EW.LJ7(AC.segt(20n, 0n, sl), 0n)) == True{} : Bool}:
  Equal.trans(Bool, CH7.CHKw(AC.segt(20n, 0n, sl), EW.XJ7(AC.segt(20n, 0n, sl), 0n), EW.FJ7(0, AC.segt(20n, 0n, sl), 0n), EW.LJ7(AC.segt(20n, 0n, sl), 0n)), CHKhS(U32.sub(EW.O8(AC.segt(20n, 0n, sl), 0n), EW.O7(AC.segt(20n, 0n, sl), 0n)), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(EW.O7(AC.segt(20n, 0n, sl), 0n)), 0n))), True{}, h7_unf(AC.segt(20n, 0n, sl), 0n, 0),
    Equal.trans(Bool, CHKhS(U32.sub(EW.O8(AC.segt(20n, 0n, sl), 0n), EW.O7(AC.segt(20n, 0n, sl), 0n)), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(EW.O7(AC.segt(20n, 0n, sl), 0n)), 0n))), CHKhS(U32.sub(EW.O8(AC.segt(20n, 0n, sl), 0n), 2737225), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(2737225), 0n))), True{},
      Equal.cong(U32, Bool, z => CHKhS(U32.sub(EW.O8(AC.segt(20n, 0n, sl), 0n), z), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(z), 0n))), EW.O7(AC.segt(20n, 0n, sl), 0n), 2737225, e7),
      Equal.trans(Bool, CHKhS(U32.sub(EW.O8(AC.segt(20n, 0n, sl), 0n), 2737225), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(2737225), 0n))), CHKhS(U32.sub(2737812, 2737225), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(2737225), 0n))), True{},
        Equal.cong(U32, Bool, z => CHKhS(U32.sub(z, 2737225), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(2737225), 0n))), EW.O8(AC.segt(20n, 0n, sl), 0n), 2737812, e8),
        Equal.trans(Bool, CHKhS(U32.sub(2737812, 2737225), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(2737225), 0n))), CHKhS(U32.sub(2737812, 2737225), 584), True{},
          Equal.cong(U32, Bool, z => CHKhS(U32.sub(2737812, 2737225), z), CH7.SPOw(AC.segt(20n, 0n, sl), Nat.add(U32.to_nat(2737225), 0n)), 584, spo_gen(sl, Nat.add(U32.to_nat(2737225), 0n), FD.nat__add_zero(U32.to_nat(2737225)), flo, fhi, h, hadd)), {==}))))
