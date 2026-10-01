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
import ./amap.bend as AM
import ./schema_shapes.bend as SH
import ./dk.bend as DK
import ./mtree_defs.bend as MD
import ./words_obj_light.bend as WO
import ./list_obj_light.bend as LO
import ./pv_obj_light.bend as PV
import ./bitlist_obj_light.bend as BO
import ./cells_light.bend as CE
import ./root_names_light.bend as RN
import ./ulist_obj_light.bend as UL
import ./elems48_light.bend as E48

# GENERATED by root_laws_b (codegen). Do not edit.
# The definitions of root_types.bend that state no root law (its light companion, codegen/proofs/support/light_split.py): importers that only
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
def fzth_w(+m: WMr) -> {fz_w(th_w(m)) == m : WMr}:
  match m:
    case WMr{+t, +n}:
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) : {WMr{_, n} == WMr{t, n} : WMr}
      {==}
type BMr is Data:
  BMr{t: F.array__Tree<U32>, k: U32}
def th_b(m: BMr) -> O.Bits:
  match m:
    case BMr{+t, +k}: O.Bits{F.array__thaw(U32, t), k}
def fz_b(x: O.Bits) -> BMr:
  match x:
    case O.Bits{ws, +k}: BMr{F.array__freeze(U32, ws), k}
def fzth_b(+m: BMr) -> {fz_b(th_b(m)) == m : BMr}:
  match m:
    case BMr{+t, +k}:
      %Equal.sym(F.array__Tree<U32>, F.array__freeze(U32, F.array__thaw(U32, t)), t, F.array__freeze_thaw(U32, t)) : {BMr{_, k} == BMr{t, k} : BMr}
      {==}
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
law nth_l8192_DepositRequest:
  for +W: List<&2, FuluDepositRequest_d.DepositRequest>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FuluDepositRequest_d.DepositRequest, W)) == True{} : Bool}
  {F.spec_common__nth(FuluDepositRequest_d.DepositRequest, W, i) == Some{xat_l8192_DepositRequest(W, i)} : Maybe<&2, FuluDepositRequest_d.DepositRequest>}
def nth_l8192_DepositRequest(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FuluDepositRequest_d.DepositRequest, Nil{}, i) == Some{xat_l8192_DepositRequest(Nil{}, i)} : Maybe<&2, FuluDepositRequest_d.DepositRequest>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l8192_DepositRequest(t, j, hi)
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
law nth_l16_WithdrawalRequest:
  for +W: List<&2, FuluWithdrawalRequest_d.WithdrawalRequest>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FuluWithdrawalRequest_d.WithdrawalRequest, W)) == True{} : Bool}
  {F.spec_common__nth(FuluWithdrawalRequest_d.WithdrawalRequest, W, i) == Some{xat_l16_WithdrawalRequest(W, i)} : Maybe<&2, FuluWithdrawalRequest_d.WithdrawalRequest>}
def nth_l16_WithdrawalRequest(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FuluWithdrawalRequest_d.WithdrawalRequest, Nil{}, i) == Some{xat_l16_WithdrawalRequest(Nil{}, i)} : Maybe<&2, FuluWithdrawalRequest_d.WithdrawalRequest>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l16_WithdrawalRequest(t, j, hi)
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
law nth_l2_ConsolidationRequest:
  for +W: List<&2, FuluConsolidationRequest_d.ConsolidationRequest>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FuluConsolidationRequest_d.ConsolidationRequest, W)) == True{} : Bool}
  {F.spec_common__nth(FuluConsolidationRequest_d.ConsolidationRequest, W, i) == Some{xat_l2_ConsolidationRequest(W, i)} : Maybe<&2, FuluConsolidationRequest_d.ConsolidationRequest>}
def nth_l2_ConsolidationRequest(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FuluConsolidationRequest_d.ConsolidationRequest, Nil{}, i) == Some{xat_l2_ConsolidationRequest(Nil{}, i)} : Maybe<&2, FuluConsolidationRequest_d.ConsolidationRequest>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l2_ConsolidationRequest(t, j, hi)
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
def fzth_bl1073741824_bx(+m: MB<WMr>) -> {fz_bl1073741824_bx(th_bl1073741824_bx(m)) == m : MB<WMr>}:
  match m:
    case MSome{+v}:
      %Equal.sym(WMr, fz_w(th_w(v)), v, fzth_w(v)) : {MSome{_} == MSome{v} : MB<WMr>}
      {==}
    case MNone{}: {==}

# ---- l1048576_bl1073741824: list of bl1073741824_bx (Type-kind elements, through mirrors) ----
def am_l1048576_bl1073741824(t: F.array__Tree<MB<WMr>>) -> Array<O.Boxed<O.Words>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_bl1073741824_bx(x)}
    case F.TNode{l, r}: ANode{am_l1048576_bl1073741824(l), am_l1048576_bl1073741824(r)}

def amsize_l1048576_bl1073741824(+d: Nat, +t: F.array__Tree<MB<WMr>>, +pf: {F.array__perfect(MB<WMr>, d, t) == True{} : Bool}) -> {Array.size(O.Boxed<O.Words>, am_l1048576_bl1073741824(t)) == (am_l1048576_bl1073741824(t), F.u32__pow2u(d)) : Array<O.Boxed<O.Words>> & U32}:
  match d t:
    case 0n F.TLeaf{x}:
      {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({Array.size(O.Boxed<O.Words>, am_l1048576_bl1073741824(F.TNode{l, r})) == (am_l1048576_bl1073741824(F.TNode{l, r}), 1) : Array<O.Boxed<O.Words>> & U32}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({Array.size(O.Boxed<O.Words>, ALeaf{th_bl1073741824_bx(x)}) == (ALeaf{th_bl1073741824_bx(x)}, F.u32__pow2u(1n+p)) : Array<O.Boxed<O.Words>> & U32}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<O.Words>> & U32, Array.size(O.Boxed<O.Words>, am_l1048576_bl1073741824(l)), (am_l1048576_bl1073741824(l), F.u32__pow2u(p)), amsize_l1048576_bl1073741824(p, l, F.array__pf_left(MB<WMr>, p, l, r, pf))) : {Array.size.node(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), _) == (ANode{am_l1048576_bl1073741824(l), am_l1048576_bl1073741824(r)}, U32.shl(F.u32__pow2u(p))) : Array<O.Boxed<O.Words>> & U32}
      {==}

def amswap_go_l1048576_bl1073741824(+d: Nat, +t: F.array__Tree<MB<WMr>>, +i: U32, +v: MB<WMr>, +x: MB<WMr>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<WMr>>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(F.u32__pow2u(d))) == b : Bool}, +pf: {F.array__perfect(MB<WMr>, d, t) == True{} : Bool}) -> {Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(t), F.u32__pow2u(d), i, th_bl1073741824_bx(v), b) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(MB<WMr>, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{th_bl1073741824_bx(v)}, th_bl1073741824_bx(y)) == (ALeaf{th_bl1073741824_bx(v)}, th_bl1073741824_bx(_)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(F.TNode{l, r}), 1, i, th_bl1073741824_bx(v), b) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, 0n, F.TNode{l, r}, U32.to_nat(i), v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({Array.swap.go(O.Boxed<O.Words>, ALeaf{th_bl1073741824_bx(y)}, F.u32__pow2u(1n+p), i, th_bl1073741824_bx(v), b) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, 1n+p, F.TLeaf{y}, U32.to_nat(i), v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<WMr>, p, l, r, pf)
      +hil = F.array__lt_bridge(i, p, hp, True{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.lo(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(l), _, i, th_bl1073741824_bx(v), U32.is_lt(i, U32.shr(_)))) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, 1n+p, F.TNode{l, r}, ti, v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), True{}, hil) : {Array.swap.lo(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(l), F.u32__pow2u(p), i, th_bl1073741824_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p))))) == (am_l1048576_bl1073741824(F.array__tupd(MB<WMr>, 1n+p, F.TNode{l, r}, ti, v, _)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      %Equal.sym(Array<O.Boxed<O.Words>> & O.Boxed<O.Words>, Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(l), F.u32__pow2u(p), i, th_bl1073741824_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p)))), (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, p, l, ti, v)), th_bl1073741824_bx(x)), amswap_go_l1048576_bl1073741824(p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, MB<WMr>>, F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, l), ti), F.spec_common__nth(MB<WMr>, F.spec_common__append(MB<WMr>, F.array__slots(MB<WMr>, l), F.array__slots(MB<WMr>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<WMr>>, F.spec_common__nth(MB<WMr>, F.spec_common__append(MB<WMr>, F.array__slots(MB<WMr>, l), F.array__slots(MB<WMr>, r)), ti), F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, l), ti), F.list__nth_append_left(MB<WMr>, F.array__slots(MB<WMr>, l), F.array__slots(MB<WMr>, r), ti, F.array__len_lt(MB<WMr>, p, l, ti, pl, hil))), hx), U32.is_lt(i, U32.shr(F.u32__pow2u(p))), {==}, pl)) : {Array.swap.lo(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), _) == (am_l1048576_bl1073741824(F.TNode{F.array__tupd(MB<WMr>, p, l, ti, v, F.array__ndec(p, ti)), r}), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<WMr>, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = F.array__lt_bridge(i, p, hp, False{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +le = F.nat__not_lt_le(ti, F.spec_common__pow2(p), nb)
      +j = U32.sub(i, F.u32__pow2u(p))
      +k = Nat.sub(ti, F.spec_common__pow2(p))
      +ej = F.array__sub_bridge(i, p, hp, le)
      +hir = F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), F.array__upper_lt(ti, p, hi, le))
      +hxr = F.logic__subst(Nat, n => {F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, r), n) == Some{x} : Maybe<&2, MB<WMr>>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, MB<WMr>>, F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, r), k), F.spec_common__nth(MB<WMr>, F.spec_common__append(MB<WMr>, F.array__slots(MB<WMr>, l), F.array__slots(MB<WMr>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<WMr>>, F.spec_common__nth(MB<WMr>, F.spec_common__append(MB<WMr>, F.array__slots(MB<WMr>, l), F.array__slots(MB<WMr>, r)), ti), F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, r), k), F.array__right_nth(MB<WMr>, p, l, r, ti, pl, le)), hx))
      +ih = amswap_go_l1048576_bl1073741824(p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, U32.shr(F.u32__pow2u(p))), {==}, F.array__pf_right(MB<WMr>, p, l, r, pf))
      +ih2 = F.logic__subst(Nat, n => {Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), F.u32__pow2u(p), j, th_bl1073741824_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, p, r, n, v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.hi(O.Boxed<O.Words>, am_l1048576_bl1073741824(l), Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), _, U32.sub(i, _), th_bl1073741824_bx(v), U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, 1n+p, F.TNode{l, r}, ti, v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), False{}, nb) : {Array.swap.hi(O.Boxed<O.Words>, am_l1048576_bl1073741824(l), Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), F.u32__pow2u(p), j, th_bl1073741824_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p))))) == (am_l1048576_bl1073741824(F.array__tupd(MB<WMr>, 1n+p, F.TNode{l, r}, ti, v, _)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      %Equal.sym(Array<O.Boxed<O.Words>> & O.Boxed<O.Words>, Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(r), F.u32__pow2u(p), j, th_bl1073741824_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))), (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, p, r, k, v)), th_bl1073741824_bx(x)), ih2) : {Array.swap.hi(O.Boxed<O.Words>, am_l1048576_bl1073741824(l), _) == (am_l1048576_bl1073741824(F.TNode{l, F.array__tupd(MB<WMr>, p, r, k, v, F.array__ndec(p, k))}), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def amswap_l1048576_bl1073741824(+d: Nat, +t: F.array__Tree<MB<WMr>>, +i: U32, +v: MB<WMr>, +x: MB<WMr>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<WMr>>}, +pf: {F.array__perfect(MB<WMr>, d, t) == True{} : Bool}) -> {Array.swap(O.Boxed<O.Words>, am_l1048576_bl1073741824(t), i, th_bl1073741824_bx(v)) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}:
  %Equal.sym(Array<O.Boxed<O.Words>> & U32, Array.size(O.Boxed<O.Words>, am_l1048576_bl1073741824(t)), (am_l1048576_bl1073741824(t), F.u32__pow2u(d)), amsize_l1048576_bl1073741824(d, t, pf)) : {Array.swap.at(O.Boxed<O.Words>, i, th_bl1073741824_bx(v), _) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {Array.swap.go(O.Boxed<O.Words>, am_l1048576_bl1073741824(t), F.u32__pow2u(d), _, th_bl1073741824_bx(v), U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)), th_bl1073741824_bx(x)) : Array<O.Boxed<O.Words>> & O.Boxed<O.Words>}
  amswap_go_l1048576_bl1073741824(d, t, i, v, x, hd, hi, hx, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), {==}, pf)

