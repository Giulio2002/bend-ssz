import Base
import ../types/fulu.bend as F
import ../spec/type_legality.bend as S
import ../src/schema.bend as Actual

law boolean_normative_legal:
  S.type_legal(F.boolean.schema())
def boolean_normative_legal(): {==}

law boolean_validator_accepts:
  {Actual.valid(F.boolean.schema()) == True{} : Bool}
def boolean_validator_accepts(): {==}

law uint8_normative_legal:
  S.type_legal(F.uint8.schema())
def uint8_normative_legal(): {==}

law uint8_validator_accepts:
  {Actual.valid(F.uint8.schema()) == True{} : Bool}
def uint8_validator_accepts(): {==}

law uint32_normative_legal:
  S.type_legal(F.uint32.schema())
def uint32_normative_legal(): {==}

law uint32_validator_accepts:
  {Actual.valid(F.uint32.schema()) == True{} : Bool}
def uint32_validator_accepts(): {==}

law uint64_normative_legal:
  S.type_legal(F.uint64.schema())
def uint64_normative_legal(): {==}

law uint64_validator_accepts:
  {Actual.valid(F.uint64.schema()) == True{} : Bool}
def uint64_validator_accepts(): {==}

law uint256_normative_legal:
  S.type_legal(F.uint256.schema())
def uint256_normative_legal(): {==}

law uint256_validator_accepts:
  {Actual.valid(F.uint256.schema()) == True{} : Bool}
def uint256_validator_accepts(): {==}

law Bytes1_normative_legal:
  S.type_legal(F.Bytes1.schema())
def Bytes1_normative_legal(): ({==}, {==})

law Bytes1_validator_accepts:
  {Actual.valid(F.Bytes1.schema()) == True{} : Bool}
def Bytes1_validator_accepts(): {==}

law Bytes4_normative_legal:
  S.type_legal(F.Bytes4.schema())
def Bytes4_normative_legal(): ({==}, {==})

law Bytes4_validator_accepts:
  {Actual.valid(F.Bytes4.schema()) == True{} : Bool}
def Bytes4_validator_accepts(): {==}

law Bytes32_normative_legal:
  S.type_legal(F.Bytes32.schema())
def Bytes32_normative_legal(): ({==}, {==})

law Bytes32_validator_accepts:
  {Actual.valid(F.Bytes32.schema()) == True{} : Bool}
def Bytes32_validator_accepts(): {==}

law Bytes48_normative_legal:
  S.type_legal(F.Bytes48.schema())
def Bytes48_normative_legal(): ({==}, {==})

law Bytes48_validator_accepts:
  {Actual.valid(F.Bytes48.schema()) == True{} : Bool}
def Bytes48_validator_accepts(): {==}

law Bytes96_normative_legal:
  S.type_legal(F.Bytes96.schema())
def Bytes96_normative_legal(): ({==}, {==})

law Bytes96_validator_accepts:
  {Actual.valid(F.Bytes96.schema()) == True{} : Bool}
def Bytes96_validator_accepts(): {==}

law Bytes8_normative_legal:
  S.type_legal(F.Bytes8.schema())
def Bytes8_normative_legal(): ({==}, {==})

law Bytes8_validator_accepts:
  {Actual.valid(F.Bytes8.schema()) == True{} : Bool}
def Bytes8_validator_accepts(): {==}

law Bytes20_normative_legal:
  S.type_legal(F.Bytes20.schema())
def Bytes20_normative_legal(): ({==}, {==})

law Bytes20_validator_accepts:
  {Actual.valid(F.Bytes20.schema()) == True{} : Bool}
def Bytes20_validator_accepts(): {==}

law Slot_normative_legal:
  S.type_legal(F.Slot.schema())
def Slot_normative_legal(): {==}

law Slot_validator_accepts:
  {Actual.valid(F.Slot.schema()) == True{} : Bool}
def Slot_validator_accepts(): {==}

law Epoch_normative_legal:
  S.type_legal(F.Epoch.schema())
def Epoch_normative_legal(): {==}

law Epoch_validator_accepts:
  {Actual.valid(F.Epoch.schema()) == True{} : Bool}
def Epoch_validator_accepts(): {==}

law Gwei_normative_legal:
  S.type_legal(F.Gwei.schema())
def Gwei_normative_legal(): {==}

law Gwei_validator_accepts:
  {Actual.valid(F.Gwei.schema()) == True{} : Bool}
def Gwei_validator_accepts(): {==}

law Hash32_normative_legal:
  S.type_legal(F.Hash32.schema())
def Hash32_normative_legal(): ({==}, {==})

