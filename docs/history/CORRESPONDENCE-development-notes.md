> **Status (2026-09-30).** The transcription notes below were written while the proofs were
> being built; every "remains open", "unfinished", "outstanding" or "absent" in them is
> historical and has since been closed by the checked laws of END_TO_END.bend (serialize,
> deserialize, rejection, uniqueness and hash_tree_root, universally quantified over every legal
> schema, unions and progressive/compatible types included) and ROOT_DOMAIN.bend (the root
> domain is structural validity plus uint256 lengths, with no encoding premise, and is strictly
> broader than the serializable values). What is still open is listed in docs/PREMISES.md, not
> here. Strictness choices beyond the prose are listed at the end ("Deliberate strictness").

# Normative correspondence and proof boundary

The frozen normative sources are `vendor/consensus-specs/ssz/simple-serialize.md`,
`vendor/consensus-specs/fulu_mainnet.py` and `schemas/fulu_mainnet.json`.
Independent `spec/*.bend` modules do not import `src` or proof modules. Shared
SSZ metadata consists of `types/primitive.bend` and `types/schema.bend`
representations and the closed identity/bound tables in `types/byte_alias.bend`
and `types/list_alias.bend`; these contain no SSZ algorithms. Hash semantics use the independent pinned vendor FIPS model.
This document describes current coverage, not the historical sequence of claims.

## Primitives and bytes

UInt{a,b,c,d,e,f,g,h} represents a + 2^32 b + ... + 2^224 h. Independent unsigned
serialization uses arithmetic base-256 digits; domain validation requires zero
high digits outside the selected width. Decoding uses coefficient multiplication
and addition. Runtime masks/shifts/OR are connected to those meanings by the
word, power-division, encoding, decoding and inverse proofs. Boolean canonical
encodings are exactly singleton bytes 0 and 1. Basic roots preserve the encoding
and append zeros to exactly 32 bytes.

Byte-vector semantics require positive size, exact length and byte-range values.
The sequence serialization rule also asserts total size < 2^32. The retained
implementation/specification previously omitted that assertion for arbitrary
vector sizes. This restart repairs both using four base-256 quotient steps and
rechecks the domain, canonical codec and root composition. All frozen byte
wrapper sizes are below the bound. Closed identity laws cover Blob without
requiring the checker to expand a concrete 131072-element Nat specialization.
The old literal Blob proof is still not claimed.

Byte-list semantics (`spec/byte_list.bend`) are canonical identity with byte
validation, capacity and strict 2^32 serialized-size enforcement. Both codec
image directions and rejection are proved. Merkle roots use ceil(capacity/32)
chunks, then length mixing. Packed-count bounds and length representation are
discharged, so every accepted byte-list value has a successful 32-byte root.
`Transaction` is ByteList[1073741824]. The retained named wrapper is composed
through the closed list inventory. The separate unified `types/fulu.bend`
adapter still needs its representation and public composition proofs.

## Packing and trees

`spec/packing.bend` collects bytes in forward order, padding only a nonempty final
partial group. Empty data yields zero chunks. The runtime uses a reversed output
accumulator, whose refinement and buffer/chunk invariants are proved. A separate
single-fragment `pack_chunk([])` yields a zero leaf; it does not mean pack([]).

Perfect trees use ordered left/right subtrees and independent FIPS hashing.
`spec/limits.bend` characterizes the minimal depth covering a limit. Runtime
search has input-derived fuel proved sufficient for every mathematical limit;
public callers supply neither fuel nor a proof. Count <= limit is enforced even
when the next power-of-two capacity is larger. Missing leaves are virtual zero
subtrees. Roots refine every canonical witness; a witness for the actual
selected depth is proved, and successful roots have exactly 32 byte-range values.

## Bitfields and lengths

Bits are increasing-index Booleans with bit i at weight 2^(i mod 8) of byte i/8.
Independent octets use arithmetic weights; runtime octets use OR. Bitvectors
require exact positive size and reject nonzero unused bits. Bitlists append a
set delimiter after the actual data bits and reject absent/noncanonical markers
or capacity overflow. Structural proofs establish both codec image directions,
accepted-value validity, exact re-encoding and rejection outside the normative
serialization image. These are stronger than round trips.

`spec/bit_root.bend` packs the data bits without the delimiter. Bitvectors use
ceil(size/256); bitlists use ceil(capacity/256), followed by uint256 length
mixing. The actual packer count is now proved equal to ceil(actual bits/256),
using an accumulator invariant and arbitrary-length structural induction.
The 256 residual positions are the intrinsic chunk width; an unbounded recursive
case covers all additional chunks. Capacity monotonicity discharges the count
check for valid bitlists. Bitvector root acceptance equals vector validity.

