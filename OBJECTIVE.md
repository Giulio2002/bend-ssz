# Minimize native Bend C SSZ memory against native Go fastssz

USER CORRECTION: This project compiles to C. Optimize and benchmark NATIVE C,
not Bun/JavaScript. The previous 512/256/128 MiB targets are withdrawn. The user now explicitly requires 32 MB deserialization overhead on native C.
User requests memory as low as practically possible, like Go. Retain the formal correctness proofs while meeting the native overhead requirement. Preserve all useful existing code and proofs.

```toml
name = "SSZ / NATIVE C OPTIMIZATION"
project = "/Users/monkeair/work/ssz-optimization/project-array-native"
validation = [["/Users/monkeair/work/fulu-bend/.venv/bin/python", "automation/native_memory_acceptance.py"], ["/Users/monkeair/auto-implementer/.venv/bin/python", "automation/performance_gate.py"]]
editable = ["tools/bend_loader.ts", "tools/run_runtime_tests.py", "tools/spectests.py", "tools/primitive_backend.ts", "tools/generic_transport.ts", "benchmarks/*", "BENCHMARKS.md", "src/*", "types/*", "proofs/*", "tools/generate*.py", "PROOF.bend", "END_TO_END.bend", "ROOT_DOMAIN.bend", "MEMORY_REVIEW.md", "README.md", "WORK_LOG.md", "docs/*", "native_bench/driver.bend", "native_bench/helpers/*", "native_bench/run.py", "native_bench/fastssz/main.go"]
protected = ["automation/*", "spec/*", "vendor/*", "schemas/*", "tests/*", "fixtures/*", "fixtures.manifest.json", "cases.json", "upstream.lock.json", "tools/test_schemas.py", "tools/run_evidence.py", "memory_bench/*", "native_bench/fastssz/go.mod", "native_bench/fastssz/go.sum"]
ignore = ["build", "build/*"]
max_iterations = 0
validation_timeout = 14400
agent_timeout = 0
orchestrator_timeout = 0
backend = "claude"
model = "claude-opus-5"
orchestrator_model = "claude-opus-5"
claude = "/Users/monkeair/.local/bin/claude"
claude_effort = "medium"
[criteria]
performance = "Native deserialize/serialize workloads <=5x and hash_tree_root <=10x Go fastssz; full operation coverage, independently audited optimized references, raw reproducible samples, no missing evidence."
architecture = "Simplify native data flow and representation; eliminate avoidable full copies and intermediate value trees. Schema-driven direct typed codegen with checked compositional proofs is encouraged. Reassess JS-specific tricks on native C before keeping them."
memory = "Minimize actual native C process memory and allocation, benchmarked against native Go fastssz on identical inputs. Native decode overhead must not exceed 32,000,000 bytes on any frozen-fixture sample; compare Go as well. Report the remaining ratio and evidence-backed representation/runtime lower bounds; no completion just because a previous threshold was crossed."
proofs = "Keep every existing END_TO_END law proposition byte-for-byte, repair proof bodies as needed, and prove the actual new runtime paths equivalent to the independent SSZ specifications. Zero unsafe annotations."
coverage = "All 109 Fulu mainnet types, generic supported SSZ forms, unchanged SSZ semantics; compact primary APIs with legacy signature compatibility adapters, all 51 runtime tests and all 5440 official SSZ tests."
review = "Independent semantic and architectural audit, including malformed inputs, memory measurement honesty, proof linkage and maintainability."
```

## Entire objective

Complete the whole implementation, proof repair, native measurement and self-audit
in one continuous worker assignment. Preserve existing walk/decoder work as useful;
do not restart the mathematical work from zero. Current candidate is UNVERIFIED:
new decoder type-checks but existing end-to-end proofs have not been repaired.
Finish them. The resumed Claude session contains the prior exploration.

1. Build the actual named Fulu API through pinned Bend 2.0.16's native C backend.
The initial native harness is native_bench/driver.bend. First compilation reported
"a constructor outside its layout: ../types/fulu.BeaconState". Diagnose/fix the
source/API/harness integration; inspect build/native/build.log in the project seed
if present. Do not silently switch back to JS or patch the trusted compiler/Base.
The Go comparator is pinned to fastssz v0.1.4 / go-eth2-client v0.27.2.