law Hash32_validator_accepts:
  {Actual.valid(F.Hash32.schema()) == True{} : Bool}
def Hash32_validator_accepts(): {==}

law Version_normative_legal:
  S.type_legal(F.Version.schema())
def Version_normative_legal(): ({==}, {==})

law Version_validator_accepts:
  {Actual.valid(F.Version.schema()) == True{} : Bool}
def Version_validator_accepts(): {==}

law DomainType_normative_legal:
  S.type_legal(F.DomainType.schema())
def DomainType_normative_legal(): ({==}, {==})

law DomainType_validator_accepts:
  {Actual.valid(F.DomainType.schema()) == True{} : Bool}
def DomainType_validator_accepts(): {==}

law BLSSignature_normative_legal:
  S.type_legal(F.BLSSignature.schema())
def BLSSignature_normative_legal(): ({==}, {==})

law BLSSignature_validator_accepts:
  {Actual.valid(F.BLSSignature.schema()) == True{} : Bool}
def BLSSignature_validator_accepts(): {==}

law FinalityBranch_normative_legal:
  S.type_legal(F.FinalityBranch.schema())
def FinalityBranch_normative_legal(): ({==}, ({==}, ({==}, {==})))

law FinalityBranch_validator_accepts:
  {Actual.valid(F.FinalityBranch.schema()) == True{} : Bool}
def FinalityBranch_validator_accepts(): {==}

law VersionedHash_normative_legal:
  S.type_legal(F.VersionedHash.schema())
def VersionedHash_normative_legal(): ({==}, {==})

law VersionedHash_validator_accepts:
  {Actual.valid(F.VersionedHash.schema()) == True{} : Bool}
def VersionedHash_validator_accepts(): {==}

law G1Point_normative_legal:
  S.type_legal(F.G1Point.schema())
def G1Point_normative_legal(): ({==}, {==})

law G1Point_validator_accepts:
  {Actual.valid(F.G1Point.schema()) == True{} : Bool}
def G1Point_validator_accepts(): {==}

law G2Point_normative_legal:
  S.type_legal(F.G2Point.schema())
def G2Point_normative_legal(): ({==}, {==})

law G2Point_validator_accepts:
  {Actual.valid(F.G2Point.schema()) == True{} : Bool}
def G2Point_validator_accepts(): {==}

law Fork_normative_legal:
  S.type_legal(F.Fork.schema())
def Fork_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))

law Fork_validator_accepts:
  {Actual.valid(F.Fork.schema()) == True{} : Bool}
def Fork_validator_accepts(): {==}

law SyncAggregate_normative_legal:
  S.type_legal(F.SyncAggregate.schema())
def SyncAggregate_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))

law SyncAggregate_validator_accepts:
  {Actual.valid(F.SyncAggregate.schema()) == True{} : Bool}
def SyncAggregate_validator_accepts(): {==}

law SyncAggregatorSelectionData_normative_legal:
  S.type_legal(F.SyncAggregatorSelectionData.schema())
def SyncAggregatorSelectionData_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==}))))))

law SyncAggregatorSelectionData_validator_accepts:
  {Actual.valid(F.SyncAggregatorSelectionData.schema()) == True{} : Bool}
def SyncAggregatorSelectionData_validator_accepts(): {==}

law PowBlock_normative_legal:
  S.type_legal(F.PowBlock.schema())
def PowBlock_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))

law PowBlock_validator_accepts:
  {Actual.valid(F.PowBlock.schema()) == True{} : Bool}
def PowBlock_validator_accepts(): {==}

law CommitteeIndex_normative_legal:
  S.type_legal(F.CommitteeIndex.schema())
def CommitteeIndex_normative_legal(): {==}

law CommitteeIndex_validator_accepts:
  {Actual.valid(F.CommitteeIndex.schema()) == True{} : Bool}
def CommitteeIndex_validator_accepts(): {==}

law ValidatorIndex_normative_legal:
  S.type_legal(F.ValidatorIndex.schema())
def ValidatorIndex_normative_legal(): {==}

law ValidatorIndex_validator_accepts:
  {Actual.valid(F.ValidatorIndex.schema()) == True{} : Bool}
def ValidatorIndex_validator_accepts(): {==}

law PendingConsolidation_normative_legal:
  S.type_legal(F.PendingConsolidation.schema())
def PendingConsolidation_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==}))))))

law PendingConsolidation_validator_accepts:
  {Actual.valid(F.PendingConsolidation.schema()) == True{} : Bool}
def PendingConsolidation_validator_accepts(): {==}

law PendingPartialWithdrawal_normative_legal:
  S.type_legal(F.PendingPartialWithdrawal.schema())
