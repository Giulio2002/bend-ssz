import Base
import ../../src/obj.bend as O
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
import ../../types/boolean_encode_ssz_generated.bend as boolean_e
import ../../types/uint64_encode_ssz_generated.bend as uint64_e
import ../../types/uint256_encode_ssz_generated.bend as uint256_e
import ../../types/FuluBytes4_encode_ssz_generated.bend as FuluBytes4_e
import ../../types/FuluBytes32_encode_ssz_generated.bend as FuluBytes32_e
import ../../types/FuluBytes48_encode_ssz_generated.bend as FuluBytes48_e
import ../../types/FuluBytes96_encode_ssz_generated.bend as FuluBytes96_e
import ../../types/FuluBytes8_encode_ssz_generated.bend as FuluBytes8_e
import ../../types/FuluBytes20_encode_ssz_generated.bend as FuluBytes20_e
import ../../types/FuluFork_def_generated.bend as FuluFork_d
import ../../types/FuluFork_encode_ssz_generated.bend as FuluFork_e
import ../../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
import ../../types/FuluSyncAggregate_encode_ssz_generated.bend as FuluSyncAggregate_e
import ../../types/FuluSyncAggregatorSelectionData_def_generated.bend as FuluSyncAggregatorSelectionData_d
import ../../types/FuluSyncAggregatorSelectionData_encode_ssz_generated.bend as FuluSyncAggregatorSelectionData_e
import ../../types/FuluPowBlock_def_generated.bend as FuluPowBlock_d
import ../../types/FuluPowBlock_encode_ssz_generated.bend as FuluPowBlock_e
import ../../types/FuluPendingConsolidation_def_generated.bend as FuluPendingConsolidation_d
import ../../types/FuluPendingConsolidation_encode_ssz_generated.bend as FuluPendingConsolidation_e
import ../../types/FuluPendingPartialWithdrawal_def_generated.bend as FuluPendingPartialWithdrawal_d
import ../../types/FuluPendingPartialWithdrawal_encode_ssz_generated.bend as FuluPendingPartialWithdrawal_e
import ../../types/FuluVoluntaryExit_def_generated.bend as FuluVoluntaryExit_d
import ../../types/FuluVoluntaryExit_encode_ssz_generated.bend as FuluVoluntaryExit_e
import ../../types/FuluSignedVoluntaryExit_def_generated.bend as FuluSignedVoluntaryExit_d
import ../../types/FuluSignedVoluntaryExit_encode_ssz_generated.bend as FuluSignedVoluntaryExit_e
import ../../types/FuluHistoricalSummary_def_generated.bend as FuluHistoricalSummary_d
import ../../types/FuluHistoricalSummary_encode_ssz_generated.bend as FuluHistoricalSummary_e
import ../../types/FuluSyncCommitteeContribution_def_generated.bend as FuluSyncCommitteeContribution_d
import ../../types/FuluSyncCommitteeContribution_encode_ssz_generated.bend as FuluSyncCommitteeContribution_e
import ../../types/FuluSyncCommitteeMessage_def_generated.bend as FuluSyncCommitteeMessage_d
import ../../types/FuluSyncCommitteeMessage_encode_ssz_generated.bend as FuluSyncCommitteeMessage_e
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
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../../spec/value_domain.bend as VD
import ../../spec/fulu_schemas.bend as Spec
import ./root_names_light.bend as RN

# GENERATED by hash_tree_root_laws (codegen). Do not edit.
# Every object of a phase-A shape is structurally valid (spec/value_domain.bend
# root_valid of its view), and the generated validity of those names agrees.

def rv_bool(+o: Bool) -> {VD.root_valid(RN.v_bool(o), S.Boolean{}) == True{} : Bool}: {==}

def rv_u64(+o: O.U64) -> {VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}) == True{} : Bool}:
  match o:
    case O.U64{+lo, +hi}: {==}

def rv_u256(+o: uint256_d.Uint256) -> {VD.root_valid(RN.v_u256(o), S.Unsigned{P.U256{}}) == True{} : Bool}:
  match o:
    case uint256_d.Uint256{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}: {==}

def rv_b4(+o: FuluBytes4_d.Bytes4) -> {VD.root_valid(RN.v_b4(o), S.ByteVector{4n}) == True{} : Bool}: RN.domain_b4(o)

def rv_b32(+o: FuluBytes32_d.Bytes32) -> {VD.root_valid(RN.v_b32(o), S.ByteVector{32n}) == True{} : Bool}: RN.domain_b32(o)

def rv_b48(+o: FuluBytes48_d.Bytes48) -> {VD.root_valid(RN.v_b48(o), S.ByteVector{48n}) == True{} : Bool}: RN.domain_b48(o)

def rv_b96(+o: FuluBytes96_d.Bytes96) -> {VD.root_valid(RN.v_b96(o), S.ByteVector{96n}) == True{} : Bool}: RN.domain_b96(o)

def rv_b8(+o: FuluBytes8_d.Bytes8) -> {VD.root_valid(RN.v_b8(o), S.ByteVector{8n}) == True{} : Bool}: RN.domain_b8(o)

def rv_b20(+o: FuluBytes20_d.Bytes20) -> {VD.root_valid(RN.v_b20(o), S.ByteVector{20n}) == True{} : Bool}: RN.domain_b20(o)

