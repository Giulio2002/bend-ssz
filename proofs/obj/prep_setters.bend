import Base
import ../compact/found.bend as F
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/uint256_def_generated.bend as uint256_d
import ../../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
import ../../types/FuluSyncCommitteeContribution_def_generated.bend as FuluSyncCommitteeContribution_d
import ../../types/FuluContributionAndProof_def_generated.bend as FuluContributionAndProof_d
import ../../types/FuluSignedContributionAndProof_def_generated.bend as FuluSignedContributionAndProof_d
import ../../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
import ../../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
import ../../types/FuluProposerSlashing_def_generated.bend as FuluProposerSlashing_d
import ../../types/FuluHistoricalBatch_def_generated.bend as FuluHistoricalBatch_d
import ../../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
import ../../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
import ../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../types/FuluAggregateAndProof_def_generated.bend as FuluAggregateAndProof_d
import ../../types/FuluSignedAggregateAndProof_def_generated.bend as FuluSignedAggregateAndProof_d
import ../../types/FuluPendingAttestation_def_generated.bend as FuluPendingAttestation_d
import ../../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ../../types/FuluSyncCommittee_def_generated.bend as FuluSyncCommittee_d
import ../../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../../types/FuluDeposit_def_generated.bend as FuluDeposit_d
import ../../types/Fulu_list_DepositRequest_8192_def_generated.bend as Fulu_list_DepositRequest_8192_d
import ../../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as Fulu_list_WithdrawalRequest_16_d
import ../../types/Fulu_list_ConsolidationRequest_2_def_generated.bend as Fulu_list_ConsolidationRequest_2_d
import ../../types/FuluExecutionRequests_def_generated.bend as FuluExecutionRequests_d
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as Fulu_list_bytelist_1073741824_1048576_d
import ../../types/Fulu_list_Withdrawal_16_def_generated.bend as Fulu_list_Withdrawal_16_d
import ../../types/FuluExecutionPayload_def_generated.bend as FuluExecutionPayload_d
import ../../types/FuluLightClientHeader_def_generated.bend as FuluLightClientHeader_d
import ../../types/FuluLightClientOptimisticUpdate_def_generated.bend as FuluLightClientOptimisticUpdate_d
import ../../types/FuluLightClientFinalityUpdate_def_generated.bend as FuluLightClientFinalityUpdate_d
import ../../types/FuluLightClientUpdate_def_generated.bend as FuluLightClientUpdate_d
import ../../types/FuluLightClientBootstrap_def_generated.bend as FuluLightClientBootstrap_d
import ../../types/Fulu_list_ProposerSlashing_16_def_generated.bend as Fulu_list_ProposerSlashing_16_d
import ../../types/Fulu_list_AttesterSlashing_1_def_generated.bend as Fulu_list_AttesterSlashing_1_d
import ../../types/Fulu_list_Attestation_8_def_generated.bend as Fulu_list_Attestation_8_d
import ../../types/Fulu_list_Deposit_16_def_generated.bend as Fulu_list_Deposit_16_d
import ../../types/Fulu_list_SignedVoluntaryExit_16_def_generated.bend as Fulu_list_SignedVoluntaryExit_16_d
import ../../types/Fulu_list_SignedBLSToExecutionChange_16_def_generated.bend as Fulu_list_SignedBLSToExecutionChange_16_d
import ../../types/FuluBeaconBlockBody_def_generated.bend as FuluBeaconBlockBody_d
import ../../types/FuluBeaconBlock_def_generated.bend as FuluBeaconBlock_d
import ../../types/FuluSignedBeaconBlock_def_generated.bend as FuluSignedBeaconBlock_d
import ../../types/FuluBlobSidecar_def_generated.bend as FuluBlobSidecar_d
import ../../types/FuluDataColumnsByRootIdentifier_def_generated.bend as FuluDataColumnsByRootIdentifier_d
import ../../types/FuluMatrixEntry_def_generated.bend as FuluMatrixEntry_d
import ../../types/FuluDataColumnSidecar_def_generated.bend as FuluDataColumnSidecar_d
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ./amap.bend as AM
import ../../spec/root_relation.bend as RR
import ../../spec/fulu_schemas.bend as Spec
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./words_obj_light.bend as WO
import ./list_obj.bend as LO
import ./pv_obj.bend as PV
import ./bitlist_obj.bend as BO
import ./cells.bend as CE
import ./obj_support.bend as OS
import ./ulist_obj.bend as UL
import ./elems48.bend as E48
import ./xlist_support.bend as XS
import ./mtree_run.bend as MR
import ../../spec/codec.bend as Codec
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../spec/byte_list.bend as BL
import ./root_types.bend as RT

# GENERATED by codegen/rep_laws.py. Do not edit.
# Every field setter of the Type-kind containers keeps their representation
# invariant rep_<X> (root_types.bend), the hypothesis of their root laws: from
# rep_X(o, s) and, for a field with its own invariant, that invariant of the new
# value, rep_X(set_f(o, v), s) holds with field f replaced and the rest unchanged.

law ContributionAndProof_set_aggregator_index_rep:
  for -o: FuluContributionAndProof_d.ContributionAndProof
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ContributionAndProof(o, s)
  RT.rep_ContributionAndProof(FuluContributionAndProof_d.ContributionAndProof_set_aggregator_index(o, v), s)
def ContributionAndProof_set_aggregator_index_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+eo, +q1) = e1
  %Equal.sym(FuluContributionAndProof_d.ContributionAndProof, o, FuluContributionAndProof_d.ContributionAndProof{x0, RT.pj_ContributionAndProof_1(o), x2}, eo) : RT.rep_ContributionAndProof(FuluContributionAndProof_d.ContributionAndProof_set_aggregator_index(_, v), s)
  (v, (x2, ({==}, q1)))

law ContributionAndProof_set_contribution_rep:
  for -o: FuluContributionAndProof_d.ContributionAndProof
  for +s: S.Schema
  for -v: O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution>
  for +r: RT.rep_ContributionAndProof(o, s)
  for +rv: RT.rep_SyncCommitteeContribution_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_ContributionAndProof(FuluContributionAndProof_d.ContributionAndProof_set_contribution(o, v), s)
def ContributionAndProof_set_contribution_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+eo, +q1) = e1
  %Equal.sym(FuluContributionAndProof_d.ContributionAndProof, o, FuluContributionAndProof_d.ContributionAndProof{x0, RT.pj_ContributionAndProof_1(o), x2}, eo) : RT.rep_ContributionAndProof(FuluContributionAndProof_d.ContributionAndProof_set_contribution(_, v), s)
  (x0, (x2, ({==}, rv)))

law ContributionAndProof_set_selection_proof_rep:
  for -o: FuluContributionAndProof_d.ContributionAndProof
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_ContributionAndProof(o, s)
  RT.rep_ContributionAndProof(FuluContributionAndProof_d.ContributionAndProof_set_selection_proof(o, v), s)
def ContributionAndProof_set_selection_proof_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+eo, +q1) = e1
  %Equal.sym(FuluContributionAndProof_d.ContributionAndProof, o, FuluContributionAndProof_d.ContributionAndProof{x0, RT.pj_ContributionAndProof_1(o), x2}, eo) : RT.rep_ContributionAndProof(FuluContributionAndProof_d.ContributionAndProof_set_selection_proof(_, v), s)
  (x0, (v, ({==}, q1)))

law SignedContributionAndProof_set_message_rep:
  for -o: FuluSignedContributionAndProof_d.SignedContributionAndProof
  for +s: S.Schema
  for -v: FuluContributionAndProof_d.ContributionAndProof
  for +r: RT.rep_SignedContributionAndProof(o, s)
  for +rv: RT.rep_ContributionAndProof(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_SignedContributionAndProof(FuluSignedContributionAndProof_d.SignedContributionAndProof_set_message(o, v), s)
def SignedContributionAndProof_set_message_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSignedContributionAndProof_d.SignedContributionAndProof, o, FuluSignedContributionAndProof_d.SignedContributionAndProof{RT.pj_SignedContributionAndProof_0(o), x1}, eo) : RT.rep_SignedContributionAndProof(FuluSignedContributionAndProof_d.SignedContributionAndProof_set_message(_, v), s)
  (x1, ({==}, rv))

law SignedContributionAndProof_set_signature_rep:
  for -o: FuluSignedContributionAndProof_d.SignedContributionAndProof
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_SignedContributionAndProof(o, s)
  RT.rep_SignedContributionAndProof(FuluSignedContributionAndProof_d.SignedContributionAndProof_set_signature(o, v), s)
def SignedContributionAndProof_set_signature_rep(o, s, v, r):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSignedContributionAndProof_d.SignedContributionAndProof, o, FuluSignedContributionAndProof_d.SignedContributionAndProof{RT.pj_SignedContributionAndProof_0(o), x1}, eo) : RT.rep_SignedContributionAndProof(FuluSignedContributionAndProof_d.SignedContributionAndProof_set_signature(_, v), s)
  (v, ({==}, q0))

law ProposerSlashing_set_signed_header_1_rep:
  for -o: FuluProposerSlashing_d.ProposerSlashing
  for +s: S.Schema
  for -v: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>
  for +r: RT.rep_ProposerSlashing(o, s)
  for +rv: RT.rep_SignedBeaconBlockHeader_bx(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_ProposerSlashing(FuluProposerSlashing_d.ProposerSlashing_set_signed_header_1(o, v), s)
def ProposerSlashing_set_signed_header_1_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluProposerSlashing_d.ProposerSlashing, o, FuluProposerSlashing_d.ProposerSlashing{RT.pj_ProposerSlashing_0(o), RT.pj_ProposerSlashing_1(o)}, eo) : RT.rep_ProposerSlashing(FuluProposerSlashing_d.ProposerSlashing_set_signed_header_1(_, v), s)
  ({==}, (rv, q1))

