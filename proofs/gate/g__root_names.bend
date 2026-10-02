import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
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
import ../obj/spec_fixed.bend as F
import ../obj/mtree_defs.bend as MD
import ../obj/root_leaf.bend as RL
import ../obj/bits_leaf.bend as BL
import ../../spec/bit_packing.bend as Bp
import ../../spec/bit_root.bend as Bits
import ../../spec/packing.bend as Pack
import ../obj/root_names_light.bend as LV
import ../obj/root_names.bend as PRV

# GENERATED by object_api_coverage_gate (codegen). Do not edit.
# The object API laws that proofs/obj/root_names.bend proves (AttestationData, BLSPubkey, BLSSignature, BLSToExecutionChange, BeaconBlockHeader, BlobIdentifier, BlobIndex, Bytes20, Bytes32, Bytes4, Bytes48, Bytes8, Bytes96, CellIndex, Checkpoint, ColumnIndex, CommitmentIndex, CommitteeIndex, ConsolidationRequest, CustodyIndex, DepositData, DepositMessage, DepositRequest, Domain, DomainType, Epoch, Eth1Block, Eth1Data, Ether, ExecutionAddress, Fork, ForkData, ForkDigest, G1Point, G2Point, Gwei, Hash32, HistoricalSummary, KZGCommitment, KZGProof, NodeID, PayloadId, PendingConsolidation, PendingDeposit, PendingPartialWithdrawal, PowBlock, Root, RowIndex, SignedBLSToExecutionChange, SignedBeaconBlockHeader, SignedVoluntaryExit, SigningData, SingleAttestation, Slot, SubnetID, SyncAggregate, SyncAggregatorSelectionData, SyncCommitteeContribution, SyncCommitteeMessage, Validator, ValidatorIndex, Version, VersionedHash, VoluntaryExit, Withdrawal, WithdrawalIndex, WithdrawalRequest, boolean, uint256, uint64), each discharged by that law.

def AttestationData__root__AttestationData_root_correct(-h: B.Buf, +o: FuluAttestationData_d.AttestationData) -> RR.roots(LV.v_AttestationData(o), Spec.AttestationData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluAttestationData_h.AttestationData_hash_tree_root(h, o)))]):
  PRV.AttestationData_root_correct(h, o)

def BLSPubkey__root__BLSPubkey_root_correct(-h: B.Buf, +o: FuluBytes48_d.Bytes48) -> RR.roots(LV.v_b48(o), Spec.BLSPubkey(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSPubkey_h.BLSPubkey_hash_tree_root(h, o)))]):
  PRV.BLSPubkey_root_correct(h, o)

def BLSSignature__root__BLSSignature_root_correct(-h: B.Buf, +o: FuluBytes96_d.Bytes96) -> RR.roots(LV.v_b96(o), Spec.BLSSignature(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSSignature_h.BLSSignature_hash_tree_root(h, o)))]):
  PRV.BLSSignature_root_correct(h, o)

def BLSToExecutionChange__root__BLSToExecutionChange_root_correct(-h: B.Buf, +o: FuluBLSToExecutionChange_d.BLSToExecutionChange) -> RR.roots(LV.v_BLSToExecutionChange(o), Spec.BLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBLSToExecutionChange_h.BLSToExecutionChange_hash_tree_root(h, o)))]):
  PRV.BLSToExecutionChange_root_correct(h, o)

def BeaconBlockHeader__root__BeaconBlockHeader_root_correct(-h: B.Buf, +o: FuluBeaconBlockHeader_d.BeaconBlockHeader) -> RR.roots(LV.v_BeaconBlockHeader(o), Spec.BeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBeaconBlockHeader_h.BeaconBlockHeader_hash_tree_root(h, o)))]):
  PRV.BeaconBlockHeader_root_correct(h, o)

def BlobIdentifier__root__BlobIdentifier_root_correct(-h: B.Buf, +o: FuluBlobIdentifier_d.BlobIdentifier) -> RR.roots(LV.v_BlobIdentifier(o), Spec.BlobIdentifier(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIdentifier_h.BlobIdentifier_hash_tree_root(h, o)))]):
  PRV.BlobIdentifier_root_correct(h, o)

