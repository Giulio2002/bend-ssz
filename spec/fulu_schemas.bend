import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P

# Exact frozen mainnet Fulu schema constants; no source/proof dependencies.
def Schema0() -> T.Schema: T.Boolean{}
def boolean() -> T.Schema: Schema0()
def Schema1() -> T.Schema: T.Unsigned{P.U8{}}
def uint8() -> T.Schema: Schema1()
def Schema2() -> T.Schema: T.Unsigned{P.U32Width{}}
def uint32() -> T.Schema: Schema2()
def Schema3() -> T.Schema: T.Unsigned{P.U64{}}
def uint64() -> T.Schema: Schema3()
def Schema4() -> T.Schema: T.Unsigned{P.U256{}}
def uint256() -> T.Schema: Schema4()
def Schema5() -> T.Schema: T.ByteVector{1n}
def Bytes1() -> T.Schema: Schema5()
def Schema6() -> T.Schema: T.ByteVector{4n}
def Bytes4() -> T.Schema: Schema6()
def Schema7() -> T.Schema: T.ByteVector{32n}
def Bytes32() -> T.Schema: Schema7()
def Schema8() -> T.Schema: T.ByteVector{48n}
def Bytes48() -> T.Schema: Schema8()
def Schema9() -> T.Schema: T.ByteVector{96n}
def Bytes96() -> T.Schema: Schema9()
def Schema10() -> T.Schema: T.ByteVector{8n}
def Bytes8() -> T.Schema: Schema10()
def Schema11() -> T.Schema: T.ByteVector{20n}
def Bytes20() -> T.Schema: Schema11()
def Slot() -> T.Schema: Schema3()
def Epoch() -> T.Schema: Schema3()
def Gwei() -> T.Schema: Schema3()
def Hash32() -> T.Schema: Schema7()
def Version() -> T.Schema: Schema6()
def DomainType() -> T.Schema: Schema6()
def BLSSignature() -> T.Schema: Schema9()
def Schema12() -> T.Schema: T.Vector{Schema7(), 7n}
def FinalityBranch() -> T.Schema: Schema12()
def VersionedHash() -> T.Schema: Schema7()
def G1Point() -> T.Schema: Schema8()
def G2Point() -> T.Schema: Schema9()
def Schema13() -> T.Schema: T.Container{["previous_version", "current_version", "epoch"], T.Chain{Schema6(), T.Chain{Schema6(), T.Chain{Schema3(), T.End{}}}}}
def Fork() -> T.Schema: Schema13()
def Schema14() -> T.Schema: T.BitVector{512n}
def Schema15() -> T.Schema: T.Container{["sync_committee_bits", "sync_committee_signature"], T.Chain{Schema14(), T.Chain{Schema9(), T.End{}}}}
def SyncAggregate() -> T.Schema: Schema15()
def Schema16() -> T.Schema: T.Container{["slot", "subcommittee_index"], T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}
def SyncAggregatorSelectionData() -> T.Schema: Schema16()
def Schema17() -> T.Schema: T.Container{["block_hash", "parent_hash", "total_difficulty"], T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema4(), T.End{}}}}}
def PowBlock() -> T.Schema: Schema17()
def CommitteeIndex() -> T.Schema: Schema3()
def ValidatorIndex() -> T.Schema: Schema3()
def Schema18() -> T.Schema: T.Container{["source_index", "target_index"], T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}
def PendingConsolidation() -> T.Schema: Schema18()
def Schema19() -> T.Schema: T.Container{["validator_index", "amount", "withdrawable_epoch"], T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}}
def PendingPartialWithdrawal() -> T.Schema: Schema19()
def Schema20() -> T.Schema: T.Container{["epoch", "validator_index"], T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}
def VoluntaryExit() -> T.Schema: Schema20()
def Schema21() -> T.Schema: T.Container{["message", "signature"], T.Chain{Schema20(), T.Chain{Schema9(), T.End{}}}}
def SignedVoluntaryExit() -> T.Schema: Schema21()
def Root() -> T.Schema: Schema7()
def Schema22() -> T.Schema: T.Container{["block_summary_root", "state_summary_root"], T.Chain{Schema7(), T.Chain{Schema7(), T.End{}}}}
def HistoricalSummary() -> T.Schema: Schema22()
def Schema23() -> T.Schema: T.BitVector{128n}
def Schema24() -> T.Schema: T.Container{["slot", "beacon_block_root", "subcommittee_index", "aggregation_bits", "signature"], T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema23(), T.Chain{Schema9(), T.End{}}}}}}}
def SyncCommitteeContribution() -> T.Schema: Schema24()
def Schema25() -> T.Schema: T.Container{["aggregator_index", "contribution", "selection_proof"], T.Chain{Schema3(), T.Chain{Schema24(), T.Chain{Schema9(), T.End{}}}}}
def ContributionAndProof() -> T.Schema: Schema25()
def Schema26() -> T.Schema: T.Container{["message", "signature"], T.Chain{Schema25(), T.Chain{Schema9(), T.End{}}}}
def SignedContributionAndProof() -> T.Schema: Schema26()
def Schema27() -> T.Schema: T.Container{["slot", "beacon_block_root", "validator_index", "signature"], T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema9(), T.End{}}}}}}
def SyncCommitteeMessage() -> T.Schema: Schema27()
def Schema28() -> T.Schema: T.Container{["timestamp", "deposit_root", "deposit_count"], T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema3(), T.End{}}}}}
def Eth1Block() -> T.Schema: Schema28()
def Schema29() -> T.Schema: T.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema7(), T.End{}}}}}}}
def BeaconBlockHeader() -> T.Schema: Schema29()
def Schema30() -> T.Schema: T.Container{["message", "signature"], T.Chain{Schema29(), T.Chain{Schema9(), T.End{}}}}
def SignedBeaconBlockHeader() -> T.Schema: Schema30()
def Schema31() -> T.Schema: T.Container{["signed_header_1", "signed_header_2"], T.Chain{Schema30(), T.Chain{Schema30(), T.End{}}}}
def ProposerSlashing() -> T.Schema: Schema31()
def Schema32() -> T.Schema: T.Vector{Schema7(), U32.to_nat(8192)}
def Schema33() -> T.Schema: T.Container{["block_roots", "state_roots"], T.Chain{Schema32(), T.Chain{Schema32(), T.End{}}}}
def HistoricalBatch() -> T.Schema: Schema33()
def Schema34() -> T.Schema: T.Container{["deposit_root", "deposit_count", "block_hash"], T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema7(), T.End{}}}}}
def Eth1Data() -> T.Schema: Schema34()
def Schema35() -> T.Schema: T.Container{["epoch", "root"], T.Chain{Schema3(), T.Chain{Schema7(), T.End{}}}}
def Checkpoint() -> T.Schema: Schema35()
def Schema36() -> T.Schema: T.Container{["slot", "index", "beacon_block_root", "source", "target"], T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema35(), T.Chain{Schema35(), T.End{}}}}}}}
def AttestationData() -> T.Schema: Schema36()
def Schema37() -> T.Schema: T.Container{["committee_index", "attester_index", "data", "signature"], T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema36(), T.Chain{Schema9(), T.End{}}}}}}
def SingleAttestation() -> T.Schema: Schema37()
def Schema38() -> T.Schema: T.BitList{U32.to_nat(131072)}
def Schema39() -> T.Schema: T.BitVector{64n}
def Schema40() -> T.Schema: T.Container{["aggregation_bits", "data", "signature", "committee_bits"], T.Chain{Schema38(), T.Chain{Schema36(), T.Chain{Schema9(), T.Chain{Schema39(), T.End{}}}}}}
def Attestation() -> T.Schema: Schema40()
def Schema41() -> T.Schema: T.Container{["aggregator_index", "aggregate", "selection_proof"], T.Chain{Schema3(), T.Chain{Schema40(), T.Chain{Schema9(), T.End{}}}}}
def AggregateAndProof() -> T.Schema: Schema41()
def Schema42() -> T.Schema: T.Container{["message", "signature"], T.Chain{Schema41(), T.Chain{Schema9(), T.End{}}}}
def SignedAggregateAndProof() -> T.Schema: Schema42()
def Schema43() -> T.Schema: T.BitList{2048n}
def Schema44() -> T.Schema: T.Container{["aggregation_bits", "data", "inclusion_delay", "proposer_index"], T.Chain{Schema43(), T.Chain{Schema36(), T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}}}
def PendingAttestation() -> T.Schema: Schema44()
def Schema45() -> T.Schema: T.ListOf{Schema3(), U32.to_nat(131072)}
def Schema46() -> T.Schema: T.Container{["attesting_indices", "data", "signature"], T.Chain{Schema45(), T.Chain{Schema36(), T.Chain{Schema9(), T.End{}}}}}
def IndexedAttestation() -> T.Schema: Schema46()
def Schema47() -> T.Schema: T.Container{["attestation_1", "attestation_2"], T.Chain{Schema46(), T.Chain{Schema46(), T.End{}}}}
def AttesterSlashing() -> T.Schema: Schema47()
def Schema48() -> T.Schema: T.Container{["current_version", "genesis_validators_root"], T.Chain{Schema6(), T.Chain{Schema7(), T.End{}}}}
def ForkData() -> T.Schema: Schema48()
def ForkDigest() -> T.Schema: Schema6()
def Domain() -> T.Schema: Schema7()
def Schema49() -> T.Schema: T.Container{["object_root", "domain"], T.Chain{Schema7(), T.Chain{Schema7(), T.End{}}}}
def SigningData() -> T.Schema: Schema49()
def BLSPubkey() -> T.Schema: Schema8()
def Schema50() -> T.Schema: T.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "index"], T.Chain{Schema8(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema9(), T.Chain{Schema3(), T.End{}}}}}}}
def DepositRequest() -> T.Schema: Schema50()
def Schema51() -> T.Schema: T.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "slot"], T.Chain{Schema8(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema9(), T.Chain{Schema3(), T.End{}}}}}}}
def PendingDeposit() -> T.Schema: Schema51()
def Schema52() -> T.Schema: T.Vector{Schema8(), 512n}
def Schema53() -> T.Schema: T.Container{["pubkeys", "aggregate_pubkey"], T.Chain{Schema52(), T.Chain{Schema8(), T.End{}}}}
def SyncCommittee() -> T.Schema: Schema53()
def Schema54() -> T.Schema: T.Container{["pubkey", "withdrawal_credentials", "amount", "signature"], T.Chain{Schema8(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema9(), T.End{}}}}}}
def DepositData() -> T.Schema: Schema54()
def Schema55() -> T.Schema: T.Vector{Schema7(), 33n}
def Schema56() -> T.Schema: T.Container{["proof", "data"], T.Chain{Schema55(), T.Chain{Schema54(), T.End{}}}}
def Deposit() -> T.Schema: Schema56()
def Schema57() -> T.Schema: T.Container{["pubkey", "withdrawal_credentials", "amount"], T.Chain{Schema8(), T.Chain{Schema7(), T.Chain{Schema3(), T.End{}}}}}
def DepositMessage() -> T.Schema: Schema57()
def Schema58() -> T.Schema: T.Container{["pubkey", "withdrawal_credentials", "effective_balance", "slashed", "activation_eligibility_epoch", "activation_epoch", "exit_epoch", "withdrawable_epoch"], T.Chain{Schema8(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema0(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}}}}}}}
def Validator() -> T.Schema: Schema58()
def NodeID() -> T.Schema: Schema4()
def SubnetID() -> T.Schema: Schema3()
def Ether() -> T.Schema: Schema3()
def ParticipationFlags() -> T.Schema: Schema1()
def Schema59() -> T.Schema: T.Vector{Schema7(), 6n}
def CurrentSyncCommitteeBranch() -> T.Schema: Schema59()
def NextSyncCommitteeBranch() -> T.Schema: Schema59()
def Schema60() -> T.Schema: T.ByteList{U32.to_nat(1073741824)}
def Transaction() -> T.Schema: Schema60()
def ExecutionAddress() -> T.Schema: Schema11()
def Schema61() -> T.Schema: T.Container{["source_address", "source_pubkey", "target_pubkey"], T.Chain{Schema11(), T.Chain{Schema8(), T.Chain{Schema8(), T.End{}}}}}
def ConsolidationRequest() -> T.Schema: Schema61()
def Schema62() -> T.Schema: T.Container{["source_address", "validator_pubkey", "amount"], T.Chain{Schema11(), T.Chain{Schema8(), T.Chain{Schema3(), T.End{}}}}}
def WithdrawalRequest() -> T.Schema: Schema62()
def Schema63() -> T.Schema: T.ListOf{Schema50(), U32.to_nat(8192)}
def Schema64() -> T.Schema: T.ListOf{Schema62(), 16n}
def Schema65() -> T.Schema: T.ListOf{Schema61(), 2n}
def Schema66() -> T.Schema: T.Container{["deposits", "withdrawals", "consolidations"], T.Chain{Schema63(), T.Chain{Schema64(), T.Chain{Schema65(), T.End{}}}}}
def ExecutionRequests() -> T.Schema: Schema66()
def Schema67() -> T.Schema: T.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], T.Chain{Schema3(), T.Chain{Schema8(), T.Chain{Schema11(), T.End{}}}}}
def BLSToExecutionChange() -> T.Schema: Schema67()
def Schema68() -> T.Schema: T.Container{["message", "signature"], T.Chain{Schema67(), T.Chain{Schema9(), T.End{}}}}
def SignedBLSToExecutionChange() -> T.Schema: Schema68()
def Schema69() -> T.Schema: T.ByteVector{256n}
def Schema70() -> T.Schema: T.ByteList{32n}
def Schema71() -> T.Schema: T.Container{["parent_hash", "fee_recipient", "state_root", "receipts_root", "logs_bloom", "prev_randao", "block_number", "gas_limit", "gas_used", "timestamp", "extra_data", "base_fee_per_gas", "block_hash", "transactions_root", "withdrawals_root", "blob_gas_used", "excess_blob_gas"], T.Chain{Schema7(), T.Chain{Schema11(), T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema69(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema70(), T.Chain{Schema4(), T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}}}}}}}}}}}}}}}}
def ExecutionPayloadHeader() -> T.Schema: Schema71()
def PayloadId() -> T.Schema: Schema10()
def WithdrawalIndex() -> T.Schema: Schema3()
def Schema72() -> T.Schema: T.Container{["index", "validator_index", "address", "amount"], T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema11(), T.Chain{Schema3(), T.End{}}}}}}
def Withdrawal() -> T.Schema: Schema72()
def Schema73() -> T.Schema: T.ListOf{Schema60(), U32.to_nat(1048576)}
def Schema74() -> T.Schema: T.ListOf{Schema72(), 16n}
def Schema75() -> T.Schema: T.Container{["parent_hash", "fee_recipient", "state_root", "receipts_root", "logs_bloom", "prev_randao", "block_number", "gas_limit", "gas_used", "timestamp", "extra_data", "base_fee_per_gas", "block_hash", "transactions", "withdrawals", "blob_gas_used", "excess_blob_gas"], T.Chain{Schema7(), T.Chain{Schema11(), T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema69(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema70(), T.Chain{Schema4(), T.Chain{Schema7(), T.Chain{Schema73(), T.Chain{Schema74(), T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}}}}}}}}}}}}}}}}
def ExecutionPayload() -> T.Schema: Schema75()
def Schema76() -> T.Schema: T.ListOf{Schema7(), U32.to_nat(16777216)}
def Schema77() -> T.Schema: T.ListOf{Schema34(), 2048n}
def Schema78() -> T.Schema: T.ListOf{Schema58(), Nat.mul(U32.to_nat(1073741824), 1024n)}
def Schema79() -> T.Schema: T.ListOf{Schema3(), Nat.mul(U32.to_nat(1073741824), 1024n)}
def Schema80() -> T.Schema: T.Vector{Schema7(), U32.to_nat(65536)}
def Schema81() -> T.Schema: T.Vector{Schema3(), U32.to_nat(8192)}
def Schema82() -> T.Schema: T.ListOf{Schema1(), Nat.mul(U32.to_nat(1073741824), 1024n)}
def Schema83() -> T.Schema: T.BitVector{4n}
def Schema84() -> T.Schema: T.ListOf{Schema22(), U32.to_nat(16777216)}
def Schema85() -> T.Schema: T.ListOf{Schema51(), U32.to_nat(134217728)}
def Schema86() -> T.Schema: T.ListOf{Schema19(), U32.to_nat(134217728)}
def Schema87() -> T.Schema: T.ListOf{Schema18(), U32.to_nat(262144)}
def Schema88() -> T.Schema: T.Vector{Schema3(), 64n}
def Schema89() -> T.Schema: T.Container{["genesis_time", "genesis_validators_root", "slot", "fork", "latest_block_header", "block_roots", "state_roots", "historical_roots", "eth1_data", "eth1_data_votes", "eth1_deposit_index", "validators", "balances", "randao_mixes", "slashings", "previous_epoch_participation", "current_epoch_participation", "justification_bits", "previous_justified_checkpoint", "current_justified_checkpoint", "finalized_checkpoint", "inactivity_scores", "current_sync_committee", "next_sync_committee", "latest_execution_payload_header", "next_withdrawal_index", "next_withdrawal_validator_index", "historical_summaries", "deposit_requests_start_index", "deposit_balance_to_consume", "exit_balance_to_consume", "earliest_exit_epoch", "consolidation_balance_to_consume", "earliest_consolidation_epoch", "pending_deposits", "pending_partial_withdrawals", "pending_consolidations", "proposer_lookahead"], T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema3(), T.Chain{Schema13(), T.Chain{Schema29(), T.Chain{Schema32(), T.Chain{Schema32(), T.Chain{Schema76(), T.Chain{Schema34(), T.Chain{Schema77(), T.Chain{Schema3(), T.Chain{Schema78(), T.Chain{Schema79(), T.Chain{Schema80(), T.Chain{Schema81(), T.Chain{Schema82(), T.Chain{Schema82(), T.Chain{Schema83(), T.Chain{Schema35(), T.Chain{Schema35(), T.Chain{Schema35(), T.Chain{Schema79(), T.Chain{Schema53(), T.Chain{Schema53(), T.Chain{Schema71(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema84(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema85(), T.Chain{Schema86(), T.Chain{Schema87(), T.Chain{Schema88(), T.End{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
def BeaconState() -> T.Schema: Schema89()
def Schema90() -> T.Schema: T.Vector{Schema7(), 4n}
def ExecutionBranch() -> T.Schema: Schema90()
def Schema91() -> T.Schema: T.Container{["beacon", "execution", "execution_branch"], T.Chain{Schema29(), T.Chain{Schema71(), T.Chain{Schema90(), T.End{}}}}}
def LightClientHeader() -> T.Schema: Schema91()
def Schema92() -> T.Schema: T.Container{["attested_header", "sync_aggregate", "signature_slot"], T.Chain{Schema91(), T.Chain{Schema15(), T.Chain{Schema3(), T.End{}}}}}
def LightClientOptimisticUpdate() -> T.Schema: Schema92()
def Schema93() -> T.Schema: T.Container{["attested_header", "finalized_header", "finality_branch", "sync_aggregate", "signature_slot"], T.Chain{Schema91(), T.Chain{Schema91(), T.Chain{Schema12(), T.Chain{Schema15(), T.Chain{Schema3(), T.End{}}}}}}}
def LightClientFinalityUpdate() -> T.Schema: Schema93()
def Schema94() -> T.Schema: T.Container{["attested_header", "next_sync_committee", "next_sync_committee_branch", "finalized_header", "finality_branch", "sync_aggregate", "signature_slot"], T.Chain{Schema91(), T.Chain{Schema53(), T.Chain{Schema59(), T.Chain{Schema91(), T.Chain{Schema12(), T.Chain{Schema15(), T.Chain{Schema3(), T.End{}}}}}}}}}
def LightClientUpdate() -> T.Schema: Schema94()
def Schema95() -> T.Schema: T.Container{["header", "current_sync_committee", "current_sync_committee_branch"], T.Chain{Schema91(), T.Chain{Schema53(), T.Chain{Schema59(), T.End{}}}}}
def LightClientBootstrap() -> T.Schema: Schema95()
def BlobIndex() -> T.Schema: Schema3()
def Schema96() -> T.Schema: T.Container{["block_root", "index"], T.Chain{Schema7(), T.Chain{Schema3(), T.End{}}}}
def BlobIdentifier() -> T.Schema: Schema96()
def KZGCommitment() -> T.Schema: Schema8()
def Schema97() -> T.Schema: T.ListOf{Schema31(), 16n}
def Schema98() -> T.Schema: T.ListOf{Schema47(), 1n}
def Schema99() -> T.Schema: T.ListOf{Schema40(), 8n}
def Schema100() -> T.Schema: T.ListOf{Schema56(), 16n}
def Schema101() -> T.Schema: T.ListOf{Schema21(), 16n}
def Schema102() -> T.Schema: T.ListOf{Schema68(), 16n}
def Schema103() -> T.Schema: T.ListOf{Schema8(), U32.to_nat(4096)}
def Schema104() -> T.Schema: T.Container{["randao_reveal", "eth1_data", "graffiti", "proposer_slashings", "attester_slashings", "attestations", "deposits", "voluntary_exits", "sync_aggregate", "execution_payload", "bls_to_execution_changes", "blob_kzg_commitments", "execution_requests"], T.Chain{Schema9(), T.Chain{Schema34(), T.Chain{Schema7(), T.Chain{Schema97(), T.Chain{Schema98(), T.Chain{Schema99(), T.Chain{Schema100(), T.Chain{Schema101(), T.Chain{Schema15(), T.Chain{Schema75(), T.Chain{Schema102(), T.Chain{Schema103(), T.Chain{Schema66(), T.End{}}}}}}}}}}}}}}}
def BeaconBlockBody() -> T.Schema: Schema104()
def Schema105() -> T.Schema: T.Container{["slot", "proposer_index", "parent_root", "state_root", "body"], T.Chain{Schema3(), T.Chain{Schema3(), T.Chain{Schema7(), T.Chain{Schema7(), T.Chain{Schema104(), T.End{}}}}}}}
def BeaconBlock() -> T.Schema: Schema105()
def Schema106() -> T.Schema: T.Container{["message", "signature"], T.Chain{Schema105(), T.Chain{Schema9(), T.End{}}}}
def SignedBeaconBlock() -> T.Schema: Schema106()
def KZGProof() -> T.Schema: Schema8()
def Schema107() -> T.Schema: T.ByteVector{U32.to_nat(131072)}
def Blob() -> T.Schema: Schema107()
def Schema108() -> T.Schema: T.Vector{Schema7(), 17n}
def Schema109() -> T.Schema: T.Container{["index", "blob", "kzg_commitment", "kzg_proof", "signed_block_header", "kzg_commitment_inclusion_proof"], T.Chain{Schema3(), T.Chain{Schema107(), T.Chain{Schema8(), T.Chain{Schema8(), T.Chain{Schema30(), T.Chain{Schema108(), T.End{}}}}}}}}
def BlobSidecar() -> T.Schema: Schema109()
def Schema110() -> T.Schema: T.ByteVector{2048n}
def Cell() -> T.Schema: Schema110()
def CellIndex() -> T.Schema: Schema3()
def CommitmentIndex() -> T.Schema: Schema3()
def RowIndex() -> T.Schema: Schema3()
def ColumnIndex() -> T.Schema: Schema3()
def Schema111() -> T.Schema: T.ListOf{Schema3(), 128n}
def Schema112() -> T.Schema: T.Container{["block_root", "columns"], T.Chain{Schema7(), T.Chain{Schema111(), T.End{}}}}
def DataColumnsByRootIdentifier() -> T.Schema: Schema112()
def Schema113() -> T.Schema: T.Container{["cell", "kzg_proof", "column_index", "row_index"], T.Chain{Schema110(), T.Chain{Schema8(), T.Chain{Schema3(), T.Chain{Schema3(), T.End{}}}}}}
def MatrixEntry() -> T.Schema: Schema113()
def Schema114() -> T.Schema: T.ListOf{Schema110(), U32.to_nat(4096)}
def Schema115() -> T.Schema: T.Container{["index", "column", "kzg_commitments", "kzg_proofs", "signed_block_header", "kzg_commitments_inclusion_proof"], T.Chain{Schema3(), T.Chain{Schema114(), T.Chain{Schema103(), T.Chain{Schema103(), T.Chain{Schema30(), T.Chain{Schema90(), T.End{}}}}}}}}
def DataColumnSidecar() -> T.Schema: Schema115()
def CustodyIndex() -> T.Schema: Schema3()