def PendingPartialWithdrawal_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))

law PendingPartialWithdrawal_validator_accepts:
  {Actual.valid(F.PendingPartialWithdrawal.schema()) == True{} : Bool}
def PendingPartialWithdrawal_validator_accepts(): {==}

law VoluntaryExit_normative_legal:
  S.type_legal(F.VoluntaryExit.schema())
def VoluntaryExit_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==}))))))

law VoluntaryExit_validator_accepts:
  {Actual.valid(F.VoluntaryExit.schema()) == True{} : Bool}
def VoluntaryExit_validator_accepts(): {==}

law SignedVoluntaryExit_normative_legal:
  S.type_legal(F.SignedVoluntaryExit.schema())
def SignedVoluntaryExit_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==})))))), ({==}, (({==}, {==}), {==}))))))

law SignedVoluntaryExit_validator_accepts:
  {Actual.valid(F.SignedVoluntaryExit.schema()) == True{} : Bool}
def SignedVoluntaryExit_validator_accepts(): {==}

law Root_normative_legal:
  S.type_legal(F.Root.schema())
def Root_normative_legal(): ({==}, {==})

law Root_validator_accepts:
  {Actual.valid(F.Root.schema()) == True{} : Bool}
def Root_validator_accepts(): {==}

law HistoricalSummary_normative_legal:
  S.type_legal(F.HistoricalSummary.schema())
def HistoricalSummary_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))

law HistoricalSummary_validator_accepts:
  {Actual.valid(F.HistoricalSummary.schema()) == True{} : Bool}
def HistoricalSummary_validator_accepts(): {==}

law SyncCommitteeContribution_normative_legal:
  S.type_legal(F.SyncCommitteeContribution.schema())
def SyncCommitteeContribution_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))))))

law SyncCommitteeContribution_validator_accepts:
  {Actual.valid(F.SyncCommitteeContribution.schema()) == True{} : Bool}
def SyncCommitteeContribution_validator_accepts(): {==}

law ContributionAndProof_normative_legal:
  S.type_legal(F.ContributionAndProof.schema())
def ContributionAndProof_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==}))))))))

law ContributionAndProof_validator_accepts:
  {Actual.valid(F.ContributionAndProof.schema()) == True{} : Bool}
def ContributionAndProof_validator_accepts(): {==}

law SignedContributionAndProof_normative_legal:
  S.type_legal(F.SignedContributionAndProof.schema())
def SignedContributionAndProof_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), {==}))))))

law SignedContributionAndProof_validator_accepts:
  {Actual.valid(F.SignedContributionAndProof.schema()) == True{} : Bool}
def SignedContributionAndProof_validator_accepts(): {==}

law SyncCommitteeMessage_normative_legal:
  S.type_legal(F.SyncCommitteeMessage.schema())
def SyncCommitteeMessage_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==}))))))))))

law SyncCommitteeMessage_validator_accepts:
  {Actual.valid(F.SyncCommitteeMessage.schema()) == True{} : Bool}
def SyncCommitteeMessage_validator_accepts(): {==}

law Eth1Block_normative_legal:
  S.type_legal(F.Eth1Block.schema())
def Eth1Block_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))

law Eth1Block_validator_accepts:
  {Actual.valid(F.Eth1Block.schema()) == True{} : Bool}
def Eth1Block_validator_accepts(): {==}

law BeaconBlockHeader_normative_legal:
  S.type_legal(F.BeaconBlockHeader.schema())
def BeaconBlockHeader_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))))))

law BeaconBlockHeader_validator_accepts:
  {Actual.valid(F.BeaconBlockHeader.schema()) == True{} : Bool}
def BeaconBlockHeader_validator_accepts(): {==}

law SignedBeaconBlockHeader_normative_legal:
  S.type_legal(F.SignedBeaconBlockHeader.schema())
def SignedBeaconBlockHeader_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==}))))))

law SignedBeaconBlockHeader_validator_accepts:
  {Actual.valid(F.SignedBeaconBlockHeader.schema()) == True{} : Bool}
def SignedBeaconBlockHeader_validator_accepts(): {==}

law ProposerSlashing_normative_legal:
  S.type_legal(F.ProposerSlashing.schema())
def ProposerSlashing_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), {==}))))))

law ProposerSlashing_validator_accepts:
  {Actual.valid(F.ProposerSlashing.schema()) == True{} : Bool}
def ProposerSlashing_validator_accepts(): {==}

law HistoricalBatch_normative_legal:
  S.type_legal(F.HistoricalBatch.schema())
def HistoricalBatch_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, ({==}, ({==}, {==}))), {==}))))))

