# Native SSZ benchmarks — Bend C versus Go fastssz

Reproduce exactly these numbers with:

```
python3 benchmarks/run.py --report build/performance/report.json
python3 tools/generate_benchmarks_md.py build/performance/report.json
```

The frozen operator gate that reads the same report is
`python3 automation/performance_gate.py`.

## Method

Both sides are native and built fresh by the runner: Bend through its native C
backend (`bend benchmarks/native_driver.bend -o ...`, run with `--threads 1
--gpu off`), Go through `go build` with `GOMAXPROCS(1)`. No Bun/JavaScript
result appears here. Only the public API is measured (`ssz.deserialize`,
`ssz.serialize`, `ssz.hash_tree_root`); reading the workload, choosing the
schema and, for serialize and hash_tree_root, the single preparatory decode are
outside every timed region on both sides.

Each row is one type, one workload and one operation: the operation is repeated
`operations_per_sample` times inside one timed region (calibrated so a sample is
long enough that timer resolution is not a factor), every result is consumed,
and at least five samples per side alternate between the implementations in
fresh processes. Reported timings are nanoseconds per operation; the ratio is
median(Bend) / median(Go), per workload, with no aggregation across workloads.

Before any timing is recorded both implementations must round-trip the exact
workload bytes and agree on the checksum of the hash tree root; that agreement
is what `verified` means in the report.

Two measurement properties worth stating plainly:

* Bend is lazy, so its deserialize loop folds every decoded leaf to force the
  value, while the Go loop retains the decoded struct without traversing it.
  The Bend deserialize numbers are therefore pessimistic, never the reverse.
* Repeating an operation on the same input in Bend copies the input graph per
  iteration, because a value consumed by a call has to be duplicated to be
  used again; Go re-reads the same buffer. That duplication is a genuine cost
  of calling the API repeatedly in Bend and is inside the Bend measurement.

| environment | |
|---|---|
| cpu | Apple M4 |
| os | macOS-15.6-arm64-arm-64bit-Mach-O |
| bend_compiler | bend 2.0.16 |
| reference_compiler | go version go1.25.5 darwin/arm64 |
| bend_flags | --threads 1 --gpu off (native C backend, release build) |
| reference_flags | go build (release defaults), GOMAXPROCS=1 |
| reference_revision | go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod) |

## Result against the frozen contract

* 978 measured workloads covering 327 of the 327 required operations.
* 5 of 978 workloads are within their operation limit (deserialize/serialize 5x, hash_tree_root 10x).

Ratio distribution over all measured workloads: minimum 2.2x, median 85.8x, maximum 2285.7x.

* `deserialize`: 326 workloads, minimum 15.9x, median 188.3x, maximum 985.0x (limit 5x).
* `serialize`: 326 workloads, minimum 2.2x, median 191.2x, maximum 2285.7x (limit 5x).
* `hash_tree_root`: 326 workloads, minimum 16.0x, median 64.3x, maximum 202.1x (limit 10x).

## What the numbers say

The gate fails. The shortfall is not concentrated in one type or one operation,
and it is not a constant factor either - it is a large per-call cost plus a
large per-element cost:

* the cheapest workloads are the ones that do almost nothing per call
  (`boolean.serialize`, `Bytes1.serialize`), which is where the Bend runtime's
  own call overhead is most of what is measured;
* fixed 32-byte leaves cost single-digit microseconds per call in Bend against
  tens of nanoseconds in Go, so even small containers that move almost no data
  land in the hundreds;
* `hash_tree_root` is the closest family because both sides are dominated by
  hashing rather than by walking structure. A 131,072-byte `Blob` is 4,096
  chunks and 4,095 merkle hashes: Bend takes 29.3 ms for it and Go 0.41 ms,
  about 7.2 us against 0.10 us per hash. That is the pinned pure-Bend SHA-256,
  which by instruction may not be replaced with hardware SHA, foreign crypto or
  compiler intrinsics.

Both implementations agree on every root and on every malformed input, so this
is a throughput gap, not a semantic one. Closing it needs representation work
rather than tuning: byte payloads still become one list cell per byte at the
public `T.Value` boundary for serialize and root, sequences still cost one spine
cell per element, and every public call re-validates its schema. Those are the
three places these measurements point at.

## All measured workloads

| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |
|---|---|---:|---:|---:|---:|---:|---:|:--:|
| AggregateAndProof.deserialize | large-fixture | 346 | 8192 | 36865.2 | 157.9 | 233.5x | 5x | no |
| AggregateAndProof.deserialize | medium-fixture | 345 | 8192 | 36865.2 | 159.0 | 231.8x | 5x | no |
| AggregateAndProof.deserialize | small-fixture | 345 | 8192 | 37231.4 | 161.4 | 230.6x | 5x | no |
| AggregateAndProof.hash_tree_root | large-fixture | 346 | 2176 | 217830.9 | 2987.2 | 72.9x | 10x | no |
| AggregateAndProof.hash_tree_root | medium-fixture | 345 | 2816 | 167258.5 | 2136.8 | 78.3x | 10x | no |
| AggregateAndProof.hash_tree_root | small-fixture | 345 | 2176 | 217830.9 | 2985.4 | 73.0x | 10x | no |
| AggregateAndProof.serialize | large-fixture | 346 | 8192 | 40039.1 | 60.3 | 664.5x | 5x | no |
| AggregateAndProof.serialize | medium-fixture | 345 | 8192 | 49072.3 | 72.3 | 678.5x | 5x | no |
| AggregateAndProof.serialize | small-fixture | 345 | 8192 | 39550.8 | 59.1 | 669.8x | 5x | no |
| Attestation.deserialize | large-fixture | 237 | 16384 | 25756.8 | 125.9 | 204.5x | 5x | no |
| Attestation.deserialize | medium-fixture | 237 | 16384 | 26916.5 | 124.8 | 215.7x | 5x | no |
| Attestation.deserialize | small-fixture | 237 | 16384 | 26367.2 | 115.7 | 227.9x | 5x | no |
| Attestation.hash_tree_root | large-fixture | 237 | 2816 | 186079.5 | 2393.6 | 77.7x | 10x | no |
| Attestation.hash_tree_root | medium-fixture | 237 | 2560 | 187890.6 | 2396.6 | 78.4x | 10x | no |
| Attestation.hash_tree_root | small-fixture | 237 | 2560 | 189843.8 | 1547.8 | 122.7x | 10x | no |
| Attestation.serialize | large-fixture | 237 | 16384 | 23742.7 | 50.6 | 469.0x | 5x | no |
| Attestation.serialize | medium-fixture | 237 | 16384 | 24231.0 | 53.7 | 451.4x | 5x | no |
| Attestation.serialize | small-fixture | 237 | 16384 | 23803.7 | 53.1 | 447.9x | 5x | no |
| AttestationData.deserialize | large-fixture | 128 | 40960 | 11743.2 | 52.2 | 225.2x | 5x | no |
| AttestationData.deserialize | medium-fixture | 128 | 40960 | 11840.8 | 57.8 | 204.9x | 5x | no |
| AttestationData.deserialize | small-fixture | 128 | 40960 | 11889.6 | 57.4 | 207.0x | 5x | no |
| AttestationData.hash_tree_root | large-fixture | 128 | 3200 | 80000.0 | 848.6 | 94.3x | 10x | no |
| AttestationData.hash_tree_root | medium-fixture | 128 | 6400 | 91562.5 | 850.1 | 107.7x | 10x | no |
| AttestationData.hash_tree_root | small-fixture | 128 | 6400 | 84062.5 | 845.9 | 99.4x | 10x | no |
| AttestationData.serialize | large-fixture | 128 | 32768 | 12085.0 | 30.1 | 401.6x | 5x | no |
| AttestationData.serialize | medium-fixture | 128 | 32768 | 12054.4 | 29.8 | 404.8x | 5x | no |
| AttestationData.serialize | small-fixture | 128 | 32768 | 12085.0 | 32.0 | 377.4x | 5x | no |
| AttesterSlashing.deserialize | large-fixture | 624 | 7936 | 58341.7 | 247.8 | 235.5x | 5x | no |
| AttesterSlashing.deserialize | medium-fixture | 552 | 8192 | 52978.5 | 239.9 | 220.8x | 5x | no |
| AttesterSlashing.deserialize | small-fixture | 512 | 8192 | 48217.8 | 232.6 | 207.3x | 5x | no |
| AttesterSlashing.hash_tree_root | large-fixture | 624 | 1792 | 281250.0 | 5760.1 | 48.8x | 10x | no |
| AttesterSlashing.hash_tree_root | medium-fixture | 552 | 1920 | 259375.0 | 5989.2 | 43.3x | 10x | no |
| AttesterSlashing.hash_tree_root | small-fixture | 512 | 2048 | 248535.2 | 5979.2 | 41.6x | 10x | no |
| AttesterSlashing.serialize | large-fixture | 624 | 5248 | 87080.8 | 112.6 | 773.2x | 5x | no |
| AttesterSlashing.serialize | medium-fixture | 552 | 3200 | 74375.0 | 89.5 | 830.8x | 5x | no |
| AttesterSlashing.serialize | small-fixture | 512 | 6400 | 68750.0 | 84.8 | 810.9x | 5x | no |
| BLSPubkey.deserialize | random | 48 | 114688 | 4412.0 | 36.3 | 121.6x | 5x | no |
| BLSPubkey.deserialize | saturated | 48 | 114688 | 5057.2 | 43.5 | 116.2x | 5x | no |
| BLSPubkey.deserialize | zero | 48 | 114688 | 4630.0 | 42.3 | 109.4x | 5x | no |
| BLSPubkey.hash_tree_root | random | 48 | 40960 | 11084.0 | 291.4 | 38.0x | 10x | no |
| BLSPubkey.hash_tree_root | saturated | 48 | 40960 | 11254.9 | 297.8 | 37.8x | 10x | no |
| BLSPubkey.hash_tree_root | zero | 48 | 40960 | 10986.3 | 291.9 | 37.6x | 10x | no |
| BLSPubkey.serialize | random | 48 | 524288 | 824.0 | 17.7 | 46.6x | 5x | no |
| BLSPubkey.serialize | saturated | 48 | 507904 | 836.8 | 17.5 | 47.8x | 5x | no |
| BLSPubkey.serialize | zero | 48 | 507904 | 823.0 | 17.1 | 48.0x | 5x | no |
| BLSSignature.deserialize | random | 96 | 73728 | 6890.2 | 44.4 | 155.3x | 5x | no |
| BLSSignature.deserialize | saturated | 96 | 73728 | 6930.9 | 43.7 | 158.7x | 5x | no |
| BLSSignature.deserialize | zero | 96 | 73728 | 6903.8 | 44.5 | 155.3x | 5x | no |
| BLSSignature.hash_tree_root | random | 96 | 16384 | 22766.1 | 478.8 | 47.5x | 10x | no |
| BLSSignature.hash_tree_root | saturated | 96 | 16384 | 22522.0 | 482.6 | 46.7x | 10x | no |
| BLSSignature.hash_tree_root | zero | 96 | 16384 | 22888.2 | 483.4 | 47.3x | 10x | no |
| BLSSignature.serialize | random | 96 | 167936 | 1625.6 | 21.7 | 75.0x | 5x | no |
| BLSSignature.serialize | saturated | 96 | 253952 | 1642.0 | 21.9 | 75.0x | 5x | no |
| BLSSignature.serialize | zero | 96 | 286720 | 1628.8 | 21.4 | 76.3x | 5x | no |
| BLSToExecutionChange.deserialize | large-fixture | 76 | 73728 | 6958.0 | 19.8 | 350.5x | 5x | no |
| BLSToExecutionChange.deserialize | medium-fixture | 76 | 36864 | 7053.0 | 17.9 | 394.1x | 5x | no |
| BLSToExecutionChange.deserialize | small-fixture | 76 | 36864 | 7053.0 | 18.0 | 391.7x | 5x | no |
| BLSToExecutionChange.hash_tree_root | large-fixture | 76 | 8192 | 32959.0 | 414.4 | 79.5x | 10x | no |
| BLSToExecutionChange.hash_tree_root | medium-fixture | 76 | 8192 | 34179.7 | 415.1 | 82.3x | 10x | no |
| BLSToExecutionChange.hash_tree_root | small-fixture | 76 | 8192 | 33935.5 | 414.1 | 81.9x | 10x | no |
| BLSToExecutionChange.serialize | large-fixture | 76 | 106496 | 4319.4 | 22.3 | 193.3x | 5x | no |
| BLSToExecutionChange.serialize | medium-fixture | 76 | 106496 | 4441.5 | 21.9 | 202.6x | 5x | no |
| BLSToExecutionChange.serialize | small-fixture | 76 | 106496 | 4488.4 | 22.2 | 202.0x | 5x | no |
| BeaconBlock.deserialize | large-fixture | 21487 | 256 | 2003906.2 | 11505.2 | 174.2x | 5x | no |
| BeaconBlock.deserialize | medium-fixture | 21424 | 256 | 1906250.0 | 9975.8 | 191.1x | 5x | no |
| BeaconBlock.deserialize | small-fixture | 11198 | 512 | 1126953.1 | 4447.3 | 253.4x | 5x | no |
| BeaconBlock.hash_tree_root | large-fixture | 21487 | 82 | 5609756.1 | 98076.7 | 57.2x | 10x | no |
| BeaconBlock.hash_tree_root | medium-fixture | 21424 | 62 | 8032258.1 | 102786.3 | 78.1x | 10x | no |
| BeaconBlock.hash_tree_root | small-fixture | 11198 | 100 | 4800000.0 | 69787.5 | 68.8x | 10x | no |
| BeaconBlock.serialize | large-fixture | 21487 | 62 | 4209677.4 | 2262.8 | 1860.4x | 5x | no |
| BeaconBlock.serialize | medium-fixture | 21424 | 62 | 4225806.5 | 2139.1 | 1975.5x | 5x | no |
| BeaconBlock.serialize | small-fixture | 11198 | 128 | 2414062.5 | 1203.8 | 2005.4x | 5x | no |
| BeaconBlockBody.deserialize | large-fixture | 24042 | 128 | 2187500.0 | 12246.4 | 178.6x | 5x | no |
| BeaconBlockBody.deserialize | medium-fixture | 19087 | 256 | 1718750.0 | 8528.5 | 201.5x | 5x | no |
| BeaconBlockBody.deserialize | small-fixture | 11894 | 256 | 1035156.2 | 5269.9 | 196.4x | 5x | no |
| BeaconBlockBody.hash_tree_root | large-fixture | 24042 | 50 | 10140000.0 | 119133.3 | 85.1x | 10x | no |
| BeaconBlockBody.hash_tree_root | medium-fixture | 19087 | 31 | 8322580.6 | 99450.3 | 83.7x | 10x | no |
| BeaconBlockBody.hash_tree_root | small-fixture | 11894 | 82 | 5865853.7 | 71706.8 | 81.8x | 10x | no |
| BeaconBlockBody.serialize | large-fixture | 24042 | 62 | 4112903.2 | 2717.1 | 1513.7x | 5x | no |
| BeaconBlockBody.serialize | medium-fixture | 19087 | 128 | 3554687.5 | 1966.8 | 1807.3x | 5x | no |
| BeaconBlockBody.serialize | small-fixture | 11894 | 128 | 2078125.0 | 1391.9 | 1493.0x | 5x | no |
| BeaconBlockHeader.deserialize | large-fixture | 112 | 49152 | 10498.0 | 24.0 | 436.6x | 5x | no |
| BeaconBlockHeader.deserialize | medium-fixture | 112 | 49152 | 12207.0 | 27.1 | 451.0x | 5x | no |
| BeaconBlockHeader.deserialize | small-fixture | 112 | 49152 | 10396.3 | 24.4 | 426.5x | 5x | no |
| BeaconBlockHeader.hash_tree_root | large-fixture | 112 | 7936 | 50907.3 | 576.3 | 88.3x | 10x | no |
| BeaconBlockHeader.hash_tree_root | medium-fixture | 112 | 7936 | 51915.3 | 577.1 | 90.0x | 10x | no |
| BeaconBlockHeader.hash_tree_root | small-fixture | 112 | 8192 | 51025.4 | 578.5 | 88.2x | 10x | no |
| BeaconBlockHeader.serialize | large-fixture | 112 | 65536 | 6835.9 | 25.5 | 268.5x | 5x | no |
| BeaconBlockHeader.serialize | medium-fixture | 112 | 65536 | 6790.2 | 25.4 | 267.6x | 5x | no |
| BeaconBlockHeader.serialize | small-fixture | 112 | 65536 | 6881.7 | 25.9 | 265.7x | 5x | no |
| BeaconState.deserialize | large-fixture | 2741095 | 1 | 253000000.0 | 355250.0 | 712.2x | 5x | no |
| BeaconState.deserialize | medium-fixture | 2740473 | 1 | 256000000.0 | 352625.0 | 726.0x | 5x | no |
| BeaconState.deserialize | small-fixture | 2738771 | 2 | 230000000.0 | 278687.5 | 825.3x | 5x | no |
| BeaconState.hash_tree_root | large-fixture | 2741095 | 1 | 732000000.0 | 9307292.0 | 78.6x | 10x | no |
| BeaconState.hash_tree_root | medium-fixture | 2740473 | 1 | 694000000.0 | 8580583.0 | 80.9x | 10x | no |
| BeaconState.hash_tree_root | small-fixture | 2738771 | 1 | 692000000.0 | 8523708.0 | 81.2x | 10x | no |
| BeaconState.serialize | large-fixture | 2741095 | 1 | 320000000.0 | 352666.0 | 907.4x | 5x | no |
| BeaconState.serialize | medium-fixture | 2740473 | 1 | 312000000.0 | 349208.0 | 893.5x | 5x | no |
| BeaconState.serialize | small-fixture | 2738771 | 1 | 304000000.0 | 363625.0 | 836.0x | 5x | no |
| Blob.deserialize | random | 131072 | 50 | 10840000.0 | 11609.2 | 933.7x | 5x | no |
| Blob.deserialize | saturated | 131072 | 27 | 10000000.0 | 15086.4 | 662.8x | 5x | no |
| Blob.deserialize | zero | 131072 | 50 | 10720000.0 | 11465.0 | 935.0x | 5x | no |
| Blob.hash_tree_root | random | 131072 | 16 | 29312500.0 | 410130.2 | 71.5x | 10x | no |
| Blob.hash_tree_root | saturated | 131072 | 16 | 29375000.0 | 380247.4 | 77.3x | 10x | no |
| Blob.hash_tree_root | zero | 131072 | 16 | 29375000.0 | 380390.6 | 77.2x | 10x | no |
| Blob.serialize | random | 131072 | 124 | 2241935.5 | 7813.2 | 286.9x | 5x | no |
| Blob.serialize | saturated | 131072 | 124 | 2314516.1 | 8182.5 | 282.9x | 5x | no |
| Blob.serialize | zero | 131072 | 124 | 2306451.6 | 7854.2 | 293.7x | 5x | no |
| BlobIdentifier.deserialize | large-fixture | 40 | 65536 | 4058.8 | 14.7 | 275.9x | 5x | no |
| BlobIdentifier.deserialize | medium-fixture | 40 | 65536 | 4058.8 | 14.7 | 275.3x | 5x | no |
| BlobIdentifier.deserialize | small-fixture | 40 | 65536 | 4028.3 | 15.1 | 267.3x | 5x | no |
| BlobIdentifier.hash_tree_root | large-fixture | 40 | 16384 | 21850.6 | 131.4 | 166.2x | 10x | no |
| BlobIdentifier.hash_tree_root | medium-fixture | 40 | 16384 | 21789.6 | 132.4 | 164.5x | 10x | no |
| BlobIdentifier.hash_tree_root | small-fixture | 40 | 16384 | 21606.4 | 132.4 | 163.2x | 10x | no |
| BlobIdentifier.serialize | large-fixture | 40 | 163840 | 2685.5 | 19.0 | 141.2x | 5x | no |
| BlobIdentifier.serialize | medium-fixture | 40 | 90112 | 2752.1 | 19.9 | 138.5x | 5x | no |
| BlobIdentifier.serialize | small-fixture | 40 | 180224 | 2713.3 | 18.6 | 146.0x | 5x | no |
| BlobIndex.deserialize | random | 8 | 204800 | 1352.5 | 39.7 | 34.1x | 5x | no |
| BlobIndex.deserialize | saturated | 8 | 409600 | 1135.3 | 32.7 | 34.7x | 5x | no |
| BlobIndex.deserialize | zero | 8 | 253952 | 1110.4 | 32.7 | 34.0x | 5x | no |
| BlobIndex.hash_tree_root | random | 8 | 122880 | 4126.0 | 166.7 | 24.7x | 10x | no |
| BlobIndex.hash_tree_root | saturated | 8 | 114688 | 4185.3 | 169.8 | 24.6x | 10x | no |
| BlobIndex.hash_tree_root | zero | 8 | 122880 | 4166.7 | 179.7 | 23.2x | 10x | no |
| BlobIndex.serialize | random | 8 | 524288 | 621.8 | 11.7 | 53.2x | 5x | no |
| BlobIndex.serialize | saturated | 8 | 524288 | 637.1 | 11.2 | 57.0x | 5x | no |
| BlobIndex.serialize | zero | 8 | 524288 | 633.2 | 11.0 | 57.5x | 5x | no |
| BlobSidecar.deserialize | large-fixture | 131928 | 50 | 11200000.0 | 12079.2 | 927.2x | 5x | no |
| BlobSidecar.deserialize | medium-fixture | 131928 | 50 | 11060000.0 | 11745.0 | 941.7x | 5x | no |
| BlobSidecar.deserialize | small-fixture | 131928 | 44 | 11090909.1 | 11259.5 | 985.0x | 5x | no |
| BlobSidecar.hash_tree_root | large-fixture | 131928 | 16 | 29875000.0 | 358695.3 | 83.3x | 10x | no |
| BlobSidecar.hash_tree_root | medium-fixture | 131928 | 16 | 29562500.0 | 358041.7 | 82.6x | 10x | no |
| BlobSidecar.hash_tree_root | small-fixture | 131928 | 16 | 29687500.0 | 385302.1 | 77.0x | 10x | no |
| BlobSidecar.serialize | large-fixture | 131928 | 54 | 6185185.2 | 10686.7 | 578.8x | 5x | no |
| BlobSidecar.serialize | medium-fixture | 131928 | 54 | 6203703.7 | 10547.1 | 588.2x | 5x | no |
| BlobSidecar.serialize | small-fixture | 131928 | 54 | 6277777.8 | 10888.9 | 576.5x | 5x | no |
| Bytes1.deserialize | random | 1 | 524288 | 579.8 | 32.3 | 18.0x | 5x | no |
| Bytes1.deserialize | saturated | 1 | 524288 | 566.5 | 30.0 | 18.9x | 5x | no |
| Bytes1.deserialize | zero | 1 | 524288 | 581.7 | 32.0 | 18.2x | 5x | no |
| Bytes1.hash_tree_root | random | 1 | 139264 | 3956.5 | 215.3 | 18.4x | 10x | no |
| Bytes1.hash_tree_root | saturated | 1 | 131072 | 3463.7 | 200.9 | 17.2x | 10x | no |
| Bytes1.hash_tree_root | zero | 1 | 139264 | 3295.9 | 185.6 | 17.8x | 10x | no |
| Bytes1.serialize | random | 1 | 5000000 | 50.8 | 11.3 | 4.5x | 5x | yes |
| Bytes1.serialize | saturated | 1 | 5000000 | 51.2 | 11.2 | 4.6x | 5x | yes |
| Bytes1.serialize | zero | 1 | 5000000 | 49.2 | 11.7 | 4.2x | 5x | yes |
| Bytes20.deserialize | random | 20 | 204800 | 2568.4 | 40.8 | 62.9x | 5x | no |
| Bytes20.deserialize | saturated | 20 | 204800 | 2587.9 | 40.3 | 64.3x | 5x | no |
| Bytes20.deserialize | zero | 20 | 180224 | 2513.5 | 38.0 | 66.2x | 5x | no |
| Bytes20.hash_tree_root | random | 20 | 90112 | 5581.9 | 176.0 | 31.7x | 10x | no |
| Bytes20.hash_tree_root | saturated | 20 | 81920 | 5566.4 | 187.3 | 29.7x | 10x | no |
| Bytes20.hash_tree_root | zero | 20 | 90112 | 5504.3 | 184.6 | 29.8x | 10x | no |
| Bytes20.serialize | random | 20 | 1048576 | 397.7 | 17.0 | 23.3x | 5x | no |
| Bytes20.serialize | saturated | 20 | 1048576 | 402.5 | 16.9 | 23.8x | 5x | no |
| Bytes20.serialize | zero | 20 | 1048576 | 392.9 | 17.1 | 23.0x | 5x | no |
| Bytes32.deserialize | random | 32 | 110592 | 2450.4 | 41.9 | 58.5x | 5x | no |
| Bytes32.deserialize | saturated | 32 | 221184 | 2382.6 | 40.6 | 58.6x | 5x | no |
| Bytes32.deserialize | zero | 32 | 126976 | 2346.9 | 40.7 | 57.6x | 5x | no |
| Bytes32.hash_tree_root | random | 32 | 57344 | 8562.4 | 152.9 | 56.0x | 10x | no |
| Bytes32.hash_tree_root | saturated | 32 | 57344 | 8789.1 | 152.7 | 57.5x | 10x | no |
| Bytes32.hash_tree_root | zero | 32 | 57344 | 8544.9 | 153.7 | 55.6x | 10x | no |
| Bytes32.serialize | random | 32 | 524288 | 644.7 | 17.0 | 37.9x | 5x | no |
| Bytes32.serialize | saturated | 32 | 524288 | 680.9 | 19.2 | 35.4x | 5x | no |
| Bytes32.serialize | zero | 32 | 524288 | 623.7 | 17.2 | 36.3x | 5x | no |
| Bytes4.deserialize | random | 4 | 524288 | 795.4 | 30.1 | 26.4x | 5x | no |
| Bytes4.deserialize | saturated | 4 | 524288 | 814.4 | 31.8 | 25.6x | 5x | no |
| Bytes4.deserialize | zero | 4 | 262144 | 949.9 | 36.7 | 25.9x | 5x | no |
| Bytes4.hash_tree_root | random | 4 | 155648 | 3006.8 | 156.5 | 19.2x | 10x | no |
| Bytes4.hash_tree_root | saturated | 4 | 155648 | 3045.3 | 159.1 | 19.1x | 10x | no |
| Bytes4.hash_tree_root | zero | 4 | 122880 | 3474.9 | 180.8 | 19.2x | 10x | no |
| Bytes4.serialize | random | 4 | 3407872 | 81.3 | 10.5 | 7.7x | 5x | no |
| Bytes4.serialize | saturated | 4 | 5000000 | 83.0 | 11.3 | 7.4x | 5x | no |
| Bytes4.serialize | zero | 4 | 5000000 | 96.2 | 12.6 | 7.6x | 5x | no |
| Bytes48.deserialize | random | 48 | 122880 | 4142.3 | 35.6 | 116.3x | 5x | no |
| Bytes48.deserialize | saturated | 48 | 114688 | 4638.7 | 39.5 | 117.4x | 5x | no |
| Bytes48.deserialize | zero | 48 | 122880 | 4215.5 | 37.0 | 113.8x | 5x | no |
| Bytes48.hash_tree_root | random | 48 | 40960 | 11523.4 | 291.4 | 39.5x | 10x | no |
| Bytes48.hash_tree_root | saturated | 48 | 40960 | 13964.8 | 335.8 | 41.6x | 10x | no |
| Bytes48.hash_tree_root | zero | 48 | 40960 | 10351.6 | 269.6 | 38.4x | 10x | no |
| Bytes48.serialize | random | 48 | 524288 | 770.6 | 16.2 | 47.6x | 5x | no |
| Bytes48.serialize | saturated | 48 | 507904 | 864.3 | 18.0 | 48.0x | 5x | no |
| Bytes48.serialize | zero | 48 | 524288 | 783.9 | 16.8 | 46.6x | 5x | no |
| Bytes8.deserialize | random | 8 | 204800 | 1342.8 | 33.1 | 40.6x | 5x | no |
| Bytes8.deserialize | saturated | 8 | 204800 | 1372.1 | 35.5 | 38.6x | 5x | no |
| Bytes8.deserialize | zero | 8 | 204800 | 1254.9 | 33.2 | 37.8x | 5x | no |
| Bytes8.hash_tree_root | random | 8 | 65536 | 3875.7 | 184.9 | 21.0x | 10x | no |
| Bytes8.hash_tree_root | saturated | 8 | 122880 | 3873.7 | 180.4 | 21.5x | 10x | no |
| Bytes8.hash_tree_root | zero | 8 | 122880 | 3833.0 | 188.4 | 20.3x | 10x | no |
| Bytes8.serialize | random | 8 | 2621440 | 177.4 | 12.5 | 14.2x | 5x | no |
| Bytes8.serialize | saturated | 8 | 2621440 | 169.0 | 11.9 | 14.2x | 5x | no |
| Bytes8.serialize | zero | 8 | 2621440 | 175.5 | 12.1 | 14.5x | 5x | no |
| Bytes96.deserialize | random | 96 | 65536 | 7537.8 | 49.3 | 152.9x | 5x | no |
| Bytes96.deserialize | saturated | 96 | 65536 | 7476.8 | 49.6 | 150.9x | 5x | no |
| Bytes96.deserialize | zero | 96 | 65536 | 7690.4 | 49.5 | 155.2x | 5x | no |
| Bytes96.hash_tree_root | random | 96 | 16384 | 25146.5 | 519.2 | 48.4x | 10x | no |
| Bytes96.hash_tree_root | saturated | 96 | 16384 | 24536.1 | 519.5 | 47.2x | 10x | no |
| Bytes96.hash_tree_root | zero | 96 | 16384 | 25146.5 | 524.5 | 47.9x | 10x | no |
| Bytes96.serialize | random | 96 | 286720 | 1792.7 | 23.8 | 75.3x | 5x | no |
| Bytes96.serialize | saturated | 96 | 253952 | 1756.2 | 22.8 | 77.2x | 5x | no |
| Bytes96.serialize | zero | 96 | 253952 | 1772.0 | 24.2 | 73.3x | 5x | no |
| Cell.deserialize | random | 2048 | 1728 | 153356.5 | 320.1 | 479.0x | 5x | no |
| Cell.deserialize | saturated | 2048 | 3456 | 157118.1 | 306.0 | 513.5x | 5x | no |
| Cell.deserialize | zero | 2048 | 3200 | 158125.0 | 307.6 | 514.1x | 5x | no |
| Cell.hash_tree_root | random | 2048 | 1024 | 457031.2 | 6655.4 | 68.7x | 10x | no |
| Cell.hash_tree_root | saturated | 2048 | 1024 | 472656.2 | 6642.4 | 71.2x | 10x | no |
| Cell.hash_tree_root | zero | 2048 | 1024 | 459960.9 | 6641.4 | 69.3x | 10x | no |
| Cell.serialize | random | 2048 | 8192 | 35644.5 | 226.7 | 157.2x | 5x | no |
| Cell.serialize | saturated | 2048 | 8192 | 36132.8 | 228.1 | 158.4x | 5x | no |
| Cell.serialize | zero | 2048 | 8192 | 42480.5 | 232.0 | 183.1x | 5x | no |
| CellIndex.deserialize | random | 8 | 409600 | 1201.2 | 35.0 | 34.3x | 5x | no |
| CellIndex.deserialize | saturated | 8 | 253952 | 1177.4 | 34.9 | 33.7x | 5x | no |
| CellIndex.deserialize | zero | 8 | 253952 | 1189.2 | 32.7 | 36.4x | 5x | no |
| CellIndex.hash_tree_root | random | 8 | 90112 | 4316.9 | 181.1 | 23.8x | 10x | no |
| CellIndex.hash_tree_root | saturated | 8 | 106496 | 4432.1 | 175.8 | 25.2x | 10x | no |
| CellIndex.hash_tree_root | zero | 8 | 106496 | 4319.4 | 185.8 | 23.2x | 10x | no |
| CellIndex.serialize | random | 8 | 524288 | 722.9 | 12.4 | 58.1x | 5x | no |
| CellIndex.serialize | saturated | 8 | 524288 | 642.8 | 11.5 | 56.0x | 5x | no |
| CellIndex.serialize | zero | 8 | 524288 | 671.4 | 12.3 | 54.7x | 5x | no |
| Checkpoint.deserialize | large-fixture | 40 | 122880 | 4321.3 | 16.8 | 257.3x | 5x | no |
| Checkpoint.deserialize | medium-fixture | 40 | 114688 | 4316.1 | 17.1 | 252.6x | 5x | no |
| Checkpoint.deserialize | small-fixture | 40 | 61440 | 4085.3 | 15.2 | 269.6x | 5x | no |
| Checkpoint.hash_tree_root | large-fixture | 40 | 16384 | 22583.0 | 141.8 | 159.2x | 10x | no |
| Checkpoint.hash_tree_root | medium-fixture | 40 | 16384 | 22338.9 | 142.1 | 157.2x | 10x | no |
| Checkpoint.hash_tree_root | small-fixture | 40 | 16384 | 22888.2 | 142.3 | 160.8x | 10x | no |
| Checkpoint.serialize | large-fixture | 40 | 90112 | 2763.2 | 20.2 | 136.9x | 5x | no |
| Checkpoint.serialize | medium-fixture | 40 | 163840 | 3057.9 | 24.5 | 124.7x | 5x | no |
| Checkpoint.serialize | small-fixture | 40 | 180224 | 2802.1 | 20.1 | 139.4x | 5x | no |
| ColumnIndex.deserialize | random | 8 | 253952 | 1169.5 | 32.6 | 35.9x | 5x | no |
| ColumnIndex.deserialize | saturated | 8 | 409600 | 1174.3 | 34.4 | 34.1x | 5x | no |
| ColumnIndex.deserialize | zero | 8 | 409600 | 1264.6 | 35.7 | 35.4x | 5x | no |
| ColumnIndex.hash_tree_root | random | 8 | 106496 | 4328.8 | 180.1 | 24.0x | 10x | no |
| ColumnIndex.hash_tree_root | saturated | 8 | 114688 | 4333.5 | 172.4 | 25.1x | 10x | no |
| ColumnIndex.hash_tree_root | zero | 8 | 98304 | 4333.5 | 183.5 | 23.6x | 10x | no |
| ColumnIndex.serialize | random | 8 | 524288 | 671.4 | 12.3 | 54.5x | 5x | no |
| ColumnIndex.serialize | saturated | 8 | 524288 | 659.9 | 11.1 | 59.2x | 5x | no |
| ColumnIndex.serialize | zero | 8 | 524288 | 709.5 | 12.6 | 56.4x | 5x | no |
| CommitmentIndex.deserialize | random | 8 | 409600 | 1186.5 | 34.7 | 34.2x | 5x | no |
| CommitmentIndex.deserialize | saturated | 8 | 253952 | 1216.8 | 35.4 | 34.4x | 5x | no |
| CommitmentIndex.deserialize | zero | 8 | 253952 | 1177.4 | 33.3 | 35.4x | 5x | no |
| CommitmentIndex.hash_tree_root | random | 8 | 106496 | 4328.8 | 180.3 | 24.0x | 10x | no |
| CommitmentIndex.hash_tree_root | saturated | 8 | 106496 | 4328.8 | 177.8 | 24.3x | 10x | no |
| CommitmentIndex.hash_tree_root | zero | 8 | 106496 | 4319.4 | 176.7 | 24.4x | 10x | no |
| CommitmentIndex.serialize | random | 8 | 524288 | 658.0 | 12.2 | 53.9x | 5x | no |
| CommitmentIndex.serialize | saturated | 8 | 524288 | 772.5 | 14.0 | 55.2x | 5x | no |
| CommitmentIndex.serialize | zero | 8 | 524288 | 652.3 | 11.4 | 57.3x | 5x | no |
| CommitteeIndex.deserialize | random | 8 | 253952 | 1173.5 | 35.1 | 33.4x | 5x | no |
| CommitteeIndex.deserialize | saturated | 8 | 409600 | 1240.2 | 38.6 | 32.1x | 5x | no |
| CommitteeIndex.deserialize | zero | 8 | 253952 | 1181.3 | 35.4 | 33.4x | 5x | no |
| CommitteeIndex.hash_tree_root | random | 8 | 106496 | 4375.8 | 192.5 | 22.7x | 10x | no |
| CommitteeIndex.hash_tree_root | saturated | 8 | 114688 | 4237.6 | 174.9 | 24.2x | 10x | no |
| CommitteeIndex.hash_tree_root | zero | 8 | 106496 | 4450.9 | 181.8 | 24.5x | 10x | no |
| CommitteeIndex.serialize | random | 8 | 524288 | 665.7 | 10.8 | 61.7x | 5x | no |
| CommitteeIndex.serialize | saturated | 8 | 524288 | 640.9 | 11.1 | 57.8x | 5x | no |
| CommitteeIndex.serialize | zero | 8 | 524288 | 673.3 | 12.3 | 54.5x | 5x | no |
| ConsolidationRequest.deserialize | large-fixture | 116 | 40960 | 12207.0 | 29.4 | 415.5x | 5x | no |
| ConsolidationRequest.deserialize | medium-fixture | 116 | 40960 | 12011.7 | 31.8 | 377.9x | 5x | no |
| ConsolidationRequest.deserialize | small-fixture | 116 | 40960 | 11059.6 | 27.2 | 407.0x | 5x | no |
| ConsolidationRequest.hash_tree_root | large-fixture | 116 | 8192 | 48706.1 | 606.4 | 80.3x | 10x | no |
| ConsolidationRequest.hash_tree_root | medium-fixture | 116 | 8192 | 47973.6 | 606.9 | 79.0x | 10x | no |
| ConsolidationRequest.hash_tree_root | small-fixture | 116 | 8192 | 47607.4 | 604.8 | 78.7x | 10x | no |
| ConsolidationRequest.serialize | large-fixture | 116 | 65536 | 7049.6 | 28.7 | 245.8x | 5x | no |
| ConsolidationRequest.serialize | medium-fixture | 116 | 65536 | 7049.6 | 28.4 | 248.0x | 5x | no |
| ConsolidationRequest.serialize | small-fixture | 116 | 73728 | 6401.9 | 27.4 | 234.0x | 5x | no |
| ContributionAndProof.deserialize | large-fixture | 264 | 24576 | 18961.6 | 65.2 | 290.7x | 5x | no |
| ContributionAndProof.deserialize | medium-fixture | 264 | 16384 | 26611.3 | 86.2 | 308.7x | 5x | no |
| ContributionAndProof.deserialize | small-fixture | 264 | 8192 | 32714.8 | 94.7 | 345.6x | 5x | no |
| ContributionAndProof.hash_tree_root | large-fixture | 264 | 3200 | 81250.0 | 1086.0 | 74.8x | 10x | no |
| ContributionAndProof.hash_tree_root | medium-fixture | 264 | 5248 | 80983.2 | 1078.3 | 75.1x | 10x | no |
| ContributionAndProof.hash_tree_root | small-fixture | 264 | 4480 | 109151.8 | 1504.1 | 72.6x | 10x | no |
| ContributionAndProof.serialize | large-fixture | 264 | 24576 | 17211.9 | 38.2 | 450.5x | 5x | no |
| ContributionAndProof.serialize | medium-fixture | 264 | 24576 | 16886.4 | 37.8 | 446.5x | 5x | no |
| ContributionAndProof.serialize | small-fixture | 264 | 16384 | 21606.4 | 51.8 | 417.1x | 5x | no |
| CurrentSyncCommitteeBranch.deserialize | random | 192 | 40960 | 11792.0 | 44.7 | 263.8x | 5x | no |
| CurrentSyncCommitteeBranch.deserialize | saturated | 192 | 40960 | 11792.0 | 46.1 | 256.0x | 5x | no |
| CurrentSyncCommitteeBranch.deserialize | zero | 192 | 40960 | 11645.5 | 45.5 | 256.0x | 5x | no |
| CurrentSyncCommitteeBranch.hash_tree_root | random | 192 | 8192 | 35644.5 | 603.3 | 59.1x | 10x | no |
| CurrentSyncCommitteeBranch.hash_tree_root | saturated | 192 | 8192 | 35034.2 | 602.1 | 58.2x | 10x | no |
| CurrentSyncCommitteeBranch.hash_tree_root | zero | 192 | 8192 | 35156.2 | 598.1 | 58.8x | 10x | no |
| CurrentSyncCommitteeBranch.serialize | random | 192 | 57344 | 7603.2 | 25.2 | 301.8x | 5x | no |
| CurrentSyncCommitteeBranch.serialize | saturated | 192 | 57344 | 7550.9 | 24.5 | 308.7x | 5x | no |
| CurrentSyncCommitteeBranch.serialize | zero | 192 | 57344 | 7568.4 | 24.8 | 305.7x | 5x | no |
| CustodyIndex.deserialize | random | 8 | 524288 | 1064.3 | 30.4 | 35.0x | 5x | no |
| CustodyIndex.deserialize | saturated | 8 | 524288 | 896.5 | 26.0 | 34.5x | 5x | no |
| CustodyIndex.deserialize | zero | 8 | 524288 | 877.4 | 26.5 | 33.1x | 5x | no |
| CustodyIndex.hash_tree_root | random | 8 | 155648 | 3148.1 | 132.8 | 23.7x | 10x | no |
| CustodyIndex.hash_tree_root | saturated | 8 | 139264 | 3231.3 | 140.1 | 23.1x | 10x | no |
| CustodyIndex.hash_tree_root | zero | 8 | 139264 | 3418.0 | 154.1 | 22.2x | 10x | no |
| CustodyIndex.serialize | random | 8 | 524288 | 488.3 | 8.9 | 55.1x | 5x | no |
| CustodyIndex.serialize | saturated | 8 | 524288 | 501.6 | 9.1 | 55.0x | 5x | no |
| CustodyIndex.serialize | zero | 8 | 524288 | 499.7 | 9.0 | 55.8x | 5x | no |
| DataColumnSidecar.deserialize | large-fixture | 19076 | 384 | 1200520.8 | 2545.0 | 471.7x | 5x | no |
| DataColumnSidecar.deserialize | medium-fixture | 17028 | 256 | 1023437.5 | 2471.4 | 414.1x | 5x | no |
| DataColumnSidecar.deserialize | small-fixture | 6500 | 1280 | 399218.8 | 874.3 | 456.6x | 5x | no |
| DataColumnSidecar.hash_tree_root | large-fixture | 19076 | 128 | 3390625.0 | 45565.1 | 74.4x | 10x | no |
| DataColumnSidecar.hash_tree_root | medium-fixture | 17028 | 128 | 3054687.5 | 40973.3 | 74.6x | 10x | no |
| DataColumnSidecar.hash_tree_root | small-fixture | 6500 | 384 | 1205729.2 | 16570.3 | 72.8x | 10x | no |
| DataColumnSidecar.serialize | large-fixture | 19076 | 256 | 1289062.5 | 1727.2 | 746.3x | 5x | no |
| DataColumnSidecar.serialize | medium-fixture | 17028 | 384 | 1148437.5 | 1314.2 | 873.8x | 5x | no |
| DataColumnSidecar.serialize | small-fixture | 6500 | 1024 | 431640.6 | 516.3 | 836.0x | 5x | no |
| DataColumnsByRootIdentifier.deserialize | large-fixture | 92 | 65536 | 7919.3 | 59.2 | 133.9x | 5x | no |
| DataColumnsByRootIdentifier.deserialize | medium-fixture | 60 | 98304 | 5198.2 | 53.7 | 96.9x | 5x | no |
| DataColumnsByRootIdentifier.deserialize | small-fixture | 36 | 90112 | 2885.3 | 33.2 | 86.8x | 5x | no |
| DataColumnsByRootIdentifier.hash_tree_root | large-fixture | 92 | 8192 | 39428.7 | 567.4 | 69.5x | 10x | no |
| DataColumnsByRootIdentifier.hash_tree_root | medium-fixture | 60 | 8192 | 31738.3 | 558.7 | 56.8x | 10x | no |
| DataColumnsByRootIdentifier.hash_tree_root | small-fixture | 36 | 24576 | 19816.1 | 188.8 | 105.0x | 10x | no |
| DataColumnsByRootIdentifier.serialize | large-fixture | 92 | 49152 | 7975.3 | 22.8 | 350.1x | 5x | no |
| DataColumnsByRootIdentifier.serialize | medium-fixture | 60 | 53248 | 4657.5 | 18.3 | 254.9x | 5x | no |
| DataColumnsByRootIdentifier.serialize | small-fixture | 36 | 286720 | 1639.2 | 16.6 | 98.8x | 5x | no |
| Deposit.deserialize | large-fixture | 1240 | 6400 | 83437.5 | 716.0 | 116.5x | 5x | no |
| Deposit.deserialize | medium-fixture | 1240 | 6400 | 83593.8 | 701.5 | 119.2x | 5x | no |
| Deposit.deserialize | small-fixture | 1240 | 6400 | 81562.5 | 711.2 | 114.7x | 5x | no |
| Deposit.hash_tree_root | large-fixture | 1240 | 1792 | 260602.7 | 3516.7 | 74.1x | 10x | no |
| Deposit.hash_tree_root | medium-fixture | 1240 | 1920 | 259895.8 | 3512.8 | 74.0x | 10x | no |
| Deposit.hash_tree_root | small-fixture | 1240 | 2048 | 257812.5 | 3516.6 | 73.3x | 10x | no |
| Deposit.serialize | large-fixture | 1240 | 4480 | 88616.1 | 154.9 | 571.9x | 5x | no |
| Deposit.serialize | medium-fixture | 1240 | 5248 | 82507.6 | 147.5 | 559.2x | 5x | no |
| Deposit.serialize | small-fixture | 1240 | 4480 | 82812.5 | 151.5 | 546.8x | 5x | no |
| DepositData.deserialize | large-fixture | 184 | 32768 | 13610.8 | 48.8 | 278.7x | 5x | no |
| DepositData.deserialize | medium-fixture | 184 | 40960 | 14428.7 | 50.1 | 288.1x | 5x | no |
| DepositData.deserialize | small-fixture | 184 | 40960 | 12915.0 | 45.8 | 282.2x | 5x | no |
| DepositData.hash_tree_root | large-fixture | 184 | 8192 | 48828.1 | 563.3 | 86.7x | 10x | no |
| DepositData.hash_tree_root | medium-fixture | 184 | 7936 | 48765.1 | 563.3 | 86.6x | 10x | no |
| DepositData.hash_tree_root | small-fixture | 184 | 8192 | 49804.7 | 564.1 | 88.3x | 10x | no |
| DepositData.serialize | large-fixture | 184 | 40960 | 8398.4 | 29.7 | 282.6x | 5x | no |
| DepositData.serialize | medium-fixture | 184 | 49152 | 8422.9 | 29.0 | 290.9x | 5x | no |
| DepositData.serialize | small-fixture | 184 | 49152 | 8056.6 | 28.5 | 282.8x | 5x | no |
| DepositMessage.deserialize | large-fixture | 88 | 73728 | 7025.8 | 35.6 | 197.2x | 5x | no |
| DepositMessage.deserialize | medium-fixture | 88 | 40960 | 6543.0 | 33.8 | 193.6x | 5x | no |
| DepositMessage.deserialize | small-fixture | 88 | 40960 | 6689.5 | 34.8 | 192.1x | 5x | no |
| DepositMessage.hash_tree_root | large-fixture | 88 | 16384 | 30090.3 | 339.2 | 88.7x | 10x | no |
| DepositMessage.hash_tree_root | medium-fixture | 88 | 16384 | 30334.5 | 338.9 | 89.5x | 10x | no |
| DepositMessage.hash_tree_root | small-fixture | 88 | 16384 | 29968.3 | 338.4 | 88.6x | 10x | no |
| DepositMessage.serialize | large-fixture | 88 | 106496 | 4216.1 | 20.5 | 205.2x | 5x | no |
| DepositMessage.serialize | medium-fixture | 88 | 114688 | 4115.5 | 19.9 | 206.4x | 5x | no |
| DepositMessage.serialize | small-fixture | 88 | 106496 | 4216.1 | 19.9 | 211.4x | 5x | no |
| DepositRequest.deserialize | large-fixture | 192 | 16384 | 23437.5 | 93.6 | 250.3x | 5x | no |
| DepositRequest.deserialize | medium-fixture | 192 | 16384 | 21179.2 | 84.4 | 250.9x | 5x | no |
| DepositRequest.deserialize | small-fixture | 192 | 40960 | 12573.2 | 47.5 | 264.6x | 5x | no |
| DepositRequest.hash_tree_root | large-fixture | 192 | 3968 | 103830.6 | 1622.2 | 64.0x | 10x | no |
| DepositRequest.hash_tree_root | medium-fixture | 192 | 5248 | 114519.8 | 1624.3 | 70.5x | 10x | no |
| DepositRequest.hash_tree_root | small-fixture | 192 | 5248 | 120998.5 | 1601.2 | 75.6x | 10x | no |
| DepositRequest.serialize | large-fixture | 192 | 24576 | 18717.4 | 61.9 | 302.2x | 5x | no |
| DepositRequest.serialize | medium-fixture | 192 | 24576 | 14404.3 | 48.5 | 297.0x | 5x | no |
| DepositRequest.serialize | small-fixture | 192 | 49152 | 9033.2 | 28.2 | 320.3x | 5x | no |
| Domain.deserialize | random | 32 | 90112 | 2940.8 | 51.8 | 56.8x | 5x | no |
| Domain.deserialize | saturated | 32 | 77824 | 2736.9 | 47.4 | 57.8x | 5x | no |
| Domain.deserialize | zero | 32 | 131072 | 3028.9 | 46.6 | 65.1x | 5x | no |
| Domain.hash_tree_root | random | 32 | 40960 | 10717.8 | 203.1 | 52.8x | 10x | no |
| Domain.hash_tree_root | saturated | 32 | 32768 | 11016.8 | 222.9 | 49.4x | 10x | no |
| Domain.hash_tree_root | zero | 32 | 32768 | 10772.7 | 204.6 | 52.7x | 10x | no |
| Domain.serialize | random | 32 | 507904 | 834.8 | 25.8 | 32.4x | 5x | no |
| Domain.serialize | saturated | 32 | 524288 | 860.2 | 26.6 | 32.3x | 5x | no |
| Domain.serialize | zero | 32 | 507904 | 962.8 | 26.2 | 36.7x | 5x | no |
| DomainType.deserialize | random | 4 | 167936 | 1560.1 | 55.0 | 28.4x | 5x | no |
| DomainType.deserialize | saturated | 4 | 253952 | 1086.8 | 42.7 | 25.5x | 5x | no |
| DomainType.deserialize | zero | 4 | 253952 | 1169.5 | 54.2 | 21.6x | 5x | no |
| DomainType.hash_tree_root | random | 4 | 98304 | 4536.9 | 278.9 | 16.3x | 10x | no |
| DomainType.hash_tree_root | saturated | 4 | 98304 | 5055.7 | 316.5 | 16.0x | 10x | no |
| DomainType.hash_tree_root | zero | 4 | 114688 | 4577.6 | 214.5 | 21.3x | 10x | no |
| DomainType.serialize | random | 4 | 2621440 | 155.3 | 18.9 | 8.2x | 5x | no |
| DomainType.serialize | saturated | 4 | 4194304 | 142.6 | 18.0 | 7.9x | 5x | no |
| DomainType.serialize | zero | 4 | 2097152 | 116.3 | 15.7 | 7.4x | 5x | no |
| Epoch.deserialize | random | 8 | 335872 | 1554.2 | 44.4 | 35.0x | 5x | no |
| Epoch.deserialize | saturated | 8 | 204800 | 1596.7 | 46.3 | 34.5x | 5x | no |
| Epoch.deserialize | zero | 8 | 143360 | 1402.1 | 41.7 | 33.6x | 5x | no |
| Epoch.hash_tree_root | random | 8 | 81920 | 5297.9 | 211.2 | 25.1x | 10x | no |
| Epoch.hash_tree_root | saturated | 8 | 81920 | 5310.1 | 214.0 | 24.8x | 10x | no |
| Epoch.hash_tree_root | zero | 8 | 65536 | 5447.4 | 228.5 | 23.8x | 10x | no |
| Epoch.serialize | random | 8 | 253952 | 1012.0 | 16.6 | 61.0x | 5x | no |
| Epoch.serialize | saturated | 8 | 507904 | 921.4 | 16.2 | 56.9x | 5x | no |
| Epoch.serialize | zero | 8 | 507904 | 1012.0 | 17.3 | 58.6x | 5x | no |
| Eth1Block.deserialize | large-fixture | 48 | 73728 | 7649.7 | 50.6 | 151.2x | 5x | no |
| Eth1Block.deserialize | medium-fixture | 48 | 65536 | 7049.6 | 48.4 | 145.6x | 5x | no |
| Eth1Block.deserialize | small-fixture | 48 | 32768 | 8453.4 | 45.2 | 187.1x | 5x | no |
| Eth1Block.hash_tree_root | large-fixture | 48 | 8192 | 31982.4 | 310.6 | 103.0x | 10x | no |
| Eth1Block.hash_tree_root | medium-fixture | 48 | 8192 | 46875.0 | 460.6 | 101.8x | 10x | no |
| Eth1Block.hash_tree_root | small-fixture | 48 | 8192 | 48706.1 | 457.4 | 106.5x | 10x | no |
| Eth1Block.serialize | large-fixture | 48 | 98304 | 5574.5 | 27.2 | 205.1x | 5x | no |
| Eth1Block.serialize | medium-fixture | 48 | 73728 | 4964.2 | 25.2 | 197.2x | 5x | no |
| Eth1Block.serialize | small-fixture | 48 | 40960 | 6103.5 | 25.8 | 236.7x | 5x | no |
| Eth1Data.deserialize | large-fixture | 72 | 90112 | 5637.4 | 44.8 | 125.9x | 5x | no |
| Eth1Data.deserialize | medium-fixture | 72 | 81920 | 5932.6 | 48.7 | 121.8x | 5x | no |
| Eth1Data.deserialize | small-fixture | 72 | 45056 | 5459.9 | 39.9 | 136.7x | 5x | no |
| Eth1Data.hash_tree_root | large-fixture | 72 | 16384 | 27526.9 | 258.3 | 106.6x | 10x | no |
| Eth1Data.hash_tree_root | medium-fixture | 72 | 16384 | 26977.5 | 250.6 | 107.7x | 10x | no |
| Eth1Data.hash_tree_root | small-fixture | 72 | 16384 | 28808.6 | 268.0 | 107.5x | 10x | no |
| Eth1Data.serialize | large-fixture | 72 | 114688 | 3836.5 | 18.1 | 212.3x | 5x | no |
| Eth1Data.serialize | medium-fixture | 72 | 49152 | 4435.2 | 21.9 | 202.6x | 5x | no |
| Eth1Data.serialize | small-fixture | 72 | 131072 | 3631.6 | 18.3 | 198.0x | 5x | no |
| Ether.deserialize | random | 8 | 524288 | 888.8 | 26.9 | 33.1x | 5x | no |
| Ether.deserialize | saturated | 8 | 507904 | 882.1 | 25.5 | 34.6x | 5x | no |
| Ether.deserialize | zero | 8 | 524288 | 944.1 | 28.2 | 33.5x | 5x | no |
| Ether.hash_tree_root | random | 8 | 139264 | 3267.2 | 144.9 | 22.6x | 10x | no |
| Ether.hash_tree_root | saturated | 8 | 53248 | 5352.3 | 211.6 | 25.3x | 10x | no |
| Ether.hash_tree_root | zero | 8 | 139264 | 3260.0 | 141.4 | 23.1x | 10x | no |
| Ether.serialize | random | 8 | 524288 | 513.1 | 9.3 | 55.2x | 5x | no |
| Ether.serialize | saturated | 8 | 524288 | 509.3 | 9.2 | 55.5x | 5x | no |
| Ether.serialize | zero | 8 | 524288 | 522.6 | 9.5 | 54.8x | 5x | no |
| ExecutionAddress.deserialize | random | 20 | 90112 | 3018.5 | 45.9 | 65.8x | 5x | no |
| ExecutionAddress.deserialize | saturated | 20 | 155648 | 3340.9 | 46.6 | 71.7x | 5x | no |
| ExecutionAddress.deserialize | zero | 20 | 69632 | 3231.3 | 47.3 | 68.3x | 5x | no |
| ExecutionAddress.hash_tree_root | random | 20 | 57344 | 6940.6 | 223.0 | 31.1x | 10x | no |
| ExecutionAddress.hash_tree_root | saturated | 20 | 65536 | 6424.0 | 197.2 | 32.6x | 10x | no |
| ExecutionAddress.hash_tree_root | zero | 20 | 65536 | 7186.9 | 246.5 | 29.2x | 10x | no |
| ExecutionAddress.serialize | random | 20 | 524288 | 513.1 | 22.5 | 22.8x | 5x | no |
| ExecutionAddress.serialize | saturated | 20 | 524288 | 488.3 | 20.2 | 24.2x | 5x | no |
| ExecutionAddress.serialize | zero | 20 | 524288 | 486.4 | 19.9 | 24.4x | 5x | no |
| ExecutionBranch.deserialize | random | 128 | 40960 | 11792.0 | 58.7 | 200.7x | 5x | no |
| ExecutionBranch.deserialize | saturated | 128 | 40960 | 11865.2 | 59.9 | 197.9x | 5x | no |
| ExecutionBranch.deserialize | zero | 128 | 24576 | 11108.4 | 54.1 | 205.4x | 5x | no |
| ExecutionBranch.hash_tree_root | random | 128 | 8192 | 35888.7 | 574.7 | 62.4x | 10x | no |
| ExecutionBranch.hash_tree_root | saturated | 128 | 8192 | 35888.7 | 575.1 | 62.4x | 10x | no |
| ExecutionBranch.hash_tree_root | zero | 128 | 8192 | 36132.8 | 575.6 | 62.8x | 10x | no |
| ExecutionBranch.serialize | random | 128 | 32768 | 7629.4 | 31.4 | 242.8x | 5x | no |
| ExecutionBranch.serialize | saturated | 128 | 57344 | 7585.8 | 28.5 | 266.1x | 5x | no |
| ExecutionBranch.serialize | zero | 128 | 57344 | 7341.7 | 28.8 | 255.2x | 5x | no |
| ExecutionPayload.deserialize | large-fixture | 4033 | 1408 | 351562.5 | 960.3 | 366.1x | 5x | no |
| ExecutionPayload.deserialize | medium-fixture | 2445 | 1216 | 213815.8 | 678.9 | 315.0x | 5x | no |
| ExecutionPayload.deserialize | small-fixture | 1921 | 1600 | 169375.0 | 460.1 | 368.2x | 5x | no |
| ExecutionPayload.hash_tree_root | large-fixture | 4033 | 50 | 5180000.0 | 33452.5 | 154.8x | 10x | no |
| ExecutionPayload.hash_tree_root | medium-fixture | 2445 | 128 | 2726562.5 | 20975.9 | 130.0x | 10x | no |
| ExecutionPayload.hash_tree_root | small-fixture | 1921 | 128 | 2156250.0 | 17480.1 | 123.4x | 10x | no |
| ExecutionPayload.serialize | large-fixture | 4033 | 1152 | 399305.6 | 627.6 | 636.2x | 5x | no |
| ExecutionPayload.serialize | medium-fixture | 2445 | 1664 | 256610.6 | 497.6 | 515.6x | 5x | no |
| ExecutionPayload.serialize | small-fixture | 1921 | 2432 | 179687.5 | 343.7 | 522.8x | 5x | no |
| ExecutionPayloadHeader.deserialize | large-fixture | 604 | 8192 | 54443.4 | 138.3 | 393.8x | 5x | no |
| ExecutionPayloadHeader.deserialize | medium-fixture | 594 | 8192 | 63842.8 | 161.7 | 394.9x | 5x | no |
| ExecutionPayloadHeader.deserialize | small-fixture | 590 | 8192 | 59082.0 | 143.9 | 410.6x | 5x | no |
| ExecutionPayloadHeader.hash_tree_root | large-fixture | 604 | 2560 | 194140.6 | 2755.6 | 70.5x | 10x | no |
| ExecutionPayloadHeader.hash_tree_root | medium-fixture | 594 | 2432 | 212171.1 | 2927.2 | 72.5x | 10x | no |
| ExecutionPayloadHeader.hash_tree_root | small-fixture | 590 | 2176 | 221507.4 | 3023.6 | 73.3x | 10x | no |
| ExecutionPayloadHeader.serialize | large-fixture | 604 | 8192 | 39672.9 | 115.7 | 342.8x | 5x | no |
| ExecutionPayloadHeader.serialize | medium-fixture | 594 | 8192 | 41626.0 | 122.3 | 340.4x | 5x | no |
| ExecutionPayloadHeader.serialize | small-fixture | 590 | 8192 | 43823.2 | 129.6 | 338.1x | 5x | no |
| ExecutionRequests.deserialize | large-fixture | 1624 | 1984 | 142137.1 | 628.7 | 226.1x | 5x | no |
| ExecutionRequests.deserialize | medium-fixture | 1004 | 5248 | 88224.1 | 342.5 | 257.6x | 5x | no |
| ExecutionRequests.deserialize | small-fixture | 396 | 8192 | 36010.7 | 186.1 | 193.5x | 5x | no |
| ExecutionRequests.hash_tree_root | large-fixture | 1624 | 896 | 493303.6 | 10095.7 | 48.9x | 10x | no |
| ExecutionRequests.hash_tree_root | medium-fixture | 1004 | 1536 | 341145.8 | 6923.4 | 49.3x | 10x | no |
| ExecutionRequests.hash_tree_root | small-fixture | 396 | 1408 | 176136.4 | 3825.6 | 46.0x | 10x | no |
| ExecutionRequests.serialize | large-fixture | 1624 | 1920 | 216666.7 | 254.1 | 852.7x | 5x | no |
| ExecutionRequests.serialize | medium-fixture | 1004 | 3456 | 124131.9 | 153.2 | 810.1x | 5x | no |
| ExecutionRequests.serialize | small-fixture | 396 | 7936 | 51033.3 | 76.5 | 667.3x | 5x | no |
| FinalityBranch.deserialize | random | 224 | 16384 | 15930.2 | 59.1 | 269.4x | 5x | no |
| FinalityBranch.deserialize | saturated | 224 | 16384 | 19836.4 | 71.1 | 279.1x | 5x | no |
| FinalityBranch.deserialize | zero | 224 | 32768 | 15838.6 | 55.2 | 287.2x | 5x | no |
| FinalityBranch.hash_tree_root | random | 224 | 8192 | 50903.3 | 828.3 | 61.5x | 10x | no |
| FinalityBranch.hash_tree_root | saturated | 224 | 8192 | 50415.0 | 821.1 | 61.4x | 10x | no |
| FinalityBranch.hash_tree_root | zero | 224 | 8192 | 50659.2 | 830.4 | 61.0x | 10x | no |
| FinalityBranch.serialize | random | 224 | 40960 | 10473.6 | 31.9 | 328.7x | 5x | no |
| FinalityBranch.serialize | saturated | 224 | 40960 | 10131.8 | 31.9 | 317.1x | 5x | no |
| FinalityBranch.serialize | zero | 224 | 40960 | 10302.7 | 32.6 | 316.5x | 5x | no |
| Fork.deserialize | large-fixture | 16 | 90112 | 2951.9 | 13.4 | 221.1x | 5x | no |
| Fork.deserialize | medium-fixture | 16 | 180224 | 2896.4 | 13.3 | 218.2x | 5x | no |
| Fork.deserialize | small-fixture | 16 | 204800 | 2485.4 | 11.0 | 225.1x | 5x | no |
| Fork.hash_tree_root | large-fixture | 16 | 16384 | 26794.4 | 369.3 | 72.6x | 10x | no |
| Fork.hash_tree_root | medium-fixture | 16 | 16384 | 26184.1 | 340.8 | 76.8x | 10x | no |
| Fork.hash_tree_root | small-fixture | 16 | 16384 | 25695.8 | 340.1 | 75.5x | 10x | no |
| Fork.serialize | large-fixture | 16 | 167936 | 1798.3 | 17.9 | 100.5x | 5x | no |
| Fork.serialize | medium-fixture | 16 | 286720 | 1691.5 | 18.5 | 91.3x | 5x | no |
| Fork.serialize | small-fixture | 16 | 335872 | 1491.6 | 15.9 | 93.9x | 5x | no |
| ForkData.deserialize | large-fixture | 36 | 65536 | 3967.3 | 15.4 | 257.4x | 5x | no |
| ForkData.deserialize | medium-fixture | 36 | 122880 | 4052.7 | 18.0 | 224.8x | 5x | no |
| ForkData.deserialize | small-fixture | 36 | 122880 | 4500.3 | 20.6 | 218.9x | 5x | no |
| ForkData.hash_tree_root | large-fixture | 36 | 16384 | 22827.1 | 159.0 | 143.5x | 10x | no |
| ForkData.hash_tree_root | medium-fixture | 36 | 16384 | 22094.7 | 145.1 | 152.3x | 10x | no |
| ForkData.hash_tree_root | small-fixture | 36 | 16384 | 22644.0 | 158.9 | 142.5x | 10x | no |
| ForkData.serialize | large-fixture | 36 | 126976 | 2142.1 | 18.8 | 113.7x | 5x | no |
| ForkData.serialize | medium-fixture | 36 | 110592 | 2179.2 | 21.3 | 102.1x | 5x | no |
| ForkData.serialize | small-fixture | 36 | 102400 | 2363.3 | 21.9 | 108.0x | 5x | no |
| ForkDigest.deserialize | random | 4 | 507904 | 939.2 | 35.1 | 26.7x | 5x | no |
| ForkDigest.deserialize | saturated | 4 | 507904 | 941.1 | 33.7 | 27.9x | 5x | no |
| ForkDigest.deserialize | zero | 4 | 507904 | 978.5 | 41.6 | 23.5x | 5x | no |
| ForkDigest.hash_tree_root | random | 4 | 131072 | 3509.5 | 187.9 | 18.7x | 10x | no |
| ForkDigest.hash_tree_root | saturated | 4 | 69632 | 3475.4 | 179.1 | 19.4x | 10x | no |
| ForkDigest.hash_tree_root | zero | 4 | 65536 | 3494.3 | 182.7 | 19.1x | 10x | no |
| ForkDigest.serialize | random | 4 | 5000000 | 98.8 | 12.6 | 7.8x | 5x | no |
| ForkDigest.serialize | saturated | 4 | 5000000 | 95.4 | 12.3 | 7.8x | 5x | no |
| ForkDigest.serialize | zero | 4 | 4194304 | 98.5 | 12.5 | 7.9x | 5x | no |
| G1Point.deserialize | random | 48 | 53248 | 4788.9 | 38.0 | 126.1x | 5x | no |
| G1Point.deserialize | saturated | 48 | 90112 | 4760.7 | 40.2 | 118.3x | 5x | no |
| G1Point.deserialize | zero | 48 | 106496 | 4798.3 | 42.9 | 112.0x | 5x | no |
| G1Point.hash_tree_root | random | 48 | 40960 | 12060.5 | 327.1 | 36.9x | 10x | no |
| G1Point.hash_tree_root | saturated | 48 | 20480 | 12011.7 | 299.3 | 40.1x | 10x | no |
| G1Point.hash_tree_root | zero | 48 | 40960 | 12060.5 | 315.1 | 38.3x | 10x | no |
| G1Point.serialize | random | 48 | 507904 | 909.6 | 20.0 | 45.6x | 5x | no |
| G1Point.serialize | saturated | 48 | 524288 | 915.5 | 18.6 | 49.1x | 5x | no |
| G1Point.serialize | zero | 48 | 524288 | 909.8 | 18.6 | 48.9x | 5x | no |
| G2Point.deserialize | random | 96 | 65536 | 7309.0 | 45.8 | 159.6x | 5x | no |
| G2Point.deserialize | saturated | 96 | 65536 | 7339.5 | 49.3 | 149.0x | 5x | no |
| G2Point.deserialize | zero | 96 | 65536 | 7522.6 | 49.6 | 151.6x | 5x | no |
| G2Point.hash_tree_root | random | 96 | 16384 | 24841.3 | 524.5 | 47.4x | 10x | no |
| G2Point.hash_tree_root | saturated | 96 | 16384 | 24536.1 | 519.6 | 47.2x | 10x | no |
| G2Point.hash_tree_root | zero | 96 | 16384 | 28137.2 | 571.5 | 49.2x | 10x | no |
| G2Point.serialize | random | 96 | 143360 | 1736.9 | 23.2 | 75.0x | 5x | no |
| G2Point.serialize | saturated | 96 | 286720 | 1740.4 | 22.9 | 75.8x | 5x | no |
| G2Point.serialize | zero | 96 | 253952 | 1732.6 | 23.1 | 75.1x | 5x | no |
| Gwei.deserialize | random | 8 | 253952 | 1177.4 | 33.0 | 35.7x | 5x | no |
| Gwei.deserialize | saturated | 8 | 253952 | 1177.4 | 35.0 | 33.6x | 5x | no |
| Gwei.deserialize | zero | 8 | 409600 | 1196.3 | 35.5 | 33.7x | 5x | no |
| Gwei.hash_tree_root | random | 8 | 106496 | 4385.1 | 176.1 | 24.9x | 10x | no |
| Gwei.hash_tree_root | saturated | 8 | 106496 | 4413.3 | 176.5 | 25.0x | 10x | no |
| Gwei.hash_tree_root | zero | 8 | 106496 | 4357.0 | 183.3 | 23.8x | 10x | no |
| Gwei.serialize | random | 8 | 524288 | 658.0 | 11.5 | 57.0x | 5x | no |
| Gwei.serialize | saturated | 8 | 524288 | 659.9 | 11.1 | 59.7x | 5x | no |
| Gwei.serialize | zero | 8 | 524288 | 665.7 | 11.9 | 56.2x | 5x | no |
| Hash32.deserialize | random | 32 | 110592 | 2387.2 | 38.7 | 61.7x | 5x | no |
| Hash32.deserialize | saturated | 32 | 110592 | 2405.2 | 42.2 | 57.0x | 5x | no |
| Hash32.deserialize | zero | 32 | 110592 | 2378.1 | 41.5 | 57.3x | 5x | no |
| Hash32.hash_tree_root | random | 32 | 28672 | 8614.7 | 147.7 | 58.3x | 10x | no |
| Hash32.hash_tree_root | saturated | 32 | 49152 | 8524.6 | 152.4 | 55.9x | 10x | no |
| Hash32.hash_tree_root | zero | 32 | 28672 | 8684.4 | 138.4 | 62.7x | 10x | no |
| Hash32.serialize | random | 32 | 524288 | 642.8 | 18.6 | 34.6x | 5x | no |
| Hash32.serialize | saturated | 32 | 524288 | 740.1 | 21.5 | 34.5x | 5x | no |
| Hash32.serialize | zero | 32 | 524288 | 627.5 | 18.6 | 33.8x | 5x | no |
| HistoricalBatch.deserialize | large-fixture | 524288 | 10 | 45400000.0 | 446275.0 | 101.7x | 5x | no |
| HistoricalBatch.deserialize | medium-fixture | 524288 | 10 | 46000000.0 | 445283.4 | 103.3x | 5x | no |
| HistoricalBatch.deserialize | small-fixture | 524288 | 10 | 45400000.0 | 447304.1 | 101.5x | 5x | no |
| HistoricalBatch.hash_tree_root | large-fixture | 524288 | 2 | 133500000.0 | 1605583.5 | 83.1x | 10x | no |
| HistoricalBatch.hash_tree_root | medium-fixture | 524288 | 2 | 137000000.0 | 1606208.5 | 85.3x | 10x | no |
| HistoricalBatch.hash_tree_root | small-fixture | 524288 | 2 | 136500000.0 | 1611396.0 | 84.7x | 10x | no |
| HistoricalBatch.serialize | large-fixture | 524288 | 8 | 50875000.0 | 108562.5 | 468.6x | 5x | no |
| HistoricalBatch.serialize | medium-fixture | 524288 | 6 | 52833333.3 | 100291.7 | 526.8x | 5x | no |
| HistoricalBatch.serialize | small-fixture | 524288 | 8 | 50750000.0 | 110927.1 | 457.5x | 5x | no |
| HistoricalSummary.deserialize | large-fixture | 64 | 90112 | 5570.8 | 20.0 | 278.7x | 5x | no |
| HistoricalSummary.deserialize | medium-fixture | 64 | 49152 | 5900.1 | 19.6 | 300.6x | 5x | no |
| HistoricalSummary.deserialize | small-fixture | 64 | 90112 | 5437.7 | 19.7 | 275.4x | 5x | no |
| HistoricalSummary.hash_tree_root | large-fixture | 64 | 16384 | 31677.2 | 156.8 | 202.1x | 10x | no |
| HistoricalSummary.hash_tree_root | medium-fixture | 64 | 16384 | 26977.5 | 143.0 | 188.6x | 10x | no |
| HistoricalSummary.hash_tree_root | small-fixture | 64 | 16384 | 29052.7 | 157.5 | 184.5x | 10x | no |
| HistoricalSummary.serialize | large-fixture | 64 | 122880 | 3629.6 | 21.8 | 166.5x | 5x | no |
| HistoricalSummary.serialize | medium-fixture | 64 | 122880 | 3588.9 | 21.3 | 168.3x | 5x | no |
| HistoricalSummary.serialize | small-fixture | 64 | 139264 | 3597.5 | 21.4 | 167.9x | 5x | no |
| IndexedAttestation.deserialize | large-fixture | 308 | 16384 | 30517.6 | 125.3 | 243.6x | 5x | no |
| IndexedAttestation.deserialize | medium-fixture | 284 | 16384 | 28015.1 | 119.7 | 234.0x | 5x | no |
| IndexedAttestation.deserialize | small-fixture | 236 | 16384 | 23437.5 | 102.7 | 228.3x | 5x | no |
| IndexedAttestation.hash_tree_root | large-fixture | 308 | 2560 | 175390.6 | 3067.0 | 57.2x | 10x | no |
| IndexedAttestation.hash_tree_root | medium-fixture | 284 | 1600 | 162500.0 | 3246.5 | 50.1x | 10x | no |
| IndexedAttestation.hash_tree_root | small-fixture | 236 | 3456 | 146412.0 | 2952.3 | 49.6x | 10x | no |
| IndexedAttestation.serialize | large-fixture | 308 | 8192 | 35278.3 | 56.6 | 623.0x | 5x | no |
| IndexedAttestation.serialize | medium-fixture | 284 | 8192 | 31616.2 | 51.6 | 612.2x | 5x | no |
| IndexedAttestation.serialize | small-fixture | 236 | 16384 | 24658.2 | 52.4 | 470.2x | 5x | no |
| KZGCommitment.deserialize | random | 48 | 106496 | 4826.5 | 43.0 | 112.1x | 5x | no |
| KZGCommitment.deserialize | saturated | 48 | 53248 | 4788.9 | 37.6 | 127.3x | 5x | no |
| KZGCommitment.deserialize | zero | 48 | 106496 | 4788.9 | 43.1 | 111.1x | 5x | no |
| KZGCommitment.hash_tree_root | random | 48 | 40960 | 12133.8 | 322.3 | 37.6x | 10x | no |
| KZGCommitment.hash_tree_root | saturated | 48 | 32768 | 12085.0 | 313.5 | 38.6x | 10x | no |
| KZGCommitment.hash_tree_root | zero | 48 | 40960 | 12060.5 | 336.9 | 35.8x | 10x | no |
| KZGCommitment.serialize | random | 48 | 524288 | 923.2 | 18.4 | 50.0x | 5x | no |
| KZGCommitment.serialize | saturated | 48 | 507904 | 925.4 | 19.2 | 48.2x | 5x | no |
| KZGCommitment.serialize | zero | 48 | 507904 | 937.2 | 18.9 | 49.6x | 5x | no |
| KZGProof.deserialize | random | 48 | 106496 | 4854.6 | 42.8 | 113.4x | 5x | no |
| KZGProof.deserialize | saturated | 48 | 106496 | 4826.5 | 39.9 | 121.0x | 5x | no |
| KZGProof.deserialize | zero | 48 | 53248 | 4826.5 | 38.3 | 126.1x | 5x | no |
| KZGProof.hash_tree_root | random | 48 | 20480 | 11914.1 | 299.9 | 39.7x | 10x | no |
| KZGProof.hash_tree_root | saturated | 48 | 40960 | 12085.0 | 336.5 | 35.9x | 10x | no |
| KZGProof.hash_tree_root | zero | 48 | 32768 | 11993.4 | 293.0 | 40.9x | 10x | no |
| KZGProof.serialize | random | 48 | 507904 | 923.4 | 18.4 | 50.2x | 5x | no |
| KZGProof.serialize | saturated | 48 | 524288 | 913.6 | 19.1 | 47.9x | 5x | no |
| KZGProof.serialize | zero | 48 | 524288 | 1033.8 | 20.1 | 51.5x | 5x | no |
| LightClientBootstrap.deserialize | large-fixture | 25676 | 128 | 2492187.5 | 12235.0 | 203.7x | 5x | no |
| LightClientBootstrap.deserialize | medium-fixture | 25666 | 128 | 2476562.5 | 12188.8 | 203.2x | 5x | no |
| LightClientBootstrap.deserialize | small-fixture | 25651 | 128 | 2515625.0 | 12007.8 | 209.5x | 5x | no |
| LightClientBootstrap.hash_tree_root | large-fixture | 25676 | 70 | 6514285.7 | 120128.6 | 54.2x | 10x | no |
| LightClientBootstrap.hash_tree_root | medium-fixture | 25666 | 70 | 6742857.1 | 120144.0 | 56.1x | 10x | no |
| LightClientBootstrap.hash_tree_root | small-fixture | 25651 | 41 | 6390243.9 | 117570.1 | 54.4x | 10x | no |
| LightClientBootstrap.serialize | large-fixture | 25676 | 62 | 4306451.6 | 3184.8 | 1352.2x | 5x | no |
| LightClientBootstrap.serialize | medium-fixture | 25666 | 100 | 4810000.0 | 3251.2 | 1479.4x | 5x | no |
| LightClientBootstrap.serialize | small-fixture | 25651 | 62 | 4580645.2 | 3559.8 | 1286.8x | 5x | no |
| LightClientFinalityUpdate.deserialize | large-fixture | 2096 | 1280 | 216406.2 | 1336.0 | 162.0x | 5x | no |
| LightClientFinalityUpdate.deserialize | medium-fixture | 2078 | 1216 | 215460.5 | 1319.1 | 163.3x | 5x | no |
| LightClientFinalityUpdate.deserialize | small-fixture | 2066 | 2432 | 213404.6 | 1279.9 | 166.7x | 5x | no |
| LightClientFinalityUpdate.hash_tree_root | large-fixture | 2096 | 768 | 647135.4 | 10493.8 | 61.7x | 10x | no |
| LightClientFinalityUpdate.hash_tree_root | medium-fixture | 2078 | 640 | 628125.0 | 9590.0 | 65.5x | 10x | no |
| LightClientFinalityUpdate.hash_tree_root | small-fixture | 2066 | 640 | 654687.5 | 10496.0 | 62.4x | 10x | no |
| LightClientFinalityUpdate.serialize | large-fixture | 2096 | 1664 | 279447.1 | 362.9 | 770.0x | 5x | no |
| LightClientFinalityUpdate.serialize | medium-fixture | 2078 | 1664 | 315504.8 | 397.2 | 794.4x | 5x | no |
| LightClientFinalityUpdate.serialize | small-fixture | 2066 | 1664 | 280048.1 | 365.3 | 766.6x | 5x | no |
| LightClientHeader.deserialize | large-fixture | 860 | 3200 | 82812.5 | 512.2 | 161.7x | 5x | no |
| LightClientHeader.deserialize | medium-fixture | 850 | 3200 | 80937.5 | 508.6 | 159.1x | 5x | no |
| LightClientHeader.deserialize | small-fixture | 830 | 3200 | 80937.5 | 508.8 | 159.1x | 5x | no |
| LightClientHeader.hash_tree_root | large-fixture | 860 | 1664 | 285456.7 | 3919.0 | 72.8x | 10x | no |
| LightClientHeader.hash_tree_root | medium-fixture | 850 | 896 | 286830.4 | 4307.3 | 66.6x | 10x | no |
| LightClientHeader.hash_tree_root | small-fixture | 830 | 896 | 282366.1 | 3923.5 | 72.0x | 10x | no |
| LightClientHeader.serialize | large-fixture | 860 | 4480 | 90625.0 | 158.3 | 572.6x | 5x | no |
| LightClientHeader.serialize | medium-fixture | 850 | 5248 | 90891.8 | 148.5 | 612.2x | 5x | no |
| LightClientHeader.serialize | small-fixture | 830 | 5248 | 88795.7 | 149.1 | 595.7x | 5x | no |
| LightClientOptimisticUpdate.deserialize | large-fixture | 1031 | 2240 | 120535.7 | 613.4 | 196.5x | 5x | no |
| LightClientOptimisticUpdate.deserialize | medium-fixture | 1013 | 4480 | 111607.1 | 626.7 | 178.1x | 5x | no |
| LightClientOptimisticUpdate.deserialize | small-fixture | 1000 | 2624 | 114710.4 | 609.6 | 188.2x | 5x | no |
| LightClientOptimisticUpdate.hash_tree_root | large-fixture | 1031 | 1408 | 348011.4 | 5184.3 | 67.1x | 10x | no |
| LightClientOptimisticUpdate.hash_tree_root | medium-fixture | 1013 | 1408 | 339488.6 | 5191.4 | 65.4x | 10x | no |
| LightClientOptimisticUpdate.hash_tree_root | small-fixture | 1000 | 1408 | 337358.0 | 5181.6 | 65.1x | 10x | no |
| LightClientOptimisticUpdate.serialize | large-fixture | 1031 | 3200 | 142187.5 | 209.7 | 678.2x | 5x | no |
| LightClientOptimisticUpdate.serialize | medium-fixture | 1013 | 3456 | 141782.4 | 174.5 | 812.5x | 5x | no |
| LightClientOptimisticUpdate.serialize | small-fixture | 1000 | 1728 | 139467.6 | 147.3 | 947.0x | 5x | no |
| LightClientUpdate.deserialize | large-fixture | 26914 | 128 | 3039062.5 | 14410.8 | 210.9x | 5x | no |
| LightClientUpdate.deserialize | medium-fixture | 26893 | 128 | 2671875.0 | 12364.9 | 216.1x | 5x | no |
| LightClientUpdate.deserialize | small-fixture | 26885 | 128 | 2765625.0 | 12862.0 | 215.0x | 5x | no |
| LightClientUpdate.hash_tree_root | large-fixture | 26914 | 70 | 7042857.1 | 126082.7 | 55.9x | 10x | no |
| LightClientUpdate.hash_tree_root | medium-fixture | 26893 | 70 | 7985714.3 | 140344.0 | 56.9x | 10x | no |
| LightClientUpdate.hash_tree_root | small-fixture | 26885 | 70 | 7128571.4 | 126139.3 | 56.5x | 10x | no |
| LightClientUpdate.serialize | large-fixture | 26914 | 50 | 4260000.0 | 3428.3 | 1242.6x | 5x | no |
| LightClientUpdate.serialize | medium-fixture | 26893 | 62 | 4838709.7 | 3532.3 | 1369.9x | 5x | no |
| LightClientUpdate.serialize | small-fixture | 26885 | 62 | 4645161.3 | 3336.7 | 1392.1x | 5x | no |
| MatrixEntry.deserialize | large-fixture | 2112 | 1600 | 164375.0 | 353.1 | 465.5x | 5x | no |
| MatrixEntry.deserialize | medium-fixture | 2112 | 1600 | 162500.0 | 331.6 | 490.1x | 5x | no |
| MatrixEntry.deserialize | small-fixture | 2112 | 1600 | 172500.0 | 361.1 | 477.8x | 5x | no |
| MatrixEntry.hash_tree_root | large-fixture | 2112 | 896 | 536830.4 | 6881.0 | 78.0x | 10x | no |
| MatrixEntry.hash_tree_root | medium-fixture | 2112 | 896 | 506696.4 | 6287.2 | 80.6x | 10x | no |
| MatrixEntry.hash_tree_root | small-fixture | 2112 | 896 | 508928.6 | 6656.9 | 76.5x | 10x | no |
| MatrixEntry.serialize | large-fixture | 2112 | 4480 | 106696.4 | 274.2 | 389.1x | 5x | no |
| MatrixEntry.serialize | medium-fixture | 2112 | 3968 | 106350.8 | 246.4 | 431.7x | 5x | no |
| MatrixEntry.serialize | small-fixture | 2112 | 3968 | 105342.7 | 240.7 | 437.6x | 5x | no |
| NextSyncCommitteeBranch.deserialize | random | 192 | 16384 | 16723.6 | 68.5 | 244.0x | 5x | no |
| NextSyncCommitteeBranch.deserialize | saturated | 192 | 16384 | 16174.3 | 65.7 | 246.2x | 5x | no |
| NextSyncCommitteeBranch.deserialize | zero | 192 | 16384 | 15991.2 | 64.1 | 249.3x | 5x | no |
| NextSyncCommitteeBranch.hash_tree_root | random | 192 | 8192 | 50903.3 | 888.0 | 57.3x | 10x | no |
| NextSyncCommitteeBranch.hash_tree_root | saturated | 192 | 8192 | 51635.7 | 848.9 | 60.8x | 10x | no |
| NextSyncCommitteeBranch.hash_tree_root | zero | 192 | 8192 | 51391.6 | 912.6 | 56.3x | 10x | no |
| NextSyncCommitteeBranch.serialize | random | 192 | 40960 | 11254.9 | 38.6 | 291.3x | 5x | no |
| NextSyncCommitteeBranch.serialize | saturated | 192 | 40960 | 10546.9 | 33.7 | 312.6x | 5x | no |
| NextSyncCommitteeBranch.serialize | zero | 192 | 40960 | 10742.2 | 34.2 | 314.3x | 5x | no |
| NodeID.deserialize | random | 32 | 204800 | 1381.8 | 41.5 | 33.3x | 5x | no |
| NodeID.deserialize | saturated | 32 | 204800 | 1411.1 | 41.9 | 33.7x | 5x | no |
| NodeID.deserialize | zero | 32 | 204800 | 1396.5 | 42.3 | 33.0x | 5x | no |
| NodeID.hash_tree_root | random | 32 | 90112 | 5271.2 | 155.6 | 33.9x | 10x | no |
| NodeID.hash_tree_root | saturated | 32 | 40960 | 5615.2 | 182.5 | 30.8x | 10x | no |
| NodeID.hash_tree_root | zero | 32 | 81920 | 5102.5 | 159.7 | 31.9x | 10x | no |
| NodeID.serialize | random | 32 | 524288 | 877.4 | 19.0 | 46.1x | 5x | no |
| NodeID.serialize | saturated | 32 | 507904 | 982.5 | 19.3 | 51.0x | 5x | no |
| NodeID.serialize | zero | 32 | 524288 | 886.9 | 18.7 | 47.4x | 5x | no |
| ParticipationFlags.deserialize | random | 1 | 524288 | 761.0 | 34.4 | 22.1x | 5x | no |
| ParticipationFlags.deserialize | saturated | 1 | 524288 | 772.5 | 35.1 | 22.0x | 5x | no |
| ParticipationFlags.deserialize | zero | 1 | 524288 | 782.0 | 35.1 | 22.3x | 5x | no |
| ParticipationFlags.hash_tree_root | random | 1 | 106496 | 4319.4 | 183.4 | 23.5x | 10x | no |
| ParticipationFlags.hash_tree_root | saturated | 1 | 106496 | 4281.9 | 181.3 | 23.6x | 10x | no |
| ParticipationFlags.hash_tree_root | zero | 1 | 114688 | 4263.7 | 179.7 | 23.7x | 10x | no |
| ParticipationFlags.serialize | random | 1 | 524288 | 600.8 | 10.8 | 55.6x | 5x | no |
| ParticipationFlags.serialize | saturated | 1 | 524288 | 692.4 | 13.1 | 52.7x | 5x | no |
| ParticipationFlags.serialize | zero | 1 | 524288 | 595.1 | 10.8 | 55.3x | 5x | no |
| PayloadId.deserialize | random | 8 | 204800 | 1377.0 | 35.6 | 38.7x | 5x | no |
| PayloadId.deserialize | saturated | 8 | 204800 | 1342.8 | 35.7 | 37.6x | 5x | no |
| PayloadId.deserialize | zero | 8 | 204800 | 1357.4 | 36.5 | 37.1x | 5x | no |
| PayloadId.hash_tree_root | random | 8 | 131072 | 3860.5 | 196.7 | 19.6x | 10x | no |
| PayloadId.hash_tree_root | saturated | 8 | 131072 | 3830.0 | 189.7 | 20.2x | 10x | no |
| PayloadId.hash_tree_root | zero | 8 | 122880 | 3873.7 | 184.4 | 21.0x | 10x | no |
| PayloadId.serialize | random | 8 | 2621440 | 169.8 | 12.1 | 14.1x | 5x | no |
| PayloadId.serialize | saturated | 8 | 2621440 | 178.9 | 12.6 | 14.2x | 5x | no |
| PayloadId.serialize | zero | 8 | 2621440 | 179.7 | 12.7 | 14.2x | 5x | no |
| PendingAttestation.deserialize | large-fixture | 150 | 24576 | 17985.0 | 96.5 | 186.4x | 5x | no |
| PendingAttestation.deserialize | medium-fixture | 149 | 24576 | 19409.2 | 104.0 | 186.7x | 5x | no |
| PendingAttestation.deserialize | small-fixture | 149 | 24576 | 17211.9 | 95.8 | 179.7x | 5x | no |
| PendingAttestation.hash_tree_root | large-fixture | 150 | 4480 | 116071.4 | 1540.5 | 75.3x | 10x | no |
| PendingAttestation.hash_tree_root | medium-fixture | 149 | 3968 | 111643.1 | 1540.8 | 72.5x | 10x | no |
| PendingAttestation.hash_tree_root | small-fixture | 149 | 4480 | 114955.4 | 1538.5 | 74.7x | 10x | no |
| PendingAttestation.serialize | large-fixture | 150 | 16384 | 20507.8 | 36.4 | 563.3x | 5x | no |
| PendingAttestation.serialize | medium-fixture | 149 | 16384 | 22827.1 | 40.4 | 565.0x | 5x | no |
| PendingAttestation.serialize | small-fixture | 149 | 16384 | 20690.9 | 38.9 | 532.3x | 5x | no |
| PendingConsolidation.deserialize | large-fixture | 16 | 221184 | 2337.4 | 12.3 | 189.4x | 5x | no |
| PendingConsolidation.deserialize | medium-fixture | 16 | 204800 | 2514.6 | 13.7 | 183.2x | 5x | no |
| PendingConsolidation.deserialize | small-fixture | 16 | 81920 | 2856.4 | 14.7 | 194.3x | 5x | no |
| PendingConsolidation.hash_tree_root | large-fixture | 16 | 24576 | 17374.7 | 130.6 | 133.0x | 10x | no |
| PendingConsolidation.hash_tree_root | medium-fixture | 16 | 24576 | 17537.4 | 141.2 | 124.2x | 10x | no |
| PendingConsolidation.hash_tree_root | small-fixture | 16 | 24576 | 18473.3 | 141.5 | 130.6x | 10x | no |
| PendingConsolidation.serialize | large-fixture | 16 | 253952 | 1882.2 | 15.1 | 124.7x | 5x | no |
| PendingConsolidation.serialize | medium-fixture | 16 | 204800 | 1982.4 | 14.7 | 135.0x | 5x | no |
| PendingConsolidation.serialize | small-fixture | 16 | 221184 | 1962.2 | 15.5 | 126.4x | 5x | no |
| PendingDeposit.deserialize | large-fixture | 192 | 32768 | 14038.1 | 53.1 | 264.5x | 5x | no |
| PendingDeposit.deserialize | medium-fixture | 192 | 32768 | 14007.6 | 54.3 | 257.9x | 5x | no |
| PendingDeposit.deserialize | small-fixture | 192 | 32768 | 15869.1 | 62.9 | 252.2x | 5x | no |
| PendingDeposit.hash_tree_root | large-fixture | 192 | 6400 | 71406.2 | 941.9 | 75.8x | 10x | no |
| PendingDeposit.hash_tree_root | medium-fixture | 192 | 7936 | 63760.1 | 882.8 | 72.2x | 10x | no |
| PendingDeposit.hash_tree_root | small-fixture | 192 | 3968 | 63004.0 | 841.1 | 74.9x | 10x | no |
| PendingDeposit.serialize | large-fixture | 192 | 40960 | 11084.0 | 34.2 | 324.4x | 5x | no |
| PendingDeposit.serialize | medium-fixture | 192 | 40960 | 9863.3 | 32.5 | 303.6x | 5x | no |
| PendingDeposit.serialize | small-fixture | 192 | 40960 | 11621.1 | 37.3 | 311.6x | 5x | no |
| PendingPartialWithdrawal.deserialize | large-fixture | 24 | 139264 | 3482.6 | 14.9 | 233.1x | 5x | no |
| PendingPartialWithdrawal.deserialize | medium-fixture | 24 | 81920 | 3454.6 | 14.2 | 243.1x | 5x | no |
| PendingPartialWithdrawal.deserialize | small-fixture | 24 | 163840 | 3283.7 | 16.1 | 204.0x | 5x | no |
| PendingPartialWithdrawal.hash_tree_root | large-fixture | 24 | 16384 | 28381.3 | 336.6 | 84.3x | 10x | no |
| PendingPartialWithdrawal.hash_tree_root | medium-fixture | 24 | 16384 | 24902.3 | 310.5 | 80.2x | 10x | no |
| PendingPartialWithdrawal.hash_tree_root | small-fixture | 24 | 16384 | 24719.2 | 309.7 | 79.8x | 10x | no |
| PendingPartialWithdrawal.serialize | large-fixture | 24 | 155648 | 2993.9 | 19.3 | 155.4x | 5x | no |
| PendingPartialWithdrawal.serialize | medium-fixture | 24 | 155648 | 2685.5 | 16.7 | 161.0x | 5x | no |
| PendingPartialWithdrawal.serialize | small-fixture | 24 | 139264 | 3123.6 | 16.4 | 189.9x | 5x | no |
| PowBlock.deserialize | large-fixture | 96 | 36864 | 7487.0 | 78.3 | 95.6x | 5x | no |
| PowBlock.deserialize | medium-fixture | 96 | 36864 | 7351.3 | 75.0 | 98.1x | 5x | no |
| PowBlock.deserialize | small-fixture | 96 | 65536 | 7293.7 | 75.3 | 96.9x | 5x | no |
| PowBlock.hash_tree_root | large-fixture | 96 | 8192 | 38452.1 | 365.1 | 105.3x | 10x | no |
| PowBlock.hash_tree_root | medium-fixture | 96 | 8192 | 38452.1 | 340.1 | 113.1x | 10x | no |
| PowBlock.hash_tree_root | small-fixture | 96 | 8192 | 36743.2 | 337.0 | 109.0x | 10x | no |
| PowBlock.serialize | large-fixture | 96 | 40960 | 5981.4 | 30.3 | 197.5x | 5x | no |
| PowBlock.serialize | medium-fixture | 96 | 73728 | 5872.9 | 26.4 | 222.6x | 5x | no |
| PowBlock.serialize | small-fixture | 96 | 81920 | 5749.5 | 26.2 | 219.1x | 5x | no |
| ProposerSlashing.deserialize | large-fixture | 416 | 8192 | 43457.0 | 161.7 | 268.8x | 5x | no |
| ProposerSlashing.deserialize | medium-fixture | 416 | 8192 | 38940.4 | 147.3 | 264.4x | 5x | no |
| ProposerSlashing.deserialize | small-fixture | 416 | 8192 | 38940.4 | 149.3 | 260.8x | 5x | no |
| ProposerSlashing.hash_tree_root | large-fixture | 416 | 2816 | 171875.0 | 2122.0 | 81.0x | 10x | no |
| ProposerSlashing.hash_tree_root | medium-fixture | 416 | 1600 | 173125.0 | 2407.1 | 71.9x | 10x | no |
| ProposerSlashing.hash_tree_root | small-fixture | 416 | 1408 | 172585.2 | 2130.2 | 81.0x | 10x | no |
| ProposerSlashing.serialize | large-fixture | 416 | 8192 | 50293.0 | 75.0 | 670.2x | 5x | no |
| ProposerSlashing.serialize | medium-fixture | 416 | 7936 | 51159.3 | 75.8 | 675.3x | 5x | no |
| ProposerSlashing.serialize | small-fixture | 416 | 8192 | 51269.5 | 75.8 | 676.5x | 5x | no |
| Root.deserialize | random | 32 | 110592 | 2432.4 | 42.4 | 57.4x | 5x | no |
| Root.deserialize | saturated | 32 | 110592 | 2432.4 | 42.5 | 57.2x | 5x | no |
| Root.deserialize | zero | 32 | 110592 | 2414.3 | 42.9 | 56.2x | 5x | no |
| Root.hash_tree_root | random | 32 | 28672 | 9033.2 | 146.7 | 61.6x | 10x | no |
| Root.hash_tree_root | saturated | 32 | 28672 | 9033.2 | 139.6 | 64.7x | 10x | no |
| Root.hash_tree_root | zero | 32 | 49152 | 9053.5 | 161.9 | 55.9x | 10x | no |
| Root.serialize | random | 32 | 524288 | 652.3 | 19.3 | 33.7x | 5x | no |
| Root.serialize | saturated | 32 | 524288 | 658.0 | 18.9 | 34.8x | 5x | no |
| Root.serialize | zero | 32 | 524288 | 658.0 | 17.3 | 38.0x | 5x | no |
| RowIndex.deserialize | random | 8 | 409600 | 1237.8 | 35.8 | 34.6x | 5x | no |
| RowIndex.deserialize | saturated | 8 | 409600 | 1237.8 | 36.5 | 33.9x | 5x | no |
| RowIndex.deserialize | zero | 8 | 409600 | 1245.1 | 35.9 | 34.6x | 5x | no |
| RowIndex.hash_tree_root | random | 8 | 57344 | 4551.5 | 206.3 | 22.1x | 10x | no |
| RowIndex.hash_tree_root | saturated | 8 | 106496 | 4601.1 | 187.7 | 24.5x | 10x | no |
| RowIndex.hash_tree_root | zero | 8 | 106496 | 4582.3 | 195.8 | 23.4x | 10x | no |
| RowIndex.serialize | random | 8 | 524288 | 688.6 | 12.3 | 56.0x | 5x | no |
| RowIndex.serialize | saturated | 8 | 507904 | 697.0 | 12.5 | 55.8x | 5x | no |
| RowIndex.serialize | zero | 8 | 524288 | 684.7 | 12.7 | 53.8x | 5x | no |
| SignedAggregateAndProof.deserialize | large-fixture | 446 | 8192 | 48339.8 | 209.8 | 230.4x | 5x | no |
| SignedAggregateAndProof.deserialize | medium-fixture | 445 | 8192 | 48217.8 | 204.8 | 235.4x | 5x | no |
| SignedAggregateAndProof.deserialize | small-fixture | 445 | 8192 | 47485.4 | 223.9 | 212.1x | 5x | no |
| SignedAggregateAndProof.hash_tree_root | large-fixture | 446 | 1792 | 258370.5 | 3714.1 | 69.6x | 10x | no |
| SignedAggregateAndProof.hash_tree_root | medium-fixture | 445 | 1280 | 201562.5 | 2793.9 | 72.1x | 10x | no |
| SignedAggregateAndProof.hash_tree_root | small-fixture | 445 | 1792 | 253906.2 | 3391.8 | 74.9x | 10x | no |
| SignedAggregateAndProof.serialize | large-fixture | 446 | 3968 | 61239.9 | 88.2 | 694.1x | 5x | no |
| SignedAggregateAndProof.serialize | medium-fixture | 445 | 3968 | 61744.0 | 81.5 | 757.9x | 5x | no |
| SignedAggregateAndProof.serialize | small-fixture | 445 | 3200 | 70312.5 | 99.6 | 705.9x | 5x | no |
| SignedBLSToExecutionChange.deserialize | large-fixture | 172 | 16384 | 16113.3 | 51.8 | 310.8x | 5x | no |
| SignedBLSToExecutionChange.deserialize | medium-fixture | 172 | 24576 | 16764.3 | 57.7 | 290.4x | 5x | no |
| SignedBLSToExecutionChange.deserialize | small-fixture | 172 | 16384 | 16540.5 | 50.7 | 326.1x | 5x | no |
| SignedBLSToExecutionChange.hash_tree_root | large-fixture | 172 | 6400 | 74218.8 | 846.7 | 87.7x | 10x | no |
| SignedBLSToExecutionChange.hash_tree_root | medium-fixture | 172 | 6400 | 75000.0 | 927.0 | 80.9x | 10x | no |
| SignedBLSToExecutionChange.hash_tree_root | small-fixture | 172 | 6400 | 74843.8 | 847.4 | 88.3x | 10x | no |
| SignedBLSToExecutionChange.serialize | large-fixture | 172 | 32768 | 13305.7 | 39.4 | 337.6x | 5x | no |
| SignedBLSToExecutionChange.serialize | medium-fixture | 172 | 32768 | 13275.1 | 39.6 | 335.2x | 5x | no |
| SignedBLSToExecutionChange.serialize | small-fixture | 172 | 32768 | 13458.3 | 36.1 | 372.6x | 5x | no |
| SignedBeaconBlock.deserialize | large-fixture | 23999 | 128 | 2828125.0 | 15005.5 | 188.5x | 5x | no |
| SignedBeaconBlock.deserialize | medium-fixture | 18718 | 128 | 1945312.5 | 10648.1 | 182.7x | 5x | no |
| SignedBeaconBlock.deserialize | small-fixture | 16683 | 256 | 1687500.0 | 10804.4 | 156.2x | 5x | no |
| SignedBeaconBlock.hash_tree_root | large-fixture | 23999 | 54 | 8574074.1 | 124001.5 | 69.1x | 10x | no |
| SignedBeaconBlock.hash_tree_root | medium-fixture | 18718 | 41 | 6292682.9 | 97276.4 | 64.7x | 10x | no |
| SignedBeaconBlock.hash_tree_root | small-fixture | 16683 | 82 | 5365853.7 | 86679.9 | 61.9x | 10x | no |
| SignedBeaconBlock.serialize | large-fixture | 23999 | 62 | 6741935.5 | 2949.6 | 2285.7x | 5x | no |
| SignedBeaconBlock.serialize | medium-fixture | 18718 | 50 | 5020000.0 | 2440.8 | 2056.7x | 5x | no |
| SignedBeaconBlock.serialize | small-fixture | 16683 | 62 | 4419354.8 | 1957.7 | 2257.5x | 5x | no |
| SignedBeaconBlockHeader.deserialize | large-fixture | 208 | 24576 | 20345.1 | 59.6 | 341.2x | 5x | no |
| SignedBeaconBlockHeader.deserialize | medium-fixture | 208 | 24576 | 20385.7 | 60.2 | 338.4x | 5x | no |
| SignedBeaconBlockHeader.deserialize | small-fixture | 208 | 24576 | 20467.1 | 66.2 | 309.3x | 5x | no |
| SignedBeaconBlockHeader.hash_tree_root | large-fixture | 208 | 5248 | 95464.9 | 1025.8 | 93.1x | 10x | no |
| SignedBeaconBlockHeader.hash_tree_root | medium-fixture | 208 | 2624 | 94131.1 | 1127.5 | 83.5x | 10x | no |
| SignedBeaconBlockHeader.hash_tree_root | small-fixture | 208 | 5248 | 96798.8 | 1121.0 | 86.4x | 10x | no |
| SignedBeaconBlockHeader.serialize | large-fixture | 208 | 24576 | 17456.1 | 42.6 | 409.5x | 5x | no |
| SignedBeaconBlockHeader.serialize | medium-fixture | 208 | 24576 | 17293.3 | 43.8 | 394.8x | 5x | no |
| SignedBeaconBlockHeader.serialize | small-fixture | 208 | 24576 | 17781.6 | 45.3 | 392.4x | 5x | no |
| SignedContributionAndProof.deserialize | large-fixture | 360 | 8192 | 37353.5 | 128.2 | 291.3x | 5x | no |
| SignedContributionAndProof.deserialize | medium-fixture | 360 | 8192 | 37353.5 | 129.9 | 287.6x | 5x | no |
| SignedContributionAndProof.deserialize | small-fixture | 360 | 8192 | 36743.2 | 129.8 | 283.0x | 5x | no |
| SignedContributionAndProof.hash_tree_root | large-fixture | 360 | 3200 | 180000.0 | 2329.5 | 77.3x | 10x | no |
| SignedContributionAndProof.hash_tree_root | medium-fixture | 360 | 3200 | 158750.0 | 2096.1 | 75.7x | 10x | no |
| SignedContributionAndProof.hash_tree_root | small-fixture | 360 | 3200 | 153437.5 | 1910.2 | 80.3x | 10x | no |
| SignedContributionAndProof.serialize | large-fixture | 360 | 8192 | 39672.9 | 65.8 | 603.2x | 5x | no |
| SignedContributionAndProof.serialize | medium-fixture | 360 | 8192 | 39672.9 | 65.7 | 604.1x | 5x | no |
| SignedContributionAndProof.serialize | small-fixture | 360 | 8192 | 38574.2 | 64.2 | 601.0x | 5x | no |
| SignedVoluntaryExit.deserialize | large-fixture | 112 | 24576 | 10945.6 | 42.4 | 258.3x | 5x | no |
| SignedVoluntaryExit.deserialize | medium-fixture | 112 | 40960 | 12158.2 | 52.1 | 233.4x | 5x | no |
| SignedVoluntaryExit.deserialize | small-fixture | 112 | 40960 | 10937.5 | 47.4 | 230.8x | 5x | no |
| SignedVoluntaryExit.hash_tree_root | large-fixture | 112 | 8192 | 55175.8 | 551.7 | 100.0x | 10x | no |
| SignedVoluntaryExit.hash_tree_root | medium-fixture | 112 | 8192 | 55419.9 | 551.1 | 100.6x | 10x | no |
| SignedVoluntaryExit.hash_tree_root | small-fixture | 112 | 7936 | 55443.5 | 604.2 | 91.8x | 10x | no |
| SignedVoluntaryExit.serialize | large-fixture | 112 | 57344 | 8004.3 | 28.4 | 281.9x | 5x | no |
| SignedVoluntaryExit.serialize | medium-fixture | 112 | 49152 | 7893.9 | 31.2 | 252.8x | 5x | no |
| SignedVoluntaryExit.serialize | small-fixture | 112 | 57344 | 7899.7 | 28.6 | 276.6x | 5x | no |
| SigningData.deserialize | large-fixture | 64 | 81920 | 5761.7 | 20.5 | 281.4x | 5x | no |
| SigningData.deserialize | medium-fixture | 64 | 90112 | 5581.9 | 20.3 | 275.1x | 5x | no |
| SigningData.deserialize | small-fixture | 64 | 49152 | 5574.5 | 18.8 | 297.0x | 5x | no |
| SigningData.hash_tree_root | large-fixture | 64 | 16384 | 28259.3 | 156.8 | 180.2x | 10x | no |
| SigningData.hash_tree_root | medium-fixture | 64 | 16384 | 28015.1 | 156.9 | 178.5x | 10x | no |
| SigningData.hash_tree_root | small-fixture | 64 | 16384 | 27343.8 | 144.2 | 189.6x | 10x | no |
| SigningData.serialize | large-fixture | 64 | 57344 | 3888.8 | 24.4 | 159.1x | 5x | no |
| SigningData.serialize | medium-fixture | 64 | 61440 | 3890.0 | 24.3 | 159.9x | 5x | no |
| SigningData.serialize | small-fixture | 64 | 122880 | 3694.7 | 21.9 | 168.7x | 5x | no |
| SingleAttestation.deserialize | large-fixture | 240 | 16384 | 23986.8 | 96.8 | 247.8x | 5x | no |
| SingleAttestation.deserialize | medium-fixture | 240 | 16384 | 24169.9 | 95.1 | 254.3x | 5x | no |
| SingleAttestation.deserialize | small-fixture | 240 | 16384 | 24414.1 | 96.9 | 251.9x | 5x | no |
| SingleAttestation.hash_tree_root | large-fixture | 240 | 3456 | 130787.0 | 1580.0 | 82.8x | 10x | no |
| SingleAttestation.hash_tree_root | medium-fixture | 240 | 3968 | 125000.0 | 1578.3 | 79.2x | 10x | no |
| SingleAttestation.hash_tree_root | small-fixture | 240 | 1600 | 133750.0 | 1593.1 | 84.0x | 10x | no |
| SingleAttestation.serialize | large-fixture | 240 | 16384 | 28686.5 | 62.9 | 456.1x | 5x | no |
| SingleAttestation.serialize | medium-fixture | 240 | 16384 | 25817.9 | 56.2 | 459.3x | 5x | no |
| SingleAttestation.serialize | small-fixture | 240 | 16384 | 26611.3 | 59.0 | 451.2x | 5x | no |
| Slot.deserialize | random | 8 | 409600 | 1355.0 | 39.7 | 34.1x | 5x | no |
| Slot.deserialize | saturated | 8 | 253952 | 1216.8 | 35.5 | 34.3x | 5x | no |
| Slot.deserialize | zero | 8 | 253952 | 1220.7 | 35.9 | 34.0x | 5x | no |
| Slot.hash_tree_root | random | 8 | 53248 | 4413.3 | 181.5 | 24.3x | 10x | no |
| Slot.hash_tree_root | saturated | 8 | 98304 | 4526.8 | 202.3 | 22.4x | 10x | no |
| Slot.hash_tree_root | zero | 8 | 106496 | 4413.3 | 197.6 | 22.3x | 10x | no |
| Slot.serialize | random | 8 | 524288 | 749.6 | 13.2 | 57.0x | 5x | no |
| Slot.serialize | saturated | 8 | 524288 | 679.0 | 12.3 | 55.4x | 5x | no |
| Slot.serialize | zero | 8 | 524288 | 690.5 | 12.2 | 56.7x | 5x | no |
| SubnetID.deserialize | random | 8 | 409600 | 1220.7 | 36.1 | 33.8x | 5x | no |
| SubnetID.deserialize | saturated | 8 | 409600 | 1225.6 | 36.1 | 33.9x | 5x | no |
| SubnetID.deserialize | zero | 8 | 409600 | 1218.3 | 36.6 | 33.3x | 5x | no |
| SubnetID.hash_tree_root | random | 8 | 98304 | 4465.7 | 187.1 | 23.9x | 10x | no |
| SubnetID.hash_tree_root | saturated | 8 | 106496 | 4572.9 | 181.9 | 25.1x | 10x | no |
| SubnetID.hash_tree_root | zero | 8 | 106496 | 4497.8 | 196.2 | 22.9x | 10x | no |
| SubnetID.serialize | random | 8 | 524288 | 812.5 | 13.9 | 58.5x | 5x | no |
| SubnetID.serialize | saturated | 8 | 524288 | 679.0 | 12.3 | 55.2x | 5x | no |
| SubnetID.serialize | zero | 8 | 524288 | 694.3 | 12.1 | 57.3x | 5x | no |
| SyncAggregate.deserialize | large-fixture | 160 | 16384 | 30334.5 | 49.6 | 612.2x | 5x | no |
| SyncAggregate.deserialize | medium-fixture | 160 | 16384 | 29235.8 | 48.4 | 603.5x | 5x | no |
| SyncAggregate.deserialize | small-fixture | 160 | 16384 | 30273.4 | 46.8 | 646.8x | 5x | no |
| SyncAggregate.hash_tree_root | large-fixture | 160 | 8192 | 59814.5 | 594.3 | 100.6x | 10x | no |
| SyncAggregate.hash_tree_root | medium-fixture | 160 | 8192 | 62255.9 | 595.0 | 104.6x | 10x | no |
| SyncAggregate.hash_tree_root | small-fixture | 160 | 7936 | 58845.8 | 543.4 | 108.3x | 10x | no |
| SyncAggregate.serialize | large-fixture | 160 | 32768 | 13732.9 | 34.0 | 403.4x | 5x | no |
| SyncAggregate.serialize | medium-fixture | 160 | 32768 | 13824.5 | 34.8 | 397.1x | 5x | no |
| SyncAggregate.serialize | small-fixture | 160 | 32768 | 13793.9 | 34.4 | 400.7x | 5x | no |
| SyncAggregatorSelectionData.deserialize | large-fixture | 16 | 90112 | 3151.6 | 14.9 | 211.3x | 5x | no |
| SyncAggregatorSelectionData.deserialize | medium-fixture | 16 | 102400 | 2529.3 | 13.4 | 189.4x | 5x | no |
| SyncAggregatorSelectionData.deserialize | small-fixture | 16 | 102400 | 2548.8 | 13.2 | 192.5x | 5x | no |
| SyncAggregatorSelectionData.hash_tree_root | large-fixture | 16 | 24576 | 18880.2 | 142.0 | 133.0x | 10x | no |
| SyncAggregatorSelectionData.hash_tree_root | medium-fixture | 16 | 24576 | 18839.5 | 155.0 | 121.6x | 10x | no |
| SyncAggregatorSelectionData.hash_tree_root | small-fixture | 16 | 24576 | 19002.3 | 141.8 | 134.0x | 10x | no |
| SyncAggregatorSelectionData.serialize | large-fixture | 16 | 204800 | 2041.0 | 16.2 | 125.7x | 5x | no |
| SyncAggregatorSelectionData.serialize | medium-fixture | 16 | 126976 | 2071.3 | 14.3 | 144.4x | 5x | no |
| SyncAggregatorSelectionData.serialize | small-fixture | 16 | 126976 | 2197.3 | 17.5 | 125.5x | 5x | no |
| SyncCommittee.deserialize | large-fixture | 24624 | 128 | 2312500.0 | 3171.9 | 729.1x | 5x | no |
| SyncCommittee.deserialize | medium-fixture | 24624 | 128 | 2296875.0 | 3073.6 | 747.3x | 5x | no |
| SyncCommittee.deserialize | small-fixture | 24624 | 128 | 2359375.0 | 3146.8 | 749.8x | 5x | no |
| SyncCommittee.hash_tree_root | large-fixture | 24624 | 82 | 6134146.3 | 113540.7 | 54.0x | 10x | no |
| SyncCommittee.hash_tree_root | medium-fixture | 24624 | 82 | 6121951.2 | 122524.9 | 50.0x | 10x | no |
| SyncCommittee.hash_tree_root | small-fixture | 24624 | 70 | 6214285.7 | 111807.1 | 55.6x | 10x | no |
| SyncCommittee.serialize | large-fixture | 24624 | 128 | 3289062.5 | 3976.6 | 827.1x | 5x | no |
| SyncCommittee.serialize | medium-fixture | 24624 | 128 | 3437500.0 | 3896.8 | 882.1x | 5x | no |
| SyncCommittee.serialize | small-fixture | 24624 | 128 | 3414062.5 | 3870.8 | 882.0x | 5x | no |
| SyncCommitteeContribution.deserialize | large-fixture | 160 | 32768 | 15502.9 | 46.2 | 335.5x | 5x | no |
| SyncCommitteeContribution.deserialize | medium-fixture | 160 | 32768 | 15228.3 | 46.5 | 327.8x | 5x | no |
| SyncCommitteeContribution.deserialize | small-fixture | 160 | 24576 | 18269.9 | 57.0 | 320.6x | 5x | no |
| SyncCommitteeContribution.hash_tree_root | large-fixture | 160 | 6400 | 64218.8 | 846.7 | 75.8x | 10x | no |
| SyncCommitteeContribution.hash_tree_root | medium-fixture | 160 | 7936 | 60609.9 | 794.7 | 76.3x | 10x | no |
| SyncCommitteeContribution.hash_tree_root | small-fixture | 160 | 6400 | 73125.0 | 913.7 | 80.0x | 10x | no |
| SyncCommitteeContribution.serialize | large-fixture | 160 | 49152 | 9948.7 | 28.4 | 350.3x | 5x | no |
| SyncCommitteeContribution.serialize | medium-fixture | 160 | 49152 | 10131.8 | 29.8 | 340.1x | 5x | no |
| SyncCommitteeContribution.serialize | small-fixture | 160 | 40960 | 11865.2 | 34.5 | 343.9x | 5x | no |
| SyncCommitteeMessage.deserialize | large-fixture | 144 | 20480 | 13671.9 | 29.7 | 459.8x | 5x | no |
| SyncCommitteeMessage.deserialize | medium-fixture | 144 | 40960 | 13403.3 | 30.5 | 439.1x | 5x | no |
| SyncCommitteeMessage.deserialize | small-fixture | 144 | 40960 | 12622.1 | 30.8 | 410.1x | 5x | no |
| SyncCommitteeMessage.hash_tree_root | large-fixture | 144 | 8192 | 56518.6 | 630.8 | 89.6x | 10x | no |
| SyncCommitteeMessage.hash_tree_root | medium-fixture | 144 | 7936 | 60609.9 | 631.4 | 96.0x | 10x | no |
| SyncCommitteeMessage.hash_tree_root | small-fixture | 144 | 8192 | 49438.5 | 548.3 | 90.2x | 10x | no |
| SyncCommitteeMessage.serialize | large-fixture | 144 | 49152 | 9094.2 | 32.3 | 281.7x | 5x | no |
| SyncCommitteeMessage.serialize | medium-fixture | 144 | 49152 | 9257.0 | 32.5 | 285.1x | 5x | no |
| SyncCommitteeMessage.serialize | small-fixture | 144 | 49152 | 7710.8 | 28.6 | 269.1x | 5x | no |
| Transaction.deserialize | large | 1048576 | 4 | 85000000.0 | 91937.5 | 924.5x | 5x | no |
| Transaction.deserialize | medium | 4096 | 896 | 314732.1 | 721.5 | 436.2x | 5x | no |
| Transaction.deserialize | small | 32 | 221184 | 2328.4 | 41.2 | 56.4x | 5x | no |
| Transaction.hash_tree_root | large | 1048576 | 1 | 288000000.0 | 3441000.0 | 83.7x | 10x | no |
| Transaction.hash_tree_root | medium | 4096 | 256 | 1441406.2 | 14175.3 | 101.7x | 10x | no |
| Transaction.hash_tree_root | small | 32 | 896 | 483258.9 | 2603.9 | 185.6x | 10x | no |
| Transaction.serialize | large | 1048576 | 8 | 34500000.0 | 91229.2 | 378.2x | 5x | no |
| Transaction.serialize | medium | 4096 | 3968 | 116935.5 | 379.6 | 308.0x | 5x | no |
| Transaction.serialize | small | 32 | 409600 | 986.3 | 17.4 | 56.7x | 5x | no |
| Validator.deserialize | large-fixture | 121 | 32768 | 14556.9 | 50.8 | 286.8x | 5x | no |
| Validator.deserialize | medium-fixture | 121 | 32768 | 14404.3 | 51.4 | 280.4x | 5x | no |
| Validator.deserialize | small-fixture | 121 | 32768 | 16418.5 | 56.0 | 293.4x | 5x | no |
| Validator.hash_tree_root | large-fixture | 121 | 3968 | 72832.7 | 829.4 | 87.8x | 10x | no |
| Validator.hash_tree_root | medium-fixture | 121 | 6400 | 74218.8 | 826.0 | 89.9x | 10x | no |
| Validator.hash_tree_root | small-fixture | 121 | 3200 | 81875.0 | 910.4 | 89.9x | 10x | no |
| Validator.serialize | large-fixture | 121 | 40960 | 11572.3 | 31.9 | 363.0x | 5x | no |
| Validator.serialize | medium-fixture | 121 | 40960 | 11450.2 | 31.3 | 365.9x | 5x | no |
| Validator.serialize | small-fixture | 121 | 40960 | 12182.6 | 34.6 | 351.7x | 5x | no |
| ValidatorIndex.deserialize | random | 8 | 409600 | 1196.3 | 35.0 | 34.2x | 5x | no |
| ValidatorIndex.deserialize | saturated | 8 | 409600 | 1193.8 | 35.1 | 34.1x | 5x | no |
| ValidatorIndex.deserialize | zero | 8 | 253952 | 1122.3 | 35.3 | 31.8x | 5x | no |
| ValidatorIndex.hash_tree_root | random | 8 | 106496 | 4385.1 | 184.5 | 23.8x | 10x | no |
| ValidatorIndex.hash_tree_root | saturated | 8 | 114688 | 4412.0 | 174.7 | 25.3x | 10x | no |
| ValidatorIndex.hash_tree_root | zero | 8 | 114688 | 4324.8 | 171.6 | 25.2x | 10x | no |
| ValidatorIndex.serialize | random | 8 | 524288 | 663.8 | 12.1 | 54.9x | 5x | no |
| ValidatorIndex.serialize | saturated | 8 | 524288 | 675.2 | 12.2 | 55.2x | 5x | no |
| ValidatorIndex.serialize | zero | 8 | 524288 | 659.9 | 11.7 | 56.2x | 5x | no |
| Version.deserialize | random | 4 | 507904 | 1025.8 | 37.4 | 27.4x | 5x | no |
| Version.deserialize | saturated | 4 | 507904 | 943.1 | 37.5 | 25.1x | 5x | no |
| Version.deserialize | zero | 4 | 507904 | 945.1 | 35.3 | 26.7x | 5x | no |
| Version.hash_tree_root | random | 4 | 122880 | 3531.9 | 184.1 | 19.2x | 10x | no |
| Version.hash_tree_root | saturated | 4 | 131072 | 3578.2 | 186.6 | 19.2x | 10x | no |
| Version.hash_tree_root | zero | 4 | 57344 | 4289.9 | 229.3 | 18.7x | 10x | no |
| Version.serialize | random | 4 | 4718592 | 106.4 | 13.9 | 7.7x | 5x | no |
| Version.serialize | saturated | 4 | 2621440 | 95.7 | 12.2 | 7.9x | 5x | no |
| Version.serialize | zero | 4 | 5000000 | 95.8 | 12.2 | 7.8x | 5x | no |
| VersionedHash.deserialize | random | 32 | 110592 | 2396.2 | 42.4 | 56.5x | 5x | no |
| VersionedHash.deserialize | saturated | 32 | 110592 | 2378.1 | 42.5 | 56.0x | 5x | no |
| VersionedHash.deserialize | zero | 32 | 204800 | 2417.0 | 41.5 | 58.3x | 5x | no |
| VersionedHash.hash_tree_root | random | 32 | 28672 | 8893.7 | 152.9 | 58.2x | 10x | no |
| VersionedHash.hash_tree_root | saturated | 32 | 57344 | 8492.6 | 155.8 | 54.5x | 10x | no |
| VersionedHash.hash_tree_root | zero | 32 | 57344 | 8806.5 | 166.0 | 53.0x | 10x | no |
| VersionedHash.serialize | random | 32 | 524288 | 633.2 | 17.6 | 36.1x | 5x | no |
| VersionedHash.serialize | saturated | 32 | 524288 | 606.5 | 17.1 | 35.6x | 5x | no |
| VersionedHash.serialize | zero | 32 | 524288 | 631.3 | 17.7 | 35.7x | 5x | no |
| VoluntaryExit.deserialize | large-fixture | 16 | 180224 | 2485.8 | 12.0 | 207.1x | 5x | no |
| VoluntaryExit.deserialize | medium-fixture | 16 | 204800 | 2558.6 | 13.5 | 189.0x | 5x | no |
| VoluntaryExit.deserialize | small-fixture | 16 | 110592 | 2405.2 | 12.0 | 200.0x | 5x | no |
| VoluntaryExit.hash_tree_root | large-fixture | 16 | 24576 | 19246.4 | 155.1 | 124.1x | 10x | no |
| VoluntaryExit.hash_tree_root | medium-fixture | 16 | 24576 | 22054.0 | 155.0 | 142.3x | 10x | no |
| VoluntaryExit.hash_tree_root | small-fixture | 16 | 24576 | 18880.2 | 154.6 | 122.1x | 10x | no |
| VoluntaryExit.serialize | large-fixture | 16 | 126976 | 1992.5 | 14.4 | 138.8x | 5x | no |
| VoluntaryExit.serialize | medium-fixture | 16 | 126976 | 2008.3 | 15.2 | 132.4x | 5x | no |
| VoluntaryExit.serialize | small-fixture | 16 | 221184 | 1993.8 | 16.3 | 122.1x | 5x | no |
| Withdrawal.deserialize | large-fixture | 44 | 49152 | 5350.7 | 17.5 | 306.0x | 5x | no |
| Withdrawal.deserialize | medium-fixture | 44 | 90112 | 5382.2 | 19.4 | 276.9x | 5x | no |
| Withdrawal.deserialize | small-fixture | 44 | 45056 | 6103.5 | 18.4 | 331.9x | 5x | no |
| Withdrawal.hash_tree_root | large-fixture | 44 | 8192 | 36499.0 | 375.9 | 97.1x | 10x | no |
| Withdrawal.hash_tree_root | medium-fixture | 44 | 8192 | 35766.6 | 343.2 | 104.2x | 10x | no |
| Withdrawal.hash_tree_root | small-fixture | 44 | 8192 | 35888.7 | 341.9 | 105.0x | 10x | no |
| Withdrawal.serialize | large-fixture | 44 | 106496 | 4432.1 | 22.1 | 200.1x | 5x | no |
| Withdrawal.serialize | medium-fixture | 44 | 106496 | 4357.0 | 22.5 | 194.1x | 5x | no |
| Withdrawal.serialize | small-fixture | 44 | 90112 | 4816.2 | 25.0 | 192.7x | 5x | no |
| WithdrawalIndex.deserialize | random | 8 | 409600 | 1267.1 | 35.9 | 35.3x | 5x | no |
| WithdrawalIndex.deserialize | saturated | 8 | 409600 | 1252.4 | 40.4 | 31.0x | 5x | no |
| WithdrawalIndex.deserialize | zero | 8 | 253952 | 1216.8 | 36.1 | 33.7x | 5x | no |
| WithdrawalIndex.hash_tree_root | random | 8 | 98304 | 4598.0 | 202.9 | 22.7x | 10x | no |
| WithdrawalIndex.hash_tree_root | saturated | 8 | 98304 | 4618.3 | 226.2 | 20.4x | 10x | no |
| WithdrawalIndex.hash_tree_root | zero | 8 | 106496 | 4582.3 | 183.2 | 25.0x | 10x | no |
| WithdrawalIndex.serialize | random | 8 | 524288 | 715.3 | 12.4 | 57.9x | 5x | no |
| WithdrawalIndex.serialize | saturated | 8 | 524288 | 682.8 | 12.1 | 56.4x | 5x | no |
| WithdrawalIndex.serialize | zero | 8 | 524288 | 682.8 | 12.1 | 56.5x | 5x | no |
| WithdrawalRequest.deserialize | large-fixture | 76 | 65536 | 7995.6 | 25.6 | 312.4x | 5x | no |
| WithdrawalRequest.deserialize | medium-fixture | 76 | 65536 | 7751.5 | 23.7 | 327.1x | 5x | no |
| WithdrawalRequest.deserialize | small-fixture | 76 | 57344 | 7673.0 | 24.6 | 311.5x | 5x | no |
| WithdrawalRequest.hash_tree_root | large-fixture | 76 | 8192 | 38452.1 | 488.1 | 78.8x | 10x | no |
| WithdrawalRequest.hash_tree_root | medium-fixture | 76 | 8192 | 38818.4 | 488.2 | 79.5x | 10x | no |
| WithdrawalRequest.hash_tree_root | small-fixture | 76 | 8192 | 37597.7 | 486.8 | 77.2x | 10x | no |
| WithdrawalRequest.serialize | large-fixture | 76 | 90112 | 4993.8 | 24.6 | 202.9x | 5x | no |
| WithdrawalRequest.serialize | medium-fixture | 76 | 90112 | 5104.8 | 25.1 | 203.6x | 5x | no |
| WithdrawalRequest.serialize | small-fixture | 76 | 53248 | 4770.1 | 24.8 | 192.6x | 5x | no |
| boolean.deserialize | false | 1 | 524288 | 574.1 | 35.8 | 16.0x | 5x | no |
| boolean.deserialize | true | 1 | 524288 | 570.3 | 35.9 | 15.9x | 5x | no |
| boolean.hash_tree_root | false | 1 | 131072 | 3089.9 | 193.5 | 16.0x | 10x | no |
| boolean.hash_tree_root | true | 1 | 77824 | 3071.0 | 179.5 | 17.1x | 10x | no |
| boolean.serialize | false | 1 | 5000000 | 27.8 | 11.7 | 2.4x | 5x | yes |
| boolean.serialize | true | 1 | 5000000 | 26.6 | 11.9 | 2.2x | 5x | yes |
| uint256.deserialize | random | 32 | 335872 | 1476.8 | 44.4 | 33.3x | 5x | no |
| uint256.deserialize | saturated | 32 | 335872 | 1586.9 | 45.5 | 34.9x | 5x | no |
| uint256.deserialize | zero | 32 | 335872 | 1506.5 | 44.1 | 34.2x | 5x | no |
| uint256.hash_tree_root | random | 32 | 49152 | 5188.0 | 167.8 | 30.9x | 10x | no |
| uint256.hash_tree_root | saturated | 32 | 90112 | 5149.1 | 169.9 | 30.3x | 10x | no |
| uint256.hash_tree_root | zero | 32 | 90112 | 5304.5 | 167.5 | 31.7x | 10x | no |
| uint256.serialize | random | 32 | 524288 | 894.5 | 18.5 | 48.5x | 5x | no |
| uint256.serialize | saturated | 32 | 253952 | 921.4 | 18.2 | 50.5x | 5x | no |
| uint256.serialize | zero | 32 | 507904 | 905.7 | 17.5 | 51.7x | 5x | no |
| uint32.deserialize | random | 4 | 507904 | 949.0 | 36.9 | 25.8x | 5x | no |
| uint32.deserialize | saturated | 4 | 524288 | 818.3 | 31.3 | 26.2x | 5x | no |
| uint32.deserialize | zero | 4 | 507904 | 974.6 | 37.4 | 26.0x | 5x | no |
| uint32.hash_tree_root | random | 4 | 131072 | 3593.4 | 155.5 | 23.1x | 10x | no |
| uint32.hash_tree_root | saturated | 4 | 131072 | 3616.3 | 161.8 | 22.4x | 10x | no |
| uint32.hash_tree_root | zero | 4 | 57344 | 4342.2 | 214.5 | 20.2x | 10x | no |
| uint32.serialize | random | 4 | 524288 | 518.8 | 9.2 | 56.5x | 5x | no |
| uint32.serialize | saturated | 4 | 524288 | 530.2 | 9.4 | 56.5x | 5x | no |
| uint32.serialize | zero | 4 | 524288 | 639.0 | 11.4 | 56.0x | 5x | no |
| uint64.deserialize | random | 8 | 507904 | 1021.8 | 29.8 | 34.3x | 5x | no |
| uint64.deserialize | saturated | 8 | 507904 | 1019.9 | 29.9 | 34.1x | 5x | no |
| uint64.deserialize | zero | 8 | 507904 | 1023.8 | 30.2 | 33.9x | 5x | no |
| uint64.hash_tree_root | random | 8 | 122880 | 3686.5 | 147.3 | 25.0x | 10x | no |
| uint64.hash_tree_root | saturated | 8 | 131072 | 3685.0 | 156.8 | 23.5x | 10x | no |
| uint64.hash_tree_root | zero | 8 | 122880 | 3727.2 | 147.8 | 25.2x | 10x | no |
| uint64.serialize | random | 8 | 524288 | 587.5 | 10.4 | 56.4x | 5x | no |
| uint64.serialize | saturated | 8 | 524288 | 560.8 | 9.7 | 58.0x | 5x | no |
| uint64.serialize | zero | 8 | 524288 | 560.8 | 9.7 | 58.1x | 5x | no |
| uint8.deserialize | random | 1 | 524288 | 778.2 | 35.2 | 22.1x | 5x | no |
| uint8.deserialize | saturated | 1 | 524288 | 778.2 | 34.8 | 22.3x | 5x | no |
| uint8.deserialize | zero | 1 | 524288 | 751.5 | 35.1 | 21.4x | 5x | no |
| uint8.hash_tree_root | random | 1 | 106496 | 4357.0 | 194.9 | 22.4x | 10x | no |
| uint8.hash_tree_root | saturated | 1 | 114688 | 4464.3 | 194.6 | 22.9x | 10x | no |
| uint8.hash_tree_root | zero | 1 | 114688 | 4246.3 | 178.6 | 23.8x | 10x | no |
| uint8.serialize | random | 1 | 524288 | 604.6 | 10.7 | 56.6x | 5x | no |
| uint8.serialize | saturated | 1 | 524288 | 598.9 | 11.1 | 53.9x | 5x | no |
| uint8.serialize | zero | 1 | 524288 | 583.6 | 10.4 | 56.0x | 5x | no |

## Malformed input

The runner also feeds each workload back to both implementations with a byte
removed, a byte appended and - where the type is variable size - a first offset
outside the region, and records whether each implementation refused it.

* 685 malformed inputs; Bend refused 642, the
  reference refused 642, disagreements: 0.

(Not every mutation is invalid: appending a byte to a byte list is still a
valid value of that type. What matters is that the two implementations make
the same decision on every one of them.)

Per-sample timings, batch sizes, workload sources, source hashes and artifact
hashes are in the report JSON; the raw runner log is build/performance/benchmark.log.