law ProposerSlashing_set_signed_header_2_rep:
  for -o: FuluProposerSlashing_d.ProposerSlashing
  for +s: S.Schema
  for -v: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>
  for +r: RT.rep_ProposerSlashing(o, s)
  for +rv: RT.rep_SignedBeaconBlockHeader_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_ProposerSlashing(FuluProposerSlashing_d.ProposerSlashing_set_signed_header_2(o, v), s)
def ProposerSlashing_set_signed_header_2_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluProposerSlashing_d.ProposerSlashing, o, FuluProposerSlashing_d.ProposerSlashing{RT.pj_ProposerSlashing_0(o), RT.pj_ProposerSlashing_1(o)}, eo) : RT.rep_ProposerSlashing(FuluProposerSlashing_d.ProposerSlashing_set_signed_header_2(_, v), s)
  ({==}, (q0, rv))

law HistoricalBatch_set_block_roots_rep:
  for -o: FuluHistoricalBatch_d.HistoricalBatch
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_HistoricalBatch(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_HistoricalBatch(FuluHistoricalBatch_d.HistoricalBatch_set_block_roots(o, v), s)
def HistoricalBatch_set_block_roots_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluHistoricalBatch_d.HistoricalBatch, o, FuluHistoricalBatch_d.HistoricalBatch{RT.pj_HistoricalBatch_0(o), RT.pj_HistoricalBatch_1(o)}, eo) : RT.rep_HistoricalBatch(FuluHistoricalBatch_d.HistoricalBatch_set_block_roots(_, v), s)
  ({==}, (rv, q1))

law HistoricalBatch_set_state_roots_rep:
  for -o: FuluHistoricalBatch_d.HistoricalBatch
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_HistoricalBatch(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_HistoricalBatch(FuluHistoricalBatch_d.HistoricalBatch_set_state_roots(o, v), s)
def HistoricalBatch_set_state_roots_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluHistoricalBatch_d.HistoricalBatch, o, FuluHistoricalBatch_d.HistoricalBatch{RT.pj_HistoricalBatch_0(o), RT.pj_HistoricalBatch_1(o)}, eo) : RT.rep_HistoricalBatch(FuluHistoricalBatch_d.HistoricalBatch_set_state_roots(_, v), s)
  ({==}, (q0, rv))

law Attestation_set_aggregation_bits_rep:
  for -o: FuluAttestation_d.Attestation
  for +s: S.Schema
  for -v: O.Bits
  for +r: RT.rep_Attestation(o, s)
  for +rv: BO.rep_bits(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_Attestation(FuluAttestation_d.Attestation_set_aggregation_bits(o, v), s)
def Attestation_set_aggregation_bits_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluAttestation_d.Attestation, o, FuluAttestation_d.Attestation{RT.pj_Attestation_0(o), x1, x2, x3}, eo) : RT.rep_Attestation(FuluAttestation_d.Attestation_set_aggregation_bits(_, v), s)
  (x1, (x2, (x3, ({==}, rv))))

law Attestation_set_data_rep:
  for -o: FuluAttestation_d.Attestation
  for +s: S.Schema
  for +v: FuluAttestationData_d.AttestationData
  for +r: RT.rep_Attestation(o, s)
  RT.rep_Attestation(FuluAttestation_d.Attestation_set_data(o, v), s)
def Attestation_set_data_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluAttestation_d.Attestation, o, FuluAttestation_d.Attestation{RT.pj_Attestation_0(o), x1, x2, x3}, eo) : RT.rep_Attestation(FuluAttestation_d.Attestation_set_data(_, v), s)
  (v, (x2, (x3, ({==}, q0))))

law Attestation_set_signature_rep:
  for -o: FuluAttestation_d.Attestation
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_Attestation(o, s)
  RT.rep_Attestation(FuluAttestation_d.Attestation_set_signature(o, v), s)
def Attestation_set_signature_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluAttestation_d.Attestation, o, FuluAttestation_d.Attestation{RT.pj_Attestation_0(o), x1, x2, x3}, eo) : RT.rep_Attestation(FuluAttestation_d.Attestation_set_signature(_, v), s)
  (x1, (v, (x3, ({==}, q0))))

law Attestation_set_committee_bits_rep:
  for -o: FuluAttestation_d.Attestation
  for +s: S.Schema
  for +v: Fulu_bitvector_64_d.Bitvector64
  for +r: RT.rep_Attestation(o, s)
  RT.rep_Attestation(FuluAttestation_d.Attestation_set_committee_bits(o, v), s)
def Attestation_set_committee_bits_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluAttestation_d.Attestation, o, FuluAttestation_d.Attestation{RT.pj_Attestation_0(o), x1, x2, x3}, eo) : RT.rep_Attestation(FuluAttestation_d.Attestation_set_committee_bits(_, v), s)
  (x1, (x2, (v, ({==}, q0))))

law AggregateAndProof_set_aggregator_index_rep:
  for -o: FuluAggregateAndProof_d.AggregateAndProof
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_AggregateAndProof(o, s)
  RT.rep_AggregateAndProof(FuluAggregateAndProof_d.AggregateAndProof_set_aggregator_index(o, v), s)
def AggregateAndProof_set_aggregator_index_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+eo, +q1) = e1
  %Equal.sym(FuluAggregateAndProof_d.AggregateAndProof, o, FuluAggregateAndProof_d.AggregateAndProof{x0, RT.pj_AggregateAndProof_1(o), x2}, eo) : RT.rep_AggregateAndProof(FuluAggregateAndProof_d.AggregateAndProof_set_aggregator_index(_, v), s)
  (v, (x2, ({==}, q1)))

law AggregateAndProof_set_aggregate_rep:
  for -o: FuluAggregateAndProof_d.AggregateAndProof
  for +s: S.Schema
  for -v: O.Boxed<FuluAttestation_d.Attestation>
  for +r: RT.rep_AggregateAndProof(o, s)
  for +rv: RT.rep_Attestation_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_AggregateAndProof(FuluAggregateAndProof_d.AggregateAndProof_set_aggregate(o, v), s)
def AggregateAndProof_set_aggregate_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+eo, +q1) = e1
  %Equal.sym(FuluAggregateAndProof_d.AggregateAndProof, o, FuluAggregateAndProof_d.AggregateAndProof{x0, RT.pj_AggregateAndProof_1(o), x2}, eo) : RT.rep_AggregateAndProof(FuluAggregateAndProof_d.AggregateAndProof_set_aggregate(_, v), s)
  (x0, (x2, ({==}, rv)))

law AggregateAndProof_set_selection_proof_rep:
  for -o: FuluAggregateAndProof_d.AggregateAndProof
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_AggregateAndProof(o, s)
  RT.rep_AggregateAndProof(FuluAggregateAndProof_d.AggregateAndProof_set_selection_proof(o, v), s)
def AggregateAndProof_set_selection_proof_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+eo, +q1) = e1
  %Equal.sym(FuluAggregateAndProof_d.AggregateAndProof, o, FuluAggregateAndProof_d.AggregateAndProof{x0, RT.pj_AggregateAndProof_1(o), x2}, eo) : RT.rep_AggregateAndProof(FuluAggregateAndProof_d.AggregateAndProof_set_selection_proof(_, v), s)
  (x0, (v, ({==}, q1)))

law SignedAggregateAndProof_set_message_rep:
  for -o: FuluSignedAggregateAndProof_d.SignedAggregateAndProof
  for +s: S.Schema
  for -v: FuluAggregateAndProof_d.AggregateAndProof
  for +r: RT.rep_SignedAggregateAndProof(o, s)
  for +rv: RT.rep_AggregateAndProof(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_SignedAggregateAndProof(FuluSignedAggregateAndProof_d.SignedAggregateAndProof_set_message(o, v), s)
def SignedAggregateAndProof_set_message_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSignedAggregateAndProof_d.SignedAggregateAndProof, o, FuluSignedAggregateAndProof_d.SignedAggregateAndProof{RT.pj_SignedAggregateAndProof_0(o), x1}, eo) : RT.rep_SignedAggregateAndProof(FuluSignedAggregateAndProof_d.SignedAggregateAndProof_set_message(_, v), s)
  (x1, ({==}, rv))

law SignedAggregateAndProof_set_signature_rep:
  for -o: FuluSignedAggregateAndProof_d.SignedAggregateAndProof
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_SignedAggregateAndProof(o, s)
  RT.rep_SignedAggregateAndProof(FuluSignedAggregateAndProof_d.SignedAggregateAndProof_set_signature(o, v), s)
def SignedAggregateAndProof_set_signature_rep(o, s, v, r):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSignedAggregateAndProof_d.SignedAggregateAndProof, o, FuluSignedAggregateAndProof_d.SignedAggregateAndProof{RT.pj_SignedAggregateAndProof_0(o), x1}, eo) : RT.rep_SignedAggregateAndProof(FuluSignedAggregateAndProof_d.SignedAggregateAndProof_set_signature(_, v), s)
  (v, ({==}, q0))

law PendingAttestation_set_aggregation_bits_rep:
  for -o: FuluPendingAttestation_d.PendingAttestation
  for +s: S.Schema
  for -v: O.Bits
  for +r: RT.rep_PendingAttestation(o, s)
  for +rv: BO.rep_bits(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_aggregation_bits(o, v), s)
def PendingAttestation_set_aggregation_bits_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluPendingAttestation_d.PendingAttestation, o, FuluPendingAttestation_d.PendingAttestation{RT.pj_PendingAttestation_0(o), x1, x2, x3}, eo) : RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_aggregation_bits(_, v), s)
  (x1, (x2, (x3, ({==}, rv))))

law PendingAttestation_set_data_rep:
  for -o: FuluPendingAttestation_d.PendingAttestation
  for +s: S.Schema
  for +v: FuluAttestationData_d.AttestationData
  for +r: RT.rep_PendingAttestation(o, s)
  RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_data(o, v), s)
