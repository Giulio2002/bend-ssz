import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../types/Fulu_bitvector_128_def_generated.bend as Fulu_bitvector_128_d
import ../../types/Fulu_bitvector_512_def_generated.bend as Fulu_bitvector_512_d
import ../../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes4_def_generated.bend as FuluBytes4_d
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes8_def_generated.bend as FuluBytes8_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/uint256_def_generated.bend as uint256_d
import ../../types/boolean_hashtreeroot_generated.bend as boolean_h
import ../../types/uint64_hashtreeroot_generated.bend as uint64_h
import ../../types/uint256_hashtreeroot_generated.bend as uint256_h
import ../../types/FuluBytes4_hashtreeroot_generated.bend as FuluBytes4_h
import ../../types/FuluBytes32_hashtreeroot_generated.bend as FuluBytes32_h
import ../../types/FuluBytes48_hashtreeroot_generated.bend as FuluBytes48_h
import ../../types/FuluBytes96_hashtreeroot_generated.bend as FuluBytes96_h
import ../../types/FuluBytes8_hashtreeroot_generated.bend as FuluBytes8_h
import ../../types/FuluBytes20_hashtreeroot_generated.bend as FuluBytes20_h
import ../../types/FuluFork_def_generated.bend as FuluFork_d
import ../../types/FuluFork_hashtreeroot_generated.bend as FuluFork_h
import ../../types/Fulu_bitvector_512_hashtreeroot_generated.bend as Fulu_bitvector_512_h
import ../../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
import ../../types/FuluSyncAggregate_hashtreeroot_generated.bend as FuluSyncAggregate_h
import ../../types/FuluSyncAggregatorSelectionData_def_generated.bend as FuluSyncAggregatorSelectionData_d
import ../../types/FuluSyncAggregatorSelectionData_hashtreeroot_generated.bend as FuluSyncAggregatorSelectionData_h
import ../../types/FuluPowBlock_def_generated.bend as FuluPowBlock_d
import ../../types/FuluPowBlock_hashtreeroot_generated.bend as FuluPowBlock_h
import ../../types/FuluPendingConsolidation_def_generated.bend as FuluPendingConsolidation_d
import ../../types/FuluPendingConsolidation_hashtreeroot_generated.bend as FuluPendingConsolidation_h
import ../../types/FuluPendingPartialWithdrawal_def_generated.bend as FuluPendingPartialWithdrawal_d
import ../../types/FuluPendingPartialWithdrawal_hashtreeroot_generated.bend as FuluPendingPartialWithdrawal_h
import ../../types/FuluVoluntaryExit_def_generated.bend as FuluVoluntaryExit_d
import ../../types/FuluVoluntaryExit_hashtreeroot_generated.bend as FuluVoluntaryExit_h
import ../../types/FuluSignedVoluntaryExit_def_generated.bend as FuluSignedVoluntaryExit_d
import ../../types/FuluSignedVoluntaryExit_hashtreeroot_generated.bend as FuluSignedVoluntaryExit_h
import ../../types/FuluHistoricalSummary_def_generated.bend as FuluHistoricalSummary_d
import ../../types/FuluHistoricalSummary_hashtreeroot_generated.bend as FuluHistoricalSummary_h
import ../../types/Fulu_bitvector_128_hashtreeroot_generated.bend as Fulu_bitvector_128_h
import ../../types/FuluSyncCommitteeContribution_def_generated.bend as FuluSyncCommitteeContribution_d
import ../../types/FuluSyncCommitteeContribution_hashtreeroot_generated.bend as FuluSyncCommitteeContribution_h
import ../../types/FuluSyncCommitteeMessage_def_generated.bend as FuluSyncCommitteeMessage_d
import ../../types/FuluSyncCommitteeMessage_hashtreeroot_generated.bend as FuluSyncCommitteeMessage_h
import ../../types/FuluEth1Block_def_generated.bend as FuluEth1Block_d
import ../../types/FuluEth1Block_hashtreeroot_generated.bend as FuluEth1Block_h
import ../../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../../types/FuluBeaconBlockHeader_hashtreeroot_generated.bend as FuluBeaconBlockHeader_h
import ../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../types/FuluSignedBeaconBlockHeader_hashtreeroot_generated.bend as FuluSignedBeaconBlockHeader_h
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluEth1Data_hashtreeroot_generated.bend as FuluEth1Data_h
import ../../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../../types/FuluCheckpoint_hashtreeroot_generated.bend as FuluCheckpoint_h
import ../../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../../types/FuluAttestationData_hashtreeroot_generated.bend as FuluAttestationData_h
import ../../types/FuluSingleAttestation_def_generated.bend as FuluSingleAttestation_d
import ../../types/FuluSingleAttestation_hashtreeroot_generated.bend as FuluSingleAttestation_h
import ../../types/Fulu_bitvector_64_hashtreeroot_generated.bend as Fulu_bitvector_64_h
import ../../types/FuluForkData_def_generated.bend as FuluForkData_d
import ../../types/FuluForkData_hashtreeroot_generated.bend as FuluForkData_h
import ../../types/FuluSigningData_def_generated.bend as FuluSigningData_d
import ../../types/FuluSigningData_hashtreeroot_generated.bend as FuluSigningData_h
import ../../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../../types/FuluDepositRequest_hashtreeroot_generated.bend as FuluDepositRequest_h
import ../../types/FuluPendingDeposit_def_generated.bend as FuluPendingDeposit_d
import ../../types/FuluPendingDeposit_hashtreeroot_generated.bend as FuluPendingDeposit_h
import ../../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../../types/FuluDepositData_hashtreeroot_generated.bend as FuluDepositData_h
import ../../types/FuluDepositMessage_def_generated.bend as FuluDepositMessage_d
import ../../types/FuluDepositMessage_hashtreeroot_generated.bend as FuluDepositMessage_h
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_hashtreeroot_generated.bend as FuluValidator_h
import ../../types/FuluConsolidationRequest_def_generated.bend as FuluConsolidationRequest_d
import ../../types/FuluConsolidationRequest_hashtreeroot_generated.bend as FuluConsolidationRequest_h
import ../../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../../types/FuluWithdrawalRequest_hashtreeroot_generated.bend as FuluWithdrawalRequest_h
import ../../types/FuluBLSToExecutionChange_def_generated.bend as FuluBLSToExecutionChange_d
import ../../types/FuluBLSToExecutionChange_hashtreeroot_generated.bend as FuluBLSToExecutionChange_h
import ../../types/FuluSignedBLSToExecutionChange_def_generated.bend as FuluSignedBLSToExecutionChange_d
import ../../types/FuluSignedBLSToExecutionChange_hashtreeroot_generated.bend as FuluSignedBLSToExecutionChange_h
import ../../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
import ../../types/FuluWithdrawal_hashtreeroot_generated.bend as FuluWithdrawal_h
import ../../types/FuluBlobIdentifier_def_generated.bend as FuluBlobIdentifier_d
import ../../types/FuluBlobIdentifier_hashtreeroot_generated.bend as FuluBlobIdentifier_h
import ../../types/FuluSlot_hashtreeroot_generated.bend as FuluSlot_h
import ../../types/FuluEpoch_hashtreeroot_generated.bend as FuluEpoch_h
import ../../types/FuluGwei_hashtreeroot_generated.bend as FuluGwei_h
import ../../types/FuluHash32_hashtreeroot_generated.bend as FuluHash32_h
import ../../types/FuluVersion_hashtreeroot_generated.bend as FuluVersion_h
import ../../types/FuluDomainType_hashtreeroot_generated.bend as FuluDomainType_h
import ../../types/FuluBLSSignature_hashtreeroot_generated.bend as FuluBLSSignature_h
import ../../types/FuluVersionedHash_hashtreeroot_generated.bend as FuluVersionedHash_h
import ../../types/FuluG1Point_hashtreeroot_generated.bend as FuluG1Point_h
import ../../types/FuluG2Point_hashtreeroot_generated.bend as FuluG2Point_h
import ../../types/FuluCommitteeIndex_hashtreeroot_generated.bend as FuluCommitteeIndex_h
import ../../types/FuluValidatorIndex_hashtreeroot_generated.bend as FuluValidatorIndex_h
import ../../types/FuluRoot_hashtreeroot_generated.bend as FuluRoot_h
import ../../types/FuluForkDigest_hashtreeroot_generated.bend as FuluForkDigest_h
import ../../types/FuluDomain_hashtreeroot_generated.bend as FuluDomain_h
import ../../types/FuluBLSPubkey_hashtreeroot_generated.bend as FuluBLSPubkey_h
import ../../types/FuluNodeID_hashtreeroot_generated.bend as FuluNodeID_h
import ../../types/FuluSubnetID_hashtreeroot_generated.bend as FuluSubnetID_h
import ../../types/FuluEther_hashtreeroot_generated.bend as FuluEther_h
import ../../types/FuluExecutionAddress_hashtreeroot_generated.bend as FuluExecutionAddress_h
import ../../types/FuluPayloadId_hashtreeroot_generated.bend as FuluPayloadId_h
import ../../types/FuluWithdrawalIndex_hashtreeroot_generated.bend as FuluWithdrawalIndex_h
import ../../types/FuluBlobIndex_hashtreeroot_generated.bend as FuluBlobIndex_h
import ../../types/FuluKZGCommitment_hashtreeroot_generated.bend as FuluKZGCommitment_h
import ../../types/FuluKZGProof_hashtreeroot_generated.bend as FuluKZGProof_h
import ../../types/FuluCellIndex_hashtreeroot_generated.bend as FuluCellIndex_h
import ../../types/FuluCommitmentIndex_hashtreeroot_generated.bend as FuluCommitmentIndex_h
import ../../types/FuluRowIndex_hashtreeroot_generated.bend as FuluRowIndex_h
import ../../types/FuluColumnIndex_hashtreeroot_generated.bend as FuluColumnIndex_h
import ../../types/FuluCustodyIndex_hashtreeroot_generated.bend as FuluCustodyIndex_h
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/root_relation.bend as RR
import ../../spec/primitives.bend as SP
import ../../spec/byte_root.bend as Br
import ../../spec/limits.bend as Lim
import ../../spec/tree.bend as Tr
import ../../spec/value_domain.bend as VD
import ../../spec/fulu_schemas.bend as Spec
import ../../proofs/integer_encoding.bend as IE
import ./spec_fixed.bend as F
import ./mtree_defs.bend as MD
import ./mtree_spec.bend as MS
import ./root_support.bend as RS
import ./root_leaf.bend as RL
import ./bits_leaf.bend as BL
import ../../spec/bit_packing.bend as Bp
import ../../spec/bit_root.bend as Bits
import ../../spec/packing.bend as Pack
import ./root_names_light.bend as LV

# GENERATED by hash_tree_root_laws (codegen). Do not edit.
# Root laws of the generated object API against spec/root_relation.bend.

def d_bool(+hl: Nat, o: Bool) -> D.Digest: O.bool_chunk(o)
def st_bool(+hl: Nat, -h: B.Buf, +o: Bool, +seg: U32) -> {boolean_h.bool_root(hl, h, o, seg) == (h, d_bool(hl, o)) : B.Buf & D.Digest}: {==}
def rs_bool(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Bool) -> RR.roots(LV.v_bool(o), S.Boolean{}, [D.bytes(d_bool(hl, o))]): RL.bool_root(o)

def d_u64(+hl: Nat, o: O.U64) -> D.Digest: O.u64_chunk(o)
def st_u64(+hl: Nat, -h: B.Buf, +o: O.U64, +seg: U32) -> {uint64_h.u64_root(hl, h, o, seg) == (h, d_u64(hl, o)) : B.Buf & D.Digest}: {==}
def rs_u64(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: O.U64) -> RR.roots(LV.v_u64(o), S.Unsigned{P.U64{}}, [D.bytes(d_u64(hl, o))]): RL.u64_root(o)

# ---- u256 (uwide) ----
def c0_u256(o: uint256_d.Uint256) -> D.Digest:
  match o:
    case uint256_d.Uint256{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}
def d_u256(+hl: Nat, +o: uint256_d.Uint256) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_u256(o)], 0n)
def st_u256(+hl: Nat, -h: B.Buf, +o: uint256_d.Uint256, +seg: U32) -> {uint256_h.u256_root(hl, h, o, seg) == (h, d_u256(hl, o)) : B.Buf & D.Digest}:
  match o:
    case uint256_d.Uint256{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: {==}
def rs_u256(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: uint256_d.Uint256) -> RR.roots(LV.v_u256(o), S.Unsigned{P.U256{}}, [D.bytes(d_u256(hl, o))]):
  match o:
    case uint256_d.Uint256{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      %IE.uint_hash_tree_root_correct(P.U256{}, P.UInt{w0, w1, w2, w3, w4, w5, w6, w7}) :
        {_ == Some{D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)})} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}), List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), RL.bytes_8(w0, w1, w2, w3, w4, w5, w6, w7)) :
        {I.uint_root(P.U256{}, P.UInt{w0, w1, w2, w3, w4, w5, w6, w7}) == Some{_} : Maybe<&2, +List<U32>>}
      {==}

# ---- b4 (rec) ----
def c0_b4(o: FuluBytes4_d.Bytes4) -> D.Digest:
  match o:
    case FuluBytes4_d.Bytes4{+w0}: D.D{B.swap32(w0), 0, 0, 0, 0, 0, 0, 0}
def d_b4(+hl: Nat, +o: FuluBytes4_d.Bytes4) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_b4(o)], 0n)
def st_b4(+hl: Nat, -h: B.Buf, +o: FuluBytes4_d.Bytes4, +seg: U32) -> {FuluBytes4_h.b4_root(hl, h, o, seg) == (h, d_b4(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBytes4_d.Bytes4{+w0}: {==}
def chunks_b4(+o: FuluBytes4_d.Bytes4) -> {Br.chunks(LV.vb_b4(o)) == MD.bytes_list([c0_b4(o)]) : +List<+List<U32>>}:
  match o:
    case FuluBytes4_d.Bytes4{+w0}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), 0, 0, 0, 0, 0, 0, 0}), List.append(&2, U32, F.limbs([w0]), SP.zero_bytes(28n)), RL.bytes_1(w0)) :
        {Br.chunks(F.limbs([w0])) == [_] : +List<+List<U32>>}
      {==}
def rs_canon_b4(+o: FuluBytes4_d.Bytes4) -> {Br.canonical_depth(LV.vb_b4(o), 0n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b4(o)), MD.bytes_list([c0_b4(o)]), chunks_b4(o)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 0n) == True{} : Bool}
  {==}
def rs_gate_b4(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes4_d.Bytes4) -> {RR.bytevector_at_depth(4n, 0n, LV.vb_b4(o)) == Some{D.bytes(d_b4(hl, o))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(4n, LV.vb_b4(o)), True{}, LV.domain_b4(o)) :
    {Br.gate(_, 0n, LV.vb_b4(o)) == Some{D.bytes(d_b4(hl, o))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b4(o)), MD.bytes_list([c0_b4(o)]), chunks_b4(o)) :
    {Some{Tr.tree(0n, _)} == Some{D.bytes(d_b4(hl, o))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(0n, True{}, hl, [c0_b4(o)], 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(d_b4(hl, o))} : Maybe<&2, +List<U32>>}
  {==}
def rs_b4(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes4_d.Bytes4) -> RR.roots(LV.v_b4(o), S.ByteVector{4n}, [D.bytes(d_b4(hl, o))]):
  (0n, (rs_canon_b4(o), rs_gate_b4(hl, ehl, o)))

# ---- b32 (rec) ----
def c0_b32(o: FuluBytes32_d.Bytes32) -> D.Digest:
  match o:
    case FuluBytes32_d.Bytes32{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}
def d_b32(+hl: Nat, +o: FuluBytes32_d.Bytes32) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_b32(o)], 0n)
def st_b32(+hl: Nat, -h: B.Buf, +o: FuluBytes32_d.Bytes32, +seg: U32) -> {FuluBytes32_h.b32_root(hl, h, o, seg) == (h, d_b32(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBytes32_d.Bytes32{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: {==}
def chunks_b32(+o: FuluBytes32_d.Bytes32) -> {Br.chunks(LV.vb_b32(o)) == MD.bytes_list([c0_b32(o)]) : +List<+List<U32>>}:
  match o:
    case FuluBytes32_d.Bytes32{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}), List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), RL.bytes_8(w0, w1, w2, w3, w4, w5, w6, w7)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7])) == [_] : +List<+List<U32>>}
      {==}
def rs_canon_b32(+o: FuluBytes32_d.Bytes32) -> {Br.canonical_depth(LV.vb_b32(o), 0n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b32(o)), MD.bytes_list([c0_b32(o)]), chunks_b32(o)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 0n) == True{} : Bool}
  {==}
def rs_gate_b32(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes32_d.Bytes32) -> {RR.bytevector_at_depth(32n, 0n, LV.vb_b32(o)) == Some{D.bytes(d_b32(hl, o))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(32n, LV.vb_b32(o)), True{}, LV.domain_b32(o)) :
    {Br.gate(_, 0n, LV.vb_b32(o)) == Some{D.bytes(d_b32(hl, o))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b32(o)), MD.bytes_list([c0_b32(o)]), chunks_b32(o)) :
    {Some{Tr.tree(0n, _)} == Some{D.bytes(d_b32(hl, o))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(0n, True{}, hl, [c0_b32(o)], 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(d_b32(hl, o))} : Maybe<&2, +List<U32>>}
  {==}
def rs_b32(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes32_d.Bytes32) -> RR.roots(LV.v_b32(o), S.ByteVector{32n}, [D.bytes(d_b32(hl, o))]):
  (0n, (rs_canon_b32(o), rs_gate_b32(hl, ehl, o)))

# ---- b48 (rec) ----
def c0_b48(o: FuluBytes48_d.Bytes48) -> D.Digest:
  match o:
    case FuluBytes48_d.Bytes48{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}
def c1_b48(o: FuluBytes48_d.Bytes48) -> D.Digest:
  match o:
    case FuluBytes48_d.Bytes48{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11}: D.D{B.swap32(w8), B.swap32(w9), B.swap32(w10), B.swap32(w11), 0, 0, 0, 0}
def d_b48(+hl: Nat, +o: FuluBytes48_d.Bytes48) -> D.Digest: MD.rtree(1n, True{}, hl, [c0_b48(o), c1_b48(o)], 0n)
def st_b48(+hl: Nat, -h: B.Buf, +o: FuluBytes48_d.Bytes48, +seg: U32) -> {FuluBytes48_h.b48_root(hl, h, o, seg) == (h, d_b48(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBytes48_d.Bytes48{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11}: {==}
def chunks_b48(+o: FuluBytes48_d.Bytes48) -> {Br.chunks(LV.vb_b48(o)) == MD.bytes_list([c0_b48(o), c1_b48(o)]) : +List<+List<U32>>}:
  match o:
    case FuluBytes48_d.Bytes48{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}), List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), RL.bytes_8(w0, w1, w2, w3, w4, w5, w6, w7)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11])) == [_, D.bytes(c1_b48(FuluBytes48_d.Bytes48{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11}))] : +List<+List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w8), B.swap32(w9), B.swap32(w10), B.swap32(w11), 0, 0, 0, 0}), List.append(&2, U32, F.limbs([w8, w9, w10, w11]), SP.zero_bytes(16n)), RL.bytes_4(w8, w9, w10, w11)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11])) == [List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), _] : +List<+List<U32>>}
      {==}
def rs_canon_b48(+o: FuluBytes48_d.Bytes48) -> {Br.canonical_depth(LV.vb_b48(o), 1n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b48(o)), MD.bytes_list([c0_b48(o), c1_b48(o)]), chunks_b48(o)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 1n) == True{} : Bool}
  {==}
def rs_gate_b48(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes48_d.Bytes48) -> {RR.bytevector_at_depth(48n, 1n, LV.vb_b48(o)) == Some{D.bytes(d_b48(hl, o))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(48n, LV.vb_b48(o)), True{}, LV.domain_b48(o)) :
    {Br.gate(_, 1n, LV.vb_b48(o)) == Some{D.bytes(d_b48(hl, o))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b48(o)), MD.bytes_list([c0_b48(o), c1_b48(o)]), chunks_b48(o)) :
    {Some{Tr.tree(1n, _)} == Some{D.bytes(d_b48(hl, o))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(1n, True{}, hl, [c0_b48(o), c1_b48(o)], 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(d_b48(hl, o))} : Maybe<&2, +List<U32>>}
  {==}
def rs_b48(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes48_d.Bytes48) -> RR.roots(LV.v_b48(o), S.ByteVector{48n}, [D.bytes(d_b48(hl, o))]):
  (1n, (rs_canon_b48(o), rs_gate_b48(hl, ehl, o)))

# ---- b96 (rec) ----
def c0_b96(o: FuluBytes96_d.Bytes96) -> D.Digest:
  match o:
    case FuluBytes96_d.Bytes96{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15, +w16, +w17, +w18, +w19, +w20, +w21, +w22, +w23}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}
def c1_b96(o: FuluBytes96_d.Bytes96) -> D.Digest:
  match o:
    case FuluBytes96_d.Bytes96{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15, +w16, +w17, +w18, +w19, +w20, +w21, +w22, +w23}: D.D{B.swap32(w8), B.swap32(w9), B.swap32(w10), B.swap32(w11), B.swap32(w12), B.swap32(w13), B.swap32(w14), B.swap32(w15)}
def c2_b96(o: FuluBytes96_d.Bytes96) -> D.Digest:
  match o:
    case FuluBytes96_d.Bytes96{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15, +w16, +w17, +w18, +w19, +w20, +w21, +w22, +w23}: D.D{B.swap32(w16), B.swap32(w17), B.swap32(w18), B.swap32(w19), B.swap32(w20), B.swap32(w21), B.swap32(w22), B.swap32(w23)}
def d_b96(+hl: Nat, +o: FuluBytes96_d.Bytes96) -> D.Digest: MD.rtree(2n, True{}, hl, [c0_b96(o), c1_b96(o), c2_b96(o)], 0n)
def st_b96(+hl: Nat, -h: B.Buf, +o: FuluBytes96_d.Bytes96, +seg: U32) -> {FuluBytes96_h.b96_root(hl, h, o, seg) == (h, d_b96(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBytes96_d.Bytes96{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15, +w16, +w17, +w18, +w19, +w20, +w21, +w22, +w23}: {==}
def chunks_b96(+o: FuluBytes96_d.Bytes96) -> {Br.chunks(LV.vb_b96(o)) == MD.bytes_list([c0_b96(o), c1_b96(o), c2_b96(o)]) : +List<+List<U32>>}:
  match o:
    case FuluBytes96_d.Bytes96{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15, +w16, +w17, +w18, +w19, +w20, +w21, +w22, +w23}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}), List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), RL.bytes_8(w0, w1, w2, w3, w4, w5, w6, w7)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23])) == [_, D.bytes(c1_b96(FuluBytes96_d.Bytes96{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23})), D.bytes(c2_b96(FuluBytes96_d.Bytes96{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23}))] : +List<+List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w8), B.swap32(w9), B.swap32(w10), B.swap32(w11), B.swap32(w12), B.swap32(w13), B.swap32(w14), B.swap32(w15)}), List.append(&2, U32, F.limbs([w8, w9, w10, w11, w12, w13, w14, w15]), SP.zero_bytes(0n)), RL.bytes_8(w8, w9, w10, w11, w12, w13, w14, w15)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23])) == [List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), _, D.bytes(c2_b96(FuluBytes96_d.Bytes96{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23}))] : +List<+List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w16), B.swap32(w17), B.swap32(w18), B.swap32(w19), B.swap32(w20), B.swap32(w21), B.swap32(w22), B.swap32(w23)}), List.append(&2, U32, F.limbs([w16, w17, w18, w19, w20, w21, w22, w23]), SP.zero_bytes(0n)), RL.bytes_8(w16, w17, w18, w19, w20, w21, w22, w23)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23])) == [List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), List.append(&2, U32, F.limbs([w8, w9, w10, w11, w12, w13, w14, w15]), SP.zero_bytes(0n)), _] : +List<+List<U32>>}
      {==}
def rs_canon_b96(+o: FuluBytes96_d.Bytes96) -> {Br.canonical_depth(LV.vb_b96(o), 2n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b96(o)), MD.bytes_list([c0_b96(o), c1_b96(o), c2_b96(o)]), chunks_b96(o)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 2n) == True{} : Bool}
  {==}
def rs_gate_b96(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes96_d.Bytes96) -> {RR.bytevector_at_depth(96n, 2n, LV.vb_b96(o)) == Some{D.bytes(d_b96(hl, o))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(96n, LV.vb_b96(o)), True{}, LV.domain_b96(o)) :
    {Br.gate(_, 2n, LV.vb_b96(o)) == Some{D.bytes(d_b96(hl, o))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b96(o)), MD.bytes_list([c0_b96(o), c1_b96(o), c2_b96(o)]), chunks_b96(o)) :
    {Some{Tr.tree(2n, _)} == Some{D.bytes(d_b96(hl, o))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(2n, True{}, hl, [c0_b96(o), c1_b96(o), c2_b96(o)], 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(d_b96(hl, o))} : Maybe<&2, +List<U32>>}
  {==}
def rs_b96(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes96_d.Bytes96) -> RR.roots(LV.v_b96(o), S.ByteVector{96n}, [D.bytes(d_b96(hl, o))]):
  (2n, (rs_canon_b96(o), rs_gate_b96(hl, ehl, o)))

# ---- b8 (rec) ----
def c0_b8(o: FuluBytes8_d.Bytes8) -> D.Digest:
  match o:
    case FuluBytes8_d.Bytes8{+w0, +w1}: D.D{B.swap32(w0), B.swap32(w1), 0, 0, 0, 0, 0, 0}
def d_b8(+hl: Nat, +o: FuluBytes8_d.Bytes8) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_b8(o)], 0n)
def st_b8(+hl: Nat, -h: B.Buf, +o: FuluBytes8_d.Bytes8, +seg: U32) -> {FuluBytes8_h.b8_root(hl, h, o, seg) == (h, d_b8(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBytes8_d.Bytes8{+w0, +w1}: {==}
def chunks_b8(+o: FuluBytes8_d.Bytes8) -> {Br.chunks(LV.vb_b8(o)) == MD.bytes_list([c0_b8(o)]) : +List<+List<U32>>}:
  match o:
    case FuluBytes8_d.Bytes8{+w0, +w1}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), 0, 0, 0, 0, 0, 0}), List.append(&2, U32, F.limbs([w0, w1]), SP.zero_bytes(24n)), RL.bytes_2(w0, w1)) :
        {Br.chunks(F.limbs([w0, w1])) == [_] : +List<+List<U32>>}
      {==}
