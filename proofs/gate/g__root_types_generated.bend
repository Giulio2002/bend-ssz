import Base
import ../compact/found_generated.bend as F
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/FuluContributionAndProof_def_generated.bend as FuluContributionAndProof_d
import ../../types/FuluContributionAndProof_hashtreeroot_generated.bend as FuluContributionAndProof_h
import ../../types/FuluSignedContributionAndProof_def_generated.bend as FuluSignedContributionAndProof_d
import ../../types/FuluSignedContributionAndProof_hashtreeroot_generated.bend as FuluSignedContributionAndProof_h
import ../../types/FuluProposerSlashing_def_generated.bend as FuluProposerSlashing_d
import ../../types/FuluProposerSlashing_hashtreeroot_generated.bend as FuluProposerSlashing_h
import ../../types/FuluHistoricalBatch_def_generated.bend as FuluHistoricalBatch_d
import ../../types/FuluHistoricalBatch_hashtreeroot_generated.bend as FuluHistoricalBatch_h
import ../../types/FuluAttestation_def_generated.bend as FuluAttestation_d
import ../../types/FuluAttestation_hashtreeroot_generated.bend as FuluAttestation_h
import ../../types/FuluAggregateAndProof_def_generated.bend as FuluAggregateAndProof_d
import ../../types/FuluAggregateAndProof_hashtreeroot_generated.bend as FuluAggregateAndProof_h
import ../../types/FuluSignedAggregateAndProof_def_generated.bend as FuluSignedAggregateAndProof_d
import ../../types/FuluSignedAggregateAndProof_hashtreeroot_generated.bend as FuluSignedAggregateAndProof_h
import ../../types/FuluPendingAttestation_def_generated.bend as FuluPendingAttestation_d
import ../../types/FuluPendingAttestation_hashtreeroot_generated.bend as FuluPendingAttestation_h
import ../../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
import ../../types/FuluIndexedAttestation_hashtreeroot_generated.bend as FuluIndexedAttestation_h
import ../../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
import ../../types/FuluAttesterSlashing_hashtreeroot_generated.bend as FuluAttesterSlashing_h
import ../../types/FuluSyncCommittee_def_generated.bend as FuluSyncCommittee_d
import ../../types/FuluSyncCommittee_hashtreeroot_generated.bend as FuluSyncCommittee_h
import ../../types/FuluDeposit_def_generated.bend as FuluDeposit_d
import ../../types/FuluDeposit_hashtreeroot_generated.bend as FuluDeposit_h
import ../../types/FuluExecutionRequests_def_generated.bend as FuluExecutionRequests_d
import ../../types/FuluExecutionRequests_hashtreeroot_generated.bend as FuluExecutionRequests_h
import ../../types/FuluExecutionPayloadHeader_def_generated.bend as FuluExecutionPayloadHeader_d
import ../../types/FuluExecutionPayloadHeader_hashtreeroot_generated.bend as FuluExecutionPayloadHeader_h
import ../../types/FuluLightClientHeader_def_generated.bend as FuluLightClientHeader_d
import ../../types/FuluLightClientHeader_hashtreeroot_generated.bend as FuluLightClientHeader_h
import ../../types/FuluLightClientOptimisticUpdate_def_generated.bend as FuluLightClientOptimisticUpdate_d
import ../../types/FuluLightClientOptimisticUpdate_hashtreeroot_generated.bend as FuluLightClientOptimisticUpdate_h
import ../../types/FuluLightClientFinalityUpdate_def_generated.bend as FuluLightClientFinalityUpdate_d
import ../../types/FuluLightClientFinalityUpdate_hashtreeroot_generated.bend as FuluLightClientFinalityUpdate_h
import ../../types/FuluLightClientUpdate_def_generated.bend as FuluLightClientUpdate_d
import ../../types/FuluLightClientUpdate_hashtreeroot_generated.bend as FuluLightClientUpdate_h
import ../../types/FuluLightClientBootstrap_def_generated.bend as FuluLightClientBootstrap_d
import ../../types/FuluLightClientBootstrap_hashtreeroot_generated.bend as FuluLightClientBootstrap_h
import ../../types/FuluBlob_hashtreeroot_generated.bend as FuluBlob_h
import ../../types/FuluBlobSidecar_def_generated.bend as FuluBlobSidecar_d
import ../../types/FuluBlobSidecar_hashtreeroot_generated.bend as FuluBlobSidecar_h
import ../../types/FuluCell_hashtreeroot_generated.bend as FuluCell_h
import ../../types/FuluDataColumnsByRootIdentifier_def_generated.bend as FuluDataColumnsByRootIdentifier_d
import ../../types/FuluDataColumnsByRootIdentifier_hashtreeroot_generated.bend as FuluDataColumnsByRootIdentifier_h
import ../../types/FuluMatrixEntry_def_generated.bend as FuluMatrixEntry_d
import ../../types/FuluMatrixEntry_hashtreeroot_generated.bend as FuluMatrixEntry_h
import ../../types/FuluDataColumnSidecar_def_generated.bend as FuluDataColumnSidecar_d
import ../../types/FuluDataColumnSidecar_hashtreeroot_generated.bend as FuluDataColumnSidecar_h
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../obj/cform.bend as CF
import ../obj/amap.bend as AM
import ../../spec/root_relation.bend as RR
import ../../spec/fulu_schemas.bend as Spec
import ../obj/schema_shapes_generated.bend as SH
import ../obj/dk.bend as DK
import ../obj/mtree_defs.bend as MD
import ../obj/words_obj_light.bend as WO_L
import ../obj/list_obj_light.bend as LO_L
import ../obj/pv_obj_light.bend as PV_L
import ../obj/bitlist_obj_light.bend as BO_L
import ../obj/cells_light.bend as CE_L
import ../obj/obj_support.bend as OS
import ../obj/root_names_light_generated.bend as RN_L
import ../obj/ulist_obj_light.bend as UL_L
import ../obj/elems48_light.bend as E48_L
import ../obj/xlist_support.bend as XS
import ../obj/mtree_run.bend as MR
import ../../spec/codec.bend as Codec
import ../../spec/limits.bend as Lim
import ../../spec/bit_root.bend as Mix
import ../../spec/nat_bytes.bend as Len
import ../../spec/byte_list.bend as BL
import ../obj/root_types_light_generated.bend as LV
import ../obj/root_types_generated.bend as PRV