def PendingAttestation_set_data_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluPendingAttestation_d.PendingAttestation, o, FuluPendingAttestation_d.PendingAttestation{RT.pj_PendingAttestation_0(o), x1, x2, x3}, eo) : RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_data(_, v), s)
  (v, (x2, (x3, ({==}, q0))))

law PendingAttestation_set_inclusion_delay_rep:
  for -o: FuluPendingAttestation_d.PendingAttestation
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_PendingAttestation(o, s)
  RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_inclusion_delay(o, v), s)
def PendingAttestation_set_inclusion_delay_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluPendingAttestation_d.PendingAttestation, o, FuluPendingAttestation_d.PendingAttestation{RT.pj_PendingAttestation_0(o), x1, x2, x3}, eo) : RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_inclusion_delay(_, v), s)
  (x1, (v, (x3, ({==}, q0))))

law PendingAttestation_set_proposer_index_rep:
  for -o: FuluPendingAttestation_d.PendingAttestation
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_PendingAttestation(o, s)
  RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_proposer_index(o, v), s)
def PendingAttestation_set_proposer_index_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluPendingAttestation_d.PendingAttestation, o, FuluPendingAttestation_d.PendingAttestation{RT.pj_PendingAttestation_0(o), x1, x2, x3}, eo) : RT.rep_PendingAttestation(FuluPendingAttestation_d.PendingAttestation_set_proposer_index(_, v), s)
  (x1, (x2, (v, ({==}, q0))))

law IndexedAttestation_set_attesting_indices_rep:
  for -o: FuluIndexedAttestation_d.IndexedAttestation
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_IndexedAttestation(o, s)
  for +rv: UL.rep_ul(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_set_attesting_indices(o, v), s)
def IndexedAttestation_set_attesting_indices_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+eo, +q0) = e1
  %Equal.sym(FuluIndexedAttestation_d.IndexedAttestation, o, FuluIndexedAttestation_d.IndexedAttestation{RT.pj_IndexedAttestation_0(o), x1, x2}, eo) : RT.rep_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_set_attesting_indices(_, v), s)
  (x1, (x2, ({==}, rv)))

law IndexedAttestation_set_data_rep:
  for -o: FuluIndexedAttestation_d.IndexedAttestation
  for +s: S.Schema
  for +v: FuluAttestationData_d.AttestationData
  for +r: RT.rep_IndexedAttestation(o, s)
  RT.rep_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_set_data(o, v), s)
def IndexedAttestation_set_data_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+eo, +q0) = e1
  %Equal.sym(FuluIndexedAttestation_d.IndexedAttestation, o, FuluIndexedAttestation_d.IndexedAttestation{RT.pj_IndexedAttestation_0(o), x1, x2}, eo) : RT.rep_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_set_data(_, v), s)
  (v, (x2, ({==}, q0)))

law IndexedAttestation_set_signature_rep:
  for -o: FuluIndexedAttestation_d.IndexedAttestation
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_IndexedAttestation(o, s)
  RT.rep_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_set_signature(o, v), s)
def IndexedAttestation_set_signature_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+eo, +q0) = e1
  %Equal.sym(FuluIndexedAttestation_d.IndexedAttestation, o, FuluIndexedAttestation_d.IndexedAttestation{RT.pj_IndexedAttestation_0(o), x1, x2}, eo) : RT.rep_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_set_signature(_, v), s)
  (x1, (v, ({==}, q0)))

law AttesterSlashing_set_attestation_1_rep:
  for -o: FuluAttesterSlashing_d.AttesterSlashing
  for +s: S.Schema
  for -v: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>
  for +r: RT.rep_AttesterSlashing(o, s)
  for +rv: RT.rep_IndexedAttestation_bx(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_AttesterSlashing(FuluAttesterSlashing_d.AttesterSlashing_set_attestation_1(o, v), s)
def AttesterSlashing_set_attestation_1_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluAttesterSlashing_d.AttesterSlashing, o, FuluAttesterSlashing_d.AttesterSlashing{RT.pj_AttesterSlashing_0(o), RT.pj_AttesterSlashing_1(o)}, eo) : RT.rep_AttesterSlashing(FuluAttesterSlashing_d.AttesterSlashing_set_attestation_1(_, v), s)
  ({==}, (rv, q1))

law AttesterSlashing_set_attestation_2_rep:
  for -o: FuluAttesterSlashing_d.AttesterSlashing
  for +s: S.Schema
  for -v: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>
  for +r: RT.rep_AttesterSlashing(o, s)
  for +rv: RT.rep_IndexedAttestation_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_AttesterSlashing(FuluAttesterSlashing_d.AttesterSlashing_set_attestation_2(o, v), s)
def AttesterSlashing_set_attestation_2_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluAttesterSlashing_d.AttesterSlashing, o, FuluAttesterSlashing_d.AttesterSlashing{RT.pj_AttesterSlashing_0(o), RT.pj_AttesterSlashing_1(o)}, eo) : RT.rep_AttesterSlashing(FuluAttesterSlashing_d.AttesterSlashing_set_attestation_2(_, v), s)
  ({==}, (q0, rv))

law SyncCommittee_set_pubkeys_rep:
  for -o: FuluSyncCommittee_d.SyncCommittee
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_SyncCommittee(o, s)
  for +rv: E48.rep_ev(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_SyncCommittee(FuluSyncCommittee_d.SyncCommittee_set_pubkeys(o, v), s)
def SyncCommittee_set_pubkeys_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSyncCommittee_d.SyncCommittee, o, FuluSyncCommittee_d.SyncCommittee{RT.pj_SyncCommittee_0(o), x1}, eo) : RT.rep_SyncCommittee(FuluSyncCommittee_d.SyncCommittee_set_pubkeys(_, v), s)
  (x1, ({==}, rv))

law SyncCommittee_set_aggregate_pubkey_rep:
  for -o: FuluSyncCommittee_d.SyncCommittee
  for +s: S.Schema
  for +v: FuluBytes48_d.Bytes48
  for +r: RT.rep_SyncCommittee(o, s)
  RT.rep_SyncCommittee(FuluSyncCommittee_d.SyncCommittee_set_aggregate_pubkey(o, v), s)
def SyncCommittee_set_aggregate_pubkey_rep(o, s, v, r):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSyncCommittee_d.SyncCommittee, o, FuluSyncCommittee_d.SyncCommittee{RT.pj_SyncCommittee_0(o), x1}, eo) : RT.rep_SyncCommittee(FuluSyncCommittee_d.SyncCommittee_set_aggregate_pubkey(_, v), s)
  (v, ({==}, q0))

law Deposit_set_proof_rep:
  for -o: FuluDeposit_d.Deposit
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_Deposit(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_Deposit(FuluDeposit_d.Deposit_set_proof(o, v), s)
def Deposit_set_proof_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluDeposit_d.Deposit, o, FuluDeposit_d.Deposit{RT.pj_Deposit_0(o), RT.pj_Deposit_1(o)}, eo) : RT.rep_Deposit(FuluDeposit_d.Deposit_set_proof(_, v), s)
  ({==}, (rv, q1))

law Deposit_set_data_rep:
  for -o: FuluDeposit_d.Deposit
  for +s: S.Schema
  for -v: O.Boxed<FuluDepositData_d.DepositData>
  for +r: RT.rep_Deposit(o, s)
  for +rv: RT.rep_DepositData_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_Deposit(FuluDeposit_d.Deposit_set_data(o, v), s)
def Deposit_set_data_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, +q1) = c0
  %Equal.sym(FuluDeposit_d.Deposit, o, FuluDeposit_d.Deposit{RT.pj_Deposit_0(o), RT.pj_Deposit_1(o)}, eo) : RT.rep_Deposit(FuluDeposit_d.Deposit_set_data(_, v), s)
  ({==}, (q0, rv))

law ExecutionRequests_set_deposits_rep:
  for -o: FuluExecutionRequests_d.ExecutionRequests
  for +s: S.Schema
  for -v: Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq
  for +r: RT.rep_ExecutionRequests(o, s)
  for +rv: RT.rep_l8192_DepositRequest(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_ExecutionRequests(FuluExecutionRequests_d.ExecutionRequests_set_deposits(o, v), s)
def ExecutionRequests_set_deposits_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, c1) = c0
  (+q1, +q2) = c1
  %Equal.sym(FuluExecutionRequests_d.ExecutionRequests, o, FuluExecutionRequests_d.ExecutionRequests{RT.pj_ExecutionRequests_0(o), RT.pj_ExecutionRequests_1(o), RT.pj_ExecutionRequests_2(o)}, eo) : RT.rep_ExecutionRequests(FuluExecutionRequests_d.ExecutionRequests_set_deposits(_, v), s)
  ({==}, (rv, (q1, q2)))

law ExecutionRequests_set_withdrawals_rep:
  for -o: FuluExecutionRequests_d.ExecutionRequests
  for +s: S.Schema
  for -v: Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq
  for +r: RT.rep_ExecutionRequests(o, s)
  for +rv: RT.rep_l16_WithdrawalRequest(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_ExecutionRequests(FuluExecutionRequests_d.ExecutionRequests_set_withdrawals(o, v), s)
def ExecutionRequests_set_withdrawals_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, c1) = c0
  (+q1, +q2) = c1
  %Equal.sym(FuluExecutionRequests_d.ExecutionRequests, o, FuluExecutionRequests_d.ExecutionRequests{RT.pj_ExecutionRequests_0(o), RT.pj_ExecutionRequests_1(o), RT.pj_ExecutionRequests_2(o)}, eo) : RT.rep_ExecutionRequests(FuluExecutionRequests_d.ExecutionRequests_set_withdrawals(_, v), s)
  ({==}, (q0, (rv, q2)))