def amset_l1048576_bl1073741824(+d: Nat, +t: F.array__Tree<MB<WMr>>, +i: U32, +v: MB<WMr>, +x: MB<WMr>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<WMr>>}, +pf: {F.array__perfect(MB<WMr>, d, t) == True{} : Bool}) -> {Array.set(O.Boxed<O.Words>, am_l1048576_bl1073741824(t), i, th_bl1073741824_bx(v)) == am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<O.Words>>}:
  %Equal.sym(Array<O.Boxed<O.Words>> & O.Boxed<O.Words>, Array.swap(O.Boxed<O.Words>, am_l1048576_bl1073741824(t), i, th_bl1073741824_bx(v)), (am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)), th_bl1073741824_bx(x)), amswap_l1048576_bl1073741824(d, t, i, v, x, hd, hi, hx, pf)) : {Array.set.fin(O.Boxed<O.Words>, _) == am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<O.Words>>}
  {==}

# Swap an element out (replaced by th_bl1073741824_bx(z)), then set th_bl1073741824_bx(x) back: the array is
# unchanged. This is the leaf step of every tree over such a list.
def amswap_back_l1048576_bl1073741824(+d: Nat, +t: F.array__Tree<MB<WMr>>, +i: U32, +z: MB<WMr>, +x: MB<WMr>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<WMr>>},
    +pf: {F.array__perfect(MB<WMr>, d, t) == True{} : Bool})
    -> {Array.set(O.Boxed<O.Words>, am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t, U32.to_nat(i), z)), i, th_bl1073741824_bx(x)) == am_l1048576_bl1073741824(t) : Array<O.Boxed<O.Words>>}:
  +t2 = F.array__upd(MB<WMr>, d, t, U32.to_nat(i), z)
  +hz = F.logic__subst(List<&2, MB<WMr>>, ys => {F.spec_common__nth(MB<WMr>, ys, U32.to_nat(i)) == Some{z} : Maybe<&2, MB<WMr>>}, F.spec_common__update(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i), z), F.array__slots(MB<WMr>, t2),
    Equal.sym(List<&2, MB<WMr>>, F.array__slots(MB<WMr>, t2), F.spec_common__update(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i), z), F.array__upd_slots(MB<WMr>, d, t, U32.to_nat(i), z, hi, pf)),
    F.list__nth_update_same(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i), z, F.list__nth_lt_length(MB<WMr>, F.array__slots(MB<WMr>, t), U32.to_nat(i), x, hx)))
  %Equal.sym(Array<O.Boxed<O.Words>>, Array.set(O.Boxed<O.Words>, am_l1048576_bl1073741824(t2), i, th_bl1073741824_bx(x)), am_l1048576_bl1073741824(F.array__upd(MB<WMr>, d, t2, U32.to_nat(i), x)),
      amset_l1048576_bl1073741824(d, t2, i, x, z, hd, hi, hz, F.array__upd_perfect(MB<WMr>, d, t, U32.to_nat(i), z, pf))) :
    {_ == am_l1048576_bl1073741824(t) : Array<O.Boxed<O.Words>>}
  %Equal.sym(F.array__Tree<MB<WMr>>, F.array__upd(MB<WMr>, d, t2, U32.to_nat(i), x), t, AM.upd_restore(MB<WMr>, d, t, U32.to_nat(i), z, x, hi, hx, pf)) :
    {am_l1048576_bl1073741824(_) == am_l1048576_bl1073741824(t) : Array<O.Boxed<O.Words>>}
  {==}
def xat_l1048576_bl1073741824(W: List<&2, MB<WMr>>, +i: Nat) -> MB<WMr>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l1048576_bl1073741824(t, j)
law nth_l1048576_bl1073741824:
  for +W: List<&2, MB<WMr>>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(MB<WMr>, W)) == True{} : Bool}
  {F.spec_common__nth(MB<WMr>, W, i) == Some{xat_l1048576_bl1073741824(W, i)} : Maybe<&2, MB<WMr>>}
def nth_l1048576_bl1073741824(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(MB<WMr>, Nil{}, i) == Some{xat_l1048576_bl1073741824(Nil{}, i)} : Maybe<&2, MB<WMr>>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l1048576_bl1073741824(t, j, hi)
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
law tfzam_l1048576_bl1073741824:
  for +t: F.array__Tree<MB<WMr>>
  {tfz_l1048576_bl1073741824(am_l1048576_bl1073741824(t)) == t : F.array__Tree<MB<WMr>>}
def tfzam_l1048576_bl1073741824(t):
  match t:
    case F.TLeaf{+x}:
      %Equal.sym(MB<WMr>, fz_bl1073741824_bx(th_bl1073741824_bx(x)), x, fzth_bl1073741824_bx(x)) : {F.TLeaf{_} == F.TLeaf{x} : F.array__Tree<MB<WMr>>}
      {==}
    case F.TNode{+l, +r}:
      %Equal.sym(F.array__Tree<MB<WMr>>, tfz_l1048576_bl1073741824(am_l1048576_bl1073741824(l)), l, tfzam_l1048576_bl1073741824(l)) : {F.TNode{_, tfz_l1048576_bl1073741824(am_l1048576_bl1073741824(r))} == F.TNode{l, r} : F.array__Tree<MB<WMr>>}
      %Equal.sym(F.array__Tree<MB<WMr>>, tfz_l1048576_bl1073741824(am_l1048576_bl1073741824(r)), r, tfzam_l1048576_bl1073741824(r)) : {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<MB<WMr>>}
      {==}
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
law nth_l16_Withdrawal:
  for +W: List<&2, FuluWithdrawal_d.Withdrawal>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FuluWithdrawal_d.Withdrawal, W)) == True{} : Bool}
  {F.spec_common__nth(FuluWithdrawal_d.Withdrawal, W, i) == Some{xat_l16_Withdrawal(W, i)} : Maybe<&2, FuluWithdrawal_d.Withdrawal>}
def nth_l16_Withdrawal(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FuluWithdrawal_d.Withdrawal, Nil{}, i) == Some{xat_l16_Withdrawal(Nil{}, i)} : Maybe<&2, FuluWithdrawal_d.Withdrawal>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l16_Withdrawal(t, j, hi)
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
def fzth_ProposerSlashing(+m: M_ProposerSlashing) -> {fz_ProposerSlashing(th_ProposerSlashing(m)) == m : M_ProposerSlashing}:
  match m:
    case M_ProposerSlashing{+a0, +a1}:
      {==}