law HistoricalBatch_validator_accepts:
  {Actual.valid(F.HistoricalBatch.schema()) == True{} : Bool}
def HistoricalBatch_validator_accepts(): {==}

law Eth1Data_normative_legal:
  S.type_legal(F.Eth1Data.schema())
def Eth1Data_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==}))))))))

law Eth1Data_validator_accepts:
  {Actual.valid(F.Eth1Data.schema()) == True{} : Bool}
def Eth1Data_validator_accepts(): {==}

law Checkpoint_normative_legal:
  S.type_legal(F.Checkpoint.schema())
def Checkpoint_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==}))))))

law Checkpoint_validator_accepts:
  {Actual.valid(F.Checkpoint.schema()) == True{} : Bool}
def Checkpoint_validator_accepts(): {==}

law AttestationData_normative_legal:
  S.type_legal(F.AttestationData.schema())
def AttestationData_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==}))))))))))))

law AttestationData_validator_accepts:
  {Actual.valid(F.AttestationData.schema()) == True{} : Bool}
def AttestationData_validator_accepts(): {==}

law SingleAttestation_normative_legal:
  S.type_legal(F.SingleAttestation.schema())
def SingleAttestation_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==}))))))))))

law SingleAttestation_validator_accepts:
  {Actual.valid(F.SingleAttestation.schema()) == True{} : Bool}
def SingleAttestation_validator_accepts(): {==}

law Attestation_normative_legal:
  S.type_legal(F.Attestation.schema())
def Attestation_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))))

law Attestation_validator_accepts:
  {Actual.valid(F.Attestation.schema()) == True{} : Bool}
def Attestation_validator_accepts(): {==}

law AggregateAndProof_normative_legal:
  S.type_legal(F.AggregateAndProof.schema())
def AggregateAndProof_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))), ({==}, (({==}, {==}), {==}))))))))

law AggregateAndProof_validator_accepts:
  {Actual.valid(F.AggregateAndProof.schema()) == True{} : Bool}
def AggregateAndProof_validator_accepts(): {==}

law SignedAggregateAndProof_normative_legal:
  S.type_legal(F.SignedAggregateAndProof.schema())
def SignedAggregateAndProof_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), {==}))))))

law SignedAggregateAndProof_validator_accepts:
  {Actual.valid(F.SignedAggregateAndProof.schema()) == True{} : Bool}
def SignedAggregateAndProof_validator_accepts(): {==}

law PendingAttestation_normative_legal:
  S.type_legal(F.PendingAttestation.schema())
def PendingAttestation_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, ({==}, ({==}, ({==}, {==}))))))))))

law PendingAttestation_validator_accepts:
  {Actual.valid(F.PendingAttestation.schema()) == True{} : Bool}
def PendingAttestation_validator_accepts(): {==}

law IndexedAttestation_normative_legal:
  S.type_legal(F.IndexedAttestation.schema())
def IndexedAttestation_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==}))))))))

law IndexedAttestation_validator_accepts:
  {Actual.valid(F.IndexedAttestation.schema()) == True{} : Bool}
def IndexedAttestation_validator_accepts(): {==}

law AttesterSlashing_normative_legal:
  S.type_legal(F.AttesterSlashing.schema())
def AttesterSlashing_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), {==}))))))

law AttesterSlashing_validator_accepts:
  {Actual.valid(F.AttesterSlashing.schema()) == True{} : Bool}
def AttesterSlashing_validator_accepts(): {==}

law ForkData_normative_legal:
  S.type_legal(F.ForkData.schema())
def ForkData_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))

law ForkData_validator_accepts:
  {Actual.valid(F.ForkData.schema()) == True{} : Bool}
def ForkData_validator_accepts(): {==}

law ForkDigest_normative_legal:
  S.type_legal(F.ForkDigest.schema())
def ForkDigest_normative_legal(): ({==}, {==})

law ForkDigest_validator_accepts:
  {Actual.valid(F.ForkDigest.schema()) == True{} : Bool}
def ForkDigest_validator_accepts(): {==}

law Domain_normative_legal:
  S.type_legal(F.Domain.schema())
def Domain_normative_legal(): ({==}, {==})

law Domain_validator_accepts:
  {Actual.valid(F.Domain.schema()) == True{} : Bool}
def Domain_validator_accepts(): {==}

law SigningData_normative_legal:
  S.type_legal(F.SigningData.schema())
def SigningData_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))

law SigningData_validator_accepts:
  {Actual.valid(F.SigningData.schema()) == True{} : Bool}
def SigningData_validator_accepts(): {==}

