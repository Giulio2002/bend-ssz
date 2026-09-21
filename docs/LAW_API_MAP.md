# Old-to-new law and API map (array-indexed migration)

Status of this document: **design of record, not yet implemented.** Nothing in
`src/` has been migrated to array storage at the time of writing. The map below
is written first, as the orchestrator requires, so that every translation can be
inspected for non-weakening *before* the representation changes. Rows are marked
`planned` where the new form does not exist yet; none are marked `done`.

Update, 2026-09-21: the starting point for the migration is now a *checked*
base. `bend PROOF.bend` and `bend END_TO_END.bend` check with zero unsafe
annotations (5.1-5.7 GB of physical footprint each, varying between runs), and both frozen gates
(`automation/root_domain_acceptance.py`, `automation/native_memory_acceptance.py`)
exit 0, which also means the 29 END_TO_END propositions in section 2 below are
currently proved in their original form. Every row in this map is therefore a
change to a proposition that is presently checked, and the non-weakening
argument for each has to be read against that, not against a broken base. See
WORK_LOG.md for the measurements and for the two normalization blow-ups
(exported case-split laws, and a literal depth in the root-domain witness) that
had to be repaired to get there - both are worth knowing before writing the
array development, because the same two mistakes are easy to repeat in an
index-arithmetic proof.

## 0. What the pinned runtime actually offers (measured, not assumed)

The migration target is constrained by facts about pinned Bend 2.0.16 that were
measured on this machine, not inferred. Evidence: `benchmarks/probes/` (sources
and numbers) and the emitted C at `build/native/bend-ssz.c`.

1. The native runtime has contiguous block storage. The emitted C defines
   `TAG_BUF` and `TAG_ARR` terms and the block layer around them
   (`build/native/bend-ssz.c:185-190`, `:3526-3620`). Its own comment states:
   *"A block owns one allocation in its physical class (an ARR of class c 2^c
   Terms in 2^c words, a BUF 2^c u32 in 2^buf_wcls(c) words) ... get, set, swap,
   size and new open no half."* So `Array<T>` is a contiguous block with O(1)
   indexed access, and `Array<U32>` is a packed u32 buffer - not a pointer-chasing
   tree, despite the `ALeaf/ANode` surface syntax.