def rv_Fork(+o: FuluFork_d.Fork) -> {VD.root_valid(RN.v_Fork(o), S.Container{["previous_version", "current_version", "epoch"], S.Chain{S.ByteVector{4n}, S.Chain{S.ByteVector{4n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluFork_d.Fork{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b4(x0), S.ByteVector{4n}), True{}, rv_b4(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b4(x1), S.Items{RN.v_u64(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{4n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b4(x1), S.ByteVector{4n}), True{}, rv_b4(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_bv512(+o: Fulu_bitvector_512_d.Bitvector512) -> {VD.root_valid(RN.v_bv512(o), S.BitVector{512n}) == True{} : Bool}:
  %Equal.sym(Nat, List.length(&2, Bool, RN.bits_bv512(o)), 512n, RN.blen_bv512(o)) :
    {Bool.and(Nat.is_lt(0n, 512n), Nat.is_eq(_, 512n)) == True{} : Bool}
  {==}

def rv_SyncAggregate(+o: FuluSyncAggregate_d.SyncAggregate) -> {VD.root_valid(RN.v_SyncAggregate(o), S.Container{["sync_committee_bits", "sync_committee_signature"], S.Chain{S.BitVector{512n}, S.Chain{S.ByteVector{96n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluSyncAggregate_d.SyncAggregate{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_bv512(x0), S.BitVector{512n}), True{}, rv_bv512(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x1), S.ByteVector{96n}), True{}, rv_b96(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_SyncAggregatorSelectionData(+o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData) -> {VD.root_valid(RN.v_SyncAggregatorSelectionData(o), S.Container{["slot", "subcommittee_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_PowBlock(+o: FuluPowBlock_d.PowBlock) -> {VD.root_valid(RN.v_PowBlock(o), S.Container{["block_hash", "parent_hash", "total_difficulty"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U256{}}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluPowBlock_d.PowBlock{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x0), S.ByteVector{32n}), True{}, rv_b32(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u256(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U256{}}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u256(x2), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U256{}}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u256(x2), S.Unsigned{P.U256{}}), True{}, rv_u256(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_PendingConsolidation(+o: FuluPendingConsolidation_d.PendingConsolidation) -> {VD.root_valid(RN.v_PendingConsolidation(o), S.Container{["source_index", "target_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluPendingConsolidation_d.PendingConsolidation{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_PendingPartialWithdrawal(+o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal) -> {VD.root_valid(RN.v_PendingPartialWithdrawal(o), S.Container{["validator_index", "amount", "withdrawable_epoch"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.Items{RN.v_u64(x2), S.EmptyItems{}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_VoluntaryExit(+o: FuluVoluntaryExit_d.VoluntaryExit) -> {VD.root_valid(RN.v_VoluntaryExit(o), S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluVoluntaryExit_d.VoluntaryExit{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_SignedVoluntaryExit(+o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit) -> {VD.root_valid(RN.v_SignedVoluntaryExit(o), S.Container{["message", "signature"], S.Chain{S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluSignedVoluntaryExit_d.SignedVoluntaryExit{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_VoluntaryExit(x0), S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}), True{}, rv_VoluntaryExit(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x1), S.ByteVector{96n}), True{}, rv_b96(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_HistoricalSummary(+o: FuluHistoricalSummary_d.HistoricalSummary) -> {VD.root_valid(RN.v_HistoricalSummary(o), S.Container{["block_summary_root", "state_summary_root"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluHistoricalSummary_d.HistoricalSummary{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x0), S.ByteVector{32n}), True{}, rv_b32(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{32n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_bv128(+o: Fulu_bitvector_128_d.Bitvector128) -> {VD.root_valid(RN.v_bv128(o), S.BitVector{128n}) == True{} : Bool}:
  %Equal.sym(Nat, List.length(&2, Bool, RN.bits_bv128(o)), 128n, RN.blen_bv128(o)) :
    {Bool.and(Nat.is_lt(0n, 128n), Nat.is_eq(_, 128n)) == True{} : Bool}
  {==}

def rv_SyncCommitteeContribution(+o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution) -> {VD.root_valid(RN.v_SyncCommitteeContribution(o), S.Container{["slot", "beacon_block_root", "subcommittee_index", "aggregation_bits", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.BitVector{128n}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}}) == True{} : Bool}:
  match o:
    case FuluSyncCommitteeContribution_d.SyncCommitteeContribution{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_bv128(x3), S.Items{RN.v_b96(x4), S.EmptyItems{}}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.BitVector{128n}, S.Chain{S.ByteVector{96n}, S.End{}}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.Items{RN.v_bv128(x3), S.Items{RN.v_b96(x4), S.EmptyItems{}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.BitVector{128n}, S.Chain{S.ByteVector{96n}, S.End{}}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_bv128(x3), S.Items{RN.v_b96(x4), S.EmptyItems{}}}, S.Chain{S.BitVector{128n}, S.Chain{S.ByteVector{96n}, S.End{}}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_bv128(x3), S.BitVector{128n}), True{}, rv_bv128(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x4), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}}))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x4), S.ByteVector{96n}), True{}, rv_b96(x4)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))))) == True{} : Bool}
      {==}

def rv_SyncCommitteeMessage(+o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage) -> {VD.root_valid(RN.v_SyncCommitteeMessage(o), S.Container{["slot", "beacon_block_root", "validator_index", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}) == True{} : Bool}:
  match o:
    case FuluSyncCommitteeMessage_d.SyncCommitteeMessage{+x0, +x1, +x2, +x3}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.EmptyItems{}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.EmptyItems{}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x3), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x3), S.ByteVector{96n}), True{}, rv_b96(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))))) == True{} : Bool}
      {==}

def rv_Eth1Block(+o: FuluEth1Block_d.Eth1Block) -> {VD.root_valid(RN.v_Eth1Block(o), S.Container{["timestamp", "deposit_root", "deposit_count"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluEth1Block_d.Eth1Block{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_BeaconBlockHeader(+o: FuluBeaconBlockHeader_d.BeaconBlockHeader) -> {VD.root_valid(RN.v_BeaconBlockHeader(o), S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}) == True{} : Bool}:
  match o:
    case FuluBeaconBlockHeader_d.BeaconBlockHeader{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.Items{RN.v_b32(x2), S.Items{RN.v_b32(x3), S.Items{RN.v_b32(x4), S.EmptyItems{}}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x2), S.Items{RN.v_b32(x3), S.Items{RN.v_b32(x4), S.EmptyItems{}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x2), S.ByteVector{32n}), True{}, rv_b32(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x3), S.Items{RN.v_b32(x4), S.EmptyItems{}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x3), S.ByteVector{32n}), True{}, rv_b32(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x4), S.EmptyItems{}}, S.Chain{S.ByteVector{32n}, S.End{}}))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x4), S.ByteVector{32n}), True{}, rv_b32(x4)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))))) == True{} : Bool}
      {==}

def rv_SignedBeaconBlockHeader(+o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader) -> {VD.root_valid(RN.v_SignedBeaconBlockHeader(o), S.Container{["message", "signature"], S.Chain{S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_BeaconBlockHeader(x0), S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}), True{}, rv_BeaconBlockHeader(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x1), S.ByteVector{96n}), True{}, rv_b96(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_Eth1Data(+o: FuluEth1Data_d.Eth1Data) -> {VD.root_valid(RN.v_Eth1Data(o), S.Container{["deposit_root", "deposit_count", "block_hash"], S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluEth1Data_d.Eth1Data{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x0), S.ByteVector{32n}), True{}, rv_b32(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.Items{RN.v_b32(x2), S.EmptyItems{}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x2), S.EmptyItems{}}, S.Chain{S.ByteVector{32n}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x2), S.ByteVector{32n}), True{}, rv_b32(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_Checkpoint(+o: FuluCheckpoint_d.Checkpoint) -> {VD.root_valid(RN.v_Checkpoint(o), S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluCheckpoint_d.Checkpoint{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{32n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_AttestationData(+o: FuluAttestationData_d.AttestationData) -> {VD.root_valid(RN.v_AttestationData(o), S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}) == True{} : Bool}:
  match o:
    case FuluAttestationData_d.AttestationData{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.Items{RN.v_b32(x2), S.Items{RN.v_Checkpoint(x3), S.Items{RN.v_Checkpoint(x4), S.EmptyItems{}}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x2), S.Items{RN.v_Checkpoint(x3), S.Items{RN.v_Checkpoint(x4), S.EmptyItems{}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x2), S.ByteVector{32n}), True{}, rv_b32(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_Checkpoint(x3), S.Items{RN.v_Checkpoint(x4), S.EmptyItems{}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_Checkpoint(x3), S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}), True{}, rv_Checkpoint(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_Checkpoint(x4), S.EmptyItems{}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_Checkpoint(x4), S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}), True{}, rv_Checkpoint(x4)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))))) == True{} : Bool}
      {==}

def rv_SingleAttestation(+o: FuluSingleAttestation_d.SingleAttestation) -> {VD.root_valid(RN.v_SingleAttestation(o), S.Container{["committee_index", "attester_index", "data", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}) == True{} : Bool}:
  match o:
    case FuluSingleAttestation_d.SingleAttestation{+x0, +x1, +x2, +x3}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.Items{RN.v_AttestationData(x2), S.Items{RN.v_b96(x3), S.EmptyItems{}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_AttestationData(x2), S.Items{RN.v_b96(x3), S.EmptyItems{}}}, S.Chain{S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_AttestationData(x2), S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}), True{}, rv_AttestationData(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x3), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x3), S.ByteVector{96n}), True{}, rv_b96(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))))) == True{} : Bool}
      {==}

def rv_bv64(+o: Fulu_bitvector_64_d.Bitvector64) -> {VD.root_valid(RN.v_bv64(o), S.BitVector{64n}) == True{} : Bool}:
  %Equal.sym(Nat, List.length(&2, Bool, RN.bits_bv64(o)), 64n, RN.blen_bv64(o)) :
    {Bool.and(Nat.is_lt(0n, 64n), Nat.is_eq(_, 64n)) == True{} : Bool}
  {==}

def rv_ForkData(+o: FuluForkData_d.ForkData) -> {VD.root_valid(RN.v_ForkData(o), S.Container{["current_version", "genesis_validators_root"], S.Chain{S.ByteVector{4n}, S.Chain{S.ByteVector{32n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluForkData_d.ForkData{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b4(x0), S.ByteVector{4n}), True{}, rv_b4(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{32n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_SigningData(+o: FuluSigningData_d.SigningData) -> {VD.root_valid(RN.v_SigningData(o), S.Container{["object_root", "domain"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluSigningData_d.SigningData{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x0), S.ByteVector{32n}), True{}, rv_b32(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{32n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_DepositRequest(+o: FuluDepositRequest_d.DepositRequest) -> {VD.root_valid(RN.v_DepositRequest(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "index"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}) == True{} : Bool}:
  match o:
    case FuluDepositRequest_d.DepositRequest{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x0), S.ByteVector{48n}), True{}, rv_b48(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x3), S.ByteVector{96n}), True{}, rv_b96(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x4), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x4), S.Unsigned{P.U64{}}), True{}, rv_u64(x4)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))))) == True{} : Bool}
      {==}

def rv_PendingDeposit(+o: FuluPendingDeposit_d.PendingDeposit) -> {VD.root_valid(RN.v_PendingDeposit(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "slot"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}) == True{} : Bool}:
  match o:
    case FuluPendingDeposit_d.PendingDeposit{+x0, +x1, +x2, +x3, +x4}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x0), S.ByteVector{48n}), True{}, rv_b48(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x3), S.ByteVector{96n}), True{}, rv_b96(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x4), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x4), S.Unsigned{P.U64{}}), True{}, rv_u64(x4)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))))) == True{} : Bool}
      {==}

def rv_DepositData(+o: FuluDepositData_d.DepositData) -> {VD.root_valid(RN.v_DepositData(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}) == True{} : Bool}:
  match o:
    case FuluDepositData_d.DepositData{+x0, +x1, +x2, +x3}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x0), S.ByteVector{48n}), True{}, rv_b48(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.EmptyItems{}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.Items{RN.v_b96(x3), S.EmptyItems{}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x3), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x3), S.ByteVector{96n}), True{}, rv_b96(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))))) == True{} : Bool}
      {==}

