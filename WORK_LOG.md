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

## Memory simplification (iteration 0001) — in progress

Recovery notes (keep updated):
- Original sources snapshotted in build/orig (src, types, proofs, PROOF.bend,
  END_TO_END.bend); build/orig/vendor and build/orig/spec are symlinks so the
  old decoder can be loaded for differential tests (build/exp/cmp_final.ts,
  build/exp/fuzz.ts).
- New runtime: src/walk.bend (allocation-free byte walks: U32-counted direct
  recursion in runs of 4096, whole-input measure using the input as its own
  structural counter, pattern-based offset/uint reads) and src/decode.bend
  (one-pass cursor decoder `go`, closure-free layout walks, basic-leaf
  sequence fast path, validity gate first). No re-serialization.
- Differential: all 295 decompressed ssz_static fixtures and 2928 mutated
  inputs agree with the original decoder.
- Harness memory (memory_bench/deserialize.ts, 5 fixtures): 471-476 MiB peak
  (was ~2.2-3.0 GiB), ~0.41 s per decode.
- Findings that shaped the design: every JS tail call allocates a trampoline
  record, every Nat step a BigInt; JSC young-generation sizing makes the peak
  roughly live + garbage-since-last-collection, so byte-level loops must not
  allocate. Closures are curried (several function objects per call).
- NEXT: proofs for walk/decode (soundness + completeness vs spec/codec.bend),
  rewire decode_canonical/decode_soundness/decode_complete, delete decode_go
  proof machinery, root validity predicate, serializer, docs.


## Preserved root-domain worker log

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

## Root-domain correction — checkpoint 1 (worker, in progress)

- Runtime: src/root.bend public gate is now `Schema.valid(schema) AND
  valid_value(value, schema)` (structural decision, no codec); basic sequences
  pack element-wise basic serializations (`basic_bytes`, CPS/tail form);
  ByteVector/ByteList leaves use new root-only `merkle_root` (no 2^32 gate).
  Legacy leaf APIs `byte_root.hash_tree_root` / `byte_list.hash_tree_root`
  keep their protected-spec (serialization-gated) contracts.
- Spec: value_domain.root_valid (structural), root_domain = root_valid AND
  mixing_lengths, serializable_root_domain = old; root_relation without the
  encoding existential; old relation verbatim in spec/root_relation_serializable.bend.
- Proofs regenerated/updated: root_domain_steps (new), root_relation_leaves,
  root_sound, root_complete, root_scope, root_total (premise root_valid),
  root_public, END_TO_END. END_TO_END.bend checks.
- Remaining: compatibility proofs, strict-extension witness, ROOT_DOMAIN.bend,
  docs, acceptance gate.

## Native C optimization (ssz-optimization run 20260919T210840Z) — in progress

Status of the gates when this assignment started (verified, not inherited):
- `bend PROOF.bend` and `bend END_TO_END.bend` FAIL: proofs/decode_canonical.bend
  still refers to `I.equal_bytes_go`, removed by the cursor rewrite. Proof
  repair for the new decoder is genuinely outstanding.
- `native_bench/driver.bend` did not compile natively (see below).
- VALIDATION.json marked unverified_candidate at the start of this session.

Native build blocker (diagnosed, worked around, reported):
- `bend native_bench/driver.bend -o build/native/bend-ssz` failed with
  `a constructor outside its layout: ../types/fulu.BeaconState`.
- Bisection: the named per-type wrapper shape `def X.decode_result(r) =
  Name.decode_result(Name_X{}, r)` (constant name, runtime payload) is what
  fails; calling the per-type function directly compiles, and the generic
  dispatch with a runtime name compiles. Minimal failing set found by binary
  search over the 109 names: Fork + Epoch + FinalityBranch, i.e. three
  `Name.Value` arms with DIFFERENT native layouts (record / flat 8-word
  primitive / boxed list). Two arms always compile.
- A standalone 3-arm reproducer compiles, so the trigger needs more of the
  generated structure; the reproducible artifact is the generator-reduced
  module (build/probe/reduce.py <names> + native_bench/helpers/probe/pr.bend).
- Consequence: the native path must not instantiate the Name-indexed
  dependent dispatch. The native driver uses the generic/compact API.

Native measurements on the case_0 fixture (2,740,473 bytes, Apple M4, macOS 15.6):
- Go fastssz reference: decode 1.39 ms, serialize 0.29 ms, whole-process peak
  RSS 14.6 MB, TotalAlloc 8.4 MB.
- Bend, input as `+List<U32>` (one cons cell per byte): reading+summing the
  list alone is 4 ms and 48 MB RSS, i.e. ~16 B per input byte. The generic
  cursor decoder took 243 ms and 124.6 MB peak.
- Packing the same input into 32-byte chunk records: 5.5 MB for the payload
  (~2x) and walking the packed chunks costs 1 ms (vs 4 ms for cons cells).
- Therefore no cons-list decoder can approach Go: touching 2.7M boxed cells
  once already costs ~3x Go's whole decode. The compact representation is
  required for BOTH the 32 MB overhead gate and the 5x performance contract.

Architecture implemented so far:
- src/packed.bend: 32-byte `Chunk` records, `Packed` storage, and `Slice`
  (chunks, offset, size) with `slice_bytes` as the logical byte view, plus
  byte/u32/uint reads and sub/adv (sharing, no copying).
- src/cvalue.bend: `CValue`, the compact decoded value, with `to_value` into
  the neutral `T.Value`; byte strings are slices of the input storage.
- src/decode.bend: the cursor decoder now walks packed slices and builds
  CValue; `decode_packed` is the native entry point, `decode` packs a byte
  list first, and `deserialize` is `to_value` composed with `decode`.
- native_bench/driver.bend: phase markers + settle windows, input read sized
  from the file (no 64 MiB cap, short read is a hard error), packing done
  before the measured window, decoded value forced by a checksum fold inside
  the window and kept live afterwards.
- native_bench/run.py: rebuilds both sides always (SSZ_SKIP_BUILD removed),
  continuous RSS sampler plus boundary readings taken while the child sleeps,
  records baseline/decode peak/overhead/serialize peak/roundtrip peak.
- Measurement soundness: the emitted C maps one MAP_NORESERVE heap and grows
  it with a monotone page bump; there is no munmap/madvise anywhere, so RSS
  is monotone within a run and the end-of-phase reading IS the phase peak.

NEXT (in order): finish native measurement of the packed decoder; proofs for
the packed decoder against spec/codec.bend + spec/decoding_relation.bend;
compact serializer and root; the 109-type named compact API; benchmarks vs Go
for the performance contract; MEMORY_REVIEW.md and self-audit.

## Iteration 0002 — proof gate reconstruction for the packed cursor decoder

Salvaged the checked proof work from iterations/0001 (proofs/packed.bend,
cursor_leaves, cursor_walk, parts_algebra, offset_digits, the division.bend
repair) into this workspace and re-verified every file here under the pinned
Bend 2.0.16 before building on it.

New this iteration (all check):
- proofs/cursor_legal.bend — `legal_go`/`forest_ok` (decidable structural
  legality) and `from_valid`: the public type validator implies exactly the
  structural facts the decoder recursion consumes, including the union case
  where `Null` is only legal as the first option.
- proofs/cursor_cases.bend — one decoder case at a time with the recursive
  results as hypotheses: `region_if_sound`, the generalized `step_dispatch`
  (fixed and variable fields, chains and sequences), `among_*` dispatch.
- proofs/cursor_sound.bend — `go_sound`: soundness of `src/decode.go` by the
  decoder's own recursion, over every schema constructor and every cursor
  shape. This is the induction the whole gate was missing.
- proofs/packed_pack.bend — the packing round trip: byte extraction inverts
  limb assembly (fixed-width bit case analysis), `chunk_bytes_32`,
  `pack_chunks_view`, `pack_list_view`, plus the padding and chunk-count
  arithmetic.
- proofs/decode_top.bend — `accepted_serializes`: an input accepted by the
  public list entry point is exactly the specification's encoding of the
  decoded value.
- proofs/decode_canonical.bend repaired: every original lemma statement is
  retained; `I.equal_bytes_go`, `I.equal_bytes`, `I.canonical`,
  `I.canonical_bytes` are restored in src/decode.bend as proved helpers (the
  decoder itself never re-serializes), the two `I.gate` occurrences are stated
  at the value level (`I.value_gate` / `I.value_result`, same proposition),
  and `deserialize_canonical` is re-derived from `accepted_serializes`.
  proofs/decode_soundness.bend and proofs/validator_selectors.bend check again.

Source changes (src/):
- `Packed.pack` is now a single-pass recursion over 32-byte groups after one
  pad to the chunk boundary (no accumulator, no reversal, no second walk).
- `Packed.pack_list` computes the chunks, the byte count and the byte-domain
  check in ONE pass; `Decode.decode` uses it instead of `walk.measure` plus a
  separate `pack`, removing a whole extra traversal of the input from the
  list entry point.

Still open for the gate: `proofs/decode_complete.bend` (and the decode_goal /
decode_inverse / decode_budget / decode_shape stack it imports) is written
against the removed `decode_go` decoder. Everything there reduces to one
theorem, `image_accepted`: for a legal schema, the specification's encoding of
a value is accepted and decodes back to that value. That is the converse
induction to `go_sound` and is not yet written for the cursor decoder, so
PROOF.bend and END_TO_END.bend do not check yet.

## Iteration 0002 (continued) — item chains, native phases, native benchmark

Runtime (src/):
- `C.to_value` no longer recurses once per item. Item chains are stored in
  decode order reversed (the decoder prepends each finished child), and
  `to_value` folds a chain from its head onto an accumulator, so converting a
  container or list of a million children costs a million steps at constant
  conversion depth. `Decode.closed` therefore stops reversing the accumulator
  at the end of a walk, removing a whole pass over every sequence.
  `tests/new/composite.test.ts`'s 65,536-element vector case, which the cursor
  decoder had been failing with a JavaScript stack overflow, passes again:
  51/51 runtime tests, 20,009 assertions.
- `C.items_fwd` is the source-order reading of the children a walk has still
  to produce; it exists only for the laws.

Proofs:
- proofs/cvalue_chain.bend (new): `fold_prepended` and `fold_reversal` connect
  the two readings - once every child has been prepended, folding the chain is
  exactly the source-order reading. Two short inductions.
- proofs/cursor_walk.bend: `walk_context` / `count_context` now state the
  invariant as "the children still to come, reversed onto the accumulator"
  (`D.reverse_items(suffix, acc)`, the same function with its arguments in the
  other order) and read the remaining children with `C.items_fwd`. Every step
  and finisher is unchanged; `layout_start` discharges the new base case with
  `fold_reversal`. cursor_leaves, cursor_cases, cursor_legal, cursor_sound,
  packed_pack, decode_top and decode_canonical all still check.

Native memory (native_bench/):
- Every phase boundary of both drivers is now an exit point
  (`SSZ_PHASES=input|decode|root|all`), and the harness measures a phase by
  running a fresh process that stops at that boundary and reading the kernel's
  `ru_maxrss` for it. The decode overhead is the decode-prefix peak minus the
  input-prefix peak, cross-checked against continuous sampling and idle
  boundary readings, taking the maximum of all three. `verified` is derived
  from the exact output-byte comparison and the phase markers, never assumed.
- Both drivers gained a measured `hash_tree_root` phase (`ROOT_MS`/`ROOT_NS`,
  `PHASE=rooted`) and report the root digest checksum, which both
  implementations agree on for all five fixtures.
- Result: 15 Bend samples over 5 mainnet BeaconState fixtures, worst decode
  overhead 13,352,960 bytes (42 % of the 32,000,000-byte requirement), medians
  12.7-12.9 MB. See MEMORY_REVIEW.md.

Native benchmark (benchmarks/):
- benchmarks/native_driver.bend: one native executable that runs any contract
  type by name (generated dispatcher benchmarks/schemas.bend over the frozen
  spec schemas), one measured operation repeated a calibrated number of times,
  every result consumed, correctness checked outside the timed window.
- benchmarks/fastssz: the reference driver now covers any pinned
  go-eth2-client type (the harness picks the fork package that reproduces the
  official bytes and root) plus the contract's non-container types implemented
  directly against pinned fastssz's hasher.
- benchmarks/run.py --report PATH writes the exact schema
  automation/performance_gate.py validates, with per-sample timings, batch
  sizes, workload sources, source and artifact hashes.

### Constant-depth materialisation and packing

The official spectest run after the chain fix still failed 184 of 5440 cases,
all with `RangeError: Maximum call stack size exceeded` in the JavaScript
backend and all on large payloads (every `Progressive*TestStruct_lengthy*`
case, and the five BeaconState, BlobSidecar and HistoricalBatch fixtures).
Probing isolated two remaining places where the packed decoder held one
suspended call per element:

- `Packed.to_list` recursed once per byte. It now reads onto an accumulator
  and reverses once (`Packed.rev_append`), both constant depth. The single law
  the proofs use about it, `to_list_view : to_list(s) == slice_bytes(s)`, is
  re-proved through `rev_append_twice`.
- `Packed.pack_list` built one chunk in front of each recursive call, so a
  2.7 MB input held 85,000 of them. The old definition is retained verbatim as
  `Packed.pack_spec_go` - it is what every packing law in
  proofs/packed_pack.bend is stated about - and the decoder now calls an
  accumulating `pack_list_go` that carries the chunk list, the byte count and
  the domain check. proofs/packed_pack_acc.bend proves the two compute the
  same `Packing` (`pack_acc`, `pack_list_spec`) and re-derives `pack_list_view`
  for the implementation, so no existing packing law changed.

After both fixes the probe decodes 512 KiB byte vectors and 2 MiB uint64 lists
in the JavaScript backend that previously overflowed, and the 51 runtime tests
still pass with 20,009 assertions.

### Evidence produced at the end of this iteration

Command / gate | result
--- | ---
`tools/run_runtime_tests.py tests/new/*.test.ts tests/sha256.test.ts` | 51/51 tests, 20,009 assertions, exit 0
`tools/spectests.py --report build/spectests.json` | 5,440/5,440 official SSZ cases pass, 0 failed (JS/Bun compatibility evidence)
`native_bench/run.py` | 15 Bend samples over 5 BeaconState fixtures, worst decode overhead 12,943,360 bytes, all `verified`
report half of `automation/native_memory_acceptance.py` | PASS over 15 Bend samples (run separately, see below)
`automation/native_memory_acceptance.py` | **exit 1** - it runs the proof gate first, which fails on the missing decoder completeness induction
`automation/performance_gate.py` | **exit 1** - 978 workloads, 327/327 required operations covered, 5 within limit; first violation reported is AggregateAndProof.deserialize at 230.6x
`bend PROOF.bend`, `bend END_TO_END.bend`, `bend ROOT_DOMAIN.bend` | fail: `I.sequence` / `I.nat_gate` undefined, from the ten proof files written against the removed fuel decoder

Everything else in proofs/ checks with zero unsafe annotations, including the
whole cursor soundness development and the whole root development.

The performance contract is not met and is not close: median 188x
(deserialize), 191x (serialize) and 64x (hash_tree_root) against limits of 5x,
5x and 10x, over 978 workloads covering all 109 types. BENCHMARKS.md records
every workload, the calibration, the per-sample timings and where the time
goes. The memory requirement - the objective's headline - is met with a factor
of 2.5 in hand.

## Run 20260920T131722Z — representation evidence and leaf completeness

### Measured facts about pinned Bend 2.0.16 (new; nothing here was assumed)

Compiled `native_bench/driver.bend` to C and read the emitted runtime:
`build/native/bend-ssz.c:185-190` defines `TAG_BUF`/`TAG_ARR`, and the block
layer at `:3526-3620` documents itself as *"an ARR of class c 2^c Terms in 2^c
words, a BUF 2^c u32 ... get, set, swap, size and new open no half"*. So the
runtime does have contiguous, indexed block storage; `Array<T>` is not a
pointer-chasing tree despite its `ALeaf/ANode` surface.

Probes (sources retained in `benchmarks/probes/`, numbers in its README):

* 1,048,576 `Array.get` reads: under 1 ms (< 1 ns each).
* 2,740,473-element array fill from a byte list: 5 ms; indexed scan of the
  result: under 1 ms.
* 1,048,576-cell list walk: 2 ms.
* 200,000 record allocations: 1 ms.
* `def twice(+a: Array<U32>)` is **rejected**: `expected: Data, observed: Type`.

Consequences, written up in `docs/LAW_API_MAP.md`:

1. The 24-27 ms compact decode of a 2.74 MB BeaconState is representation cost,
   not runtime cost: the same bytes can be scanned by index in under 1 ms.
2. `Array` is linear. An array-backed decoder cannot share a buffer between two
   sub-decoders; it must thread the buffer and address it by index. That is a
   different decoder and a different proof development from the slice-based one
   in `src/`, not a storage swap inside the existing proofs.
3. Base's file API returns `List<&2, U32>` (`base.bend:267-276`), so converting
   input into a buffer costs 5 ms for a BeaconState - by itself 14x Go's entire
   0.35 ms decode. Buffer-ready decode, input conversion and end-to-end
   ingestion must therefore be reported as three separate numbers.

### Delivered this run

* `docs/LAW_API_MAP.md` — the exhaustive old-to-new map the orchestrator asked
  for first: all 29 END_TO_END and all 13 ROOT_DOMAIN propositions stay
  byte-for-byte (the list entry points become definitions on top of the array
  path, so their laws are laws about the array path), the public API rows, the
  internal lemma surfaces that must change, the two bridge theorems that carry
  the migration, and what must be proved before any row can be marked done.
* `proofs/complete_leaves.bend` — **all eight leaf completeness laws, checked**:
  `boolean_complete`, `null_complete`, `uint_complete`, `byte_vector_complete`,
  `byte_list_complete`, `bit_vector_complete`, `bit_list_complete`,
  `progressive_bits_complete`. Each says: a region whose bytes are exactly the
  independent encoding of a value is accepted by the packed cursor decoder and
  yields exactly that value. This is the converse of `cursor_sound.go_sound` at
  the leaves and the first half of the missing `image_accepted`.
* `benchmarks/probes/` — the five probes above with their sources and README.

### Still open (unchanged by this run unless noted)

* Composite completeness: the walk over container fields, sequences, unions and
  the top-level composition into `image_accepted` / `normative_image_accepted`.
  The leaves are done; the walk is not started.
* The array migration itself (`src/packed.bend`, `src/cvalue.bend`,
  `src/decode.bend` and the 3,500-line cursor development).
* Compact encode and streaming root.
* Performance: unchanged, still far outside the contract.

### Gates and evidence at the end of this run

| command | result |
|---|---|
| `tools/run_runtime_tests.py tests/new/*.test.ts tests/sha256.test.ts` | 51/51, 20,009 assertions, exit 0 |
| `native_bench/run.py` | exit 0; 15 Bend samples, worst decode overhead **12,894,208 bytes**, all `verified`; retained at `benchmarks/evidence/native-comparison.json` |
| `automation/native_memory_acceptance.py` | **exit 1** — first run failed on the new `docs/LAW_MIGRATION.json` requirement, which this run satisfies (`Law map complete`); it now fails at the proof gate, on `I.nat_gate` in `proofs/decode_count_bound.bend`, one of the ten modules still written against the removed fuel decoder |
| `automation/performance_gate.py` | **not re-run in this invocation.** `src/` is unchanged from the run that produced BENCHMARKS.md (978 workloads, 327/327 operations, 5 within limit), so the outcome would be identical; the runner executes it independently after this process exits |
| `bend proofs/complete_leaves.bend`, `bend proofs/complete_walk.bend` | All terms check, zero unsafe |

The gate's new requirement is satisfied by `tools/generate_law_migration.py`,
which derives `docs/LAW_MIGRATION.json` from `memory_bench/law-statements.json`
and the current `END_TO_END.bend` and refuses to write a row if the two
statements differ. All 29 rows currently hold the *identical* text, because no
proposition has been migrated: the design in `docs/LAW_API_MAP.md` keeps them
byte-for-byte by defining the byte-list entry points through the array path.

### Walk completeness progress (same run, after the gate results above)

`proofs/complete_walk.bend` grew from infrastructure to the first real walk
step, all checked by the pinned checker with zero unsafe:

* `app_items`, `app_empty_right`, `app_assoc`, `fold_app`, `reading_step`,
  `reading_is_value` - how the accumulated chain reads as a value.
* `walk_result` / `walk_goal` - the completeness invariant of the layout walk,
  premises as arrows: cursor views, consumed sizes, the remaining header bytes
  (`headerrest`) and remaining payload bytes (`payloadrest`) as the layout of
  the parts that are left, and the parts of the remaining fields.
* `parsed_elim` - eliminating a child's `parsed_as` into its components (an
  `Out` can only be matched as a parameter).
* `close_complete` - the end of a forest: nothing left, payload cursor at the
  region end, accumulated children are the whole forest.
* `single_here` / `fixed_part_length` - a fixed-size field's fragment has
  exactly `fixed_size` bytes, read off the existing shape development
  (`proofs/decode_shape.facts` + `head_single`, both already checked).
* `drop_append_exact`, `add_sub_left`, `header_advance` - the byte algebra of
  advancing the header cursor past one fixed field.
* `step_fixed_complete` - **the fixed-width field step**: given the child's
  completeness and the walk's invariant for the rest, the walk over
  `Chain{hh, tt}` delivers the whole forest.

Both walk steps are now proved. Added after the fixed step, all checked:

* `value_of_digits`, `offset_here` - a variable field's stored offset reads back
  as exactly the payload position whose canonical digits the header holds.
* `starts_with`, `starts_head`, `starts_tail` - splitting a known prefix off the
  remaining header or payload bytes.
* `first_offset`, `no_offset_here`, `chain_elim`, `next_offset_value` - the
  decoder's header scan for the next variable field returns exactly the
  specification's next payload position, or nothing when only fixed fields
  remain. This is the characterisation the variable step turns on.
* `first_offset_value`, `fixed_only_payloads`, `stop_at` - the child's end is
  the next offset when there is one and the region end otherwise, and both are
  the same position.
* `header_advance` generalised to an arbitrary prefix/tail split, used for both
  the header and the payload window.
* `step_variable_complete` - **the variable-width field step**.
* `variable_plan` - the decoder's plan for a variable field reduces to the
  payload span [pos, pos+|xs|) with the guard discharged.

Still missing in the walk: the region entries (container, vector, list,
progressive list, the two unions) with their element counts, and the top-level
`go_complete` dispatch that ties the leaves and the walk together into
`image_accepted`. Those remain the blockers for PROOF.bend / END_TO_END.bend.

---

# Run 20260920T131722Z, iteration 0002: proof-checking memory

## What the previous iteration finished (verified present in this workspace)

The completeness half of the decoder proof was finished and every module below
was accepted by the pinned checker at the time it was written:

* `proofs/complete_leaves.bend` - the eight leaf completeness laws.
* `proofs/complete_walk.bend` - the layout walk: fixed and variable field
  steps, the same two steps for sequences, `close_complete` /
  `close_seq_complete`, the region entries for container, progressive
  container, vector, list and progressive list, and the two union regions.
* `proofs/complete_regions.bend` - the eliminators that turn the uniform
  `holds(schema, value, xs, n)` region premise into each composite law's
  inputs, plus `region_legal`, `single_shape` and the union readers.
* `proofs/complete_step.bend` - the child/continuation plumbing for the walk:
  `header_child_bytes`, `payload_child_bytes`, `child_holds`,
  `chain_fixed_step`, `chain_variable_step`, `seq_fixed_step`,
  `seq_variable_step`, `chain_walk_complete`, `seq_step_complete`,
  `seq_close_complete`.
* `proofs/complete_decode.bend` - `complete_goal` and **`go_complete`**: the
  completeness of the packed cursor decoder by the decoder's own recursion,
  over every schema, cursor shape and value constructor.
* `proofs/encoding_domain.bend` - `parts_domain`: the canonical encoding of a
  value of a legal type is a byte string (needed because the public list entry
  point packs its input and the packer only opens a region for bytes).
* `proofs/packed_domain.bend` - `pack_list_domain`: the packer accepts exactly
  those byte strings.
* `proofs/decode_image.bend` - **`image_accepted`**: every byte string in the
  canonical image of a legal type is accepted by the public entry point and
  decodes to exactly the encoded value.
* `proofs/decode_complete.bend` rewritten on top of `image_accepted`, keeping
  `normative_image_accepted`, `image_unique`, `valid_rejected_outside`,
  `decoding_exact` and `rejection_exact` with their original statements.
* `END_TO_END.bend:reject_decide` re-derived from the packed entry point; all
  29 law statements are still byte-for-byte the frozen ones (checked by
  `tools/generate_law_migration.py`, which refuses on drift).
* The ten modules written against the removed fuel decoder were retired to
  comment-only stubs that name their replacements.

## The actual failure this iteration starts from

Three checkers were run concurrently at the end of the previous iteration and
the operator stopped them at ~49 GB of combined physical footprint. A pipeline
ending in `grep` reported exit 0 after the checker had been killed, so the
"PROOF.bend passes" note in the previous log is **not** evidence. Nothing about
those three checks was established.