2. Establish native baseline and candidate on identical fixture bytes with real
OS peak RSS, allocation/live-state evidence and sequential timings. Compare like
workloads: the fixed current native harness measures whole-process read/decode/
serialize/write peak RSS and separately decode-only duration. Its peak is NOT
isolated deserialization; report this explicitly. Add phase profiling as needed
without moving real work out of the measurement. Compilation is excluded. No
forced GC, allocator/RSS accounting tricks, foreign SSZ implementation, cached
answers or fixture recognition. No parallel public decode calls. Use all five
BeaconState fixtures, repeat/alternate with Go, validate every output byte.
A smaller Go RSS alone does not prove an exact feasible floor for Bend; investigate.

3. Simplify the native runtime as far as practical: compact byte and primitive
representations, shared input ranges/cursors instead of copied sublists, direct
schema-generated typed construction, structural validity instead of serialize-to-
validate, bounded temporary allocation and streaming serialization/merkleization.
Keep only JS-motivated block/trampoline tricks that also help native execution.
Native Array is a tree, not automatically a packed byte buffer. Native C compilation
does not automatically turn a linked list into a packed array. Inspect emitted C
and native allocation behavior before making claims.

4. Retain all existing public APIs/signatures as compatibility surfaces. If their
representations prevent Go-like memory, a compact preferred native API is allowed,
but it must be the real documented supported API, cover ALL 109 types, have fully
checked independent semantic refinements and named compositions, and be used by
the native harness via minimal audited plumbing. Old proofs do not automatically
verify the new API. No separate unproved benchmark-only fast path. The generator
itself need not be trusted if Bend checks every generated proof. Avoid duplicated
handwritten per-type algorithms/proofs; use reusable verified primitives.

5. Every original END_TO_END proposition remains exactly intact; proof bodies may
change. All original 51 runtime tests and all 5440 spectests remain mandatory as
compatibility evidence. They currently execute JS and must not be mislabeled as
native coverage. Add native correctness coverage for changed paths, including
malformed input, bounds, offset/canonicality cases and real fixture roundtrips.
Every new native-facing API requires implementation-connected proofs and checked
composition, no admission/axiom/unsafe/changed compiler. Keep the independent specs
frozen. SHA remains upstream c16cd69cedff0e9e19251401dee1cd973458faef, unchanged.

6. Explore and measure the meaningful architectural allocation reductions, then
report residual memory by source (input, output, intermediate, allocator/runtime).
Do not declare completion solely from a small local gain or any previous MiB cap.
Demonstrate that remaining gap versus Go is understood and that practical major
reductions have been implemented or ruled out with evidence. Independent auditor
must assess this honestly. Go-like memory is a goal, not a fabricated guarantee.
Report native serializer and root peaks too; preserve all original semantics.

There is ONE SSZ workflow. The prior root-domain worker is stopped. Its current
source and proof changes are merged into THIS candidate. Root correctness is part
of the optimization's non-regression contract, not a separate project. Preserve
structural root validity without whole-parent serialization requirements, all
old serializable-root compatibility, and the broader-domain witness. ROOT_DOMAIN
is imported by PROOF and checked by the unified acceptance gate. Finish its pending
proof repairs together with the cursor decoder changes. The merged END_TO_END
propositions are frozen; the pre-correction declarations remain archived in
memory_bench/law-statements-pre-root-correction.json for the semantic audit. No
codec or rejection guarantee may be lost. Treat the merged candidate as UNVERIFIED
until the full integrated native/proof/conformance gate and audit pass.

Prior root worker reports: updated runtime passed all 5440 spectests and 51 tests;
full_root_correct and serializable_root_compatibility checked. Last work focused
on the symbolic broader-domain witness and auditing hidden serialization gates.
Its WORK_LOG is appended to the combined WORK_LOG. The root candidate and native
candidate were merged against the root source; 27 changed files integrated without
conflicts. This is preserved work, not evidence the combination already passes.

