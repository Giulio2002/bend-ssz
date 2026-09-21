# Native memory review — Bend C SSZ versus Go fastssz

Scope: the **native** Bend C backend only. Nothing in this document is a
Bun/JavaScript measurement.

Reproduce with:

```
python3 native_bench/run.py          # writes build/native/comparison.json
python3 automation/native_memory_acceptance.py   # frozen operator gate
```

The Bend side is now the **compact primary path**
(`native_bench/driver_compact.bend`): one packed `Array<U32>` input buffer, an
in-place validating decode (`src/cscan.bend` through `src/api.bend`),
`hash_tree_root` over the same buffer (`src/croot.bend`, `src/merkle_fast.bend`,
the pinned BendHub SHA-256 package), and a streamed encode. The earlier
list-based driver (`native_bench/driver.bend`, `src/packed.bend`,
`src/cvalue.bend`) is no longer what is measured.

The proofs do **not** yet cover this path; see "What is not established" below.

## What is measured, and how

Both programs (`native_bench/driver_compact.bend`,
`native_bench/fastssz/main.go`) run the same workload on the same raw fixture
bytes, one sequential thread, a fresh process per sample:

read file → decode → `hash_tree_root` → serialize → write.

* **Go:** `os.ReadFile`, `UnmarshalSSZ` into the generated struct plus a
  checksum fold, `HashTreeRoot`, `MarshalSSZ`, write.
* **Bend:** the file is read in 64 KiB pieces straight into the packed buffer
  (the input never exists as a whole byte list); the last byte is read before
  the baseline marker so the buffer is fully built before the baseline is
  taken. Decode validates the whole `BeaconState` in place, so the decoded
  value is the validated buffer, a zero-copy view. The decode verdict is
  matched on inside the measured window, and a rejected input exits nonzero
  ("decode rejected"). Root runs over the same buffer. Serialize streams the
  view's bytes to the output file in 64 KiB pieces, reading words by index, and
  its time includes the writes.

Every phase boundary is also an exit point (`SSZ_PHASES=input|decode|root|all`).
A phase's peak comes from a **separate process that performs exactly the prefix
of the workload up to that boundary and then stops**. The kernel reports that
process's peak resident size through `wait4`'s `ru_maxrss`, a high-water mark
maintained on every page fault rather than a sample. Two such runs bracket a
phase:

    decode_overhead_bytes = peak(prefix through decode) − peak(prefix through input)

A stopping process now just drops the buffer and exits; it does not traverse
it. An earlier version folded the buffer at the stop point. On this runtime that
fold copies O(n log n) words (see the emitted-C section), which inflated both
bracketing runs to a 15.7 MB baseline. Removing it brought the true
post-input baseline down to 7.1–7.4 MB, and the decode overhead stayed where it
was.

Two independent methods cross-check the kernel figure: a 0.5 ms sampler during
the full run, and a reading at every phase marker while the child is idle in
its 150 ms settle window. Every reported peak is the **maximum** of the kernel
high-water mark, the boundary readings and all samples. The harness fails the
run if the stopping process's kernel peak is materially below what sampling saw
in the full run.

`verified` is derived, not asserted: a sample counts as verified only when the
process wrote output bytes identical to the fixture, reached every phase marker
and reported decode, root and serialize measurements. For every fixture, Bend
and Go agree on the root digest checksum (`root_checksum_agreement`).

Compilation is excluded from every sample and always rebuilt. The pinned
compiler's own peak memory for this driver varies between compiles of the same
source (5.2 GB to over 6.5 GB measured). The harness therefore compiles under a
physical-footprint cap of 6.5 GB, below the operator watchdog, and retries a
capped attempt. The attempts are recorded in `comparison.json`
(`bend_compile_attempts`).

## Result

Five mainnet Fulu `BeaconState` fixtures, three Bend and three Go samples each,
medians. Apple M4 / macOS 15.6 arm64, Bend 2.0.16 native C backend
(`--threads 1 --gpu off`), Go 1.25.5 with pinned fastssz via go-eth2-client.
Run of 2026-09-21, `build/native/comparison.json`
(sha256 `801a0aeb…3d1509`), Bend executable `5a3dee43…7a769e`, emitted C
`build/native/bend-compact.c` (`34dab261…4927d29`):