def rs_canon_b8(+o: FuluBytes8_d.Bytes8) -> {Br.canonical_depth(LV.vb_b8(o), 0n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b8(o)), MD.bytes_list([c0_b8(o)]), chunks_b8(o)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 0n) == True{} : Bool}
  {==}
def rs_gate_b8(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes8_d.Bytes8) -> {RR.bytevector_at_depth(8n, 0n, LV.vb_b8(o)) == Some{D.bytes(d_b8(hl, o))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(8n, LV.vb_b8(o)), True{}, LV.domain_b8(o)) :
    {Br.gate(_, 0n, LV.vb_b8(o)) == Some{D.bytes(d_b8(hl, o))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b8(o)), MD.bytes_list([c0_b8(o)]), chunks_b8(o)) :
    {Some{Tr.tree(0n, _)} == Some{D.bytes(d_b8(hl, o))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(0n, True{}, hl, [c0_b8(o)], 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(d_b8(hl, o))} : Maybe<&2, +List<U32>>}
  {==}
def rs_b8(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes8_d.Bytes8) -> RR.roots(LV.v_b8(o), S.ByteVector{8n}, [D.bytes(d_b8(hl, o))]):
  (0n, (rs_canon_b8(o), rs_gate_b8(hl, ehl, o)))

# ---- b20 (rec) ----
def c0_b20(o: FuluBytes20_d.Bytes20) -> D.Digest:
  match o:
    case FuluBytes20_d.Bytes20{+w0, +w1, +w2, +w3, +w4}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), 0, 0, 0}
def d_b20(+hl: Nat, +o: FuluBytes20_d.Bytes20) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_b20(o)], 0n)
def st_b20(+hl: Nat, -h: B.Buf, +o: FuluBytes20_d.Bytes20, +seg: U32) -> {FuluBytes20_h.b20_root(hl, h, o, seg) == (h, d_b20(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBytes20_d.Bytes20{+w0, +w1, +w2, +w3, +w4}: {==}
def chunks_b20(+o: FuluBytes20_d.Bytes20) -> {Br.chunks(LV.vb_b20(o)) == MD.bytes_list([c0_b20(o)]) : +List<+List<U32>>}:
  match o:
    case FuluBytes20_d.Bytes20{+w0, +w1, +w2, +w3, +w4}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), 0, 0, 0}), List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4]), SP.zero_bytes(12n)), RL.bytes_5(w0, w1, w2, w3, w4)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4])) == [_] : +List<+List<U32>>}
      {==}
def rs_canon_b20(+o: FuluBytes20_d.Bytes20) -> {Br.canonical_depth(LV.vb_b20(o), 0n) == True{} : Bool}:
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b20(o)), MD.bytes_list([c0_b20(o)]), chunks_b20(o)) :
    {Lim.minimal(List.length(&2, +List<U32>, _), 0n) == True{} : Bool}
  {==}
def rs_gate_b20(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes20_d.Bytes20) -> {RR.bytevector_at_depth(20n, 0n, LV.vb_b20(o)) == Some{D.bytes(d_b20(hl, o))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, VD.bytevector_domain(20n, LV.vb_b20(o)), True{}, LV.domain_b20(o)) :
    {Br.gate(_, 0n, LV.vb_b20(o)) == Some{D.bytes(d_b20(hl, o))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_b20(o)), MD.bytes_list([c0_b20(o)]), chunks_b20(o)) :
    {Some{Tr.tree(0n, _)} == Some{D.bytes(d_b20(hl, o))} : Maybe<&2, +List<U32>>}
  %MS.rtree_spec(0n, True{}, hl, [c0_b20(o)], 0n, {==}, {==}, ehl) :
    {Some{_} == Some{D.bytes(d_b20(hl, o))} : Maybe<&2, +List<U32>>}
  {==}
def rs_b20(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBytes20_d.Bytes20) -> RR.roots(LV.v_b20(o), S.ByteVector{20n}, [D.bytes(d_b20(hl, o))]):
  (0n, (rs_canon_b20(o), rs_gate_b20(hl, ehl, o)))

def d_Fork(+hl: Nat, +o: FuluFork_d.Fork) -> D.Digest:
  match o:
    case FuluFork_d.Fork{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_b4(hl, x0), d_b4(hl, x1), d_u64(hl, x2)], 0n)
def st_Fork(+hl: Nat, -h: B.Buf, +o: FuluFork_d.Fork, +seg: U32) -> {FuluFork_h.Fork_root(hl, h, o, seg) == (h, d_Fork(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluFork_d.Fork{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(hl, h, x0, seg), (h, d_b4(hl, x0)), st_b4(hl, h, x0, seg)) :
        {FuluFork_h.Fork_rt0(hl, seg, x0, x1, x2, _) == (h, d_Fork(hl, FuluFork_d.Fork{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(hl, h, x1, seg), (h, d_b4(hl, x1)), st_b4(hl, h, x1, seg)) :
        {FuluFork_h.Fork_rt1(hl, seg, x0, x1, x2, d_b4(hl, x0), _) == (h, d_Fork(hl, FuluFork_d.Fork{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_Fork(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluFork_d.Fork) -> RR.roots(LV.v_Fork(o), S.Container{["previous_version", "current_version", "epoch"], S.Chain{S.ByteVector{4n}, S.Chain{S.ByteVector{4n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}, [D.bytes(d_Fork(hl, o))]):
  match o:
    case FuluFork_d.Fork{+x0, +x1, +x2}:
      (MD.bytes_list([d_b4(hl, x0), d_b4(hl, x1), d_u64(hl, x2)]), (([D.bytes(d_b4(hl, x0))], (MD.bytes_list([d_b4(hl, x1), d_u64(hl, x2)]), (rs_b4(hl, ehl, x0), (([D.bytes(d_b4(hl, x1))], (MD.bytes_list([d_u64(hl, x2)]), (rs_b4(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([]), (rs_u64(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_b4(hl, x0), d_b4(hl, x1), d_u64(hl, x2)], {==}, {==}, {==}, ehl)))

# ---- bv512 (rec) ----
def c0_bv512(o: Fulu_bitvector_512_d.Bitvector512) -> D.Digest:
  match o:
    case Fulu_bitvector_512_d.Bitvector512{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}
def c1_bv512(o: Fulu_bitvector_512_d.Bitvector512) -> D.Digest:
  match o:
    case Fulu_bitvector_512_d.Bitvector512{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15}: D.D{B.swap32(w8), B.swap32(w9), B.swap32(w10), B.swap32(w11), B.swap32(w12), B.swap32(w13), B.swap32(w14), B.swap32(w15)}
def d_bv512(+hl: Nat, +o: Fulu_bitvector_512_d.Bitvector512) -> D.Digest: MD.rtree(1n, True{}, hl, [c0_bv512(o), c1_bv512(o)], 0n)
def st_bv512(+hl: Nat, -h: B.Buf, +o: Fulu_bitvector_512_d.Bitvector512, +seg: U32) -> {Fulu_bitvector_512_h.bv512_root(hl, h, o, seg) == (h, d_bv512(hl, o)) : B.Buf & D.Digest}:
  match o:
    case Fulu_bitvector_512_d.Bitvector512{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15}: {==}
def chunks_bv512(+o: Fulu_bitvector_512_d.Bitvector512) -> {Br.chunks(LV.vb_bv512(o)) == MD.bytes_list([c0_bv512(o), c1_bv512(o)]) : +List<+List<U32>>}:
  match o:
    case Fulu_bitvector_512_d.Bitvector512{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), B.swap32(w4), B.swap32(w5), B.swap32(w6), B.swap32(w7)}), List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), RL.bytes_8(w0, w1, w2, w3, w4, w5, w6, w7)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15])) == [_, D.bytes(c1_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}))] : +List<+List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w8), B.swap32(w9), B.swap32(w10), B.swap32(w11), B.swap32(w12), B.swap32(w13), B.swap32(w14), B.swap32(w15)}), List.append(&2, U32, F.limbs([w8, w9, w10, w11, w12, w13, w14, w15]), SP.zero_bytes(0n)), RL.bytes_8(w8, w9, w10, w11, w12, w13, w14, w15)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15])) == [List.append(&2, U32, F.limbs([w0, w1, w2, w3, w4, w5, w6, w7]), SP.zero_bytes(0n)), _] : +List<+List<U32>>}
      {==}
def packv_bv512(+o: Fulu_bitvector_512_d.Bitvector512) -> {Bp.pack(LV.bits_bv512(o)) == LV.vb_bv512(o) : +List<U32>}:
  match o:
    case Fulu_bitvector_512_d.Bitvector512{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15}:
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w0), List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))))))), List.append(&2, U32, I.limb(w0), Bp.pack(List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))))))), BL.pack_word(w0, List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))))))) :
        {_ == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))))))), List.append(&2, U32, I.limb(w1), Bp.pack(List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))))))), BL.pack_word(w1, List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))))))) :
        {List.append(&2, U32, I.limb(w0), _) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))))), List.append(&2, U32, I.limb(w2), Bp.pack(List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))))), BL.pack_word(w2, List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), _)) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w3), List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))))), List.append(&2, U32, I.limb(w3), Bp.pack(List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))))), BL.pack_word(w3, List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), _))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w4), List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))), List.append(&2, U32, I.limb(w4), Bp.pack(List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))), BL.pack_word(w4, List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), _)))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w5), List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))), List.append(&2, U32, I.limb(w5), Bp.pack(List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))), BL.pack_word(w5, List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), _))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w6), List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))), List.append(&2, U32, I.limb(w6), Bp.pack(List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))), BL.pack_word(w6, List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), _)))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w7), List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))), List.append(&2, U32, I.limb(w7), Bp.pack(List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))), BL.pack_word(w7, List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), _))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w8), List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))), List.append(&2, U32, I.limb(w8), Bp.pack(List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))), BL.pack_word(w8, List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), _)))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w9), List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))), List.append(&2, U32, I.limb(w9), Bp.pack(List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))), BL.pack_word(w9, List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), _))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w10), List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))), List.append(&2, U32, I.limb(w10), Bp.pack(List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))), BL.pack_word(w10, List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), List.append(&2, U32, I.limb(w9), _)))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w11), List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))), List.append(&2, U32, I.limb(w11), Bp.pack(List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))), BL.pack_word(w11, List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), List.append(&2, U32, I.limb(w9), List.append(&2, U32, I.limb(w10), _))))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w12), List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))), List.append(&2, U32, I.limb(w12), Bp.pack(List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))), BL.pack_word(w12, List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), List.append(&2, U32, I.limb(w9), List.append(&2, U32, I.limb(w10), List.append(&2, U32, I.limb(w11), _)))))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w13), List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))), List.append(&2, U32, I.limb(w13), Bp.pack(List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))), BL.pack_word(w13, List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), [])))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), List.append(&2, U32, I.limb(w9), List.append(&2, U32, I.limb(w10), List.append(&2, U32, I.limb(w11), List.append(&2, U32, I.limb(w12), _))))))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w14), List.append(&2, Bool, BL.wbits(w15), []))), List.append(&2, U32, I.limb(w14), Bp.pack(List.append(&2, Bool, BL.wbits(w15), []))), BL.pack_word(w14, List.append(&2, Bool, BL.wbits(w15), []))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), List.append(&2, U32, I.limb(w9), List.append(&2, U32, I.limb(w10), List.append(&2, U32, I.limb(w11), List.append(&2, U32, I.limb(w12), List.append(&2, U32, I.limb(w13), _)))))))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w15), [])), List.append(&2, U32, I.limb(w15), Bp.pack([])), BL.pack_word(w15, [])) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), List.append(&2, U32, I.limb(w3), List.append(&2, U32, I.limb(w4), List.append(&2, U32, I.limb(w5), List.append(&2, U32, I.limb(w6), List.append(&2, U32, I.limb(w7), List.append(&2, U32, I.limb(w8), List.append(&2, U32, I.limb(w9), List.append(&2, U32, I.limb(w10), List.append(&2, U32, I.limb(w11), List.append(&2, U32, I.limb(w12), List.append(&2, U32, I.limb(w13), List.append(&2, U32, I.limb(w14), _))))))))))))))) == F.limbs([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) : +List<U32>}
      {==}
def rs_gate_bv512(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Fulu_bitvector_512_d.Bitvector512) -> {Bits.bitvector_at_depth(512n, 1n, LV.bits_bv512(o)) == Some{D.bytes(d_bv512(hl, o))} : Maybe<&2, +List<U32>>}:
  match o:
    case Fulu_bitvector_512_d.Bitvector512{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7, +w8, +w9, +w10, +w11, +w12, +w13, +w14, +w15}:
      %Equal.sym(Nat, List.length(&2, Bool, LV.bits_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})), 512n, LV.blen_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})) :
        {Bits.vector_gate(Bool.and(Nat.is_lt(0n, 512n), Nat.is_eq(_, 512n)), 512n, 1n, LV.bits_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})) == Some{D.bytes(d_bv512(hl, Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<U32>, Bp.pack(LV.bits_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})), LV.vb_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}), packv_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})) :
        {Lim.at_depth(Bits.chunk_limit(512n), 1n, Pack.scan(_, 31n, [], [])) == Some{D.bytes(d_bv512(hl, Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})), MD.bytes_list([c0_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}), c1_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})]), chunks_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})) :
        {Lim.at_depth(Bits.chunk_limit(512n), 1n, _) == Some{D.bytes(d_bv512(hl, Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(Bits.chunk_limit(512n), 1n, MD.bytes_list([c0_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}), c1_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})])), Some{D.bytes(MD.rtree(1n, Nat.is_lt(0n, MD.dlen([c0_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}), c1_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})])), hl, [c0_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}), c1_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})], 0n))}, RS.at_depth_tree(Bits.chunk_limit(512n), 1n, hl, [c0_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}), c1_bv512(Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})], {==}, {==}, ehl)) :
        {_ == Some{D.bytes(d_bv512(hl, Fulu_bitvector_512_d.Bitvector512{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}))} : Maybe<&2, +List<U32>>}
      {==}
def rs_bv512(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Fulu_bitvector_512_d.Bitvector512) -> RR.roots(LV.v_bv512(o), S.BitVector{512n}, [D.bytes(d_bv512(hl, o))]):
  (1n, ({==}, rs_gate_bv512(hl, ehl, o)))

def d_SyncAggregate(+hl: Nat, +o: FuluSyncAggregate_d.SyncAggregate) -> D.Digest:
  match o:
    case FuluSyncAggregate_d.SyncAggregate{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_bv512(hl, x0), d_b96(hl, x1)], 0n)
def st_SyncAggregate(+hl: Nat, -h: B.Buf, +o: FuluSyncAggregate_d.SyncAggregate, +seg: U32) -> {FuluSyncAggregate_h.SyncAggregate_root(hl, h, o, seg) == (h, d_SyncAggregate(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSyncAggregate_d.SyncAggregate{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, Fulu_bitvector_512_h.bv512_root(hl, h, x0, seg), (h, d_bv512(hl, x0)), st_bv512(hl, h, x0, seg)) :
        {FuluSyncAggregate_h.SyncAggregate_rt0(hl, seg, x0, x1, _) == (h, d_SyncAggregate(hl, FuluSyncAggregate_d.SyncAggregate{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x1, seg), (h, d_b96(hl, x1)), st_b96(hl, h, x1, seg)) :
        {FuluSyncAggregate_h.SyncAggregate_rt1(hl, seg, x0, x1, d_bv512(hl, x0), _) == (h, d_SyncAggregate(hl, FuluSyncAggregate_d.SyncAggregate{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_SyncAggregate(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSyncAggregate_d.SyncAggregate) -> RR.roots(LV.v_SyncAggregate(o), S.Container{["sync_committee_bits", "sync_committee_signature"], S.Chain{S.BitVector{512n}, S.Chain{S.ByteVector{96n}, S.End{}}}}, [D.bytes(d_SyncAggregate(hl, o))]):
  match o:
    case FuluSyncAggregate_d.SyncAggregate{+x0, +x1}:
      (MD.bytes_list([d_bv512(hl, x0), d_b96(hl, x1)]), (([D.bytes(d_bv512(hl, x0))], (MD.bytes_list([d_b96(hl, x1)]), (rs_bv512(hl, ehl, x0), (([D.bytes(d_b96(hl, x1))], (MD.bytes_list([]), (rs_b96(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_bv512(hl, x0), d_b96(hl, x1)], {==}, {==}, {==}, ehl)))

def d_SyncAggregatorSelectionData(+hl: Nat, +o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData) -> D.Digest:
  match o:
    case FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1)], 0n)
def st_SyncAggregatorSelectionData(+hl: Nat, -h: B.Buf, +o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData, +seg: U32) -> {FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_root(hl, h, o, seg) == (h, d_SyncAggregatorSelectionData(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData{+x0, +x1}:
      {==}
def rs_SyncAggregatorSelectionData(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData) -> RR.roots(LV.v_SyncAggregatorSelectionData(o), S.Container{["slot", "subcommittee_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, [D.bytes(d_SyncAggregatorSelectionData(hl, o))]):
  match o:
    case FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData{+x0, +x1}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([]), (rs_u64(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_u64(hl, x0), d_u64(hl, x1)], {==}, {==}, {==}, ehl)))

def d_PowBlock(+hl: Nat, +o: FuluPowBlock_d.PowBlock) -> D.Digest:
  match o:
    case FuluPowBlock_d.PowBlock{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_b32(hl, x0), d_b32(hl, x1), d_u256(hl, x2)], 0n)
def st_PowBlock(+hl: Nat, -h: B.Buf, +o: FuluPowBlock_d.PowBlock, +seg: U32) -> {FuluPowBlock_h.PowBlock_root(hl, h, o, seg) == (h, d_PowBlock(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluPowBlock_d.PowBlock{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x0, seg), (h, d_b32(hl, x0)), st_b32(hl, h, x0, seg)) :
        {FuluPowBlock_h.PowBlock_rt0(hl, seg, x0, x1, x2, _) == (h, d_PowBlock(hl, FuluPowBlock_d.PowBlock{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluPowBlock_h.PowBlock_rt1(hl, seg, x0, x1, x2, d_b32(hl, x0), _) == (h, d_PowBlock(hl, FuluPowBlock_d.PowBlock{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, uint256_h.u256_root(hl, h, x2, seg), (h, d_u256(hl, x2)), st_u256(hl, h, x2, seg)) :
        {FuluPowBlock_h.PowBlock_rt2(hl, seg, x0, x1, x2, d_b32(hl, x0), d_b32(hl, x1), _) == (h, d_PowBlock(hl, FuluPowBlock_d.PowBlock{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_PowBlock(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluPowBlock_d.PowBlock) -> RR.roots(LV.v_PowBlock(o), S.Container{["block_hash", "parent_hash", "total_difficulty"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U256{}}, S.End{}}}}}, [D.bytes(d_PowBlock(hl, o))]):
  match o:
    case FuluPowBlock_d.PowBlock{+x0, +x1, +x2}:
      (MD.bytes_list([d_b32(hl, x0), d_b32(hl, x1), d_u256(hl, x2)]), (([D.bytes(d_b32(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u256(hl, x2)]), (rs_b32(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u256(hl, x2)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u256(hl, x2))], (MD.bytes_list([]), (rs_u256(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_b32(hl, x0), d_b32(hl, x1), d_u256(hl, x2)], {==}, {==}, {==}, ehl)))

def d_PendingConsolidation(+hl: Nat, +o: FuluPendingConsolidation_d.PendingConsolidation) -> D.Digest:
  match o:
    case FuluPendingConsolidation_d.PendingConsolidation{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1)], 0n)
def st_PendingConsolidation(+hl: Nat, -h: B.Buf, +o: FuluPendingConsolidation_d.PendingConsolidation, +seg: U32) -> {FuluPendingConsolidation_h.PendingConsolidation_root(hl, h, o, seg) == (h, d_PendingConsolidation(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluPendingConsolidation_d.PendingConsolidation{+x0, +x1}:
      {==}
def rs_PendingConsolidation(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluPendingConsolidation_d.PendingConsolidation) -> RR.roots(LV.v_PendingConsolidation(o), S.Container{["source_index", "target_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, [D.bytes(d_PendingConsolidation(hl, o))]):
  match o:
    case FuluPendingConsolidation_d.PendingConsolidation{+x0, +x1}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([]), (rs_u64(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_u64(hl, x0), d_u64(hl, x1)], {==}, {==}, {==}, ehl)))

def d_PendingPartialWithdrawal(+hl: Nat, +o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal) -> D.Digest:
  match o:
    case FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1), d_u64(hl, x2)], 0n)
def st_PendingPartialWithdrawal(+hl: Nat, -h: B.Buf, +o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal, +seg: U32) -> {FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_root(hl, h, o, seg) == (h, d_PendingPartialWithdrawal(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal{+x0, +x1, +x2}:
      {==}
def rs_PendingPartialWithdrawal(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal) -> RR.roots(LV.v_PendingPartialWithdrawal(o), S.Container{["validator_index", "amount", "withdrawable_epoch"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}, [D.bytes(d_PendingPartialWithdrawal(hl, o))]):
  match o:
    case FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal{+x0, +x1, +x2}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1), d_u64(hl, x2)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1), d_u64(hl, x2)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([d_u64(hl, x2)]), (rs_u64(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([]), (rs_u64(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_u64(hl, x0), d_u64(hl, x1), d_u64(hl, x2)], {==}, {==}, {==}, ehl)))

def d_VoluntaryExit(+hl: Nat, +o: FuluVoluntaryExit_d.VoluntaryExit) -> D.Digest:
  match o:
    case FuluVoluntaryExit_d.VoluntaryExit{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1)], 0n)
def st_VoluntaryExit(+hl: Nat, -h: B.Buf, +o: FuluVoluntaryExit_d.VoluntaryExit, +seg: U32) -> {FuluVoluntaryExit_h.VoluntaryExit_root(hl, h, o, seg) == (h, d_VoluntaryExit(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluVoluntaryExit_d.VoluntaryExit{+x0, +x1}:
      {==}
def rs_VoluntaryExit(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluVoluntaryExit_d.VoluntaryExit) -> RR.roots(LV.v_VoluntaryExit(o), S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, [D.bytes(d_VoluntaryExit(hl, o))]):
  match o:
    case FuluVoluntaryExit_d.VoluntaryExit{+x0, +x1}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([]), (rs_u64(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_u64(hl, x0), d_u64(hl, x1)], {==}, {==}, {==}, ehl)))

def d_SignedVoluntaryExit(+hl: Nat, +o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit) -> D.Digest:
  match o:
    case FuluSignedVoluntaryExit_d.SignedVoluntaryExit{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_VoluntaryExit(hl, x0), d_b96(hl, x1)], 0n)
def st_SignedVoluntaryExit(+hl: Nat, -h: B.Buf, +o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit, +seg: U32) -> {FuluSignedVoluntaryExit_h.SignedVoluntaryExit_root(hl, h, o, seg) == (h, d_SignedVoluntaryExit(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSignedVoluntaryExit_d.SignedVoluntaryExit{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluVoluntaryExit_h.VoluntaryExit_root(hl, h, x0, seg), (h, d_VoluntaryExit(hl, x0)), st_VoluntaryExit(hl, h, x0, seg)) :
        {FuluSignedVoluntaryExit_h.SignedVoluntaryExit_rt0(hl, seg, x0, x1, _) == (h, d_SignedVoluntaryExit(hl, FuluSignedVoluntaryExit_d.SignedVoluntaryExit{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x1, seg), (h, d_b96(hl, x1)), st_b96(hl, h, x1, seg)) :
        {FuluSignedVoluntaryExit_h.SignedVoluntaryExit_rt1(hl, seg, x0, x1, d_VoluntaryExit(hl, x0), _) == (h, d_SignedVoluntaryExit(hl, FuluSignedVoluntaryExit_d.SignedVoluntaryExit{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_SignedVoluntaryExit(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit) -> RR.roots(LV.v_SignedVoluntaryExit(o), S.Container{["message", "signature"], S.Chain{S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}, [D.bytes(d_SignedVoluntaryExit(hl, o))]):
  match o:
    case FuluSignedVoluntaryExit_d.SignedVoluntaryExit{+x0, +x1}:
      (MD.bytes_list([d_VoluntaryExit(hl, x0), d_b96(hl, x1)]), (([D.bytes(d_VoluntaryExit(hl, x0))], (MD.bytes_list([d_b96(hl, x1)]), (rs_VoluntaryExit(hl, ehl, x0), (([D.bytes(d_b96(hl, x1))], (MD.bytes_list([]), (rs_b96(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_VoluntaryExit(hl, x0), d_b96(hl, x1)], {==}, {==}, {==}, ehl)))

def d_HistoricalSummary(+hl: Nat, +o: FuluHistoricalSummary_d.HistoricalSummary) -> D.Digest:
  match o:
    case FuluHistoricalSummary_d.HistoricalSummary{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_b32(hl, x0), d_b32(hl, x1)], 0n)
def st_HistoricalSummary(+hl: Nat, -h: B.Buf, +o: FuluHistoricalSummary_d.HistoricalSummary, +seg: U32) -> {FuluHistoricalSummary_h.HistoricalSummary_root(hl, h, o, seg) == (h, d_HistoricalSummary(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluHistoricalSummary_d.HistoricalSummary{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x0, seg), (h, d_b32(hl, x0)), st_b32(hl, h, x0, seg)) :
        {FuluHistoricalSummary_h.HistoricalSummary_rt0(hl, seg, x0, x1, _) == (h, d_HistoricalSummary(hl, FuluHistoricalSummary_d.HistoricalSummary{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluHistoricalSummary_h.HistoricalSummary_rt1(hl, seg, x0, x1, d_b32(hl, x0), _) == (h, d_HistoricalSummary(hl, FuluHistoricalSummary_d.HistoricalSummary{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_HistoricalSummary(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluHistoricalSummary_d.HistoricalSummary) -> RR.roots(LV.v_HistoricalSummary(o), S.Container{["block_summary_root", "state_summary_root"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}, [D.bytes(d_HistoricalSummary(hl, o))]):
  match o:
    case FuluHistoricalSummary_d.HistoricalSummary{+x0, +x1}:
      (MD.bytes_list([d_b32(hl, x0), d_b32(hl, x1)]), (([D.bytes(d_b32(hl, x0))], (MD.bytes_list([d_b32(hl, x1)]), (rs_b32(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([]), (rs_b32(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_b32(hl, x0), d_b32(hl, x1)], {==}, {==}, {==}, ehl)))

# ---- bv128 (rec) ----
def c0_bv128(o: Fulu_bitvector_128_d.Bitvector128) -> D.Digest:
  match o:
    case Fulu_bitvector_128_d.Bitvector128{+w0, +w1, +w2, +w3}: D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), 0, 0, 0, 0}
def d_bv128(+hl: Nat, +o: Fulu_bitvector_128_d.Bitvector128) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_bv128(o)], 0n)
def st_bv128(+hl: Nat, -h: B.Buf, +o: Fulu_bitvector_128_d.Bitvector128, +seg: U32) -> {Fulu_bitvector_128_h.bv128_root(hl, h, o, seg) == (h, d_bv128(hl, o)) : B.Buf & D.Digest}:
  match o:
    case Fulu_bitvector_128_d.Bitvector128{+w0, +w1, +w2, +w3}: {==}
def chunks_bv128(+o: Fulu_bitvector_128_d.Bitvector128) -> {Br.chunks(LV.vb_bv128(o)) == MD.bytes_list([c0_bv128(o)]) : +List<+List<U32>>}:
  match o:
    case Fulu_bitvector_128_d.Bitvector128{+w0, +w1, +w2, +w3}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), B.swap32(w2), B.swap32(w3), 0, 0, 0, 0}), List.append(&2, U32, F.limbs([w0, w1, w2, w3]), SP.zero_bytes(16n)), RL.bytes_4(w0, w1, w2, w3)) :
        {Br.chunks(F.limbs([w0, w1, w2, w3])) == [_] : +List<+List<U32>>}
      {==}
def packv_bv128(+o: Fulu_bitvector_128_d.Bitvector128) -> {Bp.pack(LV.bits_bv128(o)) == LV.vb_bv128(o) : +List<U32>}:
  match o:
    case Fulu_bitvector_128_d.Bitvector128{+w0, +w1, +w2, +w3}:
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w0), List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), []))))), List.append(&2, U32, I.limb(w0), Bp.pack(List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), []))))), BL.pack_word(w0, List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), []))))) :
        {_ == F.limbs([w0, w1, w2, w3]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w1), List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), [])))), List.append(&2, U32, I.limb(w1), Bp.pack(List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), [])))), BL.pack_word(w1, List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), [])))) :
        {List.append(&2, U32, I.limb(w0), _) == F.limbs([w0, w1, w2, w3]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w2), List.append(&2, Bool, BL.wbits(w3), []))), List.append(&2, U32, I.limb(w2), Bp.pack(List.append(&2, Bool, BL.wbits(w3), []))), BL.pack_word(w2, List.append(&2, Bool, BL.wbits(w3), []))) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), _)) == F.limbs([w0, w1, w2, w3]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w3), [])), List.append(&2, U32, I.limb(w3), Bp.pack([])), BL.pack_word(w3, [])) :
        {List.append(&2, U32, I.limb(w0), List.append(&2, U32, I.limb(w1), List.append(&2, U32, I.limb(w2), _))) == F.limbs([w0, w1, w2, w3]) : +List<U32>}
      {==}
def rs_gate_bv128(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Fulu_bitvector_128_d.Bitvector128) -> {Bits.bitvector_at_depth(128n, 0n, LV.bits_bv128(o)) == Some{D.bytes(d_bv128(hl, o))} : Maybe<&2, +List<U32>>}:
  match o:
    case Fulu_bitvector_128_d.Bitvector128{+w0, +w1, +w2, +w3}:
      %Equal.sym(Nat, List.length(&2, Bool, LV.bits_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})), 128n, LV.blen_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})) :
        {Bits.vector_gate(Bool.and(Nat.is_lt(0n, 128n), Nat.is_eq(_, 128n)), 128n, 0n, LV.bits_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})) == Some{D.bytes(d_bv128(hl, Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<U32>, Bp.pack(LV.bits_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})), LV.vb_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3}), packv_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})) :
        {Lim.at_depth(Bits.chunk_limit(128n), 0n, Pack.scan(_, 31n, [], [])) == Some{D.bytes(d_bv128(hl, Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})), MD.bytes_list([c0_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})]), chunks_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})) :
        {Lim.at_depth(Bits.chunk_limit(128n), 0n, _) == Some{D.bytes(d_bv128(hl, Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(Bits.chunk_limit(128n), 0n, MD.bytes_list([c0_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})])), Some{D.bytes(MD.rtree(0n, Nat.is_lt(0n, MD.dlen([c0_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})])), hl, [c0_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})], 0n))}, RS.at_depth_tree(Bits.chunk_limit(128n), 0n, hl, [c0_bv128(Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3})], {==}, {==}, ehl)) :
        {_ == Some{D.bytes(d_bv128(hl, Fulu_bitvector_128_d.Bitvector128{w0, w1, w2, w3}))} : Maybe<&2, +List<U32>>}
      {==}
