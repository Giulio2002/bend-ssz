import Base
import ./FuluBeaconBlock_e2e_generated.bend as BR
import ./FuluBeaconBlock_e2e_root_generated.bend as RB
import ./e2e_bbatt.bend as AT5
import ./e2e_bbsl.bend as AS4
import ./e2e_bl48.bend as K11
import ./e2e_dl_l16_SignedBLSToExecutionChange.bend as BC10
import ./e2e_dl_l16_SignedVoluntaryExit.bend as VE7
import ./e2e_dl_l16_WithdrawalRequest.bend as DQ1
import ./e2e_dl_l2_ConsolidationRequest.bend as DQ2
import ./e2e_dl_l8192_DepositRequest.bend as DQ0
import ./e2e_epr.bend as RC9
import ./e2e_ml_l16_Deposit.bend as DP6
import ./e2e_ml_l16_ProposerSlashing.bend as PS3
import ./e2e_rec_BeaconBlock.bend as RK
import ./e2e_rl_l16_SignedBLSToExecutionChange.bend as RV10
import ./e2e_rl_l16_SignedVoluntaryExit.bend as RV7
import ./e2e_rl_l16_WithdrawalRequest.bend as RQ1
import ./e2e_rl_l2_ConsolidationRequest.bend as RQ2
import ./e2e_rl_l8192_DepositRequest.bend as RQ0
import ./e2e_support.bend as E
import ../proofs/compact/found.bend as FD
import ../proofs/obj/root_types_light.bend as RT
import ../proofs/obj/schema_shapes.bend as W_proofs_obj_schema_shapes
import ../proofs/obj/words_obj_light.bend as WO
import ../spec/fulu_schemas.bend as Spec
import ../src/buffer.bend as B
import ../src/digest.bend as D
import ../src/model.bend as API
import ../src/obj.bend as O
import ../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ../types/FuluBLSToExecutionChange_def_generated.bend as FuluBLSToExecutionChange_d
import ../types/FuluBeaconBlockBody_def_generated.bend as FuluBeaconBlockBody_d
import ../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../types/FuluBeaconBlock_def_generated.bend as FuluBeaconBlock_d
import ../types/FuluBeaconBlock_encode_ssz_generated.bend as FuluBeaconBlock_e
import ../types/FuluBeaconBlock_hashtreeroot_generated.bend as FuluBeaconBlock_h
import ../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../types/FuluConsolidationRequest_def_generated.bend as FuluConsolidationRequest_d
import ../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../types/FuluDeposit_def_generated.bend as FuluDeposit_d
import ../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../types/FuluExecutionPayload_def_generated.bend as FuluExecutionPayload_d
import ../types/FuluExecutionRequests_def_generated.bend as FuluExecutionRequests_d
import ../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../types/FuluProposerSlashing_def_generated.bend as FuluProposerSlashing_d
import ../types/FuluSignedBLSToExecutionChange_def_generated.bend as FuluSignedBLSToExecutionChange_d
import ../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../types/FuluSignedVoluntaryExit_def_generated.bend as FuluSignedVoluntaryExit_d
import ../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
import ../types/FuluTransaction_def_generated.bend as FuluTransaction_d
import ../types/FuluVoluntaryExit_def_generated.bend as FuluVoluntaryExit_d
import ../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
import ../types/Fulu_bitlist_131072_def_generated.bend as Fulu_bitlist_131072_d
import ../types/Fulu_bitvector_512_def_generated.bend as Fulu_bitvector_512_d
import ../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d
import ../types/Fulu_bytelist_32_def_generated.bend as Fulu_bytelist_32_d
import ../types/Fulu_bytevec_256_def_generated.bend as Fulu_bytevec_256_d
import ../types/Fulu_list_Attestation_8_def_generated.bend as Fulu_list_Attestation_8_d
import ../types/Fulu_list_AttesterSlashing_1_def_generated.bend as Fulu_list_AttesterSlashing_1_d
import ../types/Fulu_list_ConsolidationRequest_2_def_generated.bend as Fulu_list_ConsolidationRequest_2_d
import ../types/Fulu_list_DepositRequest_8192_def_generated.bend as Fulu_list_DepositRequest_8192_d
import ../types/Fulu_list_Deposit_16_def_generated.bend as Fulu_list_Deposit_16_d
import ../types/Fulu_list_ProposerSlashing_16_def_generated.bend as Fulu_list_ProposerSlashing_16_d
import ../types/Fulu_list_SignedBLSToExecutionChange_16_def_generated.bend as Fulu_list_SignedBLSToExecutionChange_16_d
import ../types/Fulu_list_SignedVoluntaryExit_16_def_generated.bend as Fulu_list_SignedVoluntaryExit_16_d
import ../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as Fulu_list_WithdrawalRequest_16_d
import ../types/Fulu_list_Withdrawal_16_def_generated.bend as Fulu_list_Withdrawal_16_d
import ../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Fulu_list_bytelist_1073741824_1048576_d
import ../types/Fulu_list_bytevec_48_4096_def_generated.bend as Fulu_list_bytevec_48_4096_d
import ../types/Fulu_list_uint64_131072_def_generated.bend as Fulu_list_uint64_131072_d
import ../types/Fulu_vec_bytevec_32_33_def_generated.bend as Fulu_vec_bytevec_32_33_d
import ../types/uint256_def_generated.bend as uint256_d
import ../types/uint64_def_generated.bend as uint64_d