def BlobIndex__root__BlobIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.BlobIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBlobIndex_h.BlobIndex_hash_tree_root(h, o)))]):
  PRV.BlobIndex_root_correct(h, o)

def Bytes20__root__Bytes20_root_correct(-h: B.Buf, +o: FuluBytes20_d.Bytes20) -> RR.roots(LV.v_b20(o), Spec.Bytes20(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes20_h.Bytes20_hash_tree_root(h, o)))]):
  PRV.Bytes20_root_correct(h, o)

def Bytes32__root__Bytes32_root_correct(-h: B.Buf, +o: FuluBytes32_d.Bytes32) -> RR.roots(LV.v_b32(o), Spec.Bytes32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes32_h.Bytes32_hash_tree_root(h, o)))]):
  PRV.Bytes32_root_correct(h, o)

def Bytes4__root__Bytes4_root_correct(-h: B.Buf, +o: FuluBytes4_d.Bytes4) -> RR.roots(LV.v_b4(o), Spec.Bytes4(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes4_h.Bytes4_hash_tree_root(h, o)))]):
  PRV.Bytes4_root_correct(h, o)

def Bytes48__root__Bytes48_root_correct(-h: B.Buf, +o: FuluBytes48_d.Bytes48) -> RR.roots(LV.v_b48(o), Spec.Bytes48(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes48_h.Bytes48_hash_tree_root(h, o)))]):
  PRV.Bytes48_root_correct(h, o)

def Bytes8__root__Bytes8_root_correct(-h: B.Buf, +o: FuluBytes8_d.Bytes8) -> RR.roots(LV.v_b8(o), Spec.Bytes8(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes8_h.Bytes8_hash_tree_root(h, o)))]):
  PRV.Bytes8_root_correct(h, o)

def Bytes96__root__Bytes96_root_correct(-h: B.Buf, +o: FuluBytes96_d.Bytes96) -> RR.roots(LV.v_b96(o), Spec.Bytes96(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluBytes96_h.Bytes96_hash_tree_root(h, o)))]):
  PRV.Bytes96_root_correct(h, o)

def CellIndex__root__CellIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.CellIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCellIndex_h.CellIndex_hash_tree_root(h, o)))]):
  PRV.CellIndex_root_correct(h, o)

def Checkpoint__root__Checkpoint_root_correct(-h: B.Buf, +o: FuluCheckpoint_d.Checkpoint) -> RR.roots(LV.v_Checkpoint(o), Spec.Checkpoint(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCheckpoint_h.Checkpoint_hash_tree_root(h, o)))]):
  PRV.Checkpoint_root_correct(h, o)

def ColumnIndex__root__ColumnIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.ColumnIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluColumnIndex_h.ColumnIndex_hash_tree_root(h, o)))]):
  PRV.ColumnIndex_root_correct(h, o)

def CommitmentIndex__root__CommitmentIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.CommitmentIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitmentIndex_h.CommitmentIndex_hash_tree_root(h, o)))]):
  PRV.CommitmentIndex_root_correct(h, o)

def CommitteeIndex__root__CommitteeIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.CommitteeIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCommitteeIndex_h.CommitteeIndex_hash_tree_root(h, o)))]):
  PRV.CommitteeIndex_root_correct(h, o)

def ConsolidationRequest__root__ConsolidationRequest_root_correct(-h: B.Buf, +o: FuluConsolidationRequest_d.ConsolidationRequest) -> RR.roots(LV.v_ConsolidationRequest(o), Spec.ConsolidationRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluConsolidationRequest_h.ConsolidationRequest_hash_tree_root(h, o)))]):
  PRV.ConsolidationRequest_root_correct(h, o)

def CustodyIndex__root__CustodyIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.CustodyIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluCustodyIndex_h.CustodyIndex_hash_tree_root(h, o)))]):
  PRV.CustodyIndex_root_correct(h, o)

