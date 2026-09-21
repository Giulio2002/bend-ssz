# Native memory review — Bend C SSZ versus Go fastssz

Scope: the **native** Bend C backend only. Nothing in this document is a
Bun/JavaScript measurement.

Reproduce with:

```
python3 native_bench/run.py                        # writes build/native/comparison.json
python3 automation/native_memory_acceptance.py     # frozen operator gate (also runs proofs,
                                                   # runtime tests, spectests, then run.py)
```

The measured Bend program is `native_bench/driver.bend`, the **compact primary
path**:

* one packed `Array<U32>` input buffer;
* an in-place validating decode (`API.validate` → `src/cscan.bend`);
* `hash_tree_root` over the same buffer (`API.root` → `src/croot.bend`,
  `src/merkle_fast.bend`, the pinned BendHub SHA-256 package), with every
  intermediate digest in the buffer's own packed scratch;
* a streamed encode.

The list-based modules (`src/packed.bend`, `src/cvalue.bend`, `src/decode.bend`,
…) are the model the checked proofs are about; they are not in the measured
program (see "Emitted C" below).

**The proofs do not cover the compact path.** See "What is not established".

## What is measured, and how

Both programs (`native_bench/driver.bend`, `native_bench/fastssz/main.go`) run
the same workload on the same raw fixture bytes, one sequential thread, a fresh
process per sample:

read file → decode → `hash_tree_root` → serialize → write.

* **Go:** `os.ReadFile`, `UnmarshalSSZ` into the generated struct plus a
  checksum fold, `HashTreeRoot`, `MarshalSSZ`, write.
* **Bend:**
  - read: the file goes straight into the packed buffer in 64 KiB pieces, so
    the input never exists as a whole byte list, and the last byte is read
    before the baseline marker so the buffer is complete when the baseline is
    taken;
  - decode: validates the whole `BeaconState` in place. The decoded value is
    the validated buffer (a zero-copy view), the verdict is matched on inside
    the measured window, and a rejected input exits nonzero;
  - root: runs over the same buffer;
  - serialize: streams the view's bytes to the output file in 64 KiB pieces,
    and its time includes the writes.

Every phase boundary is also an exit point (`SSZ_PHASES=input|decode|root|all`).
A phase's peak comes from a **separate process that performs exactly the prefix
of the workload up to that boundary and then stops**. The kernel reports that
process's peak resident size through `wait4`'s `ru_maxrss`, a high-water mark
maintained on every page fault, not a sample. So:

    decode_overhead_bytes = peak(prefix through decode) − peak(prefix through input)

A stopping process drops its buffer without traversing it, so it does no work
the full run does not. A 0.5 ms sampler during the full run and idle readings
at each phase marker cross-check the kernel figure, and every reported peak is
the **maximum** of all three. The harness fails the run if the stopping
process's kernel peak is materially below what sampling saw in the full run.

`verified` is derived: the process wrote output bytes identical to the fixture,
reached every phase marker and reported decode, root and serialize timings.
For every fixture, the root checksums of Bend and Go agree
(`root_checksum_agreement`). A 0 ms decode reading is a present reading: the
driver's clock has millisecond resolution and a compact BeaconState decode
finishes inside one tick. The harness used to mistake that 0 for a missing
value; that was fixed in `native_bench/run.py` (`first`).

Compilation is excluded from every sample and always rebuilt, under a 6.5 GB
compile-footprint cap with retries; every attempt is recorded in
`comparison.json` (`bend_compile_attempts`).

## Result

Run of 2026-09-21 (report written 12:13) inside the frozen gate
`automation/native_memory_acceptance.py` (exit 0, 2,181 s, peak 5.83 GB for the
whole gate process tree under `benchmarks/checks/capped_run.py`; log:
`benchmarks/evidence/native_memory_acceptance.log`). Five mainnet Fulu
`BeaconState` fixtures, three Bend and three Go samples each, medians. Apple M4
/ macOS 15.6 arm64, Bend 2.0.16 native C (`--threads 1 --gpu off`), Go 1.25.5
with pinned fastssz / go-eth2-client. Raw report:
`benchmarks/evidence/native-comparison.json`. Emitted C:
`benchmarks/evidence/driver-emitted.c.gz`. Executable and C hashes:
`benchmarks/evidence/driver-artifacts.sha256`.