# GENERATED by codegen/e2e_witness.py. Do not edit.
# Non-vacuity of the bridges of FuluBeaconBlock that take premises: every premise holds of the default object
# D = BeaconBlock_default() (one def per premise, named after its binder), so the bridge applies to D.

# NE() is the default with one element in every list reachable through containers and boxes
# (the witnesses named _nonempty).
def NE() -> FuluBeaconBlock_d.BeaconBlock:
  FuluBeaconBlock_d.BeaconBlock{uint64_d.u64_default(), uint64_d.u64_default(), FuluBytes32_d.b32_default(), FuluBytes32_d.b32_default(), FuluBeaconBlockBody_d.BeaconBlockBody_bx_wrap(FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{FuluBytes96_d.b96_default(), FuluEth1Data_d.Eth1Data_default(), FuluBytes32_d.b32_default(), Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{ALeaf{FuluProposerSlashing_d.ProposerSlashing_bx_default()}, 1}, Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{ALeaf{FuluAttesterSlashing_d.AttesterSlashing_bx_default()}, 1}, Fulu_list_Attestation_8_d.l8_Attestation_Seq{ALeaf{FuluAttestation_d.Attestation_bx_default()}, 1}, Fulu_list_Deposit_16_d.l16_Deposit_Seq{ALeaf{FuluDeposit_d.Deposit_bx_default()}, 1}, Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{ALeaf{FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()}, 1}}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{FuluSyncAggregate_d.SyncAggregate_bx_default(), FuluExecutionPayload_d.ExecutionPayload_bx_wrap(FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0_default(), FuluExecutionPayload_d.ExecutionPayload_g1{uint64_d.u64_default(), uint64_d.u64_default(), O.words_new(1), uint256_d.u256_default(), FuluBytes32_d.b32_default(), Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{ALeaf{FuluTransaction_d.bl1073741824_bx_default()}, 1}, Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq{ALeaf{FuluWithdrawal_d.Withdrawal_default()}, 1}, uint64_d.u64_default()}, FuluExecutionPayload_d.ExecutionPayload_g2_default()}), Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{ALeaf{FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()}, 1}, O.words_new(48), FuluExecutionRequests_d.ExecutionRequests{Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq{ALeaf{FuluDepositRequest_d.DepositRequest_default()}, 1}, Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq{ALeaf{FuluWithdrawalRequest_d.WithdrawalRequest_default()}, 1}, Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq{ALeaf{FuluConsolidationRequest_d.ConsolidationRequest_default()}, 1}}}})}

def BZ3_0() -> {O.Bits{Array.new(U32, 3n, 0), 0} == O.Bits{FD.array__thaw(U32, FD.array__trep(U32, 3n, 0)), 0} : O.Bits}:
  %FD.array__new(U32, 3n, 0) : {O.Bits{Array.new(U32, 3n, 0), 0} == O.Bits{_, 0} : O.Bits}
  {==}