law BLSPubkey_normative_legal:
  S.type_legal(F.BLSPubkey.schema())
def BLSPubkey_normative_legal(): ({==}, {==})

law BLSPubkey_validator_accepts:
  {Actual.valid(F.BLSPubkey.schema()) == True{} : Bool}
def BLSPubkey_validator_accepts(): {==}

law DepositRequest_normative_legal:
  S.type_legal(F.DepositRequest.schema())
def DepositRequest_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))

law DepositRequest_validator_accepts:
  {Actual.valid(F.DepositRequest.schema()) == True{} : Bool}
def DepositRequest_validator_accepts(): {==}

law PendingDeposit_normative_legal:
  S.type_legal(F.PendingDeposit.schema())
def PendingDeposit_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))

law PendingDeposit_validator_accepts:
  {Actual.valid(F.PendingDeposit.schema()) == True{} : Bool}
def PendingDeposit_validator_accepts(): {==}

law SyncCommittee_normative_legal:
  S.type_legal(F.SyncCommittee.schema())
def SyncCommittee_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, {==}), {==}))))))

law SyncCommittee_validator_accepts:
  {Actual.valid(F.SyncCommittee.schema()) == True{} : Bool}
def SyncCommittee_validator_accepts(): {==}

law DepositData_normative_legal:
  S.type_legal(F.DepositData.schema())
def DepositData_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==}))))))))))

law DepositData_validator_accepts:
  {Actual.valid(F.DepositData.schema()) == True{} : Bool}
def DepositData_validator_accepts(): {==}

law Deposit_normative_legal:
  S.type_legal(F.Deposit.schema())
def Deposit_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))))), {==}))))))

law Deposit_validator_accepts:
  {Actual.valid(F.Deposit.schema()) == True{} : Bool}
def Deposit_validator_accepts(): {==}

law DepositMessage_normative_legal:
  S.type_legal(F.DepositMessage.schema())
def DepositMessage_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))

law DepositMessage_validator_accepts:
  {Actual.valid(F.DepositMessage.schema()) == True{} : Bool}
def DepositMessage_validator_accepts(): {==}

law Validator_normative_legal:
  S.type_legal(F.Validator.schema())
def Validator_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))))))))))))

law Validator_validator_accepts:
  {Actual.valid(F.Validator.schema()) == True{} : Bool}
def Validator_validator_accepts(): {==}

law NodeID_normative_legal:
  S.type_legal(F.NodeID.schema())
def NodeID_normative_legal(): {==}

law NodeID_validator_accepts:
  {Actual.valid(F.NodeID.schema()) == True{} : Bool}
def NodeID_validator_accepts(): {==}

law SubnetID_normative_legal:
  S.type_legal(F.SubnetID.schema())
def SubnetID_normative_legal(): {==}

law SubnetID_validator_accepts:
  {Actual.valid(F.SubnetID.schema()) == True{} : Bool}
def SubnetID_validator_accepts(): {==}

law Ether_normative_legal:
  S.type_legal(F.Ether.schema())
def Ether_normative_legal(): {==}

law Ether_validator_accepts:
  {Actual.valid(F.Ether.schema()) == True{} : Bool}
def Ether_validator_accepts(): {==}

law ParticipationFlags_normative_legal:
  S.type_legal(F.ParticipationFlags.schema())
def ParticipationFlags_normative_legal(): {==}

law ParticipationFlags_validator_accepts:
  {Actual.valid(F.ParticipationFlags.schema()) == True{} : Bool}
def ParticipationFlags_validator_accepts(): {==}

law CurrentSyncCommitteeBranch_normative_legal:
  S.type_legal(F.CurrentSyncCommitteeBranch.schema())
def CurrentSyncCommitteeBranch_normative_legal(): ({==}, ({==}, ({==}, {==})))

law CurrentSyncCommitteeBranch_validator_accepts:
  {Actual.valid(F.CurrentSyncCommitteeBranch.schema()) == True{} : Bool}
def CurrentSyncCommitteeBranch_validator_accepts(): {==}

law NextSyncCommitteeBranch_normative_legal:
  S.type_legal(F.NextSyncCommitteeBranch.schema())
def NextSyncCommitteeBranch_normative_legal(): ({==}, ({==}, ({==}, {==})))

law NextSyncCommitteeBranch_validator_accepts:
  {Actual.valid(F.NextSyncCommitteeBranch.schema()) == True{} : Bool}
def NextSyncCommitteeBranch_validator_accepts(): {==}

law Transaction_normative_legal:
  S.type_legal(F.Transaction.schema())
def Transaction_normative_legal(): {==}

