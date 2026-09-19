import Base
import ../types/fulu.bend as F
import ../types/schema.bend as T
import ../src/ssz.bend as API
import ../spec/type_legality.bend as Legal
import ../spec/codec.bend as S
import ./fulu_legality.bend as Named
import ./codec_composition.bend as Codec

# Closed proof index over every frozen public name, including untested types.
type Name is Data:
  boolean{}
  uint8{}
  uint32{}
  uint64{}
  uint256{}
  Bytes1{}
  Bytes4{}
  Bytes32{}
  Bytes48{}
  Bytes96{}
  Bytes8{}
  Bytes20{}
  Slot{}
  Epoch{}
  Gwei{}
  Hash32{}
  Version{}
  DomainType{}
  BLSSignature{}
  FinalityBranch{}
  VersionedHash{}
  G1Point{}
  G2Point{}
  Fork{}
  SyncAggregate{}
  SyncAggregatorSelectionData{}
  PowBlock{}
  CommitteeIndex{}
  ValidatorIndex{}
  PendingConsolidation{}
  PendingPartialWithdrawal{}
  VoluntaryExit{}
  SignedVoluntaryExit{}
  Root{}
  HistoricalSummary{}
  SyncCommitteeContribution{}
  ContributionAndProof{}
  SignedContributionAndProof{}
  SyncCommitteeMessage{}
  Eth1Block{}
  BeaconBlockHeader{}
  SignedBeaconBlockHeader{}
  ProposerSlashing{}
  HistoricalBatch{}
  Eth1Data{}
  Checkpoint{}
  AttestationData{}
  SingleAttestation{}
  Attestation{}
  AggregateAndProof{}
  SignedAggregateAndProof{}
  PendingAttestation{}
  IndexedAttestation{}
  AttesterSlashing{}
  ForkData{}
  ForkDigest{}
  Domain{}
  SigningData{}
  BLSPubkey{}
  DepositRequest{}
  PendingDeposit{}
  SyncCommittee{}
  DepositData{}
  Deposit{}
  DepositMessage{}
  Validator{}
  NodeID{}
  SubnetID{}
  Ether{}
  ParticipationFlags{}
  CurrentSyncCommitteeBranch{}
  NextSyncCommitteeBranch{}
  Transaction{}
  ExecutionAddress{}
  ConsolidationRequest{}
  WithdrawalRequest{}
  ExecutionRequests{}
  BLSToExecutionChange{}
  SignedBLSToExecutionChange{}
  ExecutionPayloadHeader{}
  PayloadId{}
  WithdrawalIndex{}
  Withdrawal{}
  ExecutionPayload{}
  BeaconState{}
  ExecutionBranch{}
  LightClientHeader{}
  LightClientOptimisticUpdate{}
  LightClientFinalityUpdate{}
  LightClientUpdate{}
  LightClientBootstrap{}
  BlobIndex{}
  BlobIdentifier{}
  KZGCommitment{}
  BeaconBlockBody{}
  BeaconBlock{}
  SignedBeaconBlock{}
  KZGProof{}
  Blob{}
  BlobSidecar{}
  Cell{}
  CellIndex{}
  CommitmentIndex{}
  RowIndex{}
  ColumnIndex{}
  DataColumnsByRootIdentifier{}
  MatrixEntry{}
  DataColumnSidecar{}
  CustodyIndex{}

