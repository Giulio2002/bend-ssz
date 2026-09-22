# Proof plan for the generated production codec

Status, 2026-09-21 (iteration 17). The production SSZ path is the **generated
typed owning object API** (`types/fulu_obj.bend` for the 109 Fulu names,
`types/generic_obj.bend` for the supported generic forms; see
docs/CODEGEN.md). What is checked about it today:

* `proofs/obj/fields_*.bend`, `collections_*.bend`, `seq_elem.bend`: field
  read-after-write, unrelated fields unchanged, overwrite, checked-write
  accept/reject, swap, element read-after-write, rejected write/append leaves
  the value unchanged, accepted write keeps the length, accepted append
  increases it by one. Stated over an object built from variables, so they hold
  for every object of the type, including the ones `X_decode` returns.
* `proofs/obj/cache.bend`: the cached element-root tree agrees with the
  uncached root after updates and appends.
* `proofs/obj/cost.bend`: the cost model of the generated loops.
* `proofs/compact/*.bend`: a **universal** soundness proof of the compact
  window scanner (`src/cscan.bend`) - an accepted window satisfies the
  byte-level specification `V.CVm`, for every schema, frame, fuel and buffer.
  That scanner is no longer on the production path; the proof is kept because
  its layers (array facts, buffer denotation, word reads, the machine-level
  specification and its monotonicity) are exactly the reusable foundation the
  generated validator's proof needs.

What is **not** checked, and is the open obligation:

1. `X_ok(buf, off, len) == True` iff the window is a canonical SSZ encoding of
   `X` - soundness, completeness and rejection, for every generated name.
2. `X_read` of an accepted window is the value that encoding denotes.
3. `X_encode(X_read(w)) == w` byte for byte, and `X_read(X_encode(o))` is `o`
   up to non-semantic cache/capacity content.
4. `X_hash_tree_root` equals the independent specification root.
5. The packed-bytes → FIPS byte-list SHA bridge (section 3 below): the
   dependency proves its runtime equal to its own packed specification, not
   equal to FIPS on the unpacked bytes.

The route is the one below: the foundations in section 0 are shared with
`proofs/compact/found.bend`, `buf.bend`, `bits.bend` and `reads.bend`, which
already check; the per-constructor obligations of sections 1-4 have to be
restated for the *generated* `_ok`/`_read`/`_put`/`_root` families, which the
generator can emit compositionally because each family is built from the same
handful of shapes.

---

## 0. Foundations Base does not provide

1. **Perfect arrays.** `Array<T>` is a tree navigated by `U32` shifts and masks
   (`Array.get.go`, `Array.swap.go`). Needed: a predicate `perfect(a, d)`
   (every path has length d), `Array.size(perfect d) = 2^d`,
   `perfect(Array.new(d, v), d)`, `set` preserves `perfect`, and the two
   get-after-set laws for indices below 2^d. Everything is by induction on d
   plus `U32` facts about `shr`, `and`, `sub` and `is_lt`. `proofs/word_facts.bend`
   has some of those facts.
2. **Buffer denotation.** `bytes(b: Buf) : List<U32>`, a spec view that already
   exists (`B.to_list`). Laws: `byte_at(b, i) = nth(bytes(b), i)` for i < size;
   `bytes(of_list(n, xs)) = xs`; `fill_at` places a piece; scratch writes
   (`set_digest`) leave `bytes` unchanged (they are above `scratch_base(n)`).
3. **Word reads.** `read32(b, i)` is the little-endian decode of bytes
   i..i+3; `read64` likewise.

## 1. Schema correspondence

`cs_of : T.Schema -> CS` is generated. The proof obligation is per schema
constructor, not per Fulu type: the generator's precomputed numbers (fixed
part, header offsets, strides, limits and the `big` flag, depths, `plain`,
check trees, active masks, selector trees) equal the spec's functions of the
schema (`spec/layout.bend`, `spec/limits.bend`, ...). The shape to prove is a
relation `Corr(T, cs)` with one rule per constructor, plus a generated, checked
instance `Corr(Spec.X(), Compact.X())` for each of the 109 names and 144
generic schemas, composed from the rules. That is the same pattern as the
existing generated `proofs/fulu_*` inventories.

## 2. Decode (validate)

`valid_in(cs, off, len, b) = True  <->  Spec accepts bytes(b)[off, off+len) at T`
under `Corr(T, cs)`. This is the existing `image_accepted` /
`normative_image_accepted` / `valid_rejected_outside` / `reject_decide` pair
restated over a window. The route: an invariant for the frame machine
(`cscan.run`) saying that the pending frames' windows tile the input and that
each finished frame's window is in the image of its schema; then fuel
sufficiency (the fuel `64 + 4 len` bounds the steps). The `plain` shortcut
needs a lemma: a plain fixed schema accepts every byte string of its size.
Check trees need: skipping plain fixed fields does not change acceptance.

## 3. Root

`digest_bytes(root_in(cs, off, len, b)) = Spec.root(T, decode(bytes window))`
for accepted windows. Parts:

* **SHA bridge (ours to prove; the package does not claim it).** For the
  64-byte messages SSZ hashes: `D.hash_pair(l, r)` equals
  `FIPS.sha256_bytes(bytes(l) ++ bytes(r))`. The package proves the runtime
  equal to its packed specification (`sha256_array_correct`). What remains is
  packed specification = FIPS on the unpacked 64 bytes, for symbolic words. It
  must be proved symbolically: concrete-length SHA terms time out in the
  checker (WORK_LOG), so the proof must go by congruence through a shared
  compression function, never by evaluating it.
* **Streaming merkleization = spec merkleize.** The level-stack invariant (the
  stack holds the roots of the completed subtrees named by the set bits of the
  leaf count), the ascent with Z(k), and the zero table:
  `fill_zeros` writes Z(k) with Z(k+1) = H(Z(k), Z(k)), the spec's definition.
  The progressive variant: segment k of 4^k chunks, and the right-to-left fold
  equal to `spec/progressive.bend`'s recursion.
* **Walker = relational root** (`spec/root_relation.bend`), by the same frame
  invariant as decode, with nested segments not overlapping (seg + 64 per
  nesting level, fewer than 15 levels).

## 4. Encode

`bytes(encode(view, b)) = bytes(b)[off, off+len)`: copy correctness from the
array laws. With decode (section 2) and the existing uniqueness law
`image_unique`, the encoding of the decoded value is the input window.

## 5. Law translation

Each END_TO_END / ROOT_DOMAIN row in `docs/LAW_API_MAP.md` then gets a
compact counterpart stated over `Buf` and `View` with the bridge from
section 0.2, and the list-based statement follows from the compact one plus the
bridge. That is the non-weakening argument the map asks for.
