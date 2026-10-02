"""Text helpers shared by the bridge and composed-theorem generators (codegen/proofs/bridges, codegen/proofs/composed).

Everything here returns Bend source text; nothing reads or writes a file.
"""


def unpack_pairs(src, names, indent, tmp='s', start=1, closed=True):
    """The Bend lines that take a nested pair `src` apart into `names`, one binder per line.

    Each line binds a name and the rest of the pair (`tmp<start>`, `tmp<start + 1>`, ...); with `closed` the last
    line binds the last two names together, so `names` has one entry more than there are lines:

        (+T, s1) = s0
        (+dw, s2) = s1
        (+N, +q) = s2          <-  unpack_pairs("s0", ["T", "dw", "N", "q"], indent)
    """
    out, prev = [], src
    for i in range(len(names) - 2 if closed else len(names)):
        cur = f'{tmp}{start + i}'
        out.append(f'{indent}(+{names[i]}, {cur}) = {prev}')
        prev = cur
    if closed:
        out.append(f'{indent}(+{names[-2]}, +{names[-1]}) = {prev}')
    return '\n'.join(out)


# The module aliases the bridge generators' Bend files import, one line per (path, alias). Where one alias names different modules in
# different files (EB, EM, EL, ...), the alias is spelled <alias>=<file stem> in import_lines.
_MODULES = '''
../proofs/compact/arith.bend as A
../proofs/compact/arith.bend as A4
../proofs/obj/arr_copy.bend as AC
../proofs/obj/arr_emit.bend as AE
../proofs/obj/arr_shift.bend as AH
../proofs/obj/arr_enc.bend as AN
../src/model.bend as API
../proofs/obj/arr_spec.bend as AS
../proofs/obj/arr_vec.bend as AV
../src/buffer.bend as B
../proofs/compact/buf.bend as BF
../proofs/obj/bitlist_pack.bend as BK
./e2e_bitl.bend as BL
./e2e_blist.bend as BL
../proofs/obj/spec_arr_Blob.bend as BL
./e2e_bitl.bend as BLB
../proofs/obj/bits_leaf.bend as BLf
../proofs/obj/bitlist_obj.bend as BO
../proofs/obj/bitlist_obj_light.bend as BO
../proofs/obj/bitlist_rep.bend as BOr
./e2e_pbs.bend as BS
../proofs/compact/bits.bend as BT
./e2e_bview.bend as BV
./e2e_bvh.bend as BV
./e2e_bvw.bend as BVW
./e2e_bx.bend as BX
./e2e_bx.bend as BXW
../spec/primitives.bend as Bytes
./e2e_cap.bend as C
./e2e_comp.bend as C
../proofs/obj/cells.bend as CE
./e2e_chunks.bend as CH
../proofs/obj/var_winx_l1024_u16.bend as CH0
../proofs/obj/encx_ProgressiveBitsStruct_iface.bend as CI
../proofs/codec_inverse.bend as CI
../proofs/obj/vbitcore.bend as CO
./e2e_cap.bend as CQ4
../spec/codec.bend as Codec
../types/proglist_proglist_VarTestStruct_def_generated.bend as D
../types/proglist_ProgressiveVarTestStruct_def_generated.bend as D
../src/digest.bend as D
./e2e_db.bend as DB
./FuluBlobSidecar_e2e_dec_generated.bend as DB
./e2e_dbs_BlobSidecar.bend as DBS
./e2e_dfx.bend as DFX
../proofs/obj/dk.bend as DK
../proofs/obj/vbitdl.bend as DL
./e2e_dpt.bend as DPT
./e2e_dvp_pl_pl_VarTestStruct.bend as DVP
./e2e_dvp_pl_ProgressiveVarTestStruct.bend as DVP
./e2e_dz.bend as DZ
../spec/decoding_relation.bend as Decoding
../spec/value_domain.bend as Domain
./e2e_bytes.bend as E
./e2e_support.bend as E
./e2e_bits.bend as E2B
../END_TO_END.bend as E2E
./e2e_tree.bend as E3
./e2e_any.bend as E4
../proofs/obj/elems48.bend as E48
./e2e_bits.bend as EB
./FuluBlobSidecar_e2e_generated.bend as EB
./e2e_encld.bend as EL
../proofs/obj/var_elems.bend as EL
./e2e_emit.bend as EM
../proofs/obj/var_codec_DataColumnsByRootIdentifier_enc.bend as EN
../proofs/obj/var_codec_ProgressiveBitsStruct_enc.bend as EN
./e2e_encp.bend as EP
../proofs/obj/encx_l1048576_bl1073741824.bend as ET
./e2e_e48w.bend as EW
./e2e_e48w.bend as EW48
../proofs/obj/encx_l16_Withdrawal.bend as EWL
../proofs/obj/encx_l4096_b48.bend as EX
../proofs/obj/encx_pbits.bend as EXP
../proofs/obj/encx_bits1280.bend as EX_bits1280
../proofs/obj/encx_bits1281.bend as EX_bits1281
../proofs/obj/encx_bits256.bend as EX_bits256
../proofs/obj/encx_bits257.bend as EX_bits257
../proofs/obj/encx_pbits.bend as EX_pbits
./e2e_bytes.bend as EY
../spec/codec.bend as Encoding
../proofs/obj/spec_fixed.bend as F
../proofs/obj/vfx_bv257.bend as F57
../proofs/obj/vfx_v6_b32.bend as F6
../proofs/obj/vfx_v7_b32.bend as F7
../proofs/obj/vfx_bv1280.bend as F80
../proofs/obj/vfx_bv1281.bend as F81
../proofs/obj/spec_bits.bend as FB
../proofs/compact/found.bend as FD
../proofs/obj/vfx_SyncAggregate.bend as FSA
../proofs/obj/vfx_SyncCommittee.bend as FSC
../proofs/obj/spec_fixed.bend as FX
../proofs/obj/vfx_u16.bend as FX16
../proofs/obj/vfx_u8.bend as FX8
../types/FuluAttestationData_def_generated.bend as FuluAttestationData_d
../types/FuluAttestation_def_generated.bend as FuluAttestation_d
../types/FuluAttesterSlashing_def_generated.bend as FuluAttesterSlashing_d
../types/FuluBeaconBlockHeader_def_generated.bend as FuluBeaconBlockHeader_d
../types/FuluBlobSidecar_def_generated.bend as FuluBlobSidecar_d
../types/FuluBlobSidecar_encode_ssz_generated.bend as FuluBlobSidecar_e
../types/FuluBlobSidecar_hashtreeroot_generated.bend as FuluBlobSidecar_h
../types/FuluBlobSidecar_decode_ssz_generated.bend as FuluBlobSidecar_r
../types/FuluBytes32_def_generated.bend as FuluBytes32_d
../types/FuluBytes48_def_generated.bend as FuluBytes48_d
../types/FuluBytes96_def_generated.bend as FuluBytes96_d
../types/FuluDataColumnsByRootIdentifier_def_generated.bend as FuluDataColumnsByRootIdentifier_d
../types/FuluDataColumnsByRootIdentifier_encode_ssz_generated.bend as FuluDataColumnsByRootIdentifier_e
../types/FuluEth1Data_def_generated.bend as FuluEth1Data_d
../types/FuluIndexedAttestation_def_generated.bend as FuluIndexedAttestation_d
../types/FuluSignedBeaconBlockHeader_def_generated.bend as FuluSignedBeaconBlockHeader_d
../types/FuluSyncAggregate_def_generated.bend as FuluSyncAggregate_d
../types/FuluSyncCommittee_def_generated.bend as FuluSyncCommittee_d
../types/FuluWithdrawal_def_generated.bend as FuluWithdrawal_d
../types/Fulu_bitvector_512_def_generated.bend as Fulu_bitvector_512_d
../types/Fulu_bitvector_64_def_generated.bend as Fulu_bitvector_64_d
../proofs/obj/gleaf.bend as GL
./e2e_gpb.bend as GPB
../proofs/obj/generic_specs.bend as GS
../proofs/obj/gvalid_gtypes2.bend as GV
./e2e_gwin.bend as GW
./e2e_hvk.bend as HVK
../src/primitives.bend as I
../proofs/integer_decoding.bend as ID
../proofs/obj/var_winx_l4096_b48.bend as K
./e2e_load.bend as L
../types/Fulu_list_bytelist_1073741824_1048576_def_generated.bend as LD
../proofs/obj/list_obj.bend as LO
../types/Fulu_list_Withdrawal_16_def_generated.bend as LW
../proofs/obj/vua_lay.bend as LY
../spec/type_legality.bend as Legal
../src/merkle_fast.bend as M
../proofs/obj/spec_arr_SyncCommittee.bend as M
../proofs/obj/spec_arr_BlobSidecar.bend as M
../proofs/obj/spec_arr_HistoricalBatch.bend as M
../spec/primitives.bend as M0_WO_SP
../proofs/obj/mtree_run.bend as MR
../src/obj.bend as O
../proofs/nat_order.bend as Order
../types/primitive.bend as P
../src/primitives.bend as P4
../proofs/obj/packed_bytes.bend as PB
../proofs/obj/pb_min.bend as PB
../proofs/obj/packed_bytes.bend as PBF
../proofs/obj/pb_min.bend as PBM
../proofs/obj/var_winp_pbits.bend as PBW
../types/ProgressiveBitsStruct_def_generated.bend as PB_d
../types/ProgressiveBitsStruct_encode_ssz_generated.bend as PB_e
../types/ProgressiveBitsStruct_hashtreeroot_generated.bend as PB_h
../proofs/power_division.bend as PD
../proofs/obj/packed_obj_light.bend as PK
./e2e_plist.bend as PL
../proofs/obj/pv_obj.bend as PV
./e2e_plw.bend as PW
../proofs/obj/repr.bend as R
./FuluBlob_e2e_root_generated.bend as RB
../proofs/compact/reads.bend as RD
../proofs/obj/fixrej_SyncCommittee.bend as RJ
../proofs/obj/fixrej_BlobSidecar.bend as RJ
../proofs/obj/fixrej_HistoricalBatch.bend as RJ
../proofs/obj/fixrej_Blob.bend as RJ
./e2e_rl_ExecutionPayload.bend as RLV
../proofs/obj/root_names.bend as RN
../proofs/obj/root_gnames_light.bend as RN
../proofs/obj/root_gnames.bend as RN
../proofs/obj/root_names_light.bend as RN
../proofs/obj/root_types.bend as RT
../proofs/obj/root_gtypes2.bend as RT
../proofs/obj/root_gtypes.bend as RT
../proofs/obj/root_types_light.bend as RT
../spec/root_relation.bend as Roots
../types/schema.bend as S
../proofs/obj/spec_fixed.bend as SF
../proofs/obj/schema_shapes.bend as SH
../spec/primitives.bend as SP
../proofs/obj/sub_pack.bend as SP2
../spec/fulu_schemas.bend as Spec
../proofs/obj/generic_specs.bend as Spec
../types/fulu_obj.bend as T
../proofs/obj/vvl_l1048576_bl1073741824.bend as TX
./e2e_tz.bend as TZ
./e2e_ulist.bend as U
../proofs/obj/vua.bend as UA
../proofs/obj/vua_copy.bend as UC
../proofs/obj/vua_ct.bend as UCT
../proofs/obj/ulist_obj.bend as UL
../proofs/obj/ulist_obj_light.bend as UL
../proofs/u32_order.bend as UO
../proofs/obj/vua_rd.bend as UR
../proofs/obj/vua_win.bend as UW
../proofs/primitive_invariants.bend as V
../proofs/obj/vvl_v2_VarTestStruct.bend as V2
../proofs/obj/vbv257s.bend as V2S
../proofs/obj/vbv128s.bend as V2S8
../proofs/obj/vbv1281d.bend as V81
../proofs/obj/vbuf.bend as VB
../proofs/obj/vbig.bend as VBG
../proofs/obj/vbitl.bend as VBL
../proofs/obj/vbrt.bend as VBR
../proofs/obj/vbitrep.bend as VBR
../proofs/obj/vbspec.bend as VBS
../proofs/obj/vbitenc.bend as VBT
../proofs/obj/vbytes.bend as VBY
../proofs/obj/vcopy.bend as VC
../proofs/obj/vcont.bend as VCN
../proofs/obj/vdepth.bend as VD
../proofs/obj/vvle.bend as VE2
../proofs/obj/vfix.bend as VF
../proofs/obj/vfx_bv1.bend as VFB1
../proofs/obj/vlist.bend as VL
../proofs/obj/valid_lib.bend as VL
../proofs/obj/vlist.bend as VLS
../proofs/obj/vmul.bend as VM
../proofs/obj/vpb29.bend as VP
../proofs/obj/vbrt.bend as VR
../proofs/obj/vbitrep.bend as VR
../proofs/obj/vrejb.bend as VRB
../proofs/obj/vrejf.bend as VRF
../proofs/type_validator_soundness.bend as VS
../proofs/obj/vspec.bend as VS
../proofs/obj/vspec.bend as VSP
../proofs/obj/vu32.bend as VU
../proofs/obj/vvlu.bend as VVU
./e2e_vw512.bend as VW
../proofs/obj/vua_fixb.bend as VXB
../proofs/obj/vfxg.bend as VXG
../proofs/obj/vbyte.bend as VY
../proofs/obj/vbytes.bend as VY
../proofs/obj/vbytes.bend as VYS
../types/VarTestStruct_def_generated.bend as VarTestStruct_d
../proofs/obj/var_winx_ProgressiveTestStruct.bend as W
../proofs/obj/var_winx_ProgressiveComplexTestStruct.bend as W
../proofs/obj/var_winx_l4096_b48.bend as W
../proofs/obj/var_winx_bits131072.bend as W131
../proofs/obj/wany.bend as WA
../proofs/obj/var_winp_bool.bend as WB
../proofs/obj/wbits_obj_light.bend as WBV
../proofs/obj/wbits_obj.bend as WBV
../proofs/obj/vuwd.bend as WD
../proofs/word_facts.bend as WF
../proofs/obj/words_obj.bend as WO
../proofs/obj/words_obj_light.bend as WO
../proofs/obj/words_root.bend as WR
../proofs/obj/words_spec.bend as WS
../proofs/word_split.bend as WSp
../proofs/obj/var_winx_l131072_u64.bend as WU
./e2e_fixd.bend as X
./e2e_fixdw48.bend as X48
./e2e_fixdw.bend as XW
../proofs/obj/var_winx_Attestation.bend as YA
../proofs/obj/var_winx_IndexedAttestation.bend as YI
../proofs/obj/var_winx_AttesterSlashing.bend as YS
../proofs/obj/vvlb_bl1073741824.bend as YW
../proofs/obj/var_winx_VarTestStruct.bend as YW
../types/bitvector_256_def_generated.bend as bitvector_256_d
../types/bitvector_257_def_generated.bend as bitvector_257_d
../types/bitvector_257_encode_ssz_generated.bend as bitvector_257_e
../types/vec_VarTestStruct_2_def_generated.bend as vec_VarTestStruct_2_d
'''


def _module_keys():
    entries = [l for l in _MODULES.split('\n') if l]
    by_alias = {}
    for l in entries:
        by_alias.setdefault(l.rsplit(' as ', 1)[-1] if ' as ' in l else l, []).append(l)
    keys = {}
    for alias, ls in by_alias.items():
        for l in ls:
            stem = l.split(' ')[0].rsplit('/', 1)[-1][:-len('.bend')] if ' as ' in l else ''
            keys[alias if len(ls) == 1 else alias + '=' + stem] = 'import ' + l
    return keys


_KEYS = _module_keys()


def import_lines(spec):
    """The Bend import lines for the aliases in `spec` (space separated), in that order: `import_lines('Base O FD')`."""
    return '\n'.join(_KEYS[k] for k in spec.split())