| fixture | input bytes | Bend baseline | Bend decode peak | **Bend decode overhead** | worst sample | Go baseline | Go decode peak | Go decode overhead |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| case_0 | 2,740,473 | 7,274,496 | 7,323,648 | **49,152** | 409,600 | 8,028,160 | 11,436,032 | 3,375,104 |
| case_1 | 2,740,934 | 7,274,496 | 7,290,880 | **49,152** | 49,152 | 8,241,152 | 11,616,256 | 3,358,720 |
| case_2 | 2,741,095 | 7,307,264 | 7,307,264 | **16,384** | 49,152 | 8,028,160 | 11,403,264 | 3,375,104 |
| case_3 | 2,739,794 | 7,340,032 | 7,356,416 | **49,152** | 81,920 | 8,257,536 | 11,632,640 | 3,391,488 |
| case_4 | 2,738,771 | 7,307,264 | 7,389,184 | **49,152** | 81,920 | 8,257,536 | 11,599,872 | 3,375,104 |

Worst Bend sample: **409,600 bytes**, 1.3 % of the 32,000,000-byte limit; all
15 Bend and 15 Go samples are `verified`. The other 14 Bend samples are
0-81,920 bytes. In the worst sample (case_0, repeat 0), the stop-after-decode
process peaked at 7,716,864 bytes, while the same repeat's stop-after-root
process, which does strictly more work, peaked at 7,471,104. So the extra
~0.25 MB is page-residency variation of that one process, not decode work. It is
reported as measured anyway. The sampler cross-check held: at most 1.046 ×
the kernel decode peak, against the harness's 1.05 limit. Go's decode overhead
is 3.1-3.6 MB, because Go copies the byte fields into its struct.

Phase peaks from the same run (medians):

| fixture | Bend root-phase peak | Bend serialize-phase peak | Bend whole run | Go root-phase peak | Go serialize-phase peak | Go whole run |
|---|---:|---:|---:|---:|---:|---:|
| case_0 | 7,471,104 | 7,864,320 | 7,864,320 | 19,185,664 | 21,921,792 | 21,921,792 |
| case_1 | 7,438,336 | 7,815,168 | 7,815,168 | 19,365,888 | 22,183,936 | 22,183,936 |
| case_2 | 7,438,336 | 7,520,256 | 7,520,256 | 19,382,272 | 21,921,792 | 21,921,792 |
| case_3 | 7,471,104 | 7,979,008 | 7,979,008 | 19,562,496 | 22,167,552 | 22,167,552 |
| case_4 | 7,503,872 | 7,979,008 | 7,979,008 | 19,382,272 | 21,921,792 | 21,921,792 |

The whole Bend process, including input, decode, hashing, serialization and
output, peaks at 7.5-8.1 MB over all 15 samples, against 21.8-24.4 MB for Go.
For history: the list-based Bend path peaked at about 97 MB with a 12.7-13.0 MB
decode overhead. The whole-run peak is not the decode peak; both are listed.

Build note: the pinned compiler is a Bun/JavaScriptCore executable, and its own
peak varied from 5 GB to over 6.5 GB on this loaded machine. One gate attempt
failed because four C-emission compiles hit the runner's 6.5 GB cap. Both
runners now give compiler processes (only) `BUN_JSC_forceRAMSize=3000000000`.
This run's compiles peaked at 2.86 GB and 3.26 GB on the first attempt, and the
emitted C (`4f4302b5…`) is byte-identical to a compile without the variable.
The setting is recorded as `bend_compile_env` in the report.

Timings in this harness are phase markers at millisecond resolution on a
shared machine, not the performance contract. That is measured by
`benchmarks/run.py` (BENCHMARKS.md).

## Where the memory goes, and the remaining gap