def th_ProposerSlashing_bx(m: MB<M_ProposerSlashing>) -> O.Boxed<FuluProposerSlashing_d.ProposerSlashing>:
  match m:
    case MSome{+v}: O.BSome{th_ProposerSlashing(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_ProposerSlashing_bx(x: O.Boxed<FuluProposerSlashing_d.ProposerSlashing>) -> MB<M_ProposerSlashing>:
  match x:
    case O.BSome{v, rest}: MSome{fz_ProposerSlashing(v)}
    case O.BNone{}: MNone{}
def fzth_ProposerSlashing_bx(+m: MB<M_ProposerSlashing>) -> {fz_ProposerSlashing_bx(th_ProposerSlashing_bx(m)) == m : MB<M_ProposerSlashing>}:
  match m:
    case MSome{+v}:
      %Equal.sym(M_ProposerSlashing, fz_ProposerSlashing(th_ProposerSlashing(v)), v, fzth_ProposerSlashing(v)) : {MSome{_} == MSome{v} : MB<M_ProposerSlashing>}
      {==}
    case MNone{}: {==}

# ---- l16_ProposerSlashing: list of ProposerSlashing_bx (Type-kind elements, through mirrors) ----
def am_l16_ProposerSlashing(t: F.array__Tree<MB<M_ProposerSlashing>>) -> Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_ProposerSlashing_bx(x)}
    case F.TNode{l, r}: ANode{am_l16_ProposerSlashing(l), am_l16_ProposerSlashing(r)}

def amsize_l16_ProposerSlashing(+d: Nat, +t: F.array__Tree<MB<M_ProposerSlashing>>, +pf: {F.array__perfect(MB<M_ProposerSlashing>, d, t) == True{} : Bool}) -> {Array.size(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t)) == (am_l16_ProposerSlashing(t), F.u32__pow2u(d)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & U32}:
  match d t:
    case 0n F.TLeaf{x}:
      {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({Array.size(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(F.TNode{l, r})) == (am_l16_ProposerSlashing(F.TNode{l, r}), 1) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & U32}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({Array.size(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, ALeaf{th_ProposerSlashing_bx(x)}) == (ALeaf{th_ProposerSlashing_bx(x)}, F.u32__pow2u(1n+p)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & U32}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & U32, Array.size(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l)), (am_l16_ProposerSlashing(l), F.u32__pow2u(p)), amsize_l16_ProposerSlashing(p, l, F.array__pf_left(MB<M_ProposerSlashing>, p, l, r, pf))) : {Array.size.node(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), _) == (ANode{am_l16_ProposerSlashing(l), am_l16_ProposerSlashing(r)}, U32.shl(F.u32__pow2u(p))) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & U32}
      {==}

def amswap_go_l16_ProposerSlashing(+d: Nat, +t: F.array__Tree<MB<M_ProposerSlashing>>, +i: U32, +v: MB<M_ProposerSlashing>, +x: MB<M_ProposerSlashing>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_ProposerSlashing>>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(F.u32__pow2u(d))) == b : Bool}, +pf: {F.array__perfect(MB<M_ProposerSlashing>, d, t) == True{} : Bool}) -> {Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t), F.u32__pow2u(d), i, th_ProposerSlashing_bx(v), b) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(MB<M_ProposerSlashing>, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{th_ProposerSlashing_bx(v)}, th_ProposerSlashing_bx(y)) == (ALeaf{th_ProposerSlashing_bx(v)}, th_ProposerSlashing_bx(_)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(F.TNode{l, r}), 1, i, th_ProposerSlashing_bx(v), b) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, 0n, F.TNode{l, r}, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, ALeaf{th_ProposerSlashing_bx(y)}, F.u32__pow2u(1n+p), i, th_ProposerSlashing_bx(v), b) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, 1n+p, F.TLeaf{y}, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_ProposerSlashing>, p, l, r, pf)
      +hil = F.array__lt_bridge(i, p, hp, True{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.lo(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l), _, i, th_ProposerSlashing_bx(v), U32.is_lt(i, U32.shr(_)))) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, 1n+p, F.TNode{l, r}, ti, v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), True{}, hil) : {Array.swap.lo(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l), F.u32__pow2u(p), i, th_ProposerSlashing_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p))))) == (am_l16_ProposerSlashing(F.array__tupd(MB<M_ProposerSlashing>, 1n+p, F.TNode{l, r}, ti, v, _)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      %Equal.sym(Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l), F.u32__pow2u(p), i, th_ProposerSlashing_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p)))), (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, p, l, ti, v)), th_ProposerSlashing_bx(x)), amswap_go_l16_ProposerSlashing(p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, MB<M_ProposerSlashing>>, F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), ti), F.spec_common__nth(MB<M_ProposerSlashing>, F.spec_common__append(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), F.array__slots(MB<M_ProposerSlashing>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_ProposerSlashing>>, F.spec_common__nth(MB<M_ProposerSlashing>, F.spec_common__append(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), F.array__slots(MB<M_ProposerSlashing>, r)), ti), F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), ti), F.list__nth_append_left(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), F.array__slots(MB<M_ProposerSlashing>, r), ti, F.array__len_lt(MB<M_ProposerSlashing>, p, l, ti, pl, hil))), hx), U32.is_lt(i, U32.shr(F.u32__pow2u(p))), {==}, pl)) : {Array.swap.lo(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), _) == (am_l16_ProposerSlashing(F.TNode{F.array__tupd(MB<M_ProposerSlashing>, p, l, ti, v, F.array__ndec(p, ti)), r}), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_ProposerSlashing>, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = F.array__lt_bridge(i, p, hp, False{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +le = F.nat__not_lt_le(ti, F.spec_common__pow2(p), nb)
      +j = U32.sub(i, F.u32__pow2u(p))
      +k = Nat.sub(ti, F.spec_common__pow2(p))
      +ej = F.array__sub_bridge(i, p, hp, le)
      +hir = F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), F.array__upper_lt(ti, p, hi, le))
      +hxr = F.logic__subst(Nat, n => {F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, r), n) == Some{x} : Maybe<&2, MB<M_ProposerSlashing>>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, MB<M_ProposerSlashing>>, F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, r), k), F.spec_common__nth(MB<M_ProposerSlashing>, F.spec_common__append(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), F.array__slots(MB<M_ProposerSlashing>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_ProposerSlashing>>, F.spec_common__nth(MB<M_ProposerSlashing>, F.spec_common__append(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, l), F.array__slots(MB<M_ProposerSlashing>, r)), ti), F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, r), k), F.array__right_nth(MB<M_ProposerSlashing>, p, l, r, ti, pl, le)), hx))
      +ih = amswap_go_l16_ProposerSlashing(p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, U32.shr(F.u32__pow2u(p))), {==}, F.array__pf_right(MB<M_ProposerSlashing>, p, l, r, pf))
      +ih2 = F.logic__subst(Nat, n => {Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), F.u32__pow2u(p), j, th_ProposerSlashing_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, p, r, n, v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.hi(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l), Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), _, U32.sub(i, _), th_ProposerSlashing_bx(v), U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, 1n+p, F.TNode{l, r}, ti, v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), False{}, nb) : {Array.swap.hi(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l), Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), F.u32__pow2u(p), j, th_ProposerSlashing_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p))))) == (am_l16_ProposerSlashing(F.array__tupd(MB<M_ProposerSlashing>, 1n+p, F.TNode{l, r}, ti, v, _)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      %Equal.sym(Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(r), F.u32__pow2u(p), j, th_ProposerSlashing_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))), (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, p, r, k, v)), th_ProposerSlashing_bx(x)), ih2) : {Array.swap.hi(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(l), _) == (am_l16_ProposerSlashing(F.TNode{l, F.array__tupd(MB<M_ProposerSlashing>, p, r, k, v, F.array__ndec(p, k))}), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def amswap_l16_ProposerSlashing(+d: Nat, +t: F.array__Tree<MB<M_ProposerSlashing>>, +i: U32, +v: MB<M_ProposerSlashing>, +x: MB<M_ProposerSlashing>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_ProposerSlashing>>}, +pf: {F.array__perfect(MB<M_ProposerSlashing>, d, t) == True{} : Bool}) -> {Array.swap(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t), i, th_ProposerSlashing_bx(v)) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}:
  %Equal.sym(Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & U32, Array.size(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t)), (am_l16_ProposerSlashing(t), F.u32__pow2u(d)), amsize_l16_ProposerSlashing(d, t, pf)) : {Array.swap.at(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, i, th_ProposerSlashing_bx(v), _) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {Array.swap.go(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t), F.u32__pow2u(d), _, th_ProposerSlashing_bx(v), U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>}
  amswap_go_l16_ProposerSlashing(d, t, i, v, x, hd, hi, hx, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), {==}, pf)

def amset_l16_ProposerSlashing(+d: Nat, +t: F.array__Tree<MB<M_ProposerSlashing>>, +i: U32, +v: MB<M_ProposerSlashing>, +x: MB<M_ProposerSlashing>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_ProposerSlashing>>}, +pf: {F.array__perfect(MB<M_ProposerSlashing>, d, t) == True{} : Bool}) -> {Array.set(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t), i, th_ProposerSlashing_bx(v)) == am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>}:
  %Equal.sym(Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>> & O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, Array.swap(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t), i, th_ProposerSlashing_bx(v)), (am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)), th_ProposerSlashing_bx(x)), amswap_l16_ProposerSlashing(d, t, i, v, x, hd, hi, hx, pf)) : {Array.set.fin(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, _) == am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>}
  {==}

# Swap an element out (replaced by th_ProposerSlashing_bx(z)), then set th_ProposerSlashing_bx(x) back: the array is
# unchanged. This is the leaf step of every tree over such a list.
def amswap_back_l16_ProposerSlashing(+d: Nat, +t: F.array__Tree<MB<M_ProposerSlashing>>, +i: U32, +z: MB<M_ProposerSlashing>, +x: MB<M_ProposerSlashing>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_ProposerSlashing>>},
    +pf: {F.array__perfect(MB<M_ProposerSlashing>, d, t) == True{} : Bool})
    -> {Array.set(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), z)), i, th_ProposerSlashing_bx(x)) == am_l16_ProposerSlashing(t) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>}:
  +t2 = F.array__upd(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), z)
  +hz = F.logic__subst(List<&2, MB<M_ProposerSlashing>>, ys => {F.spec_common__nth(MB<M_ProposerSlashing>, ys, U32.to_nat(i)) == Some{z} : Maybe<&2, MB<M_ProposerSlashing>>}, F.spec_common__update(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i), z), F.array__slots(MB<M_ProposerSlashing>, t2),
    Equal.sym(List<&2, MB<M_ProposerSlashing>>, F.array__slots(MB<M_ProposerSlashing>, t2), F.spec_common__update(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i), z), F.array__upd_slots(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), z, hi, pf)),
    F.list__nth_update_same(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i), z, F.list__nth_lt_length(MB<M_ProposerSlashing>, F.array__slots(MB<M_ProposerSlashing>, t), U32.to_nat(i), x, hx)))
  %Equal.sym(Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>, Array.set(O.Boxed<FuluProposerSlashing_d.ProposerSlashing>, am_l16_ProposerSlashing(t2), i, th_ProposerSlashing_bx(x)), am_l16_ProposerSlashing(F.array__upd(MB<M_ProposerSlashing>, d, t2, U32.to_nat(i), x)),
      amset_l16_ProposerSlashing(d, t2, i, x, z, hd, hi, hz, F.array__upd_perfect(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), z, pf))) :
    {_ == am_l16_ProposerSlashing(t) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>}
  %Equal.sym(F.array__Tree<MB<M_ProposerSlashing>>, F.array__upd(MB<M_ProposerSlashing>, d, t2, U32.to_nat(i), x), t, AM.upd_restore(MB<M_ProposerSlashing>, d, t, U32.to_nat(i), z, x, hi, hx, pf)) :
    {am_l16_ProposerSlashing(_) == am_l16_ProposerSlashing(t) : Array<O.Boxed<FuluProposerSlashing_d.ProposerSlashing>>}
  {==}
def xat_l16_ProposerSlashing(W: List<&2, MB<M_ProposerSlashing>>, +i: Nat) -> MB<M_ProposerSlashing>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_ProposerSlashing(t, j)
law nth_l16_ProposerSlashing:
  for +W: List<&2, MB<M_ProposerSlashing>>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(MB<M_ProposerSlashing>, W)) == True{} : Bool}
  {F.spec_common__nth(MB<M_ProposerSlashing>, W, i) == Some{xat_l16_ProposerSlashing(W, i)} : Maybe<&2, MB<M_ProposerSlashing>>}