def rv_DepositMessage(+o: FuluDepositMessage_d.DepositMessage) -> {VD.root_valid(RN.v_DepositMessage(o), S.Container{["pubkey", "withdrawal_credentials", "amount"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluDepositMessage_d.DepositMessage{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x0), S.ByteVector{48n}), True{}, rv_b48(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_Validator(+o: FuluValidator_d.Validator) -> {VD.root_valid(RN.v_Validator(o), S.Container{["pubkey", "withdrawal_credentials", "effective_balance", "slashed", "activation_eligibility_epoch", "activation_epoch", "exit_epoch", "withdrawable_epoch"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Boolean{}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}}}}) == True{} : Bool}:
  match o:
    case FuluValidator_d.Validator{+x0, +x1, +x2, +x3, +x4, +x5, +x6, +x7}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x0), S.ByteVector{48n}), True{}, rv_b48(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b32(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_bool(x3), S.Items{RN.v_u64(x4), S.Items{RN.v_u64(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.EmptyItems{}}}}}}}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Boolean{}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x1), S.ByteVector{32n}), True{}, rv_b32(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.Items{RN.v_bool(x3), S.Items{RN.v_u64(x4), S.Items{RN.v_u64(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.EmptyItems{}}}}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Boolean{}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_bool(x3), S.Items{RN.v_u64(x4), S.Items{RN.v_u64(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.EmptyItems{}}}}}}, S.Chain{S.Boolean{}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_bool(x3), S.Boolean{}), True{}, rv_bool(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x4), S.Items{RN.v_u64(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.EmptyItems{}}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x4), S.Unsigned{P.U64{}}), True{}, rv_u64(x4)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.EmptyItems{}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}})))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x5), S.Unsigned{P.U64{}}), True{}, rv_u64(x5)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.EmptyItems{}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}))))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x6), S.Unsigned{P.U64{}}), True{}, rv_u64(x6)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x7), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}})))))))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x7), S.Unsigned{P.U64{}}), True{}, rv_u64(x7)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))))))))) == True{} : Bool}
      {==}