def rs_bv128(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Fulu_bitvector_128_d.Bitvector128) -> RR.roots(LV.v_bv128(o), S.BitVector{128n}, [D.bytes(d_bv128(hl, o))]):
  (0n, ({==}, rs_gate_bv128(hl, ehl, o)))

def d_SyncCommitteeContribution(+hl: Nat, +o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution) -> D.Digest:
  match o:
    case FuluSyncCommitteeContribution_d.SyncCommitteeContribution{+x0, +x1, +x2, +x3, +x4}: MD.rtree(3n, True{}, hl, [d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bv128(hl, x3), d_b96(hl, x4)], 0n)
def st_SyncCommitteeContribution(+hl: Nat, -h: B.Buf, +o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution, +seg: U32) -> {FuluSyncCommitteeContribution_h.SyncCommitteeContribution_root(hl, h, o, seg) == (h, d_SyncCommitteeContribution(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSyncCommitteeContribution_d.SyncCommitteeContribution{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluSyncCommitteeContribution_h.SyncCommitteeContribution_rt1(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), _) == (h, d_SyncCommitteeContribution(hl, FuluSyncCommitteeContribution_d.SyncCommitteeContribution{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, Fulu_bitvector_128_h.bv128_root(hl, h, x3, seg), (h, d_bv128(hl, x3)), st_bv128(hl, h, x3, seg)) :
        {FuluSyncCommitteeContribution_h.SyncCommitteeContribution_rt3(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), _) == (h, d_SyncCommitteeContribution(hl, FuluSyncCommitteeContribution_d.SyncCommitteeContribution{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x4, seg), (h, d_b96(hl, x4)), st_b96(hl, h, x4, seg)) :
        {FuluSyncCommitteeContribution_h.SyncCommitteeContribution_rt4(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bv128(hl, x3), _) == (h, d_SyncCommitteeContribution(hl, FuluSyncCommitteeContribution_d.SyncCommitteeContribution{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      {==}
def rs_SyncCommitteeContribution(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution) -> RR.roots(LV.v_SyncCommitteeContribution(o), S.Container{["slot", "beacon_block_root", "subcommittee_index", "aggregation_bits", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.BitVector{128n}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}}, [D.bytes(d_SyncCommitteeContribution(hl, o))]):
  match o:
    case FuluSyncCommitteeContribution_d.SyncCommitteeContribution{+x0, +x1, +x2, +x3, +x4}:
      (MD.bytes_list([d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bv128(hl, x3), d_b96(hl, x4)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2), d_bv128(hl, x3), d_b96(hl, x4)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2), d_bv128(hl, x3), d_b96(hl, x4)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([d_bv128(hl, x3), d_b96(hl, x4)]), (rs_u64(hl, ehl, x2), (([D.bytes(d_bv128(hl, x3))], (MD.bytes_list([d_b96(hl, x4)]), (rs_bv128(hl, ehl, x3), (([D.bytes(d_b96(hl, x4))], (MD.bytes_list([]), (rs_b96(hl, ehl, x4), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(5n, 3n, hl, [d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bv128(hl, x3), d_b96(hl, x4)], {==}, {==}, {==}, ehl)))

def d_SyncCommitteeMessage(+hl: Nat, +o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage) -> D.Digest:
  match o:
    case FuluSyncCommitteeMessage_d.SyncCommitteeMessage{+x0, +x1, +x2, +x3}: MD.rtree(2n, True{}, hl, [d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)], 0n)
def st_SyncCommitteeMessage(+hl: Nat, -h: B.Buf, +o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage, +seg: U32) -> {FuluSyncCommitteeMessage_h.SyncCommitteeMessage_root(hl, h, o, seg) == (h, d_SyncCommitteeMessage(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSyncCommitteeMessage_d.SyncCommitteeMessage{+x0, +x1, +x2, +x3}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluSyncCommitteeMessage_h.SyncCommitteeMessage_rt1(hl, seg, x0, x1, x2, x3, d_u64(hl, x0), _) == (h, d_SyncCommitteeMessage(hl, FuluSyncCommitteeMessage_d.SyncCommitteeMessage{x0, x1, x2, x3})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x3, seg), (h, d_b96(hl, x3)), st_b96(hl, h, x3, seg)) :
        {FuluSyncCommitteeMessage_h.SyncCommitteeMessage_rt3(hl, seg, x0, x1, x2, x3, d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), _) == (h, d_SyncCommitteeMessage(hl, FuluSyncCommitteeMessage_d.SyncCommitteeMessage{x0, x1, x2, x3})) : B.Buf & D.Digest}
      {==}
def rs_SyncCommitteeMessage(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage) -> RR.roots(LV.v_SyncCommitteeMessage(o), S.Container{["slot", "beacon_block_root", "validator_index", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}, [D.bytes(d_SyncCommitteeMessage(hl, o))]):
  match o:
    case FuluSyncCommitteeMessage_d.SyncCommitteeMessage{+x0, +x1, +x2, +x3}:
      (MD.bytes_list([d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2), d_b96(hl, x3)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([d_b96(hl, x3)]), (rs_u64(hl, ehl, x2), (([D.bytes(d_b96(hl, x3))], (MD.bytes_list([]), (rs_b96(hl, ehl, x3), ({==}, {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(4n, 2n, hl, [d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)], {==}, {==}, {==}, ehl)))

def d_Eth1Block(+hl: Nat, +o: FuluEth1Block_d.Eth1Block) -> D.Digest:
  match o:
    case FuluEth1Block_d.Eth1Block{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2)], 0n)
def st_Eth1Block(+hl: Nat, -h: B.Buf, +o: FuluEth1Block_d.Eth1Block, +seg: U32) -> {FuluEth1Block_h.Eth1Block_root(hl, h, o, seg) == (h, d_Eth1Block(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluEth1Block_d.Eth1Block{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluEth1Block_h.Eth1Block_rt1(hl, seg, x0, x1, x2, d_u64(hl, x0), _) == (h, d_Eth1Block(hl, FuluEth1Block_d.Eth1Block{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_Eth1Block(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluEth1Block_d.Eth1Block) -> RR.roots(LV.v_Eth1Block(o), S.Container{["timestamp", "deposit_root", "deposit_count"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}, [D.bytes(d_Eth1Block(hl, o))]):
  match o:
    case FuluEth1Block_d.Eth1Block{+x0, +x1, +x2}:
      (MD.bytes_list([d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([]), (rs_u64(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_u64(hl, x0), d_b32(hl, x1), d_u64(hl, x2)], {==}, {==}, {==}, ehl)))

def d_BeaconBlockHeader(+hl: Nat, +o: FuluBeaconBlockHeader_d.BeaconBlockHeader) -> D.Digest:
  match o:
    case FuluBeaconBlockHeader_d.BeaconBlockHeader{+x0, +x1, +x2, +x3, +x4}: MD.rtree(3n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_b32(hl, x3), d_b32(hl, x4)], 0n)
def st_BeaconBlockHeader(+hl: Nat, -h: B.Buf, +o: FuluBeaconBlockHeader_d.BeaconBlockHeader, +seg: U32) -> {FuluBeaconBlockHeader_h.BeaconBlockHeader_root(hl, h, o, seg) == (h, d_BeaconBlockHeader(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBeaconBlockHeader_d.BeaconBlockHeader{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x2, seg), (h, d_b32(hl, x2)), st_b32(hl, h, x2, seg)) :
        {FuluBeaconBlockHeader_h.BeaconBlockHeader_rt2(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_u64(hl, x1), _) == (h, d_BeaconBlockHeader(hl, FuluBeaconBlockHeader_d.BeaconBlockHeader{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x3, seg), (h, d_b32(hl, x3)), st_b32(hl, h, x3, seg)) :
        {FuluBeaconBlockHeader_h.BeaconBlockHeader_rt3(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), _) == (h, d_BeaconBlockHeader(hl, FuluBeaconBlockHeader_d.BeaconBlockHeader{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x4, seg), (h, d_b32(hl, x4)), st_b32(hl, h, x4, seg)) :
        {FuluBeaconBlockHeader_h.BeaconBlockHeader_rt4(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_b32(hl, x3), _) == (h, d_BeaconBlockHeader(hl, FuluBeaconBlockHeader_d.BeaconBlockHeader{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      {==}
def rs_BeaconBlockHeader(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBeaconBlockHeader_d.BeaconBlockHeader) -> RR.roots(LV.v_BeaconBlockHeader(o), S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}, [D.bytes(d_BeaconBlockHeader(hl, o))]):
  match o:
    case FuluBeaconBlockHeader_d.BeaconBlockHeader{+x0, +x1, +x2, +x3, +x4}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_b32(hl, x3), d_b32(hl, x4)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1), d_b32(hl, x2), d_b32(hl, x3), d_b32(hl, x4)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([d_b32(hl, x2), d_b32(hl, x3), d_b32(hl, x4)]), (rs_u64(hl, ehl, x1), (([D.bytes(d_b32(hl, x2))], (MD.bytes_list([d_b32(hl, x3), d_b32(hl, x4)]), (rs_b32(hl, ehl, x2), (([D.bytes(d_b32(hl, x3))], (MD.bytes_list([d_b32(hl, x4)]), (rs_b32(hl, ehl, x3), (([D.bytes(d_b32(hl, x4))], (MD.bytes_list([]), (rs_b32(hl, ehl, x4), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(5n, 3n, hl, [d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_b32(hl, x3), d_b32(hl, x4)], {==}, {==}, {==}, ehl)))

def d_SignedBeaconBlockHeader(+hl: Nat, +o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader) -> D.Digest:
  match o:
    case FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_BeaconBlockHeader(hl, x0), d_b96(hl, x1)], 0n)
def st_SignedBeaconBlockHeader(+hl: Nat, -h: B.Buf, +o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader, +seg: U32) -> {FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_root(hl, h, o, seg) == (h, d_SignedBeaconBlockHeader(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_root(hl, h, x0, seg), (h, d_BeaconBlockHeader(hl, x0)), st_BeaconBlockHeader(hl, h, x0, seg)) :
        {FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_rt0(hl, seg, x0, x1, _) == (h, d_SignedBeaconBlockHeader(hl, FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x1, seg), (h, d_b96(hl, x1)), st_b96(hl, h, x1, seg)) :
        {FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_rt1(hl, seg, x0, x1, d_BeaconBlockHeader(hl, x0), _) == (h, d_SignedBeaconBlockHeader(hl, FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_SignedBeaconBlockHeader(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader) -> RR.roots(LV.v_SignedBeaconBlockHeader(o), S.Container{["message", "signature"], S.Chain{S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}, [D.bytes(d_SignedBeaconBlockHeader(hl, o))]):
  match o:
    case FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{+x0, +x1}:
      (MD.bytes_list([d_BeaconBlockHeader(hl, x0), d_b96(hl, x1)]), (([D.bytes(d_BeaconBlockHeader(hl, x0))], (MD.bytes_list([d_b96(hl, x1)]), (rs_BeaconBlockHeader(hl, ehl, x0), (([D.bytes(d_b96(hl, x1))], (MD.bytes_list([]), (rs_b96(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_BeaconBlockHeader(hl, x0), d_b96(hl, x1)], {==}, {==}, {==}, ehl)))

def d_Eth1Data(+hl: Nat, +o: FuluEth1Data_d.Eth1Data) -> D.Digest:
  match o:
    case FuluEth1Data_d.Eth1Data{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_b32(hl, x0), d_u64(hl, x1), d_b32(hl, x2)], 0n)
def st_Eth1Data(+hl: Nat, -h: B.Buf, +o: FuluEth1Data_d.Eth1Data, +seg: U32) -> {FuluEth1Data_h.Eth1Data_root(hl, h, o, seg) == (h, d_Eth1Data(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluEth1Data_d.Eth1Data{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x0, seg), (h, d_b32(hl, x0)), st_b32(hl, h, x0, seg)) :
        {FuluEth1Data_h.Eth1Data_rt0(hl, seg, x0, x1, x2, _) == (h, d_Eth1Data(hl, FuluEth1Data_d.Eth1Data{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x2, seg), (h, d_b32(hl, x2)), st_b32(hl, h, x2, seg)) :
        {FuluEth1Data_h.Eth1Data_rt2(hl, seg, x0, x1, x2, d_b32(hl, x0), d_u64(hl, x1), _) == (h, d_Eth1Data(hl, FuluEth1Data_d.Eth1Data{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_Eth1Data(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluEth1Data_d.Eth1Data) -> RR.roots(LV.v_Eth1Data(o), S.Container{["deposit_root", "deposit_count", "block_hash"], S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}}, [D.bytes(d_Eth1Data(hl, o))]):
  match o:
    case FuluEth1Data_d.Eth1Data{+x0, +x1, +x2}:
      (MD.bytes_list([d_b32(hl, x0), d_u64(hl, x1), d_b32(hl, x2)]), (([D.bytes(d_b32(hl, x0))], (MD.bytes_list([d_u64(hl, x1), d_b32(hl, x2)]), (rs_b32(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([d_b32(hl, x2)]), (rs_u64(hl, ehl, x1), (([D.bytes(d_b32(hl, x2))], (MD.bytes_list([]), (rs_b32(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_b32(hl, x0), d_u64(hl, x1), d_b32(hl, x2)], {==}, {==}, {==}, ehl)))

def d_Checkpoint(+hl: Nat, +o: FuluCheckpoint_d.Checkpoint) -> D.Digest:
  match o:
    case FuluCheckpoint_d.Checkpoint{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_u64(hl, x0), d_b32(hl, x1)], 0n)
def st_Checkpoint(+hl: Nat, -h: B.Buf, +o: FuluCheckpoint_d.Checkpoint, +seg: U32) -> {FuluCheckpoint_h.Checkpoint_root(hl, h, o, seg) == (h, d_Checkpoint(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluCheckpoint_d.Checkpoint{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluCheckpoint_h.Checkpoint_rt1(hl, seg, x0, x1, d_u64(hl, x0), _) == (h, d_Checkpoint(hl, FuluCheckpoint_d.Checkpoint{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_Checkpoint(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluCheckpoint_d.Checkpoint) -> RR.roots(LV.v_Checkpoint(o), S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, [D.bytes(d_Checkpoint(hl, o))]):
  match o:
    case FuluCheckpoint_d.Checkpoint{+x0, +x1}:
      (MD.bytes_list([d_u64(hl, x0), d_b32(hl, x1)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_b32(hl, x1)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([]), (rs_b32(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_u64(hl, x0), d_b32(hl, x1)], {==}, {==}, {==}, ehl)))

def d_AttestationData(+hl: Nat, +o: FuluAttestationData_d.AttestationData) -> D.Digest:
  match o:
    case FuluAttestationData_d.AttestationData{+x0, +x1, +x2, +x3, +x4}: MD.rtree(3n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_Checkpoint(hl, x3), d_Checkpoint(hl, x4)], 0n)
def st_AttestationData(+hl: Nat, -h: B.Buf, +o: FuluAttestationData_d.AttestationData, +seg: U32) -> {FuluAttestationData_h.AttestationData_root(hl, h, o, seg) == (h, d_AttestationData(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluAttestationData_d.AttestationData{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x2, seg), (h, d_b32(hl, x2)), st_b32(hl, h, x2, seg)) :
        {FuluAttestationData_h.AttestationData_rt2(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_u64(hl, x1), _) == (h, d_AttestationData(hl, FuluAttestationData_d.AttestationData{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluCheckpoint_h.Checkpoint_root(hl, h, x3, seg), (h, d_Checkpoint(hl, x3)), st_Checkpoint(hl, h, x3, seg)) :
        {FuluAttestationData_h.AttestationData_rt3(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), _) == (h, d_AttestationData(hl, FuluAttestationData_d.AttestationData{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluCheckpoint_h.Checkpoint_root(hl, h, x4, seg), (h, d_Checkpoint(hl, x4)), st_Checkpoint(hl, h, x4, seg)) :
        {FuluAttestationData_h.AttestationData_rt4(hl, seg, x0, x1, x2, x3, x4, d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_Checkpoint(hl, x3), _) == (h, d_AttestationData(hl, FuluAttestationData_d.AttestationData{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      {==}
def rs_AttestationData(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluAttestationData_d.AttestationData) -> RR.roots(LV.v_AttestationData(o), S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}, [D.bytes(d_AttestationData(hl, o))]):
  match o:
    case FuluAttestationData_d.AttestationData{+x0, +x1, +x2, +x3, +x4}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_Checkpoint(hl, x3), d_Checkpoint(hl, x4)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1), d_b32(hl, x2), d_Checkpoint(hl, x3), d_Checkpoint(hl, x4)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([d_b32(hl, x2), d_Checkpoint(hl, x3), d_Checkpoint(hl, x4)]), (rs_u64(hl, ehl, x1), (([D.bytes(d_b32(hl, x2))], (MD.bytes_list([d_Checkpoint(hl, x3), d_Checkpoint(hl, x4)]), (rs_b32(hl, ehl, x2), (([D.bytes(d_Checkpoint(hl, x3))], (MD.bytes_list([d_Checkpoint(hl, x4)]), (rs_Checkpoint(hl, ehl, x3), (([D.bytes(d_Checkpoint(hl, x4))], (MD.bytes_list([]), (rs_Checkpoint(hl, ehl, x4), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(5n, 3n, hl, [d_u64(hl, x0), d_u64(hl, x1), d_b32(hl, x2), d_Checkpoint(hl, x3), d_Checkpoint(hl, x4)], {==}, {==}, {==}, ehl)))

def d_SingleAttestation(+hl: Nat, +o: FuluSingleAttestation_d.SingleAttestation) -> D.Digest:
  match o:
    case FuluSingleAttestation_d.SingleAttestation{+x0, +x1, +x2, +x3}: MD.rtree(2n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1), d_AttestationData(hl, x2), d_b96(hl, x3)], 0n)
def st_SingleAttestation(+hl: Nat, -h: B.Buf, +o: FuluSingleAttestation_d.SingleAttestation, +seg: U32) -> {FuluSingleAttestation_h.SingleAttestation_root(hl, h, o, seg) == (h, d_SingleAttestation(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSingleAttestation_d.SingleAttestation{+x0, +x1, +x2, +x3}:
      %Equal.sym(B.Buf & D.Digest, FuluAttestationData_h.AttestationData_root(hl, h, x2, seg), (h, d_AttestationData(hl, x2)), st_AttestationData(hl, h, x2, seg)) :
        {FuluSingleAttestation_h.SingleAttestation_rt2(hl, seg, x0, x1, x2, x3, d_u64(hl, x0), d_u64(hl, x1), _) == (h, d_SingleAttestation(hl, FuluSingleAttestation_d.SingleAttestation{x0, x1, x2, x3})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x3, seg), (h, d_b96(hl, x3)), st_b96(hl, h, x3, seg)) :
        {FuluSingleAttestation_h.SingleAttestation_rt3(hl, seg, x0, x1, x2, x3, d_u64(hl, x0), d_u64(hl, x1), d_AttestationData(hl, x2), _) == (h, d_SingleAttestation(hl, FuluSingleAttestation_d.SingleAttestation{x0, x1, x2, x3})) : B.Buf & D.Digest}
      {==}
def rs_SingleAttestation(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSingleAttestation_d.SingleAttestation) -> RR.roots(LV.v_SingleAttestation(o), S.Container{["committee_index", "attester_index", "data", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}, [D.bytes(d_SingleAttestation(hl, o))]):
  match o:
    case FuluSingleAttestation_d.SingleAttestation{+x0, +x1, +x2, +x3}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1), d_AttestationData(hl, x2), d_b96(hl, x3)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1), d_AttestationData(hl, x2), d_b96(hl, x3)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([d_AttestationData(hl, x2), d_b96(hl, x3)]), (rs_u64(hl, ehl, x1), (([D.bytes(d_AttestationData(hl, x2))], (MD.bytes_list([d_b96(hl, x3)]), (rs_AttestationData(hl, ehl, x2), (([D.bytes(d_b96(hl, x3))], (MD.bytes_list([]), (rs_b96(hl, ehl, x3), ({==}, {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(4n, 2n, hl, [d_u64(hl, x0), d_u64(hl, x1), d_AttestationData(hl, x2), d_b96(hl, x3)], {==}, {==}, {==}, ehl)))

# ---- bv64 (rec) ----
def c0_bv64(o: Fulu_bitvector_64_d.Bitvector64) -> D.Digest:
  match o:
    case Fulu_bitvector_64_d.Bitvector64{+w0, +w1}: D.D{B.swap32(w0), B.swap32(w1), 0, 0, 0, 0, 0, 0}
def d_bv64(+hl: Nat, +o: Fulu_bitvector_64_d.Bitvector64) -> D.Digest: MD.rtree(0n, True{}, hl, [c0_bv64(o)], 0n)
def st_bv64(+hl: Nat, -h: B.Buf, +o: Fulu_bitvector_64_d.Bitvector64, +seg: U32) -> {Fulu_bitvector_64_h.bv64_root(hl, h, o, seg) == (h, d_bv64(hl, o)) : B.Buf & D.Digest}:
  match o:
    case Fulu_bitvector_64_d.Bitvector64{+w0, +w1}: {==}
def chunks_bv64(+o: Fulu_bitvector_64_d.Bitvector64) -> {Br.chunks(LV.vb_bv64(o)) == MD.bytes_list([c0_bv64(o)]) : +List<+List<U32>>}:
  match o:
    case Fulu_bitvector_64_d.Bitvector64{+w0, +w1}:
      %Equal.sym(+List<U32>, D.bytes(D.D{B.swap32(w0), B.swap32(w1), 0, 0, 0, 0, 0, 0}), List.append(&2, U32, F.limbs([w0, w1]), SP.zero_bytes(24n)), RL.bytes_2(w0, w1)) :
        {Br.chunks(F.limbs([w0, w1])) == [_] : +List<+List<U32>>}
      {==}
def packv_bv64(+o: Fulu_bitvector_64_d.Bitvector64) -> {Bp.pack(LV.bits_bv64(o)) == LV.vb_bv64(o) : +List<U32>}:
  match o:
    case Fulu_bitvector_64_d.Bitvector64{+w0, +w1}:
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w0), List.append(&2, Bool, BL.wbits(w1), []))), List.append(&2, U32, I.limb(w0), Bp.pack(List.append(&2, Bool, BL.wbits(w1), []))), BL.pack_word(w0, List.append(&2, Bool, BL.wbits(w1), []))) :
        {_ == F.limbs([w0, w1]) : +List<U32>}
      %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, BL.wbits(w1), [])), List.append(&2, U32, I.limb(w1), Bp.pack([])), BL.pack_word(w1, [])) :
        {List.append(&2, U32, I.limb(w0), _) == F.limbs([w0, w1]) : +List<U32>}
      {==}
def rs_gate_bv64(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Fulu_bitvector_64_d.Bitvector64) -> {Bits.bitvector_at_depth(64n, 0n, LV.bits_bv64(o)) == Some{D.bytes(d_bv64(hl, o))} : Maybe<&2, +List<U32>>}:
  match o:
    case Fulu_bitvector_64_d.Bitvector64{+w0, +w1}:
      %Equal.sym(Nat, List.length(&2, Bool, LV.bits_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})), 64n, LV.blen_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})) :
        {Bits.vector_gate(Bool.and(Nat.is_lt(0n, 64n), Nat.is_eq(_, 64n)), 64n, 0n, LV.bits_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})) == Some{D.bytes(d_bv64(hl, Fulu_bitvector_64_d.Bitvector64{w0, w1}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<U32>, Bp.pack(LV.bits_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})), LV.vb_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1}), packv_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})) :
        {Lim.at_depth(Bits.chunk_limit(64n), 0n, Pack.scan(_, 31n, [], [])) == Some{D.bytes(d_bv64(hl, Fulu_bitvector_64_d.Bitvector64{w0, w1}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(+List<+List<U32>>, Br.chunks(LV.vb_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})), MD.bytes_list([c0_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})]), chunks_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})) :
        {Lim.at_depth(Bits.chunk_limit(64n), 0n, _) == Some{D.bytes(d_bv64(hl, Fulu_bitvector_64_d.Bitvector64{w0, w1}))} : Maybe<&2, +List<U32>>}
      %Equal.sym(Maybe<&2, +List<U32>>, Lim.at_depth(Bits.chunk_limit(64n), 0n, MD.bytes_list([c0_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})])), Some{D.bytes(MD.rtree(0n, Nat.is_lt(0n, MD.dlen([c0_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})])), hl, [c0_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})], 0n))}, RS.at_depth_tree(Bits.chunk_limit(64n), 0n, hl, [c0_bv64(Fulu_bitvector_64_d.Bitvector64{w0, w1})], {==}, {==}, ehl)) :
        {_ == Some{D.bytes(d_bv64(hl, Fulu_bitvector_64_d.Bitvector64{w0, w1}))} : Maybe<&2, +List<U32>>}
      {==}
def rs_bv64(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: Fulu_bitvector_64_d.Bitvector64) -> RR.roots(LV.v_bv64(o), S.BitVector{64n}, [D.bytes(d_bv64(hl, o))]):
  (0n, ({==}, rs_gate_bv64(hl, ehl, o)))

def d_ForkData(+hl: Nat, +o: FuluForkData_d.ForkData) -> D.Digest:
  match o:
    case FuluForkData_d.ForkData{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_b4(hl, x0), d_b32(hl, x1)], 0n)
def st_ForkData(+hl: Nat, -h: B.Buf, +o: FuluForkData_d.ForkData, +seg: U32) -> {FuluForkData_h.ForkData_root(hl, h, o, seg) == (h, d_ForkData(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluForkData_d.ForkData{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(hl, h, x0, seg), (h, d_b4(hl, x0)), st_b4(hl, h, x0, seg)) :
        {FuluForkData_h.ForkData_rt0(hl, seg, x0, x1, _) == (h, d_ForkData(hl, FuluForkData_d.ForkData{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluForkData_h.ForkData_rt1(hl, seg, x0, x1, d_b4(hl, x0), _) == (h, d_ForkData(hl, FuluForkData_d.ForkData{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_ForkData(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluForkData_d.ForkData) -> RR.roots(LV.v_ForkData(o), S.Container{["current_version", "genesis_validators_root"], S.Chain{S.ByteVector{4n}, S.Chain{S.ByteVector{32n}, S.End{}}}}, [D.bytes(d_ForkData(hl, o))]):
  match o:
    case FuluForkData_d.ForkData{+x0, +x1}:
      (MD.bytes_list([d_b4(hl, x0), d_b32(hl, x1)]), (([D.bytes(d_b4(hl, x0))], (MD.bytes_list([d_b32(hl, x1)]), (rs_b4(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([]), (rs_b32(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_b4(hl, x0), d_b32(hl, x1)], {==}, {==}, {==}, ehl)))

def d_SigningData(+hl: Nat, +o: FuluSigningData_d.SigningData) -> D.Digest:
  match o:
    case FuluSigningData_d.SigningData{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_b32(hl, x0), d_b32(hl, x1)], 0n)
def st_SigningData(+hl: Nat, -h: B.Buf, +o: FuluSigningData_d.SigningData, +seg: U32) -> {FuluSigningData_h.SigningData_root(hl, h, o, seg) == (h, d_SigningData(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSigningData_d.SigningData{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x0, seg), (h, d_b32(hl, x0)), st_b32(hl, h, x0, seg)) :
        {FuluSigningData_h.SigningData_rt0(hl, seg, x0, x1, _) == (h, d_SigningData(hl, FuluSigningData_d.SigningData{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluSigningData_h.SigningData_rt1(hl, seg, x0, x1, d_b32(hl, x0), _) == (h, d_SigningData(hl, FuluSigningData_d.SigningData{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_SigningData(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSigningData_d.SigningData) -> RR.roots(LV.v_SigningData(o), S.Container{["object_root", "domain"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}, [D.bytes(d_SigningData(hl, o))]):
  match o:
    case FuluSigningData_d.SigningData{+x0, +x1}:
      (MD.bytes_list([d_b32(hl, x0), d_b32(hl, x1)]), (([D.bytes(d_b32(hl, x0))], (MD.bytes_list([d_b32(hl, x1)]), (rs_b32(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([]), (rs_b32(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_b32(hl, x0), d_b32(hl, x1)], {==}, {==}, {==}, ehl)))

def d_DepositRequest(+hl: Nat, +o: FuluDepositRequest_d.DepositRequest) -> D.Digest:
  match o:
    case FuluDepositRequest_d.DepositRequest{+x0, +x1, +x2, +x3, +x4}: MD.rtree(3n, True{}, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)], 0n)
def st_DepositRequest(+hl: Nat, -h: B.Buf, +o: FuluDepositRequest_d.DepositRequest, +seg: U32) -> {FuluDepositRequest_h.DepositRequest_root(hl, h, o, seg) == (h, d_DepositRequest(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluDepositRequest_d.DepositRequest{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x0, seg), (h, d_b48(hl, x0)), st_b48(hl, h, x0, seg)) :
        {FuluDepositRequest_h.DepositRequest_rt0(hl, seg, x0, x1, x2, x3, x4, _) == (h, d_DepositRequest(hl, FuluDepositRequest_d.DepositRequest{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluDepositRequest_h.DepositRequest_rt1(hl, seg, x0, x1, x2, x3, x4, d_b48(hl, x0), _) == (h, d_DepositRequest(hl, FuluDepositRequest_d.DepositRequest{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x3, seg), (h, d_b96(hl, x3)), st_b96(hl, h, x3, seg)) :
        {FuluDepositRequest_h.DepositRequest_rt3(hl, seg, x0, x1, x2, x3, x4, d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), _) == (h, d_DepositRequest(hl, FuluDepositRequest_d.DepositRequest{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      {==}
def rs_DepositRequest(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluDepositRequest_d.DepositRequest) -> RR.roots(LV.v_DepositRequest(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "index"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}, [D.bytes(d_DepositRequest(hl, o))]):
  match o:
    case FuluDepositRequest_d.DepositRequest{+x0, +x1, +x2, +x3, +x4}:
      (MD.bytes_list([d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)]), (([D.bytes(d_b48(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)]), (rs_b48(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([d_b96(hl, x3), d_u64(hl, x4)]), (rs_u64(hl, ehl, x2), (([D.bytes(d_b96(hl, x3))], (MD.bytes_list([d_u64(hl, x4)]), (rs_b96(hl, ehl, x3), (([D.bytes(d_u64(hl, x4))], (MD.bytes_list([]), (rs_u64(hl, ehl, x4), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(5n, 3n, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)], {==}, {==}, {==}, ehl)))

def d_PendingDeposit(+hl: Nat, +o: FuluPendingDeposit_d.PendingDeposit) -> D.Digest:
  match o:
    case FuluPendingDeposit_d.PendingDeposit{+x0, +x1, +x2, +x3, +x4}: MD.rtree(3n, True{}, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)], 0n)
def st_PendingDeposit(+hl: Nat, -h: B.Buf, +o: FuluPendingDeposit_d.PendingDeposit, +seg: U32) -> {FuluPendingDeposit_h.PendingDeposit_root(hl, h, o, seg) == (h, d_PendingDeposit(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluPendingDeposit_d.PendingDeposit{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x0, seg), (h, d_b48(hl, x0)), st_b48(hl, h, x0, seg)) :
        {FuluPendingDeposit_h.PendingDeposit_rt0(hl, seg, x0, x1, x2, x3, x4, _) == (h, d_PendingDeposit(hl, FuluPendingDeposit_d.PendingDeposit{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluPendingDeposit_h.PendingDeposit_rt1(hl, seg, x0, x1, x2, x3, x4, d_b48(hl, x0), _) == (h, d_PendingDeposit(hl, FuluPendingDeposit_d.PendingDeposit{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x3, seg), (h, d_b96(hl, x3)), st_b96(hl, h, x3, seg)) :
        {FuluPendingDeposit_h.PendingDeposit_rt3(hl, seg, x0, x1, x2, x3, x4, d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), _) == (h, d_PendingDeposit(hl, FuluPendingDeposit_d.PendingDeposit{x0, x1, x2, x3, x4})) : B.Buf & D.Digest}
      {==}
def rs_PendingDeposit(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluPendingDeposit_d.PendingDeposit) -> RR.roots(LV.v_PendingDeposit(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "slot"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}, [D.bytes(d_PendingDeposit(hl, o))]):
  match o:
    case FuluPendingDeposit_d.PendingDeposit{+x0, +x1, +x2, +x3, +x4}:
      (MD.bytes_list([d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)]), (([D.bytes(d_b48(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)]), (rs_b48(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([d_b96(hl, x3), d_u64(hl, x4)]), (rs_u64(hl, ehl, x2), (([D.bytes(d_b96(hl, x3))], (MD.bytes_list([d_u64(hl, x4)]), (rs_b96(hl, ehl, x3), (([D.bytes(d_u64(hl, x4))], (MD.bytes_list([]), (rs_u64(hl, ehl, x4), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(5n, 3n, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3), d_u64(hl, x4)], {==}, {==}, {==}, ehl)))

def d_DepositData(+hl: Nat, +o: FuluDepositData_d.DepositData) -> D.Digest:
  match o:
    case FuluDepositData_d.DepositData{+x0, +x1, +x2, +x3}: MD.rtree(2n, True{}, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)], 0n)
def st_DepositData(+hl: Nat, -h: B.Buf, +o: FuluDepositData_d.DepositData, +seg: U32) -> {FuluDepositData_h.DepositData_root(hl, h, o, seg) == (h, d_DepositData(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluDepositData_d.DepositData{+x0, +x1, +x2, +x3}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x0, seg), (h, d_b48(hl, x0)), st_b48(hl, h, x0, seg)) :
        {FuluDepositData_h.DepositData_rt0(hl, seg, x0, x1, x2, x3, _) == (h, d_DepositData(hl, FuluDepositData_d.DepositData{x0, x1, x2, x3})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluDepositData_h.DepositData_rt1(hl, seg, x0, x1, x2, x3, d_b48(hl, x0), _) == (h, d_DepositData(hl, FuluDepositData_d.DepositData{x0, x1, x2, x3})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x3, seg), (h, d_b96(hl, x3)), st_b96(hl, h, x3, seg)) :
        {FuluDepositData_h.DepositData_rt3(hl, seg, x0, x1, x2, x3, d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), _) == (h, d_DepositData(hl, FuluDepositData_d.DepositData{x0, x1, x2, x3})) : B.Buf & D.Digest}
      {==}
def rs_DepositData(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluDepositData_d.DepositData) -> RR.roots(LV.v_DepositData(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}, [D.bytes(d_DepositData(hl, o))]):
  match o:
    case FuluDepositData_d.DepositData{+x0, +x1, +x2, +x3}:
      (MD.bytes_list([d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)]), (([D.bytes(d_b48(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)]), (rs_b48(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2), d_b96(hl, x3)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([d_b96(hl, x3)]), (rs_u64(hl, ehl, x2), (([D.bytes(d_b96(hl, x3))], (MD.bytes_list([]), (rs_b96(hl, ehl, x3), ({==}, {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(4n, 2n, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_b96(hl, x3)], {==}, {==}, {==}, ehl)))

def d_DepositMessage(+hl: Nat, +o: FuluDepositMessage_d.DepositMessage) -> D.Digest:
  match o:
    case FuluDepositMessage_d.DepositMessage{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2)], 0n)
def st_DepositMessage(+hl: Nat, -h: B.Buf, +o: FuluDepositMessage_d.DepositMessage, +seg: U32) -> {FuluDepositMessage_h.DepositMessage_root(hl, h, o, seg) == (h, d_DepositMessage(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluDepositMessage_d.DepositMessage{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x0, seg), (h, d_b48(hl, x0)), st_b48(hl, h, x0, seg)) :
        {FuluDepositMessage_h.DepositMessage_rt0(hl, seg, x0, x1, x2, _) == (h, d_DepositMessage(hl, FuluDepositMessage_d.DepositMessage{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluDepositMessage_h.DepositMessage_rt1(hl, seg, x0, x1, x2, d_b48(hl, x0), _) == (h, d_DepositMessage(hl, FuluDepositMessage_d.DepositMessage{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_DepositMessage(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluDepositMessage_d.DepositMessage) -> RR.roots(LV.v_DepositMessage(o), S.Container{["pubkey", "withdrawal_credentials", "amount"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}, [D.bytes(d_DepositMessage(hl, o))]):
  match o:
    case FuluDepositMessage_d.DepositMessage{+x0, +x1, +x2}:
      (MD.bytes_list([d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2)]), (([D.bytes(d_b48(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2)]), (rs_b48(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([]), (rs_u64(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2)], {==}, {==}, {==}, ehl)))

def d_Validator(+hl: Nat, +o: FuluValidator_d.Validator) -> D.Digest:
  match o:
    case FuluValidator_d.Validator{+x0, +x1, +x2, +x3, +x4, +x5, +x6, +x7}: MD.rtree(3n, True{}, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bool(hl, x3), d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)], 0n)
def st_Validator(+hl: Nat, -h: B.Buf, +o: FuluValidator_d.Validator, +seg: U32) -> {FuluValidator_h.Validator_root(hl, h, o, seg) == (h, d_Validator(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluValidator_d.Validator{+x0, +x1, +x2, +x3, +x4, +x5, +x6, +x7}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x0, seg), (h, d_b48(hl, x0)), st_b48(hl, h, x0, seg)) :
        {FuluValidator_h.Validator_rt0(hl, seg, x0, x1, x2, x3, x4, x5, x6, x7, _) == (h, d_Validator(hl, FuluValidator_d.Validator{x0, x1, x2, x3, x4, x5, x6, x7})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x1, seg), (h, d_b32(hl, x1)), st_b32(hl, h, x1, seg)) :
        {FuluValidator_h.Validator_rt1(hl, seg, x0, x1, x2, x3, x4, x5, x6, x7, d_b48(hl, x0), _) == (h, d_Validator(hl, FuluValidator_d.Validator{x0, x1, x2, x3, x4, x5, x6, x7})) : B.Buf & D.Digest}
      {==}
def rs_Validator(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluValidator_d.Validator) -> RR.roots(LV.v_Validator(o), S.Container{["pubkey", "withdrawal_credentials", "effective_balance", "slashed", "activation_eligibility_epoch", "activation_epoch", "exit_epoch", "withdrawable_epoch"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Boolean{}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}}}}, [D.bytes(d_Validator(hl, o))]):
  match o:
    case FuluValidator_d.Validator{+x0, +x1, +x2, +x3, +x4, +x5, +x6, +x7}:
      (MD.bytes_list([d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bool(hl, x3), d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)]), (([D.bytes(d_b48(hl, x0))], (MD.bytes_list([d_b32(hl, x1), d_u64(hl, x2), d_bool(hl, x3), d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)]), (rs_b48(hl, ehl, x0), (([D.bytes(d_b32(hl, x1))], (MD.bytes_list([d_u64(hl, x2), d_bool(hl, x3), d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)]), (rs_b32(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([d_bool(hl, x3), d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)]), (rs_u64(hl, ehl, x2), (([D.bytes(d_bool(hl, x3))], (MD.bytes_list([d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)]), (rs_bool(hl, ehl, x3), (([D.bytes(d_u64(hl, x4))], (MD.bytes_list([d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)]), (rs_u64(hl, ehl, x4), (([D.bytes(d_u64(hl, x5))], (MD.bytes_list([d_u64(hl, x6), d_u64(hl, x7)]), (rs_u64(hl, ehl, x5), (([D.bytes(d_u64(hl, x6))], (MD.bytes_list([d_u64(hl, x7)]), (rs_u64(hl, ehl, x6), (([D.bytes(d_u64(hl, x7))], (MD.bytes_list([]), (rs_u64(hl, ehl, x7), ({==}, {==})))), {==})))), {==})))), {==})))), {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(8n, 3n, hl, [d_b48(hl, x0), d_b32(hl, x1), d_u64(hl, x2), d_bool(hl, x3), d_u64(hl, x4), d_u64(hl, x5), d_u64(hl, x6), d_u64(hl, x7)], {==}, {==}, {==}, ehl)))

def d_ConsolidationRequest(+hl: Nat, +o: FuluConsolidationRequest_d.ConsolidationRequest) -> D.Digest:
  match o:
    case FuluConsolidationRequest_d.ConsolidationRequest{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_b20(hl, x0), d_b48(hl, x1), d_b48(hl, x2)], 0n)
def st_ConsolidationRequest(+hl: Nat, -h: B.Buf, +o: FuluConsolidationRequest_d.ConsolidationRequest, +seg: U32) -> {FuluConsolidationRequest_h.ConsolidationRequest_root(hl, h, o, seg) == (h, d_ConsolidationRequest(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluConsolidationRequest_d.ConsolidationRequest{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes20_h.b20_root(hl, h, x0, seg), (h, d_b20(hl, x0)), st_b20(hl, h, x0, seg)) :
        {FuluConsolidationRequest_h.ConsolidationRequest_rt0(hl, seg, x0, x1, x2, _) == (h, d_ConsolidationRequest(hl, FuluConsolidationRequest_d.ConsolidationRequest{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x1, seg), (h, d_b48(hl, x1)), st_b48(hl, h, x1, seg)) :
        {FuluConsolidationRequest_h.ConsolidationRequest_rt1(hl, seg, x0, x1, x2, d_b20(hl, x0), _) == (h, d_ConsolidationRequest(hl, FuluConsolidationRequest_d.ConsolidationRequest{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x2, seg), (h, d_b48(hl, x2)), st_b48(hl, h, x2, seg)) :
        {FuluConsolidationRequest_h.ConsolidationRequest_rt2(hl, seg, x0, x1, x2, d_b20(hl, x0), d_b48(hl, x1), _) == (h, d_ConsolidationRequest(hl, FuluConsolidationRequest_d.ConsolidationRequest{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_ConsolidationRequest(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluConsolidationRequest_d.ConsolidationRequest) -> RR.roots(LV.v_ConsolidationRequest(o), S.Container{["source_address", "source_pubkey", "target_pubkey"], S.Chain{S.ByteVector{20n}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{48n}, S.End{}}}}}, [D.bytes(d_ConsolidationRequest(hl, o))]):
  match o:
    case FuluConsolidationRequest_d.ConsolidationRequest{+x0, +x1, +x2}:
      (MD.bytes_list([d_b20(hl, x0), d_b48(hl, x1), d_b48(hl, x2)]), (([D.bytes(d_b20(hl, x0))], (MD.bytes_list([d_b48(hl, x1), d_b48(hl, x2)]), (rs_b20(hl, ehl, x0), (([D.bytes(d_b48(hl, x1))], (MD.bytes_list([d_b48(hl, x2)]), (rs_b48(hl, ehl, x1), (([D.bytes(d_b48(hl, x2))], (MD.bytes_list([]), (rs_b48(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_b20(hl, x0), d_b48(hl, x1), d_b48(hl, x2)], {==}, {==}, {==}, ehl)))

def d_WithdrawalRequest(+hl: Nat, +o: FuluWithdrawalRequest_d.WithdrawalRequest) -> D.Digest:
  match o:
    case FuluWithdrawalRequest_d.WithdrawalRequest{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_b20(hl, x0), d_b48(hl, x1), d_u64(hl, x2)], 0n)
def st_WithdrawalRequest(+hl: Nat, -h: B.Buf, +o: FuluWithdrawalRequest_d.WithdrawalRequest, +seg: U32) -> {FuluWithdrawalRequest_h.WithdrawalRequest_root(hl, h, o, seg) == (h, d_WithdrawalRequest(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluWithdrawalRequest_d.WithdrawalRequest{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes20_h.b20_root(hl, h, x0, seg), (h, d_b20(hl, x0)), st_b20(hl, h, x0, seg)) :
        {FuluWithdrawalRequest_h.WithdrawalRequest_rt0(hl, seg, x0, x1, x2, _) == (h, d_WithdrawalRequest(hl, FuluWithdrawalRequest_d.WithdrawalRequest{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x1, seg), (h, d_b48(hl, x1)), st_b48(hl, h, x1, seg)) :
        {FuluWithdrawalRequest_h.WithdrawalRequest_rt1(hl, seg, x0, x1, x2, d_b20(hl, x0), _) == (h, d_WithdrawalRequest(hl, FuluWithdrawalRequest_d.WithdrawalRequest{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_WithdrawalRequest(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluWithdrawalRequest_d.WithdrawalRequest) -> RR.roots(LV.v_WithdrawalRequest(o), S.Container{["source_address", "validator_pubkey", "amount"], S.Chain{S.ByteVector{20n}, S.Chain{S.ByteVector{48n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}, [D.bytes(d_WithdrawalRequest(hl, o))]):
  match o:
    case FuluWithdrawalRequest_d.WithdrawalRequest{+x0, +x1, +x2}:
      (MD.bytes_list([d_b20(hl, x0), d_b48(hl, x1), d_u64(hl, x2)]), (([D.bytes(d_b20(hl, x0))], (MD.bytes_list([d_b48(hl, x1), d_u64(hl, x2)]), (rs_b20(hl, ehl, x0), (([D.bytes(d_b48(hl, x1))], (MD.bytes_list([d_u64(hl, x2)]), (rs_b48(hl, ehl, x1), (([D.bytes(d_u64(hl, x2))], (MD.bytes_list([]), (rs_u64(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_b20(hl, x0), d_b48(hl, x1), d_u64(hl, x2)], {==}, {==}, {==}, ehl)))

def d_BLSToExecutionChange(+hl: Nat, +o: FuluBLSToExecutionChange_d.BLSToExecutionChange) -> D.Digest:
  match o:
    case FuluBLSToExecutionChange_d.BLSToExecutionChange{+x0, +x1, +x2}: MD.rtree(2n, True{}, hl, [d_u64(hl, x0), d_b48(hl, x1), d_b20(hl, x2)], 0n)
def st_BLSToExecutionChange(+hl: Nat, -h: B.Buf, +o: FuluBLSToExecutionChange_d.BLSToExecutionChange, +seg: U32) -> {FuluBLSToExecutionChange_h.BLSToExecutionChange_root(hl, h, o, seg) == (h, d_BLSToExecutionChange(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBLSToExecutionChange_d.BLSToExecutionChange{+x0, +x1, +x2}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(hl, h, x1, seg), (h, d_b48(hl, x1)), st_b48(hl, h, x1, seg)) :
        {FuluBLSToExecutionChange_h.BLSToExecutionChange_rt1(hl, seg, x0, x1, x2, d_u64(hl, x0), _) == (h, d_BLSToExecutionChange(hl, FuluBLSToExecutionChange_d.BLSToExecutionChange{x0, x1, x2})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes20_h.b20_root(hl, h, x2, seg), (h, d_b20(hl, x2)), st_b20(hl, h, x2, seg)) :
        {FuluBLSToExecutionChange_h.BLSToExecutionChange_rt2(hl, seg, x0, x1, x2, d_u64(hl, x0), d_b48(hl, x1), _) == (h, d_BLSToExecutionChange(hl, FuluBLSToExecutionChange_d.BLSToExecutionChange{x0, x1, x2})) : B.Buf & D.Digest}
      {==}
def rs_BLSToExecutionChange(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBLSToExecutionChange_d.BLSToExecutionChange) -> RR.roots(LV.v_BLSToExecutionChange(o), S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}, [D.bytes(d_BLSToExecutionChange(hl, o))]):
  match o:
    case FuluBLSToExecutionChange_d.BLSToExecutionChange{+x0, +x1, +x2}:
      (MD.bytes_list([d_u64(hl, x0), d_b48(hl, x1), d_b20(hl, x2)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_b48(hl, x1), d_b20(hl, x2)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_b48(hl, x1))], (MD.bytes_list([d_b20(hl, x2)]), (rs_b48(hl, ehl, x1), (([D.bytes(d_b20(hl, x2))], (MD.bytes_list([]), (rs_b20(hl, ehl, x2), ({==}, {==})))), {==})))), {==})))),
        RS.aggregate_digests(3n, 2n, hl, [d_u64(hl, x0), d_b48(hl, x1), d_b20(hl, x2)], {==}, {==}, {==}, ehl)))

def d_SignedBLSToExecutionChange(+hl: Nat, +o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange) -> D.Digest:
  match o:
    case FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_BLSToExecutionChange(hl, x0), d_b96(hl, x1)], 0n)
def st_SignedBLSToExecutionChange(+hl: Nat, -h: B.Buf, +o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, +seg: U32) -> {FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_root(hl, h, o, seg) == (h, d_SignedBLSToExecutionChange(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_root(hl, h, x0, seg), (h, d_BLSToExecutionChange(hl, x0)), st_BLSToExecutionChange(hl, h, x0, seg)) :
        {FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_rt0(hl, seg, x0, x1, _) == (h, d_SignedBLSToExecutionChange(hl, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{x0, x1})) : B.Buf & D.Digest}
      %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(hl, h, x1, seg), (h, d_b96(hl, x1)), st_b96(hl, h, x1, seg)) :
        {FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_rt1(hl, seg, x0, x1, d_BLSToExecutionChange(hl, x0), _) == (h, d_SignedBLSToExecutionChange(hl, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_SignedBLSToExecutionChange(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange) -> RR.roots(LV.v_SignedBLSToExecutionChange(o), S.Container{["message", "signature"], S.Chain{S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}, [D.bytes(d_SignedBLSToExecutionChange(hl, o))]):
  match o:
    case FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{+x0, +x1}:
      (MD.bytes_list([d_BLSToExecutionChange(hl, x0), d_b96(hl, x1)]), (([D.bytes(d_BLSToExecutionChange(hl, x0))], (MD.bytes_list([d_b96(hl, x1)]), (rs_BLSToExecutionChange(hl, ehl, x0), (([D.bytes(d_b96(hl, x1))], (MD.bytes_list([]), (rs_b96(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_BLSToExecutionChange(hl, x0), d_b96(hl, x1)], {==}, {==}, {==}, ehl)))

def d_Withdrawal(+hl: Nat, +o: FuluWithdrawal_d.Withdrawal) -> D.Digest:
  match o:
    case FuluWithdrawal_d.Withdrawal{+x0, +x1, +x2, +x3}: MD.rtree(2n, True{}, hl, [d_u64(hl, x0), d_u64(hl, x1), d_b20(hl, x2), d_u64(hl, x3)], 0n)
def st_Withdrawal(+hl: Nat, -h: B.Buf, +o: FuluWithdrawal_d.Withdrawal, +seg: U32) -> {FuluWithdrawal_h.Withdrawal_root(hl, h, o, seg) == (h, d_Withdrawal(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluWithdrawal_d.Withdrawal{+x0, +x1, +x2, +x3}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes20_h.b20_root(hl, h, x2, seg), (h, d_b20(hl, x2)), st_b20(hl, h, x2, seg)) :
        {FuluWithdrawal_h.Withdrawal_rt2(hl, seg, x0, x1, x2, x3, d_u64(hl, x0), d_u64(hl, x1), _) == (h, d_Withdrawal(hl, FuluWithdrawal_d.Withdrawal{x0, x1, x2, x3})) : B.Buf & D.Digest}
      {==}
def rs_Withdrawal(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluWithdrawal_d.Withdrawal) -> RR.roots(LV.v_Withdrawal(o), S.Container{["index", "validator_index", "address", "amount"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{20n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}, [D.bytes(d_Withdrawal(hl, o))]):
  match o:
    case FuluWithdrawal_d.Withdrawal{+x0, +x1, +x2, +x3}:
      (MD.bytes_list([d_u64(hl, x0), d_u64(hl, x1), d_b20(hl, x2), d_u64(hl, x3)]), (([D.bytes(d_u64(hl, x0))], (MD.bytes_list([d_u64(hl, x1), d_b20(hl, x2), d_u64(hl, x3)]), (rs_u64(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([d_b20(hl, x2), d_u64(hl, x3)]), (rs_u64(hl, ehl, x1), (([D.bytes(d_b20(hl, x2))], (MD.bytes_list([d_u64(hl, x3)]), (rs_b20(hl, ehl, x2), (([D.bytes(d_u64(hl, x3))], (MD.bytes_list([]), (rs_u64(hl, ehl, x3), ({==}, {==})))), {==})))), {==})))), {==})))),
        RS.aggregate_digests(4n, 2n, hl, [d_u64(hl, x0), d_u64(hl, x1), d_b20(hl, x2), d_u64(hl, x3)], {==}, {==}, {==}, ehl)))

def d_BlobIdentifier(+hl: Nat, +o: FuluBlobIdentifier_d.BlobIdentifier) -> D.Digest:
  match o:
    case FuluBlobIdentifier_d.BlobIdentifier{+x0, +x1}: MD.rtree(1n, True{}, hl, [d_b32(hl, x0), d_u64(hl, x1)], 0n)
def st_BlobIdentifier(+hl: Nat, -h: B.Buf, +o: FuluBlobIdentifier_d.BlobIdentifier, +seg: U32) -> {FuluBlobIdentifier_h.BlobIdentifier_root(hl, h, o, seg) == (h, d_BlobIdentifier(hl, o)) : B.Buf & D.Digest}:
  match o:
    case FuluBlobIdentifier_d.BlobIdentifier{+x0, +x1}:
      %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(hl, h, x0, seg), (h, d_b32(hl, x0)), st_b32(hl, h, x0, seg)) :
        {FuluBlobIdentifier_h.BlobIdentifier_rt0(hl, seg, x0, x1, _) == (h, d_BlobIdentifier(hl, FuluBlobIdentifier_d.BlobIdentifier{x0, x1})) : B.Buf & D.Digest}
      {==}
def rs_BlobIdentifier(+hl: Nat, +ehl: {hl == 64n : Nat}, +o: FuluBlobIdentifier_d.BlobIdentifier) -> RR.roots(LV.v_BlobIdentifier(o), S.Container{["block_root", "index"], S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, [D.bytes(d_BlobIdentifier(hl, o))]):
  match o:
    case FuluBlobIdentifier_d.BlobIdentifier{+x0, +x1}:
      (MD.bytes_list([d_b32(hl, x0), d_u64(hl, x1)]), (([D.bytes(d_b32(hl, x0))], (MD.bytes_list([d_u64(hl, x1)]), (rs_b32(hl, ehl, x0), (([D.bytes(d_u64(hl, x1))], (MD.bytes_list([]), (rs_u64(hl, ehl, x1), ({==}, {==})))), {==})))),
        RS.aggregate_digests(2n, 1n, hl, [d_b32(hl, x0), d_u64(hl, x1)], {==}, {==}, {==}, ehl)))

# boolean: the root of every boolean object is its specification root.
law boolean_root_correct:
  for -h: B.Buf
  for +o: Bool
  RR.roots(LV.v_bool(o), Spec.boolean(), [D.bytes(Pair.snd(B.Buf, D.Digest, boolean_h.boolean_hash_tree_root(h, o)))])
def boolean_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, boolean_h.bool_root(64n, h, o, 0), (h, d_bool(64n, o)), st_bool(64n, h, o, 0)) :
    RR.roots(LV.v_bool(o), Spec.boolean(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_bool(64n, {==}, o)

# uint64: the root of every uint64 object is its specification root.
law uint64_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.uint64(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint64_h.uint64_hash_tree_root(h, o)))])
def uint64_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.uint64(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def uint64_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law uint64_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.uint64(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint64_h.uint64_hash_tree_root(h, o)))])
def uint64_decoded_root_correct(x0, x1, h, o, e):
  %uint64_view_link(x0, x1) : RR.roots(_, Spec.uint64(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint64_h.uint64_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.uint64(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint64_h.uint64_hash_tree_root(h, o)))])
  uint64_root_correct(h, o)

# uint256: the root of every uint256 object is its specification root.
law uint256_root_correct:
  for -h: B.Buf
  for +o: uint256_d.Uint256
  RR.roots(LV.v_u256(o), Spec.uint256(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint256_h.uint256_hash_tree_root(h, o)))])
def uint256_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint256_h.u256_root(64n, h, o, 0), (h, d_u256(64n, o)), st_u256(64n, h, o, 0)) :
    RR.roots(LV.v_u256(o), Spec.uint256(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u256(64n, {==}, o)

def uint256_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_u256(uint256_d.Uint256{x0, x1, x2, x3, x4, x5, x6, x7}) == S.UnsignedValue{P.UInt{x0, x1, x2, x3, x4, x5, x6, x7}} : S.Value}: {==}
law uint256_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: uint256_d.Uint256
  for +e: {o == uint256_d.Uint256{x0, x1, x2, x3, x4, x5, x6, x7} : uint256_d.Uint256}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, x2, x3, x4, x5, x6, x7}}, Spec.uint256(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint256_h.uint256_hash_tree_root(h, o)))])
def uint256_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %uint256_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.uint256(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint256_h.uint256_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u256(_), Spec.uint256(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint256_h.uint256_hash_tree_root(h, o)))])
  uint256_root_correct(h, o)

# Bytes4: the root of every Bytes4 object is its specification root.
law Bytes4_root_correct:
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  RR.roots(LV.v_b4(o), Spec.Bytes4(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes4_h.Bytes4_hash_tree_root(h, o)))])
def Bytes4_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(64n, h, o, 0), (h, d_b4(64n, o)), st_b4(64n, h, o, 0)) :
    RR.roots(LV.v_b4(o), Spec.Bytes4(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b4(64n, {==}, o)

def Bytes4_view_link(+x0: U32) -> {LV.v_b4(FuluBytes4_d.Bytes4{x0}) == S.BytesValue{F.limbs([x0])} : S.Value}: {==}
law Bytes4_decoded_root_correct:
  for +x0: U32
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  for +e: {o == FuluBytes4_d.Bytes4{x0} : FuluBytes4_d.Bytes4}
  RR.roots(S.BytesValue{F.limbs([x0])}, Spec.Bytes4(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes4_h.Bytes4_hash_tree_root(h, o)))])
def Bytes4_decoded_root_correct(x0, h, o, e):
  %Bytes4_view_link(x0) : RR.roots(_, Spec.Bytes4(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes4_h.Bytes4_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b4(_), Spec.Bytes4(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes4_h.Bytes4_hash_tree_root(h, o)))])
  Bytes4_root_correct(h, o)

# Bytes32: the root of every Bytes32 object is its specification root.
law Bytes32_root_correct:
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  RR.roots(LV.v_b32(o), Spec.Bytes32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes32_h.Bytes32_hash_tree_root(h, o)))])
def Bytes32_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(64n, h, o, 0), (h, d_b32(64n, o)), st_b32(64n, h, o, 0)) :
    RR.roots(LV.v_b32(o), Spec.Bytes32(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b32(64n, {==}, o)

def Bytes32_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_b32(FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])} : S.Value}: {==}
law Bytes32_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  for +e: {o == FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7} : FuluBytes32_d.Bytes32}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, Spec.Bytes32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes32_h.Bytes32_hash_tree_root(h, o)))])
def Bytes32_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %Bytes32_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.Bytes32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes32_h.Bytes32_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b32(_), Spec.Bytes32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes32_h.Bytes32_hash_tree_root(h, o)))])
  Bytes32_root_correct(h, o)

# Bytes48: the root of every Bytes48 object is its specification root.
law Bytes48_root_correct:
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  RR.roots(LV.v_b48(o), Spec.Bytes48(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes48_h.Bytes48_hash_tree_root(h, o)))])
def Bytes48_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(64n, h, o, 0), (h, d_b48(64n, o)), st_b48(64n, h, o, 0)) :
    RR.roots(LV.v_b48(o), Spec.Bytes48(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b48(64n, {==}, o)

def Bytes48_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32) -> {LV.v_b48(FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])} : S.Value}: {==}
law Bytes48_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  for +e: {o == FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11} : FuluBytes48_d.Bytes48}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, Spec.Bytes48(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes48_h.Bytes48_hash_tree_root(h, o)))])
def Bytes48_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, h, o, e):
  %Bytes48_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) : RR.roots(_, Spec.Bytes48(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes48_h.Bytes48_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b48(_), Spec.Bytes48(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes48_h.Bytes48_hash_tree_root(h, o)))])
  Bytes48_root_correct(h, o)

# Bytes96: the root of every Bytes96 object is its specification root.
law Bytes96_root_correct:
  for -h: B.Buf
  for +o: FuluBytes96_d.Bytes96
  RR.roots(LV.v_b96(o), Spec.Bytes96(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes96_h.Bytes96_hash_tree_root(h, o)))])
def Bytes96_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(64n, h, o, 0), (h, d_b96(64n, o)), st_b96(64n, h, o, 0)) :
    RR.roots(LV.v_b96(o), Spec.Bytes96(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b96(64n, {==}, o)

def Bytes96_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32) -> {LV.v_b96(FuluBytes96_d.Bytes96{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23])} : S.Value}: {==}
law Bytes96_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for -h: B.Buf
  for +o: FuluBytes96_d.Bytes96
  for +e: {o == FuluBytes96_d.Bytes96{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23} : FuluBytes96_d.Bytes96}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23])}, Spec.Bytes96(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes96_h.Bytes96_hash_tree_root(h, o)))])
def Bytes96_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, h, o, e):
  %Bytes96_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23) : RR.roots(_, Spec.Bytes96(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes96_h.Bytes96_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b96(_), Spec.Bytes96(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes96_h.Bytes96_hash_tree_root(h, o)))])
  Bytes96_root_correct(h, o)

# Bytes8: the root of every Bytes8 object is its specification root.
law Bytes8_root_correct:
  for -h: B.Buf
  for +o: FuluBytes8_d.Bytes8
  RR.roots(LV.v_b8(o), Spec.Bytes8(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes8_h.Bytes8_hash_tree_root(h, o)))])
def Bytes8_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes8_h.b8_root(64n, h, o, 0), (h, d_b8(64n, o)), st_b8(64n, h, o, 0)) :
    RR.roots(LV.v_b8(o), Spec.Bytes8(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b8(64n, {==}, o)

def Bytes8_view_link(+x0: U32, +x1: U32) -> {LV.v_b8(FuluBytes8_d.Bytes8{x0, x1}) == S.BytesValue{F.limbs([x0, x1])} : S.Value}: {==}
law Bytes8_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: FuluBytes8_d.Bytes8
  for +e: {o == FuluBytes8_d.Bytes8{x0, x1} : FuluBytes8_d.Bytes8}
  RR.roots(S.BytesValue{F.limbs([x0, x1])}, Spec.Bytes8(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes8_h.Bytes8_hash_tree_root(h, o)))])
def Bytes8_decoded_root_correct(x0, x1, h, o, e):
  %Bytes8_view_link(x0, x1) : RR.roots(_, Spec.Bytes8(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes8_h.Bytes8_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b8(_), Spec.Bytes8(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes8_h.Bytes8_hash_tree_root(h, o)))])
  Bytes8_root_correct(h, o)

# Bytes20: the root of every Bytes20 object is its specification root.
law Bytes20_root_correct:
  for -h: B.Buf
  for +o: FuluBytes20_d.Bytes20
  RR.roots(LV.v_b20(o), Spec.Bytes20(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes20_h.Bytes20_hash_tree_root(h, o)))])
def Bytes20_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes20_h.b20_root(64n, h, o, 0), (h, d_b20(64n, o)), st_b20(64n, h, o, 0)) :
    RR.roots(LV.v_b20(o), Spec.Bytes20(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b20(64n, {==}, o)

def Bytes20_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32) -> {LV.v_b20(FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4])} : S.Value}: {==}
law Bytes20_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for -h: B.Buf
  for +o: FuluBytes20_d.Bytes20
  for +e: {o == FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4} : FuluBytes20_d.Bytes20}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4])}, Spec.Bytes20(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes20_h.Bytes20_hash_tree_root(h, o)))])
def Bytes20_decoded_root_correct(x0, x1, x2, x3, x4, h, o, e):
  %Bytes20_view_link(x0, x1, x2, x3, x4) : RR.roots(_, Spec.Bytes20(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes20_h.Bytes20_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b20(_), Spec.Bytes20(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes20_h.Bytes20_hash_tree_root(h, o)))])
  Bytes20_root_correct(h, o)

# Slot: the root of every Slot object is its specification root.
law Slot_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.Slot(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSlot_h.Slot_hash_tree_root(h, o)))])
def Slot_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.Slot(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def Slot_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law Slot_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.Slot(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSlot_h.Slot_hash_tree_root(h, o)))])
def Slot_decoded_root_correct(x0, x1, h, o, e):
  %Slot_view_link(x0, x1) : RR.roots(_, Spec.Slot(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSlot_h.Slot_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.Slot(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSlot_h.Slot_hash_tree_root(h, o)))])
  Slot_root_correct(h, o)

# Epoch: the root of every Epoch object is its specification root.
law Epoch_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.Epoch(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEpoch_h.Epoch_hash_tree_root(h, o)))])
def Epoch_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.Epoch(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def Epoch_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law Epoch_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.Epoch(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEpoch_h.Epoch_hash_tree_root(h, o)))])
def Epoch_decoded_root_correct(x0, x1, h, o, e):
  %Epoch_view_link(x0, x1) : RR.roots(_, Spec.Epoch(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEpoch_h.Epoch_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.Epoch(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEpoch_h.Epoch_hash_tree_root(h, o)))])
  Epoch_root_correct(h, o)

# Gwei: the root of every Gwei object is its specification root.
law Gwei_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.Gwei(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluGwei_h.Gwei_hash_tree_root(h, o)))])
def Gwei_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.Gwei(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def Gwei_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law Gwei_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.Gwei(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluGwei_h.Gwei_hash_tree_root(h, o)))])
def Gwei_decoded_root_correct(x0, x1, h, o, e):
  %Gwei_view_link(x0, x1) : RR.roots(_, Spec.Gwei(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluGwei_h.Gwei_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.Gwei(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluGwei_h.Gwei_hash_tree_root(h, o)))])
  Gwei_root_correct(h, o)

# Hash32: the root of every Hash32 object is its specification root.
law Hash32_root_correct:
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  RR.roots(LV.v_b32(o), Spec.Hash32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHash32_h.Hash32_hash_tree_root(h, o)))])
def Hash32_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(64n, h, o, 0), (h, d_b32(64n, o)), st_b32(64n, h, o, 0)) :
    RR.roots(LV.v_b32(o), Spec.Hash32(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b32(64n, {==}, o)

def Hash32_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_b32(FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])} : S.Value}: {==}
law Hash32_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  for +e: {o == FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7} : FuluBytes32_d.Bytes32}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, Spec.Hash32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHash32_h.Hash32_hash_tree_root(h, o)))])
def Hash32_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %Hash32_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.Hash32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHash32_h.Hash32_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b32(_), Spec.Hash32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHash32_h.Hash32_hash_tree_root(h, o)))])
  Hash32_root_correct(h, o)

# Version: the root of every Version object is its specification root.
law Version_root_correct:
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  RR.roots(LV.v_b4(o), Spec.Version(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersion_h.Version_hash_tree_root(h, o)))])
def Version_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(64n, h, o, 0), (h, d_b4(64n, o)), st_b4(64n, h, o, 0)) :
    RR.roots(LV.v_b4(o), Spec.Version(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b4(64n, {==}, o)

def Version_view_link(+x0: U32) -> {LV.v_b4(FuluBytes4_d.Bytes4{x0}) == S.BytesValue{F.limbs([x0])} : S.Value}: {==}
law Version_decoded_root_correct:
  for +x0: U32
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  for +e: {o == FuluBytes4_d.Bytes4{x0} : FuluBytes4_d.Bytes4}
  RR.roots(S.BytesValue{F.limbs([x0])}, Spec.Version(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersion_h.Version_hash_tree_root(h, o)))])
def Version_decoded_root_correct(x0, h, o, e):
  %Version_view_link(x0) : RR.roots(_, Spec.Version(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersion_h.Version_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b4(_), Spec.Version(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersion_h.Version_hash_tree_root(h, o)))])
  Version_root_correct(h, o)

# DomainType: the root of every DomainType object is its specification root.
law DomainType_root_correct:
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  RR.roots(LV.v_b4(o), Spec.DomainType(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomainType_h.DomainType_hash_tree_root(h, o)))])
def DomainType_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(64n, h, o, 0), (h, d_b4(64n, o)), st_b4(64n, h, o, 0)) :
    RR.roots(LV.v_b4(o), Spec.DomainType(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b4(64n, {==}, o)

def DomainType_view_link(+x0: U32) -> {LV.v_b4(FuluBytes4_d.Bytes4{x0}) == S.BytesValue{F.limbs([x0])} : S.Value}: {==}
law DomainType_decoded_root_correct:
  for +x0: U32
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  for +e: {o == FuluBytes4_d.Bytes4{x0} : FuluBytes4_d.Bytes4}
  RR.roots(S.BytesValue{F.limbs([x0])}, Spec.DomainType(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomainType_h.DomainType_hash_tree_root(h, o)))])
def DomainType_decoded_root_correct(x0, h, o, e):
  %DomainType_view_link(x0) : RR.roots(_, Spec.DomainType(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomainType_h.DomainType_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b4(_), Spec.DomainType(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomainType_h.DomainType_hash_tree_root(h, o)))])
  DomainType_root_correct(h, o)

# BLSSignature: the root of every BLSSignature object is its specification root.
law BLSSignature_root_correct:
  for -h: B.Buf
  for +o: FuluBytes96_d.Bytes96
  RR.roots(LV.v_b96(o), Spec.BLSSignature(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSSignature_h.BLSSignature_hash_tree_root(h, o)))])
def BLSSignature_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(64n, h, o, 0), (h, d_b96(64n, o)), st_b96(64n, h, o, 0)) :
    RR.roots(LV.v_b96(o), Spec.BLSSignature(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b96(64n, {==}, o)

def BLSSignature_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32) -> {LV.v_b96(FuluBytes96_d.Bytes96{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23])} : S.Value}: {==}
law BLSSignature_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for -h: B.Buf
  for +o: FuluBytes96_d.Bytes96
  for +e: {o == FuluBytes96_d.Bytes96{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23} : FuluBytes96_d.Bytes96}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23])}, Spec.BLSSignature(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSSignature_h.BLSSignature_hash_tree_root(h, o)))])
def BLSSignature_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, h, o, e):
  %BLSSignature_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23) : RR.roots(_, Spec.BLSSignature(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSSignature_h.BLSSignature_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b96(_), Spec.BLSSignature(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSSignature_h.BLSSignature_hash_tree_root(h, o)))])
  BLSSignature_root_correct(h, o)

# VersionedHash: the root of every VersionedHash object is its specification root.
law VersionedHash_root_correct:
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  RR.roots(LV.v_b32(o), Spec.VersionedHash(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersionedHash_h.VersionedHash_hash_tree_root(h, o)))])
def VersionedHash_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(64n, h, o, 0), (h, d_b32(64n, o)), st_b32(64n, h, o, 0)) :
    RR.roots(LV.v_b32(o), Spec.VersionedHash(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b32(64n, {==}, o)

def VersionedHash_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_b32(FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])} : S.Value}: {==}
law VersionedHash_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  for +e: {o == FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7} : FuluBytes32_d.Bytes32}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, Spec.VersionedHash(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersionedHash_h.VersionedHash_hash_tree_root(h, o)))])
def VersionedHash_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %VersionedHash_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.VersionedHash(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersionedHash_h.VersionedHash_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b32(_), Spec.VersionedHash(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersionedHash_h.VersionedHash_hash_tree_root(h, o)))])
  VersionedHash_root_correct(h, o)

# G1Point: the root of every G1Point object is its specification root.
law G1Point_root_correct:
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  RR.roots(LV.v_b48(o), Spec.G1Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG1Point_h.G1Point_hash_tree_root(h, o)))])
def G1Point_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(64n, h, o, 0), (h, d_b48(64n, o)), st_b48(64n, h, o, 0)) :
    RR.roots(LV.v_b48(o), Spec.G1Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b48(64n, {==}, o)

def G1Point_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32) -> {LV.v_b48(FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])} : S.Value}: {==}
law G1Point_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  for +e: {o == FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11} : FuluBytes48_d.Bytes48}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, Spec.G1Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG1Point_h.G1Point_hash_tree_root(h, o)))])
def G1Point_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, h, o, e):
  %G1Point_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) : RR.roots(_, Spec.G1Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG1Point_h.G1Point_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b48(_), Spec.G1Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG1Point_h.G1Point_hash_tree_root(h, o)))])
  G1Point_root_correct(h, o)

# G2Point: the root of every G2Point object is its specification root.
law G2Point_root_correct:
  for -h: B.Buf
  for +o: FuluBytes96_d.Bytes96
  RR.roots(LV.v_b96(o), Spec.G2Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG2Point_h.G2Point_hash_tree_root(h, o)))])
def G2Point_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes96_h.b96_root(64n, h, o, 0), (h, d_b96(64n, o)), st_b96(64n, h, o, 0)) :
    RR.roots(LV.v_b96(o), Spec.G2Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b96(64n, {==}, o)

def G2Point_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32) -> {LV.v_b96(FuluBytes96_d.Bytes96{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23])} : S.Value}: {==}
law G2Point_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for -h: B.Buf
  for +o: FuluBytes96_d.Bytes96
  for +e: {o == FuluBytes96_d.Bytes96{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23} : FuluBytes96_d.Bytes96}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23])}, Spec.G2Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG2Point_h.G2Point_hash_tree_root(h, o)))])
def G2Point_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, h, o, e):
  %G2Point_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23) : RR.roots(_, Spec.G2Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG2Point_h.G2Point_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b96(_), Spec.G2Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG2Point_h.G2Point_hash_tree_root(h, o)))])
  G2Point_root_correct(h, o)

# Fork: the root of every Fork object is its specification root.
law Fork_root_correct:
  for -h: B.Buf
  for +o: FuluFork_d.Fork
  RR.roots(LV.v_Fork(o), Spec.Fork(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluFork_h.Fork_hash_tree_root(h, o)))])
def Fork_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluFork_h.Fork_root(64n, h, o, 0), (h, d_Fork(64n, o)), st_Fork(64n, h, o, 0)) :
    RR.roots(LV.v_Fork(o), Spec.Fork(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_Fork(64n, {==}, o)

def Fork_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32) -> {LV.v_Fork(FuluFork_d.Fork{FuluBytes4_d.Bytes4{x0}, FuluBytes4_d.Bytes4{x1}, O.U64{x2, x3}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0])}, S.Items{S.BytesValue{F.limbs([x1])}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}} : S.Value}: {==}
law Fork_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for -h: B.Buf
  for +o: FuluFork_d.Fork
  for +e: {o == FuluFork_d.Fork{FuluBytes4_d.Bytes4{x0}, FuluBytes4_d.Bytes4{x1}, O.U64{x2, x3}} : FuluFork_d.Fork}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0])}, S.Items{S.BytesValue{F.limbs([x1])}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}, Spec.Fork(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluFork_h.Fork_hash_tree_root(h, o)))])
def Fork_decoded_root_correct(x0, x1, x2, x3, h, o, e):
  %Fork_view_link(x0, x1, x2, x3) : RR.roots(_, Spec.Fork(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluFork_h.Fork_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_Fork(_), Spec.Fork(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluFork_h.Fork_hash_tree_root(h, o)))])
  Fork_root_correct(h, o)

# SyncAggregate: the root of every SyncAggregate object is its specification root.
law SyncAggregate_root_correct:
  for -h: B.Buf
  for +o: FuluSyncAggregate_d.SyncAggregate
  RR.roots(LV.v_SyncAggregate(o), Spec.SyncAggregate(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregate_h.SyncAggregate_hash_tree_root(h, o)))])
def SyncAggregate_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSyncAggregate_h.SyncAggregate_root(64n, h, o, 0), (h, d_SyncAggregate(64n, o)), st_SyncAggregate(64n, h, o, 0)) :
    RR.roots(LV.v_SyncAggregate(o), Spec.SyncAggregate(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SyncAggregate(64n, {==}, o)

# SyncAggregatorSelectionData: the root of every SyncAggregatorSelectionData object is its specification root.
law SyncAggregatorSelectionData_root_correct:
  for -h: B.Buf
  for +o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData
  RR.roots(LV.v_SyncAggregatorSelectionData(o), Spec.SyncAggregatorSelectionData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_hash_tree_root(h, o)))])
def SyncAggregatorSelectionData_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_root(64n, h, o, 0), (h, d_SyncAggregatorSelectionData(64n, o)), st_SyncAggregatorSelectionData(64n, h, o, 0)) :
    RR.roots(LV.v_SyncAggregatorSelectionData(o), Spec.SyncAggregatorSelectionData(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SyncAggregatorSelectionData(64n, {==}, o)

def SyncAggregatorSelectionData_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32) -> {LV.v_SyncAggregatorSelectionData(FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData{O.U64{x0, x1}, O.U64{x2, x3}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}} : S.Value}: {==}
law SyncAggregatorSelectionData_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for -h: B.Buf
  for +o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData
  for +e: {o == FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData{O.U64{x0, x1}, O.U64{x2, x3}} : FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}, Spec.SyncAggregatorSelectionData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_hash_tree_root(h, o)))])
def SyncAggregatorSelectionData_decoded_root_correct(x0, x1, x2, x3, h, o, e):
  %SyncAggregatorSelectionData_view_link(x0, x1, x2, x3) : RR.roots(_, Spec.SyncAggregatorSelectionData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SyncAggregatorSelectionData(_), Spec.SyncAggregatorSelectionData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_hash_tree_root(h, o)))])
  SyncAggregatorSelectionData_root_correct(h, o)

# PowBlock: the root of every PowBlock object is its specification root.
law PowBlock_root_correct:
  for -h: B.Buf
  for +o: FuluPowBlock_d.PowBlock
  RR.roots(LV.v_PowBlock(o), Spec.PowBlock(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPowBlock_h.PowBlock_hash_tree_root(h, o)))])
def PowBlock_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluPowBlock_h.PowBlock_root(64n, h, o, 0), (h, d_PowBlock(64n, o)), st_PowBlock(64n, h, o, 0)) :
    RR.roots(LV.v_PowBlock(o), Spec.PowBlock(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_PowBlock(64n, {==}, o)

def PowBlock_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32) -> {LV.v_PowBlock(FuluPowBlock_d.PowBlock{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}, uint256_d.Uint256{x16, x17, x18, x19, x20, x21, x22, x23}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.Items{S.UnsignedValue{P.UInt{x16, x17, x18, x19, x20, x21, x22, x23}}, S.EmptyItems{}}}}} : S.Value}: {==}
law PowBlock_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for -h: B.Buf
  for +o: FuluPowBlock_d.PowBlock
  for +e: {o == FuluPowBlock_d.PowBlock{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}, uint256_d.Uint256{x16, x17, x18, x19, x20, x21, x22, x23}} : FuluPowBlock_d.PowBlock}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.Items{S.UnsignedValue{P.UInt{x16, x17, x18, x19, x20, x21, x22, x23}}, S.EmptyItems{}}}}}, Spec.PowBlock(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPowBlock_h.PowBlock_hash_tree_root(h, o)))])
def PowBlock_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, h, o, e):
  %PowBlock_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23) : RR.roots(_, Spec.PowBlock(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPowBlock_h.PowBlock_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_PowBlock(_), Spec.PowBlock(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPowBlock_h.PowBlock_hash_tree_root(h, o)))])
  PowBlock_root_correct(h, o)

# CommitteeIndex: the root of every CommitteeIndex object is its specification root.
law CommitteeIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.CommitteeIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitteeIndex_h.CommitteeIndex_hash_tree_root(h, o)))])
def CommitteeIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.CommitteeIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def CommitteeIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law CommitteeIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.CommitteeIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitteeIndex_h.CommitteeIndex_hash_tree_root(h, o)))])
def CommitteeIndex_decoded_root_correct(x0, x1, h, o, e):
  %CommitteeIndex_view_link(x0, x1) : RR.roots(_, Spec.CommitteeIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitteeIndex_h.CommitteeIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.CommitteeIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitteeIndex_h.CommitteeIndex_hash_tree_root(h, o)))])
  CommitteeIndex_root_correct(h, o)