| fixture | input bytes | Bend baseline | Bend decode peak | **Bend decode overhead** | worst sample | Go baseline | Go decode peak | Go decode overhead |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| case_0 | 2,740,473 | 7,143,424 | 7,208,960 | **65,536** | 180,224 | 8,241,152 | 11,649,024 | 3,407,872 |
| case_1 | 2,740,934 | 7,438,336 | 7,438,336 | **32,768** | 147,456 | 8,257,536 | 11,649,024 | 3,391,488 |
| case_2 | 2,741,095 | 7,290,880 | 7,323,648 | **0** | 32,768 | 8,257,536 | 11,419,648 | 3,375,104 |
| case_3 | 2,739,794 | 7,290,880 | 7,356,416 | **65,536** | 180,224 | 8,257,536 | 11,665,408 | 3,407,872 |
| case_4 | 2,738,771 | 7,258,112 | 7,323,648 | **65,536** | 98,304 | 8,257,536 | 11,632,640 | 3,391,488 |

Worst single Bend sample: **180,224 bytes**, 0.56 % of the 32,000,000-byte
limit. All 15 Bend samples are `verified`. The previous list-based decoder
measured 12.7–13.0 MB here, and Go measures 3.4 MB.

Phase peaks from the same run:

| fixture | Bend root-phase peak | Bend serialize-phase peak | Bend whole run | Go root-phase peak | Go serialize-phase peak | Go whole run |
|---|---:|---:|---:|---:|---:|---:|
| case_0 | 7,323,648 | 7,536,640 | 7,536,640 | 19,382,272 | 22,200,320 | 22,200,320 |
| case_1 | 7,471,104 | 7,782,400 | 7,782,400 | 21,315,584 | 24,100,864 | 24,100,864 |
| case_2 | 7,454,720 | 7,749,632 | 7,749,632 | 19,431,424 | 21,905,408 | 21,905,408 |
| case_3 | 7,454,720 | 7,913,472 | 7,913,472 | 19,398,656 | 22,200,320 | 22,200,320 |
| case_4 | 7,421,952 | 7,684,096 | 7,684,096 | 21,299,200 | 24,100,864 | 24,100,864 |

The whole Bend process, including startup, input, decode, hashing, serialization
and output, peaks at 7.5–7.9 MB, against 21.9–24.1 MB for Go and ≈ 97 MB for the
previous list-based Bend path. The whole-run peak is **not** the decode peak;
both are listed.

Latency from the same runs (medians, ns). The Bend driver's clock has
millisecond resolution, so its figures are quantised. These are memory-harness
timings, not the performance contract's measurement (see BENCHMARKS.md):

| fixture | Bend decode | Go decode | Bend root | Go root | root ratio | Bend serialize (incl. writes) | Go serialize |
|---|---:|---:|---:|---:|---:|---:|---:|
| case_0 | 2,000,000 | 1,286,000 | 82,000,000 | 7,543,875 | 10.9x | 10,000,000 | 272,250 |
| case_1 | 2,000,000 | 1,298,834 | 82,000,000 | 7,538,542 | 10.9x | 10,000,000 | 273,042 |
| case_2 | 2,000,000 | 1,281,291 | 82,000,000 | 7,565,166 | 10.8x | 10,000,000 | 342,416 |
| case_3 | 1,000,000 | 1,317,500 | 82,000,000 | 7,746,500 | 10.6x | 10,000,000 | 279,625 |
| case_4 | 1,000,000 | 1,332,708 | 82,000,000 | 7,673,667 | 10.7x | 10,000,000 | 314,416 |

Decode is within 5x of Go. Root is just over the 10x contract limit. Serialize
is 30–37x Go even though Bend's figure includes the writes and Go's does not.
In the previous list-based path these were 14–15x, 79–82x and 1,070–1,300x.

**Fairness, stated plainly.**

* Bend's decoded value is a validated view of the input buffer; Go builds a
  typed struct and copies byte fields into it. That is the design, not a
  measurement trick: decode does all required validation (sizes, offsets, list
  limits, boolean bytes, bit-vector padding, bit-list terminators), and every
  field and element is then reachable through `src/access.bend` without
  copying. It favours Bend on decode overhead, and it is also why Bend's
  serialize of an unmodified view is a copy of its window.
* Go's decode is forced by a checksum fold over the struct. Bend's decode
  result is the verdict, and it is matched on inside the window; there is no
  deferred work, because the scan reads every offset, length and checked byte
  before it returns.

## Where the memory goes

