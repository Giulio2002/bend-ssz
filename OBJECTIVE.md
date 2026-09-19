# Operator-authorized recovery on Bend 2.0.16

The user requested restarting this blocked SSZ workflow. The old installed 2.0.5/preload disappeared; the installed 2.0.16 binary and Base are now pinned in automation/toolchain.json. This supersedes old tool paths/version assumptions, not the no-unsafe requirement. Do NOT downgrade to suppress termination failures or change global toolchains.

Preserve iteration-0011 completed codec/root/named proof work. All five END_TO_END laws exist; start by reading them and the final WORK_LOG checkpoint. Do not restart earlier completed subproblems. Investigate every one of the 110 unsafe annotations reported by the new compiler. Identify actual definitions and termination/coverage problems or compiler defects; repair actual code/proofs soundly. Zero unsafe annotations are required in PROOF and END_TO_END with the pinned unmodified checker. Merely removing source text, hiding diagnostics or counting an unsafe checker success is forbidden. If a compiler defect is established, provide a minimal reproducer and exact external fix needed; do not self-patch the trusted kernel. Never invent proof validity.

Repair the runtime test transport for the installed compiler (read bend guide and inspect supported JS emission). tools/run_runtime_tests.py must execute the unchanged tests/sha256.test.ts and ALL tests/new/*.test.ts through actual compiled Bend; implement a local compile/import adapter if necessary. Frozen acceptance invokes that entry with explicit test arguments. Preserve tests and all original assertions. Adapt tools/spectests.py and its runtime loading to current Bend, preserving 5,440 exact cases, expected-output isolation, hard error handling and transport regressions. Expected results never enter the tested implementation. No replacement of Bend algorithms with host implementations. For this operator-authorized migration, tools/run_runtime_tests.py is a new editable test entry; it is not permission to weaken tests.

Run the full frozen acceptance under 2.0.16, including all official cases, and archive new source-attributed evidence. Update stale comments/status. Independently self-audit all original AUDITOR.md criteria, then obtain a new independent audit and orchestrator completion review. A previous green run on 2.0.5 does not validate this toolchain. Continue all outstanding work without stopping at one fixed annotation or a loader milestone. Preserve session continuity and checkpoint inside the invocation.

# Fully verified mainnet Fulu SSZ library in Bend

Build a standalone pure Bend SSZ library, specifically supporting EVERY SSZ type
exported by the pinned mainnet Fulu Python spec and every nested field type.
This replaces the previous Fulu state-transition task; do not resume that task.
All schemas and exact mainnet limits are frozen in schemas/fulu_mainnet.json.
The normative sources are vendor/consensus-specs/ssz/simple-serialize.md and
vendor/consensus-specs/fulu_mainnet.py at the commit in upstream.lock.json.
Provide usable named Bend types/APIs for every Fulu container and named SSZ alias;
a JSON schema inventory alone does not implement a type. Ensure field order,
widths, vector sizes, list capacities and nested definitions exactly match Fulu.
This includes BeaconState, blocks/bodies, operations, execution payloads,
light-client types, PeerDAS types, and cryptographic byte wrappers. No Electra
upgrade/state-transition logic, other fork presets, BLS or KZG verification.

Use SHA-256 DIRECTLY from https://github.com/Giulio2002/bend-sha256, pinned at
4690c56c2490dcf522a2bfbcdee3d2e177271692 (latest fetched main). It is already copied
in vendor/bend_sha256. Preserve HASH_PROOF: the actual runtime hash equals the
independent FIPS SHA-256 specification for every byte input and returns 32 bytes.
Do not replace it with external crypto or resurrect Fulu's old local SHA path.

Full functional proof scope: type validity, valid-value domains, canonical
serialization, deserialization and exact malformed-input rejection, hash_tree_root,
packing, chunk padding, Merkleization, length/selector mixing, and composition to
EVERY Fulu public type. Cover integers through uint256, bools, byte arrays, bit
vectors/lists, vectors/lists, containers, unions, and all additional SSZ constructs
needed by every pinned generic spectest (including progressive and compatible
types). Round trips alone are insufficient: prove refinement against independent
normative semantics, decoding completeness/soundness and canonical rejection,
correct roots and exactly 32 root bytes. Prove offsets, bounds, delimiters,
unused-bit rejection, overflow handling, nesting, empty cases and limit edges.
Use mathematical all-input statements with no fixture-size/resource restriction
masquerading as protocol correctness. Explain actual runtime/resource limits.
SSZ Merkle proof generation/verification APIs and JSON formatting are not required;
transport must nevertheless faithfully connect test inputs to the proven API.

Independent spec/*.bend must not import src or proof modules, nor define the
meaning of SSZ as whatever the implementation returns. Neutral representation
datatypes may be shared; document a precise normative-spec correspondence.
Add END_TO_END.bend, imported by PROOF.bend, with actual universally quantified
serialize_correct, deserialize_correct, deserialize_rejection_correct,
hash_tree_root_correct and fulu_types_correct laws. The latter must cover the
complete frozen inventory, including types without direct official test cases.
Prove all reachable implementation layers and discharge public input invariants.
No holes, axioms, unsafe proof escapes, self-equality specs, assumed codec/Merkle
correctness, external transition/SSZ oracles, or new cryptographic assumptions.
Trust only the unmodified pinned Bend checker/Base and faithful independent spec
transcription for functional correctness; state compiler/runtime/hardware and
collision-resistance boundaries separately. No BLS/KZG package is needed.

ALL official SSZ spectests MUST pass: all mainnet Fulu ssz_static cases AND all
ssz_generic cases from the pinned v1.6.1 general release archive. The complete
case list and file hashes are frozen in cases.json and fixtures.manifest.json.
Never exclude, skip, hardcode, substitute expected results, or classify backend
errors/timeouts as valid rejection. Official valid cases require exact encoded
bytes, decoded value and expected root, not just round-trip agreement. Invalid
cases pass only on actual semantic rejection. No use of Python reference SSZ to
compute implementation outputs; Python may independently decode test metadata
and serve as an additional reference comparator. Build tools/spectests.py with
--report PATH, returning nonzero unless EVERY case passes. Report JSON contains
cases:[{case:<exact inventory path>,status:"passed"|"failed",...}], plus evidence.
Do not give expected values/roots to the implementation backend.

Read WORK_LOG.md, PROOF_STATUS.md, README.md and automation/restart-provenance.json.
This run continues preserved work from the previous SSZ run, including its latest
interrupted candidate. That candidate is UNVERIFIED until the checker, tests and
independent reviews establish its current claims. Do not restart implementation
from scratch or treat prior reports as current evidence. Preserve sound progress.

Work continuously toward the ENTIRE end-to-end objective in each invocation.
Do not stop and return needs_work merely because one lemma, codec family or
intermediate milestone is finished. Continue across subsystems: complete all
remaining SSZ constructors and every Fulu named type, integrate every official
case, finish full independent semantics and all universal composed public proofs,
and pass the complete gates. Maintain intermediate checkpoints and precise
WORK_LOG notes without ending the invocation. No total cycle or agent-time cap.
When an actual process/context/resource limit forces a return, report needs_work
with a precise recoverable checkpoint; that is not objective completion.

Before proposing completion, perform your own substantive audit using frozen
AUDITOR.md: inspect normative correspondence, nonvacuous propositions, dependency
closure to actual APIs/adapters, all public invariants, rejection behavior, full
inventory and no expected-output leakage. Fix discovered defects and repeat
appropriate checks. The orchestrator must independently perform the same checks;
the separate auditor remains an additional mandatory gate. Neither a green finite
test suite nor checked local lemmas establish the required full verification.
Hard proofs are remaining work, not an external blocker. Do not compromise proof
soundness or restrict the input domain to accelerate reported completion.

Work only in your isolated workspace. Do not modify Fulu, other projects,
credentials, tools, runner, acceptance files or vendor. No worker subagents,
commits, pushes or deployment. Use build/ scratch. Pinned Bend 2.0.16:
/Users/monkeair/.bend/bin/bend; Bun: /Users/monkeair/.bun/bin/bun.
Python with fixture dependencies: /Users/monkeair/work/fulu-bend/.venv/bin/python.
Do not claim full success while automation/acceptance.py is failing.

```toml
name = "Fully verified Fulu SSZ with all official SSZ spectests"
project = ".."
backend = "claude"
claude = "/Users/monkeair/.local/bin/claude"
claude_effort = "medium"
model = "claude-opus-5"
orchestrator_model = "claude-opus-5"
max_iterations = 0
agent_timeout = 0
orchestrator_timeout = 0
validation_timeout = 43200
editable = ["src/*", "spec/*", "proofs/*", "types/*", "*.bend", "tools/*", "tests/new/*", "README.md", "WORK_LOG.md", "PROOF_STATUS.md", "VALIDATION.json"]
protected = ["vendor/*", "fixtures/*", "schemas/*", "cases.json", "fixtures.manifest.json", "upstream.lock.json", "automation/*", "tests/sha256.test.ts", "HASH_PROOF.bend", "src/sha256.bend"]
ignore = ["build", "build/*", "*.pyc"]
validation = [["/Users/monkeair/work/fulu-bend/.venv/bin/python", "automation/acceptance.py"]]

[criteria]
fulu_types = "Every frozen mainnet Fulu named SSZ type and nested schema has an exact usable Bend definition; no missing types or changed bounds."
implementation = "Complete actual Bend serialization/deserialization/rejection and hash-tree-root APIs for all Fulu types and pinned generic SSZ constructs."
specification = "Independent normative SSZ semantics and full type mapping with legal domains, canonical rejection and exact mainnet parameters."
proofs = "Universal actual-API serialization, deserialization, rejection and root refinement, composed across every Fulu type; all premises discharged."
sha256 = "Direct latest pinned user's Bend SHA byte API, universal FIPS and 32-byte output proofs included in the root checker."
spectests = "Every inventoried mainnet Fulu static and generic SSZ spectest passes without skips, hardcoding, expected-output leakage or infrastructure-error acceptance."
trust = "No holes, unsafe/admitted proofs, vacuous specifications or unproved codec/Merkle oracles; honest proof map and reproducible trust boundary."
```