def nth_l16_ProposerSlashing(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(MB<M_ProposerSlashing>, Nil{}, i) == Some{xat_l16_ProposerSlashing(Nil{}, i)} : Maybe<&2, MB<M_ProposerSlashing>>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l16_ProposerSlashing(t, j, hi)
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
law tfzam_l16_ProposerSlashing:
  for +t: F.array__Tree<MB<M_ProposerSlashing>>
  {tfz_l16_ProposerSlashing(am_l16_ProposerSlashing(t)) == t : F.array__Tree<MB<M_ProposerSlashing>>}
def tfzam_l16_ProposerSlashing(t):
  match t:
    case F.TLeaf{+x}:
      %Equal.sym(MB<M_ProposerSlashing>, fz_ProposerSlashing_bx(th_ProposerSlashing_bx(x)), x, fzth_ProposerSlashing_bx(x)) : {F.TLeaf{_} == F.TLeaf{x} : F.array__Tree<MB<M_ProposerSlashing>>}
      {==}
    case F.TNode{+l, +r}:
      %Equal.sym(F.array__Tree<MB<M_ProposerSlashing>>, tfz_l16_ProposerSlashing(am_l16_ProposerSlashing(l)), l, tfzam_l16_ProposerSlashing(l)) : {F.TNode{_, tfz_l16_ProposerSlashing(am_l16_ProposerSlashing(r))} == F.TNode{l, r} : F.array__Tree<MB<M_ProposerSlashing>>}
      %Equal.sym(F.array__Tree<MB<M_ProposerSlashing>>, tfz_l16_ProposerSlashing(am_l16_ProposerSlashing(r)), r, tfzam_l16_ProposerSlashing(r)) : {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<MB<M_ProposerSlashing>>}
      {==}
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
def fzth_IndexedAttestation(+m: M_IndexedAttestation) -> {fz_IndexedAttestation(th_IndexedAttestation(m)) == m : M_IndexedAttestation}:
  match m:
    case M_IndexedAttestation{+a0, +a1, +a2}:
      %Equal.sym(WMr, fz_w(th_w(a0)), a0, fzth_w(a0)) :
        {M_IndexedAttestation{_, a1, a2} == M_IndexedAttestation{a0, a1, a2} : M_IndexedAttestation}
      {==}

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
def fzth_IndexedAttestation_bx(+m: MB<M_IndexedAttestation>) -> {fz_IndexedAttestation_bx(th_IndexedAttestation_bx(m)) == m : MB<M_IndexedAttestation>}:
  match m:
    case MSome{+v}:
      %Equal.sym(M_IndexedAttestation, fz_IndexedAttestation(th_IndexedAttestation(v)), v, fzth_IndexedAttestation(v)) : {MSome{_} == MSome{v} : MB<M_IndexedAttestation>}
      {==}
    case MNone{}: {==}

# ---- Data mirror of AttesterSlashing ----
type M_AttesterSlashing is Data:
  M_AttesterSlashing{a0: M_IndexedAttestation, a1: M_IndexedAttestation}
def th_AttesterSlashing(m: M_AttesterSlashing) -> FuluAttesterSlashing_d.AttesterSlashing:
  match m:
    case M_AttesterSlashing{+a0, +a1}: FuluAttesterSlashing_d.AttesterSlashing{O.BSome{th_IndexedAttestation(a0), O.BNone{}}, O.BSome{th_IndexedAttestation(a1), O.BNone{}}}
def fz_AttesterSlashing(x: FuluAttesterSlashing_d.AttesterSlashing) -> M_AttesterSlashing:
  match x:
    case FuluAttesterSlashing_d.AttesterSlashing{x0, x1}: M_AttesterSlashing{mfz_IndexedAttestation_bx(x0), mfz_IndexedAttestation_bx(x1)}
def fzth_AttesterSlashing(+m: M_AttesterSlashing) -> {fz_AttesterSlashing(th_AttesterSlashing(m)) == m : M_AttesterSlashing}:
  match m:
    case M_AttesterSlashing{+a0, +a1}:
      %Equal.sym(M_IndexedAttestation, mfz_IndexedAttestation_bx(O.BSome{th_IndexedAttestation(a0), O.BNone{}}), a0, fzth_IndexedAttestation(a0)) :
        {M_AttesterSlashing{_, mfz_IndexedAttestation_bx(O.BSome{th_IndexedAttestation(a1), O.BNone{}})} == M_AttesterSlashing{a0, a1} : M_AttesterSlashing}
      %Equal.sym(M_IndexedAttestation, mfz_IndexedAttestation_bx(O.BSome{th_IndexedAttestation(a1), O.BNone{}}), a1, fzth_IndexedAttestation(a1)) :
        {M_AttesterSlashing{a0, _} == M_AttesterSlashing{a0, a1} : M_AttesterSlashing}
      {==}

def th_AttesterSlashing_bx(m: MB<M_AttesterSlashing>) -> O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>:
  match m:
    case MSome{+v}: O.BSome{th_AttesterSlashing(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_AttesterSlashing_bx(x: O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>) -> MB<M_AttesterSlashing>:
  match x:
    case O.BSome{v, rest}: MSome{fz_AttesterSlashing(v)}
    case O.BNone{}: MNone{}
def fzth_AttesterSlashing_bx(+m: MB<M_AttesterSlashing>) -> {fz_AttesterSlashing_bx(th_AttesterSlashing_bx(m)) == m : MB<M_AttesterSlashing>}:
  match m:
    case MSome{+v}:
      %Equal.sym(M_AttesterSlashing, fz_AttesterSlashing(th_AttesterSlashing(v)), v, fzth_AttesterSlashing(v)) : {MSome{_} == MSome{v} : MB<M_AttesterSlashing>}
      {==}
    case MNone{}: {==}

# ---- l1_AttesterSlashing: list of AttesterSlashing_bx (Type-kind elements, through mirrors) ----
def am_l1_AttesterSlashing(t: F.array__Tree<MB<M_AttesterSlashing>>) -> Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_AttesterSlashing_bx(x)}
    case F.TNode{l, r}: ANode{am_l1_AttesterSlashing(l), am_l1_AttesterSlashing(r)}

def amsize_l1_AttesterSlashing(+d: Nat, +t: F.array__Tree<MB<M_AttesterSlashing>>, +pf: {F.array__perfect(MB<M_AttesterSlashing>, d, t) == True{} : Bool}) -> {Array.size(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t)) == (am_l1_AttesterSlashing(t), F.u32__pow2u(d)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & U32}:
  match d t:
    case 0n F.TLeaf{x}:
      {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({Array.size(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(F.TNode{l, r})) == (am_l1_AttesterSlashing(F.TNode{l, r}), 1) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & U32}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({Array.size(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, ALeaf{th_AttesterSlashing_bx(x)}) == (ALeaf{th_AttesterSlashing_bx(x)}, F.u32__pow2u(1n+p)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & U32}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & U32, Array.size(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l)), (am_l1_AttesterSlashing(l), F.u32__pow2u(p)), amsize_l1_AttesterSlashing(p, l, F.array__pf_left(MB<M_AttesterSlashing>, p, l, r, pf))) : {Array.size.node(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), _) == (ANode{am_l1_AttesterSlashing(l), am_l1_AttesterSlashing(r)}, U32.shl(F.u32__pow2u(p))) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & U32}
      {==}

def amswap_go_l1_AttesterSlashing(+d: Nat, +t: F.array__Tree<MB<M_AttesterSlashing>>, +i: U32, +v: MB<M_AttesterSlashing>, +x: MB<M_AttesterSlashing>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_AttesterSlashing>>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(F.u32__pow2u(d))) == b : Bool}, +pf: {F.array__perfect(MB<M_AttesterSlashing>, d, t) == True{} : Bool}) -> {Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t), F.u32__pow2u(d), i, th_AttesterSlashing_bx(v), b) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(MB<M_AttesterSlashing>, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{th_AttesterSlashing_bx(v)}, th_AttesterSlashing_bx(y)) == (ALeaf{th_AttesterSlashing_bx(v)}, th_AttesterSlashing_bx(_)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(F.TNode{l, r}), 1, i, th_AttesterSlashing_bx(v), b) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, 0n, F.TNode{l, r}, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, ALeaf{th_AttesterSlashing_bx(y)}, F.u32__pow2u(1n+p), i, th_AttesterSlashing_bx(v), b) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, 1n+p, F.TLeaf{y}, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_AttesterSlashing>, p, l, r, pf)
      +hil = F.array__lt_bridge(i, p, hp, True{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.lo(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l), _, i, th_AttesterSlashing_bx(v), U32.is_lt(i, U32.shr(_)))) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, 1n+p, F.TNode{l, r}, ti, v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), True{}, hil) : {Array.swap.lo(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l), F.u32__pow2u(p), i, th_AttesterSlashing_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p))))) == (am_l1_AttesterSlashing(F.array__tupd(MB<M_AttesterSlashing>, 1n+p, F.TNode{l, r}, ti, v, _)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      %Equal.sym(Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l), F.u32__pow2u(p), i, th_AttesterSlashing_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p)))), (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, p, l, ti, v)), th_AttesterSlashing_bx(x)), amswap_go_l1_AttesterSlashing(p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, MB<M_AttesterSlashing>>, F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), ti), F.spec_common__nth(MB<M_AttesterSlashing>, F.spec_common__append(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), F.array__slots(MB<M_AttesterSlashing>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_AttesterSlashing>>, F.spec_common__nth(MB<M_AttesterSlashing>, F.spec_common__append(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), F.array__slots(MB<M_AttesterSlashing>, r)), ti), F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), ti), F.list__nth_append_left(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), F.array__slots(MB<M_AttesterSlashing>, r), ti, F.array__len_lt(MB<M_AttesterSlashing>, p, l, ti, pl, hil))), hx), U32.is_lt(i, U32.shr(F.u32__pow2u(p))), {==}, pl)) : {Array.swap.lo(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), _) == (am_l1_AttesterSlashing(F.TNode{F.array__tupd(MB<M_AttesterSlashing>, p, l, ti, v, F.array__ndec(p, ti)), r}), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_AttesterSlashing>, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = F.array__lt_bridge(i, p, hp, False{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +le = F.nat__not_lt_le(ti, F.spec_common__pow2(p), nb)
      +j = U32.sub(i, F.u32__pow2u(p))
      +k = Nat.sub(ti, F.spec_common__pow2(p))
      +ej = F.array__sub_bridge(i, p, hp, le)
      +hir = F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), F.array__upper_lt(ti, p, hi, le))
      +hxr = F.logic__subst(Nat, n => {F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, r), n) == Some{x} : Maybe<&2, MB<M_AttesterSlashing>>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, MB<M_AttesterSlashing>>, F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, r), k), F.spec_common__nth(MB<M_AttesterSlashing>, F.spec_common__append(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), F.array__slots(MB<M_AttesterSlashing>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_AttesterSlashing>>, F.spec_common__nth(MB<M_AttesterSlashing>, F.spec_common__append(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, l), F.array__slots(MB<M_AttesterSlashing>, r)), ti), F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, r), k), F.array__right_nth(MB<M_AttesterSlashing>, p, l, r, ti, pl, le)), hx))
      +ih = amswap_go_l1_AttesterSlashing(p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, U32.shr(F.u32__pow2u(p))), {==}, F.array__pf_right(MB<M_AttesterSlashing>, p, l, r, pf))
      +ih2 = F.logic__subst(Nat, n => {Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), F.u32__pow2u(p), j, th_AttesterSlashing_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, p, r, n, v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.hi(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l), Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), _, U32.sub(i, _), th_AttesterSlashing_bx(v), U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, 1n+p, F.TNode{l, r}, ti, v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), False{}, nb) : {Array.swap.hi(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l), Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), F.u32__pow2u(p), j, th_AttesterSlashing_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p))))) == (am_l1_AttesterSlashing(F.array__tupd(MB<M_AttesterSlashing>, 1n+p, F.TNode{l, r}, ti, v, _)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      %Equal.sym(Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(r), F.u32__pow2u(p), j, th_AttesterSlashing_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))), (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, p, r, k, v)), th_AttesterSlashing_bx(x)), ih2) : {Array.swap.hi(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(l), _) == (am_l1_AttesterSlashing(F.TNode{l, F.array__tupd(MB<M_AttesterSlashing>, p, r, k, v, F.array__ndec(p, k))}), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def amswap_l1_AttesterSlashing(+d: Nat, +t: F.array__Tree<MB<M_AttesterSlashing>>, +i: U32, +v: MB<M_AttesterSlashing>, +x: MB<M_AttesterSlashing>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_AttesterSlashing>>}, +pf: {F.array__perfect(MB<M_AttesterSlashing>, d, t) == True{} : Bool}) -> {Array.swap(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t), i, th_AttesterSlashing_bx(v)) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}:
  %Equal.sym(Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & U32, Array.size(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t)), (am_l1_AttesterSlashing(t), F.u32__pow2u(d)), amsize_l1_AttesterSlashing(d, t, pf)) : {Array.swap.at(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, i, th_AttesterSlashing_bx(v), _) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {Array.swap.go(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t), F.u32__pow2u(d), _, th_AttesterSlashing_bx(v), U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>}
  amswap_go_l1_AttesterSlashing(d, t, i, v, x, hd, hi, hx, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), {==}, pf)