# GENERATED by object_api_coverage_gate (codegen). Do not edit.
# The object API laws that proofs/obj/root_types_generated.bend proves (AggregateAndProof, Attestation, AttesterSlashing, Blob, BlobSidecar, Cell, ContributionAndProof, DataColumnSidecar, DataColumnsByRootIdentifier, Deposit, ExecutionPayloadHeader, ExecutionRequests, HistoricalBatch, IndexedAttestation, LightClientBootstrap, LightClientFinalityUpdate, LightClientHeader, LightClientOptimisticUpdate, LightClientUpdate, MatrixEntry, PendingAttestation, ProposerSlashing, SignedAggregateAndProof, SignedContributionAndProof, SyncCommittee), each discharged by that law.

def AggregateAndProof__root__AggregateAndProof_root_correct(-h: B.Buf, -o: FuluAggregateAndProof_d.AggregateAndProof, +s: S.Schema, +es: {s == Spec.AggregateAndProof() : S.Schema}, +rep: LV.rep_AggregateAndProof(o, s)) -> RR.roots(LV.v_AggregateAndProof(o), s, [D.bytes(Pair.snd(FuluAggregateAndProof_d.AggregateAndProof, D.Digest, Pair.snd(B.Buf, FuluAggregateAndProof_d.AggregateAndProof & D.Digest, FuluAggregateAndProof_h.AggregateAndProof_hash_tree_root(h, o))))]):
  PRV.AggregateAndProof_root_correct(h, o, s, es, rep)

def Attestation__root__Attestation_root_correct(-h: B.Buf, -o: FuluAttestation_d.Attestation, +s: S.Schema, +es: {s == Spec.Attestation() : S.Schema}, +rep: LV.rep_Attestation(o, s)) -> RR.roots(LV.v_Attestation(o), s, [D.bytes(Pair.snd(FuluAttestation_d.Attestation, D.Digest, Pair.snd(B.Buf, FuluAttestation_d.Attestation & D.Digest, FuluAttestation_h.Attestation_hash_tree_root(h, o))))]):
  PRV.Attestation_root_correct(h, o, s, es, rep)

