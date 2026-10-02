import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes4_def_generated.bend as FuluBytes4_d
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes8_def_generated.bend as FuluBytes8_d
import ../../types/uint256_def_generated.bend as uint256_d
import ../../types/uint8_encode_ssz_generated.bend as uint8_e
import ../../types/uint64_encode_ssz_generated.bend as uint64_e
import ../../types/uint256_encode_ssz_generated.bend as uint256_e
import ../../types/FuluBytes4_encode_ssz_generated.bend as FuluBytes4_e
import ../../types/FuluBytes32_encode_ssz_generated.bend as FuluBytes32_e
import ../../types/FuluBytes48_encode_ssz_generated.bend as FuluBytes48_e
import ../../types/FuluBytes8_encode_ssz_generated.bend as FuluBytes8_e
import ../../types/FuluBytes20_encode_ssz_generated.bend as FuluBytes20_e
import ../../types/FuluEth1Block_def_generated.bend as FuluEth1Block_d
import ../../types/FuluEth1Block_encode_ssz_generated.bend as FuluEth1Block_e
import ../../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../../types/FuluBeaconBlockHeader_encode_ssz_generated.bend as FuluBeaconBlockHeader_e
import ../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../types/FuluSignedBeaconBlockHeader_encode_ssz_generated.bend as FuluSignedBeaconBlockHeader_e
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluEth1Data_encode_ssz_generated.bend as FuluEth1Data_e
import ../../types/FuluCheckpoint_def_generated.bend as FuluCheckpoint_d
import ../../types/FuluCheckpoint_encode_ssz_generated.bend as FuluCheckpoint_e
import ../../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../../types/FuluAttestationData_encode_ssz_generated.bend as FuluAttestationData_e
import ../../types/FuluSingleAttestation_def_generated.bend as FuluSingleAttestation_d
import ../../types/FuluSingleAttestation_encode_ssz_generated.bend as FuluSingleAttestation_e
import ../../types/FuluForkData_def_generated.bend as FuluForkData_d
import ../../types/FuluForkData_encode_ssz_generated.bend as FuluForkData_e
import ../../types/FuluSigningData_def_generated.bend as FuluSigningData_d
import ../../types/FuluSigningData_encode_ssz_generated.bend as FuluSigningData_e
import ../../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../../types/FuluDepositRequest_encode_ssz_generated.bend as FuluDepositRequest_e
import ../../types/FuluPendingDeposit_def_generated.bend as FuluPendingDeposit_d
import ../../types/FuluPendingDeposit_encode_ssz_generated.bend as FuluPendingDeposit_e
import ../../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../../types/FuluDepositData_encode_ssz_generated.bend as FuluDepositData_e
import ../../types/FuluDepositMessage_def_generated.bend as FuluDepositMessage_d
import ../../types/FuluDepositMessage_encode_ssz_generated.bend as FuluDepositMessage_e
import ../../types/FuluValidator_def_generated.bend as FuluValidator_d
import ../../types/FuluValidator_encode_ssz_generated.bend as FuluValidator_e
import ../../types/FuluConsolidationRequest_def_generated.bend as FuluConsolidationRequest_d
import ../../types/FuluConsolidationRequest_encode_ssz_generated.bend as FuluConsolidationRequest_e
import ../../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../../types/FuluWithdrawalRequest_encode_ssz_generated.bend as FuluWithdrawalRequest_e
import ../../types/FuluBLSToExecutionChange_def_generated.bend as FuluBLSToExecutionChange_d
import ../../types/FuluBLSToExecutionChange_encode_ssz_generated.bend as FuluBLSToExecutionChange_e
import ../../types/FuluSignedBLSToExecutionChange_def_generated.bend as FuluSignedBLSToExecutionChange_d
import ../../types/FuluSignedBLSToExecutionChange_encode_ssz_generated.bend as FuluSignedBLSToExecutionChange_e
import ../../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
import ../../types/FuluWithdrawal_encode_ssz_generated.bend as FuluWithdrawal_e
import ../../types/FuluBlobIdentifier_def_generated.bend as FuluBlobIdentifier_d
import ../../types/FuluBlobIdentifier_encode_ssz_generated.bend as FuluBlobIdentifier_e
import ../../types/FuluForkDigest_encode_ssz_generated.bend as FuluForkDigest_e
import ../../types/FuluDomain_encode_ssz_generated.bend as FuluDomain_e
import ../../types/FuluBLSPubkey_encode_ssz_generated.bend as FuluBLSPubkey_e
import ../../types/FuluNodeID_encode_ssz_generated.bend as FuluNodeID_e
import ../../types/FuluSubnetID_encode_ssz_generated.bend as FuluSubnetID_e
import ../../types/FuluEther_encode_ssz_generated.bend as FuluEther_e
import ../../types/FuluParticipationFlags_encode_ssz_generated.bend as FuluParticipationFlags_e
import ../../types/FuluExecutionAddress_encode_ssz_generated.bend as FuluExecutionAddress_e
import ../../types/FuluPayloadId_encode_ssz_generated.bend as FuluPayloadId_e
import ../../types/FuluWithdrawalIndex_encode_ssz_generated.bend as FuluWithdrawalIndex_e
import ../../types/FuluBlobIndex_encode_ssz_generated.bend as FuluBlobIndex_e
import ../../types/FuluKZGCommitment_encode_ssz_generated.bend as FuluKZGCommitment_e
import ../../types/FuluKZGProof_encode_ssz_generated.bend as FuluKZGProof_e
import ../../types/FuluCellIndex_encode_ssz_generated.bend as FuluCellIndex_e
import ../../types/FuluCommitmentIndex_encode_ssz_generated.bend as FuluCommitmentIndex_e
import ../../types/FuluRowIndex_encode_ssz_generated.bend as FuluRowIndex_e
import ../obj/serialize_1_generated.bend as PRV