law ExecutionRequests_set_consolidations_rep:
  for -o: FuluExecutionRequests_d.ExecutionRequests
  for +s: S.Schema
  for -v: Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq
  for +r: RT.rep_ExecutionRequests(o, s)
  for +rv: RT.rep_l2_ConsolidationRequest(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))
  RT.rep_ExecutionRequests(FuluExecutionRequests_d.ExecutionRequests_set_consolidations(o, v), s)
def ExecutionRequests_set_consolidations_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, c1) = c0
  (+q1, +q2) = c1
  %Equal.sym(FuluExecutionRequests_d.ExecutionRequests, o, FuluExecutionRequests_d.ExecutionRequests{RT.pj_ExecutionRequests_0(o), RT.pj_ExecutionRequests_1(o), RT.pj_ExecutionRequests_2(o)}, eo) : RT.rep_ExecutionRequests(FuluExecutionRequests_d.ExecutionRequests_set_consolidations(_, v), s)
  ({==}, (q0, (q1, rv)))

law ExecutionPayloadHeader_set_parent_hash_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_parent_hash(o, v), s)
def ExecutionPayloadHeader_set_parent_hash_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_parent_hash(_, v), s)
  (v, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_fee_recipient_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes20_d.Bytes20
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_fee_recipient(o, v), s)
def ExecutionPayloadHeader_set_fee_recipient_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_fee_recipient(_, v), s)
  (x0, (v, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_state_root_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_state_root(o, v), s)
def ExecutionPayloadHeader_set_state_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_state_root(_, v), s)
  (x0, (x1, (v, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_receipts_root_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_receipts_root(o, v), s)
def ExecutionPayloadHeader_set_receipts_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_receipts_root(_, v), s)
  (x0, (x1, (x2, (v, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_logs_bloom_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  for +rv: WO.rep_bv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_logs_bloom(o, v), s)
def ExecutionPayloadHeader_set_logs_bloom_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_logs_bloom(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (rv, q10)))))))))))))))))

law ExecutionPayloadHeader_set_prev_randao_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_prev_randao(o, v), s)
def ExecutionPayloadHeader_set_prev_randao_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_prev_randao(_, v), s)
  (x0, (x1, (x2, (x3, (v, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_block_number_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_block_number(o, v), s)
def ExecutionPayloadHeader_set_block_number_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_block_number(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (v, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_gas_limit_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_gas_limit(o, v), s)
def ExecutionPayloadHeader_set_gas_limit_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_gas_limit(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (v, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_gas_used_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_gas_used(o, v), s)
def ExecutionPayloadHeader_set_gas_used_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_gas_used(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (v, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_timestamp_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_timestamp(o, v), s)
def ExecutionPayloadHeader_set_timestamp_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_timestamp(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (v, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_extra_data_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  for +rv: LO.rep_bl(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_extra_data(o, v), s)
def ExecutionPayloadHeader_set_extra_data_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_extra_data(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, rv)))))))))))))))))

law ExecutionPayloadHeader_set_base_fee_per_gas_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: uint256_d.Uint256
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_base_fee_per_gas(o, v), s)
def ExecutionPayloadHeader_set_base_fee_per_gas_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_base_fee_per_gas(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (v, (x12, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_block_hash_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_block_hash(o, v), s)
def ExecutionPayloadHeader_set_block_hash_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_block_hash(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (v, (x13, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_transactions_root_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_transactions_root(o, v), s)
def ExecutionPayloadHeader_set_transactions_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_transactions_root(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (v, (x14, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_withdrawals_root_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_withdrawals_root(o, v), s)
def ExecutionPayloadHeader_set_withdrawals_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_withdrawals_root(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (v, (x15, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_blob_gas_used_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_blob_gas_used(o, v), s)
def ExecutionPayloadHeader_set_blob_gas_used_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_blob_gas_used(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (v, (x16, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayloadHeader_set_excess_blob_gas_rep:
  for -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayloadHeader(o, s)
  RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_excess_blob_gas(o, v), s)
def ExecutionPayloadHeader_set_excess_blob_gas_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x13, e11) = e10
  (+x14, e12) = e11
  (+x15, e13) = e12
  (+x16, e14) = e13
  (+eo, c0) = e14
  (+q4, +q10) = c0
  %Equal.sym(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, o, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, RT.pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, RT.pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}}, eo) : RT.rep_ExecutionPayloadHeader(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_set_excess_blob_gas(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x13, (x14, (x15, (v, ({==}, (q4, q10)))))))))))))))))

law ExecutionPayload_set_parent_hash_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_parent_hash(o, v), s)
def ExecutionPayload_set_parent_hash_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_parent_hash(_, v), s)
  (v, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_fee_recipient_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: FuluBytes20_d.Bytes20
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_fee_recipient(o, v), s)
def ExecutionPayload_set_fee_recipient_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_fee_recipient(_, v), s)
  (x0, (v, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_state_root_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_state_root(o, v), s)
def ExecutionPayload_set_state_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_state_root(_, v), s)
  (x0, (x1, (v, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_receipts_root_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_receipts_root(o, v), s)
def ExecutionPayload_set_receipts_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_receipts_root(_, v), s)
  (x0, (x1, (x2, (v, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_logs_bloom_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_ExecutionPayload(o, s)
  for +rv: WO.rep_bv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_logs_bloom(o, v), s)
def ExecutionPayload_set_logs_bloom_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_logs_bloom(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (rv, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_prev_randao_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_prev_randao(o, v), s)
def ExecutionPayload_set_prev_randao_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_prev_randao(_, v), s)
  (x0, (x1, (x2, (x3, (v, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_block_number_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_block_number(o, v), s)
def ExecutionPayload_set_block_number_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_block_number(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (v, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_gas_limit_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_gas_limit(o, v), s)
def ExecutionPayload_set_gas_limit_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_gas_limit(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (v, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_gas_used_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_gas_used(o, v), s)
def ExecutionPayload_set_gas_used_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_gas_used(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (v, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_timestamp_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_timestamp(o, v), s)
def ExecutionPayload_set_timestamp_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_timestamp(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (v, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_extra_data_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_ExecutionPayload(o, s)
  for +rv: LO.rep_bl(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_extra_data(o, v), s)
def ExecutionPayload_set_extra_data_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_extra_data(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (rv, (q13, q14)))))))))))))))))

law ExecutionPayload_set_base_fee_per_gas_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: uint256_d.Uint256
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_base_fee_per_gas(o, v), s)
def ExecutionPayload_set_base_fee_per_gas_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_base_fee_per_gas(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (v, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_block_hash_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_block_hash(o, v), s)
def ExecutionPayload_set_block_hash_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_block_hash(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (v, (x15, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_transactions_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for -v: Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq
  for +r: RT.rep_ExecutionPayload(o, s)
  for +rv: RT.rep_l1048576_bl1073741824(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))))
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_transactions(o, v), s)
def ExecutionPayload_set_transactions_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_transactions(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (rv, q14)))))))))))))))))

law ExecutionPayload_set_withdrawals_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for -v: Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq
  for +r: RT.rep_ExecutionPayload(o, s)
  for +rv: RT.rep_l16_Withdrawal(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))))))
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_withdrawals(o, v), s)
def ExecutionPayload_set_withdrawals_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_withdrawals(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (x16, ({==}, (q4, (q10, (q13, rv)))))))))))))))))

law ExecutionPayload_set_blob_gas_used_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_blob_gas_used(o, v), s)
def ExecutionPayload_set_blob_gas_used_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_blob_gas_used(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (v, (x16, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law ExecutionPayload_set_excess_blob_gas_rep:
  for -o: FuluExecutionPayload_d.ExecutionPayload
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_ExecutionPayload(o, s)
  RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_excess_blob_gas(o, v), s)
def ExecutionPayload_set_excess_blob_gas_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+x5, e4) = e3
  (+x6, e5) = e4
  (+x7, e6) = e5
  (+x8, e7) = e6
  (+x9, e8) = e7
  (+x11, e9) = e8
  (+x12, e10) = e9
  (+x15, e11) = e10
  (+x16, e12) = e11
  (+eo, c0) = e12
  (+q4, c1) = c0
  (+q10, c2) = c1
  (+q13, +q14) = c2
  %Equal.sym(FuluExecutionPayload_d.ExecutionPayload, o, FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, RT.pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, RT.pj_ExecutionPayload_10(o), x11, x12, RT.pj_ExecutionPayload_13(o), RT.pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}}, eo) : RT.rep_ExecutionPayload(FuluExecutionPayload_d.ExecutionPayload_set_excess_blob_gas(_, v), s)
  (x0, (x1, (x2, (x3, (x5, (x6, (x7, (x8, (x9, (x11, (x12, (x15, (v, ({==}, (q4, (q10, (q13, q14)))))))))))))))))

law LightClientHeader_set_beacon_rep:
  for -o: FuluLightClientHeader_d.LightClientHeader
  for +s: S.Schema
  for +v: FuluBeaconBlockHeader_d.BeaconBlockHeader
  for +r: RT.rep_LightClientHeader(o, s)
  RT.rep_LightClientHeader(FuluLightClientHeader_d.LightClientHeader_set_beacon(o, v), s)
def LightClientHeader_set_beacon_rep(o, s, v, r):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, +q2) = c0
  %Equal.sym(FuluLightClientHeader_d.LightClientHeader, o, FuluLightClientHeader_d.LightClientHeader{x0, RT.pj_LightClientHeader_1(o), RT.pj_LightClientHeader_2(o)}, eo) : RT.rep_LightClientHeader(FuluLightClientHeader_d.LightClientHeader_set_beacon(_, v), s)
  (v, ({==}, (q1, q2)))

law LightClientHeader_set_execution_rep:
  for -o: FuluLightClientHeader_d.LightClientHeader
  for +s: S.Schema
  for -v: O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>
  for +r: RT.rep_LightClientHeader(o, s)
  for +rv: RT.rep_ExecutionPayloadHeader_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_LightClientHeader(FuluLightClientHeader_d.LightClientHeader_set_execution(o, v), s)
