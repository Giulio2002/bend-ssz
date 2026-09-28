import Base
import ../compact/found.bend as F
import ../../src/obj.bend as O
import ../../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d
import ../../types/FuluBytes20_def_generated.bend as FuluBytes20_d
import ../../types/FuluBytes32_def_generated.bend as FuluBytes32_d
import ../../types/FuluBytes48_def_generated.bend as FuluBytes48_d
import ../../types/FuluBytes96_def_generated.bend as FuluBytes96_d
import ../../types/uint256_def_generated.bend as uint256_d
import ../../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
import ../../types/FuluSignedVoluntaryExit_def_generated.bend as FuluSignedVoluntaryExit_d
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
import ../../types/FuluDepositRequest_def_generated.bend as FuluDepositRequest_d
import ../../types/FuluSyncCommittee_def_generated.bend as FuluSyncCommittee_d
import ../../types/FuluDepositData_def_generated.bend as FuluDepositData_d
import ../../types/FuluDeposit_def_generated.bend as FuluDeposit_d
import ../../types/FuluTransaction_def_generated.bend as FuluTransaction_d
import ../../types/FuluConsolidationRequest_def_generated.bend as FuluConsolidationRequest_d
import ../../types/FuluWithdrawalRequest_def_generated.bend as FuluWithdrawalRequest_d
import ../../types/Fulu_list_DepositRequest_8192_def_generated.bend as Fulu_list_DepositRequest_8192_d
import ../../types/Fulu_list_WithdrawalRequest_16_def_generated.bend as Fulu_list_WithdrawalRequest_16_d
import ../../types/Fulu_list_ConsolidationRequest_2_def_generated.bend as Fulu_list_ConsolidationRequest_2_d
import ../../types/FuluExecutionRequests_def_generated.bend as FuluExecutionRequests_d
import ../../types/FuluSignedBLSToExecutionChange_def_generated.bend as FuluSignedBLSToExecutionChange_d
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
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
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./words_obj_light.bend as WO
import ./list_obj_light.bend as LO
import ./pv_obj_light.bend as PV
import ./bitlist_obj_light.bend as BO
import ./cells_light.bend as CE
import ./root_names_light.bend as RN
import ./ulist_obj_light.bend as UL
import ./elems48_light.bend as E48

# GENERATED by codegen/root_laws_b.py. Do not edit.
# The definitions of root_types.bend that state no root law (its light companion, codegen/light_split.py): importers that only
# state against them skip the root laws' imports.

# ---- Data mirrors of Type-kind objects (for lists of Type-kind elements) ----
# A list's array holds Type-kind boxes; its laws describe the array as the
# image AM.am(th, t) of a Data mirror tree t. `th` builds the object from its
# mirror, `fz` reads the mirror back, and fz(th(m)) == m.
type WMr is Data:
  WMr{t: F.array__Tree<U32>, n: U32}
def th_w(m: WMr) -> O.Words:
  match m:
    case WMr{+t, +n}: O.Words{F.array__thaw(U32, t), n}
def fz_w(x: O.Words) -> WMr:
  match x:
    case O.Words{ws, +n}: WMr{F.array__freeze(U32, ws), n}
type BMr is Data:
  BMr{t: F.array__Tree<U32>, k: U32}
def th_b(m: BMr) -> O.Bits:
  match m:
    case BMr{+t, +k}: O.Bits{F.array__thaw(U32, t), k}
def fz_b(x: O.Bits) -> BMr:
  match x:
    case O.Bits{ws, +k}: BMr{F.array__freeze(U32, ws), k}
type MB<-X: Data> is Data:
  MNone{}
  MSome{v: X}

# ---- box of SyncCommitteeContribution ----
def v_SyncCommitteeContribution_bx(o: O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution>) -> S.Value:
  match o:
    case O.BSome{+v, rest}: RN.v_SyncCommitteeContribution(v)
    case O.BNone{}: S.NullValue{}
def rep_SyncCommitteeContribution_bx(o: O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution>, +s: S.Schema) -> Data:
  DK.Ex(FuluSyncCommitteeContribution_d.SyncCommitteeContribution, v => {o == O.BSome{v, O.BNone{}} : O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution>})
# ---- ContributionAndProof (Type-kind container, 3 fields) ----
def pj_ContributionAndProof_1(o: FuluContributionAndProof_d.ContributionAndProof) -> O.Boxed<FuluSyncCommitteeContribution_d.SyncCommitteeContribution>:
  match o:
    case FuluContributionAndProof_d.ContributionAndProof{+x0, x1, +x2}: x1
def v_ContributionAndProof(o: FuluContributionAndProof_d.ContributionAndProof) -> S.Value:
  match o:
    case FuluContributionAndProof_d.ContributionAndProof{+x0, x1, +x2}: S.Sequence{S.Items{RN.v_u64(x0), S.Items{v_SyncCommitteeContribution_bx(x1), S.Items{RN.v_b96(x2), S.EmptyItems{}}}}}
def rep_ContributionAndProof(o: FuluContributionAndProof_d.ContributionAndProof, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x0 => DK.Ex(FuluBytes96_d.Bytes96, x2 => DK.P2({o == FuluContributionAndProof_d.ContributionAndProof{x0, pj_ContributionAndProof_1(o), x2} : FuluContributionAndProof_d.ContributionAndProof}, rep_SyncCommitteeContribution_bx(pj_ContributionAndProof_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))))))
# ---- SignedContributionAndProof (Type-kind container, 2 fields) ----
def pj_SignedContributionAndProof_0(o: FuluSignedContributionAndProof_d.SignedContributionAndProof) -> FuluContributionAndProof_d.ContributionAndProof:
  match o:
    case FuluSignedContributionAndProof_d.SignedContributionAndProof{x0, +x1}: x0
def v_SignedContributionAndProof(o: FuluSignedContributionAndProof_d.SignedContributionAndProof) -> S.Value:
  match o:
    case FuluSignedContributionAndProof_d.SignedContributionAndProof{x0, +x1}: S.Sequence{S.Items{v_ContributionAndProof(x0), S.Items{RN.v_b96(x1), S.EmptyItems{}}}}
def rep_SignedContributionAndProof(o: FuluSignedContributionAndProof_d.SignedContributionAndProof, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes96_d.Bytes96, x1 => DK.P2({o == FuluSignedContributionAndProof_d.SignedContributionAndProof{pj_SignedContributionAndProof_0(o), x1} : FuluSignedContributionAndProof_d.SignedContributionAndProof}, rep_ContributionAndProof(pj_SignedContributionAndProof_0(o), SH.Chain_head(SH.Container_fields(s)))))
# ---- box of SignedBeaconBlockHeader ----
def v_SignedBeaconBlockHeader_bx(o: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>) -> S.Value:
  match o:
    case O.BSome{+v, rest}: RN.v_SignedBeaconBlockHeader(v)
    case O.BNone{}: S.NullValue{}
def rep_SignedBeaconBlockHeader_bx(o: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>, +s: S.Schema) -> Data:
  DK.Ex(FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader, v => {o == O.BSome{v, O.BNone{}} : O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>})
# ---- ProposerSlashing (Type-kind container, 2 fields) ----
def pj_ProposerSlashing_0(o: FuluProposerSlashing_d.ProposerSlashing) -> O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>:
  match o:
    case FuluProposerSlashing_d.ProposerSlashing{x0, x1}: x0
def pj_ProposerSlashing_1(o: FuluProposerSlashing_d.ProposerSlashing) -> O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>:
  match o:
    case FuluProposerSlashing_d.ProposerSlashing{x0, x1}: x1
def v_ProposerSlashing(o: FuluProposerSlashing_d.ProposerSlashing) -> S.Value:
  match o:
    case FuluProposerSlashing_d.ProposerSlashing{x0, x1}: S.Sequence{S.Items{v_SignedBeaconBlockHeader_bx(x0), S.Items{v_SignedBeaconBlockHeader_bx(x1), S.EmptyItems{}}}}
def rep_ProposerSlashing(o: FuluProposerSlashing_d.ProposerSlashing, +s: S.Schema) -> Data:
  DK.P2({o == FuluProposerSlashing_d.ProposerSlashing{pj_ProposerSlashing_0(o), pj_ProposerSlashing_1(o)} : FuluProposerSlashing_d.ProposerSlashing}, DK.P2(rep_SignedBeaconBlockHeader_bx(pj_ProposerSlashing_0(o), SH.Chain_head(SH.Container_fields(s))), rep_SignedBeaconBlockHeader_bx(pj_ProposerSlashing_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))))
# ---- HistoricalBatch (Type-kind container, 2 fields) ----
def pj_HistoricalBatch_0(o: FuluHistoricalBatch_d.HistoricalBatch) -> O.Words:
  match o:
    case FuluHistoricalBatch_d.HistoricalBatch{x0, x1}: x0
def pj_HistoricalBatch_1(o: FuluHistoricalBatch_d.HistoricalBatch) -> O.Words:
  match o:
    case FuluHistoricalBatch_d.HistoricalBatch{x0, x1}: x1
def v_HistoricalBatch(o: FuluHistoricalBatch_d.HistoricalBatch) -> S.Value:
  match o:
    case FuluHistoricalBatch_d.HistoricalBatch{x0, x1}: S.Sequence{S.Items{PV.pview(x0), S.Items{PV.pview(x1), S.EmptyItems{}}}}
def rep_HistoricalBatch(o: FuluHistoricalBatch_d.HistoricalBatch, +s: S.Schema) -> Data:
  DK.P2({o == FuluHistoricalBatch_d.HistoricalBatch{pj_HistoricalBatch_0(o), pj_HistoricalBatch_1(o)} : FuluHistoricalBatch_d.HistoricalBatch}, DK.P2(PV.rep_pv(pj_HistoricalBatch_0(o), SH.Chain_head(SH.Container_fields(s))), PV.rep_pv(pj_HistoricalBatch_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))))
# ---- Attestation (Type-kind container, 4 fields) ----
def pj_Attestation_0(o: FuluAttestation_d.Attestation) -> O.Bits:
  match o:
    case FuluAttestation_d.Attestation{x0, +x1, +x2, +x3}: x0
def v_Attestation(o: FuluAttestation_d.Attestation) -> S.Value:
  match o:
    case FuluAttestation_d.Attestation{x0, +x1, +x2, +x3}: S.Sequence{S.Items{S.BitsValue{BO.bview(x0)}, S.Items{RN.v_AttestationData(x1), S.Items{RN.v_b96(x2), S.Items{RN.v_bv64(x3), S.EmptyItems{}}}}}}
def rep_Attestation(o: FuluAttestation_d.Attestation, +s: S.Schema) -> Data:
  DK.Ex(FuluAttestationData_d.AttestationData, x1 => DK.Ex(FuluBytes96_d.Bytes96, x2 => DK.Ex(Fulu_bitvector_64_d.Bitvector64, x3 => DK.P2({o == FuluAttestation_d.Attestation{pj_Attestation_0(o), x1, x2, x3} : FuluAttestation_d.Attestation}, BO.rep_bits(pj_Attestation_0(o), SH.Chain_head(SH.Container_fields(s)))))))
