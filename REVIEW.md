> **Historical document.** This review describes the repository as of 19 September 2026 and is kept
> for provenance; its findings and figures are not maintained. Current coverage:
> docs/RESULTS.md and docs/PREMISES.md (figures generated from the artifacts); trust base:
> docs/TRUST.md.

# SSZ publication review — 19 September 2026

## Verdict

This is a substantial, real proof-carrying Bend implementation, with meaningful
public API refinement theorems and strong finite conformance evidence. It is not
merely a collection of tests called “proofs.” I found no explicit admission,
unsafe annotation, fixture lookup, or host-language replacement in the inspected
runtime/proof dependency graph. The five public obligations are implemented as
composed laws about the actual exported functions.

**I would publish it as a reviewed research library with explicitly scoped
formal guarantees. I would not label the entire executable product “100%
formally verified,” or recommend the present implementation as a performant
production SSZ backend.** The theorem/specification boundary, root domain,
compiler/runtime, host representation and operational limitations below matter.
The recovery workflow has now independently passed acceptance and recorded auditor approval and orchestrator completion. Private publication is a separate packaging action.
The optimization branch must preserve these guarantees, not manufacture faster
results by weakening them.

This review was performed by the interactive Codex agent itself, separately from
the worker's completion summary. It includes direct reading of the public laws,
public implementation linkage, independent specifications, selected central proof
compositions, normative reference text, named schema generation and runtime
harness; a complete import/declaration inventory; an independent AST comparison
of all named schemas; fresh proof/runtime checks; and hash verification of the
archived official test evidence. It is **not** a claim that every line of all
3,288 law bodies received a separate manual mathematical audit. Kernel checking
covers the reachable declarations; semantic review and specification transcription
remain human/tool trust boundaries.

## Snapshot and scope

The input snapshot is the recovered Bend 2.0.16 candidate from
`20260919T160942Z-d5d21daf/iterations/0001/workspace`. The exact path and initial
file hashes are in `evidence/review-20260919/snapshot.json`. Publication changes
are documentation, review utilities/evidence and packaging; codec/proof sources
are retained. The active implementation workflow and performance branch are
separate and may evolve after this snapshot.

- Consensus reference: v1.6.1, commit
  `5fa6edcca8ab4cf548653e6680b17b9d3e04d225`.
- Named domain: 109 mainnet Fulu SSZ names, including 59 container records.
- Tests: 295 mainnet/Fulu static cases over 59 tested names, plus 5,145 general
  SSZ cases. Not every named alias has its own static fixture.
- SHA dependency: the user's `bend-sha256`, pinned at
  `4690c56c2490dcf522a2bfbcdee3d2e177271692`. This identifies the dependency; it
  is not a claim that it remains GitHub's latest commit.
- Toolchain: Bend 2.0.16, with binary and Base SHA-256 in
  `automation/toolchain.json`. The older `bend: 2.0.5` field in
  `upstream.lock.json` is historical provenance, not the current checker.
- No consensus state transition, fork upgrade, BLS verification, KZG verification,
  network protocol or database correctness is established by SSZ proofs.
  BLS/KZG objects are serialized as their specified bytes, without crypto validation.

## Exactly what the public proofs establish

`END_TO_END.bend` imports `src/ssz.bend` and `types/fulu.bend`. The generic
`src/ssz` functions directly delegate to the runtime codec, decoder and root
modules. They are not separate reference implementations used only by proofs.
All statements below are mathematical statements in Bend's checked semantics.
They do not automatically transfer to every behavior of emitted JavaScript.