def amset_l1_AttesterSlashing(+d: Nat, +t: F.array__Tree<MB<M_AttesterSlashing>>, +i: U32, +v: MB<M_AttesterSlashing>, +x: MB<M_AttesterSlashing>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_AttesterSlashing>>}, +pf: {F.array__perfect(MB<M_AttesterSlashing>, d, t) == True{} : Bool}) -> {Array.set(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t), i, th_AttesterSlashing_bx(v)) == am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>}:
  %Equal.sym(Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>> & O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, Array.swap(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t), i, th_AttesterSlashing_bx(v)), (am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)), th_AttesterSlashing_bx(x)), amswap_l1_AttesterSlashing(d, t, i, v, x, hd, hi, hx, pf)) : {Array.set.fin(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, _) == am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>}
  {==}

# Swap an element out (replaced by th_AttesterSlashing_bx(z)), then set th_AttesterSlashing_bx(x) back: the array is
# unchanged. This is the leaf step of every tree over such a list.
def amswap_back_l1_AttesterSlashing(+d: Nat, +t: F.array__Tree<MB<M_AttesterSlashing>>, +i: U32, +z: MB<M_AttesterSlashing>, +x: MB<M_AttesterSlashing>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_AttesterSlashing>>},
    +pf: {F.array__perfect(MB<M_AttesterSlashing>, d, t) == True{} : Bool})
    -> {Array.set(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), z)), i, th_AttesterSlashing_bx(x)) == am_l1_AttesterSlashing(t) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>}:
  +t2 = F.array__upd(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), z)
  +hz = F.logic__subst(List<&2, MB<M_AttesterSlashing>>, ys => {F.spec_common__nth(MB<M_AttesterSlashing>, ys, U32.to_nat(i)) == Some{z} : Maybe<&2, MB<M_AttesterSlashing>>}, F.spec_common__update(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i), z), F.array__slots(MB<M_AttesterSlashing>, t2),
    Equal.sym(List<&2, MB<M_AttesterSlashing>>, F.array__slots(MB<M_AttesterSlashing>, t2), F.spec_common__update(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i), z), F.array__upd_slots(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), z, hi, pf)),
    F.list__nth_update_same(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i), z, F.list__nth_lt_length(MB<M_AttesterSlashing>, F.array__slots(MB<M_AttesterSlashing>, t), U32.to_nat(i), x, hx)))
  %Equal.sym(Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>, Array.set(O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>, am_l1_AttesterSlashing(t2), i, th_AttesterSlashing_bx(x)), am_l1_AttesterSlashing(F.array__upd(MB<M_AttesterSlashing>, d, t2, U32.to_nat(i), x)),
      amset_l1_AttesterSlashing(d, t2, i, x, z, hd, hi, hz, F.array__upd_perfect(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), z, pf))) :
    {_ == am_l1_AttesterSlashing(t) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>}
  %Equal.sym(F.array__Tree<MB<M_AttesterSlashing>>, F.array__upd(MB<M_AttesterSlashing>, d, t2, U32.to_nat(i), x), t, AM.upd_restore(MB<M_AttesterSlashing>, d, t, U32.to_nat(i), z, x, hi, hx, pf)) :
    {am_l1_AttesterSlashing(_) == am_l1_AttesterSlashing(t) : Array<O.Boxed<FuluAttesterSlashing_d.AttesterSlashing>>}
  {==}
def xat_l1_AttesterSlashing(W: List<&2, MB<M_AttesterSlashing>>, +i: Nat) -> MB<M_AttesterSlashing>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l1_AttesterSlashing(t, j)
law nth_l1_AttesterSlashing:
  for +W: List<&2, MB<M_AttesterSlashing>>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(MB<M_AttesterSlashing>, W)) == True{} : Bool}
  {F.spec_common__nth(MB<M_AttesterSlashing>, W, i) == Some{xat_l1_AttesterSlashing(W, i)} : Maybe<&2, MB<M_AttesterSlashing>>}