def WZ0() -> {O.words_new(0) == O.Words{FD.array__thaw(U32, FD.array__trep(U32, 3n, 0)), 0} : O.Words}:
  %FD.array__new(U32, 3n, 0) : {O.words_new(0) == O.Words{_, 0} : O.Words}
  {==}

def WZ1() -> {O.words_new(1) == O.Words{FD.array__thaw(U32, FD.array__trep(U32, 4n, 0)), 1} : O.Words}:
  %FD.array__new(U32, 4n, 0) : {O.words_new(1) == O.Words{_, 1} : O.Words}
  {==}

def WZ1056() -> {O.words_new(1056) == O.Words{FD.array__thaw(U32, FD.array__trep(U32, 9n, 0)), 1056} : O.Words}:
  %FD.array__new(U32, 9n, 0) : {O.words_new(1056) == O.Words{_, 1056} : O.Words}
  {==}

def WZ256() -> {O.words_new(256) == O.Words{FD.array__thaw(U32, FD.array__trep(U32, 7n, 0)), 256} : O.Words}:
  %FD.array__new(U32, 7n, 0) : {O.words_new(256) == O.Words{_, 256} : O.Words}
  {==}

def WZ48() -> {O.words_new(48) == O.Words{FD.array__thaw(U32, FD.array__trep(U32, 5n, 0)), 48} : O.Words}:
  %FD.array__new(U32, 5n, 0) : {O.words_new(48) == O.Words{_, 48} : O.Words}
  {==}

def premise_rep() -> RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_default(), Spec.BeaconBlock()):
  (uint64_d.u64_default(), (uint64_d.u64_default(), (FuluBytes32_d.b32_default(), (FuluBytes32_d.b32_default(), ({==}, ({==}, (FuluBytes96_d.b96_default(), (FuluEth1Data_d.Eth1Data_default(), (FuluBytes32_d.b32_default(), ({==}, (((FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), {==}), (((FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), {==}), (((FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), {==}), (((FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), {==}), (((FD.TLeaf{FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))), {==}), ((FuluSyncAggregate_d.SyncAggregate_default(), {==}), (({==}, (FuluBytes32_d.b32_default(), (FuluBytes20_d.b20_default(), (FuluBytes32_d.b32_default(), (FuluBytes32_d.b32_default(), (FuluBytes32_d.b32_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), (uint256_d.u256_default(), (FuluBytes32_d.b32_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), ({==}, (((FD.array__trep(U32, 7n, 0), (7n, (256, (7n, (32n, (WZ256(), (FD.array__trep_perfect(U32, 7n, 0), ({==}, ({==}, ({==}, ({==}, ({==}, {==})))))))))))), {==}), ((Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, {==}), (((FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), {==}), ((FD.TLeaf{FuluWithdrawal_d.Withdrawal_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))), {==}))))))))))))))))))), (((FD.TLeaf{FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))), {==}), (((FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==})))))), {==}), ({==}, (((FD.TLeaf{FuluDepositRequest_d.DepositRequest_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))), {==}), (((FD.TLeaf{FuluWithdrawalRequest_d.WithdrawalRequest_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))), {==}), ((FD.TLeaf{FuluConsolidationRequest_d.ConsolidationRequest_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))), {==})))))))))))))))))))))))

def premise_hs34() -> PS3.sdt(RT.pj_BeaconBlockBody_3(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))):
  (FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==})))))))

def premise_hs44() -> AS4.sd1(RT.pj_BeaconBlockBody_4(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))):
  (FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==})))))))

def premise_hs54() -> AT5.sd8(RT.pj_BeaconBlockBody_5(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))):
  (FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==})))))))

def premise_hs64() -> DP6.sdt(RT.pj_BeaconBlockBody_6(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))):
  (FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==})))))))

def premise_hs74() -> RV7.sda_l16_SignedVoluntaryExit(RT.pj_BeaconBlockBody_7(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))), 31n):
  (FD.TLeaf{FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()}, (0n, (0, ({==}, ({==}, ({==}, {==}))))))