# ValidatorIndex: the root of every ValidatorIndex object is its specification root.
law ValidatorIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.ValidatorIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidatorIndex_h.ValidatorIndex_hash_tree_root(h, o)))])
def ValidatorIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.ValidatorIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def ValidatorIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law ValidatorIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.ValidatorIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidatorIndex_h.ValidatorIndex_hash_tree_root(h, o)))])
def ValidatorIndex_decoded_root_correct(x0, x1, h, o, e):
  %ValidatorIndex_view_link(x0, x1) : RR.roots(_, Spec.ValidatorIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidatorIndex_h.ValidatorIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.ValidatorIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidatorIndex_h.ValidatorIndex_hash_tree_root(h, o)))])
  ValidatorIndex_root_correct(h, o)

# PendingConsolidation: the root of every PendingConsolidation object is its specification root.
law PendingConsolidation_root_correct:
  for -h: B.Buf
  for +o: FuluPendingConsolidation_d.PendingConsolidation
  RR.roots(LV.v_PendingConsolidation(o), Spec.PendingConsolidation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingConsolidation_h.PendingConsolidation_hash_tree_root(h, o)))])
def PendingConsolidation_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluPendingConsolidation_h.PendingConsolidation_root(64n, h, o, 0), (h, d_PendingConsolidation(64n, o)), st_PendingConsolidation(64n, h, o, 0)) :
    RR.roots(LV.v_PendingConsolidation(o), Spec.PendingConsolidation(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_PendingConsolidation(64n, {==}, o)

def PendingConsolidation_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32) -> {LV.v_PendingConsolidation(FuluPendingConsolidation_d.PendingConsolidation{O.U64{x0, x1}, O.U64{x2, x3}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}} : S.Value}: {==}
law PendingConsolidation_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for -h: B.Buf
  for +o: FuluPendingConsolidation_d.PendingConsolidation
  for +e: {o == FuluPendingConsolidation_d.PendingConsolidation{O.U64{x0, x1}, O.U64{x2, x3}} : FuluPendingConsolidation_d.PendingConsolidation}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}, Spec.PendingConsolidation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingConsolidation_h.PendingConsolidation_hash_tree_root(h, o)))])
