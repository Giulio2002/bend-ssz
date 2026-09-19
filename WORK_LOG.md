# Evidence chronology

Entries before “Restart iteration 0001” below are preserved historical notes.
Their counts and build-artifact paths are not current validation and those
artifacts are not assumed available in this workspace. Current evidence is in
VALIDATION.json and the final restart checkpoint below.

# Starting checkpoint

User replaced Fulu state-transition work with fully verified SSZ for ALL mainnet
Fulu types, using their latest SHA-256 package and the auto implementer in color
tmux. Previous Fulu runner is interrupted; leave its files and candidate intact.

109 named SSZ types exported from pinned mainnet Fulu Python module (containers,
primitive aliases and instantiated sequence/branch types). schemas/fulu_mainnet.json
recursively records exact fields and bounds. Generic type constructors are not
concrete named types and are excluded from that export. Source Python is pinned
under vendor for independent completeness inspection.

Official inventory: 295 Fulu ssz_static cases over 59 container types; 5,145 generic
SSZ cases; total 5,440. All must pass. The other named Fulu types still need explicit
Bend definitions, independent boundary tests, and universal proof coverage.

Only SHA exists so far. PROOF.bend checks universal SHA refinement and length;
16 independent Node crypto comparisons pass padding/chunk boundaries (32 assertions).
No SSZ correctness claim yet. Implement independent model, actual library/types,
strict spectest runner and universal proofs; see frozen objective. Full acceptance
intentionally reports missing SSZ runner until it exists.

# Cycle 0001 — primitive implementation and partial checked foundation

Status: needs_work. This cycle does NOT finish the requested primitive proof
milestone or the full objective. No protected source, vendor, fixture, schema,
acceptance harness or existing SHA test was edited. No commits or pushes.

Read README, previous work log, pinned SSZ serialization document, frozen schema,
checker guide/Base representation and the existing SHA proof/integration. Added:

- Neutral `types/primitive.bend`: six legal width constructors and eight-U32-limb
  unsigned value representation, covering the full uint256 runtime domain.
- `src/primitives.bend`: actual boolean and uint8/16/32/64/128/256 serialization,
  decoding, runtime integer-domain checks, overflow rejection, exact length and
  byte-range rejection, and 32-byte padded basic roots. Width/value constructor
  bridges avoid guessing generated JavaScript enum tags.
- `types/fulu_primitives.bend`: usable type aliases and valid/serialize/deserialize/
  hash_tree_root operations for all 21 frozen boolean/integer names; generic
  uint16 and uint128 too. Integer aliases share a UInt representation and require
  their validated domain; these are not compile-time refinement types.
- Independent `spec/primitives.bend`: arithmetic base-256 digit and reconstruction
  semantics, boolean canonical semantics, exact byte scope, domain and root
  definitions. It imports only Base and neutral representations. Precise source
  correspondence and remaining arithmetic obligations are documented in
  `spec/CORRESPONDENCE.md`.
- `proofs/primitives.bend`, imported by PROOF alongside the untouched HASH_PROOF:
  universal boolean encoding/decoding/root refinement and encoding completeness;
  universal actual boolean rejection agreement and byte domain; universal raw
  byte-scope validator refinement; exact integer rejection iff normative scope
  fails; generic padding length and actual optional integer-root length.
  No holes, axioms, unsafe definitions, or unproved laws added.
- Strict `tools/spectests.py --report PATH` and a Bun-to-Bend transport backend.
  Every inventory path receives a row. Unsupported cases fail. Primitive valid
  cases compare all three official outputs independently; invalid cases require
  the actual decoder's None. Backend requests contain no expected result fields.
  Root/encode receive only values; decode necessarily receives its byte input.
  Host BigInt only maps integers to/from U32 limbs; Bend does codec/root work.
- Primitive boundary tests, all-bit integer tests, invalid bytes at all positions,
  boolean rejection, named alias coverage, and four infrastructure-failure tests.

Debugging evidence: the first transport attempt used unqualified enum tags and
object-shaped booleans, which do not match this Bend JS compiler's representation.
The strict comparator exposed these errors (30/72 primitive cases passed then).
Fixed by calling Bend width constructors and using native JS booleans; added
constructor and alias regression checks. Also used the provided ruamel.yaml
parser instead of unavailable PyYAML. No dependencies were installed or edited.

Final checks:

1. `BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend`: exit 0,
   “All terms check”, including original universal SHA claims. The installed shell
   launcher prints a harmless denied write to ~/.bend/last; checker still exits 0.
2. Bun tests with the installed Bend preload on tests/new/primitives.test.ts and
   untouched tests/sha256.test.ts: 6 pass, 0 fail, 2,192 assertions. SHA alone is
   1 test over 16 input lengths, 32 assertions, and passes inside acceptance too.
3. `/Users/monkeair/work/fulu-bend/.venv/bin/python tests/new/test_transport.py`:
   4 pass. Nonzero backend exit, timeout, structured backend error and missing
   responses all produce failed inventory rows, never semantic rejection passes.
4. Official runner: 72 pass (all 6 boolean and 66 uint cases), 5,368 fail as
   unsupported, 5,440 rows total. 172 backend requests. Exit 1 as required.
   Reports: build/primitive-report.json and build/spectests.json.
5. Frozen automation/acceptance.py: inventory validation, root checker and SHA
   tests pass; acceptance fails at spectests with 72/5,440 passed. Exit 1.
   Full output: build/acceptance.log. Persistent summary: VALIDATION.json.

Remaining work (not an external blocker): integer mask/shift versus arithmetic
refinement; representation/range correspondence; integer encoding/root refinement
and accepted decoding soundness/completeness; explicit boolean inverse soundness;
public input invariants and alias composition; all 88 other frozen named types and
nested schemas; all composite/progressive/compatible codecs, packing and Merkle
semantics/proofs; all remaining official cases; complete universal END_TO_END
laws and independent semantic audit. PROOF_STATUS.md enumerates the exact 88
remaining names and limits of every checked claim. Mathematical proofs have no
fixture-size restriction. Runtime/compiler/transport/resource and cryptographic
boundaries are documented separately. A green primitive test suite does not
establish any missing theorem or finish this assignment.

# Cycle 0002 — primitive refinement and inverse laws; byte/Merkle building blocks

Status: needs_work. Worked only in iteration 0002's fresh workspace, with no
subagents, commits or pushes. Re-read the retained README, work log, proof map,
primitive implementation/spec/proofs, aliases, transport, pinned normative rules,
and relevant Base arithmetic. Preserved src/primitives.bend, existing primitive
aliases, strict transport, original SHA integration/proofs and all protected files.

The previously missing primitive codec proof chain is now checked:

- Word comparison reflection establishes boolean accepted-decoding canonicality.
- Proved the actual Base long-division recurrence for 2^8, 2^16 and 2^24 by
  induction over arbitrary bit-word lengths, using carry-preserving subtraction
  and structural quotient/remainder views. Bridged the resulting U32 quotient
  to shifts and remainder to the low-byte mask. Generated patterns bind symbolic
  bits; there is no fixture enumeration, bounded test surrogate or oracle.
- Proved every actual limb's four bytes equal the independent arithmetic digits,
  all eight limbs compose, width domains match, actual serialization refines
  spec, and serialized results have exact widths and byte-range elements.
- Proved shifts/OR used for decoding equal independent coefficient multiplication
  and addition, discharging byte-domain premises from actual input validation.
  spec/primitives.bend now spells coefficients first (256*b rather than b*256,
  likewise 65536/16777216); this preserves precisely the same arithmetic meaning
  and avoids relying on an assumed multiplication lemma. The spec still does
  not import implementation or proofs and does not use the implementation's OR.
- Proved accepted integer decoding canonically re-encodes, full limb extraction
  is invertible, overflow-checking narrowing preserves all zero-defaulted
  lookups, normative encoding decodes completely, and accepted decoding yields
  the normative encoding and a valid value. This supplements, rather than
  replaces, independent serialization/decoding refinement.
- Proved root construction retains the entire accepted encoding, appends the
  correct zeros, refines the independent basic root, and yields exactly 32
  elements in the byte domain. The internal pad helper's no-truncation condition
  is now discharged for public integer roots.
- Composed direct laws through all 21 frozen primitive aliases. Main claims and
  dependency map are in PROOF_STATUS.md and spec/CORRESPONDENCE.md. Required full
  Fulu END_TO_END laws are still absent; no incomplete law stubs were introduced.

Extended the library beyond primitives:

- Added generic fixed-byte-vector codecs and independent semantics with legal
  positive lengths, exact scopes, byte-range validation, refinement, rejection,
  accepted soundness and completeness. Added all 24 frozen fixed-byte wrappers
  with exact valid/serialize/deserialize APIs; their roots are still missing.
- A full-size Blob test exposed JS call-stack overflow in the reused recursive
  primitive validator. Kept the primitive implementation unchanged; implemented
  a tail-recursive byte-vector validator and proved its accumulator invariant
  against independent byte_scope for all inputs/lengths. Full-size Blob and Cell
  codec boundary tests now pass. Large constants use exact Nat products.
- Direct named codec specializations check for 23 byte wrappers. Attempting the
  Blob=131072 specialization exhausts the unmodified default checker stack,
  including compact U32.to_nat and Nat-product representations. Its generic
  all-length theorem checks, and its runtime codec works, but direct Blob proof
  specialization is explicitly unfinished. No resource cap was added to the
  theorem or protocol. Scratch reproduction is build/blob-proof.bend; it is not
  imported into the root checker. This is work to resolve, not an external block.
- Added checked pack_chunk fragment materialization (0..32 bytes) with exact
  zero-padding contents and 32-element length. Oversized input is rejected after
  at most 33 list cells; a 131072-element rejection test passes. Empty fragment
  yields a zero padding leaf; this is NOT full SSZ pack([]), which needs [] chunks.
- Added binary hash_pair for two exact 32-byte chunks, calling the unchanged
  pinned SHA API. Independent FIPS refinement, exact malformed-input rejection,
  output length and output byte bounds check. The byte-bound proof also strengthens
  knowledge of the actual SHA output without modifying its protected claims.
  General packing and Merkleization are still not implemented or assumed correct.

Final validation in this workspace:

1. Root Bend checker: exit 0, All terms check (build/checker.log). Includes the
   preserved HASH_PROOF and all new checked modules. The installed launcher still
   prints its denied ~/.bend/last write; no checker modification was made.
2. Bun primitive + new byte/node + original SHA tests: 9 pass, 0 fail, 2428
   assertions (build/bun-tests.log). Byte tests exercise every frozen fixed-byte
   name, full-size Blob/Cell, short/long encodings and invalid U32 elements;
   binary-node results are compared independently with Node SHA-256.
3. Existing transport failure tests: 4 pass (build/transport-tests.log), including
   backend failure/timeout/error/missing responses. No transport code changed.