def rv_ConsolidationRequest(+o: FuluConsolidationRequest_d.ConsolidationRequest) -> {VD.root_valid(RN.v_ConsolidationRequest(o), S.Container{["source_address", "source_pubkey", "target_pubkey"], S.Chain{S.ByteVector{20n}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{48n}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluConsolidationRequest_d.ConsolidationRequest{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b20(x0), S.ByteVector{20n}), True{}, rv_b20(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b48(x1), S.Items{RN.v_b48(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{48n}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x1), S.ByteVector{48n}), True{}, rv_b48(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b48(x2), S.EmptyItems{}}, S.Chain{S.ByteVector{48n}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x2), S.ByteVector{48n}), True{}, rv_b48(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_WithdrawalRequest(+o: FuluWithdrawalRequest_d.WithdrawalRequest) -> {VD.root_valid(RN.v_WithdrawalRequest(o), S.Container{["source_address", "validator_pubkey", "amount"], S.Chain{S.ByteVector{20n}, S.Chain{S.ByteVector{48n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluWithdrawalRequest_d.WithdrawalRequest{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b20(x0), S.ByteVector{20n}), True{}, rv_b20(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b48(x1), S.Items{RN.v_u64(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{48n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x1), S.ByteVector{48n}), True{}, rv_b48(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x2), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x2), S.Unsigned{P.U64{}}), True{}, rv_u64(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_BLSToExecutionChange(+o: FuluBLSToExecutionChange_d.BLSToExecutionChange) -> {VD.root_valid(RN.v_BLSToExecutionChange(o), S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}) == True{} : Bool}:
  match o:
    case FuluBLSToExecutionChange_d.BLSToExecutionChange{+x0, +x1, +x2}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b48(x1), S.Items{RN.v_b20(x2), S.EmptyItems{}}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b48(x1), S.ByteVector{48n}), True{}, rv_b48(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b20(x2), S.EmptyItems{}}, S.Chain{S.ByteVector{20n}, S.End{}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b20(x2), S.ByteVector{20n}), True{}, rv_b20(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{})))) == True{} : Bool}
      {==}

def rv_SignedBLSToExecutionChange(+o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange) -> {VD.root_valid(RN.v_SignedBLSToExecutionChange(o), S.Container{["message", "signature"], S.Chain{S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_BLSToExecutionChange(x0), S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}), True{}, rv_BLSToExecutionChange(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_b96(x1), S.EmptyItems{}}, S.Chain{S.ByteVector{96n}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b96(x1), S.ByteVector{96n}), True{}, rv_b96(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

def rv_Withdrawal(+o: FuluWithdrawal_d.Withdrawal) -> {VD.root_valid(RN.v_Withdrawal(o), S.Container{["index", "validator_index", "address", "amount"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{20n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}) == True{} : Bool}:
  match o:
    case FuluWithdrawal_d.Withdrawal{+x0, +x1, +x2, +x3}:
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x0), S.Unsigned{P.U64{}}), True{}, rv_u64(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.Items{RN.v_b20(x2), S.Items{RN.v_u64(x3), S.EmptyItems{}}}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{20n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_b20(x2), S.Items{RN.v_u64(x3), S.EmptyItems{}}}, S.Chain{S.ByteVector{20n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_b20(x2), S.ByteVector{20n}), True{}, rv_b20(x2)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x3), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}})))) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x3), S.Unsigned{P.U64{}}), True{}, rv_u64(x3)) :
        {Bool.and(True{}, Bool.and(True{}, Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))))) == True{} : Bool}
      {==}

def rv_BlobIdentifier(+o: FuluBlobIdentifier_d.BlobIdentifier) -> {VD.root_valid(RN.v_BlobIdentifier(o), S.Container{["block_root", "index"], S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}) == True{} : Bool}:
  match o:
    case FuluBlobIdentifier_d.BlobIdentifier{+x0, +x1}:
      %Equal.sym(Bool, VD.root_valid(RN.v_b32(x0), S.ByteVector{32n}), True{}, rv_b32(x0)) :
        {Bool.and(_, VD.root_valid(S.Items{RN.v_u64(x1), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}})) == True{} : Bool}
      %Equal.sym(Bool, VD.root_valid(RN.v_u64(x1), S.Unsigned{P.U64{}}), True{}, rv_u64(x1)) :
        {Bool.and(True{}, Bool.and(_, VD.root_valid(S.EmptyItems{}, S.End{}))) == True{} : Bool}
      {==}

# boolean: every object is valid, as its generated validity says.
def boolean_valid_agrees(+o: Bool) -> {boolean_e.bool_valid(o) == VD.root_valid(RN.v_bool(o), Spec.boolean()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_bool(o), S.Boolean{}), True{}, rv_bool(o)) : {boolean_e.bool_valid(o) == _ : Bool}
  {==}

# uint64: every object is valid, as its generated validity says.
def uint64_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.uint64()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# uint256: every object is valid, as its generated validity says.
def uint256_valid_agrees(+o: uint256_d.Uint256) -> {uint256_e.u256_valid(o) == VD.root_valid(RN.v_u256(o), Spec.uint256()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u256(o), S.Unsigned{P.U256{}}), True{}, rv_u256(o)) : {uint256_e.u256_valid(o) == _ : Bool}
  {==}

# Bytes4: every object is valid, as its generated validity says.
def Bytes4_valid_agrees(+o: FuluBytes4_d.Bytes4) -> {FuluBytes4_e.b4_valid(o) == VD.root_valid(RN.v_b4(o), Spec.Bytes4()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b4(o), S.ByteVector{4n}), True{}, rv_b4(o)) : {FuluBytes4_e.b4_valid(o) == _ : Bool}
  {==}

# Bytes32: every object is valid, as its generated validity says.
def Bytes32_valid_agrees(+o: FuluBytes32_d.Bytes32) -> {FuluBytes32_e.b32_valid(o) == VD.root_valid(RN.v_b32(o), Spec.Bytes32()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b32(o), S.ByteVector{32n}), True{}, rv_b32(o)) : {FuluBytes32_e.b32_valid(o) == _ : Bool}
  {==}

# Bytes48: every object is valid, as its generated validity says.
def Bytes48_valid_agrees(+o: FuluBytes48_d.Bytes48) -> {FuluBytes48_e.b48_valid(o) == VD.root_valid(RN.v_b48(o), Spec.Bytes48()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b48(o), S.ByteVector{48n}), True{}, rv_b48(o)) : {FuluBytes48_e.b48_valid(o) == _ : Bool}
  {==}

# Bytes96: every object is valid, as its generated validity says.
def Bytes96_valid_agrees(+o: FuluBytes96_d.Bytes96) -> {FuluBytes96_e.b96_valid(o) == VD.root_valid(RN.v_b96(o), Spec.Bytes96()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b96(o), S.ByteVector{96n}), True{}, rv_b96(o)) : {FuluBytes96_e.b96_valid(o) == _ : Bool}
  {==}

# Bytes8: every object is valid, as its generated validity says.
def Bytes8_valid_agrees(+o: FuluBytes8_d.Bytes8) -> {FuluBytes8_e.b8_valid(o) == VD.root_valid(RN.v_b8(o), Spec.Bytes8()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b8(o), S.ByteVector{8n}), True{}, rv_b8(o)) : {FuluBytes8_e.b8_valid(o) == _ : Bool}
  {==}

# Bytes20: every object is valid, as its generated validity says.
def Bytes20_valid_agrees(+o: FuluBytes20_d.Bytes20) -> {FuluBytes20_e.b20_valid(o) == VD.root_valid(RN.v_b20(o), Spec.Bytes20()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b20(o), S.ByteVector{20n}), True{}, rv_b20(o)) : {FuluBytes20_e.b20_valid(o) == _ : Bool}
  {==}