law Transaction_validator_accepts:
  {Actual.valid(F.Transaction.schema()) == True{} : Bool}
def Transaction_validator_accepts(): {==}

law ExecutionAddress_normative_legal:
  S.type_legal(F.ExecutionAddress.schema())
def ExecutionAddress_normative_legal(): ({==}, {==})

law ExecutionAddress_validator_accepts:
  {Actual.valid(F.ExecutionAddress.schema()) == True{} : Bool}
def ExecutionAddress_validator_accepts(): {==}

law ConsolidationRequest_normative_legal:
  S.type_legal(F.ConsolidationRequest.schema())
def ConsolidationRequest_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))

law ConsolidationRequest_validator_accepts:
  {Actual.valid(F.ConsolidationRequest.schema()) == True{} : Bool}
def ConsolidationRequest_validator_accepts(): {==}

law WithdrawalRequest_normative_legal:
  S.type_legal(F.WithdrawalRequest.schema())
def WithdrawalRequest_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))

law WithdrawalRequest_validator_accepts:
  {Actual.valid(F.WithdrawalRequest.schema()) == True{} : Bool}
def WithdrawalRequest_validator_accepts(): {==}

law ExecutionRequests_normative_legal:
  S.type_legal(F.ExecutionRequests.schema())
def ExecutionRequests_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))), {==}))))))))

law ExecutionRequests_validator_accepts:
  {Actual.valid(F.ExecutionRequests.schema()) == True{} : Bool}
def ExecutionRequests_validator_accepts(): {==}

law BLSToExecutionChange_normative_legal:
  S.type_legal(F.BLSToExecutionChange.schema())
def BLSToExecutionChange_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))

law BLSToExecutionChange_validator_accepts:
  {Actual.valid(F.BLSToExecutionChange.schema()) == True{} : Bool}
def BLSToExecutionChange_validator_accepts(): {==}

law SignedBLSToExecutionChange_normative_legal:
  S.type_legal(F.SignedBLSToExecutionChange.schema())
def SignedBLSToExecutionChange_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), {==}))))))

law SignedBLSToExecutionChange_validator_accepts:
  {Actual.valid(F.SignedBLSToExecutionChange.schema()) == True{} : Bool}
def SignedBLSToExecutionChange_validator_accepts(): {==}

law ExecutionPayloadHeader_normative_legal:
  S.type_legal(F.ExecutionPayloadHeader.schema())
def ExecutionPayloadHeader_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==}))))))))))))))))))))))))))))))))))))

law ExecutionPayloadHeader_validator_accepts:
  {Actual.valid(F.ExecutionPayloadHeader.schema()) == True{} : Bool}
def ExecutionPayloadHeader_validator_accepts(): {==}

law PayloadId_normative_legal:
  S.type_legal(F.PayloadId.schema())
def PayloadId_normative_legal(): ({==}, {==})

law PayloadId_validator_accepts:
  {Actual.valid(F.PayloadId.schema()) == True{} : Bool}
def PayloadId_validator_accepts(): {==}

law WithdrawalIndex_normative_legal:
  S.type_legal(F.WithdrawalIndex.schema())
def WithdrawalIndex_normative_legal(): {==}

law WithdrawalIndex_validator_accepts:
  {Actual.valid(F.WithdrawalIndex.schema()) == True{} : Bool}
def WithdrawalIndex_validator_accepts(): {==}

law Withdrawal_normative_legal:
  S.type_legal(F.Withdrawal.schema())
def Withdrawal_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))

law Withdrawal_validator_accepts:
  {Actual.valid(F.Withdrawal.schema()) == True{} : Bool}
def Withdrawal_validator_accepts(): {==}

law ExecutionPayload_normative_legal:
  S.type_legal(F.ExecutionPayload.schema())
def ExecutionPayload_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))), ({==}, ({==}, ({==}, ({==}, {==}))))))))))))))))))))))))))))))))))))

law ExecutionPayload_validator_accepts:
  {Actual.valid(F.ExecutionPayload.schema()) == True{} : Bool}
def ExecutionPayload_validator_accepts(): {==}

law BeaconState_normative_legal:
  S.type_legal(F.BeaconState.schema())
def BeaconState_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==}))))))))), ({==}, ({==}, ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, {==}))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==}))))))), ({==}, (({==}, ({==}, {==})), {==}))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

law BeaconState_validator_accepts:
  {Actual.valid(F.BeaconState.schema()) == True{} : Bool}
def BeaconState_validator_accepts(): {==}

law ExecutionBranch_normative_legal:
  S.type_legal(F.ExecutionBranch.schema())
def ExecutionBranch_normative_legal(): ({==}, ({==}, ({==}, {==})))

