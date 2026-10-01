# Results

## Coverage

- 109 mainnet Fulu names (`codegen/fulu.yaml`, frozen in `schemas/fulu_mainnet.json`) and the
  `ssz_generic` forms: 136 supported schemas (15 official classes plus 121 structural forms such as `vec_uint16_4`,
  `bitlist_33`, `proglist_bool`) of the suite's 144; the other 8 (zero-length vectors and bit vectors) are not SSZ types
  and are refused. Five of the 136 are the fork's own `boolean` / `uint8` / `uint32` / `uint64` / `uint256`
  (`uint16` and `uint128` exist only in the suite), so there are 131 generic names beside the 109 Fulu ones. Readable
  names come from `codegen/core/names.py`.
- <!-- fig:names -->240<!-- /fig --> names have object-API facades (`proofs/api/`: <!-- fig:facade_files -->720<!-- /fig --> files), each
  with an encode, a decode and a hash_tree_root file. `proofs/gate/MISSING.txt`: <!-- fig:missing -->0<!-- /fig --> of
  <!-- fig:core_pairs -->2160<!-- /fig --> core (name, law) pairs lack a proving law. Laws per name (from
  `proofs/gate/api_map.json`; the first nine are the core laws, which every name has):
<!-- fig:law_table -->
| Law | Names |
|---|---|
| `root` | 240 |
| `ok_eval` | 240 |
| `decode_accept` | 240 |
| `decode_spec` | 240 |
| `decode_unique` | 240 |
| `decode_reject` | 240 |
| `decode_none` | 240 |
| `encode_eval` | 240 |
| `encode_spec` | 240 |
| `roundtrip` | 73 |
| `encoded_size` | 75 |
| `reject_short` | 73 |
| `reject_long` | 73 |
| `decode_tree` | 118 |
| `decode_input` | 126 |
| `serialize_valid` | 208 |
| `decode_offsets` | 240 |
<!-- /fig -->
- End-to-end bridges (`e2e/manifest.json`): <!-- fig:bridged_i -->240<!-- /fig --> names have the encode bridge (i),
  <!-- fig:bridged_iv -->240<!-- /fig --> the root bridge (iv), <!-- fig:bridged_dec -->240<!-- /fig --> the decode bridges
  (ii)/(iii); <!-- fig:bridged_full -->240<!-- /fig --> have all four. Without (ii)/(iii): <!-- fig:no_dec_bridge -->none<!-- /fig -->.
  The manifest's open lists: <!-- fig:manifest_open -->`uncovered` empty, `decode_uncovered` empty, `root_awaiting` empty<!-- /fig -->.
  The remaining premises and limits are in [PREMISES.md](PREMISES.md).

All figures in this section are generated from the artifacts by `codegen/docs/doc_figures.py`, which
`codegen/regen_all.py --check` runs.

## Object-API laws (`proofs/api/<Name>_{encode_ssz,decode_ssz,hashtreeroot}_proof_generated.bend`)

Each facade restates, for the generated functions in `types/<Name>_*_generated.bend`, the laws
proved in `proofs/obj/`, and discharges each one by its proving law:

- **encode**: `encode_eval` gives the exact bytes `X_encode` writes for an object; `encode_spec`
  shows those bytes are `Decoding.decodes(Spec.X(), bytes, value)`, the spec's canonical
  encoding of the object's value; `encoded_size`, `serialize_valid` and `roundtrip` follow.
- **decode**: `decode_accept` / `decode_spec` / `decode_input`: an input that is a canonical
  encoding decodes to an object whose value is the encoded one; `decode_reject` / `decode_none`:
  every other input returns `None`; `decode_unique`: two accepted inputs with one value are equal;
  `reject_short` / `reject_long` for fixed-size names.
- **hash_tree_root**: `root`: the digest is the spec's root (`spec/root_relation.bend`) of the
  object's value.

## End-to-end bridges (`e2e/`)

For each covered name (`e2e/manifest.json`), in the terms of END_TO_END.bend's model API:

- (i) `<Name>_e2e_encode`: `Some(bytes of X_encode(o)) == API.serialize(Spec.X(), value(o))`;
- (ii)/(iii) `<Name>_e2e_decode_accept` / `_decode_view` / `_decode_reject`: the object decoder
  accepts exactly what `API.deserialize` accepts, with the same value, and rejects the rest;
- (iv) `<Name>_e2e_root`: the object's root is `API.hash_tree_root(Spec.X(), value(o))`.

Combined with END_TO_END's laws, each bridge says the object API meets the specification
directly. END_TO_END's statements are frozen; only their proofs were changed.

## Object-mutation laws (field, element and setter access)

Public statements, listed in `e2e/STATEMENTS.txt` and locked in `frozen.lock.json`:

- setter laws, `e2e/<Name>_e2e_set_generated.bend` (`codegen/proofs/collections/e2e_setters.py`), for
  <!-- fig:set_containers -->71<!-- /fig --> containers (Fulu and generic, BeaconState included):
  <!-- fig:set_view_count -->315<!-- /fig --> spec-value laws `view(set_f(o, w)) == field_set(view(o), k, view_f(w))`
  (`proofs/obj/value_set.bend`), composed with the root bridge (<!-- fig:set_root_count -->315<!-- /fig -->
  statements) and the encode bridge (<!-- fig:set_encode_count -->114<!-- /fig --> statements) where the
  bridge's premises allow;
- setter-keeps-rep laws, `proofs/obj/prep_setters.bend` (`codegen/proofs/collections/rep_laws.py`):
  <!-- fig:obj_setter_laws -->211<!-- /fig --> laws over <!-- fig:obj_setter_containers -->36<!-- /fig --> containers;
- collection laws of the public API, `proofs/obj/coll_api_*.bend`, `proofs/obj/coll_bits.bend`, `proofs/obj/coll_bytes.bend` (`codegen/proofs/collections/coll_laws.py`):
  <!-- fig:obj_coll_statements -->474<!-- /fig --> statements over <!-- fig:obj_coll_count -->41<!-- /fig -->
  collections: the flag is exactly the runtime's own guard (computed from the object, read from the generated code; it is not compared
  with the spec's length limit), rejection leaving the object unchanged, None outside the length, the length after an accepted set or
  append; read-back after set (and append, growth included) for <!-- fig:obj_coll_readback -->41<!-- /fig --> collections: the packed collections of whole-word
  elements (`proofs/obj/words_rw.bend`, `proofs/obj/coll_zeros.bend`, `coll_b32.bend`, `coll_b48.bend`, `coll_u64.bend`), the bit lists and byte collections (`proofs/obj/u32bits.bend`,
  `proofs/obj/coll_bits.bend`, `proofs/obj/coll_bytes.bend`) and the list of 2048-byte cells (`proofs/obj/cell_rw.bend`); the other-index law of the
  The spec-value set law of the 2 bit-list collections (`proofs/obj/bits_view.bend`, `codegen/proofs/collections/bits_view.py`: the word replace is a bit replace of the word-expanded storage, by the 32-way split on `i & 31`, then the view is `btk` of it) is in `coll_bits.bend`.
  Data-element lists. The array-list read-back and the boxed-list laws (`proofs/obj/tarray.bend`, `coll_seq.bend`) are in the gate like the rest, and for the five boxed lists the spec-value law `..._api_view_set` (`proofs/obj/tfz_boxed.bend`, `codegen/proofs/collections/boxedview.py`: freezing the array `Array.set` writes is updating the frozen tree of mirrors, by one induction over the depth against `tarray.bend`'s `put`, then `view_seq.bend`'s induction over the items); the view of the new element is that of the stored box, `v_X_bx(th_X_bx(fz_X_bx(wrap v)))`, which the root bridges read of a stored element.
  The spec-value law, `..._api_view_set`, for <!-- fig:obj_coll_view -->41<!-- /fig --> collections: the spec view of the collection after an accepted
  set is the view before with that item replaced by the view of the new element (`proofs/obj/value_set.bend`'s `field_set`: the k-th item of
  a Sequence; `bytes_set` for a byte sequence). The view is the one the root bridges use (`hview`, `pview`, `eview`, `uview`, `vview8`, `xv_<list>`,
  `BytesValue{wview}`, `vview1`), so a reader can compose it with the root and encode bridges; `proofs/obj/view_b32.bend`, `view_b48.bend`, `view_u64.bend`,
  `view_seq.bend` (which also covers the boxed lists, over the frozen mirror trees of `root_types_light.bend`), `view_bytes.bend` and, for the list of 2048-byte cells, `view_cells.bend` (`codegen/proofs/collections/view_laws.py`, `codegen/proofs/collections/viewcells.py`: the same induction, with a cell's bytes the limbs of its 512-word window, `proofs/obj/words_list.bend`; it needs `hcap`, the blocks below the count inside the storage) prove it by one induction over the items and `proofs/obj/words_win.bend`'s word-level facts
  `proofs/obj/coll_root.bend` composes it with the collections' root laws (`ev_rs`, `el_rs`, `pv_rs`: the digest of an object is a specification root of its view under its representation invariant): `..._api_root_set`, for <!-- fig:obj_coll_root -->9<!-- /fig --> collections, says the digest after an accepted set is a specification root of the view with that item replaced. The representation invariant is rebuilt for the written storage (the same tree shape, `words_win.bend`'s `tk_perfect`, the same length).
  An accepted append with room in the storage gives `seq_append`: the view before with the new element's view at the end (`..._api_view_append`; the word lists, the record lists and the byte lists), and `..._api_view_append_grow` when the append reallocates (the word lists: `proofs/obj/words_win.bend`'s `at_cpy_in` says the copy keeps the old words).
  (the byte collections: through the limbs of the written word, `proofs/obj/byte_bits.bend`, and the split of the index into word and offset, `proofs/obj/u32split.bend`).