| phase | Bend | Go | why |
|---|---:|---:|---|
| baseline (runtime + input) | 7.2–7.5 MB | 8.0–8.3 MB | Bend: runtime floor plus the input block, whose capacity is the next power of two in words (2.74 MB of input in a 4 MiB block). Go: runtime plus `os.ReadFile`'s slice |
| decode | 0–0.41 MB (median ≤ 49 KB) | 3.1–3.6 MB | Bend allocates no per-element structure: validation state is one frame record per open container or sequence, and plain fixed fields and vectors are not visited at all. Go builds and fills the struct |
| root | +0–0.2 MB | +7.5–10.4 MB | Bend: the level stack and zero-subtree table live in 32 KiB of scratch inside the input block's slack. Go: the hasher buffer grows with the largest group of chunks |
| serialize + write | +0.03–0.6 MB | +0.2–2.8 MB | Bend: one 64 KiB byte list per `File.write_bytes` call; Base's file API accepts only a byte list. Go: the marshalled output slice |

The Bend decode overhead is at page granularity (median 0-3 pages of 16 KiB; the 25-page outlier is discussed above): there is nothing
per element left to remove. The baseline is below Go's. So the remaining
difference to Go on this workload is in Bend's favour, and it comes from a
design difference that should be stated plainly: Bend's decoded value is a view
of the input, while Go's is an owned struct.

What is **not** list-free in the measured program, and why:

* `File.read_at` returns each 64 KiB input piece as a byte list (Base API);
  `B.fill_at` packs it into the buffer immediately, and at most one piece is
  live at a time.
* `File.write_bytes` takes a byte list, so writing builds one 64 KiB piece at a
  time.
* `ROOTSUM`, the driver's checksum of the root for the harness, is formed from
  the 32-byte list view after the root is timed.
* The SHA package's internals are its own. The interface used is packed
  `Array<U32>` in and eight words out.

## Emitted C (read, not assumed)

`build/native/bend-compact.c` (163,145 lines, sha256 `4f4302b5…935818eb`;
compressed copy in evidence):

* function ids exist for the compact walkers only. `grep -c FID____SRC_<module>`
  gives `CROOT_` 3,235, `MERKLE_FAST_` 310 and `API_` 4; the scanner and the
  buffer accessors are inlined into them;
* the count is 0 for every list-based module: `PACKED`, `CVALUE`, `SCHEMA_`,
  `WALK`, `DECODE_`, `CODEC`, `ROOT_`, `TREE_`, `LIMITS`, `PACKING`,
  `BYTE_ROOT`, `BYTE_LIST`;
* buffer and scratch access are block reads and writes (`blk_read`/`blk_write`,
  82 sites), which the block layer documents as O(1) with no copy:

  > A match on ANode is blk_half twice: each half allocated in its class and
  > copied … get, set, swap, size and new open no half.

  Every runtime access therefore goes through `Array.get`/`Array.set`. The
  encoder copies a whole-buffer view with `Array.clone`, which the same comment
  describes as a raw block copy for a U32 buffer.

## What is not established

* **Proofs of the compact path.** No checked law covers `src/buffer`,
  `cschema`, `cscan`, `access`, `croot`, `merkle_fast`, `digest` or `api`, nor
  the packed-input → FIPS SHA bridge. `docs/COMPACT_PROOF_PLAN.md` lays out the
  work. The checked roots (`PROOF.bend`, `END_TO_END.bend`, `ROOT_DOMAIN.bend`:
  5.00–5.28 GB, logs in `benchmarks/evidence/check_*.log`) are about the
  list-based model API.
* **Coverage limits of the compact schema beyond the official cases.**
  Progressive containers are limited to 31 active positions, refused
  explicitly beyond that. Compatible-union option compatibility
  (`spec/compatibility.bend`) is not re-derived by the generator. The official
  cases pass, but that is finite evidence, not unrestricted semantics.
* ru_maxrss measures resident pages, not allocator accounting; the Bend runtime
  exposes no heap counter, and patching the compiler or emitted C to add one is
  out of scope. Three samples per fixture per implementation on one shared
  machine. Memory figures were stable to within 0.3 MB.
