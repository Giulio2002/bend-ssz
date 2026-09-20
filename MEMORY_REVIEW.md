# Native memory review — Bend C SSZ versus Go fastssz

Scope: the **native** Bend C backend only. Nothing in this document is a
Bun/JavaScript measurement; the JS runtime is used elsewhere in this
repository for conformance evidence only and no JS number appears here.

Reproduce with:

```
python3 native_bench/run.py          # writes build/native/comparison.json
python3 automation/native_memory_acceptance.py   # frozen operator gate
```

The proof half of that gate now passes: `bend PROOF.bend` and
`bend END_TO_END.bend` report "All terms check." with zero unsafe annotations,
and `automation/root_domain_acceptance.py` (which runs the proofs, the 51
runtime tests and all 5440 official SSZ cases) exits 0 on this copy. The
checker peaks at 5.1 GB of physical footprint for `PROOF.bend`; see WORK_LOG.md
for how that was measured and for the two normalization blow-ups that had to be
repaired first. `PROOF_STATUS.md` is frozen for this iteration and its "Current
state" section predates these runs.

The report-checking half of the gate - three or more Bend samples per fixture,
integer measurements, `verified`, and
`decode_overhead_bytes == max(0, peak - baseline) <= 32,000,000` - passes over
all 15 Bend samples.

## What is measured, and how

Both programs (`native_bench/driver.bend`, `native_bench/fastssz/main.go`) run
the same workload on the same raw fixture bytes:

read file → full typed decode, forced by a checksum fold over every decoded
leaf → `hash_tree_root` → serialize → write, one sequential thread, a fresh
process per sample.

Every phase boundary is also an exit point (`SSZ_PHASES=input|decode|root|all`).
A phase's peak is therefore obtained from a **separate process that performs
exactly the prefix of the workload up to that boundary and then stops**, and
whose peak resident size the kernel reports through `wait4`'s `ru_maxrss` — a
high-water mark the kernel maintains on every page fault, not a sample. Two
such runs bracket a phase:

    decode_overhead_bytes = peak(prefix through decode) − peak(prefix through input)

`baseline_rss_bytes` is the input-prefix peak (post-input, pre-decode), and
`decode_peak_rss_bytes` the decode-prefix peak, so the reported overhead is
exactly `max(0, peak − baseline)` as the frozen gate requires.

Two independent methods cross-check this: a 0.5 ms sampler runs for the whole
full-length run, and a reading is taken at every phase marker while the child
is idle inside its 150 ms settle window. Every reported peak is the **maximum**
of the kernel high-water mark, the boundary readings and all samples, so no
method can hide a spike below another. The harness additionally fails the run
if the stopping process's kernel peak is materially below what sampling saw in
the full run, which would mean the bracketing run was not doing the same work.

Resident size is not monotone *downward* on macOS (the kernel can compress or
evict pages), so `monotone_within_decode` is recorded as an observation rather
than assumed; correctness of the peak does not depend on it, because the
kernel high-water mark is taken independently.

`verified` is derived, never asserted: a sample is verified only when the
process re-emitted the fixture bytes exactly (`output_bytes_match`), reached
every phase marker, and reported decode, root and serialize measurements. The
harness also records that both implementations agree on the root digest
checksum for each fixture (`root_checksum_agreement`), which they do.

Nothing is moved out of the measured window: the decoded value is folded into
a checksum inside the decode phase (so no part of it can be deferred or
eliminated) and is still live afterwards, since it is hashed and serialized.
Compilation is excluded and always rebuilt. The emitted C is retained at
`build/native/bend-ssz.c`.

## Result

Five mainnet Fulu `BeaconState` fixtures, three Bend samples each (15 Bend
samples), medians, Apple M4 / macOS 15.6, Bend 2.0.16 native C backend
(`--threads 1 --gpu off`), Go 1.25.5 with pinned fastssz via go-eth2-client.
Re-measured on 2026-09-21 by `automation/native_memory_acceptance.py`, which
rebuilt both programs and exited 0:

| fixture | input bytes | Bend baseline | Bend decode peak | **Bend decode overhead** | worst sample | Go baseline | Go decode peak | Go decode overhead |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| case_0 | 2,740,473 | 12,992,512 | 25,706,496 | **12,730,368** | 12,763,136 | 8,355,840 | 11,681,792 | 3,325,952 |
| case_1 | 2,740,934 | 13,008,896 | 25,821,184 | **12,845,056** | 12,861,440 | 8,028,160 | 11,632,640 | 3,440,640 |
| case_2 | 2,741,095 | 13,139,968 | 26,001,408 | **12,812,288** | 12,976,128 | 8,241,152 | 11,632,640 | 3,391,488 |
| case_3 | 2,739,794 | 13,139,968 | 25,821,184 | **12,697,600** | 12,697,600 | 8,257,536 | 11,616,256 | 3,358,720 |
| case_4 | 2,738,771 | 13,107,200 | 25,853,952 | **12,730,368** | 12,763,136 | 8,028,160 | 11,550,720 | 3,358,720 |

Worst single Bend sample: **12,976,128 bytes**, 41 % of the 32,000,000-byte
requirement; all 15 Bend samples are under the cap and `verified`. The raw
report of this run is `build/native/comparison.json`; the previous run is
retained at `benchmarks/evidence/native-comparison.json`.

Bend decode overhead is 3.8x Go's on the same fixtures (12.7-13.0 MB against
3.3-3.4 MB). Phase peaks from the same run, which the gate reports but does not
cap: root phase 94.1-94.3 MB (Bend) against 19.1-19.6 MB (Go), serialize and
whole-run 97.0-97.1 MB against 21.9-22.2 MB. The root and serialize phases are
therefore where the remaining native memory is, and both still route through
`T.Value` and byte-per-cons lists; that is the migration described in
`docs/LAW_API_MAP.md`, which is not implemented.

**Which function each number brackets.** `baseline_rss_bytes` is the kernel peak
of a process that reads the fixture and packs it into the decoder's storage and
then stops (`SSZ_PHASES=input`). `decode_peak_rss_bytes` is the kernel peak of a
process that does the same and then runs `Decode.decode_packed` to completion
with the result forced by a checksum fold over every leaf
(`SSZ_PHASES=decode`). That is the compact decoder, reached directly - **not**
`ssz.deserialize`, which additionally materialises `T.Value` and is what the
benchmark harness measures (253 ms and far more allocation for the same
fixture). The operator's instruction to make the compact API primary is exactly
what would remove that discrepancy; it is not done, so the two numbers still
measure different functions and this document says so rather than pretending
otherwise.

**Fairness of the comparison, stated plainly.** Two asymmetries run in opposite
directions and neither is hidden:

* Bend's baseline includes packing the input into 32-byte `Chunk` records
  (`native_bench/driver.bend` reads the file in 64 KiB pieces and packs each
  immediately), while `native_bench/fastssz/main.go` does a plain
  `os.ReadFile`. Bend's baseline is therefore ~12.9 MB against Go's ~8.3 MB for
  the same 2.74 MB of input, and the extra is the packed representation plus a
  larger runtime floor. Measuring decode *overhead above that baseline* is the
  requirement's definition, but the absolute baselines are in the table so the
  input representation cannot hide there.
* Bend's decoded byte leaves are zero-copy slices into that packed storage,
  while Go copies byte fields into typed arrays. That favours Bend on decode
  overhead, and it is why Go's 3.2-3.5 MB is not a like-for-like floor for
  Bend's 12.7-12.9 MB: Go pays copy costs Bend does not, and Bend pays one spine
  cell plus one leaf node per element that Go does not.

Per-phase peaks on the same runs (kernel `ru_maxrss` of a process that stops at
that boundary):

