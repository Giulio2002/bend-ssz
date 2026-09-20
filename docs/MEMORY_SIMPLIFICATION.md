# SSZ memory simplification

The immediate problem is allocation in the runtime, not proof-checker scheduling.
Measurements below use actual Bend-generated JavaScript on Bun --smol and the
same mainnet Fulu BeaconState fixtures as the existing benchmark. No forced GC.
Other host jobs remain active. RSS includes uncollected garbage and runtime space;
it is not a measurement of the irreducible state representation size.

## What the current implementation does

1. Represent the input as a linked list with one U32-valued node per byte.
2. Decode layout headers into lists of copied byte-list slices.
3. Traverse the schema to construct a generic Value tree.
4. Serialize that entire tree again and compare it with the original input.
5. Convert the generic tree to the generated typed BeaconState.
6. For roots, serialize again through Codec.valid before computing a root.

A 2,740,473-byte fixture reached 1,313,144,832 bytes RSS after raw decoding and
3,533,996,032 after the canonical reserialization in the diagnostic run. The typed
adapter added little to peak RSS in that run. These observations identify where
allocations accumulate; they do not establish that every byte remains live.

## First implemented change

Layout.finish previously reversed the fixed accumulator and then passed that
result to Lists.append, which reverses its first input before reversing it onto
the second. The fixed region was copied three times. It now reverses directly
onto the final variable tail, constructing the fixed output once.

The layout proof proves equality of the resulting bytes for arbitrary fixed and
variable lists. All existing PROOF.bend imports, including END_TO_END.bend, check
with zero unsafe annotations. No specification, API, rejection condition, type,
fixture or crypto dependency changes. The proof-runner-only experiment was put
aside; acceptance.py is unchanged.

This is a first reduction in allocation, not the completed architectural rewrite.
The public API comparison covers all five fixtures in fresh processes and
alternates before/after order. Raw samples are in build/memory-profile. It measures
full public deserialize, with raw-to-linked conversion outside the timed region
but included in process peak RSS. The phase diagnostic deliberately retains
intermediate results; do not equate its peak with the public API measurement.

## Architectural work remaining

- Replace materialized byte slices with bounded cursors/ranges and explicit
  consume/remaining accounting. Reject invalid offsets, gaps, trailing bytes and
  noncanonical encodings directly. Prove those checks equivalent to the existing
  canonical serialization relation before eliminating the reencoding guard.
- Build typed Fulu values directly. Keep the generic Value relation as the
  independent semantic model rather than a compulsory intermediate runtime tree.
- Use packed byte storage with a proved logical byte-sequence view where it
  materially reduces allocation; Bend's native Array is a binary tree, so simply
  replacing List with Array is not a compact-buffer solution.
- Validate values structurally, including bounds and integer ranges, without
  constructing a serialized result just to discard it. Keep serialized-size
  validity distinct from root-value validity.
- Stream serialization into one output and hash chunks without assembling complete
  serialized states. Preserve compatibility with the independent root-domain work.

Retain all 109 Fulu types, all existing public semantic guarantees and all 5,440
SSZ cases. New runtime paths must have their own implementation-connected proofs;
the old implementation's proofs do not automatically cover a new representation.
Measure peak memory and retained memory separately, record all phases, and reject
attempts to improve scores by moving decode work outside the measurement.
