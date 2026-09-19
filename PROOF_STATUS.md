# Proof status — CURRENT obligation table (iteration 0011, rechecked on Bend 2.0.16)

Everything below "Historical notes" is superseded. A green checker establishes
only the propositions written; the propositions below are stated in
`END_TO_END.bend` and checked through `PROOF.bend` (which imports it).

| Required law | Actual API | Independent specification | Checked theorems composed | Unresolved premises | Public composition |
| --- | --- | --- | --- | --- | --- |
| serialize_correct | `src/ssz.serialize` | `spec/type_legality.type_legal`, `spec/codec.encoding_for_legal_type` | codec_composition.serialize_for_valid_type; type_validator_complete.public_complete; type_validator_soundness.public_sound | none | checked (END_TO_END) |
| deserialize_correct (+unique) | `src/ssz.deserialize` | `spec/decoding_relation.decodes` | decode_soundness.accepted_decodes; decode_complete.image_accepted/normative_image_accepted/image_unique (recursive inverse decode_inverse.inverse, layout image, item counts, decode_budget.accepts_finite) | none | checked |
| deserialize_rejection_correct | `src/ssz.deserialize` | `spec/decoding_relation.outside_image` | decode_soundness.outside_image_rejected; decode_complete.valid_rejected_outside; validator equivalence | none | checked |
| hash_tree_root_correct | `src/ssz.hash_tree_root` | `spec/root_relation.root_for_legal_type`, `spec/value_domain.root_domain` | root_public.root_sound (root_sound.sound, root_steps), root_public.root_complete (root_complete.complete, root_complete_steps: relation ⇒ exactly this root, hence the relation is functional), root_public.root_total (root_total.total, root_total_steps), root_scope.accepted_root_scope | none (see domain note) | checked |
| fulu_types_correct | `types/fulu.bend` `Name.*` dispatch; every `X.*` is definitionally `Name.*` at `Name_X` | `spec/fulu_schemas.bend` (named schemas ARE these constants) | fulu_named.legal/inverse/sound/complete (fulu_legality, fulu_adapter_inverse/preservation/complete), codec_shape, representation_erasure, the four generic laws | none | checked |

Domain note (hash_tree_root): valid values are those with a normative encoding
(all serialization assertions including the 2^32 offset bound) whose mixed
lengths are uint256 (`mix_in_length` serializes `len(value)` as uint256;
`to_bytes(32)` raises otherwise). For bounded lists this is expected to follow
from the size bound (the condition is stated explicitly rather than derived from the size bound); for
unbounded progressive bitlists it is a genuine normative condition. It is not a
runtime/resource restriction. Totality is proved on exactly this domain.

Proof-engineering boundary: the pinned checker compares Nats in unary, so any
checked equation that unfolds two separately written large limits (e.g.
2^40) overflows. Named schemas are therefore the independent constants
themselves (single source), and the named law is proved symbolically over the
closed name index; per-name public aliases (`X.serialize(v) :=
Name.serialize(Name_X{}, v)`) are definitional and are additionally checked
textually by `tests/new/fulu_inventory.test.ts`.

Toolchain (current): Bend 2.0.16 pinned by `automation/toolchain.json`
(bend sha256 da9bc51449f04a65bf633351fb754cd6f883f5f5d9ab0c4e947f5c6f19eb7386,
base.bend sha256 e149828ca05581f61d1b06cf2a7d1a744e394d29a4c8e1942e5062ecbf30f5b8).
Evidence produced under Bend 2.0.5 (iterations 0001–0011, including the
"Latest evidence (iteration 0011)" paragraph below) is historical.

Unsafe inventory and repair (2.0.16): the pinned checker initially reported
"All terms check, with 110 unsafe annotations." Its `cli_report` counts every
definition marked `@unsafe` or whose name contains `~` (a template instance,
whose cross-instance recursion it does not termination-check). There is no
`@unsafe` text in the project; all 110 were the instances of the five generic
templates `to_items`, `to_items_go`, `from_items`, `from_items_go`,
`from_step` in `types/fulu.bend` over 22 element types (22 × 5). Each was
replaced by monomorphic helpers `C.seq_to_go`, `C.seq_to`, `C.seq_step`,
`C.seq_from_go`, `C.seq_from` (same algorithm, ordinary structurally
terminating definitions checked by the kernel). The adapter proofs
`proofs/fulu_adapter_{inverse,preservation,complete}.bend` are regenerated and
are identical to the previous proofs under exactly that renaming; only the
per-element helper lemmas mention the helpers, and every public/named law
statement is textually unchanged. Now `PROOF.bend` and `END_TO_END.bend`:
"All terms check." (zero unsafe) with the unmodified checker. Row-level
inventory and a minimal reproducer (template: 2 unsafe; monomorphic: 0):
`tools/unsafe-2.0.16/`. This is intended checker behaviour, not a kernel defect.