def nth_l1_AttesterSlashing(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(MB<M_AttesterSlashing>, Nil{}, i) == Some{xat_l1_AttesterSlashing(Nil{}, i)} : Maybe<&2, MB<M_AttesterSlashing>>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l1_AttesterSlashing(t, j, hi)
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
law tfzam_l1_AttesterSlashing:
  for +t: F.array__Tree<MB<M_AttesterSlashing>>
  {tfz_l1_AttesterSlashing(am_l1_AttesterSlashing(t)) == t : F.array__Tree<MB<M_AttesterSlashing>>}
def tfzam_l1_AttesterSlashing(t):
  match t:
    case F.TLeaf{+x}:
      %Equal.sym(MB<M_AttesterSlashing>, fz_AttesterSlashing_bx(th_AttesterSlashing_bx(x)), x, fzth_AttesterSlashing_bx(x)) : {F.TLeaf{_} == F.TLeaf{x} : F.array__Tree<MB<M_AttesterSlashing>>}
      {==}
    case F.TNode{+l, +r}:
      %Equal.sym(F.array__Tree<MB<M_AttesterSlashing>>, tfz_l1_AttesterSlashing(am_l1_AttesterSlashing(l)), l, tfzam_l1_AttesterSlashing(l)) : {F.TNode{_, tfz_l1_AttesterSlashing(am_l1_AttesterSlashing(r))} == F.TNode{l, r} : F.array__Tree<MB<M_AttesterSlashing>>}
      %Equal.sym(F.array__Tree<MB<M_AttesterSlashing>>, tfz_l1_AttesterSlashing(am_l1_AttesterSlashing(r)), r, tfzam_l1_AttesterSlashing(r)) : {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<MB<M_AttesterSlashing>>}
      {==}
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
def fzth_Attestation(+m: M_Attestation) -> {fz_Attestation(th_Attestation(m)) == m : M_Attestation}:
  match m:
    case M_Attestation{+a0, +a1, +a2, +a3}:
      %Equal.sym(BMr, fz_b(th_b(a0)), a0, fzth_b(a0)) :
        {M_Attestation{_, a1, a2, a3} == M_Attestation{a0, a1, a2, a3} : M_Attestation}
      {==}

def th_Attestation_bx(m: MB<M_Attestation>) -> O.Boxed<FuluAttestation_d.Attestation>:
  match m:
    case MSome{+v}: O.BSome{th_Attestation(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_Attestation_bx(x: O.Boxed<FuluAttestation_d.Attestation>) -> MB<M_Attestation>:
  match x:
    case O.BSome{v, rest}: MSome{fz_Attestation(v)}
    case O.BNone{}: MNone{}
def fzth_Attestation_bx(+m: MB<M_Attestation>) -> {fz_Attestation_bx(th_Attestation_bx(m)) == m : MB<M_Attestation>}:
  match m:
    case MSome{+v}:
      %Equal.sym(M_Attestation, fz_Attestation(th_Attestation(v)), v, fzth_Attestation(v)) : {MSome{_} == MSome{v} : MB<M_Attestation>}
      {==}
    case MNone{}: {==}

# ---- l8_Attestation: list of Attestation_bx (Type-kind elements, through mirrors) ----
def am_l8_Attestation(t: F.array__Tree<MB<M_Attestation>>) -> Array<O.Boxed<FuluAttestation_d.Attestation>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_Attestation_bx(x)}
    case F.TNode{l, r}: ANode{am_l8_Attestation(l), am_l8_Attestation(r)}

def amsize_l8_Attestation(+d: Nat, +t: F.array__Tree<MB<M_Attestation>>, +pf: {F.array__perfect(MB<M_Attestation>, d, t) == True{} : Bool}) -> {Array.size(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t)) == (am_l8_Attestation(t), F.u32__pow2u(d)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & U32}:
  match d t:
    case 0n F.TLeaf{x}:
      {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({Array.size(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(F.TNode{l, r})) == (am_l8_Attestation(F.TNode{l, r}), 1) : Array<O.Boxed<FuluAttestation_d.Attestation>> & U32}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({Array.size(O.Boxed<FuluAttestation_d.Attestation>, ALeaf{th_Attestation_bx(x)}) == (ALeaf{th_Attestation_bx(x)}, F.u32__pow2u(1n+p)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & U32}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<FuluAttestation_d.Attestation>> & U32, Array.size(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l)), (am_l8_Attestation(l), F.u32__pow2u(p)), amsize_l8_Attestation(p, l, F.array__pf_left(MB<M_Attestation>, p, l, r, pf))) : {Array.size.node(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), _) == (ANode{am_l8_Attestation(l), am_l8_Attestation(r)}, U32.shl(F.u32__pow2u(p))) : Array<O.Boxed<FuluAttestation_d.Attestation>> & U32}
      {==}

def amswap_go_l8_Attestation(+d: Nat, +t: F.array__Tree<MB<M_Attestation>>, +i: U32, +v: MB<M_Attestation>, +x: MB<M_Attestation>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Attestation>>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(F.u32__pow2u(d))) == b : Bool}, +pf: {F.array__perfect(MB<M_Attestation>, d, t) == True{} : Bool}) -> {Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t), F.u32__pow2u(d), i, th_Attestation_bx(v), b) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(MB<M_Attestation>, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{th_Attestation_bx(v)}, th_Attestation_bx(y)) == (ALeaf{th_Attestation_bx(v)}, th_Attestation_bx(_)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(F.TNode{l, r}), 1, i, th_Attestation_bx(v), b) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, 0n, F.TNode{l, r}, U32.to_nat(i), v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, ALeaf{th_Attestation_bx(y)}, F.u32__pow2u(1n+p), i, th_Attestation_bx(v), b) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, 1n+p, F.TLeaf{y}, U32.to_nat(i), v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_Attestation>, p, l, r, pf)
      +hil = F.array__lt_bridge(i, p, hp, True{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.lo(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l), _, i, th_Attestation_bx(v), U32.is_lt(i, U32.shr(_)))) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, 1n+p, F.TNode{l, r}, ti, v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), True{}, hil) : {Array.swap.lo(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l), F.u32__pow2u(p), i, th_Attestation_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p))))) == (am_l8_Attestation(F.array__tupd(MB<M_Attestation>, 1n+p, F.TNode{l, r}, ti, v, _)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      %Equal.sym(Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>, Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l), F.u32__pow2u(p), i, th_Attestation_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p)))), (am_l8_Attestation(F.array__upd(MB<M_Attestation>, p, l, ti, v)), th_Attestation_bx(x)), amswap_go_l8_Attestation(p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, MB<M_Attestation>>, F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), ti), F.spec_common__nth(MB<M_Attestation>, F.spec_common__append(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), F.array__slots(MB<M_Attestation>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_Attestation>>, F.spec_common__nth(MB<M_Attestation>, F.spec_common__append(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), F.array__slots(MB<M_Attestation>, r)), ti), F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), ti), F.list__nth_append_left(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), F.array__slots(MB<M_Attestation>, r), ti, F.array__len_lt(MB<M_Attestation>, p, l, ti, pl, hil))), hx), U32.is_lt(i, U32.shr(F.u32__pow2u(p))), {==}, pl)) : {Array.swap.lo(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), _) == (am_l8_Attestation(F.TNode{F.array__tupd(MB<M_Attestation>, p, l, ti, v, F.array__ndec(p, ti)), r}), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_Attestation>, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = F.array__lt_bridge(i, p, hp, False{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +le = F.nat__not_lt_le(ti, F.spec_common__pow2(p), nb)
      +j = U32.sub(i, F.u32__pow2u(p))
      +k = Nat.sub(ti, F.spec_common__pow2(p))
      +ej = F.array__sub_bridge(i, p, hp, le)
      +hir = F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), F.array__upper_lt(ti, p, hi, le))
      +hxr = F.logic__subst(Nat, n => {F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, r), n) == Some{x} : Maybe<&2, MB<M_Attestation>>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, MB<M_Attestation>>, F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, r), k), F.spec_common__nth(MB<M_Attestation>, F.spec_common__append(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), F.array__slots(MB<M_Attestation>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_Attestation>>, F.spec_common__nth(MB<M_Attestation>, F.spec_common__append(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, l), F.array__slots(MB<M_Attestation>, r)), ti), F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, r), k), F.array__right_nth(MB<M_Attestation>, p, l, r, ti, pl, le)), hx))
      +ih = amswap_go_l8_Attestation(p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, U32.shr(F.u32__pow2u(p))), {==}, F.array__pf_right(MB<M_Attestation>, p, l, r, pf))
      +ih2 = F.logic__subst(Nat, n => {Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), F.u32__pow2u(p), j, th_Attestation_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, p, r, n, v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.hi(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l), Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), _, U32.sub(i, _), th_Attestation_bx(v), U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, 1n+p, F.TNode{l, r}, ti, v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), False{}, nb) : {Array.swap.hi(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l), Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), F.u32__pow2u(p), j, th_Attestation_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p))))) == (am_l8_Attestation(F.array__tupd(MB<M_Attestation>, 1n+p, F.TNode{l, r}, ti, v, _)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      %Equal.sym(Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>, Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(r), F.u32__pow2u(p), j, th_Attestation_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))), (am_l8_Attestation(F.array__upd(MB<M_Attestation>, p, r, k, v)), th_Attestation_bx(x)), ih2) : {Array.swap.hi(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(l), _) == (am_l8_Attestation(F.TNode{l, F.array__tupd(MB<M_Attestation>, p, r, k, v, F.array__ndec(p, k))}), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def amswap_l8_Attestation(+d: Nat, +t: F.array__Tree<MB<M_Attestation>>, +i: U32, +v: MB<M_Attestation>, +x: MB<M_Attestation>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Attestation>>}, +pf: {F.array__perfect(MB<M_Attestation>, d, t) == True{} : Bool}) -> {Array.swap(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t), i, th_Attestation_bx(v)) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}:
  %Equal.sym(Array<O.Boxed<FuluAttestation_d.Attestation>> & U32, Array.size(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t)), (am_l8_Attestation(t), F.u32__pow2u(d)), amsize_l8_Attestation(d, t, pf)) : {Array.swap.at(O.Boxed<FuluAttestation_d.Attestation>, i, th_Attestation_bx(v), _) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {Array.swap.go(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t), F.u32__pow2u(d), _, th_Attestation_bx(v), U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == (am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)), th_Attestation_bx(x)) : Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>}
  amswap_go_l8_Attestation(d, t, i, v, x, hd, hi, hx, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), {==}, pf)

def amset_l8_Attestation(+d: Nat, +t: F.array__Tree<MB<M_Attestation>>, +i: U32, +v: MB<M_Attestation>, +x: MB<M_Attestation>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Attestation>>}, +pf: {F.array__perfect(MB<M_Attestation>, d, t) == True{} : Bool}) -> {Array.set(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t), i, th_Attestation_bx(v)) == am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluAttestation_d.Attestation>>}:
  %Equal.sym(Array<O.Boxed<FuluAttestation_d.Attestation>> & O.Boxed<FuluAttestation_d.Attestation>, Array.swap(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t), i, th_Attestation_bx(v)), (am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)), th_Attestation_bx(x)), amswap_l8_Attestation(d, t, i, v, x, hd, hi, hx, pf)) : {Array.set.fin(O.Boxed<FuluAttestation_d.Attestation>, _) == am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluAttestation_d.Attestation>>}
  {==}

# Swap an element out (replaced by th_Attestation_bx(z)), then set th_Attestation_bx(x) back: the array is
# unchanged. This is the leaf step of every tree over such a list.
def amswap_back_l8_Attestation(+d: Nat, +t: F.array__Tree<MB<M_Attestation>>, +i: U32, +z: MB<M_Attestation>, +x: MB<M_Attestation>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Attestation>>},
    +pf: {F.array__perfect(MB<M_Attestation>, d, t) == True{} : Bool})
    -> {Array.set(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), z)), i, th_Attestation_bx(x)) == am_l8_Attestation(t) : Array<O.Boxed<FuluAttestation_d.Attestation>>}:
  +t2 = F.array__upd(MB<M_Attestation>, d, t, U32.to_nat(i), z)
  +hz = F.logic__subst(List<&2, MB<M_Attestation>>, ys => {F.spec_common__nth(MB<M_Attestation>, ys, U32.to_nat(i)) == Some{z} : Maybe<&2, MB<M_Attestation>>}, F.spec_common__update(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i), z), F.array__slots(MB<M_Attestation>, t2),
    Equal.sym(List<&2, MB<M_Attestation>>, F.array__slots(MB<M_Attestation>, t2), F.spec_common__update(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i), z), F.array__upd_slots(MB<M_Attestation>, d, t, U32.to_nat(i), z, hi, pf)),
    F.list__nth_update_same(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i), z, F.list__nth_lt_length(MB<M_Attestation>, F.array__slots(MB<M_Attestation>, t), U32.to_nat(i), x, hx)))
  %Equal.sym(Array<O.Boxed<FuluAttestation_d.Attestation>>, Array.set(O.Boxed<FuluAttestation_d.Attestation>, am_l8_Attestation(t2), i, th_Attestation_bx(x)), am_l8_Attestation(F.array__upd(MB<M_Attestation>, d, t2, U32.to_nat(i), x)),
      amset_l8_Attestation(d, t2, i, x, z, hd, hi, hz, F.array__upd_perfect(MB<M_Attestation>, d, t, U32.to_nat(i), z, pf))) :
    {_ == am_l8_Attestation(t) : Array<O.Boxed<FuluAttestation_d.Attestation>>}
  %Equal.sym(F.array__Tree<MB<M_Attestation>>, F.array__upd(MB<M_Attestation>, d, t2, U32.to_nat(i), x), t, AM.upd_restore(MB<M_Attestation>, d, t, U32.to_nat(i), z, x, hi, hx, pf)) :
    {am_l8_Attestation(_) == am_l8_Attestation(t) : Array<O.Boxed<FuluAttestation_d.Attestation>>}
  {==}