| Property | Actual checked claim | Preconditions / limits |
|---|---|---|
| Type-validator soundness | An accepted public schema satisfies independent `type_legality` | Public schema context; internal forest/helper constructors are handled separately |
| Type-validator completeness | Every independently legal schema is accepted by the runtime validator | Legality includes all relevant type/metadata constraints |
| Serialization | `serialize_correct`: public result equals independent `encoding_for_legal_type` for a legal schema | Equality is of `Maybe` results, including rejection; arbitrary schema/value inputs |
| Illegal-type serialization | Every value under an illegal schema is rejected | Illegality is represented as refutation of the independent legality proposition |
| Decode soundness | A returned value has the exact input as its independent canonical encoding, and its schema is legal | No arbitrary “decoder is correct” premise |
| Decode completeness | Every independently canonical encoding of a legal type is accepted as exactly its value | Not only previously accepted or tested inputs |
| Decode uniqueness | Two values of a legal schema with the same canonical encoding are equal | This establishes injectivity of that encoding domain |
| Exact rejection | The public decoder returns `None` exactly outside the canonical image for a legal schema | All bytes of illegal types reject as well; resource crashes are not `None` |
| Decoder traversal sufficiency | Finite successful traversals lift to the actual public fuel; successful results are stable/unique across sufficient fuel | Mathematical Nat arithmetic; no wall-clock or machine-overflow guarantee |
| Root soundness | Every returned root satisfies the independent recursive root relation and its schema is legal | The relation explicitly includes serializability |
| Root completeness | Every root admitted by that relation is exactly the public returned root | Legal schema; this is completeness for the stated relation, not an unstated larger domain |
| Root totality | A root exists for every legal-schema value satisfying `root_domain` | `root_domain` = independent serializability AND recursive uint256 length-mixer representability |
| Root representation | Successful roots are exactly 32 elements, each in byte range | Stronger than a list-length-only claim |
| Named Fulu composition | `fulu_types_correct` quantifies over every constructor of the closed 109-name index | Exact relation to the frozen schema constants; see external transcription boundary |
| Named serialization | Named public serialization equals independent serialization of the neutral representation | Bounds checked dynamically; constructing a raw record is not proof of validity |
| Named decoding/rejection | Named decoded values characterize the canonical image; adapter conversion does not silently lose valid decoded values | Inverse, preservation and shape-completeness lemmas compose here |
| Named roots | Soundness, completeness, 32-byte scope and domain-qualified totality carry through typed adapters | Same root-domain restriction as the generic theorem |
| Typed round trip | `from_ssz(to_ssz(v)) = Some(v)` for every typed value | Representation inverse; this alone does not assert the raw value satisfies SSZ bounds |
| SHA-256 functional refinement | Actual `src/sha256.hash` equals vendored independent FIPS byte-digest model | The transcribed FIPS model and pinned checker are trusted |
| SHA-256 output size | SHA byte API returns exactly 32 elements for arbitrary typed input lists | Root laws separately establish byte range where used |
| Nonvacuity | Concrete legal Boolean, encoded Boolean, accepted/rejected bytes, root-domain and named-type witnesses exist | Demonstrates real instances, not a proof of external specification faithfulness |

Central proof paths inspected include `codec_composition`, `decode_complete`,
`decode_inverse`, `decode_budget`, `root_public`, the root sound/complete/total
compositions, validator equivalence and the Fulu adapter/name compositions.
The recursive child codec, layout and traversal lemmas are connected to these
roots. `PROOF.bend` imports `END_TO_END.bend` and `HASH_PROOF.bend`.

## Why the decoder specification is meaningful

`spec/decoding_relation.bend` defines decoding by the canonical image of the
independent serializer, and rejection as the absence of any such value. It does
not define success as “whatever the implementation decoder returned.” This is a
legitimate inverse specification: the pinned SSZ document explicitly introduces
deserialization through injectivity of serialization.

The independent serializer recursively describes fields, children, fixed portions,
variable portions and little-endian offsets. Its layout computes the complete
fixed region, cumulative variable offsets and payload concatenation, including
the strict 2^32 serialized-length condition. The implementation uses its own
accumulator/layout/decoder machinery. The proof bridges the two.

The runtime decoder additionally reserializes decoded values and compares the
bytes for canonicality. That is real checked work inside the public API, not a
proof shortcut. It helps reject malformed encodings but is an obvious cost to
investigate. Removing it is acceptable only with a replacement proof establishing
the same exact soundness, completeness and rejection behavior.

The rejection theorem covers malformed offsets, unused or trailing bytes,
noncanonical bit encodings, invalid selectors and range/shape failures insofar
as they lie outside the independent canonical image. It does not prove a timing
bound or protection from memory exhaustion on malicious inputs.

## Root-domain qualification — material finding

The root relation is not independent of *serialization validity*: its top-level
`root_for_legal_type` includes existence of a normative encoding. The public
runtime also gates root computation on codec validity. The totality theorem
further requires every length mixed into a root to fit uint256.