**Baseline, 7.1–7.4 MB:** the runtime's floor plus the input buffer. The buffer
is one `Array<U32>` block, whose capacity is the next power of two in words:
2.74 MB of input occupies a 4 MiB block. Go's baseline is 8.2 MB for the same
bytes (runtime plus `os.ReadFile`'s slice).

**Decode, 0–180 KB:** the validator allocates no per-element structure. Its
state is one frame record per open container or sequence, and the schema is a
precomputed compact tree (`types/fulu_cschema.bend`). The residual is page
granularity plus the frames; it does not grow with the number of elements.

**Root, +0.1–0.2 MB:** merkleization is streaming. There is one 512-slot digest
stack (`MF.DStack`), each nesting level of the schema uses its own 64-slot
segment, and every Merkle node is eight words hashed through the package's
packed entry point. No chunk list or tree is built.

**Serialize, +0.2–0.5 MB:** one 64 KiB byte list per `File.write_bytes` call.
Base's file API accepts only a byte list, so a list per piece is the boundary
cost of writing. The encode API itself (`A.encode`) returns a fresh packed
`Buf` with no list.

## What the emitted C contains (read, not assumed)

`build/native/bend-compact.c` has 151,302 lines. Function ids exist only for the
compact modules (`croot`, `merkle_fast`, `api`, `digest`) and the SHA package
(`CID_0XDA83506FB9F059EAD7AFCFA2F498DF5F_*`). None exist for `src/packed`,
`src/cvalue`, `src/schema`, `src/walk`, `src/scan`, `src/root`, `src/tree`,
`src/ssz` or `src/decode` (`grep -c FID____SRC_<module>` is 0 for each). The
validator's recursive `run` appears inside `API_RUN_GO`, where the backend
inlined it into the dispatcher.

The block layer's own comment (lines ~1816–1825) is what shaped two decisions:

> A match on ANode is blk_half twice: each half allocated in its class and
> copied … A match to the leaves copies O(n log n) words where a view copied
> none; get, set, swap, size and new open no half.

So every runtime access to the buffer goes through `Array.get`/`Array.set`
(O(1), no copy). The first serializer walked the `ANode` tree; replacing it with
an indexed word loop took serialize from 21–23 ms to 10 ms. The stop-point fold
that inflated the baseline, described above, was removed for the same reason.

What is **not** list-free, and why:

* `File.read_at` returns each 64 KiB input piece as a byte list (Base API), and
  `B.fill_at` packs it into the buffer immediately. At most one piece is live
  at a time.
* `File.write_bytes` takes a byte list, so serialize-to-file builds one 64 KiB
  piece at a time.
* The digest checksum for `ROOTSUM` is formed from the 32-byte list view after
  the root is timed. It is driver output formatting, not part of the root.
* The pinned SHA package's internals are its own. The only interface used is
  packed `Array<U32>` in and eight words out.

## Compile-time costs that shaped the layout

* The generated schema table originally expanded every nested schema inline
  and carried 109-way index/name tables; elaborating that module alone cost
  3.98 GB. The generator now emits nested named schemas as calls to their
  definitions, and the index table lives in its own module
  (`types/fulu_cschema_index.bend`) that only multi-type programs import.
  The schema module now costs 0.22 GB and the index 1.30 GB.
* The pinned compiler elaborates every definition of every imported module, so
  field access and encode live in `src/access.bend` rather than `src/api.bend`.

## What is not established

* **Proofs:** none of the compact modules (`buffer`, `cschema`, `cscan`,
  `merkle_fast`, `croot`, `api`, `access`) has a checked refinement against the
  frozen specifications yet. Nor is the packed-input → FIPS byte-list SHA bridge
  proved (the package release does not provide it). The existing
  `PROOF.bend`/`END_TO_END.bend` are about the list-based modules, which still
  exist for them.
* **Conformance through the new API:** the compact path is checked on all five
  `BeaconState` fixtures (roots equal `roots.yaml`, byte-exact round trip,
  truncated and overlong inputs rejected), on 57 official `ssz_static` types
  rooted by the interpreter, and by 49 field-access checks against an
  independent reader (`build/access_check.py`). It does not yet run the 5440
  official cases. The compact schema has no progressive list, progressive
  bit-list, progressive container or compatible-union forms yet, and those
  make up about half of `ssz_generic`.
* **Performance contract:** root is ~10.8x and serialize ~30–37x Go on
  `BeaconState` in this harness, so the per-workload gate is not met.
* ru_maxrss measures resident pages, not allocator accounting; the Bend runtime
  exposes no heap counter, and patching the compiler or emitted C to add one is
  out of scope. Three samples per fixture per implementation on one machine;
  memory figures were stable to within 0.3 MB across samples.