def xat_l8_Attestation(W: List<&2, MB<M_Attestation>>, +i: Nat) -> MB<M_Attestation>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l8_Attestation(t, j)
law nth_l8_Attestation:
  for +W: List<&2, MB<M_Attestation>>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(MB<M_Attestation>, W)) == True{} : Bool}
  {F.spec_common__nth(MB<M_Attestation>, W, i) == Some{xat_l8_Attestation(W, i)} : Maybe<&2, MB<M_Attestation>>}
def nth_l8_Attestation(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(MB<M_Attestation>, Nil{}, i) == Some{xat_l8_Attestation(Nil{}, i)} : Maybe<&2, MB<M_Attestation>>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l8_Attestation(t, j, hi)
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
law tfzam_l8_Attestation:
  for +t: F.array__Tree<MB<M_Attestation>>
  {tfz_l8_Attestation(am_l8_Attestation(t)) == t : F.array__Tree<MB<M_Attestation>>}
def tfzam_l8_Attestation(t):
  match t:
    case F.TLeaf{+x}:
      %Equal.sym(MB<M_Attestation>, fz_Attestation_bx(th_Attestation_bx(x)), x, fzth_Attestation_bx(x)) : {F.TLeaf{_} == F.TLeaf{x} : F.array__Tree<MB<M_Attestation>>}
      {==}
    case F.TNode{+l, +r}:
      %Equal.sym(F.array__Tree<MB<M_Attestation>>, tfz_l8_Attestation(am_l8_Attestation(l)), l, tfzam_l8_Attestation(l)) : {F.TNode{_, tfz_l8_Attestation(am_l8_Attestation(r))} == F.TNode{l, r} : F.array__Tree<MB<M_Attestation>>}
      %Equal.sym(F.array__Tree<MB<M_Attestation>>, tfz_l8_Attestation(am_l8_Attestation(r)), r, tfzam_l8_Attestation(r)) : {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<MB<M_Attestation>>}
      {==}
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
def fzth_Deposit(+m: M_Deposit) -> {fz_Deposit(th_Deposit(m)) == m : M_Deposit}:
  match m:
    case M_Deposit{+a0, +a1}:
      %Equal.sym(WMr, fz_w(th_w(a0)), a0, fzth_w(a0)) :
        {M_Deposit{_, mfz_DepositData_bx(O.BSome{a1, O.BNone{}})} == M_Deposit{a0, a1} : M_Deposit}
      {==}

def th_Deposit_bx(m: MB<M_Deposit>) -> O.Boxed<FuluDeposit_d.Deposit>:
  match m:
    case MSome{+v}: O.BSome{th_Deposit(v), O.BNone{}}
    case MNone{}: O.BNone{}
def fz_Deposit_bx(x: O.Boxed<FuluDeposit_d.Deposit>) -> MB<M_Deposit>:
  match x:
    case O.BSome{v, rest}: MSome{fz_Deposit(v)}
    case O.BNone{}: MNone{}
def fzth_Deposit_bx(+m: MB<M_Deposit>) -> {fz_Deposit_bx(th_Deposit_bx(m)) == m : MB<M_Deposit>}:
  match m:
    case MSome{+v}:
      %Equal.sym(M_Deposit, fz_Deposit(th_Deposit(v)), v, fzth_Deposit(v)) : {MSome{_} == MSome{v} : MB<M_Deposit>}
      {==}
    case MNone{}: {==}

# ---- l16_Deposit: list of Deposit_bx (Type-kind elements, through mirrors) ----
def am_l16_Deposit(t: F.array__Tree<MB<M_Deposit>>) -> Array<O.Boxed<FuluDeposit_d.Deposit>>:
  match t:
    case F.TLeaf{x}: ALeaf{th_Deposit_bx(x)}
    case F.TNode{l, r}: ANode{am_l16_Deposit(l), am_l16_Deposit(r)}

def amsize_l16_Deposit(+d: Nat, +t: F.array__Tree<MB<M_Deposit>>, +pf: {F.array__perfect(MB<M_Deposit>, d, t) == True{} : Bool}) -> {Array.size(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t)) == (am_l16_Deposit(t), F.u32__pow2u(d)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & U32}:
  match d t:
    case 0n F.TLeaf{x}:
      {==}
    case 0n F.TNode{l, r}:
      Empty.absurd({Array.size(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(F.TNode{l, r})) == (am_l16_Deposit(F.TNode{l, r}), 1) : Array<O.Boxed<FuluDeposit_d.Deposit>> & U32}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{x}:
      Empty.absurd({Array.size(O.Boxed<FuluDeposit_d.Deposit>, ALeaf{th_Deposit_bx(x)}) == (ALeaf{th_Deposit_bx(x)}, F.u32__pow2u(1n+p)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & U32}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<FuluDeposit_d.Deposit>> & U32, Array.size(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l)), (am_l16_Deposit(l), F.u32__pow2u(p)), amsize_l16_Deposit(p, l, F.array__pf_left(MB<M_Deposit>, p, l, r, pf))) : {Array.size.node(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), _) == (ANode{am_l16_Deposit(l), am_l16_Deposit(r)}, U32.shl(F.u32__pow2u(p))) : Array<O.Boxed<FuluDeposit_d.Deposit>> & U32}
      {==}

def amswap_go_l16_Deposit(+d: Nat, +t: F.array__Tree<MB<M_Deposit>>, +i: U32, +v: MB<M_Deposit>, +x: MB<M_Deposit>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Deposit>>}, +b: Bool, +eb: {U32.is_lt(i, U32.shr(F.u32__pow2u(d))) == b : Bool}, +pf: {F.array__perfect(MB<M_Deposit>, d, t) == True{} : Bool}) -> {Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t), F.u32__pow2u(d), i, th_Deposit_bx(v), b) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}:
  match d t b:
    case 0n F.TLeaf{+y} _:
      %F.array__leaf_value(MB<M_Deposit>, y, U32.to_nat(i), x, hi, hx) : {(ALeaf{th_Deposit_bx(v)}, th_Deposit_bx(y)) == (ALeaf{th_Deposit_bx(v)}, th_Deposit_bx(_)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      {==}
    case 0n F.TNode{l, r} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(F.TNode{l, r}), 1, i, th_Deposit_bx(v), b) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, 0n, F.TNode{l, r}, U32.to_nat(i), v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}, F.logic__false_true(pf))
    case 1n+p F.TLeaf{y} _:
      Empty.absurd({Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, ALeaf{th_Deposit_bx(y)}, F.u32__pow2u(1n+p), i, th_Deposit_bx(v), b) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, 1n+p, F.TLeaf{y}, U32.to_nat(i), v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}, F.logic__false_true(pf))
    case 1n+ +p F.TNode{+l, +r} True{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_Deposit>, p, l, r, pf)
      +hil = F.array__lt_bridge(i, p, hp, True{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == True{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +ti = U32.to_nat(i)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.lo(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l), _, i, th_Deposit_bx(v), U32.is_lt(i, U32.shr(_)))) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, 1n+p, F.TNode{l, r}, ti, v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), True{}, hil) : {Array.swap.lo(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l), F.u32__pow2u(p), i, th_Deposit_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p))))) == (am_l16_Deposit(F.array__tupd(MB<M_Deposit>, 1n+p, F.TNode{l, r}, ti, v, _)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      %Equal.sym(Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>, Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l), F.u32__pow2u(p), i, th_Deposit_bx(v), U32.is_lt(i, U32.shr(F.u32__pow2u(p)))), (am_l16_Deposit(F.array__upd(MB<M_Deposit>, p, l, ti, v)), th_Deposit_bx(x)), amswap_go_l16_Deposit(p, l, i, v, x, hp, hil, Equal.trans(Maybe<&2, MB<M_Deposit>>, F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), ti), F.spec_common__nth(MB<M_Deposit>, F.spec_common__append(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), F.array__slots(MB<M_Deposit>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_Deposit>>, F.spec_common__nth(MB<M_Deposit>, F.spec_common__append(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), F.array__slots(MB<M_Deposit>, r)), ti), F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), ti), F.list__nth_append_left(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), F.array__slots(MB<M_Deposit>, r), ti, F.array__len_lt(MB<M_Deposit>, p, l, ti, pl, hil))), hx), U32.is_lt(i, U32.shr(F.u32__pow2u(p))), {==}, pl)) : {Array.swap.lo(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), _) == (am_l16_Deposit(F.TNode{F.array__tupd(MB<M_Deposit>, p, l, ti, v, F.array__ndec(p, ti)), r}), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      {==}
    case 1n+ +p F.TNode{+l, +r} False{}:
      +hp = F.nat__lt_trans(p, 1n+p, 32n, F.nat__lt_succ(p), hd)
      +pl = F.array__pf_left(MB<M_Deposit>, p, l, r, pf)
      +ti = U32.to_nat(i)
      +nb = F.array__lt_bridge(i, p, hp, False{}, F.logic__subst(U32, w => {U32.is_lt(i, w) == False{} : Bool}, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd), eb))
      +le = F.nat__not_lt_le(ti, F.spec_common__pow2(p), nb)
      +j = U32.sub(i, F.u32__pow2u(p))
      +k = Nat.sub(ti, F.spec_common__pow2(p))
      +ej = F.array__sub_bridge(i, p, hp, le)
      +hir = F.logic__subst(Nat, n => {Nat.is_lt(n, F.spec_common__pow2(p)) == True{} : Bool}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), F.array__upper_lt(ti, p, hi, le))
      +hxr = F.logic__subst(Nat, n => {F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, r), n) == Some{x} : Maybe<&2, MB<M_Deposit>>}, k, U32.to_nat(j), Equal.sym(Nat, U32.to_nat(j), k, ej), Equal.trans(Maybe<&2, MB<M_Deposit>>, F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, r), k), F.spec_common__nth(MB<M_Deposit>, F.spec_common__append(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), F.array__slots(MB<M_Deposit>, r)), ti), Some{x}, Equal.sym(Maybe<&2, MB<M_Deposit>>, F.spec_common__nth(MB<M_Deposit>, F.spec_common__append(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, l), F.array__slots(MB<M_Deposit>, r)), ti), F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, r), k), F.array__right_nth(MB<M_Deposit>, p, l, r, ti, pl, le)), hx))
      +ih = amswap_go_l16_Deposit(p, r, j, v, x, hp, hir, hxr, U32.is_lt(j, U32.shr(F.u32__pow2u(p))), {==}, F.array__pf_right(MB<M_Deposit>, p, l, r, pf))
      +ih2 = F.logic__subst(Nat, n => {Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), F.u32__pow2u(p), j, th_Deposit_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, p, r, n, v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}, U32.to_nat(j), k, ej, ih)
      %Equal.sym(U32, U32.shr(F.u32__pow2u(1n+p)), F.u32__pow2u(p), F.u32__shr_pow2u(p, hd)) : {Array.swap.hi(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l), Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), _, U32.sub(i, _), th_Deposit_bx(v), U32.is_lt(U32.sub(i, _), U32.shr(_)))) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, 1n+p, F.TNode{l, r}, ti, v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      %Equal.sym(Bool, Nat.is_lt(ti, F.spec_common__pow2(p)), False{}, nb) : {Array.swap.hi(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l), Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), F.u32__pow2u(p), j, th_Deposit_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p))))) == (am_l16_Deposit(F.array__tupd(MB<M_Deposit>, 1n+p, F.TNode{l, r}, ti, v, _)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      %Equal.sym(Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>, Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(r), F.u32__pow2u(p), j, th_Deposit_bx(v), U32.is_lt(j, U32.shr(F.u32__pow2u(p)))), (am_l16_Deposit(F.array__upd(MB<M_Deposit>, p, r, k, v)), th_Deposit_bx(x)), ih2) : {Array.swap.hi(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(l), _) == (am_l16_Deposit(F.TNode{l, F.array__tupd(MB<M_Deposit>, p, r, k, v, F.array__ndec(p, k))}), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
      {==}

# Public Base entry points. Premises: the tree is perfect of depth d < 32 and
# the index is below 2^d; x is the value currently stored at that index.
def amswap_l16_Deposit(+d: Nat, +t: F.array__Tree<MB<M_Deposit>>, +i: U32, +v: MB<M_Deposit>, +x: MB<M_Deposit>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Deposit>>}, +pf: {F.array__perfect(MB<M_Deposit>, d, t) == True{} : Bool}) -> {Array.swap(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t), i, th_Deposit_bx(v)) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}:
  %Equal.sym(Array<O.Boxed<FuluDeposit_d.Deposit>> & U32, Array.size(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t)), (am_l16_Deposit(t), F.u32__pow2u(d)), amsize_l16_Deposit(d, t, pf)) : {Array.swap.at(O.Boxed<FuluDeposit_d.Deposit>, i, th_Deposit_bx(v), _) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
  %Equal.sym(U32, U32.and(i, U32.sub(F.u32__pow2u(d), 1)), i, F.u32__mask_pow2u(i, d, hd, hi)) : {Array.swap.go(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t), F.u32__pow2u(d), _, th_Deposit_bx(v), U32.is_lt(_, U32.shr(F.u32__pow2u(d)))) == (am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)), th_Deposit_bx(x)) : Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>}
  amswap_go_l16_Deposit(d, t, i, v, x, hd, hi, hx, U32.is_lt(i, U32.shr(F.u32__pow2u(d))), {==}, pf)

