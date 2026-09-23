# Old-to-new law and API map (array-indexed migration)

Status, 2026-09-21 (iteration 17). **No `END_TO_END` or `ROOT_DOMAIN`
proposition has been changed.** `docs/LAW_MIGRATION.json` - the file the frozen
gate `automation/native_memory_acceptance.py` reads - therefore records every
original law as its own counterpart, with the equivalence argument being
identity. That is the honest state: the array/object migration happened in the
*runtime*, and the universal laws still speak about the list-based model API
that `src/model.bend` provides.

What that means concretely:

* the 29 `END_TO_END` and 13 `ROOT_DOMAIN` propositions are byte-for-byte the
  frozen ones and are checked (`benchmarks/evidence/check_*.log`);
* the production runtime is the generated typed owning object API
  (`types/fulu_obj.bend`, `types/generic_obj.bend`), which carries checked
  mutation/collection/cache/cost laws (`proofs/obj/*.bend`) and native evidence
  for all 5,440 official cases. Since 2026-09-22 it also carries **codec
  correctness laws on one stated class**: `proofs/obj/codec_*.bend` and
  `proofs/obj/gcodec_0.bend` hold, for every name whose encoding is a whole
  number of words at word-aligned positions (70 of the 109 Fulu names and 7 of
  the generic schemas), that decoding an encoding returns the object, that the
  encoding has the type's fixed size, and that a buffer one byte short or one
  byte long is rejected - stated over free word variables, so over every object
  of the type, and proved by computation against `T.<name>_encode` and
  `T.<name>_decode` themselves. The remaining names (sub-word leaves, variable
  size) have **no codec-correctness law yet**: those equations are not
  definitional and need the bit lemmas and the offset development;
* Since 2026-09-23 (Bend 2.0.25) the generated codec is also **connected to the
  independent specification** for 83 of the 109 Fulu names
  (`codegen/spec_laws.py` -> `proofs/obj/spec_fixed.bend`, `spec_bits.bend`,
  `spec_small.bend`, `spec_codec_{0..6}.bend`, `spec_unique_{0,1,small}.bend`):
  the bytes the encoder emits through `B.emit` satisfy
  `Decoding.decodes(Spec.<N>(), bytes, value)` of spec/decoding_relation.bend
  (encoder soundness against spec/codec.bend; for objects with packed storage
  every storage padding word is free); decoding a buffer of the size accepts and
  returns the object whose spec value is related to exactly that buffer's bytes;
  every other size is refused; and every spec value of those bytes equals the
  decoded value (via the frozen `deserialize_unique` and the name's legality
  witness). For `boolean` the rejection is characterized exactly: every byte
  above 1 is outside the spec image.
  **Buffers**: `proofs/obj/repr.bend` proves every perfect Array tree of depth d
  is the canonical tree of its words, so `spec_repr_*.bend` state the decode and
  view laws for EVERY perfect buffer array of the loader's depth (not a literal
  tree); `load.bend`/`spec_input_*.bend` state them for the buffer the real
  loader builds (`B.fill_at(B.alloc(n), 0, bytes)`, benchmarks/compact/objio.bend)
  from every byte list of the size. Arrays that are not perfect trees are not
  produced by Base's `Array.new`/`set`; they are outside this bridge.
  Not covered: HistoricalBatch, SyncCommittee, Blob, BlobSidecar (packed storage
  beyond 512 words: need loop induction over the array model), Validator (a
  boolean inside an unaligned record), the 21 variable-size names, and all roots.
* Root equality is blocked at one point, recorded with measurements: the SHA
  function-level bridge between the pinned package's `fips.bend` and the vendored
  one is proved (`proofs/obj/sha_bridge.bend`), but the checker normalizes every
  checked type eagerly and without sharing: `{VF.extension(k, h) == VF.extension(k, h)}`
  with h a free list checks in 0.3 s (k=8), 2.5 s (k=12), 71 s (k=16) and not
  within 120 s (k=20), about x28 per four rounds. Both the package's packed
  specification and the vendored spec fix 48 rounds, so any statement that
  mentions the 48-round schedule - which the 64-byte link `hash_pair == FIPS on
  64 bytes` must - is out of reach for this checker. No root law is claimed.