# GENERATED by object_api_coverage_gate (codegen). Do not edit.
# The object API laws that proofs/obj/serialize_1_generated.bend proves (AttestationData, BLSPubkey, BLSToExecutionChange, BeaconBlockHeader, BlobIdentifier, BlobIndex, CellIndex, Checkpoint, CommitmentIndex, ConsolidationRequest, DepositData, DepositMessage, DepositRequest, Domain, Eth1Block, Eth1Data, Ether, ExecutionAddress, ForkData, ForkDigest, KZGCommitment, KZGProof, NodeID, ParticipationFlags, PayloadId, PendingDeposit, RowIndex, SignedBLSToExecutionChange, SignedBeaconBlockHeader, SigningData, SingleAttestation, SubnetID, Validator, Withdrawal, WithdrawalIndex, WithdrawalRequest), each discharged by that law.

def AttestationData__serialize_valid__AttestationData_serialize_valid(+o: FuluAttestationData_d.AttestationData, e: {FuluAttestationData_e.AttestationData_valid(o) == True{} : Bool}) -> {FuluAttestationData_e.AttestationData_serialize(o) == O.encoded(FuluAttestationData_e.AttestationData_encode(o)) : O.Encoded}:
  PRV.AttestationData_serialize_valid(o, e)

def BLSPubkey__serialize_valid__BLSPubkey_serialize_valid(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == True{} : Bool}) -> {FuluBLSPubkey_e.BLSPubkey_serialize(o) == O.encoded(FuluBLSPubkey_e.BLSPubkey_encode(o)) : O.Encoded}:
  PRV.BLSPubkey_serialize_valid(o, e)

def BLSToExecutionChange__serialize_valid__BLSToExecutionChange_serialize_valid(+o: FuluBLSToExecutionChange_d.BLSToExecutionChange, e: {FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o) == True{} : Bool}) -> {FuluBLSToExecutionChange_e.BLSToExecutionChange_serialize(o) == O.encoded(FuluBLSToExecutionChange_e.BLSToExecutionChange_encode(o)) : O.Encoded}:
  PRV.BLSToExecutionChange_serialize_valid(o, e)

def BeaconBlockHeader__serialize_valid__BeaconBlockHeader_serialize_valid(+o: FuluBeaconBlockHeader_d.BeaconBlockHeader, e: {FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o) == True{} : Bool}) -> {FuluBeaconBlockHeader_e.BeaconBlockHeader_serialize(o) == O.encoded(FuluBeaconBlockHeader_e.BeaconBlockHeader_encode(o)) : O.Encoded}:
  PRV.BeaconBlockHeader_serialize_valid(o, e)