Runtime adapter (2.0.16): the 2.0.5 preload `bend2/main.ts` no longer exists.
`tools/bend_loader.ts` (Bun preload plugin) compiles each imported `.bend`
module with the pinned compiler's own library emitter (via its official
`bend page.html -o dir` bundler) and re-exports the result unchanged;
`tools/run_runtime_tests.py` and `tools/spectests.py`/`probe_backend.py` use it.
No Bend algorithm is replaced by host code; expected outputs never reach it.

Trust boundary: the unmodified pinned Bend checker/Base; faithful transcription
of `simple-serialize.md` in `spec/*.bend` and of `schemas/fulu_mainnet.json`
in `spec/fulu_schemas.bend`; the vendored FIPS SHA-256 specification
(`HASH_PROOF.bend` proves the runtime SHA equals it and returns 32 bytes).
Collision resistance of SHA-256 is not assumed or used. Compiler (Bend→JS),
the local loader `tools/bend_loader.ts`, Bun runtime, hardware and the JSON
transport are outside the proofs; the
transport only converts representations and never sends expected outputs.

Runtime/resource limits (not protocol restrictions): runtime Nat is a machine
word (programs abort past 2^48-1 per the Bend guide), Bun memory/stack and
wall-clock time. Official runs treat crashes/timeouts as failures.

Theorem index: `python3 tools/theorem_index.py` writes build/theorem_index.txt.

Historical evidence (iteration 0011, Bend 2.0.5; current 2.0.16 evidence is in
VALIDATION.json `bend_2_0_16`): PROOF.bend and END_TO_END.bend check; 51
runtime tests / 20,009 assertions pass; 5,440/5,440 official cases pass (two
separate complete runs: worker run and the acceptance run); frozen acceptance
exit 0. Reports and the acceptance log are archived under tools/ with SHA-256
names; VALIDATION.json records source hashes.

Proof map (new this iteration): decode_facts, decode_shape, decode_goal,
decode_inverse, decode_complete (decoder completeness/uniqueness/exact
rejection); root_steps, root_sound, root_complete_steps, root_complete,
root_total_steps, root_total, root_public (root soundness, completeness,
totality); fulu_named (name-indexed adapters); u32_order, leaf_sizes,
exact_division (arithmetic helpers). Generators (constructor enumeration only):
tools/generate_decode_shape.py, generate_decode_inverse.py,
generate_root_sound.py, generate_root_total.py, generate_root_complete.py,
generate_fulu_named.py, generate_fulu.py.

# Historical notes (superseded)

# Proof status — objective incomplete

Iteration 0003 extends the retained composite implementation with checked
layout, canonical-decoder and successful-root-scope laws.
PROOF.bend also typechecks the new API dependency closure; typechecking functions
is not a refinement proof. END_TO_END.bend and its five required laws remain
absent. No full-Fulu verification or acceptance claim is made. Historical evidence is separate from current worker validation: iteration 0003's
worker reported 5,440 passes, followed by a runner result with 5,439 passes and
one Bun segmentation fault. Iteration 0004 retained no edits or validation;
those earlier build artifacts are unavailable here.

Iteration 0005 worker run `0ce8c3e8-4a42-45b4-bf31-75831fda9fdf` completed all
5,440 official cases successfully, with 159 zero backend exits and no retries.
The exact report is preserved as
[an immutable worker report](tools/validation-iteration-0005-official-87fef23523b4e03a65f570920b38dc2260fdd35a8b98f196a93ebacce5cf0ee8.json).
Frozen acceptance exited 1 for missing END_TO_END.bend. This identifies this
worker run; subsequent runner results must be assessed separately. Bun's
lower-memory mode passed three diagnostic repetitions and this full run, but
the earlier native crash's root cause was not confirmed. The full objective
remains incomplete.

## Current checked dependency map