def DepositData__root__DepositData_root_correct(-h: B.Buf, +o: FuluDepositData_d.DepositData) -> RR.roots(LV.v_DepositData(o), Spec.DepositData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositData_h.DepositData_hash_tree_root(h, o)))]):
  PRV.DepositData_root_correct(h, o)

def DepositMessage__root__DepositMessage_root_correct(-h: B.Buf, +o: FuluDepositMessage_d.DepositMessage) -> RR.roots(LV.v_DepositMessage(o), Spec.DepositMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositMessage_h.DepositMessage_hash_tree_root(h, o)))]):
  PRV.DepositMessage_root_correct(h, o)

def DepositRequest__root__DepositRequest_root_correct(-h: B.Buf, +o: FuluDepositRequest_d.DepositRequest) -> RR.roots(LV.v_DepositRequest(o), Spec.DepositRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDepositRequest_h.DepositRequest_hash_tree_root(h, o)))]):
  PRV.DepositRequest_root_correct(h, o)

def Domain__root__Domain_root_correct(-h: B.Buf, +o: FuluBytes32_d.Bytes32) -> RR.roots(LV.v_b32(o), Spec.Domain(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomain_h.Domain_hash_tree_root(h, o)))]):
  PRV.Domain_root_correct(h, o)

def DomainType__root__DomainType_root_correct(-h: B.Buf, +o: FuluBytes4_d.Bytes4) -> RR.roots(LV.v_b4(o), Spec.DomainType(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluDomainType_h.DomainType_hash_tree_root(h, o)))]):
  PRV.DomainType_root_correct(h, o)

def Epoch__root__Epoch_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.Epoch(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEpoch_h.Epoch_hash_tree_root(h, o)))]):
  PRV.Epoch_root_correct(h, o)

def Eth1Block__root__Eth1Block_root_correct(-h: B.Buf, +o: FuluEth1Block_d.Eth1Block) -> RR.roots(LV.v_Eth1Block(o), Spec.Eth1Block(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Block_h.Eth1Block_hash_tree_root(h, o)))]):
  PRV.Eth1Block_root_correct(h, o)

def Eth1Data__root__Eth1Data_root_correct(-h: B.Buf, +o: FuluEth1Data_d.Eth1Data) -> RR.roots(LV.v_Eth1Data(o), Spec.Eth1Data(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEth1Data_h.Eth1Data_hash_tree_root(h, o)))]):
  PRV.Eth1Data_root_correct(h, o)

def Ether__root__Ether_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.Ether(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluEther_h.Ether_hash_tree_root(h, o)))]):
  PRV.Ether_root_correct(h, o)

def ExecutionAddress__root__ExecutionAddress_root_correct(-h: B.Buf, +o: FuluBytes20_d.Bytes20) -> RR.roots(LV.v_b20(o), Spec.ExecutionAddress(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluExecutionAddress_h.ExecutionAddress_hash_tree_root(h, o)))]):
  PRV.ExecutionAddress_root_correct(h, o)

def Fork__root__Fork_root_correct(-h: B.Buf, +o: FuluFork_d.Fork) -> RR.roots(LV.v_Fork(o), Spec.Fork(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluFork_h.Fork_hash_tree_root(h, o)))]):
  PRV.Fork_root_correct(h, o)

def ForkData__root__ForkData_root_correct(-h: B.Buf, +o: FuluForkData_d.ForkData) -> RR.roots(LV.v_ForkData(o), Spec.ForkData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkData_h.ForkData_hash_tree_root(h, o)))]):
  PRV.ForkData_root_correct(h, o)

def ForkDigest__root__ForkDigest_root_correct(-h: B.Buf, +o: FuluBytes4_d.Bytes4) -> RR.roots(LV.v_b4(o), Spec.ForkDigest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluForkDigest_h.ForkDigest_hash_tree_root(h, o)))]):
  PRV.ForkDigest_root_correct(h, o)