Current preserved source derives from interrupted run 20260919T191523Z-f913a588,
iterations/0001/workspace. Its build/ directory remains available read-only there
for experiments and logs. New native baseline takes priority over interpreting
those JS figures. Record architecture, source proof scope, comparison methodology,
raw evidence and remaining gaps in MEMORY_REVIEW.md. Do not publish or merge.

## Consolidation provenance

Native candidate: /Users/monkeair/work/ssz-memory/runs/20260919T203135Z-a45176d2/iterations/0001/workspace
Root candidate: /Users/monkeair/work/ssz-root-domain/runs/20260919T184030Z-63199378/iterations/0001/workspace
Read their build/log directories as needed. Both former workers are stopped; do not
restart them. Keep one ongoing optimization worker and one combined acceptance.
No need to repeat already-completed architecture exploration or reset sound proofs.

## Latest explicit user requirement: 32 MB native C decode overhead

This supersedes earlier no-fixed-cap wording. The user requires **32 MB of overhead
when deserializing in native C**, with formal proofs retained. Use 32,000,000 bytes
(decimal MB), not 32 MiB. No JS/Bun result counts toward this requirement.

Operational definition: additional resident memory during the complete native
deserialize API, above process RSS immediately after loading/preparing the input
and BEFORE any decoding/validation work. Include decoded-state allocation and all
temporaries. Report baseline RSS, peak RSS during decode, overhead, retained state
and whole-process roundtrip peak separately; never hide a large input representation
by omitting its baseline size. Keep the output live until the measurement completes.
No pre-decode, forced GC, mocked metrics or native work shifted outside the phase.
Do not use whole-process roundtrip RSS as though it were the decode-phase peak.

The native benchmark harness needs real phase-specific OS/allocator instrumentation
for this definition. It is now explicitly editable to implement that machinery;
the independent auditor must inspect it and cross-check OS peak measurements.
A sampling-only estimate that can miss spikes is not sufficient for the hard cap.
Do not patch the trusted compiler or SSZ algorithm in emitted C. Instrumentation
may be host harness plumbing only, clearly separated from the proved Bend code.
Each Bend sample in build/native/comparison.json must include baseline_rss_bytes,
decode_peak_rss_bytes, decode_overhead_bytes=max(0,peak-baseline), and verified=true.
At least three samples on each of the five identical fixtures; all must meet cap.
Go uses the same workload/boundaries. Continue minimizing practical allocation even
when under cap, but do not promise theoretical optimality.

Full existing and new-path formal correctness proofs, all 109 types, all 51 runtime
tests, all 5440 spectests, native correctness and independent audit remain required.
Memory results are measured resource evidence, not themselves a universal formal
memory-bound theorem. Do not conflate those claims. This is still ONE SSZ job.


## Native performance release contract — latest user requirement

This extends the existing whole objective; all implementation, proofs, conformance,
mutation and audit requirements remain. Preserve the seeded work and session.
First accepted versions MUST satisfy native codec runtime <=5x and hash_tree_root <=10x Go fastssz
for EVERY required operation/workload, not just an aggregate. Performance is a
measured acceptance condition, not a proved universal timing theorem. Do not
claim current work meets it without fresh comparable evidence. No partial
checkpoint is completion. Continue all missing implementation + proofs + native
benchmarks + optimization + self-audit in each assignment. No arbitrary worker
four-hour cap or planned checkpoint exit; earlier prose to that effect is superseded.

Implement benchmarks/run.py --report PATH, and BENCHMARKS.md with a reproducible
command and tables for ALL operations in automation/performance_contract.json.
That contract and automation/performance_gate.py are frozen operator-owned gates.
Read the gate to follow its exact report schema. Add workload sizes, seeds,
valid/invalid cases where applicable and realistic representative larger cases;
the listed operations are the MINIMUM, never permission to omit other public APIs.
Benchmark small/medium/large nonempty workloads for each scalable operation and
edge cases separately. One smoke-sized fixture or a mixed average is insufficient.
DSA includes reused LRU in these benchmarks; no separate LRU worker is needed.