def LightClientHeader_set_execution_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, +q2) = c0
  %Equal.sym(FuluLightClientHeader_d.LightClientHeader, o, FuluLightClientHeader_d.LightClientHeader{x0, RT.pj_LightClientHeader_1(o), RT.pj_LightClientHeader_2(o)}, eo) : RT.rep_LightClientHeader(FuluLightClientHeader_d.LightClientHeader_set_execution(_, v), s)
  (x0, ({==}, (rv, q2)))

law LightClientHeader_set_execution_branch_rep:
  for -o: FuluLightClientHeader_d.LightClientHeader
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_LightClientHeader(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))
  RT.rep_LightClientHeader(FuluLightClientHeader_d.LightClientHeader_set_execution_branch(o, v), s)
def LightClientHeader_set_execution_branch_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, +q2) = c0
  %Equal.sym(FuluLightClientHeader_d.LightClientHeader, o, FuluLightClientHeader_d.LightClientHeader{x0, RT.pj_LightClientHeader_1(o), RT.pj_LightClientHeader_2(o)}, eo) : RT.rep_LightClientHeader(FuluLightClientHeader_d.LightClientHeader_set_execution_branch(_, v), s)
  (x0, ({==}, (q1, rv)))

law LightClientOptimisticUpdate_set_attested_header_rep:
  for -o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate
  for +s: S.Schema
  for -v: FuluLightClientHeader_d.LightClientHeader
  for +r: RT.rep_LightClientOptimisticUpdate(o, s)
  for +rv: RT.rep_LightClientHeader(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_LightClientOptimisticUpdate(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate_set_attested_header(o, v), s)
def LightClientOptimisticUpdate_set_attested_header_rep(o, s, v, r, rv):
  (+x2, e0) = r
  (+eo, c0) = e0
  (+q0, +q1) = c0
  %Equal.sym(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate, o, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{RT.pj_LightClientOptimisticUpdate_0(o), RT.pj_LightClientOptimisticUpdate_1(o), x2}, eo) : RT.rep_LightClientOptimisticUpdate(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate_set_attested_header(_, v), s)
  (x2, ({==}, (rv, q1)))

law LightClientOptimisticUpdate_set_sync_aggregate_rep:
  for -o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate
  for +s: S.Schema
  for -v: O.Boxed<FuluSyncAggregate_d.SyncAggregate>
  for +r: RT.rep_LightClientOptimisticUpdate(o, s)
  for +rv: RT.rep_SyncAggregate_bx(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_LightClientOptimisticUpdate(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate_set_sync_aggregate(o, v), s)
def LightClientOptimisticUpdate_set_sync_aggregate_rep(o, s, v, r, rv):
  (+x2, e0) = r
  (+eo, c0) = e0
  (+q0, +q1) = c0
  %Equal.sym(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate, o, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{RT.pj_LightClientOptimisticUpdate_0(o), RT.pj_LightClientOptimisticUpdate_1(o), x2}, eo) : RT.rep_LightClientOptimisticUpdate(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate_set_sync_aggregate(_, v), s)
  (x2, ({==}, (q0, rv)))

law LightClientOptimisticUpdate_set_signature_slot_rep:
  for -o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_LightClientOptimisticUpdate(o, s)
  RT.rep_LightClientOptimisticUpdate(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate_set_signature_slot(o, v), s)
def LightClientOptimisticUpdate_set_signature_slot_rep(o, s, v, r):
  (+x2, e0) = r
  (+eo, c0) = e0
  (+q0, +q1) = c0
  %Equal.sym(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate, o, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{RT.pj_LightClientOptimisticUpdate_0(o), RT.pj_LightClientOptimisticUpdate_1(o), x2}, eo) : RT.rep_LightClientOptimisticUpdate(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate_set_signature_slot(_, v), s)
  (v, ({==}, (q0, q1)))

law LightClientFinalityUpdate_set_attested_header_rep:
  for -o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate
  for +s: S.Schema
  for -v: FuluLightClientHeader_d.LightClientHeader
  for +r: RT.rep_LightClientFinalityUpdate(o, s)
  for +rv: RT.rep_LightClientHeader(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_attested_header(o, v), s)
def LightClientFinalityUpdate_set_attested_header_rep(o, s, v, r, rv):
  (+x4, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, +q3) = c2
  %Equal.sym(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, o, FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{RT.pj_LightClientFinalityUpdate_0(o), RT.pj_LightClientFinalityUpdate_1(o), RT.pj_LightClientFinalityUpdate_2(o), RT.pj_LightClientFinalityUpdate_3(o), x4}, eo) : RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_attested_header(_, v), s)
  (x4, ({==}, (rv, (q1, (q2, q3)))))

law LightClientFinalityUpdate_set_finalized_header_rep:
  for -o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate
  for +s: S.Schema
  for -v: FuluLightClientHeader_d.LightClientHeader
  for +r: RT.rep_LightClientFinalityUpdate(o, s)
  for +rv: RT.rep_LightClientHeader(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_finalized_header(o, v), s)
def LightClientFinalityUpdate_set_finalized_header_rep(o, s, v, r, rv):
  (+x4, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, +q3) = c2
  %Equal.sym(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, o, FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{RT.pj_LightClientFinalityUpdate_0(o), RT.pj_LightClientFinalityUpdate_1(o), RT.pj_LightClientFinalityUpdate_2(o), RT.pj_LightClientFinalityUpdate_3(o), x4}, eo) : RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_finalized_header(_, v), s)
  (x4, ({==}, (q0, (rv, (q2, q3)))))

law LightClientFinalityUpdate_set_finality_branch_rep:
  for -o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_LightClientFinalityUpdate(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))
  RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_finality_branch(o, v), s)
def LightClientFinalityUpdate_set_finality_branch_rep(o, s, v, r, rv):
  (+x4, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, +q3) = c2
  %Equal.sym(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, o, FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{RT.pj_LightClientFinalityUpdate_0(o), RT.pj_LightClientFinalityUpdate_1(o), RT.pj_LightClientFinalityUpdate_2(o), RT.pj_LightClientFinalityUpdate_3(o), x4}, eo) : RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_finality_branch(_, v), s)
  (x4, ({==}, (q0, (q1, (rv, q3)))))

law LightClientFinalityUpdate_set_sync_aggregate_rep:
  for -o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate
  for +s: S.Schema
  for -v: O.Boxed<FuluSyncAggregate_d.SyncAggregate>
  for +r: RT.rep_LightClientFinalityUpdate(o, s)
  for +rv: RT.rep_SyncAggregate_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))
  RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_sync_aggregate(o, v), s)
def LightClientFinalityUpdate_set_sync_aggregate_rep(o, s, v, r, rv):
  (+x4, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, +q3) = c2
  %Equal.sym(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, o, FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{RT.pj_LightClientFinalityUpdate_0(o), RT.pj_LightClientFinalityUpdate_1(o), RT.pj_LightClientFinalityUpdate_2(o), RT.pj_LightClientFinalityUpdate_3(o), x4}, eo) : RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_sync_aggregate(_, v), s)
  (x4, ({==}, (q0, (q1, (q2, rv)))))

law LightClientFinalityUpdate_set_signature_slot_rep:
  for -o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_LightClientFinalityUpdate(o, s)
  RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_signature_slot(o, v), s)
def LightClientFinalityUpdate_set_signature_slot_rep(o, s, v, r):
  (+x4, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, +q3) = c2
  %Equal.sym(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, o, FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{RT.pj_LightClientFinalityUpdate_0(o), RT.pj_LightClientFinalityUpdate_1(o), RT.pj_LightClientFinalityUpdate_2(o), RT.pj_LightClientFinalityUpdate_3(o), x4}, eo) : RT.rep_LightClientFinalityUpdate(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate_set_signature_slot(_, v), s)
  (v, ({==}, (q0, (q1, (q2, q3)))))

law LightClientUpdate_set_attested_header_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for -v: FuluLightClientHeader_d.LightClientHeader
  for +r: RT.rep_LightClientUpdate(o, s)
  for +rv: RT.rep_LightClientHeader(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_attested_header(o, v), s)
def LightClientUpdate_set_attested_header_rep(o, s, v, r, rv):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_attested_header(_, v), s)
  (x6, ({==}, (rv, (q1, (q2, (q3, (q4, q5)))))))

law LightClientUpdate_set_next_sync_committee_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for -v: FuluSyncCommittee_d.SyncCommittee
  for +r: RT.rep_LightClientUpdate(o, s)
  for +rv: RT.rep_SyncCommittee(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_next_sync_committee(o, v), s)
def LightClientUpdate_set_next_sync_committee_rep(o, s, v, r, rv):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_next_sync_committee(_, v), s)
  (x6, ({==}, (q0, (rv, (q2, (q3, (q4, q5)))))))

law LightClientUpdate_set_next_sync_committee_branch_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_LightClientUpdate(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_next_sync_committee_branch(o, v), s)
def LightClientUpdate_set_next_sync_committee_branch_rep(o, s, v, r, rv):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_next_sync_committee_branch(_, v), s)
  (x6, ({==}, (q0, (q1, (rv, (q3, (q4, q5)))))))

law LightClientUpdate_set_finalized_header_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for -v: FuluLightClientHeader_d.LightClientHeader
  for +r: RT.rep_LightClientUpdate(o, s)
  for +rv: RT.rep_LightClientHeader(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_finalized_header(o, v), s)
def LightClientUpdate_set_finalized_header_rep(o, s, v, r, rv):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_finalized_header(_, v), s)
  (x6, ({==}, (q0, (q1, (q2, (rv, (q4, q5)))))))

