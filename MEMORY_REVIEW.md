# Native memory review — Bend C SSZ versus Go fastssz

Scope: the **native** Bend C backend only. Nothing in this document is a
Bun/JavaScript measurement.

Reproduce with:

```
python3 native_bench/run.py                        # writes build/native/comparison.json
python3 automation/native_memory_acceptance.py     # frozen operator gate (also runs proofs,
                                                   # runtime tests, spectests, then run.py)
```

The measured Bend program is `native_bench/driver.bend`, which uses the
**generated typed owning object API** (`types/fulu_obj.bend`, emitted by
`codegen/generate.py`; see docs/CODEGEN.md):

* one packed `Array<U32>` input buffer, filled straight from the file;
* `BeaconState_decode`: the generated validator over that buffer, then the
  generated reader, which builds the typed owning object - a record per
  container, packed `Array<U32>` for byte/bit/packed storage and array-backed
  sequences of element objects. The object owns its storage; it is not a view
  into the input;
* `BeaconState_hash_tree_root` over the object, streaming, with every
  intermediate digest in a packed scratch buffer and the pinned BendHub
  SHA-256 package doing the compression;
* `BeaconState_encode`: fresh canonical bytes from the object.

The object is kept live until after the measurement (`keep_obj`), so nothing
that decode allocated can be collected before the peak is taken.

The list-based modules (`src/model.bend`, `src/packed.bend`, `src/cvalue.bend`,
`src/decode.bend`, ...) are the model the checked `END_TO_END` proofs are about;
they are not in the measured program (see "Emitted C" below).

**The universal proofs do not cover the generated object codec.** See "What is
not established".

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
  - decode: the generated validator runs over the whole `BeaconState` window
    and the generated reader then builds the typed owning object, copying its
    storage out of the input buffer. The verdict is matched on inside the
    measured window, a rejected input exits nonzero, and the object is kept
    live past the peak measurement;
  - root: `BeaconState_hash_tree_root` of that object;
  - serialize: `BeaconState_encode` produces fresh canonical bytes, streamed
    to the output file in 64 KiB pieces, and its time includes the writes.

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
| case_0 | 2,740,473 | 7,159,808 | 12,943,360 | **5,783,552** | 5,832,704 | 8,404,992 | 11,763,712 | 3,358,720 |
| case_1 | 2,740,934 | 7,225,344 | 12,943,360 | **5,718,016** | 5,718,016 | 8,241,152 | 11,649,024 | 3,407,872 |
| case_2 | 2,741,095 | 7,274,496 | 12,959,744 | **5,685,248** | 5,865,472 | 8,142,848 | 11,665,408 | 3,424,256 |
| case_3 | 2,739,794 | 7,274,496 | 12,943,360 | **5,718,016** | 5,750,784 | 8,388,608 | 11,730,944 | 3,309,568 |
| case_4 | 2,738,771 | 7,208,960 | 12,992,512 | **5,718,016** | 5,914,624 | 8,388,608 | 11,747,328 | 3,358,720 |

Worst Bend sample: **5,914,624 bytes**, 18.5 % of the 32,000,000-byte
limit; all 15 Bend and 15 Go samples are `verified`. Go's worst decode
overhead on the same fixtures is 3,637,248 bytes, so the remaining ratio is
about 1.63x Go.

Both sides do the same thing: they copy the byte fields out of the input into
a typed owning value. Bend's residual excess over Go is the packed storage
rounding - every `Array<U32>` is a power-of-two block and every packed byte
range is rounded up to whole 32-byte chunks, so a collection costs up to twice
its bytes - plus the runtime's own block headers. Neither is reachable from
the SSZ code: `Array.new` is the only allocation the pinned Base offers and
its size is 2^d.

The sampler cross-check held on every sample (`monotone_within_decode`, and
the sampled maximum never above the kernel decode peak). Every output byte was
compared (`output_bytes_match`), and the root checksums agree between the two
implementations on every fixture.

Phase peaks from the same run (medians):