# Slot: every object is valid, as its generated validity says.
def Slot_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.Slot()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# Epoch: every object is valid, as its generated validity says.
def Epoch_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.Epoch()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# Gwei: every object is valid, as its generated validity says.
def Gwei_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.Gwei()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# Hash32: every object is valid, as its generated validity says.
def Hash32_valid_agrees(+o: FuluBytes32_d.Bytes32) -> {FuluBytes32_e.b32_valid(o) == VD.root_valid(RN.v_b32(o), Spec.Hash32()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b32(o), S.ByteVector{32n}), True{}, rv_b32(o)) : {FuluBytes32_e.b32_valid(o) == _ : Bool}
  {==}

# Version: every object is valid, as its generated validity says.
def Version_valid_agrees(+o: FuluBytes4_d.Bytes4) -> {FuluBytes4_e.b4_valid(o) == VD.root_valid(RN.v_b4(o), Spec.Version()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b4(o), S.ByteVector{4n}), True{}, rv_b4(o)) : {FuluBytes4_e.b4_valid(o) == _ : Bool}
  {==}

# DomainType: every object is valid, as its generated validity says.
def DomainType_valid_agrees(+o: FuluBytes4_d.Bytes4) -> {FuluBytes4_e.b4_valid(o) == VD.root_valid(RN.v_b4(o), Spec.DomainType()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b4(o), S.ByteVector{4n}), True{}, rv_b4(o)) : {FuluBytes4_e.b4_valid(o) == _ : Bool}
  {==}

# BLSSignature: every object is valid, as its generated validity says.
def BLSSignature_valid_agrees(+o: FuluBytes96_d.Bytes96) -> {FuluBytes96_e.b96_valid(o) == VD.root_valid(RN.v_b96(o), Spec.BLSSignature()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b96(o), S.ByteVector{96n}), True{}, rv_b96(o)) : {FuluBytes96_e.b96_valid(o) == _ : Bool}
  {==}

# VersionedHash: every object is valid, as its generated validity says.
def VersionedHash_valid_agrees(+o: FuluBytes32_d.Bytes32) -> {FuluBytes32_e.b32_valid(o) == VD.root_valid(RN.v_b32(o), Spec.VersionedHash()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b32(o), S.ByteVector{32n}), True{}, rv_b32(o)) : {FuluBytes32_e.b32_valid(o) == _ : Bool}
  {==}

# G1Point: every object is valid, as its generated validity says.
def G1Point_valid_agrees(+o: FuluBytes48_d.Bytes48) -> {FuluBytes48_e.b48_valid(o) == VD.root_valid(RN.v_b48(o), Spec.G1Point()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b48(o), S.ByteVector{48n}), True{}, rv_b48(o)) : {FuluBytes48_e.b48_valid(o) == _ : Bool}
  {==}

# G2Point: every object is valid, as its generated validity says.
def G2Point_valid_agrees(+o: FuluBytes96_d.Bytes96) -> {FuluBytes96_e.b96_valid(o) == VD.root_valid(RN.v_b96(o), Spec.G2Point()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b96(o), S.ByteVector{96n}), True{}, rv_b96(o)) : {FuluBytes96_e.b96_valid(o) == _ : Bool}
  {==}