2. Indexed access is fast enough for the contract: 2,740,473 indexed reads of an
   `Array<U32>` take under 1 ms (`benchmarks/probes/list_to_array.bend`,
   `SCAN_MS=0`), against a 1.75 ms budget (5x Go's 0.35 ms BeaconState decode).
   The current chunk-list decoder needs 24-27 ms for the same fixture.
3. **`Array<T>` has kind `Type`, not `Data`, so it cannot be duplicated.**
   `def twice(+a: Array<U32>)` is rejected with `expected: Data, observed: Type`
   (`benchmarks/probes/array_share.bend`). An array-backed decoder therefore
   cannot hand a shared view of the input to two sub-decoders; it must thread the
   buffer linearly and address it by index, returning the buffer with every
   result.
4. Base's file API yields a linked list: `File.read_bytes`/`File.read_at` return
   `List<&2, U32>` (`/Users/monkeair/.bend/bend2/base.bend:267-276`). There is no
   buffer-returning read. Converting a 2.74 MB byte list into an `Array<U32>`
   costs 5 ms (`FILL_MS=5`), which is already 14x Go's entire decode. This is why
   buffer-ready decode, input conversion and end-to-end ingestion must be
   reported as three separate numbers; the conversion cost is a property of the
   pinned Base, not of the SSZ code.
5. Allocation of decoded nodes is cheap: 200,000 two-field records build in 1 ms
   (`benchmarks/probes/record_alloc.bend`), about 5 ns per record.

Consequence for the architecture: the array migration is worth doing and is
where the remaining speed is, but it is a **different decoder** - linear buffer
threading plus index arithmetic - and therefore a different proof development
from the slice-based one now in `src/`. It cannot be a drop-in substitution of
one storage type inside the existing proofs.

## 1. Design that keeps every END_TO_END proposition byte-for-byte

The frozen propositions in `END_TO_END.bend` speak about `+List<U32>` input
bytes and `T.Value`. The migration keeps them **unchanged** by making the
list-level entry points *definitions on top of the array path* rather than
independent implementations:

```
store_of_list : +List<U32> -> Store                 (array fill, runtime)
deserialize_store : T.Schema -> Store -> Store & Maybe<CValue>   (primary)
deserialize (schema, xs) := forget(deserialize_store(schema, store_of_list(xs)))
```

Because the list entry point is *defined through* the array path, a law stated
about the list entry point is a law about the array path composed with the
bridge; it is not an adapter proved separately from the runtime. Two bridge
theorems carry the weight and are named in every row below:

* `store_denotation` - `store_bytes(store_of_list(xs)) == xs` for every byte list
  in domain (`bytes_domain(xs) == True{}`): filling an array from a list and
  reading it back by index yields the same byte sequence.
* `store_index` - `byte_at(s, i)` equals `IP.at(store_bytes(s), i)` for `i` below
  the size: the indexed read agrees with the denotation the specs quantify over.

Every law whose statement mentions only `T.Value`, `T.Schema` and byte lists
therefore **stays byte-for-byte**. Only laws that mention a *representation*
(`P.Slice`, `C.CValue`, `Packed.Packing`) need a migrated signature, and those
are internal lemmas, not END_TO_END propositions.

## 2. END_TO_END laws (29) - all stay byte-for-byte

| law | old proposition | new proposition | bridge | why not weaker |
|---|---|---|---|---|
| `decide_invalid` | over `T.Schema`, `Bool` | unchanged | none needed | statement never mentions storage |
| `illegal_invalid` | over `T.Schema` | unchanged | none needed | same |
| `serialize_illegal` | `API.serialize` on `T.Value` | unchanged | `encode_bridge` | `serialize` becomes `bytes_of_store(encode_store(...))`; same domain, same `None` cases |
| `serialize_correct` | `API.serialize` exactness | unchanged | `encode_bridge` | conclusion is the same equation on the same list |
| `accepted_spec` | `API.deserialize` sound | unchanged | `store_denotation`, `store_index` | premise and conclusion identical; only the proof route changes |
| `spec_accepted` | `API.deserialize` complete | unchanged | same | same |
| `deserialize_correct` | both directions | unchanged | same | same |
| `deserialize_unique` | injectivity | unchanged | same | same |
| `reject_decide` | rejection on illegal type | unchanged | same | same; body must be re-derived from the new entry point |
| `deserialize_rejection_correct` | both directions | unchanged | same | same |
| `root_accepted` | `API.hash_tree_root` sound | unchanged | `root_bridge` | root consumes compact values; conclusion is the same relation on the same 32 bytes |
| `hash_tree_root_correct` | sound + complete + total | unchanged | `root_bridge` | same three conjuncts, same domain |
| `named_valid`, `preserved`, `named_accepted_result`, `named_decoded`, `decoded_shape`, `named_rejected_result`, `named_root_accepted`, `named_outside`, `fulu_types_correct` | per-name Fulu composition over `T.Value` | unchanged | the same three bridges | the named layer is definitional over the generic layer; migrating storage under it changes no proposition |
| `legal_boolean_exists`, `boolean_image_exists`, `boolean_image_decoded`, `boolean_rejects_two`, `boolean_root_domain`, `empty_container_absurd`, `illegal_empty_container`, `checkpoint_named_legal` | closed witnesses | unchanged | none needed | closed terms; they only need the entry points to keep their types |

`memory_bench/law-statements.json` is the frozen byte-for-byte snapshot and must
keep matching after the migration; `automation/native_memory_acceptance.py`
checks exactly that, and no row above changes a character of any proposition.

## 3. ROOT_DOMAIN laws (13) - all stay byte-for-byte

`none_unless`, `domain_rejected`, `illegal_rejected`, `relation_unique`,
`generic_contract`, `named_contract`, `full_root_correct`, `with_previous_at`,
`with_previous`, `previous_at`, `previous_preserved`,
`serializable_root_compatibility`, `root_domain_strictly_broader`.

All of these are stated over `T.Schema`, `T.Value`, the relational root
semantics and 32-byte outputs. None mentions a storage representation, so all
stay byte-for-byte; the only work is re-deriving bodies that go through the
decoder, using `root_bridge`. The broader-domain witness
(`root_domain_strictly_broader`) is a closed term and is unaffected.

## 4. Public API surface

| old API | new API | status | bridge theorem | non-weakening argument |
|---|---|---|---|---|
| `ssz.deserialize(schema, +List<U32>) -> Maybe<T.Value>` | `ssz.deserialize_store(schema, Store) -> Store & Maybe<CValue>` primary; list form kept as a definition on top | planned | `store_denotation`, `store_index`, `value_denotation` | the list form is *defined* as fill + primary + forget, so its law is a law about the primary path; the accepted set is unchanged because the bridge is an isomorphism on byte lists in domain |
| `ssz.serialize(schema, T.Value) -> Maybe<+List<U32>>` | `ssz.encode(schema, CValue) -> Maybe<Store>` primary; list form defined as `bytes_of_store . encode` | planned | `encode_bridge`, `value_denotation` | same encoding function, same rejection set; the list form's proposition is unchanged |
| `ssz.hash_tree_root(schema, T.Value) -> Maybe<+List<U32>>` | `ssz.root(schema, CValue) -> Maybe<Digest>` primary, streaming; list form defined on top | planned | `root_bridge` | same relation, same 32-byte conclusion, same domain predicate |
| `ssz.valid`, `ssz.type_valid` | unchanged | done | none | schema-level only |
| schema constructors (`boolean_type` ... `compatible_union_type`, `chain`, `end`) | unchanged | done | none | schemas are Data and small; they are not a storage representation |
| value constructors (`boolean_value` ... `null_value`) | compact constructors on `CValue` plus the existing `T.Value` ones for the spec/oracle layer | planned | `value_denotation` | the compact constructors cover the same value space; `T.Value` stays as the specification's view only |
| `types/fulu.bend` `Name.{schema,to_ssz,from_ssz,valid,serialize,deserialize,hash_tree_root}` for all 109 names | same names, compact types (`Store`/`CValue`) | planned | per-name composition over the three generic bridges | the named layer is definitional; its laws quantify over the same closed name index |

## 5. Internal lemma surfaces that do change signature (not END_TO_END)

| old | new | why the change is forced | non-weakening |
|---|---|---|---|
| `P.Slice{chunks: +List<Chunk>, start, size}` | `Store` = linear `Array<U32>` + size, cursors are `Nat` indices | `Array` cannot be duplicated (probe 3), so a slice cannot carry its own storage | denotation `store_bytes` has the same type as `P.slice_bytes`, so every downstream law keeps its shape |
| `PK.byte_at_view`, `sub_view`, `adv_view`, `wf_*` | `store_index`, `store_take`, `store_drop`, `store_size` | same content over indices | each new lemma has the same conclusion with `store_bytes` in place of `slice_bytes` |
| `C.CValue` with `CCons/CEnd` child spine | `CValue` with array-backed children | the operator requires no linked spine in decoded sequences | `C.to_value` stays as the spec view; the child-order laws are restated over indexed access with the same order |
| `Pack.Packing`, `pack_list`, `pack_spec` | `store_of_list` + `store_denotation` | packing becomes a fill, not a chunk build | the packing round-trip law becomes the denotation law, same equation |

## 6. What has to be true before any row above can be marked done

1. `store_index` and `store_denotation` must be *proved*, not assumed. Both are
   statements about `Array.get`, whose Base definition descends `ANode` with
   `U32.shr`/`U32.and`/`U32.sub` index arithmetic; proving them needs the
   bit-level word lemmas that `proofs/word_*.bend` already provide for the
   existing limb code. This is the first real obstacle of the migration and it
   has not been started.
2. The decoder must be rewritten in linear buffer-threading style, and the whole
   `proofs/cursor_*.bend` development (about 3,500 lines) restated over indices,
   because every one of its laws currently quantifies over a duplicable
   `P.Slice`.
3. Only then do the rows in sections 2-4 become provable through the bridges.

Until 1 and 2 are done, the honest status of the migration is: measured,
designed, justified, and not implemented.