The length-mixer condition is explicit and mathematically sensible. However,
blanket wording that these are simply “all valid SSZ values” needs care. The
pinned SSZ Merkleization formulas recurse over child roots for composite lists,
vectors and containers without first serializing the entire parent. A huge
composite object can satisfy type-level element/length constraints while failing
the serializer's whole-object 2^32 byte bound. The present public relation excludes
it by construction. I did not construct a multi-gigabyte runtime counterexample;
this is a directly visible specification/domain limitation, not a measured
small-fixture failure.

Accordingly, **full root correctness/totality is established on the explicitly
stated serializable/root-domain subset, not demonstrated for a broader
interpretation of every type-valid mathematical SSZ object**. The review does not
silently discharge that extra equivalence. A future full-domain claim needs a
separate independent type-value validity predicate and a proof of its relationship
to the root domain, or a consciously documented narrower API contract. This does
not weaken the exact decoding theorem for serialized byte strings.

## Fulu schema and typed-field review

I independently parsed the vendored Python reference with a restricted AST
interpreter for declarations, primitive aliases, constants, container fields,
vector/list/bit bounds and generalized-index branch lengths. It does not execute
Ethereum Python code and does not use the project's existing generator. Comparing
all 109 expanded schemas with the frozen JSON found no missing or different
schemas. Numeric string bounds were normalized to integers for comparison.

I also checked the declared field names/order of all 59 Bend container records
against that inventory. Existing runtime tests compare every independent Bend
schema constant against the JSON and verify the closed name index and public
serialization/deserialization/root aliases.

The formal name theorem quantifies over `Name`, whose schemas are shared
independent constants. It is not a formal parser proof from the Python reference
or SSZ prose into those constants. Shared constants avoid duplicated huge Nat
normalization and inconsistent bounds, but external transcription remains a
trust boundary. Two mutually inverse adapters alone could consistently relabel
same-typed fields; the independent field-order/transcription checks and official
value comparisons are relevant evidence against that mistake.

The schema extraction comparison is finite executable evidence, not a new
universal theorem. Exact scripts/results are under `evidence/review-20260919/`.

## Dependency, termination and unsafe review

The transitive `PROOF.bend` import graph contains 218 local Bend files and 3,288
`law` declarations, including the SHA dependency. There are no missing local
imports. Declaration count is inventory only, not a percentage-complete metric.
The reachable source scan found no non-comment `@unsafe`, `admit`, `axiom` or
`sorry` markers. A scan cannot prove soundness; the unmodified checker must also
accept the entire graph with zero unsafe annotations.

The earlier 110 unsafe annotations arose from five generic sequence helper
templates instantiated for 22 element types. The repair uses ordinary monomorphic
helpers and keeps adapter composition. Diagnostic reproducer files intentionally
contain the old template pattern but are not dependencies of the proof roots.
No compiler/Base change was made to suppress diagnostics.

Independent `spec/*.bend` imports do not point to implementation or proof modules.
Neutral data declarations and FIPS/spec functions are shared. This is useful
separation, not proof that the prose was transcribed perfectly. The review does
not certify the Bend kernel or Base's metatheory.

## Runtime and test-harness review

The TypeScript transport builds/deconstructs tagged Bend representations, converts
integer limbs and dispatches named/generic APIs. The actual codec and SHA work
remain Bend functions. The loader invokes the pinned Bend HTML bundler's own JS
library emitter and exports its result. Its cache key includes the compiler,
Base and workspace Bend source files, including vendor code. The accepted run
was repeated after repairing an earlier cache omission of vendor dependencies.

The official runner compares exact decoded values, serialized bytes and 32-byte
roots. Expected outputs stay in the Python comparator rather than becoming
implementation inputs. Invalid fixtures require semantic rejection; nonzero
backend exits, errors, timeouts and response-count mismatches fail the case.
The inventory is checked against all frozen fixture hashes before and after the
gate; missing/skipped cases cannot satisfy it.

Remaining limitations:

- Python, Bun, the loader, transport, emitted JS and compilation are not proved.
- Typed Bend proofs do not apply to arbitrary malformed JS objects that bypass
  the representation contract.
- Mathematical Nat reasoning does not prove correct execution beyond the
  runtime's documented 48-bit Nat/resource limits, nor prove absence of every
  intermediate overflow for all theoretical inputs.
- The runtime test adapter rejects empty runs, failures, errors and missing test
  files, but its historical 51/20,009 counts are printed rather than independently
  enforced as an immutable assertion count. Frozen test files and separate review
  are still important. A passing count alone would not prove meaningful tests.