# ---- box of Attestation ----
def pjb_Attestation_bx(o: O.Boxed<FuluAttestation_d.Attestation>) -> FuluAttestation_d.Attestation:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluAttestation_d.Attestation_default()
def v_Attestation_bx(o: O.Boxed<FuluAttestation_d.Attestation>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_Attestation(v)
    case O.BNone{}: S.NullValue{}
def rep_Attestation_bx(o: O.Boxed<FuluAttestation_d.Attestation>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_Attestation_bx(o), O.BNone{}} : O.Boxed<FuluAttestation_d.Attestation>}, rep_Attestation(pjb_Attestation_bx(o), s))
# ---- AggregateAndProof (Type-kind container, 3 fields) ----
def pj_AggregateAndProof_1(o: FuluAggregateAndProof_d.AggregateAndProof) -> O.Boxed<FuluAttestation_d.Attestation>:
  match o:
    case FuluAggregateAndProof_d.AggregateAndProof{+x0, x1, +x2}: x1
def v_AggregateAndProof(o: FuluAggregateAndProof_d.AggregateAndProof) -> S.Value:
  match o:
    case FuluAggregateAndProof_d.AggregateAndProof{+x0, x1, +x2}: S.Sequence{S.Items{RN.v_u64(x0), S.Items{v_Attestation_bx(x1), S.Items{RN.v_b96(x2), S.EmptyItems{}}}}}
def rep_AggregateAndProof(o: FuluAggregateAndProof_d.AggregateAndProof, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x0 => DK.Ex(FuluBytes96_d.Bytes96, x2 => DK.P2({o == FuluAggregateAndProof_d.AggregateAndProof{x0, pj_AggregateAndProof_1(o), x2} : FuluAggregateAndProof_d.AggregateAndProof}, rep_Attestation_bx(pj_AggregateAndProof_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))))))
# ---- SignedAggregateAndProof (Type-kind container, 2 fields) ----
def pj_SignedAggregateAndProof_0(o: FuluSignedAggregateAndProof_d.SignedAggregateAndProof) -> FuluAggregateAndProof_d.AggregateAndProof:
  match o:
    case FuluSignedAggregateAndProof_d.SignedAggregateAndProof{x0, +x1}: x0
def v_SignedAggregateAndProof(o: FuluSignedAggregateAndProof_d.SignedAggregateAndProof) -> S.Value:
  match o:
    case FuluSignedAggregateAndProof_d.SignedAggregateAndProof{x0, +x1}: S.Sequence{S.Items{v_AggregateAndProof(x0), S.Items{RN.v_b96(x1), S.EmptyItems{}}}}
def rep_SignedAggregateAndProof(o: FuluSignedAggregateAndProof_d.SignedAggregateAndProof, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes96_d.Bytes96, x1 => DK.P2({o == FuluSignedAggregateAndProof_d.SignedAggregateAndProof{pj_SignedAggregateAndProof_0(o), x1} : FuluSignedAggregateAndProof_d.SignedAggregateAndProof}, rep_AggregateAndProof(pj_SignedAggregateAndProof_0(o), SH.Chain_head(SH.Container_fields(s)))))
# ---- PendingAttestation (Type-kind container, 4 fields) ----
def pj_PendingAttestation_0(o: FuluPendingAttestation_d.PendingAttestation) -> O.Bits:
  match o:
    case FuluPendingAttestation_d.PendingAttestation{x0, +x1, +x2, +x3}: x0
def v_PendingAttestation(o: FuluPendingAttestation_d.PendingAttestation) -> S.Value:
  match o:
    case FuluPendingAttestation_d.PendingAttestation{x0, +x1, +x2, +x3}: S.Sequence{S.Items{S.BitsValue{BO.bview(x0)}, S.Items{RN.v_AttestationData(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_u64(x3), S.EmptyItems{}}}}}}
def rep_PendingAttestation(o: FuluPendingAttestation_d.PendingAttestation, +s: S.Schema) -> Data:
  DK.Ex(FuluAttestationData_d.AttestationData, x1 => DK.Ex(O.U64, x2 => DK.Ex(O.U64, x3 => DK.P2({o == FuluPendingAttestation_d.PendingAttestation{pj_PendingAttestation_0(o), x1, x2, x3} : FuluPendingAttestation_d.PendingAttestation}, BO.rep_bits(pj_PendingAttestation_0(o), SH.Chain_head(SH.Container_fields(s)))))))
# ---- IndexedAttestation (Type-kind container, 3 fields) ----
def pj_IndexedAttestation_0(o: FuluIndexedAttestation_d.IndexedAttestation) -> O.Words:
  match o:
    case FuluIndexedAttestation_d.IndexedAttestation{x0, +x1, +x2}: x0
def v_IndexedAttestation(o: FuluIndexedAttestation_d.IndexedAttestation) -> S.Value:
  match o:
    case FuluIndexedAttestation_d.IndexedAttestation{x0, +x1, +x2}: S.Sequence{S.Items{UL.uview(x0), S.Items{RN.v_AttestationData(x1), S.Items{RN.v_b96(x2), S.EmptyItems{}}}}}
def rep_IndexedAttestation(o: FuluIndexedAttestation_d.IndexedAttestation, +s: S.Schema) -> Data:
  DK.Ex(FuluAttestationData_d.AttestationData, x1 => DK.Ex(FuluBytes96_d.Bytes96, x2 => DK.P2({o == FuluIndexedAttestation_d.IndexedAttestation{pj_IndexedAttestation_0(o), x1, x2} : FuluIndexedAttestation_d.IndexedAttestation}, UL.rep_ul(pj_IndexedAttestation_0(o), SH.Chain_head(SH.Container_fields(s))))))
# ---- box of IndexedAttestation ----
def pjb_IndexedAttestation_bx(o: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>) -> FuluIndexedAttestation_d.IndexedAttestation:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluIndexedAttestation_d.IndexedAttestation_default()
def v_IndexedAttestation_bx(o: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_IndexedAttestation(v)
    case O.BNone{}: S.NullValue{}
def rep_IndexedAttestation_bx(o: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_IndexedAttestation_bx(o), O.BNone{}} : O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>}, rep_IndexedAttestation(pjb_IndexedAttestation_bx(o), s))
# ---- AttesterSlashing (Type-kind container, 2 fields) ----
def pj_AttesterSlashing_0(o: FuluAttesterSlashing_d.AttesterSlashing) -> O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>:
  match o:
    case FuluAttesterSlashing_d.AttesterSlashing{x0, x1}: x0
def pj_AttesterSlashing_1(o: FuluAttesterSlashing_d.AttesterSlashing) -> O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>:
  match o:
    case FuluAttesterSlashing_d.AttesterSlashing{x0, x1}: x1
def v_AttesterSlashing(o: FuluAttesterSlashing_d.AttesterSlashing) -> S.Value:
  match o:
    case FuluAttesterSlashing_d.AttesterSlashing{x0, x1}: S.Sequence{S.Items{v_IndexedAttestation_bx(x0), S.Items{v_IndexedAttestation_bx(x1), S.EmptyItems{}}}}
def rep_AttesterSlashing(o: FuluAttesterSlashing_d.AttesterSlashing, +s: S.Schema) -> Data:
  DK.P2({o == FuluAttesterSlashing_d.AttesterSlashing{pj_AttesterSlashing_0(o), pj_AttesterSlashing_1(o)} : FuluAttesterSlashing_d.AttesterSlashing}, DK.P2(rep_IndexedAttestation_bx(pj_AttesterSlashing_0(o), SH.Chain_head(SH.Container_fields(s))), rep_IndexedAttestation_bx(pj_AttesterSlashing_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))))
# ---- SyncCommittee (Type-kind container, 2 fields) ----
def pj_SyncCommittee_0(o: FuluSyncCommittee_d.SyncCommittee) -> O.Words:
  match o:
    case FuluSyncCommittee_d.SyncCommittee{x0, +x1}: x0
def v_SyncCommittee(o: FuluSyncCommittee_d.SyncCommittee) -> S.Value:
  match o:
    case FuluSyncCommittee_d.SyncCommittee{x0, +x1}: S.Sequence{S.Items{E48.eview(x0), S.Items{RN.v_b48(x1), S.EmptyItems{}}}}
def rep_SyncCommittee(o: FuluSyncCommittee_d.SyncCommittee, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes48_d.Bytes48, x1 => DK.P2({o == FuluSyncCommittee_d.SyncCommittee{pj_SyncCommittee_0(o), x1} : FuluSyncCommittee_d.SyncCommittee}, E48.rep_ev(pj_SyncCommittee_0(o), SH.Chain_head(SH.Container_fields(s)))))
# ---- box of DepositData ----
def v_DepositData_bx(o: O.Boxed<FuluDepositData_d.DepositData>) -> S.Value:
  match o:
    case O.BSome{+v, rest}: RN.v_DepositData(v)
    case O.BNone{}: S.NullValue{}
def rep_DepositData_bx(o: O.Boxed<FuluDepositData_d.DepositData>, +s: S.Schema) -> Data:
  DK.Ex(FuluDepositData_d.DepositData, v => {o == O.BSome{v, O.BNone{}} : O.Boxed<FuluDepositData_d.DepositData>})
# ---- Deposit (Type-kind container, 2 fields) ----
def pj_Deposit_0(o: FuluDeposit_d.Deposit) -> O.Words:
  match o:
    case FuluDeposit_d.Deposit{x0, x1}: x0
def pj_Deposit_1(o: FuluDeposit_d.Deposit) -> O.Boxed<FuluDepositData_d.DepositData>:
  match o:
    case FuluDeposit_d.Deposit{x0, x1}: x1
def v_Deposit(o: FuluDeposit_d.Deposit) -> S.Value:
  match o:
    case FuluDeposit_d.Deposit{x0, x1}: S.Sequence{S.Items{PV.pview(x0), S.Items{v_DepositData_bx(x1), S.EmptyItems{}}}}
def rep_Deposit(o: FuluDeposit_d.Deposit, +s: S.Schema) -> Data:
  DK.P2({o == FuluDeposit_d.Deposit{pj_Deposit_0(o), pj_Deposit_1(o)} : FuluDeposit_d.Deposit}, DK.P2(PV.rep_pv(pj_Deposit_0(o), SH.Chain_head(SH.Container_fields(s))), rep_DepositData_bx(pj_Deposit_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))))
# ---- l8192_DepositRequest: list of DepositRequest (Data elements) ----
def xat_l8192_DepositRequest(W: List<&2, FuluDepositRequest_d.DepositRequest>, +i: Nat) -> FuluDepositRequest_d.DepositRequest:
  match W:
    case Nil{}: FuluDepositRequest_d.DepositRequest_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l8192_DepositRequest(t, j)
def xi_l8192_DepositRequest(k: Nat, +W: List<&2, FuluDepositRequest_d.DepositRequest>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN.v_DepositRequest(xat_l8192_DepositRequest(W, i)), xi_l8192_DepositRequest(q, W, 1n+i)}
def xlen_o_l8192_DepositRequest(o: Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq) -> U32:
  match o:
    case Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq{arr, +n}: n
def xv_l8192_DepositRequest(o: Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq) -> S.Value:
  match o:
    case Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq{arr, +n}: S.Sequence{xi_l8192_DepositRequest(U32.to_nat(n), F.array__slots(FuluDepositRequest_d.DepositRequest, F.array__freeze(FuluDepositRequest_d.DepositRequest, arr)), 0n)}
