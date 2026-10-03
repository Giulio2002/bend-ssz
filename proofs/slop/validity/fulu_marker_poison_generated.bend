import Base
import ../../../src/obj.bend as O
import ../../../types/FuluFinalityBranch_encode_ssz_generated.bend as FuluFinalityBranch_e
import ../../../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
import ../../../types/FuluSyncAggregate_encode_ssz_generated.bend as FuluSyncAggregate_e
import ../../../types/FuluSyncCommitteeContribution_def_generated.bend as FuluSyncCommitteeContribution_d
import ../../../types/FuluSyncCommitteeContribution_encode_ssz_generated.bend as FuluSyncCommitteeContribution_e
import ../../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../../types/FuluSignedBeaconBlockHeader_encode_ssz_generated.bend as FuluSignedBeaconBlockHeader_e
import ../../../types/FuluProposerSlashing_def_generated.bend as FuluProposerSlashing_d
import ../../../types/FuluProposerSlashing_encode_ssz_generated.bend as FuluProposerSlashing_e
import ../../../types/Fulu_vec_bytevec_32_8192_encode_ssz_generated.bend as Fulu_vec_bytevec_32_8192_e
import ../../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../../types/FuluAttestation_encode_ssz_generated.bend as FuluAttestation_e
import ../../../types/Fulu_list_uint64_131072_encode_ssz_generated.bend as Fulu_list_uint64_131072_e
import ../../../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../../../types/FuluIndexedAttestation_encode_ssz_generated.bend as FuluIndexedAttestation_e
import ../../../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ../../../types/FuluAttesterSlashing_encode_ssz_generated.bend as FuluAttesterSlashing_e
import ../../../types/Fulu_vec_bytevec_48_512_encode_ssz_generated.bend as Fulu_vec_bytevec_48_512_e
import ../../../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../../../types/FuluDepositData_encode_ssz_generated.bend as FuluDepositData_e
import ../../../types/Fulu_vec_bytevec_32_33_encode_ssz_generated.bend as Fulu_vec_bytevec_32_33_e
import ../../../types/FuluDeposit_def_generated.bend as FuluDeposit_d
import ../../../types/FuluDeposit_encode_ssz_generated.bend as FuluDeposit_e
import ../../../types/FuluCurrentSyncCommitteeBranch_encode_ssz_generated.bend as FuluCurrentSyncCommitteeBranch_e
import ../../../types/FuluTransaction_encode_ssz_generated.bend as FuluTransaction_e
import ../../../types/Fulu_bytevec_256_encode_ssz_generated.bend as Fulu_bytevec_256_e
import ../../../types/Fulu_bytelist_32_encode_ssz_generated.bend as Fulu_bytelist_32_e
import ../../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../../types/FuluExecutionPayloadHeader_encode_ssz_generated.bend as FuluExecutionPayloadHeader_e
import ../../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Fulu_list_bytelist_1073741824_1048576_d
import ../../../types/Fulu_list_bytelist_1073741824_1048576_encode_ssz_generated.bend as Fulu_list_bytelist_1073741824_1048576_e
import ../../../types/FuluExecutionPayload_def_generated.bend as FuluExecutionPayload_d
import ../../../types/FuluExecutionPayload_encode_ssz_generated.bend as FuluExecutionPayload_e
import ../../../types/Fulu_list_bytevec_32_16777216_encode_ssz_generated.bend as Fulu_list_bytevec_32_16777216_e
import ../../../types/Fulu_list_uint64_1099511627776_encode_ssz_generated.bend as Fulu_list_uint64_1099511627776_e
import ../../../types/Fulu_vec_bytevec_32_65536_encode_ssz_generated.bend as Fulu_vec_bytevec_32_65536_e
import ../../../types/Fulu_vec_uint64_8192_encode_ssz_generated.bend as Fulu_vec_uint64_8192_e
import ../../../types/Fulu_list_uint8_1099511627776_encode_ssz_generated.bend as Fulu_list_uint8_1099511627776_e
import ../../../types/Fulu_vec_uint64_64_encode_ssz_generated.bend as Fulu_vec_uint64_64_e
import ../../../types/FuluExecutionBranch_encode_ssz_generated.bend as FuluExecutionBranch_e
import ../../../types/Fulu_list_AttesterSlashing_1_def_generated.bend as Fulu_list_AttesterSlashing_1_d
import ../../../types/Fulu_list_AttesterSlashing_1_encode_ssz_generated.bend as Fulu_list_AttesterSlashing_1_e
import ../../../types/Fulu_list_Attestation_8_def_generated.bend as Fulu_list_Attestation_8_d
import ../../../types/Fulu_list_Attestation_8_encode_ssz_generated.bend as Fulu_list_Attestation_8_e
import ../../../types/Fulu_list_bytevec_48_4096_encode_ssz_generated.bend as Fulu_list_bytevec_48_4096_e
import ../../../types/FuluBeaconBlockBody_def_generated.bend as FuluBeaconBlockBody_d
import ../../../types/FuluBeaconBlockBody_encode_ssz_generated.bend as FuluBeaconBlockBody_e
import ../../../types/FuluBlob_encode_ssz_generated.bend as FuluBlob_e
import ../../../types/Fulu_vec_bytevec_32_17_encode_ssz_generated.bend as Fulu_vec_bytevec_32_17_e
import ../../../types/FuluCell_encode_ssz_generated.bend as FuluCell_e
import ../../../types/Fulu_list_uint64_128_encode_ssz_generated.bend as Fulu_list_uint64_128_e
import ../../../types/Fulu_list_bytevec_2048_4096_encode_ssz_generated.bend as Fulu_list_bytevec_2048_4096_e