Build BOTH sides optimized in release mode on the same machine; Bend must use its
native C backend, one sequential execution thread. No Bun/JS result qualifies.
Create genuinely optimized C implementations of the SAME DSA algorithms with
identical semantics, numeric domain, representation choices and workloads. C may
use normal efficient memory management; never deliberately penalize the reference.
BLS uses pinned upstream blst C with its normal optimized assembly enabled where
supported; match Ethereum POP domain, input validation, subgroup checks and
aggregation/security semantics. C/blst are benchmark references ONLY, never foreign
runtime replacements for the proved Bend algorithms. SSZ uses pinned Go fastssz,
not a C SSZ library; its codec maximum is 5x and hash_tree_root maximum is 10x. All 109 Fulu types need serialize,
deserialize and root comparisons, with generated fastssz definitions where needed.
Start SSZ with the five existing BeaconState cases; preserve the separate native
32,000,000-byte decode-overhead gate and all proofs. Add representative larger
states as supplemental evidence, clearly distinguishing synthetic from production.

At least five alternating independent samples per workload, calibrated enough to
avoid timer quantization; include repeated batches for tiny operations and record
operations per sample. Input generation, compilation and unrelated file IO excluded
from operation timings symmetrically. Include required validation/allocation and
consume all results; no precomputation, cached answers, fixture detection, omitted
checks or dead-code-eliminated calls. Preserve raw timing logs and output checks;
record exact sources, reference pins, compiler versions/flags, CPU/OS, executable
hashes, operation definitions and sample counts. Reference times must be positive.
Do not hide bad workloads with geomeans. Report medians and individual samples;
each workload median ratio must meet the limit. Audit noise, variation and rerun
borderline cases under controlled conditions before final acceptance.

The runner must freshly build and execute measured programs; honor no skip-build
flag in acceptance. Report current source_sha256 for all candidate runtime/proof/
benchmark inputs, artifacts with raw logs/executable hashes, and correct outputs.
The numeric gate cannot prove honesty of a worker-authored runner: the independent
auditor MUST inspect harnesses, C reference quality, workload coverage, proof linkage
and reproduce timings before accepting. Missing native compiler support is a real
blocker to report and fix in source; never silently substitute JS or patch a trusted
compiler. Keep implementation simple and reusable; do not restart proven mathematics.


## Latest user correction: separate codec/hash limits; NO hardware SHA

Native deserialization <=5x Go fastssz; native serialization/encoding <=5x Go
fastssz; native hash_tree_root <=10x Go fastssz. These limits apply to each
required workload and all 109 types; no average may hide failures. The frozen
performance contract maps exact operation identifiers to their limits. Extra
operations default to 5x and may not be mislabeled to evade their proper limit.
The existing 32,000,000-byte native decode-overhead limit is unchanged.

The user explicitly rejected adding hardware acceleration. Do NOT add hardware
SHA, foreign accelerated crypto, compiler intrinsics or a changed compiler. Keep
the pinned upstream pure-Bend SHA implementation and the existing formal proof
requirements. Do not weaken proofs or claim microbenchmarks establish impossibility.
Continue the entire existing scope from this preserved candidate and session.
No work is accepted simply because it was copied into this run.

## Operator revision: compact public API, 2026-09-20 (takes precedence)

The user explicitly authorizes redesigning the primary API and its storage types.
The previous unchanged-public-signatures constraint applies ONLY to optional legacy
compatibility adapters. It MUST NOT force compact results back into linked byte lists.
Continue the preserved implementation and proof work; do not start over.

Deliver the entire change end to end:
* Make packed bytes/native buffers and compact decoded values the documented primary
  public API for all 109 Fulu mainnet types and supported generic forms. Expose usable
  field access/iteration and input lifetime/ownership semantics. Inspect generated C.
* Decode directly from packed storage; preserve byte slices where valid. Encode and
  hash_tree_root consume compact values directly, without routing through T.Value,
  CValue.to_value, byte-per-cons lists or whole-tree materialization. Encode returns
  compact bytes. Use bounded scratch space and streaming Merkleization where useful.