def premise_hs94() -> RC9.SHS_P(RT.pj_ExecutionPayload_4(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))), RT.pj_ExecutionPayload_10(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))), RT.pj_ExecutionPayload_13(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))), RT.pj_ExecutionPayload_14(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))))):
  ((FD.array__trep(U32, 7n, 0), (7n, (256, (7n, (32n, (WZ256(), (FD.array__trep_perfect(U32, 7n, 0), ({==}, ({==}, ({==}, ({==}, ({==}, {==})))))))))))), (Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, ((FD.TLeaf{RT.MNone{}}, (0n, (0, ({==}, ({==}, ({==}, ({==}, {==}))))))), (FD.TLeaf{FuluWithdrawal_d.Withdrawal_default()}, (0n, (0, ({==}, ({==}, ({==}, {==})))))))))

def premise_hs104() -> RV10.sda_l16_SignedBLSToExecutionChange(RT.pj_BeaconBlockBody_10(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))), 31n):
  (FD.TLeaf{FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()}, (0n, (0, ({==}, ({==}, ({==}, {==}))))))

def premise_hs114() -> K11.sdk48(RT.pj_BeaconBlockBody_11(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))):
  (FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), {==})))))

def premise_hv114() -> {O.unit_ok(48, WO.len(RT.pj_BeaconBlockBody_11(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))) == True{} : Bool}:
  {==}

def premise_ha124() -> RQ0.sda_l8192_DepositRequest(RT.pj_ExecutionRequests_0(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), 31n):
  (FD.TLeaf{FuluDepositRequest_d.DepositRequest_default()}, (0n, (0, ({==}, ({==}, ({==}, {==}))))))

def premise_hb124() -> RQ1.sda_l16_WithdrawalRequest(RT.pj_ExecutionRequests_1(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), 31n):
  (FD.TLeaf{FuluWithdrawalRequest_d.WithdrawalRequest_default()}, (0n, (0, ({==}, ({==}, ({==}, {==}))))))

def premise_hc124() -> RQ2.sda_l2_ConsolidationRequest(RT.pj_ExecutionRequests_2(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), 31n):
  (FD.TLeaf{FuluConsolidationRequest_d.ConsolidationRequest_default()}, (0n, (0, ({==}, ({==}, ({==}, {==}))))))

def premise_hZ() -> RK.SZW(FuluBeaconBlock_d.BeaconBlock_default()):
  (PS3.LLX(RT.pj_BeaconBlockBody_3(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), (AS4.LN1(RT.pj_BeaconBlockBody_4(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), (AT5.LN8(RT.pj_BeaconBlockBody_5(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), (DP6.LLX(RT.pj_BeaconBlockBody_6(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), (VE7.WLL(RT.pj_BeaconBlockBody_7(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), (RC9.EPL(RT.pj_ExecutionPayload_10(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))), RT.pj_ExecutionPayload_13(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))), RT.pj_ExecutionPayload_14(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))))), (BC10.WLL(RT.pj_BeaconBlockBody_10(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))), (U32.to_nat(WO.len(RT.pj_BeaconBlockBody_11(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default()))))), (Nat.add(Nat.add(Nat.add(12n, DQ0.WLL(RT.pj_ExecutionRequests_0(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))))), DQ1.WLL(RT.pj_ExecutionRequests_1(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))))), DQ2.WLL(RT.pj_ExecutionRequests_2(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(FuluBeaconBlock_d.BeaconBlock_default())))))), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))))))))))))

def FuluBeaconBlock_e2e_witness() -> {Some{E.obytes(Pair.snd(FuluBeaconBlock_d.BeaconBlock, B.Buf, FuluBeaconBlock_e.BeaconBlock_encode(FuluBeaconBlock_d.BeaconBlock_default())))} == API.serialize(Spec.BeaconBlock(), RT.v_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_default())) : Maybe<&2, +List<U32>>}:
  BR.FuluBeaconBlock_e2e_encode(FuluBeaconBlock_d.BeaconBlock_default(), premise_rep(), premise_hs34(), premise_hs44(), premise_hs54(), premise_hs64(), premise_hs74(), premise_hs94(), premise_hs104(), premise_hs114(), premise_hv114(), premise_ha124(), premise_hb124(), premise_hc124(), premise_hZ())