- No exhaustive compiler differential test or formal compiler-correctness proof.
- No constant-time, memory-bound, worst-case complexity or denial-of-service proof.
- No global resource guarantee: a crash is a runtime failure, never a valid `None`.

## Evidence and confidence

The archived current-toolchain acceptance report records 5,440 passed and zero
failed cases. I verified all 136 source hashes recorded by that report against
the publication snapshot and independently verified the fixture manifest. That
report hashes runtime/type/harness sources; it is not by itself an exhaustive
proof-source provenance record. The review adds a hash manifest of the complete
reachable proof graph and reruns both proof roots on the publication copy.

Fresh publication-check results are recorded in `CHECKS.json`, with raw logs.
The transport regression suite initially failed because a clean copy lacked the
`build/` scratch directory. Creating the documented scratch directory and rerunning
resolves that setup failure; the initial failure log is retained, not hidden.
The separate implementation runner also finished a fresh full gate in 2,325 seconds with exit 0. Its log confirms 5,440/5,440 official cases and both proof roots. Its auditor approved with two low-severity evidence-label findings; the orchestrator marked the run complete. Those raw records are included alongside this independent review.

The official fixtures establish finite interoperability evidence, not universal
correctness by themselves. They cover 59 static names, while the named proof and
inventory cover 109 names. This difference is expected and explicitly reported.

## Quality and performance assessment

Strengths: pure Bend implementation; independent semantic modules; exact
canonical-image decoder contract; sufficient traversal arguments rather than an
unproved fixed recursion cutoff; all-name typed API composition; own verified
SHA integration; reproducible pinned inputs; meaningful negative transport tests.

Weaknesses: large generated proof surface and long validation cycles; heavy
list/limb/tag representations; repeated schema/byte validation and canonical
reserialization; an immature runtime integration path; machine-specific tool
paths; historical status contradictions; and very poor current large-record
performance. Proof checking establishes functional equations, not efficiency.

The isolated fastssz benchmark uses exactly matching Fulu BeaconState bytes/roots
and measures named APIs after setup. Its first 2.74 MB fixture measured roughly
6.67 seconds to deserialize in Bend versus 0.186 ms in fastssz. The figures are
preliminary shared-machine observations with significant variability, not a
controlled production-performance claim. The fixtures have 0–8 validators and
must not be presented as production BeaconStates with millions of validators.
No cached state-root shortcut was found in the Go comparison path.

The initial optimization target is **sequential full deserialization latency**,
with all public work inside the timed call and fresh input per invocation. No
parallel throughput, fixture memoization or shifted preparation is an acceptable
substitute. Each candidate must still pass full proof/runtime/official gates.

## Findings and disposition

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| R1 | Material scope limitation | Root totality/refinement is conditioned on the project's serializable/root domain, not proved equivalent to every broader type-valid-object domain | Clearly documented; not represented as universally discharged |
| R2 | Trust boundary | Compiler, JS runtime, loader/transport and finite machine arithmetic are outside the formal proof | Clearly documented; cannot claim literal whole-executable verification |
| R3 | Medium documentation | README and correspondence text retained conflicting historical “unfinished” claims; upstream lock still names 2.0.5 | README corrected; history separated/labelled; current toolchain authority identified |
| R4 | High usability/performance | Current BeaconState codec is orders of magnitude slower than the fastssz comparison on tested fixtures | Separate proof-preserving sequential-deserialization research; no production-speed claim |
| R5 | Medium reproducibility | Absolute local tool paths and external checker/Bun installation | Reproduction instructions and exact hashes provided; portable packaging remains follow-up |
| R6 | Evidence boundary | Existing official report hashes 136 runtime-related files, not every proof source | Added full reachable-proof manifest and fresh proof-root checks |
| R7 | Evidence boundary | Only 59 names have official static fixtures; 109 names are claimed | Independent full schema comparison, typed field checks and universal closed-index composition reviewed |
| R8 | Low setup issue | Transport regression tests require an existing build directory | Documented setup; initial failure retained and corrected rerun recorded |

No finding above is silently classified as “fixed” by passing tests. I found no
specific small-input codec mismatch during this review, but that is not a promise
that no bug exists. The honest release description is: **pure Bend Fulu SSZ with
checked, domain-qualified public refinement proofs and all pinned official SSZ
fixtures passing, subject to the documented specification and execution trust
boundaries**.