law ExecutionBranch_validator_accepts:
  {Actual.valid(F.ExecutionBranch.schema()) == True{} : Bool}
def ExecutionBranch_validator_accepts(): {==}

law LightClientHeader_normative_legal:
  S.type_legal(F.LightClientHeader.schema())
def LightClientHeader_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==}))))))))

law LightClientHeader_validator_accepts:
  {Actual.valid(F.LightClientHeader.schema()) == True{} : Bool}
def LightClientHeader_validator_accepts(): {==}

law LightClientOptimisticUpdate_normative_legal:
  S.type_legal(F.LightClientOptimisticUpdate.schema())
def LightClientOptimisticUpdate_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))), ({==}, ({==}, {==}))))))))

law LightClientOptimisticUpdate_validator_accepts:
  {Actual.valid(F.LightClientOptimisticUpdate.schema()) == True{} : Bool}
def LightClientOptimisticUpdate_validator_accepts(): {==}

law LightClientFinalityUpdate_normative_legal:
  S.type_legal(F.LightClientFinalityUpdate.schema())
def LightClientFinalityUpdate_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==})))))))), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))), ({==}, ({==}, {==}))))))))))))

law LightClientFinalityUpdate_validator_accepts:
  {Actual.valid(F.LightClientFinalityUpdate.schema()) == True{} : Bool}
def LightClientFinalityUpdate_validator_accepts(): {==}

law LightClientUpdate_normative_legal:
  S.type_legal(F.LightClientUpdate.schema())
def LightClientUpdate_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==})))))))), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))), ({==}, ({==}, {==}))))))))))))))))

law LightClientUpdate_validator_accepts:
  {Actual.valid(F.LightClientUpdate.schema()) == True{} : Bool}
def LightClientUpdate_validator_accepts(): {==}

law LightClientBootstrap_normative_legal:
  S.type_legal(F.LightClientBootstrap.schema())
def LightClientBootstrap_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==}))))))))

law LightClientBootstrap_validator_accepts:
  {Actual.valid(F.LightClientBootstrap.schema()) == True{} : Bool}
def LightClientBootstrap_validator_accepts(): {==}

law BlobIndex_normative_legal:
  S.type_legal(F.BlobIndex.schema())
def BlobIndex_normative_legal(): {==}

law BlobIndex_validator_accepts:
  {Actual.valid(F.BlobIndex.schema()) == True{} : Bool}
def BlobIndex_validator_accepts(): {==}

law BlobIdentifier_normative_legal:
  S.type_legal(F.BlobIdentifier.schema())
def BlobIdentifier_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))

law BlobIdentifier_validator_accepts:
  {Actual.valid(F.BlobIdentifier.schema()) == True{} : Bool}
def BlobIdentifier_validator_accepts(): {==}

law KZGCommitment_normative_legal:
  S.type_legal(F.KZGCommitment.schema())
def KZGCommitment_normative_legal(): ({==}, {==})

law KZGCommitment_validator_accepts:
  {Actual.valid(F.KZGCommitment.schema()) == True{} : Bool}
def KZGCommitment_validator_accepts(): {==}

law BeaconBlockBody_normative_legal:
  S.type_legal(F.BeaconBlockBody.schema())
def BeaconBlockBody_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==})))))), ({==}, (({==}, {==}), {==}))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), {==}))))))), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))), {==})))))))), {==}))))))))))))))))))))))))))))

law BeaconBlockBody_validator_accepts:
  {Actual.valid(F.BeaconBlockBody.schema()) == True{} : Bool}
def BeaconBlockBody_validator_accepts(): {==}

law BeaconBlock_normative_legal:
  S.type_legal(F.BeaconBlock.schema())
def BeaconBlock_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==})))))), ({==}, (({==}, {==}), {==}))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), {==}))))))), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))), {==})))))))), {==})))))))))))))))))))))))))))), {==}))))))))))))

law BeaconBlock_validator_accepts:
  {Actual.valid(F.BeaconBlock.schema()) == True{} : Bool}
def BeaconBlock_validator_accepts(): {==}

law SignedBeaconBlock_normative_legal:
  S.type_legal(F.SignedBeaconBlock.schema())
def SignedBeaconBlock_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), {==})))))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))), {==})))))))))))), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, ({==}, {==}))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), {==})))))))))), {==}))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, {==})))))), ({==}, (({==}, {==}), {==}))))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))), ({==}, ({==}, ({==}, ({==}, {==})))))))))))))))))))))))))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))), ({==}, (({==}, {==}), {==}))))))), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, {==}))))))))), ({==}, (({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))))), {==})))))))), {==})))))))))))))))))))))))))))), {==})))))))))))), ({==}, (({==}, {==}), {==}))))))