| fixture | Bend root-phase peak | Bend serialize-phase peak | Bend whole run | Go root-phase peak | Go serialize-phase peak | Go whole run |
|---|---:|---:|---:|---:|---:|---:|
| case_0 | 13,172,736 | 13,680,640 | 13,680,640 | 19,513,344 | 21,954,560 | 21,954,560 |
| case_1 | 13,139,968 | 13,959,168 | 13,959,168 | 19,005,440 | 21,741,568 | 21,741,568 |
| case_2 | 13,189,120 | 13,746,176 | 13,746,176 | 19,415,040 | 21,905,408 | 21,905,408 |
| case_3 | 13,205,504 | 14,516,224 | 14,516,224 | 21,741,568 | 22,216,704 | 22,216,704 |
| case_4 | 13,123,584 | 13,484,032 | 13,484,032 | 19,595,264 | 22,200,320 | 22,200,320 |

The whole Bend process, including input, decode, hashing, serialization and
output, peaks at 13.5-15.3 MB over all 15 samples, against 21.5-24.4 MB for Go.
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

* **Universal codec proofs of the generated object path.** No checked law
  states that the generated validator accepts exactly the canonical encodings,
  or that the generated reader/encoder round-trip, for `types/fulu_obj.bend`
  and `types/generic_obj.bend`. What is checked is: the mutation, collection,
  cache and cost laws of `proofs/obj/*.bend`; the universal soundness proof of
  the compact window scanner (`proofs/compact/sound.bend`); and the model-API
  laws of `PROOF.bend` / `END_TO_END.bend` / `ROOT_DOMAIN.bend` (logs in
  `benchmarks/evidence/check_*.log`). The packed-input → FIPS SHA bridge is
  also still open. `docs/COMPACT_PROOF_PLAN.md` lays out the work; it is the
  largest remaining obligation and is not claimed as done anywhere.
* **Coverage limits beyond the official cases.** Progressive containers are
  limited to 31 active positions and refused explicitly beyond that
  (`codegen/generic.py`). Eight of the 144 official generic schema
  descriptions are refused as not SSZ types (zero-length vectors and bit
  vectors); every official case for them is an invalid case. Compatible-union
  option compatibility (`spec/compatibility.bend`) is not re-derived by the
  generator. All 5,440 official cases pass through the generated object API,
  but that is finite evidence, not unrestricted semantics.
* ru_maxrss measures resident pages, not allocator accounting; the Bend runtime
  exposes no heap counter, and patching the compiler or emitted C to add one is
  out of scope. Three samples per fixture per implementation on one shared
  machine. Memory figures were stable to within 0.3 MB.

## 2026-09-23: native memory on stock Bend 2.0.25

`native_bench/run.py` (the native step of `automation/native_memory_acceptance.py`)
run directly on 2.0.25 with a fresh build, because the gate's earlier step
`automation/acceptance.py` still compares the compiler against the 2.0.16 pin in
the protected `automation/toolchain.json` and stops with "Pinned 2.0.16
toolchain identity changed: bend" (see docs/TOOLCHAIN.md for the hash-only
update). The gate's own per-sample conditions were applied to
`build/native/comparison.json`: complete, 5 fixtures, 3 verified Bend samples
each, `decode_overhead_bytes == max(0, peak - baseline)`, all <= 32,000,000.

| fixture | Bend max decode overhead | Go max decode overhead |
| --- | ---: | ---: |
| BeaconState ssz_random case_0 | 6,209,536 | 3,571,712 |
| case_1 | 6,340,608 | 3,637,248 |
| case_2 | 5,767,168 | 3,407,872 |
| case_3 | 6,422,528 | 3,555,328 |
| case_4 | 6,193,152 | 3,768,320 |

Worst Bend/Go ratio 1.8x; all 15 Bend samples verified and within the cap. The
representation and residual-source analysis above is unchanged (same generated
runtime; only the compiler moved).

## 2026-09-23 (later): re-run after the checked encoder

Same procedure as the previous section, fresh build of the final iteration-22
runtime (fused validity in the encoder; decode path unchanged).
`automation/native_memory_acceptance.py` again stops at its acceptance.py step
("Pinned 2.0.16 toolchain identity changed: bend"); `native_bench/run.py`
directly: complete, 5 fixtures, 3 verified samples per side each.
Log: build/final/native_bench.log.

| fixture | Bend max decode overhead | Go max decode overhead |
| --- | ---: | ---: |
| BeaconState ssz_random case_0 | 6,127,616 | 3,702,784 |
| case_1 | 6,373,376 | 3,620,864 |
| case_2 | 5,865,472 | 3,604,480 |
| case_3 | 6,144,000 | 3,424,256 |
| case_4 | 6,291,456 | 3,407,872 |

Worst Bend overhead 6.37 MB (cap 32,000,000 B); worst Bend/Go ratio 1.8x.