`spec/nat_bytes.bend` gives arithmetic base-256 digits and a zero-high-quotient
predicate for exact-width conversion. `value` independently interprets bytes as
little-endian positional coefficients. Proofs reach Base.divmod's recurrence,
prove quotient/remainder reconstruction, exact value recovery, byte bounds,
width and overflow rejection. There is no machine-word narrowing. A bitlist
root accepts exactly capacity-valid values whose actual length fits uint256,
as required by the normative mixer. Root totality for each final Fulu type must
still discharge its length domain. These laws are not restricted to runtime Nat.

The retained selector mixer pads its uint8 selector to 32 bytes, matching pinned
spectests/reference Merkle helpers. The document's abbreviated “uint8
serialization” wording is interpreted with that chunk padding. Union option membership and
universal union composition are proved (END_TO_END.bend's laws cover every legal union).

## Development notes (historical; superseded where they say "remains")

General nested vector/list/container/union and progressive/compatible APIs now
exist, as do all 109 named APIs. Full independent semantics and universal
composition for these new APIs remain unfinished. `spec/layout.bend` follows the
normative fixed_parts/variable_parts formula using arithmetic uint32 digits;
its unconditional encoding refinement now reaches the actual reversed
accumulators, exact offset representability, byte validation, and strict size
rejection. `spec/layout_decoding.bend` independently specifies forward slices,
little-endian offset values and canonical extent boundaries without traversal
fuel. The actual layout decoder now refines this semantics for every width list and
input; byte-domain premises for offset reading are discharged by the public
input check and slice-domain preservation. Offsets use the independent uint32
coefficient semantics already used by primitive decoding, converted exactly to
Nat; the header reader supplies four bytes. Encoder-image soundness/completeness
and the generic decoder's traversal bound remain unfinished.

`spec/progressive.bend` uses independent perfect-tree roots and drops capacities
1, 4, 16, ... from the chunk list, hashing the recursive remainder on the left.
The complete predicate characterizes non-exhausted recursion. Checked laws prove
all finite inputs complete with the public list-length bound, actual FIPS root
refinement, exact chunk-domain rejection, and 32 byte-range root elements.

(Historical: the five END_TO_END laws were then absent; they are now checked.) No placeholders or assumed
codec/Merkle results stand in for them. Neither finite official passes nor checked
local laws establish full Fulu correctness. Compiler/runtime/transport/hardware
and collision-resistance boundaries are separate from checker/Base and faithful
independent transcription trust. Separate auditor/orchestrator gates remain due.

The new `spec/schema.bend` fixed-size classifier and `spec/codec.bend`
serialization transcription import only neutral representations and independent
specification modules. Fixed-size classification and sequence counts now have
universal actual-implementation equality laws. `encoding_for_legal_type` is
explicitly a partial specification layer: no complete type-legality, decoding
or codec refinement claim is attached to it yet.

`proofs/cached_tree.bend` proves generated zero-table lookup for arbitrary table
size, fallback correctness at arbitrary depth, actual subtree-consumption
identity, and ordinary/progressive Merkle API equivalence. The generic root's
bounded cache changes evaluation cost only; it does not bound protocol depth or
assume precomputed cryptographic outputs.

Transaction now follows the retained closed-inventory pattern: neutral
`types/list_alias.bend` contains only the name and exact frozen capacity,
`src/list_alias.bend` supplies actual APIs, and `spec/list_alias.bend` independently
selects byte-list semantics. Universal laws over that closed inventory compose
codecs, canonical rejection, roots and totality. The named Transaction wrapper
uses these APIs directly; unified typed-adapter composition remains separate.

The generic root successful-output theorem now proves 32-byte scope through
`src/ssz.bend` for all schema/value inputs. No validity premise is assumed for
this theorem: invalid data can return None. It does not prove correct root
contents or that all valid inputs return Some. The generic canonical-decoder law
likewise proves actual re-serialization of every accepted result, while leaving
independent generic semantic refinement and completeness explicit obligations.

The schema-forest predicates express structural representation invariants only;
they do not define independent SSZ type legality. Their proofs derive recursive
well-formedness from actual validation. `codec_composition.serialize_for_valid_type`
composes the independent leaf and layout formulas to all recursive constructors
for every value under the actual type-validity premise. It includes encoder
rejection on invalid values. Equivalence of that premise to independent normative
legality, independent decoding and root composition remain unfinished.

`decoding_relation.decodes` is the independent canonical encoding-image relation.
`decode_soundness` establishes public accepted-value soundness and rejection of
inputs outside that image. Completeness and uniqueness are separate obligations.
`layout_bounds` supplies all-input child-slice size bounds for the traversal proof.

`root_relation` states successful recursive roots using existential canonical
Merkle depths characterized by `limits.minimal`. It covers basic packing,
composite child roots, capacity padding, progressive trees, exact active-slot
placement, length and selector mixing. It imports only independent specifications
and neutral representations. Cached Merkleization has checked soundness and
completeness against this relation; retained byte/bit leaf refinements are also
composed in both directions. General recursive root refinement is proved
(END_TO_END.hash_tree_root_correct).
`value_domain` distinguishes independent serialization validity from recursive
uint256 length-mixer representability. The current public validity API is proved
equal to the former for accepted schemas; implication to the latter for all
mathematical inputs is not claimed. This documents rather than conceals the
remaining unbounded-bitlist domain obligation.

`type_legality` transcribes the illegal-type and union rules as an independent
judgement. `compatibility` uses finite derivation trees for public pairs, all
cross-option pairs, rows and aligned active slots. Type identity includes basic
byte/uint8 aliases; ordinary unions require option identity. Progressive fields
must retain shared names at their original slots. There is no fuel in this
meaning. Actual validator equivalence and bounded traversal completeness remain
proof obligations. `type_legality_structure` derives the structural forest
invariants from independent legality without assuming validator correctness.

The `representation` predicate concerns tags/field shape only. Its `erase`
function drops irrelevant limits and names solely within adapter proofs;
`representation_erasure.shape_erases` proves the original predicate unchanged
for all values and schemas. These descriptors never reach runtime codecs or
roots. `fulu_adapter_complete` proves all 109 conversions accept their erased
shape; `codec_shape` links successful independent encoding to original shape.
Checked per-name closed composition remains outstanding because direct large-Nat
specializations exhaust the pinned checker's normalizer stack.

Iteration 0006 connects independent legality/compatibility metadata to the actual
validator: names/counts/active bits, expanded slots, original field positions and
named-field legality have checked refinements. The 256-slot bound is derived
from public type legality. Actual identity acceptance implies normative identity;
no equality is claimed on internal Named nodes. Compatibility fuel monotonicity
and an established Null/Named slot invariant are prerequisites only; the finite
compatibility derivation relation is not yet proved equivalent to public runtime
compatibility, and the public traversal budget remains to be discharged.

## Iteration 0011 correspondence notes

- Decoding (`decoding_relation.decodes`): a byte string decodes to v exactly when
  `encoding_for_legal_type(schema, v) == Some{bytes}`. This transcribes the
  pinned "Deserialization" section's requirement that deserialization is the
  inverse of serialization with canonical-input hardening: every accepted input
  is the canonical encoding of the returned value (offsets, fixed/variable
  regions, strict size bound, unused/delimiter bits, selector ranges), and every
  canonical encoding is accepted with exactly that value. Rejection is the
  complement (`outside_image`).
- Roots (`root_relation.roots`): per constructor, the pinned "Merkleization"
  rules: `pack`/`pack_bits` with zero padding, `merkleize` at the least
  power-of-two depth covering `chunk_count` (existential minimal depth),
  `merkleize_progressive`, active-field placement with zero chunks and the
  active-bits chunk, `mix_in_length` (uint256 little-endian length) and
  `mix_in_selector`. Composite sequences contribute one recursive root per
  element; basic sequences are packed from the independent encoding.
- Valid values (`value_domain.root_domain`): structurally valid values
  (`root_valid`: every value has its schema's shape, every length within its
  bound) whose mixed lengths are uint256; no whole-object encoding is required.
  ROOT_DOMAIN.bend proves this strictly broader than the serializable values
  (`root_domain_strictly_broader`) and that roots of serializable values are
  unchanged.
- Fulu names (`fulu_schemas.bend`): transcribed from `schemas/fulu_mainnet.json`
  only. The implementation's named schemas are these constants (single source).
  The closed index `types/fulu.bend Name` has exactly the 109 frozen names
  (checked at runtime against the JSON; the proof quantifies over it).

## Deliberate strictness

- A Union with more than 128 options is illegal (`type_legality.bend`: at most 127 options after
  the first). The prose says only that selectors above 127 "should not" be used; no reference type
  uses more.
- Duplicate field names in a container or progressive container are illegal
  (`type_legality.named_fields`: `distinct_names`). The prose has no such rule, but a Python
  container cannot express duplicates.
- `mix_in_selector` serializes the selector into a 32-byte chunk (`mixing.bend`), matching the
  reference implementation and the official vectors; the prose's "uint8 serialization" is read
  with that chunk padding.
- Decoding is the image of serialization (`decoding_relation.bend`), which implies every item of
  the prose's hardening list (offsets, trailing bytes, delimiter and padding bits, selector range).
