# Statement diff of the round-8 fixes (agent/r8-fixes)

Two changes: generated laws that close the eight critical survivors of the manual spec-mutation audit, round 8
(docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md, "Round 8 fixes"), and the removal of the definitions in `src/` that have no caller
(Giulio's request after the round-8 report).

## Lock and statements

* `frozen.lock.json` does **not** change. `tools/verify_frozen.py` passes without `--update` on the regenerated tree
  ("36 planted changes ok; 42 files, 4 statement roots, 1915 statement_defs files match"), and `--update` rewrites the lock byte for byte
  (sha256 `13bda5ff0ff5be4ca79a5df0e7f5b0dfee01366a9db6133d1b5ce8563ed7832d`). The `statement_defs` entries of `src/obj.bend` and
  `src/merkle_fast.bend` hash only the definitions an end-to-end statement reaches; none of the removed definitions is one of them.
* `e2e/STATEMENTS.txt` is unchanged (`git diff` empty), and so are END_TO_END.bend, ROOT_DOMAIN.bend, PROOF.bend, HASH_PROOF.bend,
  `spec/`, `schemas/` and `memory_bench/law-statements.json`.
* No frozen statement references a removed definition. `e2e/STATEMENTS.txt` names `M.shr_by` (kept) and nothing else of
  `src/merkle_fast.bend`.

## Removed definitions (168)

How they were found: every top-level `def` / `type` of `src/*.bend`, reachability from every reference outside `src/`
(types/, proofs/, e2e/, spec/, the root `.bend` files through their import aliases; codegen/, tools/, benchmarks/, tests/ through
`<alias>.<name>` for an alias some module binds to that `src/` file) and through the call graph inside `src/`, to a fixpoint; then
`git grep` of each name, qualified and bare, over the whole tree (docs/ and the mutation-testing records excluded).

| file | removed |
|---|---|
| `src/merkle_fast.bend` | 73 of 82: the streaming merkleizer (`merkleize_bytes`, `merkleize_at`, `merkleize_in`, `merkleize_kind`, `merkleize_pick`, `merkleize_tree`, `merkleize_prog`, `merkleize_prog_at`, `merkleize_prog_pick`), its chunk readers (`byte_mask`, `clip_partial`, `clip_pick`, `clip_word`, `mask_sel`, `mask_pick`, `apply_mask`, `fix`, `g0`..`g7`, `w0`..`w7`, `chunk_pick`, `masked_in`, `chunk_go`, `chunk_at`), the level stack (`push`, `push_leaf`, `leaves`, `climb`, `slot_pick`, `ascend`, `depth_go`, `depth_of`, `close_pick`, `full_in`, `close`), the progressive segments (`prog_depth`, `is_prog`, `prog_cap`, `prog_start`, `pick_u32`, `umin`, `prog_k`, `seg_of`, `copy_slot`, `seal_if`, `push_prog_at`, `push_prog`, `fold_prog`, `fold_from`, `seal_last`, `close_prog_at`, `close_prog_pick`, `close_prog`, `push_any_pick`, `push_any`, `close_any_pick`, `close_any`, `prog_segments`) and `bit_in`, `bit`. Kept: `shr_step`, `shr_by`, `shl_step`, `shl_by`, `fill_zeros`, `ready_pick`, `first_word`, `ready_seen`, `ready` (the object API uses `M.ready`, `M.shl_by`, `M.shr_by`) |
| `src/obj.bend` | `elems_root_prog`, `erp_size` (a progressive list of byte vectors: no schema name has one; `codegen/impl/typed_object_runtime.py` now stops if one appears), `words_read`, `bits_words` |
| `src/buffer.bend` | `be_word_at`, `capacity_small`, `of_list`, `scratch_words`, `swap_pair`, `to_list`, `to_list_at`, `to_list_go` |
| `src/decode.bend` | `decode_packed` |
| `src/packed.bend` | `chunks_of`, `packing_slice`, `read_tail` |
| `src/primitives.bend` | `make_uint`, `width8`, `width16`, `width32`, `width64`, `width128`, `width256` |
| `src/root.bend` | `append` |
| `src/sha256.bend` | `get_or_zero`, `at` |
| `src/walk.bend` | `run_skip`, `run_copy`, `skip_short`, `copy_short`, `skip_blocks`, `skip`, `copy_blocks`, `copy_super`, `copy`, `Scan`, `Measure`, `run_scan`, `scan_all`, `measure`, `offset`, `width32`, `word` (only `limb` is left) |
| `src/model.bend` | the schema and value constructors `boolean_type`, `unsigned_type`, `byte_vector_type`, `byte_list_type`, `bit_vector_type`, `bit_list_type`, `vector_type`, `list_type`, `container_type`, `union_type`, `null_type`, `progressive_list_type`, `progressive_bits_type`, `progressive_container_type`, `compatible_union_type`, `chain`, `end`, `boolean_value`, `unsigned_value`, `bytes_value`, `bits_value`, `sequence_value`, `items`, `empty_items`, `selected_value`, `null_value` |
| `src/ssz.bend` | the same 26 re-exports |

No proof or law was about a removed definition only, so no generator lost output. The round-8 equivalent mutants on the removed code
(`r8-a05-prog-cnt/03`, `r8-b02-merkle-fast/01..04`) no longer apply (`patch -p1`: "1 out of 1 hunk FAILED").

## Kept although only proofs reach them

26 definitions are reached only from the hand-written proof modules (`proofs/*.bend`, in PROOF.bend's import closure), which state
facts about them: `buffer.bend` `drop`, `fold`; `bytes.bend` `chunk_checked`, `chunk_scope`, `chunk_valid`, `pack_chunk`;
`codec.bend` `join`; `cvalue.bend` `items_fwd`; `decode.bend` `value_result`; `layout.bend` `decode`, `decode_gate`, `header_length`,
`headers`, `next_offset`, `read_header`, `resolve`, `resolve_gate`, `resolved_part`, `slices_done`; `mixing.bend` `mix_in_length`;
`packed.bend` `pack_spec`, `pack_spec_go`, `pack_step`, `packing_chunks`, `packing_domain`, `packing_length`. Those modules are not
generated and are part of the frozen proof roots, so they stay (with the definitions they are about).