def PendingConsolidation_decoded_root_correct(x0, x1, x2, x3, h, o, e):
  %PendingConsolidation_view_link(x0, x1, x2, x3) : RR.roots(_, Spec.PendingConsolidation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingConsolidation_h.PendingConsolidation_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_PendingConsolidation(_), Spec.PendingConsolidation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingConsolidation_h.PendingConsolidation_hash_tree_root(h, o)))])
  PendingConsolidation_root_correct(h, o)

# PendingPartialWithdrawal: the root of every PendingPartialWithdrawal object is its specification root.
law PendingPartialWithdrawal_root_correct:
  for -h: B.Buf
  for +o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal
  RR.roots(LV.v_PendingPartialWithdrawal(o), Spec.PendingPartialWithdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_hash_tree_root(h, o)))])
def PendingPartialWithdrawal_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_root(64n, h, o, 0), (h, d_PendingPartialWithdrawal(64n, o)), st_PendingPartialWithdrawal(64n, h, o, 0)) :
    RR.roots(LV.v_PendingPartialWithdrawal(o), Spec.PendingPartialWithdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_PendingPartialWithdrawal(64n, {==}, o)

def PendingPartialWithdrawal_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32) -> {LV.v_PendingPartialWithdrawal(FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal{O.U64{x0, x1}, O.U64{x2, x3}, O.U64{x4, x5}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x4, x5, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}} : S.Value}: {==}
law PendingPartialWithdrawal_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for -h: B.Buf
  for +o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal
  for +e: {o == FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal{O.U64{x0, x1}, O.U64{x2, x3}, O.U64{x4, x5}} : FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x4, x5, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}, Spec.PendingPartialWithdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_hash_tree_root(h, o)))])