def BlobIdentifier__serialize_valid__BlobIdentifier_serialize_valid(+o: FuluBlobIdentifier_d.BlobIdentifier, e: {FuluBlobIdentifier_e.BlobIdentifier_valid(o) == True{} : Bool}) -> {FuluBlobIdentifier_e.BlobIdentifier_serialize(o) == O.encoded(FuluBlobIdentifier_e.BlobIdentifier_encode(o)) : O.Encoded}:
  PRV.BlobIdentifier_serialize_valid(o, e)

def BlobIndex__serialize_valid__BlobIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluBlobIndex_e.BlobIndex_serialize(o) == O.encoded(FuluBlobIndex_e.BlobIndex_encode(o)) : O.Encoded}:
  PRV.BlobIndex_serialize_valid(o, e)

def CellIndex__serialize_valid__CellIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluCellIndex_e.CellIndex_serialize(o) == O.encoded(FuluCellIndex_e.CellIndex_encode(o)) : O.Encoded}:
  PRV.CellIndex_serialize_valid(o, e)

def Checkpoint__serialize_valid__Checkpoint_serialize_valid(+o: FuluCheckpoint_d.Checkpoint, e: {FuluCheckpoint_e.Checkpoint_valid(o) == True{} : Bool}) -> {FuluCheckpoint_e.Checkpoint_serialize(o) == O.encoded(FuluCheckpoint_e.Checkpoint_encode(o)) : O.Encoded}:
  PRV.Checkpoint_serialize_valid(o, e)

def CommitmentIndex__serialize_valid__CommitmentIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluCommitmentIndex_e.CommitmentIndex_serialize(o) == O.encoded(FuluCommitmentIndex_e.CommitmentIndex_encode(o)) : O.Encoded}:
  PRV.CommitmentIndex_serialize_valid(o, e)

def ConsolidationRequest__serialize_valid__ConsolidationRequest_serialize_valid(+o: FuluConsolidationRequest_d.ConsolidationRequest, e: {FuluConsolidationRequest_e.ConsolidationRequest_valid(o) == True{} : Bool}) -> {FuluConsolidationRequest_e.ConsolidationRequest_serialize(o) == O.encoded(FuluConsolidationRequest_e.ConsolidationRequest_encode(o)) : O.Encoded}:
  PRV.ConsolidationRequest_serialize_valid(o, e)

def DepositData__serialize_valid__DepositData_serialize_valid(+o: FuluDepositData_d.DepositData, e: {FuluDepositData_e.DepositData_valid(o) == True{} : Bool}) -> {FuluDepositData_e.DepositData_serialize(o) == O.encoded(FuluDepositData_e.DepositData_encode(o)) : O.Encoded}:
  PRV.DepositData_serialize_valid(o, e)

def DepositMessage__serialize_valid__DepositMessage_serialize_valid(+o: FuluDepositMessage_d.DepositMessage, e: {FuluDepositMessage_e.DepositMessage_valid(o) == True{} : Bool}) -> {FuluDepositMessage_e.DepositMessage_serialize(o) == O.encoded(FuluDepositMessage_e.DepositMessage_encode(o)) : O.Encoded}:
  PRV.DepositMessage_serialize_valid(o, e)

def DepositRequest__serialize_valid__DepositRequest_serialize_valid(+o: FuluDepositRequest_d.DepositRequest, e: {FuluDepositRequest_e.DepositRequest_valid(o) == True{} : Bool}) -> {FuluDepositRequest_e.DepositRequest_serialize(o) == O.encoded(FuluDepositRequest_e.DepositRequest_encode(o)) : O.Encoded}:
  PRV.DepositRequest_serialize_valid(o, e)

def Domain__serialize_valid__Domain_serialize_valid(+o: FuluBytes32_d.Bytes32, e: {FuluBytes32_e.b32_valid(o) == True{} : Bool}) -> {FuluDomain_e.Domain_serialize(o) == O.encoded(FuluDomain_e.Domain_encode(o)) : O.Encoded}:
  PRV.Domain_serialize_valid(o, e)

def Eth1Block__serialize_valid__Eth1Block_serialize_valid(+o: FuluEth1Block_d.Eth1Block, e: {FuluEth1Block_e.Eth1Block_valid(o) == True{} : Bool}) -> {FuluEth1Block_e.Eth1Block_serialize(o) == O.encoded(FuluEth1Block_e.Eth1Block_encode(o)) : O.Encoded}:
  PRV.Eth1Block_serialize_valid(o, e)