* Keep legacy byte-list entry points as explicit compatibility adapters so original
  tests and frozen END_TO_END propositions remain valid. Prove the new PRIMARY public
  operations against the independent specs, including rejection/completeness, exact
  encode/decode round trips, root equality, and representation/adapter bridges.
  Existing proofs of adapters alone do not verify the primary path. Repair all current
  undefined decoder lemmas; no holes, unsafe, weakened premises or axioms.
* Benchmark the actual primary API against Go fastssz with equivalent starting and
  ending representations and forcing. Report buffer-ready decode separately from
  input conversion and end-to-end ingestion. Include required validation, allocation,
  output construction and realization. Do not hide required work in setup or add a
  Bend-only traversal without reporting and matching it. Packing from a legacy list
  is an explicit compatibility cost, not the default fast path. Benchmark encode,
  decode and hash_tree_root consistently; no mixing different Go denominators.
* Keep every required operation and workload, all 5440 official tests and 51 runtime
  tests. Add meaningful compact-path checks and exact-output comparisons; legacy-only
  spectest success is insufficient. Keep the pinned compiler/Base/spec/vendor intact.
* Targets unchanged: <=5x Go for decode and encode, <=10x for hash_tree_root, <=32,000,000
  bytes native decode overhead on every fixed-fixture sample. Frozen automation and
  thresholds stay protected; editable benchmark drivers must invoke the primary API.
* First expose and integrate the existing fast packed decoder; then complete compact
  encode/root and missing proofs. Use targeted measurements between edits; run the
  full suite at meaningful milestones, not repeatedly without implementation changes.
  Give the worker ALL remaining obligations at once. An incomplete checkpoint goes
  straight back to the worker with the remaining work; it is not completion.

Evidence at restart: compact BeaconState decode 24-27 ms versus legacy public API
230-256 ms under different harnesses. Do not assume these are directly comparable
or a proven speedup. Build one honest matched comparison. Full proofs are currently
broken; preserve and repair them. Read WORK_LOG.md and MEMORY_REVIEW.md.

## Final operator correction: no linked-list runtime representation

There must be NO linked-list representation in the primary production SSZ path:
not input storage, chunk storage, decoded vectors/lists, container fields, schemas
walked at runtime, encode output, hash chunks or Merkle scratch state. The current
Packed linked chunk chain and CValue child lists are intermediate designs, NOT the
final architecture. Use native packed arrays, indexed arenas, fixed records and
array-backed sequences throughout. Inspect emitted C to confirm indexed storage.
Avoid linked-spine lookups, hidden materialization and per-byte boxed cells.

The user also withdraws the request to retain public linked-list compatibility
APIs. Remove these from the production API. Lists may remain only in independent
mathematical specs, proof models or test-oracle adapters outside measured/runtime
paths. Preserve the original semantic obligations; representation-dependent law
signatures may be migrated to array observations with explicit equivalence bridges,
never weaker premises or omitted cases. The old byte-for-byte law snapshot and
legacy test adapter restrictions are now superseded ONLY where the representation
change requires it. First document an exhaustive old-to-new law/API map; the
orchestrator must inspect each translation and require the independent auditor to
check non-weakening. Adapt boundary test transports without changing official test
vectors or expected outcomes. Do not edit benchmark thresholds, pinned compiler,
Base, cryptographic dependencies or independent mathematical SSZ definitions.

The whole library, all 109 types and generic forms, must use the new public design.
No alternate fast demo while the main API remains list based. Specs must prove
actual array-indexed operations and all existing malformed-input/round-trip/root
obligations. Zero unsafe/axioms/holes. All original official cases must still run
through the new primary API and pass. Keep native 32 MB overhead and 5x decode,
5x encode, 10x root speed limits. The full implementation and proof migration is
one assignment; do not stop at a partial checkpoint knowingly leaving work open.


# User-authorized SSZ object API requirement — 2026-09-21

This replaces the earlier deferral and overrides acceptance of view-only decoding as the primary API. Preserve existing implementation and proof progress; reuse it where valid.