def PendingPartialWithdrawal_decoded_root_correct(x0, x1, x2, x3, x4, x5, h, o, e):
  %PendingPartialWithdrawal_view_link(x0, x1, x2, x3, x4, x5) : RR.roots(_, Spec.PendingPartialWithdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_PendingPartialWithdrawal(_), Spec.PendingPartialWithdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_hash_tree_root(h, o)))])
  PendingPartialWithdrawal_root_correct(h, o)

# VoluntaryExit: the root of every VoluntaryExit object is its specification root.
law VoluntaryExit_root_correct:
  for -h: B.Buf
  for +o: FuluVoluntaryExit_d.VoluntaryExit
  RR.roots(LV.v_VoluntaryExit(o), Spec.VoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVoluntaryExit_h.VoluntaryExit_hash_tree_root(h, o)))])
def VoluntaryExit_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluVoluntaryExit_h.VoluntaryExit_root(64n, h, o, 0), (h, d_VoluntaryExit(64n, o)), st_VoluntaryExit(64n, h, o, 0)) :
    RR.roots(LV.v_VoluntaryExit(o), Spec.VoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_VoluntaryExit(64n, {==}, o)

def VoluntaryExit_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32) -> {LV.v_VoluntaryExit(FuluVoluntaryExit_d.VoluntaryExit{O.U64{x0, x1}, O.U64{x2, x3}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}} : S.Value}: {==}
law VoluntaryExit_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for -h: B.Buf
  for +o: FuluVoluntaryExit_d.VoluntaryExit
  for +e: {o == FuluVoluntaryExit_d.VoluntaryExit{O.U64{x0, x1}, O.U64{x2, x3}} : FuluVoluntaryExit_d.VoluntaryExit}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}, Spec.VoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVoluntaryExit_h.VoluntaryExit_hash_tree_root(h, o)))])
def VoluntaryExit_decoded_root_correct(x0, x1, x2, x3, h, o, e):
  %VoluntaryExit_view_link(x0, x1, x2, x3) : RR.roots(_, Spec.VoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVoluntaryExit_h.VoluntaryExit_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_VoluntaryExit(_), Spec.VoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVoluntaryExit_h.VoluntaryExit_hash_tree_root(h, o)))])
  VoluntaryExit_root_correct(h, o)

# SignedVoluntaryExit: the root of every SignedVoluntaryExit object is its specification root.
law SignedVoluntaryExit_root_correct:
  for -h: B.Buf
  for +o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit
  RR.roots(LV.v_SignedVoluntaryExit(o), Spec.SignedVoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedVoluntaryExit_h.SignedVoluntaryExit_hash_tree_root(h, o)))])
def SignedVoluntaryExit_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSignedVoluntaryExit_h.SignedVoluntaryExit_root(64n, h, o, 0), (h, d_SignedVoluntaryExit(64n, o)), st_SignedVoluntaryExit(64n, h, o, 0)) :
    RR.roots(LV.v_SignedVoluntaryExit(o), Spec.SignedVoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SignedVoluntaryExit(64n, {==}, o)

def SignedVoluntaryExit_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32) -> {LV.v_SignedVoluntaryExit(FuluSignedVoluntaryExit_d.SignedVoluntaryExit{FuluVoluntaryExit_d.VoluntaryExit{O.U64{x0, x1}, O.U64{x2, x3}}, FuluBytes96_d.Bytes96{x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27}}) == S.Sequence{S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27])}, S.EmptyItems{}}}} : S.Value}: {==}
law SignedVoluntaryExit_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for -h: B.Buf
  for +o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit
  for +e: {o == FuluSignedVoluntaryExit_d.SignedVoluntaryExit{FuluVoluntaryExit_d.VoluntaryExit{O.U64{x0, x1}, O.U64{x2, x3}}, FuluBytes96_d.Bytes96{x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27}} : FuluSignedVoluntaryExit_d.SignedVoluntaryExit}
  RR.roots(S.Sequence{S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27])}, S.EmptyItems{}}}}, Spec.SignedVoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedVoluntaryExit_h.SignedVoluntaryExit_hash_tree_root(h, o)))])
def SignedVoluntaryExit_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, h, o, e):
  %SignedVoluntaryExit_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27) : RR.roots(_, Spec.SignedVoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedVoluntaryExit_h.SignedVoluntaryExit_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SignedVoluntaryExit(_), Spec.SignedVoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedVoluntaryExit_h.SignedVoluntaryExit_hash_tree_root(h, o)))])
  SignedVoluntaryExit_root_correct(h, o)

# Root: the root of every Root object is its specification root.
law Root_root_correct:
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  RR.roots(LV.v_b32(o), Spec.Root(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRoot_h.Root_hash_tree_root(h, o)))])
def Root_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(64n, h, o, 0), (h, d_b32(64n, o)), st_b32(64n, h, o, 0)) :
    RR.roots(LV.v_b32(o), Spec.Root(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b32(64n, {==}, o)

def Root_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_b32(FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])} : S.Value}: {==}
law Root_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  for +e: {o == FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7} : FuluBytes32_d.Bytes32}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, Spec.Root(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRoot_h.Root_hash_tree_root(h, o)))])
def Root_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %Root_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.Root(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRoot_h.Root_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b32(_), Spec.Root(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRoot_h.Root_hash_tree_root(h, o)))])
  Root_root_correct(h, o)

# HistoricalSummary: the root of every HistoricalSummary object is its specification root.
law HistoricalSummary_root_correct:
  for -h: B.Buf
  for +o: FuluHistoricalSummary_d.HistoricalSummary
  RR.roots(LV.v_HistoricalSummary(o), Spec.HistoricalSummary(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHistoricalSummary_h.HistoricalSummary_hash_tree_root(h, o)))])
def HistoricalSummary_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluHistoricalSummary_h.HistoricalSummary_root(64n, h, o, 0), (h, d_HistoricalSummary(64n, o)), st_HistoricalSummary(64n, h, o, 0)) :
    RR.roots(LV.v_HistoricalSummary(o), Spec.HistoricalSummary(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_HistoricalSummary(64n, {==}, o)

def HistoricalSummary_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32) -> {LV.v_HistoricalSummary(FuluHistoricalSummary_d.HistoricalSummary{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.EmptyItems{}}}} : S.Value}: {==}
law HistoricalSummary_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for -h: B.Buf
  for +o: FuluHistoricalSummary_d.HistoricalSummary
  for +e: {o == FuluHistoricalSummary_d.HistoricalSummary{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}} : FuluHistoricalSummary_d.HistoricalSummary}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.EmptyItems{}}}}, Spec.HistoricalSummary(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHistoricalSummary_h.HistoricalSummary_hash_tree_root(h, o)))])
def HistoricalSummary_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, h, o, e):
  %HistoricalSummary_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15) : RR.roots(_, Spec.HistoricalSummary(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHistoricalSummary_h.HistoricalSummary_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_HistoricalSummary(_), Spec.HistoricalSummary(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHistoricalSummary_h.HistoricalSummary_hash_tree_root(h, o)))])
  HistoricalSummary_root_correct(h, o)

# SyncCommitteeContribution: the root of every SyncCommitteeContribution object is its specification root.
law SyncCommitteeContribution_root_correct:
  for -h: B.Buf
  for +o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution
  RR.roots(LV.v_SyncCommitteeContribution(o), Spec.SyncCommitteeContribution(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeContribution_h.SyncCommitteeContribution_hash_tree_root(h, o)))])
def SyncCommitteeContribution_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSyncCommitteeContribution_h.SyncCommitteeContribution_root(64n, h, o, 0), (h, d_SyncCommitteeContribution(64n, o)), st_SyncCommitteeContribution(64n, h, o, 0)) :
    RR.roots(LV.v_SyncCommitteeContribution(o), Spec.SyncCommitteeContribution(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SyncCommitteeContribution(64n, {==}, o)

# SyncCommitteeMessage: the root of every SyncCommitteeMessage object is its specification root.
law SyncCommitteeMessage_root_correct:
  for -h: B.Buf
  for +o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage
  RR.roots(LV.v_SyncCommitteeMessage(o), Spec.SyncCommitteeMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeMessage_h.SyncCommitteeMessage_hash_tree_root(h, o)))])
def SyncCommitteeMessage_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSyncCommitteeMessage_h.SyncCommitteeMessage_root(64n, h, o, 0), (h, d_SyncCommitteeMessage(64n, o)), st_SyncCommitteeMessage(64n, h, o, 0)) :
    RR.roots(LV.v_SyncCommitteeMessage(o), Spec.SyncCommitteeMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SyncCommitteeMessage(64n, {==}, o)

def SyncCommitteeMessage_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32) -> {LV.v_SyncCommitteeMessage(FuluSyncCommitteeMessage_d.SyncCommitteeMessage{O.U64{x0, x1}, FuluBytes32_d.Bytes32{x2, x3, x4, x5, x6, x7, x8, x9}, O.U64{x10, x11}, FuluBytes96_d.Bytes96{x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9])}, S.Items{S.UnsignedValue{P.UInt{x10, x11, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35])}, S.EmptyItems{}}}}}} : S.Value}: {==}
law SyncCommitteeMessage_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for -h: B.Buf
  for +o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage
  for +e: {o == FuluSyncCommitteeMessage_d.SyncCommitteeMessage{O.U64{x0, x1}, FuluBytes32_d.Bytes32{x2, x3, x4, x5, x6, x7, x8, x9}, O.U64{x10, x11}, FuluBytes96_d.Bytes96{x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35}} : FuluSyncCommitteeMessage_d.SyncCommitteeMessage}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9])}, S.Items{S.UnsignedValue{P.UInt{x10, x11, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35])}, S.EmptyItems{}}}}}}, Spec.SyncCommitteeMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeMessage_h.SyncCommitteeMessage_hash_tree_root(h, o)))])
def SyncCommitteeMessage_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, h, o, e):
  %SyncCommitteeMessage_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35) : RR.roots(_, Spec.SyncCommitteeMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeMessage_h.SyncCommitteeMessage_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SyncCommitteeMessage(_), Spec.SyncCommitteeMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeMessage_h.SyncCommitteeMessage_hash_tree_root(h, o)))])
  SyncCommitteeMessage_root_correct(h, o)

# Eth1Block: the root of every Eth1Block object is its specification root.
law Eth1Block_root_correct:
  for -h: B.Buf
  for +o: FuluEth1Block_d.Eth1Block
  RR.roots(LV.v_Eth1Block(o), Spec.Eth1Block(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Block_h.Eth1Block_hash_tree_root(h, o)))])
def Eth1Block_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluEth1Block_h.Eth1Block_root(64n, h, o, 0), (h, d_Eth1Block(64n, o)), st_Eth1Block(64n, h, o, 0)) :
    RR.roots(LV.v_Eth1Block(o), Spec.Eth1Block(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_Eth1Block(64n, {==}, o)

def Eth1Block_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32) -> {LV.v_Eth1Block(FuluEth1Block_d.Eth1Block{O.U64{x0, x1}, FuluBytes32_d.Bytes32{x2, x3, x4, x5, x6, x7, x8, x9}, O.U64{x10, x11}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9])}, S.Items{S.UnsignedValue{P.UInt{x10, x11, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}} : S.Value}: {==}
law Eth1Block_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for -h: B.Buf
  for +o: FuluEth1Block_d.Eth1Block
  for +e: {o == FuluEth1Block_d.Eth1Block{O.U64{x0, x1}, FuluBytes32_d.Bytes32{x2, x3, x4, x5, x6, x7, x8, x9}, O.U64{x10, x11}} : FuluEth1Block_d.Eth1Block}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9])}, S.Items{S.UnsignedValue{P.UInt{x10, x11, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}, Spec.Eth1Block(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Block_h.Eth1Block_hash_tree_root(h, o)))])
def Eth1Block_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, h, o, e):
  %Eth1Block_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) : RR.roots(_, Spec.Eth1Block(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Block_h.Eth1Block_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_Eth1Block(_), Spec.Eth1Block(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Block_h.Eth1Block_hash_tree_root(h, o)))])
  Eth1Block_root_correct(h, o)

# BeaconBlockHeader: the root of every BeaconBlockHeader object is its specification root.
law BeaconBlockHeader_root_correct:
  for -h: B.Buf
  for +o: FuluBeaconBlockHeader_d.BeaconBlockHeader
  RR.roots(LV.v_BeaconBlockHeader(o), Spec.BeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_hash_tree_root(h, o)))])
def BeaconBlockHeader_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_root(64n, h, o, 0), (h, d_BeaconBlockHeader(64n, o)), st_BeaconBlockHeader(64n, h, o, 0)) :
    RR.roots(LV.v_BeaconBlockHeader(o), Spec.BeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_BeaconBlockHeader(64n, {==}, o)

def BeaconBlockHeader_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32) -> {LV.v_BeaconBlockHeader(FuluBeaconBlockHeader_d.BeaconBlockHeader{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes32_d.Bytes32{x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, FuluBytes32_d.Bytes32{x20, x21, x22, x23, x24, x25, x26, x27}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.BytesValue{F.limbs([x20, x21, x22, x23, x24, x25, x26, x27])}, S.EmptyItems{}}}}}}} : S.Value}: {==}
law BeaconBlockHeader_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for -h: B.Buf
  for +o: FuluBeaconBlockHeader_d.BeaconBlockHeader
  for +e: {o == FuluBeaconBlockHeader_d.BeaconBlockHeader{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes32_d.Bytes32{x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, FuluBytes32_d.Bytes32{x20, x21, x22, x23, x24, x25, x26, x27}} : FuluBeaconBlockHeader_d.BeaconBlockHeader}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.BytesValue{F.limbs([x20, x21, x22, x23, x24, x25, x26, x27])}, S.EmptyItems{}}}}}}}, Spec.BeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_hash_tree_root(h, o)))])
def BeaconBlockHeader_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, h, o, e):
  %BeaconBlockHeader_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27) : RR.roots(_, Spec.BeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_BeaconBlockHeader(_), Spec.BeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_hash_tree_root(h, o)))])
  BeaconBlockHeader_root_correct(h, o)

# SignedBeaconBlockHeader: the root of every SignedBeaconBlockHeader object is its specification root.
law SignedBeaconBlockHeader_root_correct:
  for -h: B.Buf
  for +o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader
  RR.roots(LV.v_SignedBeaconBlockHeader(o), Spec.SignedBeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_hash_tree_root(h, o)))])
def SignedBeaconBlockHeader_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_root(64n, h, o, 0), (h, d_SignedBeaconBlockHeader(64n, o)), st_SignedBeaconBlockHeader(64n, h, o, 0)) :
    RR.roots(LV.v_SignedBeaconBlockHeader(o), Spec.SignedBeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SignedBeaconBlockHeader(64n, {==}, o)

def SignedBeaconBlockHeader_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32, +x36: U32, +x37: U32, +x38: U32, +x39: U32, +x40: U32, +x41: U32, +x42: U32, +x43: U32, +x44: U32, +x45: U32, +x46: U32, +x47: U32, +x48: U32, +x49: U32, +x50: U32, +x51: U32) -> {LV.v_SignedBeaconBlockHeader(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{FuluBeaconBlockHeader_d.BeaconBlockHeader{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes32_d.Bytes32{x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, FuluBytes32_d.Bytes32{x20, x21, x22, x23, x24, x25, x26, x27}}, FuluBytes96_d.Bytes96{x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51}}) == S.Sequence{S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.BytesValue{F.limbs([x20, x21, x22, x23, x24, x25, x26, x27])}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51])}, S.EmptyItems{}}}} : S.Value}: {==}
law SignedBeaconBlockHeader_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for +x36: U32
  for +x37: U32
  for +x38: U32
  for +x39: U32
  for +x40: U32
  for +x41: U32
  for +x42: U32
  for +x43: U32
  for +x44: U32
  for +x45: U32
  for +x46: U32
  for +x47: U32
  for +x48: U32
  for +x49: U32
  for +x50: U32
  for +x51: U32
  for -h: B.Buf
  for +o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader
  for +e: {o == FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{FuluBeaconBlockHeader_d.BeaconBlockHeader{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes32_d.Bytes32{x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, FuluBytes32_d.Bytes32{x20, x21, x22, x23, x24, x25, x26, x27}}, FuluBytes96_d.Bytes96{x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51}} : FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader}
  RR.roots(S.Sequence{S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.BytesValue{F.limbs([x20, x21, x22, x23, x24, x25, x26, x27])}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51])}, S.EmptyItems{}}}}, Spec.SignedBeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_hash_tree_root(h, o)))])
def SignedBeaconBlockHeader_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, h, o, e):
  %SignedBeaconBlockHeader_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51) : RR.roots(_, Spec.SignedBeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SignedBeaconBlockHeader(_), Spec.SignedBeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_hash_tree_root(h, o)))])
  SignedBeaconBlockHeader_root_correct(h, o)

# Eth1Data: the root of every Eth1Data object is its specification root.
law Eth1Data_root_correct:
  for -h: B.Buf
  for +o: FuluEth1Data_d.Eth1Data
  RR.roots(LV.v_Eth1Data(o), Spec.Eth1Data(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Data_h.Eth1Data_hash_tree_root(h, o)))])
def Eth1Data_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluEth1Data_h.Eth1Data_root(64n, h, o, 0), (h, d_Eth1Data(64n, o)), st_Eth1Data(64n, h, o, 0)) :
    RR.roots(LV.v_Eth1Data(o), Spec.Eth1Data(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_Eth1Data(64n, {==}, o)

def Eth1Data_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32) -> {LV.v_Eth1Data(FuluEth1Data_d.Eth1Data{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, O.U64{x8, x9}, FuluBytes32_d.Bytes32{x10, x11, x12, x13, x14, x15, x16, x17}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.UnsignedValue{P.UInt{x8, x9, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x10, x11, x12, x13, x14, x15, x16, x17])}, S.EmptyItems{}}}}} : S.Value}: {==}
law Eth1Data_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for -h: B.Buf
  for +o: FuluEth1Data_d.Eth1Data
  for +e: {o == FuluEth1Data_d.Eth1Data{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, O.U64{x8, x9}, FuluBytes32_d.Bytes32{x10, x11, x12, x13, x14, x15, x16, x17}} : FuluEth1Data_d.Eth1Data}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.UnsignedValue{P.UInt{x8, x9, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x10, x11, x12, x13, x14, x15, x16, x17])}, S.EmptyItems{}}}}}, Spec.Eth1Data(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Data_h.Eth1Data_hash_tree_root(h, o)))])