The range-checked generic setters (<!-- fig:set_checked_count -->11<!-- /fig -->, `uint8` / `uint16` fields) have their
flag, rejection and accepted-value laws in the same files. Not stated: the spec-value
append law of the bit lists, of a byte list whose append reallocates the storage, and of the boxed lists; the root view of the record lists that have none; the
composed root and encode statement of a mutated list for the boxed lists, the Bytes32 list, the u64 collections and the record lists; and
setter-then-encode where the encode bridge takes storage premises.
[PREMISES.md](PREMISES.md) section 9.

## Conformance (official vectors, through the generated object API)

`benchmarks/evidence/object_conformance.json`: every `mainnet/fulu/ssz_static` case of
consensus-specs v1.6.1 (295 cases, 59 types; decode, re-encode byte for byte, root against
`roots.yaml`). `benchmarks/evidence/generic_object_conformance.json`: every `ssz_generic` case
(5,145, valid and invalid, all 10 families; the 8 zero-length schemas are rejected by
construction).

The fixtures these runs read are the pinned release files: `tools/verify_fixtures.py` checks every
committed fixture against `fixtures.manifest.json` (in every full check), and with `--tarballs`
fetches `general.tar.gz` and `mainnet.tar.gz`, requires their sha256 to be `upstream.lock.json`'s,
and requires the manifest to be exactly the archives' `ssz_generic` and `fulu/ssz_static` members,
each with the same sha256.

## Other test evidence (finite regressions, not laws)

All against the independent oracle `codegen/core/oracle.py` (written from the specification, sharing
no code with the generated runtime) unless noted; last run <!-- fig:evidence_date -->2026-10-01<!-- /fig --> on the ssz server at
<!-- fig:evidence_commit -->5bdc9afa<!-- /fig -->, all passing. The runtime is stock Bend 2.0.34; each file records the compiler, the sources,
the harness and the hash of every native program it ran (`benchmarks/checks/provenance.py`).