def amset_l16_Deposit(+d: Nat, +t: F.array__Tree<MB<M_Deposit>>, +i: U32, +v: MB<M_Deposit>, +x: MB<M_Deposit>, +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool}, +hx: {F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Deposit>>}, +pf: {F.array__perfect(MB<M_Deposit>, d, t) == True{} : Bool}) -> {Array.set(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t), i, th_Deposit_bx(v)) == am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluDeposit_d.Deposit>>}:
  %Equal.sym(Array<O.Boxed<FuluDeposit_d.Deposit>> & O.Boxed<FuluDeposit_d.Deposit>, Array.swap(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t), i, th_Deposit_bx(v)), (am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)), th_Deposit_bx(x)), amswap_l16_Deposit(d, t, i, v, x, hd, hi, hx, pf)) : {Array.set.fin(O.Boxed<FuluDeposit_d.Deposit>, _) == am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), v)) : Array<O.Boxed<FuluDeposit_d.Deposit>>}
  {==}

# Swap an element out (replaced by th_Deposit_bx(z)), then set th_Deposit_bx(x) back: the array is
# unchanged. This is the leaf step of every tree over such a list.
def amswap_back_l16_Deposit(+d: Nat, +t: F.array__Tree<MB<M_Deposit>>, +i: U32, +z: MB<M_Deposit>, +x: MB<M_Deposit>,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool},
    +hi: {Nat.is_lt(U32.to_nat(i), F.spec_common__pow2(d)) == True{} : Bool},
    +hx: {F.spec_common__nth(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i)) == Some{x} : Maybe<&2, MB<M_Deposit>>},
    +pf: {F.array__perfect(MB<M_Deposit>, d, t) == True{} : Bool})
    -> {Array.set(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), z)), i, th_Deposit_bx(x)) == am_l16_Deposit(t) : Array<O.Boxed<FuluDeposit_d.Deposit>>}:
  +t2 = F.array__upd(MB<M_Deposit>, d, t, U32.to_nat(i), z)
  +hz = F.logic__subst(List<&2, MB<M_Deposit>>, ys => {F.spec_common__nth(MB<M_Deposit>, ys, U32.to_nat(i)) == Some{z} : Maybe<&2, MB<M_Deposit>>}, F.spec_common__update(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i), z), F.array__slots(MB<M_Deposit>, t2),
    Equal.sym(List<&2, MB<M_Deposit>>, F.array__slots(MB<M_Deposit>, t2), F.spec_common__update(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i), z), F.array__upd_slots(MB<M_Deposit>, d, t, U32.to_nat(i), z, hi, pf)),
    F.list__nth_update_same(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i), z, F.list__nth_lt_length(MB<M_Deposit>, F.array__slots(MB<M_Deposit>, t), U32.to_nat(i), x, hx)))
  %Equal.sym(Array<O.Boxed<FuluDeposit_d.Deposit>>, Array.set(O.Boxed<FuluDeposit_d.Deposit>, am_l16_Deposit(t2), i, th_Deposit_bx(x)), am_l16_Deposit(F.array__upd(MB<M_Deposit>, d, t2, U32.to_nat(i), x)),
      amset_l16_Deposit(d, t2, i, x, z, hd, hi, hz, F.array__upd_perfect(MB<M_Deposit>, d, t, U32.to_nat(i), z, pf))) :
    {_ == am_l16_Deposit(t) : Array<O.Boxed<FuluDeposit_d.Deposit>>}
  %Equal.sym(F.array__Tree<MB<M_Deposit>>, F.array__upd(MB<M_Deposit>, d, t2, U32.to_nat(i), x), t, AM.upd_restore(MB<M_Deposit>, d, t, U32.to_nat(i), z, x, hi, hx, pf)) :
    {am_l16_Deposit(_) == am_l16_Deposit(t) : Array<O.Boxed<FuluDeposit_d.Deposit>>}
  {==}
def xat_l16_Deposit(W: List<&2, MB<M_Deposit>>, +i: Nat) -> MB<M_Deposit>:
  match W:
    case Nil{}: MNone{}
    case Con{+x, t}:
      match i:
        case 0n: x
        case 1n+j: xat_l16_Deposit(t, j)
law nth_l16_Deposit:
  for +W: List<&2, MB<M_Deposit>>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(MB<M_Deposit>, W)) == True{} : Bool}
  {F.spec_common__nth(MB<M_Deposit>, W, i) == Some{xat_l16_Deposit(W, i)} : Maybe<&2, MB<M_Deposit>>}
def nth_l16_Deposit(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(MB<M_Deposit>, Nil{}, i) == Some{xat_l16_Deposit(Nil{}, i)} : Maybe<&2, MB<M_Deposit>>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l16_Deposit(t, j, hi)
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
law tfzam_l16_Deposit:
  for +t: F.array__Tree<MB<M_Deposit>>
  {tfz_l16_Deposit(am_l16_Deposit(t)) == t : F.array__Tree<MB<M_Deposit>>}
def tfzam_l16_Deposit(t):
  match t:
    case F.TLeaf{+x}:
      %Equal.sym(MB<M_Deposit>, fz_Deposit_bx(th_Deposit_bx(x)), x, fzth_Deposit_bx(x)) : {F.TLeaf{_} == F.TLeaf{x} : F.array__Tree<MB<M_Deposit>>}
      {==}
    case F.TNode{+l, +r}:
      %Equal.sym(F.array__Tree<MB<M_Deposit>>, tfz_l16_Deposit(am_l16_Deposit(l)), l, tfzam_l16_Deposit(l)) : {F.TNode{_, tfz_l16_Deposit(am_l16_Deposit(r))} == F.TNode{l, r} : F.array__Tree<MB<M_Deposit>>}
      %Equal.sym(F.array__Tree<MB<M_Deposit>>, tfz_l16_Deposit(am_l16_Deposit(r)), r, tfzam_l16_Deposit(r)) : {F.TNode{l, _} == F.TNode{l, r} : F.array__Tree<MB<M_Deposit>>}
      {==}
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
law nth_l16_SignedVoluntaryExit:
  for +W: List<&2, FuluSignedVoluntaryExit_d.SignedVoluntaryExit>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, W)) == True{} : Bool}
  {F.spec_common__nth(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, W, i) == Some{xat_l16_SignedVoluntaryExit(W, i)} : Maybe<&2, FuluSignedVoluntaryExit_d.SignedVoluntaryExit>}
def nth_l16_SignedVoluntaryExit(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FuluSignedVoluntaryExit_d.SignedVoluntaryExit, Nil{}, i) == Some{xat_l16_SignedVoluntaryExit(Nil{}, i)} : Maybe<&2, FuluSignedVoluntaryExit_d.SignedVoluntaryExit>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l16_SignedVoluntaryExit(t, j, hi)
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
law nth_l16_SignedBLSToExecutionChange:
  for +W: List<&2, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange>
  for +i: Nat
  for +hi: {Nat.is_lt(i, F.spec_common__length(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, W)) == True{} : Bool}
  {F.spec_common__nth(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, W, i) == Some{xat_l16_SignedBLSToExecutionChange(W, i)} : Maybe<&2, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange>}
def nth_l16_SignedBLSToExecutionChange(W, i, hi):
  match W:
    case Nil{}: Empty.absurd({F.spec_common__nth(FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange, Nil{}, i) == Some{xat_l16_SignedBLSToExecutionChange(Nil{}, i)} : Maybe<&2, FuluSignedBLSToExecutionChange_d.SignedBLSToExecutionChange>}, MD.false_true(Equal.trans(Bool, False{}, Nat.is_lt(i, 0n), True{}, Equal.sym(Bool, Nat.is_lt(i, 0n), False{}, F.nat__not_lt_zero(i)), hi)))
    case Con{+x, +t}:
      match i:
        case 0n: {==}
        case 1n+ +j: nth_l16_SignedBLSToExecutionChange(t, j, hi)
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