law LightClientUpdate_set_finality_branch_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_LightClientUpdate(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_finality_branch(o, v), s)
def LightClientUpdate_set_finality_branch_rep(o, s, v, r, rv):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_finality_branch(_, v), s)
  (x6, ({==}, (q0, (q1, (q2, (q3, (rv, q5)))))))

law LightClientUpdate_set_sync_aggregate_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for -v: O.Boxed<FuluSyncAggregate_d.SyncAggregate>
  for +r: RT.rep_LightClientUpdate(o, s)
  for +rv: RT.rep_SyncAggregate_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_sync_aggregate(o, v), s)
def LightClientUpdate_set_sync_aggregate_rep(o, s, v, r, rv):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_sync_aggregate(_, v), s)
  (x6, ({==}, (q0, (q1, (q2, (q3, (q4, rv)))))))

law LightClientUpdate_set_signature_slot_rep:
  for -o: FuluLightClientUpdate_d.LightClientUpdate
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_LightClientUpdate(o, s)
  RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_signature_slot(o, v), s)
def LightClientUpdate_set_signature_slot_rep(o, s, v, r):
  (+x6, e0) = r
  (+eo, c0) = e0
  (+q0, c1) = c0
  (+q1, c2) = c1
  (+q2, c3) = c2
  (+q3, c4) = c3
  (+q4, +q5) = c4
  %Equal.sym(FuluLightClientUpdate_d.LightClientUpdate, o, FuluLightClientUpdate_d.LightClientUpdate{RT.pj_LightClientUpdate_0(o), RT.pj_LightClientUpdate_1(o), RT.pj_LightClientUpdate_2(o), RT.pj_LightClientUpdate_3(o), RT.pj_LightClientUpdate_4(o), RT.pj_LightClientUpdate_5(o), x6}, eo) : RT.rep_LightClientUpdate(FuluLightClientUpdate_d.LightClientUpdate_set_signature_slot(_, v), s)
  (v, ({==}, (q0, (q1, (q2, (q3, (q4, q5)))))))

law LightClientBootstrap_set_header_rep:
  for -o: FuluLightClientBootstrap_d.LightClientBootstrap
  for +s: S.Schema
  for -v: FuluLightClientHeader_d.LightClientHeader
  for +r: RT.rep_LightClientBootstrap(o, s)
  for +rv: RT.rep_LightClientHeader(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_LightClientBootstrap(FuluLightClientBootstrap_d.LightClientBootstrap_set_header(o, v), s)
def LightClientBootstrap_set_header_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, c1) = c0
  (+q1, +q2) = c1
  %Equal.sym(FuluLightClientBootstrap_d.LightClientBootstrap, o, FuluLightClientBootstrap_d.LightClientBootstrap{RT.pj_LightClientBootstrap_0(o), RT.pj_LightClientBootstrap_1(o), RT.pj_LightClientBootstrap_2(o)}, eo) : RT.rep_LightClientBootstrap(FuluLightClientBootstrap_d.LightClientBootstrap_set_header(_, v), s)
  ({==}, (rv, (q1, q2)))

law LightClientBootstrap_set_current_sync_committee_rep:
  for -o: FuluLightClientBootstrap_d.LightClientBootstrap
  for +s: S.Schema
  for -v: FuluSyncCommittee_d.SyncCommittee
  for +r: RT.rep_LightClientBootstrap(o, s)
  for +rv: RT.rep_SyncCommittee(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_LightClientBootstrap(FuluLightClientBootstrap_d.LightClientBootstrap_set_current_sync_committee(o, v), s)
def LightClientBootstrap_set_current_sync_committee_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, c1) = c0
  (+q1, +q2) = c1
  %Equal.sym(FuluLightClientBootstrap_d.LightClientBootstrap, o, FuluLightClientBootstrap_d.LightClientBootstrap{RT.pj_LightClientBootstrap_0(o), RT.pj_LightClientBootstrap_1(o), RT.pj_LightClientBootstrap_2(o)}, eo) : RT.rep_LightClientBootstrap(FuluLightClientBootstrap_d.LightClientBootstrap_set_current_sync_committee(_, v), s)
  ({==}, (q0, (rv, q2)))

law LightClientBootstrap_set_current_sync_committee_branch_rep:
  for -o: FuluLightClientBootstrap_d.LightClientBootstrap
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_LightClientBootstrap(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))
  RT.rep_LightClientBootstrap(FuluLightClientBootstrap_d.LightClientBootstrap_set_current_sync_committee_branch(o, v), s)
def LightClientBootstrap_set_current_sync_committee_branch_rep(o, s, v, r, rv):
  (+eo, c0) = r
  (+q0, c1) = c0
  (+q1, +q2) = c1
  %Equal.sym(FuluLightClientBootstrap_d.LightClientBootstrap, o, FuluLightClientBootstrap_d.LightClientBootstrap{RT.pj_LightClientBootstrap_0(o), RT.pj_LightClientBootstrap_1(o), RT.pj_LightClientBootstrap_2(o)}, eo) : RT.rep_LightClientBootstrap(FuluLightClientBootstrap_d.LightClientBootstrap_set_current_sync_committee_branch(_, v), s)
  ({==}, (q0, (q1, rv)))

law BeaconBlockBody_set_randao_reveal_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_BeaconBlockBody(o, s)
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(o, v), s)
def BeaconBlockBody_set_randao_reveal_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_randao_reveal(_, v), s)
  (v, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_eth1_data_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for +v: FuluEth1Data_d.Eth1Data
  for +r: RT.rep_BeaconBlockBody(o, s)
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(o, v), s)
def BeaconBlockBody_set_eth1_data_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_eth1_data(_, v), s)
  (x0, (v, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_graffiti_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_BeaconBlockBody(o, s)
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(o, v), s)
def BeaconBlockBody_set_graffiti_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_graffiti(_, v), s)
  (x0, (x1, (v, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_proposer_slashings_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_l16_ProposerSlashing(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_proposer_slashings(o, v), s)
def BeaconBlockBody_set_proposer_slashings_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_proposer_slashings(_, v), s)
  (x0, (x1, (x2, ({==}, (rv, (q4, (q5, (q6, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_attester_slashings_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_l1_AttesterSlashing(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_attester_slashings(o, v), s)
def BeaconBlockBody_set_attester_slashings_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_attester_slashings(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (rv, (q5, (q6, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_attestations_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: Fulu_list_Attestation_8_d.l8_Attestation_Seq
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_l8_Attestation(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_attestations(o, v), s)
def BeaconBlockBody_set_attestations_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_attestations(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (rv, (q6, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_deposits_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: Fulu_list_Deposit_16_d.l16_Deposit_Seq
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_l16_Deposit(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_deposits(o, v), s)
def BeaconBlockBody_set_deposits_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_deposits(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (rv, (q7, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_voluntary_exits_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_l16_SignedVoluntaryExit(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_voluntary_exits(o, v), s)
def BeaconBlockBody_set_voluntary_exits_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_voluntary_exits(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (rv, (q8, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_sync_aggregate_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: O.Boxed<FuluSyncAggregate_d.SyncAggregate>
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_SyncAggregate_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_sync_aggregate(o, v), s)
def BeaconBlockBody_set_sync_aggregate_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_sync_aggregate(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (rv, (q9, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_execution_payload_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: O.Boxed<FuluExecutionPayload_d.ExecutionPayload>
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_ExecutionPayload_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_execution_payload(o, v), s)
def BeaconBlockBody_set_execution_payload_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_execution_payload(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (rv, (q10, (q11, q12)))))))))))))

law BeaconBlockBody_set_bls_to_execution_changes_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_l16_SignedBLSToExecutionChange(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_bls_to_execution_changes(o, v), s)
def BeaconBlockBody_set_bls_to_execution_changes_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_bls_to_execution_changes(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (q9, (rv, (q11, q12)))))))))))))

law BeaconBlockBody_set_blob_kzg_commitments_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: E48.rep_el(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_blob_kzg_commitments(o, v), s)
def BeaconBlockBody_set_blob_kzg_commitments_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_blob_kzg_commitments(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (q9, (q10, (rv, q12)))))))))))))

law BeaconBlockBody_set_execution_requests_rep:
  for -o: FuluBeaconBlockBody_d.BeaconBlockBody
  for +s: S.Schema
  for -v: FuluExecutionRequests_d.ExecutionRequests
  for +r: RT.rep_BeaconBlockBody(o, s)
  for +rv: RT.rep_ExecutionRequests(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))))
  RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_execution_requests(o, v), s)
def BeaconBlockBody_set_execution_requests_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+eo, c0) = e2
  (+q3, c1) = c0
  (+q4, c2) = c1
  (+q5, c3) = c2
  (+q6, c4) = c3
  (+q7, c5) = c4
  (+q8, c6) = c5
  (+q9, c7) = c6
  (+q10, c8) = c7
  (+q11, +q12) = c8
  %Equal.sym(FuluBeaconBlockBody_d.BeaconBlockBody, o, FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, RT.pj_BeaconBlockBody_3(o), RT.pj_BeaconBlockBody_4(o), RT.pj_BeaconBlockBody_5(o), RT.pj_BeaconBlockBody_6(o), RT.pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{RT.pj_BeaconBlockBody_8(o), RT.pj_BeaconBlockBody_9(o), RT.pj_BeaconBlockBody_10(o), RT.pj_BeaconBlockBody_11(o), RT.pj_BeaconBlockBody_12(o)}}, eo) : RT.rep_BeaconBlockBody(FuluBeaconBlockBody_d.BeaconBlockBody_set_execution_requests(_, v), s)
  (x0, (x1, (x2, ({==}, (q3, (q4, (q5, (q6, (q7, (q8, (q9, (q10, (q11, rv)))))))))))))

law BeaconBlock_set_slot_rep:
  for -o: FuluBeaconBlock_d.BeaconBlock
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_BeaconBlock(o, s)
  RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_slot(o, v), s)
