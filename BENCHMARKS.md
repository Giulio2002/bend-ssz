> Historical view-API measurements, not current object-codec acceptance.

# Native SSZ benchmarks — Bend C versus Go fastssz

Reproduce exactly these numbers with:

```
python3 benchmarks/run.py --report build/performance/report.json
python3 tools/generate_benchmarks_md.py build/performance/report.json
```

The frozen operator gate that reads the same report is
`python3 automation/performance_gate.py`.

## Method

Both sides are native and built fresh by the runner, one sequential thread each.
Bend is the **compact primary API** through its native C backend, run with
`--threads 1 --gpu off`; one program per operation, built from
`benchmarks/compact/{dec,enc,root}.bend` under a compile-memory cap (every
attempt is recorded in the report's `bend_compiles`). Go is pinned fastssz via
go-eth2-client, built with `go build` and run with `GOMAXPROCS(1)`. No
Bun/JavaScript result appears here.

What each operation is:

| operation | Bend (compact API) | Go fastssz |
|---|---|---|
| deserialize | `API.validate(schema, size, buf)`: validate the whole encoding in place; the validated buffer is the decoded value | `UnmarshalSSZ` into the generated struct |
| serialize | `A.encode(view, buf)`: a fresh packed buffer holding the encoding (a block copy for a whole-buffer view), after one untimed decode | `MarshalSSZ` after one untimed decode |
| hash_tree_root | `API.root(schema, size, buf)` on a buffer the decode program accepted in the verification step | `HashTreeRoot` after one untimed decode |

Reading the workload into a buffer and selecting the schema are outside every
timed region on both sides. Each row is one type, one workload and one
operation. Each side calibrates its own repetition count toward a 0.25 s
sample (capped at five million operations) and repeats the operation that
many times inside one timed region, consuming every result. Timings are
normalised by that side's own count: `operations_per_sample` is the Bend
count and `reference_operations_per_sample` the Go count, both in the report.
At least five samples per side alternate between the implementations in fresh
processes. The ratio is median(Bend ns/op) / median(Go ns/op) per workload, with
no aggregation across workloads. Capped batches of very fast operations (a few
nanoseconds) are the ones most exposed to timer resolution.

Before any timing, both implementations must round-trip the exact workload
bytes (Bend: decode then `A.encode`, output compared byte for byte) and agree
on the checksum of the hash tree root, and on official fixtures that checksum
must equal the official root's. That agreement is what `verified` means.

Stated plainly:

* Bend's decoded value is a validated view of the input buffer, while Go
  copies byte fields into a typed struct. Decode does every check the
  specification requires, but it builds nothing, and that favours Bend.
  Where every byte string of the right length is valid (plain schemas such
  as `Blob` or `Checkpoint`), decode is a length check, and those rows show
  ratios near 0.
* Go's SHA-256 uses the CPU's SHA instructions. Bend uses the pinned
  pure-Bend package, which by instruction may not be replaced with hardware
  SHA, foreign crypto or intrinsics. Per 64-byte node that is about 0.26 us
  against Go's ~0.06 us, so `hash_tree_root` starts about 4x behind before
  any walking overhead.
* The machine was not idle: other user processes ran throughout. Samples
  alternate between the two sides, so the load affects both.

| environment | |
|---|---|
| cpu | Apple M4 |
| os | macOS-15.6-arm64-arm-64bit |
| bend_compiler | bend 2.0.16 |
| reference_compiler | go version go1.25.5 darwin/arm64 |
| bend_flags | --threads 1 --gpu off (native C backend, release build) |
| reference_flags | go build (release defaults), GOMAXPROCS=1 |
| reference_revision | go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod) |

## Result against the frozen contract

* 978 measured workloads covering 327 of the 327 required operations.
* 978 of 978 workloads are within their operation limit (deserialize/serialize 5x, hash_tree_root 10x).

Ratio distribution over all measured workloads: minimum 0.0x, median 0.7x, maximum 7.6x.

* `deserialize`: 326 workloads, minimum 0.0x, median 0.2x, maximum 4.9x (limit 5x).
* `serialize`: 326 workloads, minimum 0.4x, median 0.8x, maximum 3.9x (limit 5x).
* `hash_tree_root`: 326 workloads, minimum 0.3x, median 4.2x, maximum 7.6x (limit 10x).

## What the numbers say

Every measured workload is within its limit.

## All measured workloads

| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |
|---|---|---:|---:|---:|---:|---:|---:|:--:|
| AggregateAndProof.deserialize | large-fixture | 346 | 524288 | 587.5 | 137.4 | 4.3x | 5x | yes |
| AggregateAndProof.deserialize | medium-fixture | 345 | 524288 | 560.8 | 149.9 | 3.7x | 5x | yes |
| AggregateAndProof.deserialize | small-fixture | 345 | 524288 | 549.3 | 134.8 | 4.1x | 5x | yes |
| AggregateAndProof.hash_tree_root | large-fixture | 346 | 32768 | 13458.3 | 2577.6 | 5.2x | 10x | yes |
| AggregateAndProof.hash_tree_root | medium-fixture | 345 | 40960 | 10376.0 | 1924.1 | 5.4x | 10x | yes |
| AggregateAndProof.hash_tree_root | small-fixture | 345 | 32768 | 13061.5 | 2521.5 | 5.2x | 10x | yes |
| AggregateAndProof.serialize | large-fixture | 346 | 5000000 | 52.8 | 50.2 | 1.1x | 5x | yes |
| AggregateAndProof.serialize | medium-fixture | 345 | 5000000 | 50.2 | 48.9 | 1.0x | 5x | yes |
| AggregateAndProof.serialize | small-fixture | 345 | 5000000 | 48.2 | 47.2 | 1.0x | 5x | yes |
| Attestation.deserialize | large-fixture | 237 | 1572864 | 271.5 | 106.6 | 2.5x | 5x | yes |
| Attestation.deserialize | medium-fixture | 237 | 1048576 | 257.5 | 102.4 | 2.5x | 5x | yes |
| Attestation.deserialize | small-fixture | 237 | 1572864 | 263.2 | 103.7 | 2.5x | 5x | yes |
| Attestation.hash_tree_root | large-fixture | 237 | 49152 | 10396.3 | 2154.4 | 4.8x | 10x | yes |
| Attestation.hash_tree_root | medium-fixture | 237 | 40960 | 9887.7 | 2000.1 | 4.9x | 10x | yes |
| Attestation.hash_tree_root | small-fixture | 237 | 49152 | 8931.5 | 1181.4 | 7.6x | 10x | yes |
| Attestation.serialize | large-fixture | 237 | 5000000 | 25.4 | 35.5 | 0.7x | 5x | yes |
| Attestation.serialize | medium-fixture | 237 | 5000000 | 27.4 | 39.7 | 0.7x | 5x | yes |
| Attestation.serialize | small-fixture | 237 | 5000000 | 23.8 | 34.6 | 0.7x | 5x | yes |
| AttestationData.deserialize | large-fixture | 128 | 5000000 | 7.2 | 50.9 | 0.1x | 5x | yes |
| AttestationData.deserialize | medium-fixture | 128 | 5000000 | 6.6 | 50.8 | 0.1x | 5x | yes |
| AttestationData.deserialize | small-fixture | 128 | 5000000 | 6.8 | 51.3 | 0.1x | 5x | yes |
| AttestationData.hash_tree_root | large-fixture | 128 | 114688 | 4002.2 | 748.1 | 5.3x | 10x | yes |
| AttestationData.hash_tree_root | medium-fixture | 128 | 106496 | 3990.8 | 771.3 | 5.2x | 10x | yes |
| AttestationData.hash_tree_root | small-fixture | 128 | 114688 | 3949.8 | 735.1 | 5.4x | 10x | yes |
| AttestationData.serialize | large-fixture | 128 | 5000000 | 17.2 | 25.8 | 0.7x | 5x | yes |
| AttestationData.serialize | medium-fixture | 128 | 5000000 | 17.4 | 25.9 | 0.7x | 5x | yes |
| AttestationData.serialize | small-fixture | 128 | 5000000 | 17.2 | 26.4 | 0.7x | 5x | yes |
| AttesterSlashing.deserialize | large-fixture | 624 | 524288 | 663.8 | 238.9 | 2.8x | 5x | yes |
| AttesterSlashing.deserialize | medium-fixture | 552 | 524288 | 669.5 | 232.7 | 2.9x | 5x | yes |
| AttesterSlashing.deserialize | small-fixture | 512 | 524288 | 671.4 | 229.4 | 2.9x | 5x | yes |
| AttesterSlashing.hash_tree_root | large-fixture | 624 | 16384 | 26001.0 | 5446.9 | 4.8x | 10x | yes |
| AttesterSlashing.hash_tree_root | medium-fixture | 552 | 16384 | 25695.8 | 5294.8 | 4.9x | 10x | yes |
| AttesterSlashing.hash_tree_root | small-fixture | 512 | 16384 | 25390.6 | 5255.8 | 4.8x | 10x | yes |
| AttesterSlashing.serialize | large-fixture | 624 | 4718592 | 96.4 | 89.8 | 1.1x | 5x | yes |
| AttesterSlashing.serialize | medium-fixture | 552 | 4718592 | 94.5 | 76.6 | 1.2x | 5x | yes |
| AttesterSlashing.serialize | small-fixture | 512 | 5000000 | 52.6 | 68.5 | 0.8x | 5x | yes |
| BLSPubkey.deserialize | random | 48 | 5000000 | 5.2 | 36.4 | 0.1x | 5x | yes |
| BLSPubkey.deserialize | saturated | 48 | 5000000 | 5.2 | 37.4 | 0.1x | 5x | yes |
| BLSPubkey.deserialize | zero | 48 | 5000000 | 5.2 | 36.0 | 0.1x | 5x | yes |
| BLSPubkey.hash_tree_root | random | 48 | 1048576 | 424.4 | 284.6 | 1.5x | 10x | yes |
| BLSPubkey.hash_tree_root | saturated | 48 | 1048576 | 428.2 | 285.9 | 1.5x | 10x | yes |
| BLSPubkey.hash_tree_root | zero | 48 | 1048576 | 418.7 | 284.5 | 1.5x | 10x | yes |
| BLSPubkey.serialize | random | 48 | 5000000 | 12.0 | 18.3 | 0.7x | 5x | yes |
| BLSPubkey.serialize | saturated | 48 | 5000000 | 12.2 | 17.9 | 0.7x | 5x | yes |
| BLSPubkey.serialize | zero | 48 | 5000000 | 12.4 | 17.6 | 0.7x | 5x | yes |
| BLSSignature.deserialize | random | 96 | 5000000 | 5.4 | 41.7 | 0.1x | 5x | yes |
| BLSSignature.deserialize | saturated | 96 | 5000000 | 5.2 | 40.9 | 0.1x | 5x | yes |
| BLSSignature.deserialize | zero | 96 | 5000000 | 5.4 | 41.8 | 0.1x | 5x | yes |
| BLSSignature.hash_tree_root | random | 96 | 409600 | 1074.2 | 462.6 | 2.3x | 10x | yes |
| BLSSignature.hash_tree_root | saturated | 96 | 409600 | 1064.5 | 467.1 | 2.3x | 10x | yes |
| BLSSignature.hash_tree_root | zero | 96 | 253952 | 1078.9 | 469.1 | 2.3x | 10x | yes |
| BLSSignature.serialize | random | 96 | 5000000 | 17.4 | 22.3 | 0.8x | 5x | yes |
| BLSSignature.serialize | saturated | 96 | 5000000 | 17.6 | 21.2 | 0.8x | 5x | yes |
| BLSSignature.serialize | zero | 96 | 5000000 | 17.2 | 21.3 | 0.8x | 5x | yes |
| BLSToExecutionChange.deserialize | large-fixture | 76 | 5000000 | 6.8 | 19.4 | 0.4x | 5x | yes |
| BLSToExecutionChange.deserialize | medium-fixture | 76 | 5000000 | 7.4 | 20.3 | 0.4x | 5x | yes |
| BLSToExecutionChange.deserialize | small-fixture | 76 | 5000000 | 6.8 | 19.3 | 0.4x | 5x | yes |
| BLSToExecutionChange.hash_tree_root | large-fixture | 76 | 253952 | 1862.6 | 391.6 | 4.8x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | medium-fixture | 76 | 221184 | 1822.0 | 396.0 | 4.6x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | small-fixture | 76 | 253952 | 1882.2 | 394.6 | 4.8x | 10x | yes |
| BLSToExecutionChange.serialize | large-fixture | 76 | 5000000 | 17.4 | 21.9 | 0.8x | 5x | yes |
| BLSToExecutionChange.serialize | medium-fixture | 76 | 5000000 | 18.4 | 23.1 | 0.8x | 5x | yes |
| BLSToExecutionChange.serialize | small-fixture | 76 | 5000000 | 17.2 | 21.1 | 0.8x | 5x | yes |
| BeaconBlock.deserialize | large-fixture | 21487 | 49152 | 5594.9 | 11917.1 | 0.5x | 5x | yes |
| BeaconBlock.deserialize | medium-fixture | 21424 | 106496 | 4892.2 | 10427.3 | 0.5x | 5x | yes |
| BeaconBlock.deserialize | small-fixture | 11198 | 114688 | 4324.8 | 3318.7 | 1.3x | 5x | yes |
| BeaconBlock.hash_tree_root | large-fixture | 21487 | 1152 | 398437.5 | 81234.6 | 4.9x | 10x | yes |
| BeaconBlock.hash_tree_root | medium-fixture | 21424 | 1024 | 462890.6 | 100177.4 | 4.6x | 10x | yes |
| BeaconBlock.hash_tree_root | small-fixture | 11198 | 1408 | 336647.7 | 68968.9 | 4.9x | 10x | yes |
| BeaconBlock.serialize | large-fixture | 21487 | 180224 | 2308.2 | 1495.2 | 1.5x | 5x | yes |
| BeaconBlock.serialize | medium-fixture | 21424 | 180224 | 2596.8 | 1541.0 | 1.7x | 5x | yes |
| BeaconBlock.serialize | small-fixture | 11198 | 204800 | 1323.2 | 975.2 | 1.4x | 5x | yes |
| BeaconBlockBody.deserialize | large-fixture | 24042 | 90112 | 5204.6 | 10483.8 | 0.5x | 5x | yes |
| BeaconBlockBody.deserialize | medium-fixture | 19087 | 102400 | 2714.8 | 7509.2 | 0.4x | 5x | yes |
| BeaconBlockBody.deserialize | small-fixture | 11894 | 114688 | 4359.7 | 4745.2 | 0.9x | 5x | yes |
| BeaconBlockBody.hash_tree_root | large-fixture | 24042 | 896 | 465401.8 | 99363.0 | 4.7x | 10x | yes |
| BeaconBlockBody.hash_tree_root | medium-fixture | 19087 | 1152 | 394965.3 | 84736.3 | 4.7x | 10x | yes |
| BeaconBlockBody.hash_tree_root | small-fixture | 11894 | 1408 | 289062.5 | 61138.8 | 4.7x | 10x | yes |
| BeaconBlockBody.serialize | large-fixture | 24042 | 204800 | 2299.8 | 1700.0 | 1.4x | 5x | yes |
| BeaconBlockBody.serialize | medium-fixture | 19087 | 204800 | 2338.9 | 1367.3 | 1.7x | 5x | yes |
| BeaconBlockBody.serialize | small-fixture | 11894 | 409600 | 1142.6 | 876.0 | 1.3x | 5x | yes |
| BeaconBlockHeader.deserialize | large-fixture | 112 | 5000000 | 6.0 | 19.3 | 0.3x | 5x | yes |
| BeaconBlockHeader.deserialize | medium-fixture | 112 | 5000000 | 5.8 | 18.2 | 0.3x | 5x | yes |
| BeaconBlockHeader.deserialize | small-fixture | 112 | 5000000 | 6.4 | 19.2 | 0.3x | 5x | yes |
| BeaconBlockHeader.hash_tree_root | large-fixture | 112 | 180224 | 2424.8 | 492.9 | 4.9x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | medium-fixture | 112 | 180224 | 2441.4 | 494.1 | 4.9x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | small-fixture | 112 | 163840 | 2526.9 | 509.3 | 5.0x | 10x | yes |
| BeaconBlockHeader.serialize | large-fixture | 112 | 5000000 | 16.0 | 21.7 | 0.7x | 5x | yes |
| BeaconBlockHeader.serialize | medium-fixture | 112 | 5000000 | 16.2 | 22.5 | 0.7x | 5x | yes |
| BeaconBlockHeader.serialize | small-fixture | 112 | 5000000 | 18.4 | 25.1 | 0.7x | 5x | yes |
| BeaconState.deserialize | large-fixture | 2741095 | 106496 | 4920.4 | 250468.7 | 0.0x | 5x | yes |
| BeaconState.deserialize | medium-fixture | 2740473 | 114688 | 5161.8 | 258286.7 | 0.0x | 5x | yes |
| BeaconState.deserialize | small-fixture | 2738771 | 180224 | 2868.7 | 215379.1 | 0.0x | 5x | yes |
| BeaconState.hash_tree_root | large-fixture | 2741095 | 16 | 29187500.0 | 8299183.6 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | medium-fixture | 2740473 | 14 | 30428571.4 | 8733881.1 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | small-fixture | 2738771 | 18 | 25777777.8 | 7454850.5 | 3.5x | 10x | yes |
| BeaconState.serialize | large-fixture | 2741095 | 1280 | 325781.2 | 219856.7 | 1.5x | 5x | yes |
| BeaconState.serialize | medium-fixture | 2740473 | 1280 | 367968.8 | 244008.0 | 1.5x | 5x | yes |
| BeaconState.serialize | small-fixture | 2738771 | 1536 | 290364.6 | 198191.4 | 1.5x | 5x | yes |
| Blob.deserialize | random | 131072 | 5000000 | 5.6 | 6712.0 | 0.0x | 5x | yes |
| Blob.deserialize | saturated | 131072 | 5000000 | 5.2 | 6562.7 | 0.0x | 5x | yes |
| Blob.deserialize | zero | 131072 | 5000000 | 5.6 | 6708.9 | 0.0x | 5x | yes |
| Blob.hash_tree_root | random | 131072 | 256 | 1328125.0 | 333008.6 | 4.0x | 10x | yes |
| Blob.hash_tree_root | saturated | 131072 | 256 | 1308593.8 | 331399.5 | 3.9x | 10x | yes |
| Blob.hash_tree_root | zero | 131072 | 256 | 1332031.2 | 338111.3 | 3.9x | 10x | yes |
| Blob.serialize | random | 131072 | 40960 | 10253.9 | 5086.3 | 2.0x | 5x | yes |
| Blob.serialize | saturated | 131072 | 49152 | 9928.4 | 4950.2 | 2.0x | 5x | yes |
| Blob.serialize | zero | 131072 | 40960 | 10253.9 | 5068.6 | 2.0x | 5x | yes |
| BlobIdentifier.deserialize | large-fixture | 40 | 5000000 | 5.8 | 14.0 | 0.4x | 5x | yes |
| BlobIdentifier.deserialize | medium-fixture | 40 | 5000000 | 7.0 | 17.5 | 0.4x | 5x | yes |
| BlobIdentifier.deserialize | small-fixture | 40 | 5000000 | 6.4 | 16.3 | 0.4x | 5x | yes |
| BlobIdentifier.hash_tree_root | large-fixture | 40 | 524288 | 618.0 | 115.2 | 5.4x | 10x | yes |
| BlobIdentifier.hash_tree_root | medium-fixture | 40 | 524288 | 682.8 | 117.3 | 5.8x | 10x | yes |
| BlobIdentifier.hash_tree_root | small-fixture | 40 | 524288 | 719.1 | 131.7 | 5.5x | 10x | yes |
| BlobIdentifier.serialize | large-fixture | 40 | 5000000 | 10.0 | 15.9 | 0.6x | 5x | yes |
| BlobIdentifier.serialize | medium-fixture | 40 | 5000000 | 12.6 | 20.1 | 0.6x | 5x | yes |
| BlobIdentifier.serialize | small-fixture | 40 | 5000000 | 11.6 | 18.5 | 0.6x | 5x | yes |
| BlobIndex.deserialize | random | 8 | 5000000 | 4.4 | 28.3 | 0.2x | 5x | yes |
| BlobIndex.deserialize | saturated | 8 | 5000000 | 4.6 | 27.9 | 0.2x | 5x | yes |
| BlobIndex.deserialize | zero | 8 | 5000000 | 4.6 | 29.8 | 0.2x | 5x | yes |
| BlobIndex.hash_tree_root | random | 8 | 5000000 | 47.6 | 157.4 | 0.3x | 10x | yes |
| BlobIndex.hash_tree_root | saturated | 8 | 5000000 | 47.8 | 157.9 | 0.3x | 10x | yes |
| BlobIndex.hash_tree_root | zero | 8 | 5000000 | 49.4 | 159.2 | 0.3x | 10x | yes |
| BlobIndex.serialize | random | 8 | 5000000 | 7.4 | 9.8 | 0.8x | 5x | yes |
| BlobIndex.serialize | saturated | 8 | 5000000 | 7.2 | 9.9 | 0.7x | 5x | yes |
| BlobIndex.serialize | zero | 8 | 5000000 | 7.8 | 10.4 | 0.7x | 5x | yes |
| BlobSidecar.deserialize | large-fixture | 131928 | 5000000 | 7.0 | 6524.9 | 0.0x | 5x | yes |
| BlobSidecar.deserialize | medium-fixture | 131928 | 5000000 | 6.8 | 5976.4 | 0.0x | 5x | yes |
| BlobSidecar.deserialize | small-fixture | 131928 | 5000000 | 5.8 | 6232.7 | 0.0x | 5x | yes |
| BlobSidecar.hash_tree_root | large-fixture | 131928 | 256 | 1402343.8 | 342720.2 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | medium-fixture | 131928 | 256 | 1437500.0 | 352974.3 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | small-fixture | 131928 | 256 | 1371093.8 | 333554.5 | 4.1x | 10x | yes |
| BlobSidecar.serialize | large-fixture | 131928 | 16384 | 21240.2 | 5654.3 | 3.8x | 5x | yes |
| BlobSidecar.serialize | medium-fixture | 131928 | 16384 | 21545.4 | 5701.8 | 3.8x | 5x | yes |
| BlobSidecar.serialize | small-fixture | 131928 | 12288 | 20914.7 | 5412.0 | 3.9x | 5x | yes |
| Bytes1.deserialize | random | 1 | 5000000 | 5.6 | 32.0 | 0.2x | 5x | yes |
| Bytes1.deserialize | saturated | 1 | 5000000 | 5.8 | 33.9 | 0.2x | 5x | yes |
| Bytes1.deserialize | zero | 1 | 5000000 | 5.2 | 31.3 | 0.2x | 5x | yes |
| Bytes1.hash_tree_root | random | 1 | 5000000 | 60.0 | 189.7 | 0.3x | 10x | yes |
| Bytes1.hash_tree_root | saturated | 1 | 5000000 | 56.6 | 188.0 | 0.3x | 10x | yes |
| Bytes1.hash_tree_root | zero | 1 | 5000000 | 55.6 | 182.1 | 0.3x | 10x | yes |
| Bytes1.serialize | random | 1 | 5000000 | 8.6 | 10.6 | 0.8x | 5x | yes |
| Bytes1.serialize | saturated | 1 | 5000000 | 8.8 | 10.7 | 0.8x | 5x | yes |
| Bytes1.serialize | zero | 1 | 5000000 | 8.2 | 10.5 | 0.8x | 5x | yes |
| Bytes20.deserialize | random | 20 | 5000000 | 5.6 | 36.8 | 0.2x | 5x | yes |
| Bytes20.deserialize | saturated | 20 | 5000000 | 5.4 | 37.3 | 0.1x | 5x | yes |
| Bytes20.deserialize | zero | 20 | 5000000 | 5.6 | 37.2 | 0.2x | 5x | yes |
| Bytes20.hash_tree_root | random | 20 | 5000000 | 53.2 | 187.8 | 0.3x | 10x | yes |
| Bytes20.hash_tree_root | saturated | 20 | 4980736 | 54.6 | 186.1 | 0.3x | 10x | yes |
| Bytes20.hash_tree_root | zero | 20 | 5000000 | 54.6 | 197.0 | 0.3x | 10x | yes |
| Bytes20.serialize | random | 20 | 5000000 | 9.6 | 17.2 | 0.6x | 5x | yes |
| Bytes20.serialize | saturated | 20 | 5000000 | 9.8 | 17.4 | 0.6x | 5x | yes |
| Bytes20.serialize | zero | 20 | 5000000 | 9.8 | 17.3 | 0.6x | 5x | yes |
| Bytes32.deserialize | random | 32 | 5000000 | 5.6 | 37.4 | 0.1x | 5x | yes |
| Bytes32.deserialize | saturated | 32 | 5000000 | 5.6 | 37.3 | 0.2x | 5x | yes |
| Bytes32.deserialize | zero | 32 | 5000000 | 5.6 | 37.8 | 0.1x | 5x | yes |
| Bytes32.hash_tree_root | random | 32 | 5000000 | 46.8 | 155.9 | 0.3x | 10x | yes |
| Bytes32.hash_tree_root | saturated | 32 | 5000000 | 49.4 | 160.2 | 0.3x | 10x | yes |
| Bytes32.hash_tree_root | zero | 32 | 5000000 | 48.6 | 159.0 | 0.3x | 10x | yes |
| Bytes32.serialize | random | 32 | 5000000 | 9.8 | 17.5 | 0.6x | 5x | yes |
| Bytes32.serialize | saturated | 32 | 5000000 | 9.4 | 16.5 | 0.6x | 5x | yes |
| Bytes32.serialize | zero | 32 | 5000000 | 9.8 | 17.5 | 0.6x | 5x | yes |
| Bytes4.deserialize | random | 4 | 5000000 | 5.6 | 33.8 | 0.2x | 5x | yes |
| Bytes4.deserialize | saturated | 4 | 5000000 | 5.6 | 33.7 | 0.2x | 5x | yes |
| Bytes4.deserialize | zero | 4 | 5000000 | 5.4 | 33.8 | 0.2x | 5x | yes |
| Bytes4.hash_tree_root | random | 4 | 4980736 | 54.6 | 177.5 | 0.3x | 10x | yes |
| Bytes4.hash_tree_root | saturated | 4 | 5000000 | 53.6 | 179.6 | 0.3x | 10x | yes |
| Bytes4.hash_tree_root | zero | 4 | 4980736 | 52.8 | 185.0 | 0.3x | 10x | yes |
| Bytes4.serialize | random | 4 | 5000000 | 8.2 | 11.1 | 0.7x | 5x | yes |
| Bytes4.serialize | saturated | 4 | 5000000 | 8.2 | 10.9 | 0.8x | 5x | yes |
| Bytes4.serialize | zero | 4 | 5000000 | 8.0 | 11.1 | 0.7x | 5x | yes |
| Bytes48.deserialize | random | 48 | 5000000 | 5.6 | 38.8 | 0.1x | 5x | yes |
| Bytes48.deserialize | saturated | 48 | 5000000 | 4.4 | 30.6 | 0.1x | 5x | yes |
| Bytes48.deserialize | zero | 48 | 5000000 | 5.6 | 40.1 | 0.1x | 5x | yes |
| Bytes48.hash_tree_root | random | 48 | 1048576 | 389.1 | 256.0 | 1.5x | 10x | yes |
| Bytes48.hash_tree_root | saturated | 48 | 1048576 | 371.9 | 247.0 | 1.5x | 10x | yes |
| Bytes48.hash_tree_root | zero | 48 | 1048576 | 434.9 | 289.1 | 1.5x | 10x | yes |
| Bytes48.serialize | random | 48 | 5000000 | 12.6 | 18.3 | 0.7x | 5x | yes |
| Bytes48.serialize | saturated | 48 | 5000000 | 10.4 | 15.5 | 0.7x | 5x | yes |
| Bytes48.serialize | zero | 48 | 5000000 | 12.8 | 18.7 | 0.7x | 5x | yes |
| Bytes8.deserialize | random | 8 | 5000000 | 5.0 | 29.9 | 0.2x | 5x | yes |
| Bytes8.deserialize | saturated | 8 | 5000000 | 5.2 | 30.9 | 0.2x | 5x | yes |
| Bytes8.deserialize | zero | 8 | 5000000 | 5.0 | 29.8 | 0.2x | 5x | yes |
| Bytes8.hash_tree_root | random | 8 | 4980736 | 50.0 | 167.5 | 0.3x | 10x | yes |
| Bytes8.hash_tree_root | saturated | 8 | 5000000 | 53.0 | 175.6 | 0.3x | 10x | yes |
| Bytes8.hash_tree_root | zero | 8 | 5000000 | 49.8 | 164.6 | 0.3x | 10x | yes |
| Bytes8.serialize | random | 8 | 5000000 | 7.4 | 10.0 | 0.7x | 5x | yes |
| Bytes8.serialize | saturated | 8 | 5000000 | 8.4 | 11.4 | 0.7x | 5x | yes |
| Bytes8.serialize | zero | 8 | 5000000 | 7.8 | 10.4 | 0.7x | 5x | yes |
| Bytes96.deserialize | random | 96 | 5000000 | 5.2 | 41.5 | 0.1x | 5x | yes |
| Bytes96.deserialize | saturated | 96 | 5000000 | 5.2 | 40.0 | 0.1x | 5x | yes |
| Bytes96.deserialize | zero | 96 | 5000000 | 5.4 | 41.3 | 0.1x | 5x | yes |
| Bytes96.hash_tree_root | random | 96 | 409600 | 1106.0 | 470.6 | 2.4x | 10x | yes |
| Bytes96.hash_tree_root | saturated | 96 | 409600 | 1054.7 | 452.5 | 2.3x | 10x | yes |
| Bytes96.hash_tree_root | zero | 96 | 409600 | 1120.6 | 470.3 | 2.4x | 10x | yes |
| Bytes96.serialize | random | 96 | 5000000 | 18.4 | 21.8 | 0.8x | 5x | yes |
| Bytes96.serialize | saturated | 96 | 5000000 | 17.2 | 22.2 | 0.8x | 5x | yes |
| Bytes96.serialize | zero | 96 | 5000000 | 17.4 | 21.6 | 0.8x | 5x | yes |
| Cell.deserialize | random | 2048 | 5000000 | 5.2 | 203.3 | 0.0x | 5x | yes |
| Cell.deserialize | saturated | 2048 | 5000000 | 5.0 | 195.9 | 0.0x | 5x | yes |
| Cell.deserialize | zero | 2048 | 5000000 | 5.0 | 197.8 | 0.0x | 5x | yes |
| Cell.hash_tree_root | random | 2048 | 16384 | 20568.8 | 5547.7 | 3.7x | 10x | yes |
| Cell.hash_tree_root | saturated | 2048 | 24576 | 20182.3 | 5438.2 | 3.7x | 10x | yes |
| Cell.hash_tree_root | zero | 2048 | 16384 | 21057.1 | 5584.4 | 3.8x | 10x | yes |
| Cell.serialize | random | 2048 | 2621440 | 170.9 | 170.1 | 1.0x | 5x | yes |
| Cell.serialize | saturated | 2048 | 2621440 | 166.7 | 171.5 | 1.0x | 5x | yes |
| Cell.serialize | zero | 2048 | 2621440 | 170.1 | 171.1 | 1.0x | 5x | yes |
| CellIndex.deserialize | random | 8 | 5000000 | 4.8 | 30.1 | 0.2x | 5x | yes |
| CellIndex.deserialize | saturated | 8 | 5000000 | 4.6 | 30.2 | 0.2x | 5x | yes |
| CellIndex.deserialize | zero | 8 | 5000000 | 4.8 | 30.1 | 0.2x | 5x | yes |
| CellIndex.hash_tree_root | random | 8 | 5000000 | 51.0 | 171.7 | 0.3x | 10x | yes |
| CellIndex.hash_tree_root | saturated | 8 | 5000000 | 50.6 | 168.5 | 0.3x | 10x | yes |
| CellIndex.hash_tree_root | zero | 8 | 4980736 | 49.6 | 171.4 | 0.3x | 10x | yes |
| CellIndex.serialize | random | 8 | 5000000 | 8.0 | 10.7 | 0.7x | 5x | yes |
| CellIndex.serialize | saturated | 8 | 5000000 | 7.6 | 10.6 | 0.7x | 5x | yes |
| CellIndex.serialize | zero | 8 | 5000000 | 7.6 | 10.5 | 0.7x | 5x | yes |
| Checkpoint.deserialize | large-fixture | 40 | 5000000 | 6.4 | 15.5 | 0.4x | 5x | yes |
| Checkpoint.deserialize | medium-fixture | 40 | 5000000 | 6.4 | 15.8 | 0.4x | 5x | yes |
| Checkpoint.deserialize | small-fixture | 40 | 5000000 | 6.4 | 16.2 | 0.4x | 5x | yes |
| Checkpoint.hash_tree_root | large-fixture | 40 | 524288 | 663.8 | 123.2 | 5.4x | 10x | yes |
| Checkpoint.hash_tree_root | medium-fixture | 40 | 524288 | 661.8 | 123.4 | 5.4x | 10x | yes |
| Checkpoint.hash_tree_root | small-fixture | 40 | 524288 | 659.9 | 122.2 | 5.4x | 10x | yes |
| Checkpoint.serialize | large-fixture | 40 | 5000000 | 11.4 | 17.9 | 0.6x | 5x | yes |
| Checkpoint.serialize | medium-fixture | 40 | 5000000 | 11.2 | 18.4 | 0.6x | 5x | yes |
| Checkpoint.serialize | small-fixture | 40 | 5000000 | 11.4 | 18.3 | 0.6x | 5x | yes |
| ColumnIndex.deserialize | random | 8 | 5000000 | 5.0 | 30.3 | 0.2x | 5x | yes |
| ColumnIndex.deserialize | saturated | 8 | 5000000 | 4.8 | 30.6 | 0.2x | 5x | yes |
| ColumnIndex.deserialize | zero | 8 | 5000000 | 4.8 | 30.0 | 0.2x | 5x | yes |
| ColumnIndex.hash_tree_root | random | 8 | 5000000 | 51.2 | 172.8 | 0.3x | 10x | yes |
| ColumnIndex.hash_tree_root | saturated | 8 | 5000000 | 50.4 | 168.5 | 0.3x | 10x | yes |
| ColumnIndex.hash_tree_root | zero | 8 | 4980736 | 50.8 | 172.9 | 0.3x | 10x | yes |
| ColumnIndex.serialize | random | 8 | 5000000 | 7.6 | 10.7 | 0.7x | 5x | yes |
| ColumnIndex.serialize | saturated | 8 | 5000000 | 7.8 | 10.5 | 0.7x | 5x | yes |
| ColumnIndex.serialize | zero | 8 | 5000000 | 7.8 | 10.2 | 0.8x | 5x | yes |
| CommitmentIndex.deserialize | random | 8 | 5000000 | 4.8 | 30.0 | 0.2x | 5x | yes |
| CommitmentIndex.deserialize | saturated | 8 | 5000000 | 4.8 | 31.0 | 0.2x | 5x | yes |
| CommitmentIndex.deserialize | zero | 8 | 5000000 | 4.8 | 30.4 | 0.2x | 5x | yes |
| CommitmentIndex.hash_tree_root | random | 8 | 5000000 | 51.8 | 171.1 | 0.3x | 10x | yes |
| CommitmentIndex.hash_tree_root | saturated | 8 | 5000000 | 51.0 | 172.4 | 0.3x | 10x | yes |
| CommitmentIndex.hash_tree_root | zero | 8 | 5000000 | 52.2 | 171.7 | 0.3x | 10x | yes |
| CommitmentIndex.serialize | random | 8 | 5000000 | 8.0 | 10.4 | 0.8x | 5x | yes |
| CommitmentIndex.serialize | saturated | 8 | 5000000 | 8.0 | 10.5 | 0.8x | 5x | yes |
| CommitmentIndex.serialize | zero | 8 | 5000000 | 7.8 | 11.1 | 0.7x | 5x | yes |
| CommitteeIndex.deserialize | random | 8 | 5000000 | 4.8 | 30.3 | 0.2x | 5x | yes |
| CommitteeIndex.deserialize | saturated | 8 | 5000000 | 4.6 | 30.5 | 0.2x | 5x | yes |
| CommitteeIndex.deserialize | zero | 8 | 5000000 | 4.8 | 30.6 | 0.2x | 5x | yes |
| CommitteeIndex.hash_tree_root | random | 8 | 4980736 | 50.8 | 172.7 | 0.3x | 10x | yes |
| CommitteeIndex.hash_tree_root | saturated | 8 | 4980736 | 51.2 | 176.5 | 0.3x | 10x | yes |
| CommitteeIndex.hash_tree_root | zero | 8 | 5000000 | 52.0 | 177.3 | 0.3x | 10x | yes |
| CommitteeIndex.serialize | random | 8 | 5000000 | 7.6 | 10.6 | 0.7x | 5x | yes |
| CommitteeIndex.serialize | saturated | 8 | 5000000 | 8.0 | 10.4 | 0.8x | 5x | yes |
| CommitteeIndex.serialize | zero | 8 | 5000000 | 7.8 | 10.6 | 0.7x | 5x | yes |
| ConsolidationRequest.deserialize | large-fixture | 116 | 5000000 | 6.4 | 19.7 | 0.3x | 5x | yes |
| ConsolidationRequest.deserialize | medium-fixture | 116 | 5000000 | 6.4 | 21.1 | 0.3x | 5x | yes |
| ConsolidationRequest.deserialize | small-fixture | 116 | 5000000 | 6.6 | 21.1 | 0.3x | 5x | yes |
| ConsolidationRequest.hash_tree_root | large-fixture | 116 | 221184 | 2106.8 | 469.5 | 4.5x | 10x | yes |
| ConsolidationRequest.hash_tree_root | medium-fixture | 116 | 221184 | 2097.8 | 468.9 | 4.5x | 10x | yes |
| ConsolidationRequest.hash_tree_root | small-fixture | 116 | 221184 | 2106.8 | 473.8 | 4.4x | 10x | yes |
| ConsolidationRequest.serialize | large-fixture | 116 | 5000000 | 16.2 | 23.6 | 0.7x | 5x | yes |
| ConsolidationRequest.serialize | medium-fixture | 116 | 5000000 | 16.6 | 23.7 | 0.7x | 5x | yes |
| ConsolidationRequest.serialize | small-fixture | 116 | 5000000 | 16.6 | 22.9 | 0.7x | 5x | yes |
| ContributionAndProof.deserialize | large-fixture | 264 | 5000000 | 6.8 | 77.8 | 0.1x | 5x | yes |
| ContributionAndProof.deserialize | medium-fixture | 264 | 5000000 | 6.8 | 73.4 | 0.1x | 5x | yes |
| ContributionAndProof.deserialize | small-fixture | 264 | 5000000 | 6.8 | 74.9 | 0.1x | 5x | yes |
| ContributionAndProof.hash_tree_root | large-fixture | 264 | 65536 | 5920.4 | 1287.3 | 4.6x | 10x | yes |
| ContributionAndProof.hash_tree_root | medium-fixture | 264 | 73728 | 6524.0 | 1394.1 | 4.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | small-fixture | 264 | 73728 | 6144.2 | 1309.3 | 4.7x | 10x | yes |
| ContributionAndProof.serialize | large-fixture | 264 | 5000000 | 53.0 | 37.7 | 1.4x | 5x | yes |
| ContributionAndProof.serialize | medium-fixture | 264 | 5000000 | 51.6 | 37.2 | 1.4x | 5x | yes |
| ContributionAndProof.serialize | small-fixture | 264 | 5000000 | 50.2 | 37.8 | 1.3x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 6.2 | 48.2 | 0.1x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | saturated | 192 | 5000000 | 5.0 | 41.3 | 0.1x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 5.8 | 46.2 | 0.1x | 5x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | random | 192 | 180224 | 2202.8 | 634.3 | 3.5x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | saturated | 192 | 204800 | 2168.0 | 643.3 | 3.4x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | zero | 192 | 180224 | 2374.8 | 701.6 | 3.4x | 10x | yes |
| CurrentSyncCommitteeBranch.serialize | random | 192 | 5000000 | 27.8 | 26.6 | 1.0x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 24.8 | 24.8 | 1.0x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 27.2 | 26.1 | 1.0x | 5x | yes |
| CustodyIndex.deserialize | random | 8 | 5000000 | 4.4 | 27.8 | 0.2x | 5x | yes |
| CustodyIndex.deserialize | saturated | 8 | 5000000 | 4.4 | 28.1 | 0.2x | 5x | yes |
| CustodyIndex.deserialize | zero | 8 | 5000000 | 4.2 | 26.8 | 0.2x | 5x | yes |
| CustodyIndex.hash_tree_root | random | 8 | 5000000 | 48.0 | 154.9 | 0.3x | 10x | yes |
| CustodyIndex.hash_tree_root | saturated | 8 | 5000000 | 47.4 | 161.5 | 0.3x | 10x | yes |
| CustodyIndex.hash_tree_root | zero | 8 | 5000000 | 49.4 | 156.2 | 0.3x | 10x | yes |
| CustodyIndex.serialize | random | 8 | 5000000 | 7.4 | 10.0 | 0.7x | 5x | yes |
| CustodyIndex.serialize | saturated | 8 | 5000000 | 7.4 | 9.6 | 0.8x | 5x | yes |
| CustodyIndex.serialize | zero | 8 | 5000000 | 7.2 | 9.9 | 0.7x | 5x | yes |
| DataColumnSidecar.deserialize | large-fixture | 19076 | 2097152 | 241.8 | 1997.2 | 0.1x | 5x | yes |
| DataColumnSidecar.deserialize | medium-fixture | 17028 | 1572864 | 269.6 | 1826.4 | 0.1x | 5x | yes |
| DataColumnSidecar.deserialize | small-fixture | 6500 | 2097152 | 234.1 | 740.1 | 0.3x | 5x | yes |
| DataColumnSidecar.hash_tree_root | large-fixture | 19076 | 2432 | 208881.6 | 49514.4 | 4.2x | 10x | yes |
| DataColumnSidecar.hash_tree_root | medium-fixture | 17028 | 2432 | 185855.3 | 43768.9 | 4.2x | 10x | yes |
| DataColumnSidecar.hash_tree_root | small-fixture | 6500 | 5248 | 84984.8 | 20076.0 | 4.2x | 10x | yes |
| DataColumnSidecar.serialize | large-fixture | 19076 | 204800 | 2207.0 | 998.8 | 2.2x | 5x | yes |
| DataColumnSidecar.serialize | medium-fixture | 17028 | 204800 | 2573.2 | 932.9 | 2.8x | 5x | yes |
| DataColumnSidecar.serialize | small-fixture | 6500 | 524288 | 732.4 | 438.5 | 1.7x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | large-fixture | 92 | 3145728 | 156.4 | 62.4 | 2.5x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | medium-fixture | 60 | 3145728 | 154.8 | 59.6 | 2.6x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | small-fixture | 36 | 3145728 | 154.8 | 40.6 | 3.8x | 5x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | large-fixture | 92 | 139264 | 3209.7 | 613.3 | 5.2x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | medium-fixture | 60 | 163840 | 2862.5 | 602.1 | 4.8x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | small-fixture | 36 | 335872 | 1351.7 | 212.4 | 6.4x | 10x | yes |
| DataColumnsByRootIdentifier.serialize | large-fixture | 92 | 5000000 | 16.2 | 25.6 | 0.6x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | medium-fixture | 60 | 5000000 | 11.8 | 21.0 | 0.6x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | small-fixture | 36 | 5000000 | 11.4 | 19.1 | 0.6x | 5x | yes |
| Deposit.deserialize | large-fixture | 1240 | 5000000 | 6.2 | 717.2 | 0.0x | 5x | yes |
| Deposit.deserialize | medium-fixture | 1240 | 5000000 | 6.0 | 702.7 | 0.0x | 5x | yes |
| Deposit.deserialize | small-fixture | 1240 | 5000000 | 6.8 | 733.4 | 0.0x | 5x | yes |
| Deposit.hash_tree_root | large-fixture | 1240 | 32768 | 14129.6 | 3463.9 | 4.1x | 10x | yes |
| Deposit.hash_tree_root | medium-fixture | 1240 | 32768 | 14129.6 | 3413.0 | 4.1x | 10x | yes |
| Deposit.hash_tree_root | small-fixture | 1240 | 24576 | 15258.8 | 3529.9 | 4.3x | 10x | yes |
| Deposit.serialize | large-fixture | 1240 | 2621440 | 153.7 | 112.7 | 1.4x | 5x | yes |
| Deposit.serialize | medium-fixture | 1240 | 2621440 | 154.5 | 118.5 | 1.3x | 5x | yes |
| Deposit.serialize | small-fixture | 1240 | 2621440 | 164.0 | 131.2 | 1.3x | 5x | yes |
| DepositData.deserialize | large-fixture | 184 | 5000000 | 7.2 | 53.5 | 0.1x | 5x | yes |
| DepositData.deserialize | medium-fixture | 184 | 5000000 | 7.4 | 52.5 | 0.1x | 5x | yes |
| DepositData.deserialize | small-fixture | 184 | 5000000 | 5.8 | 42.8 | 0.1x | 5x | yes |
| DepositData.hash_tree_root | large-fixture | 184 | 139264 | 3130.7 | 682.0 | 4.6x | 10x | yes |
| DepositData.hash_tree_root | medium-fixture | 184 | 77824 | 3135.3 | 682.8 | 4.6x | 10x | yes |
| DepositData.hash_tree_root | small-fixture | 184 | 90112 | 2663.4 | 583.4 | 4.6x | 10x | yes |
| DepositData.serialize | large-fixture | 184 | 5000000 | 29.6 | 31.5 | 0.9x | 5x | yes |
| DepositData.serialize | medium-fixture | 184 | 5000000 | 29.8 | 31.5 | 0.9x | 5x | yes |
| DepositData.serialize | small-fixture | 184 | 5000000 | 25.8 | 26.6 | 1.0x | 5x | yes |
| DepositMessage.deserialize | large-fixture | 88 | 5000000 | 7.0 | 42.5 | 0.2x | 5x | yes |
| DepositMessage.deserialize | medium-fixture | 88 | 5000000 | 6.8 | 40.6 | 0.2x | 5x | yes |
| DepositMessage.deserialize | small-fixture | 88 | 5000000 | 7.4 | 43.1 | 0.2x | 5x | yes |
| DepositMessage.hash_tree_root | large-fixture | 88 | 253952 | 1901.9 | 404.7 | 4.7x | 10x | yes |
| DepositMessage.hash_tree_root | medium-fixture | 88 | 253952 | 1913.7 | 409.6 | 4.7x | 10x | yes |
| DepositMessage.hash_tree_root | small-fixture | 88 | 143360 | 1918.2 | 410.6 | 4.7x | 10x | yes |
| DepositMessage.serialize | large-fixture | 88 | 5000000 | 18.2 | 24.0 | 0.8x | 5x | yes |
| DepositMessage.serialize | medium-fixture | 88 | 5000000 | 17.8 | 23.5 | 0.8x | 5x | yes |
| DepositMessage.serialize | small-fixture | 88 | 5000000 | 18.4 | 23.6 | 0.8x | 5x | yes |
| DepositRequest.deserialize | large-fixture | 192 | 5000000 | 7.4 | 52.4 | 0.1x | 5x | yes |
| DepositRequest.deserialize | medium-fixture | 192 | 5000000 | 6.8 | 46.3 | 0.1x | 5x | yes |
| DepositRequest.deserialize | small-fixture | 192 | 5000000 | 6.8 | 51.2 | 0.1x | 5x | yes |
| DepositRequest.hash_tree_root | large-fixture | 192 | 106496 | 4094.1 | 888.6 | 4.6x | 10x | yes |
| DepositRequest.hash_tree_root | medium-fixture | 192 | 122880 | 3613.3 | 787.4 | 4.6x | 10x | yes |
| DepositRequest.hash_tree_root | small-fixture | 192 | 106496 | 4291.2 | 929.3 | 4.6x | 10x | yes |
| DepositRequest.serialize | large-fixture | 192 | 5000000 | 27.8 | 30.3 | 0.9x | 5x | yes |
| DepositRequest.serialize | medium-fixture | 192 | 5000000 | 24.6 | 25.8 | 1.0x | 5x | yes |
| DepositRequest.serialize | small-fixture | 192 | 5000000 | 29.0 | 30.8 | 0.9x | 5x | yes |
| Domain.deserialize | random | 32 | 5000000 | 5.4 | 36.3 | 0.1x | 5x | yes |
| Domain.deserialize | saturated | 32 | 5000000 | 5.2 | 36.4 | 0.1x | 5x | yes |
| Domain.deserialize | zero | 32 | 5000000 | 5.4 | 35.5 | 0.2x | 5x | yes |
| Domain.hash_tree_root | random | 32 | 5000000 | 46.4 | 156.8 | 0.3x | 10x | yes |
| Domain.hash_tree_root | saturated | 32 | 5000000 | 46.4 | 159.2 | 0.3x | 10x | yes |
| Domain.hash_tree_root | zero | 32 | 5000000 | 49.0 | 161.5 | 0.3x | 10x | yes |
| Domain.serialize | random | 32 | 5000000 | 9.2 | 17.4 | 0.5x | 5x | yes |
| Domain.serialize | saturated | 32 | 5000000 | 9.4 | 17.4 | 0.5x | 5x | yes |
| Domain.serialize | zero | 32 | 5000000 | 9.6 | 17.0 | 0.6x | 5x | yes |
| DomainType.deserialize | random | 4 | 5000000 | 5.2 | 31.4 | 0.2x | 5x | yes |
| DomainType.deserialize | saturated | 4 | 5000000 | 5.2 | 31.7 | 0.2x | 5x | yes |
| DomainType.deserialize | zero | 4 | 5000000 | 5.2 | 32.7 | 0.2x | 5x | yes |
| DomainType.hash_tree_root | random | 4 | 5000000 | 51.0 | 165.0 | 0.3x | 10x | yes |
| DomainType.hash_tree_root | saturated | 4 | 4980736 | 51.2 | 171.5 | 0.3x | 10x | yes |
| DomainType.hash_tree_root | zero | 4 | 5000000 | 53.2 | 173.1 | 0.3x | 10x | yes |
| DomainType.serialize | random | 4 | 5000000 | 7.8 | 10.4 | 0.7x | 5x | yes |
| DomainType.serialize | saturated | 4 | 5000000 | 7.8 | 10.2 | 0.8x | 5x | yes |
| DomainType.serialize | zero | 4 | 5000000 | 8.2 | 11.1 | 0.7x | 5x | yes |
| Epoch.deserialize | random | 8 | 5000000 | 4.8 | 30.2 | 0.2x | 5x | yes |
| Epoch.deserialize | saturated | 8 | 5000000 | 4.8 | 30.3 | 0.2x | 5x | yes |
| Epoch.deserialize | zero | 8 | 5000000 | 4.8 | 30.4 | 0.2x | 5x | yes |
| Epoch.hash_tree_root | random | 8 | 5000000 | 52.4 | 172.7 | 0.3x | 10x | yes |
| Epoch.hash_tree_root | saturated | 8 | 5000000 | 52.8 | 174.2 | 0.3x | 10x | yes |
| Epoch.hash_tree_root | zero | 8 | 4980736 | 51.8 | 176.3 | 0.3x | 10x | yes |
| Epoch.serialize | random | 8 | 5000000 | 8.0 | 10.7 | 0.7x | 5x | yes |
| Epoch.serialize | saturated | 8 | 5000000 | 8.0 | 10.7 | 0.7x | 5x | yes |
| Epoch.serialize | zero | 8 | 5000000 | 7.8 | 10.9 | 0.7x | 5x | yes |
| Eth1Block.deserialize | large-fixture | 48 | 5000000 | 5.8 | 31.2 | 0.2x | 5x | yes |
| Eth1Block.deserialize | medium-fixture | 48 | 5000000 | 6.0 | 32.8 | 0.2x | 5x | yes |
| Eth1Block.deserialize | small-fixture | 48 | 5000000 | 7.2 | 40.5 | 0.2x | 5x | yes |
| Eth1Block.hash_tree_root | large-fixture | 48 | 204800 | 1289.1 | 258.8 | 5.0x | 10x | yes |
| Eth1Block.hash_tree_root | medium-fixture | 48 | 335872 | 1280.2 | 258.1 | 5.0x | 10x | yes |
| Eth1Block.hash_tree_root | small-fixture | 48 | 286720 | 1454.4 | 292.1 | 5.0x | 10x | yes |
| Eth1Block.serialize | large-fixture | 48 | 5000000 | 10.6 | 17.4 | 0.6x | 5x | yes |
| Eth1Block.serialize | medium-fixture | 48 | 5000000 | 10.4 | 17.5 | 0.6x | 5x | yes |
| Eth1Block.serialize | small-fixture | 48 | 5000000 | 12.8 | 22.2 | 0.6x | 5x | yes |
| Eth1Data.deserialize | large-fixture | 72 | 5000000 | 7.0 | 56.3 | 0.1x | 5x | yes |
| Eth1Data.deserialize | medium-fixture | 72 | 5000000 | 6.2 | 47.5 | 0.1x | 5x | yes |
| Eth1Data.deserialize | small-fixture | 72 | 5000000 | 5.8 | 46.4 | 0.1x | 5x | yes |
| Eth1Data.hash_tree_root | large-fixture | 72 | 167936 | 1482.7 | 293.7 | 5.0x | 10x | yes |
| Eth1Data.hash_tree_root | medium-fixture | 72 | 335872 | 1304.1 | 277.4 | 4.7x | 10x | yes |
| Eth1Data.hash_tree_root | small-fixture | 72 | 335872 | 1295.1 | 263.8 | 4.9x | 10x | yes |
| Eth1Data.serialize | large-fixture | 72 | 5000000 | 17.2 | 22.4 | 0.8x | 5x | yes |
| Eth1Data.serialize | medium-fixture | 72 | 5000000 | 16.0 | 20.6 | 0.8x | 5x | yes |
| Eth1Data.serialize | small-fixture | 72 | 5000000 | 15.6 | 20.7 | 0.8x | 5x | yes |
| Ether.deserialize | random | 8 | 5000000 | 5.2 | 32.9 | 0.2x | 5x | yes |
| Ether.deserialize | saturated | 8 | 5000000 | 5.0 | 32.0 | 0.2x | 5x | yes |
| Ether.deserialize | zero | 8 | 5000000 | 5.0 | 30.2 | 0.2x | 5x | yes |
| Ether.hash_tree_root | random | 8 | 5000000 | 56.8 | 184.0 | 0.3x | 10x | yes |
| Ether.hash_tree_root | saturated | 8 | 5000000 | 56.0 | 182.4 | 0.3x | 10x | yes |
| Ether.hash_tree_root | zero | 8 | 5000000 | 54.0 | 175.2 | 0.3x | 10x | yes |
| Ether.serialize | random | 8 | 5000000 | 8.6 | 11.5 | 0.7x | 5x | yes |
| Ether.serialize | saturated | 8 | 5000000 | 8.6 | 11.2 | 0.8x | 5x | yes |
| Ether.serialize | zero | 8 | 5000000 | 8.0 | 10.6 | 0.8x | 5x | yes |
| ExecutionAddress.deserialize | random | 20 | 5000000 | 5.6 | 37.6 | 0.1x | 5x | yes |
| ExecutionAddress.deserialize | saturated | 20 | 5000000 | 5.4 | 37.5 | 0.1x | 5x | yes |
| ExecutionAddress.deserialize | zero | 20 | 5000000 | 5.4 | 37.9 | 0.1x | 5x | yes |
| ExecutionAddress.hash_tree_root | random | 20 | 5000000 | 54.4 | 187.2 | 0.3x | 10x | yes |
| ExecutionAddress.hash_tree_root | saturated | 20 | 5000000 | 55.8 | 193.9 | 0.3x | 10x | yes |
| ExecutionAddress.hash_tree_root | zero | 20 | 5000000 | 56.0 | 189.8 | 0.3x | 10x | yes |
| ExecutionAddress.serialize | random | 20 | 5000000 | 9.8 | 17.9 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | saturated | 20 | 5000000 | 9.2 | 17.0 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | zero | 20 | 5000000 | 9.8 | 17.5 | 0.6x | 5x | yes |
| ExecutionBranch.deserialize | random | 128 | 5000000 | 5.0 | 36.4 | 0.1x | 5x | yes |
| ExecutionBranch.deserialize | saturated | 128 | 5000000 | 5.8 | 40.8 | 0.1x | 5x | yes |
| ExecutionBranch.deserialize | zero | 128 | 5000000 | 6.2 | 44.3 | 0.1x | 5x | yes |
| ExecutionBranch.hash_tree_root | random | 128 | 253952 | 1067.1 | 440.6 | 2.4x | 10x | yes |
| ExecutionBranch.hash_tree_root | saturated | 128 | 409600 | 1206.1 | 510.2 | 2.4x | 10x | yes |
| ExecutionBranch.hash_tree_root | zero | 128 | 409600 | 1008.3 | 411.8 | 2.4x | 10x | yes |
| ExecutionBranch.serialize | random | 128 | 5000000 | 15.4 | 19.5 | 0.8x | 5x | yes |
| ExecutionBranch.serialize | saturated | 128 | 5000000 | 17.2 | 22.3 | 0.8x | 5x | yes |
| ExecutionBranch.serialize | zero | 128 | 5000000 | 18.6 | 23.0 | 0.8x | 5x | yes |
| ExecutionPayload.deserialize | large-fixture | 4033 | 253952 | 1059.3 | 695.0 | 1.5x | 5x | yes |
| ExecutionPayload.deserialize | medium-fixture | 2445 | 524288 | 787.7 | 548.0 | 1.4x | 5x | yes |
| ExecutionPayload.deserialize | small-fixture | 1921 | 524288 | 726.7 | 380.1 | 1.9x | 5x | yes |
| ExecutionPayload.hash_tree_root | large-fixture | 4033 | 3456 | 128472.2 | 30242.5 | 4.2x | 10x | yes |
| ExecutionPayload.hash_tree_root | medium-fixture | 2445 | 3200 | 84375.0 | 18167.6 | 4.6x | 10x | yes |
| ExecutionPayload.hash_tree_root | small-fixture | 1921 | 7936 | 59853.8 | 13297.7 | 4.5x | 10x | yes |
| ExecutionPayload.serialize | large-fixture | 4033 | 1048576 | 325.2 | 372.0 | 0.9x | 5x | yes |
| ExecutionPayload.serialize | medium-fixture | 2445 | 1048576 | 328.1 | 273.5 | 1.2x | 5x | yes |
| ExecutionPayload.serialize | small-fixture | 1921 | 2621440 | 170.1 | 198.5 | 0.9x | 5x | yes |
| ExecutionPayloadHeader.deserialize | large-fixture | 604 | 2621440 | 170.5 | 120.6 | 1.4x | 5x | yes |
| ExecutionPayloadHeader.deserialize | medium-fixture | 594 | 3145728 | 167.5 | 115.2 | 1.5x | 5x | yes |
| ExecutionPayloadHeader.deserialize | small-fixture | 590 | 3145728 | 166.3 | 108.9 | 1.5x | 5x | yes |
| ExecutionPayloadHeader.hash_tree_root | large-fixture | 604 | 40960 | 10717.8 | 2133.5 | 5.0x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | medium-fixture | 594 | 32768 | 12268.1 | 2408.3 | 5.1x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | small-fixture | 590 | 32768 | 12085.0 | 2405.0 | 5.0x | 10x | yes |
| ExecutionPayloadHeader.serialize | large-fixture | 604 | 4718592 | 92.6 | 79.5 | 1.2x | 5x | yes |
| ExecutionPayloadHeader.serialize | medium-fixture | 594 | 4718592 | 92.4 | 80.8 | 1.1x | 5x | yes |
| ExecutionPayloadHeader.serialize | small-fixture | 590 | 4194304 | 98.5 | 85.7 | 1.1x | 5x | yes |
| ExecutionRequests.deserialize | large-fixture | 1624 | 2097152 | 235.6 | 449.9 | 0.5x | 5x | yes |
| ExecutionRequests.deserialize | medium-fixture | 1004 | 2097152 | 237.0 | 276.9 | 0.9x | 5x | yes |
| ExecutionRequests.deserialize | small-fixture | 396 | 2097152 | 237.5 | 141.5 | 1.7x | 5x | yes |
| ExecutionRequests.hash_tree_root | large-fixture | 1624 | 8192 | 44921.9 | 9247.8 | 4.9x | 10x | yes |
| ExecutionRequests.hash_tree_root | medium-fixture | 1004 | 16384 | 26916.5 | 5416.6 | 5.0x | 10x | yes |
| ExecutionRequests.hash_tree_root | small-fixture | 396 | 32768 | 13946.5 | 2979.0 | 4.7x | 10x | yes |
| ExecutionRequests.serialize | large-fixture | 1624 | 2621440 | 164.4 | 164.0 | 1.0x | 5x | yes |
| ExecutionRequests.serialize | medium-fixture | 1004 | 5000000 | 86.2 | 98.9 | 0.9x | 5x | yes |
| ExecutionRequests.serialize | small-fixture | 396 | 5000000 | 46.6 | 46.6 | 1.0x | 5x | yes |
| FinalityBranch.deserialize | random | 224 | 5000000 | 5.8 | 50.2 | 0.1x | 5x | yes |
| FinalityBranch.deserialize | saturated | 224 | 5000000 | 5.8 | 49.6 | 0.1x | 5x | yes |
| FinalityBranch.deserialize | zero | 224 | 5000000 | 5.8 | 48.2 | 0.1x | 5x | yes |
| FinalityBranch.hash_tree_root | random | 224 | 180224 | 2374.8 | 789.7 | 3.0x | 10x | yes |
| FinalityBranch.hash_tree_root | saturated | 224 | 204800 | 2319.3 | 774.0 | 3.0x | 10x | yes |
| FinalityBranch.hash_tree_root | zero | 224 | 102400 | 2587.9 | 854.4 | 3.0x | 10x | yes |
| FinalityBranch.serialize | random | 224 | 5000000 | 27.4 | 29.2 | 0.9x | 5x | yes |
| FinalityBranch.serialize | saturated | 224 | 5000000 | 26.0 | 29.8 | 0.9x | 5x | yes |
| FinalityBranch.serialize | zero | 224 | 5000000 | 26.8 | 29.4 | 0.9x | 5x | yes |
| Fork.deserialize | large-fixture | 16 | 5000000 | 6.4 | 13.2 | 0.5x | 5x | yes |
| Fork.deserialize | medium-fixture | 16 | 5000000 | 6.4 | 13.4 | 0.5x | 5x | yes |
| Fork.deserialize | small-fixture | 16 | 5000000 | 6.4 | 13.2 | 0.5x | 5x | yes |
| Fork.hash_tree_root | large-fixture | 16 | 335872 | 1444.0 | 285.2 | 5.1x | 10x | yes |
| Fork.hash_tree_root | medium-fixture | 16 | 167936 | 1458.9 | 294.0 | 5.0x | 10x | yes |
| Fork.hash_tree_root | small-fixture | 16 | 286720 | 1419.5 | 285.1 | 5.0x | 10x | yes |
| Fork.serialize | large-fixture | 16 | 5000000 | 7.6 | 16.5 | 0.5x | 5x | yes |
| Fork.serialize | medium-fixture | 16 | 5000000 | 7.8 | 17.0 | 0.5x | 5x | yes |
| Fork.serialize | small-fixture | 16 | 5000000 | 7.8 | 17.4 | 0.4x | 5x | yes |
| ForkData.deserialize | large-fixture | 36 | 5000000 | 6.8 | 16.7 | 0.4x | 5x | yes |
| ForkData.deserialize | medium-fixture | 36 | 5000000 | 6.8 | 16.6 | 0.4x | 5x | yes |
| ForkData.deserialize | small-fixture | 36 | 5000000 | 6.4 | 15.6 | 0.4x | 5x | yes |
| ForkData.hash_tree_root | large-fixture | 36 | 524288 | 642.8 | 122.6 | 5.2x | 10x | yes |
| ForkData.hash_tree_root | medium-fixture | 36 | 524288 | 648.5 | 122.0 | 5.3x | 10x | yes |
| ForkData.hash_tree_root | small-fixture | 36 | 524288 | 650.4 | 123.5 | 5.3x | 10x | yes |
| ForkData.serialize | large-fixture | 36 | 5000000 | 11.8 | 18.8 | 0.6x | 5x | yes |
| ForkData.serialize | medium-fixture | 36 | 5000000 | 11.6 | 18.2 | 0.6x | 5x | yes |
| ForkData.serialize | small-fixture | 36 | 5000000 | 11.4 | 18.0 | 0.6x | 5x | yes |
| ForkDigest.deserialize | random | 4 | 5000000 | 4.8 | 30.0 | 0.2x | 5x | yes |
| ForkDigest.deserialize | saturated | 4 | 5000000 | 5.2 | 31.4 | 0.2x | 5x | yes |
| ForkDigest.deserialize | zero | 4 | 5000000 | 4.8 | 30.0 | 0.2x | 5x | yes |
| ForkDigest.hash_tree_root | random | 4 | 5000000 | 49.4 | 167.9 | 0.3x | 10x | yes |
| ForkDigest.hash_tree_root | saturated | 4 | 5000000 | 50.2 | 157.5 | 0.3x | 10x | yes |
| ForkDigest.hash_tree_root | zero | 4 | 5000000 | 51.2 | 173.5 | 0.3x | 10x | yes |
| ForkDigest.serialize | random | 4 | 5000000 | 7.4 | 10.2 | 0.7x | 5x | yes |
| ForkDigest.serialize | saturated | 4 | 5000000 | 8.0 | 10.3 | 0.8x | 5x | yes |
| ForkDigest.serialize | zero | 4 | 5000000 | 7.6 | 10.1 | 0.8x | 5x | yes |
| G1Point.deserialize | random | 48 | 5000000 | 5.0 | 34.7 | 0.1x | 5x | yes |
| G1Point.deserialize | saturated | 48 | 5000000 | 5.2 | 35.6 | 0.1x | 5x | yes |
| G1Point.deserialize | zero | 48 | 5000000 | 5.0 | 35.2 | 0.1x | 5x | yes |
| G1Point.hash_tree_root | random | 48 | 1048576 | 405.3 | 270.0 | 1.5x | 10x | yes |
| G1Point.hash_tree_root | saturated | 48 | 1048576 | 403.4 | 268.9 | 1.5x | 10x | yes |
| G1Point.hash_tree_root | zero | 48 | 1048576 | 406.3 | 267.7 | 1.5x | 10x | yes |
| G1Point.serialize | random | 48 | 5000000 | 11.2 | 16.7 | 0.7x | 5x | yes |
| G1Point.serialize | saturated | 48 | 5000000 | 11.6 | 17.2 | 0.7x | 5x | yes |
| G1Point.serialize | zero | 48 | 5000000 | 11.0 | 16.2 | 0.7x | 5x | yes |
| G2Point.deserialize | random | 96 | 5000000 | 5.2 | 39.3 | 0.1x | 5x | yes |
| G2Point.deserialize | saturated | 96 | 5000000 | 5.6 | 42.7 | 0.1x | 5x | yes |
| G2Point.deserialize | zero | 96 | 5000000 | 5.2 | 38.8 | 0.1x | 5x | yes |
| G2Point.hash_tree_root | random | 96 | 409600 | 1069.3 | 458.2 | 2.3x | 10x | yes |
| G2Point.hash_tree_root | saturated | 96 | 409600 | 1057.1 | 445.5 | 2.4x | 10x | yes |
| G2Point.hash_tree_root | zero | 96 | 253952 | 1055.3 | 439.3 | 2.4x | 10x | yes |
| G2Point.serialize | random | 96 | 5000000 | 17.2 | 21.5 | 0.8x | 5x | yes |
| G2Point.serialize | saturated | 96 | 5000000 | 17.2 | 21.7 | 0.8x | 5x | yes |
| G2Point.serialize | zero | 96 | 5000000 | 17.2 | 21.0 | 0.8x | 5x | yes |
| Gwei.deserialize | random | 8 | 5000000 | 4.8 | 30.3 | 0.2x | 5x | yes |
| Gwei.deserialize | saturated | 8 | 5000000 | 4.8 | 30.3 | 0.2x | 5x | yes |
| Gwei.deserialize | zero | 8 | 5000000 | 4.6 | 29.7 | 0.2x | 5x | yes |
| Gwei.hash_tree_root | random | 8 | 5000000 | 53.4 | 174.0 | 0.3x | 10x | yes |
| Gwei.hash_tree_root | saturated | 8 | 5000000 | 51.0 | 165.1 | 0.3x | 10x | yes |
| Gwei.hash_tree_root | zero | 8 | 5000000 | 51.4 | 174.5 | 0.3x | 10x | yes |
| Gwei.serialize | random | 8 | 5000000 | 8.4 | 11.1 | 0.8x | 5x | yes |
| Gwei.serialize | saturated | 8 | 5000000 | 7.8 | 10.4 | 0.8x | 5x | yes |
| Gwei.serialize | zero | 8 | 5000000 | 7.8 | 10.8 | 0.7x | 5x | yes |
| Hash32.deserialize | random | 32 | 5000000 | 5.0 | 34.6 | 0.1x | 5x | yes |
| Hash32.deserialize | saturated | 32 | 5000000 | 5.0 | 34.6 | 0.1x | 5x | yes |
| Hash32.deserialize | zero | 32 | 5000000 | 5.2 | 35.0 | 0.1x | 5x | yes |
| Hash32.hash_tree_root | random | 32 | 5000000 | 45.4 | 153.3 | 0.3x | 10x | yes |
| Hash32.hash_tree_root | saturated | 32 | 5000000 | 45.4 | 153.5 | 0.3x | 10x | yes |
| Hash32.hash_tree_root | zero | 32 | 5000000 | 44.6 | 151.4 | 0.3x | 10x | yes |
| Hash32.serialize | random | 32 | 5000000 | 9.2 | 16.3 | 0.6x | 5x | yes |
| Hash32.serialize | saturated | 32 | 5000000 | 9.0 | 15.8 | 0.6x | 5x | yes |
| Hash32.serialize | zero | 32 | 5000000 | 9.0 | 16.1 | 0.6x | 5x | yes |
| HistoricalBatch.deserialize | large-fixture | 524288 | 5000000 | 6.8 | 375477.8 | 0.0x | 5x | yes |
| HistoricalBatch.deserialize | medium-fixture | 524288 | 5000000 | 6.8 | 377097.8 | 0.0x | 5x | yes |
| HistoricalBatch.deserialize | small-fixture | 524288 | 5000000 | 6.8 | 374452.1 | 0.0x | 5x | yes |
| HistoricalBatch.hash_tree_root | large-fixture | 524288 | 82 | 5097561.0 | 1316178.9 | 3.9x | 10x | yes |
| HistoricalBatch.hash_tree_root | medium-fixture | 524288 | 82 | 5146341.5 | 1325094.1 | 3.9x | 10x | yes |
| HistoricalBatch.hash_tree_root | small-fixture | 524288 | 82 | 5121951.2 | 1327292.3 | 3.9x | 10x | yes |
| HistoricalBatch.serialize | large-fixture | 524288 | 8192 | 39917.0 | 78156.2 | 0.5x | 5x | yes |
| HistoricalBatch.serialize | medium-fixture | 524288 | 8192 | 37963.9 | 76462.3 | 0.5x | 5x | yes |
| HistoricalBatch.serialize | small-fixture | 524288 | 8192 | 38818.4 | 75058.4 | 0.5x | 5x | yes |
| HistoricalSummary.deserialize | large-fixture | 64 | 5000000 | 6.4 | 16.3 | 0.4x | 5x | yes |
| HistoricalSummary.deserialize | medium-fixture | 64 | 5000000 | 6.4 | 17.0 | 0.4x | 5x | yes |
| HistoricalSummary.deserialize | small-fixture | 64 | 5000000 | 6.2 | 16.3 | 0.4x | 5x | yes |
| HistoricalSummary.hash_tree_root | large-fixture | 64 | 524288 | 631.3 | 119.0 | 5.3x | 10x | yes |
| HistoricalSummary.hash_tree_root | medium-fixture | 64 | 524288 | 642.8 | 120.7 | 5.3x | 10x | yes |
| HistoricalSummary.hash_tree_root | small-fixture | 64 | 524288 | 654.2 | 124.5 | 5.3x | 10x | yes |
| HistoricalSummary.serialize | large-fixture | 64 | 5000000 | 11.2 | 18.7 | 0.6x | 5x | yes |
| HistoricalSummary.serialize | medium-fixture | 64 | 5000000 | 11.4 | 18.7 | 0.6x | 5x | yes |
| HistoricalSummary.serialize | small-fixture | 64 | 5000000 | 11.8 | 19.2 | 0.6x | 5x | yes |
| IndexedAttestation.deserialize | large-fixture | 308 | 3145728 | 152.0 | 104.4 | 1.5x | 5x | yes |
| IndexedAttestation.deserialize | medium-fixture | 284 | 3670016 | 161.3 | 109.5 | 1.5x | 5x | yes |
| IndexedAttestation.deserialize | small-fixture | 236 | 3145728 | 151.0 | 93.7 | 1.6x | 5x | yes |
| IndexedAttestation.hash_tree_root | large-fixture | 308 | 32768 | 12054.4 | 2646.1 | 4.6x | 10x | yes |
| IndexedAttestation.hash_tree_root | medium-fixture | 284 | 20480 | 11474.6 | 2423.4 | 4.7x | 10x | yes |
| IndexedAttestation.hash_tree_root | small-fixture | 236 | 40960 | 10864.3 | 2331.1 | 4.7x | 10x | yes |
| IndexedAttestation.serialize | large-fixture | 308 | 5000000 | 49.2 | 43.4 | 1.1x | 5x | yes |
| IndexedAttestation.serialize | medium-fixture | 284 | 5000000 | 51.2 | 42.7 | 1.2x | 5x | yes |
| IndexedAttestation.serialize | small-fixture | 236 | 5000000 | 25.2 | 35.1 | 0.7x | 5x | yes |
| KZGCommitment.deserialize | random | 48 | 5000000 | 5.0 | 36.0 | 0.1x | 5x | yes |
| KZGCommitment.deserialize | saturated | 48 | 5000000 | 5.2 | 36.2 | 0.1x | 5x | yes |
| KZGCommitment.deserialize | zero | 48 | 5000000 | 5.2 | 36.2 | 0.1x | 5x | yes |
| KZGCommitment.hash_tree_root | random | 48 | 1048576 | 414.8 | 284.0 | 1.5x | 10x | yes |
| KZGCommitment.hash_tree_root | saturated | 48 | 1048576 | 433.9 | 290.4 | 1.5x | 10x | yes |
| KZGCommitment.hash_tree_root | zero | 48 | 1048576 | 401.5 | 264.2 | 1.5x | 10x | yes |
| KZGCommitment.serialize | random | 48 | 5000000 | 11.6 | 17.1 | 0.7x | 5x | yes |
| KZGCommitment.serialize | saturated | 48 | 5000000 | 11.8 | 17.5 | 0.7x | 5x | yes |
| KZGCommitment.serialize | zero | 48 | 5000000 | 11.8 | 17.1 | 0.7x | 5x | yes |
| KZGProof.deserialize | random | 48 | 5000000 | 5.6 | 39.2 | 0.1x | 5x | yes |
| KZGProof.deserialize | saturated | 48 | 5000000 | 5.4 | 38.9 | 0.1x | 5x | yes |
| KZGProof.deserialize | zero | 48 | 5000000 | 5.6 | 38.5 | 0.1x | 5x | yes |
| KZGProof.hash_tree_root | random | 48 | 1048576 | 434.9 | 291.5 | 1.5x | 10x | yes |
| KZGProof.hash_tree_root | saturated | 48 | 1048576 | 431.1 | 288.4 | 1.5x | 10x | yes |
| KZGProof.hash_tree_root | zero | 48 | 1048576 | 442.5 | 294.9 | 1.5x | 10x | yes |
| KZGProof.serialize | random | 48 | 5000000 | 12.6 | 19.0 | 0.7x | 5x | yes |
| KZGProof.serialize | saturated | 48 | 5000000 | 12.6 | 18.5 | 0.7x | 5x | yes |
| KZGProof.serialize | zero | 48 | 5000000 | 12.6 | 18.5 | 0.7x | 5x | yes |
| LightClientBootstrap.deserialize | large-fixture | 25676 | 524288 | 661.8 | 10656.2 | 0.1x | 5x | yes |
| LightClientBootstrap.deserialize | medium-fixture | 25666 | 524288 | 663.8 | 10735.1 | 0.1x | 5x | yes |
| LightClientBootstrap.deserialize | small-fixture | 25651 | 524288 | 658.0 | 10715.0 | 0.1x | 5x | yes |
| LightClientBootstrap.hash_tree_root | large-fixture | 25676 | 1280 | 351562.5 | 78122.1 | 4.5x | 10x | yes |
| LightClientBootstrap.hash_tree_root | medium-fixture | 25666 | 1024 | 413085.9 | 91531.9 | 4.5x | 10x | yes |
| LightClientBootstrap.hash_tree_root | small-fixture | 25651 | 1152 | 411458.3 | 92193.1 | 4.5x | 10x | yes |
| LightClientBootstrap.serialize | large-fixture | 25676 | 180224 | 2053.0 | 1785.9 | 1.1x | 5x | yes |
| LightClientBootstrap.serialize | medium-fixture | 25666 | 180224 | 2580.1 | 2238.5 | 1.2x | 5x | yes |
| LightClientBootstrap.serialize | small-fixture | 25651 | 102400 | 2421.9 | 2119.9 | 1.1x | 5x | yes |
| LightClientFinalityUpdate.deserialize | large-fixture | 2096 | 409600 | 1301.3 | 1324.4 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.deserialize | medium-fixture | 2078 | 409600 | 1276.9 | 1241.7 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.deserialize | small-fixture | 2066 | 507904 | 1403.8 | 1386.9 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.hash_tree_root | large-fixture | 2096 | 6400 | 57500.0 | 10510.9 | 5.5x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | medium-fixture | 2078 | 8192 | 48461.9 | 9019.9 | 5.4x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | small-fixture | 2066 | 8192 | 46508.8 | 8927.0 | 5.2x | 10x | yes |
| LightClientFinalityUpdate.serialize | large-fixture | 2096 | 1048576 | 420.6 | 299.5 | 1.4x | 5x | yes |
| LightClientFinalityUpdate.serialize | medium-fixture | 2078 | 1048576 | 431.1 | 246.2 | 1.8x | 5x | yes |
| LightClientFinalityUpdate.serialize | small-fixture | 2066 | 1048576 | 376.7 | 244.8 | 1.5x | 5x | yes |
| LightClientHeader.deserialize | large-fixture | 860 | 524288 | 555.0 | 767.8 | 0.7x | 5x | yes |
| LightClientHeader.deserialize | medium-fixture | 850 | 524288 | 585.6 | 593.3 | 1.0x | 5x | yes |
| LightClientHeader.deserialize | small-fixture | 830 | 524288 | 581.7 | 637.5 | 0.9x | 5x | yes |
| LightClientHeader.hash_tree_root | large-fixture | 860 | 12288 | 24007.2 | 4490.8 | 5.3x | 10x | yes |
| LightClientHeader.hash_tree_root | medium-fixture | 850 | 12288 | 20670.6 | 4670.5 | 4.4x | 10x | yes |
| LightClientHeader.hash_tree_root | small-fixture | 830 | 16384 | 24902.3 | 4779.7 | 5.2x | 10x | yes |
| LightClientHeader.serialize | large-fixture | 860 | 3145728 | 117.0 | 128.2 | 0.9x | 5x | yes |
| LightClientHeader.serialize | medium-fixture | 850 | 3670016 | 131.1 | 139.1 | 0.9x | 5x | yes |
| LightClientHeader.serialize | small-fixture | 830 | 3670016 | 129.4 | 129.2 | 1.0x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | large-fixture | 1031 | 524288 | 970.8 | 836.8 | 1.2x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | medium-fixture | 1013 | 524288 | 940.3 | 835.6 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | small-fixture | 1000 | 507904 | 791.5 | 675.0 | 1.2x | 5x | yes |
| LightClientOptimisticUpdate.hash_tree_root | large-fixture | 1031 | 16384 | 30639.6 | 5647.3 | 5.4x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | medium-fixture | 1013 | 8192 | 30273.4 | 5773.4 | 5.2x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | small-fixture | 1000 | 8192 | 29541.0 | 5766.0 | 5.1x | 10x | yes |
| LightClientOptimisticUpdate.serialize | large-fixture | 1031 | 1048576 | 248.0 | 182.0 | 1.4x | 5x | yes |
| LightClientOptimisticUpdate.serialize | medium-fixture | 1013 | 3670016 | 126.7 | 159.7 | 0.8x | 5x | yes |
| LightClientOptimisticUpdate.serialize | small-fixture | 1000 | 3670016 | 132.4 | 155.6 | 0.9x | 5x | yes |
| LightClientUpdate.deserialize | large-fixture | 26914 | 335872 | 1470.8 | 13903.8 | 0.1x | 5x | yes |
| LightClientUpdate.deserialize | medium-fixture | 26893 | 204800 | 1523.4 | 17788.8 | 0.1x | 5x | yes |
| LightClientUpdate.deserialize | small-fixture | 26885 | 167936 | 1631.6 | 15531.1 | 0.1x | 5x | yes |
| LightClientUpdate.hash_tree_root | large-fixture | 26914 | 896 | 524553.6 | 116088.2 | 4.5x | 10x | yes |
| LightClientUpdate.hash_tree_root | medium-fixture | 26893 | 768 | 528645.8 | 115251.3 | 4.6x | 10x | yes |
| LightClientUpdate.hash_tree_root | small-fixture | 26885 | 768 | 593750.0 | 121410.1 | 4.9x | 10x | yes |
| LightClientUpdate.serialize | large-fixture | 26914 | 155648 | 2878.3 | 2402.8 | 1.2x | 5x | yes |
| LightClientUpdate.serialize | medium-fixture | 26893 | 131072 | 3486.6 | 3385.3 | 1.0x | 5x | yes |
| LightClientUpdate.serialize | small-fixture | 26885 | 61440 | 3385.4 | 3228.5 | 1.0x | 5x | yes |
| MatrixEntry.deserialize | large-fixture | 2112 | 5000000 | 18.4 | 246.1 | 0.1x | 5x | yes |
| MatrixEntry.deserialize | medium-fixture | 2112 | 5000000 | 19.0 | 246.7 | 0.1x | 5x | yes |
| MatrixEntry.deserialize | small-fixture | 2112 | 5000000 | 18.6 | 242.1 | 0.1x | 5x | yes |
| MatrixEntry.hash_tree_root | large-fixture | 2112 | 16384 | 26184.1 | 6228.9 | 4.2x | 10x | yes |
| MatrixEntry.hash_tree_root | medium-fixture | 2112 | 16384 | 25878.9 | 6220.1 | 4.2x | 10x | yes |
| MatrixEntry.hash_tree_root | small-fixture | 2112 | 16384 | 26245.1 | 6275.4 | 4.2x | 10x | yes |
| MatrixEntry.serialize | large-fixture | 2112 | 1048576 | 375.7 | 196.5 | 1.9x | 5x | yes |
| MatrixEntry.serialize | medium-fixture | 2112 | 1048576 | 374.8 | 195.5 | 1.9x | 5x | yes |
| MatrixEntry.serialize | small-fixture | 2112 | 1048576 | 379.6 | 200.6 | 1.9x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 7.0 | 63.5 | 0.1x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | saturated | 192 | 5000000 | 7.6 | 66.4 | 0.1x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 6.4 | 57.1 | 0.1x | 5x | yes |
| NextSyncCommitteeBranch.hash_tree_root | random | 192 | 155648 | 3038.9 | 916.6 | 3.3x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | saturated | 192 | 77824 | 3058.2 | 914.9 | 3.3x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | zero | 192 | 155648 | 3006.8 | 918.9 | 3.3x | 10x | yes |
| NextSyncCommitteeBranch.serialize | random | 192 | 5000000 | 32.8 | 36.0 | 0.9x | 5x | yes |
| NextSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 34.6 | 37.1 | 0.9x | 5x | yes |
| NextSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 32.4 | 31.0 | 1.0x | 5x | yes |
| NodeID.deserialize | random | 32 | 5000000 | 5.6 | 46.8 | 0.1x | 5x | yes |
| NodeID.deserialize | saturated | 32 | 5000000 | 5.8 | 46.4 | 0.1x | 5x | yes |
| NodeID.deserialize | zero | 32 | 5000000 | 6.2 | 48.4 | 0.1x | 5x | yes |
| NodeID.hash_tree_root | random | 32 | 5000000 | 59.8 | 206.5 | 0.3x | 10x | yes |
| NodeID.hash_tree_root | saturated | 32 | 5000000 | 57.8 | 205.0 | 0.3x | 10x | yes |
| NodeID.hash_tree_root | zero | 32 | 5000000 | 56.4 | 204.6 | 0.3x | 10x | yes |
| NodeID.serialize | random | 32 | 5000000 | 11.2 | 22.1 | 0.5x | 5x | yes |
| NodeID.serialize | saturated | 32 | 5000000 | 11.4 | 21.9 | 0.5x | 5x | yes |
| NodeID.serialize | zero | 32 | 5000000 | 12.0 | 23.2 | 0.5x | 5x | yes |
| ParticipationFlags.deserialize | random | 1 | 5000000 | 5.8 | 42.6 | 0.1x | 5x | yes |
| ParticipationFlags.deserialize | saturated | 1 | 5000000 | 5.8 | 40.2 | 0.1x | 5x | yes |
| ParticipationFlags.deserialize | zero | 1 | 5000000 | 6.2 | 39.6 | 0.2x | 5x | yes |
| ParticipationFlags.hash_tree_root | random | 1 | 5000000 | 68.0 | 218.1 | 0.3x | 10x | yes |
| ParticipationFlags.hash_tree_root | saturated | 1 | 5000000 | 67.8 | 231.8 | 0.3x | 10x | yes |
| ParticipationFlags.hash_tree_root | zero | 1 | 5000000 | 67.6 | 226.5 | 0.3x | 10x | yes |
| ParticipationFlags.serialize | random | 1 | 5000000 | 10.4 | 12.2 | 0.9x | 5x | yes |
| ParticipationFlags.serialize | saturated | 1 | 5000000 | 10.2 | 12.9 | 0.8x | 5x | yes |
| ParticipationFlags.serialize | zero | 1 | 5000000 | 10.4 | 12.0 | 0.9x | 5x | yes |
| PayloadId.deserialize | random | 8 | 5000000 | 7.4 | 38.4 | 0.2x | 5x | yes |
| PayloadId.deserialize | saturated | 8 | 5000000 | 6.2 | 41.7 | 0.1x | 5x | yes |
| PayloadId.deserialize | zero | 8 | 5000000 | 6.8 | 48.7 | 0.1x | 5x | yes |
| PayloadId.hash_tree_root | random | 8 | 5000000 | 68.0 | 230.2 | 0.3x | 10x | yes |
| PayloadId.hash_tree_root | saturated | 8 | 3932160 | 66.6 | 231.5 | 0.3x | 10x | yes |
| PayloadId.hash_tree_root | zero | 8 | 5000000 | 66.2 | 226.9 | 0.3x | 10x | yes |
| PayloadId.serialize | random | 8 | 5000000 | 10.4 | 13.6 | 0.8x | 5x | yes |
| PayloadId.serialize | saturated | 8 | 5000000 | 10.4 | 14.3 | 0.7x | 5x | yes |
| PayloadId.serialize | zero | 8 | 5000000 | 10.6 | 13.0 | 0.8x | 5x | yes |
| PendingAttestation.deserialize | large-fixture | 150 | 1572864 | 302.0 | 89.3 | 3.4x | 5x | yes |
| PendingAttestation.deserialize | medium-fixture | 149 | 1572864 | 312.2 | 90.1 | 3.5x | 5x | yes |
| PendingAttestation.deserialize | small-fixture | 149 | 1048576 | 356.7 | 112.0 | 3.2x | 5x | yes |
| PendingAttestation.hash_tree_root | large-fixture | 150 | 65536 | 7232.7 | 1337.6 | 5.4x | 10x | yes |
| PendingAttestation.hash_tree_root | medium-fixture | 149 | 32768 | 7354.7 | 1353.0 | 5.4x | 10x | yes |
| PendingAttestation.hash_tree_root | small-fixture | 149 | 49152 | 8707.7 | 1543.3 | 5.6x | 10x | yes |
| PendingAttestation.serialize | large-fixture | 150 | 5000000 | 27.6 | 33.6 | 0.8x | 5x | yes |
| PendingAttestation.serialize | medium-fixture | 149 | 5000000 | 27.6 | 33.4 | 0.8x | 5x | yes |
| PendingAttestation.serialize | small-fixture | 149 | 5000000 | 34.0 | 42.4 | 0.8x | 5x | yes |
| PendingConsolidation.deserialize | large-fixture | 16 | 5000000 | 6.6 | 13.7 | 0.5x | 5x | yes |
| PendingConsolidation.deserialize | medium-fixture | 16 | 5000000 | 6.8 | 14.0 | 0.5x | 5x | yes |
| PendingConsolidation.deserialize | small-fixture | 16 | 5000000 | 6.6 | 14.0 | 0.5x | 5x | yes |
| PendingConsolidation.hash_tree_root | large-fixture | 16 | 524288 | 684.7 | 124.4 | 5.5x | 10x | yes |
| PendingConsolidation.hash_tree_root | medium-fixture | 16 | 524288 | 684.7 | 124.6 | 5.5x | 10x | yes |
| PendingConsolidation.hash_tree_root | small-fixture | 16 | 524288 | 724.8 | 133.2 | 5.4x | 10x | yes |
| PendingConsolidation.serialize | large-fixture | 16 | 5000000 | 8.0 | 16.2 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | medium-fixture | 16 | 5000000 | 8.0 | 16.4 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | small-fixture | 16 | 5000000 | 8.0 | 16.4 | 0.5x | 5x | yes |
| PendingDeposit.deserialize | large-fixture | 192 | 5000000 | 6.8 | 50.6 | 0.1x | 5x | yes |
| PendingDeposit.deserialize | medium-fixture | 192 | 5000000 | 6.8 | 51.1 | 0.1x | 5x | yes |
| PendingDeposit.deserialize | small-fixture | 192 | 5000000 | 6.8 | 51.2 | 0.1x | 5x | yes |
| PendingDeposit.hash_tree_root | large-fixture | 192 | 106496 | 4047.1 | 882.7 | 4.6x | 10x | yes |
| PendingDeposit.hash_tree_root | medium-fixture | 192 | 114688 | 4037.0 | 882.8 | 4.6x | 10x | yes |
| PendingDeposit.hash_tree_root | small-fixture | 192 | 106496 | 3990.8 | 877.6 | 4.5x | 10x | yes |
| PendingDeposit.serialize | large-fixture | 192 | 5000000 | 27.6 | 30.7 | 0.9x | 5x | yes |
| PendingDeposit.serialize | medium-fixture | 192 | 5000000 | 27.6 | 31.2 | 0.9x | 5x | yes |
| PendingDeposit.serialize | small-fixture | 192 | 5000000 | 27.6 | 29.3 | 0.9x | 5x | yes |
| PendingPartialWithdrawal.deserialize | large-fixture | 24 | 5000000 | 6.8 | 16.2 | 0.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | medium-fixture | 24 | 5000000 | 6.8 | 16.2 | 0.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | small-fixture | 24 | 5000000 | 6.6 | 15.8 | 0.4x | 5x | yes |
| PendingPartialWithdrawal.hash_tree_root | large-fixture | 24 | 286720 | 1454.4 | 291.7 | 5.0x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | medium-fixture | 24 | 286720 | 1468.3 | 292.0 | 5.0x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | small-fixture | 24 | 167936 | 1447.0 | 293.3 | 4.9x | 10x | yes |
| PendingPartialWithdrawal.serialize | large-fixture | 24 | 5000000 | 9.2 | 19.2 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | medium-fixture | 24 | 5000000 | 9.8 | 20.4 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | small-fixture | 24 | 5000000 | 9.0 | 18.7 | 0.5x | 5x | yes |
| PowBlock.deserialize | large-fixture | 96 | 5000000 | 5.2 | 55.9 | 0.1x | 5x | yes |
| PowBlock.deserialize | medium-fixture | 96 | 5000000 | 5.2 | 55.7 | 0.1x | 5x | yes |
| PowBlock.deserialize | small-fixture | 96 | 5000000 | 5.6 | 59.0 | 0.1x | 5x | yes |
| PowBlock.hash_tree_root | large-fixture | 96 | 409600 | 1167.0 | 240.3 | 4.9x | 10x | yes |
| PowBlock.hash_tree_root | medium-fixture | 96 | 409600 | 1167.0 | 240.0 | 4.9x | 10x | yes |
| PowBlock.hash_tree_root | small-fixture | 96 | 409600 | 1167.0 | 239.8 | 4.9x | 10x | yes |
| PowBlock.serialize | large-fixture | 96 | 5000000 | 13.2 | 17.8 | 0.7x | 5x | yes |
| PowBlock.serialize | medium-fixture | 96 | 5000000 | 13.2 | 17.6 | 0.7x | 5x | yes |
| PowBlock.serialize | small-fixture | 96 | 5000000 | 13.6 | 18.3 | 0.7x | 5x | yes |
| ProposerSlashing.deserialize | large-fixture | 416 | 5000000 | 5.2 | 84.0 | 0.1x | 5x | yes |
| ProposerSlashing.deserialize | medium-fixture | 416 | 5000000 | 5.2 | 82.9 | 0.1x | 5x | yes |
| ProposerSlashing.deserialize | small-fixture | 416 | 5000000 | 5.2 | 83.5 | 0.1x | 5x | yes |
| ProposerSlashing.hash_tree_root | large-fixture | 416 | 65536 | 7553.1 | 1512.5 | 5.0x | 10x | yes |
| ProposerSlashing.hash_tree_root | medium-fixture | 416 | 32768 | 7568.4 | 1510.9 | 5.0x | 10x | yes |
| ProposerSlashing.hash_tree_root | small-fixture | 416 | 65536 | 7537.8 | 1513.1 | 5.0x | 10x | yes |
| ProposerSlashing.serialize | large-fixture | 416 | 5000000 | 41.2 | 37.8 | 1.1x | 5x | yes |
| ProposerSlashing.serialize | medium-fixture | 416 | 5000000 | 41.4 | 37.3 | 1.1x | 5x | yes |
| ProposerSlashing.serialize | small-fixture | 416 | 5000000 | 41.2 | 38.8 | 1.1x | 5x | yes |
| Root.deserialize | random | 32 | 5000000 | 4.4 | 29.9 | 0.1x | 5x | yes |
| Root.deserialize | saturated | 32 | 5000000 | 4.2 | 29.3 | 0.1x | 5x | yes |
| Root.deserialize | zero | 32 | 5000000 | 4.0 | 27.0 | 0.1x | 5x | yes |
| Root.hash_tree_root | random | 32 | 5000000 | 38.0 | 128.5 | 0.3x | 10x | yes |
| Root.hash_tree_root | saturated | 32 | 5000000 | 38.0 | 128.9 | 0.3x | 10x | yes |
| Root.hash_tree_root | zero | 32 | 5000000 | 38.8 | 130.0 | 0.3x | 10x | yes |
| Root.serialize | random | 32 | 5000000 | 7.6 | 14.1 | 0.5x | 5x | yes |
| Root.serialize | saturated | 32 | 5000000 | 7.6 | 13.7 | 0.6x | 5x | yes |
| Root.serialize | zero | 32 | 5000000 | 7.0 | 12.3 | 0.6x | 5x | yes |
| RowIndex.deserialize | random | 8 | 5000000 | 4.0 | 25.4 | 0.2x | 5x | yes |
| RowIndex.deserialize | saturated | 8 | 5000000 | 4.0 | 25.1 | 0.2x | 5x | yes |
| RowIndex.deserialize | zero | 8 | 5000000 | 4.2 | 25.3 | 0.2x | 5x | yes |
| RowIndex.hash_tree_root | random | 8 | 5000000 | 43.4 | 137.6 | 0.3x | 10x | yes |
| RowIndex.hash_tree_root | saturated | 8 | 5000000 | 43.0 | 137.8 | 0.3x | 10x | yes |
| RowIndex.hash_tree_root | zero | 8 | 5000000 | 44.2 | 140.9 | 0.3x | 10x | yes |
| RowIndex.serialize | random | 8 | 5000000 | 6.6 | 8.7 | 0.8x | 5x | yes |
| RowIndex.serialize | saturated | 8 | 5000000 | 6.6 | 8.9 | 0.7x | 5x | yes |
| RowIndex.serialize | zero | 8 | 5000000 | 6.4 | 8.9 | 0.7x | 5x | yes |
| SignedAggregateAndProof.deserialize | large-fixture | 446 | 524288 | 686.6 | 139.3 | 4.9x | 5x | yes |
| SignedAggregateAndProof.deserialize | medium-fixture | 445 | 524288 | 646.6 | 133.8 | 4.8x | 5x | yes |
| SignedAggregateAndProof.deserialize | small-fixture | 445 | 524288 | 686.6 | 141.7 | 4.8x | 5x | yes |
| SignedAggregateAndProof.hash_tree_root | large-fixture | 446 | 32768 | 12268.1 | 2415.4 | 5.1x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | medium-fixture | 445 | 40960 | 9863.3 | 1810.3 | 5.4x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | small-fixture | 445 | 32768 | 12298.6 | 2413.0 | 5.1x | 10x | yes |
| SignedAggregateAndProof.serialize | large-fixture | 446 | 5000000 | 42.2 | 49.7 | 0.8x | 5x | yes |
| SignedAggregateAndProof.serialize | medium-fixture | 445 | 5000000 | 43.0 | 51.2 | 0.8x | 5x | yes |
| SignedAggregateAndProof.serialize | small-fixture | 445 | 5000000 | 42.8 | 51.0 | 0.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | large-fixture | 172 | 5000000 | 5.2 | 33.6 | 0.2x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | medium-fixture | 172 | 5000000 | 5.2 | 33.7 | 0.2x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | small-fixture | 172 | 5000000 | 5.2 | 34.2 | 0.2x | 5x | yes |
| SignedBLSToExecutionChange.hash_tree_root | large-fixture | 172 | 163840 | 2819.8 | 602.7 | 4.7x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | medium-fixture | 172 | 163840 | 2819.8 | 602.9 | 4.7x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | small-fixture | 172 | 163840 | 2825.9 | 602.5 | 4.7x | 10x | yes |
| SignedBLSToExecutionChange.serialize | large-fixture | 172 | 5000000 | 21.2 | 22.9 | 0.9x | 5x | yes |
| SignedBLSToExecutionChange.serialize | medium-fixture | 172 | 5000000 | 21.2 | 22.1 | 1.0x | 5x | yes |
| SignedBLSToExecutionChange.serialize | small-fixture | 172 | 5000000 | 21.2 | 22.4 | 0.9x | 5x | yes |
| SignedBeaconBlock.deserialize | large-fixture | 23999 | 131072 | 3692.6 | 9028.4 | 0.4x | 5x | yes |
| SignedBeaconBlock.deserialize | medium-fixture | 18718 | 114688 | 4185.3 | 7582.9 | 0.6x | 5x | yes |
| SignedBeaconBlock.deserialize | small-fixture | 16683 | 139264 | 3339.0 | 6976.1 | 0.5x | 5x | yes |
| SignedBeaconBlock.hash_tree_root | large-fixture | 23999 | 1152 | 400173.6 | 84396.8 | 4.7x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | medium-fixture | 18718 | 1408 | 333096.6 | 69227.1 | 4.8x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | small-fixture | 16683 | 1280 | 262500.0 | 56508.9 | 4.6x | 10x | yes |
| SignedBeaconBlock.serialize | large-fixture | 23999 | 204800 | 2070.3 | 1587.9 | 1.3x | 5x | yes |
| SignedBeaconBlock.serialize | medium-fixture | 18718 | 221184 | 2075.2 | 1199.4 | 1.7x | 5x | yes |
| SignedBeaconBlock.serialize | small-fixture | 16683 | 221184 | 2075.2 | 1090.3 | 1.9x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | large-fixture | 208 | 5000000 | 5.2 | 35.8 | 0.1x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | medium-fixture | 208 | 5000000 | 5.2 | 35.4 | 0.1x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | small-fixture | 208 | 5000000 | 5.0 | 35.7 | 0.1x | 5x | yes |
| SignedBeaconBlockHeader.hash_tree_root | large-fixture | 208 | 131072 | 3517.2 | 728.5 | 4.8x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | medium-fixture | 208 | 139264 | 3532.9 | 729.1 | 4.8x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | small-fixture | 208 | 131072 | 3524.8 | 728.8 | 4.8x | 10x | yes |
| SignedBeaconBlockHeader.serialize | large-fixture | 208 | 5000000 | 21.2 | 23.7 | 0.9x | 5x | yes |
| SignedBeaconBlockHeader.serialize | medium-fixture | 208 | 5000000 | 21.2 | 25.1 | 0.8x | 5x | yes |
| SignedBeaconBlockHeader.serialize | small-fixture | 208 | 5000000 | 21.2 | 23.7 | 0.9x | 5x | yes |
| SignedContributionAndProof.deserialize | large-fixture | 360 | 5000000 | 5.2 | 84.7 | 0.1x | 5x | yes |
| SignedContributionAndProof.deserialize | medium-fixture | 360 | 5000000 | 5.2 | 84.0 | 0.1x | 5x | yes |
| SignedContributionAndProof.deserialize | small-fixture | 360 | 5000000 | 5.2 | 83.7 | 0.1x | 5x | yes |
| SignedContributionAndProof.hash_tree_root | large-fixture | 360 | 73728 | 6388.3 | 1359.1 | 4.7x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | medium-fixture | 360 | 73728 | 6401.9 | 1358.8 | 4.7x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | small-fixture | 360 | 73728 | 6401.9 | 1359.4 | 4.7x | 10x | yes |
| SignedContributionAndProof.serialize | large-fixture | 360 | 5000000 | 41.4 | 37.9 | 1.1x | 5x | yes |
| SignedContributionAndProof.serialize | medium-fixture | 360 | 5000000 | 41.2 | 37.6 | 1.1x | 5x | yes |
| SignedContributionAndProof.serialize | small-fixture | 360 | 5000000 | 41.2 | 37.1 | 1.1x | 5x | yes |
| SignedVoluntaryExit.deserialize | large-fixture | 112 | 5000000 | 5.2 | 29.6 | 0.2x | 5x | yes |
| SignedVoluntaryExit.deserialize | medium-fixture | 112 | 5000000 | 5.2 | 30.0 | 0.2x | 5x | yes |
| SignedVoluntaryExit.deserialize | small-fixture | 112 | 5000000 | 5.2 | 29.6 | 0.2x | 5x | yes |
| SignedVoluntaryExit.hash_tree_root | large-fixture | 112 | 253952 | 1898.0 | 390.8 | 4.9x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | medium-fixture | 112 | 143360 | 1897.3 | 391.5 | 4.8x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | small-fixture | 112 | 253952 | 1898.0 | 391.1 | 4.9x | 10x | yes |
| SignedVoluntaryExit.serialize | large-fixture | 112 | 5000000 | 13.2 | 19.3 | 0.7x | 5x | yes |
| SignedVoluntaryExit.serialize | medium-fixture | 112 | 5000000 | 13.2 | 19.1 | 0.7x | 5x | yes |
| SignedVoluntaryExit.serialize | small-fixture | 112 | 5000000 | 13.2 | 18.5 | 0.7x | 5x | yes |
| SigningData.deserialize | large-fixture | 64 | 5000000 | 5.2 | 13.2 | 0.4x | 5x | yes |
| SigningData.deserialize | medium-fixture | 64 | 5000000 | 5.2 | 13.1 | 0.4x | 5x | yes |
| SigningData.deserialize | small-fixture | 64 | 5000000 | 5.2 | 13.4 | 0.4x | 5x | yes |
| SigningData.hash_tree_root | large-fixture | 64 | 524288 | 534.1 | 101.5 | 5.3x | 10x | yes |
| SigningData.hash_tree_root | medium-fixture | 64 | 524288 | 534.1 | 101.6 | 5.3x | 10x | yes |
| SigningData.hash_tree_root | small-fixture | 64 | 524288 | 534.1 | 101.6 | 5.3x | 10x | yes |
| SigningData.serialize | large-fixture | 64 | 5000000 | 9.0 | 14.6 | 0.6x | 5x | yes |
| SigningData.serialize | medium-fixture | 64 | 5000000 | 8.8 | 14.7 | 0.6x | 5x | yes |
| SigningData.serialize | small-fixture | 64 | 5000000 | 9.0 | 14.9 | 0.6x | 5x | yes |
| SingleAttestation.deserialize | large-fixture | 240 | 5000000 | 5.2 | 58.1 | 0.1x | 5x | yes |
| SingleAttestation.deserialize | medium-fixture | 240 | 5000000 | 5.2 | 57.9 | 0.1x | 5x | yes |
| SingleAttestation.deserialize | small-fixture | 240 | 5000000 | 5.2 | 57.8 | 0.1x | 5x | yes |
| SingleAttestation.hash_tree_root | large-fixture | 240 | 90112 | 5337.8 | 1025.8 | 5.2x | 10x | yes |
| SingleAttestation.hash_tree_root | medium-fixture | 240 | 90112 | 5326.7 | 1024.9 | 5.2x | 10x | yes |
| SingleAttestation.hash_tree_root | small-fixture | 240 | 90112 | 5315.6 | 1024.5 | 5.2x | 10x | yes |
| SingleAttestation.serialize | large-fixture | 240 | 5000000 | 21.0 | 27.1 | 0.8x | 5x | yes |
| SingleAttestation.serialize | medium-fixture | 240 | 5000000 | 21.2 | 27.2 | 0.8x | 5x | yes |
| SingleAttestation.serialize | small-fixture | 240 | 5000000 | 21.0 | 27.3 | 0.8x | 5x | yes |
| Slot.deserialize | random | 8 | 5000000 | 3.8 | 23.1 | 0.2x | 5x | yes |
| Slot.deserialize | saturated | 8 | 5000000 | 3.8 | 23.6 | 0.2x | 5x | yes |
| Slot.deserialize | zero | 8 | 5000000 | 3.8 | 23.3 | 0.2x | 5x | yes |
| Slot.hash_tree_root | random | 8 | 5000000 | 40.2 | 129.1 | 0.3x | 10x | yes |
| Slot.hash_tree_root | saturated | 8 | 5000000 | 40.6 | 127.5 | 0.3x | 10x | yes |
| Slot.hash_tree_root | zero | 8 | 5000000 | 40.4 | 130.2 | 0.3x | 10x | yes |
| Slot.serialize | random | 8 | 5000000 | 6.0 | 8.0 | 0.7x | 5x | yes |
| Slot.serialize | saturated | 8 | 5000000 | 6.0 | 8.1 | 0.7x | 5x | yes |
| Slot.serialize | zero | 8 | 5000000 | 6.0 | 8.0 | 0.8x | 5x | yes |
| SubnetID.deserialize | random | 8 | 5000000 | 3.6 | 23.4 | 0.2x | 5x | yes |
| SubnetID.deserialize | saturated | 8 | 5000000 | 3.6 | 23.2 | 0.2x | 5x | yes |
| SubnetID.deserialize | zero | 8 | 5000000 | 3.8 | 23.3 | 0.2x | 5x | yes |
| SubnetID.hash_tree_root | random | 8 | 5000000 | 39.8 | 130.4 | 0.3x | 10x | yes |
| SubnetID.hash_tree_root | saturated | 8 | 5000000 | 39.4 | 131.0 | 0.3x | 10x | yes |
| SubnetID.hash_tree_root | zero | 8 | 5000000 | 40.6 | 131.3 | 0.3x | 10x | yes |
| SubnetID.serialize | random | 8 | 5000000 | 6.0 | 8.2 | 0.7x | 5x | yes |
| SubnetID.serialize | saturated | 8 | 5000000 | 6.0 | 8.2 | 0.7x | 5x | yes |
| SubnetID.serialize | zero | 8 | 5000000 | 6.0 | 8.0 | 0.8x | 5x | yes |
| SyncAggregate.deserialize | large-fixture | 160 | 5000000 | 5.2 | 34.1 | 0.2x | 5x | yes |
| SyncAggregate.deserialize | medium-fixture | 160 | 5000000 | 5.2 | 33.6 | 0.2x | 5x | yes |
| SyncAggregate.deserialize | small-fixture | 160 | 5000000 | 5.4 | 34.0 | 0.2x | 5x | yes |
| SyncAggregate.hash_tree_root | large-fixture | 160 | 286720 | 1670.6 | 386.1 | 4.3x | 10x | yes |
| SyncAggregate.hash_tree_root | medium-fixture | 160 | 286720 | 1667.1 | 386.5 | 4.3x | 10x | yes |
| SyncAggregate.hash_tree_root | small-fixture | 160 | 286720 | 1670.6 | 386.3 | 4.3x | 10x | yes |
| SyncAggregate.serialize | large-fixture | 160 | 5000000 | 21.0 | 21.4 | 1.0x | 5x | yes |
| SyncAggregate.serialize | medium-fixture | 160 | 5000000 | 21.2 | 21.0 | 1.0x | 5x | yes |
| SyncAggregate.serialize | small-fixture | 160 | 5000000 | 21.4 | 21.4 | 1.0x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | large-fixture | 16 | 5000000 | 5.2 | 10.9 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | medium-fixture | 16 | 5000000 | 5.2 | 10.6 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | small-fixture | 16 | 5000000 | 5.2 | 10.8 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.hash_tree_root | large-fixture | 16 | 524288 | 543.6 | 100.4 | 5.4x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | medium-fixture | 16 | 524288 | 543.6 | 100.3 | 5.4x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | small-fixture | 16 | 524288 | 547.4 | 100.3 | 5.5x | 10x | yes |
| SyncAggregatorSelectionData.serialize | large-fixture | 16 | 5000000 | 6.2 | 12.4 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | medium-fixture | 16 | 5000000 | 6.2 | 12.5 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | small-fixture | 16 | 5000000 | 6.0 | 12.4 | 0.5x | 5x | yes |
| SyncCommittee.deserialize | large-fixture | 24624 | 5000000 | 5.2 | 1251.4 | 0.0x | 5x | yes |
| SyncCommittee.deserialize | medium-fixture | 24624 | 5000000 | 5.2 | 1263.2 | 0.0x | 5x | yes |
| SyncCommittee.deserialize | small-fixture | 24624 | 5000000 | 5.2 | 1201.4 | 0.0x | 5x | yes |
| SyncCommittee.hash_tree_root | large-fixture | 24624 | 1408 | 334517.0 | 81107.4 | 4.1x | 10x | yes |
| SyncCommittee.hash_tree_root | medium-fixture | 24624 | 1408 | 334517.0 | 81131.8 | 4.1x | 10x | yes |
| SyncCommittee.hash_tree_root | small-fixture | 24624 | 1408 | 331676.1 | 81081.9 | 4.1x | 10x | yes |
| SyncCommittee.serialize | large-fixture | 24624 | 126976 | 2047.6 | 1596.7 | 1.3x | 5x | yes |
| SyncCommittee.serialize | medium-fixture | 24624 | 126976 | 2047.6 | 1655.4 | 1.2x | 5x | yes |
| SyncCommittee.serialize | small-fixture | 24624 | 126976 | 2047.6 | 1651.3 | 1.2x | 5x | yes |
| SyncCommitteeContribution.deserialize | large-fixture | 160 | 5000000 | 5.2 | 36.0 | 0.1x | 5x | yes |
| SyncCommitteeContribution.deserialize | medium-fixture | 160 | 5000000 | 5.2 | 35.9 | 0.1x | 5x | yes |
| SyncCommitteeContribution.deserialize | small-fixture | 160 | 5000000 | 5.2 | 35.8 | 0.1x | 5x | yes |
| SyncCommitteeContribution.hash_tree_root | large-fixture | 160 | 155648 | 3038.9 | 650.9 | 4.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | medium-fixture | 160 | 163840 | 3039.6 | 650.6 | 4.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | small-fixture | 160 | 163840 | 3033.4 | 651.2 | 4.7x | 10x | yes |
| SyncCommitteeContribution.serialize | large-fixture | 160 | 5000000 | 21.2 | 21.5 | 1.0x | 5x | yes |
| SyncCommitteeContribution.serialize | medium-fixture | 160 | 5000000 | 21.2 | 21.1 | 1.0x | 5x | yes |
| SyncCommitteeContribution.serialize | small-fixture | 160 | 5000000 | 21.2 | 21.5 | 1.0x | 5x | yes |
| SyncCommitteeMessage.deserialize | large-fixture | 144 | 5000000 | 5.2 | 19.0 | 0.3x | 5x | yes |
| SyncCommitteeMessage.deserialize | medium-fixture | 144 | 5000000 | 5.2 | 18.6 | 0.3x | 5x | yes |
| SyncCommitteeMessage.deserialize | small-fixture | 144 | 5000000 | 5.2 | 19.2 | 0.3x | 5x | yes |
| SyncCommitteeMessage.hash_tree_root | large-fixture | 144 | 221184 | 2129.4 | 449.8 | 4.7x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | medium-fixture | 144 | 221184 | 2129.4 | 449.0 | 4.7x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | small-fixture | 144 | 221184 | 2129.4 | 449.6 | 4.7x | 10x | yes |
| SyncCommitteeMessage.serialize | large-fixture | 144 | 5000000 | 21.2 | 20.7 | 1.0x | 5x | yes |
| SyncCommitteeMessage.serialize | medium-fixture | 144 | 5000000 | 21.2 | 20.5 | 1.0x | 5x | yes |
| SyncCommitteeMessage.serialize | small-fixture | 144 | 5000000 | 21.2 | 21.0 | 1.0x | 5x | yes |
| Transaction.deserialize | large | 1048576 | 5000000 | 19.6 | 40540.6 | 0.0x | 5x | yes |
| Transaction.deserialize | medium | 4096 | 5000000 | 19.6 | 268.8 | 0.1x | 5x | yes |
| Transaction.deserialize | small | 32 | 5000000 | 19.8 | 27.3 | 0.7x | 5x | yes |
| Transaction.hash_tree_root | large | 1048576 | 54 | 9018518.5 | 2194632.8 | 4.1x | 10x | yes |
| Transaction.hash_tree_root | medium | 4096 | 8192 | 41870.1 | 10001.9 | 4.2x | 10x | yes |
| Transaction.hash_tree_root | small | 32 | 65536 | 6897.0 | 1907.9 | 3.6x | 10x | yes |
| Transaction.serialize | large | 1048576 | 3968 | 65020.2 | 39993.2 | 1.6x | 5x | yes |
| Transaction.serialize | medium | 4096 | 1572864 | 266.4 | 226.8 | 1.2x | 5x | yes |
| Transaction.serialize | small | 32 | 5000000 | 7.0 | 12.6 | 0.6x | 5x | yes |
| Validator.deserialize | large-fixture | 121 | 2097152 | 120.2 | 32.9 | 3.7x | 5x | yes |
| Validator.deserialize | medium-fixture | 121 | 3670016 | 120.2 | 32.2 | 3.7x | 5x | yes |
| Validator.deserialize | small-fixture | 121 | 3670016 | 118.8 | 32.5 | 3.7x | 5x | yes |
| Validator.hash_tree_root | large-fixture | 121 | 155648 | 3122.4 | 589.8 | 5.3x | 10x | yes |
| Validator.hash_tree_root | medium-fixture | 121 | 155648 | 3122.4 | 590.6 | 5.3x | 10x | yes |
| Validator.hash_tree_root | small-fixture | 121 | 155648 | 3128.9 | 590.4 | 5.3x | 10x | yes |
| Validator.serialize | large-fixture | 121 | 5000000 | 13.2 | 20.0 | 0.7x | 5x | yes |
| Validator.serialize | medium-fixture | 121 | 5000000 | 13.2 | 20.1 | 0.7x | 5x | yes |
| Validator.serialize | small-fixture | 121 | 5000000 | 13.2 | 20.0 | 0.7x | 5x | yes |
| ValidatorIndex.deserialize | random | 8 | 5000000 | 3.6 | 23.5 | 0.2x | 5x | yes |
| ValidatorIndex.deserialize | saturated | 8 | 5000000 | 4.0 | 25.4 | 0.2x | 5x | yes |
| ValidatorIndex.deserialize | zero | 8 | 5000000 | 3.8 | 23.2 | 0.2x | 5x | yes |
| ValidatorIndex.hash_tree_root | random | 8 | 5000000 | 39.8 | 130.9 | 0.3x | 10x | yes |
| ValidatorIndex.hash_tree_root | saturated | 8 | 5000000 | 42.0 | 138.7 | 0.3x | 10x | yes |
| ValidatorIndex.hash_tree_root | zero | 8 | 5000000 | 39.8 | 130.5 | 0.3x | 10x | yes |
| ValidatorIndex.serialize | random | 8 | 5000000 | 6.0 | 8.2 | 0.7x | 5x | yes |
| ValidatorIndex.serialize | saturated | 8 | 5000000 | 6.6 | 8.5 | 0.8x | 5x | yes |
| ValidatorIndex.serialize | zero | 8 | 5000000 | 6.0 | 8.0 | 0.8x | 5x | yes |
| Version.deserialize | random | 4 | 5000000 | 4.0 | 25.5 | 0.2x | 5x | yes |
| Version.deserialize | saturated | 4 | 5000000 | 4.2 | 25.0 | 0.2x | 5x | yes |
| Version.deserialize | zero | 4 | 5000000 | 4.2 | 25.3 | 0.2x | 5x | yes |
| Version.hash_tree_root | random | 4 | 5000000 | 42.8 | 134.8 | 0.3x | 10x | yes |
| Version.hash_tree_root | saturated | 4 | 5000000 | 42.0 | 138.6 | 0.3x | 10x | yes |
| Version.hash_tree_root | zero | 4 | 5000000 | 42.2 | 138.5 | 0.3x | 10x | yes |
| Version.serialize | random | 4 | 5000000 | 6.4 | 8.4 | 0.8x | 5x | yes |
| Version.serialize | saturated | 4 | 5000000 | 6.4 | 8.5 | 0.8x | 5x | yes |
| Version.serialize | zero | 4 | 5000000 | 6.4 | 8.4 | 0.8x | 5x | yes |
| VersionedHash.deserialize | random | 32 | 5000000 | 4.4 | 29.5 | 0.1x | 5x | yes |
| VersionedHash.deserialize | saturated | 32 | 5000000 | 4.2 | 29.0 | 0.1x | 5x | yes |
| VersionedHash.deserialize | zero | 32 | 5000000 | 4.2 | 28.5 | 0.1x | 5x | yes |
| VersionedHash.hash_tree_root | random | 32 | 5000000 | 37.8 | 127.7 | 0.3x | 10x | yes |
| VersionedHash.hash_tree_root | saturated | 32 | 5000000 | 38.2 | 130.3 | 0.3x | 10x | yes |
| VersionedHash.hash_tree_root | zero | 32 | 5000000 | 37.6 | 126.2 | 0.3x | 10x | yes |
| VersionedHash.serialize | random | 32 | 5000000 | 7.4 | 13.4 | 0.6x | 5x | yes |
| VersionedHash.serialize | saturated | 32 | 5000000 | 7.4 | 13.4 | 0.6x | 5x | yes |
| VersionedHash.serialize | zero | 32 | 5000000 | 7.4 | 13.2 | 0.6x | 5x | yes |
| VoluntaryExit.deserialize | large-fixture | 16 | 5000000 | 5.2 | 10.9 | 0.5x | 5x | yes |
| VoluntaryExit.deserialize | medium-fixture | 16 | 5000000 | 5.0 | 10.5 | 0.5x | 5x | yes |
| VoluntaryExit.deserialize | small-fixture | 16 | 5000000 | 5.4 | 11.2 | 0.5x | 5x | yes |
| VoluntaryExit.hash_tree_root | large-fixture | 16 | 524288 | 549.3 | 100.5 | 5.5x | 10x | yes |
| VoluntaryExit.hash_tree_root | medium-fixture | 16 | 524288 | 547.4 | 100.4 | 5.4x | 10x | yes |
| VoluntaryExit.hash_tree_root | small-fixture | 16 | 524288 | 545.5 | 100.6 | 5.4x | 10x | yes |
| VoluntaryExit.serialize | large-fixture | 16 | 5000000 | 6.4 | 12.5 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | medium-fixture | 16 | 5000000 | 6.4 | 12.8 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | small-fixture | 16 | 5000000 | 7.0 | 13.9 | 0.5x | 5x | yes |
| Withdrawal.deserialize | large-fixture | 44 | 5000000 | 5.2 | 12.8 | 0.4x | 5x | yes |
| Withdrawal.deserialize | medium-fixture | 44 | 5000000 | 5.2 | 13.2 | 0.4x | 5x | yes |
| Withdrawal.deserialize | small-fixture | 44 | 5000000 | 5.2 | 12.7 | 0.4x | 5x | yes |
| Withdrawal.hash_tree_root | large-fixture | 44 | 204800 | 1293.9 | 243.4 | 5.3x | 10x | yes |
| Withdrawal.hash_tree_root | medium-fixture | 44 | 335872 | 1298.1 | 243.1 | 5.3x | 10x | yes |
| Withdrawal.hash_tree_root | small-fixture | 44 | 335872 | 1298.1 | 243.3 | 5.3x | 10x | yes |
| Withdrawal.serialize | large-fixture | 44 | 5000000 | 9.0 | 15.1 | 0.6x | 5x | yes |
| Withdrawal.serialize | medium-fixture | 44 | 5000000 | 9.0 | 15.2 | 0.6x | 5x | yes |
| Withdrawal.serialize | small-fixture | 44 | 5000000 | 9.6 | 15.7 | 0.6x | 5x | yes |
| WithdrawalIndex.deserialize | random | 8 | 5000000 | 4.2 | 25.4 | 0.2x | 5x | yes |
| WithdrawalIndex.deserialize | saturated | 8 | 5000000 | 4.0 | 25.3 | 0.2x | 5x | yes |
| WithdrawalIndex.deserialize | zero | 8 | 5000000 | 3.8 | 23.4 | 0.2x | 5x | yes |
| WithdrawalIndex.hash_tree_root | random | 8 | 5000000 | 43.0 | 142.1 | 0.3x | 10x | yes |
| WithdrawalIndex.hash_tree_root | saturated | 8 | 5000000 | 43.0 | 138.1 | 0.3x | 10x | yes |
| WithdrawalIndex.hash_tree_root | zero | 8 | 5000000 | 43.2 | 139.0 | 0.3x | 10x | yes |
| WithdrawalIndex.serialize | random | 8 | 5000000 | 6.6 | 9.0 | 0.7x | 5x | yes |
| WithdrawalIndex.serialize | saturated | 8 | 5000000 | 6.6 | 8.7 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | zero | 8 | 5000000 | 6.0 | 8.2 | 0.7x | 5x | yes |
| WithdrawalRequest.deserialize | large-fixture | 76 | 5000000 | 5.2 | 15.0 | 0.3x | 5x | yes |
| WithdrawalRequest.deserialize | medium-fixture | 76 | 5000000 | 5.2 | 14.8 | 0.4x | 5x | yes |
| WithdrawalRequest.deserialize | small-fixture | 76 | 5000000 | 5.6 | 15.7 | 0.4x | 5x | yes |
| WithdrawalRequest.hash_tree_root | large-fixture | 76 | 335872 | 1536.3 | 317.4 | 4.8x | 10x | yes |
| WithdrawalRequest.hash_tree_root | medium-fixture | 76 | 167936 | 1482.7 | 317.1 | 4.7x | 10x | yes |
| WithdrawalRequest.hash_tree_root | small-fixture | 76 | 167936 | 1488.7 | 317.5 | 4.7x | 10x | yes |
| WithdrawalRequest.serialize | large-fixture | 76 | 5000000 | 13.2 | 16.3 | 0.8x | 5x | yes |
| WithdrawalRequest.serialize | medium-fixture | 76 | 5000000 | 13.2 | 16.2 | 0.8x | 5x | yes |
| WithdrawalRequest.serialize | small-fixture | 76 | 5000000 | 14.0 | 17.6 | 0.8x | 5x | yes |
| boolean.deserialize | false | 1 | 5000000 | 18.4 | 22.9 | 0.8x | 5x | yes |
| boolean.deserialize | true | 1 | 5000000 | 18.8 | 23.7 | 0.8x | 5x | yes |
| boolean.hash_tree_root | false | 1 | 5000000 | 49.8 | 180.7 | 0.3x | 10x | yes |
| boolean.hash_tree_root | true | 1 | 5000000 | 44.8 | 138.4 | 0.3x | 10x | yes |
| boolean.serialize | false | 1 | 5000000 | 6.0 | 7.5 | 0.8x | 5x | yes |
| boolean.serialize | true | 1 | 5000000 | 6.0 | 7.6 | 0.8x | 5x | yes |
| uint256.deserialize | random | 32 | 5000000 | 5.8 | 43.5 | 0.1x | 5x | yes |
| uint256.deserialize | saturated | 32 | 5000000 | 5.2 | 40.4 | 0.1x | 5x | yes |
| uint256.deserialize | zero | 32 | 5000000 | 6.4 | 47.9 | 0.1x | 5x | yes |
| uint256.hash_tree_root | random | 32 | 4980736 | 49.8 | 172.1 | 0.3x | 10x | yes |
| uint256.hash_tree_root | saturated | 32 | 5000000 | 37.6 | 123.2 | 0.3x | 10x | yes |
| uint256.hash_tree_root | zero | 32 | 5000000 | 52.8 | 179.3 | 0.3x | 10x | yes |
| uint256.serialize | random | 32 | 5000000 | 10.8 | 19.1 | 0.6x | 5x | yes |
| uint256.serialize | saturated | 32 | 5000000 | 10.8 | 18.7 | 0.6x | 5x | yes |
| uint256.serialize | zero | 32 | 5000000 | 13.6 | 24.4 | 0.6x | 5x | yes |
| uint32.deserialize | random | 4 | 5000000 | 4.0 | 26.1 | 0.2x | 5x | yes |
| uint32.deserialize | saturated | 4 | 5000000 | 4.0 | 26.1 | 0.2x | 5x | yes |
| uint32.deserialize | zero | 4 | 5000000 | 4.0 | 26.0 | 0.2x | 5x | yes |
| uint32.hash_tree_root | random | 4 | 5000000 | 42.8 | 135.9 | 0.3x | 10x | yes |
| uint32.hash_tree_root | saturated | 4 | 5000000 | 43.0 | 139.4 | 0.3x | 10x | yes |
| uint32.hash_tree_root | zero | 4 | 5000000 | 43.6 | 140.7 | 0.3x | 10x | yes |
| uint32.serialize | random | 4 | 5000000 | 6.4 | 8.6 | 0.7x | 5x | yes |
| uint32.serialize | saturated | 4 | 5000000 | 6.6 | 8.7 | 0.8x | 5x | yes |
| uint32.serialize | zero | 4 | 5000000 | 6.4 | 8.7 | 0.7x | 5x | yes |
| uint64.deserialize | random | 8 | 5000000 | 4.0 | 25.2 | 0.2x | 5x | yes |
| uint64.deserialize | saturated | 8 | 5000000 | 4.0 | 24.9 | 0.2x | 5x | yes |
| uint64.deserialize | zero | 8 | 5000000 | 4.0 | 24.8 | 0.2x | 5x | yes |
| uint64.hash_tree_root | random | 8 | 5000000 | 43.0 | 136.7 | 0.3x | 10x | yes |
| uint64.hash_tree_root | saturated | 8 | 5000000 | 43.2 | 136.9 | 0.3x | 10x | yes |
| uint64.hash_tree_root | zero | 8 | 5000000 | 42.8 | 139.3 | 0.3x | 10x | yes |
| uint64.serialize | random | 8 | 5000000 | 6.6 | 8.8 | 0.8x | 5x | yes |
| uint64.serialize | saturated | 8 | 5000000 | 6.6 | 8.7 | 0.8x | 5x | yes |
| uint64.serialize | zero | 8 | 5000000 | 6.4 | 8.8 | 0.7x | 5x | yes |
| uint8.deserialize | random | 1 | 5000000 | 4.0 | 25.2 | 0.2x | 5x | yes |
| uint8.deserialize | saturated | 1 | 5000000 | 4.0 | 24.5 | 0.2x | 5x | yes |
| uint8.deserialize | zero | 1 | 5000000 | 4.0 | 24.0 | 0.2x | 5x | yes |
| uint8.hash_tree_root | random | 1 | 5000000 | 45.2 | 138.5 | 0.3x | 10x | yes |
| uint8.hash_tree_root | saturated | 1 | 5000000 | 42.8 | 137.4 | 0.3x | 10x | yes |
| uint8.hash_tree_root | zero | 1 | 5000000 | 44.2 | 139.8 | 0.3x | 10x | yes |
| uint8.serialize | random | 1 | 5000000 | 6.6 | 8.0 | 0.8x | 5x | yes |
| uint8.serialize | saturated | 1 | 5000000 | 6.6 | 8.2 | 0.8x | 5x | yes |
| uint8.serialize | zero | 1 | 5000000 | 6.6 | 7.9 | 0.8x | 5x | yes |

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