| fixture | Bend root-phase peak | Bend serialize-phase peak | Bend whole run | Go whole run |
|---|---:|---:|---:|---:|
| case_0 | 94,076,928 | 96,927,744 | 96,927,744 | 22,216,704 |
| case_1 | 94,273,536 | 97,026,048 | 97,026,048 | 21,905,408 |
| case_2 | 94,257,152 | 97,107,968 | 97,107,968 | 22,183,936 |
| case_3 | 94,175,232 | 97,042,432 | 97,042,432 | 22,183,936 |
| case_4 | 94,142,464 | 97,026,048 | 97,026,048 | 21,905,408 |

Latency on the same runs (medians, nanoseconds, one sequential thread; the
Bend driver's clock has millisecond resolution, so its figures are quantised):

| fixture | Bend decode | Go decode | Bend root | Go root | Bend serialize | Go serialize |
|---|---:|---:|---:|---:|---:|---:|
| case_0 | 19,000,000 | 1,276,000 | 609,000,000 | 7,567,541 | 349,000,000 | 292,709 |
| case_1 | 20,000,000 | 1,430,458 | 613,000,000 | 7,644,833 | 362,000,000 | 282,250 |
| case_2 | 18,000,000 | 1,300,875 | 621,000,000 | 7,585,916 | 367,000,000 | 299,750 |
| case_3 | 19,000,000 | 1,368,125 | 609,000,000 | 7,736,541 | 357,000,000 | 321,250 |
| case_4 | 19,000,000 | 1,373,000 | 611,000,000 | 7,615,542 | 354,000,000 | 331,417 |

On this 2026-09-21 run that is roughly 14-15x Go on the compact decode, 79-82x
on hash_tree_root and 1,070-1,300x on serialize, against contract limits of 5x,
10x and 5x. These ratios are **not a controlled measurement**: the Bend driver's
clock quantises to 1 ms, and the Go side has moved between runs on the same
binary and fixtures (1.3-1.4 ms per decode here against 2.3-4.2 ms in the
previous run), which is machine noise. Use BENCHMARKS.md - which calibrates
batch sizes and takes five alternating samples per workload - for the numbers
the performance contract is judged on. Note also that the decode figure here is
`Decode.decode_packed`; BENCHMARKS.md measures the public `ssz.deserialize`,
which is far slower again because it materialises `T.Value`.

Whole-process peak including startup, the packed input, hashing, serialization
and output is ≈ 97 MB for Bend and ≈ 22 MB for Go; that number is **not** the
decode overhead and is dominated by the root and serialize phases (see below).

## What the emitted C actually contains (read, not assumed)

`bend native_bench/driver.bend -o build/native/bend-ssz.c` emits a 202,157-line
C file. Relevant findings, by line:

* `:185-190` - the runtime's term tags include `TAG_BUF` (packed u32 buffer) and
  `TAG_ARR` (array of terms) alongside `TAG_PAK`, `TAG_CTR`, `TAG_CLO`.
* `:3526-3536` - the block layer documents itself: *"A block owns one allocation
  in its physical class (an ARR of class c 2^c Terms in 2^c words, a BUF 2^c u32
  in 2^buf_wcls(c) words) ... A match to the leaves copies O(n log n) words where
  a view copied none; get, set, swap, size and new open no half."*
* `:3549-3562` - `blk_read`/`blk_write` index a block directly (`H[loc + i]` for
  an ARR, `*blk_ptr(H, loc, i)` for a BUF), i.e. O(1) indexed access.

So the runtime does have contiguous indexed storage, and `Array<T>` is not a
pointer-chasing tree despite its `ALeaf`/`ANode` surface. The current SSZ
storage, however, does **not** use it: `src/packed.bend` stores input as
`+List<Chunk>`, a linked spine of 8-field `Chunk` constructors, and
`src/cvalue.bend` stores container/sequence children as a `CCons` spine. Neither
compiles to a block; both compile to `TAG_CTR` nodes linked by pointers. That is
the representation the memory numbers above measure.

Measured consequences (probe sources and outputs in `benchmarks/probes/`):

| probe | result | per unit |
|---|---|---|
| 1,048,576 `Array.get` reads | under 1 ms | < 1 ns |
| fill a 2,740,473-slot `Array<U32>` from a byte list | 5 ms | 1.8 ns/byte |
| indexed scan of that array | under 1 ms | < 0.4 ns/byte |
| walk a 1,048,576-cell `+List<U32>` | 2 ms | 2 ns/cell |
| build 200,000 two-field records | 1 ms | ~5 ns |

Against Go fastssz's 0.35 ms BeaconState decode, an indexed scan of the same
2.74 MB is within the 5x budget on its own, while the current decoder needs
24-27 ms. The gap is representation, not runtime.

Two constraints found at the same time, both load-bearing for any migration:

1. `Array<T>` has kind `Type`, not `Data`, so it cannot be duplicated
   (`benchmarks/probes/array_share.bend` fails to compile with
   `expected: Data, observed: Type`). An array-backed decoder must thread the
   buffer linearly and address it by index; it cannot hand a shared view to two
   sub-decoders the way the current `P.Slice` does.
2. Base's file API returns `List<&2, U32>` (`base.bend:267-276`), so converting
   input into a buffer costs 5 ms per BeaconState - 14x Go's entire decode -
   before any decoding. Buffer-ready decode, input conversion and end-to-end
   ingestion are therefore three different numbers and must be reported
   separately.

`docs/LAW_API_MAP.md` records the migration design these facts imply, including
which propositions stay byte-for-byte and which internal lemma surfaces have to
change. The migration is **not implemented**; `src/` is unchanged in this run.

## Where the remaining decode memory goes

Bend grows 4.7 bytes of resident memory per input byte during decode, Go 1.2.
The decoder is already zero-copy for byte payloads: `src/packed.bend` stores
the input as 32-byte `Chunk` nodes and a decoded `CBytes` leaf is a `Slice`
into that same storage (`sub`/`adv` never copy, and `adv` drops whole chunks so
sequential reading stays constant time per byte). What remains is the node
count of the decoded structure itself: every child of a container, vector or
list costs one `CCons` spine cell plus one leaf node, and a `BeaconState`
fixture has on the order of 10^5–10^6 children (65,536 randao mixes, 8,192
block and state roots, validators, balances, participation flags). At two
runtime nodes per child this is the observed 13 MB, and it is the direct cost
of representing the decoded value at all — Go stores the same children in
packed slices with no per-element header.

Reducing it further requires representing whole fixed-width sequences as a
single packed run instead of a spine of cells (a `CRun` leaf carrying the
slice plus the element schema), which changes what `C.to_value` and the
soundness laws range over. That is a real, implementable next step, not a
tuning knob; it is not attempted here because the existing 12.9 MB already meets
the requirement with a factor of 2.5 in hand, while the proof obligations it
would add are substantial.

The **root** phase, by contrast, grows ≈ 68 MB, and serialization pushes the
process to ≈ 97 MB: `API.hash_tree_root` and `API.serialize` both take the
neutral `T.Value` (`C.to_value`), which materialises every byte payload as a
one-cell-per-byte list. Those two phases, not decode, are where native
allocation is still far from Go, and a compact `CValue`-level serializer and
root (with their own refinement proofs against `spec/codec.bend` and the
relational root semantics) is the outstanding memory work.

## Honest limits of this evidence

* Three samples per fixture per implementation on one machine; memory figures
  were stable to within 0.3 MB across samples, timings vary more. The recorded
  run was made with no other workload of this project running.
* `ru_maxrss` measures resident pages, not the allocator's own accounting; the
  Bend runtime exposes no heap counter, and patching the emitted C or the
  compiler to add one is out of scope by instruction.
* The comparison uses the same fixtures for both sides and compares output
  bytes exactly, but fairness of the *workload* (what "fully decoded" means in
  each type system) is a judgement an independent auditor must make: Bend
  builds a schema-generic value, Go builds generated typed structs.