Deserialization must return a typed, owning Fulu object, equivalent in observable behavior to fastssz UnmarshalSSZ. Serialization consumes/reads that object and produces fresh canonical SSZ bytes. Provide the concrete fields and indexed collections for every one of the 109 required names (including aliases), with field updates and list appends within SSZ bounds. Use packed native arrays for arrays/bytes, not linked-list representations. An untyped raw buffer plus Bool, or offset/length view requiring the caller to supply arbitrary storage, is not the primary decoded object API.

Own storage and preserve input isolation: input may be consumed by ownership transfer; if the caller retains an independent input copy, changing it must not change the decoded value. Expose ordinary typed scalar fields and owned indexed collection values; internal views are allowed only when ownership and validity are enforced by the API, never an escape from producing the required typed object. Mutation must preserve other fields and valid object invariants. Structural edits must not leave usable stale child offsets. Appending past list bounds must be rejected. Efficient updates may consume and return the owning object under Bend's affine rules. Do not assume a public record wrapping a mutable raw buffer proves immutability or isolation.

Prove the actual object decoder/encoder against independent SSZ semantics, representation and ownership boundaries, decode/encode roundtrips, field access/update and bounded append correctness. Explain the trusted compiler/runtime ownership assumptions; a theorem about a scanner or model does not prove object construction or runtime alias isolation. Add compiler-negative ownership misuse checks and runtime mutation/isolation regressions as evidence, clearly distinguished from universal formal laws. Preserve all existing laws, coverage and sound reusable proof modules; no unsafe/admitted proofs or narrowed domains.

Benchmark the real object API against fastssz: bytes -> fully constructed typed object; object -> fresh bytes; root of the object after mutations as well as decoded input. Include allocations, necessary copying and materialization in the timed region. Consume actual outputs and check full bytes/roots; never substitute validation-only or cached-byte copying for general object codec performance. View-only numbers may remain clearly labeled historical/optional API diagnostics and cannot satisfy object performance acceptance. Provide construction and mutation/append tests and representative benchmark evidence. Preserve the original Go reference, workloads, <=5x codec and <=10x root targets, <=32,000,000 byte decode overhead definition, proof memory ceiling, stock Bend, no FFI and pure-Bend SHA requirements. Do not relax limits to make object construction pass; report conflicts honestly.

Continue the entire remaining objective, not just the API change. Self-audit using AUDITOR.md and actual fastssz behavior before claiming completion. Refresh all native performance, memory, runtime, official conformance and proof evidence for the new public implementation. Existing view-only speed acceptance does not establish this new criterion.

# User-authorized schema-driven generation and cached object roots

Effective immediately: switch SSZ development toward a schema-driven generator. This supplements the owning-object requirement and supersedes the prior decision to defer it.