def schema(name: Name) -> T.Schema:
  match name:
    case boolean{}: F.boolean.schema()
    case uint8{}: F.uint8.schema()
    case uint32{}: F.uint32.schema()
    case uint64{}: F.uint64.schema()
    case uint256{}: F.uint256.schema()
    case Bytes1{}: F.Bytes1.schema()
    case Bytes4{}: F.Bytes4.schema()
    case Bytes32{}: F.Bytes32.schema()
    case Bytes48{}: F.Bytes48.schema()
    case Bytes96{}: F.Bytes96.schema()
    case Bytes8{}: F.Bytes8.schema()
    case Bytes20{}: F.Bytes20.schema()
    case Slot{}: F.Slot.schema()
    case Epoch{}: F.Epoch.schema()
    case Gwei{}: F.Gwei.schema()
    case Hash32{}: F.Hash32.schema()
    case Version{}: F.Version.schema()
    case DomainType{}: F.DomainType.schema()
    case BLSSignature{}: F.BLSSignature.schema()
    case FinalityBranch{}: F.FinalityBranch.schema()
    case VersionedHash{}: F.VersionedHash.schema()
    case G1Point{}: F.G1Point.schema()
    case G2Point{}: F.G2Point.schema()
    case Fork{}: F.Fork.schema()
    case SyncAggregate{}: F.SyncAggregate.schema()
    case SyncAggregatorSelectionData{}: F.SyncAggregatorSelectionData.schema()
    case PowBlock{}: F.PowBlock.schema()
    case CommitteeIndex{}: F.CommitteeIndex.schema()
    case ValidatorIndex{}: F.ValidatorIndex.schema()
    case PendingConsolidation{}: F.PendingConsolidation.schema()
    case PendingPartialWithdrawal{}: F.PendingPartialWithdrawal.schema()
    case VoluntaryExit{}: F.VoluntaryExit.schema()
    case SignedVoluntaryExit{}: F.SignedVoluntaryExit.schema()
    case Root{}: F.Root.schema()
    case HistoricalSummary{}: F.HistoricalSummary.schema()
    case SyncCommitteeContribution{}: F.SyncCommitteeContribution.schema()
    case ContributionAndProof{}: F.ContributionAndProof.schema()
    case SignedContributionAndProof{}: F.SignedContributionAndProof.schema()
    case SyncCommitteeMessage{}: F.SyncCommitteeMessage.schema()
    case Eth1Block{}: F.Eth1Block.schema()
    case BeaconBlockHeader{}: F.BeaconBlockHeader.schema()
    case SignedBeaconBlockHeader{}: F.SignedBeaconBlockHeader.schema()
    case ProposerSlashing{}: F.ProposerSlashing.schema()
    case HistoricalBatch{}: F.HistoricalBatch.schema()
    case Eth1Data{}: F.Eth1Data.schema()
    case Checkpoint{}: F.Checkpoint.schema()
    case AttestationData{}: F.AttestationData.schema()
    case SingleAttestation{}: F.SingleAttestation.schema()
    case Attestation{}: F.Attestation.schema()
    case AggregateAndProof{}: F.AggregateAndProof.schema()
    case SignedAggregateAndProof{}: F.SignedAggregateAndProof.schema()
    case PendingAttestation{}: F.PendingAttestation.schema()
    case IndexedAttestation{}: F.IndexedAttestation.schema()
    case AttesterSlashing{}: F.AttesterSlashing.schema()
    case ForkData{}: F.ForkData.schema()
    case ForkDigest{}: F.ForkDigest.schema()
    case Domain{}: F.Domain.schema()
    case SigningData{}: F.SigningData.schema()
    case BLSPubkey{}: F.BLSPubkey.schema()
    case DepositRequest{}: F.DepositRequest.schema()
    case PendingDeposit{}: F.PendingDeposit.schema()
    case SyncCommittee{}: F.SyncCommittee.schema()
    case DepositData{}: F.DepositData.schema()
    case Deposit{}: F.Deposit.schema()
    case DepositMessage{}: F.DepositMessage.schema()
    case Validator{}: F.Validator.schema()
    case NodeID{}: F.NodeID.schema()
    case SubnetID{}: F.SubnetID.schema()
    case Ether{}: F.Ether.schema()
    case ParticipationFlags{}: F.ParticipationFlags.schema()
    case CurrentSyncCommitteeBranch{}: F.CurrentSyncCommitteeBranch.schema()
    case NextSyncCommitteeBranch{}: F.NextSyncCommitteeBranch.schema()
    case Transaction{}: F.Transaction.schema()
    case ExecutionAddress{}: F.ExecutionAddress.schema()
    case ConsolidationRequest{}: F.ConsolidationRequest.schema()
    case WithdrawalRequest{}: F.WithdrawalRequest.schema()
    case ExecutionRequests{}: F.ExecutionRequests.schema()
    case BLSToExecutionChange{}: F.BLSToExecutionChange.schema()
    case SignedBLSToExecutionChange{}: F.SignedBLSToExecutionChange.schema()
    case ExecutionPayloadHeader{}: F.ExecutionPayloadHeader.schema()
    case PayloadId{}: F.PayloadId.schema()
    case WithdrawalIndex{}: F.WithdrawalIndex.schema()
    case Withdrawal{}: F.Withdrawal.schema()
    case ExecutionPayload{}: F.ExecutionPayload.schema()
    case BeaconState{}: F.BeaconState.schema()
    case ExecutionBranch{}: F.ExecutionBranch.schema()
    case LightClientHeader{}: F.LightClientHeader.schema()
    case LightClientOptimisticUpdate{}: F.LightClientOptimisticUpdate.schema()
    case LightClientFinalityUpdate{}: F.LightClientFinalityUpdate.schema()
    case LightClientUpdate{}: F.LightClientUpdate.schema()
    case LightClientBootstrap{}: F.LightClientBootstrap.schema()
    case BlobIndex{}: F.BlobIndex.schema()
    case BlobIdentifier{}: F.BlobIdentifier.schema()
    case KZGCommitment{}: F.KZGCommitment.schema()
    case BeaconBlockBody{}: F.BeaconBlockBody.schema()
    case BeaconBlock{}: F.BeaconBlock.schema()
    case SignedBeaconBlock{}: F.SignedBeaconBlock.schema()
    case KZGProof{}: F.KZGProof.schema()
    case Blob{}: F.Blob.schema()
    case BlobSidecar{}: F.BlobSidecar.schema()
    case Cell{}: F.Cell.schema()
    case CellIndex{}: F.CellIndex.schema()
    case CommitmentIndex{}: F.CommitmentIndex.schema()
    case RowIndex{}: F.RowIndex.schema()
    case ColumnIndex{}: F.ColumnIndex.schema()
    case DataColumnsByRootIdentifier{}: F.DataColumnsByRootIdentifier.schema()
    case MatrixEntry{}: F.MatrixEntry.schema()
    case DataColumnSidecar{}: F.DataColumnSidecar.schema()
    case CustodyIndex{}: F.CustodyIndex.schema()