4. Full official inventory runner: 72 passed, 5368 failed, all 5440 exact paths,
   exit 1 (build/direct-spectests.json and build/spectests.log). No new composite
   official case is claimed: byte roots and generic vectors are not connected
   until their complete actual APIs exist. Expected outputs stay out of backend
   serialize/root requests. Unsupported cases still fail, never skip.
5. Frozen acceptance.py: exit 1 (build/acceptance.log). Inventory verification,
   root checker and original SHA test pass; the unchanged full inventory gate
   fails on the 5368 unsupported cases. Persistent summary is VALIDATION.json.

Remaining: Blob's named proof specialization; full byte-vector roots and general
packing/Merkleization with limits/mixing; the 64 names without any API and complete
root/proof coverage for all 88 non-primitive names; every required composite,
progressive/compatible and generic construct; all remaining official cases;
complete END_TO_END laws, frozen acceptance, independent auditor approval and
orchestrator review. Compiler/transport/runtime/hardware and collision-resistance
boundaries remain explicit. No fixture-size premise is used as protocol correctness.


## Cycle 3 — checked length mixing and virtual zero subtrees (incomplete assignment)

Re-read the retained workspace, byte alias generator, normative SSZ Merkleization
rules, schema-backed aliases, independent semantics and proof chain. Preserved all
protected files and retained primitive/byte codecs and strict transport.

The first requested obligation, Blob named codec specialization, remains unresolved.
Reproduced the machine-stack overflow under the unchanged checker using
`build/blob.bend` (direct generic theorem application at Nat.mul(128n,1024n));
exit 1, `build/blob-check.log`. A named size function did not avoid it. All exploratory
alias/proof edits were restored using the unchanged generator. No bounded theorem,
checker patch, assumed specialization or false completion claim was introduced.
This is remaining implementation/proof work, not an external blocker.

Implemented `src/mixing.bend:mix_in_length` over every existing eight-limb uint256
value. Independent `spec/mixing.bend` uses arithmetic base-256 digits and FIPS SHA,
not implementation functions. `proofs/mixing.bend`, imported by PROOF.bend, proves
universal actual-API refinement, exact malformed-root rejection, output length
and byte bounds, and discharges the length-encoding 32-byte invariant. No length
or fixture cap is imposed. Added `zero_hash` in src/merkle with an independent
all-zero perfect-tree recurrence and checked all-depth refinement, length, byte
bounds and exact chunk scope. It uses one hash per depth and does not allocate
2^depth leaves. It does not implement general packing, tree limits, or next-power-
of-two selection. Selector mixing was not added.

Validation in this workspace:
- `BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend`: exit 0,
  All terms check (`build/checker.log`). SHA proofs stay imported and unchanged.
- Bun primitive, byte, new mixing/zero-subtree and protected SHA tests: 12 passed,
  0 failed, 2,638 assertions (`build/bun-tests.log`). New tests compare independently
  hashed length encodings across limb edges through 2^256-1, malformed root sizes
  and elements, and zero-subtree depths 0..64. These tests do not limit the laws.
- Python transport regression tests: 4 passed, exit 0 (`build/transport-tests.log`).
- Full direct runner: 72 passed, 5,368 failed, all 5,440 paths, exit 1
  (`build/direct-spectests.json`). No new official-case API is complete, so transport
  coverage remains unchanged. Expected outputs remain exclusively in the comparator.
- Frozen acceptance: exit 1 after passing root checker and original SHA test and
  reporting the same official-case counts (`build/acceptance.log`, `build/spectests.json`).

Outstanding: finish Blob specialization; implement/prove general byte packing,
limit-aware Merkleization including empty/non-power-of-two/capacity/malformed cases,
all 24 byte-wrapper roots and selector mixing; complete the remaining 64 named
APIs and nested/generic constructs, every official case, and full END_TO_END laws.
This cycle is smaller than the requested milestone and does not complete it.
Status remains needs_work. No commits, subagents or protected-file changes.


## Cycle 4 — verified byte packing and explicit-depth trees (partial byte-root milestone)

Worked only in iteration 0004. Re-read README, WORK_LOG, actual byte/merkle/mixing
modules, the frozen schema inventory, generator and pinned normative packing and
Merkleization rules. Kept protected SHA, vendor, fixtures, harness and transport
unchanged. No subagents, commits or pushes.

Added src/spec/proofs packing modules. The actual pack is tail-recursive and uses
a reversed output accumulator with bounded partial buffers. The independent
specification assembles output in forward order. All-input proofs establish exact
refinement and byte-range rejection; a separate scan invariant, discharged by the
public API, proves exact 32-byte scope for all returned chunks. Empty input yields
no chunks and only a partial final chunk is right-padded.

Added src/spec/proofs tree modules. `merkleize_at_depth` accepts up to 2^depth
exact chunks, consumes a stream, hashes via the pinned wrapper and pads missing
subtrees virtually. Its independent model recursively splits by perfect-subtree
capacity and uses FIPS SHA. Universal consume refinement proves root and leftover
suffix; public refinement, exact malformed/overflow rejection, byte scope and
32-byte output length check. This includes empty/singleton trees and arbitrary
non-power-of-two counts within the explicit capacity. It is NOT the arbitrary-
limit API: next-power-of-two selection and a separate non-power-of-two limit check
remain to be implemented/proved. Named byte-wrapper roots are still missing.

Blob investigation isolated a non-SSZ reproducer: applying an all-Nat reflexivity
lemma to Nat.mul(128n,1024n) also exhausts the checker stack. Recorded the unchanged
CLI failure in build/blob-normalization.log (exit 1), with reproducer source in
build/blob-normalization.bend. A build-only diagnostic calls installed Bend.book_load
and Bend.book_valid directly to expose the exception stack (no checker edits):
term_compare, recursive constructor comparison and term_higher appear in
build/blob-normalization-stack.log. Constructor-headed shared constants resolve
the minimal reflexivity example but not the real codec law; a list-first scope
helper also did not resolve it. Restored all such exploratory generator, alias
and primitive-spec changes. Blob specialization remains unfinished, without any
resource-bound premises or assumed correctness. This is not an external blocker.

Validation:
- Root checker: BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend,
  exit 0, All terms check (build/checker.log).
- Bun primitive, byte, mixing, new packing_tree and protected SHA tests: 16 passed,
  zero failed, 3,244 assertions, exit 0 (build/bun-tests.log). New tests independently
  partition byte streams and materialize comparison trees, cover empty and boundary
  sizes, malformed bytes/chunks, overflow, depths 0..64 with virtual padding, and
  a full 131072-byte Blob-sized input through packing and a depth-12 tree. These
  finite checks supplement unbounded laws, not restrict them.
- Python tests/new/test_transport.py: 4 passed, exit 0 (build/transport-tests.log).
- Every official path via tools/spectests.py --report build/direct-spectests.json:
  72 passed, 5,368 failed, all 5,440 paths, exit 1. No backend API coverage was
  promoted prematurely and expected outputs remain outside backend requests.
- Frozen automation/acceptance.py: exit 1, with passing checker and original SHA
  test followed by the same official counts (build/acceptance.log, build/spectests.json).

Still required: resolve Blob named codec composition; arbitrary-limit depth
selection and limit enforcement; compose exact named roots for all 24 byte aliases;
selector mixing; all remaining 64 named APIs, nested and generic/progressive/
compatible constructs; full END_TO_END laws, all official cases, frozen acceptance,
independent auditor and orchestration completion review. Status: needs_work.


## Cycle 5 — arbitrary limits, named byte roots and closed-inventory composition

Worked only in iteration 0005; no subagents, commits, pushes or protected edits.
Re-read the retained README/work log, depth-tree source/spec/proofs, byte codecs,
frozen byte inventory and pinned normative packing/next-power/limit rules.

Implemented src/limits.bend with logarithmic doubling search, count <= limit
checked separately from rounded tree capacity, default-limit behavior and virtual
padding. Added independent minimal-depth semantics and Nat order lemmas. Universal
proofs discharge the derived fuel invariant, prove minimality/uniqueness and root
refinement for every independent canonical depth, exact malformed/overflow
rejection, zero/default cases and 32-byte output scope. No resource cap is a public
premise and no exhausted-fuel case is classified as semantic rejection.

Implemented fixed-byte roots by composing validated byte vectors, packing and
default Merkleization. Generic proofs establish independent root refinement,
acceptance iff the vector domain holds, and exact output scope/length. Constructed
and proved a canonical depth witness for every raw input; no caller witness or
byte/chunk premise is required. Added .hash_tree_root to all 24 named byte aliases,
including full Blob and Cell, and direct root laws to the 23 existing literal-
specialized proof sets.

Restructured Blob composition rather than retrying large numeric syntax. Introduced
a closed neutral ByteAlias identity/length table generated from the exact frozen
24-name inventory. All named .valid/.serialize/.deserialize/.hash_tree_root wrappers
now directly delegate to src/byte_alias.bend using their named tag. The checked
proofs/fulu_byte_inventory.bend quantifies over EVERY identity and every raw input,
including Blob, and proves actual codecs, soundness/completeness, rejection and
roots. Its symbolic identity keeps the size expression unreduced during proof
comparison. This is the composition route for Blob; the old direct literal Blob
application remains omitted and is not claimed to check. No enum constructor is
excluded, no invariant is assumed, and no checker modification is used. The
independent spec shares only neutral identity/preset constants, never algorithms.

Extended transport to generic uint8 vectors using actual Bend vector codecs and
roots. Only type length, raw values or decode input encodings reach the backend;
expected encodings/values/roots stay in the Python comparator. All 161 new official
uint8-vector cases pass, including invalid zero-length types. Unsupported families
still fail, and all backend failure regressions continue to fail cases correctly.

New boundary tests independently round powers and materialize trees for limits
0..130; verify non-power-of-two capacity-vs-limit overflow, malformed chunks,
default limits and virtual zero roots through 2^40; compare all 24 frozen named
bounds and roots, including Blob and Cell; check invalid bytes/lengths and strict
transport errors. Initial test code attempted to exchange constructor tags between
separately compiled Bun module namespaces; that is not a valid host bridge. The
final test uses each named module's .length accessor and calls its actual root API,
so tags remain within the compiled module. No runtime domain was weakened.

Final verification:
- BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend: exit 0,
  All terms check (build/checker.log), preserving HASH_PROOF.
- Bun with Bend preload across primitive, bytes, mixing, packing_tree,
  limits_byte_root and protected SHA test files: 20 passed, 0 failed,
  4892 assertions (build/bun-tests.log).
- Python tests/new/test_transport.py: four passed, exit 0
  (build/transport-tests.log).
- Full tools/spectests.py --report build/direct-spectests.json: 233 passed,
  5207 failed, all 5440 paths, exit 1 (build/direct-spectests.log).
