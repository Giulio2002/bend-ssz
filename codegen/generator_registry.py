"""The registry of the generators: the one list regenerate_all.py, tools/strictcheck.sh and the tests read.

A generator is a script `codegen/<dir>/<name>.py` that writes generated files and accepts `--check` (exit 0 when
every file it owns is what it would write). Everything else under codegen/ is a library the generators import
(codegen/core/, the shared modules of codegen/proofs/support/ ...), or the driver (regenerate_all.py, regenerate_touched.py).
codegen/tests/test_registry.py keeps this list and the tree in step: every file that accepts --check is registered,
every entry exists, the dependencies are acyclic.

Run order (`ordered()`): the `first` stage (generate: the object API every law generator reads), then the `mid`
generators (independent of each other: they run in the pool, alphabetical here), then the `last` stage in dependency
order (`after`): a generator that reads another's output (the gates and facades index the laws, the bridges index the
facades, the witnesses and composed theorems read the bridges, the statements read those, the doc figures read the
statements). A `pool` names last-stage generators that do not read each other and may run together.
`heavy` ranks the slowest generators (measured; 0 first): the pool starts them first so its tail is short.
"""
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class Gen:
    name: str                      # the file stem; `--only name`, the stamp key of regenerate_touched
    dir: str                       # the directory below codegen/
    stage: str = 'mid'             # 'first' | 'mid' | 'last'
    after: tuple = ()              # names whose outputs this generator reads (last stage: run after them)
    heavy: int | None = None       # rank among the slowest generators, 0 first
    pool: str | None = None        # last-stage generators with the same pool may run in the pool together

    @property
    def path(self) -> Path:
        return ROOT / 'codegen' / self.dir / f'{self.name}.py'