law type_legal:
  for +name: Name
  Legal.type_legal(schema(name))
def type_legal(name):
  match name:
    case boolean{}: Named.boolean_normative_legal()
    case uint8{}: Named.uint8_normative_legal()
    case uint32{}: Named.uint32_normative_legal()
    case uint64{}: Named.uint64_normative_legal()
    case uint256{}: Named.uint256_normative_legal()
    case Bytes1{}: Named.Bytes1_normative_legal()
    case Bytes4{}: Named.Bytes4_normative_legal()
    case Bytes32{}: Named.Bytes32_normative_legal()
    case Bytes48{}: Named.Bytes48_normative_legal()
    case Bytes96{}: Named.Bytes96_normative_legal()
    case Bytes8{}: Named.Bytes8_normative_legal()
    case Bytes20{}: Named.Bytes20_normative_legal()
    case Slot{}: Named.Slot_normative_legal()
    case Epoch{}: Named.Epoch_normative_legal()
    case Gwei{}: Named.Gwei_normative_legal()
    case Hash32{}: Named.Hash32_normative_legal()
    case Version{}: Named.Version_normative_legal()
    case DomainType{}: Named.DomainType_normative_legal()
    case BLSSignature{}: Named.BLSSignature_normative_legal()
    case FinalityBranch{}: Named.FinalityBranch_normative_legal()
    case VersionedHash{}: Named.VersionedHash_normative_legal()
    case G1Point{}: Named.G1Point_normative_legal()
    case G2Point{}: Named.G2Point_normative_legal()
    case Fork{}: Named.Fork_normative_legal()
    case SyncAggregate{}: Named.SyncAggregate_normative_legal()
    case SyncAggregatorSelectionData{}: Named.SyncAggregatorSelectionData_normative_legal()
    case PowBlock{}: Named.PowBlock_normative_legal()
    case CommitteeIndex{}: Named.CommitteeIndex_normative_legal()
    case ValidatorIndex{}: Named.ValidatorIndex_normative_legal()
    case PendingConsolidation{}: Named.PendingConsolidation_normative_legal()
    case PendingPartialWithdrawal{}: Named.PendingPartialWithdrawal_normative_legal()
    case VoluntaryExit{}: Named.VoluntaryExit_normative_legal()
    case SignedVoluntaryExit{}: Named.SignedVoluntaryExit_normative_legal()
    case Root{}: Named.Root_normative_legal()
    case HistoricalSummary{}: Named.HistoricalSummary_normative_legal()
    case SyncCommitteeContribution{}: Named.SyncCommitteeContribution_normative_legal()
    case ContributionAndProof{}: Named.ContributionAndProof_normative_legal()
    case SignedContributionAndProof{}: Named.SignedContributionAndProof_normative_legal()
    case SyncCommitteeMessage{}: Named.SyncCommitteeMessage_normative_legal()
    case Eth1Block{}: Named.Eth1Block_normative_legal()
    case BeaconBlockHeader{}: Named.BeaconBlockHeader_normative_legal()
    case SignedBeaconBlockHeader{}: Named.SignedBeaconBlockHeader_normative_legal()
    case ProposerSlashing{}: Named.ProposerSlashing_normative_legal()
    case HistoricalBatch{}: Named.HistoricalBatch_normative_legal()
    case Eth1Data{}: Named.Eth1Data_normative_legal()
    case Checkpoint{}: Named.Checkpoint_normative_legal()
    case AttestationData{}: Named.AttestationData_normative_legal()
    case SingleAttestation{}: Named.SingleAttestation_normative_legal()
    case Attestation{}: Named.Attestation_normative_legal()
    case AggregateAndProof{}: Named.AggregateAndProof_normative_legal()
    case SignedAggregateAndProof{}: Named.SignedAggregateAndProof_normative_legal()
    case PendingAttestation{}: Named.PendingAttestation_normative_legal()
    case IndexedAttestation{}: Named.IndexedAttestation_normative_legal()
    case AttesterSlashing{}: Named.AttesterSlashing_normative_legal()
    case ForkData{}: Named.ForkData_normative_legal()
    case ForkDigest{}: Named.ForkDigest_normative_legal()
    case Domain{}: Named.Domain_normative_legal()
    case SigningData{}: Named.SigningData_normative_legal()
    case BLSPubkey{}: Named.BLSPubkey_normative_legal()
    case DepositRequest{}: Named.DepositRequest_normative_legal()
    case PendingDeposit{}: Named.PendingDeposit_normative_legal()
    case SyncCommittee{}: Named.SyncCommittee_normative_legal()
    case DepositData{}: Named.DepositData_normative_legal()
    case Deposit{}: Named.Deposit_normative_legal()
    case DepositMessage{}: Named.DepositMessage_normative_legal()
    case Validator{}: Named.Validator_normative_legal()
    case NodeID{}: Named.NodeID_normative_legal()
    case SubnetID{}: Named.SubnetID_normative_legal()
    case Ether{}: Named.Ether_normative_legal()
    case ParticipationFlags{}: Named.ParticipationFlags_normative_legal()
    case CurrentSyncCommitteeBranch{}: Named.CurrentSyncCommitteeBranch_normative_legal()
    case NextSyncCommitteeBranch{}: Named.NextSyncCommitteeBranch_normative_legal()
    case Transaction{}: Named.Transaction_normative_legal()
    case ExecutionAddress{}: Named.ExecutionAddress_normative_legal()
    case ConsolidationRequest{}: Named.ConsolidationRequest_normative_legal()
    case WithdrawalRequest{}: Named.WithdrawalRequest_normative_legal()
    case ExecutionRequests{}: Named.ExecutionRequests_normative_legal()
    case BLSToExecutionChange{}: Named.BLSToExecutionChange_normative_legal()
    case SignedBLSToExecutionChange{}: Named.SignedBLSToExecutionChange_normative_legal()
    case ExecutionPayloadHeader{}: Named.ExecutionPayloadHeader_normative_legal()
    case PayloadId{}: Named.PayloadId_normative_legal()
    case WithdrawalIndex{}: Named.WithdrawalIndex_normative_legal()
    case Withdrawal{}: Named.Withdrawal_normative_legal()
    case ExecutionPayload{}: Named.ExecutionPayload_normative_legal()
    case BeaconState{}: Named.BeaconState_normative_legal()
    case ExecutionBranch{}: Named.ExecutionBranch_normative_legal()
    case LightClientHeader{}: Named.LightClientHeader_normative_legal()
    case LightClientOptimisticUpdate{}: Named.LightClientOptimisticUpdate_normative_legal()
    case LightClientFinalityUpdate{}: Named.LightClientFinalityUpdate_normative_legal()
    case LightClientUpdate{}: Named.LightClientUpdate_normative_legal()
    case LightClientBootstrap{}: Named.LightClientBootstrap_normative_legal()
    case BlobIndex{}: Named.BlobIndex_normative_legal()
    case BlobIdentifier{}: Named.BlobIdentifier_normative_legal()
    case KZGCommitment{}: Named.KZGCommitment_normative_legal()
    case BeaconBlockBody{}: Named.BeaconBlockBody_normative_legal()
    case BeaconBlock{}: Named.BeaconBlock_normative_legal()
    case SignedBeaconBlock{}: Named.SignedBeaconBlock_normative_legal()
    case KZGProof{}: Named.KZGProof_normative_legal()
    case Blob{}: Named.Blob_normative_legal()
    case BlobSidecar{}: Named.BlobSidecar_normative_legal()
    case Cell{}: Named.Cell_normative_legal()
    case CellIndex{}: Named.CellIndex_normative_legal()
    case CommitmentIndex{}: Named.CommitmentIndex_normative_legal()
    case RowIndex{}: Named.RowIndex_normative_legal()
    case ColumnIndex{}: Named.ColumnIndex_normative_legal()
    case DataColumnsByRootIdentifier{}: Named.DataColumnsByRootIdentifier_normative_legal()
    case MatrixEntry{}: Named.MatrixEntry_normative_legal()
    case DataColumnSidecar{}: Named.DataColumnSidecar_normative_legal()
    case CustodyIndex{}: Named.CustodyIndex_normative_legal()