- Frozen automation/acceptance.py: exit 1 after passing root checker and original
  SHA test and reporting the same case counts (build/acceptance.log and
  build/spectests.json).

Remaining: selector mixing; all remaining 64 named types/nested schemas and
composite/bit/union/progressive/compatible constructs; all five END_TO_END laws;
all remaining 5207 cases and frozen acceptance; independent semantic and final
orchestration approval. Closed-inventory Blob composition is newly claimed for
review; literal-specialized Blob proof is explicitly not claimed. Status needs_work.

## Iteration 6: checked selector mixing and bitfield serialization foundation

Worked only in the supplied 0006 workspace, without subagents, commits or pushes.
Preserved protected files, SHA proofs, closed-inventory Blob/Cell dispatch and
strict transport. Re-read the retained README/log, actual mixing/proof modules,
pinned serialization/Merkleization rules and frozen schema bitfield occurrences.

Implemented mix_in_selector with uint8 range and root byte-scope checks, one
zero-padded selector chunk, and the existing pinned SHA path. Independent spec
and checked universal laws establish refinement, exact rejection/acceptance,
chunk content/invariant, byte range and exactly 32 output bytes. The pinned doc
calls the selector uint8 serialization without stating its Merkle chunk padding.
Resolved this against the pinned generic test-format definition and compatible
union fixture: reconstructed the progressive single-field inner root separately;
32-byte selector chunk matches official root, a raw one-byte suffix does not.
Recorded correspondence and a metadata-reading comparator regression. This does
not claim the complete compatible-union case passes through a union API.

Implemented bit packing and bitvector/bitlist serializers over Boolean lists.
Implementation ORs weighted bits; independent semantics sum positional weights.
Generated octet proofs perform exhaustive elimination of eight Boolean positions
(no fixture inputs or arbitrary resource limits), then structural induction proves
all-list refinement, byte bounds and exact output length. Composed serializer
laws prove positive/exact bitvector domain, bitlist capacity domain, appended True
delimiter semantics, exact acceptance/rejection for value/type domains, byte bounds
and length. Zero-capacity empty bitlists serialize to [1]; Bitvector[0] rejects.
These are serializer APIs only. Bit decoders, unused-bit/delimiter rejection,
roots, full inverse laws and nested named composition remain unfinished. Therefore
transport support remains unchanged; no incomplete official family is enabled.

Validation in this workspace:
- Root checker: BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend,
  exit 0, All terms check (build/checker.log). The wrapper cannot write its
  external ~/.bend/last cache under the sandbox; the unchanged checker succeeds.