def rep_l8192_DepositRequest(o: Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<FuluDepositRequest_d.DepositRequest>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq{F.array__thaw(FuluDepositRequest_d.DepositRequest, t), N} : Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq},
    DK.P2({F.array__perfect(FuluDepositRequest_d.DepositRequest, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),
    {Nat.is_le(U32.to_nat(xlen_o_l8192_DepositRequest(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- l16_WithdrawalRequest: list of WithdrawalRequest (Data elements) ----
def xat_l16_WithdrawalRequest(W: List<&2, FuluWithdrawalRequest_d.WithdrawalRequest>, +i: Nat) -> FuluWithdrawalRequest_d.WithdrawalRequest:
  match W:
    case Nil{}: FuluWithdrawalRequest_d.WithdrawalRequest_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_WithdrawalRequest(t, j)
def xi_l16_WithdrawalRequest(k: Nat, +W: List<&2, FuluWithdrawalRequest_d.WithdrawalRequest>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN.v_WithdrawalRequest(xat_l16_WithdrawalRequest(W, i)), xi_l16_WithdrawalRequest(q, W, 1n+i)}
def xlen_o_l16_WithdrawalRequest(o: Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq) -> U32:
  match o:
    case Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq{arr, +n}: n
def xv_l16_WithdrawalRequest(o: Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq) -> S.Value:
  match o:
    case Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq{arr, +n}: S.Sequence{xi_l16_WithdrawalRequest(U32.to_nat(n), F.array__slots(FuluWithdrawalRequest_d.WithdrawalRequest, F.array__freeze(FuluWithdrawalRequest_d.WithdrawalRequest, arr)), 0n)}
def rep_l16_WithdrawalRequest(o: Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<FuluWithdrawalRequest_d.WithdrawalRequest>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq{F.array__thaw(FuluWithdrawalRequest_d.WithdrawalRequest, t), N} : Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq},
    DK.P2({F.array__perfect(FuluWithdrawalRequest_d.WithdrawalRequest, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),
    {Nat.is_le(U32.to_nat(xlen_o_l16_WithdrawalRequest(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- l2_ConsolidationRequest: list of ConsolidationRequest (Data elements) ----
def xat_l2_ConsolidationRequest(W: List<&2, FuluConsolidationRequest_d.ConsolidationRequest>, +i: Nat) -> FuluConsolidationRequest_d.ConsolidationRequest:
  match W:
    case Nil{}: FuluConsolidationRequest_d.ConsolidationRequest_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l2_ConsolidationRequest(t, j)
def xi_l2_ConsolidationRequest(k: Nat, +W: List<&2, FuluConsolidationRequest_d.ConsolidationRequest>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN.v_ConsolidationRequest(xat_l2_ConsolidationRequest(W, i)), xi_l2_ConsolidationRequest(q, W, 1n+i)}
def xlen_o_l2_ConsolidationRequest(o: Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq) -> U32:
  match o:
    case Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq{arr, +n}: n
def xv_l2_ConsolidationRequest(o: Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq) -> S.Value:
  match o:
    case Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq{arr, +n}: S.Sequence{xi_l2_ConsolidationRequest(U32.to_nat(n), F.array__slots(FuluConsolidationRequest_d.ConsolidationRequest, F.array__freeze(FuluConsolidationRequest_d.ConsolidationRequest, arr)), 0n)}
def rep_l2_ConsolidationRequest(o: Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<FuluConsolidationRequest_d.ConsolidationRequest>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq{F.array__thaw(FuluConsolidationRequest_d.ConsolidationRequest, t), N} : Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq},
    DK.P2({F.array__perfect(FuluConsolidationRequest_d.ConsolidationRequest, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),
    {Nat.is_le(U32.to_nat(xlen_o_l2_ConsolidationRequest(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- ExecutionRequests (Type-kind container, 3 fields) ----
def pj_ExecutionRequests_0(o: FuluExecutionRequests_d.ExecutionRequests) -> Fulu_list_DepositRequest_8192_d.l8192_DepositRequest_Seq:
  match o:
    case FuluExecutionRequests_d.ExecutionRequests{x0, x1, x2}: x0
def pj_ExecutionRequests_1(o: FuluExecutionRequests_d.ExecutionRequests) -> Fulu_list_WithdrawalRequest_16_d.l16_WithdrawalRequest_Seq:
  match o:
    case FuluExecutionRequests_d.ExecutionRequests{x0, x1, x2}: x1
def pj_ExecutionRequests_2(o: FuluExecutionRequests_d.ExecutionRequests) -> Fulu_list_ConsolidationRequest_2_d.l2_ConsolidationRequest_Seq:
  match o:
    case FuluExecutionRequests_d.ExecutionRequests{x0, x1, x2}: x2
def v_ExecutionRequests(o: FuluExecutionRequests_d.ExecutionRequests) -> S.Value:
  match o:
    case FuluExecutionRequests_d.ExecutionRequests{x0, x1, x2}: S.Sequence{S.Items{xv_l8192_DepositRequest(x0), S.Items{xv_l16_WithdrawalRequest(x1), S.Items{xv_l2_ConsolidationRequest(x2), S.EmptyItems{}}}}}
def rep_ExecutionRequests(o: FuluExecutionRequests_d.ExecutionRequests, +s: S.Schema) -> Data:
  DK.P2({o == FuluExecutionRequests_d.ExecutionRequests{pj_ExecutionRequests_0(o), pj_ExecutionRequests_1(o), pj_ExecutionRequests_2(o)} : FuluExecutionRequests_d.ExecutionRequests}, DK.P2(rep_l8192_DepositRequest(pj_ExecutionRequests_0(o), SH.Chain_head(SH.Container_fields(s))), DK.P2(rep_l16_WithdrawalRequest(pj_ExecutionRequests_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), rep_l2_ConsolidationRequest(pj_ExecutionRequests_2(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
# ---- ExecutionPayloadHeader (Type-kind container, 17 fields, in groups) ----
def pj_ExecutionPayloadHeader_4(o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader) -> O.Words:
  match o:
    case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{+x8, +x9, x10, +x11, +x12, +x13, +x14, +x15}:
              match g2:
                case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{+x16}:
                  x4
def pj_ExecutionPayloadHeader_10(o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader) -> O.Words:
  match o:
    case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{+x8, +x9, x10, +x11, +x12, +x13, +x14, +x15}:
              match g2:
                case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{+x16}:
                  x10
def v_ExecutionPayloadHeader(o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader) -> S.Value:
  match o:
    case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{+x8, +x9, x10, +x11, +x12, +x13, +x14, +x15}:
              match g2:
                case FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{+x16}:
                  S.Sequence{S.Items{RN.v_b32(x0), S.Items{RN.v_b20(x1), S.Items{RN.v_b32(x2), S.Items{RN.v_b32(x3), S.Items{S.BytesValue{WO.wview(x4)}, S.Items{RN.v_b32(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.Items{RN.v_u64(x8), S.Items{RN.v_u64(x9), S.Items{S.BytesValue{WO.wview(x10)}, S.Items{RN.v_u256(x11), S.Items{RN.v_b32(x12), S.Items{RN.v_b32(x13), S.Items{RN.v_b32(x14), S.Items{RN.v_u64(x15), S.Items{RN.v_u64(x16), S.EmptyItems{}}}}}}}}}}}}}}}}}}}
def rep_ExecutionPayloadHeader(o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes32_d.Bytes32, x0 => DK.Ex(FuluBytes20_d.Bytes20, x1 => DK.Ex(FuluBytes32_d.Bytes32, x2 => DK.Ex(FuluBytes32_d.Bytes32, x3 => DK.Ex(FuluBytes32_d.Bytes32, x5 => DK.Ex(O.U64, x6 => DK.Ex(O.U64, x7 => DK.Ex(O.U64, x8 => DK.Ex(O.U64, x9 => DK.Ex(uint256_d.Uint256, x11 => DK.Ex(FuluBytes32_d.Bytes32, x12 => DK.Ex(FuluBytes32_d.Bytes32, x13 => DK.Ex(FuluBytes32_d.Bytes32, x14 => DK.Ex(O.U64, x15 => DK.Ex(O.U64, x16 => DK.P2({o == FuluExecutionPayloadHeader_d.ExecutionPayloadHeader{FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g0{x0, x1, x2, x3, pj_ExecutionPayloadHeader_4(o), x5, x6, x7}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g1{x8, x9, pj_ExecutionPayloadHeader_10(o), x11, x12, x13, x14, x15}, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_g2{x16}} : FuluExecutionPayloadHeader_d.ExecutionPayloadHeader}, DK.P2(WO.rep_bv(pj_ExecutionPayloadHeader_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), LO.rep_bl(pj_ExecutionPayloadHeader_10(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))))))))))))))))))
# ---- box of bl1073741824 (byte storage) ----
def pjb_bl1073741824_bx(o: O.Boxed<O.Words>) -> O.Words:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluTransaction_d.bl1073741824_default()
def v_bl1073741824_bx(o: O.Boxed<O.Words>) -> S.Value:
  match o:
    case O.BSome{v, rest}: S.BytesValue{WO.wview(v)}
    case O.BNone{}: S.NullValue{}
def rep_bl1073741824_bx(o: O.Boxed<O.Words>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_bl1073741824_bx(o), O.BNone{}} : O.Boxed<O.Words>}, LO.rep_bl(pjb_bl1073741824_bx(o), s))
def th_bl1073741824_bx(m: MB<WMr>) -> O.Boxed<O.Words>:
  match m:
    case MSome{+v}: O.BSome{th_w(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_bl1073741824_bx(x: O.Boxed<O.Words>) -> MB<WMr>:
  match x:
    case O.BSome{v, rest}: MSome{fz_w(v)}
    case O.BNone{}: MNone{}
# ---- l1048576_bl1073741824: list of bl1073741824_bx (Type-kind elements, through mirrors) ----
def am_l1048576_bl1073741824(t: F.array__Tree<MB<WMr>>) -> Array<O.Boxed<O.Words>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_bl1073741824_bx(x)}
    case F.TNode{l, r}: ANode{am_l1048576_bl1073741824(l), am_l1048576_bl1073741824(r)}

def xat_l1048576_bl1073741824(W: List<&2, MB<WMr>>, +i: Nat) -> MB<WMr>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l1048576_bl1073741824(t, j)
def ereps_l1048576_bl1073741824(k: Nat, +W: List<&2, MB<WMr>>, +i: Nat, +sE: S.Schema) -> Data:
  match k:
    case 0n: {True{} == True{} : Bool}
    case 1n+q: DK.P2(rep_bl1073741824_bx(th_bl1073741824_bx(xat_l1048576_bl1073741824(W, i)), sE), ereps_l1048576_bl1073741824(q, W, 1n+i, sE))
def xi_l1048576_bl1073741824(k: Nat, +W: List<&2, MB<WMr>>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{v_bl1073741824_bx(th_bl1073741824_bx(xat_l1048576_bl1073741824(W, i))), xi_l1048576_bl1073741824(q, W, 1n+i)}
def tfz_l1048576_bl1073741824(a: Array<O.Boxed<O.Words>>) -> F.array__Tree<MB<WMr>>:
  match a:
    case ALeaf{x}: F.TLeaf{fz_bl1073741824_bx(x)}
    case ANode{l, r}: F.TNode{tfz_l1048576_bl1073741824(l), tfz_l1048576_bl1073741824(r)}
def xlen_o_l1048576_bl1073741824(o: Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq) -> U32:
  match o:
    case Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{arr, +n}: n
def xv_l1048576_bl1073741824(o: Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq) -> S.Value:
  match o:
    case Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{arr, +n}: S.Sequence{xi_l1048576_bl1073741824(U32.to_nat(n), F.array__slots(MB<WMr>, tfz_l1048576_bl1073741824(arr)), 0n)}
def rep_l1048576_bl1073741824(o: Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<MB<WMr>>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq{am_l1048576_bl1073741824(t), N} : Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq},
    DK.P2({F.array__perfect(MB<WMr>, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},
          ereps_l1048576_bl1073741824(U32.to_nat(N), F.array__slots(MB<WMr>, t), 0n, SH.ListOf_element(s))))))))),
    {Nat.is_le(U32.to_nat(xlen_o_l1048576_bl1073741824(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- l16_Withdrawal: list of Withdrawal (Data elements) ----
def xat_l16_Withdrawal(W: List<&2, FuluWithdrawal_d.Withdrawal>, +i: Nat) -> FuluWithdrawal_d.Withdrawal:
  match W:
    case Nil{}: FuluWithdrawal_d.Withdrawal_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_Withdrawal(t, j)
def xi_l16_Withdrawal(k: Nat, +W: List<&2, FuluWithdrawal_d.Withdrawal>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN.v_Withdrawal(xat_l16_Withdrawal(W, i)), xi_l16_Withdrawal(q, W, 1n+i)}
def xlen_o_l16_Withdrawal(o: Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq) -> U32:
  match o:
    case Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq{arr, +n}: n
def xv_l16_Withdrawal(o: Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq) -> S.Value:
  match o:
    case Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq{arr, +n}: S.Sequence{xi_l16_Withdrawal(U32.to_nat(n), F.array__slots(FuluWithdrawal_d.Withdrawal, F.array__freeze(FuluWithdrawal_d.Withdrawal, arr)), 0n)}
def rep_l16_Withdrawal(o: Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<FuluWithdrawal_d.Withdrawal>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq{F.array__thaw(FuluWithdrawal_d.Withdrawal, t), N} : Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq},
    DK.P2({F.array__perfect(FuluWithdrawal_d.Withdrawal, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),
    {Nat.is_le(U32.to_nat(xlen_o_l16_Withdrawal(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- ExecutionPayload (Type-kind container, 17 fields, in groups) ----
def pj_ExecutionPayload_4(o: FuluExecutionPayload_d.ExecutionPayload) -> O.Words:
  match o:
    case FuluExecutionPayload_d.ExecutionPayload{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayload_d.ExecutionPayload_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayload_d.ExecutionPayload_g1{+x8, +x9, x10, +x11, +x12, x13, x14, +x15}:
              match g2:
                case FuluExecutionPayload_d.ExecutionPayload_g2{+x16}:
                  x4
def pj_ExecutionPayload_10(o: FuluExecutionPayload_d.ExecutionPayload) -> O.Words:
  match o:
    case FuluExecutionPayload_d.ExecutionPayload{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayload_d.ExecutionPayload_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayload_d.ExecutionPayload_g1{+x8, +x9, x10, +x11, +x12, x13, x14, +x15}:
              match g2:
                case FuluExecutionPayload_d.ExecutionPayload_g2{+x16}:
                  x10
def pj_ExecutionPayload_13(o: FuluExecutionPayload_d.ExecutionPayload) -> Fulu_list_bytelist_1073741824_1048576_d.l1048576_bl1073741824_Seq:
  match o:
    case FuluExecutionPayload_d.ExecutionPayload{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayload_d.ExecutionPayload_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayload_d.ExecutionPayload_g1{+x8, +x9, x10, +x11, +x12, x13, x14, +x15}:
              match g2:
                case FuluExecutionPayload_d.ExecutionPayload_g2{+x16}:
                  x13
def pj_ExecutionPayload_14(o: FuluExecutionPayload_d.ExecutionPayload) -> Fulu_list_Withdrawal_16_d.l16_Withdrawal_Seq:
  match o:
    case FuluExecutionPayload_d.ExecutionPayload{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayload_d.ExecutionPayload_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayload_d.ExecutionPayload_g1{+x8, +x9, x10, +x11, +x12, x13, x14, +x15}:
              match g2:
                case FuluExecutionPayload_d.ExecutionPayload_g2{+x16}:
                  x14
def v_ExecutionPayload(o: FuluExecutionPayload_d.ExecutionPayload) -> S.Value:
  match o:
    case FuluExecutionPayload_d.ExecutionPayload{g0, g1, +g2}:
      match g0:
        case FuluExecutionPayload_d.ExecutionPayload_g0{+x0, +x1, +x2, +x3, x4, +x5, +x6, +x7}:
          match g1:
            case FuluExecutionPayload_d.ExecutionPayload_g1{+x8, +x9, x10, +x11, +x12, x13, x14, +x15}:
              match g2:
                case FuluExecutionPayload_d.ExecutionPayload_g2{+x16}:
                  S.Sequence{S.Items{RN.v_b32(x0), S.Items{RN.v_b20(x1), S.Items{RN.v_b32(x2), S.Items{RN.v_b32(x3), S.Items{S.BytesValue{WO.wview(x4)}, S.Items{RN.v_b32(x5), S.Items{RN.v_u64(x6), S.Items{RN.v_u64(x7), S.Items{RN.v_u64(x8), S.Items{RN.v_u64(x9), S.Items{S.BytesValue{WO.wview(x10)}, S.Items{RN.v_u256(x11), S.Items{RN.v_b32(x12), S.Items{xv_l1048576_bl1073741824(x13), S.Items{xv_l16_Withdrawal(x14), S.Items{RN.v_u64(x15), S.Items{RN.v_u64(x16), S.EmptyItems{}}}}}}}}}}}}}}}}}}}
def rep_ExecutionPayload(o: FuluExecutionPayload_d.ExecutionPayload, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes32_d.Bytes32, x0 => DK.Ex(FuluBytes20_d.Bytes20, x1 => DK.Ex(FuluBytes32_d.Bytes32, x2 => DK.Ex(FuluBytes32_d.Bytes32, x3 => DK.Ex(FuluBytes32_d.Bytes32, x5 => DK.Ex(O.U64, x6 => DK.Ex(O.U64, x7 => DK.Ex(O.U64, x8 => DK.Ex(O.U64, x9 => DK.Ex(uint256_d.Uint256, x11 => DK.Ex(FuluBytes32_d.Bytes32, x12 => DK.Ex(O.U64, x15 => DK.Ex(O.U64, x16 => DK.P2({o == FuluExecutionPayload_d.ExecutionPayload{FuluExecutionPayload_d.ExecutionPayload_g0{x0, x1, x2, x3, pj_ExecutionPayload_4(o), x5, x6, x7}, FuluExecutionPayload_d.ExecutionPayload_g1{x8, x9, pj_ExecutionPayload_10(o), x11, x12, pj_ExecutionPayload_13(o), pj_ExecutionPayload_14(o), x15}, FuluExecutionPayload_d.ExecutionPayload_g2{x16}} : FuluExecutionPayload_d.ExecutionPayload}, DK.P2(WO.rep_bv(pj_ExecutionPayload_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), DK.P2(LO.rep_bl(pj_ExecutionPayload_10(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))), DK.P2(rep_l1048576_bl1073741824(pj_ExecutionPayload_13(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))))), rep_l16_Withdrawal(pj_ExecutionPayload_14(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))))))))))))))))))))))
# ---- box of ExecutionPayloadHeader ----
def pjb_ExecutionPayloadHeader_bx(o: O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>) -> FuluExecutionPayloadHeader_d.ExecutionPayloadHeader:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader_default()
def v_ExecutionPayloadHeader_bx(o: O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_ExecutionPayloadHeader(v)
    case O.BNone{}: S.NullValue{}
def rep_ExecutionPayloadHeader_bx(o: O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_ExecutionPayloadHeader_bx(o), O.BNone{}} : O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>}, rep_ExecutionPayloadHeader(pjb_ExecutionPayloadHeader_bx(o), s))
# ---- LightClientHeader (Type-kind container, 3 fields) ----
def pj_LightClientHeader_1(o: FuluLightClientHeader_d.LightClientHeader) -> O.Boxed<FuluExecutionPayloadHeader_d.ExecutionPayloadHeader>:
  match o:
    case FuluLightClientHeader_d.LightClientHeader{+x0, x1, x2}: x1
def pj_LightClientHeader_2(o: FuluLightClientHeader_d.LightClientHeader) -> O.Words:
  match o:
    case FuluLightClientHeader_d.LightClientHeader{+x0, x1, x2}: x2
def v_LightClientHeader(o: FuluLightClientHeader_d.LightClientHeader) -> S.Value:
  match o:
    case FuluLightClientHeader_d.LightClientHeader{+x0, x1, x2}: S.Sequence{S.Items{RN.v_BeaconBlockHeader(x0), S.Items{v_ExecutionPayloadHeader_bx(x1), S.Items{PV.pview(x2), S.EmptyItems{}}}}}
def rep_LightClientHeader(o: FuluLightClientHeader_d.LightClientHeader, +s: S.Schema) -> Data:
  DK.Ex(FuluBeaconBlockHeader_d.BeaconBlockHeader, x0 => DK.P2({o == FuluLightClientHeader_d.LightClientHeader{x0, pj_LightClientHeader_1(o), pj_LightClientHeader_2(o)} : FuluLightClientHeader_d.LightClientHeader}, DK.P2(rep_ExecutionPayloadHeader_bx(pj_LightClientHeader_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), PV.rep_pv(pj_LightClientHeader_2(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
# ---- box of SyncAggregate ----
def v_SyncAggregate_bx(o: O.Boxed<FuluSyncAggregate_d.SyncAggregate>) -> S.Value:
  match o:
    case O.BSome{+v, rest}: RN.v_SyncAggregate(v)
    case O.BNone{}: S.NullValue{}
def rep_SyncAggregate_bx(o: O.Boxed<FuluSyncAggregate_d.SyncAggregate>, +s: S.Schema) -> Data:
  DK.Ex(FuluSyncAggregate_d.SyncAggregate, v => {o == O.BSome{v, O.BNone{}} : O.Boxed<FuluSyncAggregate_d.SyncAggregate>})
# ---- LightClientOptimisticUpdate (Type-kind container, 3 fields) ----
def pj_LightClientOptimisticUpdate_0(o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate) -> FuluLightClientHeader_d.LightClientHeader:
  match o:
    case FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{x0, x1, +x2}: x0
def pj_LightClientOptimisticUpdate_1(o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate) -> O.Boxed<FuluSyncAggregate_d.SyncAggregate>:
  match o:
    case FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{x0, x1, +x2}: x1
def v_LightClientOptimisticUpdate(o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate) -> S.Value:
  match o:
    case FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{x0, x1, +x2}: S.Sequence{S.Items{v_LightClientHeader(x0), S.Items{v_SyncAggregate_bx(x1), S.Items{RN.v_u64(x2), S.EmptyItems{}}}}}
def rep_LightClientOptimisticUpdate(o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x2 => DK.P2({o == FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate{pj_LightClientOptimisticUpdate_0(o), pj_LightClientOptimisticUpdate_1(o), x2} : FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate}, DK.P2(rep_LightClientHeader(pj_LightClientOptimisticUpdate_0(o), SH.Chain_head(SH.Container_fields(s))), rep_SyncAggregate_bx(pj_LightClientOptimisticUpdate_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))))))
# ---- LightClientFinalityUpdate (Type-kind container, 5 fields) ----
def pj_LightClientFinalityUpdate_0(o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate) -> FuluLightClientHeader_d.LightClientHeader:
  match o:
    case FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{x0, x1, x2, x3, +x4}: x0
def pj_LightClientFinalityUpdate_1(o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate) -> FuluLightClientHeader_d.LightClientHeader:
  match o:
    case FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{x0, x1, x2, x3, +x4}: x1
def pj_LightClientFinalityUpdate_2(o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate) -> O.Words:
  match o:
    case FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{x0, x1, x2, x3, +x4}: x2
def pj_LightClientFinalityUpdate_3(o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate) -> O.Boxed<FuluSyncAggregate_d.SyncAggregate>:
  match o:
    case FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{x0, x1, x2, x3, +x4}: x3
def v_LightClientFinalityUpdate(o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate) -> S.Value:
  match o:
    case FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{x0, x1, x2, x3, +x4}: S.Sequence{S.Items{v_LightClientHeader(x0), S.Items{v_LightClientHeader(x1), S.Items{PV.pview(x2), S.Items{v_SyncAggregate_bx(x3), S.Items{RN.v_u64(x4), S.EmptyItems{}}}}}}}
def rep_LightClientFinalityUpdate(o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x4 => DK.P2({o == FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate{pj_LightClientFinalityUpdate_0(o), pj_LightClientFinalityUpdate_1(o), pj_LightClientFinalityUpdate_2(o), pj_LightClientFinalityUpdate_3(o), x4} : FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate}, DK.P2(rep_LightClientHeader(pj_LightClientFinalityUpdate_0(o), SH.Chain_head(SH.Container_fields(s))), DK.P2(rep_LightClientHeader(pj_LightClientFinalityUpdate_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), DK.P2(PV.rep_pv(pj_LightClientFinalityUpdate_2(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), rep_SyncAggregate_bx(pj_LightClientFinalityUpdate_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))
# ---- LightClientUpdate (Type-kind container, 7 fields) ----
def pj_LightClientUpdate_0(o: FuluLightClientUpdate_d.LightClientUpdate) -> FuluLightClientHeader_d.LightClientHeader:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: x0
def pj_LightClientUpdate_1(o: FuluLightClientUpdate_d.LightClientUpdate) -> FuluSyncCommittee_d.SyncCommittee:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: x1
def pj_LightClientUpdate_2(o: FuluLightClientUpdate_d.LightClientUpdate) -> O.Words:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: x2
def pj_LightClientUpdate_3(o: FuluLightClientUpdate_d.LightClientUpdate) -> FuluLightClientHeader_d.LightClientHeader:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: x3
def pj_LightClientUpdate_4(o: FuluLightClientUpdate_d.LightClientUpdate) -> O.Words:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: x4
def pj_LightClientUpdate_5(o: FuluLightClientUpdate_d.LightClientUpdate) -> O.Boxed<FuluSyncAggregate_d.SyncAggregate>:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: x5
def v_LightClientUpdate(o: FuluLightClientUpdate_d.LightClientUpdate) -> S.Value:
  match o:
    case FuluLightClientUpdate_d.LightClientUpdate{x0, x1, x2, x3, x4, x5, +x6}: S.Sequence{S.Items{v_LightClientHeader(x0), S.Items{v_SyncCommittee(x1), S.Items{PV.pview(x2), S.Items{v_LightClientHeader(x3), S.Items{PV.pview(x4), S.Items{v_SyncAggregate_bx(x5), S.Items{RN.v_u64(x6), S.EmptyItems{}}}}}}}}}
def rep_LightClientUpdate(o: FuluLightClientUpdate_d.LightClientUpdate, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x6 => DK.P2({o == FuluLightClientUpdate_d.LightClientUpdate{pj_LightClientUpdate_0(o), pj_LightClientUpdate_1(o), pj_LightClientUpdate_2(o), pj_LightClientUpdate_3(o), pj_LightClientUpdate_4(o), pj_LightClientUpdate_5(o), x6} : FuluLightClientUpdate_d.LightClientUpdate}, DK.P2(rep_LightClientHeader(pj_LightClientUpdate_0(o), SH.Chain_head(SH.Container_fields(s))), DK.P2(rep_SyncCommittee(pj_LightClientUpdate_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), DK.P2(PV.rep_pv(pj_LightClientUpdate_2(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), DK.P2(rep_LightClientHeader(pj_LightClientUpdate_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), DK.P2(PV.rep_pv(pj_LightClientUpdate_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), rep_SyncAggregate_bx(pj_LightClientUpdate_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))))
# ---- LightClientBootstrap (Type-kind container, 3 fields) ----
def pj_LightClientBootstrap_0(o: FuluLightClientBootstrap_d.LightClientBootstrap) -> FuluLightClientHeader_d.LightClientHeader:
  match o:
    case FuluLightClientBootstrap_d.LightClientBootstrap{x0, x1, x2}: x0
def pj_LightClientBootstrap_1(o: FuluLightClientBootstrap_d.LightClientBootstrap) -> FuluSyncCommittee_d.SyncCommittee:
  match o:
    case FuluLightClientBootstrap_d.LightClientBootstrap{x0, x1, x2}: x1
def pj_LightClientBootstrap_2(o: FuluLightClientBootstrap_d.LightClientBootstrap) -> O.Words:
  match o:
    case FuluLightClientBootstrap_d.LightClientBootstrap{x0, x1, x2}: x2
def v_LightClientBootstrap(o: FuluLightClientBootstrap_d.LightClientBootstrap) -> S.Value:
  match o:
    case FuluLightClientBootstrap_d.LightClientBootstrap{x0, x1, x2}: S.Sequence{S.Items{v_LightClientHeader(x0), S.Items{v_SyncCommittee(x1), S.Items{PV.pview(x2), S.EmptyItems{}}}}}
def rep_LightClientBootstrap(o: FuluLightClientBootstrap_d.LightClientBootstrap, +s: S.Schema) -> Data:
  DK.P2({o == FuluLightClientBootstrap_d.LightClientBootstrap{pj_LightClientBootstrap_0(o), pj_LightClientBootstrap_1(o), pj_LightClientBootstrap_2(o)} : FuluLightClientBootstrap_d.LightClientBootstrap}, DK.P2(rep_LightClientHeader(pj_LightClientBootstrap_0(o), SH.Chain_head(SH.Container_fields(s))), DK.P2(rep_SyncCommittee(pj_LightClientBootstrap_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), PV.rep_pv(pj_LightClientBootstrap_2(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))
# ---- box of ProposerSlashing ----
def pjb_ProposerSlashing_bx(o: O.Boxed<FuluProposerSlashing_d.ProposerSlashing>) -> FuluProposerSlashing_d.ProposerSlashing:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluProposerSlashing_d.ProposerSlashing_default()
def v_ProposerSlashing_bx(o: O.Boxed<FuluProposerSlashing_d.ProposerSlashing>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_ProposerSlashing(v)
    case O.BNone{}: S.NullValue{}
def rep_ProposerSlashing_bx(o: O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_ProposerSlashing_bx(o), O.BNone{}} : O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}, rep_ProposerSlashing(pjb_ProposerSlashing_bx(o), s))
def mfz_SignedBeaconBlockHeader_bx(x: O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>) -> FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader:
  match x:
    case O.BSome{+v, rest}: v
    case O.BNone{}: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader_default()

# ---- Data mirror of ProposerSlashing ----
type M_ProposerSlashing is Data:
  M_ProposerSlashing{a0: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader, a1: FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader}
def th_ProposerSlashing(m: M_ProposerSlashing) -> FuluProposerSlashing_d.ProposerSlashing:
  match m:
    case M_ProposerSlashing{+a0, +a1}: FuluProposerSlashing_d.ProposerSlashing{O.BSome{a0, O.BNone{}}, O.BSome{a1, O.BNone{}}}
def fz_ProposerSlashing(x: FuluProposerSlashing_d.ProposerSlashing) -> M_ProposerSlashing:
  match x:
    case FuluProposerSlashing_d.ProposerSlashing{x0, x1}: M_ProposerSlashing{mfz_SignedBeaconBlockHeader_bx(x0), mfz_SignedBeaconBlockHeader_bx(x1)}
def th_ProposerSlashing_bx(m: MB<M_ProposerSlashing>) -> O.Boxed<FuluProposerSlashing_d.ProposerSlashing>:
  match m:
    case MSome{+v}: O.BSome{th_ProposerSlashing(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_ProposerSlashing_bx(x: O.Boxed<FuluProposerSlashing_d.ProposerSlashing>) -> MB<M_ProposerSlashing>:
  match x:
    case O.BSome{v, rest}: MSome{fz_ProposerSlashing(v)}
    case O.BNone{}: MNone{}
# ---- l16_ProposerSlashing: list of ProposerSlashing_bx (Type-kind elements, through mirrors) ----
def am_l16_ProposerSlashing(t: F.array__Tree<MB<M_ProposerSlashing>>) -> Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_ProposerSlashing_bx(x)}
    case F.TNode{l, r}: ANode{am_l16_ProposerSlashing(l), am_l16_ProposerSlashing(r)}

def xat_l16_ProposerSlashing(W: List<&2, MB<M_ProposerSlashing>>, +i: Nat) -> MB<M_ProposerSlashing>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_ProposerSlashing(t, j)
def ereps_l16_ProposerSlashing(k: Nat, +W: List<&2, MB<M_ProposerSlashing>>, +i: Nat, +sE: S.Schema) -> Data:
  match k:
    case 0n: {True{} == True{} : Bool}
    case 1n+q: DK.P2(rep_ProposerSlashing_bx(th_ProposerSlashing_bx(xat_l16_ProposerSlashing(W, i)), sE), ereps_l16_ProposerSlashing(q, W, 1n+i, sE))
def xi_l16_ProposerSlashing(k: Nat, +W: List<&2, MB<M_ProposerSlashing>>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{v_ProposerSlashing_bx(th_ProposerSlashing_bx(xat_l16_ProposerSlashing(W, i))), xi_l16_ProposerSlashing(q, W, 1n+i)}
def tfz_l16_ProposerSlashing(a: Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>) -> F.array__Tree<MB<M_ProposerSlashing>>:
  match a:
    case ALeaf{x}: F.TLeaf{fz_ProposerSlashing_bx(x)}
    case ANode{l, r}: F.TNode{tfz_l16_ProposerSlashing(l), tfz_l16_ProposerSlashing(r)}
def xlen_o_l16_ProposerSlashing(o: Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq) -> U32:
  match o:
    case Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{arr, +n}: n
def xv_l16_ProposerSlashing(o: Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq) -> S.Value:
  match o:
    case Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{arr, +n}: S.Sequence{xi_l16_ProposerSlashing(U32.to_nat(n), F.array__slots(MB<M_ProposerSlashing>, tfz_l16_ProposerSlashing(arr)), 0n)}
def rep_l16_ProposerSlashing(o: Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<MB<M_ProposerSlashing>>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq{am_l16_ProposerSlashing(t), N} : Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq},
    DK.P2({F.array__perfect(MB<M_ProposerSlashing>, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},
          ereps_l16_ProposerSlashing(U32.to_nat(N), F.array__slots(MB<M_ProposerSlashing>, t), 0n, SH.ListOf_element(s))))))))),
    {Nat.is_le(U32.to_nat(xlen_o_l16_ProposerSlashing(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- box of AttesterSlashing ----
def pjb_AttesterSlashing_bx(o: O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>) -> FuluAttesterSlashing_d.AttesterSlashing:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluAttesterSlashing_d.AttesterSlashing_default()
def v_AttesterSlashing_bx(o: O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_AttesterSlashing(v)
    case O.BNone{}: S.NullValue{}
def rep_AttesterSlashing_bx(o: O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_AttesterSlashing_bx(o), O.BNone{}} : O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}, rep_AttesterSlashing(pjb_AttesterSlashing_bx(o), s))
# ---- Data mirror of IndexedAttestation ----
type M_IndexedAttestation is Data:
  M_IndexedAttestation{a0: WMr, a1: FuluAttestationData_d.AttestationData, a2: FuluBytes96_d.Bytes96}
def th_IndexedAttestation(m: M_IndexedAttestation) -> FuluIndexedAttestation_d.IndexedAttestation:
  match m:
    case M_IndexedAttestation{+a0, +a1, +a2}: FuluIndexedAttestation_d.IndexedAttestation{th_w(a0), a1, a2}
def fz_IndexedAttestation(x: FuluIndexedAttestation_d.IndexedAttestation) -> M_IndexedAttestation:
  match x:
    case FuluIndexedAttestation_d.IndexedAttestation{x0, +x1, +x2}: M_IndexedAttestation{fz_w(x0), x1, x2}
def mfz_IndexedAttestation_bx(x: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>) -> M_IndexedAttestation:
  match x:
    case O.BSome{v, rest}: fz_IndexedAttestation(v)
    case O.BNone{}: fz_IndexedAttestation(FuluIndexedAttestation_d.IndexedAttestation_default())
def th_IndexedAttestation_bx(m: MB<M_IndexedAttestation>) -> O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>:
  match m:
    case MSome{+v}: O.BSome{th_IndexedAttestation(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_IndexedAttestation_bx(x: O.Boxed<FuluIndexedAttestation_d.IndexedAttestation>) -> MB<M_IndexedAttestation>:
  match x:
    case O.BSome{v, rest}: MSome{fz_IndexedAttestation(v)}
    case O.BNone{}: MNone{}
# ---- Data mirror of AttesterSlashing ----
type M_AttesterSlashing is Data:
  M_AttesterSlashing{a0: M_IndexedAttestation, a1: M_IndexedAttestation}
def th_AttesterSlashing(m: M_AttesterSlashing) -> FuluAttesterSlashing_d.AttesterSlashing:
  match m:
    case M_AttesterSlashing{+a0, +a1}: FuluAttesterSlashing_d.AttesterSlashing{O.BSome{th_IndexedAttestation(a0), O.BNone{}}, O.BSome{th_IndexedAttestation(a1), O.BNone{}}}
def fz_AttesterSlashing(x: FuluAttesterSlashing_d.AttesterSlashing) -> M_AttesterSlashing:
  match x:
    case FuluAttesterSlashing_d.AttesterSlashing{x0, x1}: M_AttesterSlashing{mfz_IndexedAttestation_bx(x0), mfz_IndexedAttestation_bx(x1)}
def th_AttesterSlashing_bx(m: MB<M_AttesterSlashing>) -> O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>:
  match m:
    case MSome{+v}: O.BSome{th_AttesterSlashing(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_AttesterSlashing_bx(x: O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>) -> MB<M_AttesterSlashing>:
  match x:
    case O.BSome{v, rest}: MSome{fz_AttesterSlashing(v)}
    case O.BNone{}: MNone{}
# ---- l1_AttesterSlashing: list of AttesterSlashing_bx (Type-kind elements, through mirrors) ----
def am_l1_AttesterSlashing(t: F.array__Tree<MB<M_AttesterSlashing>>) -> Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_AttesterSlashing_bx(x)}
    case F.TNode{l, r}: ANode{am_l1_AttesterSlashing(l), am_l1_AttesterSlashing(r)}

def xat_l1_AttesterSlashing(W: List<&2, MB<M_AttesterSlashing>>, +i: Nat) -> MB<M_AttesterSlashing>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l1_AttesterSlashing(t, j)
def ereps_l1_AttesterSlashing(k: Nat, +W: List<&2, MB<M_AttesterSlashing>>, +i: Nat, +sE: S.Schema) -> Data:
  match k:
    case 0n: {True{} == True{} : Bool}
    case 1n+q: DK.P2(rep_AttesterSlashing_bx(th_AttesterSlashing_bx(xat_l1_AttesterSlashing(W, i)), sE), ereps_l1_AttesterSlashing(q, W, 1n+i, sE))
def xi_l1_AttesterSlashing(k: Nat, +W: List<&2, MB<M_AttesterSlashing>>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{v_AttesterSlashing_bx(th_AttesterSlashing_bx(xat_l1_AttesterSlashing(W, i))), xi_l1_AttesterSlashing(q, W, 1n+i)}
def tfz_l1_AttesterSlashing(a: Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>) -> F.array__Tree<MB<M_AttesterSlashing>>:
  match a:
    case ALeaf{x}: F.TLeaf{fz_AttesterSlashing_bx(x)}
    case ANode{l, r}: F.TNode{tfz_l1_AttesterSlashing(l), tfz_l1_AttesterSlashing(r)}
def xlen_o_l1_AttesterSlashing(o: Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq) -> U32:
  match o:
    case Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{arr, +n}: n
def xv_l1_AttesterSlashing(o: Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq) -> S.Value:
  match o:
    case Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{arr, +n}: S.Sequence{xi_l1_AttesterSlashing(U32.to_nat(n), F.array__slots(MB<M_AttesterSlashing>, tfz_l1_AttesterSlashing(arr)), 0n)}
def rep_l1_AttesterSlashing(o: Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<MB<M_AttesterSlashing>>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq{am_l1_AttesterSlashing(t), N} : Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq},
    DK.P2({F.array__perfect(MB<M_AttesterSlashing>, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},
          ereps_l1_AttesterSlashing(U32.to_nat(N), F.array__slots(MB<M_AttesterSlashing>, t), 0n, SH.ListOf_element(s))))))))),
    {Nat.is_le(U32.to_nat(xlen_o_l1_AttesterSlashing(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- Data mirror of Attestation ----
type M_Attestation is Data:
  M_Attestation{a0: BMr, a1: FuluAttestationData_d.AttestationData, a2: FuluBytes96_d.Bytes96, a3: Fulu_bitvector_64_d.Bitvector64}
def th_Attestation(m: M_Attestation) -> FuluAttestation_d.Attestation:
  match m:
    case M_Attestation{+a0, +a1, +a2, +a3}: FuluAttestation_d.Attestation{th_b(a0), a1, a2, a3}
def fz_Attestation(x: FuluAttestation_d.Attestation) -> M_Attestation:
  match x:
    case FuluAttestation_d.Attestation{x0, +x1, +x2, +x3}: M_Attestation{fz_b(x0), x1, x2, x3}
def th_Attestation_bx(m: MB<M_Attestation>) -> O.Boxed<FuluAttestation_d.Attestation>:
  match m:
    case MSome{+v}: O.BSome{th_Attestation(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_Attestation_bx(x: O.Boxed<FuluAttestation_d.Attestation>) -> MB<M_Attestation>:
  match x:
    case O.BSome{v, rest}: MSome{fz_Attestation(v)}
    case O.BNone{}: MNone{}
# ---- l8_Attestation: list of Attestation_bx (Type-kind elements, through mirrors) ----
def am_l8_Attestation(t: F.array__Tree<MB<M_Attestation>>) -> Array<O.Boxed<FuluAttestation_d.Attestation>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_Attestation_bx(x)}
    case F.TNode{l, r}: ANode{am_l8_Attestation(l), am_l8_Attestation(r)}

def xat_l8_Attestation(W: List<&2, MB<M_Attestation>>, +i: Nat) -> MB<M_Attestation>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l8_Attestation(t, j)
def ereps_l8_Attestation(k: Nat, +W: List<&2, MB<M_Attestation>>, +i: Nat, +sE: S.Schema) -> Data:
  match k:
    case 0n: {True{} == True{} : Bool}
    case 1n+q: DK.P2(rep_Attestation_bx(th_Attestation_bx(xat_l8_Attestation(W, i)), sE), ereps_l8_Attestation(q, W, 1n+i, sE))
def xi_l8_Attestation(k: Nat, +W: List<&2, MB<M_Attestation>>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{v_Attestation_bx(th_Attestation_bx(xat_l8_Attestation(W, i))), xi_l8_Attestation(q, W, 1n+i)}
def tfz_l8_Attestation(a: Array<O.Boxed<FuluAttestation_d.Attestation>>) -> F.array__Tree<MB<M_Attestation>>:
  match a:
    case ALeaf{x}: F.TLeaf{fz_Attestation_bx(x)}
    case ANode{l, r}: F.TNode{tfz_l8_Attestation(l), tfz_l8_Attestation(r)}
def xlen_o_l8_Attestation(o: Fulu_list_Attestation_8_d.l8_Attestation_Seq) -> U32:
  match o:
    case Fulu_list_Attestation_8_d.l8_Attestation_Seq{arr, +n}: n
def xv_l8_Attestation(o: Fulu_list_Attestation_8_d.l8_Attestation_Seq) -> S.Value:
  match o:
    case Fulu_list_Attestation_8_d.l8_Attestation_Seq{arr, +n}: S.Sequence{xi_l8_Attestation(U32.to_nat(n), F.array__slots(MB<M_Attestation>, tfz_l8_Attestation(arr)), 0n)}
def rep_l8_Attestation(o: Fulu_list_Attestation_8_d.l8_Attestation_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<MB<M_Attestation>>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_Attestation_8_d.l8_Attestation_Seq{am_l8_Attestation(t), N} : Fulu_list_Attestation_8_d.l8_Attestation_Seq},
    DK.P2({F.array__perfect(MB<M_Attestation>, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},
          ereps_l8_Attestation(U32.to_nat(N), F.array__slots(MB<M_Attestation>, t), 0n, SH.ListOf_element(s))))))))),
    {Nat.is_le(U32.to_nat(xlen_o_l8_Attestation(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- box of Deposit ----
def pjb_Deposit_bx(o: O.Boxed<FuluDeposit_d.Deposit>) -> FuluDeposit_d.Deposit:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluDeposit_d.Deposit_default()
def v_Deposit_bx(o: O.Boxed<FuluDeposit_d.Deposit>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_Deposit(v)
    case O.BNone{}: S.NullValue{}
def rep_Deposit_bx(o: O.Boxed<FuluDeposit_d.Deposit>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_Deposit_bx(o), O.BNone{}} : O.Boxed<FuluDeposit_d.Deposit>}, rep_Deposit(pjb_Deposit_bx(o), s))
def mfz_DepositData_bx(x: O.Boxed<FuluDepositData_d.DepositData>) -> FuluDepositData_d.DepositData:
  match x:
    case O.BSome{+v, rest}: v
    case O.BNone{}: FuluDepositData_d.DepositData_default()

# ---- Data mirror of Deposit ----
type M_Deposit is Data:
  M_Deposit{a0: WMr, a1: FuluDepositData_d.DepositData}
def th_Deposit(m: M_Deposit) -> FuluDeposit_d.Deposit:
  match m:
    case M_Deposit{+a0, +a1}: FuluDeposit_d.Deposit{th_w(a0), O.BSome{a1, O.BNone{}}}
def fz_Deposit(x: FuluDeposit_d.Deposit) -> M_Deposit:
  match x:
    case FuluDeposit_d.Deposit{x0, x1}: M_Deposit{fz_w(x0), mfz_DepositData_bx(x1)}
def th_Deposit_bx(m: MB<M_Deposit>) -> O.Boxed<FuluDeposit_d.Deposit>:
  match m:
    case MSome{+v}: O.BSome{th_Deposit(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_Deposit_bx(x: O.Boxed<FuluDeposit_d.Deposit>) -> MB<M_Deposit>:
  match x:
    case O.BSome{v, rest}: MSome{fz_Deposit(v)}
    case O.BNone{}: MNone{}
# ---- l16_Deposit: list of Deposit_bx (Type-kind elements, through mirrors) ----
def am_l16_Deposit(t: F.array__Tree<MB<M_Deposit>>) -> Array<O.Boxed<FuluDeposit_d.Deposit>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_Deposit_bx(x)}
    case F.TNode{l, r}: ANode{am_l16_Deposit(l), am_l16_Deposit(r)}

def xat_l16_Deposit(W: List<&2, MB<M_Deposit>>, +i: Nat) -> MB<M_Deposit>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_Deposit(t, j)
def ereps_l16_Deposit(k: Nat, +W: List<&2, MB<M_Deposit>>, +i: Nat, +sE: S.Schema) -> Data:
  match k:
    case 0n: {True{} == True{} : Bool}
    case 1n+q: DK.P2(rep_Deposit_bx(th_Deposit_bx(xat_l16_Deposit(W, i)), sE), ereps_l16_Deposit(q, W, 1n+i, sE))
def xi_l16_Deposit(k: Nat, +W: List<&2, MB<M_Deposit>>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{v_Deposit_bx(th_Deposit_bx(xat_l16_Deposit(W, i))), xi_l16_Deposit(q, W, 1n+i)}
def tfz_l16_Deposit(a: Array<O.Boxed<FuluDeposit_d.Deposit>>) -> F.array__Tree<MB<M_Deposit>>:
  match a:
    case ALeaf{x}: F.TLeaf{fz_Deposit_bx(x)}
    case ANode{l, r}: F.TNode{tfz_l16_Deposit(l), tfz_l16_Deposit(r)}
def xlen_o_l16_Deposit(o: Fulu_list_Deposit_16_d.l16_Deposit_Seq) -> U32:
  match o:
    case Fulu_list_Deposit_16_d.l16_Deposit_Seq{arr, +n}: n
def xv_l16_Deposit(o: Fulu_list_Deposit_16_d.l16_Deposit_Seq) -> S.Value:
  match o:
    case Fulu_list_Deposit_16_d.l16_Deposit_Seq{arr, +n}: S.Sequence{xi_l16_Deposit(U32.to_nat(n), F.array__slots(MB<M_Deposit>, tfz_l16_Deposit(arr)), 0n)}
def rep_l16_Deposit(o: Fulu_list_Deposit_16_d.l16_Deposit_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<MB<M_Deposit>>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_Deposit_16_d.l16_Deposit_Seq{am_l16_Deposit(t), N} : Fulu_list_Deposit_16_d.l16_Deposit_Seq},
    DK.P2({F.array__perfect(MB<M_Deposit>, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
    DK.P2({Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool},
          ereps_l16_Deposit(U32.to_nat(N), F.array__slots(MB<M_Deposit>, t), 0n, SH.ListOf_element(s))))))))),
    {Nat.is_le(U32.to_nat(xlen_o_l16_Deposit(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- l16_SignedVoluntaryExit: list of SignedVoluntaryExit (Data elements) ----
def xat_l16_SignedVoluntaryExit(W: List<&2, FuluSignedVoluntaryExit_d.SignedVoluntaryExit>, +i: Nat) -> FuluSignedVoluntaryExit_d.SignedVoluntaryExit:
  match W:
    case Nil{}: FuluSignedVoluntaryExit_d.SignedVoluntaryExit_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_SignedVoluntaryExit(t, j)
def xi_l16_SignedVoluntaryExit(k: Nat, +W: List<&2, FuluSignedVoluntaryExit_d.SignedVoluntaryExit>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN.v_SignedVoluntaryExit(xat_l16_SignedVoluntaryExit(W, i)), xi_l16_SignedVoluntaryExit(q, W, 1n+i)}
def xlen_o_l16_SignedVoluntaryExit(o: Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq) -> U32:
  match o:
    case Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{arr, +n}: n
def xv_l16_SignedVoluntaryExit(o: Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq) -> S.Value:
  match o:
    case Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{arr, +n}: S.Sequence{xi_l16_SignedVoluntaryExit(U32.to_nat(n), F.array__slots(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, F.array__freeze(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, arr)), 0n)}
def rep_l16_SignedVoluntaryExit(o: Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<FuluSignedVoluntaryExit_d.SignedVoluntaryExit>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq{F.array__thaw(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, t), N} : Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq},
    DK.P2({F.array__perfect(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),
    {Nat.is_le(U32.to_nat(xlen_o_l16_SignedVoluntaryExit(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- box of ExecutionPayload ----
def pjb_ExecutionPayload_bx(o: O.Boxed<FuluExecutionPayload_d.ExecutionPayload>) -> FuluExecutionPayload_d.ExecutionPayload:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluExecutionPayload_d.ExecutionPayload_default()
def v_ExecutionPayload_bx(o: O.Boxed<FuluExecutionPayload_d.ExecutionPayload>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_ExecutionPayload(v)
    case O.BNone{}: S.NullValue{}
def rep_ExecutionPayload_bx(o: O.Boxed<FuluExecutionPayload_d.ExecutionPayload>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_ExecutionPayload_bx(o), O.BNone{}} : O.Boxed<FuluExecutionPayload_d.ExecutionPayload>}, rep_ExecutionPayload(pjb_ExecutionPayload_bx(o), s))
# ---- l16_SignedBLSToExecutionChange: list of SignedBLSToExecutionChange (Data elements) ----
def xat_l16_SignedBLSToExecutionChange(W: List<&2, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange>, +i: Nat) -> FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange:
  match W:
    case Nil{}: FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange_default()
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_SignedBLSToExecutionChange(t, j)
def xi_l16_SignedBLSToExecutionChange(k: Nat, +W: List<&2, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange>, +i: Nat) -> S.Value:
  match k:
    case 0n: S.EmptyItems{}
    case 1n+q: S.Items{RN.v_SignedBLSToExecutionChange(xat_l16_SignedBLSToExecutionChange(W, i)), xi_l16_SignedBLSToExecutionChange(q, W, 1n+i)}
def xlen_o_l16_SignedBLSToExecutionChange(o: Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq) -> U32:
  match o:
    case Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{arr, +n}: n
def xv_l16_SignedBLSToExecutionChange(o: Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq) -> S.Value:
  match o:
    case Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{arr, +n}: S.Sequence{xi_l16_SignedBLSToExecutionChange(U32.to_nat(n), F.array__slots(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, F.array__freeze(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, arr)), 0n)}
def rep_l16_SignedBLSToExecutionChange(o: Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq, +s: S.Schema) -> Data:
  DK.P2(DK.Ex(F.array__Tree<FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({o == Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq{F.array__thaw(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, t), N} : Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq},
    DK.P2({F.array__perfect(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, dw, t) == True{} : Bool},
    DK.P2({Nat.is_lt(dw, 32n) == True{} : Bool},
          {Nat.is_le(U32.to_nat(N), F.spec_common__pow2(dw)) == True{} : Bool})))))),
    {Nat.is_le(U32.to_nat(xlen_o_l16_SignedBLSToExecutionChange(o)), SH.ListOf_limit(s)) == True{} : Bool})
# ---- BeaconBlockBody (Type-kind container, 13 fields, in groups) ----
def pj_BeaconBlockBody_3(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> Fulu_list_ProposerSlashing_16_d.l16_ProposerSlashing_Seq:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x3
def pj_BeaconBlockBody_4(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> Fulu_list_AttesterSlashing_1_d.l1_AttesterSlashing_Seq:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x4
def pj_BeaconBlockBody_5(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> Fulu_list_Attestation_8_d.l8_Attestation_Seq:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x5
def pj_BeaconBlockBody_6(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> Fulu_list_Deposit_16_d.l16_Deposit_Seq:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x6
def pj_BeaconBlockBody_7(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> Fulu_list_SignedVoluntaryExit_16_d.l16_SignedVoluntaryExit_Seq:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x7
def pj_BeaconBlockBody_8(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> O.Boxed<FuluSyncAggregate_d.SyncAggregate>:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x8
def pj_BeaconBlockBody_9(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> O.Boxed<FuluExecutionPayload_d.ExecutionPayload>:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x9
def pj_BeaconBlockBody_10(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> Fulu_list_SignedBLSToExecutionChange_16_d.l16_SignedBLSToExecutionChange_Seq:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x10
def pj_BeaconBlockBody_11(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> O.Words:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x11
def pj_BeaconBlockBody_12(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> FuluExecutionRequests_d.ExecutionRequests:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              x12
def v_BeaconBlockBody(o: FuluBeaconBlockBody_d.BeaconBlockBody) -> S.Value:
  match o:
    case FuluBeaconBlockBody_d.BeaconBlockBody{g0, g1}:
      match g0:
        case FuluBeaconBlockBody_d.BeaconBlockBody_g0{+x0, +x1, +x2, x3, x4, x5, x6, x7}:
          match g1:
            case FuluBeaconBlockBody_d.BeaconBlockBody_g1{x8, x9, x10, x11, x12}:
              S.Sequence{S.Items{RN.v_b96(x0), S.Items{RN.v_Eth1Data(x1), S.Items{RN.v_b32(x2), S.Items{xv_l16_ProposerSlashing(x3), S.Items{xv_l1_AttesterSlashing(x4), S.Items{xv_l8_Attestation(x5), S.Items{xv_l16_Deposit(x6), S.Items{xv_l16_SignedVoluntaryExit(x7), S.Items{v_SyncAggregate_bx(x8), S.Items{v_ExecutionPayload_bx(x9), S.Items{xv_l16_SignedBLSToExecutionChange(x10), S.Items{E48.eview(x11), S.Items{v_ExecutionRequests(x12), S.EmptyItems{}}}}}}}}}}}}}}}
def rep_BeaconBlockBody(o: FuluBeaconBlockBody_d.BeaconBlockBody, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes96_d.Bytes96, x0 => DK.Ex(FuluEth1Data_d.Eth1Data, x1 => DK.Ex(FuluBytes32_d.Bytes32, x2 => DK.P2({o == FuluBeaconBlockBody_d.BeaconBlockBody{FuluBeaconBlockBody_d.BeaconBlockBody_g0{x0, x1, x2, pj_BeaconBlockBody_3(o), pj_BeaconBlockBody_4(o), pj_BeaconBlockBody_5(o), pj_BeaconBlockBody_6(o), pj_BeaconBlockBody_7(o)}, FuluBeaconBlockBody_d.BeaconBlockBody_g1{pj_BeaconBlockBody_8(o), pj_BeaconBlockBody_9(o), pj_BeaconBlockBody_10(o), pj_BeaconBlockBody_11(o), pj_BeaconBlockBody_12(o)}} : FuluBeaconBlockBody_d.BeaconBlockBody}, DK.P2(rep_l16_ProposerSlashing(pj_BeaconBlockBody_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), DK.P2(rep_l1_AttesterSlashing(pj_BeaconBlockBody_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), DK.P2(rep_l8_Attestation(pj_BeaconBlockBody_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))), DK.P2(rep_l16_Deposit(pj_BeaconBlockBody_6(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))), DK.P2(rep_l16_SignedVoluntaryExit(pj_BeaconBlockBody_7(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))), DK.P2(rep_SyncAggregate_bx(pj_BeaconBlockBody_8(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))), DK.P2(rep_ExecutionPayload_bx(pj_BeaconBlockBody_9(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))), DK.P2(rep_l16_SignedBLSToExecutionChange(pj_BeaconBlockBody_10(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))), DK.P2(E48.rep_el(pj_BeaconBlockBody_11(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))))))))))), rep_ExecutionRequests(pj_BeaconBlockBody_12(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))))))))))))))))
# ---- box of BeaconBlockBody ----
def pjb_BeaconBlockBody_bx(o: O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>) -> FuluBeaconBlockBody_d.BeaconBlockBody:
  match o:
    case O.BSome{v, rest}: v
    case O.BNone{}: FuluBeaconBlockBody_d.BeaconBlockBody_default()
def v_BeaconBlockBody_bx(o: O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>) -> S.Value:
  match o:
    case O.BSome{v, rest}: v_BeaconBlockBody(v)
    case O.BNone{}: S.NullValue{}
def rep_BeaconBlockBody_bx(o: O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>, +s: S.Schema) -> Data:
  DK.P2({o == O.BSome{pjb_BeaconBlockBody_bx(o), O.BNone{}} : O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>}, rep_BeaconBlockBody(pjb_BeaconBlockBody_bx(o), s))
# ---- BeaconBlock (Type-kind container, 5 fields) ----
def pj_BeaconBlock_4(o: FuluBeaconBlock_d.BeaconBlock) -> O.Boxed<FuluBeaconBlockBody_d.BeaconBlockBody>:
  match o:
    case FuluBeaconBlock_d.BeaconBlock{+x0, +x1, +x2, +x3, x4}: x4
def v_BeaconBlock(o: FuluBeaconBlock_d.BeaconBlock) -> S.Value:
  match o:
    case FuluBeaconBlock_d.BeaconBlock{+x0, +x1, +x2, +x3, x4}: S.Sequence{S.Items{RN.v_u64(x0), S.Items{RN.v_u64(x1), S.Items{RN.v_b32(x2), S.Items{RN.v_b32(x3), S.Items{v_BeaconBlockBody_bx(x4), S.EmptyItems{}}}}}}}
def rep_BeaconBlock(o: FuluBeaconBlock_d.BeaconBlock, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x0 => DK.Ex(O.U64, x1 => DK.Ex(FuluBytes32_d.Bytes32, x2 => DK.Ex(FuluBytes32_d.Bytes32, x3 => DK.P2({o == FuluBeaconBlock_d.BeaconBlock{x0, x1, x2, x3, pj_BeaconBlock_4(o)} : FuluBeaconBlock_d.BeaconBlock}, rep_BeaconBlockBody_bx(pj_BeaconBlock_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))
# ---- SignedBeaconBlock (Type-kind container, 2 fields) ----
def pj_SignedBeaconBlock_0(o: FuluSignedBeaconBlock_d.SignedBeaconBlock) -> FuluBeaconBlock_d.BeaconBlock:
  match o:
    case FuluSignedBeaconBlock_d.SignedBeaconBlock{x0, +x1}: x0
def v_SignedBeaconBlock(o: FuluSignedBeaconBlock_d.SignedBeaconBlock) -> S.Value:
  match o:
    case FuluSignedBeaconBlock_d.SignedBeaconBlock{x0, +x1}: S.Sequence{S.Items{v_BeaconBlock(x0), S.Items{RN.v_b96(x1), S.EmptyItems{}}}}
def rep_SignedBeaconBlock(o: FuluSignedBeaconBlock_d.SignedBeaconBlock, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes96_d.Bytes96, x1 => DK.P2({o == FuluSignedBeaconBlock_d.SignedBeaconBlock{pj_SignedBeaconBlock_0(o), x1} : FuluSignedBeaconBlock_d.SignedBeaconBlock}, rep_BeaconBlock(pj_SignedBeaconBlock_0(o), SH.Chain_head(SH.Container_fields(s)))))
# ---- BlobSidecar (Type-kind container, 6 fields) ----
def pj_BlobSidecar_1(o: FuluBlobSidecar_d.BlobSidecar) -> O.Words:
  match o:
    case FuluBlobSidecar_d.BlobSidecar{+x0, x1, +x2, +x3, x4, x5}: x1
def pj_BlobSidecar_4(o: FuluBlobSidecar_d.BlobSidecar) -> O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>:
  match o:
    case FuluBlobSidecar_d.BlobSidecar{+x0, x1, +x2, +x3, x4, x5}: x4
def pj_BlobSidecar_5(o: FuluBlobSidecar_d.BlobSidecar) -> O.Words:
  match o:
    case FuluBlobSidecar_d.BlobSidecar{+x0, x1, +x2, +x3, x4, x5}: x5
def v_BlobSidecar(o: FuluBlobSidecar_d.BlobSidecar) -> S.Value:
  match o:
    case FuluBlobSidecar_d.BlobSidecar{+x0, x1, +x2, +x3, x4, x5}: S.Sequence{S.Items{RN.v_u64(x0), S.Items{S.BytesValue{WO.wview(x1)}, S.Items{RN.v_b48(x2), S.Items{RN.v_b48(x3), S.Items{v_SignedBeaconBlockHeader_bx(x4), S.Items{PV.pview(x5), S.EmptyItems{}}}}}}}}
def rep_BlobSidecar(o: FuluBlobSidecar_d.BlobSidecar, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x0 => DK.Ex(FuluBytes48_d.Bytes48, x2 => DK.Ex(FuluBytes48_d.Bytes48, x3 => DK.P2({o == FuluBlobSidecar_d.BlobSidecar{x0, pj_BlobSidecar_1(o), x2, x3, pj_BlobSidecar_4(o), pj_BlobSidecar_5(o)} : FuluBlobSidecar_d.BlobSidecar}, DK.P2(WO.rep_bv(pj_BlobSidecar_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), DK.P2(rep_SignedBeaconBlockHeader_bx(pj_BlobSidecar_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), PV.rep_pv(pj_BlobSidecar_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))
# ---- DataColumnsByRootIdentifier (Type-kind container, 2 fields) ----
def pj_DataColumnsByRootIdentifier_1(o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier) -> O.Words:
  match o:
    case FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{+x0, x1}: x1
def v_DataColumnsByRootIdentifier(o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier) -> S.Value:
  match o:
    case FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{+x0, x1}: S.Sequence{S.Items{RN.v_b32(x0), S.Items{UL.uview(x1), S.EmptyItems{}}}}
def rep_DataColumnsByRootIdentifier(o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes32_d.Bytes32, x0 => DK.P2({o == FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier{x0, pj_DataColumnsByRootIdentifier_1(o)} : FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier}, UL.rep_ul(pj_DataColumnsByRootIdentifier_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s))))))
# ---- MatrixEntry (Type-kind container, 4 fields) ----
def pj_MatrixEntry_0(o: FuluMatrixEntry_d.MatrixEntry) -> O.Words:
  match o:
    case FuluMatrixEntry_d.MatrixEntry{x0, +x1, +x2, +x3}: x0
def v_MatrixEntry(o: FuluMatrixEntry_d.MatrixEntry) -> S.Value:
  match o:
    case FuluMatrixEntry_d.MatrixEntry{x0, +x1, +x2, +x3}: S.Sequence{S.Items{S.BytesValue{WO.wview(x0)}, S.Items{RN.v_b48(x1), S.Items{RN.v_u64(x2), S.Items{RN.v_u64(x3), S.EmptyItems{}}}}}}
def rep_MatrixEntry(o: FuluMatrixEntry_d.MatrixEntry, +s: S.Schema) -> Data:
  DK.Ex(FuluBytes48_d.Bytes48, x1 => DK.Ex(O.U64, x2 => DK.Ex(O.U64, x3 => DK.P2({o == FuluMatrixEntry_d.MatrixEntry{pj_MatrixEntry_0(o), x1, x2, x3} : FuluMatrixEntry_d.MatrixEntry}, WO.rep_bv(pj_MatrixEntry_0(o), SH.Chain_head(SH.Container_fields(s)))))))
# ---- DataColumnSidecar (Type-kind container, 6 fields) ----
def pj_DataColumnSidecar_1(o: FuluDataColumnSidecar_d.DataColumnSidecar) -> O.Words:
  match o:
    case FuluDataColumnSidecar_d.DataColumnSidecar{+x0, x1, x2, x3, x4, x5}: x1
def pj_DataColumnSidecar_2(o: FuluDataColumnSidecar_d.DataColumnSidecar) -> O.Words:
  match o:
    case FuluDataColumnSidecar_d.DataColumnSidecar{+x0, x1, x2, x3, x4, x5}: x2
def pj_DataColumnSidecar_3(o: FuluDataColumnSidecar_d.DataColumnSidecar) -> O.Words:
  match o:
    case FuluDataColumnSidecar_d.DataColumnSidecar{+x0, x1, x2, x3, x4, x5}: x3
def pj_DataColumnSidecar_4(o: FuluDataColumnSidecar_d.DataColumnSidecar) -> O.Boxed<FuluSignedBeaconBlockHeader_d.SignedBeaconBlockHeader>:
  match o:
    case FuluDataColumnSidecar_d.DataColumnSidecar{+x0, x1, x2, x3, x4, x5}: x4
def pj_DataColumnSidecar_5(o: FuluDataColumnSidecar_d.DataColumnSidecar) -> O.Words:
  match o:
    case FuluDataColumnSidecar_d.DataColumnSidecar{+x0, x1, x2, x3, x4, x5}: x5
def v_DataColumnSidecar(o: FuluDataColumnSidecar_d.DataColumnSidecar) -> S.Value:
  match o:
    case FuluDataColumnSidecar_d.DataColumnSidecar{+x0, x1, x2, x3, x4, x5}: S.Sequence{S.Items{RN.v_u64(x0), S.Items{CE.eview(x1), S.Items{E48.eview(x2), S.Items{E48.eview(x3), S.Items{v_SignedBeaconBlockHeader_bx(x4), S.Items{PV.pview(x5), S.EmptyItems{}}}}}}}}
def rep_DataColumnSidecar(o: FuluDataColumnSidecar_d.DataColumnSidecar, +s: S.Schema) -> Data:
  DK.Ex(O.U64, x0 => DK.P2({o == FuluDataColumnSidecar_d.DataColumnSidecar{x0, pj_DataColumnSidecar_1(o), pj_DataColumnSidecar_2(o), pj_DataColumnSidecar_3(o), pj_DataColumnSidecar_4(o), pj_DataColumnSidecar_5(o)} : FuluDataColumnSidecar_d.DataColumnSidecar}, DK.P2(CE.rep_el(pj_DataColumnSidecar_1(o), SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), DK.P2(E48.rep_el(pj_DataColumnSidecar_2(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))), DK.P2(E48.rep_el(pj_DataColumnSidecar_3(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s)))))), DK.P2(rep_SignedBeaconBlockHeader_bx(pj_DataColumnSidecar_4(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))), PV.rep_pv(pj_DataColumnSidecar_5(o), SH.Chain_head(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Chain_tail(SH.Container_fields(s))))))))))))))