def BeaconBlock_set_slot_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+eo, +q4) = e3
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock, o, FuluBeaconBlock_d.BeaconBlock{x0, x1, x2, x3, RT.pj_BeaconBlock_4(o)}, eo) : RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_slot(_, v), s)
  (v, (x1, (x2, (x3, ({==}, q4)))))

law BeaconBlock_set_proposer_index_rep:
  for -o: FuluBeaconBlock_d.BeaconBlock
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_BeaconBlock(o, s)
  RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_proposer_index(o, v), s)
def BeaconBlock_set_proposer_index_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+eo, +q4) = e3
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock, o, FuluBeaconBlock_d.BeaconBlock{x0, x1, x2, x3, RT.pj_BeaconBlock_4(o)}, eo) : RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_proposer_index(_, v), s)
  (x0, (v, (x2, (x3, ({==}, q4)))))

law BeaconBlock_set_parent_root_rep:
  for -o: FuluBeaconBlock_d.BeaconBlock
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_BeaconBlock(o, s)
  RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_parent_root(o, v), s)
def BeaconBlock_set_parent_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+eo, +q4) = e3
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock, o, FuluBeaconBlock_d.BeaconBlock{x0, x1, x2, x3, RT.pj_BeaconBlock_4(o)}, eo) : RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_parent_root(_, v), s)
  (x0, (x1, (v, (x3, ({==}, q4)))))

law BeaconBlock_set_state_root_rep:
  for -o: FuluBeaconBlock_d.BeaconBlock
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_BeaconBlock(o, s)
  RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_state_root(o, v), s)
def BeaconBlock_set_state_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+eo, +q4) = e3
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock, o, FuluBeaconBlock_d.BeaconBlock{x0, x1, x2, x3, RT.pj_BeaconBlock_4(o)}, eo) : RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_state_root(_, v), s)
  (x0, (x1, (x2, (v, ({==}, q4)))))

law BeaconBlock_set_body_rep:
  for -o: FuluBeaconBlock_d.BeaconBlock
  for +s: S.Schema
  for -v: O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>
  for +r: RT.rep_BeaconBlock(o, s)
  for +rv: RT.rep_BeaconBlockBody_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_body(o, v), s)
def BeaconBlock_set_body_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x1, e1) = e0
  (+x2, e2) = e1
  (+x3, e3) = e2
  (+eo, +q4) = e3
  %Equal.sym(FuluBeaconBlock_d.BeaconBlock, o, FuluBeaconBlock_d.BeaconBlock{x0, x1, x2, x3, RT.pj_BeaconBlock_4(o)}, eo) : RT.rep_BeaconBlock(FuluBeaconBlock_d.BeaconBlock_set_body(_, v), s)
  (x0, (x1, (x2, (x3, ({==}, rv)))))

law SignedBeaconBlock_set_message_rep:
  for -o: FuluSignedBeaconBlock_d.SignedBeaconBlock
  for +s: S.Schema
  for -v: FuluBeaconBlock_d.BeaconBlock
  for +r: RT.rep_SignedBeaconBlock(o, s)
  for +rv: RT.rep_BeaconBlock(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_SignedBeaconBlock(FuluSignedBeaconBlock_d.SignedBeaconBlock_set_message(o, v), s)
def SignedBeaconBlock_set_message_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSignedBeaconBlock_d.SignedBeaconBlock, o, FuluSignedBeaconBlock_d.SignedBeaconBlock{RT.pj_SignedBeaconBlock_0(o), x1}, eo) : RT.rep_SignedBeaconBlock(FuluSignedBeaconBlock_d.SignedBeaconBlock_set_message(_, v), s)
  (x1, ({==}, rv))

law SignedBeaconBlock_set_signature_rep:
  for -o: FuluSignedBeaconBlock_d.SignedBeaconBlock
  for +s: S.Schema
  for +v: FuluBytes96_d.Bytes96
  for +r: RT.rep_SignedBeaconBlock(o, s)
  RT.rep_SignedBeaconBlock(FuluSignedBeaconBlock_d.SignedBeaconBlock_set_signature(o, v), s)
def SignedBeaconBlock_set_signature_rep(o, s, v, r):
  (+x1, e0) = r
  (+eo, +q0) = e0
  %Equal.sym(FuluSignedBeaconBlock_d.SignedBeaconBlock, o, FuluSignedBeaconBlock_d.SignedBeaconBlock{RT.pj_SignedBeaconBlock_0(o), x1}, eo) : RT.rep_SignedBeaconBlock(FuluSignedBeaconBlock_d.SignedBeaconBlock_set_signature(_, v), s)
  (v, ({==}, q0))

law BlobSidecar_set_index_rep:
  for -o: FuluBlobSidecar_d.BlobSidecar
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_BlobSidecar(o, s)
  RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_index(o, v), s)
def BlobSidecar_set_index_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, c0) = e2
  (+q1, c1) = c0
  (+q4, +q5) = c1
  %Equal.sym(FuluBlobSidecar_d.BlobSidecar, o, FuluBlobSidecar_d.BlobSidecar{x0, RT.pj_BlobSidecar_1(o), x2, x3, RT.pj_BlobSidecar_4(o), RT.pj_BlobSidecar_5(o)}, eo) : RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_index(_, v), s)
  (v, (x2, (x3, ({==}, (q1, (q4, q5))))))

law BlobSidecar_set_blob_rep:
  for -o: FuluBlobSidecar_d.BlobSidecar
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_BlobSidecar(o, s)
  for +rv: WO.rep_bv(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_blob(o, v), s)
def BlobSidecar_set_blob_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, c0) = e2
  (+q1, c1) = c0
  (+q4, +q5) = c1
  %Equal.sym(FuluBlobSidecar_d.BlobSidecar, o, FuluBlobSidecar_d.BlobSidecar{x0, RT.pj_BlobSidecar_1(o), x2, x3, RT.pj_BlobSidecar_4(o), RT.pj_BlobSidecar_5(o)}, eo) : RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_blob(_, v), s)
  (x0, (x2, (x3, ({==}, (rv, (q4, q5))))))

law BlobSidecar_set_kzg_commitment_rep:
  for -o: FuluBlobSidecar_d.BlobSidecar
  for +s: S.Schema
  for +v: FuluBytes48_d.Bytes48
  for +r: RT.rep_BlobSidecar(o, s)
  RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_kzg_commitment(o, v), s)
def BlobSidecar_set_kzg_commitment_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, c0) = e2
  (+q1, c1) = c0
  (+q4, +q5) = c1
  %Equal.sym(FuluBlobSidecar_d.BlobSidecar, o, FuluBlobSidecar_d.BlobSidecar{x0, RT.pj_BlobSidecar_1(o), x2, x3, RT.pj_BlobSidecar_4(o), RT.pj_BlobSidecar_5(o)}, eo) : RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_kzg_commitment(_, v), s)
  (x0, (v, (x3, ({==}, (q1, (q4, q5))))))

law BlobSidecar_set_kzg_proof_rep:
  for -o: FuluBlobSidecar_d.BlobSidecar
  for +s: S.Schema
  for +v: FuluBytes48_d.Bytes48
  for +r: RT.rep_BlobSidecar(o, s)
  RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_kzg_proof(o, v), s)
def BlobSidecar_set_kzg_proof_rep(o, s, v, r):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, c0) = e2
  (+q1, c1) = c0
  (+q4, +q5) = c1
  %Equal.sym(FuluBlobSidecar_d.BlobSidecar, o, FuluBlobSidecar_d.BlobSidecar{x0, RT.pj_BlobSidecar_1(o), x2, x3, RT.pj_BlobSidecar_4(o), RT.pj_BlobSidecar_5(o)}, eo) : RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_kzg_proof(_, v), s)
  (x0, (x2, (v, ({==}, (q1, (q4, q5))))))

law BlobSidecar_set_signed_block_header_rep:
  for -o: FuluBlobSidecar_d.BlobSidecar
  for +s: S.Schema
  for -v: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>
  for +r: RT.rep_BlobSidecar(o, s)
  for +rv: RT.rep_SignedBeaconBlockHeader_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_signed_block_header(o, v), s)
def BlobSidecar_set_signed_block_header_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, c0) = e2
  (+q1, c1) = c0
  (+q4, +q5) = c1
  %Equal.sym(FuluBlobSidecar_d.BlobSidecar, o, FuluBlobSidecar_d.BlobSidecar{x0, RT.pj_BlobSidecar_1(o), x2, x3, RT.pj_BlobSidecar_4(o), RT.pj_BlobSidecar_5(o)}, eo) : RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_signed_block_header(_, v), s)
  (x0, (x2, (x3, ({==}, (q1, (rv, q5))))))

law BlobSidecar_set_kzg_commitment_inclusion_proof_rep:
  for -o: FuluBlobSidecar_d.BlobSidecar
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_BlobSidecar(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
  RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_kzg_commitment_inclusion_proof(o, v), s)
def BlobSidecar_set_kzg_commitment_inclusion_proof_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, c0) = e2
  (+q1, c1) = c0
  (+q4, +q5) = c1
  %Equal.sym(FuluBlobSidecar_d.BlobSidecar, o, FuluBlobSidecar_d.BlobSidecar{x0, RT.pj_BlobSidecar_1(o), x2, x3, RT.pj_BlobSidecar_4(o), RT.pj_BlobSidecar_5(o)}, eo) : RT.rep_BlobSidecar(FuluBlobSidecar_d.BlobSidecar_set_kzg_commitment_inclusion_proof(_, v), s)
  (x0, (x2, (x3, ({==}, (q1, (q4, rv))))))

law DataColumnsByRootIdentifier_set_block_root_rep:
  for -o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier
  for +s: S.Schema
  for +v: FuluBytes32_d.Bytes32
  for +r: RT.rep_DataColumnsByRootIdentifier(o, s)
  RT.rep_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier_set_block_root(o, v), s)