- Bun test with Bend preload, all tests/new/*.test.ts and protected SHA test:
  exit 0, 24 tests pass, 8463 assertions (build/bun-tests.log). New comparisons
  cover every octet/partial octet, 0/1/7/8/9 and chunk/capacity boundaries through
  2048 bits, all 256 selector values, malformed roots and overflowing selectors.
- Python tests/new/test_transport.py: exit 0, four tests pass
  (build/transport-tests.log).
- Full tools/spectests.py --report build/direct-spectests.json: exit 1,
  233 pass, 5207 fail, all 5440 inventory entries (build/direct-spectests.log).
- Frozen automation/acceptance.py: exit 1, after root checker and protected
  SHA test succeed; same 233/5207 case counts (build/acceptance.log,
  build/spectests.json). No backend error is accepted as semantic rejection.

Remaining: finish bitvector/bitlist decoding and roots with all canonical rejection
and inverse laws; the remaining 64 named APIs/nested schemas; general composites,
unions, progressive/compatible types; all five universal END_TO_END laws; every
remaining official case and frozen acceptance, plus independent review. Selector
mixing helper completion does not establish union correctness. Status needs_work.

## Iteration 7: checked bitfield deserialization and documentation corrections

Re-read the supplied 0007 workspace, retained README/log, bitfield modules and
pinned bitfield deserialization rules. No subagents, commits or pushes. Preserved
all protected files, SHA integration, closed byte-inventory composition and strict
transport. Fixed the four auditor-identified selector status passages: the helper
is implemented/proved; union APIs and option membership remain unfinished.

Added actual bitvector_deserialize and bitlist_deserialize APIs, exposed from
src/bitfields.bend with parser helpers in src/bit_decode.bend. Octet extraction
uses masks and shifts; independent spec/bit_decoding.bend uses arithmetic
floor-division and remainder. A generated intrinsic eight-bit proof composes the
existing all-input byte-shape reflection with exhaustive Boolean constructor
elimination. This covers all byte values, not a fixture sample or input-size cap.
The parser proof discharges that byte-domain premise via public validation.

Bitvectors require a positive size, exact ceil(size/8) bytes, and zero unused high
bits. Bitlists reject empty input, zero final bytes and non-byte values, strip the
highest set bit of the final octet only, and enforce the actual decoded capacity.
Zero-capacity empty lists accept [1]. All-input refinement against independent
arithmetic parser semantics checks. Explicit laws prove both directions of
accepted-value and rejection agreement, and successful vector output length and
list capacity. These soundness/completeness laws concern decoding semantics;
universal serializer/decoder inverse and canonical re-encoding laws are NOT yet
claimed. Bitfield roots remain unimplemented. The requested whole milestone is
therefore incomplete, and no incomplete bitfield family is enabled in transport.

Verification in this workspace:
- Root checker: BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend,
  exit 0, All terms check (build/checker.log). The external wrapper cache write
  remains sandbox-denied; unchanged checking succeeds without it.
- All tests/new/*.test.ts plus protected SHA test with Bend Bun preload:
  exit 0, 27 tests pass, 14216 assertions (build/bun-tests.log). New tests cover
  every final-octet pattern, every one-octet vector width, delimiter and unused-bit
  rejection, non-bytes, empty/zero-capacity lists, byte/chunk/capacity boundaries,
  and finite canonical re-encoding comparisons through 2048 bits. These finite
  inverse checks do not substitute for the outstanding universal inverse laws.
- Python tests/new/test_transport.py: exit 0, four tests pass
  (build/transport-tests.log).
- Full inventory runner --report build/direct-spectests.json: exit 1,
  233 passed, 5207 failed, 5440 rows (build/direct-spectests.log).
- Frozen automation/acceptance.py: exit 1 after root checker and protected SHA
  test pass; same 233/5207 inventory results (build/acceptance.log,
  build/spectests.json).

Remaining: universal codec inverse/canonical re-encoding linkage; bitfield roots
with delimiter exclusion, capacity chunk limits, actual bit-length mixing and
32-byte proofs; official bitfield transport; all remaining 64 named APIs and
nested/composite/union/progressive/compatible constructs; all five END_TO_END laws;
all official cases and frozen acceptance plus independent final reviews. This is
checked partial progress; status needs_work.

## Iteration 8: universal bitvector inverse composition

Worked only in the supplied 0008 workspace without subagents, commits or pushes.
Re-read retained README/log, actual bitfield parsers and pinned serialization
rules. Preserved implementation, protected files, SHA integration, independent
specifications and strict transport. This cycle adds proofs rather than altering
the algorithms or expanding unsupported official-case claims.

Added proofs/bit_inverse.bend and its fixture-independent generator. Intrinsic
8-bit constructor elimination proves octet inversion in both directions. Existing
universal byte-shape reflection discharges the byte-domain reduction. Structural
induction then proves that repacking expanded arbitrary valid bytes returns the
original sequence, and that taking the original length from expanded packed
arbitrary Boolean lists recovers the original bits, including partial octets.

Added proofs/bit_vector_inverse.bend. It discharges the actual packed byte scope
from existing arithmetic length/byte-domain proofs, reflects the actual Nat
comparison, derives positive vector size from public validity, and proves the
actual public vector serializer/decoder round trip for every valid value. The
only premise is the genuine legal type/value domain. It also composes independent
serialization refinement to prove the actual decoder accepts normative encodings.
No resource-bound premise or assumed codec correctness was added. All new laws
are imported by PROOF.bend alongside preserved claims.

The converse public accepted-byte canonical re-encoding theorem is NOT completed.
The arbitrary-byte repacking lemma operates on full expansion, not the public
parser's truncated result; that missing linkage must still be proved. Bitlist
inverse composition and all bitfield roots also remain incomplete. Thus no new
transport family is enabled and this remains a partial milestone.

Verification:
- Root checker, BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend:
  exit 0, All terms check (build/checker.log). The wrapper's external cache write
  is sandbox-denied as before, without affecting checker success.
- All tests/new/*.test.ts plus protected SHA test with Bend Bun preload:
  exit 0, 27 tests pass, 14216 assertions (build/bun-tests.log).
- Python tests/new/test_transport.py: exit 0, four tests pass
  (build/transport-tests.log).
- Full official runner --report build/direct-spectests.json: exit 1,
  233 passed, 5207 failed, 5440 inventoried (build/direct-spectests.log).
- Frozen automation/acceptance.py: exit 1 after root checker and protected SHA
  test pass; same 233/5207 counts (build/acceptance.log, build/spectests.json).

Remaining: public canonical re-encoding and exact serialization-image rejection;
bitlist inverse laws; bitfield roots with delimiter exclusion, capacity-derived
limits, actual bit-length conversion/mixing and 32-byte proofs; official bitfield
transport; the remaining 64 named/nested APIs and all generic/composite/union/
progressive/compatible constructs; five universal END_TO_END laws; all official
cases, frozen acceptance and final independent reviews. Status needs_work.

## Iteration 9: public bitvector canonical re-encoding

Re-read the supplied 0009 workspace's README/log, actual parser and retained
inverse proofs. Worked only here, without subagents, commits or pushes. Preserved
all protected files, pinned SHA implementation/proofs, independent specs and
strict transport. No runtime algorithm was changed.

Added proofs/bit_take_unique.bend. Structural induction proves that equal-length
bit sequences producing the same accepted take result are equal. At the base,
actual acceptance requires all remaining bits to be zero; equal-length zero tails
are identical. Cons-result inversion proves equality of every preceding bit.

Added proofs/bit_vector_canonical.bend and imported it through PROOF.bend. The
validated exact byte count and decoded output length establish equal expansion
lengths for original and packed output bytes. Parser uniqueness connects the
truncated value to the original expansion; existing repack_expanded then proves
exact re-encoding. Public laws establish accepted value validity, actual
serialization equals original bytes, and independent normative serialization
equals original bytes. Converse normative-image completeness and rejection
exclusion also check. This completes the missing public bitvector canonical
re-encoding direction, not merely a round trip. Byte range, byte count, positive
size and padding invariants are discharged internally; there are no resource-bound
premises. Legal-value and accepted-decode premises are the genuine theorem domains.

Validation:
- Root checker: BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend,
  exit 0, All terms check (build/checker.log). The wrapper's external cache write
  remains sandbox-denied without affecting the unchanged checker.
- All tests/new/*.test.ts plus protected SHA test with Bend Bun preload:
  exit 0, 27 tests pass, 14216 assertions (build/bun-tests.log).
- Python tests/new/test_transport.py: exit 0, four tests pass
  (build/transport-tests.log).
- Full official runner --report build/direct-spectests.json: exit 1,
  233 passed, 5207 failed, 5440 inventoried (build/direct-spectests.log).
- Frozen automation/acceptance.py: exit 1 after root checker and original SHA
  test pass, with the same 233/5207 case counts (build/acceptance.log,
  build/spectests.json).

No new official family is enabled because bitfield roots are still missing.
Remaining: both bitlist inverse directions including delimiter reinsertion;
bitvector/bitlist roots with delimiter-free packing, capacity chunk limits, actual
bit-length conversion/mixing and 32-byte proofs; official bitfield transport;
remaining 64 named/nested APIs and all generic/composite/union/progressive/
compatible constructs; all five END_TO_END laws; every official case, frozen
acceptance and independent completion reviews. Status needs_work.

## Iteration 10 — bitlist delimiter laws and public value inverse

Re-read the current isolated workspace, README, prior work log, actual bitfield
APIs and retained inverse/canonicality proofs. Preserved all protected files,
checked bitvector foundation, closed-inventory byte aliases and SHA integration.

Added proofs/bit_delimiter.bend: accumulator reversal identity and involution,
universal delimiter insertion/removal, accepted delimiter reconstruction with an
explicit zero-padding witness, and consumed-padding bounds. Added the reproducible
tools/generate_bit_list_inverse.py and generated proofs/bit_list_inverse.bend.
Its arbitrary-accumulator induction proves delimiter parsing of the actual packed
serialization for every Boolean list. There are eight residual cases (lengths
zero through seven) and one recursive eight-bit case; no list-size premise or
fixture enumeration is used.

Added proofs/bit_list_codec.bend and imported it through PROOF.bend. Packed-byte
invariants discharge public byte validation. Checked laws establish actual public
bitlist round trips for all legal values/capacities, completeness of independent
normative serialization, accepted-value validity, exclusion of every legal
normative encoding from rejection, and the exact delimiter/padding shape of every
accepted public input. Empty lists and zero-capacity lists are included in the
universal statements. Existing decoder refinement covers missing delimiters,
non-byte inputs and capacity rejection; no new runtime implementation was needed.

Validation (current workspace):
- Root checker exit 0, All terms check (build/checker.log); unchanged wrapper
  external cache write is sandbox-denied and does not affect checker completion.
- All seven Bun runtime files including protected SHA: exit 0, 27 passed,
  zero failed, 14216 assertions (build/bun-tests.log).
- Python transport failure tests: exit 0, four passed (build/transport-tests.log).
- Every inventoried official case: runner exit 1, 233 passed, 5207 failed,
  5440 total (build/direct-spectests.json and build/direct-spectests.log).
- Frozen acceptance exit 1 after checker and protected SHA test pass; same
  233/5207 counts (build/acceptance.log and build/spectests.json).

Remaining: accepted bitlist byte-to-value-to-byte canonicality and thus the full
serialization-image equivalence. The new delimiter reconstruction still needs
composition with octet alignment and repacking for that direction. Also remaining:
bitvector/bitlist roots, delimiter-free packing/capacity chunk limits, actual bit
length conversion/mixing and root byte invariants; official bitfield transport;
remaining 64 named and nested APIs and general/composite/union/progressive/
compatible constructs; all five END_TO_END laws; full official acceptance and
independent completion reviews. No root correctness or complete bitlist inverse
claim is made. Status needs_work.

## Iteration 11 — accepted bitlist canonicality

Re-read the retained README, work log, delimiter/codec proofs, actual packing and
independent bitfield semantics in this isolated workspace. Preserved runtime APIs,
protected files, pinned SHA, closed byte inventory and strict transport.

Added proofs/bit_padding.bend, proving forward reconstruction from reversed
accepted delimiter shape and whole-octet alignment of byte expansion. Added
proofs/bit_padding_pack.bend and its reproducible generator
 tools/generate_bit_padding.py. The packing law removes zero padding only when
its count is at most seven AND the complete marker-bearing sequence is octet
aligned. Both conditions are discharged at the public API. Structural recursion
covers arbitrary list lengths; the finite residual cases express the eight
positions in an octet, not a fixture or computational size limit.

Added proofs/bit_list_canonical.bend and imported it through PROOF.bend. Accepted
public decoding implies byte-domain validity, exact forward delimiter/padding
shape and alignment. The padding law and existing repack_expanded establish that
packing the value with its marker gives the original bytes. Public actual and
independent normative serializers therefore re-encode exactly. Existing legal
value validity and normative-image completeness now characterize acceptance in
both directions. An explicit outside-image rejection law quantifies over all
legal Boolean lists; together with retained rejected-image exclusion, it proves
exact rejection. Empty and zero-capacity lists, byte boundaries and malformed
inputs are included universally. No spec was altered and no resource premise
was introduced. Both bitfield codec inverse/canonicality milestones are complete.

Validation in iteration 0011:
- Root checker exit 0, All terms check (build/checker.log). The wrapper's denied
  external cache write remains separate from checker success.
- All seven Bun test files including protected SHA: exit 0, 27 tests pass,
  14216 assertions (build/bun-tests.log).
- Transport failure tests: exit 0, four pass (build/transport-tests.log).
- Full official inventory: exit 1, 233 passed, 5207 failed, 5440 total
  (build/direct-spectests.json and build/direct-spectests.log).
- Frozen acceptance: exit 1 after checker and protected SHA pass, same case
  counts (build/acceptance.log and build/spectests.json).

Remaining: bitvector/bitlist roots using delimiter-free packing and capacity
ceil(N/256) limits; actual bit-length conversion/mixing and output byte invariants;
official bitfield transport; remaining 64 named/nested APIs and general vectors,
lists, containers, unions, progressive/compatible constructs; all five END_TO_END
laws; full official acceptance and independent completion reviews. No bitfield
root or complete Fulu objective claim is made. Status needs_work.

# Workflow restart: end-to-end ownership

The user requested continuous full-objective worker assignments and substantive
orchestrator self-audit, followed by restarting SSZ. Latest iteration 12 work was
preserved after graceful interruption, including unreviewed edits. See frozen
automation/restart-provenance.json for original run/candidate paths. This restart
does not certify those edits. Read current code and establish current evidence.
Do not stop at the next bitfield milestone: continue all the way through composite
types, all Fulu definitions, all official cases and complete public SSZ proofs.

## Restart iteration 0001 — live checkpoint (2026-09-19)

Re-read the retained candidate and restart provenance. The baseline root checker
passed in this workspace (build/checker-baseline.log); prior numerical reports
were not treated as current evidence. No protected file was edited.

Discharged bitvector packed chunk counts: proofs/bit_chunk_count.bend relates
actual Pack.scan length to its buffer/count invariant, proves the ceiling formula
for arbitrary Boolean-list lengths, and proves capacity monotonicity. Its finite
256-way residual split is the intrinsic bits-per-chunk split plus a structurally
recursive unbounded case, not fixture enumeration. Public bitvector totality and
exact acceptance now discharge the former extra count premise.

Added exact-width natural encoding in src/spec/proofs/nat_bytes.bend. The proof
reaches Base.divmod's recurrence, proves quotient/remainder reconstruction,
byte-range and exact numeric conversion, zero-high-digit overflow rejection,
exact width, and capacity monotonicity. This avoids narrowing length via U32.
New actual bitlist roots pack without a delimiter, enforce ceil(capacity/256),
encode the actual bit length as 32 little-endian bytes and hash via the preserved
pinned SHA. Checked laws compose independent root refinement, selected canonical
depth, byte scope, exact acceptance, and totality for lengths representable by
the normative uint256 mixer. No machine-resource restriction occurs in these laws.
Representability of each final Fulu public domain still needs named composition.

Bitlist transport now calls the actual Bend codecs/root; hex value metadata is
independently read in the comparator. No expected encoding or root is passed to
serialize/root. Current direct inventory run: 812 passed, 4628 failed, all 5440
paths; all 494 bitlist cases added. This is incomplete. Root checker and new tests
have passed during development; final full gate refresh follows later in this
invocation. General composite/progressive/compatible constructors, 64 missing
names and the five END_TO_END laws remain outstanding.


## Restart iteration 0001 — final recoverable context checkpoint

Status: needs_work. The invocation reaches its context-budget checkpoint with
substantial implementation still required; this is not completion of the
assignment or approval of a milestone as the overall objective. No external
input is needed. Continue from this workspace, not an older iteration.

Continued beyond the bitfield work into byte-list semantics/codecs/roots and
Transaction. Added src/spec/proofs/byte_list.bend, proving exact canonical
identity and decoding completeness, byte/capacity validation, strict total
serialized-size overflow rejection below 2^32, ceiling chunk bounds, independent
root refinement, successful 32-byte scope and root totality for every valid
value. types/fulu_transaction.bend exposes the exact frozen ByteList[1073741824]
API. Its explicit named theorem composition is still unfinished: do not count
the generic ByteList theorem as a completed named theorem. Thus there are 46
usable frozen names, 45 with named/closed-inventory proof composition, and 63
without APIs (59 containers/four vector aliases).

The frozen AUDITOR.md self-audit found a real retained mismatch: arbitrary byte
vectors lacked the sequence serializer's strict 2^32 total-size assertion.
Repaired src/bytes.bend and spec/bytes.bend, adjusted domain/root composition,
and added boundary tests without allocating enormous inputs. A first expression
using comparison to a concrete 2^32-1 Nat exhausted the unchanged checker stack;
it was replaced with four exact arithmetic quotient steps. This is the same
protocol bound, not a smaller resource restriction. The resulting root checker
and all affected tests pass. Historical generic claims without this size guard
are superseded. No unresolved version of that discovered defect is retained.

Final reproducible checks in this workspace:

1. BEND_NO_TELEMETRY=1 /Users/monkeair/.bend/bin/bend PROOF.bend — exit 0,
   All terms check (build/checker.log). The launcher still reports its denied
   ~/.bend/last write, separately from successful checking. SHA proofs unchanged.
2. Bun all tests/new/*.test.ts plus protected tests/sha256.test.ts with the Bend
   preload — exit 0, 34 tests / 15002 assertions / zero failures
   (build/bun-tests.log). Includes independent sparse Merkle roots for Transaction,
   empty/capacity/chunk boundaries, bitlist metadata/transport and natural-length
   conversion through the full native Nat range.
3. Python tests/new/test_transport.py — exit 0, four tests pass
   (build/transport-tests.log). Errors/timeouts/missing outputs remain failures.
4. Direct official runner — exit 1; 812 pass / 4628 fail / 5440 exact unique
   inventory paths (build/direct-spectests.json). All 494 bitlists pass. No new
   static container is claimed. Byte-list APIs are available in transport but
   there is no standalone official ByteList family in the frozen general archive.
5. Frozen automation/acceptance.py — exit 1, after inventory verification, root
   checking and the original SHA test pass; official inventory still fails
   (build/acceptance.log, build/spectests.json).
6. Report audit confirms complete exact path order/uniqueness, only passed/failed
   statuses, matching independent/frozen-run counts, and no spec import of src
   or proofs. Actual SHA wrapper/HASH_PROOF still call the pinned upstream API
   and independent FIPS laws. Source inspection confirms expected roots/bytes
   stay in the comparator and semantic rejection requires actual backend None.

README.md, PROOF_STATUS.md, spec/CORRESPONDENCE.md and VALIDATION.json now describe
current coverage and limits rather than accumulating conflicting historical
claims. VALIDATION.json includes artifact existence and SHA-256 hashes. No
independent auditor/orchestrator approval is claimed. Self-audit result remains
needs_work because the full objective is unfinished.

Recoverable next work: finish generic nested vectors/lists, containers/unions,
progressive and compatible types with independent semantics and actual-API
proofs (especially fixed/variable offset layouts, canonical boundaries and total
size checks). Add all 63 remaining exact named APIs; complete Transaction's named
proof composition and length-domain discharge through every Fulu type. Add all
five genuine END_TO_END laws/import, faithful nested backend dispatch and all
remaining official cases. Re-run full gates and the substantive audit. No proof
holes, assumed codec/Merkle correctness, altered fixtures, hardcoded expected
outputs, new cryptographic assumptions, subagents, commits or pushes were used.

## Iteration 0002 — composite implementation checkpoint (in progress)

Added recursive schema/value representations, generic offset layouts, nested
vector/list/container/union codecs and roots, progressive constructs and
compatible-union validation. Generated `types/fulu.bend` from frozen schemas:
109 named APIs, including concrete typed records for all 59 containers and typed
aliases/conversions for nested schemas. Named static requests now dispatch through
these named APIs. This is implementation coverage, NOT proven refinement.

`PROOF.bend` now also typechecks the new API dependency closure. Independent
`spec/layout.bend` transcribes fixed/variable serialization layout without source
imports. `proofs/lists.bend` checks universal tail-list length and append equality;
`proofs/layout.bend` checks the fixed-region length against independent semantics.
Full layout, generic codec/root, inventory composition and END_TO_END laws remain
unfinished. Decoder and compatibility traversal fuel are derived from inputs but
sufficiency has not been proved; this is an explicit unresolved public obligation.

Large progressive fixtures exposed Base List.length stack overflow in new layout
code; tail-recursive replacements fixed sample serialization/root. Canonical byte
comparison was also changed to tail recursion. Five new composite tests (27
assertions) pass, covering malformed offsets, empty variable members, union roots,
progressive roots and moved-field compatibility rejection. Root checker passed
with the new implementation closure. Full official evaluation is still running;
no new full-suite success is claimed. Earlier all-at-once experimental runner
failed all rows after backend timeout; batching replaces it. Static metadata uses
roots.yaml (generic uses meta.yaml), corrected after that diagnostic run.

A direct Transaction named-law specialization was attempted but the checker
expanded the closed 1,073,741,824 capacity and overflowed its stack, including
on the domain specialization. The failing candidate was removed (draft remains
in build/transaction-laws.bend.txt); no named theorem is claimed. Generic
byte-list laws remain checked and unchanged. This needs a sound symbolic
closed-inventory composition, not a weakened capacity or assumed theorem.

Large-value implementation work: generic sequence counting, encoding, decoding,
root collection and generated named conversions now use tail accumulators.
A 65,536-element uint8 vector encodes/decodes successfully in a regression test.
Pure progressive Merkle laws now include a checked all-input traversal-completion
proof, exact chunk-domain acceptance and 32-byte range output, independent of
runtime limits. This does not complete progressive value/type composition.

Profiling a 1.3 MiB ProgressiveTestStruct established successful encoding (~6.8s)
and decoding (~22.3s); root execution exceeded the old 180-second batch limit.
A per-root, SHA-computed zero-subtree cache is being integrated, with uncached
fallback at every larger depth. Cache size is a performance choice, never an
input-domain restriction. Backend timeout is now configurable (default 1800s);
timeouts still fail, including invalid cases. Ongoing earlier runs use earlier
code snapshots and are diagnostic only, not final validation evidence.

Normative audit correction: removed the generic decoder's blanket <2^32 byte
filter. The pinned document places that assertion in the fixed/variable sequence
layout, which still enforces it; union and packed-bit serialization have their
own rules. Applying the layout assertion globally could reject a mathematically
valid top-level union or bitfield that its serializer accepts. No giant fixture
or machine-size premise is substituted for this all-input issue.

Added independent `spec/schema.bend` size classification and
`spec/codec.bend` recursive serialization for legal schemas, using the independent
layout formula and retained independent primitive semantics. Type legality,
full decode semantics and composed refinement remain explicit open obligations.

An attempted tail-length replacement in the retained byte-list module exposed
additional root-gate proof rewrites. It was rolled back together with its proof
edit to preserve the checked foundation; no changed byte-list proof is claimed.
Large raw byte-list inputs may still exhaust Base List.length at runtime. The
new generic sequence/offset paths use their proved tail operations. A follow-up
can parameterize the byte-list root gate by its measured length and transport
existing gate laws using lists.length_correct.

Checkpoint: PROOF.bend checks with cached-tree equivalence, progressive root
refinement/total traversal, independent fixed-size classification and sequence
count laws. The runtime suite reached 43 tests / 15,800 assertions with no failures;
a fresh rerun follows the global-decoder-size audit correction. Static/named
schema coverage is 109/109 definitions, not 109/109 composed proofs. Frozen
acceptance is running all cases with the longer resource timeout; first large
ProgressiveTestStruct cases now pass. Its report is not complete yet. Current
VALIDATION.json records this pending state rather than stale iteration-1 counts.

All four infrastructure-failure regressions completed successfully (1,688.405s):
backend crashes, timeout, structured backend_error and missing outputs leave every
inventory row failed. The post-audit runtime suite again passed 43 tests / 15,800
assertions. The complete acceptance run remains in progress; large cases now
advance successfully with actual roots, not substituted expected values.

Transaction composition recovered soundly: the single-name closed inventory
keeps the identity symbolic, analogous to retained Blob/byte inventory proofs.
`fulu_list_inventory` now checks domain/codec/rejection, decoding soundness and
completeness, independent roots, exact root acceptance, totality and byte scope.
The actual named Transaction wrapper now directly dispatches through it, with
unchanged capacity. Root checker passes; targeted byte-list/Transaction tests
pass (2 tests, 268 assertions). This supersedes the earlier failed direct literal
specialization. The separate newly generated typed-adapter path still awaits
full composed proof with all 109 names.

Remaining public-invariant audit item: the generic `valid` predicate is currently
serialization acceptance. For unrestricted bitlist/progressive-bitlist values,
length representability in the uint256 root mixer is not yet discharged by that
predicate. Fulu capacities are small enough in principle, but their complete
composed proof is still required; the unrestricted progressive domain needs a
precise normative validity treatment. Do not claim generic valid-value root
totality from the current implementation or from finite fixture success.

## Recoverable interruption checkpoint — end of iteration 0002 worker context

Context capacity forced a return before objective completion. The full frozen
acceptance process was explicitly interrupted (exit 130); its partial batch
counters are recorded in VALIDATION.json and are not a completed spectest report.
The in-flight process predated the new interruption-report handler, so no complete
per-case report is claimed. The independent runner must execute all cases again.
Do not reuse partial counters as per-case evidence or mark unexecuted cases passed.

Latest completed work also proves normative fixed-region byte length and that
strict total layout size entails representability of every uint32 offset. The
actual full accumulator-layout refinement, layout decoder soundness/completeness
and rejection, and universal generic/named composition remain unfinished.

Resume from these files, not build drafts:
1. Check PROOF.bend and run the full official runner / frozen acceptance; inspect
   every actual failure. Default per-batch timeout is 1800s because large valid
   progressive fixtures require substantial pure Bend hashing. Timeout remains
   failure. The runner now preserves an incomplete all-inventory report on Ctrl-C.
2. Complete layout refinement against spec/layout.bend. Useful checked lemmas:
   fixed_length_correct, fixed_parts_length, advance_total, offsets_representable,
   lists.reverse_append and append_length. Connect encode_go's reversed buffers
   to fixed_parts/payloads, then prove finish's exact domain and byte content.
3. Finish independent type legality, generic decoding/root semantics and composed
   proofs, including decoder and compatibility traversal sufficiency. Treat
   unrestricted bitfield uint256 length domains explicitly; no runtime bound is
   a proof. Large raw byte-list stack behavior remains a runtime follow-up.
4. Prove the generated typed adapters for all 109 names. Retained Transaction
   composition is now checked via fulu_list_inventory, but the unified generated
   API has a distinct adapter path. Add the five genuine END_TO_END laws only
   when proved, import them from PROOF.bend, and finish all gates and full audit.

Self-review against frozen AUDITOR.md verified current partial claims: independent
spec imports, direct pinned SHA, no new proof escapes, cache fallback validity,
exact named schema tests, expected-output isolation and backend error handling.
It is not a completion audit: the open public invariants and missing end-to-end
laws are substantive remaining objective work, explicitly documented above.

Final local root-checker rerun after the last proof additions exited 0: All terms
check. Acceptance was interrupted after diagnostic batch 70 / 3,719 passes;
no complete spectest JSON exists for that run. The preserved source checkpoint
and VALIDATION.json distinguish that unfinished gate from successful checks.


## Iteration 0003: retained evidence reconciliation and layout proofs

The current workspace is iteration 0003. Its initial build directory was absent,
so prior log/report artifacts are not locally available. The supplied orchestrator
record establishes that its subsequent iteration-0002 acceptance run completed
all 5,440 official cases successfully (11,446 requests, 159 backend exits zero),
then exited 1 with end-to-end proof missing. This supersedes the *worker's*
interrupted-run status, not the missing universal proofs. No fresh complete
run is inferred from that history. A current acceptance run is in progress at
build/iteration-0003-acceptance.log.

Checked new unconditional layout serialization refinement: accumulator ordering,
independent fixed/payload byte domain, lengths, offset failure, and strict total
size rejection. This is `proofs/layout.bend:encode_correct`, universally quantified
over all fragment lists, including invalid and overflowing layouts. Added
independent forward layout decoding semantics and checked exact slice extraction,
successful prefix extraction and arbitrary short-input rejection. Extent resolver
composition is currently being checked; full header/decoder composition and all
generic/named/end-to-end obligations remain open. Protected files and actual
runtime codecs are unchanged by this work so far.

The full public layout encoder and decoder refinements now check. New header
proofs use independent primitive uint32 coefficient semantics, prove slice byte
preservation, and discharge the public byte-domain guard. The outstanding
layout obligation is the canonical encoder-image equivalence, beyond the
independent algorithm refinement already proved.

Continued into the generic codec/decoder/root subsystems: checked all leaf codec
dispatch and combinator refinements, actual public decoder accepted-result
canonicality, and universal successful-root 32-byte scope for every generic
constructor/public SSZ API. The latter reaches arbitrary constructed cache sizes,
performs structural induction through forest accumulation, and uses the retained
SHA/mixing proofs. Neither canonicality nor scope substitutes for the missing
full independent recursive semantics, completeness, correct root contents or
valid-value totality. No END_TO_END placeholder was added.

Runtime checks: retained 43 tests passed with 15,800 assertions; new independent
layout tests passed with 934 assertions. The interruption transport regression
passed. The current complete official runner is still in progress; batch counts
are diagnostics only. All previously recorded src/types/backend hashes remain
unchanged, as do protected SHA files. Re-read both frozen AUDITOR.md copies and
checked independent-spec imports and actual-API reachability of new laws.

### Recoverable proof checkpoint (iteration 0003)

The latest root checker is build/iteration-0003-checker-24.log (exit 0, all terms
check). Runtime suite: 45 passed, zero failed, 18,462 assertions; the increased
count includes explicit list-termination checks in the new layout comparator.
All three new proof generators reproduce their checked files byte for byte.
No src, types, backend, fixture, schema, vendor, SHA, policy or acceptance file
was changed during this iteration.

Traversal prerequisites now available:
- layout_slices: exact extraction/refinement, byte-domain preservation, exact
  partition/reconstruction, consumed length and prefix/remainder size bounds.
- layout_counts: accepted layout outputs exactly one slice per supplied width.
- decode_count_bound: arbitrary natural division quotient bounds and successful
  item_count <= actual input length, including empty variable members.
- schema_measure: field/width counts and field count <= schema structural weight.
- decode_layout_bound: combines actual item_count/layout calls into sequence
  slice-count <= input bytes and container slice-count <= schema weight.

Resume by propagating slice-size bounds through complete header/extent layouts
and proving the nested decode_go budget sufficient, rather than treating the
count lemmas as that theorem. Compatibility additionally needs legal active-field
expansion bounds (<=256 positions) and an independent compatibility/legality
meaning. Full independent value/root semantics, layout canonical encoding-image
equivalence, recursive generic codec/root content refinement, valid-value root
totality/uint256 mixer domains, and all 109 unified adapter proofs remain open.
The new generic root scope theorem proves only successful roots are 32 bytes;
accepted decoder canonicality proves actual re-encoding, not independent generic
completeness. END_TO_END.bend remains absent. All three auditor completion
requirements are carried forward. Hard remaining proofs are work, not an external
blocker. The completed official-run evidence will be recorded separately from
this proof checkpoint when the current process finishes.

Additional continuation detail: a recursive `codec.encode_go` accumulator proof
must establish a proper schema-forest invariant. For malformed internal forests
such as Chain{Boolean, Boolean}, a leaf-valued tail ignores the runtime accumulator
whereas the independent forward `parts` concatenates; public type validation
rejects such forests. Do not assert an unconditional helper equality for every
raw internal forest. Prove the weak well-formed forest property from public type
legality, preserve it through option selection and internal Repeat construction,
and then compose the checked leaf/helper/layout laws. This is an outstanding
helper-precondition obligation, not an identified defect on legal public schemas.

### Completed current validation and context-budget checkpoint

The current iteration-0003 frozen acceptance process completed, rather than being
interrupted: 5,440 passed, zero failed, 11,446 requests and 159 backend exits zero.
Verified the report contains exactly the 5,440 unique frozen inventory paths.
Acceptance exited 1 with `INCOMPLETE: end-to-end SSZ proof missing`. The final
expanded PROOF separately passed the checker after all proof edits. Runtime and
backend source stayed unchanged throughout this completed official run.

Current evidence is recorded and hashed in VALIDATION.json: checker-24, final
45-test/18,462-assertion runtime log, interruption regression, complete spectests
report and complete acceptance log. The prior worker interruption and subsequent
iteration-0002 completed runner evidence are separately attributed as historical.
No validation process remains active.

This invocation reaches its context-budget checkpoint with the entire objective
still incomplete. Resume the precise proof obligations above; do not treat the
completed official run, generic output-scope proof or canonical re-encoding law
as a substitute for full independent end-to-end refinement. All three auditor
completion requirements remain outstanding. No external input is required.

### Iteration 0005: current workspace and evidence attribution

Re-read retained status, restart provenance, runner and both AUDITOR policies.
No build artifacts or iteration-0004 edits were retained. Earlier iteration-0003
worker success (5,440 cases) and later runner failure (5,439 cases plus one Bun
process failure) are historical, distinct observations. Iteration 0004 did not
produce a retained candidate. Corrected README, PROOF_STATUS and VALIDATION to
mark prior artifacts unavailable and avoid treating discarded work as evidence.
Future reports will use separately verified content-addressed archives.

Fresh iteration-0005 initial checker: All terms check. Runtime suite: 45 tests,
18,462 assertions, zero failures. Evidence archive and interruption regressions
pass. Three independent-process executions of the previously reported case using
Bun --smol passed exact official encoded bytes, decoded value and root comparisons
(43.55s, 48.51s, 61.61s). The case's native failure was not reproduced, so no claim
of a confirmed root cause is made. Adopted lower-memory mode as an empirical
mitigation and started the complete frozen acceptance gate. There are no retries,
case exclusions or changes to semantic failure classification. Reports preserve
full backend stderr and immutable content hashes. The current full run is still
in progress; do not infer completion from its progress log.

Freshly checked proofs in this workspace: schema_forest derives recursively
well-formed internal forests from actual public type validation; it deliberately
is weaker than independent normative legality. codec_accumulator proves ordered
accumulation only under a proper finite/repeated-forest premise. codec_composition
then proves actual serialization equals independent recursive encoding for every
value of every schema accepted by the public validator, including malformed values
and all composite/progressive/compatible constructors. No conditional codec or
Merkle correctness oracle is assumed: recursive child equalities and structural
premises are discharged by induction. Independent type legality, generic decoding,
root content/totality, traversal sufficiency and END_TO_END remain outstanding.

The root proof now imports checked recursive serialization and all 109 named
representation-inverse laws. Every typed value converts to the neutral SSZ
representation and back without loss; this is not a codec round-trip substitute.
The other adapter direction (accepted generic conversion preserves the original
value), conversion completeness on valid generic values, and named codec/root
composition remain open.

Added independent frozen schema constants in spec/fulu_schemas.bend, importing
only Base and neutral types. Their finite inventory test is separate from universal
functional claims. A direct per-name schema equality/named-serialization attempt
hits the pinned checker's stack limit while expanding Blob's large Nat constant.
The candidate is in build/fulu_serialization.candidate.bend, NOT imported by PROOF;
tools/generate_fulu_schema_proofs.py regenerates it as explicitly unverified scratch.
The isolated Blob schema-acceptance lemma checks; the closed schema-equality lemma
is the failing normalization step. A symbolic closed inventory or suitable
structural proof arrangement remains needed; this is unfinished proof work, not
an external blocker or permission to assume schema equality.

Further checked layers: layout_bounds proves every returned child slice is no
longer than its parent input, for all mathematical inputs. decode_soundness
connects public accepted values to the independent canonical encoding relation
and proves rejection of every string outside that image. This is one direction
of exact rejection; it does not prove no canonical input is rejected. Expanded
runtime tests pass: 46 tests, 18,572 assertions. The expanded root checker passes.
The current official run is still in progress.

Added independent recursive root relations with canonical existential depths,
exact active-field placement and uint256 mixing. Checked cached Merkleization
soundness/completeness and byte/bit leaf root correspondence in both directions.
The new value-domain specification explicitly separates serialization validity
from length-mixer representability; proved the current public validity predicate
refines the former. Generic root totality and the public mathematical domain gap
remain open. These are partial layers, not END_TO_END completion.

Both representation directions now check for all 109 names: typed values survive
conversion to/from the generic representation, and any accepted generic conversion
preserves the original value. A further checked family proves conversion accepts
all values with the corresponding structural representation shape. To avoid
expanding large protocol Nat literals in adapter-only proofs, it uses independent
structural erasure; a universal shape-erasure theorem proves no representation
shape is lost. Erased descriptors are proof-only and never replace runtime SSZ
schemas or protocol bounds. Codec-shape proofs connect independent successful
encoding to the original representation shape.

The fully closed per-name encoding-to-conversion composition still hits the
checker normalization limit (first located at Attestation's closed schema).
Its unverified candidate is build/fulu_conversion_composition.candidate.bend,
regenerated by tools/generate_fulu_conversion_composition.py, and is not imported
by PROOF. General independent encoding-to-shape and shape-erasure facts check;
closed named composition is still an explicit remaining obligation.

Independent type legality and compatible-Merkleization semantics now exist.
Compatibility is an unrestricted finite derivation relation (Pair/All/Row/Slots),
not the runtime's fuel-indexed boolean. Type legality covers all constructors,
nullable/compatible union constraints, field names, active-slot configurations
and exact selector ranges. The checked type_legality_structure theorem derives
proper finite schema forests and recursive well-formedness directly from that
independent legality judgement. Equivalence with the actual validator and its
traversal-budget sufficiency remains unfinished; these definitions do not assert
that equivalence by fiat.

Validation note: the expanded 49-test run under the default five-second test
limit recorded 47 passes and two timeouts while checker/full spectests were also
active. Its log is preserved as build/iteration-0005-runtime-current.log. Both
large stress tests completed their assertions but exceeded wall-clock limits;
they are failures in this record, not reclassified as semantic rejection. A
separate run with an explicit stress-test timeout is required. Official backend
failure classification and its timeout are unchanged. All five Python transport
failure/interruption tests passed in 1463.778 seconds.

All 109 actual named schemas now have checked independent legality witnesses
and checked actual-validator acceptance laws. A closed symbolic name inventory
composes generic actual serialization with independent encoding at every named
schema for every generic value, discharging type validation internally. This
avoids large-Nat normalization while preserving the actual schema functions.
Typed-wrapper composition and a universal equality to the separately transcribed
frozen schema mapping are still separate outstanding obligations.

Completed worker official run 0ce8c3e8-4a42-45b4-bf31-75831fda9fdf:
5,440 passed, zero failed, exact frozen inventory order/uniqueness verified,
159 backend exits all zero. Frozen acceptance returned 1 solely for missing
END_TO_END.bend. Preserved the exact official report under tools/ with digest
87fef23523b4e03a65f570920b38dc2260fdd35a8b98f196a93ebacce5cf0ee8,
and the separate three-run diagnostic with digest
7e2eb5f21892ea7d41c96e0bc7d9ce4193af9a6ed1c2fa0779231ff8d0d2a93a.
These immutable reports identify this worker's runs only; subsequent runner
results must be evaluated separately. No confirmed native crash root cause is
claimed. The lower-memory mitigation passed the diagnostic repetitions and this
full run without retries, skipped cases or changed comparisons.

### Iteration 0005 recoverable context-budget checkpoint

The final root checker passes. The isolated runtime rerun with an explicit
60-second stress-test timeout passes all 49 tests (18,585 assertions) in 17.11s.
The earlier default-timeout run remains recorded as 47 passes/two timeouts;
these are distinct runs. All five transport regressions and both immutable-report
regressions pass. No src/ or types/ runtime file changed from the retained
snapshot. Protected SHA files match their retained hashes. Independent spec
imports contain no src/proofs dependencies. The full worker report has exactly
all 5,440 frozen paths, 11,446 requests, 159 zero backend exits, no diagnostics,
and expected_outputs_sent_to_backend=false.

Substantive self-inspection against AUDITOR.md: checked the new independent
legality/compatibility rules against the pinned Illegal types, Union and
Compatible Merkleization sections; checked root-relation capacity, ordering,
active slots, delimiter omission and mixing rules; checked accumulator premises
are derived rather than assumed; checked adapter inverse/preservation scope and
all 109 closed-index names. Inspected runner/probe requests: encode/root receive
schema and input values only; official expected outputs stay in comparators.
Crashes, timeouts, missing responses and structured backend errors remain
failures. No unverified scratch candidate is imported by PROOF. This is a partial
self-audit, not a completion audit: public proof closure is still missing.

Resume in this dependency order:
1. Prove actual type-validator equivalence with spec/type_legality and the
   finite compatibility derivation relation, including compatible_go budget
   sufficiency for legal schemas and active-slot bounds. Existing legality and
   actual-validator witnesses cover every closed Fulu schema independently.
2. Complete layout canonical encoding-image soundness/completeness. Existing
   layout refinements, cut-prefix laws, offsets-fit, slice sizes and counts are
   checked, but do not prove that full equivalence by themselves.
3. Prove decode_go traversal sufficiency and canonical decoding completeness/
   uniqueness, using child-size and count bounds through nesting. A useful rank
   candidate is (2+schema_weight)*(2+input_length), with Repeat traversal bounded
   by its remaining part count plus the child's rank. This is a proof plan, not
   a checked theorem. Current accepted-value soundness/outside-image rejection
   alone do not establish exact rejection.
4. Compose roots recursively against spec/root_relation, including packing,
   forest accumulation, active placement, selector/length mixing, successful
   32-byte roots and valid-value totality. Resolve the public serialization-valid
   versus uint256 mixing-domain gap for unrestricted bitlists/progressive bits;
   do not substitute machine/fixture bounds. Cached Merkle and byte/bit leaf
   relation laws are checked building blocks, not assumed oracles.
5. Complete typed named API composition and the separate exact frozen-schema
   mapping proof. Use the closed symbolic name inventory to avoid huge Nat
   expansion. All 109 adapter inverses, accepted representation preservation,
   erased-shape completeness, independent legality and validator acceptance are
   checked. Direct closed composition candidates still overflow normalization;
   regenerate scratch with tools/generate_fulu_schema_proofs.py and
   tools/generate_fulu_conversion_composition.py, not as asserted evidence.
6. Add genuine universal END_TO_END laws and only then seek full acceptance and
   repeat the full completion audit. END_TO_END is still absent; acceptance is
   failing. Hard remaining proofs are work, not an external blocker.

This invocation stops at the context-budget checkpoint, not at objective
completion. Current artifacts and precise proof coverage are recorded in
VALIDATION.json; immutable reports/log bundles under tools/ survive fresh copies
which omit build/. No permission or external input is needed to continue.

## Iteration 0006 — validator prerequisites, context checkpoint

Re-read the retained status documents, restart provenance, both audit checklists,
actual schema validator and independent legality/compatibility definitions. The
iteration-0005 immutable worker reports remain historical evidence, separately
from the supplied subsequent runner result. All three archived artifact hashes
verify in this copy. No runtime implementation, transport, fixture, vendor or
protected SHA source changed in this invocation.

New laws, all imported by PROOF.bend and checked together:
- validator_metadata: runtime/spec name, bit and selector equality, membership,
  name uniqueness, field count, active count (including accumulator), active-slot
  expansion, and slot count bounded by the original active-list length.
- compatibility_positions: accumulator field lookup equals independent forward
  lookup for every schema/start index; shared-position tests agree, including
  gaps and absent names. Natural equality symmetry is proved structurally.
- validator_fields: final-active-bit equality and both directions of actual
  named_fields_valid versus the independent named_fields proposition.
- active_slot_bound: expanded slot count is at most 256, with the premise derived
  separately from actual public validator acceptance and independent legality.
- compatibility_identity: actual identity acceptance implies independent identity
  for every schema pair. This deliberately is not an equality theorem: the
  independent helper admits Named identity while actual identity rejects it.
- compatibility_monotone: increasing fuel preserves acceptance for each of the
  four modes reached by public compatibility. Fuel and schemas are unrestricted;
  the proof-only Mode index identifies exactly codes 0, 1, 2 and 3. This is not
  a sufficiency theorem for the public budget.
- compatibility_slot_shape: actual and independent active expansion establish a
  finite forest of Null/Named slots for every input. This premise must be used
  when relating mode 3 to the independent Slots judgement; arbitrary raw forests
  cannot support an unconditional equivalence.

Generators enumerate representation constructors, not test values or protocol
inputs. Large generated matrices expose tags the unmodified checker needs for
exhaustive reduction. The checker rejected an initial U32-default mode proof
because a residual word-tail pattern would not reduce; the retained proof uses
an explicit four-constructor mode index, covering all actual public call modes.
No failed candidate is imported or reported as checked evidence.

Fresh validation: final PROOF.bend checker exit 0, All terms check. Runtime suite
exit 0: 49 tests, 18,585 assertions, 9.88 seconds, timeout 60 seconds per test.
Frozen check_inventory verified all 5,440 paths and fixture hashes. The full
spectest runner and acceptance were not rerun in this proof-only invocation;
END_TO_END.bend remains absent, and no acceptance success is claimed. Previous
all-case reports cannot establish the remaining universal laws. This iteration's
exact checker/runtime logs are archived separately with hashes in VALIDATION.json.

Partial self-audit against AUDITOR.md: inspected the new law propositions and
all added root imports; metadata comparisons refer to independent definitions;
active-slot bounds use the normative 256 limit, not a runtime cap; monotonicity
is distinguished from sufficiency; Named identity asymmetry and mode-3 forest
premises are explicit. No implementation/spec semantics or expected-output
transport changed. This is not a completion audit.

Recovery after this context-budget checkpoint:
1. Finish selector-set validator equivalence and actual compatible_go soundness
   into finite derivations. Use identity soundness, position equivalence and the
   newly established Null/Named slot invariant. Do not claim mode-3 equivalence
   for arbitrary raw Chain forests.
2. Establish a structural compatibility rank using the public 256-slot bound,
   then use monotonicity to lift sufficient child budgets to the actual public
   budget. Complete actual validator equivalence in both directions.
3. Continue all previous checkpoint obligations: canonical layout image iff,
   decode traversal/completeness/uniqueness, recursive root contents/totality,
   unrestricted public mixing domains, typed named composition and exact frozen
   schema correspondence, then all five END_TO_END laws and every frozen gate.
No external input is required. The objective remains incomplete; this checkpoint
must not be treated as completion of the assigned continuous objective.

## Iteration 0007 — ongoing validator composition

Re-read retained files and audit requirements in the fresh workspace. Direct
baseline PROOF check passed. Constructed and checked finite derivation assembly,
Named-child budget lifting, and compatibility soundness for all four actual
modes (with the Slots forest invariant). Public compatibility acceptance and
CompatibleUnion option acceptance now construct independent finite derivations.
Selector validation now has soundness and completeness against the independent
selector proposition, with the seen-set disjointness invariant explicitly proved.
Type-validator soundness now covers every Schema constructor: actual public
acceptance implies spec/type_legality.type_legal, including progressive metadata
and CompatibleUnion derivations. These modules are imported into PROOF.bend.
Reverse validator implication and sufficient compatibility traversal still need
proof. Work continues; this is a recovery note, not a stopping condition.

The structural compatibility rank is now checked: regular modes use
1 + 512*(weight(a)+weight(b)); Slots adds remaining slot counts and weighs only
field payloads. Expanded payload weight is bounded by the original field forest;
each legal active list has at most 256 slots. Checked step inequalities cover
regular children, slot tails, Named slot comparisons and progressive expansion.
The actual public Pair and CompatibleUnion All fuel formulas dominate this rank.
compatibility_stability proves fuel-extension equality above the rank.
compatibility_public_budget discharges rank and recursive bounds from independent
legality, proving actual public results stable under arbitrary added fuel and
able to accept any finite successful traversal. This establishes budget
stabilization, not yet completeness from every normative finite derivation.
The remaining obstacle is constructing a finite runtime traversal from normative
Leaf identity for composite types (particularly CompatibleUnion), respecting
legality and its mutual compatibility witness; do not assume that construction.

The combined root checker passed after the public compatibility budget laws.
Additional checked prerequisites now include public identity equivalence
(identity_legality), metadata equality reflection, and proof-only alias
normalization. identity_normalization.reflect converts independent identity
into equality of normalized schemas; identity_decision proves normalization
preserves the entire identity decision, and derives substitution/transitivity.
All preserve every bound, field name, selector and active bit; normalization
only expands ByteVector/ByteList to their uint8 sequence aliases. No runtime or
independent specification changes were made for these proofs. They are now
imported by PROOF.bend. build/schema-symbolic.bend is an unimported failed
large-Nat experiment, not evidence or a proof dependency.

A fresh complete official run is in progress under session 27167, report target
build/iteration-0007-official.json, log build/iteration-0007-official.log. Do not
modify implementation/backend files during this run: keep its source attribution
coherent. No full-run success is claimed before its completion. The exact
remaining compatibility obstruction is the independent self-identity rule for
ProgressiveContainer/CompatibleUnion versus the runtime's expanded traversal.
One sound implementation option to investigate is explicitly recognizing that
normative rule in these branches, then reproving affected soundness, monotonicity
and stabilization laws; do not assume old traversal completeness.

Decoder traversal sufficiency is now checked and imported through
proofs/decode_budget.bend. decode_monotone proves preservation of exact successful
raw results under added fuel. decode_rank uses (2+schema weight)*(2+maximum bytes)
for regular nodes and a remaining-slice count for Repeat. decode_stability proves
full equality under fuel extension above that rank, including rejection results.
The proof propagates actual layout slice/count bounds and actual option lookup
weight/shape bounds; schema_forest.valid_well_formed discharges the public forest
premise. public_budget uses the actual input-derived fuel expression with no
input-size restriction. accepts_finite transfers ANY finite successful raw decode
to that public budget, and finite_unique proves equal successful outcomes across
arbitrary finite budgets. These are traversal results, not yet the missing
canonical encoding-image inverse or independent decoding completeness theorem.
All supporting modules checked individually. No runtime/backend change occurred.

## Iteration 0009 — recovery notes (in progress)

Fresh workspace baseline: PROOF.bend checked (All terms check). The retained
unimported candidates proofs/compatibility_equivalence.bend (normative finite
derivation => actual public compatible / CompatibleUnion option check) and
proofs/layout_image.bend (encoding image => independent layout decoding) were
checked standalone and are now imported by PROOF.bend.
New: proofs/type_validator_complete.bend (generator
tools/generate_type_validator_complete.py, constructor enumeration only) proves
spec legality => actual valid_go acceptance for every constructor and forest
flag; with type_validator_soundness this is both directions of validator
equivalence. CompatibleUnion uses options_complete with legality re-derived by
soundness from the just-proved acceptance (no assumption).

## Iteration 0011 — decoder completeness (in progress, recovery notes)

Checked and imported into PROOF.bend (root checker passes, ~35 s):
- decode_facts (repaired def order) and generated decode_shape
  (tools/generate_decode_shape.py): layout facts of the independent encoder
  (single fragment with exact normative fixed size; forest/repeat widths).
- decode_goal (hand-written): leaf inverses for every leaf constructor, exact
  item counts recovered from canonical images (fixed and 4-byte offset),
  width positivity, container/list/vector/progressive-list decoder steps,
  union selector steps and bounds, accumulated forest steps.
- decode_inverse (tools/generate_decode_inverse.py): recursive decoder inverse
  `inverse` at a structural value fuel, plus validator lookup facts.
- decode_complete: image_accepted (actual deserialize accepts the independent
  canonical image with exactly the encoded value, via decode_budget.accepts_finite),
  decoding_exact, image_unique (encoding injective), rejection_exact.
- u32_order repaired (U32 comparison = Nat comparison of values).
Next: five-law obligation table, END_TO_END.bend, recursive roots, named types.
- Root soundness (checked, imported): root_steps (hand-written relation steps:
  aggregate/merkle/mix, sequences, leaves, forests, containers, unions,
  progressive containers with active placement), root_sound
  (tools/generate_root_sound.py: recursive `sound` for every value/cache size,
  relation length threading), root_public.root_sound (API root => independent
  root_for_legal_type) and root_bytes (32 byte-range bytes).
  Next: root completeness (relation => API) and totality on root_domain.
- Root totality (checked): root_total_steps, root_total
  (tools/generate_root_total.py), root_public.root_total: every value in
  spec/value_domain.root_domain has an actual root.
- END_TO_END.bend (imported by PROOF.bend) now contains checked universal
  serialize_correct, deserialize_correct (+ deserialize_unique),
  deserialize_rejection_correct and hash_tree_root_correct. fulu_types_correct
  is the remaining law (named dispatch restructure planned: named schemas are
  the independent spec/fulu_schemas constants; typed APIs are aliases of a
  name-indexed generic dispatch so laws never unfold big limits).
- Named restructure (checked): tools/generate_fulu.py now emits the closed
  index `Name` (109 names), `Name.schema` = spec/fulu_schemas constants,
  `Name.to_ssz/from_ssz/valid/serialize/deserialize/hash_tree_root`, and every
  public `X.*` as an alias of `Name.*` at `Name_X`. proofs/fulu_named.bend
  (tools/generate_fulu_named.py) gives name-indexed legality, inverse,
  preservation and shape completeness. Direct per-name alias equalities
  overflow the checker (unary Nat), so aliasing is definitional and checked
  textually by tests/new/fulu_inventory.test.ts.
- Root completeness (checked): root_complete_steps, root_complete
  (tools/generate_root_complete.py), root_public.root_complete.
- END_TO_END.bend: all five laws checked, hash_tree_root_correct is an exact
  characterization (sound, complete, total, 32 bytes); fulu_types_correct over
  the closed index; nonvacuity witnesses added.

### Iteration 0011 self-audit against AUDITOR.md (before final gates)

- Specification meaning: END_TO_END states each law against independent
  spec/*.bend (type_legality, codec, decoding_relation, root_relation,
  value_domain, fulu_schemas); spec imports only neutral types and the vendored
  FIPS SHA spec (grep-verified). Decoding = exact canonical image; rejection =
  its complement; roots = relational per-constructor Merkleization semantics
  with existential minimal depths; completeness shows it is functional.
- Nonvacuity: END_TO_END has concrete witnesses (legal Boolean, a canonical
  image and its decoding, a rejected input, a root-domain value, an illegal
  empty container, a legal named Fulu type).
- Preconditions: public premises are only type legality, the canonical image
  relation and the normative root domain. Validator equivalence, forest
  well-formedness, traversal budgets, item counts, width positivity, selector
  bounds, uint256 mixing and 32-byte scope are all discharged inside proofs.
- Dependency closure: laws are about src/ssz (serialize/deserialize/
  hash_tree_root) and types/fulu Name.* directly; per-name X.* are
  definitional aliases (checked textually at runtime; direct equalities
  overflow the checker's unary Nats, documented).
- No holes/@unsafe/open laws in the new modules (grep-verified); PROOF.bend
  and END_TO_END.bend check.
- Tests: 51 runtime tests (incl. new closed-index test) pass; all 5,440
  official cases pass (archived report
  tools/validation-iteration-0011-official-078298017bf4363a90e3cb9203671cdff58d335ec34d3151b055bd09d1aabc3e.json);
  transport/expected-output isolation unchanged (tools/generic_transport.ts,
  tools/spectests.py not modified this iteration).
- Residual trust/limits: checker/Base, transcription faithfulness, compiler/
  runtime/hardware, runtime Nat word size and memory; SHA collision
  resistance unused. Typed record field *names* are generated by the same zip
  as their order from the frozen JSON; the bijection laws do not distinguish a
  hypothetical relabelling of same-typed fields (correct by construction).

### Iteration 0011 final gates

- PROOF.bend: All terms check (includes END_TO_END.bend).
- Runtime: 51 tests, 20,009 assertions, 0 failures.
- Official: 5,440/5,440 (worker run, archived
  tools/validation-iteration-0011-official-078298017b...json).
- Frozen acceptance: exit 0 (report tools/validation-iteration-0011-acceptance-e71e2e8a...json,
  log tools/validation-iteration-0011-acceptance-log-a08dd753...txt).
- Transport-failure regressions: 5 pass; run-evidence regressions: 2 pass.
- VALIDATION.json updated (status complete_claim_for_review; historical
  iteration-0006 record preserved under historical_iteration_0006_worker).
Status: completion claim for independent orchestrator/auditor review.

## Bend 2.0.16 migration (operator-authorized recovery) — checkpoint 1

- Pinned 2.0.16 checker initially: PROOF.bend "All terms check, with 110
  unsafe annotations." The binary's embedded CLI (`cli_report`) counts every
  Def that is `@unsafe` OR whose name contains `~` (a template instance).
  No `@unsafe` text exists in the project. All 110 are instances of the five
  generic templates in types/fulu.bend (to_items, to_items_go, from_items,
  from_items_go, from_step) over 22 distinct element types (22 x 5 = 110);
  inventory in build/unsafe_inventory.md. Classification: template instances;
  their bodies were structurally terminating, but the checker does not check
  termination across distinct instances, so it deliberately reports them as
  unsafe. Not a kernel defect. Reproducer: build/repro/template_count.bend
  (a two-instance structurally terminating template reports "2 unsafe
  annotations"; the monomorphic version reports none).
- Repair: tools/generate_fulu.py now emits monomorphic per-element helpers
  `C.seq_to_go/seq_to/seq_step/seq_from_go/seq_from` (identical algorithm,
  ordinary termination-checked defs). Adapter proof generators updated to
  target them and to parse the current Name.to_ssz dispatch; regenerated
  proofs/fulu_adapter_{inverse,preservation,complete}.bend are byte-identical
  to the retained proofs under the exact renaming (checked by script). No
  theorem statement changed otherwise.
- Result: PROOF.bend and END_TO_END.bend: "All terms check." (zero unsafe).

## Bend 2.0.16 migration — checkpoint 2 (final gates)

- Runtime adapter: the 2.0.5 preload (`~/.bend/current/bend2/main.ts`) is gone.
  The 2.0.16 binary's own loader (`load_js` -> `js_lib(book, outs, outs)`,
  exporting every def via `run_lib`) is reachable through its official page
  bundler `bend page.html -o dir`. `tools/bend_loader.ts` (Bun preload
  plugin) uses exactly that per imported module and re-exports the result;
  cache in build/bend-loader keyed by toolchain hashes + all workspace .bend.
  `tools/run_runtime_tests.py` runs `bun test --preload tools/bend_loader.ts`,
  verifies pins, parses counts; nonzero on failure, compile/load error, zero
  tests, missing files (all four checked with scratch negative tests).
- Tests unchanged: 51 tests / 20,009 assertions pass (= 0011 baseline).
- spectests.py/probe_backend.py now use the loader (PRELOAD) and record
  bend version/bend/base hashes; primitive_backend.ts and generic_transport.ts
  needed no change (plain `.bend` imports). test_transport.py +
  test_run_evidence.py: 7 OK. Probe of ssz_static/BeaconState case_0: passed.
- Worker spectests: 5,440/5,440 (tools/validation-bend-2.0.16-official-29a6f069...json;
  before the cache key was widened to include vendor/*.bend).
- Frozen acceptance: exit 0 — PROOF.bend "All terms check.", runtime 51/20,009,
  5,440/5,440, END_TO_END.bend "All terms check."; report
  tools/validation-bend-2.0.16-acceptance-3d5716ac...json, log
  tools/validation-bend-2.0.16-acceptance-log-14487fcb...txt.
- Self-audit: public/named theorem statements unchanged (only per-element
  helper lemmas renamed); spec/*.bend imports only spec, neutral types and
  vendor FIPS; no @unsafe/axioms/holes; dependency chain unchanged
  (END_TO_END -> proofs -> src/ssz and types/fulu adapters).
- Docs: README (commands, 2.0.16 status, historical 0011), PROOF_STATUS
  (inventory, repair, loader, trust boundary), VALIDATION.json `bend_2_0_16`.
Status: complete_claim_for_review (independent review pending).
