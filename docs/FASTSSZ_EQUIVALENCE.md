# fastssz ↔ Bend compact runtime: algorithms and layouts

Reference: pinned `github.com/ferranbt/fastssz v0.1.4` (`hasher.go`,
`encode.go`) and the go-eth2-client v0.27.2 generated codecs (for example
`spec/fulu/beaconstate_ssz.go`). Bend: `src/buffer.bend`, `src/cschema.bend`,
`src/cscan.bend`, `src/access.bend`, `src/croot.bend`, `src/merkle_fast.bend`,
`src/digest.bend`, entry points `src/api.bend` and `src/ssz.bend`.

The goal is the same *efficient algorithms and data layouts*, not a literal
port. Below, each fastssz mechanism is followed by its Bend counterpart and
every difference, with the reason for it.

## Input and ownership

| fastssz | Bend |
|---|---|
| `[]byte` input, borrowed by `UnmarshalSSZ` | `B.Buf`: one packed `Array<U32>`, four bytes per little-endian word, owned by the caller; every operation takes it and returns it with its result |
| random access by slice index | `B.byte_at` / `B.read32` / `B.read64`: `Array.get`, O(1) on the native block storage (emitted C `blk_read`, see MEMORY_REVIEW.md) |

`Array` is linear in Bend (kind `Type`), so a buffer cannot be shared between
two readers at once. It is threaded instead: every reader returns it.

## Decode

| fastssz (generated `UnmarshalSSZ`) | Bend (`API.validate` → `cscan.valid_in`) |
|---|---|
| `size < fixedPart` / `size != N` checks | same checks, with sizes precomputed per schema by `tools/generate_cschema.py` (fixed part, header offsets, strides, limits) |
| offsets: first == fixed part, each ≥ previous, ≤ size | same, in the container frame (`FCont`: `first_ok`, `grow_ok`) and the variable-element frame (`FVarList`) |
| list length divisible by element size, ≤ limit | same (`CList`: `exact`, `within`) |
| bool byte ∈ {0,1}, bit-vector padding zero, bit-list terminator present and within limit | same (tags 1, 2, 3) |
| **copies** every byte field into the struct, allocates a slice per list, decodes every element | **no copy**: the decoded value is the validated window, an `Access.View`; fields and elements are found by header offsets and offset tables when read (`Access.field`, `Access.elem`) |
| visits every field | visits only the fields that need a check: plain fixed-size fields (uints, byte vectors, whole-byte bit vectors, and vectors or containers built only from those) are valid by their position, and each container carries a generated "check tree" of the rest. A plain schema is validated by its length alone; a variable field that is a byte list or a list of plain elements is checked by its length when its end offset is known; a container whose variable fields are all such lists validates one offset per step |

Consequence: Bend's decode does all the validation fastssz does but builds
nothing. That is why `Blob.deserialize` is a length check against Go's 131 KB
copy, and why the benchmark reports it as it is rather than as like-for-like
work (BENCHMARKS.md).

## Encode

| fastssz (`MarshalSSZ` / `MarshalSSZTo`) | Bend (`Access.encode`) |
|---|---|
| appends every field to a byte slice, recomputing offsets | copies the value's window into a fresh packed `Buf`, one word per step: the window of a validated value *is* its canonical encoding, since SSZ encodings are unique |

Difference, stated plainly: the compact API has no builder for *new* values
yet, so encode serializes decoded views, not values assembled field by field.
Building values in the legacy `T.Value` model and serializing them remains the
list-based model API.

## hash_tree_root

| fastssz (`Hasher`) | Bend (`croot` + `merkle_fast`) |
|---|---|
| `Hasher.buf`: a byte slice that grows as field roots and chunks are appended; `Merkleize(indx)` hashes the group from `indx` layer by layer, in place | a streaming level stack: each chunk or field root is pushed and combined with the stack while the index's low bits are set, so at most one digest per level is live. The stack and all intermediate digests live in the input buffer's own **Merkle scratch** (1024 eight-word slots after the data, `B.get_digest` / `B.set_digest`), one 64-slot segment per nesting level |
| `zeroHashes[65]`: package-level table computed at init | Z(0..63) in scratch slots 960..1023, computed by hashing the first time a buffer is hashed (63 hashes) and reused for every later root of the buffer. A closed top-level Bend definition is re-evaluated at every reference (`benchmarks/probes/caf.bend`), so a global table is not an option |
| odd layer: append `zeroHashes[i]` | ascent: the right sibling at level k is Z(k) wherever bit k of the leaf count is clear; one hash per level |
| `MerkleizeWithMixin`: 32-byte little-endian length chunk | `croot.mix_in`: the same chunk (`length_chunk`), also used for union selectors |
| `PutBitlist`: strip the terminator bit | chunk read with the terminator bit masked (`mpos`/`mask`) |
| `PutUint64Array`, `PutBytes`: pack basic elements | a packed sequence (basic elements, and `Bytes32` elements, whose root is their own chunk) is merkleized directly from its byte range |
| `crypto/sha256` (SHA-2 instructions on arm64) | the pinned pure-Bend package `0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend`, message built with `Array.new` + 16 `Array.set`, result read with 8 `Array.get` |

Differences: the level stack keeps Bend's hash scratch bounded (32 KiB per
buffer, whatever the input size), where fastssz's `buf` grows with the number
of chunks in the largest group. Pure-Bend SHA-256 takes about 0.26 µs per
64-byte node, against about 0.06 µs for Go's hardware-assisted SHA. Hardware
SHA is excluded by instruction, so `hash_tree_root` starts about 4x behind
before any walking cost.

## Forms fastssz v0.1.4 does not have

Progressive lists, progressive bit lists, progressive containers and
compatible unions (the `ssz_generic` progressive and union cases) are
supported by the compact runtime. They are rooted progressively (4^k-chunk
segments whose roots are folded right to left, `merkle_fast.merkleize_prog`,
`push_prog`, `close_prog`) and mixed with the active mask or the selector.
fastssz v0.1.4 has no counterpart, so they appear only in conformance, not in
the performance comparison.
