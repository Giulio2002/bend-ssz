# codegen/

The generators: Python programs that write every generated file of the repository (the typed object API, the laws and
facades, the end-to-end bridges, the witnesses, the composed theorems, `e2e/STATEMENTS.txt`, the figures in the docs).
Their inputs are `codegen/fulu.yaml`, the frozen generic schema descriptions and the frozen specification.

    python3 codegen/regenerate_all.py --check -j 12     # every generator's --check (server only)
    python3 codegen/regenerate_all.py                   # write mode, repeated until nothing changes
    python3 codegen/regenerate_all.py --only a,b        # just these (names without .py)
    python3 codegen/regenerate_all.py --touched         # only the generators whose inputs changed (regenerate_touched.py)
    python3 codegen/regenerate_all.py --list [--paths]  # the run order
    python3 -m unittest discover codegen/tests -t .   # the unit tests (light; also fine on a laptop)
    tools/test_codegen.sh                          # tests + ruff + regenerate_all --check

Never run a generator, `--check` or `regenerate_all` on a laptop: they read the whole tree.

## Layout

| Directory | Purpose |
|---|---|
| `generator_registry.py` | the list of generators: name, directory, stage (`first`/`mid`/`last`), dependencies (`after`), heaviness, pool |
| `regenerate_all.py`, `regenerate_touched.py`, `regen_trace/` | the driver: order, parallelism, `--check`, the `--touched` dev loop |
| `core/` | shared libraries every generator may import: `paths` (the repo roots), `writer` (the `GENERATED` header and the one `--check`/write protocol), `bendtext` (small Bend-text builders), `schema`, `generic`, `names`, `oracle`, `retired` |
| `impl/` | the implementation: `generate` (the typed object API, `types/*_generated.bend`), `runtime_file_split` (the runtime split), `reproducible_tool_scripts` (reruns `tools/generate_*.py`), `fulu_schema_inventory_check` |
| `proofs/laws/` | spec-connected codec laws and root laws of the fixed-size and generic names (`spec_connected_codec_laws`, `sub_word_codec_laws`, `hash_tree_root_laws*`, `root_view_validity_laws`, `sha256_node_laws`, `packed_vector_root_laws`, `length_only_reject_laws*`, ...) |
| `proofs/var/` | codec laws, byte-offset windows and encoder windows of the variable-size names (`var_*`, `encx_*`, `vedge`) |
| `proofs/collections/` | collection, setter, view and mutation laws (`collection_api_laws`, `laws`, `setter_keeps_representation_laws`, `packed_list_set_view`, `setter_bridge_compositions`) and the validating serializer (`validating_serializer_bridges`) |
| `proofs/slop/` | the laws that close mutation-testing survivors (`validity_checks`, `buffer_capacity`, `decoder_offsets`, `encoder_constants`, `spec_constants`, ...; layout in `docs/mutation_testing/SLOP_LAYOUT.md`) || `proofs/facades/` | the per-name facades and the coverage gates (`object_api_facade_proofs`, `object_api_coverage_gate`) |
| `proofs/bridges/` | the end-to-end bridges to END_TO_END's model (`object_api_model_bridges` and the shares it imports: `block_and_light_client_bridges`, `test_struct_and_union_bridges`, `fixed_size_name_bridges`, ...) |
| `proofs/witnesses/` | non-vacuity witnesses of the bridges and of the collection statements (`bridge_premise_witnesses`, `collection_premise_witnesses`) |
| `proofs/composed/` | the composed object-level theorems and their decoded-object premise providers (`decode_then_encode_theorems`, `fixed_size_composed_theorems`, `decoded_object_premises`) |
| `proofs/decoded/` | the decoded-object library generators (`decoded_byte_storage_facts` = `e2e_dz`, `beacon_state_decoded_facts` = `e2e_dbs`, `boxed_record_list_decoded_facts`, `fixed_word_field_decoded_premises`, `bit_list_decoded_facts`, ...) |
| `proofs/support/` | text libraries several proof generators share (`deep`, `okw`, `light_definition_modules`, `bitfix`, `bitsim`, `large_limit_size_facts`, `zeros_without_case_split`) |
| `docs/` | `statements` (`e2e/STATEMENTS.txt`), `documentation_figures` (the figures in README and docs), `import_graph` |
| `templates/` | the `.bend.in` files some generators copy or fill in |
| `tests/` | unit tests: registry validity, writer, header form, imports, text helpers, names |
| `MOVES.tsv` | where every generator and template lived before this layout (old path, new path); `tools/remap_codegen_paths.py` rewrites references |

A generator's module name is its file stem and is unique across `codegen/`: headers, `--only` and the regen stamps name
generators by it, never by the directory.

## Conventions

* **A generator** is a script with a `main()` that builds `out`, a dict `{Path: text}`, and ends with
  `if '--check' in sys.argv: return writer.check(out, 'stale ...: ', 'current')` followed by `writer.write(out, orphans=...)`.
  It is registered in `generator_registry.py` (the test fails otherwise).
* **Running.** `python3 codegen/<dir>/<name>.py [--check]`: the file starts with a three-line preamble that puts the repository
  root on `sys.path`. Everything imports by package: `from codegen.proofs.var import single_list_container_codec_laws as VL`.
* **The header.** Every generated `.bend` file carries `# GENERATED by <generator> (codegen). Do not edit.`, optionally
  `(codegen: <detail>)`; built by `writer.header()`, never by a path, so it does not change when files move.
* **The file name.** Every generated `.bend` file carries `_generated` in its name (`types/FuluBytes1_encode_ssz_generated.bend`, `proofs/obj/arr_copy_generated.bend`).
  A generator names its files by its own stem (`proofs/obj/arr_copy_generated.bend`); `core/generated_names.py` is the one place that adds the suffix: a generator
  process (a script under `codegen/`) sees the files of `core/generated_names.txt` under their stem names, and what it writes (the files, the
  `import` lines and the repo-relative paths in the text) gets the suffix. A NEW generator names its files with the suffix itself
  (`test_generated_names` fails for a generated `.bend` file without it). Tools, tests and the checker see the real names; `tools/verify_frozen.py` reads through the same view.
  `writer.owner(text)` reads the generator back (orphan scans skip files another generator owns).
* **Paths** come from `core/repository_paths.py` (`ROOT`, `OBJ`, `E2E`, `TYPES`, `TEMPLATES`), not from `__file__` arithmetic.
* **Shared state** between providers and the composer is an explicit object (`composed/decoded_object_premises.py: BUF`, a `BufferFacts`),
  not loose module globals.
* **Lint.** `ruff check codegen` (config: `ruff.toml` at the root) must stay clean.
* **Dead code** is deleted, not commented out: a function nothing references is removed (the byte-identical regeneration
  is the proof it was unused).