def Eth1Data__serialize_valid__Eth1Data_serialize_valid(+o: FuluEth1Data_d.Eth1Data, e: {FuluEth1Data_e.Eth1Data_valid(o) == True{} : Bool}) -> {FuluEth1Data_e.Eth1Data_serialize(o) == O.encoded(FuluEth1Data_e.Eth1Data_encode(o)) : O.Encoded}:
  PRV.Eth1Data_serialize_valid(o, e)

def Ether__serialize_valid__Ether_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluEther_e.Ether_serialize(o) == O.encoded(FuluEther_e.Ether_encode(o)) : O.Encoded}:
  PRV.Ether_serialize_valid(o, e)

def ExecutionAddress__serialize_valid__ExecutionAddress_serialize_valid(+o: FuluBytes20_d.Bytes20, e: {FuluBytes20_e.b20_valid(o) == True{} : Bool}) -> {FuluExecutionAddress_e.ExecutionAddress_serialize(o) == O.encoded(FuluExecutionAddress_e.ExecutionAddress_encode(o)) : O.Encoded}:
  PRV.ExecutionAddress_serialize_valid(o, e)

def ForkData__serialize_valid__ForkData_serialize_valid(+o: FuluForkData_d.ForkData, e: {FuluForkData_e.ForkData_valid(o) == True{} : Bool}) -> {FuluForkData_e.ForkData_serialize(o) == O.encoded(FuluForkData_e.ForkData_encode(o)) : O.Encoded}:
  PRV.ForkData_serialize_valid(o, e)

def ForkDigest__serialize_valid__ForkDigest_serialize_valid(+o: FuluBytes4_d.Bytes4, e: {FuluBytes4_e.b4_valid(o) == True{} : Bool}) -> {FuluForkDigest_e.ForkDigest_serialize(o) == O.encoded(FuluForkDigest_e.ForkDigest_encode(o)) : O.Encoded}:
  PRV.ForkDigest_serialize_valid(o, e)

def KZGCommitment__serialize_valid__KZGCommitment_serialize_valid(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == True{} : Bool}) -> {FuluKZGCommitment_e.KZGCommitment_serialize(o) == O.encoded(FuluKZGCommitment_e.KZGCommitment_encode(o)) : O.Encoded}:
  PRV.KZGCommitment_serialize_valid(o, e)

def KZGProof__serialize_valid__KZGProof_serialize_valid(+o: FuluBytes48_d.Bytes48, e: {FuluBytes48_e.b48_valid(o) == True{} : Bool}) -> {FuluKZGProof_e.KZGProof_serialize(o) == O.encoded(FuluKZGProof_e.KZGProof_encode(o)) : O.Encoded}:
  PRV.KZGProof_serialize_valid(o, e)

def NodeID__serialize_valid__NodeID_serialize_valid(+o: uint256_d.Uint256, e: {uint256_e.u256_valid(o) == True{} : Bool}) -> {FuluNodeID_e.NodeID_serialize(o) == O.encoded(FuluNodeID_e.NodeID_encode(o)) : O.Encoded}:
  PRV.NodeID_serialize_valid(o, e)

def ParticipationFlags__serialize_valid__ParticipationFlags_serialize_valid(+o: U32, e: {uint8_e.u8_valid(o) == True{} : Bool}) -> {FuluParticipationFlags_e.ParticipationFlags_serialize(o) == O.encoded(FuluParticipationFlags_e.ParticipationFlags_encode(o)) : O.Encoded}:
  PRV.ParticipationFlags_serialize_valid(o, e)

def PayloadId__serialize_valid__PayloadId_serialize_valid(+o: FuluBytes8_d.Bytes8, e: {FuluBytes8_e.b8_valid(o) == True{} : Bool}) -> {FuluPayloadId_e.PayloadId_serialize(o) == O.encoded(FuluPayloadId_e.PayloadId_encode(o)) : O.Encoded}:
  PRV.PayloadId_serialize_valid(o, e)

