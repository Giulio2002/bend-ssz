# Mainnet Fulu SSZ in Bend

A standalone pure Bend SSZ library for every type of the pinned mainnet Fulu
spec (109 frozen names) and every generic SSZ construct used by the pinned
v1.6.1 `ssz_generic` tests (uints to uint256, booleans, byte vectors/lists,
bitvectors/bitlists, vectors, lists, containers, unions, progressive lists,
progressive bitlists, progressive containers and compatible unions).

## Current status (Bend 2.0.16 recovery of iteration 0011)

Toolchain: Bend 2.0.16 pinned in `automation/toolchain.json` (bend sha256
`da9bc514…7386`, base.bend sha256 `e149828c…f5b8`). All evidence produced
under Bend 2.0.5 (iterations ≤ 0011) is historical only.

`END_TO_END.bend` (imported by `PROOF.bend`) states and proves, universally
over all schemas/values/byte strings (no size or fixture restriction):

| Law | Public API | Independent specification |
| --- | --- | --- |
| `serialize_correct` | `src/ssz.serialize` | legal types: equal to `spec/codec.encoding_for_legal_type`; illegal types: rejected |
| `deserialize_correct` (+ `deserialize_unique`) | `src/ssz.deserialize` | accepted with value v exactly when the type is legal and the bytes are v's canonical normative encoding; the image is injective |
| `deserialize_rejection_correct` | `src/ssz.deserialize` | rejects exactly the inputs outside the canonical image of a legal type (every input of an illegal type) |
| `hash_tree_root_correct` | `src/ssz.hash_tree_root` | every returned root is 32 byte-range bytes satisfying `spec/root_relation.root_for_legal_type`; every value of `spec/value_domain.root_domain` has a root |
| `fulu_types_correct` | `types/fulu.bend` `Name.*` (every public `X.*` is an alias of `Name.*` at `Name_X`) | for each of the 109 names: legal independent schema (`spec/fulu_schemas.bend`), serialization, exact decoding, exact rejection, roots and totality, typed adapter inverse |

2.0.16 evidence (this workspace, source hashes in VALIDATION.json):
`PROOF.bend` and `END_TO_END.bend` report "All terms check." with zero unsafe
annotations under the unmodified pinned checker; 51 runtime tests / 20,009
assertions pass through actually compiled Bend (same counts as 0011); all
5,440 official cases pass
([worker run](tools/validation-bend-2.0.16-official-29a6f06957b4f7e2558b2cdb28f4692894d2d6de505d38d89f748ab9433dcfa7.json));
frozen `automation/acceptance.py` exited 0
([report](tools/validation-bend-2.0.16-acceptance-3d5716ac75c135575f638617cc1a638cc04d22beb811e4bd44cec70c7f3b49e9.json),
[log](tools/validation-bend-2.0.16-acceptance-log-14487fcb3126bd9701477c9d04c31fecfab16f0cb45e7a0fb0ef8e8abfbfe11f.txt)).
This is a completion claim for independent review, not a self-approval.

Unsafe repair: 2.0.16 counts every template instance (`f~N`) as an unsafe
annotation. The initial 110 were the 22 × 5 instances of the generic sequence
templates in `types/fulu.bend`; they were replaced by monomorphic, ordinarily
termination-checked helpers `C.seq_*` with the identical algorithm (generator
`tools/generate_fulu.py`). Inventory and a minimal reproducer:
`tools/unsafe-2.0.16/`. Not a checker defect.