# GENERATED by poison_flag (codegen). Do not edit.
# The invalid-object results of the generated writers are poisoned (docs/SIZE_LIMIT_DESIGN.md: the marker is 4294967295).
# By computation on the generated writers: a stale marker literal in types/ makes the law false.

def v7_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, FuluFinalityBranch_e.v7_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v8192_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_bytevec_32_8192_e.v8192_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l131072_u64_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_uint64_131072_e.l131072_u64_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v512_b48_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_bytevec_48_512_e.v512_b48_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v33_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_bytevec_32_33_e.v33_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v6_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, FuluCurrentSyncCommitteeBranch_e.v6_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def bl1073741824_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, FuluTransaction_e.bl1073741824_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def b256_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_bytevec_256_e.b256_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def bl32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_bytelist_32_e.bl32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l16777216_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_bytevec_32_16777216_e.l16777216_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l1099511627776_u64_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_uint64_1099511627776_e.l1099511627776_u64_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v65536_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_bytevec_32_65536_e.v65536_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v8192_u64_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_uint64_8192_e.v8192_u64_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l1099511627776_u8_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_uint8_1099511627776_e.l1099511627776_u8_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v64_u64_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_uint64_64_e.v64_u64_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v4_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, FuluExecutionBranch_e.v4_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l4096_b48_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_bytevec_48_4096_e.l4096_b48_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def b131072_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, FuluBlob_e.b131072_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def v17_b32_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_vec_bytevec_32_17_e.v17_b32_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def b2048_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, FuluCell_e.b2048_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l128_u64_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_uint64_128_e.l128_u64_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def l4096_b2048_pk_false_poisoned(out: Array<U32>, +pos: U32, o: O.Words) -> {O.is_poisoned(Pair.snd(O.Words, U32, Pair.snd(Array<U32>, O.Words & U32, Fulu_list_bytevec_2048_4096_e.l4096_b2048_pk(out, pos, (o, False{}))))) == True{} : Bool}:
  {==}