def G1Point__root__G1Point_root_correct(-h: B.Buf, +o: FuluBytes48_d.Bytes48) -> RR.roots(LV.v_b48(o), Spec.G1Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG1Point_h.G1Point_hash_tree_root(h, o)))]):
  PRV.G1Point_root_correct(h, o)

def G2Point__root__G2Point_root_correct(-h: B.Buf, +o: FuluBytes96_d.Bytes96) -> RR.roots(LV.v_b96(o), Spec.G2Point(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluG2Point_h.G2Point_hash_tree_root(h, o)))]):
  PRV.G2Point_root_correct(h, o)

def Gwei__root__Gwei_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.Gwei(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluGwei_h.Gwei_hash_tree_root(h, o)))]):
  PRV.Gwei_root_correct(h, o)

def Hash32__root__Hash32_root_correct(-h: B.Buf, +o: FuluBytes32_d.Bytes32) -> RR.roots(LV.v_b32(o), Spec.Hash32(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHash32_h.Hash32_hash_tree_root(h, o)))]):
  PRV.Hash32_root_correct(h, o)

def HistoricalSummary__root__HistoricalSummary_root_correct(-h: B.Buf, +o: FuluHistoricalSummary_d.HistoricalSummary) -> RR.roots(LV.v_HistoricalSummary(o), Spec.HistoricalSummary(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluHistoricalSummary_h.HistoricalSummary_hash_tree_root(h, o)))]):
  PRV.HistoricalSummary_root_correct(h, o)

def KZGCommitment__root__KZGCommitment_root_correct(-h: B.Buf, +o: FuluBytes48_d.Bytes48) -> RR.roots(LV.v_b48(o), Spec.KZGCommitment(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGCommitment_h.KZGCommitment_hash_tree_root(h, o)))]):
  PRV.KZGCommitment_root_correct(h, o)

def KZGProof__root__KZGProof_root_correct(-h: B.Buf, +o: FuluBytes48_d.Bytes48) -> RR.roots(LV.v_b48(o), Spec.KZGProof(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluKZGProof_h.KZGProof_hash_tree_root(h, o)))]):
  PRV.KZGProof_root_correct(h, o)

def NodeID__root__NodeID_root_correct(-h: B.Buf, +o: uint256_d.Uint256) -> RR.roots(LV.v_u256(o), Spec.NodeID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluNodeID_h.NodeID_hash_tree_root(h, o)))]):
  PRV.NodeID_root_correct(h, o)

def PayloadId__root__PayloadId_root_correct(-h: B.Buf, +o: FuluBytes8_d.Bytes8) -> RR.roots(LV.v_b8(o), Spec.PayloadId(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPayloadId_h.PayloadId_hash_tree_root(h, o)))]):
  PRV.PayloadId_root_correct(h, o)

def PendingConsolidation__root__PendingConsolidation_root_correct(-h: B.Buf, +o: FuluPendingConsolidation_d.PendingConsolidation) -> RR.roots(LV.v_PendingConsolidation(o), Spec.PendingConsolidation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingConsolidation_h.PendingConsolidation_hash_tree_root(h, o)))]):
  PRV.PendingConsolidation_root_correct(h, o)

def PendingDeposit__root__PendingDeposit_root_correct(-h: B.Buf, +o: FuluPendingDeposit_d.PendingDeposit) -> RR.roots(LV.v_PendingDeposit(o), Spec.PendingDeposit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingDeposit_h.PendingDeposit_hash_tree_root(h, o)))]):
  PRV.PendingDeposit_root_correct(h, o)

def PendingPartialWithdrawal__root__PendingPartialWithdrawal_root_correct(-h: B.Buf, +o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal) -> RR.roots(LV.v_PendingPartialWithdrawal(o), Spec.PendingPartialWithdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPendingPartialWithdrawal_h.PendingPartialWithdrawal_hash_tree_root(h, o)))]):
  PRV.PendingPartialWithdrawal_root_correct(h, o)