law SignedBeaconBlock_validator_accepts:
  {Actual.valid(F.SignedBeaconBlock.schema()) == True{} : Bool}
def SignedBeaconBlock_validator_accepts(): {==}

law KZGProof_normative_legal:
  S.type_legal(F.KZGProof.schema())
def KZGProof_normative_legal(): ({==}, {==})

law KZGProof_validator_accepts:
  {Actual.valid(F.KZGProof.schema()) == True{} : Bool}
def KZGProof_validator_accepts(): {==}

law Blob_normative_legal:
  S.type_legal(F.Blob.schema())
def Blob_normative_legal(): ({==}, {==})

law Blob_validator_accepts:
  {Actual.valid(F.Blob.schema()) == True{} : Bool}
def Blob_validator_accepts(): {==}

law BlobSidecar_normative_legal:
  S.type_legal(F.BlobSidecar.schema())
def BlobSidecar_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==}))))))))))))))

law BlobSidecar_validator_accepts:
  {Actual.valid(F.BlobSidecar.schema()) == True{} : Bool}
def BlobSidecar_validator_accepts(): {==}

law Cell_normative_legal:
  S.type_legal(F.Cell.schema())
def Cell_normative_legal(): ({==}, {==})

law Cell_validator_accepts:
  {Actual.valid(F.Cell.schema()) == True{} : Bool}
def Cell_validator_accepts(): {==}

law CellIndex_normative_legal:
  S.type_legal(F.CellIndex.schema())
def CellIndex_normative_legal(): {==}

law CellIndex_validator_accepts:
  {Actual.valid(F.CellIndex.schema()) == True{} : Bool}
def CellIndex_validator_accepts(): {==}

law CommitmentIndex_normative_legal:
  S.type_legal(F.CommitmentIndex.schema())
def CommitmentIndex_normative_legal(): {==}

law CommitmentIndex_validator_accepts:
  {Actual.valid(F.CommitmentIndex.schema()) == True{} : Bool}
def CommitmentIndex_validator_accepts(): {==}

law RowIndex_normative_legal:
  S.type_legal(F.RowIndex.schema())
def RowIndex_normative_legal(): {==}

law RowIndex_validator_accepts:
  {Actual.valid(F.RowIndex.schema()) == True{} : Bool}
def RowIndex_validator_accepts(): {==}

law ColumnIndex_normative_legal:
  S.type_legal(F.ColumnIndex.schema())
def ColumnIndex_normative_legal(): {==}

law ColumnIndex_validator_accepts:
  {Actual.valid(F.ColumnIndex.schema()) == True{} : Bool}
def ColumnIndex_validator_accepts(): {==}

law DataColumnsByRootIdentifier_normative_legal:
  S.type_legal(F.DataColumnsByRootIdentifier.schema())
def DataColumnsByRootIdentifier_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==}))))))

law DataColumnsByRootIdentifier_validator_accepts:
  {Actual.valid(F.DataColumnsByRootIdentifier.schema()) == True{} : Bool}
def DataColumnsByRootIdentifier_validator_accepts(): {==}

law MatrixEntry_normative_legal:
  S.type_legal(F.MatrixEntry.schema())
def MatrixEntry_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, ({==}, ({==}, ({==}, {==}))))))))))

law MatrixEntry_validator_accepts:
  {Actual.valid(F.MatrixEntry.schema()) == True{} : Bool}
def MatrixEntry_validator_accepts(): {==}

law DataColumnSidecar_normative_legal:
  S.type_legal(F.DataColumnSidecar.schema())
def DataColumnSidecar_normative_legal(): ({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, (({==}, (({==}, ({==}, {==})), ({==}, ({==}, ({==}, ({==}, ({==}, (({==}, {==}), ({==}, (({==}, {==}), ({==}, (({==}, {==}), {==})))))))))))), ({==}, (({==}, {==}), {==})))))), ({==}, (({==}, ({==}, ({==}, {==}))), {==}))))))))))))))

law DataColumnSidecar_validator_accepts:
  {Actual.valid(F.DataColumnSidecar.schema()) == True{} : Bool}
def DataColumnSidecar_validator_accepts(): {==}

law CustodyIndex_normative_legal:
  S.type_legal(F.CustodyIndex.schema())
def CustodyIndex_normative_legal(): {==}

law CustodyIndex_validator_accepts:
  {Actual.valid(F.CustodyIndex.schema()) == True{} : Bool}
def CustodyIndex_validator_accepts(): {==}