| File | Harness | What |
|---|---|---|
| `fuzz_objects.json` | `tests_generated/fuzz_objects.py` | <!-- fig:fuzz_types -->240<!-- /fig --> types (<!-- fig:fuzz_fulu -->109<!-- /fig --> Fulu, <!-- fig:fuzz_generic -->131<!-- /fig --> generic), seed 20260921: <!-- fig:fuzz_valid -->1,920<!-- /fig --> valid values (random, zero, maximal, empty, list-boundary), <!-- fig:fuzz_random -->15,360<!-- /fig --> random and <!-- fig:fuzz_boundary -->34,228<!-- /fig --> field-boundary corruptions (<!-- fig:fuzz_kinds -->16<!-- /fig --> kinds in all), <!-- fig:fuzz_history -->3,840<!-- /fig --> mutation-history steps through the object setters of <!-- fig:fuzz_setter_types -->64<!-- /fig --> types (the others are leaves and aliases without setters); <!-- fig:fuzz_mismatches -->0<!-- /fig --> mismatches; about <!-- fig:fuzz_elapsed -->3<!-- /fig --> minutes |
| `object_mutations.json` | `benchmarks/checks/object_mutations.py` | malformed variants of every ssz_static case (5,455 inputs); the verdict of each comes from the oracle; 0 disagreements |
| `object_mutation_tests.json` | `tests_generated/mutations.py` | 8 field/element updates through the object API against the oracle's re-encoding, rejections leave the value unchanged |
| `invalid_objects.json` | `tests_generated/invalid_objects.py` | 14 cases: representable but invalid objects (built with raw constructors) are refused by the checked encoder, each with a valid control |
| `negative_api.json` | `tests_generated/negative_api.py` | 7 programs: appending to vectors, use after move, duplication and a stale collection must not compile (for the stated reason), a positive control must |
| `object_cache.json` | `benchmarks/checks/object_cache.py` | cached validator-list roots under 7 modes and 100 seeded histories equal the uncached root and the oracle's |

`tests_generated/mutations.py` stays the eight hand-written update checks; the schema-driven corruption tests are the
field-boundary corruptions of `fuzz_objects.py` (`bounds` walks the schema and the value: every field start, offset slot,
offset target and collection element), counted separately above. The whole runtime evidence suite (`tools/run_evidence.sh`:
builds, eight harnesses, the Bun tests) takes about 6 minutes on the ssz server with warm program caches (the first build of
all programs adds about 15); `fuzz_objects.py` alone takes about 3 minutes. 45 of the 109 Fulu names have no setters in the generated API
(the basic types and aliases, `ProposerSlashing`, `AttesterSlashing`): `fuzz_objects.json` lists them, and their values get
valid, corrupted and boundary cases but no mutation histories; the 131 generic names have no fuzz programs, so they get the
same valid, corrupted and boundary cases only.

Every evidence file carries a provenance stamp: commit, time, runtime toolchain hashes, the
arguments, the sha256 of the tested sources (the whole `types/*.bend`, including the dispatch
modules `types/fulu_obj_*.bend` and `types/generic_obj_*.bend` the programs call, `src/*.bend`,
the drivers `benchmarks/objprog/*.bend` and `benchmarks/compact/*.bend`, and the vector set
`cases.json` + `fixtures.manifest.json`) and of the harness that produced it with the oracle and
schema readers it relies on. `python3 benchmarks/checks/provenance.py` says, for each file,
whether those hashes are the current tree's. Rebuild the programs with
`python3 benchmarks/quick.py --build all`, `--build-generic all`, `--build-fuzz all` and
`bend benchmarks/compact/<o>.bend -o build/compact-<o>`, then run the harnesses (on the ssz
server, with `BEND_RUNTIME` naming the pinned runtime compiler of `benchmarks/toolchain.json`).

Removed as stale on 2026-09-30: `spectests-js.json` (the JavaScript-runtime spectest run of
09-23; that runner no longer exists, and the native object-API conformance above covers the same
vectors). Moved to `docs/history/evidence/`: `native-comparison.json` and the driver artifacts
of the 09-21 memory comparison with Go (a macOS measurement of an earlier Bend, cited by
`docs/history/MEMORY_REVIEW.md`; performance, not correctness).