def FuluBeaconBlock_e2e_witness_root() -> {Some{D.bytes(Pair.snd(FuluBeaconBlock_d.BeaconBlock, D.Digest, Pair.snd(B.Buf, FuluBeaconBlock_d.BeaconBlock & D.Digest, FuluBeaconBlock_h.BeaconBlock_hash_tree_root(B.alloc(0), FuluBeaconBlock_d.BeaconBlock_default()))))} == API.hash_tree_root(Spec.BeaconBlock(), RT.v_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_default())) : Maybe<&2, +List<U32>>}:
  RB.FuluBeaconBlock_e2e_root(B.alloc(0), FuluBeaconBlock_d.BeaconBlock_default(), premise_rep())

# The same bridges at the non-empty object NE(): every premise is proved of NE().

def premise_ne_rep() -> RT.rep_BeaconBlock(NE(), Spec.BeaconBlock()):
  (uint64_d.u64_default(), (uint64_d.u64_default(), (FuluBytes32_d.b32_default(), (FuluBytes32_d.b32_default(), ({==}, ({==}, (FuluBytes96_d.b96_default(), (FuluEth1Data_d.Eth1Data_default(), (FuluBytes32_d.b32_default(), ({==}, (((RT.tfz_l16_ProposerSlashing(ALeaf{FuluProposerSlashing_d.ProposerSlashing_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, (({==}, ({==}, ((FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default(), {==}), (FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default(), {==})))), {==})))))))), {==}), (((RT.tfz_l1_AttesterSlashing(ALeaf{FuluAttesterSlashing_d.AttesterSlashing_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, (({==}, ({==}, (({==}, (FuluAttestationData_d.AttestationData_default(), (FuluBytes96_d.b96_default(), ({==}, (Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, ({==}, {==})))))), ({==}, (FuluAttestationData_d.AttestationData_default(), (FuluBytes96_d.b96_default(), ({==}, (Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, ({==}, {==}))))))))), {==})))))))), {==}), (((RT.tfz_l8_Attestation(ALeaf{FuluAttestation_d.Attestation_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, (({==}, (FuluAttestationData_d.AttestationData_default(), (FuluBytes96_d.b96_default(), (Fulu_bitvector_64_d.bv64_default(), ({==}, (Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (BZ3_0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, ({==}, {==}))))))), {==})))))))), {==}), (((RT.tfz_l16_Deposit(ALeaf{FuluDeposit_d.Deposit_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, (({==}, ({==}, (((FD.array__trep(U32, 9n, 0), (9n, (1056, (32n, (WZ1056(), (FD.array__trep_perfect(U32, 9n, 0), ({==}, ({==}, {==})))))))), {==}), (FuluDepositData_d.DepositData_default(), {==})))), {==})))))))), {==}), (((FD.TLeaf{FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))), {==}), ((FuluSyncAggregate_d.SyncAggregate_default(), {==}), (({==}, (FuluBytes32_d.b32_default(), (FuluBytes20_d.b20_default(), (FuluBytes32_d.b32_default(), (FuluBytes32_d.b32_default(), (FuluBytes32_d.b32_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), (uint256_d.u256_default(), (FuluBytes32_d.b32_default(), (uint64_d.u64_default(), (uint64_d.u64_default(), ({==}, (((FD.array__trep(U32, 7n, 0), (7n, (256, (7n, (32n, (WZ256(), (FD.array__trep_perfect(U32, 7n, 0), ({==}, ({==}, ({==}, ({==}, ({==}, {==})))))))))))), {==}), ((Inr{(FD.array__trep(U32, 4n, 0), (4n, (1, (0n, (1n, (WZ1(), (FD.array__trep_perfect(U32, 4n, 0), ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))))))}, {==}), (((RT.tfz_l1048576_bl1073741824(ALeaf{FuluTransaction_d.bl1073741824_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, (({==}, (Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, {==})), {==})))))))), {==}), ((FD.TLeaf{FuluWithdrawal_d.Withdrawal_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))), {==}))))))))))))))))))), (((FD.TLeaf{FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))), {==}), (((FD.array__trep(U32, 5n, 0), (5n, (48, (WZ48(), (FD.array__trep_perfect(U32, 5n, 0), ({==}, {==})))))), {==}), ({==}, (((FD.TLeaf{FuluDepositRequest_d.DepositRequest_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))), {==}), (((FD.TLeaf{FuluWithdrawalRequest_d.WithdrawalRequest_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))), {==}), ((FD.TLeaf{FuluConsolidationRequest_d.ConsolidationRequest_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))), {==})))))))))))))))))))))))