GENERATORS = (
    # codegen/core/
    Gen('readable_type_names', 'core'),
    # codegen/impl/
    Gen('fulu_schema_inventory_check', 'impl'),
    Gen('typed_object_runtime', 'impl', stage='first'),
    Gen('runtime_file_split', 'impl'),
    Gen('reproducible_tool_scripts', 'impl'),
    # codegen/docs/
    Gen('documentation_figures', 'docs', stage='last', after=('end_to_end_statement_list',)),
    Gen('import_graph', 'docs'),
    Gen('end_to_end_statement_list', 'docs', stage='last', after=('bridge_premise_witnesses', 'decode_then_encode_theorems')),
    # codegen/proofs/laws/
    Gen('array_copy_and_emit_laws', 'proofs/laws'),
    Gen('bit_list_pack_laws', 'proofs/laws'),
    Gen('packed_byte_list_root_laws', 'proofs/laws'),
    Gen('cached_root_laws', 'proofs/laws'),
    Gen('length_only_reject_laws', 'proofs/laws'),
    Gen('byte_checked_reject_laws', 'proofs/laws'),
    Gen('padding_bits_reject_laws', 'proofs/laws'),
    Gen('decode_window_laws', 'proofs/laws'),
    Gen('reported_size_and_vector_bound', 'proofs/slop'),
    Gen('buffer_capacity', 'proofs/slop'),
    Gen('length_check_refusal', 'proofs/slop'),
    Gen('fixed_writer_guards', 'proofs/slop'),
    Gen('aligned_write_guard', 'proofs/slop'),
    Gen('symbolic_buffer_capacity', 'proofs/slop'),
    Gen('encoder_constants', 'proofs/slop'),
    Gen('write_start_and_sizes', 'proofs/slop'),
    Gen('spec_constants', 'proofs/slop'),
    Gen('spec_constants_extra', 'proofs/slop'),
    Gen('container_field_validity', 'proofs/slop'),
    Gen('packed_boolean_validity', 'proofs/slop'),
    Gen('bit_padding_validity', 'proofs/slop'),
    Gen('first_offset_check', 'proofs/slop'),
    Gen('collection_guards', 'proofs/slop'),
    Gen('word_unit_validity', 'proofs/slop'),
    Gen('cell_list_guards', 'proofs/slop'),
    Gen('tight_storage_root', 'proofs/slop'),
    Gen('cached_list_roots', 'proofs/slop'),
    Gen('small_type_predicates', 'proofs/slop'),
    Gen('decode_checked_laws', 'proofs/slop'),
    Gen('append_guard_bounds', 'proofs/slop'),
    Gen('writer_poison_laws', 'proofs/slop'),
    Gen('word_positions', 'proofs/slop'),
    Gen('decoder_offsets', 'proofs/slop'),
    Gen('validity_checks', 'proofs/slop'),
    Gen('poison_flag', 'proofs/slop'),
    Gen('crash_fix_laws', 'proofs/slop'),
    Gen('packed_vector_root_laws', 'proofs/laws'),
    Gen('progressive_list_root_laws', 'proofs/laws'),
    Gen('hash_tree_root_laws', 'proofs/laws'),
    Gen('container_root_laws', 'proofs/laws', heavy=5),
    Gen('generic_form_root_laws', 'proofs/laws'),
    Gen('schema_shape_laws', 'proofs/laws'),
    Gen('sha256_node_laws', 'proofs/laws'),
    Gen('spec_connected_codec_laws', 'proofs/laws', heavy=4),
    Gen('sub_word_codec_laws', 'proofs/laws'),
    Gen('root_view_validity_laws', 'proofs/laws', heavy=7),
    # codegen/proofs/var/
    Gen('encoder_window_children', 'proofs/var'),
    Gen('deep_tree_list_children', 'proofs/var'),
    Gen('aggregate_and_proof_encoder_laws', 'proofs/var'),
    Gen('bit_list_container_codec_laws', 'proofs/var'),
    Gen('bit_list_codec_laws', 'proofs/var'),
    Gen('bit_list_encoder_laws', 'proofs/var'),
    Gen('bit_list_encoder_window', 'proofs/var'),
    Gen('byte_list_codec_laws', 'proofs/var'),
    Gen('byte_list_offset_windows', 'proofs/var'),
    Gen('container_encoder_windows', 'proofs/var', heavy=0),
    Gen('container_encoder_top_laws', 'proofs/var'),
    Gen('beacon_state_fixed_field_readers', 'proofs/var'),
    Gen('single_list_container_codec_laws', 'proofs/var'),
    Gen('multi_variable_field_codec_laws', 'proofs/var'),
    Gen('progressive_bit_list_codec_laws', 'proofs/var'),
    Gen('progressive_word_list_codec_laws', 'proofs/var'),
    Gen('progressive_small_list_codec_laws', 'proofs/var'),
    Gen('fixed_record_encoder_windows', 'proofs/var'),
    Gen('record_list_offset_windows', 'proofs/var'),
    Gen('sub_word_record_list_windows', 'proofs/var'),
    Gen('whole_buffer_decoder_laws', 'proofs/var'),
    Gen('unaligned_read_laws', 'proofs/var'),
    Gen('unaligned_write_laws', 'proofs/var'),
    Gen('sub_word_leaf_writer_laws', 'proofs/var'),
    Gen('word_vector_writer_laws', 'proofs/var'),
    Gen('variable_element_list_windows', 'proofs/var'),
    Gen('variable_element_list_encoders', 'proofs/var'),
    Gen('nested_type_window_laws', 'proofs/var'),
    Gen('block_body_offset_windows', 'proofs/var', heavy=1),
    Gen('light_client_update_window', 'proofs/var'),
    Gen('generic_bit_list_window', 'proofs/var'),
    Gen('container_list_offset_windows', 'proofs/var'),
    Gen('uint16_list_window', 'proofs/var'),
    Gen('compatible_union_window', 'proofs/var'),
    Gen('validator_list_window', 'proofs/var'),
    Gen('multi_variable_container_windows', 'proofs/var'),
    Gen('buffer_end_short_reads', 'proofs/var'),
    # codegen/proofs/collections/
    Gen('bit_list_set_view', 'proofs/collections'),
    Gen('uint64_list_zero_tail', 'proofs/collections'),
    Gen('record_list_encode_after_set', 'proofs/collections'),
    Gen('word_list_encode_after_set', 'proofs/collections'),
    Gen('merged_word_zero_tail', 'proofs/collections'),
    Gen('byte_list_encode_after_set', 'proofs/collections'),
    Gen('halfword_merge_bytes', 'proofs/collections'),
    Gen('halfword_list_encode_after_set', 'proofs/collections'),
    Gen('halfword_merge_read', 'proofs/collections'),
    Gen('uint16_list_runtime_set_laws', 'proofs/collections'),
    Gen('bit_list_zero_tails', 'proofs/collections'),
    Gen('bit_list_encode_after_set', 'proofs/collections'),
    Gen('uint16_from_two_bytes', 'proofs/collections'),
    Gen('boxed_list_set_view', 'proofs/collections'),
    Gen('collection_api_laws', 'proofs/collections'),
    Gen('setter_bridge_compositions', 'proofs/collections', stage='last', after=('object_api_model_bridges',)),
    Gen('object_field_access_laws', 'proofs/collections'),
    Gen('setter_keeps_representation_laws', 'proofs/collections'),
    Gen('validating_serializer_bridges', 'proofs/collections'),
    Gen('index_word_offset_split', 'proofs/collections'),
    Gen('packed_list_set_view', 'proofs/collections'),
    Gen('cell_list_set_view', 'proofs/collections'),
    # codegen/proofs/facades/
    Gen('object_api_facade_proofs', 'proofs/facades', stage='last', after=('object_api_coverage_gate',), heavy=6),
    Gen('object_api_coverage_gate', 'proofs/facades', stage='last', after=('typed_object_runtime',), heavy=3),
    # codegen/proofs/bridges/
    Gen('object_api_model_bridges', 'proofs/bridges', stage='last', after=('object_api_facade_proofs',), heavy=2),
    Gen('block_body_record_list_views', 'proofs/bridges'),
    # codegen/proofs/witnesses/
    Gen('decoder_acceptance_witnesses', 'proofs/witnesses'),
    Gen('output_bytes_length', 'proofs/witnesses'),
    Gen('zero_run_lemmas', 'proofs/witnesses'),
    Gen('symbolic_decoder_witnesses', 'proofs/witnesses', stage='last', after=('zero_run_lemmas',)),
    Gen('light_client_skeleton_witnesses', 'proofs/witnesses', stage='last', after=('symbolic_decoder_witnesses', 'decode_then_encode_theorems')),
    Gen('beacon_state_symbolic_witness', 'proofs/witnesses', stage='last', after=('symbolic_decoder_witnesses',)),
    Gen('collection_premise_witnesses', 'proofs/witnesses'),
    Gen('bridge_premise_witnesses', 'proofs/witnesses', stage='last', after=('setter_bridge_compositions',), pool='witness-compose'),
    # codegen/proofs/composed/
    Gen('decode_then_encode_theorems', 'proofs/composed', stage='last', after=('setter_bridge_compositions',), pool='witness-compose'),
    # codegen/proofs/decoded/
    Gen('blob_sidecar_decoded_premises', 'proofs/decoded'),
    Gen('unboxed_record_list_decoded_facts', 'proofs/decoded'),
    Gen('progressive_variable_list_decoded_facts', 'proofs/decoded'),
    Gen('nested_progressive_list_element_hooks', 'proofs/decoded'),
    Gen('variable_vector_decoded_facts', 'proofs/decoded'),
    Gen('variable_struct_list_element_hooks', 'proofs/decoded'),
    Gen('progressive_struct_list_element_hooks', 'proofs/decoded'),
    Gen('boxed_record_list_decoded_facts', 'proofs/decoded'),
    Gen('block_body_decoded_facts', 'proofs/decoded'),
    Gen('bit_list_decoded_facts', 'proofs/decoded'),
    Gen('block_decoded_facts', 'proofs/decoded'),
    Gen('beacon_state_decoded_facts', 'proofs/decoded'),
    Gen('execution_payload_decoded_facts', 'proofs/decoded'),
    Gen('fixed_word_field_decoded_premises', 'proofs/decoded'),
    Gen('decoded_byte_storage_facts', 'proofs/decoded'),
    Gen('progressive_list_length_facts', 'proofs/decoded'),
    Gen('record_list_window_decoded_facts', 'proofs/decoded'),
    Gen('record_list_byte_count_facts', 'proofs/decoded'),
    Gen('variable_record_list_decoded_facts', 'proofs/decoded'),
    # codegen/proofs/support/
    Gen('light_definition_modules', 'proofs/support'),
)

STAGES = ('first', 'mid', 'last')


def by_name() -> dict:
    """{name: Gen}; names are unique across the tree (they are the file stems and the --only keys)."""
    return {g.name: g for g in GENERATORS}


def ordered() -> list:
    """The generators in run order: first, mid (alphabetical), then the last stage topologically by `after`
    (ties in registry order). Raises ValueError on an unknown dependency or a cycle."""
    names = by_name()
    for g in GENERATORS:
        for a in g.after:
            if a not in names:
                raise ValueError(f'{g.name}: unknown dependency {a}')
    out = [g for g in GENERATORS if g.stage == 'first'] + sorted((g for g in GENERATORS if g.stage == 'mid'), key=lambda g: g.name)
    pending = [g for g in GENERATORS if g.stage == 'last']
    done = {g.name for g in out}
    while pending:
        ready = next((g for g in pending if all(a in done for a in g.after)), None)
        if ready is None:
            raise ValueError('dependency cycle among: ' + ', '.join(g.name for g in pending))
        out.append(ready)
        done.add(ready.name)
        pending.remove(ready)
    return out