def SyncCommitteeContribution_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution>, U32, Pair.snd(Array<U32>, O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution> & U32, FuluSyncCommitteeContribution_e.SyncCommitteeContribution_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def SignedBeaconBlockHeader_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>, U32, Pair.snd(Array<U32>, O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader> & U32, FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def Attestation_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluAttestation_d.Attestation>, U32, Pair.snd(Array<U32>, O.Boxed<FuluAttestation_d.Attestation> & U32, FuluAttestation_e.Attestation_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def IndexedAttestation_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>, U32, Pair.snd(Array<U32>, O.Boxed<FuluIndexedAttestation_d.IndexedAttestation> & U32, FuluIndexedAttestation_e.IndexedAttestation_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def DepositData_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluDepositData_d.DepositData>, U32, Pair.snd(Array<U32>, O.Boxed<FuluDepositData_d.DepositData> & U32, FuluDepositData_e.DepositData_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def bl1073741824_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<O.Words>, U32, Pair.snd(Array<U32>, O.Boxed<O.Words> & U32, FuluTransaction_e.bl1073741824_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def ExecutionPayloadHeader_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, U32, Pair.snd(Array<U32>, O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader> & U32, FuluExecutionPayloadHeader_e.ExecutionPayloadHeader_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def SyncAggregate_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluSyncAggregate_d.SyncAggregate>, U32, Pair.snd(Array<U32>, O.Boxed<FuluSyncAggregate_d.SyncAggregate> & U32, FuluSyncAggregate_e.SyncAggregate_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def ProposerSlashing_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, U32, Pair.snd(Array<U32>, O.Boxed<FuluProposerSlashing_d.ProposerSlashing> & U32, FuluProposerSlashing_e.ProposerSlashing_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def AttesterSlashing_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, U32, Pair.snd(Array<U32>, O.Boxed<FuluAttesterSlashing_d.AttesterSlashing> & U32, FuluAttesterSlashing_e.AttesterSlashing_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def Deposit_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluDeposit_d.Deposit>, U32, Pair.snd(Array<U32>, O.Boxed<FuluDeposit_d.Deposit> & U32, FuluDeposit_e.Deposit_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def ExecutionPayload_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluExecutionPayload_d.ExecutionPayload>, U32, Pair.snd(Array<U32>, O.Boxed<FuluExecutionPayload_d.ExecutionPayload> & U32, FuluExecutionPayload_e.ExecutionPayload_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def BeaconBlockBody_bx_putk_none_poisoned(out: Array<U32>, +pos: U32) -> {O.is_poisoned(Pair.snd(O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, U32, Pair.snd(Array<U32>, O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody> & U32, FuluBeaconBlockBody_e.BeaconBlockBody_bx_putk(out, pos, O.BNone{})))) == True{} : Bool}:
  {==}

def l1048576_bl1073741824_sz_ok_false_poisoned(ok: Bool, arr: Array<O.Boxed<O.Words>>, +n: U32) -> {O.is_poisoned(Pair.snd(Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, U32, Fulu_list_bytelist_1073741824_1048576_e.l1048576_bl1073741824_sz_ok(False{}, arr, n))) == True{} : Bool}:
  {==}

def l1_AttesterSlashing_sz_ok_false_poisoned(ok: Bool, arr: Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>, +n: U32) -> {O.is_poisoned(Pair.snd(Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq, U32, Fulu_list_AttesterSlashing_1_e.l1_AttesterSlashing_sz_ok(False{}, arr, n))) == True{} : Bool}:
  {==}

def l8_Attestation_sz_ok_false_poisoned(ok: Bool, arr: Array<O.Boxed<FuluAttestation_d.Attestation>>, +n: U32) -> {O.is_poisoned(Pair.snd(Fulu_list_Attestation_8_d.l8_Attestation_Seq, U32, Fulu_list_Attestation_8_e.l8_Attestation_sz_ok(False{}, arr, n))) == True{} : Bool}:
  {==}