| Layer | Universal actual-API coverage |
| --- | --- |
| HASH_PROOF / vendor SHA | Preserved direct runtime SHA equals independent FIPS; exactly 32 output bytes |
| word_facts / word_split / power_division | Comparison, mask and carry facts; arithmetic division versus shifts |
| primitive encoding/decoding/inverse/canonical modules | Independent uint8..uint256 and boolean semantics, canonical images, exact rejection, root bytes |
| fulu_primitives | All 21 frozen primitive names, domain/codec/root/inverse composition |
| bytes / byte_root | Byte-vector domains, canonical codecs and roots, including repaired total serialized-size bound <2^32 |
| packing / tree / limits / merkle / mixing | Ordered chunks and padding; minimal arbitrary-limit trees; virtual zeros; count/malformed rejection; FIPS nodes, length and selector mixing; output scope |
| fulu_byte_inventory / fulu_bytes | All 24 closed fixed-byte identities, including Blob; 23 retained literal specializations |
| bit_packing / bitfields / bit_decode and inverse/canonical chains | Independent arithmetic bit semantics; both codec-image directions; unused-bit/delimiter/capacity rejection |
| bit_chunk_count | Actual scan length invariant; ceil(bits/256) for every list; capacity monotonicity |
| bit_root | Bitvector independent roots at every canonical depth, constructed selected witness, exact acceptance = validity, totality and 32-byte scope |
| nat_bytes | Exact-width natural conversion; actual division reconstruction; exact positional numeric value, byte range, width, overflow rejection and monotonicity |
| bit_list_root | Delimiter-free packing, ceil(capacity/256), exact length mixing, independent FIPS refinement, exact acceptance and output scope |
| byte_list | Canonical identity codecs and exact rejection, byte/capacity/serialized-size validation, ceil(capacity/32) packing bound, root refinement and totality for every valid value |

Bitlist root acceptance is capacity validity AND uint256 representability of its
actual bit length. This is the normative mixer domain, not a resource cap.
Totality is proved under that domain and also for all values within a capacity
whose length fits uint256. Named Fulu composition must discharge those conditions.
Byte-list validity includes the sequence serializer's stricter 2^32 size bound,
which now discharges its uint256 mixing domain internally.

The count proofs use intrinsic 32-byte / 256-bit residual positions plus an
arbitrary-size recursive case. Nat-byte conversion uses the 256 intrinsic byte
values plus a proof excluding larger residues. None enumerates fixture values,
assumes codec/Merkle correctness, or restricts mathematical inputs to runtime Nat.
All new modules above are reachable through PROOF.bend.

## New composite layers

- `lists`: universal tail-recursive length/append/replicate equality with Base.
- `layout`: unconditional actual encoding refinement to the independent fixed/
  payload formula, including reversed accumulators, exact offsets, byte-domain
  validation and strict size overflow rejection.
- `layout_slices`, `layout_extents`, `layout_headers`: unconditional actual layout
  decoder refinement to independent forward slicing/header/extent semantics.
  Every byte-domain premise is discharged at the public layout entry point.
  The separate equivalence between that decoder and the encoder's canonical
  image (both directions) still needs proof.
- `layout_counts`, `decode_count_bound`, `schema_measure`, `decode_layout_bound`:
  successful slice counts, sequence-count bounds by input byte length, container
  field bounds by schema weight, and their composition at actual decoder calls.
  These are traversal prerequisites, not the complete fuel-sufficiency theorem.
- `codec_helpers`, `codec_leaves`: actual generic leaf dispatch, layout wrapping,
  tagging and compatible-option selection refine the independent specifications.
  Recursive forest composition and full independent type legality remain open.
- `decode_canonical`: actual byte comparison refines extensional sequence
  equality. Every value accepted by the exported SSZ decoder serializes to the
  exact input through the actual serializer. This does not establish independent
  decoding completeness or traversal-budget sufficiency.
- `root_scope`: every successful generic/public SSZ root consists of exactly 32
  byte-range elements, for every schema/value. The proof reaches constructed
  cache tables, SHA, mixers and each recursive constructor. It establishes
  successful-output scope, not root contents or valid-value root totality.
- `progressive`: independent subtree slicing and FIPS hashing; actual tree
  refinement, all-input traversal sufficiency, exact chunk-domain acceptance and
  32-byte byte-range output. No fixture or machine-size bound is assumed.
- Generic schema validity, nested codecs, root composition and typed adapters are
  implemented and typechecked, but do not yet have universal composed refinement.
  Decoder and compatibility traversal bounds still need sufficiency proofs.

## Named inventory

All 109 names now have usable definitions/APIs in `types/fulu.bend`, generated
from frozen metadata. All 59 containers are concrete typed records. Four vector
aliases and Transaction are included, with exact nested definitions. Runtime
tests compare all schemas and named API exports to frozen inventory.

Retained named proofs cover the 21 primitives and 24 byte identities.
`fulu_list_inventory` now adds Transaction through its closed symbolic inventory,
proving domain, serialization, decoding soundness/completeness, exact rejection,
independent root refinement, valid-value root totality and 32-byte output scope.
Its named wrappers directly call those inventory APIs. Keeping the identity
symbolic avoids expanding the billion-byte capacity during checking; the frozen
capacity is unchanged. No premise restricting values was added.

The new unified `types/fulu.bend` typed adapters still need their own composition;
the retained named proofs do not automatically cover that separate dispatch path.

## Completion obligations

