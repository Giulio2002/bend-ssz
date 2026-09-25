# Reuse assessment: Giulio2002/bend-collections (2026-09-25)

Requested by OPERATOR_DIRECTIVE_20260925.md. Inspected upstream `main` at
commit 06caea4 (`git clone https://github.com/Giulio2002/bend-collections`,
read-only copy in build/bend-collections, not vendored). Its toolchain pin
(tools/toolchain.json) is stock Bend 2.0.25 with the same Base sha256 as ours
(e5639663…), so its modules could be imported without a toolchain change.

## What is already reused

`proofs/compact/found.bend` carries the proof library of the earlier pinned
snapshot 4f59da4 (docs/OPERATOR_ARRAY_PROOF_REUSE.md): the array model
(`array__Tree`, `thaw`/`freeze`, `perfect`, `upd`, `slots`, `array__set`,
`array__swap`, `array__size_thaw`, `array__new`, `trep`), the Nat order laws
(`nat__*`) and U32 facts (`u32__*`). Every cached-root, producer and loop proof
of this iteration (cloop*, cset, cmut, capi, cgrow, chist, cspec_*) is stated
over these definitions. At 06caea4 these modules are proofs/lib/array*.bend,
nat*.bend, order.bend, u32*.bend.

## What was considered and not adopted, with reasons

| upstream | what it proves | fit for SSZ | decision |
| --- | --- | --- | --- |
| `bitlist` (src/containers/bitlist.bend, proofs/containers/bitlist) | its own packed growable bit list refines a list-of-Bool model over every operation trace (new, with_limit, get/assign/push/pop, from_bools) | No SSZ encoding, delimiter or root. Its representation (words plus length, with its own limit handling) differs from `O.Bits{Array<U32>, blen}`, which the generated codec, validator and root laws use. Its word/bit lemmas (`word_bits`, `take_word`, `flat_snoc`) overlap bitlist_pack.bend (`bitsof`, `btk`, `bpack`), which is already checked. | not adopted. Swapping the runtime bit list would invalidate checked root/codec laws and benchmarks for no new SSZ property. |
| `dynamic_array` | push/pop/set/clear on `AR.Tree<Maybe<T>>` slots refine a list model over traces; growth doubles capacity (`grow_until_real`, `sgrow_props`) | Same idea as our `append`/`room` (capacity doubling, copy loop). But its slot type `Maybe<T>` and shadow state differ from the generated `Seq{Array<T>, n}` and `Cached{…}`. The SSZ-specific facts (depth = `B.words_depth(n)`, limit guard, `rep_<list>`) are proved in cgrow.bend and the cspec_* producer laws. | not adopted as storage. Its trace-refinement pattern (real = f(shadow) along every history) is the one chist.bend uses for cached-list histories. |
| `hash_table`, `lru`, trees, heaps, queues | their own container specifications | not used by SSZ | not applicable |
| crypto (sha, keccak, blake) | SHA-256 = FIPS spec for every input | SSZ already pins the BendHub SHA package `0xda83506f…` with its own `sha256_array_correct` | unchanged |

## Conclusion

No upstream structure provides an SSZ property we lack. Adopting its runtime
containers would change representations that the checked codec, root and
cache laws are stated over. What we do reuse is its array/Nat/U32 proof
library (already vendored) and its trace-refinement proof pattern. If a later
change moves list storage onto `dynamic_array`, the bridge needed is: its
`abs(real(sh))` list equals `F.array__slots` of our items tree for the first n
slots, plus the `words_depth` capacity fact.
