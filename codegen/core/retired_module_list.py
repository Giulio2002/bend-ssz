"""Generated modules that are no longer written: nothing imports them, so their laws fed no result.

The generators below still compute some of these texts (another module's text is built from
theirs, or they share a template with a live module) but drop them before writing and checking,
through drop(). The committed files were deleted with this list (audit round 5, item 9: modules
imported by nothing). A module listed here can come back only by taking it off the list, and then
something should import it.

The kept modules that nothing imports (umbrella roots on purpose) are listed, with the reason, in
docs/LAYOUT.md ("Modules nothing imports").
"""
from pathlib import Path

from codegen.core.repository_paths import ROOT  # noqa: E402

RETIRED = {
    # codegen/proofs/bridges/object_api_model_bridges.py (entries of codegen/proofs/bridges/test_struct_and_union_bridges.py): the non-D forms of the encode records;
    # every bridge and composed theorem uses the D twins e2e_encq2d, e2e_encvd, e2e_encld
    'e2e/e2e_encq2.bend': 'the non-D form of e2e_encq2d',
    'e2e/e2e_encv.bend': 'the non-D form of e2e_encvd',
    'e2e/e2e_encl.bend': 'the non-D form of e2e_encld (its only importers were e2e_encq2 and e2e_encv)',
    # codegen/proofs/bridges/object_api_model_bridges.py (entries of codegen/proofs/bridges/block_and_light_client_bridges.py): window views the decode bridges do not use
    # (they go through the deep twins e2e_vbxY_*, or another route for LightClientUpdate)
    'e2e/e2e_vbx_BeaconBlock.bend': 'superseded by e2e_vbxY_BeaconBlock',
    'e2e/e2e_vbx_BeaconBlockBody.bend': 'superseded by e2e_vbxY_BeaconBlockBody',
    'e2e/e2e_vbx_SignedBeaconBlock.bend': 'superseded by e2e_vbxY_SignedBeaconBlock',
    'e2e/e2e_vbx_LightClientUpdate.bend': 'no decode bridge reads LightClientUpdate through it',
    # codegen/proofs/var/container_encoder_windows.py / container_encoder_top_laws.py (codegen/proofs/support/encode_size_limit_twins.py okw_companion): OKW companions no caller imports
    'proofs/obj/encx_Attestation_iface_o.bend': 'OKW companion with no importer',
    'proofs/obj/encx_AttesterSlashing_iface_o.bend': 'OKW companion with no importer',
    'proofs/obj/encx_BitsStruct_iface_o.bend': 'OKW companion with no importer',
    'proofs/obj/encx_IndexedAttestation_iface_o.bend': 'OKW companion with no importer',
    'proofs/obj/encx_ProgressiveBitsStruct_iface_o.bend': 'OKW companion with no importer',
    'proofs/obj/encx_ProgressiveBitsStruct_size_o.bend': 'OKW companion with no importer',
    'proofs/obj/var_codec_BitsStruct_enc_o.bend': 'OKW companion with no importer',
    # codegen/proofs/var/deep_tree_list_children.py: D twins with no importer
    'proofs/obj/encx_l131072_u64_d.bend': 'D twin with no importer',
    'proofs/obj/encx_pl_bool_d.bend': 'D twin with no importer',
    'proofs/obj/encx_pl_u16_d.bend': 'D twin with no importer',
    # codegen/proofs/var/progressive_small_list_codec_laws.py: encoder windows whose only importers were the D twins above
    'proofs/obj/encx_pl_bool.bend': 'imported only by the retired encx_pl_bool_d',
    'proofs/obj/encx_pl_u16.bend': 'imported only by the retired encx_pl_u16_d',
    # codegen/proofs/var/nested_type_window_laws.py, codegen/proofs/var/container_list_offset_windows.py: byte-window interfaces no decode proof uses
    'proofs/obj/var_winx_DataColumnsByRootIdentifier.bend': 'byte window with no importer',
    'proofs/obj/var_winx_PendingAttestation.bend': 'byte window with no importer',
    'proofs/obj/var_winx_bits2048.bend': 'imported only by retired windows',
    'proofs/obj/var_winx_l128_u64.bend': 'imported only by retired windows',
    'proofs/obj/var_winx_l1_AttesterSlashing.bend': 'byte window with no importer',
    'proofs/obj/var_winx_l8_Attestation.bend': 'byte window with no importer',
    # codegen/proofs/var/word_vector_writer_laws.py: packed-word writers of Bitvector[1/2/8]
    'proofs/obj/vuwg_bv1.bend': 'writer with no importer',
    'proofs/obj/vuwg_bv2.bend': 'writer with no importer',
    'proofs/obj/vuwg_bv8.bend': 'writer with no importer',
}


def drop(out):
    """out ({path: text}) without the retired modules"""
    return {p: t for p, t in out.items() if str(Path(p).resolve().relative_to(ROOT)) not in RETIRED}