def DataColumnsByRootIdentifier_set_block_root_rep(o, s, v, r):
  (+x0, e0) = r
  (+eo, +q1) = e0
  %Equal.sym(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, o, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{x0, RT.pj_DataColumnsByRootIdentifier_1(o)}, eo) : RT.rep_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier_set_block_root(_, v), s)
  (v, ({==}, q1))

law DataColumnsByRootIdentifier_set_columns_rep:
  for -o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_DataColumnsByRootIdentifier(o, s)
  for +rv: UL.rep_ul(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier_set_columns(o, v), s)
def DataColumnsByRootIdentifier_set_columns_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, +q1) = e0
  %Equal.sym(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, o, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{x0, RT.pj_DataColumnsByRootIdentifier_1(o)}, eo) : RT.rep_DataColumnsByRootIdentifier(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier_set_columns(_, v), s)
  (x0, ({==}, rv))

law MatrixEntry_set_cell_rep:
  for -o: FuluMatrixEntry_d.MatrixEntry
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_MatrixEntry(o, s)
  for +rv: WO.rep_bv(v, SH.Chain_head(SH.Container_fields(s)))
  RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_cell(o, v), s)
def MatrixEntry_set_cell_rep(o, s, v, r, rv):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluMatrixEntry_d.MatrixEntry, o, FuluMatrixEntry_d.MatrixEntry{RT.pj_MatrixEntry_0(o), x1, x2, x3}, eo) : RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_cell(_, v), s)
  (x1, (x2, (x3, ({==}, rv))))

law MatrixEntry_set_kzg_proof_rep:
  for -o: FuluMatrixEntry_d.MatrixEntry
  for +s: S.Schema
  for +v: FuluBytes48_d.Bytes48
  for +r: RT.rep_MatrixEntry(o, s)
  RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_kzg_proof(o, v), s)
def MatrixEntry_set_kzg_proof_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluMatrixEntry_d.MatrixEntry, o, FuluMatrixEntry_d.MatrixEntry{RT.pj_MatrixEntry_0(o), x1, x2, x3}, eo) : RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_kzg_proof(_, v), s)
  (v, (x2, (x3, ({==}, q0))))

law MatrixEntry_set_column_index_rep:
  for -o: FuluMatrixEntry_d.MatrixEntry
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_MatrixEntry(o, s)
  RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_column_index(o, v), s)
def MatrixEntry_set_column_index_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluMatrixEntry_d.MatrixEntry, o, FuluMatrixEntry_d.MatrixEntry{RT.pj_MatrixEntry_0(o), x1, x2, x3}, eo) : RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_column_index(_, v), s)
  (x1, (v, (x3, ({==}, q0))))

law MatrixEntry_set_row_index_rep:
  for -o: FuluMatrixEntry_d.MatrixEntry
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_MatrixEntry(o, s)
  RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_row_index(o, v), s)
def MatrixEntry_set_row_index_rep(o, s, v, r):
  (+x1, e0) = r
  (+x2, e1) = e0
  (+x3, e2) = e1
  (+eo, +q0) = e2
  %Equal.sym(FuluMatrixEntry_d.MatrixEntry, o, FuluMatrixEntry_d.MatrixEntry{RT.pj_MatrixEntry_0(o), x1, x2, x3}, eo) : RT.rep_MatrixEntry(FuluMatrixEntry_d.MatrixEntry_set_row_index(_, v), s)
  (x1, (x2, (v, ({==}, q0))))

law DataColumnSidecar_set_index_rep:
  for -o: FuluDataColumnSidecar_d.DataColumnSidecar
  for +s: S.Schema
  for +v: O.U64
  for +r: RT.rep_DataColumnSidecar(o, s)
  RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_index(o, v), s)
def DataColumnSidecar_set_index_rep(o, s, v, r):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, c1) = c0
  (+q2, c2) = c1
  (+q3, c3) = c2
  (+q4, +q5) = c3
  %Equal.sym(FuluDataColumnSidecar_d.DataColumnSidecar, o, FuluDataColumnSidecar_d.DataColumnSidecar{x0, RT.pj_DataColumnSidecar_1(o), RT.pj_DataColumnSidecar_2(o), RT.pj_DataColumnSidecar_3(o), RT.pj_DataColumnSidecar_4(o), RT.pj_DataColumnSidecar_5(o)}, eo) : RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_index(_, v), s)
  (v, ({==}, (q1, (q2, (q3, (q4, q5))))))

law DataColumnSidecar_set_column_rep:
  for -o: FuluDataColumnSidecar_d.DataColumnSidecar
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_DataColumnSidecar(o, s)
  for +rv: CE.rep_el(v, SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))
  RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_column(o, v), s)
def DataColumnSidecar_set_column_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, c1) = c0
  (+q2, c2) = c1
  (+q3, c3) = c2
  (+q4, +q5) = c3
  %Equal.sym(FuluDataColumnSidecar_d.DataColumnSidecar, o, FuluDataColumnSidecar_d.DataColumnSidecar{x0, RT.pj_DataColumnSidecar_1(o), RT.pj_DataColumnSidecar_2(o), RT.pj_DataColumnSidecar_3(o), RT.pj_DataColumnSidecar_4(o), RT.pj_DataColumnSidecar_5(o)}, eo) : RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_column(_, v), s)
  (x0, ({==}, (rv, (q2, (q3, (q4, q5))))))

law DataColumnSidecar_set_kzg_commitments_rep:
  for -o: FuluDataColumnSidecar_d.DataColumnSidecar
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_DataColumnSidecar(o, s)
  for +rv: E48.rep_el(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))
  RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_commitments(o, v), s)
def DataColumnSidecar_set_kzg_commitments_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, c1) = c0
  (+q2, c2) = c1
  (+q3, c3) = c2
  (+q4, +q5) = c3
  %Equal.sym(FuluDataColumnSidecar_d.DataColumnSidecar, o, FuluDataColumnSidecar_d.DataColumnSidecar{x0, RT.pj_DataColumnSidecar_1(o), RT.pj_DataColumnSidecar_2(o), RT.pj_DataColumnSidecar_3(o), RT.pj_DataColumnSidecar_4(o), RT.pj_DataColumnSidecar_5(o)}, eo) : RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_commitments(_, v), s)
  (x0, ({==}, (q1, (rv, (q3, (q4, q5))))))

law DataColumnSidecar_set_kzg_proofs_rep:
  for -o: FuluDataColumnSidecar_d.DataColumnSidecar
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_DataColumnSidecar(o, s)
  for +rv: E48.rep_el(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))
  RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_proofs(o, v), s)
def DataColumnSidecar_set_kzg_proofs_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, c1) = c0
  (+q2, c2) = c1
  (+q3, c3) = c2
  (+q4, +q5) = c3
  %Equal.sym(FuluDataColumnSidecar_d.DataColumnSidecar, o, FuluDataColumnSidecar_d.DataColumnSidecar{x0, RT.pj_DataColumnSidecar_1(o), RT.pj_DataColumnSidecar_2(o), RT.pj_DataColumnSidecar_3(o), RT.pj_DataColumnSidecar_4(o), RT.pj_DataColumnSidecar_5(o)}, eo) : RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_proofs(_, v), s)
  (x0, ({==}, (q1, (q2, (rv, (q4, q5))))))

law DataColumnSidecar_set_signed_block_header_rep:
  for -o: FuluDataColumnSidecar_d.DataColumnSidecar
  for +s: S.Schema
  for -v: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>
  for +r: RT.rep_DataColumnSidecar(o, s)
  for +rv: RT.rep_SignedBeaconBlockHeader_bx(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))
  RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_signed_block_header(o, v), s)
def DataColumnSidecar_set_signed_block_header_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, c1) = c0
  (+q2, c2) = c1
  (+q3, c3) = c2
  (+q4, +q5) = c3
  %Equal.sym(FuluDataColumnSidecar_d.DataColumnSidecar, o, FuluDataColumnSidecar_d.DataColumnSidecar{x0, RT.pj_DataColumnSidecar_1(o), RT.pj_DataColumnSidecar_2(o), RT.pj_DataColumnSidecar_3(o), RT.pj_DataColumnSidecar_4(o), RT.pj_DataColumnSidecar_5(o)}, eo) : RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_signed_block_header(_, v), s)
  (x0, ({==}, (q1, (q2, (q3, (rv, q5))))))

law DataColumnSidecar_set_kzg_commitments_inclusion_proof_rep:
  for -o: FuluDataColumnSidecar_d.DataColumnSidecar
  for +s: S.Schema
  for -v: O.Words
  for +r: RT.rep_DataColumnSidecar(o, s)
  for +rv: PV.rep_pv(v, SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
  RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_commitments_inclusion_proof(o, v), s)
def DataColumnSidecar_set_kzg_commitments_inclusion_proof_rep(o, s, v, r, rv):
  (+x0, e0) = r
  (+eo, c0) = e0
  (+q1, c1) = c0
  (+q2, c2) = c1
  (+q3, c3) = c2
  (+q4, +q5) = c3
  %Equal.sym(FuluDataColumnSidecar_d.DataColumnSidecar, o, FuluDataColumnSidecar_d.DataColumnSidecar{x0, RT.pj_DataColumnSidecar_1(o), RT.pj_DataColumnSidecar_2(o), RT.pj_DataColumnSidecar_3(o), RT.pj_DataColumnSidecar_4(o), RT.pj_DataColumnSidecar_5(o)}, eo) : RT.rep_DataColumnSidecar(FuluDataColumnSidecar_d.DataColumnSidecar_set_kzg_commitments_inclusion_proof(_, v), s)
  (x0, ({==}, (q1, (q2, (q3, (q4, rv))))))