* The public encoder is `<Name>_serialize -> O.Encoded{ok, bytes}`: it refuses
  representable-but-invalid objects (scalars out of range, bits or bytes set
  past a length, lengths over limits or not whole elements, storage too small
  for a length, empty boxes) instead of masking or merging them. For the 74
  Data names the law `serialize = valid ? encoded(encode) : refused` is checked
  (proofs/obj/serialize_*.bend). For the linear names the check is fused into
  the writers (codegen/generate.py `emit_putk`) and is covered by native
  regressions (tests_generated/invalid_objects.py) and the spectests, not yet by
  a law equating the fused flag with `<p>_valid`.
* `src/model.bend` is kept precisely because the frozen propositions are about
  it. Deleting it would delete checked coverage, which the operator instruction
  forbids until equivalent generated laws exist.

The rest of this document is the design of record for the translation that is
still to be carried out. Rows marked `planned` are still planned. Nothing below
is presented as done.

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
semantics and 32-byte outputs. None mentions a storage representation. Twelve
are byte-for-byte as merged; the only work is re-deriving bodies that go
through the decoder, using `root_bridge`.

**`root_domain_strictly_broader` changed, as a strengthening.** As merged
from the root-domain worker (`ROOT_DOMAIN.bend` lines 222-225 there) it fixed
the witness depth at 3:

```
law root_domain_strictly_broader:
  for +r: Nat
  (@+xs: ... -> Broader.broader_facts(Witness.nest_schema(3n, r), Witness.nest_value(3n, r, xs))) &
  Exists(T.Schema, schema => Exists(T.Value, value => Broader.broader_facts(schema, value)))
```

It now quantifies over every depth `d` with premise `Nat.is_le(3n, d) == True`.
Instantiating `d := 3` discharges the premise by computation (`{==}`) and
gives the old statement exactly, so the generalised law is a strengthening.
That instantiation is not added as a separate checked law, for a measured
reason: a corollary `root_domain_strictly_broader_depth3(r) =
root_domain_strictly_broader(3n, r, {==})` made the checker normalize the
witness at the literal depth - the blow-up the generalisation was introduced to
avoid - and `ROOT_DOMAIN.bend` went from 5.03 GB to over the 6.8 GB cap in
two attempts (benchmarks/evidence/check_ROOT_DOMAIN.log records the passing
check without it). The frozen gate `automation/root_domain_acceptance.py`
requires the law by name, which the generalised law satisfies.

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

   **Measured, 2026-09-22.** The obstacle is now demonstrated rather than
   predicted, and it is larger than "needs the word lemmas":

   * the kernel does no symbolic algebra on native `U32`. `((x & 255) & 255) ==
     (x & 255)` does not check: `expected U32.and(U32.and(x, 255), 255)`,
     `observed U32.and(x, 255)`. The `proofs/word_*` and `proofs/compact/bits`
     lemmas are about the *specification's* bit-list `U32`, which is a
     different type from the runtime's native word, so they do not transfer;
   * there is no read-after-write law for `Array`. `Array.get(Array.set(a, i,
     v), i)` does not reduce on a symbolic `a`, because `Array.size` is stuck.
     Every statement of the form `store_index` needs exactly that lemma.

   Neither can be added as an axiom (the objective forbids it), and neither is
   derivable in the pinned kernel without induction over a symbolic tree. Until
   one of them is available, a universal law about array-backed storage can
   only be discharged where both sides reduce by computation - which is the
   aligned fixed class that `proofs/obj/codec_*.bend` covers (70 of 109 names,
   7 of 144 generic schemas, four laws each).
2. The decoder must be rewritten in linear buffer-threading style, and the whole
   `proofs/cursor_*.bend` development (about 3,500 lines) restated over indices,
   because every one of its laws currently quantifies over a duplicable
   `P.Slice`.
3. Only then do the rows in sections 2-4 become provable through the bridges.

Until 1 and 2 are done, the honest status of the migration is: measured,
designed, justified, and not implemented.
