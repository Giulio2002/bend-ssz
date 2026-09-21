# Proof plan for the compact primary path (not yet carried out)

Status, 2026-09-21: **no checked proof covers the compact modules** (`src/buffer`,
`cschema`, `cscan`, `access`, `croot`, `merkle_fast`, `digest`, `api`, the
compact half of `ssz`). Their evidence is native testing: all 5,440 official
cases, 1,180 mutation checks against an independent validator, differential
roots against the proved list-based modules, and the fixture round trips
(WORK_LOG.md). This file records what the proofs have to establish, in the
order they depend on each other, so the work can start without re-planning.
Every item must be a checked Bend law with no unsafe annotation, axiom or hole,
checked one process at a time under the 8 GB ceiling.

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