def Eth1Data_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, h, o, e):
  %Eth1Data_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17) : RR.roots(_, Spec.Eth1Data(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Data_h.Eth1Data_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_Eth1Data(_), Spec.Eth1Data(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Data_h.Eth1Data_hash_tree_root(h, o)))])
  Eth1Data_root_correct(h, o)

# Checkpoint: the root of every Checkpoint object is its specification root.
law Checkpoint_root_correct:
  for -h: B.Buf
  for +o: FuluCheckpoint_d.Checkpoint
  RR.roots(LV.v_Checkpoint(o), Spec.Checkpoint(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCheckpoint_h.Checkpoint_hash_tree_root(h, o)))])
def Checkpoint_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluCheckpoint_h.Checkpoint_root(64n, h, o, 0), (h, d_Checkpoint(64n, o)), st_Checkpoint(64n, h, o, 0)) :
    RR.roots(LV.v_Checkpoint(o), Spec.Checkpoint(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_Checkpoint(64n, {==}, o)

def Checkpoint_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32) -> {LV.v_Checkpoint(FuluCheckpoint_d.Checkpoint{O.U64{x0, x1}, FuluBytes32_d.Bytes32{x2, x3, x4, x5, x6, x7, x8, x9}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9])}, S.EmptyItems{}}}} : S.Value}: {==}
law Checkpoint_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for -h: B.Buf
  for +o: FuluCheckpoint_d.Checkpoint
  for +e: {o == FuluCheckpoint_d.Checkpoint{O.U64{x0, x1}, FuluBytes32_d.Bytes32{x2, x3, x4, x5, x6, x7, x8, x9}} : FuluCheckpoint_d.Checkpoint}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9])}, S.EmptyItems{}}}}, Spec.Checkpoint(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCheckpoint_h.Checkpoint_hash_tree_root(h, o)))])
def Checkpoint_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, h, o, e):
  %Checkpoint_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9) : RR.roots(_, Spec.Checkpoint(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCheckpoint_h.Checkpoint_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_Checkpoint(_), Spec.Checkpoint(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCheckpoint_h.Checkpoint_hash_tree_root(h, o)))])
  Checkpoint_root_correct(h, o)

# AttestationData: the root of every AttestationData object is its specification root.
law AttestationData_root_correct:
  for -h: B.Buf
  for +o: FuluAttestationData_d.AttestationData
  RR.roots(LV.v_AttestationData(o), Spec.AttestationData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluAttestationData_h.AttestationData_hash_tree_root(h, o)))])
def AttestationData_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluAttestationData_h.AttestationData_root(64n, h, o, 0), (h, d_AttestationData(64n, o)), st_AttestationData(64n, h, o, 0)) :
    RR.roots(LV.v_AttestationData(o), Spec.AttestationData(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_AttestationData(64n, {==}, o)

def AttestationData_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32) -> {LV.v_AttestationData(FuluAttestationData_d.AttestationData{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes32_d.Bytes32{x4, x5, x6, x7, x8, x9, x10, x11}, FuluCheckpoint_d.Checkpoint{O.U64{x12, x13}, FuluBytes32_d.Bytes32{x14, x15, x16, x17, x18, x19, x20, x21}}, FuluCheckpoint_d.Checkpoint{O.U64{x22, x23}, FuluBytes32_d.Bytes32{x24, x25, x26, x27, x28, x29, x30, x31}}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x12, x13, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x14, x15, x16, x17, x18, x19, x20, x21])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x22, x23, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x24, x25, x26, x27, x28, x29, x30, x31])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}} : S.Value}: {==}
law AttestationData_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for -h: B.Buf
  for +o: FuluAttestationData_d.AttestationData
  for +e: {o == FuluAttestationData_d.AttestationData{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes32_d.Bytes32{x4, x5, x6, x7, x8, x9, x10, x11}, FuluCheckpoint_d.Checkpoint{O.U64{x12, x13}, FuluBytes32_d.Bytes32{x14, x15, x16, x17, x18, x19, x20, x21}}, FuluCheckpoint_d.Checkpoint{O.U64{x22, x23}, FuluBytes32_d.Bytes32{x24, x25, x26, x27, x28, x29, x30, x31}}} : FuluAttestationData_d.AttestationData}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x12, x13, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x14, x15, x16, x17, x18, x19, x20, x21])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x22, x23, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x24, x25, x26, x27, x28, x29, x30, x31])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, Spec.AttestationData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluAttestationData_h.AttestationData_hash_tree_root(h, o)))])
def AttestationData_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, h, o, e):
  %AttestationData_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31) : RR.roots(_, Spec.AttestationData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluAttestationData_h.AttestationData_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_AttestationData(_), Spec.AttestationData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluAttestationData_h.AttestationData_hash_tree_root(h, o)))])
  AttestationData_root_correct(h, o)

# SingleAttestation: the root of every SingleAttestation object is its specification root.
law SingleAttestation_root_correct:
  for -h: B.Buf
  for +o: FuluSingleAttestation_d.SingleAttestation
  RR.roots(LV.v_SingleAttestation(o), Spec.SingleAttestation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSingleAttestation_h.SingleAttestation_hash_tree_root(h, o)))])
def SingleAttestation_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSingleAttestation_h.SingleAttestation_root(64n, h, o, 0), (h, d_SingleAttestation(64n, o)), st_SingleAttestation(64n, h, o, 0)) :
    RR.roots(LV.v_SingleAttestation(o), Spec.SingleAttestation(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SingleAttestation(64n, {==}, o)

def SingleAttestation_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32, +x36: U32, +x37: U32, +x38: U32, +x39: U32, +x40: U32, +x41: U32, +x42: U32, +x43: U32, +x44: U32, +x45: U32, +x46: U32, +x47: U32, +x48: U32, +x49: U32, +x50: U32, +x51: U32, +x52: U32, +x53: U32, +x54: U32, +x55: U32, +x56: U32, +x57: U32, +x58: U32, +x59: U32) -> {LV.v_SingleAttestation(FuluSingleAttestation_d.SingleAttestation{O.U64{x0, x1}, O.U64{x2, x3}, FuluAttestationData_d.AttestationData{O.U64{x4, x5}, O.U64{x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}, FuluCheckpoint_d.Checkpoint{O.U64{x16, x17}, FuluBytes32_d.Bytes32{x18, x19, x20, x21, x22, x23, x24, x25}}, FuluCheckpoint_d.Checkpoint{O.U64{x26, x27}, FuluBytes32_d.Bytes32{x28, x29, x30, x31, x32, x33, x34, x35}}}, FuluBytes96_d.Bytes96{x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x4, x5, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x6, x7, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x16, x17, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x18, x19, x20, x21, x22, x23, x24, x25])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x26, x27, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x28, x29, x30, x31, x32, x33, x34, x35])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59])}, S.EmptyItems{}}}}}} : S.Value}: {==}
law SingleAttestation_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for +x36: U32
  for +x37: U32
  for +x38: U32
  for +x39: U32
  for +x40: U32
  for +x41: U32
  for +x42: U32
  for +x43: U32
  for +x44: U32
  for +x45: U32
  for +x46: U32
  for +x47: U32
  for +x48: U32
  for +x49: U32
  for +x50: U32
  for +x51: U32
  for +x52: U32
  for +x53: U32
  for +x54: U32
  for +x55: U32
  for +x56: U32
  for +x57: U32
  for +x58: U32
  for +x59: U32
  for -h: B.Buf
  for +o: FuluSingleAttestation_d.SingleAttestation
  for +e: {o == FuluSingleAttestation_d.SingleAttestation{O.U64{x0, x1}, O.U64{x2, x3}, FuluAttestationData_d.AttestationData{O.U64{x4, x5}, O.U64{x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}, FuluCheckpoint_d.Checkpoint{O.U64{x16, x17}, FuluBytes32_d.Bytes32{x18, x19, x20, x21, x22, x23, x24, x25}}, FuluCheckpoint_d.Checkpoint{O.U64{x26, x27}, FuluBytes32_d.Bytes32{x28, x29, x30, x31, x32, x33, x34, x35}}}, FuluBytes96_d.Bytes96{x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59}} : FuluSingleAttestation_d.SingleAttestation}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x4, x5, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x6, x7, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x16, x17, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x18, x19, x20, x21, x22, x23, x24, x25])}, S.EmptyItems{}}}}, S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x26, x27, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x28, x29, x30, x31, x32, x33, x34, x35])}, S.EmptyItems{}}}}, S.EmptyItems{}}}}}}}, S.Items{S.BytesValue{F.limbs([x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59])}, S.EmptyItems{}}}}}}, Spec.SingleAttestation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSingleAttestation_h.SingleAttestation_hash_tree_root(h, o)))])
def SingleAttestation_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59, h, o, e):
  %SingleAttestation_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54, x55, x56, x57, x58, x59) : RR.roots(_, Spec.SingleAttestation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSingleAttestation_h.SingleAttestation_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SingleAttestation(_), Spec.SingleAttestation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSingleAttestation_h.SingleAttestation_hash_tree_root(h, o)))])
  SingleAttestation_root_correct(h, o)

# ForkData: the root of every ForkData object is its specification root.
law ForkData_root_correct:
  for -h: B.Buf
  for +o: FuluForkData_d.ForkData
  RR.roots(LV.v_ForkData(o), Spec.ForkData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkData_h.ForkData_hash_tree_root(h, o)))])
def ForkData_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluForkData_h.ForkData_root(64n, h, o, 0), (h, d_ForkData(64n, o)), st_ForkData(64n, h, o, 0)) :
    RR.roots(LV.v_ForkData(o), Spec.ForkData(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_ForkData(64n, {==}, o)

def ForkData_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32) -> {LV.v_ForkData(FuluForkData_d.ForkData{FuluBytes4_d.Bytes4{x0}, FuluBytes32_d.Bytes32{x1, x2, x3, x4, x5, x6, x7, x8}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0])}, S.Items{S.BytesValue{F.limbs([x1, x2, x3, x4, x5, x6, x7, x8])}, S.EmptyItems{}}}} : S.Value}: {==}
law ForkData_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for -h: B.Buf
  for +o: FuluForkData_d.ForkData
  for +e: {o == FuluForkData_d.ForkData{FuluBytes4_d.Bytes4{x0}, FuluBytes32_d.Bytes32{x1, x2, x3, x4, x5, x6, x7, x8}} : FuluForkData_d.ForkData}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0])}, S.Items{S.BytesValue{F.limbs([x1, x2, x3, x4, x5, x6, x7, x8])}, S.EmptyItems{}}}}, Spec.ForkData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkData_h.ForkData_hash_tree_root(h, o)))])
def ForkData_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, h, o, e):
  %ForkData_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8) : RR.roots(_, Spec.ForkData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkData_h.ForkData_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_ForkData(_), Spec.ForkData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkData_h.ForkData_hash_tree_root(h, o)))])
  ForkData_root_correct(h, o)

# ForkDigest: the root of every ForkDigest object is its specification root.
law ForkDigest_root_correct:
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  RR.roots(LV.v_b4(o), Spec.ForkDigest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkDigest_h.ForkDigest_hash_tree_root(h, o)))])
def ForkDigest_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes4_h.b4_root(64n, h, o, 0), (h, d_b4(64n, o)), st_b4(64n, h, o, 0)) :
    RR.roots(LV.v_b4(o), Spec.ForkDigest(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b4(64n, {==}, o)

def ForkDigest_view_link(+x0: U32) -> {LV.v_b4(FuluBytes4_d.Bytes4{x0}) == S.BytesValue{F.limbs([x0])} : S.Value}: {==}
law ForkDigest_decoded_root_correct:
  for +x0: U32
  for -h: B.Buf
  for +o: FuluBytes4_d.Bytes4
  for +e: {o == FuluBytes4_d.Bytes4{x0} : FuluBytes4_d.Bytes4}
  RR.roots(S.BytesValue{F.limbs([x0])}, Spec.ForkDigest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkDigest_h.ForkDigest_hash_tree_root(h, o)))])
def ForkDigest_decoded_root_correct(x0, h, o, e):
  %ForkDigest_view_link(x0) : RR.roots(_, Spec.ForkDigest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkDigest_h.ForkDigest_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b4(_), Spec.ForkDigest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkDigest_h.ForkDigest_hash_tree_root(h, o)))])
  ForkDigest_root_correct(h, o)

# Domain: the root of every Domain object is its specification root.
law Domain_root_correct:
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  RR.roots(LV.v_b32(o), Spec.Domain(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomain_h.Domain_hash_tree_root(h, o)))])
def Domain_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes32_h.b32_root(64n, h, o, 0), (h, d_b32(64n, o)), st_b32(64n, h, o, 0)) :
    RR.roots(LV.v_b32(o), Spec.Domain(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b32(64n, {==}, o)

def Domain_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_b32(FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])} : S.Value}: {==}
law Domain_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: FuluBytes32_d.Bytes32
  for +e: {o == FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7} : FuluBytes32_d.Bytes32}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, Spec.Domain(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomain_h.Domain_hash_tree_root(h, o)))])
def Domain_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %Domain_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.Domain(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomain_h.Domain_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b32(_), Spec.Domain(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomain_h.Domain_hash_tree_root(h, o)))])
  Domain_root_correct(h, o)

# SigningData: the root of every SigningData object is its specification root.
law SigningData_root_correct:
  for -h: B.Buf
  for +o: FuluSigningData_d.SigningData
  RR.roots(LV.v_SigningData(o), Spec.SigningData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSigningData_h.SigningData_hash_tree_root(h, o)))])
def SigningData_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSigningData_h.SigningData_root(64n, h, o, 0), (h, d_SigningData(64n, o)), st_SigningData(64n, h, o, 0)) :
    RR.roots(LV.v_SigningData(o), Spec.SigningData(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SigningData(64n, {==}, o)

def SigningData_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32) -> {LV.v_SigningData(FuluSigningData_d.SigningData{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.EmptyItems{}}}} : S.Value}: {==}
law SigningData_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for -h: B.Buf
  for +o: FuluSigningData_d.SigningData
  for +e: {o == FuluSigningData_d.SigningData{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, FuluBytes32_d.Bytes32{x8, x9, x10, x11, x12, x13, x14, x15}} : FuluSigningData_d.SigningData}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.BytesValue{F.limbs([x8, x9, x10, x11, x12, x13, x14, x15])}, S.EmptyItems{}}}}, Spec.SigningData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSigningData_h.SigningData_hash_tree_root(h, o)))])
def SigningData_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, h, o, e):
  %SigningData_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15) : RR.roots(_, Spec.SigningData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSigningData_h.SigningData_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SigningData(_), Spec.SigningData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSigningData_h.SigningData_hash_tree_root(h, o)))])
  SigningData_root_correct(h, o)

# BLSPubkey: the root of every BLSPubkey object is its specification root.
law BLSPubkey_root_correct:
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  RR.roots(LV.v_b48(o), Spec.BLSPubkey(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSPubkey_h.BLSPubkey_hash_tree_root(h, o)))])
def BLSPubkey_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(64n, h, o, 0), (h, d_b48(64n, o)), st_b48(64n, h, o, 0)) :
    RR.roots(LV.v_b48(o), Spec.BLSPubkey(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b48(64n, {==}, o)

def BLSPubkey_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32) -> {LV.v_b48(FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])} : S.Value}: {==}
law BLSPubkey_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  for +e: {o == FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11} : FuluBytes48_d.Bytes48}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, Spec.BLSPubkey(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSPubkey_h.BLSPubkey_hash_tree_root(h, o)))])
def BLSPubkey_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, h, o, e):
  %BLSPubkey_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) : RR.roots(_, Spec.BLSPubkey(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSPubkey_h.BLSPubkey_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b48(_), Spec.BLSPubkey(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSPubkey_h.BLSPubkey_hash_tree_root(h, o)))])
  BLSPubkey_root_correct(h, o)

# DepositRequest: the root of every DepositRequest object is its specification root.
law DepositRequest_root_correct:
  for -h: B.Buf
  for +o: FuluDepositRequest_d.DepositRequest
  RR.roots(LV.v_DepositRequest(o), Spec.DepositRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositRequest_h.DepositRequest_hash_tree_root(h, o)))])
def DepositRequest_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluDepositRequest_h.DepositRequest_root(64n, h, o, 0), (h, d_DepositRequest(64n, o)), st_DepositRequest(64n, h, o, 0)) :
    RR.roots(LV.v_DepositRequest(o), Spec.DepositRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_DepositRequest(64n, {==}, o)

def DepositRequest_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32, +x36: U32, +x37: U32, +x38: U32, +x39: U32, +x40: U32, +x41: U32, +x42: U32, +x43: U32, +x44: U32, +x45: U32, +x46: U32, +x47: U32) -> {LV.v_DepositRequest(FuluDepositRequest_d.DepositRequest{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}, FuluBytes96_d.Bytes96{x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45}, O.U64{x46, x47}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45])}, S.Items{S.UnsignedValue{P.UInt{x46, x47, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}}} : S.Value}: {==}
law DepositRequest_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for +x36: U32
  for +x37: U32
  for +x38: U32
  for +x39: U32
  for +x40: U32
  for +x41: U32
  for +x42: U32
  for +x43: U32
  for +x44: U32
  for +x45: U32
  for +x46: U32
  for +x47: U32
  for -h: B.Buf
  for +o: FuluDepositRequest_d.DepositRequest
  for +e: {o == FuluDepositRequest_d.DepositRequest{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}, FuluBytes96_d.Bytes96{x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45}, O.U64{x46, x47}} : FuluDepositRequest_d.DepositRequest}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45])}, S.Items{S.UnsignedValue{P.UInt{x46, x47, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}}}, Spec.DepositRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositRequest_h.DepositRequest_hash_tree_root(h, o)))])
def DepositRequest_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, h, o, e):
  %DepositRequest_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47) : RR.roots(_, Spec.DepositRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositRequest_h.DepositRequest_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_DepositRequest(_), Spec.DepositRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositRequest_h.DepositRequest_hash_tree_root(h, o)))])
  DepositRequest_root_correct(h, o)

# PendingDeposit: the root of every PendingDeposit object is its specification root.
law PendingDeposit_root_correct:
  for -h: B.Buf
  for +o: FuluPendingDeposit_d.PendingDeposit
  RR.roots(LV.v_PendingDeposit(o), Spec.PendingDeposit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingDeposit_h.PendingDeposit_hash_tree_root(h, o)))])
def PendingDeposit_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluPendingDeposit_h.PendingDeposit_root(64n, h, o, 0), (h, d_PendingDeposit(64n, o)), st_PendingDeposit(64n, h, o, 0)) :
    RR.roots(LV.v_PendingDeposit(o), Spec.PendingDeposit(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_PendingDeposit(64n, {==}, o)

def PendingDeposit_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32, +x36: U32, +x37: U32, +x38: U32, +x39: U32, +x40: U32, +x41: U32, +x42: U32, +x43: U32, +x44: U32, +x45: U32, +x46: U32, +x47: U32) -> {LV.v_PendingDeposit(FuluPendingDeposit_d.PendingDeposit{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}, FuluBytes96_d.Bytes96{x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45}, O.U64{x46, x47}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45])}, S.Items{S.UnsignedValue{P.UInt{x46, x47, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}}} : S.Value}: {==}
law PendingDeposit_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for +x36: U32
  for +x37: U32
  for +x38: U32
  for +x39: U32
  for +x40: U32
  for +x41: U32
  for +x42: U32
  for +x43: U32
  for +x44: U32
  for +x45: U32
  for +x46: U32
  for +x47: U32
  for -h: B.Buf
  for +o: FuluPendingDeposit_d.PendingDeposit
  for +e: {o == FuluPendingDeposit_d.PendingDeposit{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}, FuluBytes96_d.Bytes96{x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45}, O.U64{x46, x47}} : FuluPendingDeposit_d.PendingDeposit}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45])}, S.Items{S.UnsignedValue{P.UInt{x46, x47, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}}}, Spec.PendingDeposit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingDeposit_h.PendingDeposit_hash_tree_root(h, o)))])
def PendingDeposit_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, h, o, e):
  %PendingDeposit_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47) : RR.roots(_, Spec.PendingDeposit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingDeposit_h.PendingDeposit_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_PendingDeposit(_), Spec.PendingDeposit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingDeposit_h.PendingDeposit_hash_tree_root(h, o)))])
  PendingDeposit_root_correct(h, o)

# DepositData: the root of every DepositData object is its specification root.
law DepositData_root_correct:
  for -h: B.Buf
  for +o: FuluDepositData_d.DepositData
  RR.roots(LV.v_DepositData(o), Spec.DepositData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositData_h.DepositData_hash_tree_root(h, o)))])
def DepositData_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluDepositData_h.DepositData_root(64n, h, o, 0), (h, d_DepositData(64n, o)), st_DepositData(64n, h, o, 0)) :
    RR.roots(LV.v_DepositData(o), Spec.DepositData(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_DepositData(64n, {==}, o)

def DepositData_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32, +x36: U32, +x37: U32, +x38: U32, +x39: U32, +x40: U32, +x41: U32, +x42: U32, +x43: U32, +x44: U32, +x45: U32) -> {LV.v_DepositData(FuluDepositData_d.DepositData{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}, FuluBytes96_d.Bytes96{x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45])}, S.EmptyItems{}}}}}} : S.Value}: {==}
law DepositData_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for +x36: U32
  for +x37: U32
  for +x38: U32
  for +x39: U32
  for +x40: U32
  for +x41: U32
  for +x42: U32
  for +x43: U32
  for +x44: U32
  for +x45: U32
  for -h: B.Buf
  for +o: FuluDepositData_d.DepositData
  for +e: {o == FuluDepositData_d.DepositData{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}, FuluBytes96_d.Bytes96{x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45}} : FuluDepositData_d.DepositData}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45])}, S.EmptyItems{}}}}}}, Spec.DepositData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositData_h.DepositData_hash_tree_root(h, o)))])
def DepositData_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, h, o, e):
  %DepositData_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45) : RR.roots(_, Spec.DepositData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositData_h.DepositData_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_DepositData(_), Spec.DepositData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositData_h.DepositData_hash_tree_root(h, o)))])
  DepositData_root_correct(h, o)

# DepositMessage: the root of every DepositMessage object is its specification root.
law DepositMessage_root_correct:
  for -h: B.Buf
  for +o: FuluDepositMessage_d.DepositMessage
  RR.roots(LV.v_DepositMessage(o), Spec.DepositMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositMessage_h.DepositMessage_hash_tree_root(h, o)))])
def DepositMessage_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluDepositMessage_h.DepositMessage_root(64n, h, o, 0), (h, d_DepositMessage(64n, o)), st_DepositMessage(64n, h, o, 0)) :
    RR.roots(LV.v_DepositMessage(o), Spec.DepositMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_DepositMessage(64n, {==}, o)

def DepositMessage_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32) -> {LV.v_DepositMessage(FuluDepositMessage_d.DepositMessage{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}} : S.Value}: {==}
law DepositMessage_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for -h: B.Buf
  for +o: FuluDepositMessage_d.DepositMessage
  for +e: {o == FuluDepositMessage_d.DepositMessage{FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}, FuluBytes32_d.Bytes32{x12, x13, x14, x15, x16, x17, x18, x19}, O.U64{x20, x21}} : FuluDepositMessage_d.DepositMessage}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, S.Items{S.BytesValue{F.limbs([x12, x13, x14, x15, x16, x17, x18, x19])}, S.Items{S.UnsignedValue{P.UInt{x20, x21, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}, Spec.DepositMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositMessage_h.DepositMessage_hash_tree_root(h, o)))])
def DepositMessage_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, h, o, e):
  %DepositMessage_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21) : RR.roots(_, Spec.DepositMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositMessage_h.DepositMessage_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_DepositMessage(_), Spec.DepositMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositMessage_h.DepositMessage_hash_tree_root(h, o)))])
  DepositMessage_root_correct(h, o)

# Validator: the root of every Validator object is its specification root.
law Validator_root_correct:
  for -h: B.Buf
  for +o: FuluValidator_d.Validator
  RR.roots(LV.v_Validator(o), Spec.Validator(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidator_h.Validator_hash_tree_root(h, o)))])
def Validator_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluValidator_h.Validator_root(64n, h, o, 0), (h, d_Validator(64n, o)), st_Validator(64n, h, o, 0)) :
    RR.roots(LV.v_Validator(o), Spec.Validator(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_Validator(64n, {==}, o)

# NodeID: the root of every NodeID object is its specification root.
law NodeID_root_correct:
  for -h: B.Buf
  for +o: uint256_d.Uint256
  RR.roots(LV.v_u256(o), Spec.NodeID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluNodeID_h.NodeID_hash_tree_root(h, o)))])
def NodeID_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint256_h.u256_root(64n, h, o, 0), (h, d_u256(64n, o)), st_u256(64n, h, o, 0)) :
    RR.roots(LV.v_u256(o), Spec.NodeID(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u256(64n, {==}, o)

def NodeID_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32) -> {LV.v_u256(uint256_d.Uint256{x0, x1, x2, x3, x4, x5, x6, x7}) == S.UnsignedValue{P.UInt{x0, x1, x2, x3, x4, x5, x6, x7}} : S.Value}: {==}
law NodeID_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for -h: B.Buf
  for +o: uint256_d.Uint256
  for +e: {o == uint256_d.Uint256{x0, x1, x2, x3, x4, x5, x6, x7} : uint256_d.Uint256}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, x2, x3, x4, x5, x6, x7}}, Spec.NodeID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluNodeID_h.NodeID_hash_tree_root(h, o)))])
def NodeID_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, h, o, e):
  %NodeID_view_link(x0, x1, x2, x3, x4, x5, x6, x7) : RR.roots(_, Spec.NodeID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluNodeID_h.NodeID_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u256(_), Spec.NodeID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluNodeID_h.NodeID_hash_tree_root(h, o)))])
  NodeID_root_correct(h, o)