def AttesterSlashing__root__AttesterSlashing_root_correct(-h: B.Buf, -o: FuluAttesterSlashing_d.AttesterSlashing, +s: S.Schema, +es: {s == Spec.AttesterSlashing() : S.Schema}, +rep: LV.rep_AttesterSlashing(o, s)) -> RR.roots(LV.v_AttesterSlashing(o), s, [D.bytes(Pair.snd(FuluAttesterSlashing_d.AttesterSlashing, D.Digest, Pair.snd(B.Buf, FuluAttesterSlashing_d.AttesterSlashing & D.Digest, FuluAttesterSlashing_h.AttesterSlashing_hash_tree_root(h, o))))]):
  PRV.AttesterSlashing_root_correct(h, o, s, es, rep)

def Blob__root__Blob_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Blob() : S.Schema}, +rep: WO_L.rep_bv(o, s)) -> RR.roots(S.BytesValue{WO_L.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, FuluBlob_h.Blob_hash_tree_root(h, o))))]):
  PRV.Blob_root_correct(h, o, s, es, rep)

def BlobSidecar__root__BlobSidecar_root_correct(-h: B.Buf, -o: FuluBlobSidecar_d.BlobSidecar, +s: S.Schema, +es: {s == Spec.BlobSidecar() : S.Schema}, +rep: LV.rep_BlobSidecar(o, s)) -> RR.roots(LV.v_BlobSidecar(o), s, [D.bytes(Pair.snd(FuluBlobSidecar_d.BlobSidecar, D.Digest, Pair.snd(B.Buf, FuluBlobSidecar_d.BlobSidecar & D.Digest, FuluBlobSidecar_h.BlobSidecar_hash_tree_root(h, o))))]):
  PRV.BlobSidecar_root_correct(h, o, s, es, rep)

def Cell__root__Cell_root_correct(-h: B.Buf, -o: O.Words, +s: S.Schema, +es: {s == Spec.Cell() : S.Schema}, +rep: WO_L.rep_bv(o, s)) -> RR.roots(S.BytesValue{WO_L.wview(o)}, s, [D.bytes(Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, FuluCell_h.Cell_hash_tree_root(h, o))))]):
  PRV.Cell_root_correct(h, o, s, es, rep)

def ContributionAndProof__root__ContributionAndProof_root_correct(-h: B.Buf, -o: FuluContributionAndProof_d.ContributionAndProof, +s: S.Schema, +es: {s == Spec.ContributionAndProof() : S.Schema}, +rep: LV.rep_ContributionAndProof(o, s)) -> RR.roots(LV.v_ContributionAndProof(o), s, [D.bytes(Pair.snd(FuluContributionAndProof_d.ContributionAndProof, D.Digest, Pair.snd(B.Buf, FuluContributionAndProof_d.ContributionAndProof & D.Digest, FuluContributionAndProof_h.ContributionAndProof_hash_tree_root(h, o))))]):
  PRV.ContributionAndProof_root_correct(h, o, s, es, rep)

def DataColumnSidecar__root__DataColumnSidecar_root_correct(-h: B.Buf, -o: FuluDataColumnSidecar_d.DataColumnSidecar, +s: S.Schema, +es: {s == Spec.DataColumnSidecar() : S.Schema}, +rep: LV.rep_DataColumnSidecar(o, s)) -> RR.roots(LV.v_DataColumnSidecar(o), s, [D.bytes(Pair.snd(FuluDataColumnSidecar_d.DataColumnSidecar, D.Digest, Pair.snd(B.Buf, FuluDataColumnSidecar_d.DataColumnSidecar & D.Digest, FuluDataColumnSidecar_h.DataColumnSidecar_hash_tree_root(h, o))))]):
  PRV.DataColumnSidecar_root_correct(h, o, s, es, rep)