Runtime loader: `tools/bend_loader.ts` is a local Bun preload plugin. Each
imported `.bend` module is compiled by the pinned `bend` itself (its official
`bend <page.html> -o <dir>` bundler, i.e. the compiler's own library emitter)
and re-exported unchanged; no Bend algorithm is implemented in JS. Output is
cached under `build/bend-loader/` keyed by toolchain hashes and every
workspace `.bend` source. `tools/run_runtime_tests.py` and the spectest
backend both use it. The Bend→JS compiler, this adapter, Bun, and the JSON
transport are outside the proofs.

See `PROOF_STATUS.md` for the obligation table, proof map and trust boundary.
Verification commands:

```
/Users/monkeair/.bend/bin/bend PROOF.bend
/Users/monkeair/.bend/bin/bend END_TO_END.bend
/Users/monkeair/work/fulu-bend/.venv/bin/python tools/run_runtime_tests.py tests/sha256.test.ts tests/new/*.test.ts
/Users/monkeair/work/fulu-bend/.venv/bin/python tools/spectests.py --report build/spectests.json
/Users/monkeair/work/fulu-bend/.venv/bin/python automation/acceptance.py
```

## Historical evidence (superseded status text preserved)

Iteration 0011 (Bend 2.0.5, historical): PROOF/END_TO_END checked; 51 tests /
20,009 assertions; 5,440/5,440 official cases
([worker run](tools/validation-iteration-0011-official-078298017bf4363a90e3cb9203671cdff58d335ec34d3151b055bd09d1aabc3e.json));
acceptance exit 0
([report](tools/validation-iteration-0011-acceptance-e71e2e8afb9f77386cf85424954f318a75ca4b12a7e200ac0622711e45c72368.json),
[log](tools/validation-iteration-0011-acceptance-log-a08dd753782e8db1d96a15198c358cd0d1d00e54c41f14f882b5bf6564169d45.txt)).
The 2.0.5 `--preload …/bend2/main.ts` loader is no longer installed.


This standalone pure Bend library provides schema-directed serialization,
deserialization and roots for the 109 frozen mainnet Fulu names, nested
vectors/lists/containers/unions, and progressive/compatible constructs. It is
**not fully verified or accepted**. Decoding completeness, recursive root
refinement and totality, named composition and all five END_TO_END laws remain
unfinished.
Historical evidence is separate from current worker validation: iteration 0003's
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

`src/ssz.bend` is the generic API. `types/fulu.bend` provides concrete typed
records for all 59 containers, typed aliases and named `.valid`, `.serialize`,
`.deserialize`, `.hash_tree_root`, `.to_ssz` and `.from_ssz` APIs for all 109
names. Generate it reproducibly with `python tools/generate_fulu.py`; the
only input is the frozen schema inventory. Tests compare all generated schemas
against that inventory, including exact field order and bounds. This finite
inventory check is not the required universal composed proof.

Generic values use the neutral `types/schema.bend` representation. The primitive
representation is eight little-endian U32 limbs; byte/bit values use U32/Bool
lists. Public codecs return `Maybe`, with `None` for semantic rejection.
Construction of a raw typed record does not establish field validity. Retained
primitive/byte/Transaction APIs remain available in their original modules.

The new offset decoder checks fixed-region size, first offset, nondecreasing
boundaries, complete consumption, child validity, and canonical re-encoding.
The layout encoder/decoder now refine independent normative formulas for all
inputs. Accepted public decoder values provably re-serialize to the input, and
every successful public root has exactly 32 byte-range elements. Full recursive
refinement and the sufficiency of the decoder recursion bound remain open. Backend errors/timeouts remain test failures.

Checked bitvector root laws now discharge the packed-count condition for every
valid value. Bitlist roots exclude the serialization delimiter, use
ceil(capacity/256) chunks and mix the exact actual bit length. Natural-length
encoding rejects overflow instead of narrowing through U32. Proofs establish
exact arithmetic conversion, byte scope, capacity monotonicity and independent
FIPS root refinement. Bitlist root totality includes the normative uint256
length domain; composition through final Fulu domains remains unfinished.

Byte-list codecs prove canonical identity and exact rejection, including the
normative total serialized-size bound below 2^32. Their roots use
ceil(capacity/32), mix the byte length and are total for every accepted value.
The same size bound has now been repaired in the retained generic byte-vector
codec/specification, with the affected composition proofs rechecked.

SHA is called directly through the preserved wrapper to `vendor/bend_sha256`,
pinned at `4690c56c2490dcf522a2bfbcdee3d2e177271692`. `HASH_PROOF.bend` remains
unchanged. The independent model imports only Base, independent spec/FIPS
modules and neutral representation/alias metadata. See `PROOF_STATUS.md` and
`spec/CORRESPONDENCE.md` for the exact proof boundary.

Reproduce current checks from this workspace:

```sh
mkdir -p build
BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend
/Users/monkeair/work/fulu-bend/.venv/bin/python tools/run_runtime_tests.py tests/sha256.test.ts tests/new/*.test.ts
/Users/monkeair/work/fulu-bend/.venv/bin/python tests/new/test_transport.py
/Users/monkeair/work/fulu-bend/.venv/bin/python tools/spectests.py --report build/direct-spectests.json
/Users/monkeair/work/fulu-bend/.venv/bin/python automation/acceptance.py
```

The official runner emits all 5,440 frozen paths and batches transport requests.
Every valid case compares decoded values, exact official bytes and root; invalid
cases require an actual semantic rejection. Expected outputs remain exclusively
in the comparator. Static requests traverse the named typed APIs. The previous
iteration-0001 812/5,440 count and the iteration-0002 worker interruption are
historical. The later orchestrator run completed with 5,440/5,440 passes.
See VALIDATION.json for completed current checks and outstanding checks.

Functional trust remains the pinned checker/Base and independently transcribed
semantics, with unchanged HASH_PROOF and direct vendor SHA. Compilation, JavaScript
execution, marshalling, operating system and hardware are separate runtime trust
boundaries. Collision resistance is not used to prove functional equality.
Native Bend Nat transport is limited to 48 bits; memory, stack and execution time
can also prevent evaluation. These are runtime limits, not restrictions on the
mathematical proof domains. Such failures never establish semantic rejection.

Iteration 0006 adds checked validator metadata, field-position, named-field and
active-slot lemmas, plus compatibility fuel monotonicity. Full validator and
traversal equivalence remain unfinished. Fresh root checking and 49 runtime tests
(18,585 assertions) pass; the full official runner and acceptance were not rerun
this invocation. See WORK_LOG.md for the recoverable proof checkpoint and
VALIDATION.json for separately hashed evidence.

Iteration 0007 work is ongoing. The expanded root checker passes, including
actual type-validator soundness, selector-validator equivalence, compatibility
budget stabilization, and decoder public-budget sufficiency. The decoder proof
propagates actual slice/count and option-selection bounds and derives its forest
invariant from public type validity; it imposes no input-size restriction.
It does not yet establish decoding completeness against the independent encoding
image. The unchanged runtime suite passes 49 tests with 18,585 assertions. A new
complete official run is still in progress; its result is not yet claimed here.