def premise_ne_hs34() -> PS3.sdt(RT.pj_BeaconBlockBody_3(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))):
  (RT.tfz_l16_ProposerSlashing(ALeaf{FuluProposerSlashing_d.ProposerSlashing_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))

def premise_ne_hs44() -> AS4.sd1(RT.pj_BeaconBlockBody_4(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))):
  (RT.tfz_l1_AttesterSlashing(ALeaf{FuluAttesterSlashing_d.AttesterSlashing_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, ((Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}), {==}))))))))

def premise_ne_hs54() -> AT5.sd8(RT.pj_BeaconBlockBody_5(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))):
  (RT.tfz_l8_Attestation(ALeaf{FuluAttestation_d.Attestation_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, ((FD.array__trep(U32, 3n, 0), (3n, (0, (BZ3_0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, ({==}, {==}))))))), {==}))))))))

def premise_ne_hs64() -> DP6.sdt(RT.pj_BeaconBlockBody_6(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))):
  (RT.tfz_l16_Deposit(ALeaf{FuluDeposit_d.Deposit_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, ((FD.array__trep(U32, 9n, 0), (9n, (1056, (32n, (WZ1056(), (FD.array__trep_perfect(U32, 9n, 0), ({==}, ({==}, {==})))))))), {==}))))))))

def premise_ne_hs74() -> RV7.sda_l16_SignedVoluntaryExit(RT.pj_BeaconBlockBody_7(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))), 31n):
  (FD.TLeaf{FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()}, (0n, (1, ({==}, ({==}, ({==}, {==}))))))

def premise_ne_hs94() -> RC9.SHS_P(RT.pj_ExecutionPayload_4(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))), RT.pj_ExecutionPayload_10(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))), RT.pj_ExecutionPayload_13(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))), RT.pj_ExecutionPayload_14(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))))):
  ((FD.array__trep(U32, 7n, 0), (7n, (256, (7n, (32n, (WZ256(), (FD.array__trep_perfect(U32, 7n, 0), ({==}, ({==}, ({==}, ({==}, ({==}, {==})))))))))))), (Inr{(FD.array__trep(U32, 4n, 0), (4n, (1, (0n, (1n, (WZ1(), (FD.array__trep_perfect(U32, 4n, 0), ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))))))}, ((RT.tfz_l1048576_bl1073741824(ALeaf{FuluTransaction_d.bl1073741824_bx_default()}), (0n, (1, ({==}, ({==}, ({==}, ({==}, (Inl{(FD.array__trep(U32, 3n, 0), (3n, (0, (WZ0(), (FD.array__trep_perfect(U32, 3n, 0), ({==}, {==}))))))}, {==})))))))), (FD.TLeaf{FuluWithdrawal_d.Withdrawal_default()}, (0n, (1, ({==}, ({==}, ({==}, {==})))))))))

def premise_ne_hs104() -> RV10.sda_l16_SignedBLSToExecutionChange(RT.pj_BeaconBlockBody_10(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))), 31n):
  (FD.TLeaf{FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()}, (0n, (1, ({==}, ({==}, ({==}, {==}))))))

def premise_ne_hs114() -> K11.sdk48(RT.pj_BeaconBlockBody_11(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))):
  (FD.array__trep(U32, 5n, 0), (5n, (48, (WZ48(), (FD.array__trep_perfect(U32, 5n, 0), {==})))))

def premise_ne_hv114() -> {O.unit_ok(48, WO.len(RT.pj_BeaconBlockBody_11(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))) == True{} : Bool}:
  {==}