def DataColumnsByRootIdentifier__root__DataColumnsByRootIdentifier_root_correct(-h: B.Buf, -o: FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, +s: S.Schema, +es: {s == Spec.DataColumnsByRootIdentifier() : S.Schema}, +rep: LV.rep_DataColumnsByRootIdentifier(o, s)) -> RR.roots(LV.v_DataColumnsByRootIdentifier(o), s, [D.bytes(Pair.snd(FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier, D.Digest, Pair.snd(B.Buf, FuluDataColumnsByRootIdentifier_d.DataColumnsByRootIdentifier & D.Digest, FuluDataColumnsByRootIdentifier_h.DataColumnsByRootIdentifier_hash_tree_root(h, o))))]):
  PRV.DataColumnsByRootIdentifier_root_correct(h, o, s, es, rep)

def Deposit__root__Deposit_root_correct(-h: B.Buf, -o: FuluDeposit_d.Deposit, +s: S.Schema, +es: {s == Spec.Deposit() : S.Schema}, +rep: LV.rep_Deposit(o, s)) -> RR.roots(LV.v_Deposit(o), s, [D.bytes(Pair.snd(FuluDeposit_d.Deposit, D.Digest, Pair.snd(B.Buf, FuluDeposit_d.Deposit & D.Digest, FuluDeposit_h.Deposit_hash_tree_root(h, o))))]):
  PRV.Deposit_root_correct(h, o, s, es, rep)

def ExecutionPayloadHeader__root__ExecutionPayloadHeader_root_correct(-h: B.Buf, -o: FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, +s: S.Schema, +es: {s == Spec.ExecutionPayloadHeader() : S.Schema}, +rep: LV.rep_ExecutionPayloadHeader(o, s)) -> RR.roots(LV.v_ExecutionPayloadHeader(o), s, [D.bytes(Pair.snd(FuluExecutionPayloadHeader_d.ExecutionPayloadHeader, D.Digest, Pair.snd(B.Buf, FuluExecutionPayloadHeader_d.ExecutionPayloadHeader & D.Digest, FuluExecutionPayloadHeader_h.ExecutionPayloadHeader_hash_tree_root(h, o))))]):
  PRV.ExecutionPayloadHeader_root_correct(h, o, s, es, rep)

def ExecutionRequests__root__ExecutionRequests_root_correct(-h: B.Buf, -o: FuluExecutionRequests_d.ExecutionRequests, +s: S.Schema, +es: {s == Spec.ExecutionRequests() : S.Schema}, +rep: LV.rep_ExecutionRequests(o, s)) -> RR.roots(LV.v_ExecutionRequests(o), s, [D.bytes(Pair.snd(FuluExecutionRequests_d.ExecutionRequests, D.Digest, Pair.snd(B.Buf, FuluExecutionRequests_d.ExecutionRequests & D.Digest, FuluExecutionRequests_h.ExecutionRequests_hash_tree_root(h, o))))]):
  PRV.ExecutionRequests_root_correct(h, o, s, es, rep)

def HistoricalBatch__root__HistoricalBatch_root_correct(-h: B.Buf, -o: FuluHistoricalBatch_d.HistoricalBatch, +s: S.Schema, +es: {s == Spec.HistoricalBatch() : S.Schema}, +rep: LV.rep_HistoricalBatch(o, s)) -> RR.roots(LV.v_HistoricalBatch(o), s, [D.bytes(Pair.snd(FuluHistoricalBatch_d.HistoricalBatch, D.Digest, Pair.snd(B.Buf, FuluHistoricalBatch_d.HistoricalBatch & D.Digest, FuluHistoricalBatch_h.HistoricalBatch_hash_tree_root(h, o))))]):
  PRV.HistoricalBatch_root_correct(h, o, s, es, rep)

def IndexedAttestation__root__IndexedAttestation_root_correct(-h: B.Buf, -o: FuluIndexedAttestation_d.IndexedAttestation, +s: S.Schema, +es: {s == Spec.IndexedAttestation() : S.Schema}, +rep: LV.rep_IndexedAttestation(o, s)) -> RR.roots(LV.v_IndexedAttestation(o), s, [D.bytes(Pair.snd(FuluIndexedAttestation_d.IndexedAttestation, D.Digest, Pair.snd(B.Buf, FuluIndexedAttestation_d.IndexedAttestation & D.Digest, FuluIndexedAttestation_h.IndexedAttestation_hash_tree_root(h, o))))]):
  PRV.IndexedAttestation_root_correct(h, o, s, es, rep)