law validator_accepts:
  for +name: Name
  {API.type_valid(schema(name)) == True{} : Bool}
def validator_accepts(name):
  match name:
    case boolean{}: Named.boolean_validator_accepts()
    case uint8{}: Named.uint8_validator_accepts()
    case uint32{}: Named.uint32_validator_accepts()
    case uint64{}: Named.uint64_validator_accepts()
    case uint256{}: Named.uint256_validator_accepts()
    case Bytes1{}: Named.Bytes1_validator_accepts()
    case Bytes4{}: Named.Bytes4_validator_accepts()
    case Bytes32{}: Named.Bytes32_validator_accepts()
    case Bytes48{}: Named.Bytes48_validator_accepts()
    case Bytes96{}: Named.Bytes96_validator_accepts()
    case Bytes8{}: Named.Bytes8_validator_accepts()
    case Bytes20{}: Named.Bytes20_validator_accepts()
    case Slot{}: Named.Slot_validator_accepts()
    case Epoch{}: Named.Epoch_validator_accepts()
    case Gwei{}: Named.Gwei_validator_accepts()
    case Hash32{}: Named.Hash32_validator_accepts()
    case Version{}: Named.Version_validator_accepts()
    case DomainType{}: Named.DomainType_validator_accepts()
    case BLSSignature{}: Named.BLSSignature_validator_accepts()
    case FinalityBranch{}: Named.FinalityBranch_validator_accepts()
    case VersionedHash{}: Named.VersionedHash_validator_accepts()
    case G1Point{}: Named.G1Point_validator_accepts()
    case G2Point{}: Named.G2Point_validator_accepts()
    case Fork{}: Named.Fork_validator_accepts()
    case SyncAggregate{}: Named.SyncAggregate_validator_accepts()
    case SyncAggregatorSelectionData{}: Named.SyncAggregatorSelectionData_validator_accepts()
    case PowBlock{}: Named.PowBlock_validator_accepts()
    case CommitteeIndex{}: Named.CommitteeIndex_validator_accepts()
    case ValidatorIndex{}: Named.ValidatorIndex_validator_accepts()
    case PendingConsolidation{}: Named.PendingConsolidation_validator_accepts()
    case PendingPartialWithdrawal{}: Named.PendingPartialWithdrawal_validator_accepts()
    case VoluntaryExit{}: Named.VoluntaryExit_validator_accepts()
    case SignedVoluntaryExit{}: Named.SignedVoluntaryExit_validator_accepts()
    case Root{}: Named.Root_validator_accepts()
    case HistoricalSummary{}: Named.HistoricalSummary_validator_accepts()
    case SyncCommitteeContribution{}: Named.SyncCommitteeContribution_validator_accepts()
    case ContributionAndProof{}: Named.ContributionAndProof_validator_accepts()
    case SignedContributionAndProof{}: Named.SignedContributionAndProof_validator_accepts()
    case SyncCommitteeMessage{}: Named.SyncCommitteeMessage_validator_accepts()
    case Eth1Block{}: Named.Eth1Block_validator_accepts()
    case BeaconBlockHeader{}: Named.BeaconBlockHeader_validator_accepts()
    case SignedBeaconBlockHeader{}: Named.SignedBeaconBlockHeader_validator_accepts()
    case ProposerSlashing{}: Named.ProposerSlashing_validator_accepts()
    case HistoricalBatch{}: Named.HistoricalBatch_validator_accepts()
    case Eth1Data{}: Named.Eth1Data_validator_accepts()
    case Checkpoint{}: Named.Checkpoint_validator_accepts()
    case AttestationData{}: Named.AttestationData_validator_accepts()
    case SingleAttestation{}: Named.SingleAttestation_validator_accepts()
    case Attestation{}: Named.Attestation_validator_accepts()
    case AggregateAndProof{}: Named.AggregateAndProof_validator_accepts()
    case SignedAggregateAndProof{}: Named.SignedAggregateAndProof_validator_accepts()
    case PendingAttestation{}: Named.PendingAttestation_validator_accepts()
    case IndexedAttestation{}: Named.IndexedAttestation_validator_accepts()
    case AttesterSlashing{}: Named.AttesterSlashing_validator_accepts()
    case ForkData{}: Named.ForkData_validator_accepts()
    case ForkDigest{}: Named.ForkDigest_validator_accepts()
    case Domain{}: Named.Domain_validator_accepts()
    case SigningData{}: Named.SigningData_validator_accepts()
    case BLSPubkey{}: Named.BLSPubkey_validator_accepts()
    case DepositRequest{}: Named.DepositRequest_validator_accepts()
    case PendingDeposit{}: Named.PendingDeposit_validator_accepts()
    case SyncCommittee{}: Named.SyncCommittee_validator_accepts()
    case DepositData{}: Named.DepositData_validator_accepts()
    case Deposit{}: Named.Deposit_validator_accepts()
    case DepositMessage{}: Named.DepositMessage_validator_accepts()
    case Validator{}: Named.Validator_validator_accepts()
    case NodeID{}: Named.NodeID_validator_accepts()
    case SubnetID{}: Named.SubnetID_validator_accepts()
    case Ether{}: Named.Ether_validator_accepts()
    case ParticipationFlags{}: Named.ParticipationFlags_validator_accepts()
    case CurrentSyncCommitteeBranch{}: Named.CurrentSyncCommitteeBranch_validator_accepts()
    case NextSyncCommitteeBranch{}: Named.NextSyncCommitteeBranch_validator_accepts()
    case Transaction{}: Named.Transaction_validator_accepts()
    case ExecutionAddress{}: Named.ExecutionAddress_validator_accepts()
    case ConsolidationRequest{}: Named.ConsolidationRequest_validator_accepts()
    case WithdrawalRequest{}: Named.WithdrawalRequest_validator_accepts()
    case ExecutionRequests{}: Named.ExecutionRequests_validator_accepts()
    case BLSToExecutionChange{}: Named.BLSToExecutionChange_validator_accepts()
    case SignedBLSToExecutionChange{}: Named.SignedBLSToExecutionChange_validator_accepts()
    case ExecutionPayloadHeader{}: Named.ExecutionPayloadHeader_validator_accepts()
    case PayloadId{}: Named.PayloadId_validator_accepts()
    case WithdrawalIndex{}: Named.WithdrawalIndex_validator_accepts()
    case Withdrawal{}: Named.Withdrawal_validator_accepts()
    case ExecutionPayload{}: Named.ExecutionPayload_validator_accepts()
    case BeaconState{}: Named.BeaconState_validator_accepts()
    case ExecutionBranch{}: Named.ExecutionBranch_validator_accepts()
    case LightClientHeader{}: Named.LightClientHeader_validator_accepts()
    case LightClientOptimisticUpdate{}: Named.LightClientOptimisticUpdate_validator_accepts()
    case LightClientFinalityUpdate{}: Named.LightClientFinalityUpdate_validator_accepts()
    case LightClientUpdate{}: Named.LightClientUpdate_validator_accepts()
    case LightClientBootstrap{}: Named.LightClientBootstrap_validator_accepts()
    case BlobIndex{}: Named.BlobIndex_validator_accepts()
    case BlobIdentifier{}: Named.BlobIdentifier_validator_accepts()
    case KZGCommitment{}: Named.KZGCommitment_validator_accepts()
    case BeaconBlockBody{}: Named.BeaconBlockBody_validator_accepts()
    case BeaconBlock{}: Named.BeaconBlock_validator_accepts()
    case SignedBeaconBlock{}: Named.SignedBeaconBlock_validator_accepts()
    case KZGProof{}: Named.KZGProof_validator_accepts()
    case Blob{}: Named.Blob_validator_accepts()
    case BlobSidecar{}: Named.BlobSidecar_validator_accepts()
    case Cell{}: Named.Cell_validator_accepts()
    case CellIndex{}: Named.CellIndex_validator_accepts()
    case CommitmentIndex{}: Named.CommitmentIndex_validator_accepts()
    case RowIndex{}: Named.RowIndex_validator_accepts()
    case ColumnIndex{}: Named.ColumnIndex_validator_accepts()
    case DataColumnsByRootIdentifier{}: Named.DataColumnsByRootIdentifier_validator_accepts()
    case MatrixEntry{}: Named.MatrixEntry_validator_accepts()
    case DataColumnSidecar{}: Named.DataColumnSidecar_validator_accepts()
    case CustodyIndex{}: Named.CustodyIndex_validator_accepts()

# Every input value is covered, including wrong tags, lengths and bounds. The
# type-validity premise of the recursive theorem is discharged for each name.
# This is actual generic API serialization AT every named schema; it does not
# claim all typed adapters, decoding or roots have been composed yet.
law serialize_at_every_named_schema:
  for +name: Name
  for +value: T.Value
  {API.serialize(schema(name), value) == S.encoding_for_legal_type(schema(name), value) : Maybe<&2, +List<U32>>}
def serialize_at_every_named_schema(name, value):
  Codec.serialize_for_valid_type(schema(name), value, validator_accepts(name))