def premise_ne_ha124() -> RQ0.sda_l8192_DepositRequest(RT.pj_ExecutionRequests_0(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), 31n):
  (FD.TLeaf{FuluDepositRequest_d.DepositRequest_default()}, (0n, (1, ({==}, ({==}, ({==}, {==}))))))

def premise_ne_hb124() -> RQ1.sda_l16_WithdrawalRequest(RT.pj_ExecutionRequests_1(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), 31n):
  (FD.TLeaf{FuluWithdrawalRequest_d.WithdrawalRequest_default()}, (0n, (1, ({==}, ({==}, ({==}, {==}))))))

def premise_ne_hc124() -> RQ2.sda_l2_ConsolidationRequest(RT.pj_ExecutionRequests_2(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), 31n):
  (FD.TLeaf{FuluConsolidationRequest_d.ConsolidationRequest_default()}, (0n, (1, ({==}, ({==}, ({==}, {==}))))))

def premise_ne_hZ() -> RK.SZW(NE()):
  (PS3.LLX(RT.pj_BeaconBlockBody_3(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), (AS4.LN1(RT.pj_BeaconBlockBody_4(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), (AT5.LN8(RT.pj_BeaconBlockBody_5(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), (DP6.LLX(RT.pj_BeaconBlockBody_6(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), (VE7.WLL(RT.pj_BeaconBlockBody_7(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), (RC9.EPL(RT.pj_ExecutionPayload_10(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))), RT.pj_ExecutionPayload_13(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))), RT.pj_ExecutionPayload_14(RT.pjb_ExecutionPayload_bx(RT.pj_BeaconBlockBody_9(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))))), (BC10.WLL(RT.pj_BeaconBlockBody_10(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))), (U32.to_nat(WO.len(RT.pj_BeaconBlockBody_11(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE()))))), (Nat.add(Nat.add(Nat.add(12n, DQ0.WLL(RT.pj_ExecutionRequests_0(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))))), DQ1.WLL(RT.pj_ExecutionRequests_1(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))))), DQ2.WLL(RT.pj_ExecutionRequests_2(RT.pj_BeaconBlockBody_12(RT.pjb_BeaconBlockBody_bx(RT.pj_BeaconBlock_4(NE())))))), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))))))))))))

def FuluBeaconBlock_e2e_witness_nonempty() -> {Some{E.obytes(Pair.snd(FuluBeaconBlock_d.BeaconBlock, B.Buf, FuluBeaconBlock_e.BeaconBlock_encode(NE())))} == API.serialize(Spec.BeaconBlock(), RT.v_BeaconBlock(NE())) : Maybe<&2, +List<U32>>}:
  BR.FuluBeaconBlock_e2e_encode(NE(), premise_ne_rep(), premise_ne_hs34(), premise_ne_hs44(), premise_ne_hs54(), premise_ne_hs64(), premise_ne_hs74(), premise_ne_hs94(), premise_ne_hs104(), premise_ne_hs114(), premise_ne_hv114(), premise_ne_ha124(), premise_ne_hb124(), premise_ne_hc124(), premise_ne_hZ())

def FuluBeaconBlock_e2e_witness_root_nonempty() -> {Some{D.bytes(Pair.snd(FuluBeaconBlock_d.BeaconBlock, D.Digest, Pair.snd(B.Buf, FuluBeaconBlock_d.BeaconBlock & D.Digest, FuluBeaconBlock_h.BeaconBlock_hash_tree_root(B.alloc(0), NE()))))} == API.hash_tree_root(Spec.BeaconBlock(), RT.v_BeaconBlock(NE())) : Maybe<&2, +List<U32>>}:
  RB.FuluBeaconBlock_e2e_root(B.alloc(0), NE(), premise_ne_rep())

# the size premise hZ holds of the default object: its encoding is below 2^31 bytes
def FuluBeaconBlock_e2e_witness_size() -> RK.SZW(FuluBeaconBlock_d.BeaconBlock_default()):
  premise_hZ()

# the size premise hZ holds of the non-empty object: its encoding is below 2^31 bytes
def FuluBeaconBlock_e2e_witness_size_nonempty() -> RK.SZW(NE()):
  premise_ne_hZ()