# SubnetID: the root of every SubnetID object is its specification root.
law SubnetID_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.SubnetID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSubnetID_h.SubnetID_hash_tree_root(h, o)))])
def SubnetID_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.SubnetID(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def SubnetID_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law SubnetID_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.SubnetID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSubnetID_h.SubnetID_hash_tree_root(h, o)))])
def SubnetID_decoded_root_correct(x0, x1, h, o, e):
  %SubnetID_view_link(x0, x1) : RR.roots(_, Spec.SubnetID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSubnetID_h.SubnetID_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.SubnetID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSubnetID_h.SubnetID_hash_tree_root(h, o)))])
  SubnetID_root_correct(h, o)

# Ether: the root of every Ether object is its specification root.
law Ether_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.Ether(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEther_h.Ether_hash_tree_root(h, o)))])
def Ether_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.Ether(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def Ether_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law Ether_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.Ether(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEther_h.Ether_hash_tree_root(h, o)))])
def Ether_decoded_root_correct(x0, x1, h, o, e):
  %Ether_view_link(x0, x1) : RR.roots(_, Spec.Ether(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEther_h.Ether_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.Ether(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEther_h.Ether_hash_tree_root(h, o)))])
  Ether_root_correct(h, o)

# ExecutionAddress: the root of every ExecutionAddress object is its specification root.
law ExecutionAddress_root_correct:
  for -h: B.Buf
  for +o: FuluBytes20_d.Bytes20
  RR.roots(LV.v_b20(o), Spec.ExecutionAddress(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluExecutionAddress_h.ExecutionAddress_hash_tree_root(h, o)))])
def ExecutionAddress_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes20_h.b20_root(64n, h, o, 0), (h, d_b20(64n, o)), st_b20(64n, h, o, 0)) :
    RR.roots(LV.v_b20(o), Spec.ExecutionAddress(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b20(64n, {==}, o)

def ExecutionAddress_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32) -> {LV.v_b20(FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4])} : S.Value}: {==}
law ExecutionAddress_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for -h: B.Buf
  for +o: FuluBytes20_d.Bytes20
  for +e: {o == FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4} : FuluBytes20_d.Bytes20}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4])}, Spec.ExecutionAddress(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluExecutionAddress_h.ExecutionAddress_hash_tree_root(h, o)))])
def ExecutionAddress_decoded_root_correct(x0, x1, x2, x3, x4, h, o, e):
  %ExecutionAddress_view_link(x0, x1, x2, x3, x4) : RR.roots(_, Spec.ExecutionAddress(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluExecutionAddress_h.ExecutionAddress_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b20(_), Spec.ExecutionAddress(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluExecutionAddress_h.ExecutionAddress_hash_tree_root(h, o)))])
  ExecutionAddress_root_correct(h, o)

# ConsolidationRequest: the root of every ConsolidationRequest object is its specification root.
law ConsolidationRequest_root_correct:
  for -h: B.Buf
  for +o: FuluConsolidationRequest_d.ConsolidationRequest
  RR.roots(LV.v_ConsolidationRequest(o), Spec.ConsolidationRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluConsolidationRequest_h.ConsolidationRequest_hash_tree_root(h, o)))])
def ConsolidationRequest_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluConsolidationRequest_h.ConsolidationRequest_root(64n, h, o, 0), (h, d_ConsolidationRequest(64n, o)), st_ConsolidationRequest(64n, h, o, 0)) :
    RR.roots(LV.v_ConsolidationRequest(o), Spec.ConsolidationRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_ConsolidationRequest(64n, {==}, o)

def ConsolidationRequest_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32) -> {LV.v_ConsolidationRequest(FuluConsolidationRequest_d.ConsolidationRequest{FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4}, FuluBytes48_d.Bytes48{x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}, FuluBytes48_d.Bytes48{x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4])}, S.Items{S.BytesValue{F.limbs([x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16])}, S.Items{S.BytesValue{F.limbs([x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28])}, S.EmptyItems{}}}}} : S.Value}: {==}
law ConsolidationRequest_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for -h: B.Buf
  for +o: FuluConsolidationRequest_d.ConsolidationRequest
  for +e: {o == FuluConsolidationRequest_d.ConsolidationRequest{FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4}, FuluBytes48_d.Bytes48{x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}, FuluBytes48_d.Bytes48{x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28}} : FuluConsolidationRequest_d.ConsolidationRequest}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4])}, S.Items{S.BytesValue{F.limbs([x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16])}, S.Items{S.BytesValue{F.limbs([x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28])}, S.EmptyItems{}}}}}, Spec.ConsolidationRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluConsolidationRequest_h.ConsolidationRequest_hash_tree_root(h, o)))])
def ConsolidationRequest_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, h, o, e):
  %ConsolidationRequest_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28) : RR.roots(_, Spec.ConsolidationRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluConsolidationRequest_h.ConsolidationRequest_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_ConsolidationRequest(_), Spec.ConsolidationRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluConsolidationRequest_h.ConsolidationRequest_hash_tree_root(h, o)))])
  ConsolidationRequest_root_correct(h, o)

# WithdrawalRequest: the root of every WithdrawalRequest object is its specification root.
law WithdrawalRequest_root_correct:
  for -h: B.Buf
  for +o: FuluWithdrawalRequest_d.WithdrawalRequest
  RR.roots(LV.v_WithdrawalRequest(o), Spec.WithdrawalRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalRequest_h.WithdrawalRequest_hash_tree_root(h, o)))])
def WithdrawalRequest_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluWithdrawalRequest_h.WithdrawalRequest_root(64n, h, o, 0), (h, d_WithdrawalRequest(64n, o)), st_WithdrawalRequest(64n, h, o, 0)) :
    RR.roots(LV.v_WithdrawalRequest(o), Spec.WithdrawalRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_WithdrawalRequest(64n, {==}, o)

def WithdrawalRequest_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32) -> {LV.v_WithdrawalRequest(FuluWithdrawalRequest_d.WithdrawalRequest{FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4}, FuluBytes48_d.Bytes48{x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}, O.U64{x17, x18}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4])}, S.Items{S.BytesValue{F.limbs([x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16])}, S.Items{S.UnsignedValue{P.UInt{x17, x18, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}} : S.Value}: {==}
law WithdrawalRequest_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for -h: B.Buf
  for +o: FuluWithdrawalRequest_d.WithdrawalRequest
  for +e: {o == FuluWithdrawalRequest_d.WithdrawalRequest{FuluBytes20_d.Bytes20{x0, x1, x2, x3, x4}, FuluBytes48_d.Bytes48{x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}, O.U64{x17, x18}} : FuluWithdrawalRequest_d.WithdrawalRequest}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4])}, S.Items{S.BytesValue{F.limbs([x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16])}, S.Items{S.UnsignedValue{P.UInt{x17, x18, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}, Spec.WithdrawalRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalRequest_h.WithdrawalRequest_hash_tree_root(h, o)))])
def WithdrawalRequest_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, h, o, e):
  %WithdrawalRequest_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) : RR.roots(_, Spec.WithdrawalRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalRequest_h.WithdrawalRequest_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_WithdrawalRequest(_), Spec.WithdrawalRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalRequest_h.WithdrawalRequest_hash_tree_root(h, o)))])
  WithdrawalRequest_root_correct(h, o)

# BLSToExecutionChange: the root of every BLSToExecutionChange object is its specification root.
law BLSToExecutionChange_root_correct:
  for -h: B.Buf
  for +o: FuluBLSToExecutionChange_d.BLSToExecutionChange
  RR.roots(LV.v_BLSToExecutionChange(o), Spec.BLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_hash_tree_root(h, o)))])
def BLSToExecutionChange_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_root(64n, h, o, 0), (h, d_BLSToExecutionChange(64n, o)), st_BLSToExecutionChange(64n, h, o, 0)) :
    RR.roots(LV.v_BLSToExecutionChange(o), Spec.BLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_BLSToExecutionChange(64n, {==}, o)

def BLSToExecutionChange_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32) -> {LV.v_BLSToExecutionChange(FuluBLSToExecutionChange_d.BLSToExecutionChange{O.U64{x0, x1}, FuluBytes48_d.Bytes48{x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13}, FuluBytes20_d.Bytes20{x14, x15, x16, x17, x18}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13])}, S.Items{S.BytesValue{F.limbs([x14, x15, x16, x17, x18])}, S.EmptyItems{}}}}} : S.Value}: {==}
law BLSToExecutionChange_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for -h: B.Buf
  for +o: FuluBLSToExecutionChange_d.BLSToExecutionChange
  for +e: {o == FuluBLSToExecutionChange_d.BLSToExecutionChange{O.U64{x0, x1}, FuluBytes48_d.Bytes48{x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13}, FuluBytes20_d.Bytes20{x14, x15, x16, x17, x18}} : FuluBLSToExecutionChange_d.BLSToExecutionChange}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13])}, S.Items{S.BytesValue{F.limbs([x14, x15, x16, x17, x18])}, S.EmptyItems{}}}}}, Spec.BLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_hash_tree_root(h, o)))])
def BLSToExecutionChange_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, h, o, e):
  %BLSToExecutionChange_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) : RR.roots(_, Spec.BLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_BLSToExecutionChange(_), Spec.BLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_hash_tree_root(h, o)))])
  BLSToExecutionChange_root_correct(h, o)

# SignedBLSToExecutionChange: the root of every SignedBLSToExecutionChange object is its specification root.
law SignedBLSToExecutionChange_root_correct:
  for -h: B.Buf
  for +o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange
  RR.roots(LV.v_SignedBLSToExecutionChange(o), Spec.SignedBLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_hash_tree_root(h, o)))])
def SignedBLSToExecutionChange_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_root(64n, h, o, 0), (h, d_SignedBLSToExecutionChange(64n, o)), st_SignedBLSToExecutionChange(64n, h, o, 0)) :
    RR.roots(LV.v_SignedBLSToExecutionChange(o), Spec.SignedBLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_SignedBLSToExecutionChange(64n, {==}, o)

def SignedBLSToExecutionChange_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32, +x12: U32, +x13: U32, +x14: U32, +x15: U32, +x16: U32, +x17: U32, +x18: U32, +x19: U32, +x20: U32, +x21: U32, +x22: U32, +x23: U32, +x24: U32, +x25: U32, +x26: U32, +x27: U32, +x28: U32, +x29: U32, +x30: U32, +x31: U32, +x32: U32, +x33: U32, +x34: U32, +x35: U32, +x36: U32, +x37: U32, +x38: U32, +x39: U32, +x40: U32, +x41: U32, +x42: U32) -> {LV.v_SignedBLSToExecutionChange(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{FuluBLSToExecutionChange_d.BLSToExecutionChange{O.U64{x0, x1}, FuluBytes48_d.Bytes48{x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13}, FuluBytes20_d.Bytes20{x14, x15, x16, x17, x18}}, FuluBytes96_d.Bytes96{x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42}}) == S.Sequence{S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13])}, S.Items{S.BytesValue{F.limbs([x14, x15, x16, x17, x18])}, S.EmptyItems{}}}}}, S.Items{S.BytesValue{F.limbs([x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42])}, S.EmptyItems{}}}} : S.Value}: {==}
law SignedBLSToExecutionChange_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for +x12: U32
  for +x13: U32
  for +x14: U32
  for +x15: U32
  for +x16: U32
  for +x17: U32
  for +x18: U32
  for +x19: U32
  for +x20: U32
  for +x21: U32
  for +x22: U32
  for +x23: U32
  for +x24: U32
  for +x25: U32
  for +x26: U32
  for +x27: U32
  for +x28: U32
  for +x29: U32
  for +x30: U32
  for +x31: U32
  for +x32: U32
  for +x33: U32
  for +x34: U32
  for +x35: U32
  for +x36: U32
  for +x37: U32
  for +x38: U32
  for +x39: U32
  for +x40: U32
  for +x41: U32
  for +x42: U32
  for -h: B.Buf
  for +o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange
  for +e: {o == FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{FuluBLSToExecutionChange_d.BLSToExecutionChange{O.U64{x0, x1}, FuluBytes48_d.Bytes48{x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13}, FuluBytes20_d.Bytes20{x14, x15, x16, x17, x18}}, FuluBytes96_d.Bytes96{x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42}} : FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange}
  RR.roots(S.Sequence{S.Items{S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13])}, S.Items{S.BytesValue{F.limbs([x14, x15, x16, x17, x18])}, S.EmptyItems{}}}}}, S.Items{S.BytesValue{F.limbs([x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42])}, S.EmptyItems{}}}}, Spec.SignedBLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_hash_tree_root(h, o)))])
def SignedBLSToExecutionChange_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, h, o, e):
  %SignedBLSToExecutionChange_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42) : RR.roots(_, Spec.SignedBLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_SignedBLSToExecutionChange(_), Spec.SignedBLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_hash_tree_root(h, o)))])
  SignedBLSToExecutionChange_root_correct(h, o)

# PayloadId: the root of every PayloadId object is its specification root.
law PayloadId_root_correct:
  for -h: B.Buf
  for +o: FuluBytes8_d.Bytes8
  RR.roots(LV.v_b8(o), Spec.PayloadId(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPayloadId_h.PayloadId_hash_tree_root(h, o)))])
def PayloadId_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes8_h.b8_root(64n, h, o, 0), (h, d_b8(64n, o)), st_b8(64n, h, o, 0)) :
    RR.roots(LV.v_b8(o), Spec.PayloadId(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b8(64n, {==}, o)

def PayloadId_view_link(+x0: U32, +x1: U32) -> {LV.v_b8(FuluBytes8_d.Bytes8{x0, x1}) == S.BytesValue{F.limbs([x0, x1])} : S.Value}: {==}
law PayloadId_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: FuluBytes8_d.Bytes8
  for +e: {o == FuluBytes8_d.Bytes8{x0, x1} : FuluBytes8_d.Bytes8}
  RR.roots(S.BytesValue{F.limbs([x0, x1])}, Spec.PayloadId(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPayloadId_h.PayloadId_hash_tree_root(h, o)))])
def PayloadId_decoded_root_correct(x0, x1, h, o, e):
  %PayloadId_view_link(x0, x1) : RR.roots(_, Spec.PayloadId(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPayloadId_h.PayloadId_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b8(_), Spec.PayloadId(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPayloadId_h.PayloadId_hash_tree_root(h, o)))])
  PayloadId_root_correct(h, o)

# WithdrawalIndex: the root of every WithdrawalIndex object is its specification root.
law WithdrawalIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.WithdrawalIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalIndex_h.WithdrawalIndex_hash_tree_root(h, o)))])
def WithdrawalIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.WithdrawalIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def WithdrawalIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law WithdrawalIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.WithdrawalIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalIndex_h.WithdrawalIndex_hash_tree_root(h, o)))])
def WithdrawalIndex_decoded_root_correct(x0, x1, h, o, e):
  %WithdrawalIndex_view_link(x0, x1) : RR.roots(_, Spec.WithdrawalIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalIndex_h.WithdrawalIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.WithdrawalIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalIndex_h.WithdrawalIndex_hash_tree_root(h, o)))])
  WithdrawalIndex_root_correct(h, o)

# Withdrawal: the root of every Withdrawal object is its specification root.
law Withdrawal_root_correct:
  for -h: B.Buf
  for +o: FuluWithdrawal_d.Withdrawal
  RR.roots(LV.v_Withdrawal(o), Spec.Withdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawal_h.Withdrawal_hash_tree_root(h, o)))])
def Withdrawal_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluWithdrawal_h.Withdrawal_root(64n, h, o, 0), (h, d_Withdrawal(64n, o)), st_Withdrawal(64n, h, o, 0)) :
    RR.roots(LV.v_Withdrawal(o), Spec.Withdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_Withdrawal(64n, {==}, o)

def Withdrawal_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32) -> {LV.v_Withdrawal(FuluWithdrawal_d.Withdrawal{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes20_d.Bytes20{x4, x5, x6, x7, x8}, O.U64{x9, x10}}) == S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8])}, S.Items{S.UnsignedValue{P.UInt{x9, x10, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}} : S.Value}: {==}
law Withdrawal_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for -h: B.Buf
  for +o: FuluWithdrawal_d.Withdrawal
  for +e: {o == FuluWithdrawal_d.Withdrawal{O.U64{x0, x1}, O.U64{x2, x3}, FuluBytes20_d.Bytes20{x4, x5, x6, x7, x8}, O.U64{x9, x10}} : FuluWithdrawal_d.Withdrawal}
  RR.roots(S.Sequence{S.Items{S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, S.Items{S.UnsignedValue{P.UInt{x2, x3, 0, 0, 0, 0, 0, 0}}, S.Items{S.BytesValue{F.limbs([x4, x5, x6, x7, x8])}, S.Items{S.UnsignedValue{P.UInt{x9, x10, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}}}, Spec.Withdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawal_h.Withdrawal_hash_tree_root(h, o)))])
def Withdrawal_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, h, o, e):
  %Withdrawal_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) : RR.roots(_, Spec.Withdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawal_h.Withdrawal_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_Withdrawal(_), Spec.Withdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawal_h.Withdrawal_hash_tree_root(h, o)))])
  Withdrawal_root_correct(h, o)

# BlobIndex: the root of every BlobIndex object is its specification root.
law BlobIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.BlobIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIndex_h.BlobIndex_hash_tree_root(h, o)))])
def BlobIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.BlobIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def BlobIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law BlobIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.BlobIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIndex_h.BlobIndex_hash_tree_root(h, o)))])
def BlobIndex_decoded_root_correct(x0, x1, h, o, e):
  %BlobIndex_view_link(x0, x1) : RR.roots(_, Spec.BlobIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIndex_h.BlobIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.BlobIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIndex_h.BlobIndex_hash_tree_root(h, o)))])
  BlobIndex_root_correct(h, o)

# BlobIdentifier: the root of every BlobIdentifier object is its specification root.
law BlobIdentifier_root_correct:
  for -h: B.Buf
  for +o: FuluBlobIdentifier_d.BlobIdentifier
  RR.roots(LV.v_BlobIdentifier(o), Spec.BlobIdentifier(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIdentifier_h.BlobIdentifier_hash_tree_root(h, o)))])
def BlobIdentifier_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBlobIdentifier_h.BlobIdentifier_root(64n, h, o, 0), (h, d_BlobIdentifier(64n, o)), st_BlobIdentifier(64n, h, o, 0)) :
    RR.roots(LV.v_BlobIdentifier(o), Spec.BlobIdentifier(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_BlobIdentifier(64n, {==}, o)

def BlobIdentifier_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32) -> {LV.v_BlobIdentifier(FuluBlobIdentifier_d.BlobIdentifier{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, O.U64{x8, x9}}) == S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.UnsignedValue{P.UInt{x8, x9, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}} : S.Value}: {==}
law BlobIdentifier_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for -h: B.Buf
  for +o: FuluBlobIdentifier_d.BlobIdentifier
  for +e: {o == FuluBlobIdentifier_d.BlobIdentifier{FuluBytes32_d.Bytes32{x0, x1, x2, x3, x4, x5, x6, x7}, O.U64{x8, x9}} : FuluBlobIdentifier_d.BlobIdentifier}
  RR.roots(S.Sequence{S.Items{S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7])}, S.Items{S.UnsignedValue{P.UInt{x8, x9, 0, 0, 0, 0, 0, 0}}, S.EmptyItems{}}}}, Spec.BlobIdentifier(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIdentifier_h.BlobIdentifier_hash_tree_root(h, o)))])
def BlobIdentifier_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, h, o, e):
  %BlobIdentifier_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9) : RR.roots(_, Spec.BlobIdentifier(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIdentifier_h.BlobIdentifier_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_BlobIdentifier(_), Spec.BlobIdentifier(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIdentifier_h.BlobIdentifier_hash_tree_root(h, o)))])
  BlobIdentifier_root_correct(h, o)

# KZGCommitment: the root of every KZGCommitment object is its specification root.
law KZGCommitment_root_correct:
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  RR.roots(LV.v_b48(o), Spec.KZGCommitment(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGCommitment_h.KZGCommitment_hash_tree_root(h, o)))])
def KZGCommitment_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(64n, h, o, 0), (h, d_b48(64n, o)), st_b48(64n, h, o, 0)) :
    RR.roots(LV.v_b48(o), Spec.KZGCommitment(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b48(64n, {==}, o)

def KZGCommitment_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32) -> {LV.v_b48(FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])} : S.Value}: {==}
law KZGCommitment_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  for +e: {o == FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11} : FuluBytes48_d.Bytes48}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, Spec.KZGCommitment(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGCommitment_h.KZGCommitment_hash_tree_root(h, o)))])
def KZGCommitment_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, h, o, e):
  %KZGCommitment_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) : RR.roots(_, Spec.KZGCommitment(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGCommitment_h.KZGCommitment_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b48(_), Spec.KZGCommitment(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGCommitment_h.KZGCommitment_hash_tree_root(h, o)))])
  KZGCommitment_root_correct(h, o)

# KZGProof: the root of every KZGProof object is its specification root.
law KZGProof_root_correct:
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  RR.roots(LV.v_b48(o), Spec.KZGProof(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGProof_h.KZGProof_hash_tree_root(h, o)))])
def KZGProof_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, FuluBytes48_h.b48_root(64n, h, o, 0), (h, d_b48(64n, o)), st_b48(64n, h, o, 0)) :
    RR.roots(LV.v_b48(o), Spec.KZGProof(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_b48(64n, {==}, o)

def KZGProof_view_link(+x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32, +x5: U32, +x6: U32, +x7: U32, +x8: U32, +x9: U32, +x10: U32, +x11: U32) -> {LV.v_b48(FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11}) == S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])} : S.Value}: {==}
law KZGProof_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for +x2: U32
  for +x3: U32
  for +x4: U32
  for +x5: U32
  for +x6: U32
  for +x7: U32
  for +x8: U32
  for +x9: U32
  for +x10: U32
  for +x11: U32
  for -h: B.Buf
  for +o: FuluBytes48_d.Bytes48
  for +e: {o == FuluBytes48_d.Bytes48{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11} : FuluBytes48_d.Bytes48}
  RR.roots(S.BytesValue{F.limbs([x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11])}, Spec.KZGProof(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGProof_h.KZGProof_hash_tree_root(h, o)))])
def KZGProof_decoded_root_correct(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, h, o, e):
  %KZGProof_view_link(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) : RR.roots(_, Spec.KZGProof(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGProof_h.KZGProof_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_b48(_), Spec.KZGProof(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGProof_h.KZGProof_hash_tree_root(h, o)))])
  KZGProof_root_correct(h, o)

# CellIndex: the root of every CellIndex object is its specification root.
law CellIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.CellIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCellIndex_h.CellIndex_hash_tree_root(h, o)))])
def CellIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.CellIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def CellIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law CellIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.CellIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCellIndex_h.CellIndex_hash_tree_root(h, o)))])
def CellIndex_decoded_root_correct(x0, x1, h, o, e):
  %CellIndex_view_link(x0, x1) : RR.roots(_, Spec.CellIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCellIndex_h.CellIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.CellIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCellIndex_h.CellIndex_hash_tree_root(h, o)))])
  CellIndex_root_correct(h, o)

# CommitmentIndex: the root of every CommitmentIndex object is its specification root.
law CommitmentIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.CommitmentIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitmentIndex_h.CommitmentIndex_hash_tree_root(h, o)))])
def CommitmentIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.CommitmentIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def CommitmentIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law CommitmentIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.CommitmentIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitmentIndex_h.CommitmentIndex_hash_tree_root(h, o)))])
def CommitmentIndex_decoded_root_correct(x0, x1, h, o, e):
  %CommitmentIndex_view_link(x0, x1) : RR.roots(_, Spec.CommitmentIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitmentIndex_h.CommitmentIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.CommitmentIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitmentIndex_h.CommitmentIndex_hash_tree_root(h, o)))])
  CommitmentIndex_root_correct(h, o)

# RowIndex: the root of every RowIndex object is its specification root.
law RowIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.RowIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRowIndex_h.RowIndex_hash_tree_root(h, o)))])
def RowIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.RowIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def RowIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law RowIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.RowIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRowIndex_h.RowIndex_hash_tree_root(h, o)))])
def RowIndex_decoded_root_correct(x0, x1, h, o, e):
  %RowIndex_view_link(x0, x1) : RR.roots(_, Spec.RowIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRowIndex_h.RowIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.RowIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRowIndex_h.RowIndex_hash_tree_root(h, o)))])
  RowIndex_root_correct(h, o)

# ColumnIndex: the root of every ColumnIndex object is its specification root.
law ColumnIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.ColumnIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluColumnIndex_h.ColumnIndex_hash_tree_root(h, o)))])
def ColumnIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.ColumnIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def ColumnIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law ColumnIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.ColumnIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluColumnIndex_h.ColumnIndex_hash_tree_root(h, o)))])
def ColumnIndex_decoded_root_correct(x0, x1, h, o, e):
  %ColumnIndex_view_link(x0, x1) : RR.roots(_, Spec.ColumnIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluColumnIndex_h.ColumnIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.ColumnIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluColumnIndex_h.ColumnIndex_hash_tree_root(h, o)))])
  ColumnIndex_root_correct(h, o)

# CustodyIndex: the root of every CustodyIndex object is its specification root.
law CustodyIndex_root_correct:
  for -h: B.Buf
  for +o: O.U64
  RR.roots(LV.v_u64(o), Spec.CustodyIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCustodyIndex_h.CustodyIndex_hash_tree_root(h, o)))])
def CustodyIndex_root_correct(h, o):
  %Equal.sym(B.Buf & D.Digest, uint64_h.u64_root(64n, h, o, 0), (h, d_u64(64n, o)), st_u64(64n, h, o, 0)) :
    RR.roots(LV.v_u64(o), Spec.CustodyIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, _))])
  rs_u64(64n, {==}, o)

def CustodyIndex_view_link(+x0: U32, +x1: U32) -> {LV.v_u64(O.U64{x0, x1}) == S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}} : S.Value}: {==}
law CustodyIndex_decoded_root_correct:
  for +x0: U32
  for +x1: U32
  for -h: B.Buf
  for +o: O.U64
  for +e: {o == O.U64{x0, x1} : O.U64}
  RR.roots(S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}, Spec.CustodyIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCustodyIndex_h.CustodyIndex_hash_tree_root(h, o)))])
def CustodyIndex_decoded_root_correct(x0, x1, h, o, e):
  %CustodyIndex_view_link(x0, x1) : RR.roots(_, Spec.CustodyIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCustodyIndex_h.CustodyIndex_hash_tree_root(h, o)))])
  %e : RR.roots(LV.v_u64(_), Spec.CustodyIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCustodyIndex_h.CustodyIndex_hash_tree_root(h, o)))])
  CustodyIndex_root_correct(h, o)