Input: a readable YAML schema describing all 109 mainnet Fulu names, aliases, fields, order, primitive widths, vector lengths and list/bit limits. Pin mainnet constants and independently compare the schema inventory with the frozen consensus specification. Keep normative spec/* and frozen schemas/* unchanged. Put generator input and implementation in codegen/, outputs in types/, src/ and proofs/. Implement generation in stock Bend where practical: an ordinary Bend program without correctness laws may generate source containing checked laws. Provide a small reproducible CLI from YAML to generated sources; explain any host-only YAML parsing/build boundary. No foreign runtime implementation of SSZ, Merkle hashing or collections.

Generate concrete typed owning objects, specialized decode/encode/access/update/list-append/root implementations and compositional proof declarations/terms. Generate actual checked proofs, not law-name stubs or assertions. Share reusable verified primitives to avoid enormous repeated proof graphs. The unproved generator is not a correctness oracle: all emitted theorems must check with stock Bend, without unsafe, axioms or admissions, against an independent canonical SSZ specification. Do not generate the implementation and its supposed specification from identical algorithm code and call self-agreement correctness. Explicitly establish YAML-schema correspondence to independent pinned Fulu schemas. Deterministic regeneration must reproduce checked artifacts; malformed/unsupported YAML must fail clearly. Mutation checks must demonstrate wrong offsets, limits, field ordering or invalidation are detected. Do not trade runtime speed for easier proofs.

List-of-object roots: maintain packed indexed cached element roots and a Merkle tree with dirty tracking or equivalent. Updating element i recomputes the changed element root as needed and only the affected ancestor path, preserving unaffected subtree caches. Account for SSZ list limit depth, zero subtrees and mix-in length. Append must update affected leaf/path and length mix-in; handle allocation growth without claiming all appends worst-case O(log n). New objects/first roots may require full construction. Expose mutations through the owning API so mutable aliases cannot silently leave stale roots. Prove cached root equals independent uncached SSZ hash_tree_root after arbitrary supported mutation/append histories; prove unchanged elements preserved. Returning a previously cached root without mutation validation is not a valid benchmark.

Benchmark first root, warm root and roots after element updates/appends separately against honest equivalent reference operations. Report cold construction cost, retained cache bytes and peak memory; keep <=32MB decode overhead and existing <=5x codec/<=10x root targets unchanged. Caches may be lazy to avoid allocating them in decode, but root allocation and retained memory must be disclosed. Preserve existing reference/workloads and add object/mutation/cache cases; don't replace old failing rows with easier ones.

Preserve all useful prior proofs and source; connect them to the new public implementation rather than deleting obligations. Finish entire implementation, generated laws, independent semantic audit, full conformance, object-aware native performance and memory acceptance. No early stop after generator scaffolding or one type; all 109 required names and supported generic forms remain in scope. Continue through the full objective and self-audit using AUDITOR.md.


# User-required mutation proofs and linear complexity — 2026-09-21

All existing fields of returned typed SSZ objects must be editable, including nested fields and collection elements, subject to SSZ type/range/length constraints. Owned mutation APIs may consume and return the updated object under Bend affine rules. Retained independent copies must remain unchanged.

Lists support append while preserving their declared maximum length. Vectors support replacement of existing elements, but MUST NOT expose length-changing append, insertion or deletion. Byte vectors and bit vectors remain fixed length as well. Reject out-of-range indices, invalid scalar/bit values and list overflow without partial corruption of the original value. Do not expose raw mutable storage that bypasses invariants or cache invalidation.

Generate and kernel-check actual runtime-linked laws for: read-after-write; unchanged unrelated fields/elements; valid-domain preservation; nested update composition; repeated writes and independent-field update behavior; successful list append length increases by one with old prefix unchanged and new last value correct; list-bound rejection preserves state; vector replacement preserves exact length and rejection preserves state; encode/decode roundtrips after arbitrary valid update/append histories; input/copy isolation within the explicit affine compiler/runtime trust boundary; cached roots equal independent SSZ roots after arbitrary histories. Include negative type/API tests demonstrating no vector append capability, and finite mutation regressions in addition to universal laws. No axioms, unsafe annotations, assumed conclusions or narrower SSZ domains.

Complexity requirement: whole-object construction/deserialization, serialization and uncached hash-tree-root must have O(N) upper bounds, with N the serialized data size and the pinned schema/list-limit depths accounted for explicitly; where schema traversal contributes cost, state O(N + schema work) honestly. Do not label a generic arbitrary-limit operation O(N) while hiding a varying log(limit) term. Indexed scalar access/replacement should remain O(1) where supported; list append should be amortized O(1) storage growth with O(N) worst-case reallocation, and cached root maintenance should visit only changed element work plus O(log limit) ancestors. Variable-size field changes may require O(N) movement/serialization; avoid quadratic copying or rescanning during loops and batches. No requirement to slow sublinear operations to linear time.

Prove complexity of actual generated algorithms using a reviewable explicit cost model (reads/writes, traversals, allocated/copied words, hash compressions, and amortized growth as applicable). Bridge costs to the executed primitives; clearly state compiler/runtime allocation assumptions. Timings and source-code assertions are not formal complexity proofs. Distinguish proved bounds from empirical native performance, retain 5x codec/10x root and memory targets. Include scaling benchmarks as supporting evidence, not substitutes. Continue the entire existing codegen/object/proof/cache objective.


# Explicit user requirement: generated codec total correctness

For every supported schema S and valid typed owning value v, prove decode_S(encode_S(v)) succeeds with a semantically equal v (ignore nonsemantic cache contents/capacity). Consequently prove encode_S(decode_S(encode_S(v))) = encode_S(v) byte for byte. Also prove every accepted byte sequence b roundtrips exactly: encode_S(decode_S(b)) = b. SSZ is canonical for a fixed schema; do not silently normalize malformed input into an accepted value.

Prove decoder acceptance IFF there exists a valid value in the independently defined canonical SSZ encoding relation for S and b. Soundness: accepted bytes decode to that valid value. Completeness: every valid encoding is accepted (sufficient fuel/resources under explicit supported-domain assumptions). Rejection: every byte sequence outside that relation returns the specified error. Cover truncation, trailing bytes, fixed and variable sizes, first/monotone/bounded offsets, alignment and offset arithmetic overflow, list/vector constraints, boolean encodings, bitvector padding, bitlist delimiter/length, unions/selectors and all supported progressive forms. Do not call a finite mutation suite proof of all invalid encodings. Do not assume bytes or objects valid in the theorem whose purpose is to establish validation.

Encoder soundness and domain: valid objects produce canonical bytes; invalid representable objects (bad lengths, over-limit lists, invalid scalar/tag/bit values or inconsistent nested fields) return an error rather than truncating, wrapping or serializing invalid data. States rendered unconstructible by an enforced type/API invariant need an explicit invariant/construction preservation argument instead of an artificial runtime rejection law. Include direct callers and objects after field edits/appends. Invalid means invalid under SSZ/schema/API constraints, NOT invalid Ethereum signatures, state transitions or consensus rules. Allocation failure is distinct from malformed input and must not be disguised as validation rejection.

Generate compositional proofs for the actual emitted codec and connect to the independent spec for all109 Fulu names and supported generic forms; shared model self-agreement is insufficient. Retain mutation, ownership, cache equivalence and cost obligations. No unsafe/axioms/admitted holes, weakened domains or unchanged-output assumptions. Record exact theorem/API/schema coverage and assumptions. This requirement reinforces the existing roundtrip and validation objective; preserve current work and continue the entire objective.


# User requirement: all configurations and post-implementation fuzzing

All codec roundtrip, soundness, completeness, invalid-input rejection, object mutation, ownership, cache and cost obligations apply across the supported schema/configuration domain, not merely measured fixtures or selected generated types. Existing authorized scope is mainnet Fulu; clarification is pending whether the user's "all configs" additionally includes minimal/custom network presets. Do not silently narrow the schema domain or silently claim new presets are supported. At minimum cover all109 names and every supported generic SSZ schema/configuration, with explicit legality/representability assumptions and no arbitrary small test-derived proof bounds. A configuration outside the supported domain must be rejected explicitly by generation/config validation, not silently accepted with unsupported codec behavior.

After the implementation and proof integration are complete, run a substantial bounded differential fuzz campaign against independent canonical SSZ implementations/specs. Fuzz the configuration/schema parser and generated object API, not just the legacy scanner. Include seeded generated valid values and malformed bytes, nested containers/sequences/unions, offset/size arithmetic, bit encodings, empty/boundary/over-limit collections, vector fixed lengths, nested field writes, list appends and operation histories. Compare full encoded bytes, decoded semantic values and full32-byte roots (not only checksums), and compare cached roots against independently recomputed roots after mutations. Exercise copies/input isolation and rejection-state preservation. Use realistic bounded allocations; test impossible-to-allocate limits via boundary arithmetic/config rejection and proofs without claiming those large objects were fuzzed.

Use reproducible seeds, time/case budgets, source/toolchain hashes, native C execution and valid reference domains. Record corpus, coverage dimensions, actual executed case counts, crash/timeouts/mismatches and exact commands. Minimize failures, add permanent regressions, repair runtime and laws, then rerun affected proofs plus regression/full acceptance as appropriate. Fuzzing is bug-finding evidence, not a substitute for universal proofs or justification to claim every invalid input was enumerated. No completion before the final fuzz stage and its findings are resolved or explicitly reported. Keep frozen reference gates intact; add new fuzz files under the authorized tests_generated/ or codegen/ paths, and document scripts needed for reproduction.