Complete independent generic type/value, encoding/decoding and root semantics;
prove layout encoding-image equivalence, nesting, canonical rejection and root composition;
discharge every public invariant; prove adapter transport and all 109 named
identities; provide all five END_TO_END laws; pass every official case and frozen
acceptance; repeat full independent audit. Current finite checks and partial
proofs establish none of those missing universal claims.

Additional checked refinements: fixed-size classification and option lookup
(`schema`), sequence counts (`codec_count`), and cached ordinary/progressive
Merkle APIs (`cached_tree`). Cache-table invariants are constructed for arbitrary
cache size, and misses use the existing zero-subtree function at arbitrary depth.
The independent recursive codec transcription is present for legal schemas;
serialization refinement under actual type validation is checked; equivalence
with independent type legality remains unfinished.

## Iteration 0005 checked additions and precise limits

- Independent legality covers every schema constructor; compatible Merkleization
  uses finite derivations rather than runtime fuel. `type_legality_structure`
  derives the codec's forest invariant from this judgement. Equivalence with
  the actual type validator is still unproved.
- `schema_forest`, `codec_accumulator` and `codec_composition` prove recursive
  actual encoding refinement under actual accepted-type validation. Malformed
  forests are not covered by an unconditional accumulator equality.
- `layout_bounds` bounds every returned child slice by the parent input length.
  `decode_soundness` proves accepted values belong to the independent canonical
  encoding image and that inputs outside that image are rejected. The converse
  and decoder fuel sufficiency remain unproved.
- `root_relation` independently defines recursive root contents. Cached Merkle
  and byte/bit leaf operations have checked soundness/completeness against it.
  Generic recursive root refinement and totality remain unproved. The explicit
  value-domain specification exposes the uint256 mixing-length obligation.
- All 109 unified adapters have typed-value inverses and accepted-value
  representation preservation. They accept every corresponding structural shape
  after proof-only erasure of irrelevant size metadata; a universal erasure
  theorem preserves the original shape. Closed named encoding/decoding/root
  composition and exact-schema proof specialization remain unfinished. Two
  normalization-limited candidates are kept only in build/, outside PROOF.

The official runner now uses Bun's lower-memory mode, with no retries or relaxed
comparisons. Three fresh independent-process probes of the reported crashing
case passed exact official comparisons. The completed worker run passed every case, including batch 126. All five failure/interruption regressions pass. Reports
have content-addressed archives and provenance; earlier unavailable reports are
not recreated or treated as current evidence.

All 109 actual named schemas have checked independent legality witnesses and
actual-validator acceptance laws (`fulu_legality`). The closed symbolic inventory
in `fulu_serialization_inventory` proves actual generic serialization against
independent encoding at every named schema for all generic values, with the
validator premise discharged. It does not yet prove typed-wrapper composition or
the universal equality to the separately frozen schema transcription.
`normative_encoding` also proves internal actual encoding refinement for every
independently legal schema and public rejection of independently invalid values.

## Iteration 0006 additions and current limits

The root checker now includes validator metadata refinement, independent/runtime
field-position agreement, named-field validator soundness and completeness,
active-slot bounds derived from public validity or normative legality, actual
identity soundness, compatibility fuel monotonicity for all four public-path
modes, and the Null/Named slot-forest invariant established by active expansion.
These are universal prerequisites; they do not yet prove complete type-validator
equivalence, sufficient traversal budgets, or the missing end-to-end laws.

Fresh iteration-0006 checks: root checker passes; 49 runtime tests pass with
18,585 assertions; all 5,440 frozen inventory paths and hashes verify. Full
spectests and acceptance were not rerun this invocation. The immutable
iteration-0005 all-case report remains separately identified historical evidence.

## Iteration 0007 ongoing work

The expanded root checker passes with actual type-validator soundness for all
constructors, both directions of selector validation, and checked compatibility
budget stabilization derived from independent legality. The reverse type-validator
implication and independent compatibility-derivation completeness remain open.
Identity comparison agrees with the independent semantics on public schema
representations. Proof-only byte-alias normalization preserves the independent
identity decision and establishes identity substitution and transitivity.

Decoder traversal sufficiency is now proved. `decode_stability.public_budget`
establishes full result equality under arbitrary added fuel at the actual public
budget, with forest shape derived from public validation. Actual layout decoders
and option selectors supply the recursive bounds. `decode_budget.accepts_finite`
moves any finite successful raw traversal to that public budget;
`finite_unique` proves exact raw-value uniqueness across successful budgets.
These laws do not assume codec correctness or restrict mathematical input sizes.
Canonical encoding-image completeness, its inverse-layout prerequisite, and
independent decoded-value uniqueness still require proof.

The runtime suite passes 49 tests and 18,585 assertions. The new official run and
transport regressions are still running. No full acceptance claim is made;
END_TO_END.bend remains absent.