def LightClientBootstrap__root__LightClientBootstrap_root_correct(-h: B.Buf, -o: FuluLightClientBootstrap_d.LightClientBootstrap, +s: S.Schema, +es: {s == Spec.LightClientBootstrap() : S.Schema}, +rep: LV.rep_LightClientBootstrap(o, s)) -> RR.roots(LV.v_LightClientBootstrap(o), s, [D.bytes(Pair.snd(FuluLightClientBootstrap_d.LightClientBootstrap, D.Digest, Pair.snd(B.Buf, FuluLightClientBootstrap_d.LightClientBootstrap & D.Digest, FuluLightClientBootstrap_h.LightClientBootstrap_hash_tree_root(h, o))))]):
  PRV.LightClientBootstrap_root_correct(h, o, s, es, rep)

def LightClientFinalityUpdate__root__LightClientFinalityUpdate_root_correct(-h: B.Buf, -o: FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, +s: S.Schema, +es: {s == Spec.LightClientFinalityUpdate() : S.Schema}, +rep: LV.rep_LightClientFinalityUpdate(o, s)) -> RR.roots(LV.v_LightClientFinalityUpdate(o), s, [D.bytes(Pair.snd(FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate, D.Digest, Pair.snd(B.Buf, FuluLightClientFinalityUpdate_d.LightClientFinalityUpdate & D.Digest, FuluLightClientFinalityUpdate_h.LightClientFinalityUpdate_hash_tree_root(h, o))))]):
  PRV.LightClientFinalityUpdate_root_correct(h, o, s, es, rep)

def LightClientHeader__root__LightClientHeader_root_correct(-h: B.Buf, -o: FuluLightClientHeader_d.LightClientHeader, +s: S.Schema, +es: {s == Spec.LightClientHeader() : S.Schema}, +rep: LV.rep_LightClientHeader(o, s)) -> RR.roots(LV.v_LightClientHeader(o), s, [D.bytes(Pair.snd(FuluLightClientHeader_d.LightClientHeader, D.Digest, Pair.snd(B.Buf, FuluLightClientHeader_d.LightClientHeader & D.Digest, FuluLightClientHeader_h.LightClientHeader_hash_tree_root(h, o))))]):
  PRV.LightClientHeader_root_correct(h, o, s, es, rep)

def LightClientOptimisticUpdate__root__LightClientOptimisticUpdate_root_correct(-h: B.Buf, -o: FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate, +s: S.Schema, +es: {s == Spec.LightClientOptimisticUpdate() : S.Schema}, +rep: LV.rep_LightClientOptimisticUpdate(o, s)) -> RR.roots(LV.v_LightClientOptimisticUpdate(o), s, [D.bytes(Pair.snd(FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate, D.Digest, Pair.snd(B.Buf, FuluLightClientOptimisticUpdate_d.LightClientOptimisticUpdate & D.Digest, FuluLightClientOptimisticUpdate_h.LightClientOptimisticUpdate_hash_tree_root(h, o))))]):
  PRV.LightClientOptimisticUpdate_root_correct(h, o, s, es, rep)

def LightClientUpdate__root__LightClientUpdate_root_correct(-h: B.Buf, -o: FuluLightClientUpdate_d.LightClientUpdate, +s: S.Schema, +es: {s == Spec.LightClientUpdate() : S.Schema}, +rep: LV.rep_LightClientUpdate(o, s)) -> RR.roots(LV.v_LightClientUpdate(o), s, [D.bytes(Pair.snd(FuluLightClientUpdate_d.LightClientUpdate, D.Digest, Pair.snd(B.Buf, FuluLightClientUpdate_d.LightClientUpdate & D.Digest, FuluLightClientUpdate_h.LightClientUpdate_hash_tree_root(h, o))))]):
  PRV.LightClientUpdate_root_correct(h, o, s, es, rep)

def MatrixEntry__root__MatrixEntry_root_correct(-h: B.Buf, -o: FuluMatrixEntry_d.MatrixEntry, +s: S.Schema, +es: {s == Spec.MatrixEntry() : S.Schema}, +rep: LV.rep_MatrixEntry(o, s)) -> RR.roots(LV.v_MatrixEntry(o), s, [D.bytes(Pair.snd(FuluMatrixEntry_d.MatrixEntry, D.Digest, Pair.snd(B.Buf, FuluMatrixEntry_d.MatrixEntry & D.Digest, FuluMatrixEntry_h.MatrixEntry_hash_tree_root(h, o))))]):
  PRV.MatrixEntry_root_correct(h, o, s, es, rep)