def PowBlock__root__PowBlock_root_correct(-h: B.Buf, +o: FuluPowBlock_d.PowBlock) -> RR.roots(LV.v_PowBlock(o), Spec.PowBlock(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluPowBlock_h.PowBlock_hash_tree_root(h, o)))]):
  PRV.PowBlock_root_correct(h, o)

def Root__root__Root_root_correct(-h: B.Buf, +o: FuluBytes32_d.Bytes32) -> RR.roots(LV.v_b32(o), Spec.Root(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRoot_h.Root_hash_tree_root(h, o)))]):
  PRV.Root_root_correct(h, o)

def RowIndex__root__RowIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.RowIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluRowIndex_h.RowIndex_hash_tree_root(h, o)))]):
  PRV.RowIndex_root_correct(h, o)

def SignedBLSToExecutionChange__root__SignedBLSToExecutionChange_root_correct(-h: B.Buf, +o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange) -> RR.roots(LV.v_SignedBLSToExecutionChange(o), Spec.SignedBLSToExecutionChange(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBLSToExecutionChange_h.SignedBLSToExecutionChange_hash_tree_root(h, o)))]):
  PRV.SignedBLSToExecutionChange_root_correct(h, o)

def SignedBeaconBlockHeader__root__SignedBeaconBlockHeader_root_correct(-h: B.Buf, +o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader) -> RR.roots(LV.v_SignedBeaconBlockHeader(o), Spec.SignedBeaconBlockHeader(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedBeaconBlockHeader_h.SignedBeaconBlockHeader_hash_tree_root(h, o)))]):
  PRV.SignedBeaconBlockHeader_root_correct(h, o)

def SignedVoluntaryExit__root__SignedVoluntaryExit_root_correct(-h: B.Buf, +o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit) -> RR.roots(LV.v_SignedVoluntaryExit(o), Spec.SignedVoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSignedVoluntaryExit_h.SignedVoluntaryExit_hash_tree_root(h, o)))]):
  PRV.SignedVoluntaryExit_root_correct(h, o)

def SigningData__root__SigningData_root_correct(-h: B.Buf, +o: FuluSigningData_d.SigningData) -> RR.roots(LV.v_SigningData(o), Spec.SigningData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSigningData_h.SigningData_hash_tree_root(h, o)))]):
  PRV.SigningData_root_correct(h, o)

def SingleAttestation__root__SingleAttestation_root_correct(-h: B.Buf, +o: FuluSingleAttestation_d.SingleAttestation) -> RR.roots(LV.v_SingleAttestation(o), Spec.SingleAttestation(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSingleAttestation_h.SingleAttestation_hash_tree_root(h, o)))]):
  PRV.SingleAttestation_root_correct(h, o)

def Slot__root__Slot_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.Slot(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSlot_h.Slot_hash_tree_root(h, o)))]):
  PRV.Slot_root_correct(h, o)

def SubnetID__root__SubnetID_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.SubnetID(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSubnetID_h.SubnetID_hash_tree_root(h, o)))]):
  PRV.SubnetID_root_correct(h, o)

def SyncAggregate__root__SyncAggregate_root_correct(-h: B.Buf, +o: FuluSyncAggregate_d.SyncAggregate) -> RR.roots(LV.v_SyncAggregate(o), Spec.SyncAggregate(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregate_h.SyncAggregate_hash_tree_root(h, o)))]):
  PRV.SyncAggregate_root_correct(h, o)

def SyncAggregatorSelectionData__root__SyncAggregatorSelectionData_root_correct(-h: B.Buf, +o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData) -> RR.roots(LV.v_SyncAggregatorSelectionData(o), Spec.SyncAggregatorSelectionData(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncAggregatorSelectionData_h.SyncAggregatorSelectionData_hash_tree_root(h, o)))]):
  PRV.SyncAggregatorSelectionData_root_correct(h, o)

def SyncCommitteeContribution__root__SyncCommitteeContribution_root_correct(-h: B.Buf, +o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution) -> RR.roots(LV.v_SyncCommitteeContribution(o), Spec.SyncCommitteeContribution(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeContribution_h.SyncCommitteeContribution_hash_tree_root(h, o)))]):
  PRV.SyncCommitteeContribution_root_correct(h, o)