# Fork: every object is valid, as its generated validity says.
def Fork_valid_agrees(+o: FuluFork_d.Fork) -> {FuluFork_e.Fork_valid(o) == VD.root_valid(RN.v_Fork(o), Spec.Fork()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_Fork(o), S.Container{["previous_version", "current_version", "epoch"], S.Chain{S.ByteVector{4n}, S.Chain{S.ByteVector{4n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}), True{}, rv_Fork(o)) : {FuluFork_e.Fork_valid(o) == _ : Bool}
  {==}

# SyncAggregate: every object is valid, as its generated validity says.
def SyncAggregate_valid_agrees(+o: FuluSyncAggregate_d.SyncAggregate) -> {FuluSyncAggregate_e.SyncAggregate_valid(o) == VD.root_valid(RN.v_SyncAggregate(o), Spec.SyncAggregate()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SyncAggregate(o), S.Container{["sync_committee_bits", "sync_committee_signature"], S.Chain{S.BitVector{512n}, S.Chain{S.ByteVector{96n}, S.End{}}}}), True{}, rv_SyncAggregate(o)) : {FuluSyncAggregate_e.SyncAggregate_valid(o) == _ : Bool}
  {==}

# SyncAggregatorSelectionData: every object is valid, as its generated validity says.
def SyncAggregatorSelectionData_valid_agrees(+o: FuluSyncAggregatorSelectionData_d.SyncAggregatorSelectionData) -> {FuluSyncAggregatorSelectionData_e.SyncAggregatorSelectionData_valid(o) == VD.root_valid(RN.v_SyncAggregatorSelectionData(o), Spec.SyncAggregatorSelectionData()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SyncAggregatorSelectionData(o), S.Container{["slot", "subcommittee_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}), True{}, rv_SyncAggregatorSelectionData(o)) : {FuluSyncAggregatorSelectionData_e.SyncAggregatorSelectionData_valid(o) == _ : Bool}
  {==}

# PowBlock: every object is valid, as its generated validity says.
def PowBlock_valid_agrees(+o: FuluPowBlock_d.PowBlock) -> {FuluPowBlock_e.PowBlock_valid(o) == VD.root_valid(RN.v_PowBlock(o), Spec.PowBlock()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_PowBlock(o), S.Container{["block_hash", "parent_hash", "total_difficulty"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U256{}}, S.End{}}}}}), True{}, rv_PowBlock(o)) : {FuluPowBlock_e.PowBlock_valid(o) == _ : Bool}
  {==}

# CommitteeIndex: every object is valid, as its generated validity says.
def CommitteeIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.CommitteeIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# ValidatorIndex: every object is valid, as its generated validity says.
def ValidatorIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.ValidatorIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# PendingConsolidation: every object is valid, as its generated validity says.
def PendingConsolidation_valid_agrees(+o: FuluPendingConsolidation_d.PendingConsolidation) -> {FuluPendingConsolidation_e.PendingConsolidation_valid(o) == VD.root_valid(RN.v_PendingConsolidation(o), Spec.PendingConsolidation()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_PendingConsolidation(o), S.Container{["source_index", "target_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}), True{}, rv_PendingConsolidation(o)) : {FuluPendingConsolidation_e.PendingConsolidation_valid(o) == _ : Bool}
  {==}

# PendingPartialWithdrawal: every object is valid, as its generated validity says.
def PendingPartialWithdrawal_valid_agrees(+o: FuluPendingPartialWithdrawal_d.PendingPartialWithdrawal) -> {FuluPendingPartialWithdrawal_e.PendingPartialWithdrawal_valid(o) == VD.root_valid(RN.v_PendingPartialWithdrawal(o), Spec.PendingPartialWithdrawal()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_PendingPartialWithdrawal(o), S.Container{["validator_index", "amount", "withdrawable_epoch"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}), True{}, rv_PendingPartialWithdrawal(o)) : {FuluPendingPartialWithdrawal_e.PendingPartialWithdrawal_valid(o) == _ : Bool}
  {==}

# VoluntaryExit: every object is valid, as its generated validity says.
def VoluntaryExit_valid_agrees(+o: FuluVoluntaryExit_d.VoluntaryExit) -> {FuluVoluntaryExit_e.VoluntaryExit_valid(o) == VD.root_valid(RN.v_VoluntaryExit(o), Spec.VoluntaryExit()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_VoluntaryExit(o), S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}), True{}, rv_VoluntaryExit(o)) : {FuluVoluntaryExit_e.VoluntaryExit_valid(o) == _ : Bool}
  {==}

# SignedVoluntaryExit: every object is valid, as its generated validity says.
def SignedVoluntaryExit_valid_agrees(+o: FuluSignedVoluntaryExit_d.SignedVoluntaryExit) -> {FuluSignedVoluntaryExit_e.SignedVoluntaryExit_valid(o) == VD.root_valid(RN.v_SignedVoluntaryExit(o), Spec.SignedVoluntaryExit()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SignedVoluntaryExit(o), S.Container{["message", "signature"], S.Chain{S.Container{["epoch", "validator_index"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}), True{}, rv_SignedVoluntaryExit(o)) : {FuluSignedVoluntaryExit_e.SignedVoluntaryExit_valid(o) == _ : Bool}
  {==}

# Root: every object is valid, as its generated validity says.
def Root_valid_agrees(+o: FuluBytes32_d.Bytes32) -> {FuluBytes32_e.b32_valid(o) == VD.root_valid(RN.v_b32(o), Spec.Root()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b32(o), S.ByteVector{32n}), True{}, rv_b32(o)) : {FuluBytes32_e.b32_valid(o) == _ : Bool}
  {==}

# HistoricalSummary: every object is valid, as its generated validity says.
def HistoricalSummary_valid_agrees(+o: FuluHistoricalSummary_d.HistoricalSummary) -> {FuluHistoricalSummary_e.HistoricalSummary_valid(o) == VD.root_valid(RN.v_HistoricalSummary(o), Spec.HistoricalSummary()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_HistoricalSummary(o), S.Container{["block_summary_root", "state_summary_root"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}), True{}, rv_HistoricalSummary(o)) : {FuluHistoricalSummary_e.HistoricalSummary_valid(o) == _ : Bool}
  {==}

# SyncCommitteeContribution: every object is valid, as its generated validity says.
def SyncCommitteeContribution_valid_agrees(+o: FuluSyncCommitteeContribution_d.SyncCommitteeContribution) -> {FuluSyncCommitteeContribution_e.SyncCommitteeContribution_valid(o) == VD.root_valid(RN.v_SyncCommitteeContribution(o), Spec.SyncCommitteeContribution()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SyncCommitteeContribution(o), S.Container{["slot", "beacon_block_root", "subcommittee_index", "aggregation_bits", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.BitVector{128n}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}}), True{}, rv_SyncCommitteeContribution(o)) : {FuluSyncCommitteeContribution_e.SyncCommitteeContribution_valid(o) == _ : Bool}
  {==}

# SyncCommitteeMessage: every object is valid, as its generated validity says.
def SyncCommitteeMessage_valid_agrees(+o: FuluSyncCommitteeMessage_d.SyncCommitteeMessage) -> {FuluSyncCommitteeMessage_e.SyncCommitteeMessage_valid(o) == VD.root_valid(RN.v_SyncCommitteeMessage(o), Spec.SyncCommitteeMessage()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SyncCommitteeMessage(o), S.Container{["slot", "beacon_block_root", "validator_index", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}), True{}, rv_SyncCommitteeMessage(o)) : {FuluSyncCommitteeMessage_e.SyncCommitteeMessage_valid(o) == _ : Bool}
  {==}

# Eth1Block: every object is valid, as its generated validity says.
def Eth1Block_valid_agrees(+o: FuluEth1Block_d.Eth1Block) -> {FuluEth1Block_e.Eth1Block_valid(o) == VD.root_valid(RN.v_Eth1Block(o), Spec.Eth1Block()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_Eth1Block(o), S.Container{["timestamp", "deposit_root", "deposit_count"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}), True{}, rv_Eth1Block(o)) : {FuluEth1Block_e.Eth1Block_valid(o) == _ : Bool}
  {==}

# BeaconBlockHeader: every object is valid, as its generated validity says.
def BeaconBlockHeader_valid_agrees(+o: FuluBeaconBlockHeader_d.BeaconBlockHeader) -> {FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o) == VD.root_valid(RN.v_BeaconBlockHeader(o), Spec.BeaconBlockHeader()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_BeaconBlockHeader(o), S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}), True{}, rv_BeaconBlockHeader(o)) : {FuluBeaconBlockHeader_e.BeaconBlockHeader_valid(o) == _ : Bool}
  {==}

# SignedBeaconBlockHeader: every object is valid, as its generated validity says.
def SignedBeaconBlockHeader_valid_agrees(+o: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader) -> {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o) == VD.root_valid(RN.v_SignedBeaconBlockHeader(o), Spec.SignedBeaconBlockHeader()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SignedBeaconBlockHeader(o), S.Container{["message", "signature"], S.Chain{S.Container{["slot", "proposer_index", "parent_root", "state_root", "body_root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}), True{}, rv_SignedBeaconBlockHeader(o)) : {FuluSignedBeaconBlockHeader_e.SignedBeaconBlockHeader_valid(o) == _ : Bool}
  {==}

# Eth1Data: every object is valid, as its generated validity says.
def Eth1Data_valid_agrees(+o: FuluEth1Data_d.Eth1Data) -> {FuluEth1Data_e.Eth1Data_valid(o) == VD.root_valid(RN.v_Eth1Data(o), Spec.Eth1Data()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_Eth1Data(o), S.Container{["deposit_root", "deposit_count", "block_hash"], S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}}), True{}, rv_Eth1Data(o)) : {FuluEth1Data_e.Eth1Data_valid(o) == _ : Bool}
  {==}

# Checkpoint: every object is valid, as its generated validity says.
def Checkpoint_valid_agrees(+o: FuluCheckpoint_d.Checkpoint) -> {FuluCheckpoint_e.Checkpoint_valid(o) == VD.root_valid(RN.v_Checkpoint(o), Spec.Checkpoint()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_Checkpoint(o), S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}), True{}, rv_Checkpoint(o)) : {FuluCheckpoint_e.Checkpoint_valid(o) == _ : Bool}
  {==}

# AttestationData: every object is valid, as its generated validity says.
def AttestationData_valid_agrees(+o: FuluAttestationData_d.AttestationData) -> {FuluAttestationData_e.AttestationData_valid(o) == VD.root_valid(RN.v_AttestationData(o), Spec.AttestationData()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_AttestationData(o), S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}), True{}, rv_AttestationData(o)) : {FuluAttestationData_e.AttestationData_valid(o) == _ : Bool}
  {==}

# SingleAttestation: every object is valid, as its generated validity says.
def SingleAttestation_valid_agrees(+o: FuluSingleAttestation_d.SingleAttestation) -> {FuluSingleAttestation_e.SingleAttestation_valid(o) == VD.root_valid(RN.v_SingleAttestation(o), Spec.SingleAttestation()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SingleAttestation(o), S.Container{["committee_index", "attester_index", "data", "signature"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Container{["slot", "index", "beacon_block_root", "source", "target"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.Chain{S.Container{["epoch", "root"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{32n}, S.End{}}}}, S.End{}}}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}), True{}, rv_SingleAttestation(o)) : {FuluSingleAttestation_e.SingleAttestation_valid(o) == _ : Bool}
  {==}

# ForkData: every object is valid, as its generated validity says.
def ForkData_valid_agrees(+o: FuluForkData_d.ForkData) -> {FuluForkData_e.ForkData_valid(o) == VD.root_valid(RN.v_ForkData(o), Spec.ForkData()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_ForkData(o), S.Container{["current_version", "genesis_validators_root"], S.Chain{S.ByteVector{4n}, S.Chain{S.ByteVector{32n}, S.End{}}}}), True{}, rv_ForkData(o)) : {FuluForkData_e.ForkData_valid(o) == _ : Bool}
  {==}

# ForkDigest: every object is valid, as its generated validity says.
def ForkDigest_valid_agrees(+o: FuluBytes4_d.Bytes4) -> {FuluBytes4_e.b4_valid(o) == VD.root_valid(RN.v_b4(o), Spec.ForkDigest()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b4(o), S.ByteVector{4n}), True{}, rv_b4(o)) : {FuluBytes4_e.b4_valid(o) == _ : Bool}
  {==}

# Domain: every object is valid, as its generated validity says.
def Domain_valid_agrees(+o: FuluBytes32_d.Bytes32) -> {FuluBytes32_e.b32_valid(o) == VD.root_valid(RN.v_b32(o), Spec.Domain()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b32(o), S.ByteVector{32n}), True{}, rv_b32(o)) : {FuluBytes32_e.b32_valid(o) == _ : Bool}
  {==}

# SigningData: every object is valid, as its generated validity says.
def SigningData_valid_agrees(+o: FuluSigningData_d.SigningData) -> {FuluSigningData_e.SigningData_valid(o) == VD.root_valid(RN.v_SigningData(o), Spec.SigningData()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SigningData(o), S.Container{["object_root", "domain"], S.Chain{S.ByteVector{32n}, S.Chain{S.ByteVector{32n}, S.End{}}}}), True{}, rv_SigningData(o)) : {FuluSigningData_e.SigningData_valid(o) == _ : Bool}
  {==}

# BLSPubkey: every object is valid, as its generated validity says.
def BLSPubkey_valid_agrees(+o: FuluBytes48_d.Bytes48) -> {FuluBytes48_e.b48_valid(o) == VD.root_valid(RN.v_b48(o), Spec.BLSPubkey()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b48(o), S.ByteVector{48n}), True{}, rv_b48(o)) : {FuluBytes48_e.b48_valid(o) == _ : Bool}
  {==}

# DepositRequest: every object is valid, as its generated validity says.
def DepositRequest_valid_agrees(+o: FuluDepositRequest_d.DepositRequest) -> {FuluDepositRequest_e.DepositRequest_valid(o) == VD.root_valid(RN.v_DepositRequest(o), Spec.DepositRequest()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_DepositRequest(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "index"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}), True{}, rv_DepositRequest(o)) : {FuluDepositRequest_e.DepositRequest_valid(o) == _ : Bool}
  {==}

# PendingDeposit: every object is valid, as its generated validity says.
def PendingDeposit_valid_agrees(+o: FuluPendingDeposit_d.PendingDeposit) -> {FuluPendingDeposit_e.PendingDeposit_valid(o) == VD.root_valid(RN.v_PendingDeposit(o), Spec.PendingDeposit()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_PendingDeposit(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature", "slot"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}), True{}, rv_PendingDeposit(o)) : {FuluPendingDeposit_e.PendingDeposit_valid(o) == _ : Bool}
  {==}

# DepositData: every object is valid, as its generated validity says.
def DepositData_valid_agrees(+o: FuluDepositData_d.DepositData) -> {FuluDepositData_e.DepositData_valid(o) == VD.root_valid(RN.v_DepositData(o), Spec.DepositData()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_DepositData(o), S.Container{["pubkey", "withdrawal_credentials", "amount", "signature"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{96n}, S.End{}}}}}}), True{}, rv_DepositData(o)) : {FuluDepositData_e.DepositData_valid(o) == _ : Bool}
  {==}

# DepositMessage: every object is valid, as its generated validity says.
def DepositMessage_valid_agrees(+o: FuluDepositMessage_d.DepositMessage) -> {FuluDepositMessage_e.DepositMessage_valid(o) == VD.root_valid(RN.v_DepositMessage(o), Spec.DepositMessage()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_DepositMessage(o), S.Container{["pubkey", "withdrawal_credentials", "amount"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}), True{}, rv_DepositMessage(o)) : {FuluDepositMessage_e.DepositMessage_valid(o) == _ : Bool}
  {==}

# Validator: every object is valid, as its generated validity says.
def Validator_valid_agrees(+o: FuluValidator_d.Validator) -> {FuluValidator_e.Validator_valid(o) == VD.root_valid(RN.v_Validator(o), Spec.Validator()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_Validator(o), S.Container{["pubkey", "withdrawal_credentials", "effective_balance", "slashed", "activation_eligibility_epoch", "activation_epoch", "exit_epoch", "withdrawable_epoch"], S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Boolean{}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}}}}}), True{}, rv_Validator(o)) : {FuluValidator_e.Validator_valid(o) == _ : Bool}
  {==}

# NodeID: every object is valid, as its generated validity says.
def NodeID_valid_agrees(+o: uint256_d.Uint256) -> {uint256_e.u256_valid(o) == VD.root_valid(RN.v_u256(o), Spec.NodeID()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u256(o), S.Unsigned{P.U256{}}), True{}, rv_u256(o)) : {uint256_e.u256_valid(o) == _ : Bool}
  {==}

# SubnetID: every object is valid, as its generated validity says.
def SubnetID_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.SubnetID()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# Ether: every object is valid, as its generated validity says.
def Ether_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.Ether()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# ExecutionAddress: every object is valid, as its generated validity says.
def ExecutionAddress_valid_agrees(+o: FuluBytes20_d.Bytes20) -> {FuluBytes20_e.b20_valid(o) == VD.root_valid(RN.v_b20(o), Spec.ExecutionAddress()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b20(o), S.ByteVector{20n}), True{}, rv_b20(o)) : {FuluBytes20_e.b20_valid(o) == _ : Bool}
  {==}

# ConsolidationRequest: every object is valid, as its generated validity says.
def ConsolidationRequest_valid_agrees(+o: FuluConsolidationRequest_d.ConsolidationRequest) -> {FuluConsolidationRequest_e.ConsolidationRequest_valid(o) == VD.root_valid(RN.v_ConsolidationRequest(o), Spec.ConsolidationRequest()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_ConsolidationRequest(o), S.Container{["source_address", "source_pubkey", "target_pubkey"], S.Chain{S.ByteVector{20n}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{48n}, S.End{}}}}}), True{}, rv_ConsolidationRequest(o)) : {FuluConsolidationRequest_e.ConsolidationRequest_valid(o) == _ : Bool}
  {==}

# WithdrawalRequest: every object is valid, as its generated validity says.
def WithdrawalRequest_valid_agrees(+o: FuluWithdrawalRequest_d.WithdrawalRequest) -> {FuluWithdrawalRequest_e.WithdrawalRequest_valid(o) == VD.root_valid(RN.v_WithdrawalRequest(o), Spec.WithdrawalRequest()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_WithdrawalRequest(o), S.Container{["source_address", "validator_pubkey", "amount"], S.Chain{S.ByteVector{20n}, S.Chain{S.ByteVector{48n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}), True{}, rv_WithdrawalRequest(o)) : {FuluWithdrawalRequest_e.WithdrawalRequest_valid(o) == _ : Bool}
  {==}

# BLSToExecutionChange: every object is valid, as its generated validity says.
def BLSToExecutionChange_valid_agrees(+o: FuluBLSToExecutionChange_d.BLSToExecutionChange) -> {FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o) == VD.root_valid(RN.v_BLSToExecutionChange(o), Spec.BLSToExecutionChange()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_BLSToExecutionChange(o), S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}), True{}, rv_BLSToExecutionChange(o)) : {FuluBLSToExecutionChange_e.BLSToExecutionChange_valid(o) == _ : Bool}
  {==}

# SignedBLSToExecutionChange: every object is valid, as its generated validity says.
def SignedBLSToExecutionChange_valid_agrees(+o: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange) -> {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o) == VD.root_valid(RN.v_SignedBLSToExecutionChange(o), Spec.SignedBLSToExecutionChange()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_SignedBLSToExecutionChange(o), S.Container{["message", "signature"], S.Chain{S.Container{["validator_index", "from_bls_pubkey", "to_execution_address"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{48n}, S.Chain{S.ByteVector{20n}, S.End{}}}}}, S.Chain{S.ByteVector{96n}, S.End{}}}}), True{}, rv_SignedBLSToExecutionChange(o)) : {FuluSignedBLSToExecutionChange_e.SignedBLSToExecutionChange_valid(o) == _ : Bool}
  {==}

# PayloadId: every object is valid, as its generated validity says.
def PayloadId_valid_agrees(+o: FuluBytes8_d.Bytes8) -> {FuluBytes8_e.b8_valid(o) == VD.root_valid(RN.v_b8(o), Spec.PayloadId()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b8(o), S.ByteVector{8n}), True{}, rv_b8(o)) : {FuluBytes8_e.b8_valid(o) == _ : Bool}
  {==}

# WithdrawalIndex: every object is valid, as its generated validity says.
def WithdrawalIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.WithdrawalIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# Withdrawal: every object is valid, as its generated validity says.
def Withdrawal_valid_agrees(+o: FuluWithdrawal_d.Withdrawal) -> {FuluWithdrawal_e.Withdrawal_valid(o) == VD.root_valid(RN.v_Withdrawal(o), Spec.Withdrawal()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_Withdrawal(o), S.Container{["index", "validator_index", "address", "amount"], S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.Unsigned{P.U64{}}, S.Chain{S.ByteVector{20n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}}}), True{}, rv_Withdrawal(o)) : {FuluWithdrawal_e.Withdrawal_valid(o) == _ : Bool}
  {==}

# BlobIndex: every object is valid, as its generated validity says.
def BlobIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.BlobIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# BlobIdentifier: every object is valid, as its generated validity says.
def BlobIdentifier_valid_agrees(+o: FuluBlobIdentifier_d.BlobIdentifier) -> {FuluBlobIdentifier_e.BlobIdentifier_valid(o) == VD.root_valid(RN.v_BlobIdentifier(o), Spec.BlobIdentifier()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_BlobIdentifier(o), S.Container{["block_root", "index"], S.Chain{S.ByteVector{32n}, S.Chain{S.Unsigned{P.U64{}}, S.End{}}}}), True{}, rv_BlobIdentifier(o)) : {FuluBlobIdentifier_e.BlobIdentifier_valid(o) == _ : Bool}
  {==}

# KZGCommitment: every object is valid, as its generated validity says.
def KZGCommitment_valid_agrees(+o: FuluBytes48_d.Bytes48) -> {FuluBytes48_e.b48_valid(o) == VD.root_valid(RN.v_b48(o), Spec.KZGCommitment()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b48(o), S.ByteVector{48n}), True{}, rv_b48(o)) : {FuluBytes48_e.b48_valid(o) == _ : Bool}
  {==}

# KZGProof: every object is valid, as its generated validity says.
def KZGProof_valid_agrees(+o: FuluBytes48_d.Bytes48) -> {FuluBytes48_e.b48_valid(o) == VD.root_valid(RN.v_b48(o), Spec.KZGProof()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_b48(o), S.ByteVector{48n}), True{}, rv_b48(o)) : {FuluBytes48_e.b48_valid(o) == _ : Bool}
  {==}

# CellIndex: every object is valid, as its generated validity says.
def CellIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.CellIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# CommitmentIndex: every object is valid, as its generated validity says.
def CommitmentIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.CommitmentIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# RowIndex: every object is valid, as its generated validity says.
def RowIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.RowIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# ColumnIndex: every object is valid, as its generated validity says.
def ColumnIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.ColumnIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

# CustodyIndex: every object is valid, as its generated validity says.
def CustodyIndex_valid_agrees(+o: O.U64) -> {uint64_e.u64_valid(o) == VD.root_valid(RN.v_u64(o), Spec.CustodyIndex()) : Bool}:
  %Equal.sym(Bool, VD.root_valid(RN.v_u64(o), S.Unsigned{P.U64{}}), True{}, rv_u64(o)) : {uint64_e.u64_valid(o) == _ : Bool}
  {==}