def PendingDeposit__serialize_valid__PendingDeposit_serialize_valid(+o: FuluPendingDeposit_d.PendingDeposit, e: {FuluPendingDeposit_e.PendingDeposit_valid(o) == True{} : Bool}) -> {FuluPendingDeposit_e.PendingDeposit_serialize(o) == O.encoded(FuluPendingDeposit_e.PendingDeposit_encode(o)) : O.Encoded}:
  PRV.PendingDeposit_serialize_valid(o, e)

def RowIndex__serialize_valid__RowIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluRowIndex_e.RowIndex_serialize(o) == O.encoded(FuluRowIndex_e.RowIndex_encode(o)) : O.Encoded}:
  PRV.RowIndex_serialize_valid(o, e)

def SignedBLSToExecutionChange__serialize_valid__SignedBLSToExecutionChange_serialize_valid(+o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, e: {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o) == True{} : Bool}) -> {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_serialize(o) == O.encoded(FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_encode(o)) : O.Encoded}:
  PRV.SignedBLSToExecutionChange_serialize_valid(o, e)

def SignedBeaconBlockHeader__serialize_valid__SignedBeaconBlockHeader_serialize_valid(+o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader, e: {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o) == True{} : Bool}) -> {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_serialize(o) == O.encoded(FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_encode(o)) : O.Encoded}:
  PRV.SignedBeaconBlockHeader_serialize_valid(o, e)

def SigningData__serialize_valid__SigningData_serialize_valid(+o: FuluSigningData_d.SigningData, e: {FuluSigningData_e.SigningData_valid(o) == True{} : Bool}) -> {FuluSigningData_e.SigningData_serialize(o) == O.encoded(FuluSigningData_e.SigningData_encode(o)) : O.Encoded}:
  PRV.SigningData_serialize_valid(o, e)

def SingleAttestation__serialize_valid__SingleAttestation_serialize_valid(+o: FuluSingleAttestation_d.SingleAttestation, e: {FuluSingleAttestation_e.SingleAttestation_valid(o) == True{} : Bool}) -> {FuluSingleAttestation_e.SingleAttestation_serialize(o) == O.encoded(FuluSingleAttestation_e.SingleAttestation_encode(o)) : O.Encoded}:
  PRV.SingleAttestation_serialize_valid(o, e)

def SubnetID__serialize_valid__SubnetID_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluSubnetID_e.SubnetID_serialize(o) == O.encoded(FuluSubnetID_e.SubnetID_encode(o)) : O.Encoded}:
  PRV.SubnetID_serialize_valid(o, e)

def Validator__serialize_valid__Validator_serialize_valid(+o: FuluValidator_d.Validator, e: {FuluValidator_e.Validator_valid(o) == True{} : Bool}) -> {FuluValidator_e.Validator_serialize(o) == O.encoded(FuluValidator_e.Validator_encode(o)) : O.Encoded}:
  PRV.Validator_serialize_valid(o, e)

def Withdrawal__serialize_valid__Withdrawal_serialize_valid(+o: FuluWithdrawal_d.Withdrawal, e: {FuluWithdrawal_e.Withdrawal_valid(o) == True{} : Bool}) -> {FuluWithdrawal_e.Withdrawal_serialize(o) == O.encoded(FuluWithdrawal_e.Withdrawal_encode(o)) : O.Encoded}:
  PRV.Withdrawal_serialize_valid(o, e)

def WithdrawalIndex__serialize_valid__WithdrawalIndex_serialize_valid(+o: O.U64, e: {uint64_e.u64_valid(o) == True{} : Bool}) -> {FuluWithdrawalIndex_e.WithdrawalIndex_serialize(o) == O.encoded(FuluWithdrawalIndex_e.WithdrawalIndex_encode(o)) : O.Encoded}:
  PRV.WithdrawalIndex_serialize_valid(o, e)

def WithdrawalRequest__serialize_valid__WithdrawalRequest_serialize_valid(+o: FuluWithdrawalRequest_d.WithdrawalRequest, e: {FuluWithdrawalRequest_e.WithdrawalRequest_valid(o) == True{} : Bool}) -> {FuluWithdrawalRequest_e.WithdrawalRequest_serialize(o) == O.encoded(FuluWithdrawalRequest_e.WithdrawalRequest_encode(o)) : O.Encoded}:
  PRV.WithdrawalRequest_serialize_valid(o, e)