def SyncCommitteeMessage__root__SyncCommitteeMessage_root_correct(-h: B.Buf, +o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage) -> RR.roots(LV.v_SyncCommitteeMessage(o), Spec.SyncCommitteeMessage(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluSyncCommitteeMessage_h.SyncCommitteeMessage_hash_tree_root(h, o)))]):
  PRV.SyncCommitteeMessage_root_correct(h, o)

def Validator__root__Validator_root_correct(-h: B.Buf, +o: FuluValidator_d.Validator) -> RR.roots(LV.v_Validator(o), Spec.Validator(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidator_h.Validator_hash_tree_root(h, o)))]):
  PRV.Validator_root_correct(h, o)

def ValidatorIndex__root__ValidatorIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.ValidatorIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluValidatorIndex_h.ValidatorIndex_hash_tree_root(h, o)))]):
  PRV.ValidatorIndex_root_correct(h, o)

def Version__root__Version_root_correct(-h: B.Buf, +o: FuluBytes4_d.Bytes4) -> RR.roots(LV.v_b4(o), Spec.Version(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersion_h.Version_hash_tree_root(h, o)))]):
  PRV.Version_root_correct(h, o)

def VersionedHash__root__VersionedHash_root_correct(-h: B.Buf, +o: FuluBytes32_d.Bytes32) -> RR.roots(LV.v_b32(o), Spec.VersionedHash(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVersionedHash_h.VersionedHash_hash_tree_root(h, o)))]):
  PRV.VersionedHash_root_correct(h, o)

def VoluntaryExit__root__VoluntaryExit_root_correct(-h: B.Buf, +o: FuluVoluntaryExit_d.VoluntaryExit) -> RR.roots(LV.v_VoluntaryExit(o), Spec.VoluntaryExit(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluVoluntaryExit_h.VoluntaryExit_hash_tree_root(h, o)))]):
  PRV.VoluntaryExit_root_correct(h, o)

def Withdrawal__root__Withdrawal_root_correct(-h: B.Buf, +o: FuluWithdrawal_d.Withdrawal) -> RR.roots(LV.v_Withdrawal(o), Spec.Withdrawal(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawal_h.Withdrawal_hash_tree_root(h, o)))]):
  PRV.Withdrawal_root_correct(h, o)

def WithdrawalIndex__root__WithdrawalIndex_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.WithdrawalIndex(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalIndex_h.WithdrawalIndex_hash_tree_root(h, o)))]):
  PRV.WithdrawalIndex_root_correct(h, o)

def WithdrawalRequest__root__WithdrawalRequest_root_correct(-h: B.Buf, +o: FuluWithdrawalRequest_d.WithdrawalRequest) -> RR.roots(LV.v_WithdrawalRequest(o), Spec.WithdrawalRequest(), [D.bytes(Pair.snd(B.Buf, D.Digest, FuluWithdrawalRequest_h.WithdrawalRequest_hash_tree_root(h, o)))]):
  PRV.WithdrawalRequest_root_correct(h, o)

def boolean__root__boolean_root_correct(-h: B.Buf, +o: Bool) -> RR.roots(LV.v_bool(o), Spec.boolean(), [D.bytes(Pair.snd(B.Buf, D.Digest, boolean_h.boolean_hash_tree_root(h, o)))]):
  PRV.boolean_root_correct(h, o)

def uint256__root__uint256_root_correct(-h: B.Buf, +o: uint256_d.Uint256) -> RR.roots(LV.v_u256(o), Spec.uint256(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint256_h.uint256_hash_tree_root(h, o)))]):
  PRV.uint256_root_correct(h, o)

def uint64__root__uint64_root_correct(-h: B.Buf, +o: O.U64) -> RR.roots(LV.v_u64(o), Spec.uint64(), [D.bytes(Pair.snd(B.Buf, D.Digest, uint64_h.uint64_hash_tree_root(h, o)))]):
  PRV.uint64_root_correct(h, o)