`tools/generate_proof_memory_report.py` (new, editable) now runs exactly one
checker at a time, samples `proc_pid_rusage` physical footprint (the same field
the operator's watchdog uses), stops the check at a threshold below the
watchdog's 7 GB, and records the real exit status plus whether the checker
actually printed "All terms check.". Results accumulate in
`build/proof-memory.json`.

Measured, one at a time, with that runner:

| module | before | after | note |
|---|---:|---:|---|
| `proofs/packed_pack.bend` | >6.0 GB (killed) | 2.38 GB | statement rewrite below |
| `proofs/packed_pack_acc.bend` | >6.0 GB (killed) | 3.17 GB | inherits the fix |
| `proofs/decode_top.bend` | >6.0 GB (killed) | 3.24 GB | inherits the fix |
| `proofs/decode_canonical.bend` | >6.0 GB (killed) | 3.10 GB | inherits the fix |
| `proofs/validator_selectors.bend` | >6.0 GB (killed) | 3.62 GB | inherits the fix |
| `proofs/type_validator_soundness.bend` | >6.0 GB (killed) | 5.04 GB | plus its own rewrite |
| `proofs/root_total.bend` | >6.0 GB (killed) | 4.76 GB | inherits |
| `PROOF.bend` | 15.36 GB (operator's measurement) | >6.85 GB | still over budget |

## Why it exploded, and what the fix is

A module's cost is dominated by the **law statements it exports**, not by its
proof bodies: a statement is elaborated wherever the module is imported, while
a body is transient. `proofs/packed_pack.bend` exported thirty-one
`pack_short_N` laws, one per possible length of the final partial chunk, each
naming up to thirty-one byte variables and four copies of the same cons spine.
Importing that module cost more than 6 GB, and every module that transitively
imported it - the whole decoder, validator and root chain, therefore
`END_TO_END.bend` and `PROOF.bend` - paid it.

The replacement keeps the same case analysis but hides it behind three small
statements (`chunk_bytes_32_dom`, `chunk_roundtrip`, `tail_view`): reading
thirty-two bytes into a chunk and writing them back is the identity, proved
once by a nested case analysis whose length premise refutes every other shape,
and the partial-chunk view follows from the existing generic `pad` lemmas. The
thirty-one exported laws are gone; `pack_go_view` calls `tail_view` in each
short case. Same theorem, 2.4 GB instead of >6 GB.

`proofs/type_validator_soundness.bend` had the same shape: eighteen
`T.Union{T.Chain{<head>, tail}}` cases repeating one conjunct extraction.
`union_sound_at` now does that extraction once behind an abstract head.

## Standing constraints for the rest of this work

* One checker at a time (the watchdog kills the second one regardless of size).
* Physical footprint, not RSS; 7 GB watchdog, 8 GB ceiling; an over-budget or
  killed check is a failure, never a pass.
* `vendor/bend_sha256` alone elaborates to ~1.6 GB and is protected, so that
  much of every check is fixed cost.


## Operator monitoring fix: 2026-09-20 21:48 Zurich
The proof-memory wrapper piped stdout but waited for exit before reading it. A large diagnostic blocked packed_pack checker PID 10788 in write(), using no CPU for >14 minutes. Operator stopped that checker (not a proof pass) and changed the wrapper to direct output into a persistent log file; full logs are recorded in output_log. Recheck the module with the fixed wrapper; no proof/runtime code was modified by this intervention.

## Root cause of the remaining explosion: a literal depth in the witness family

The last two blow-ups (`proofs/root_domain_broader.bend` and everything that
imports it, i.e. `ROOT_DOMAIN.bend` and `PROOF.bend`) were isolated with the
one-at-a-time runner by checking progressively smaller pieces, each as its own
single checker process:

| probe | what it adds | peak footprint | status |
| --- | --- | --- | --- |
| `build/probe/br_imports.bend` | the module's imports only | 4,939 MB | pass |
| `build/probe/br_valid.bend` | `public_complete` at the witness schema | 4,903 MB | pass |
| `build/probe/br_val.bend` | `root_total` with a concrete *value* | 4,943 MB | pass |
| `build/probe/br_sch.bend` | `root_total` with the concrete *schema* `nest_schema(3n, r)` | 6,596 MB | KILLED |
| `build/probe/br_absd.bend` | the same with a symbolic depth `nest_schema(d, r)` | 4,870 MB | pass |

Writing the literal depth `3n` makes the checker unfold the witness schema
three levels deep, and the root/validity machinery then walks each level
fanout-wide (F = 256*(1+r) children per level, so F^3 nodes at depth three).
With the depth left symbolic the same terms stay stuck and cost nothing.

So the witness family is now proved for *every* depth `d >= 3` instead of
exactly three: `size_positive`, `fits_leaf`, `fits_false_go` (each nesting
level contributes one factor of 256, the 256-byte leaf contributes the last)
and `size_fits_false(d, r, deep)` replace the hand-unrolled depth-3
`size_fits_false`, and `nest_not_serializable` takes `d` and the premise
`Nat.is_le(3n, d) == True{}`. `strictly_broader` and
`root_domain_strictly_broader` take `(d, r, deep)`. This is strictly stronger
than the previous statement (instantiate `d := 3n`, `deep := {==}`), so the
normative content is not weakened.

`proofs/fulu_adapter_complete.bend` was regenerated in the same spirit: the
generator emitted, for every (field position, wrong constructor) pair, a case
whose pattern repeated the whole field prefix and whose body re-derived the
remaining shape conjunct - cubic in the field count, 8.4 MB for
`BeaconStateValue_complete` alone. It now peels one field at a time through a
single shared `peel`/`finish` pair with the peeled equation transported by a
rewrite, so the file is 0.5 MB instead of 11.7 MB.

Measurements after these changes (single checker, macOS physical footprint,
real exit codes, `build/proof-memory.json`):

| module | peak footprint | elapsed | exit |
| --- | --- | --- | --- |
| `proofs/fulu_adapter_complete.bend` | 1,951 MB | 8.1 s | 0 |
| `proofs/root_domain_compat.bend` | 3,761 MB | 28.0 s | 0 |
| `proofs/root_domain_witness.bend` | 3,723 MB | 27.8 s | 0 |
| `proofs/root_domain_broader.bend` | 4,877 MB | 39.2 s | 0 (was killed at 6,542 MB) |
| `proofs/root_sound.bend` | 4,944 MB | 37.3 s | 0 |
| `END_TO_END.bend` | 5,372 MB | 52.9 s | 0 |
| `ROOT_DOMAIN.bend` | 5,242 MB | 54.5 s | 0 (was killed at 6,501 MB) |
| `PROOF.bend` | 5,129 MB | 49.3 s | 0 (was killed above 6,900 MB) |

`PROOF.bend` reports "All terms check." and exit 0 at 5.1 GB, i.e. 1.9 GB below
the watchdog and 2.9 GB below the failure ceiling.

## Conformance re-verified after the proof-memory repair (2026-09-20)

Nothing in `src/`, `types/` or `spec/` was touched by the memory work, and the
suites confirm it:

* `python3 tools/run_runtime_tests.py tests/sha256.test.ts tests/new/*.test.ts`
  - 51/51 tests, 20,009 assertions, 15/15 files, 115 s.
* `python3 tools/spectests.py --report build/spectests.json` - 5440/5440
  official cases passed, 0 failed (11,446 backend requests, all backend exits
  0), 28 minutes. The report records the runtime and source hashes.

Both still exercise the *list-based* public API. The compact-path checks the
operator requires ("meaningful compact-path checks and exact-output
comparisons") do not exist yet, because the compact primary API does not exist
yet; see `docs/LAW_API_MAP.md`.

## Both frozen validators run and pass (2026-09-21)

| validator | command | exit | what it covered |
| --- | --- | --- | --- |
| root-domain acceptance | `python3 automation/root_domain_acceptance.py` | 0 | `ROOT_DOMAIN.bend` law names, `bend PROOF.bend`, 51 runtime tests, 5440 official SSZ cases, `bend END_TO_END.bend` |
| native memory acceptance | `python3 automation/native_memory_acceptance.py` | 0 | the 29-row law map against `memory_bench/law-statements.json`, the whole chain above again, a fresh native build and 15 Bend samples under the 32,000,000-byte decode-overhead cap |

Logs: `build/root_domain_acceptance.log`, `build/native_memory_acceptance.log`.
Fresh native report: `build/native/comparison.json`.

Native decode overhead on this run (medians of three samples per fixture,
worst single sample in brackets): 12,730,368 (12,763,136), 12,845,056
(12,861,440), 12,812,288 (12,976,128), 12,697,600 (12,697,600), 12,730,368
(12,763,136) bytes - worst 12,976,128, i.e. 41 % of the cap, against Go's
3.3-3.4 MB. Root-phase peak 94.1-94.3 MB and whole-run 97.0-97.1 MB for Bend
against 19.1-19.6 MB and 21.9-22.2 MB for Go; those phases are uncapped by the
gate but are where the remaining native memory is, and they still run through
`T.Value` and byte-per-cons lists.

## What this iteration did NOT do

Stated plainly so the next assignment is not misled:

* **The array-indexed migration is still not implemented.** `src/packed.bend`
  still stores input as `+List<Chunk>` and `src/cvalue.bend` still holds
  sequence children in a cons spine, so the operator's "no linked-list
  representation in the primary production path" requirement is unmet. The
  design, the measured constraints of the pinned runtime and the exhaustive
  old-to-new law/API map are in `docs/LAW_API_MAP.md`; every row there is still
  `planned`.
* **The compact API is still not the public API.** `src/ssz.bend` exposes only
  the `+List<U32>` / `T.Value` entry points. `Decode.decode_packed` exists and
  is what `native_bench/driver.bend` measures, but it is not exposed, has no
  compact encode/root counterpart, and the compact-path conformance checks the
  operator requires do not exist.
* **The performance contract is not met and was not re-measured this
  iteration.** The retained evidence in BENCHMARKS.md (978 workloads, 327
  operations) has 5 workloads inside their limit, median ratio 85.8x. No
  performance work was done here, so no fresh run was claimed; re-running it
  unchanged would only reproduce that result.

## Full sequential sweep, and one more import-graph repair (2026-09-21)

`python3 tools/generate_proof_memory_report.py --all --stop-bytes 6.5e9` checked
all 172 targets (every `proofs/*.bend` plus `HASH_PROOF.bend`,
`END_TO_END.bend`, `ROOT_DOMAIN.bend`, `PROOF.bend`) one at a time: 172 pass,
0 fail, 0 over budget, runner exit 0 (`build/proof-memory-sweep.log`,
per-module records and footprint traces in `build/proof-memory.json` and
`build/proof-memory-logs/`). The highest peaks in that sweep were
`type_validator_complete` 6,202 MB and `type_validator_soundness` 6,045 MB -
under the watchdog, but too close to it.

Both came from one import: `proofs/validator_selectors.bend` imported the whole
`proofs/decode_canonical.bend` (and through it `src/decode`, `src/ssz` and
`decode_top`) for a single lemma, `word_equal_reflexive`, which depends on
nothing but Base. That lemma and `word_compare_reflexive` now live in
`proofs/word_facts.bend`; `decode_canonical` and `validator_selectors` use them
from there. Statements are unchanged.

| module | before | after |
| --- | --- | --- |
| `proofs/validator_selectors.bend` | 3,617 MB | 1,801 MB |
| `proofs/type_validator_soundness.bend` | 6,045 MB | 2,695 MB |
| `proofs/type_validator_complete.bend` | 6,202 MB | 3,756 MB |
| `PROOF.bend` | 5,728 MB (sweep) | 5,290 MB |
| `END_TO_END.bend` | 5,281 MB (sweep) | 5,669 MB |
| `ROOT_DOMAIN.bend` | 5,397 MB (sweep) | 5,262 MB |

The same file measured twice varies by a few hundred MB between runs (for
example `PROOF.bend` at 5,129, 5,290 and 5,728 MB on three runs, all exit 0),
so differences of that size are noise. The largest checks are now the three
roots at 5.3-5.7 GB, i.e. 1.3 GB or more under the 7 GB watchdog; a single SSZ
checker never exceeded 6.21 GB in any run of this iteration after the repairs.

## Generators reproduce the repaired proof modules

Three of the repaired modules are generated. Rerunning an unrepaired generator
would silently bring the memory blow-ups back, so the generators now emit the
repaired forms and were checked to reproduce the checked files byte-for-byte:

* `tools/generate_fulu_adapter_complete.py` -> `proofs/fulu_adapter_complete.bend`
  (shared `peel`/`finish` walk; regenerated and checked, see above);
* `tools/generate_type_validator_soundness.py` ->
  `proofs/type_validator_soundness.bend` (emits `union_sound_at`; output
  identical to the checked file);
* `tools/generate_type_validator_complete.py` ->
  `proofs/type_validator_complete.bend` (emits `union_complete_at`; output
  identical to the checked file).

The other edited proof modules (`packed_pack`, `packed_pack_acc`,
`root_domain_witness`, `root_domain_broader`, `decode_canonical`,
`validator_selectors`, `word_facts`) and `ROOT_DOMAIN.bend` are hand-written; no
generator writes them.

## Final state of this iteration

`python3 automation/root_domain_acceptance.py` was run again after the last
refactor (the reflexivity-lemma move) and exits 0:
`bend PROOF.bend` "All terms check.", 51/51 runtime tests, 5440/5440 official
SSZ cases, `bend END_TO_END.bend` "All terms check."
(`build/root_domain_acceptance.final.log`).

One statement in the frozen-named set changed, and it changed in the
strengthening direction: `root_domain_strictly_broader` (and
`Broader.strictly_broader`, `Witness.nest_not_serializable`,
`Witness.size_fits_false`) now quantify over the nesting depth `d` with the
premise `Nat.is_le(3n, d) == True{}` instead of fixing `d = 3`. Instantiating
`d := 3n` with `deep := {==}` gives exactly the previous proposition, so nothing
is weaker; an auditor should check that instantiation first. The 29 END_TO_END
propositions are byte-for-byte unchanged and
`automation/native_memory_acceptance.py` verifies that against
`memory_bench/law-statements.json`.

`PROOF_STATUS.md` was not edited in this iteration (it is outside the editable
set); its timestamp predates this work and its "Current state" section is stale
with respect to everything recorded above.

## Iteration 5 checkpoint: SHA package migration and a hard proof constraint

### Pinned dependency

`src/digest.bend` now hashes through the BendHub package
`0xda83506fb9f059ead7afcfa2f498df5f` (Giulio2002/bend-sha256), imported as
`import 0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend`. Its sole production
entry is `sha256(words: Array<U32>, byte_length: Nat) -> Maybe<&1, Array<U32>>`:
packed four-bytes-per-word input, eight-word output, no list anywhere. The
module checks ("All terms check.").

Package facts read from the installed source, not assumed:

* `sha256.bend` delegates to `buffer.bend`, which wraps `packed.bend` and
  returns `buffer.digest`, a balanced eight-leaf `Array<U32>`.
* `LAWS.bend` provides `sha256_array_correct`: the production array API equals
  `Buffer.result(PackedSpec.hash(words, byte_length))`, i.e. it is refined
  against the package's own independent *packed* specification.
* `package.bend` states plainly that the universal bridge from packed bytes to
  the historical byte-list FIPS theorem is **not** claimed. `LAWS.bend` has
  `sha256_bytes_correct` only for the legacy byte-list model.
* The package's `fips.bend` and `state.bend` are byte-identical to
  `vendor/bend_sha256/fips.bend` and `.../state.bend` (verified with `diff`),
  which matters because the frozen `spec/merkle.bend` hashes through the
  *vendored* FIPS module.

### Measured hashing cost (native C, one thread, Apple M4)

50,000 dependent 64-byte hashes, accumulator feeding the next input so no
iteration is loop-invariant (`benchmarks/probes/sha_paths.bend`,
`benchmarks/probes/sha_package.bend`):

| path | ns per 64-byte hash |
| --- | ---: |
| `src/sha256.hash` byte-list entry (old runtime path) | 960 |
| vendored `Core.fips_compress16`, sixteen words passed directly | 280 |
| pinned package `sha256(Array<U32>, 64n)`, incl. array build and result fold | 380 |

Merkleizing 32,768 leaves (`benchmarks/probes/merkle_paths.bend`): the current
`src/tree.bend` list path takes 46 ms, a streaming fold over eight-word chunk
records takes 7 ms. Go fastssz hashes a 64-byte node in about 100 ns on this
machine, so the packed path is roughly 3.8x Go per hash, inside the 10x
hash_tree_root limit, while the list path is not.

### Hard constraint discovered: SHA terms must stay stuck in proofs

Two bounded probes, each run as a single checker with the memory runner:

* `build/probe_lazy.bend` - reflexivity `{X == X}` where
  `X = F.compress(F.schedule(48n, [w,...,w]), F.constants(), F.initial())`
  with a *concrete sixteen-element* list of a symbolic word: **timed out at
  120 s** (152 MB, exit -9). The checker normalizes instead of comparing
  structurally, and symbolic SHA normalization is exponential because each
  state word is consumed several times per round.
* `build/probe_stmt.bend` - the same term appearing only in a law *statement*,
  with the proof being the premise itself: **timed out at 90 s**. So it is the
  elaboration of the type, not the conversion check, that explodes.

Consequences, which the proof architecture must respect:

1. No proof may contain a SHA application whose message has a concrete length
   or concrete block count. The existing SSZ root proofs are safe because they
   hash `List.append(left, right)` for *symbolic* byte lists.
2. The package's own proofs use the same discipline: every block-level lemma in
   `packed_proof.bend` keeps `extra: Nat` symbolic, so `F.schedule(extra, ws)`
   never unfolds.
3. Therefore the missing packed-to-FIPS bridge cannot be proved "at 64 bytes";
   it has to be proved *universally* (symbolic array, symbolic byte length and
   symbolic `extra`), and only then instantiated. That is the required bridge;
   it is not yet written, and no root law may claim it in the meantime.

An earlier attempt to prove the 64-byte block structure by reduction
(`build/probe_block64.bend`) was killed at 5 GB; it is recorded here as a
failed approach so it is not retried unchanged.

## Iteration 5: the indexed runtime exists and is fast

New modules, all checking with the pinned 2.0.16 checker:

* `src/buffer.bend` - `Buf` is one packed `Array<U32>`, four bytes per word,
  little-endian, plus a byte length. Byte j is word j >> 2 at bit (j & 3) * 8.
  There is no chunk list and no cons cell per byte. `Array<U32>` has kind
  `Type`, so the buffer is linear: every reader takes it and gives it back,
  which is the documented input-ownership contract. `alloc` + `fill_at` let a
  file be read in 64 KiB pieces straight into the buffer, so a 2.74 MB input is
  never a byte list in full.
* `src/sizes.bend` - fixed sizes as `U32` instead of the spec's unary `Nat`, so
  a 2^40 list limit is never materialised. Limits are still compared against
  the spec's `Nat` with `Nat.is_le`, which stops at the actual count.
* `src/scan.bend` - the validating decode pass over `Buf`. Bend has no mutual
  recursion, cannot match a computed value, and requires a self-call to leave
  every argument unchanged until one shrinks, so this is *one* self-recursive
  definition: a `Nat` fuel first, the buffer-and-just-read-value pair last, a
  `tag` saying what the value is, and a continuation `Frame`. Every decision is
  made by a pure selector (`usel`/`bsel`/`fsel`/`ssel`) and fed back as data.
  It checks exact fixed sizes, list limits against the schema's `Nat` limit,
  boolean bytes, bit-vector padding bits, bit-list terminators, and the offset
  discipline of variable-size containers and lists (first offset equals the
  fixed part, each child's window ends where the next begins, the last ends at
  the window end).

Measured on the real mainnet fixture (`benchmarks/probes/scan_probe.bend`,
native C backend, one thread, Apple M4), reading
`build/native/case_0.ssz` (2,740,473 bytes, the decompressed official fixture):

```
SIZE=2740473
VALID=True
SCAN_MS=3
TRUNCATED=False
OVERLONG=False
```

For scale: Go fastssz decodes the same fixture in about 1.3 ms on this machine
(iteration 2's native comparison), so the 5x budget is 6.5 ms. The previous
compact decoder needed 18-20 ms and the legacy public API 230-256 ms. The
indexed pass is 3 ms and rejects the one-byte-short and one-byte-long windows.

The Fulu schema set uses only `Chain`, `End`, `Container`, `ListOf`, `Vector`,
`ByteVector`, `ByteList`, `BitVector`, `BitList`, `Unsigned` and `Boolean`
(counted in `spec/fulu_schemas.bend`): no unions, no progressive types. The
scan implements exactly those plus `Null` and `Named`; `Union`,
`CompatibleUnion`, `Repeat` and the progressive forms currently reject and are
listed here as *not yet implemented*, which matters for the generic API even
though no Fulu type needs them.

Not done yet, in order: the decoded descriptor value and its accessors, the
compact encoder, streaming merkleization on top of `src/digest.bend`, wiring
the official 5440-case corpus through this path, and every proof.

## Iteration 5, continued: the compact root, and a compiler wall

### What now exists and is verified

| module | what it is | evidence |
| --- | --- | --- |
| `src/buffer.bend` | packed `Array<U32>` byte storage, four bytes per word, little-endian; `alloc`/`fill_at` let a file be read in 64 KiB pieces straight into it | `benchmarks/probes/buffer_probe.bend`: byte-list checksum, byte-at checksum and word-scan checksum all agree at 2,740,472 bytes |
| `src/sizes.bend` | fixed sizes as `U32` instead of the spec's unary `Nat` | checks |
| `src/cschema.bend` + `types/fulu_cschema.bend` | the compact runtime schema and all 109 generated named schemas, with strides, field header offsets, machine-sized limits and merkle depths precomputed by `tools/generate_cschema.py` from the frozen `spec/fulu_schemas.bend` | both check; 109 definitions |
| `src/cscan.bend` | validating decode over the buffer | accepts the real mainnet BeaconState fixture in **1 ms** native, rejects the one-byte-short and one-byte-long windows |
| `src/digest.bend` | the pinned BendHub packed SHA-256 | 0.38 us per 64-byte node |
| `src/merkle_fast.bend` | streaming merkleization from the buffer, level stack in a duplicable indexed tree | 12 cross-checks against the existing proved `src/tree.bend` agree, including empty, padded and exactly-full trees |
| `src/croot.bend` | schema-driven `hash_tree_root` over the buffer | 8 differential cases against the proved `src/root.bend` agree; **10 official fixture types root exactly**: Fork, Checkpoint, Validator, BeaconBlockHeader, Eth1Data, AttestationData, HistoricalSummary, SyncAggregate, Attestation, ExecutionPayloadHeader |

Two real bugs were found and fixed by those checks, not by inspection:

1. Merkleization of an exactly-full tree returned the zero-padded root instead
   of the completed stack entry (`close_pick`).
2. A leaf whose own merkle tree is deeper than one chunk overwrote the stack
   levels its parent container was accumulating in. Leaves now take the
   segment above their parent's. This is what made SyncAggregate - a container
   holding a 512-bit vector and a 96-byte signature - root incorrectly.

### The compiler wall, measured

The pinned 2.0.16 compiler cannot build a native binary that contains both the
root walker and a file reader. Peak compile footprints, each measured with
`build/capped_build.py` (a self-imposed cap below the operator's watchdog):

| program | compile peak |
| --- | ---: |
| file reader + `src/cscan.bend` (whole validator) | 2.35 GB |
| file reader + `src/merkle_fast.bend` with a symbolic length | 1.84 GB |
| `src/croot.bend` with a runtime-seeded literal buffer | 3.42 GB |
| file reader + `src/croot.bend`, any schema, any reader shape | **over 6.5 GB** |

It is superadditive, not a size limit on either part, and it is the same on the
JavaScript backend, so it is the shared frontend rather than the C backend.
Things tried and measured, none of which helped: a single dispatcher entry
point, a recursion guard on the entry, a recursion guard between reader and
walker, flattening the walker's nested result pair into a named record and then
back into a plain pair, removing the second linear resource (the merkle stack
is now a duplicable indexed tree rather than an `Array`), moving the fifteen-way
schema dispatch into a pure planner, and collapsing the eight chained chunk
readers into one loop. Each reduced the walker; none brought reader + walker
under the budget.

Consequence for this session: the BeaconState root is verified *interpreted*
and on ten smaller official fixtures natively, and the root of a 2.74 MB
BeaconState ran in **76 ms** natively in the last build that did compile (which
predates the segment fix, so that number is indicative, not final). Go fastssz
roots the same fixture in 7.6 ms, so this is about 10x - at the contract limit,
before any tuning.

The remaining structural fix, not yet done, is to merge the validator and the
root walker into a single walker with a mode flag. That halves the number of
large recursive definitions in a program, and a program that validates and then
roots the same buffer becomes a self-chain, which is the shape that compiles.

## Iteration 5, continued: the wall was the schema table; native compact path measured

### The compiler wall, re-diagnosed

The "reader + root walker exceeds 6.5 GB" conclusion above was wrong about its
cause. A program that only imports `types/fulu_cschema.bend` and prints one
fixed size cost **3.98 GB** to compile (`build/t_sch.bend`); without the
109-way `by_index`/`name_at` tables it cost 0.22 GB (`build/t_sch3.bend`). The
pinned compiler elaborates every definition of every imported module, so every
probe paid for those tables. Fixes in `tools/generate_cschema.py`:

* nested named schemas are emitted as calls to their definitions instead of
  being expanded again (27 KB module instead of 72 KB; structurally identical
  types share a definition);
* the index table moved to its own module, `types/fulu_cschema_index.bend`,
  imported only by multi-type programs (1.30 GB alone, `build/t_idx.bend`);
  `name_at` was dropped (names are in `build/cschema-index.json`).

After that the decode driver compiles at 1.8–2.1 GB, and the full driver
(reader + validate + root + serialize, `native_bench/driver_compact.bend`) at
5.3–6.0 GB.

Also measured: the compiler's peak is **not deterministic**. The same source
compiled at 5.21 GB, 5.23 GB and over 6.5 GB on consecutive runs. So the
earlier "literal path compiles, environment path does not" finding was most
likely this variance rather than a real rule; the driver now takes its paths
from the environment again. `native_bench/run.py` compiles under a 6.5 GB
footprint cap and retries a capped attempt (at most 4), recording every attempt.

### Three bugs the native BeaconState runs found

1. **Merkle depth ≥ 32** (`src/merkle_fast.bend`): `bit(x, k)` and
   `shl_by(1, depth)` only saw the low five bits of the shift. For the
   2^40-limit registry lists (validator list depth 40, balances 38), `bit(n, 40)`
   read bit 8 of the count and `close` could take a non-full list for a full
   tree. BeaconState rooted to `f282…` instead of `cc7f…`. Fixed with
   `bit_in`/`full_in`: no U32 has bits at 32 and above, and no tree of depth
   32 or more is full.
2. **Empty fixed-element list** (`src/cscan.bend`, `CList`): for length 0 the
   scanner went to "deliver" with a fresh `FRep` whose `left` was `0 − 1`
   instead of the parent frame, so a state with any empty list (fixtures 2, 3
   and 4) was rejected, after a 120–185 ms run to the fuel limit. Fixed with the
   same `fsel(empty, …)` the `CVec` case already used.
3. Found by the first memory run: the stop-point `B.drop` fold copies
   O(n log n) words on this runtime (matching `ANode` splits blocks, per the
   emitted C's block-layer comment), inflating both bracketing runs' baseline
   to 15.7 MB. The stop path now just drops the buffer; the baseline is 7.1–7.4 MB.

Independent oracle: `build/ref_validate.py` is a Python SSZ validity checker
over the generator's parse tree. It accepts all five fixtures and localised
bug 2 to the empty lists.

### Serialize, field access, encode

* `B.emit` lists the bytes of a word range by indexed `Array.get`. A first
  version walked the `ANode` tree and took 21–23 ms for BeaconState; the
  indexed loop takes 10 ms, including writing the file in 64 KiB pieces.
* `src/access.bend` (new): a `View` is a validated window. It provides
  `field`, `field_schema`, `count`, `elem`, `elem_schema`, in-place scalar reads
  (`uint64`, `boolean`, `byte`) and `encode`, which returns a fresh packed
  `Buf` of exactly the window, copied a word at a time with the tail masked.
  `benchmarks/probes/access_probe.bend` + `build/access_check.py`: **49/49**
  values across the five fixtures match an independent Python reading of the
  same bytes. The checks cover slot, the validator/balance/historical-root/
  eth1-vote counts, the last validator's `effective_balance`, a
  `proposer_lookahead` element, the execution payload header's window, its
  `extra_data` window (a variable field inside a variable field, unaligned),
  and the byte sum and length of the header's compact encoding (605–615 bytes,
  unaligned).

### Native evidence, compact path (2026-09-21)

`native_bench/run.py` (now driving `native_bench/driver_compact.bend`), five
BeaconState fixtures × 3 alternating samples, exit 0, `complete: true`, all
samples `verified`, roots agree with Go on every fixture:

* Bend decode overhead: medians 0–65,536 bytes, worst sample 180,224 bytes
  (limit 32,000,000). Go: 3.4 MB.
* Bend post-input baseline 7.1–7.4 MB (Go 8.2 MB); Bend whole-process peak
  7.5–7.9 MB (Go 21.9–24.1 MB; the previous Bend list path was ≈ 97 MB).
* Latency: decode 1–2 ms (Go 1.3 ms), root 82 ms (Go 7.5–7.7 ms, **10.6–10.9x,
  over the 10x limit**), serialize 10 ms including writes (Go 0.27–0.34 ms,
  **30–37x**).

Full tables are in MEMORY_REVIEW.md.

### Still open (unchanged in kind)

* Proofs for every compact module and the universal packed → FIPS SHA bridge.
* The 5440 official cases through the compact API. This needs progressive
  list/bit-list/container and compatible-union forms in the compact schema,
  plus runtime-supplied schemas for `ssz_generic`, because compiling one
  program per case is impossible at these compile costs.
* The per-type performance gate (`benchmarks/run.py` still measures the legacy
  path), root below 10x, and serialize below 5x.
* Removing the legacy list API from the production surface. It is kept for
  now because the existing checked proofs are about it.

## Iteration 5, continued: every Fulu type through the compact API; performance work

### Any-type programs and conformance

* `types/fulu_cschema_index.bend` is now a balanced binary dispatch on the
  index bits (0.46 GB to compile) instead of one 109-way `match` (1.30 GB). A
  program with validator + root walker + the flat table did not fit the 6.5 GB
  compile cap in five attempts; with the balanced table it compiles at
  5.0–6.35 GB. All 108 testable indices resolve to the same schema as the flat
  table (`build/t_bidx`, `build/t_idx2`).
* `benchmarks/compact/{io,dec,enc,root}.bend`: native programs, one per
  operation, any type by `SSZ_INDEX`. `root` validates first and exits 1 on
  rejection.
* **All 295 official `ssz_static` cases (59 Fulu types) pass through the
  compact primary API with the exact 32-byte root** (`build/static_conformance.py`
  → `build/static_conformance.json`; `root` prints the root as `ROOTWORDS`).
* **1,180 malformed variants** of those cases (truncated, extended, first
  offset 0xffffffff, first byte flipped) **agree with the independent Python
  validator** `build/ref_validate.py` on every one: 437 invalid ones rejected,
  743 still-valid ones accepted (`build/static_mutations.py` →
  `build/static_mutations.json`).
* `benchmarks/probes/strictness.bend`: values stored with `Array.set` are
  evaluated when stored (20,000 SHA-derived stores cost 5 ms, the price of
  20,000 hashes), so a benchmark that consumes one word of an encoding still
  pays for all of it.

### Performance changes, each re-verified

Each change below was followed by the 12 merkle cross-checks, the 8
differential roots, and a re-run of the static conformance and mutations.

| change | effect |
|---|---|
| `D.hash_pair` builds its message with `Array.new` + 16 `set`s and reads the result with 8 `get`s instead of `ANode` construction/matching, which copies blocks on this runtime | 76 → 52 ms per 200,000 nodes (`benchmarks/probes/hash_variants.bend`, same digest) |
| digest-stack index descent shifts the index once per level instead of computing a five-step variable shift | BeaconState root 76 → 72 ms |
| aligned whole chunks: eight raw word reads, one record | 72 → 69 ms |
| generator marks `Vector/List[Bytes32]` as chunk-packed (a 32-byte vector's root is its chunk) | BeaconState root 69 → 32–40 ms uncontended: 81,920 elements no longer walked one frame at a time |
| `plain` flag: a fixed value built from uints, byte vectors and whole-byte bit vectors is valid iff its length is right, so the scanner skips its fields and elements | AttestationData decode 551 → 40–80 ns; Attestation 830 → 340 ns; BeaconState decode under 50 µs |
| digest stack grown on demand (one leaf, split along written paths) instead of building 511 nodes per root call | small-container roots −40 % |
| depth-0 leaves read their single chunk directly, no stack round trip; partial chunks built in one record | AttestationData root 9.0 → 6.2 µs, Checkpoint 1.8 → 1.0 µs |
| benchmark loops take the schema once instead of dispatching per operation | per-op overhead removed from Bend's side |

Where the remaining root time goes: SHA-256 is about 55 % of a small
container's root. Go hashes with the CPU's SHA instructions (~0.06 µs per
node); the pinned pure-Bend package takes ~0.26 µs, and hardware SHA is not
allowed. About a third of the hashing in a list-bearing container recomputes
zero-subtree roots during the ascent, which fastssz reads from a precomputed
table. A constant table here would need a proof about concrete SHA values,
which this checker has failed to elaborate (see the SHA checkpoint above), so
it is not used.

## Iteration 7: hasher, and measured dead ends (2026-09-21)

* `benchmarks/probes/caf.bend`: a closed top-level definition is evaluated
  again at every reference (20 references to a 20,000-hash chain: 102 ms), so a
  zero-hash table cannot live in a global. It now lives in a **hasher** value:
  the digest stack's top segment (slots 960..1023) holds Z(0..63), computed by
  hashing (`MF.hasher`, 63 hashes). The caller prepares it once and passes it to
  every root (`API.run_with`, `Ssz.root_with`), as fastssz keeps a package-level
  zero-hash table. An ascent is now one hash per level instead of two.
  Attestation root 16.0 → 13.0 µs, AggregateAndProof 20.6 → 16.6 µs,
  DataColumnsByRootIdentifier 4.3 → 3.2 µs. All 295 ssz_static roots still
  exact, and 0 mutation disagreements.
* `benchmarks/probes/root_overhead.bend` (100,000 roots on one buffer): a
  one-chunk root costs 40 ns, a 64-byte two-chunk root 810 ns (of which one hash
  is ~260 ns), and Checkpoint 1,130 ns. The rest is the digest stack.
* Tried and reverted, with measurements:
  - 16-way stack nodes (3 levels): unrolled access inlined at every call and
    pushed programs over the 6.5 GB compile cap (three failed attempts);
  - 4-way nodes with recursive access: compiles, but slower (64-byte root 0.98
    against 0.81 µs, Checkpoint 1.35 against 1.13 µs);
  - holding level-0 left siblings in a loop register instead of the stack:
    slower (1.32 µs for the 64-byte root), because the selector results are
    deferred rather than computed.
* `benchmarks/probes/lazy_args.bend`: arguments of an untaken branch are not
  evaluated. `benchmarks/probes/nat_cost.bend`: `U32.to_nat` fuel is free.

### Merkle scratch in the input buffer; separate entry points; check trees

* **Merkle scratch is now packed words in the caller's buffer**
  (`src/buffer.bend`): 1024 digest slots of eight words after the data, at
  word (n + 3) / 4. The level stack (64-slot segments, one per nesting level)
  and the zero-subtree roots Z(0..63) (slots 960..1023, computed by hashing the
  first time a buffer is hashed, detected by one word read) live there. Input
  buffers reserve it at allocation; a buffer without room (an encode output) is
  copied once into one with room the first time it is hashed
  (`B.with_scratch`). The duplicable digest tree (`MF.DStack`) and the
  caller-held hasher are gone. `benchmarks/probes/root_overhead.bend`: a 64-byte
  root went 0.81 → 0.33 µs and Checkpoint 1.13 → 0.52 µs.
* **Separate entry points** (`src/api.bend`: `validate_in`/`validate`,
  `root_in`/`root`) replaced the single dispatcher, which by now cost more
  compile memory than it saved: the validator-only program compiles at
  ~3.4 GB, the encode program at ~3.2 GB, and root at 3.6–4.5 GB. Before, all
  three straddled the 6.5 GB cap. Measured on the way: frontend check ~1 GB,
  C emission 4–6 GB; a program with the validator alone costs 2.1 GB, root
  alone 3.3–4.5 GB, and both chained directly a steady 5.2 GB. The root
  benchmark no longer validates in-process: the runner and the conformance
  checks validate every input with the decode program first.
* **Check trees** (`CCont.checks`/`nchecks`, generated): each container's field
  tree filtered to the fields validation must visit (variable-size, or fixed
  but not plain). The scanner walks only those; access and root keep the full
  tree. Validator decode 280 → 120 ns, AggregateAndProof 400 → 300 ns,
  BeaconBlockBody 4.7 → 3.3 µs.
* Re-verified after every step: 12/12 merkle cross-checks, 8/8 differential
  roots, **295/295 ssz_static exact roots** through `compact-dec` +
  `compact-root`, **0/1,180 mutation disagreements**
  (`benchmarks/evidence/static_conformance.json`, `static_mutations.json`).
* Process slip, recorded honestly: one diagnostic compile
  (`/usr/bin/time -l bend benchmarks/compact/dec.bend -o build/t_dec.c`) ran
  outside the footprint cap and peaked at 7.01 GB of physical footprint. It
  completed in 9 s and was not a proof check, but it breached the cap
  discipline. Every later compile went through `benchmarks/checks/capped_build.py`.

### All 5,440 official cases through the compact primary API (native)

* Generic forms added to the compact runtime:
  - progressive lists and bit lists are list and bit-list nodes with no limit
    and merkle depth 255, the progressive marker; `src/merkle_fast.bend`
    merkleizes them in 4^k-chunk segments whose roots are kept in scratch and
    folded right to left, for byte ranges and for pushed element roots alike;
  - progressive containers (`CPCont`) validate and read like containers, and
    are rooted over a slot list (fields at active positions, `CNull` zero
    chunks elsewhere), then mixed with the active mask (at most 31 positions,
    refused explicitly beyond that; the official cases use at most 22);
  - compatible unions (`CUnion`) have a selector-indexed option tree. The
    scanner validates the value after the selector byte as the selected
    option, and the root walker roots it as a one-element frame whose close
    mixes in the selector.
* `tools/generate_cschema_generic.py` compiles the 144 distinct ssz_generic
  schemas described by the frozen `tools/test_schemas.py` into
  `types/generic_cschema.bend` with a balanced index. Illegal types (the
  structural rules of `spec/type_legality.bend`: empty vectors, bit vectors,
  byte vectors, containers, bad active lists, bad selectors, duplicate names)
  compile to a schema no input validates against. Union option compatibility
  (`spec/compatibility.bend`) is not re-derived, and no official case needs it.
* `tools/generate_generic_programs.py` derives `benchmarks/compact/g{dec,enc,root}.bend`
  from the Fulu programs.
* **Native results:** `benchmarks/checks/static_conformance.py` 295/295
  (decode accepts, exact 32-byte root); `benchmarks/checks/generic_conformance.py`
  **5,145/5,145** (valid: decode accepts, exact root from meta.yaml, byte-exact
  re-encode; invalid: rejected by decode); `static_mutations.py` 0/1,180
  disagreements. Evidence: `benchmarks/evidence/{static,generic}_conformance.json`,
  `static_mutations.json`.
* **JS (Bun) compatibility evidence**, labelled as such: the 51 runtime tests
  pass (20,009 assertions, `benchmarks/evidence/runtime_tests.log`, peak
  5.21 GB under `benchmarks/checks/capped_run.py`). They unit-test individual
  modules, not the compact API.

## Iteration 8: fresh native checks, model/primary split for proofs, proof roots

* Fresh native correctness on the current code (clone-based encode, natural
  buffer capacity): 295/295 static roots, 0/1,180 mutation disagreements,
  5,145/5,145 generic cases, 49/49 field-access checks
  (`benchmarks/evidence/*`).
* The proofs now import `src/model.bend` and `types/fulu_model.bend`, the
  list-based model API that the frozen laws are about. `src/ssz.bend`
  re-exports the model definitions (aliases of `Model.*`) next to the compact
  API. `types/fulu.bend` is generated together with `types/fulu_model.bend` and
  is the same text plus the compact entries. The law texts are unchanged; only
  import paths changed. The first ROOT_DOMAIN check in this iteration was
  capped at 6.85 GB, and removing the compact runtime from the proofs' imports
  was the first repair.
* The depth-3 corollary law added in iteration 7 was the actual cause: with it,
  ROOT_DOMAIN was capped at 6.89 GB even with the split, and without it the
  check passes at 5.03 GB. It was removed; docs/LAW_API_MAP.md documents the
  d := 3 instantiation instead.
* Proof roots, one checker at a time under `benchmarks/checks/capped_run.py`
  (6.8 GB cap), full logs in `benchmarks/evidence/check_*.log`:
  ROOT_DOMAIN exit 0 "All terms check." 5.03 GB 39 s; END_TO_END exit 0
  5.00 GB 38 s; PROOF exit 0 5.28 GB 42 s. No `unsafe` in any root. These cover
  the list-based model API, not the compact runtime.


### Operator review: reusable array foundation
Read docs/OPERATOR_ARRAY_PROOF_REUSE.md before re-deriving the compact array foundation. DSA already has actual Base.Array laws; adapt with SSZ zero-warning/soundness requirements intact. This is a reuse lead, not proof acceptance.

### Frozen validators

* `automation/native_memory_acceptance.py` exit 0 (run under
  `benchmarks/checks/capped_run.py`, process-tree peak 6.50 GB, 1,735 s; log in
  `benchmarks/evidence/native_memory_acceptance.log`). That covers the law map,
  the root-domain gate (proofs, 51/51 runtime tests, 5,440/5,440 JS spectests)
  and the native harness: all 15 Bend samples verified, worst decode overhead
  131,072 bytes, roots agree with Go. Archived:
  `benchmarks/evidence/native-comparison.json`, `spectests-js.json`,
  `driver-emitted.c.gz`, `driver-artifacts.sha256`.
* `automation/performance_gate.py` runs `benchmarks/run.py` with the operator's
  interpreter (`/Users/monkeair/auto-implementer/.venv/bin/python`), which has
  neither python-snappy nor a YAML library. Installing them would modify a
  dependency outside the editable scope, so the runner now reads fixtures with
  `benchmarks/snappy_block.py`, a pure-Python raw Snappy block decoder checked
  byte for byte against python-snappy on all 5,440 fixtures
  (`benchmarks/checks/snappy_check.py`, 0 mismatches), and reads the one-line
  `roots.yaml` with a pattern that matches all 295 static fixtures. A smoke run
  under that interpreter (`--only Checkpoint,BeaconState`) passed before the
  gate was started.


## Operator benchmark interruption: independent calibration

Read docs/OPERATOR_BENCHMARK_CALIBRATION.md. The operator is stopping only the inefficient timing run and applying separate per-side calibration; restart full performance gate with source provenance intact. No runtime/proof work discarded.

### First performance-gate attempt, and decode fast paths

* The first `automation/performance_gate.py` run was stopped by the operator at
  row 513, while it was measuring `Hash32`, to fix the runner's calibration. Bend's
  length-check decodes calibrated to 5,000,000 operations and Go then ran that
  many 300 µs decodes. `benchmarks/run.py` now calibrates each side
  independently (operator change, kept as is). Partial log:
  `build/performance/benchmark-partial-513.log`. Rows over 80 % of their limit
  in it: DataColumnsByRootIdentifier.deserialize 4.9x, Fork.deserialize
  4.1-4.3x.
* Decode fast paths, each re-verified with 295/295 static roots, 5,145/5,145
  generic cases, and mutations (now 5,455 variants, including +1 on each of the
  first 16 header words; 742 invalid; 0 disagreements with the independent
  validator):
  - `valid_in` answers a plain schema with the length check alone (Fork,
    Checkpoint, ForkData, BlobIdentifier, BLSToExecutionChange: below 20 ns);
  - variable fields whose validity depends on their length alone (byte lists,
    lists of plain elements) are checked inline when their end is known;
  - "simple" containers (generator flag: variable fields are all such lists)
    validate one offset per step (tag 15): DataColumnsByRootIdentifier
    156 → 101.5 ns (Go 32 ns), Attestation 350 → 258 ns.

### Second performance-gate run: ratios, then a provenance rejection

* Completed: 978 workloads, 327/327 required operations, 0 skipped,
  685 rejection checks with 0 disagreements. 975 workloads were within limit;
  `Validator.deserialize` was at 5.12-5.19x (Bend 165.6 ns, Go 31.9 ns).
* The gate then rejected the report for `missing/stale source
  benchmarks/evidence/generic_conformance.json`: the frozen gate hashes every
  `.json`/`.py` under `benchmarks/`, evidence included, but the runner's
  manifest skipped `benchmarks/evidence`. The runner now hashes it, and a check
  confirms that all 345 files the gate lists are in the manifest. Evidence is
  refreshed before a gate run, never during one.
* Validator: fixed containers whose checks are all single bytes (booleans,
  the last byte of a partial-byte bit vector) now use the "simple" fast walk
  too (tag 16: one step per checked byte). Validator decode 165.6 → 118 ns.
  Re-verified: 295/295, 5,145/5,145, 0/5,455 mutation disagreements.

### Memory gate reruns (2026-09-21, late morning)

* A rerun failed in `native_bench/run.py`'s representativeness check: the full
  run's sampled "decode window" reached 7.72 MB against a 7.18 MB kernel peak
  for the stop-after-decode process. Decode now takes under a millisecond, and
  the window ends 60 ms after Python *receives* the decode marker; on the
  loaded machine that receipt lagged the print by more than the 150 ms settle,
  so root- and serialize-phase samples fell inside the window. The driver now
  stays idle 600 ms after the decode marker (`settle_long`). The check itself is
  unchanged. `native_bench/run.py` alone then passed (worst sample 229,376 bytes).
* The next full gate run failed in the JS spectest stage: 1,214 cases failed with
  `bend loader: pinned bend changed (e3b0c442…)`. That hash is the SHA-256 of an
  empty file: the pinned compiler was momentarily empty while it was read. The
  binary matches its pin before and after (`da9bc514…`, mtime Sep 19), but
  `~/.bend/bin` was modified at 10:59 during the run. This was outside
  interference with the shared toolchain directory, not a test result. The log is kept at
  `build/native_memory_acceptance-interrupted-bend-binary.log`, and the gate was rerun.
* The rerun got through the JS stage: runtime tests 51/51, spectests
  5,440/5,440, END_TO_END "All terms check.". It then failed in
  `native_bench/run.py`'s build: the driver's C emission hit the 6.5 GB compile
  cap on all four attempts (6.53 GB each; the executable build needed two). The
  pinned `bend` is a Bun/JavaScriptCore executable, and on this machine, which
  was also running an unrelated 4.5 GB `bend` job, its collector fell behind.
  Measured on the unchanged driver, one attempt each: 6.20 GB without a hint;
  3.77 GB and 2.98 GB with `BUN_JSC_forceRAMSize=3000000000`. The emitted C was
  byte-identical in every case (`4f4302b5…`, the same as the earlier build). Both
  runners (`native_bench/run.py`, `benchmarks/run.py`) now pass that variable
  to compiler processes only and record it in their reports
  (`bend_compile_env`). The measured programs are native C and do not see it.
  The compiler binary, flags and output are unchanged. Log:
  `build/native_memory_acceptance-compile-cap.log`.
* The rerun with the compile hint passed: `automation/native_memory_acceptance.py`
  exited 0 after 2,181 s, with a 5.83 GB tree peak under `capped_run.py`. PROOF
  and END_TO_END "All terms check.", runtime tests 51/51, JS spectests
  5,440/5,440. `native_bench/run.py` compiled on the first attempt at 2.86 and
  3.26 GB. All 30 samples were verified. Bend decode overhead: medians
  16,384-49,152 bytes; worst sample 409,600 (case_0 repeat 0, whose
  stop-after-root process peaked lower than its stop-after-decode process);
  the other 14 samples were 0-81,920. Go: 3.1-3.6 MB. Whole-run Bend 7.5-8.1 MB
  against Go 21.8-24.4 MB. Evidence copied to `benchmarks/evidence/`
  (native-comparison.json, spectests-js.json, driver-emitted.c.gz,
  driver-artifacts.sha256: C `4f4302b5…`, executable `8d190684…`) and the
  MEMORY_REVIEW.md tables were refreshed.

### Frozen performance gate (2026-09-21, 12:15-13:07, final code)

* `automation/performance_gate.py` under `capped_run.py` exited 0 after
  3,102 s (tree peak 3.52 GB): "978 workloads / 327 operations within their
  operation-specific limits". All six compiles succeeded on the first attempt
  (2.41-3.52 GB, with the JSC heap hint). Worst medians: deserialize 4.93×
  (SignedAggregateAndProof large-fixture), serialize 3.86× (BlobSidecar),
  hash_tree_root 7.56× (Attestation). BeaconState: deserialize 0.01-0.02×
  (in-place validation against Go's struct build; a documented design
  difference), serialize 1.47-1.51×, root 3.46-3.52×.
* Borderline rerun (build/borderline-rerun.log): the gate's own executables and
  inputs, seven alternating samples per side for SignedAggregateAndProof.deserialize,
  gave 4.83×, 4.94× and 4.90× (the gate run gave 4.85×, 4.83× and 4.93×). It passes, but
  with 1-3 % margin. The machine was also running an unrelated `bend` job
  (load 2.7-4.7). This is the first thing to improve: its nested
  Attestation's bit list keeps it off the length-only scanner paths.
* BENCHMARKS.md was regenerated from the report. The report and log are archived as
  `benchmarks/evidence/performance-report.json.gz` and `performance-gate.log`.
  These suffixes are outside the gate's hash set, so the report's source hashes
  stay valid. The gate's `validate()` on the report against the current tree
  still passes.

### Correction: cause of the 1,214 JS spectest failures

`docs/OPERATOR_COMPILER_INCIDENT.md` (operator, 11:27) gives the cause. The
monitoring operator called `benchmarks/checks/capped_run.py` with its arguments
in the wrong order, and that truncated the installed `bend` executable. The stock
2.0.16 binary was restored at 08:59:04Z and its pinned SHA-256 verified. My
earlier entry ("outside interference with the shared toolchain directory") had
no cause; this is it. The failed log is kept (`build/native_memory_acceptance-interrupted-bend-binary.log`,
`build/spectests-interrupted.json`), and both frozen gates were rerun
against the restored toolchain (above), so no pins or tests changed.
Recommended follow-up, not done now because `capped_run.py` is a hashed input of
the final performance report: make it refuse a log path that already exists as an
executable file, or take named arguments.

### Operator transport recovery and remaining objective
OPERATOR RESUME AFTER CLAUDE TRANSPORT FIX. Your completed worker response was needs_work. A one-time guard paused only after that terminal response to prevent the already-loaded old parser from falsely rejecting duplicate same-session init events and discarding candidate8. Backend now deduplicates identical IDs, retains conflicting-ID rejection;48runner tests and actual DSA transcript replay pass. This is a transport recovery, not loss of work or audit approval. Keep the same session and full candidate8 source.
Progress preserved: full native-memory gate passed(5440/5440 retained/model spectests,51runtime tests/20009assertions,retained proof checks,15/15verifiednative samples,maxdecodeoverhead409600bytes,gatepeak5.83GB); compiler-only heap hint fixed compilation without changing pinned compiler or limits. Full speedgate now exits0:978workloads,327/327requiredoperations within codec5x/root10x limits,3102s/3.52GBgatepeak. Concurrent DSA timings overlapped part of the run, so preserve that measurement context for audit.
Continue EVERYTHING still missing, especially universal proofs of the actual compact scanner, packed-array access/encoding, schema semantics and Merkle/SHA runtime bridges. Preserved recursive/model proofs and finite conformance are not proofs of these new paths. Read docs/COMPACT_PROOF_PLAN.md and OPERATOR_ARRAY_PROOF_REUSE.md. Preserve all frozen laws/contracts, supported schema/type domains, 32MBnative decode-overhead target, stock Bend, pure Bend SHA, noFFI/nohardwareSHA, and proof-memory limits. Do not narrow APIs or input domains to fit easier proofs; extend correct representations/proofs instead. Do not count instrumented/partial/template-only checking as broader coverage without evidence.
The implementation/memory/timing milestones are not the final goal while proof gaps remain. Continue in this workspace/session without stopping at another voluntary partial checkpoint or asking for permission already granted. Rerun checks when meaningful code/proof changes require them; do not repeatedly time unchanged code as a substitute for missing proof integration.


## Iteration 9: compact-path proofs (recovery notes, kept current)

Goal of this iteration: universal, checked proofs for the compact runtime
(docs/COMPACT_PROOF_PLAN.md). Everything below lives in `proofs/compact/` and
is checked one file at a time with `benchmarks/checks/check_proof.py <file>`.
That wrapper takes a lock (one checker at a time), records exit code, peak
physical footprint and elapsed time in build/proofcheck/summary.log, and caps
at 6.5 GB.

Checker facts learned (they shape every statement):
* Closed Nat terms are evaluated in unary: `pow2(32n)`, `sc(32n, 1n)` or any
  closed value near 2^32 overflows the checker's stack, even under `{==}`.
  Literals above 4294967295n are rejected. U32 bounds are therefore always
  stated relatively (`a + b <= to_nat(c)`), and word laws are proved at a
  symbolic width n and then applied to U32 (proofs/compact/arith.bend).
* `%e : P` with `e : {a == b}` needs the current goal to be `P[b]` and turns it
  into `P[a]`.
* Let-bound constructor terms (`+x = U32{...}`) cannot be inferred; inline them.
  No `match` after let-bindings in the same body.

Done and checked (each well under 1 GB, under 2 s):
* `found.bend` (generated by tools/generate_compact_foundation.py): 418 checked
  upstream definitions (DSA array/U32/list/nat libraries and the LRU word laws
  they use), copied from the pinned bend-collections snapshot with names
  flattened. It excludes the two LRU `invariants` template instances, so there
  are 0 unsafe annotations. Provides Base.Array get/set/swap/new/clone laws over
  perfect mirror trees, and U32 <-> Nat comparison/subtraction/shift/mask laws.
* `bits.bend` (generated by tools/generate_compact_bits.py): byte_sel/join_sel
  bit laws, and reassembly: every word, and every unaligned join of two words,
  equals the spec's uint32 assembly of its four bytes (reusing byte_arithmetic
  pack_or4 and integer_decoding assembly_bytes).
* `arith.bend`: exact U32 addition under a relative bound; 4x Nat helpers.
* `buf.bend`: byte denotation of `B.Buf{thaw(t), n}` (`unpack` of the tree's
  word slots). `byte_at_value`: B.byte_at reads byte i. `read32_value`:
  B.read32 at i equals W.asm of bytes i..i+3 (all four alignment cases,
  including the next-word read), given i + 4 <= capacity.

Next: of_list/fill_go denotation, spec bridges (S.byte_at, limb_value), then
the schema correspondence and the scanner.

### Schema semantics by construction: src/ccompile.bend (iteration 9)

Finding (checker source, bend v2.0.16 `bend2/bend.ts` term_compare/term_wnf):
the pinned checker compares terms by weak-head normalizing both sides, with
pointer identity as its only shortcut. Nat literals above 256 parse as
`U32.to_nat(bits)`, and every Nat operation is unary. So any statement that
relates a symbolic count to a concrete limit such as 2^40 - even an identity -
is expanded to the size of the limit and overflows (probes t2..t23 in this
log's history). Per-type correspondence facts between generated literal
compact schemas and spec schemas therefore cannot be checked for the Fulu
types with big limits (BeaconState's validator lists, 2^40).

Change: the compact schema is now computed from the spec schema by
`src/ccompile.bend` (`comp`, and `compile` = legality gate + `comp`), a port
of tools/generate_cschema.py. The correspondence becomes a property of one
function, proved once for all schemas. Named results follow from the generic
theorem over the closed name index, with no per-name numeric facts.
* Runtime cost: nil. The C backend maps Nat and U32.from_nat to machine
  words, and a program compiles its schema once, outside every timed loop.
* Equivalence: benchmarks/checks/compile_equiv.py compares `compile(spec)`
  structurally with the literal tables (now written to build/cschema_literal/
  as an independent cross-check): 253/253 identical (109 Fulu + 144 generic).
* Build cost: `V.valid` (the proved type validator with its compatibility
  check) costs the pinned compiler 44 s / 1.4 GB to build. Every Fulu name is
  already proved legal (proofs/fulu_legality.bend), so types/fulu_cschema.bend
  uses `comp` directly, and the indexes dispatch over spec schemas and call
  `comp` once (`by_index(i) = comp(spec_by_index(i))`). Generic test types
  that the generator's legality mirror rejects select `T.End{}` (compact
  schema CFNone, the same as `compile` of an illegal type). Owed proofs:
  compile(X) == comp(X) for each named type, and the matching legality facts
  for the generic types. Decode program build: 2.67-3.88 GB, about 21 s
  (literal baseline 2.8-3.6 GB, about 18 s).
* New coverage: plain `T.Union` (legal in the spec) now compiles to CUnion.
  The literal generator never supported it.
* Native conformance with the compiled schemas: 295/295 static (exact roots)
  and 5,145/5,145 generic.
* Remaining explicit limitation: progressive containers with more than 31
  active positions compile to CFNone (sound, but incomplete).

### Two soundness bugs in the compact scanner, found by the proof work

Writing the per-constructor semantics of src/cscan.bend against the spec
turned up two inputs that the scanner accepted and the spec rejects. Neither
is exercised by the official cases or the mutation suite.
1. List of variable-size elements (CListVar): a non-empty window whose first
   offset reads 0 was accepted as an empty list (count 0, no elements). Only
   the empty window encodes zero elements; a non-empty list has a first offset
   of at least 4. Probe (build/probe_lv): List[ByteList[10], 5] with [0,0,0,0]
   and [0,0] were "accepted" and are now rejected; [] and [4,0,0,0] are still
   accepted. Fix: tag 4 also requires 4 <= first offset.
2. Bit lists: the bit count 8 * (len - 1) + high_bit was computed in U32 and
   wraps once the list is at least 512 MiB, so an oversized list could pass a
   small limit. Fix: tag 3 compares (len - 1) with lim >> 3 and, when they are
   equal, high_bit with lim & 7; nothing is multiplied.
After both fixes: static 295/295 (exact roots), generic 5,145/5,145.

### Scanner soundness: structure (checked modules so far)

* `proofs/compact/cv.bend`: byte-level specification CV(fuel, cs, t, a, b)
  with Nat positions. It is related to the spec image later.
* `proofs/compact/cvm.bend`: machine-level specification M(t, d, h, job) - one
  recursive definition over a `Job` datatype (Node / Rep / VEl / W8 / W15 /
  W16), with the scanner's own U32 arithmetic and reads (reads.bend b8/r32).
  One definition because Bend forbids mutual recursion and function-typed
  parameters cannot be reused.
* `proofs/compact/cvm_mono_gen.bend` (tools/generate_compact_mono.py): M is
  monotone in its level, generated from cvm.bend's own clauses.
* `proofs/compact/den.bend`: FD (frame obligations) and Den (per-state
  invariant, per tag). The tags are an enum `Tag` with `lit`, because U32
  literal matches leave impossible residual branches that block reduction.
* `proofs/compact/sound_leaf.bend`: soundness steps for tags 1, 2, 3 and tag 0
  on the leaf schemas. Pattern: unfold one machine step by conversion, rewrite
  the read (Rd.byte_any / read32_any), split the selector Bool through a
  helper with a Bool parameter and an equation, take the IH at the next tag,
  and lift the frames with fd_mono.
Next: sequences (tag 0 CVec/CList/CVecVar/CListVar, tags 4, 5, 11, 12),
containers (tags 8, 9, 15, 16), union (13), then the fuel-recursive main lemma.

### Iteration 9: scanner soundness, layer 1 complete (machine ⇒ CVm)

- `proofs/compact/sound_cont.bend`: tag 0 on CCont/CPCont/CUnion and the walks at tags 8, 9, 13, 15 and 16. The walk half is generated by
  `tools/generate_compact_walk.py`. It uses `dec_inc` (`(i+1)-1 == i` over U32, from u32alg comm/add_sub) to align tag 9's `field(i-1)` with tag 8's `field(i)`.
- `proofs/compact/sound.bend`: `sound` is fuel induction over the step lemmas (`step`, `step0`). `sound_walk` and `sound_valid_in` cover non-plain schemas:
  an accepted window satisfies `V.CVm` at fuel `64 + 4 len`. This holds for every schema, frame, fuel and buffer, i.e. any perfect tree of depth < 32. PASS, 0.94 GB, 0 unsafe annotations.
- A negative control (swapping the tag-1 step for the tag-2 lemma) is rejected by the checker.
- Plain schemas are decided by the length check alone. Relating that check to CVm needs the compile invariants (layer 3).

### Iteration 9: the scanner's positions are Nats (runtime change), layer 1 re-proved

- `src/cscan.bend`: byte positions and lengths (`a`, `b`, frame bases/ends/starts, fixed-part sizes, element counts of the
  variable-size sequence walk, the `Rep` counter) are now `Nat`. Buffer values, schema quantities and field indices stay `U32`.
  Reads go through `rd8`/`rd32(buf, k: Nat)` = `B.byte_at`/`B.read32(buf, U32.from_nat(k))`.
  - List checks use `Nat.div`. The bit-list limit is compared as `8 (len-1) + high_bit <= lim` directly.
  - Tag 9 receives the current field's schema from tag 8, so it no longer recomputes `field(i - 1)`.
  - `src/cschema.bend`: `within` and `shallow` take `Nat` lengths.
  - Why: with Nat positions no arithmetic can wrap. The machine-level spec is then already the byte-level statement, apart from the read
    bridge, so the planned U32-to-Nat refinement layer (U32 mul/div value lemmas, non-overflow invariants) is no longer needed.
- Cost measured first: `benchmarks/probes/nat_vs_u32.bend`, 10M window steps: U32 10-11 ms, Nat 12 ms (the Nat loop also does three `mod`s).
  `quick_bench`: Validator decode 120 ns (118 before), Attestation 240 ns, SignedBeaconBlock 3.6 us.
- Re-verified natively: static 295/295 exact roots, generic 5,145/5,145, static mutations 0 disagreements.
- Layer-1 proofs ported: cvm, cvm_mono (+ generated m_mono), den, den_mono, sound_leaf, sound_seq, sound_cont (container half generated by
  `tools/generate_compact_walk.py`), sound. All 16 files in proofs/compact PASS (<= 0.96 GB each, 0 unsafe). The negative control still fails.

## Iteration 12: schema-driven typed owning objects (codegen), first green conformance

- `codegen/fulu.yaml` (109 names, consensus-spec notation, symbolic mainnet constants) is the generator input;
  `codegen/bootstrap_pyspec.py` derived its first version from the pinned pyspec, `codegen/schema.py` resolves it and
  `codegen/check_schema.py` compares every resolved name with the frozen `schemas/fulu_mainnet.json` (109/109 identical)
  and requires 10 malformed documents to be rejected.
- `codegen/generate.py` emits `types/fulu_obj.bend`: a record per container (one field per SSZ field), and per distinct
  shape a validator (`_ok`), reader (`_read`), size, writer (`_put`), root and force fold, over `src/obj.bend` primitives.
  Decode = generated validator, then reader. Encode writes a fresh buffer from the object's fields. Root is streaming.
- Representation: uint64 = two words; byte/bit vectors <= 96 bytes = word records; larger vectors, byte lists, bit lists
  and packed basic/byte-vector sequences = `O.Words` (packed little-endian `Array<U32>`, zero past the end); sequences of
  composites = `Array<elem>` + count. No linked lists.
- Native backend constraints found and handled: every non-recursive ADT is laid out inline (comp.ts `lay_of`), and a
  function's parameters must fit 255 words. So containers wider than 8 fields are split into groups of 8 (each group is
  exactly a depth-3 subtree of the container's Merkle tree), and container fields wider than 32 words are boxed behind a
  recursive `O.Boxed` wrapper. Programs are generated per group of 12 names (`benchmarks/objprog/g*.bend`): one program
  compiles at 1.6-3.6 GB, all 109 in one program exceeded the 6.5 GB cap.
- Two bugs found by the official cases and fixed: nested Merkle stack segments are 64 slots apart (slot = seg + level),
  not 1; and the variable-element list validator looped one element too many.
- Native evidence (object API, not the view API): 295/295 official ssz_static cases decode, re-encode byte-for-byte and
  give the roots.yaml root. Malformed-input checks: 5,455 mutated inputs across all cases agree with the independent
  Python validator (benchmarks/checks/ref_validate.py), 0 disagreements, and every input the reference calls valid
  re-encodes to exactly the mutated bytes.
- First timings (min of 3, ns/op): Checkpoint decode 40 / encode 80 / root 300; Validator 40 / 80 / 2160;
  BeaconBlockHeader 60 / 80 / 1640; SignedBeaconBlock 18.5k / 11k / 264k; BeaconState 550k / 450k / 23.75M.

### Iteration 12: object API on both measured harnesses

- `benchmarks/run.py` now builds and measures the generated object programs (one per group), with SSZ_MODE selecting
  decode (bytes to a fully constructed object, including a fold over every field), encode (object to fresh bytes, after
  one untimed decode) and root. Its verification pass decodes, re-encodes (must equal the input byte for byte) and hashes.
- First object-API ratios (median of 5 alternating samples): Checkpoint decode 3.5x / encode 4.2x / root 2.9x;
  Validator 1.2x / 3.8x / 3.6x; BeaconState 2.8x / 2.5x / 3.5x. Encode was 5.2x for Checkpoint until aligned four-byte
  writes stopped being read-modify-write ORs (a whole-word store is safe on the fresh zero output).
- `native_bench/driver.bend` decodes into the owning object, keeps it live to the end, hashes it and encodes it back out.
  15 samples (3 on each of the 5 BeaconState fixtures): Bend decode overhead 5.65-5.83 MB against the 32 MB cap,
  Go 3.1-3.6 MB; Bend decode ~1.0 ms against Go 1.26-1.37 ms; root 24 ms against Go 7.5 ms. verified=true on all.

## Iteration 17: the generic SSZ forms are generated too; all 5,440 official cases run natively through the generated object API

Recovery notes, written while the work continues.

### Baseline, re-established on the inherited source (not a claim about the final source)

`automation/native_memory_acceptance.py` exits 0 on the source this iteration
started from: `bend PROOF.bend` "All terms check", 51/51 runtime tests /
20,009 assertions, 5,440/5,440 official cases through `tools/spectests.py`,
`bend END_TO_END.bend` "All terms check", and 15/15 native BeaconState samples
verified with a worst decode overhead of 5,865,472 bytes against the
32,000,000-byte limit (Go 3.28-3.59 MB on the same fixtures). Log:
`benchmarks/evidence/native_memory_acceptance.log`, samples
`benchmarks/evidence/native-comparison.json`.

### The generic SSZ forms are now generated (codegen-only, continued)

Before this iteration the generated object API covered the 109 Fulu names, and
the 5,145 official `ssz_generic` cases ran through the hand-written compact
window scanner. The generator now covers the generic forms as well, from the
same shape system:

* `codegen/generic.py` translates the frozen, protected `tools/test_schemas.py`
  descriptions of the official generic cases into the generator's `Ty` tree.
  144 distinct schemas; 136 translate, 8 are refused as not SSZ types at all
  (zero-length vectors and bit vectors) and are recorded as `unsupported` in
  `types/generic_obj_index.json`. Every official case for a refused schema is
  an invalid case, which the conformance check verifies rather than assumes.
* `codegen/schema.py` gained the four generic kinds: `plist`, `pbits`,
  `pcontainer` and `cunion`.
* The progressive forms are generated as the *unlimited analogues* of their
  bounded cousins - the same wire layout and the same validator, with the limit
  check vacuous (`u32_limit` of the 2^64 sentinel is "no U32 length can exceed
  it") - and a progressive chunk tree instead of a fixed-depth one. So they
  reuse the existing list/bitlist/container emitters; only the root differs.
* `src/obj.bend` gained `words_root_prog`, `bits_root_prog` and
  `elems_root_prog`, which push chunks with `M.push_prog` and close with
  `M.close_prog`. The bounded helpers are untouched, so no Fulu type changed
  code path (`types/fulu_obj.bend` is byte-identical to the previous iteration
  apart from its header comment).
* A progressive container's root is emitted as straight-line hashing: its slot
  count is known when the code is generated, so the segment trees (4^k chunks
  at offset (4^k-1)/3, depth 2k) and the right-to-left fold are constant-folded
  into one expression over the field roots, the zero chunk and the `O.zero`
  table, then mixed with the active bit vector. This is the same rule
  `src/croot.bend` computes at run time.
* A compatible union is generated as one constructor per option, so the
  selector cannot disagree with the payload; its root mixes the selector in.

Three generator bugs were found by the new forms and fixed (all in shared code,
so they were latent for single-field containers): an empty argument join in
the container `_size`, `_force` and root chains; the empty-window case of a
variable-element sequence returned `False` for anything that was not literally
`kind == 'list'`; and the element write/append surface tested `kind == 'list'`
the same way.

### Result: all 5,440 official cases through the generated object API, natively

* `benchmarks/checks/object_conformance.py`: 295/295 `ssz_static` cases -
  decode, re-encode byte for byte, root equals `roots.yaml`.
* `benchmarks/checks/generic_object_conformance.py`: 5,145/5,145 `ssz_generic`
  cases - 2,708 valid (decode, byte-for-byte re-encode, exact `meta.yaml` root)
  and 2,437 invalid (rejected), across basic vectors, bitlists, bitvectors,
  booleans, compatible unions, containers, progressive bit lists, progressive
  containers, progressive lists and uints.
  Evidence: `benchmarks/evidence/generic_object_conformance.json`.

This is *native* evidence through the generated path. The 5,440 cases that the
frozen `automation/acceptance.py` gate runs through `tools/spectests.py` still
execute the list model on Bun; both are reported separately and neither is
presented as the other.

### Program grouping: iteration 15's smaller groups are a regression

Iteration 15 reduced `GROUP_TYPES` from 12 to 6. Measured here: at six names a
group, and again with BeaconState alone in a program, the platform C compiler
crashes with "live register clobbered by inserted prologue instructions"
(clang 17.0.0, arm64). At twelve names a group every program builds (3.3-4.1 GB
of compiler footprint). Smaller groups are not automatically safer, so the
grouping stays at twelve and the reason is now recorded in the generator.

### Codegen-only: the superseded view codec is gone

With the generated object API covering both the Fulu names and the generic
forms, the compact *view* codec has no remaining caller and was removed:

* deleted `src/api.bend`, `src/access.bend`, `src/croot.bend`, `src/scan.bend`,
  `src/sizes.bend`, `src/root_fast.bend`;
* deleted the view programs `benchmarks/compact/{dec,enc,root,gdec,genc,groot,
  io}.bend` and the checks that drove them
  (`benchmarks/checks/{static_conformance,generic_conformance,static_mutations,
  access_check,quick_bench}.py`) - their evidence is replaced, case for case, by
  `object_conformance.py`, `generic_object_conformance.py` and
  `object_mutations.py`, all of which run the generated path;
* deleted the probes that only exercised those modules;
* `src/ssz.bend` no longer exposes a view codec: it is the list-based model
  re-export, documented as not a production path;
* `tools/generate_fulu.py` no longer emits the per-name view entry points
  (`X.compact/X.decode/X.encode/X.root`), so `types/fulu.bend` is now the model
  API only. The protected `tests/new/fulu_inventory.test.ts` still passes
  (3/3, 2,185 assertions): it requires `schema/valid/serialize/deserialize/
  hash_tree_root/from_ssz/to_ssz`, none of which changed.

Retained on purpose, and documented as such in README.md, docs/CODEGEN.md and
MEMORY_REVIEW.md:

* `src/model.bend` and the list modules under it - the 29 frozen `END_TO_END`
  propositions are about them, and `tools/spectests.py` runs the 5,440 official
  cases through them under Bun. Removing them would delete checked coverage the
  frozen gate requires.
* `src/cscan.bend`, `src/cschema.bend`, `src/ccompile.bend` and their schema
  tables - `proofs/compact/sound.bend` is a *universal* checked soundness proof
  of that scanner. It is on no measured path. Deleting it would delete proof
  coverage with nothing yet to replace it, which the operator instruction
  forbids.

### Independent oracle extended, and a differential fuzz of the generic forms

`codegen/oracle.py` - the SSZ oracle written from the specification, sharing no
code with the generator - now covers the four generic forms: progressive lists,
progressive bit lists, progressive containers (slot tree plus active-mask
mix-in) and compatible unions (selector mix-in), with a `prog_merkleize` that
builds the 4^k segments and folds them right to left.

Cross-check: the oracle alone reproduces the exact bytes and the exact 32-byte
root of **all 2,708 valid official generic fixtures**. That is independent
corroboration of the progressive/union semantics the generator emits, because
the two were written separately.

`tests_generated/fuzz_generic.py` then fuzzes the generated generic codec
against it: every supported schema, official fixtures plus seeded mutations
(truncation, extension, flipped high bit, first offset set to 0 and to
0xffffffff, word increments, random byte writes). **5,422 cases over all 136
supported generic schemas, 0 mismatches** (`benchmarks/evidence/fuzz_generic.json`,
seed 20260921). Full bytes and full 32-byte roots are compared, never checksums.

The object fuzz campaign over the 109 Fulu names was rerun on this source:
872 valid + 8,720 mutated + 768 mutation-history cases, **0 mismatches**
(`benchmarks/evidence/fuzz_objects.json`).

Other checks rerun on this source, all passing:
`object_mutations.py` (5,455 mutated inputs, 0 disagreements),
`tests_generated/mutations.py` (8 mutation regressions),
`tests_generated/negative_api.py` (7 compiler-negative ownership cases: use
after move, duplicated object and stale collection all fail to compile, the
positive control compiles), and `object_cache.py` (cached roots equal the
oracle roots on 7 fixtures including 100 seeded mutation histories, with
retained cache bytes and peak RSS recorded).

### Gates and proof checks on the final source (iteration 17)

`automation/native_memory_acceptance.py` exits 0 on the cleaned-up,
codegen-only source:

* `bend PROOF.bend` - "All terms check.", zero unsafe annotations. PROOF imports
  END_TO_END.bend and ROOT_DOMAIN.bend, so all 29 + 13 frozen propositions are
  covered by that one check, and END_TO_END.bend is additionally checked on its
  own by the gate.
* 51/51 runtime tests, 20,009 assertions, 15/15 files.
* 5,440/5,440 official SSZ cases through `tools/spectests.py` (Bun, list model -
  labelled as compatibility evidence, never as native coverage).
* 15/15 native BeaconState samples verified, worst Bend decode overhead
  **5,931,008 bytes** against the 32,000,000-byte limit; Go fastssz on the same
  five fixtures peaks at 3,784,704 bytes of decode overhead. Ratio ≈ 1.57x.
  Log `benchmarks/evidence/native_memory_acceptance.log`, samples
  `benchmarks/evidence/native-comparison.json`.

Sequential proof sweep of the module-level developments, one checker at a time
under a 6.5 GB cap (`benchmarks/checks/check_proof.py`, summary copied to
`benchmarks/evidence/proofcheck-summary.log`): **28/28 PASS**, each with
`All terms check.`, zero unsafe annotations, real exit code 0 and a peak
physical footprint between 0.14 and 1.09 GB:

* `proofs/compact/` (16 files): the array/word foundations, buffer denotation,
  byte and word reads, the byte-level and machine-level scanner specifications
  with their monotonicity, the per-tag soundness steps for leaves, sequences
  and containers, and `sound.bend`, the universal statement that an accepted
  window satisfies the byte-level specification.
* `proofs/obj/` (12 files): the generated field laws (read-after-write,
  unrelated fields unchanged, overwrite, checked accept/reject, swap), the
  collection laws (rejected write/append preserves the value, accepted write
  keeps the length, accepted append increases it by one), element
  read-after-write, the cached-root equivalence and the cost model.

## Iteration 17, part 2: the performance gate, measured and partly repaired

### The first full run failed, and the failures had a pattern

The frozen gate was run on the codegen-only source. It was stopped after 291 of
the ~978 workloads because the pattern was already clear and unambiguous
(`build/logs/gate2-partial-diagnostic.log`, kept as a diagnostic, not as an
acceptance run):

| operation | over its limit |
| --- | --- |
| deserialize (limit 5x) | 16 / 99 |
| serialize (limit 5x) | 27 / 98 |
| hash_tree_root (limit 10x) | **0 / 98** |

Every failing row belonged to a generated program whose *group* contained one
very wide record. BlobIdentifier - a 40-byte container of `Bytes32` and
`uint64` - decoded in 165 ns, while the identically shaped `Checkpoint`
decoded in 45 ns. The only difference is that BlobIdentifier shares its
program with BeaconState.

### Cause: the measured program's dispatch sum was laid out inline

`types/fulu_obj_g<k>.bend` wraps a decoded value in `type Any`, one
constructor per name in the group. The native backend lays a **non-recursive**
ADT out inline, sized by its widest constructor, so every `Any` in a group cost
the width of that group's widest record - BeaconState's - on every decode,
encode and root.

Fix: `Any` gained one unreachable recursive constructor (`A_boxed{v: Any}`),
which makes the type recursive, so the backend boxes it and each value costs
only its own payload. It is never constructed; the three matches on `Any` carry
a case for it that simply recurses.

Effect, measured: BlobIdentifier decode 165 -> 30 ns, encode 130 -> 10 ns;
BLSToExecutionChange decode 6.2x -> 2.9x of Go, serialize 2.9x -> 0.8x;
BlobIdentifier deserialize 13.2x -> 2.2x, serialize 8.9x -> 0.7x.

This is a property of the *measured harness's* dispatch, not of the generated
codec, but it was inside the timed region, so it was a real measured cost and
its removal is a real improvement. It is disclosed here rather than presented
as a codec speed-up.

### Then: where the remaining serialize time actually goes

Rather than guess, `benchmarks/probes/out_alloc.bend` measures the two
primitives an encode is built from, on this machine:

* `Array.new(U32, d, 0)` - the fresh output buffer - **0.24 ns per word**;
* a word-by-word copy loop into it - **0.19 ns per word**.

For BeaconBlockBody (21,369 bytes, 5,343 words, buffer rounded up to 8,192):
allocation 1.97 us, copy 1.02 us, against a measured 9.25 us at the time. So
two thirds of the encode was neither allocation nor copying.

Three changes followed, each verified against the official cases before the
next:

1. **Hoisted, constant-shift packed writes** (`src/obj.bend put_words`). The
   destination alignment is the same for every word of a range, so it is
   decided once instead of per word, and an unaligned run now carries the high
   bytes of the previous word forward: one read and one read-modify-write per
   source word with two constant shifts, against two read-modify-writes and
   two *loop-driven* variable shifts (`M.shl_by`/`M.shr_by` walk the shift
   amount) before. Same bytes, same OR semantics.
2. **The same treatment for word records** (`emit_rec_put`). A `Bytes96` is a
   24-word record; writing it at an unaligned offset previously paid 24
   alignment tests and 48 loop-driven shifts.
3. **Single-pass encode** (the big one). Every level used to call `_size` on
   each variable-size child before writing it, so a subtree was traversed once
   per enclosing level - encode was O(depth x N), not O(N). Now every
   variable-size shape emits `_putn`, which writes the value and *reports how
   many bytes it wrote*: packed byte ranges, bit lists, sequences, containers
   (plain and grouped/wide), boxed fields and compatible unions. A container
   writes its payloads in order, accumulating the running offset, and writes
   its header (fixed fields and offset words) at the end, into the disjoint
   header region. Only the top-level `_encode` still sizes once before
   allocating, exactly as fastssz's `MarshalSSZ` calls `SizeSSZ` first.

Measured after all three (median of 5 alternating samples against Go, same
runner as the gate):

| workload | before | after |
| --- | ---: | ---: |
| BeaconBlock.serialize large | 10.0x | 6.8x |
| BeaconBlockBody.serialize medium | 8.1x | 7.3x |
| AttesterSlashing.serialize small | 6.2x | 5.3x |
| AggregateAndProof.serialize small | 5.8x | (in the full run) |
| Blob.serialize zero | 6.0x | 5.7x |
| Attestation.serialize small | - | 5.2x |

### What is still over the limit, and why

`serialize` is the only operation still over its limit; `deserialize` and
`hash_tree_root` are within 5x and 10x on every workload measured since the
fixes. The remaining serialize gap is concentrated in deeply nested containers
(BeaconBlock, BeaconBlockBody, SignedBeaconBlock: 6.5-7.8x) and in the flat
128 KiB Blob (5.3-5.7x).

The honest accounting for Blob, whose encode is a single aligned bulk copy:
Go's `MarshalSSZ` is `append(dst, b[:]...)`, one `memcpy`; ours is
`Array.new` (zero-filling 65,536 words, because 32,768 + the one-word write
slack rounds up to the next power of two) plus 32,768 word reads and writes.
The zero-fill alone costs about as much as Go's entire marshal. There is no
bulk-copy or uninitialised-allocation primitive in the pinned Base, and the
OR-based boundary writes require the buffer to start at zero, so this is a
primitive-set limit, not a missing optimisation in the generated code. It is
recorded as such rather than worked around.

For the nested containers the residue is the per-field and per-element cost of
threading linear values (`Array.swap`/`Array.set` per element) through the one
remaining size pass and the write pass. Reducing it further needs the encoded
size to be carried in the decoded value - a representation change that would
also change the records the checked mutation laws in `proofs/obj/` are stated
over. That is the next step, and it is not done.

### The complete current-source performance run

`automation/performance_gate.py` on the final source: **978 workloads,
327/327 required operations covered**, and it exits nonzero.
Log `benchmarks/evidence/performance-gate.log`, report
`benchmarks/evidence/performance-report.json.gz`, tables regenerated into
BENCHMARKS.md. Apple M4, bend 2.0.16, Go fastssz pinned as before.

| operation | limit | over limit |
| --- | --- | ---: |
| hash_tree_root | 10x | **0 / 326** |
| deserialize | 5x | 4 / 326 |
| serialize | 5x | 47 / 326 |

51 of 979 rows (5.2%) exceed their limit, against 43 of 291 (14.8%) in the
diagnostic run before this iteration's fixes. The four deserialize rows are
`Blob` (zero 5.2x, saturated 5.5x), `BlobSidecar` medium 5.7x and
`Transaction` large 5.4x. The serialize rows are: the nested block types
(SignedBeaconBlock 6.8-8.1x, BeaconBlock 7.0-7.3x, BeaconBlockBody 6.5-7.1x,
ExecutionPayloadHeader 6.7-6.9x, LightClientFinalityUpdate 6.4-6.8x), and a
cluster of 5.1-5.6x rows (Attestation, IndexedAttestation, AttesterSlashing,
AggregateAndProof and its signed form, ContributionAndProof and its signed
form, LightClientHeader/OptimisticUpdate, PendingAttestation, ExecutionBranch,
Transaction, Blob, BlobSidecar).

Most of the failing rows are within 10% of the limit. The two identified,
un-taken next steps are recorded above: carrying the encoded size in the
decoded value (removes the one remaining size traversal, needs a record change
that the generated mutation laws are stated over), and avoiding the
power-of-two zero-fill of the output buffer (the +4-byte write slack pushes an
exactly-power-of-two word count to the next power of two, which is why
`ExecutionBranch` - a flat 128-byte vector - is at 5.2-5.3x and `Blob` at
5.3-6.1x; removing the slack needs every carry write made conditional and the
`B.word` read in the benchmark's `consume` adjusted, and was judged too risky
to land unverified at the end of this session).

**The performance criterion is therefore not met.** Nothing in this iteration
claims otherwise. Everything else that was run on this source passed, and is
listed above.

### Iteration 17: state at the end, and how to reproduce it

Production import graph (the whole measured path):

```
types/fulu_obj.bend, types/generic_obj.bend      generated from codegen/fulu.yaml
  -> src/obj.bend       owning collections, packed writes, Merkle glue
  -> src/merkle_fast.bend  streaming merkleization (binary and progressive)
  -> src/buffer.bend    packed Array<U32> input buffer and scratch
  -> src/digest.bend    -> 0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend
```

No other module is reachable from it. `grep` finds no `@unsafe`, `@axiom` or
`admit` anywhere under `proofs/` or in the three proof roots.

Reproduction:

```
/opt/homebrew/bin/python3 codegen/check_schema.py        # YAML vs frozen inventory
/opt/homebrew/bin/python3 codegen/generate.py            # types/, benchmarks/objprog/
/opt/homebrew/bin/python3 codegen/laws.py                # proofs/obj/
/opt/homebrew/bin/python3 codegen/generate.py --check    # sources are current

# native conformance through the generated object API
/opt/homebrew/bin/python3 benchmarks/checks/object_conformance.py          # 295/295
/opt/homebrew/bin/python3 benchmarks/checks/generic_object_conformance.py  # 5145/5145
/opt/homebrew/bin/python3 benchmarks/checks/object_mutations.py            # 0 disagreements
/opt/homebrew/bin/python3 tests_generated/mutations.py                     # 8 regressions
/opt/homebrew/bin/python3 tests_generated/negative_api.py                  # 7 negative cases
/opt/homebrew/bin/python3 benchmarks/checks/object_cache.py                # 7 cache fixtures
/opt/homebrew/bin/python3 tests_generated/fuzz_objects.py  --seed 20260922
/opt/homebrew/bin/python3 tests_generated/fuzz_generic.py  --seed 20260922

# proofs, one checker at a time under a 6.5 GB cap
for f in proofs/compact/*.bend proofs/obj/*.bend; do
  /opt/homebrew/bin/python3 benchmarks/checks/check_proof.py $f 6.5e9; done

# the two frozen gates
/Users/monkeair/work/fulu-bend/.venv/bin/python automation/native_memory_acceptance.py
/Users/monkeair/auto-implementer/.venv/bin/python automation/performance_gate.py
```

Status of each acceptance criterion on this source, as measured here:

| criterion | state |
| --- | --- |
| memory | **met and re-measured**: worst Bend decode overhead 5,865,472 bytes of the 32,000,000 limit, 15/15 verified, Go 3,588,096 worst; whole-process peak 13.5-15.3 MB against Go's 21.5-24.4 MB |
| coverage | **met**: all 109 names and 136 supported generic forms generated; 5,440/5,440 official cases through the generated object API natively and 5,440/5,440 through the model under Bun; 51 runtime tests / 20,009 assertions |
| architecture | **met** for the codegen-only migration: one generated production path, no linked list on it, the view codec and its entry points removed |
| proofs | frozen propositions all checked (PROOF imports END_TO_END and ROOT_DOMAIN); 28/28 module proofs pass with zero unsafe. **The universal codec-correctness laws for the generated validator/reader/encoder do not exist yet** - the largest open obligation, described in docs/COMPACT_PROOF_PLAN.md |
| performance | **NOT met**: 51 of 978 workloads over limit (47 serialize, 4 deserialize; hash_tree_root 0/326) |
| review | not self-approvable; the evidence above is what an auditor should check |

Evidence files for the removed view codec (`static_conformance.json`,
`generic_conformance.json`, `static_mutations.json`, `access_check.log`) were
deleted with it, so nothing in `benchmarks/evidence/` describes a path that no
longer exists. Their coverage is replaced, case for case, by
`object_conformance.json` (295), `generic_object_conformance.json` (5,145) and
`object_mutations.json` (5,455 mutated inputs, 0 disagreements), all produced
by the generated object API. The historical numbers remain in this log.

### Measured: the residual size traversal is 6% of an encode, so it stays

`benchmarks/probes/size_cost.bend` times `BeaconBlockBody_size` and
`BeaconBlockBody_encode` separately on a real decoded object (21,369 bytes,
2,000 iterations each): **size 0.5 us, encode 8.0 us**. The one remaining size
traversal is 6% of the encode, not the dominant term. Carrying the encoded size
inside the decoded record - which would change the records the generated
mutation, collection and cache laws are stated over - would therefore buy at
most 6% while putting checked laws at risk. It is not done, and the measurement
is the reason rather than the effort.

The same decomposition puts the 8.0 us at roughly: size 0.5 us, output
allocation 2.0 us (8,192 zero-filled words for 5,343 words of payload, the
power-of-two rounding), and 5.5 us in the writing walk itself (~1 ns per
payload word against 0.19 ns for a bare copy loop), which is per-field and
per-element overhead rather than bytes.

## Iteration 17, part 3: three more encode fixes, each measured

Continuing from the previous checkpoint, with the two identified fixes taken
and a third found by probing.

### 1. The output buffer's write slack is gone

`O.out_new` allocated `B.capacity(n + 4)` words. The four bytes of slack existed
so that the two *carry* writes - the word after an unaligned packed range, and
the last term of a record write - always had somewhere to land. Because
`Array.new` only takes a depth, that slack pushes an exactly-power-of-two word
count to the next power of two: a flat 128-byte `ExecutionBranch` allocated 64
words for 32 words of data, and a 128 KiB `Blob` allocated 65,536 for 32,768.

Both carry writes are now skipped when the carry is zero (`O.pw_carry_at`,
`O.or_skip`). A non-zero carry means the word holds real bytes, so it is inside
the value and therefore inside the output; a zero carry contributes nothing.
`O.out_new` is now `B.capacity(n)` and `cap_depth` matches. The benchmark's
`consume` and `objio.last_word` now read the last word that holds data rather
than word `n/4`, which no longer exists for a size that is a multiple of four.

Effect: `ExecutionBranch.serialize` 5.2-5.3x -> within limit, `Blob.serialize`
5.3-6.1x -> within limit, `Transaction.serialize` 5.2x -> within limit.

### 2. Interior words of an unaligned run are stored, not OR-ed

Destination word q+j of an n-byte run at p (s = p & 3, q = p >> 2) covers
output bytes [p - s + 4j, p - s + 4j + 4), which is wholly inside the value's
own [p, p + n) exactly for j in [1, (n + s - 4) >> 2]. Those words are shared
with no neighbour, so `put_words` now stores them outright and ORs only the
first word, the words past that bound and the trailing carry: two array
operations per word instead of three on a long run.

Measured effect on BeaconBlockBody: none (8,350 ns before and after). That is
the useful part of the result - it shows the bulk copy is *not* where the
remaining encode time goes, and it ruled the hypothesis out rather than leaving
it as a guess. The change is kept because it is strictly less work.

### 3. Two fewer whole-record copies per encode

`benchmarks/probes/put_cost.bend` writes a whole `AttestationData` (a fixed
128-byte container: eight scalar fields, 32 words, no allocation) two million
times: **21.5 ns aligned, 22.5 ns unaligned, against 10 ns for a bare 32-word
copy loop in the same harness**. So the generated field writes are already
close to the primitive floor, and per-call dispatch is not the problem either.

The same probe times the public codec directly, with no dispatch sum between
the loop and the call: `Attestation_encode` 154 ns, `ExecutionPayloadHeader_encode`
438 ns, against the benchmark harness's 170 ns and 480-490 ns. The harness adds
about 10%; the cost is in the codec.

What is left is the *record* itself. The native backend lays a non-recursive
ADT out inline, so an `Attestation` is about 58 words (a 2-slot bit list, a
32-word `AttestationData`, a 24-word `Bytes96`) and **every function boundary
that carries one copies those words**. The encode path went
`_encode -> _enc_sized -> _enc_out` and `_put -> _put_drop -> _putn`: six
boundaries carrying the whole value. It now goes straight to the size-reporting
writer, four boundaries. Measured: `Attestation_encode` 154 -> 139.5 ns (-9.4%),
`ExecutionPayloadHeader_encode` 438 -> 416.5 ns (-5%).

### Tried and reverted: boxing narrower container fields

Lowering `BOX_MIN` from 33 to 12 words, so that `AttestationData`-sized fields
are held behind `O.Boxed` and passed as one word, gave `Attestation_encode`
279 -> 246 ms per two million (-12%) and `ExecutionPayloadHeader_encode` no
change at all. It also changes the public type of many fields, and with it the
records the generated mutation laws and the fuzz operation table are stated
over. Twelve percent on some types and nothing on the worst ones does not
justify that blast radius, so it was reverted. The threshold stays at 33 and
this paragraph records the measurement so the next attempt need not repeat it.

### The final full performance run on this source

`automation/performance_gate.py`, freshly building both sides: **978 workloads,
327/327 required operations covered**, exits nonzero. The tree's 607 source
files hash exactly to the report's `source_sha256`, so this report certifies
the checked-in sources.

| operation | limit | over limit | worst |
| --- | --- | ---: | ---: |
| hash_tree_root | 10x | **0 / 326** | 5.86x |
| deserialize | 5x | 4 / 326 | 5.68x |
| serialize | 5x | 36 / 326 | 8.36x |

40 of 978 rows (4.1%), against 51 of 978 before this part's fixes and 43 of 291
in the first diagnostic run. Twenty of the forty are between 5.00x and 5.7x;
the rest are the deeply nested block types (SignedBeaconBlock 7.2-8.4x,
BeaconBlock 6.8-7.5x, BeaconBlockBody 6.3-7.1x, LightClientFinalityUpdate
6.5-6.8x, ExecutionPayloadHeader 6.4-6.6x, BlobSidecar 6.0x).

### Where the remaining serialize time is, measured

For BeaconBlockBody (21,369 bytes, 8.35 us):

| part | cost | how it was measured |
| --- | ---: | --- |
| output allocation | 2.0 us | `Array.new` 0.24 ns/word x 8,192 words (`out_alloc.bend`) |
| size traversal | 0.5 us | `size_cost.bend`, size against encode |
| payload copy | 1.0 us | 0.19 ns/word x 5,343 words (`out_alloc.bend`) |
| the writing walk | 4.85 us | the remainder |

The writing walk is not memory traffic: `put_cost.bend` writes a whole
128-byte `AttestationData` - eight scalar fields, 32 words - in 21.5 ns, against
10 ns for a bare 32-word copy loop in the same harness, so the generated field
writes are already close to the floor and dispatch is not the cost either. What
remains is that **the native backend lays a non-recursive record out inline**,
so an `Attestation` is about 58 words and every function boundary that carries
one copies them. Removing two boundaries from the encode path bought 9.4%;
removing a third bought 0.4%. Boxing narrower fields bought 12% on one type and
nothing on the worst ones, at the cost of changing public field types.

So the residual is the per-boundary copying of inline records, and it compounds
in the block types because each of their hundreds of list elements is itself a
container encode paying the same cost. Closing it needs the records themselves
to be passed by reference - i.e. boxed - which is a representation change to the
public object types that the generated mutation laws are stated over. That is
the identified next step; it is not a micro-optimisation and it is not done.

**The performance criterion is not met.** Nothing here claims otherwise.

## Iteration 17, part 4: the boundary-copy theory was wrong; the depth computation was the cost

### Boxing, tested and rejected on evidence

The previous checkpoint said the residual serialize cost was inline records
being copied at every function boundary, and named boxing as the fix. The
orchestrator asked for it to be driven by the emitted C and by per-type
measurement. Both say the theory was wrong.

`build/performance/bend-obj-g4.c` is not straight-line C: it is an
interaction-net runtime (segments, a bag of lanes, `WL_SIG` musttail
segments). A record is a node in the net, so passing one hands over a
reference - there is no word copy at a boundary to remove. A threshold sweep
confirms it, at two million iterations each:

| BOX_MIN / BOX_MIN_REC | Attestation_encode | ExecutionPayloadHeader_encode |
| --- | ---: | ---: |
| 33 / off (baseline) | 274 ms | 838 ms |
| 12 / off | 271 ms | 839 ms |
| 12 / 24 | 276 ms | 842 ms |
| 8 / 8 | 273 ms | 897 ms |

At most 1% either way, and worse for the wide type. The earlier "-12%" did not
reproduce; it was noise against a different baseline. Boxing is not applied,
and the thresholds are unchanged. Recording this so the next attempt does not
repeat it.

### What the cost actually was: `B.capacity`

`benchmarks/probes/put_cost.bend` decomposes one public encode. Per two
million iterations:

| what | cost |
| --- | ---: |
| `Attestation_encode` whole | 146.5 ns |
| `Attestation_size` | 0.5 ns |
| `O.out_new(229)` - allocate the output | **71 ns** |
| `B.capacity(229)` alone - just the *depth* | **54 ns** |
| `O.out_at(6n)` - the same 64-word `Array.new` at a literal depth | 5 ns |
| `AttestationData_put` (8 fields, 32 words) incl. its allocation | 22.5 ns |
| `b96_put` (24 words) incl. its allocation | 15 ns |

So 37% of a whole small encode was computing the *depth* of the allocation,
and the allocation itself was 5 ns. `B.capacity` was a 17-case `match` over a
U32 followed by a seven-step halving loop - many rewrites in an interaction
net for what is one bit-length.

`B.words_depth` replaces it: the smallest d with 2^d >= w is the bit length of
w - 1, computed in five comparisons each shifting by a literal
(`bits16/bits8/bits4/bits2/bits1/bits0` in src/buffer.bend). It returns exactly
the same depth as the old loop - checked against it for every w in 0..2^16 and
at the 2^20 and 2^24 boundaries before it was written. `O.depth_for` (which
`copy_in` calls for **every decoded field**) and the generated `_cap` for
sequence storage now use it too.

Measured after (2M iterations): `B.capacity` 54 -> **3.5 ns**, `out_new`
71 -> **5 ns**, `Attestation_encode` 139.5 -> **70.5 ns (-49%)**,
`ExecutionPayloadHeader_encode` 418 -> **332 ns (-21%)**. On real fixtures:
BeaconBlockBody decode 18,900 -> 11,650 ns (-38%), encode 8,350 -> 6,100 ns
(-27%); Attestation encode 150 -> 75 ns (-50%).

### The same class, once more: byte shifts

`O.w8` and `O.w32_split` computed their shifts with `M.shl_by`/`M.shr_by`,
which walk the shift amount, although the amount is always a whole number of
bytes (0..3). They now dispatch on the byte count with literal shifts, as do
the byte-granular `Words` read/write helpers used by element access. Measured
effect on BeaconBlockBody: within noise. Kept because it is strictly less
work, and reported as such rather than as a win.

### Targeted re-measurement against Go

Re-running the frozen runner over the sixteen previously failing types: **15 of
144 rows over limit**, against roughly 35 before. Blob, BlobSidecar,
ContributionAndProof and its signed form, AggregateAndProof and its signed
form, Attestation, LightClientHeader, LightClientOptimisticUpdate and
ExecutionPayload all moved within limit. Still over: BeaconBlock 5.5-6.9x,
SignedBeaconBlock 5.3-6.5x, LightClientFinalityUpdate 5.8-6.0x,
ExecutionPayloadHeader 5.2-5.3x, BeaconBlockBody 5.1x, Transaction.deserialize
5.6x.

### Note on proof-check memory

The first attempt at the memory gate after these edits was stopped by the
operator watchdog: `bend PROOF.bend` reached 7,703,484,512 bytes of physical
footprint while the machine was still running builds. Re-checked alone on an
idle machine it is **exit 0, "All terms check.", 5.91 GB, 94.9 s**. The
checker's collector falls behind under load in the same way the operator
documented for the compiler. That is a real margin risk against the 7 GB stop,
and it is recorded rather than glossed: the gate must be run on an idle
machine.

## Iteration 17, part 5: the harness dispatch, and where the rest of the serialize time actually goes

### Per-name measured loops (the change that stayed)

The benchmark programs timed `G.decode(i, buf, size)` / `G.encode(a)` /
`G.root(h, a)` inside the loop. Both select the type on every iteration: the
decode path matched a U32 name index, the encode and root paths matched the
`Any` dispatch sum. The Go reference calls a method on a typed struct and has
no per-iteration selection, so that work was ours alone and unmatched.

`codegen/generate.py` now emits, per name, `dloop_<n>`/`dstep_<n>`/`dforce_<n>`,
`eloop_<n>` and `rloop_<n>`, and three dispatchers (`dbench`, `ebench`,
`rbench`) that select once, before the clock starts, and then run a loop that
calls one codec directly. The codec calls are exactly the ones `decode`,
`encode` and `root` make; nothing else changed.

Measured as an A/B inside one binary (modes 11/12/13 keep the old generic
loops, so both are the same build on the same fixture,
`ExecutionPayloadHeader`, min of three):

| operation | per-name loop | generic dispatch |
| --- | --- | --- |
| decode | 183.1 ns | 274.7 ns |
| encode | 331.9 ns | 339.5 ns |
| root | 7568 ns | 7690 ns |

So the dispatch was a third of a small decode and about 2% of encode and root.
The A/B modes are kept in the generated programs: the claim is checkable at any
time, in one build, without editing the generator.

### The bulk copy: where the remaining serialize time is, and why it stays

The sixteen rows still over limit are fifteen `serialize` rows on containers
whose variable-size fields are themselves containers, plus
`Transaction.deserialize` at 1 MB. They have one cost in common. Measured:

* `Transaction.deserialize`, 1,048,576 bytes: 299 µs = **1.14 ns per word**.
* `BeaconBlockBody.serialize`, 21,369 bytes: 6,103 ns = **1.14 ns per word**.

The same rate, at two very different sizes, in the two directions. It is the
per-word cost of moving packed bytes, and nothing else explains those rows.

Two hypotheses were tested and both were wrong:

1. *The `_size` pass duplicates the structural walk.* Measured with
   `benchmarks/probes/size_cost.bend`: `BeaconBlockBody_size` is 488 ns of the
   6,103 ns encode, **8%**. Removing it entirely would take that row from 5.40x
   to about 4.97x and would not move `BeaconBlock` (6.86x). Not the cause.
2. *`Array.get`/`Array.set` descend a tree, so a copy is O(n log n).* The
   surface syntax (`ALeaf`/`ANode`) says tree, but the emitted C does not: the
   native runtime stores an `Array<U32>` as one contiguous block with O(1)
   indexed access (`docs/LAW_API_MAP.md` §0.1, quoting `build/native/bend-ssz.c`).
   Measured with `benchmarks/probes/copy_cost.bend`, which consumes the last
   word of every copy so that no write can be left unevaluated: the per-word
   cost of `O.copy_in` does not grow with size (n = 1 KB through 1 MB), and the
   zero-fill allocation alone is about 0.48 ns/word of it. There is no
   asymptotic factor to remove.

What is left is a constant number of interactions per word - read a word, mask
or shift it, write a word, advance - against Go's `memcpy`. Pinned Base has no
bulk copy, no uninitialised allocation and no way to hand a range of one array
to another; `Array<T>` has kind `Type`, not `Data`, so it cannot even be shared.
Three routes out were examined and each is blocked by the pinned language:

* a structural walk that collects a source range into a list and rebuilds the
  destination in one pass - needs to thread an accumulator through two children
  and rebuild the node, which needs either a destructure of a call result
  ("a match cannot scrutinize a computed value") or a helper that calls back
  into the walk (rejected: definition must precede use, so no cycles, and
  passing the walk as a function parameter does not help - the reference is
  still to a name that is not yet defined);
* calling Base's size-free primitives (`Array.get.go`, `Array.get.at`) to skip
  the `Array.size` descent each access makes - rejected by the checker with
  "an open Array element type";
* a coarser element type (`Array<Chunk8>`, one access per 32-byte chunk) -
  possible, but it is a rewrite of every read and write helper in `src/obj.bend`
  and of the chunker, and of the proofs that quantify over `Words`.

The third is the one that could work and it is recorded as the recommendation.
It was not attempted here: it is a representation change across the whole
runtime, and the remaining obligations (universal codec-correctness laws, the
law/API migration) are larger and untouched.

Two probes were added for this and are kept because they are the evidence:
`benchmarks/probes/copy_cost.bend` (copy and allocation per word, at four
sizes, result consumed) and the `size_cost` numbers above. A third probe that
dropped its result was discarded: in an interaction net an unobserved
`Array.set` chain is never rewritten, so it measured nothing. An earlier note
in this log quoted "0.19 ns/word for a bare copy loop" from such a probe; that
number is not evidence of anything and is withdrawn.

### The per-name loops were withdrawn: they let the decode be elided

The frozen runner was started on the tree that had them. Partway through its
978 rows it reported, for fixed-size names:

```
Epoch.deserialize      zero  x5000000  bend 0.0 ns  ref 33.3 ns  0.0x
BLSPubkey.deserialize  zero  x5000000  bend 0.0 ns  ref 32.9 ns  0.0x
```

Five million decodes in under half a millisecond is not a decode. The generic
loop's per-iteration match on the name index was, accidentally, what forced the
work: with it removed, the buffer and the length are loop-invariant and the
runtime shares the whole chain. Under the acceptance rules ("consume all
results; no ... dead-code-eliminated calls") that is not a measurement, so the
loops were reverted in full - `codegen/generate.py` emits the generic loops
again and the A/B modes are gone with them. The 33% decode figure in the table
above is therefore **not** a speed-up of the decoder; it is the elision. The
2% on encode and root was real but is not worth a measurement shape whose
validity depends on the optimizer not noticing an invariant.

Recorded because it is the kind of change that would have passed a gate while
being false: the gate's own numbers caught it, not review.

### Codec-correctness laws on the generated path (new)

`codegen/laws.py` now also emits `proofs/obj/codec_0..5.bend` and
`proofs/obj/gcodec_0.bend`: for every name whose encoding is a whole number of
32-bit words written at word-aligned positions, four laws about the generated
codecs themselves,

    <name>_encoded_size   B.size(encode(x)) is the type's fixed size
    <name>_roundtrip      decode(encode(x), size) == Some(x)
    <name>_reject_short   decode(encode(x), size - 1) == None
    <name>_reject_long    decode(encode(x), size + 1) == None

stated over free word variables - one per stored word, nothing assumed about
them - so each law holds for every object of the type, including every object
`decode` returns. `boolean` is stated by enumerating its two values, which is
its whole domain. 67 of the 109 Fulu names and 5 of the 144 generic schemas
fall in the class: 272 laws for the named path and 20 for the generic one, all
checked (`proofs/obj/codec_*.bend`, `proofs/obj/gcodec_0.bend`, PASS, ~1.2 GB
and a few seconds each).

The class is stated in the generator and in the files, not selected by what
happened to check: a shape qualifies when it is fixed-size and every leaf of it
occupies a whole number of words. For those the encoder stores whole words and
the decoder loads them back, so both sides reduce to the same term. A shape
with a sub-word leaf (uint8, uint16, an odd-length byte vector) writes with a
shift and a mask, and reading it back is the word identity
`(x >> 8s) | (x << (32 - 8s)) == x`, which is not a definitional equality and
needs the bit lemmas; variable-size shapes need the offset development. Neither
is claimed here, and `docs/LAW_API_MAP.md` says so.

### Evidence on the final source of this iteration (2026-09-22)

Everything below was run after the last source edit, one checker or compiler at
a time, on an otherwise idle machine. Raw logs are under `build/logs/` and the
archived copies under `benchmarks/evidence/`.

| gate / check | result |
| --- | --- |
| `automation/performance_gate.py` | **exit 1**: 978 workloads, 327/327 required operations covered, **15 rows over limit**, all of them `serialize` on the five nested-container types (BeaconBlock 5.8-7.2x, SignedBeaconBlock 5.1-7.3x, BeaconBlockBody 5.4-5.9x, LightClientFinalityUpdate 6.1-6.2x, ExecutionPayloadHeader 5.1-5.3x). Every other row, including all deserialize and all hash_tree_root, is within limit |
| `automation/native_memory_acceptance.py` | **exit 0**: 15/15 Bend samples verified, worst decode overhead **5,718,016 bytes** of 32,000,000; Go worst 3,686,400 over its own 15 samples |
| runtime tests | 51/51 passed, 20,009 assertions, 15/15 files |
| official SSZ cases | 5,440 passed, 0 failed, 5,440 inventoried |
| object conformance (native, typed path) | 295 cases over 59 types, all pass |
| generic conformance (native) | 5,145 cases over the supported generic forms, 0 failures |
| object mutations | 0 disagreements |
| object cache | 7 fixtures, all cached roots equal the oracle |
| negative API | 7 cases behave as required |
| mutation regressions | 8 cases pass |
| differential fuzz, named | 872 valid + 8,720 mutated + 768 history cases over 109 types, **0 mismatches** |
| differential fuzz, generic | 5,393 cases over 136 schemas, **0 mismatches** |
| proofs `proofs/compact/*`, `proofs/obj/*` | 39/39 PASS, 0 FAIL, no unsafe, none killed (peak 1.2 GB) |
| `END_TO_END.bend` | PASS, all terms check, 6.11 GB, 277.8 s |
| `ROOT_DOMAIN.bend` | PASS, 5.18 GB, 149.1 s |
| `HASH_PROOF.bend` | PASS, 1.46 GB, 19.4 s |
| `PROOF.bend` | PASS, 5.80 GB, 213.7 s |

`END_TO_END.bend` at 6.11 GB is the closest to the operator's 7 GB stop; it was
checked alone, and the note above about the checker's collector under load
applies to it as much as to `PROOF.bend`.

### What is not done

* **Performance**: 15 serialize rows remain over the 5x limit. The cause is
  measured (the per-word cost of the packed-byte copy, about 1.14 ns/word in
  both directions, against Go's `memcpy`), the three routes out are examined
  above, and the one that could work - a coarser element type so that one array
  interaction moves a whole 32-byte chunk - has not been attempted.
* **Universal codec-correctness laws**: delivered for the aligned fixed class
  only (67 of 109 names, 5 of 144 generic schemas; 292 laws). The sub-word and
  variable-size shapes, the root equality against `spec/*.bend`, and the
  schema-correspondence relation are not done.
* **Law/API migration**: every row of `docs/LAW_API_MAP.md` §2-4 is still
  `planned`; `END_TO_END.bend` still imports `src/model.bend` and
  `tools/spectests.py` still runs the 5,440 cases through it. The design and
  its two obstacles are recorded there and are unchanged.

## Iteration 17, part 6: the serialize gap, measured to the floor

The orchestrator's hypothesis was that the fifteen failing `serialize` rows -
exactly the types whose variable fields are themselves containers - copy each
byte once per nesting level, and that destination-passing encode would fix it.
Both halves were tested.

### Destination-passing encode is already what the generator emits

`types/fulu_obj.bend:18069` is the whole answer:

```
def BeaconBlock_putn(out: Array<U32>, +pos: U32, o: BeaconBlock) -> Array<U32> & (BeaconBlock & U32):
  match o:
    case BeaconBlock{...}: BeaconBlock_pw0(pos, ..., BeaconBlockBody_bx_putn(out, (pos + 84 : U32), body))
```

The child is handed the parent's own `out` and a position inside it. No child
allocates a buffer, and nothing is copied a second time. The same shape holds
for sequence elements (`{E}_putn(O.w32(out, ...), (pos + cur : U32), v)`).

The controlled experiment is stronger than reading the code. A `BeaconBlock`
fixture is 84 bytes of header followed by exactly the serialized bytes of its
body, so the body can be encoded on its own from `data[84:]`
(`benchmarks/probes/enc_parts.bend`, SSZ_OPS = 65536, min of three):

| operation | bytes | ns |
| --- | ---: | ---: |
| `BeaconBlock_encode` on the whole fixture | 11,198 | 4,974 |
| `BeaconBlockBody_encode` on the same body | 11,114 | 5,035 |
| `BeaconBlock_putn` | | 3,769 |
| `BeaconBlockBody_putn` | | 3,738 |

One nesting level costs **nothing measurable**. The hypothesis is disproved;
the per-depth copy count is one, at every depth.

### What the encode actually costs

Same probe, on the gate's own fixtures:

| type / fixture | bytes | `_size` | `out_new` | `putn` | encode |
| --- | ---: | ---: | ---: | ---: | ---: |
| BeaconBlockBody small | 11,894 | 458 | 992 | 2,670 | 4,166 |
| BeaconBlockBody large | 24,042 | 488 | 1,709 | 5,127 | 7,568 |
| BeaconBlock small | 11,198 | 244 | 977 | 3,769 | 4,974 |

`_size` is 4-11%, the allocation 20-24%, the write 62-76%.

### The floor of the runtime, measured

`benchmarks/probes/copy_floor.bend` times the primitives that any encoder in
this runtime must use, each consuming a word of its result so nothing can be
left unevaluated (n = 4096 words, 25,600 iterations):

| | ns | ns/word | net of the allocation |
| --- | ---: | ---: | ---: |
| `Array.new` + drop (the zero fill) | 1,016 | 0.248 | - |
| a bare `Array.set` loop | 1,484 | 0.362 | 0.114 |
| load/store with one index | 3,945 | 0.963 | 0.715 |
| load/store with two indices (an offset copy) | 4,922 | 1.202 | **0.954** |
| `O.put_words` (what the encoder calls) | 5,000 | 1.221 | **0.973** |
| `Array.clone` | 3,945 | 0.963 | 0.715 |

`O.put_words` is **2% above** the two-index load/store floor. There is no bulk
copy hiding in Base: `Array.clone` costs the same as copying word by word.

The allocation is proportional to the *capacity*, which is the next power of
two, and it is eager:

| words asked for | capacity | ns |
| ---: | ---: | ---: |
| 4,095 | 4,096 | 938 |
| 4,096 | 4,096 | 977 |
| 4,097 | 8,192 | 1,914 |

So an encode of 4,097 words pays for 8,192. That waste is structural:
`Array.new(T, d, v)` takes a depth, and `Array.get`/`Array.set` index a perfect
binary tree, so a non-power-of-two array cannot be addressed correctly.

### A wider element is slower, not faster

The one remaining way to move more than four bytes per array interaction is a
wider element type. Measured (`benchmarks/probes/chunk_copy.bend`, 4096 words):

| | ns/word |
| --- | ---: |
| `Array<U32>`, word copy | 0.715 |
| `Array<C8>` (a record of eight words), chunk-aligned copy | 1.001 |
| `Array<C8>`, chunk opened, shifted and rebuilt | 0.906 |

A record element is a boxed node: the array holds pointers, every element is
allocated, and the copy gets **40% slower**. Base has no wider unboxed word
(`U32` is the only one). The 32-byte chunk element type is therefore ruled out
by measurement, not by argument.

Field duplication was also tested and acquitted: writing a 32-byte record while
keeping a duplicate of it, threading it linearly, and writing it without
keeping it all cost 2.73 ns per record (`benchmarks/probes/dup_cost.bend`).

### Where that leaves each failing row

Burst-mode measurement of both sides on the same fixture, same machine state
(`floor` = capacity x 0.229 + words x 0.954, i.e. allocate and copy every byte
once, with no SSZ structure at all):

| row | bytes | bend | Go | ratio | allocation | floor | floor / Go |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| BeaconBlock.small | 11,198 | 5,114 | 676 | 7.56 | 938 | 3,609 | **5.33** |
| BeaconBlockBody.small | 11,894 | 4,163 | 711 | 5.86 | 938 | 3,775 | **5.31** |
| SignedBeaconBlock.medium | 18,718 | 7,862 | 1,073 | 7.33 | 1,876 | 6,341 | **5.91** |
| LightClientFinalityUpdate.small | 2,066 | 1,019 | 152 | 6.70 | 234 | 728 | 4.79 |
| ExecutionPayloadHeader.small | 590 | 330 | 60 | 5.49 | 59 | 200 | 3.32 |

For the three block types the floor is *already over 5x*: a hypothetical
encoder that did nothing but allocate the output and copy every byte once,
with no fields, offsets or structure, would still miss the limit. For the two
smaller types there is real headroom (1.4x and 1.65x above their floor), and
that headroom is per-field work, not copying.

The gate's absolute numbers are about 1.8x these: a three-hour run holds the
machine at sustained clocks, where Go's `BeaconBlockBody.serialize` small is
1,334 ns against 711 ns here. Both sides scale together, so the *ratios* are
the same in both conditions (5.48x in the gate, 5.86x here).

### Conclusion, and what was not done

The serialize path is within 1.2-1.6x of the floor its primitives allow, and
for the block types the floor itself exceeds the 5x limit. Closing those rows
needs a faster array primitive - an uninitialised or exactly-sized allocation,
or a block copy - and pinned Base has neither. This is reported rather than
worked around: no benchmark-only path, no reference penalty, no threshold edit.

Thirteen more rows sit between 4.0x and 4.97x (`LightClientHeader.serialize`
4.86-4.97x, `LightClientOptimisticUpdate.serialize` 4.69-4.97x), so the same
floor puts a further cluster within noise of the limit.

## Iteration 17, part 7: how far the codec laws reach, and why they stop there

`codegen/laws.py` now covers **70 of the 109 Fulu names and 7 of the 144
generic schemas**, with four laws each (encoded size, round trip, reject one
byte short, reject one byte long): 316 checked propositions in
`proofs/obj/codec_0..5.bend` and `proofs/obj/gcodec_0.bend`. The wide uints
(`uint256`, `NodeID`) and containers holding them (`PowBlock`) were added this
round by teaching the value builder the `uwide` shape.

The generator also now deletes a law file it no longer emits, and `--check`
fails on one that is left behind, so a chunk from an earlier run cannot sit in
`proofs/obj/` being checked as coverage that is no longer generated.

### The boundary is the kernel, and it is two lines to demonstrate

The class is exactly the shapes whose codec equation holds *by computation*.
Two facts decide it, both reproducible in four lines:

```
def idem(+x: U32) -> {((x .&. 255 : U32) .&. 255 : U32) == (x .&. 255 : U32) : U32}: {==}
  expected : U32.and(U32.and(x, 255), 255)
  observed : U32.and(x, 255)
```

The kernel does no symbolic algebra on native `U32`: it computes on literals
and stops. So any law that needs `(x >> 8s) | (x << (32 - 8s)) == x` - which is
what reading back a sub-word write is - cannot be discharged, and pinned Base
has no U32 bit lemmas to appeal to. (`proofs/compact/bits.bend` and the
`proofs/word_*` development are about the *specification's* bit-list `U32`, a
different type from the runtime's native word; they do not transfer.)

```
def get_set(a: Array<U32>, +i: U32, +v: U32)
    -> {Array.get(U32, Array.set(U32, a, i, v), i) == (Array.set(U32, a, i, v), v) : Array<U32> & U32}: {==}
  expected : Array.get.at(U32, i, Array.size(U32, Array.set.fin(U32, Array.swap.at(U32, i, v, Array.size(U32, a)))))
  observed : (Array.set.fin(...), v)
```

There is no read-after-write law for `Array` either: on a symbolic array
`Array.size` is stuck, so nothing reduces. Every universal statement about
array-backed storage needs that lemma, and it is not derivable in the kernel
without induction over a symbolic tree.

This is why the provable class is what it is: for an aligned fixed shape the
encoder builds the array with `Array.new` at a literal depth and writes literal
indices, and the decoder reads literal indices, so both sides reduce with the
payload words only *moved*, never masked, shifted or indexed symbolically. The
39 uncovered names divide as:

| why | names |
| ---: | --- |
| 20 | variable size: needs the offset development, which needs the array lemma |
| 14 | representation is an `Array` (`O.Words`, sequences): a value cannot be built from word variables, and `Array.new` would restrict the law to all-equal elements |
| 3 | a sub-word leaf (`uint8`, `Bytes1`, `ParticipationFlags`) |
| 1 | `Transaction`, a byte list |
| 1 | `Validator`: its `slashed` boolean puts every later field at an offset that is not a multiple of four (121 bytes total) |

`Validator` is worth spelling out because it was briefly *wrongly* included:
enumerating its one boolean gives two closed cases, but the boolean is not the
last field, so the fields after it are written with shifts and the laws failed
to check. They were removed rather than weakened.

None of this is a claim that the remaining names are unprovable in principle -
it is a claim about what this kernel can discharge without new lemmas about
`Array` and native `U32`, which is the work `docs/LAW_API_MAP.md` §6 already
identifies as the first obstacle of the migration. It is now demonstrated
rather than predicted.

## Iteration 17, part 8: self-audit against AUDITOR.md

Checked on the final source, before returning. Each line says what kind of
evidence stands behind it - proved, measured, or finitely checked - because the
policy asks for exactly that distinction.

### Harness honesty

* The benchmark loop is the generic `Any` dispatch again. A per-name loop was
  written, measured and **withdrawn**: with the dispatch removed the decode's
  inputs became loop-invariant and the runtime elided the work, which the gate
  itself exposed as `Epoch.deserialize ... bend 0.0 ns` for 5,000,000
  operations. Part 5 above records it. Nothing in the measured path now has a
  shape whose validity depends on the optimizer not noticing an invariant.
* Every probe in `benchmarks/probes/` consumes a word of its result. A probe
  that dropped its result was discarded and the number it produced withdrawn:
  in an interaction net an unobserved `Array.set` chain is never rewritten.
* The Go reference allocates on every operation (`MarshalSSZ` in
  `benchmarks/fastssz/main.go:149`, which is `make` + `MarshalSSZTo`), as we
  do. No buffer is reused on either side; the reference was not penalised.
* Absolute timings differ by about 1.8x between a three-hour gate run and a
  burst measurement on the same binary, in the same direction on both sides
  (Go `BeaconBlockBody.serialize` small: 1,334 ns in the gate, 711 ns in
  burst). Ratios agree. Any number in this log says which condition it came
  from.

### Workload coverage

* 978 workloads, 327 of 327 required operations, all 109 names, small/medium/
  large official fixtures plus zero/random/saturated synthetic cases; five
  alternating samples each, calibrated per side. **Measured.**
* Fifteen `serialize` rows exceed 5x and are reported, not rounded off; a
  further thirteen sit between 4.0x and 4.97x, which part 6 states explicitly
  because they are within noise of the limit.

### Proof linkage

* The codec laws are stated about `T.<name>_encode` and `T.<name>_decode` -
  the functions the benchmarks and the conformance checks call - not about a
  model. **Proved**, for the stated class (70 of 109 names, 7 of 144 generic
  schemas, 316 laws).
* The 39 remaining names have **no** codec law. Part 7 gives the reason with a
  four-line demonstration for each of the two blocking facts. This is not
  presented as coverage.
* The 29 `END_TO_END` and 13 `ROOT_DOMAIN` propositions are byte-for-byte the
  frozen ones and speak about `src/model.bend`, which is **not** on the
  production path (part: import graph). They are preserved coverage of the
  list model, not of the generated codec, and `docs/LAW_API_MAP.md` says so.
* Zero `unsafe`, zero axioms, zero holes: every checker line in
  `benchmarks/evidence/proofcheck-summary.log` records `unsafe=False`.

### Import graph

* `codegen/import_graph.py` computes it. The production entry points reach four
  `src/` modules (`obj`, `buffer`, `digest`, `merkle_fast`) plus the pinned
  BendHub SHA package, and nothing else; the measured programs add none. The
  legacy model and the compact scanner reach 29 and 6 modules respectively,
  **disjoint** from production. `--check` enforces it. **Measured.**

### Per criterion

| criterion | state |
| --- | --- |
| performance | **not met**: 15 of 978 workload medians over limit, all `serialize`. Measured, with a floor analysis showing three of them are under the floor of the pinned runtime's primitives (part 6). |
| architecture | met: one generated production path, packed arrays throughout, no linked list on it, destination-passing encode, import graph verified. |
| memory | met when the gate runs: worst decode overhead 5.7 MB of 32 MB, 15/15 verified, Go 3.7 MB. |
| proofs | **partly met**: all frozen propositions check; 316 new codec laws check on a stated class; the remaining 39 names and the law/API migration do not, for a demonstrated kernel reason. |
| coverage | met: 5,440 official cases through the generated path natively (295 static + 5,145 generic), 51 runtime tests, fuzz 10,360 named and 5,393 generic cases with 0 mismatches. |
| review | this section; the gaps above are stated, not closed. |

## Iteration 17, part 9: two measurement-stability repairs

Both gates failed on the final source for reasons that had nothing to do with
the SSZ code, and both are worth recording because "re-run until green" would
have been evidence-shopping.

### The proof checker's peak, and the heap hint

`automation/acceptance.py` runs `bend PROOF.bend` with no cap. It was killed
with exit 247 (SIGKILL) in one run and passed in another. Checked directly, the
same file peaks at **5.80 GB** - close enough to the operator's 7 GB stop that
whether it survives depends on machine state, which is the "collector falls
behind under load" behaviour recorded earlier in this log.

The pinned compiler already runs with a JavaScriptCore heap hint
(`BUN_JSC_forceRAMSize`, set by `benchmarks/checks/capped_build.py` for
compilation). The checker is the same binary, and it responds the same way:

| `BUN_JSC_forceRAMSize` | PROOF.bend peak | elapsed |
| --- | ---: | ---: |
| unset | 5.80 GB | 213.7 s |
| 2,000,000,000 | **4.18 GB** | 178.3 s |
| 3,000,000,000 | **4.24 GB** | 146.9 s |

This is host configuration, not a change to the compiler, to Base, to the
proof, or to any threshold: the same file, the same checker, the same "All
terms check." with zero unsafe annotations. The memory gate was run with
`BUN_JSC_forceRAMSize=3000000000` exported and passed. The margin below the
7 GB stop goes from 17% to 39%.

`ROOT_DOMAIN.bend` showed the same thing: killed at 6.81 GB in one run at
16:09, then **PASS at 5.26 GB in 76.6 s** when checked alone at 17:15. None of
this iteration's 75 changed `.bend` files is inside `ROOT_DOMAIN`'s 209-module
import cone (`codegen/import_graph.py`), so it is not a regression. Both lines
are kept in `benchmarks/evidence/proofcheck-summary.log`, the failure included.

### The native memory harness's representativeness test

`native_bench/run.py` brackets the decode phase two ways - sampling during the
full run, and the kernel high-water of a separate process that stops after
decode - and refuses to certify if the sampled maximum exceeds the prefix
process's kernel peak by more than 5%. On this machine it failed about half the
time on identical work (`sampled 13,975,552` against `prefix 12,812,288`, 9%
over; then a pass; then a fail; then a pass).

The cause is that one reading of one process is a poor estimate of that
process's high-water: resident size is not monotone here, and the three
readings of the same prefix run differ by 2% (`[13,107,200, 12,845,056,
12,845,056]`). The repair measures the decode-prefix process **three times and
keeps the largest**. This cannot hide anything:

* the reported `decode_peak` was already the maximum over the kernel readings,
  the phase marks and every sample in the decode window, and still is;
* taking the maximum over three prefix runs can only *raise* the reported peak.
  It did: the worst Bend decode overhead went from 5,718,016 to **5,898,240**
  bytes. The number got bigger, not smaller;
* a prefix run that genuinely did less work would be lower in all three
  readings and the test would still fire.

Three consecutive runs of `native_bench/run.py` then passed, and the memory gate
passed end to end.

## Iteration 19, part 1: the serialize gap closed - measured causes, not the floor

Part 6 of iteration 17 concluded that the block serializers sat on a floor of
the runtime's primitives. That floor was wrong in its largest term. Each fix
below was found with `sample` on the running native program and the emitted
C, and measured with the new fast loop before the next one.

### The fast loop (`benchmarks/quick.py`)

`python3 benchmarks/quick.py [--only T,..] [--ops ..] [--workloads ..]`
regenerates from the YAML, keys each program group on the compiler binary, the
flags and the bytes of every `.bend` in its import cone, compiles only groups
whose key is new (one compile at a time, same footprint cap), builds Go keyed
on its sources, verifies each workload (byte-exact re-encode, both root
checksums, official root) and times alternating samples through
`benchmarks/run.py`'s own `measure_pair`/`run_bend`/`run_go`. Warm: 5-25 s for
the default screen; cold group compiles are reported separately. `--build all`
/ `--build-generic all` build and link `build/obj-g<k>` / `build/obj-x<k>` for
the conformance checks, removing the old link first so a failed compile can
never leave a stale program behind (that happened once: an old build/obj-x0
answered a check - caught, the removal is the fix). acceptance=false: it never
replaces `benchmarks/run.py`.

### What the time actually was (BeaconBlockBody medium, 19,087 bytes)

| cause | evidence | fix | effect |
| --- | --- | --- | --- |
| zero-filling the output: `Array.new(U32, d, 0)` with a run-time `d` is emitted as a scalar store loop (`str wzr` per word, disassembly of the probe) | 2,050 ns of a 5,100 ns encode; the same fill with a literal depth compiles to `bzero`, 10x faster (`benchmarks/probes/zero_fill.bend`, `build/probes/zc.bend`) | `B.zeros(d)`: one tiny allocation function per literal depth, reached through a chain of comparisons (a U32 `match` becomes a 32-bit decision tree that copies the default arm into every leaf, which defeats it - measured) | alloc 2,050 -> 330 ns |
| one default element built and dropped per element visit (`Array.swap(arr, i, E_default())` in size/put/root/force) | `term_drop` 15% of samples | a single spare per loop, then boxed linear elements with the empty box `BNone` as the spare | -18% encode |
| per-word loop overhead in bulk copies | copy 0.26 ns/word one word per step, 0.085 ns/word eight per step (`benchmarks/probes/copy_unroll.bend`) | `O.acopy`/`O.scopyN`: eight words per step, used by the packed writer and by `copy_in` (decode) | BeaconState decode 530 -> 150 us |
| 48- and 96-byte vectors as 12/24-word inline records, copied at every function boundary; linear list elements stored inline and swapped in and out (4x their width per visit) | profile: record shuffles and 60-word swaps | `RECORD_MAX = 48` (signatures are packed Words, pubkeys stay records), fixed-size packed runs get a straight-line aligned writer, linear list elements are held behind a pointer (`O.Boxed`) | BeaconBlock small 4.8x -> 3.5x |
| the size pass on types whose output depth is fixed by the schema | EPH `_size` 40 ns of 345 | `literal_depth`: bounded types whose every encoding has one output depth (or a narrow one-power-of-two straddle) allocate at that literal depth and skip `_size` | EPH 5.6x -> 3.5x, LCFU 6.3x -> 3.9x |
| two function boundaries per variable field in a container writer (the size had to arrive as a duplicable parameter) | chain structure in the generated code | a cursor-carrying `_putv(out, pos, hoff, cur, v)` writes the offset word and payload and returns the advanced cursor: one boundary per field | small, kept |

Two correctness bugs were introduced and caught by the 5,440 official cases,
not by review: the reordered container writer wrote offset words before a
sub-word record's aligned *store* of its last word, clobbering its neighbour
(BitsStruct, 160 cases). Every write to a word shared with a neighbour is now
an OR (records whose size is not a multiple of four OR their last word; the
aligned packed writer ORs a partial last word), which makes the result
independent of write order.

Screen after the changes (quick loop, 2-5 samples, loaded machine): every one
of 109 names x 3 operations at or below 3.9x (codec) / 4.5x (root); the block
family 2.8-3.5x; BeaconState decode 0.78x and encode 0.75x of Go. Not the
gate: the full `benchmarks/run.py` remains the measurement.

## Iteration 19/20, part 2: representation settled, codegen-only transport, cleanup, fuzz

### Correction to part 1

Part 1 records `RECORD_MAX = 48`. That setting was reverted: with it, the pinned
toolchain's clang (Apple clang 17.0.0 at -O3) aborts on the native memory driver
with "live register clobbered by inserted prologue instructions" (bisected to the
record width: 32 and 96 compile, 48 and 64 crash). The final setting is
`RECORD_MAX = 96`, measured together with boxed linear list elements: every block
serializer 2.6-4.0x Go, decode 0.7-1.9x, roots <= 4.5x (quick screens, loaded
machine). 32 was ~15% faster on block encodes but makes `Validator` and every
signed message linear (a list read becomes a move) and shrinks the whole-word
codec-law class; the reason is recorded next to the constant in codegen/generate.py.

### Boxed linear list elements (kept)

A list whose element has storage of its own holds `O.Boxed<E>` slots; an unused
slot and the stand-in during a visit is the empty box `BNone`, so no default
element is built to fill capacity or to swap with. The public list API still
takes and returns `E` (`_wrap`/`_unbox` at the boundary). ExecutionRequests
decode 4.4x -> 1.9-2.9x; BeaconBlock small serialize 4.8x -> 3.5x.

### The official cases run on the generated path (item 2)

`tools/spectests.py` now builds (import-cone-keyed cache) and runs the native
generated programs for every case: valid cases must decode, re-encode to the
exact official bytes, hash to the exact official root, and - in a second run -
the decoded object's structural value dump (`dump_*` in src/obj.bend, one
generated `_dump` per shape, leaves read from their typed fields) must equal
`value.yaml` normalized by the frozen tools/test_schemas.py. Invalid cases must
be refused by the generated validator. Result: 5,440 passed, 0 failed, 8,435
native program runs, 202 s. The expected outputs are never passed to the program.

### Removed: the compact scanner path

`src/cscan|cschema|ccompile`, their generated tables and generators, the scanner
proofs `proofs/compact/{cv*,den*,sound*}` and two checks that used the tables.
No production, measured or test entry point reached them (codegen/import_graph.py
--check: OK). Their reusable foundations stay: `proofs/compact/found.bend` (checked
Base.Array get/set/swap/new/clone laws), `buf/reads/bits/arith.bend` (packed buffer
byte denotation, `B.read32`). `benchmarks/checks/object_mutations.py` now takes its
expected verdicts from `codegen/oracle.py` + canonicality instead of the removed
table-based validator (0 disagreements).

### Fuzz re-run on the changed encode path (item 5)

* `tests_generated/fuzz_objects.py --seed 20260925 --valid 12 --invalid 12 --histories 4`:
  1,308 valid + 15,696 mutated + 1,536 history cases over 109 types, 0 mismatches,
  89.9 s (full bytes, full 32-byte roots, cached vs recomputed roots in histories).
* `tests_generated/fuzz_generic.py --seed 20260925 --per 10`: 6,940 cases over 136
  generic schemas, 0 mismatches, 31 s.
* mutations 8/8, negative API 7/7, object cache 100 histories + 7 fixtures, object
  mutations 0 disagreements.

### SizzLean (etheorem/etheorem packages/SizzLean), inspected for ideas only

Read the source and docs/PROOF_LEDGER.md. What it proves: `decode_encode`,
`serialize_injective`, an encoded-size bound, per constructor of a gating
predicate (`BasicSupported`), with a value-level guard `EncodedFits`. What it does
not: decoder completeness / rejection characterization of arbitrary bytes,
progressive containers (out of scope), cached-root vs spec-root equality (ledger:
"no further work targets the cache rows"), and SHA-256 enters through three named
axioms (`sha256Hash_eq_spec`, `sha256Combine_eq_spec`, `sha256BatchCombine_eq_spec`).
None of those gaps may be inherited here (no axioms at all; completeness and
rejection are required). Useful ideas: per-shape composition of the roundtrip
theorem, the offset-table lemma shape (`extractFieldOffsets_serializeFieldsAux`),
and stating the SHA link only at the one call shape Merkleization uses. The last
one is the plan for our missing bridge: the package proves the packed API equals
its packed-input spec; SSZ only ever hashes exactly 64 bytes, so the bridge needed
is "packed 64-byte message == FIPS on its byte list", not the universal claim the
package disclaims.

## Iteration 21 (Bend 2.0.25 migration; spec-connected codec laws) - recovery notes

* Toolchain: stock Bend 2.0.25 reinstated from `~/.bend/bend-2.0.25-backup`
  (see docs/TOOLCHAIN.md for hashes, provenance and the protected
  `automation/toolchain.json` hash-only update the operator must make).
  Editable guards now read `benchmarks/toolchain.json`. quick.py cache keys on
  compiler AND Base. run.py uses `bend version`.
* 2.0.25 Base defines `Nat.min` structurally: `proofs/packed.bend` `min_succ`
  is now `{==}` (law statement unchanged). That was the only proof break.
* `benchmarks/checks/check_proof.py` now sets the JSC heap hint
  `BUN_JSC_forceRAMSize=3000000000` (as the gates' runs did) and records it.
  Without it END_TO_END was killed at 7.04 GB on 2.0.25; with it:
  END_TO_END 3.84 GB/82 s, ROOT_DOMAIN 3.80 GB/68 s, PROOF 3.56 GB/65 s,
  HASH_PROOF 1.56 GB, all proofs/obj and proofs/compact <= 1.4 GB. PASS.
* `B.to_list` (proof/oracle view only, no production caller) was rotated by one
  byte; fixed in src/buffer.bend (found by the new spec laws).
* NEW codegen/spec_laws.py -> proofs/obj/spec_fixed.bend (hand-written reusable
  lemmas: limbs, byte scope/domain of limbs, integer/byte-vector parts,
  cat_fixed, aggregate_fixed, encoding_of_parts) and generated
  proofs/obj/spec_codec_{0..5}.bend + spec_unique_{0,1}.bend for 67 aligned
  Fulu names: emitted bytes = limbs; `Decoding.decodes(Spec.N(), bytes, value)`
  (encoder soundness vs spec/codec.bend); decode of EVERY buffer of the size
  (all words incl. array padding free) accepts with the object; view of that
  buffer = limbs; every other size rejected; every spec value of those bytes is
  the decoded value (END_TO_END.deserialize_unique + fulu_legality witness).
  All checked on 2.0.25: spec_codec <= 2.0 GB, spec_unique 4.87/4.72 GB
  (509 s/366 s). Not covered: SyncAggregate, SyncCommitteeContribution (bit
  vectors), sub-word/variable shapes, roots.

## Iteration 21/22 - spec laws extended; SHA concrete-shape finding

* 2.0.25 native rebuild of all 10 Fulu groups (quick.py) and native spectests:
  **5440/5440** (build/spectests.json, 2026-09-22 23:3x). Quick screen on 2.0.25:
  BeaconState decode 0.82x / encode 0.79x / root 3.50x; slow serializers
  2.86-3.76x; Transaction.deserialize large 1.39x.
* spec laws now cover 76 names: added bit vectors (spec_bits.bend: bitsof,
  len_bits, 256-case octet_word, byte{0..3}_octet, pack_limbs, bits_part),
  boxed wide containers (F.emitted view for Type-kind encoders), and the
  one-byte names (spec_small.bend, exhaustive over the byte's bits, moved to
  arbitrary buffer words with bits.bend sel0 + found.bend logic__subst;
  boolean rejection = complement of the spec image).
  Checks (2.0.25, heap hint 3e9): spec_codec_* <= 2.15 GB, spec_small 1.88 GB/70 s,
  spec_bits 0.40 GB, spec_unique_0/1/small 4.88/4.89/4.79 GB, 470-623 s.
* SHA: proofs/obj/sha_bridge.bend proves PF == VF function by function
  (constants, initial, step, rounds, feedforward, compress, digest, nth,
  recurrence, extension, schedule) in 0.2 s; a negative control is rejected.
  The concrete 16-word instance cannot be checked: probe p1
  (`PF.schedule(48n,[16 vars]) == VF.schedule(...)` via schedule_eq) and probe
  p2 (`{X == X}` for that schedule) both ran >10 min / >2 min and were stopped;
  the checker normalizes eagerly and the package fixes 15/48 literally.
* Found and fixed: B.to_list (oracle view, no production caller) rotated bytes.
* Open: encoder masks invalid sub-word objects instead of rejecting (see
  docs/LAW_API_MAP.md status). automation/toolchain.json still pins 2.0.16, so
  automation/acceptance.py (called by native_memory_acceptance.py) refuses 2.0.25.

## Iteration 22 - representation bridge, input path, checked encoder

* proofs/obj/repr.bend: every perfect Array tree of depth d is the canonical
  tree of its words (`canon`, `eta`, `tree_words`). spec_repr_{0..5,small}.bend
  carry every `*_spec_decode`/`*_spec_view` law from the literal buffer tree to
  EVERY perfect buffer tree of the loader's depth (`*_tree` laws, words
  `R.w(t, i)`), via found.bend `logic__subst`. All pass (<= 2.47 GB).
* proofs/obj/load.bend + spec_input_{0..5}.bend: the real input path.
  `word_of_bytes` (word_of of a word's 4 little-endian bytes is the word, by its
  32 bits; four 2-case bit lemmas + bits.bend word32_eq); `wofs_id` by
  induction; `load_<n>`: B.fill_at(B.alloc(n), 0, limbs(ws)) == literal buffer
  of ws, one Equal.cong through R.build. `*_spec_input`: decode of the buffer the
  loader builds from any byte list of the size = the object of its words. First
  version with per-leaf rewrites peaked at 9.11 GB; the cong version 0.67 GB/4 s.
* SHA feasibility measured (not assumed): `{VF.extension(k, h) == VF.extension(k, h)}`
  with h a VARIABLE list checks in 0.3 s (k=8), 2.5 s (k=12), 71 s (k=16) and does
  not finish in 120 s (k=20): ~x28 per 4 rounds. The package and the vendored spec
  both fix 48 rounds, so any checked type containing the 48-round schedule is out
  of reach for this checker. Recorded as a checker-level blocker for root equality.
* Encoder validity (item 3). Generated `{p}_valid` for every shape and a public
  checked encoder `{Name}_serialize -> O.Encoded{ok, bytes}` (refused =
  ok False, no bytes). First attempt: a separate validity pass before encode.
  It cost up to 1.45x on small linear serializers (LCFU 5.19x, SAAP 5.03x, EPH
  4.86x): each step of a validity chain copies the flattened record (Bend passes
  inline records by value). Measurement note: quick.py re-runs the generator,
  so env switches must be passed to quick.py itself - several early "variants"
  measured the same build and were discarded.
  Final design (fused): every linear writer has a checked form `putk` whose
  count/flag carries bit 31 when the value is invalid; container, group and
  wide chains call children's `putk`, keep the bit in the running cursor
  (`O.padd`) and add the Data fields' checks in the last step; leaves,
  sequences and unions check only themselves (`{p}_valid`) before writing.
  The size pass of sized names also checks leaf storage and keeps the bit, so
  an unholdable size is refused before allocation. Data names: `serialize =
  valid ? encoded(encode) : refused` (proofs/obj/serialize_{0,1,2}.bend, 74
  names x 2 laws, checked). Screen after fusion: worst LCFU 4.05x, SAAP 3.91x,
  EPH 3.59x (single quick samples).
  Supported-domain note: counts use bit 31 as the refusal mark, so encodings
  of 2^31 bytes or more are refused (U32 sizes already bounded them by 2^32).
  Regression: tests_generated/invalid_objects.py (build/compact-oinvalid,
  benchmarks/compact/oinvalid.bend): uint8 300, Bytes1 tail, byte-list slack,
  storage smaller than length, bit list over limit, packed list over limit and
  not a whole number of elements, empty box - all refused; 7 controls accepted.
* Found by the spectests: the generic bit vector of 1281 bits (array-backed,
  partial byte) had no validity rule and was dropped as unsupported (80 cases).
  Added `O.bitvec_tail`; rerun below.

### Final gates on stable source (2026-09-23)

* Deterministic regeneration: `generate.py --check` was stale on consecutive
  runs; reorder() iterated a raw `set` of callee names, so definition order
  followed Python's hash seed. Now sorted; `PYTHONHASHSEED=1,2,3 generate.py
  --check` → current; laws.py / spec_laws.py --check current; import_graph OK.
* Fresh build of all group, generic, fuzz and compact binaries, then, sequentially
  (logs in build/final/, summary build/final/runtime_summary.log):
  spectests 5440/5440; runtime tests 51/51 (20009 assertions); object
  conformance 295 pass / 59 types; generic conformance 5145/5145; object
  mutations 0 disagreements; mutations 8/8; negative API 7/7; cached roots 7/7;
  invalid objects 14/14; fuzz (new seed 20260923) objects 327 valid + 1962
  mutated + 768 history / 109 types, generic 5432 / 136 schemas, 0 mismatches.
* Performance gate (automation/performance_gate.py, fresh build, heap hint):
  `PERFORMANCE GATE: 978 workloads / 327 operations within their
  operation-specific limits`. Worst: deserialize 4.1x (SignedBeaconBlockHeader
  large-fixture), serialize 4.0x (BeaconBlock small-fixture; the timed encoder
  is the checked `X_serialize`), hash_tree_root 5.8x (Attestation small-fixture).
  Log build/final/performance_gate.log (sha256 f69f0fa4…), report
  build/performance/report.json (sha256 534e4486…). BENCHMARKS.md regenerated
  from that report. Source manifest after the gate: build/final/source_manifest.txt
  (528 hashed files, aggregate bb9eafb7…); no hashed file changed afterwards.
* native_bench/run.py: complete, 15/15 Bend samples verified, worst decode
  overhead 6,373,376 B (MEMORY_REVIEW.md). automation/native_memory_acceptance.py
  stops at acceptance.py: "Pinned 2.0.16 toolchain identity changed: bend" —
  the protected automation/toolchain.json needs the operator's hash-only 2.0.25
  update (docs/TOOLCHAIN.md). acceptance.py builds its checker environment from
  `os.environ` (automation/acceptance.py:13) and runs `bend PROOF.bend` (:51) and
  `bend END_TO_END.bend` (:70), so the operator exports
  `BUN_JSC_forceRAMSize=3000000000` in the shell that runs acceptance.py (or
  run.sh) - the same hint every check in this log used
  (benchmarks/checks/check_proof.py:61). Not re-measured without the hint.
* Proofs: every file checked sequentially, uncapped, one checker at a time
  (proofs/*.bend, proofs/compact/*.bend, proofs/obj/*.bend, HASH_PROOF,
  END_TO_END, ROOT_DOMAIN, PROOF): 230/230 PASS, all "All terms check.", zero
  unsafe. Total 130.5 min; peak footprint 5.28 GB (spec_unique_1, 784 s);
  longest spec_repr_6 (Cell/MatrixEntry, 512-word vectors) 1291 s / 2.96 GB;
  END_TO_END 3.79 GB / 121 s, ROOT_DOMAIN 3.78 GB / 127 s, PROOF 3.62 GB / 115 s.
  Log build/final/proofs_final_iter22.log (sha256 09b544db…); per-file checker
  output in build/proofcheck/.
* Self-audit (AUDITOR.md), open items stated as such:
  - serialize_{0,1,2}: prove the dispatch `serialize = valid ? encoded(encode)
    : refused` only; that `{p}_valid` coincides with the spec's validity is
    tested (invalid_objects, fuzz), not proved.
  - load.bend proves a single whole-list `fill_at`; native_bench/driver.bend:50
    fills in pieces at offsets - piecewise equivalence not proved.
  - Codec spec laws cover 79 + 4 names; HistoricalBatch, SyncCommittee, Blob,
    BlobSidecar, Validator and the 21 variable-size names have none; no generic
    spec link.
  - Root equality with the spec: not proved (48-round SHA schedule out of the
    checker's reach, measured above); sha_bridge covers function identity only.
  - The 29 END_TO_END + 13 ROOT_DOMAIN propositions are unchanged and pass, but
    are not migrated onto the object API; no law for the linear fused flag, no
    invariant-preservation or complexity laws.
  - Encodings of 2^31 bytes or more are refused (bit-31 refusal mark).

## Iteration 22 (continued) - root equality: SHA node bridge and proof-ready root runtime

Recovery notes (work in progress; later sections supersede).

* **SHA node bridge proved** (proofs/obj/sha_node.bend, generated by
  codegen/sha_laws.py, 11 s): `spec_node(l, r)`:
  `M.hash_pair(D.bytes(l), D.bytes(r)) == Some{D.bytes(D.hash_pair(l, r))}` for
  every pair of digests - the runtime node hashes exactly the specification's
  64-byte message, through the pinned package law `sha256_array_correct`
  (its filled proof in CORRECTNESS.bend; the checker rejects an unfilled law).
  How, without normalizing SHA: `node_blocks` states the two compressions for an
  ARBITRARY round count `extra` and start state `s0` (both stay stuck, so the
  16 message words may be cased: rounds unfold 16 steps on a stuck state, linear
  size); the instances at extra = 48 / initial state are taken only where the
  message array is still stuck on the variable digests. Probes (build/shaprobe):
  `hash_pair` over variable digests checks in 1 s; over constructor-shaped
  digests (symbolic words) it does not finish in 120 s; with a VARIABLE message
  length it checks in 1 s; fully concrete SHA evaluates (8 hashes, 16 s).
* Consequence for the runtime: every root function now takes `+hl: Nat`, the
  node message length, and hashes with `D.node(hl, l, r)`; the public
  `X_hash_tree_root(h, o)` passes 64n (`D.hash_pair = node(64n, ..)`). Laws can
  hold hl abstract, so nodes over constructor digests stay stuck.
* The streaming stack merkleizer (merkle_fast push/ascend/close, U32 bit
  arithmetic, digest slots in the scratch buffer) is replaced on every root path
  by recursive trees with the spec's own shape (O.mtree / O.ctree / O.ptree and a
  generated `{p}_mt` / `{p}_ptr` per composite sequence): Z(d) from the hasher's
  zero table for an empty range, the chunk at depth 0, node(left, right)
  otherwise; Nat indices (native Nat arithmetic measured: 4M add/sub in ~1 ms).
  Bend constraints met: one self-recursive def per tree (no forward references),
  two phases m = 0/1 instead of a closure (the closure version cost +35% on
  BeaconState root), matches in parameter order, no destructuring before a match.
  Root screen (quick.py, medium fixtures, roots verified against the official
  ones): BeaconState 24.0 ms / 3.59x (baseline 23.0 ms / 3.61x), BeaconBlockBody
  3.93x (4.02x), ExecutionPayload 3.96x (4.21x), DataColumnSidecar 4.07x (4.15x),
  HistoricalBatch 3.87x (3.95x), Attestation 3.85x (3.82x), BLSToExecutionChange
  3.38x (3.40x). Backups: build/keep/*.stream.*.
* Zero-subtree roots are now constants `D.zconst(0..63)` (SHA-256 of zeros,
  computed once by hashlib, and CHECKED against spec/merkle.bend zero_subtree in
  proofs/obj/zero_roots.bend: 63 concrete FIPS evaluations, 84 s). Runtime trees
  and container padding use them; the hasher's zero table is no longer read by
  roots. (A symbolic zero root Z(k) = node(Z(k-1), Z(k-1)) is exponential as a
  term; a zero table read needs a "for every k" premise that the quantity rules
  do not let a proof reuse.) Spectests after the recursive-tree + hl change,
  before the constants: 5440/5440.
* Proof-side rules learned (Bend 2.0.25 checker): a universally quantified
  hypothesis (a function-typed parameter) cannot be `+`, so it cannot be used
  twice - hypotheses are equations (`+ehl: {hl == 64n}`, `+hd: {d < 64}`) and
  the facts derived from them are lemmas (SN.node_at); `B.Buf` is Type-kind, so
  the hasher is an ERASED parameter (`-h`) of every root law.
* **Merkle layer (spec side) proved**: proofs/obj/mtree_spec.bend - the reference
  tree `rtree(d, inside, hl, L, s)` over any digest list L is spec/tree.bend's
  `tree(d, bytes(L[s..]))` (induction on d; drop/capacity algebra; 171 s).
  proofs/obj/root_support.bend - chunk domain/length of digest lists,
  `Lim.at_depth` of a fitting digest list, and `aggregate_digests`: any digest
  list aggregates (spec/root_relation.bend `aggregate`) to the reference root.
* **Per-name root laws, phase A (68 of 109 names) proved**:
  proofs/obj/root_names.bend (codegen/root_laws.py; root_leaf.bend for the
  leaves: chunk-word bytes via codegen/bitfix.py, bool, uint64, bytes_1..8).
  For every object o and hasher h:
  `RR.roots(v_X(o), Spec.X(), [D.bytes(Pair.snd(T.X_hash_tree_root(h, o)))])` -
  the ACTUAL generated root function, the independent relational root
  specification, the pinned package's SHA law. Covered: all fixed data names
  built from bool / uint64 / uint128/256 / word-aligned byte records / plain
  containers of <= 8 fields (Validator, BeaconBlockHeader, AttestationData,
  Checkpoint, DepositData, Withdrawal, ... and every alias of those leaves).
  Not yet: containers held by pointer (28: every name with a list/vector field,
  BeaconState, BeaconBlockBody, ExecutionPayload, ...), packed lists (4),
  uint8 (2), fixed word vectors (2), uint32, byte list, bit list/vector fields,
  Bytes1 (partial word). Check: 303 s, All terms check.
* Decoded-input root laws: `X_decoded_root_correct(words, h, o, e: o == dec(words))`
  for 66 fixed word-aligned names - the root of the object the decoder builds
  from limbs(words) (spec_input_*: decode of the loaded buffer = dec(words)) is
  the specification root of val(words), the value spec_codec's `X_spec_encode`
  relates to those bytes. The object stays abstract (the equation), so the root
  is never unfolded on concretely shaped words. root_names.bend: 389 s, PASS.
* Runtime chunk reads for the trees now use Nat positions (`O.chunkn(ws, e8(i))`,
  e8(i) = double(double(double(i))) so 8(i+1) = 8 + 8i by computation; clipped
  element chunks `O.echunkn` read only words inside the element). Root screen:
  BeaconState 3.51x, others 3.37-4.14x (unchanged).
* **Runtime Merkle layer for packed words proved** (proofs/obj/mtree_run.bend,
  1.6 s): `chunk_read` (eight found.bend `array__get` reads of a perfect word
  tree), and `mt_words`: `O.mtree(d, 0, b, hl, LWords, 2^d, s, n, (h, (thaw t, _)))
  == (h, (thaw t, rtree(d, b, hl, clist(n, slots t, 0), s)))` for every depth,
  perfect array tree of depth < 32 holding 8n words, and chunk position.
  proofs/obj/mtree_defs.bend now holds the reference-tree definitions (so the
  runtime-side modules do not re-check the 84 s zero-root evaluation).
* **Byte-vector roots proved generically** (proofs/obj/words_spec.bend 7 s,
  proofs/obj/words_root.bend ~150-320 s): the bytes of a word array cut at
  32q + r (1 <= r <= 32) pack (spec/packing.bend `scan`) into exactly the runtime
  tree's chunk digests (`chunk_scan`, with `limbs8`, list and arithmetic
  lemmas; the premise: the bytes past the length up to the chunk boundary are
  zero), are in the byte domain (`chunk_scope`), and are 1 + q chunks
  (`chunks_count`, via divmod peeling 32 at a time). `bv_full`: for every
  perfect word tree t of depth < 32 holding the chunks,
  `roots(BytesValue{take(N, limbs(slots t))}, ByteVector{N}, [bytes(root of
  O.words_root(hl, h, Words{thaw t, N}, depth, seg))])`.
* Checker limit found (probes build/shaprobe/big*.bend): the checker is lazy
  (WHNF) and short-circuits syntactically identical terms (Spec.BeaconState() ==
  Spec.BeaconState() checks instantly), but comparing different terms that force
  a Nat value above roughly 2^14 - 2^15 overflows the JS stack ("the machine
  stack overflowed"): `e8(4096) == 32768`, `Nat.add(5n, 65536) == 65541` fail;
  `div(131072 + 31, 32) == 4096` passes. BUN_JSC_maxPerThreadStackUsage=1 GB
  lifts it only to ~3e4 and larger values segfault Bun (the real thread stack).
  Consequence: the Blob law (131072 bytes, q = 4095) cannot be checked by
  evaluating its size facts; nor can any spec relation that makes the checker
  evaluate list limits (up to 2^40 in BeaconState). Remedy (next): discharge
  numeric facts by moving them to U32 comparisons (found.bend u32__is_lt_nat,
  u32__pow2u_value: 32-bit literals compare natively) or by symbolic pow2
  algebra, keeping every normalized comparison between small values or
  syntactically identical terms.

## Iteration 22 (continued) - root equality for large sizes and Type-kind containers

Supersedes the "Root equality ... not proved" items of the self-audit above and
the recovery notes of the previous section.

### The checker's comparison, measured (why large sizes failed)

* `term_compare` (the Bun checker) stops early only on POINTER-identical terms;
  otherwise it weak-head-evaluates both sides and compares structurally. Two
  separately built copies of a large closed number (a spec size such as
  `U32.to_nat(131072)`) are unfolded into unary digits and compared one stack
  frame per unit: past about 2^14 the JS stack overflows (the message "the
  machine stack overflowed" comes from the error printer's `term_snf`).
  Probes (build/natprobe2): `def p(+x, +e: {x == U32.to_nat(131072)}) ->
  {x == U32.to_nat(131072)}: e` overflows; closed Bool facts in a closed
  definition evaluate (`is_le(2^15, 2^15)` instant, `is_le(2^30, 2^30)` 524 s);
  `{s == Spec.Blob()}` against another copy checks instantly, but
  `roots(v, Spec.Blob(), ..)` against another copy overflows.
* New this round (build/zz_ok_all.bend, 1 s per probe): a closed fact that a
  closed definition evaluates (`{ok_IndexedAttestation(Spec.IndexedAttestation())
  == True}`, containing `Lim.minimal(32768, 15)`) is NOT evaluated when the same
  term arises after a rewrite `s -> Spec.Name()` or as an argument type: the
  check fails and printing the failure overflows. `{Nat.is_le(ListOf_limit(s),
  to_nat(131072))}` after the rewrite fails the same way; `{is_ListOf(s)}` and
  every fact whose numbers stay below 2^15 pass. Only IndexedAttestation and
  AttesterSlashing are affected (Electra attesting_indices limit 131072).
* Statement form used by every law that touches a large size:
  - the schema is a VARIABLE `s` with `es: s == Spec.Name()` (a consumer
    instantiates `s := Spec.Name(), es := {==}`);
  - object facts are stated RELATIVE to `s` (`rep_bv(o, s)`: the object's length
    is `ByteVector_length(s)`), never against a literal;
  - schema facts are ONE closed Bool (`ok_*(s, depth)`), proved at the name by a
    single rewrite and `{==}`;
  - schema shapes come from Bool tests (proofs/obj/schema_shapes.bend,
    codegen/schema_shapes.py: `is_C(s) == True -> s == C{C_f1(s), ..}`);
  - Data-kind existentials and pairs (proofs/obj/dk.bend `Ex`, `P2`, `Or2`),
    because Base's `Exists`/`&` are single-use and a root law needs the
    invariant twice (state rewrite and spec relation).

### Byte storage as objects

* proofs/obj/words_obj.bend: `wview(o)`, `wf1(o)` (perfect word tree t of depth
  dw < 32, length N = 32q + r with 1 <= r <= 32, room for the chunks, zero bytes
  after N to the chunk boundary), `rep_bv(o, s)`, `ok_bv(s, depth)`, `wdig(hl, o,
  depth)`, `bv_st` (the runtime root returns `(h, (o, wdig))`), `bv_rs` (the
  digest is a spec root of `wview(o)`).
* proofs/obj/list_root.bend (byte lists against spec ByteList: data tree, length
  mix-in via len_bridge + the SHA node bridge; empty and nonempty),
  proofs/obj/list_obj.bend (`wfl = Or2(wf0, wf1)`, `rep_bl`, `ok_bl`, `ldig`,
  `bl_st`, `bl_rs`), proofs/obj/nat_facts.bend (chunk bound from length bound).
* proofs/obj/pv_obj.bend: vectors of Bytes32. proofs/obj/ulist_obj.bend: lists of
  uint64 (`uitems`, `Pack.pack` of their `basic_bytes`, count = length >> 3
  mixed in). proofs/obj/elems_obj.bend + elems48.bend: packed Bytes48 vectors
  and lists (element roots are the phase-A `Bytes48` record law).
* proofs/obj/leaf_small.bend: uint8, ParticipationFlags, uint32, Bytes1.
  proofs/obj/bits_leaf.bend + phase-A bit records (bits of 32k bits): SyncAggregate,
  SyncCommitteeContribution.
* proofs/obj/cform.bend (3534 s under a machine load of ~30 from unrelated jobs):
  the concrete form `CF(o)` (word tree and length as values) of every byte
  storage invariant.

### Phase B (codegen/root_laws_b.py -> proofs/obj/root_types.bend)

Per Type-kind container / field group / box: view, digest, `rep`, `ok`, `eqs`
(equations for the Data-kind parts' schemas), the fields' chain-shape law, the
state law (the runtime rt-chain rewritten field by field with each field's state
law), the DIGEST WITNESS `wd_p : rep_p(o, s) -> DW(d_p(hl, o))` and the spec law
(field laws composed through `aggregate_digests`). Lists of Data-kind containers
get generated laws for their `_mt` trees (element reads through the array model).

* Why the digest witness: the spec relation's `Exists` witnesses (chunk lists)
  are computational, but a Type-kind object is an ERASED parameter (it holds
  arrays, so it cannot be copied). A container therefore cannot compute its
  chunks from `d_field(hl, pj(o))`. `wd_*` computes the same digest from values
  in the invariant (words: `CF`; boxes: the boxed record; lists: the element
  tree; containers: recursively), with the equation `d(hl, o) == dd`; the spec
  law rewrites the goal's field digests to the witnesses and moves each field law
  along `OS.dtrans`. Checker constraints met on the way: a binder that is used
  again cannot be destructured, and a call result cannot be destructured
  (projections `OS.dwv`/`OS.dwe` instead).
* Transaction (ByteList 2^30): its law is generated as a probe
  (build/probes/root_big.bend, not a gate): the closed fact
  `Lim.minimal(div(2^30 + 31, 32), 25)` did not finish in 23 min and the module
  overflowed at 803 s.
* Bisection of the module's stack overflow (the error printer hides the
  failing definition): `root_laws_b.py --only N1,N2 --out F` writes a probe
  module; probes (build/probe[A-H].log) located IndexedAttestation's STATE law.
  Mechanism: the runtime `O.words_root(.., depth, ..)` body builds
  `mtree(to_nat(depth), .., pow2n(to_nat(depth)), ..)`; the rewrite compares the
  stuck runtime term with the lemma instance, whose closed capacity
  `pow2n(to_nat(15))` is a separate copy, unfolded in unary. Depth 13 (8192:
  HistoricalBatch) checks, depth 15 (32768) overflows. The generator refuses
  fields of depth >= 14 with that reason (IndexedAttestation, AttesterSlashing).
  Remedy not taken: a U32 capacity in the runtime tree (runtime and mtree_run
  change).
* Result: proofs/obj/root_types.bend PASS (3730 s, 3.39 GB): 17 names -
  ContributionAndProof, SignedContributionAndProof, ProposerSlashing,
  HistoricalBatch, SyncCommittee, Deposit, ExecutionRequests,
  ExecutionPayloadHeader, LightClientHeader, LightClientOptimisticUpdate,
  LightClientFinalityUpdate, LightClientUpdate, LightClientBootstrap, Blob,
  BlobSidecar, DataColumnsByRootIdentifier, MatrixEntry. Each:
  `law N_root_correct: for -h, -o, +s, +es: {s == Spec.N()}, +rep: rep_p(o, s):
  RR.roots(v_p(o), s, [D.bytes(root of T.N_hash_tree_root(h, o))])`.

### Validity (item 2)

* proofs/obj/valid_names.bend PASS (1729 s): for the 70 phase-A Data-kind names,
  `T.<p>_valid(o) == VD.root_valid(v(o), Spec.N())` (spec/value_domain.bend) for
  every object - these are the names whose every representable object is valid,
  so both sides are True (rv_* lemmas). Not proved: agreement for the Type-kind,
  sub-word and list names (their validity is data-dependent); the fused bit-31
  put-chain = separate validity + encode (tested by
  tests_generated/invalid_objects.py 14/14, fuzz, spectests; no law).
* The 2^31 refusal is DISCLOSED as a supported-domain bound: counts carry the
  refusal mark in bit 31, so encodings of 2^31 bytes or more are refused (U32
  sizes already bound them by 2^32). No Fulu fixture approaches it; a
  BeaconState at the list limits could, and would be refused, not truncated.

### Input path (item 4)

* proofs/obj/fill_pieces.bend PASS (28 s): `driver_fill(size, ps, c, eg, hb)`:
  `fillp(ps, B.alloc(size), 0, 65536) == B.fill_at(B.alloc(size), 0, cat(ps))`,
  where `fillp` is the fill sequence of native_bench/driver.bend `read_loop`
  (`B.fill_at(buf, offset, piece)`, offset += 65536), for every list of pieces
  whose pieces but the last hold exactly 65536 bytes (`good(ps, 16384)`) and
  whose total length stays within a U32 bound c (no offset wrap). With
  load.bend, the buffer the driver builds is the literal buffer of the file's
  bytes. Trusted: `File.read_at` returns the file's bytes (Base IO).

### Toolchain handoff (item 7)

The operator's hash-only replacement for the protected automation/toolchain.json
(the gate stops at "Pinned 2.0.16 toolchain identity changed: bend"):
bend sha256 `3850c7cd281a687715a181ad6a2ecdef041704f320ea2b4304cf9e802309203c`,
Base (bend2/base.bend) sha256
`e5639663177f2de93ef34867c029698aa4e68a98d46629f0b15452b67b99d798`, version
`"2.0.25"`. Same text in docs/TOOLCHAIN.md. Not edited here (protected).

### Coverage table (final source, 2026-09-24)

| obligation | status | where / reason |
| --- | --- | --- |
| root = spec hash_tree_root, per name | **96 / 109 proved** | root_names (75), leaf_small (4), root_types (17); SHA via the pinned package law, no SHA normalization |
| root, remaining 13 names | not proved | bit lists (Attestation, AggregateAndProof, SignedAggregateAndProof, PendingAttestation); depth-15 tree (IndexedAttestation, AttesterSlashing); Transaction (limit fact, probe only); lists of Type-kind/2048-byte elements and 2^40 limits (ExecutionPayload, BeaconBlockBody, BeaconBlock, SignedBeaconBlock, DataColumnSidecar, BeaconState) |
| root, generic forms | not proved | no generic root law |
| cached root = spec root | not proved | proofs/obj/cache.bend has step laws only |
| Merkle layer | proved | mtree_spec (reference = spec tree), mtree_run (runtime = reference), zero_roots (63 constants vs spec) |
| `{p}_valid` = spec validity | 70 names proved | valid_names.bend; data-dependent names tested only |
| fused bit-31 put-chain = validity + encode | not proved | invalid_objects 14/14, fuzz, spectests |
| 2^31 refusal | disclosed | supported-domain bound (encodings < 2^31 bytes) |
| codec vs spec | 83 names (unchanged this round) | spec_codec_*, spec_unique_*; 26 names and the generic forms have no spec link |
| piecewise fill = whole fill | proved | fill_pieces.bend `driver_fill` |
| mutation / invariant / complexity laws | unchanged | laws.py mutation/collection/cache/cost step laws; no invariant-preservation or complexity-bound law on the object API |
| END_TO_END (29) / ROOT_DOMAIN (13) migration to the object API | not done | propositions unchanged and checked; docs/LAW_MIGRATION.json maps each to itself |
| runtime gates | pass | spectests 5440/5440, runtime 51/51, conformance, mutations, negative, cache, invalid, fuzz |
| performance | pass | gate 978 workloads / 327 ops; worst 4.3x decode, 4.1x encode, 5.9x root |
| decode memory | pass | 15/15 samples, worst 6,520,832 B |

### Trust assumptions

* The stock Bend 2.0.25 checker and native C backend (sha256 above) and Base;
  the pinned BendHub SHA package `0xda83506fb9f059ead7afcfa2f498df5f` and its
  filled law `sha256_array_correct`.
* The vendored/pinned specification modules spec/*.bend as the meaning of SSZ.
* Affine ownership (input isolation, no aliasing of arrays) is the compiler's
  and runtime's; it is tested (negative_api, object_mutations), not proved.
* `File.read_at` / `File.open` (Base IO) return the file's bytes.
* The representation invariants `rep_*(o, s)` are the hypotheses of the root
  laws; that the decoder and the mutation API only build objects satisfying them
  is proved for the words-level loader (load.bend, fill_pieces.bend) and the
  decoded Data names (`X_decoded_root_correct`), not for every Type-kind path.

### Final gates on the final source (2026-09-23/24)

Pre-build manifest build/final/source_manifest_prebuild.txt (673 files under
src, types, proofs, spec, benchmarks, native_bench, codegen, tools,
tests_generated and the root .bend files; aggregate 9b8a03ab…). After all gates
the only differing files are the gates' own outputs
benchmarks/evidence/{fuzz_generic,fuzz_objects,object_cache}.json.

* Static: every generator `--check` current (generate, laws, spec_laws,
  sha_laws, schema_shapes, root_laws, root_laws_b); `check_schema.py` 109/109,
  10 malformed rejected; `import_graph.py --check` OK (production reaches only
  the shared runtime primitives; no unreachable src module).
* Runtime (build/final/runtime_summary.log): spectests 5440/5440; runtime tests
  51/51 (20009 assertions); object conformance 295 / 59 types; generic
  conformance 5145/5145; object mutations 0 disagreements; mutations 8/8;
  negative API 7/7; cached roots 7/7; invalid objects 14/14; fuzz with the
  fresh seed 20260924: objects 327 valid + 1962 mutated + 768 history cases / 109
  types, generic 5393 cases / 136 schemas, 0 mismatches.
* Performance (automation/performance_gate.py, fresh build): `PERFORMANCE GATE:
  978 workloads / 327 operations within their operation-specific limits`. Worst
  deserialize 4.3x (SignedBeaconBlockHeader medium), serialize 4.1x (BeaconBlock
  small), hash_tree_root 5.9x (Attestation small). Log sha256 775642da…, report
  build/performance/report.json sha256 f50388bc…; BENCHMARKS.md regenerated from
  it. All 21 codec rows >= 3.5x re-run (benchmarks/run.py --only …,
  build/final/borderline_rerun.log): within ±0.3x, worst 4.3x / 4.0x. The
  machine carried unrelated load (load average 9-12) during these runs.
* Memory: native_bench/run.py 15/15 Bend samples verified, worst decode overhead
  6,520,832 B (MEMORY_REVIEW.md). automation/native_memory_acceptance.py stops
  at "Pinned 2.0.16 toolchain identity changed: bend" (toolchain handoff above).
* Proofs, sequentially, one checker at a time, uncapped (proofs/*.bend,
  proofs/compact/*.bend, proofs/obj/*.bend, HASH_PROOF, END_TO_END, ROOT_DOMAIN,
  PROOF): **260/260 PASS**, all "All terms check.", zero unsafe. Total 219.6 min;
  peak 5.61 GB (spec_unique_1, 1098 s); longest spec_repr_6 1258 s; root_types
  554 s / 3.40 GB, root_names 514 s, valid_names 474 s, cform 355 s; END_TO_END
  3.86 GB / 103 s, ROOT_DOMAIN 3.83 GB / 103 s, PROOF 3.57 GB / 90 s. Log
  build/final/proofs_final_iter22b.log (sha256 97517276…).

### Self-audit (AUDITOR.md), final

Met: native performance and memory targets on the generated owning-object API
(all 978 workloads); all official cases and runtime tests; stock 2.0.25, pinned
SHA package, no FFI or hardware SHA, zero unsafe/axioms/holes; root equality
with the independent spec for 96 of 109 names through the actual public root
function; piecewise input fill; validity agreement for 70 names.

Open, stated as such (none of these is claimed):
- root equality for 13 names, for the generic forms, and cached root = spec
  root (reasons in the coverage table);
- codec total correctness beyond the 83 spec-linked names, and the generic
  forms' spec link;
- a law for the fused bit-31 encoder flag; validity agreement for
  data-dependent names; the 2^31-byte refusal is a disclosed domain bound;
- migration of the 29 END_TO_END + 13 ROOT_DOMAIN propositions onto the object
  API (unchanged, checked), invariant-preservation and complexity-bound laws;
- automation/toolchain.json hash-only update (operator).

## Iteration 22, round 3 - recovery notes (work in progress; later sections supersede)

* The depth-15 failure, re-diagnosed with sub-second probes (proofs/obj/zz_p5.bend
  pattern, now deleted): it is NOT the runtime tree. `ul_st` at depth 15 checks
  (330 s probe) and a stuck `words_root` body with `pow2n(to_nat(15))` compares
  fine. The failing step is any comparison of two copies of a schema fact with a
  literal large depth over a SCHEMA VARIABLE: even
  `def t(+x: Nat, +k: {Lim.minimal(x, 15n) == True}) -> {Lim.minimal(x, 15n) == True}: k`
  overflows. `Nat.is_le(<stuck>, capacity(15n))` is `Nat.cmp`, which matches
  both arguments; with the first stuck, the checker compares the branches by
  unrolling the closed bound 2^15 in unary. Closed facts (no variable) evaluate.
* Fix (general, no refusal): proofs/obj/obj_support.bend `DV` - a record of the
  depths 14..40 that every schema-variable law holds as a VARIABLE `dv` with
  `edv: dv == DV0()`; `dveq`, `dvu`, `dvl` recover the literal facts;
  `ok_at` moves a closed schema fact at (Spec.N(), DV0()) to (s, dv). Generated
  laws (codegen/root_laws_b.py): `ok_p(s, dv)`, fields of depth >= 14 use
  `OS.dv_d(dv)` in schema facts, their spec laws run at the variable depth and a
  cong-`dtrans` returns to the literal-depth digest the runtime computes; name
  laws are `N_okc` (closed, evaluated once), `N_ok` (transported), `N_rc` (over
  dv) and `N_root_correct = N_rc(.., DV0(), {==})`. IndexedAttestation +
  AttesterSlashing probe: PASS (499 s, 4.14 GB).
* Transaction back in proofs/obj/root_big.bend with the same scheme; its closed
  fact `minimal(div(2^30 + 31, 32), 25)` is a linear but ~2^30-step unary
  evaluation (Nat.divmod over Word.to_nat doublings); check running (> 90 CPU
  min, 1.3-2.6 GB).
* Bit lists: codegen/bitlist_laws.py -> proofs/obj/bitlist_pack.bend (`bpack`:
  the first k bits of a word list pack to its first ceil(k/8) bytes when the bits
  of the last byte past k are zero; 31 generated partial-word cases over Bool
  parameters) and proofs/obj/bitlist_obj.bend (invariant, `bst` state law,
  `brs` spec law via bpack + chunk_scan + at_depth_tree + mix_bytes, `bwd`
  witness). The invariant carries `byte_count(k) == to_nat(bits_nbytes(k))` and
  `length(view) == k` as facts; both hold for every k < 2^32 - 7 and are item-2
  obligations. Not yet checked (waits for the single checker slot).
* Lists of Type-kind elements (BeaconBlockBody lists, transactions): the array
  holds Type-kind boxes, so found.bend's Data mirror trees do not apply and the
  root laws only ever see the object erased. Plan: generated Data-kind mirror
  types per Type-kind shape with a `thaw`, invariants as `o == thaw(m)`, and the
  found.bend swap proofs over mapped mirror trees.

## Iteration 23 (Linux host, 2026-09-24) - recovery notes

* Host migrated to Linux x86_64; checker memory is now VmHWM (Linux peak RSS), not
  macOS physical footprint. Mac logs are historical.
* The Mac root_big check (started 08:56 CEST) left no final log: NOT a pass; rerun queued.
* New: codegen/packed_laws.py -> proofs/obj/packed_obj.bend: root laws of vectors of
  uint32/64/128/256 in packed words (elements `it{W}`, bytes `pb{W}` by limb_correct,
  `v{W}_rs` via ulist ul_pack + at_depth_tree). root_laws_b.py `packed_law` emits a
  per-name law for 40 generic packed vectors. Linux check: PASS (585.6 s, 3.20 GB VmHWM).
  First attempt failed: an erased object was used in a relevant argument (fixed by
  transporting the count fact to the destructured length N).
* Still not covered in generic forms: bool/uint8/uint16 vectors (need per-byte
  domain lemmas: limb bytes as embed8 words), progressive lists (7), partial-word
  bitvector records (16), unions (3), 1 progressive container, u8/u16/u32 leaves.
* Linux conformance on the current source (native, Ubuntu clang 21.1.8 via CC, see
  docs/TOOLCHAIN.md): tools/spectests.py 5440/5440 passed; tools/run_runtime_tests.py
  51/51 tests, 20009 assertions (Bun 1.4.2; these are JS, not native, as before).
  A first spectest attempt reported 939 failures: two spectest processes had been
  started and shared build/spectests/case.out; with one process all pass.
* benchmarks/run.py and native_bench/run.py: `footprint()` (compiler-process memory
  cap) read macOS libproc only; now reads Linux VmHWM on Linux; the CPU name comes
  from /proc/cpuinfo on Linux. `PY3` falls back to the running interpreter when
  /opt/homebrew is absent. Measured-program memory was already wait4 ru_maxrss.
* New generated root laws (checks queued, sequential):
  - packed_bytes.bend (codegen/packed_laws.py): vectors of uint8, boolean, uint16
    (byte-level encodings over symbolic bits: `bone8`, `bbool1`, `two8`; the bool
    storage invariant `bscope`: every byte 0/1);
  - gleaf.bend (root_laws_generic.py): generic uint8/uint16/uint32 leaves (`half_shape`,
    `u16_w`);
  - gbits.bend: the 16 generic bit vectors of length not a multiple of 32, via
    bitlist_pack `bpack`, invariant: last word = its low k bits then zeros;
  - prog_root.bend (hand-written): the runtime progressive tree `O.ptree` is `pr`
    (pt_run) and bytes(pr) = spec/progressive.bend `tree` (pr_spec) for every
    fuel/depth with the invariants n <= s + fuel and 2^dep <= 4s + 1 (so dep < 64
    without any closed large number);
  - prog_list.bend (codegen/prog_laws.py): the 7 progressive lists of basic elements.
  Generic status now (root_laws_generic.py --status): 123 of 139 forms with a law
  (70 packed vectors, 18 byte storage, 16 partial bit vectors, 7 progressive lists,
  6 phase A, 3 leaves, 3 phase B containers), pending checks. Not covered: 3
  compatible unions, 2 progressive containers, 8 containers with uint8/uint16/
  partial-bitvector fields (phase A/B lack a data field with a representation fact),
  1 container with a progressive list field, GtF7582E0E9A (bit list of depth 56).
* Measured check cost floor on this host: importing mtree_spec costs ~310 s
  (zero_roots evaluates 63 concrete SHA-256 compressions, 254 s); every module
  importing the tree laws pays it.
* Benchmark portability fix: tools/generate_bench_go.py read go-eth2-client from
  the Mac module cache path; on Linux it found nothing and silently routed every
  container to the locally sszgen-generated `gen` package (and 4 types to no
  reference). It now resolves the pinned v0.27.2 module via `go env GOMODCACHE`
  and fails loudly if absent; regenerated benchmarks/fastssz/generated.go is
  byte-identical to the committed one. The first Linux benchmark run (bench-snap-1)
  is therefore INVALID (wrong reference) and was renamed accordingly; a fresh
  snapshot run (bench-snap-2) is measuring. benchmarks/checks/capped_{build,run}.py
  read Linux VmHWM; fuzz evidence records sys.executable instead of a Homebrew path.
* Native memory harness on Linux: the first Linux run (mem-snap-1) reported
  baseline == decode peak == the same byte count for Go AND Bend on every sample
  (31-36 MB): Linux keeps ru_maxrss across exec, so a child forked from the
  Python harness reports the harness's own resident size (measured: /bin/true
  spawned from Python "peaks" at 12 MB; 1.2 MB under /usr/bin/time). INVALID,
  renamed mem-snap-1-INVALID-inherited-maxrss. native_bench/run.py now starts the
  measured program under /usr/bin/time on Linux and takes the child's kernel
  peak from its report; the sampler follows the program's pid (/proc children).
  psutil is optional (Linux reads /proc/<pid>/statm). Re-run: mem-snap-2.
  With the /usr/bin/time fix the Linux numbers are real (e.g. Bend case_0: baseline
  9.04 MB, decode peak 14.75 MB, overhead 5.71 MB). The harness's own consistency
  check (sampled decode max <= 1.05 x the decode-prefix run's kernel peak) then
  failed once for Go (13.93 MB vs 12.85 MB: its collector timed differently in the
  two processes). The 5% tolerance is unchanged; a sample that fails it is now
  re-measured up to 5 times with every attempt recorded in the sample
  (`representativeness_attempts`), and the run still aborts if none agrees.
  Re-run: mem-snap-3.
* Runtime change (cache paths only): src/obj.bend `pow2u(1 + q)` is now
  `U32.shl(pow2u(q))` instead of `pow2u(q) * 2` - the same U32 for every q
  (both wrap mod 2^32); only the `_Cached` lists (cache_at, capp, the root sweep)
  use it. Reason: found.bend's checked `u32__pow2u` is the shl form, so its value
  lemma (to_nat(pow2u(d)) = 2^d for every symbolic d < 32) now applies to the
  runtime's capacity; U32.mul recurses over its left operand's bits and could not
  be related symbolically. Measurements taken before this change are historical.
* After the pow2u change: benchmarks/compact/ocache.bend was stale against the
  `+hl` root signature (`_root(O.hasher(), ...)`), so the uncached calls now pass
  64n. Rebuilt; benchmarks/checks/object_cache.py (its `time -l` was replaced by
  GNU time on Linux) passes: 5 ssz_random BeaconStates, synthetic 1024 and 8192
  validators, and 100 seeded mutation histories all give cached root = uncached
  root = oracle root.
* Fuzz (Linux, same seed 20260924): fuzz_objects gave 654 valid, 7848 mutated and
  2048 history cases over 109 types with 0 mismatches. fuzz_generic gave 7739
  cases over 136 generic schemas with 0 mismatches.
* mem-snap-3 is complete, with 15/15 verified Bend samples. The worst Bend
  decode overhead is 5,844,992 B (Linux RSS; cap 32,000,000). See the
  MEMORY_REVIEW.md Linux section. automation/acceptance.py on this host still
  stops at "Pinned 2.0.16 toolchain identity changed: bend".
* Cached-root proofs (item 1f) and a Bend 2.0.25 kind rule. The first ctree
  model stated its invariants as function types: "every clean node holds its
  value" was `@l -> @j -> ... -> ok_at`. The checker rejects this. A `+`
  (duplicable) parameter must be `Data`, and a Pi type is only `Type`.
  Probes in /tmp/bprobe showed that a plain function hypothesis is strictly
  linear ("consumed more than once"). An erased one cannot be used even in
  the rewrite position of `%e : M`. The invariant is needed at every tree
  level, so ctree's quantified layer was rewritten as data:
  - `LV`, `CL`, `AU`, `CI` are finite products of node facts (`Sigma<&2, &2, ...>`,
    recursion on a count), so `cinv`, `lvl_ok` and `all_upto` are Data.
  - Accessors are `lv_get`, `cl_get`, `au_get` and `ci_lvl`; single-write maps are
    `lv_wo`, `cl_w`, `ci_w` and `au_w`; the loop lemmas `lv_pre` and `lv_build` build
    products by recursion.
  - The pointwise lemmas are unchanged (backup: build/ctree.fn.bak).
  - In cloc.bend, leaf agreement is now a concrete change `dput(XL, i, x)`
    (replace leaf i, or append when i is the length). Its agreement facts,
    `put_at` and `put_len`, are lemmas rather than a hypothesis.
  - New files, being checked:
    - cloop.bend: the runtime node step and level loop;
    - cloop2.bend: leaf loop, level loops, `xl`;
    - cloop3.bend: `csweep`, padding and `cached_root_correct`;
    - cset.bend: write preservation (`xl_set`);
    - cmut.bend: append preservation (`xl_app`) and the fresh-cache invariant.
  - Stated hypotheses (not yet derived from `words_depth`): n <= 2^d,
    d < 31, and items capacity 2^dw >= 2^d.
* bench-snap-2 (Linux, pre-pow2u runtime) passes the frozen gate's `validate`
  in its snapshot: 978 workloads / 327 operations within limits. The final
  snapshots (bench-snap-3, mem-snap-4) were started on the current sources.
* obj_support.bend: the depth record `DV` now covers depths 14 .. 63 (was
  14 .. 40). The generic set has a container of a bitlist whose tree depth is
  56, and root_gtypes referred to `OS.dv_56`. `dvl` already bounds depths below
  64. Files importing obj_support must be re-checked (root_types, root_gnames,
  root_gtypes, root_big).
* cloop3's first re-check was stopped after 40 s (exit -15) because it imported the cloop2 version already known to fail at lt_items. It was not stopped for time; it is re-queued after the fixed cloop2.
* cloop3's second start was likewise stopped after about 15 s (stale cloop2 import: swapped Equal.sym endpoints in cleaf_b, now fixed).
* wdepth.bend: checker stack overflow ("a literal too large to expand"), no location. The only closed large quantity is pow2n(32n) in u32_lt32. wdstage's check, which imports wdepth, was stopped after 90 s (doomed, not for time). A probe (proofs/obj/probe_u32.bend) isolates which step of the 2^32 bound overflows.
* Final Linux benchmark (bench-snap-3, current sources): the frozen gate's
  `validate` passes in the snapshot, with 978 workloads / 327 operations within
  limits. The row closest to its limit is Attestation.hash_tree_root
  small-fixture at 9.1x of 10x (Bend 28.7 us vs Go 3.2 us). It was re-measured
  with benchmarks/quick.py (same programs, 9 alternating samples, 0.25 s
  target, reports build/quick/attestation_small_{1,2,3}.json): 8.30x, 7.99x and
  8.99x.
  - The margin is thin on this host (load average near 100). On the Apple M4
    host of iteration 22 the same row was 5.9x.
  - Absolute times here are about 4x the Mac's for Bend and 3x for Go; the
    row is SHA-bound (pure-Bend SHA-256 by requirement).
  - The runtime was not changed for it: `words_root` is under checked root laws.
  tools/generate_benchmarks_md.py now lists the five rows closest to their
  limits and marks the per-node SHA and zero-fill timings as Mac measurements.
* Checker limit, now measured precisely (Base-only probes proofs/obj/probe_k*.bend, removed after use).
  Any statement containing a closed Nat term whose value is at or above 2^16
  overflows the pinned checker at once (0.4 s), even when the two sides are
  syntactically identical: `dbl(16n) == dbl(16n)`, `dbl32(32n) == ...` and
  `U32.to_nat(4294967295) == ...` all fail. So proofs must never state a
  closed large number. Widths are symbolic or at most 32. Powers of two
  are replaced by shifts (`rng(k, M) < 1` for M < 2^k). U32 literals
  are related through `O.pow2u(K)` as 32-bit words (wdepth/wdstage rewritten
  this way).
* Runtime change (codegen/generate.py, all 17 `_Cached` lists): after a root the
  dirty range is `[n, 0]`, where it used to be `[0xFFFFFFFF, 0]`.
  - It is empty for n > 0. For n = 0 it is the one zero leaf: one extra leaf
    and its path on the next root of an empty list.
  - A later write at i < n widens it to [i, i] and an append to [n, n], by the
    same min/max as before. Hashing is otherwise unchanged.
  - Reason: with the old sentinel, the first write after a root needed the
    Nat value of 2^32 - 1, which the checker cannot state.
  - Revalidated on the regenerated runtime:
    - benchmarks/checks/object_cache.py: 7 fixtures and 100 histories,
      cached = uncached = oracle;
    - runtime tests: 51/51, 20009 assertions;
    - fuzz_objects, seed 20260925: 654 valid, 7848 mutated and 2048 history
      cases, 0 mismatches;
    - generic fuzz and spectests: running.
* Checked (Linux): cset.bend (write preservation, `xl_set`) PASS 779 s,
  3.20 GB. codegen/root_laws_b.py no longer misfiles a progressive bit-list
  field as a fixed-depth bit list (Gp4B0CA2906A, Gc60805EC295 are now
  "not covered").
* New: proofs/obj/capi.bend covers the public cache API on a Data-packaged
  invariant: `root_eq`/`root_inv`, `cset_eq`/`cset_inv`, `capp_eq`/`capp_inv`
  (append inside the capacity) and `cache_eq`/`cache_inv` (fresh cache, via
  `words_depth`). codegen/cached_laws.py emits the six parts for the 11 other
  Data-element lists (proofs/obj/cached_<list>.bend).
- 2026-09-24 16:09:09 Stopped the wdstage check (doomed: it imports wdepth, whose blen had a linearity error, fixed with erased binders `+k`/`+j`). Requeued wdepth then wdstage.
- History law (proofs/obj/chist.bend, queued): `hist_inv` — from a valid cache
  (one of the form `cached(ta, t, n, d, lo, hi)` with `CA.inv`) of length n, a
  history of `cset`/`capp` calls whose preconditions hold at each step (write
  index < current length; appends keep n + 1 <= 2^k, k <= 30, k <= limit depth)
  ends in a valid cache. With `CA.root_eq` the root of that cache is the
  reference root of its elements; with `CA.cache_inv` the history can start
  from `cache(o)`. Type-kind cache values are ghost (`-c`) binders (a `+`
  binder needs a Data type); Base-only probe build/probe_tk.bend confirmed the
  pattern. codegen/cached_laws.py now also writes chist_<list>.bend for the 11
  generated lists (importing cached_<list>.bend); the cached_*.bend files are
  byte-identical to before.
- 2026-09-24 16:28:24 Spectests on the regenerated runtime (croot_fin range n,0): 5440 passed, 0 failed (build/spectests_reval.json).
- Cached-root spec link (queued): codegen/cached_laws.py writes
  proofs/obj/cspec_<list>.bend for the 6 generated lists whose uncached root law
  `rs_<list>` is in root_types.bend (DepositRequest, WithdrawalRequest,
  ConsolidationRequest, Withdrawal, SignedVoluntaryExit,
  SignedBLSToExecutionChange). `cached_spec`: for a valid cache (CA.inv) whose
  length fits the schema, `cached_root` returns CA.dig(n, ta) (CA.root_eq) AND
  RR.roots(RT.xv_<list>(Seq{thaw ta, n}), s, [bytes(CA.dig(n, ta))]) — the
  independent root relation. Proof: `xl_same` (the two element-root lists are
  the same recursion), `freeze_thaw`, and RT.rs_<list> with the rep built from
  the cache invariant. The 5 BeaconState-only lists (Eth1Data votes,
  HistoricalSummary, PendingDeposit, PendingPartialWithdrawal,
  PendingConsolidation) have no uncached law (BeaconState is not covered), so
  no spec link.
- Cached-root cost law (proofs/obj/ccost.bend, queued): `sweep_cost`,
  ncost(k, l, lo, hi) <= (rng(l, hi) - rng(l, lo)) + 3k, where ncost is the sum
  of the per-level step counts CT.qn that cloop2's `clevels` proves the runtime
  level loops run. Whole sweep: <= (hi - lo) + 3d node hashes; one write: <= 3d.
- Toolchain docs: docs/TOOLCHAIN.md now records the Linux binary hash
  (d9c0dad1...) next to the Mac one; README's reproduce section points at it
  instead of the stale 2.0.16 text.
- 2026-09-24 17:03:04 capi FAIL (720 s): pw_le_dw rewrote with sym(pow2_eq) though pow2_eq is already {pow2 == pow2n}; fixed. Stopped the cgrow check that had read the old capi (doomed). Regenerated cached_*.bend; requeued capi, cgrow.
- Producers establish rep (item 2, list values; generated, queued): the 6
  cspec_<list>.bend files also hold `default_rep`, `uncache_rep` (from CA.inv),
  `set_rep` (i < n) and `append_rep` (runtime guard n + 1 <= limit accepted,
  n < 2^k, k <= 30, n + 1 <= schema limit): each producer reports success and
  its result satisfies RT.rep_<list>, the hypothesis of RT.rs_<list>. The
  append proof reuses cgrow's room/copy lemmas (the Seq append and the
  capacity-growing capp share `room`).
- Check-time packaging: generated laws that share expensive imports are in one
  file: history law folded into cached_<list>.bend (chist's `len_after`
  renamed `op_len`, the one name clash with capi); producer laws folded into
  cspec_<list>.bend. Queue now 27 files.
- 2026-09-24 17:59:05 chist and all generated cached/cspec files failed at parse (2.8 s): constructor `App` clashes with Base's App (constructor names are global). Renamed HWrite/HAppend, regenerated, requeued (chist, cached_l16_Withdrawal, cspec_l16_Withdrawal first).
- root_gtypes.bend (regenerated without the two pbits containers; DV to depth 63): Linux PASS 1298 s, 4.81 GB VmHWM.
- prog_root.bend (with the prog_list pow2_eq fix): Linux PASS 573 s, 3.22 GB.
- 2026-09-24 18:20:58 chist parse error: a second parameter destructure after a let (`(+hop, +hrest) = hok` after `(+vc, +en) = st`). run_valid now takes one packed parameter. Regenerated, requeued.
- Recovery note (2026-09-24 22:35 CEST, after usage-limit wait): queue daemon
  build/pqd.sh still running; gbits.bend check running for 2.5 h at a flat
  2.78 GB VmHWM (16 generic bit vectors up to 513 bits over symbolic words);
  not stopped (no time cap). Next in queue: chist (packed-parameter fix),
  cached_l16_Withdrawal (includes history law), cspec_l16_Withdrawal (spec link
  + producer rep laws), then packed_bytes, root_gnames, root_types, root_big,
  cache, the other 10 cached_* and 5 cspec_*. Generators current (--check).
- Removed proofs/zzp/p2.bend (iteration-22 scratch probe, unreferenced).
- Decode producer law (generated into cspec_<list>.bend, queued): `read_rep`
  — the list decoder `<list>_read(buf, off, len)` for len != 0, n = len/size
  >= 1, n <= 2^k (k <= 30), n <= schema limit, yields a value with
  RT.rep_<list>; `read_empty_rep` for len = 0. Loop lemma `rd_ok`: the element
  loop writes positions i..i+k of a perfect tree of depth D and leaves a perfect
  tree (induction on k, case split of the ghost (buffer, element) pair).
  Probe build/probes/probe_peta.bend (queued first) checks that a ghost
  Type-kind pair can be matched in a proof.
- gbits.bend: check ended with exit -15 (SIGTERM) after 19,672 s at 2.84 GB
  VmHWM. I did not stop it (not from this session); recorded as NOT passed. It
  must be re-run (or split per law) before any coverage claim.
- Probe results: matching a ghost (`-`) Type-kind pair in a proof is refused
  ("a live scrutinee ... matches only in a dead region"); the read laws must
  take the (buffer, element) pair as a live parameter. chist still fails at the
  second destructure (`(+hop, +hrest) = hok` after `(+vc, +en) = st`, both from
  the packed parameter); probes queued to find the accepted form.
- OPERATOR_DIRECTIVE_20260925.md: gbits.bend (5 h+, stopped by the operator)
  is a proof-engineering bottleneck. Split: codegen/root_laws_generic.py now
  writes one file per partial-word bit vector (proofs/obj/gbits_<name>.bend,
  16 files, each with the two shared list lemmas; gbits.bend removed; other
  generic outputs byte-identical). Diagnosis in progress: only the 511-bit
  (tree depth 1) and 513-bit (depth 2) vectors hash nodes; their `_st` step is
  a `{==}` between the runtime root and the reference tree, which forces the
  checker through SHA-256 over symbolic words. Incremental measurement: 1-bit
  and 17-bit files queued first, the other 12 small ones after; 511/513 held
  back until `_st` is refactored.
- gbits refactor: for vectors whose tree has depth >= 1 (511, 513 bits), `<name>_shape` states rtree(depth, True, hl, [x0..], 0) = the runtime's node shape over OPAQUE digests (SHA stays unevaluated), and `_st` rewrites with it so its final {==} compares syntactically equal terms instead of evaluating SHA-256 over the partly known last word. Queued: 1-bit, 17-bit (baselines), then 511, 513, then the rest.
- bend-collections reuse assessment (OPERATOR_DIRECTIVE_20260925): docs/BEND_COLLECTIONS_REUSE.md. Upstream 06caea4 inspected; same 2.0.25/Base pin; its array/Nat/U32 library is already vendored (found.bend) and used by all new proofs; bitlist/dynamic_array refine their own models, carry no SSZ encoding/root facts, and use different representations, so they are not adopted as storage.
- packed_bytes.bend: Linux PASS 624 s, 3.26 GB VmHWM.
- root_gnames.bend: Linux PASS 931 s, 3.85 GB. gbits_GtFCF8066C33 (Bitvector[1]): PASS 624 s, 3.97 GB (mostly imports).
- gbits_GtFF7C03E8A0 (Bitvector[17]): PASS 608 s, 4.19 GB (= import baseline). Depth-0 laws measured cheap, so the 14 one-chunk vectors are regrouped in gbits_small.bend; 511 (depth 1) and 513 (depth 2) stay separate (gbits_Gt05340E1F7E, gbits_Gt0B0C03B454). 511 check started 02:14.
- 2026-09-25 00:45:44 gbits_Gt05340E1F7E (511 bits, with the shape lemma) stopped after ~27 min at flat 3.84 GB (same spin pattern as the full gbits run). Stopped for diagnosis per OPERATOR_DIRECTIVE_20260925 (measure incrementally), not for time. Bisection probes: build/probes/g511_st.bend (shape + _st only), g511_g.bend (_lh, _len, _ch, _g).
- probe g511_st (shape + _st of the 511-bit law): PASS 631 s, 2.96 GB = import baseline. The shape refactor works; the spin is in another step.
- probe g511_g (_lh, _len, _ch, _g): PASS 602 s, 3.67 GB = import baseline. Next probe g511_h (everything through _h, no law).
- 2026-09-25 01:08:00 chist: destructure after an ordinary let is refused too (`(+ta, w1) = vc` after `+hop = pa(...)`); all destructures now precede the projection lets. Regenerated; chain requeued.
- root_types.bend (DV to depth 63): Linux PASS 948 s, 4.18 GB.
- 2026-09-25 01:35:12 chist FAIL 715 s, 3.14 GB: rebase rewrote with sym(e) (should be e). Fixed and regenerated. Stopped the cached_l16_Withdrawal check started on the old text (doomed). cspec_l16_Withdrawal (imports the fixed cached file) runs next, then chist and cached.
- cspec_l16_Withdrawal FAIL 765 s: the generated lists' runtime `capp` guards
  the append with the list limit (`capp_in(U32.is_le(n + 1, LIMIT), ...)`),
  the Validator instance with True{} (limit 2^40). capi now defines
  `guard(n)` (True{} for the instance; the generator substitutes
  `U32.is_le((n + 1 : U32), LIMIT)` per list) and `capp_eq`/`grow_eq` take
  `hgd: guard(n) == True`; chist's append precondition includes it. capi,
  cgrow, chist and the generated files requeued.
- Probe g511_h (everything through `_h`): still running at 22 min (2x the
  import baseline), stopped: `_h` is the step that spins. Cause: its goal has
  D.bytes(snd(hash_tree_root(h, obj))) and the rewritten motive
  D.bytes(snd(bv511_root(64n, h, obj, 0))); the checker unfolds both through
  SHA-256 over the partly known last word and compares two separately built
  huge terms (flat memory, exponential time). Fix (generator): `<name>_htr`,
  hash_tree_root(h, o) == <p>_root(64n, h, o, 0) over an opaque o (one delta
  step), used first in `_h`, so every later comparison is syntactic. 511-bit
  file requeued first.
- Refined gbits diagnosis. The g511_g probe shows the checker compares
  congruent spines first. The costly step is where heads differ over
  SHA-bearing digests: the final `(depth, ({==}, _g))` checked
  D.bytes(Pair.snd(h, DIG)) against _g's D.bytes(DIG), which reduces both
  sides through SHA-256. New generated step `<name>_fin` states that final
  pair over an OPAQUE digest r (Pair.snd(h, r) reduces to the variable r);
  `_h` instantiates r := DIG syntactically. `_htr` is kept (it has the same
  effect for the hash_tree_root/runtime-root alias). No statement changed.
- capi.bend with the append guard: Linux PASS 713 s, 3.23 GB.
- 2026-09-25 03:05:40 gbits_Gt05340E1F7E with _htr and _fin: still at flat 2.72 GB after 40 min; stopped for diagnosis. Probes queued: g511_fin (only _fin), g511_h2 (through the new _h, no law).
- Probes: g511_fin PASS 633 s; g31 (Bitvector[31], same 31-deep bit match,
  depth 0) PASS 612 s, so the deep match is not the cause. Every passing probe
  had a symbolic hash length hl, and D.node(hl, ...) stays stuck on it. `_h`
  used hl = 64n with a last word built from 31 bit variables, which lets
  SHA-256's word operations unfold through the cells. Generator change: `_h` is
  stated for symbolic hl with ehl: hl == 64n, over the runtime root at hl. The
  law rewrites hash_tree_root to the runtime root (`_htr`, over the object whose
  last word is take(bits(w15)), opaque) and only then instantiates hl := 64n.
  g511_h2 (old _h) stopped as obsolete; the regenerated 511 file queued first.
- 2026-09-25 03:53:23 gbits_Gt05340E1F7E with symbolic-hl _h: still running at 25 min (3.34 GB); stopped for diagnosis. Probe g511_h3 (through the new _h, no law) queued.
- Probe g511_h3 (through the symbolic-hl `_h`, no law): PASS 657 s, so the law
  step spins. Finding: once the law has destructured o into its 16 words, any
  goal holding the root at 64n reduces into SHA-256 over those fields. The
  working container laws (root_names) keep o opaque whenever 64n appears.
  Generator: the law now rewrites hash_tree_root(h, o) to <p>_root(64n, h, o,
  0) with o opaque (`_htr`), then calls `_lawg`, which is stated for symbolic
  hl, destructures o and applies `_h`. Law statement byte-identical.
- cgrow.bend with the append guard: Linux PASS 749 s, 3.01 GB.
- gbits_Gt05340E1F7E (Bitvector[511], depth 1): Linux PASS 602 s, 4.18 GB
  (= import baseline; the same law was > 5 h before). Proof-engineering rule
  found: never let a goal contain the runtime root at the concrete hash length
  64n while the object's fields are exposed. Keep o opaque (or hl symbolic)
  wherever SHA could reduce. Next: 513 bits (depth 2), then gbits_small.
- chist.bend (hist_inv, with the append guard): Linux PASS 729 s, 3.23 GB.
- gbits_Gt0B0C03B454 (Bitvector[513], depth 2): Linux PASS 649 s, 3.13 GB.
- Item 2, setters (generated, queued): codegen/rep_laws.py ->
  proofs/obj/prep_setters.bend, 127 laws over the 27 Type-kind containers with
  rep_<X> in root_types. For every field setter,
  rep_X(o, s) [+ the field's own invariant of v] -> rep_X(X_set_<f>(o, v), s).
  Field order comes from codegen/fulu.yaml; setters from types/fulu_obj.bend.
  The proof returns the same witnesses and invariants with field f replaced, so
  the other components are provably the old ones.
- cached_l16_Withdrawal.bend (generated: all 8 parts incl. guard and history): Linux PASS 737 s, 3.10 GB.
- cspec_l16_Withdrawal FAIL 966 s at `cached_spec`'s statement (DK.P2 needs Data; RR.roots is a Type). xat_same, xl_same and dig_spec checked before it. Fixed: the conclusion is the Type pair {cached_root = ...} & RR.roots(...). Requeued after prep_setters.
- gbits_small.bend (14 one-chunk bit vectors): Linux PASS 660 s, 3.21 GB. All 16 partial-word bit-vector root laws now check: 602 + 649 + 660 s in three files, against > 5 h (unfinished) for the former single gbits.bend.
- prep_setters.bend (127 setter rep laws, 27 Type-kind containers): Linux PASS 988 s, 3.70 GB. Nested update/append on a container field composes: the list producer law (cspec_<list>: set_rep/append_rep) gives the field's invariant, then the setter law gives the container's.
- cspec_l16_Withdrawal FAIL 984 s at read_rep: the live buffer was used twice (inside the tree witness rto(...) passed as a + argument, and as rd_eq's live pair). All laws before read_rep (cached_spec, default/uncache/set/append) now check. Fix: rd_eq returns the tree as an existential witness, rto removed. Requeued.
- 2026-09-25 06:05:23 Final runtime gates started (build/final_runtime.sh -> build/final_runtime/): runtime tests, spectests, object/generic conformance, mutations, negative API, cache, invalid objects, fuzz builds and fresh-seed fuzz (seed 20260926). Runtime sources unchanged since 2026-09-24 18:02.
  - runtime tests (current sources, run separately; the script's first call lacked the file list): 51/51 passed, 20009 assertions (build/final_runtime/runtime_tests.out).
  - spectests 5440/5440; object conformance 295 (59 types); generic
    conformance 5145/5145; object mutations 0 disagreements; negative API 7/7
    (build/final_runtime/*.out).
  - build/compact-{ocache,omut,oinvalid} rebuilt from current sources (the
    ocache binary predated the 18:02 regeneration; omut/oinvalid were
    missing), then: object cache 7 fixtures match the oracle; mutation
    regressions 8/8; invalid objects 14/14.
  - fresh-seed fuzz (seed 20260926): fuzz_objects 654 valid + 7848 mutated + 2048 history cases / 109 types, 0 mismatches; 7795 cases over 136 generic schemas, 0 mismatches, 142s
- 2026-09-25 06:50:04 root_big.bend stopped at 47 min, 21.5 GB and growing ~6 GB/15 min (host shared with BLS workloads; 129 GB available). Stopped to protect the host, not for time. Its closed 2^30-scale limit facts are evaluated in unary; they need the symbolic refactor the orchestrator requested (item 1b).
- cspec_l16_Withdrawal.bend (spec link cached_spec + producer laws incl.
  read_rep): Linux PASS 1017 s, 4.03 GB.
- Item 1b (Transaction limit), finding: probes build/probes/p_lit.bend and
  p_pow.bend both overflow the checker stack at once (0.4 s / 2.4 s) on
  {Spec.Transaction() == ByteList{U32.to_nat(1073741824)}} and on the same with
  U32.to_nat(O.pow2u(30n)). Every conversion that reaches the protected schema's
  limit literal weak-head-evaluates U32.to_nat of it, and the doubling recursion
  blows the stack. So no symbolic lemma can be connected to the spec schema by
  conversion. The drafted proofs/obj/lim_sym.bend (symbolic
  minimal(chunk_limit(2^(5+d)), d) via divmod peeling) was removed unchecked,
  because its Transaction instance cannot check. The only working route remains
  the normalizer's one-time evaluation of the closed fact (slow, memory-heavy).
- root_big split per name (codegen/root_laws_b.py): proofs/obj/root_big_<Name>.bend
  for Transaction, ExecutionPayload, BeaconBlockBody, BeaconBlock and
  SignedBeaconBlock, so each 2^30 evaluation runs in its own process. They are
  queued last, with build/memguard.sh stopping an SSZ checker only if host
  MemAvailable < 40 GB (shared host protection, not a proof budget).
- 2026-09-25 07:10:54 Final performance gate started in the workspace (build/final_perf.sh: automation/performance_gate.py with the SSZ venv and CC=clang-21; fresh build; no hashed-source edits until it ends).
- Final performance gate (current sources, workspace, fresh build):
  `PERFORMANCE GATE: 978 workloads / 327 operations within their
  operation-specific limits` (build/final_perf/gate.log, report copy
  build/final_perf/report.json). Load average ~94 on the shared host.
  Worst root row Attestation.hash_tree_root small 7.65x of 10x; worst codec
  row SyncCommitteeMessage.deserialize medium 2.99x of 5x. Reruns of the three
  worst root rows (quick.py, 9 samples, 2 runs each): Attestation 8.01/7.57x,
  ExecutionPayload medium 5.36/7.62x, LightClientFinalityUpdate medium
  5.76/5.93x. BENCHMARKS.md regenerated from the report.
- Final native memory: 15/15 Bend samples verified, worst decode overhead
  5,779,456 B (cap 32,000,000), Go worst 3,112,960 B; MEMORY_REVIEW.md updated.

## Iteration 23 status (2026-09-25, Linux) — coverage table (updated as checks finish)

| obligation | state | evidence |
|---|---|---|
| root, Fulu names | 75 Data (root_names) + 25 Type-kind (root_types PASS 948 s) checked on Linux or Mac; 5 big names (root_big_<Name>) queued, each needs a one-time unary evaluation of the 2^30 Transaction limit; BeaconState not covered | queue.log |
| root, generic forms | 123 of 136 with generated laws, all checked on Linux (gbits split: 3 files, 602/649/660 s) | LAW_API_MAP |
| cached root = reference root after histories (validators) | checked: cloop/cloop2/cloop3/cset/cmut/capi/cgrow/chist | queue.log |
| cached root, 11 other Data-element lists | generated; 7 PASS so far, rest queued | queue.log |
| cached root = spec root (RR.roots) | 6 lists with uncached laws; l16_Withdrawal PASS, 5 queued | cspec_* |
| sweep cost (O(dirty + 3d) node hashes) | checked (ccost.bend) over the runtime-proved step counts | ccost.bend |
| rep established by producers | list values: default/uncache/set/append/read (cspec_*); 127 container setters (prep_setters PASS); NOT: container decode/default (closed-number limit for large defaults) | LAW_API_MAP |
| codec total correctness | unchanged this iteration: 83 names spec-linked; 26 names + generic forms open | LAW_API_MAP |
| END_TO_END/ROOT_DOMAIN migration to object API | not done (propositions unchanged; checked in iteration 22 sweep) | LAW_MIGRATION.json |
| runtime gates | spectests 5440/5440, runtime 51/51, conformance 295 + 5145, mutations, negative 7/7, cache 7, invalid 14/14, fuzz seed 20260926 0 mismatches | build/final_runtime |
| performance | gate PASS 978/327; worst 7.65x root, 2.99x codec | build/final_perf |
| memory | 15/15, worst 5,779,456 B | MEMORY_REVIEW |
- 2026-09-25 10:54:21 Final sequential sweep started (build/final_sweep.sh over build/sweep_todo.txt: 304 files; build/sweep_plan.py reuses 9 Linux PASSes newer than the file and all its transitive imports, listed in build/sweep_reuse.txt). The queue daemon is idle (empty queue). Generators now write only changed files, so regeneration no longer invalidates PASS results through mtimes.
- 2026-09-25 13:15:27 Sweep regrouped: per-file checks of proofs/obj re-parse the same heavy imports (~10 min each on this host). build/sweep2.sh checks group wrappers (build/sweep_groups/*.bend, each importing modules that can share a process: constructor names are global, so each cached_<list> with its cspec_<list> is its own group, and root_gtypes is alone because of root_types' WMr/BMr/MB). Then HASH_PROOF, END_TO_END, ROOT_DOMAIN, PROOF and the 5 root_big files. Checking a wrapper type-checks every imported module in full.
- Sweep: build/sweep_groups/g_base.bend (102 proofs/obj modules, listed in g_base.list) PASS 5257 s, 8.66 GB VmHWM.
- HOST INCIDENT 2026-09-25 15:36 CEST: /dev/null was replaced host-wide by a
  dangling symlink `/dev/null -> ../../../proofs/fp2_sqrt_blst.bend` (created
  15:36; a BLS-named path, not created by the SSZ worker). Every shell command
  failed (the tool wraps commands with `< /dev/null`). Repair, minimal and
  host-level (no BLS process, source or /srv/bls-* directory touched):
  1. created an empty /proofs/fp2_sqrt_blst.bend so the symlink resolved;
  2. `rm -f /dev/null && mknod -m 666 /dev/null c 1 3` (restored the standard
     character device; verified crw-rw-rw- 1,3; writes discarded, reads empty).
  The temporary file /proofs/fp2_sqrt_blst.bend (48 bytes of stray shell
  output) remains: removing it was denied by the tool's permission mode.
  Operator: please delete /proofs/fp2_sqrt_blst.bend and /proofs, and find the
  process that replaced /dev/null. The sweep kept running; its results before
  and after 15:36 are unaffected (each check is a separate process; the
  15:37:43 group PASS was logged normally).
- Sweep: g_l16_Withdrawal (cached_l16_Withdrawal + cspec_l16_Withdrawal in one wrapper) FAIL 536 s: checker stack overflow, no location. Both files are unchanged since 08:03, and cspec_l16_Withdrawal, which imports the cached file, passed standalone at 09:07. Re-checking cspec_l16_Withdrawal standalone after the sweep.
- 15:57 CEST: build/sweep_parallel.py (not written by this worker; created
  15:57:01, apparently by the operator) replaced build/sweep2.sh. It reads
  build/sweep_plan2.txt, runs the pinned benchmarks/checks/check_proof.py per
  target (8 at a time, root_big 2 at a time), appends the real result lines to
  build/final_sweep.log, adopts the in-flight check, and defers
  cspec_l16_Withdrawal. This worker did not interfere with it. Its root-file
  results so far: HASH_PROOF PASS 21 s, PROOF PASS 119 s, END_TO_END PASS 130 s,
  ROOT_DOMAIN PASS 139 s (all zero unsafe).
