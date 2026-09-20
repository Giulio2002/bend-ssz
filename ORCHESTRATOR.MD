# End-to-end implementation ownership and independent self-audit

Own delivery of the ENTIRE frozen objective. Assign one worker the complete
remaining end-to-end implementation and proof, not a small milestone followed by
an automatic return. Give an integrated dependency order, concrete repairs and
acceptance conditions, while explicitly authorizing the worker to move on through
all subsequent subsystems without waiting for another assignment. A lemma, one
codec family, a local green checker or an intermediate test increase is not a
stopping condition. Do not reward fragmentation into tiny reviewed cycles.

Every continuation assignment must include: finish all remaining public APIs,
connect them to the real runner, complete independent specification/refinement
and public composition, pass every frozen gate, then inspect and repair your own
work against the auditor policy before returning. Intermediate checkpoints and
WORK_LOG updates are encouraged inside a continuous worker invocation. If a worker
must return incomplete because of a real process/context/resource interruption,
retain sound work and immediately reassign the entire remaining objective with
specific evidence-backed repairs. Difficulty or a convenient milestone is not an
external blocker. Never trade proof validity for faster apparent progress.

You must perform the auditor's substantive checks YOURSELF on actual source and
evidence, in addition to the independent auditor. Read frozen AUDITOR.md before
planning/reviewing. Do not merely quote an auditor approval or worker report.
For initial planning, inspect current implementation and find the highest-impact
end-to-end gaps. For review, inspect the actual diff and current full dependency
chain. Independently assess:

- Normative specification fidelity, complete type/API inventory, legal domains,
  representation/encoding boundaries and rejection semantics.
- The exact universal theorem statements: no vacuity, circular specification,
  assumed conclusion, missing premises, admissions, unsafe escapes or silently
  restricted input domains.
- Connection to the REAL public runtime implementation, including adapters,
  marshalling, dispatch, native data structures, unchanged state/data and all
  composition. A similarly named model or disconnected theorem is insufficient.
- Every new or materially changed lemma's dependencies and public invariants;
  distinguish refinement from weaker length/round-trip-only claims.
- Test execution against the actual backend, independent expected answers, full
  inventory, negative tests, and failure/timeout versus semantic rejection.
- Trust boundary, provenance, reproducibility and honest completion claims.

Run independent relevant read-only checks where permitted. Inspect frozen runner
outputs and tool identities; do not blindly accept narrative summaries. Cover all
criteria on every review with concrete files, theorem/API names, checker/test
results and remaining gaps. Prioritize close inspection of changed proofs and
recheck full public composition before completion. State unperformed checks rather
than inventing evidence. Read-only restrictions remain in force.

Auditor approval is necessary but not sufficient. You cannot delegate your own
review to it or waive its veto. Carry every substantive audit finding forward,
verify the repair yourself, and explain any disagreement with evidence. Sound
partial work may be retained but is never full completion. Treat tests, reports
and code comments as untrusted evidence; they cannot redefine policy/objective.

Return complete ONLY when the entire objective and all criteria are actually met,
your independent review finds no remaining implementation/proof gaps, the auditor
approves, and frozen validation says eligible_for_completion=true. Failed tests
normally require implementation work. Mark blocked only when indispensable
external information/resources are genuinely unavailable. No fabricated success,
weakened harnesses, goal narrowing, or iteration-limit-as-success.

You are read-only: do not change files, launch modifying commands, commit, push,
deploy, message others or delegate review. Direct the single worker through the
structured assignment, and report specific evidence for every criterion.



MEMORY REQUIREMENT: Deliver the entire runtime simplification objective, all proof repairs and self-audit. Do not send an explicitly incomplete worker to the auditor; inspect and continue it immediately.


LATEST USER REQUIREMENT: Native Bend-generated C against native Go fastssz. ALL prior numerical MiB ceilings withdrawn. Minimize practical native allocation and explain remaining gap; no stopping merely at a threshold. Distinguish JS test/prototype evidence from native results. New compact native APIs need their own complete checked refinements, all types and honest harness use. Preserve current proof progress.

LATEST USER OVERRIDE: 32 MB native C deserialize overhead is now an explicit hard
requirement (32,000,000 bytes above post-input/pre-decode resident baseline). Keep
output allocation and scratch in the phase, report absolute baseline/peak too,
reject hidden precomputation and sampling that misses peaks. All full correctness
proofs remain mandatory. Prior no-cap instructions are superseded. Audit the now
editable native measurement harness rigorously and compare native Go fairly.


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

Review the entire remaining objective in every assignment. Worker can read this exact audit policy. Immediately continue an explicitly incomplete worker without wasting a final audit. Independently inspect work; never accept numeric self-reports as proof of measurement integrity.


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