def PendingAttestation__root__PendingAttestation_root_correct(-h: B.Buf, -o: FuluPendingAttestation_d.PendingAttestation, +s: S.Schema, +es: {s == Spec.PendingAttestation() : S.Schema}, +rep: LV.rep_PendingAttestation(o, s)) -> RR.roots(LV.v_PendingAttestation(o), s, [D.bytes(Pair.snd(FuluPendingAttestation_d.PendingAttestation, D.Digest, Pair.snd(B.Buf, FuluPendingAttestation_d.PendingAttestation & D.Digest, FuluPendingAttestation_h.PendingAttestation_hash_tree_root(h, o))))]):
  PRV.PendingAttestation_root_correct(h, o, s, es, rep)

def ProposerSlashing__root__ProposerSlashing_root_correct(-h: B.Buf, -o: FuluProposerSlashing_d.ProposerSlashing, +s: S.Schema, +es: {s == Spec.ProposerSlashing() : S.Schema}, +rep: LV.rep_ProposerSlashing(o, s)) -> RR.roots(LV.v_ProposerSlashing(o), s, [D.bytes(Pair.snd(FuluProposerSlashing_d.ProposerSlashing, D.Digest, Pair.snd(B.Buf, FuluProposerSlashing_d.ProposerSlashing & D.Digest, FuluProposerSlashing_h.ProposerSlashing_hash_tree_root(h, o))))]):
  PRV.ProposerSlashing_root_correct(h, o, s, es, rep)

def SignedAggregateAndProof__root__SignedAggregateAndProof_root_correct(-h: B.Buf, -o: FuluSignedAggregateAndProof_d.SignedAggregateAndProof, +s: S.Schema, +es: {s == Spec.SignedAggregateAndProof() : S.Schema}, +rep: LV.rep_SignedAggregateAndProof(o, s)) -> RR.roots(LV.v_SignedAggregateAndProof(o), s, [D.bytes(Pair.snd(FuluSignedAggregateAndProof_d.SignedAggregateAndProof, D.Digest, Pair.snd(B.Buf, FuluSignedAggregateAndProof_d.SignedAggregateAndProof & D.Digest, FuluSignedAggregateAndProof_h.SignedAggregateAndProof_hash_tree_root(h, o))))]):
  PRV.SignedAggregateAndProof_root_correct(h, o, s, es, rep)

def SignedContributionAndProof__root__SignedContributionAndProof_root_correct(-h: B.Buf, -o: FuluSignedContributionAndProof_d.SignedContributionAndProof, +s: S.Schema, +es: {s == Spec.SignedContributionAndProof() : S.Schema}, +rep: LV.rep_SignedContributionAndProof(o, s)) -> RR.roots(LV.v_SignedContributionAndProof(o), s, [D.bytes(Pair.snd(FuluSignedContributionAndProof_d.SignedContributionAndProof, D.Digest, Pair.snd(B.Buf, FuluSignedContributionAndProof_d.SignedContributionAndProof & D.Digest, FuluSignedContributionAndProof_h.SignedContributionAndProof_hash_tree_root(h, o))))]):
  PRV.SignedContributionAndProof_root_correct(h, o, s, es, rep)

def SyncCommittee__root__SyncCommittee_root_correct(-h: B.Buf, -o: FuluSyncCommittee_d.SyncCommittee, +s: S.Schema, +es: {s == Spec.SyncCommittee() : S.Schema}, +rep: LV.rep_SyncCommittee(o, s)) -> RR.roots(LV.v_SyncCommittee(o), s, [D.bytes(Pair.snd(FuluSyncCommittee_d.SyncCommittee, D.Digest, Pair.snd(B.Buf, FuluSyncCommittee_d.SyncCommittee & D.Digest, FuluSyncCommittee_h.SyncCommittee_hash_tree_root(h, o))))]):
  PRV.SyncCommittee_root_correct(h, o, s, es, rep)

