# Public entry points: what each one promises, and what it expects

The library never aborts on a value a caller can build through the checked entry points. The unchecked entry points below are kept because
the proofs and the benchmarks state facts about them; each has a checked counterpart or a stated precondition. Source of the findings:
[docs/CRASH_HUNT.md](CRASH_HUNT.md); the regression run is `tools/crash_hunt/regress.sh`.

| entry point | checked? | contract |
|---|---|---|
| `X_decode_checked(buf, size)` | yes | `None` unless `size <= B.size(buf)`, `size < 2^31` and the window lies in the words the buffer's array really holds (`B.Buf` is a public constructor: its size field is a claim, R2-04); otherwise it is `X_decode`. Use this for bytes of unknown origin. |
| `X_decode(buf, size)` | window | the caller guarantees `size <= B.size(buf)` and `size < 2^31` (the library's size limit, CH-07). It validates the bytes of the window (`X_ok`) and never reads a byte outside it for a valid size; an oversized `size` reads the buffer through the index mask (aliased words, CH-06), a size within 31 bytes of 2^32 mis-sizes the storage of a byte list (CH-05). |
| `X_ok(buf, off, len)` | yes | the validator of one window; total for every argument. |
| `X_serialize(o)` | yes | `Encoded{ok, bytes}`: `ok = False` (no bytes) for an object that is not valid (`X_valid`), including a length larger than its storage, a value outside its type, an absent box (CH-12: the size pass keeps the empty box absent, so the checked writer flags it), and an encoding of 2^31 bytes or more (CH-07: sizes are U32 with bit 31 reserved as the invalid marker, so the largest object is 2^31 - 1 bytes). |
| `X_encode(o)` | no | precondition `X_valid(o)`. For an invalid object the size pass answers the marker 2^31, which `_encode` allocates (CH-02); use `_serialize`, which refuses before allocating. |
| `X_hash_tree_root(h, o)` | no | precondition `X_valid(o)`; it has no error channel (CH-08). The work is bounded by the object's storage: the chunk count is clamped to what the storage holds (CH-03), so a claimed length beyond the storage cannot cost more than the allocation (a list of composites hashes min(n, storage) elements, a cache is allocated at most as deep as its array, R2-03). For a valid object the root is the spec root whatever spare storage it has: storage smaller than the 8 words per chunk the root reads, or bytes past the length in the words up to the end of the last chunk, are cleaned in a copy first (CH-11, R2-02). `X_valid` still accepts a claim of 2^32 - 3 .. 2^32 - 1 bytes in small storage (the `(n + 3) >> 2` of `words_ok` wraps); its root is bounded and `_serialize` refuses it. |
| `X_set` / `X_append` / constructors | yes | return the flag `ok` and the object unchanged when `ok = False`. The cell list (`List[Cell, 4096]`) also refuses a cell whose length is not 2048 bytes (CH-01); every list kind has a count below which its append is accepted: the smaller of its limit and the count whose byte length (and its rounding up to a chunk) does not wrap in U32 (CH-04, R2-01, R2-06). The cell setter and appender also refuse a cell whose storage is smaller than 2048 bytes (R2-05). |
| `X_default()` | - | a valid object; a vector of variable-size elements holds present default elements (CH-10), so `serialize(default())` is the spec's zero encoding. |
| `X_build(buf, size)`, `X_read(buf, off, len)` | no | the second half of `_decode`: precondition `X_ok(buf, off, len)` (CH-09). On bytes that were not validated they can allocate in proportion to a claimed count. They are public symbols only because the decode statements unfold them; call `_decode` or `_decode_checked`. |
| `O.words_blit`, `O.words_slice`, `O.words_resize` | no | `O.*` is the runtime the generated code is written in; its functions assume the representation invariant of `O.Words` / `O.Bits` (storage holds the claimed length). `words_blit` copies nothing for an empty source. |

Two limits are part of the contract: a size is a U32 and its bit 31 is the invalid marker, so no object of 2^31 bytes or more is
encodable (CH-07); lists count in U32, so a list holds at most 2^32 - 2 elements (CH-04).
