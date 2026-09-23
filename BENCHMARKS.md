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
Bend is the **generated typed owning object API** through its native C
backend, run with `--threads 1 --gpu off`; the measured programs are
`benchmarks/objprog/g<k>.bend` over `types/fulu_obj.bend`, which
`codegen/generate.py` emits from `codegen/fulu.yaml` (see docs/CODEGEN.md).
Each is built under a compile-memory cap, every attempt recorded in the
report's `bend_compiles`. Go is pinned fastssz via go-eth2-client, built
with `go build` and run with `GOMAXPROCS(1)`. No Bun/JavaScript result
appears here.

What each operation is:

| operation | Bend (generated object API) | Go fastssz |
|---|---|---|
| deserialize | `X_decode(buf, size)`: the generated validator over the whole window, then the generated reader, which builds the typed owning object and copies its storage out of the input; plus a fold over every field of the result, so no construction is left unevaluated | `UnmarshalSSZ` into the generated struct |
| serialize | `X_serialize(o)`: the checked encoder (refuses an invalid object, else fresh canonical bytes), after one untimed decode; every encoding is consumed | `MarshalSSZ` after one untimed decode |
| hash_tree_root | `X_hash_tree_root(h, o)` of that object, with one hasher created before the clock starts, as fastssz reuses its package-level zero-hash table | `HashTreeRoot` after one untimed decode |

Reading the workload into a buffer and selecting the type are outside every
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
bytes (Bend: decode, then `X_serialize` compared byte for byte) and agree on the
checksum of the hash tree root, and on official fixtures that checksum must
equal the official root's. That agreement is what `verified` means.

Stated plainly:

* Both sides start from bytes and end with a fully constructed typed value,
  and both allocate and copy to do it. The decode row includes a fold over
  every field of the Bend object, because record fields are lazy and a
  decode that left them unevaluated would not be comparable.
* Go's SHA-256 uses the CPU's SHA instructions. Bend uses the pinned
  pure-Bend package, which by instruction may not be replaced with hardware
  SHA, foreign crypto or intrinsics. Per 64-byte node that is about 0.26 us
  against Go's ~0.06 us, so `hash_tree_root` starts about 4x behind before
  any walking overhead. It nevertheless meets its 10x limit on every row.
* Encode allocates its output with `Array.new(U32, d, 0)`, the only
  allocation the pinned Base offers, which zero-fills a power-of-two number
  of words (measured 0.24 ns/word here, against 0.19 ns/word for the copy
  itself). Go's `make`/`append` does not pay that. For a flat value such as
  `Blob` the zero-fill alone costs about as much as Go's whole marshal. This
  is a property of the available primitives and is reported, not worked
  around.
* The machine was not idle: other user processes ran throughout. Samples
  alternate between the two sides, so the load affects both.

| environment | |
|---|---|
| cpu | Apple M4 |
| os | macOS-15.6-arm64-arm-64bit |
| bend_compiler | bend 2.0.25 |
| reference_compiler | go version go1.25.5 darwin/arm64 |
| bend_flags | --threads 1 --gpu off (native C backend, release build) |
| reference_flags | go build (release defaults), GOMAXPROCS=1 |
| reference_revision | go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod) |

## Result against the frozen contract

* 978 measured workloads covering 327 of the 327 required operations.
* 978 of 978 workloads are within their operation limit (deserialize/serialize 5x, hash_tree_root 10x).

Ratio distribution over all measured workloads: minimum 0.0x, median 1.1x, maximum 5.8x.

* `deserialize`: 326 workloads, minimum 0.1x, median 1.0x, maximum 4.1x (limit 5x).
* `serialize`: 326 workloads, minimum 0.4x, median 0.8x, maximum 4.0x (limit 5x).
* `hash_tree_root`: 326 workloads, minimum 0.0x, median 3.2x, maximum 5.8x (limit 10x).

## What the numbers say

Every measured workload is within its limit.

## All measured workloads

| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |
|---|---|---:|---:|---:|---:|---:|---:|:--:|
| AggregateAndProof.deserialize | large-fixture | 346 | 2097152 | 231.7 | 108.1 | 2.1x | 5x | yes |
| AggregateAndProof.deserialize | medium-fixture | 345 | 2097152 | 233.7 | 108.3 | 2.2x | 5x | yes |
| AggregateAndProof.deserialize | small-fixture | 345 | 1572864 | 234.6 | 109.2 | 2.1x | 5x | yes |
| AggregateAndProof.hash_tree_root | large-fixture | 346 | 57344 | 8056.6 | 2123.4 | 3.8x | 10x | yes |
| AggregateAndProof.hash_tree_root | medium-fixture | 345 | 81920 | 5676.3 | 1522.4 | 3.7x | 10x | yes |
| AggregateAndProof.hash_tree_root | small-fixture | 345 | 57344 | 8056.6 | 2129.1 | 3.8x | 10x | yes |
| AggregateAndProof.serialize | large-fixture | 346 | 3670016 | 118.5 | 38.6 | 3.1x | 5x | yes |
| AggregateAndProof.serialize | medium-fixture | 345 | 4194304 | 115.9 | 39.3 | 2.9x | 5x | yes |
| AggregateAndProof.serialize | small-fixture | 345 | 4194304 | 118.5 | 39.4 | 3.0x | 5x | yes |
| Attestation.deserialize | large-fixture | 237 | 2621440 | 167.1 | 87.1 | 1.9x | 5x | yes |
| Attestation.deserialize | medium-fixture | 237 | 2621440 | 166.7 | 86.8 | 1.9x | 5x | yes |
| Attestation.deserialize | small-fixture | 237 | 2621440 | 167.8 | 87.9 | 1.9x | 5x | yes |
| Attestation.hash_tree_root | large-fixture | 237 | 73728 | 6442.6 | 1705.2 | 3.8x | 10x | yes |
| Attestation.hash_tree_root | medium-fixture | 237 | 73728 | 6442.6 | 1707.3 | 3.8x | 10x | yes |
| Attestation.hash_tree_root | small-fixture | 237 | 73728 | 6442.6 | 1102.0 | 5.8x | 10x | yes |
| Attestation.serialize | large-fixture | 237 | 4194304 | 109.9 | 29.7 | 3.7x | 5x | yes |
| Attestation.serialize | medium-fixture | 237 | 3670016 | 116.1 | 30.4 | 3.8x | 5x | yes |
| Attestation.serialize | small-fixture | 237 | 4194304 | 111.3 | 30.4 | 3.7x | 5x | yes |
| AttestationData.deserialize | large-fixture | 128 | 5000000 | 85.4 | 38.8 | 2.2x | 5x | yes |
| AttestationData.deserialize | medium-fixture | 128 | 5000000 | 85.2 | 38.2 | 2.2x | 5x | yes |
| AttestationData.deserialize | small-fixture | 128 | 5000000 | 85.2 | 38.3 | 2.2x | 5x | yes |
| AttestationData.hash_tree_root | large-fixture | 128 | 221184 | 2138.5 | 603.3 | 3.5x | 10x | yes |
| AttestationData.hash_tree_root | medium-fixture | 128 | 204800 | 2138.7 | 603.5 | 3.5x | 10x | yes |
| AttestationData.hash_tree_root | small-fixture | 128 | 221184 | 2134.0 | 604.2 | 3.5x | 10x | yes |
| AttestationData.serialize | large-fixture | 128 | 5000000 | 23.4 | 21.1 | 1.1x | 5x | yes |
| AttestationData.serialize | medium-fixture | 128 | 5000000 | 24.0 | 20.9 | 1.1x | 5x | yes |
| AttestationData.serialize | small-fixture | 128 | 5000000 | 23.0 | 19.9 | 1.2x | 5x | yes |
| AttesterSlashing.deserialize | large-fixture | 624 | 1048576 | 351.9 | 176.4 | 2.0x | 5x | yes |
| AttesterSlashing.deserialize | medium-fixture | 552 | 1048576 | 347.1 | 172.3 | 2.0x | 5x | yes |
| AttesterSlashing.deserialize | small-fixture | 512 | 1048576 | 344.3 | 166.0 | 2.1x | 5x | yes |
| AttesterSlashing.hash_tree_root | large-fixture | 624 | 24576 | 16805.0 | 4418.6 | 3.8x | 10x | yes |
| AttesterSlashing.hash_tree_root | medium-fixture | 552 | 24576 | 16479.5 | 4293.0 | 3.8x | 10x | yes |
| AttesterSlashing.hash_tree_root | small-fixture | 512 | 24576 | 16235.4 | 4255.7 | 3.8x | 10x | yes |
| AttesterSlashing.serialize | large-fixture | 624 | 1310720 | 191.5 | 70.1 | 2.7x | 5x | yes |
| AttesterSlashing.serialize | medium-fixture | 552 | 2621440 | 190.0 | 62.3 | 3.0x | 5x | yes |
| AttesterSlashing.serialize | small-fixture | 512 | 2621440 | 183.1 | 56.0 | 3.3x | 5x | yes |
| BLSPubkey.deserialize | random | 48 | 5000000 | 32.0 | 27.9 | 1.1x | 5x | yes |
| BLSPubkey.deserialize | saturated | 48 | 5000000 | 32.0 | 28.1 | 1.1x | 5x | yes |
| BLSPubkey.deserialize | zero | 48 | 5000000 | 32.6 | 28.4 | 1.1x | 5x | yes |
| BLSPubkey.hash_tree_root | random | 48 | 1572864 | 274.7 | 226.9 | 1.2x | 10x | yes |
| BLSPubkey.hash_tree_root | saturated | 48 | 1572864 | 274.0 | 230.6 | 1.2x | 10x | yes |
| BLSPubkey.hash_tree_root | zero | 48 | 1572864 | 273.4 | 223.8 | 1.2x | 10x | yes |
| BLSPubkey.serialize | random | 48 | 5000000 | 10.4 | 13.1 | 0.8x | 5x | yes |
| BLSPubkey.serialize | saturated | 48 | 5000000 | 10.4 | 13.4 | 0.8x | 5x | yes |
| BLSPubkey.serialize | zero | 48 | 5000000 | 9.0 | 13.4 | 0.7x | 5x | yes |
| BLSSignature.deserialize | random | 96 | 5000000 | 49.6 | 30.5 | 1.6x | 5x | yes |
| BLSSignature.deserialize | saturated | 96 | 5000000 | 47.8 | 31.1 | 1.5x | 5x | yes |
| BLSSignature.deserialize | zero | 96 | 5000000 | 45.4 | 30.5 | 1.5x | 5x | yes |
| BLSSignature.hash_tree_root | random | 96 | 507904 | 809.2 | 371.8 | 2.2x | 10x | yes |
| BLSSignature.hash_tree_root | saturated | 96 | 524288 | 810.6 | 369.9 | 2.2x | 10x | yes |
| BLSSignature.hash_tree_root | zero | 96 | 507904 | 809.2 | 373.2 | 2.2x | 10x | yes |
| BLSSignature.serialize | random | 96 | 5000000 | 19.0 | 15.8 | 1.2x | 5x | yes |
| BLSSignature.serialize | saturated | 96 | 5000000 | 19.0 | 15.7 | 1.2x | 5x | yes |
| BLSSignature.serialize | zero | 96 | 5000000 | 18.0 | 16.3 | 1.1x | 5x | yes |
| BLSToExecutionChange.deserialize | large-fixture | 76 | 5000000 | 42.0 | 14.9 | 2.8x | 5x | yes |
| BLSToExecutionChange.deserialize | medium-fixture | 76 | 5000000 | 42.0 | 14.6 | 2.9x | 5x | yes |
| BLSToExecutionChange.deserialize | small-fixture | 76 | 5000000 | 42.6 | 14.8 | 2.9x | 5x | yes |
| BLSToExecutionChange.hash_tree_root | large-fixture | 76 | 409600 | 1071.8 | 318.5 | 3.4x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | medium-fixture | 76 | 409600 | 1069.3 | 318.2 | 3.4x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | small-fixture | 76 | 409600 | 1069.3 | 319.2 | 3.3x | 10x | yes |
| BLSToExecutionChange.serialize | large-fixture | 76 | 5000000 | 14.2 | 16.3 | 0.9x | 5x | yes |
| BLSToExecutionChange.serialize | medium-fixture | 76 | 5000000 | 14.2 | 16.3 | 0.9x | 5x | yes |
| BLSToExecutionChange.serialize | small-fixture | 76 | 5000000 | 14.2 | 16.5 | 0.9x | 5x | yes |
| BeaconBlock.deserialize | large-fixture | 21487 | 65536 | 7553.1 | 8821.4 | 0.9x | 5x | yes |
| BeaconBlock.deserialize | medium-fixture | 21424 | 65536 | 6759.6 | 7730.2 | 0.9x | 5x | yes |
| BeaconBlock.deserialize | small-fixture | 11198 | 81920 | 5835.0 | 2540.4 | 2.3x | 5x | yes |
| BeaconBlock.hash_tree_root | large-fixture | 21487 | 1664 | 294471.2 | 75338.2 | 3.9x | 10x | yes |
| BeaconBlock.hash_tree_root | medium-fixture | 21424 | 1408 | 316051.1 | 79111.3 | 4.0x | 10x | yes |
| BeaconBlock.hash_tree_root | small-fixture | 11198 | 1216 | 208059.2 | 53753.6 | 3.9x | 10x | yes |
| BeaconBlock.serialize | large-fixture | 21487 | 106496 | 4422.7 | 1366.4 | 3.2x | 5x | yes |
| BeaconBlock.serialize | medium-fixture | 21424 | 122880 | 3898.1 | 1322.5 | 2.9x | 5x | yes |
| BeaconBlock.serialize | small-fixture | 11198 | 81920 | 3088.4 | 775.2 | 4.0x | 5x | yes |
| BeaconBlockBody.deserialize | large-fixture | 24042 | 65536 | 7171.6 | 8844.6 | 0.8x | 5x | yes |
| BeaconBlockBody.deserialize | medium-fixture | 19087 | 73728 | 6279.8 | 6320.8 | 1.0x | 5x | yes |
| BeaconBlockBody.deserialize | small-fixture | 11894 | 106496 | 4403.9 | 4025.3 | 1.1x | 5x | yes |
| BeaconBlockBody.hash_tree_root | large-fixture | 24042 | 1280 | 369531.2 | 91680.4 | 4.0x | 10x | yes |
| BeaconBlockBody.hash_tree_root | medium-fixture | 19087 | 832 | 300480.8 | 76302.9 | 3.9x | 10x | yes |
| BeaconBlockBody.hash_tree_root | small-fixture | 11894 | 2176 | 218290.4 | 55032.2 | 4.0x | 10x | yes |
| BeaconBlockBody.serialize | large-fixture | 24042 | 114688 | 4255.0 | 1596.8 | 2.7x | 5x | yes |
| BeaconBlockBody.serialize | medium-fixture | 19087 | 139264 | 3532.9 | 1257.4 | 2.8x | 5x | yes |
| BeaconBlockBody.serialize | small-fixture | 11894 | 180224 | 2680.0 | 818.5 | 3.3x | 5x | yes |
| BeaconBlockHeader.deserialize | large-fixture | 112 | 5000000 | 47.8 | 15.7 | 3.0x | 5x | yes |
| BeaconBlockHeader.deserialize | medium-fixture | 112 | 5000000 | 49.0 | 15.9 | 3.1x | 5x | yes |
| BeaconBlockHeader.deserialize | small-fixture | 112 | 5000000 | 49.0 | 16.5 | 3.0x | 5x | yes |
| BeaconBlockHeader.hash_tree_root | large-fixture | 112 | 286720 | 1597.4 | 444.1 | 3.6x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | medium-fixture | 112 | 167936 | 1595.8 | 443.1 | 3.6x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | small-fixture | 112 | 286720 | 1597.4 | 442.9 | 3.6x | 10x | yes |
| BeaconBlockHeader.serialize | large-fixture | 112 | 5000000 | 19.4 | 17.9 | 1.1x | 5x | yes |
| BeaconBlockHeader.serialize | medium-fixture | 112 | 5000000 | 19.4 | 18.2 | 1.1x | 5x | yes |
| BeaconBlockHeader.serialize | small-fixture | 112 | 5000000 | 19.4 | 17.6 | 1.1x | 5x | yes |
| BeaconState.deserialize | large-fixture | 2741095 | 3200 | 147812.5 | 186450.1 | 0.8x | 5x | yes |
| BeaconState.deserialize | medium-fixture | 2740473 | 3200 | 147500.0 | 186608.5 | 0.8x | 5x | yes |
| BeaconState.deserialize | small-fixture | 2738771 | 3200 | 146562.5 | 186014.5 | 0.8x | 5x | yes |
| BeaconState.hash_tree_root | large-fixture | 2741095 | 20 | 23400000.0 | 6783721.3 | 3.4x | 10x | yes |
| BeaconState.hash_tree_root | medium-fixture | 2740473 | 20 | 23400000.0 | 6781288.3 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | small-fixture | 2738771 | 20 | 23350000.0 | 6749040.5 | 3.5x | 10x | yes |
| BeaconState.serialize | large-fixture | 2741095 | 3456 | 139756.9 | 183859.9 | 0.8x | 5x | yes |
| BeaconState.serialize | medium-fixture | 2740473 | 3456 | 139467.6 | 183561.5 | 0.8x | 5x | yes |
| BeaconState.serialize | small-fixture | 2738771 | 3200 | 138750.0 | 183586.8 | 0.8x | 5x | yes |
| Blob.deserialize | random | 131072 | 65536 | 7217.4 | 5705.3 | 1.3x | 5x | yes |
| Blob.deserialize | saturated | 131072 | 49152 | 10050.5 | 5983.5 | 1.7x | 5x | yes |
| Blob.deserialize | zero | 131072 | 65536 | 7293.7 | 5676.8 | 1.3x | 5x | yes |
| Blob.hash_tree_root | random | 131072 | 384 | 1106770.8 | 283159.9 | 3.9x | 10x | yes |
| Blob.hash_tree_root | saturated | 131072 | 384 | 1104166.7 | 282701.0 | 3.9x | 10x | yes |
| Blob.hash_tree_root | zero | 131072 | 384 | 1104166.7 | 281681.3 | 3.9x | 10x | yes |
| Blob.serialize | random | 131072 | 81920 | 5700.7 | 5466.9 | 1.0x | 5x | yes |
| Blob.serialize | saturated | 131072 | 49152 | 8870.4 | 5955.6 | 1.5x | 5x | yes |
| Blob.serialize | zero | 131072 | 81920 | 5627.4 | 4235.7 | 1.3x | 5x | yes |
| BlobIdentifier.deserialize | large-fixture | 40 | 5000000 | 23.6 | 12.9 | 1.8x | 5x | yes |
| BlobIdentifier.deserialize | medium-fixture | 40 | 5000000 | 23.4 | 12.7 | 1.8x | 5x | yes |
| BlobIdentifier.deserialize | small-fixture | 40 | 5000000 | 23.4 | 12.8 | 1.8x | 5x | yes |
| BlobIdentifier.hash_tree_root | large-fixture | 40 | 1572864 | 273.4 | 100.8 | 2.7x | 10x | yes |
| BlobIdentifier.hash_tree_root | medium-fixture | 40 | 1572864 | 274.0 | 100.9 | 2.7x | 10x | yes |
| BlobIdentifier.hash_tree_root | small-fixture | 40 | 1572864 | 273.4 | 101.0 | 2.7x | 10x | yes |
| BlobIdentifier.serialize | large-fixture | 40 | 5000000 | 9.6 | 14.7 | 0.7x | 5x | yes |
| BlobIdentifier.serialize | medium-fixture | 40 | 5000000 | 9.6 | 14.5 | 0.7x | 5x | yes |
| BlobIdentifier.serialize | small-fixture | 40 | 5000000 | 9.6 | 14.5 | 0.7x | 5x | yes |
| BlobIndex.deserialize | random | 8 | 5000000 | 13.4 | 23.6 | 0.6x | 5x | yes |
| BlobIndex.deserialize | saturated | 8 | 5000000 | 13.4 | 23.3 | 0.6x | 5x | yes |
| BlobIndex.deserialize | zero | 8 | 5000000 | 14.2 | 23.1 | 0.6x | 5x | yes |
| BlobIndex.hash_tree_root | random | 8 | 5000000 | 4.4 | 137.0 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | saturated | 8 | 5000000 | 4.4 | 138.6 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | zero | 8 | 5000000 | 4.4 | 142.1 | 0.0x | 10x | yes |
| BlobIndex.serialize | random | 8 | 5000000 | 6.8 | 8.1 | 0.8x | 5x | yes |
| BlobIndex.serialize | saturated | 8 | 5000000 | 6.6 | 8.3 | 0.8x | 5x | yes |
| BlobIndex.serialize | zero | 8 | 5000000 | 6.8 | 8.2 | 0.8x | 5x | yes |
| BlobSidecar.deserialize | large-fixture | 131928 | 57344 | 10689.9 | 5928.6 | 1.8x | 5x | yes |
| BlobSidecar.deserialize | medium-fixture | 131928 | 32768 | 7690.4 | 4717.9 | 1.6x | 5x | yes |
| BlobSidecar.deserialize | small-fixture | 131928 | 65536 | 8132.9 | 5152.6 | 1.6x | 5x | yes |
| BlobSidecar.hash_tree_root | large-fixture | 131928 | 256 | 1445312.5 | 348050.6 | 4.2x | 10x | yes |
| BlobSidecar.hash_tree_root | medium-fixture | 131928 | 384 | 1148437.5 | 283545.6 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | small-fixture | 131928 | 384 | 1119791.7 | 275671.8 | 4.1x | 10x | yes |
| BlobSidecar.serialize | large-fixture | 131928 | 49152 | 8707.7 | 5930.7 | 1.5x | 5x | yes |
| BlobSidecar.serialize | medium-fixture | 131928 | 36864 | 6564.7 | 4550.1 | 1.4x | 5x | yes |
| BlobSidecar.serialize | small-fixture | 131928 | 65536 | 6546.0 | 4551.3 | 1.4x | 5x | yes |
| Bytes1.deserialize | random | 1 | 5000000 | 10.4 | 33.3 | 0.3x | 5x | yes |
| Bytes1.deserialize | saturated | 1 | 5000000 | 11.8 | 39.6 | 0.3x | 5x | yes |
| Bytes1.deserialize | zero | 1 | 5000000 | 10.4 | 33.6 | 0.3x | 5x | yes |
| Bytes1.hash_tree_root | random | 1 | 5000000 | 4.2 | 206.2 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | saturated | 1 | 5000000 | 4.4 | 209.3 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | zero | 1 | 5000000 | 4.6 | 218.6 | 0.0x | 10x | yes |
| Bytes1.serialize | random | 1 | 5000000 | 7.6 | 10.4 | 0.7x | 5x | yes |
| Bytes1.serialize | saturated | 1 | 5000000 | 7.6 | 10.9 | 0.7x | 5x | yes |
| Bytes1.serialize | zero | 1 | 5000000 | 7.8 | 10.9 | 0.7x | 5x | yes |
| Bytes20.deserialize | random | 20 | 5000000 | 19.0 | 28.2 | 0.7x | 5x | yes |
| Bytes20.deserialize | saturated | 20 | 5000000 | 17.8 | 28.4 | 0.6x | 5x | yes |
| Bytes20.deserialize | zero | 20 | 5000000 | 20.8 | 30.6 | 0.7x | 5x | yes |
| Bytes20.hash_tree_root | random | 20 | 5000000 | 4.4 | 152.6 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | saturated | 20 | 5000000 | 4.4 | 145.9 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | zero | 20 | 5000000 | 4.2 | 142.1 | 0.0x | 10x | yes |
| Bytes20.serialize | random | 20 | 5000000 | 7.6 | 13.7 | 0.6x | 5x | yes |
| Bytes20.serialize | saturated | 20 | 5000000 | 7.2 | 12.7 | 0.6x | 5x | yes |
| Bytes20.serialize | zero | 20 | 5000000 | 7.4 | 13.3 | 0.6x | 5x | yes |
| Bytes32.deserialize | random | 32 | 5000000 | 41.8 | 43.5 | 1.0x | 5x | yes |
| Bytes32.deserialize | saturated | 32 | 5000000 | 39.2 | 40.0 | 1.0x | 5x | yes |
| Bytes32.deserialize | zero | 32 | 5000000 | 27.6 | 28.2 | 1.0x | 5x | yes |
| Bytes32.hash_tree_root | random | 32 | 5000000 | 7.2 | 193.0 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | saturated | 32 | 5000000 | 6.4 | 186.8 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | zero | 32 | 5000000 | 6.0 | 183.7 | 0.0x | 10x | yes |
| Bytes32.serialize | random | 32 | 5000000 | 12.0 | 19.4 | 0.6x | 5x | yes |
| Bytes32.serialize | saturated | 32 | 5000000 | 12.2 | 19.0 | 0.6x | 5x | yes |
| Bytes32.serialize | zero | 32 | 5000000 | 7.6 | 13.4 | 0.6x | 5x | yes |
| Bytes4.deserialize | random | 4 | 5000000 | 9.2 | 39.1 | 0.2x | 5x | yes |
| Bytes4.deserialize | saturated | 4 | 5000000 | 9.2 | 39.1 | 0.2x | 5x | yes |
| Bytes4.deserialize | zero | 4 | 5000000 | 10.0 | 41.8 | 0.2x | 5x | yes |
| Bytes4.hash_tree_root | random | 4 | 5000000 | 4.4 | 204.1 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | saturated | 4 | 5000000 | 5.0 | 203.3 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | zero | 4 | 5000000 | 4.2 | 200.6 | 0.0x | 10x | yes |
| Bytes4.serialize | random | 4 | 5000000 | 7.2 | 12.0 | 0.6x | 5x | yes |
| Bytes4.serialize | saturated | 4 | 5000000 | 7.6 | 12.4 | 0.6x | 5x | yes |
| Bytes4.serialize | zero | 4 | 5000000 | 7.2 | 11.7 | 0.6x | 5x | yes |
| Bytes48.deserialize | random | 48 | 5000000 | 37.8 | 40.5 | 0.9x | 5x | yes |
| Bytes48.deserialize | saturated | 48 | 5000000 | 26.0 | 28.1 | 0.9x | 5x | yes |
| Bytes48.deserialize | zero | 48 | 5000000 | 39.0 | 45.3 | 0.9x | 5x | yes |
| Bytes48.hash_tree_root | random | 48 | 1572864 | 272.8 | 226.6 | 1.2x | 10x | yes |
| Bytes48.hash_tree_root | saturated | 48 | 1572864 | 273.4 | 226.3 | 1.2x | 10x | yes |
| Bytes48.hash_tree_root | zero | 48 | 1048576 | 373.8 | 322.3 | 1.2x | 10x | yes |
| Bytes48.serialize | random | 48 | 5000000 | 11.6 | 14.9 | 0.8x | 5x | yes |
| Bytes48.serialize | saturated | 48 | 5000000 | 10.4 | 13.3 | 0.8x | 5x | yes |
| Bytes48.serialize | zero | 48 | 5000000 | 15.0 | 20.9 | 0.7x | 5x | yes |
| Bytes8.deserialize | random | 8 | 5000000 | 11.4 | 23.8 | 0.5x | 5x | yes |
| Bytes8.deserialize | saturated | 8 | 5000000 | 11.4 | 23.4 | 0.5x | 5x | yes |
| Bytes8.deserialize | zero | 8 | 5000000 | 11.4 | 23.4 | 0.5x | 5x | yes |
| Bytes8.hash_tree_root | random | 8 | 5000000 | 3.8 | 136.6 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 147.9 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | zero | 8 | 5000000 | 3.8 | 135.1 | 0.0x | 10x | yes |
| Bytes8.serialize | random | 8 | 5000000 | 6.2 | 8.0 | 0.8x | 5x | yes |
| Bytes8.serialize | saturated | 8 | 5000000 | 6.2 | 8.1 | 0.8x | 5x | yes |
| Bytes8.serialize | zero | 8 | 5000000 | 6.2 | 8.1 | 0.8x | 5x | yes |
| Bytes96.deserialize | random | 96 | 5000000 | 52.8 | 31.3 | 1.7x | 5x | yes |
| Bytes96.deserialize | saturated | 96 | 5000000 | 63.2 | 44.4 | 1.4x | 5x | yes |
| Bytes96.deserialize | zero | 96 | 5000000 | 50.4 | 32.0 | 1.6x | 5x | yes |
| Bytes96.hash_tree_root | random | 96 | 507904 | 811.2 | 369.4 | 2.2x | 10x | yes |
| Bytes96.hash_tree_root | saturated | 96 | 507904 | 811.2 | 370.9 | 2.2x | 10x | yes |
| Bytes96.hash_tree_root | zero | 96 | 524288 | 812.5 | 367.5 | 2.2x | 10x | yes |
| Bytes96.serialize | random | 96 | 5000000 | 19.8 | 15.6 | 1.3x | 5x | yes |
| Bytes96.serialize | saturated | 96 | 5000000 | 31.6 | 24.7 | 1.3x | 5x | yes |
| Bytes96.serialize | zero | 96 | 5000000 | 18.2 | 16.0 | 1.1x | 5x | yes |
| Cell.deserialize | random | 2048 | 4194304 | 111.8 | 164.2 | 0.7x | 5x | yes |
| Cell.deserialize | saturated | 2048 | 2621440 | 169.4 | 164.1 | 1.0x | 5x | yes |
| Cell.deserialize | zero | 2048 | 4194304 | 112.5 | 159.8 | 0.7x | 5x | yes |
| Cell.hash_tree_root | random | 2048 | 16384 | 21301.3 | 5211.1 | 4.1x | 10x | yes |
| Cell.hash_tree_root | saturated | 2048 | 24576 | 20263.7 | 5731.1 | 3.5x | 10x | yes |
| Cell.hash_tree_root | zero | 2048 | 16384 | 22827.1 | 5411.0 | 4.2x | 10x | yes |
| Cell.serialize | random | 2048 | 2621440 | 97.3 | 142.7 | 0.7x | 5x | yes |
| Cell.serialize | saturated | 2048 | 3145728 | 149.4 | 141.5 | 1.1x | 5x | yes |
| Cell.serialize | zero | 2048 | 4718592 | 97.5 | 138.4 | 0.7x | 5x | yes |
| CellIndex.deserialize | random | 8 | 5000000 | 13.6 | 24.9 | 0.5x | 5x | yes |
| CellIndex.deserialize | saturated | 8 | 5000000 | 19.6 | 37.9 | 0.5x | 5x | yes |
| CellIndex.deserialize | zero | 8 | 5000000 | 17.8 | 30.1 | 0.6x | 5x | yes |
| CellIndex.hash_tree_root | random | 8 | 5000000 | 6.0 | 205.0 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | saturated | 8 | 5000000 | 6.2 | 208.9 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | zero | 8 | 5000000 | 4.0 | 138.8 | 0.0x | 10x | yes |
| CellIndex.serialize | random | 8 | 5000000 | 6.8 | 8.7 | 0.8x | 5x | yes |
| CellIndex.serialize | saturated | 8 | 5000000 | 10.0 | 13.0 | 0.8x | 5x | yes |
| CellIndex.serialize | zero | 8 | 5000000 | 7.2 | 9.2 | 0.8x | 5x | yes |
| Checkpoint.deserialize | large-fixture | 40 | 5000000 | 30.2 | 12.9 | 2.3x | 5x | yes |
| Checkpoint.deserialize | medium-fixture | 40 | 5000000 | 39.2 | 15.4 | 2.5x | 5x | yes |
| Checkpoint.deserialize | small-fixture | 40 | 5000000 | 46.4 | 20.4 | 2.3x | 5x | yes |
| Checkpoint.hash_tree_root | large-fixture | 40 | 1572864 | 274.0 | 101.2 | 2.7x | 10x | yes |
| Checkpoint.hash_tree_root | medium-fixture | 40 | 1572864 | 273.4 | 101.0 | 2.7x | 10x | yes |
| Checkpoint.hash_tree_root | small-fixture | 40 | 1048576 | 383.4 | 141.6 | 2.7x | 10x | yes |
| Checkpoint.serialize | large-fixture | 40 | 5000000 | 9.8 | 14.4 | 0.7x | 5x | yes |
| Checkpoint.serialize | medium-fixture | 40 | 5000000 | 10.8 | 15.5 | 0.7x | 5x | yes |
| Checkpoint.serialize | small-fixture | 40 | 5000000 | 15.4 | 23.5 | 0.7x | 5x | yes |
| ColumnIndex.deserialize | random | 8 | 5000000 | 10.8 | 23.3 | 0.5x | 5x | yes |
| ColumnIndex.deserialize | saturated | 8 | 5000000 | 10.6 | 23.7 | 0.4x | 5x | yes |
| ColumnIndex.deserialize | zero | 8 | 5000000 | 10.8 | 23.2 | 0.5x | 5x | yes |
| ColumnIndex.hash_tree_root | random | 8 | 5000000 | 4.0 | 133.3 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 135.1 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | zero | 8 | 5000000 | 4.0 | 136.9 | 0.0x | 10x | yes |
| ColumnIndex.serialize | random | 8 | 5000000 | 6.2 | 8.3 | 0.8x | 5x | yes |
| ColumnIndex.serialize | saturated | 8 | 5000000 | 6.2 | 8.3 | 0.7x | 5x | yes |
| ColumnIndex.serialize | zero | 8 | 5000000 | 6.4 | 8.1 | 0.8x | 5x | yes |
| CommitmentIndex.deserialize | random | 8 | 5000000 | 12.0 | 23.2 | 0.5x | 5x | yes |
| CommitmentIndex.deserialize | saturated | 8 | 5000000 | 20.0 | 37.7 | 0.5x | 5x | yes |
| CommitmentIndex.deserialize | zero | 8 | 5000000 | 12.4 | 23.7 | 0.5x | 5x | yes |
| CommitmentIndex.hash_tree_root | random | 8 | 5000000 | 6.4 | 229.7 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | saturated | 8 | 5000000 | 5.2 | 181.7 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 134.7 | 0.0x | 10x | yes |
| CommitmentIndex.serialize | random | 8 | 5000000 | 6.0 | 8.5 | 0.7x | 5x | yes |
| CommitmentIndex.serialize | saturated | 8 | 5000000 | 9.2 | 12.8 | 0.7x | 5x | yes |
| CommitmentIndex.serialize | zero | 8 | 5000000 | 6.0 | 8.1 | 0.7x | 5x | yes |
| CommitteeIndex.deserialize | random | 8 | 5000000 | 14.4 | 24.9 | 0.6x | 5x | yes |
| CommitteeIndex.deserialize | saturated | 8 | 5000000 | 14.2 | 25.1 | 0.6x | 5x | yes |
| CommitteeIndex.deserialize | zero | 8 | 5000000 | 14.4 | 25.7 | 0.6x | 5x | yes |
| CommitteeIndex.hash_tree_root | random | 8 | 5000000 | 3.8 | 144.4 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 151.6 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 147.6 | 0.0x | 10x | yes |
| CommitteeIndex.serialize | random | 8 | 5000000 | 5.6 | 8.7 | 0.6x | 5x | yes |
| CommitteeIndex.serialize | saturated | 8 | 5000000 | 5.6 | 8.9 | 0.6x | 5x | yes |
| CommitteeIndex.serialize | zero | 8 | 5000000 | 5.8 | 9.0 | 0.6x | 5x | yes |
| ConsolidationRequest.deserialize | large-fixture | 116 | 5000000 | 53.6 | 16.4 | 3.3x | 5x | yes |
| ConsolidationRequest.deserialize | medium-fixture | 116 | 5000000 | 53.6 | 16.0 | 3.3x | 5x | yes |
| ConsolidationRequest.deserialize | small-fixture | 116 | 5000000 | 59.4 | 17.8 | 3.3x | 5x | yes |
| ConsolidationRequest.hash_tree_root | large-fixture | 116 | 335872 | 1336.8 | 400.3 | 3.3x | 10x | yes |
| ConsolidationRequest.hash_tree_root | medium-fixture | 116 | 335872 | 1330.9 | 394.1 | 3.4x | 10x | yes |
| ConsolidationRequest.hash_tree_root | small-fixture | 116 | 335872 | 1330.9 | 394.7 | 3.4x | 10x | yes |
| ConsolidationRequest.serialize | large-fixture | 116 | 5000000 | 20.2 | 17.8 | 1.1x | 5x | yes |
| ConsolidationRequest.serialize | medium-fixture | 116 | 5000000 | 20.2 | 17.9 | 1.1x | 5x | yes |
| ConsolidationRequest.serialize | small-fixture | 116 | 5000000 | 21.0 | 18.9 | 1.1x | 5x | yes |
| ContributionAndProof.deserialize | large-fixture | 264 | 3670016 | 121.8 | 58.6 | 2.1x | 5x | yes |
| ContributionAndProof.deserialize | medium-fixture | 264 | 2621440 | 122.8 | 59.5 | 2.1x | 5x | yes |
| ContributionAndProof.deserialize | small-fixture | 264 | 3670016 | 136.8 | 65.1 | 2.1x | 5x | yes |
| ContributionAndProof.hash_tree_root | large-fixture | 264 | 106496 | 4009.5 | 1073.5 | 3.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | medium-fixture | 264 | 122880 | 4003.9 | 1073.5 | 3.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | small-fixture | 264 | 57344 | 5946.6 | 1587.6 | 3.7x | 10x | yes |
| ContributionAndProof.serialize | large-fixture | 264 | 5000000 | 47.0 | 30.3 | 1.6x | 5x | yes |
| ContributionAndProof.serialize | medium-fixture | 264 | 5000000 | 46.8 | 29.0 | 1.6x | 5x | yes |
| ContributionAndProof.serialize | small-fixture | 264 | 5000000 | 49.6 | 57.8 | 0.9x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 32.2 | 47.0 | 0.7x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | saturated | 192 | 5000000 | 44.0 | 63.6 | 0.7x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 23.2 | 36.3 | 0.6x | 5x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | random | 192 | 221184 | 1912.4 | 632.2 | 3.0x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | saturated | 192 | 221184 | 2002.9 | 731.7 | 2.7x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | zero | 192 | 221184 | 3029.2 | 943.5 | 3.2x | 10x | yes |
| CurrentSyncCommitteeBranch.serialize | random | 192 | 5000000 | 21.8 | 23.0 | 0.9x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 30.0 | 27.5 | 1.1x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 16.0 | 21.6 | 0.7x | 5x | yes |
| CustodyIndex.deserialize | random | 8 | 5000000 | 9.2 | 25.8 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | saturated | 8 | 5000000 | 9.8 | 27.5 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | zero | 8 | 5000000 | 13.0 | 34.2 | 0.4x | 5x | yes |
| CustodyIndex.hash_tree_root | random | 8 | 5000000 | 3.6 | 157.4 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | saturated | 8 | 5000000 | 3.4 | 151.1 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | zero | 8 | 5000000 | 3.4 | 146.9 | 0.0x | 10x | yes |
| CustodyIndex.serialize | random | 8 | 5000000 | 5.4 | 9.0 | 0.6x | 5x | yes |
| CustodyIndex.serialize | saturated | 8 | 5000000 | 5.8 | 9.7 | 0.6x | 5x | yes |
| CustodyIndex.serialize | zero | 8 | 5000000 | 5.8 | 9.7 | 0.6x | 5x | yes |
| DataColumnSidecar.deserialize | large-fixture | 19076 | 167936 | 1697.1 | 2511.7 | 0.7x | 5x | yes |
| DataColumnSidecar.deserialize | medium-fixture | 17028 | 409600 | 1022.9 | 1533.5 | 0.7x | 5x | yes |
| DataColumnSidecar.deserialize | small-fixture | 6500 | 524288 | 743.9 | 880.2 | 0.8x | 5x | yes |
| DataColumnSidecar.hash_tree_root | large-fixture | 19076 | 2560 | 174218.8 | 42496.9 | 4.1x | 10x | yes |
| DataColumnSidecar.hash_tree_root | medium-fixture | 17028 | 1600 | 226875.0 | 53719.4 | 4.2x | 10x | yes |
| DataColumnSidecar.hash_tree_root | small-fixture | 6500 | 7936 | 60735.9 | 14926.3 | 4.1x | 10x | yes |
| DataColumnSidecar.serialize | large-fixture | 19076 | 167936 | 1190.9 | 994.2 | 1.2x | 5x | yes |
| DataColumnSidecar.serialize | medium-fixture | 17028 | 524288 | 928.9 | 809.8 | 1.1x | 5x | yes |
| DataColumnSidecar.serialize | small-fixture | 6500 | 1048576 | 399.6 | 330.0 | 1.2x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | large-fixture | 92 | 5000000 | 55.6 | 79.7 | 0.7x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | medium-fixture | 60 | 5000000 | 34.6 | 49.7 | 0.7x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | small-fixture | 36 | 5000000 | 28.8 | 31.5 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | large-fixture | 92 | 131072 | 2174.4 | 530.4 | 4.1x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | medium-fixture | 60 | 253952 | 2669.8 | 731.1 | 3.7x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | small-fixture | 36 | 524288 | 684.7 | 232.8 | 2.9x | 10x | yes |
| DataColumnsByRootIdentifier.serialize | large-fixture | 92 | 5000000 | 30.0 | 34.8 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | medium-fixture | 60 | 5000000 | 16.6 | 17.5 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | small-fixture | 36 | 5000000 | 13.6 | 15.3 | 0.9x | 5x | yes |
| Deposit.deserialize | large-fixture | 1240 | 2621440 | 169.8 | 602.1 | 0.3x | 5x | yes |
| Deposit.deserialize | medium-fixture | 1240 | 2621440 | 170.1 | 590.2 | 0.3x | 5x | yes |
| Deposit.deserialize | small-fixture | 1240 | 2621440 | 170.1 | 601.7 | 0.3x | 5x | yes |
| Deposit.hash_tree_root | large-fixture | 1240 | 32768 | 12207.0 | 3172.6 | 3.8x | 10x | yes |
| Deposit.hash_tree_root | medium-fixture | 1240 | 24576 | 15706.4 | 3500.6 | 4.5x | 10x | yes |
| Deposit.hash_tree_root | small-fixture | 1240 | 40960 | 12207.0 | 3169.1 | 3.9x | 10x | yes |
| Deposit.serialize | large-fixture | 1240 | 3670016 | 131.1 | 172.8 | 0.8x | 5x | yes |
| Deposit.serialize | medium-fixture | 1240 | 5000000 | 85.8 | 122.1 | 0.7x | 5x | yes |
| Deposit.serialize | small-fixture | 1240 | 5000000 | 85.2 | 108.5 | 0.8x | 5x | yes |
| DepositData.deserialize | large-fixture | 184 | 4194304 | 109.7 | 37.7 | 2.9x | 5x | yes |
| DepositData.deserialize | medium-fixture | 184 | 4194304 | 106.8 | 37.3 | 2.9x | 5x | yes |
| DepositData.deserialize | small-fixture | 184 | 4194304 | 105.1 | 38.1 | 2.8x | 5x | yes |
| DepositData.hash_tree_root | large-fixture | 184 | 253952 | 1874.4 | 526.1 | 3.6x | 10x | yes |
| DepositData.hash_tree_root | medium-fixture | 184 | 253952 | 1878.3 | 525.2 | 3.6x | 10x | yes |
| DepositData.hash_tree_root | small-fixture | 184 | 253952 | 1878.3 | 525.8 | 3.6x | 10x | yes |
| DepositData.serialize | large-fixture | 184 | 5000000 | 30.8 | 22.4 | 1.4x | 5x | yes |
| DepositData.serialize | medium-fixture | 184 | 5000000 | 31.0 | 21.2 | 1.5x | 5x | yes |
| DepositData.serialize | small-fixture | 184 | 5000000 | 30.8 | 22.2 | 1.4x | 5x | yes |
| DepositMessage.deserialize | large-fixture | 88 | 5000000 | 36.8 | 31.0 | 1.2x | 5x | yes |
| DepositMessage.deserialize | medium-fixture | 88 | 5000000 | 36.6 | 30.9 | 1.2x | 5x | yes |
| DepositMessage.deserialize | small-fixture | 88 | 5000000 | 36.8 | 30.5 | 1.2x | 5x | yes |
| DepositMessage.hash_tree_root | large-fixture | 88 | 253952 | 1059.3 | 316.3 | 3.3x | 10x | yes |
| DepositMessage.hash_tree_root | medium-fixture | 88 | 253952 | 1059.3 | 315.5 | 3.4x | 10x | yes |
| DepositMessage.hash_tree_root | small-fixture | 88 | 409600 | 1062.0 | 316.4 | 3.4x | 10x | yes |
| DepositMessage.serialize | large-fixture | 88 | 5000000 | 14.8 | 16.9 | 0.9x | 5x | yes |
| DepositMessage.serialize | medium-fixture | 88 | 5000000 | 14.8 | 17.2 | 0.9x | 5x | yes |
| DepositMessage.serialize | small-fixture | 88 | 5000000 | 14.8 | 17.1 | 0.9x | 5x | yes |
| DepositRequest.deserialize | large-fixture | 192 | 2097152 | 113.0 | 37.6 | 3.0x | 5x | yes |
| DepositRequest.deserialize | medium-fixture | 192 | 2097152 | 117.3 | 38.7 | 3.0x | 5x | yes |
| DepositRequest.deserialize | small-fixture | 192 | 2097152 | 120.2 | 37.7 | 3.2x | 5x | yes |
| DepositRequest.hash_tree_root | large-fixture | 192 | 180224 | 2668.9 | 723.5 | 3.7x | 10x | yes |
| DepositRequest.hash_tree_root | medium-fixture | 192 | 180224 | 2668.9 | 724.5 | 3.7x | 10x | yes |
| DepositRequest.hash_tree_root | small-fixture | 192 | 180224 | 2668.9 | 723.9 | 3.7x | 10x | yes |
| DepositRequest.serialize | large-fixture | 192 | 5000000 | 32.6 | 22.3 | 1.5x | 5x | yes |
| DepositRequest.serialize | medium-fixture | 192 | 5000000 | 32.8 | 21.9 | 1.5x | 5x | yes |
| DepositRequest.serialize | small-fixture | 192 | 5000000 | 32.8 | 22.6 | 1.5x | 5x | yes |
| Domain.deserialize | random | 32 | 5000000 | 22.0 | 27.0 | 0.8x | 5x | yes |
| Domain.deserialize | saturated | 32 | 5000000 | 20.6 | 27.3 | 0.8x | 5x | yes |
| Domain.deserialize | zero | 32 | 5000000 | 20.6 | 27.4 | 0.8x | 5x | yes |
| Domain.hash_tree_root | random | 32 | 5000000 | 4.4 | 121.1 | 0.0x | 10x | yes |
| Domain.hash_tree_root | saturated | 32 | 5000000 | 4.6 | 126.4 | 0.0x | 10x | yes |
| Domain.hash_tree_root | zero | 32 | 5000000 | 4.6 | 124.9 | 0.0x | 10x | yes |
| Domain.serialize | random | 32 | 5000000 | 7.8 | 12.7 | 0.6x | 5x | yes |
| Domain.serialize | saturated | 32 | 5000000 | 7.8 | 13.0 | 0.6x | 5x | yes |
| Domain.serialize | zero | 32 | 5000000 | 7.8 | 12.8 | 0.6x | 5x | yes |
| DomainType.deserialize | random | 4 | 5000000 | 7.0 | 24.1 | 0.3x | 5x | yes |
| DomainType.deserialize | saturated | 4 | 5000000 | 7.0 | 24.1 | 0.3x | 5x | yes |
| DomainType.deserialize | zero | 4 | 5000000 | 7.0 | 24.1 | 0.3x | 5x | yes |
| DomainType.hash_tree_root | random | 4 | 5000000 | 3.0 | 135.1 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | saturated | 4 | 5000000 | 3.0 | 132.2 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | zero | 4 | 5000000 | 3.0 | 139.3 | 0.0x | 10x | yes |
| DomainType.serialize | random | 4 | 5000000 | 5.2 | 7.9 | 0.7x | 5x | yes |
| DomainType.serialize | saturated | 4 | 5000000 | 5.2 | 8.0 | 0.7x | 5x | yes |
| DomainType.serialize | zero | 4 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| Epoch.deserialize | random | 8 | 5000000 | 11.0 | 23.3 | 0.5x | 5x | yes |
| Epoch.deserialize | saturated | 8 | 5000000 | 11.2 | 23.3 | 0.5x | 5x | yes |
| Epoch.deserialize | zero | 8 | 5000000 | 11.0 | 23.4 | 0.5x | 5x | yes |
| Epoch.hash_tree_root | random | 8 | 5000000 | 3.6 | 134.2 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | saturated | 8 | 5000000 | 3.4 | 135.2 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | zero | 8 | 5000000 | 3.4 | 135.0 | 0.0x | 10x | yes |
| Epoch.serialize | random | 8 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| Epoch.serialize | saturated | 8 | 5000000 | 5.2 | 8.0 | 0.7x | 5x | yes |
| Epoch.serialize | zero | 8 | 5000000 | 5.2 | 7.9 | 0.7x | 5x | yes |
| Eth1Block.deserialize | large-fixture | 48 | 5000000 | 26.0 | 28.5 | 0.9x | 5x | yes |
| Eth1Block.deserialize | medium-fixture | 48 | 5000000 | 25.8 | 28.5 | 0.9x | 5x | yes |
| Eth1Block.deserialize | small-fixture | 48 | 5000000 | 25.8 | 28.4 | 0.9x | 5x | yes |
| Eth1Block.hash_tree_root | large-fixture | 48 | 524288 | 793.5 | 238.7 | 3.3x | 10x | yes |
| Eth1Block.hash_tree_root | medium-fixture | 48 | 524288 | 791.5 | 239.1 | 3.3x | 10x | yes |
| Eth1Block.hash_tree_root | small-fixture | 48 | 507904 | 791.5 | 238.8 | 3.3x | 10x | yes |
| Eth1Block.serialize | large-fixture | 48 | 5000000 | 8.4 | 15.1 | 0.6x | 5x | yes |
| Eth1Block.serialize | medium-fixture | 48 | 5000000 | 8.4 | 15.2 | 0.6x | 5x | yes |
| Eth1Block.serialize | small-fixture | 48 | 5000000 | 8.4 | 15.5 | 0.5x | 5x | yes |
| Eth1Data.deserialize | large-fixture | 72 | 5000000 | 37.8 | 41.2 | 0.9x | 5x | yes |
| Eth1Data.deserialize | medium-fixture | 72 | 5000000 | 37.2 | 41.0 | 0.9x | 5x | yes |
| Eth1Data.deserialize | small-fixture | 72 | 5000000 | 37.4 | 41.3 | 0.9x | 5x | yes |
| Eth1Data.hash_tree_root | large-fixture | 72 | 524288 | 803.0 | 241.2 | 3.3x | 10x | yes |
| Eth1Data.hash_tree_root | medium-fixture | 72 | 524288 | 801.1 | 240.5 | 3.3x | 10x | yes |
| Eth1Data.hash_tree_root | small-fixture | 72 | 524288 | 801.1 | 240.7 | 3.3x | 10x | yes |
| Eth1Data.serialize | large-fixture | 72 | 5000000 | 13.8 | 16.8 | 0.8x | 5x | yes |
| Eth1Data.serialize | medium-fixture | 72 | 5000000 | 13.8 | 17.2 | 0.8x | 5x | yes |
| Eth1Data.serialize | small-fixture | 72 | 5000000 | 13.6 | 17.0 | 0.8x | 5x | yes |
| Ether.deserialize | random | 8 | 5000000 | 11.4 | 23.3 | 0.5x | 5x | yes |
| Ether.deserialize | saturated | 8 | 5000000 | 13.0 | 27.4 | 0.5x | 5x | yes |
| Ether.deserialize | zero | 8 | 5000000 | 11.0 | 23.2 | 0.5x | 5x | yes |
| Ether.hash_tree_root | random | 8 | 5000000 | 4.8 | 176.6 | 0.0x | 10x | yes |
| Ether.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 139.2 | 0.0x | 10x | yes |
| Ether.hash_tree_root | zero | 8 | 5000000 | 4.0 | 133.7 | 0.0x | 10x | yes |
| Ether.serialize | random | 8 | 5000000 | 6.4 | 8.9 | 0.7x | 5x | yes |
| Ether.serialize | saturated | 8 | 5000000 | 7.0 | 9.0 | 0.8x | 5x | yes |
| Ether.serialize | zero | 8 | 5000000 | 6.2 | 8.3 | 0.7x | 5x | yes |
| ExecutionAddress.deserialize | random | 20 | 5000000 | 14.4 | 28.1 | 0.5x | 5x | yes |
| ExecutionAddress.deserialize | saturated | 20 | 5000000 | 14.0 | 27.2 | 0.5x | 5x | yes |
| ExecutionAddress.deserialize | zero | 20 | 5000000 | 20.2 | 40.6 | 0.5x | 5x | yes |
| ExecutionAddress.hash_tree_root | random | 20 | 5000000 | 3.6 | 133.3 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | saturated | 20 | 5000000 | 3.8 | 139.5 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | zero | 20 | 5000000 | 4.8 | 164.2 | 0.0x | 10x | yes |
| ExecutionAddress.serialize | random | 20 | 5000000 | 6.2 | 12.9 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | saturated | 20 | 5000000 | 6.0 | 12.4 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | zero | 20 | 5000000 | 9.4 | 19.1 | 0.5x | 5x | yes |
| ExecutionBranch.deserialize | random | 128 | 5000000 | 39.0 | 60.4 | 0.6x | 5x | yes |
| ExecutionBranch.deserialize | saturated | 128 | 5000000 | 38.2 | 66.1 | 0.6x | 5x | yes |
| ExecutionBranch.deserialize | zero | 128 | 5000000 | 20.4 | 35.2 | 0.6x | 5x | yes |
| ExecutionBranch.hash_tree_root | random | 128 | 253952 | 1429.4 | 619.5 | 2.3x | 10x | yes |
| ExecutionBranch.hash_tree_root | saturated | 128 | 167936 | 1542.3 | 683.1 | 2.3x | 10x | yes |
| ExecutionBranch.hash_tree_root | zero | 128 | 507904 | 996.3 | 501.4 | 2.0x | 10x | yes |
| ExecutionBranch.serialize | random | 128 | 5000000 | 25.6 | 31.6 | 0.8x | 5x | yes |
| ExecutionBranch.serialize | saturated | 128 | 5000000 | 28.2 | 36.4 | 0.8x | 5x | yes |
| ExecutionBranch.serialize | zero | 128 | 5000000 | 13.0 | 18.1 | 0.7x | 5x | yes |
| ExecutionPayload.deserialize | large-fixture | 4033 | 286720 | 924.2 | 639.3 | 1.4x | 5x | yes |
| ExecutionPayload.deserialize | medium-fixture | 2445 | 253952 | 1094.7 | 821.4 | 1.3x | 5x | yes |
| ExecutionPayload.deserialize | small-fixture | 1921 | 507904 | 931.3 | 569.3 | 1.6x | 5x | yes |
| ExecutionPayload.hash_tree_root | large-fixture | 4033 | 4480 | 97767.9 | 23824.0 | 4.1x | 10x | yes |
| ExecutionPayload.hash_tree_root | medium-fixture | 2445 | 2240 | 114285.7 | 26747.5 | 4.3x | 10x | yes |
| ExecutionPayload.hash_tree_root | small-fixture | 1921 | 3968 | 82409.3 | 18600.0 | 4.4x | 10x | yes |
| ExecutionPayload.serialize | large-fixture | 4033 | 524288 | 600.8 | 307.7 | 2.0x | 5x | yes |
| ExecutionPayload.serialize | medium-fixture | 2445 | 524288 | 795.4 | 453.3 | 1.8x | 5x | yes |
| ExecutionPayload.serialize | small-fixture | 1921 | 524288 | 715.3 | 365.1 | 2.0x | 5x | yes |
| ExecutionPayloadHeader.deserialize | large-fixture | 604 | 1572864 | 270.2 | 88.9 | 3.0x | 5x | yes |
| ExecutionPayloadHeader.deserialize | medium-fixture | 594 | 1572864 | 279.1 | 83.7 | 3.3x | 5x | yes |
| ExecutionPayloadHeader.deserialize | small-fixture | 590 | 1572864 | 270.8 | 82.7 | 3.3x | 5x | yes |
| ExecutionPayloadHeader.hash_tree_root | large-fixture | 604 | 57344 | 7690.4 | 1975.5 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | medium-fixture | 594 | 57344 | 10864.3 | 2988.1 | 3.6x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | small-fixture | 590 | 57344 | 7673.0 | 1973.7 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.serialize | large-fixture | 604 | 2097152 | 237.9 | 67.4 | 3.5x | 5x | yes |
| ExecutionPayloadHeader.serialize | medium-fixture | 594 | 2097152 | 227.9 | 66.7 | 3.4x | 5x | yes |
| ExecutionPayloadHeader.serialize | small-fixture | 590 | 2097152 | 244.1 | 69.4 | 3.5x | 5x | yes |
| ExecutionRequests.deserialize | large-fixture | 1624 | 524288 | 558.9 | 377.7 | 1.5x | 5x | yes |
| ExecutionRequests.deserialize | medium-fixture | 1004 | 1048576 | 393.9 | 232.9 | 1.7x | 5x | yes |
| ExecutionRequests.deserialize | small-fixture | 396 | 2621440 | 168.6 | 117.6 | 1.4x | 5x | yes |
| ExecutionRequests.hash_tree_root | large-fixture | 1624 | 16384 | 30273.4 | 7757.0 | 3.9x | 10x | yes |
| ExecutionRequests.hash_tree_root | medium-fixture | 1004 | 24576 | 18310.5 | 4933.9 | 3.7x | 10x | yes |
| ExecutionRequests.hash_tree_root | small-fixture | 396 | 40960 | 10595.7 | 2731.1 | 3.9x | 10x | yes |
| ExecutionRequests.serialize | large-fixture | 1624 | 1048576 | 328.1 | 131.9 | 2.5x | 5x | yes |
| ExecutionRequests.serialize | medium-fixture | 1004 | 2621440 | 160.2 | 88.5 | 1.8x | 5x | yes |
| ExecutionRequests.serialize | small-fixture | 396 | 5000000 | 87.4 | 42.5 | 2.1x | 5x | yes |
| FinalityBranch.deserialize | random | 224 | 5000000 | 27.2 | 38.3 | 0.7x | 5x | yes |
| FinalityBranch.deserialize | saturated | 224 | 5000000 | 27.2 | 38.7 | 0.7x | 5x | yes |
| FinalityBranch.deserialize | zero | 224 | 5000000 | 25.0 | 38.6 | 0.6x | 5x | yes |
| FinalityBranch.hash_tree_root | random | 224 | 253952 | 1898.0 | 662.4 | 2.9x | 10x | yes |
| FinalityBranch.hash_tree_root | saturated | 224 | 143360 | 1890.3 | 663.4 | 2.8x | 10x | yes |
| FinalityBranch.hash_tree_root | zero | 224 | 253952 | 1890.1 | 668.2 | 2.8x | 10x | yes |
| FinalityBranch.serialize | random | 224 | 5000000 | 15.4 | 23.4 | 0.7x | 5x | yes |
| FinalityBranch.serialize | saturated | 224 | 5000000 | 15.6 | 22.9 | 0.7x | 5x | yes |
| FinalityBranch.serialize | zero | 224 | 5000000 | 14.8 | 22.4 | 0.7x | 5x | yes |
| Fork.deserialize | large-fixture | 16 | 5000000 | 20.6 | 10.8 | 1.9x | 5x | yes |
| Fork.deserialize | medium-fixture | 16 | 5000000 | 22.6 | 11.0 | 2.1x | 5x | yes |
| Fork.deserialize | small-fixture | 16 | 5000000 | 21.4 | 10.8 | 2.0x | 5x | yes |
| Fork.hash_tree_root | large-fixture | 16 | 507904 | 793.5 | 242.2 | 3.3x | 10x | yes |
| Fork.hash_tree_root | medium-fixture | 16 | 524288 | 795.4 | 242.1 | 3.3x | 10x | yes |
| Fork.hash_tree_root | small-fixture | 16 | 524288 | 793.5 | 243.0 | 3.3x | 10x | yes |
| Fork.serialize | large-fixture | 16 | 5000000 | 6.6 | 13.6 | 0.5x | 5x | yes |
| Fork.serialize | medium-fixture | 16 | 5000000 | 6.6 | 13.6 | 0.5x | 5x | yes |
| Fork.serialize | small-fixture | 16 | 5000000 | 6.8 | 14.1 | 0.5x | 5x | yes |
| ForkData.deserialize | large-fixture | 36 | 5000000 | 26.8 | 13.0 | 2.1x | 5x | yes |
| ForkData.deserialize | medium-fixture | 36 | 5000000 | 26.8 | 13.2 | 2.0x | 5x | yes |
| ForkData.deserialize | small-fixture | 36 | 5000000 | 26.8 | 12.8 | 2.1x | 5x | yes |
| ForkData.hash_tree_root | large-fixture | 36 | 1572864 | 272.8 | 103.4 | 2.6x | 10x | yes |
| ForkData.hash_tree_root | medium-fixture | 36 | 1572864 | 273.4 | 103.3 | 2.6x | 10x | yes |
| ForkData.hash_tree_root | small-fixture | 36 | 1572864 | 272.8 | 103.3 | 2.6x | 10x | yes |
| ForkData.serialize | large-fixture | 36 | 5000000 | 8.6 | 14.8 | 0.6x | 5x | yes |
| ForkData.serialize | medium-fixture | 36 | 5000000 | 8.8 | 14.9 | 0.6x | 5x | yes |
| ForkData.serialize | small-fixture | 36 | 5000000 | 8.6 | 14.4 | 0.6x | 5x | yes |
| ForkDigest.deserialize | random | 4 | 5000000 | 8.2 | 24.0 | 0.3x | 5x | yes |
| ForkDigest.deserialize | saturated | 4 | 5000000 | 8.2 | 24.2 | 0.3x | 5x | yes |
| ForkDigest.deserialize | zero | 4 | 5000000 | 8.0 | 24.5 | 0.3x | 5x | yes |
| ForkDigest.hash_tree_root | random | 4 | 5000000 | 3.2 | 134.6 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | saturated | 4 | 5000000 | 3.2 | 132.9 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | zero | 4 | 5000000 | 3.2 | 133.4 | 0.0x | 10x | yes |
| ForkDigest.serialize | random | 4 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| ForkDigest.serialize | saturated | 4 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| ForkDigest.serialize | zero | 4 | 5000000 | 5.2 | 8.0 | 0.7x | 5x | yes |
| G1Point.deserialize | random | 48 | 5000000 | 34.8 | 28.3 | 1.2x | 5x | yes |
| G1Point.deserialize | saturated | 48 | 5000000 | 33.4 | 27.5 | 1.2x | 5x | yes |
| G1Point.deserialize | zero | 48 | 5000000 | 32.8 | 27.5 | 1.2x | 5x | yes |
| G1Point.hash_tree_root | random | 48 | 1572864 | 273.4 | 232.3 | 1.2x | 10x | yes |
| G1Point.hash_tree_root | saturated | 48 | 1572864 | 273.4 | 228.3 | 1.2x | 10x | yes |
| G1Point.hash_tree_root | zero | 48 | 1572864 | 272.8 | 232.1 | 1.2x | 10x | yes |
| G1Point.serialize | random | 48 | 5000000 | 10.6 | 13.3 | 0.8x | 5x | yes |
| G1Point.serialize | saturated | 48 | 5000000 | 10.6 | 13.2 | 0.8x | 5x | yes |
| G1Point.serialize | zero | 48 | 5000000 | 9.8 | 13.7 | 0.7x | 5x | yes |
| G2Point.deserialize | random | 96 | 5000000 | 49.6 | 30.8 | 1.6x | 5x | yes |
| G2Point.deserialize | saturated | 96 | 5000000 | 47.6 | 29.9 | 1.6x | 5x | yes |
| G2Point.deserialize | zero | 96 | 5000000 | 45.0 | 30.8 | 1.5x | 5x | yes |
| G2Point.hash_tree_root | random | 96 | 524288 | 810.6 | 372.7 | 2.2x | 10x | yes |
| G2Point.hash_tree_root | saturated | 96 | 507904 | 809.2 | 373.3 | 2.2x | 10x | yes |
| G2Point.hash_tree_root | zero | 96 | 524288 | 810.6 | 373.5 | 2.2x | 10x | yes |
| G2Point.serialize | random | 96 | 5000000 | 19.4 | 15.6 | 1.2x | 5x | yes |
| G2Point.serialize | saturated | 96 | 5000000 | 19.4 | 15.8 | 1.2x | 5x | yes |
| G2Point.serialize | zero | 96 | 5000000 | 18.2 | 15.6 | 1.2x | 5x | yes |
| Gwei.deserialize | random | 8 | 5000000 | 10.4 | 23.6 | 0.4x | 5x | yes |
| Gwei.deserialize | saturated | 8 | 5000000 | 10.4 | 23.3 | 0.4x | 5x | yes |
| Gwei.deserialize | zero | 8 | 5000000 | 10.0 | 23.3 | 0.4x | 5x | yes |
| Gwei.hash_tree_root | random | 8 | 5000000 | 3.8 | 138.2 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 135.8 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | zero | 8 | 5000000 | 3.8 | 139.2 | 0.0x | 10x | yes |
| Gwei.serialize | random | 8 | 5000000 | 5.6 | 8.1 | 0.7x | 5x | yes |
| Gwei.serialize | saturated | 8 | 5000000 | 5.6 | 8.1 | 0.7x | 5x | yes |
| Gwei.serialize | zero | 8 | 5000000 | 5.4 | 8.0 | 0.7x | 5x | yes |
| Hash32.deserialize | random | 32 | 5000000 | 23.4 | 31.0 | 0.8x | 5x | yes |
| Hash32.deserialize | saturated | 32 | 5000000 | 22.6 | 29.7 | 0.8x | 5x | yes |
| Hash32.deserialize | zero | 32 | 5000000 | 20.0 | 27.3 | 0.7x | 5x | yes |
| Hash32.hash_tree_root | random | 32 | 5000000 | 3.8 | 132.5 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | saturated | 32 | 5000000 | 4.0 | 133.2 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | zero | 32 | 5000000 | 3.8 | 142.2 | 0.0x | 10x | yes |
| Hash32.serialize | random | 32 | 5000000 | 6.4 | 13.0 | 0.5x | 5x | yes |
| Hash32.serialize | saturated | 32 | 5000000 | 7.0 | 13.6 | 0.5x | 5x | yes |
| Hash32.serialize | zero | 32 | 5000000 | 6.6 | 13.4 | 0.5x | 5x | yes |
| HistoricalBatch.deserialize | large-fixture | 524288 | 16384 | 30456.5 | 316560.8 | 0.1x | 5x | yes |
| HistoricalBatch.deserialize | medium-fixture | 524288 | 16384 | 27954.1 | 308003.2 | 0.1x | 5x | yes |
| HistoricalBatch.deserialize | small-fixture | 524288 | 16384 | 30090.3 | 321606.1 | 0.1x | 5x | yes |
| HistoricalBatch.hash_tree_root | large-fixture | 524288 | 70 | 4385714.3 | 1146451.3 | 3.8x | 10x | yes |
| HistoricalBatch.hash_tree_root | medium-fixture | 524288 | 62 | 4403225.8 | 1144845.8 | 3.8x | 10x | yes |
| HistoricalBatch.hash_tree_root | small-fixture | 524288 | 100 | 4400000.0 | 1144245.2 | 3.8x | 10x | yes |
| HistoricalBatch.serialize | large-fixture | 524288 | 16384 | 42419.4 | 107433.6 | 0.4x | 5x | yes |
| HistoricalBatch.serialize | medium-fixture | 524288 | 16384 | 25634.8 | 69575.1 | 0.4x | 5x | yes |
| HistoricalBatch.serialize | small-fixture | 524288 | 16384 | 25390.6 | 69928.1 | 0.4x | 5x | yes |
| HistoricalSummary.deserialize | large-fixture | 64 | 5000000 | 38.0 | 13.3 | 2.8x | 5x | yes |
| HistoricalSummary.deserialize | medium-fixture | 64 | 5000000 | 38.0 | 13.3 | 2.9x | 5x | yes |
| HistoricalSummary.deserialize | small-fixture | 64 | 5000000 | 38.0 | 13.4 | 2.8x | 5x | yes |
| HistoricalSummary.hash_tree_root | large-fixture | 64 | 1572864 | 274.7 | 101.5 | 2.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | medium-fixture | 64 | 1572864 | 274.7 | 101.7 | 2.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | small-fixture | 64 | 1572864 | 274.7 | 101.3 | 2.7x | 10x | yes |
| HistoricalSummary.serialize | large-fixture | 64 | 5000000 | 12.4 | 14.9 | 0.8x | 5x | yes |
| HistoricalSummary.serialize | medium-fixture | 64 | 5000000 | 12.4 | 14.6 | 0.8x | 5x | yes |
| HistoricalSummary.serialize | small-fixture | 64 | 5000000 | 12.4 | 14.7 | 0.8x | 5x | yes |
| IndexedAttestation.deserialize | large-fixture | 308 | 2621440 | 172.0 | 83.1 | 2.1x | 5x | yes |
| IndexedAttestation.deserialize | medium-fixture | 284 | 2621440 | 163.7 | 77.8 | 2.1x | 5x | yes |
| IndexedAttestation.deserialize | small-fixture | 236 | 2621440 | 163.7 | 75.5 | 2.2x | 5x | yes |
| IndexedAttestation.hash_tree_root | large-fixture | 308 | 57344 | 8265.9 | 2186.8 | 3.8x | 10x | yes |
| IndexedAttestation.hash_tree_root | medium-fixture | 284 | 57344 | 8248.5 | 2113.3 | 3.9x | 10x | yes |
| IndexedAttestation.hash_tree_root | small-fixture | 236 | 57344 | 7986.9 | 2097.7 | 3.8x | 10x | yes |
| IndexedAttestation.serialize | large-fixture | 308 | 4194304 | 111.8 | 35.5 | 3.1x | 5x | yes |
| IndexedAttestation.serialize | medium-fixture | 284 | 4194304 | 111.6 | 33.5 | 3.3x | 5x | yes |
| IndexedAttestation.serialize | small-fixture | 236 | 4194304 | 107.3 | 28.9 | 3.7x | 5x | yes |
| KZGCommitment.deserialize | random | 48 | 5000000 | 31.6 | 28.1 | 1.1x | 5x | yes |
| KZGCommitment.deserialize | saturated | 48 | 5000000 | 31.0 | 28.4 | 1.1x | 5x | yes |
| KZGCommitment.deserialize | zero | 48 | 5000000 | 33.4 | 28.0 | 1.2x | 5x | yes |
| KZGCommitment.hash_tree_root | random | 48 | 1572864 | 274.0 | 231.1 | 1.2x | 10x | yes |
| KZGCommitment.hash_tree_root | saturated | 48 | 1572864 | 274.7 | 224.1 | 1.2x | 10x | yes |
| KZGCommitment.hash_tree_root | zero | 48 | 1572864 | 273.4 | 228.0 | 1.2x | 10x | yes |
| KZGCommitment.serialize | random | 48 | 5000000 | 11.0 | 13.4 | 0.8x | 5x | yes |
| KZGCommitment.serialize | saturated | 48 | 5000000 | 11.2 | 13.0 | 0.9x | 5x | yes |
| KZGCommitment.serialize | zero | 48 | 5000000 | 9.8 | 13.3 | 0.7x | 5x | yes |
| KZGProof.deserialize | random | 48 | 5000000 | 24.0 | 28.3 | 0.8x | 5x | yes |
| KZGProof.deserialize | saturated | 48 | 5000000 | 24.0 | 28.5 | 0.8x | 5x | yes |
| KZGProof.deserialize | zero | 48 | 5000000 | 23.0 | 27.9 | 0.8x | 5x | yes |
| KZGProof.hash_tree_root | random | 48 | 1572864 | 268.9 | 226.9 | 1.2x | 10x | yes |
| KZGProof.hash_tree_root | saturated | 48 | 1572864 | 269.6 | 223.3 | 1.2x | 10x | yes |
| KZGProof.hash_tree_root | zero | 48 | 1572864 | 268.3 | 227.9 | 1.2x | 10x | yes |
| KZGProof.serialize | random | 48 | 5000000 | 9.4 | 13.1 | 0.7x | 5x | yes |
| KZGProof.serialize | saturated | 48 | 5000000 | 9.4 | 13.6 | 0.7x | 5x | yes |
| KZGProof.serialize | zero | 48 | 5000000 | 8.6 | 13.2 | 0.7x | 5x | yes |
| LightClientBootstrap.deserialize | large-fixture | 25676 | 286720 | 1646.2 | 8348.8 | 0.2x | 5x | yes |
| LightClientBootstrap.deserialize | medium-fixture | 25666 | 286720 | 1653.2 | 8394.5 | 0.2x | 5x | yes |
| LightClientBootstrap.deserialize | small-fixture | 25651 | 286720 | 1639.2 | 8348.5 | 0.2x | 5x | yes |
| LightClientBootstrap.hash_tree_root | large-fixture | 25676 | 1664 | 298677.9 | 78027.4 | 3.8x | 10x | yes |
| LightClientBootstrap.hash_tree_root | medium-fixture | 25666 | 1664 | 298076.9 | 78090.9 | 3.8x | 10x | yes |
| LightClientBootstrap.hash_tree_root | small-fixture | 25651 | 1664 | 297476.0 | 78005.3 | 3.8x | 10x | yes |
| LightClientBootstrap.serialize | large-fixture | 25676 | 204800 | 1352.5 | 1785.6 | 0.8x | 5x | yes |
| LightClientBootstrap.serialize | medium-fixture | 25666 | 204800 | 1357.4 | 1906.1 | 0.7x | 5x | yes |
| LightClientBootstrap.serialize | small-fixture | 25651 | 204800 | 1352.5 | 1813.4 | 0.7x | 5x | yes |
| LightClientFinalityUpdate.deserialize | large-fixture | 2096 | 507904 | 943.1 | 933.1 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.deserialize | medium-fixture | 2078 | 507904 | 945.1 | 928.8 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.deserialize | small-fixture | 2066 | 507904 | 952.9 | 940.8 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.hash_tree_root | large-fixture | 2096 | 16384 | 26916.5 | 6828.0 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | medium-fixture | 2078 | 16384 | 26977.5 | 6821.1 | 4.0x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | small-fixture | 2066 | 16384 | 26855.5 | 6829.0 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.serialize | large-fixture | 2096 | 524288 | 629.4 | 169.8 | 3.7x | 5x | yes |
| LightClientFinalityUpdate.serialize | medium-fixture | 2078 | 524288 | 625.6 | 174.1 | 3.6x | 5x | yes |
| LightClientFinalityUpdate.serialize | small-fixture | 2066 | 524288 | 619.9 | 173.9 | 3.6x | 5x | yes |
| LightClientHeader.deserialize | large-fixture | 860 | 1048576 | 379.6 | 360.6 | 1.1x | 5x | yes |
| LightClientHeader.deserialize | medium-fixture | 850 | 1048576 | 378.6 | 350.8 | 1.1x | 5x | yes |
| LightClientHeader.deserialize | small-fixture | 830 | 1048576 | 379.6 | 356.8 | 1.1x | 5x | yes |
| LightClientHeader.hash_tree_root | large-fixture | 860 | 40960 | 10937.5 | 2790.8 | 3.9x | 10x | yes |
| LightClientHeader.hash_tree_root | medium-fixture | 850 | 40960 | 10937.5 | 2792.5 | 3.9x | 10x | yes |
| LightClientHeader.hash_tree_root | small-fixture | 830 | 40960 | 10937.5 | 2797.2 | 3.9x | 10x | yes |
| LightClientHeader.serialize | large-fixture | 860 | 1572864 | 239.7 | 78.7 | 3.0x | 5x | yes |
| LightClientHeader.serialize | medium-fixture | 850 | 1572864 | 239.7 | 78.5 | 3.1x | 5x | yes |
| LightClientHeader.serialize | small-fixture | 830 | 1572864 | 239.7 | 76.3 | 3.1x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | large-fixture | 1031 | 1048576 | 473.0 | 430.3 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | medium-fixture | 1013 | 1048576 | 474.0 | 428.7 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | small-fixture | 1000 | 524288 | 474.9 | 417.4 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.hash_tree_root | large-fixture | 1031 | 32768 | 13092.0 | 3369.6 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | medium-fixture | 1013 | 32768 | 13092.0 | 3372.4 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | small-fixture | 1000 | 32768 | 13061.5 | 3365.9 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.serialize | large-fixture | 1031 | 1572864 | 275.3 | 103.2 | 2.7x | 5x | yes |
| LightClientOptimisticUpdate.serialize | medium-fixture | 1013 | 1572864 | 274.7 | 86.6 | 3.2x | 5x | yes |
| LightClientOptimisticUpdate.serialize | small-fixture | 1000 | 1572864 | 273.4 | 85.7 | 3.2x | 5x | yes |
| LightClientUpdate.deserialize | large-fixture | 26914 | 102400 | 2431.6 | 8987.4 | 0.3x | 5x | yes |
| LightClientUpdate.deserialize | medium-fixture | 26893 | 102400 | 2412.1 | 9045.3 | 0.3x | 5x | yes |
| LightClientUpdate.deserialize | small-fixture | 26885 | 102400 | 2431.6 | 8962.9 | 0.3x | 5x | yes |
| LightClientUpdate.hash_tree_root | large-fixture | 26914 | 1536 | 313151.0 | 81954.1 | 3.8x | 10x | yes |
| LightClientUpdate.hash_tree_root | medium-fixture | 26893 | 1536 | 312500.0 | 81888.6 | 3.8x | 10x | yes |
| LightClientUpdate.hash_tree_root | small-fixture | 26885 | 1536 | 313802.1 | 81920.8 | 3.8x | 10x | yes |
| LightClientUpdate.serialize | large-fixture | 26914 | 253952 | 1925.6 | 1970.8 | 1.0x | 5x | yes |
| LightClientUpdate.serialize | medium-fixture | 26893 | 143360 | 1883.4 | 1824.2 | 1.0x | 5x | yes |
| LightClientUpdate.serialize | small-fixture | 26885 | 253952 | 2110.6 | 2066.5 | 1.0x | 5x | yes |
| MatrixEntry.deserialize | large-fixture | 2112 | 3145728 | 137.3 | 169.8 | 0.8x | 5x | yes |
| MatrixEntry.deserialize | medium-fixture | 2112 | 3145728 | 137.6 | 171.4 | 0.8x | 5x | yes |
| MatrixEntry.deserialize | small-fixture | 2112 | 3145728 | 137.0 | 168.5 | 0.8x | 5x | yes |
| MatrixEntry.hash_tree_root | large-fixture | 2112 | 24576 | 18188.5 | 4483.4 | 4.1x | 10x | yes |
| MatrixEntry.hash_tree_root | medium-fixture | 2112 | 24576 | 18188.5 | 4481.9 | 4.1x | 10x | yes |
| MatrixEntry.hash_tree_root | small-fixture | 2112 | 24576 | 18188.5 | 4475.3 | 4.1x | 10x | yes |
| MatrixEntry.serialize | large-fixture | 2112 | 3670016 | 128.1 | 151.9 | 0.8x | 5x | yes |
| MatrixEntry.serialize | medium-fixture | 2112 | 3670016 | 127.5 | 147.9 | 0.9x | 5x | yes |
| MatrixEntry.serialize | small-fixture | 2112 | 3670016 | 128.1 | 136.2 | 0.9x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 26.6 | 36.4 | 0.7x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | saturated | 192 | 5000000 | 27.2 | 39.2 | 0.7x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 24.2 | 37.0 | 0.7x | 5x | yes |
| NextSyncCommitteeBranch.hash_tree_root | random | 192 | 143360 | 1911.3 | 589.9 | 3.2x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | saturated | 192 | 253952 | 1905.9 | 585.9 | 3.3x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | zero | 192 | 253952 | 1905.9 | 588.2 | 3.2x | 10x | yes |
| NextSyncCommitteeBranch.serialize | random | 192 | 5000000 | 19.8 | 19.6 | 1.0x | 5x | yes |
| NextSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 20.0 | 22.3 | 0.9x | 5x | yes |
| NextSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 14.8 | 20.6 | 0.7x | 5x | yes |
| NodeID.deserialize | random | 32 | 5000000 | 25.4 | 26.9 | 0.9x | 5x | yes |
| NodeID.deserialize | saturated | 32 | 5000000 | 27.2 | 27.1 | 1.0x | 5x | yes |
| NodeID.deserialize | zero | 32 | 5000000 | 27.4 | 27.3 | 1.0x | 5x | yes |
| NodeID.hash_tree_root | random | 32 | 5000000 | 4.2 | 125.6 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | saturated | 32 | 5000000 | 4.2 | 127.1 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | zero | 32 | 5000000 | 4.2 | 127.3 | 0.0x | 10x | yes |
| NodeID.serialize | random | 32 | 5000000 | 7.8 | 12.6 | 0.6x | 5x | yes |
| NodeID.serialize | saturated | 32 | 5000000 | 8.0 | 12.4 | 0.6x | 5x | yes |
| NodeID.serialize | zero | 32 | 5000000 | 7.2 | 12.6 | 0.6x | 5x | yes |
| ParticipationFlags.deserialize | random | 1 | 5000000 | 6.8 | 22.8 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | saturated | 1 | 5000000 | 6.8 | 23.0 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | zero | 1 | 5000000 | 6.8 | 23.3 | 0.3x | 5x | yes |
| ParticipationFlags.hash_tree_root | random | 1 | 5000000 | 3.0 | 134.8 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | saturated | 1 | 5000000 | 3.0 | 139.7 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | zero | 1 | 5000000 | 3.0 | 132.4 | 0.0x | 10x | yes |
| ParticipationFlags.serialize | random | 1 | 5000000 | 5.4 | 7.7 | 0.7x | 5x | yes |
| ParticipationFlags.serialize | saturated | 1 | 5000000 | 5.2 | 7.7 | 0.7x | 5x | yes |
| ParticipationFlags.serialize | zero | 1 | 5000000 | 5.2 | 7.5 | 0.7x | 5x | yes |
| PayloadId.deserialize | random | 8 | 5000000 | 11.0 | 23.6 | 0.5x | 5x | yes |
| PayloadId.deserialize | saturated | 8 | 5000000 | 11.0 | 23.5 | 0.5x | 5x | yes |
| PayloadId.deserialize | zero | 8 | 5000000 | 11.0 | 23.2 | 0.5x | 5x | yes |
| PayloadId.hash_tree_root | random | 8 | 5000000 | 4.0 | 133.2 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 134.9 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | zero | 8 | 5000000 | 3.8 | 136.0 | 0.0x | 10x | yes |
| PayloadId.serialize | random | 8 | 5000000 | 6.4 | 8.0 | 0.8x | 5x | yes |
| PayloadId.serialize | saturated | 8 | 5000000 | 6.6 | 8.1 | 0.8x | 5x | yes |
| PayloadId.serialize | zero | 8 | 5000000 | 6.4 | 8.0 | 0.8x | 5x | yes |
| PendingAttestation.deserialize | large-fixture | 150 | 4194304 | 108.5 | 64.7 | 1.7x | 5x | yes |
| PendingAttestation.deserialize | medium-fixture | 149 | 4194304 | 107.0 | 64.7 | 1.7x | 5x | yes |
| PendingAttestation.deserialize | small-fixture | 149 | 4194304 | 107.8 | 64.3 | 1.7x | 5x | yes |
| PendingAttestation.hash_tree_root | large-fixture | 150 | 114688 | 3984.7 | 1095.7 | 3.6x | 10x | yes |
| PendingAttestation.hash_tree_root | medium-fixture | 149 | 114688 | 3984.7 | 1096.2 | 3.6x | 10x | yes |
| PendingAttestation.hash_tree_root | small-fixture | 149 | 114688 | 3993.4 | 1095.9 | 3.6x | 10x | yes |
| PendingAttestation.serialize | large-fixture | 150 | 5000000 | 47.2 | 25.5 | 1.9x | 5x | yes |
| PendingAttestation.serialize | medium-fixture | 149 | 5000000 | 47.0 | 25.0 | 1.9x | 5x | yes |
| PendingAttestation.serialize | small-fixture | 149 | 5000000 | 47.2 | 25.4 | 1.9x | 5x | yes |
| PendingConsolidation.deserialize | large-fixture | 16 | 5000000 | 15.6 | 10.5 | 1.5x | 5x | yes |
| PendingConsolidation.deserialize | medium-fixture | 16 | 5000000 | 16.0 | 10.8 | 1.5x | 5x | yes |
| PendingConsolidation.deserialize | small-fixture | 16 | 5000000 | 16.0 | 10.9 | 1.5x | 5x | yes |
| PendingConsolidation.hash_tree_root | large-fixture | 16 | 1572864 | 269.6 | 100.5 | 2.7x | 10x | yes |
| PendingConsolidation.hash_tree_root | medium-fixture | 16 | 1572864 | 270.2 | 100.7 | 2.7x | 10x | yes |
| PendingConsolidation.hash_tree_root | small-fixture | 16 | 1572864 | 269.6 | 100.5 | 2.7x | 10x | yes |
| PendingConsolidation.serialize | large-fixture | 16 | 5000000 | 6.4 | 12.6 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | medium-fixture | 16 | 5000000 | 6.4 | 12.3 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | small-fixture | 16 | 5000000 | 6.6 | 12.4 | 0.5x | 5x | yes |
| PendingDeposit.deserialize | large-fixture | 192 | 5000000 | 90.6 | 37.4 | 2.4x | 5x | yes |
| PendingDeposit.deserialize | medium-fixture | 192 | 5000000 | 89.4 | 38.0 | 2.4x | 5x | yes |
| PendingDeposit.deserialize | small-fixture | 192 | 5000000 | 87.8 | 38.5 | 2.3x | 5x | yes |
| PendingDeposit.hash_tree_root | large-fixture | 192 | 180224 | 2657.8 | 725.7 | 3.7x | 10x | yes |
| PendingDeposit.hash_tree_root | medium-fixture | 192 | 180224 | 2663.4 | 725.3 | 3.7x | 10x | yes |
| PendingDeposit.hash_tree_root | small-fixture | 192 | 180224 | 2663.4 | 724.1 | 3.7x | 10x | yes |
| PendingDeposit.serialize | large-fixture | 192 | 5000000 | 31.2 | 23.5 | 1.3x | 5x | yes |
| PendingDeposit.serialize | medium-fixture | 192 | 5000000 | 31.0 | 21.9 | 1.4x | 5x | yes |
| PendingDeposit.serialize | small-fixture | 192 | 5000000 | 31.0 | 22.6 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | large-fixture | 24 | 5000000 | 17.6 | 12.5 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | medium-fixture | 24 | 5000000 | 17.8 | 12.6 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | small-fixture | 24 | 5000000 | 17.8 | 12.3 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.hash_tree_root | large-fixture | 24 | 524288 | 797.3 | 238.6 | 3.3x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | medium-fixture | 24 | 524288 | 795.4 | 238.3 | 3.3x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | small-fixture | 24 | 507904 | 797.4 | 238.7 | 3.3x | 10x | yes |
| PendingPartialWithdrawal.serialize | large-fixture | 24 | 5000000 | 6.8 | 14.4 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | medium-fixture | 24 | 5000000 | 7.0 | 14.5 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | small-fixture | 24 | 5000000 | 7.0 | 14.7 | 0.5x | 5x | yes |
| PowBlock.deserialize | large-fixture | 96 | 5000000 | 41.0 | 55.8 | 0.7x | 5x | yes |
| PowBlock.deserialize | medium-fixture | 96 | 5000000 | 41.0 | 56.3 | 0.7x | 5x | yes |
| PowBlock.deserialize | small-fixture | 96 | 5000000 | 41.0 | 55.5 | 0.7x | 5x | yes |
| PowBlock.hash_tree_root | large-fixture | 96 | 524288 | 799.2 | 239.9 | 3.3x | 10x | yes |
| PowBlock.hash_tree_root | medium-fixture | 96 | 524288 | 797.3 | 240.8 | 3.3x | 10x | yes |
| PowBlock.hash_tree_root | small-fixture | 96 | 507904 | 797.4 | 240.7 | 3.3x | 10x | yes |
| PowBlock.serialize | large-fixture | 96 | 5000000 | 16.2 | 17.2 | 0.9x | 5x | yes |
| PowBlock.serialize | medium-fixture | 96 | 5000000 | 16.2 | 18.2 | 0.9x | 5x | yes |
| PowBlock.serialize | small-fixture | 96 | 5000000 | 16.2 | 17.7 | 0.9x | 5x | yes |
| ProposerSlashing.deserialize | large-fixture | 416 | 1572864 | 257.5 | 85.3 | 3.0x | 5x | yes |
| ProposerSlashing.deserialize | medium-fixture | 416 | 1572864 | 266.4 | 84.6 | 3.2x | 5x | yes |
| ProposerSlashing.deserialize | small-fixture | 416 | 1572864 | 258.8 | 84.0 | 3.1x | 5x | yes |
| ProposerSlashing.hash_tree_root | large-fixture | 416 | 81920 | 5615.2 | 1543.5 | 3.6x | 10x | yes |
| ProposerSlashing.hash_tree_root | medium-fixture | 416 | 81920 | 5615.2 | 1512.5 | 3.7x | 10x | yes |
| ProposerSlashing.hash_tree_root | small-fixture | 416 | 81920 | 5615.2 | 1513.4 | 3.7x | 10x | yes |
| ProposerSlashing.serialize | large-fixture | 416 | 5000000 | 93.4 | 38.8 | 2.4x | 5x | yes |
| ProposerSlashing.serialize | medium-fixture | 416 | 5000000 | 93.2 | 37.7 | 2.5x | 5x | yes |
| ProposerSlashing.serialize | small-fixture | 416 | 5000000 | 93.6 | 38.9 | 2.4x | 5x | yes |
| Root.deserialize | random | 32 | 5000000 | 37.2 | 40.6 | 0.9x | 5x | yes |
| Root.deserialize | saturated | 32 | 5000000 | 28.8 | 30.5 | 0.9x | 5x | yes |
| Root.deserialize | zero | 32 | 5000000 | 27.8 | 28.1 | 1.0x | 5x | yes |
| Root.hash_tree_root | random | 32 | 5000000 | 5.6 | 168.4 | 0.0x | 10x | yes |
| Root.hash_tree_root | saturated | 32 | 5000000 | 4.6 | 140.5 | 0.0x | 10x | yes |
| Root.hash_tree_root | zero | 32 | 5000000 | 4.4 | 136.6 | 0.0x | 10x | yes |
| Root.serialize | random | 32 | 5000000 | 11.2 | 18.6 | 0.6x | 5x | yes |
| Root.serialize | saturated | 32 | 5000000 | 8.0 | 13.2 | 0.6x | 5x | yes |
| Root.serialize | zero | 32 | 5000000 | 7.6 | 12.7 | 0.6x | 5x | yes |
| RowIndex.deserialize | random | 8 | 5000000 | 13.4 | 23.5 | 0.6x | 5x | yes |
| RowIndex.deserialize | saturated | 8 | 5000000 | 16.6 | 29.4 | 0.6x | 5x | yes |
| RowIndex.deserialize | zero | 8 | 5000000 | 13.4 | 23.4 | 0.6x | 5x | yes |
| RowIndex.hash_tree_root | random | 8 | 5000000 | 3.8 | 143.2 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | saturated | 8 | 5000000 | 5.4 | 191.6 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 132.6 | 0.0x | 10x | yes |
| RowIndex.serialize | random | 8 | 5000000 | 6.2 | 7.9 | 0.8x | 5x | yes |
| RowIndex.serialize | saturated | 8 | 5000000 | 8.8 | 11.3 | 0.8x | 5x | yes |
| RowIndex.serialize | zero | 8 | 5000000 | 6.2 | 8.3 | 0.7x | 5x | yes |
| SignedAggregateAndProof.deserialize | large-fixture | 446 | 1048576 | 318.5 | 129.9 | 2.5x | 5x | yes |
| SignedAggregateAndProof.deserialize | medium-fixture | 445 | 1048576 | 322.3 | 130.6 | 2.5x | 5x | yes |
| SignedAggregateAndProof.deserialize | small-fixture | 445 | 1048576 | 313.8 | 130.6 | 2.4x | 5x | yes |
| SignedAggregateAndProof.hash_tree_root | large-fixture | 446 | 49152 | 9155.3 | 2414.9 | 3.8x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | medium-fixture | 445 | 40960 | 9594.7 | 2541.0 | 3.8x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | small-fixture | 445 | 40960 | 11840.8 | 3156.8 | 3.8x | 10x | yes |
| SignedAggregateAndProof.serialize | large-fixture | 446 | 2621440 | 183.9 | 47.8 | 3.8x | 5x | yes |
| SignedAggregateAndProof.serialize | medium-fixture | 445 | 2621440 | 180.1 | 49.3 | 3.7x | 5x | yes |
| SignedAggregateAndProof.serialize | small-fixture | 445 | 2621440 | 183.9 | 49.0 | 3.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | large-fixture | 172 | 5000000 | 95.6 | 34.6 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | medium-fixture | 172 | 5000000 | 94.4 | 33.9 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | small-fixture | 172 | 2621440 | 95.7 | 34.3 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.hash_tree_root | large-fixture | 172 | 221184 | 2134.0 | 603.4 | 3.5x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | medium-fixture | 172 | 221184 | 2129.4 | 602.2 | 3.5x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | small-fixture | 172 | 221184 | 2134.0 | 602.5 | 3.5x | 10x | yes |
| SignedBLSToExecutionChange.serialize | large-fixture | 172 | 5000000 | 29.4 | 21.8 | 1.3x | 5x | yes |
| SignedBLSToExecutionChange.serialize | medium-fixture | 172 | 5000000 | 29.6 | 22.2 | 1.3x | 5x | yes |
| SignedBLSToExecutionChange.serialize | small-fixture | 172 | 5000000 | 29.6 | 21.8 | 1.4x | 5x | yes |
| SignedBeaconBlock.deserialize | large-fixture | 23999 | 57344 | 8231.0 | 8894.1 | 0.9x | 5x | yes |
| SignedBeaconBlock.deserialize | medium-fixture | 18718 | 65536 | 7507.3 | 7357.7 | 1.0x | 5x | yes |
| SignedBeaconBlock.deserialize | small-fixture | 16683 | 106496 | 4563.6 | 7016.5 | 0.7x | 5x | yes |
| SignedBeaconBlock.hash_tree_root | large-fixture | 23999 | 1408 | 331676.1 | 84590.3 | 3.9x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | medium-fixture | 18718 | 1792 | 268415.2 | 69270.4 | 3.9x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | small-fixture | 16683 | 2176 | 218750.0 | 56534.2 | 3.9x | 10x | yes |
| SignedBeaconBlock.serialize | large-fixture | 23999 | 106496 | 4272.5 | 1444.2 | 3.0x | 5x | yes |
| SignedBeaconBlock.serialize | medium-fixture | 18718 | 122880 | 4044.6 | 1072.5 | 3.8x | 5x | yes |
| SignedBeaconBlock.serialize | small-fixture | 16683 | 180224 | 2741.0 | 1096.4 | 2.5x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | large-fixture | 208 | 3145728 | 146.5 | 35.5 | 4.1x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | medium-fixture | 208 | 3145728 | 142.1 | 36.7 | 3.9x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | small-fixture | 208 | 3145728 | 142.4 | 35.8 | 4.0x | 5x | yes |
| SignedBeaconBlockHeader.hash_tree_root | large-fixture | 208 | 180224 | 2674.4 | 729.8 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | medium-fixture | 208 | 180224 | 2680.0 | 729.6 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | small-fixture | 208 | 180224 | 2668.9 | 730.8 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.serialize | large-fixture | 208 | 5000000 | 35.0 | 24.5 | 1.4x | 5x | yes |
| SignedBeaconBlockHeader.serialize | medium-fixture | 208 | 5000000 | 34.8 | 24.7 | 1.4x | 5x | yes |
| SignedBeaconBlockHeader.serialize | small-fixture | 208 | 5000000 | 34.8 | 23.7 | 1.5x | 5x | yes |
| SignedContributionAndProof.deserialize | large-fixture | 360 | 2097152 | 216.0 | 85.0 | 2.5x | 5x | yes |
| SignedContributionAndProof.deserialize | medium-fixture | 360 | 2097152 | 208.4 | 83.7 | 2.5x | 5x | yes |
| SignedContributionAndProof.deserialize | small-fixture | 360 | 2097152 | 216.0 | 84.6 | 2.6x | 5x | yes |
| SignedContributionAndProof.hash_tree_root | large-fixture | 360 | 90112 | 5149.1 | 1377.1 | 3.7x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | medium-fixture | 360 | 90112 | 5115.9 | 1378.2 | 3.7x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | small-fixture | 360 | 90112 | 5071.5 | 1363.0 | 3.7x | 10x | yes |
| SignedContributionAndProof.serialize | large-fixture | 360 | 5000000 | 84.8 | 38.2 | 2.2x | 5x | yes |
| SignedContributionAndProof.serialize | medium-fixture | 360 | 5000000 | 85.2 | 36.2 | 2.4x | 5x | yes |
| SignedContributionAndProof.serialize | small-fixture | 360 | 5000000 | 84.8 | 38.3 | 2.2x | 5x | yes |
| SignedVoluntaryExit.deserialize | large-fixture | 112 | 5000000 | 54.8 | 29.7 | 1.8x | 5x | yes |
| SignedVoluntaryExit.deserialize | medium-fixture | 112 | 5000000 | 54.8 | 30.2 | 1.8x | 5x | yes |
| SignedVoluntaryExit.deserialize | small-fixture | 112 | 5000000 | 69.2 | 39.8 | 1.7x | 5x | yes |
| SignedVoluntaryExit.hash_tree_root | large-fixture | 112 | 335872 | 1336.8 | 391.1 | 3.4x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | medium-fixture | 112 | 335872 | 1336.8 | 391.4 | 3.4x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | small-fixture | 112 | 335872 | 1333.8 | 392.9 | 3.4x | 10x | yes |
| SignedVoluntaryExit.serialize | large-fixture | 112 | 5000000 | 20.8 | 18.4 | 1.1x | 5x | yes |
| SignedVoluntaryExit.serialize | medium-fixture | 112 | 5000000 | 20.8 | 18.6 | 1.1x | 5x | yes |
| SignedVoluntaryExit.serialize | small-fixture | 112 | 5000000 | 24.2 | 21.5 | 1.1x | 5x | yes |
| SigningData.deserialize | large-fixture | 64 | 5000000 | 40.6 | 13.4 | 3.0x | 5x | yes |
| SigningData.deserialize | medium-fixture | 64 | 5000000 | 40.6 | 13.3 | 3.0x | 5x | yes |
| SigningData.deserialize | small-fixture | 64 | 5000000 | 40.6 | 13.1 | 3.1x | 5x | yes |
| SigningData.hash_tree_root | large-fixture | 64 | 1572864 | 275.9 | 101.8 | 2.7x | 10x | yes |
| SigningData.hash_tree_root | medium-fixture | 64 | 1572864 | 275.9 | 101.9 | 2.7x | 10x | yes |
| SigningData.hash_tree_root | small-fixture | 64 | 1572864 | 275.9 | 102.0 | 2.7x | 10x | yes |
| SigningData.serialize | large-fixture | 64 | 5000000 | 12.6 | 14.6 | 0.9x | 5x | yes |
| SigningData.serialize | medium-fixture | 64 | 5000000 | 12.6 | 14.7 | 0.9x | 5x | yes |
| SigningData.serialize | small-fixture | 64 | 5000000 | 12.6 | 14.5 | 0.9x | 5x | yes |
| SingleAttestation.deserialize | large-fixture | 240 | 2621440 | 164.8 | 57.6 | 2.9x | 5x | yes |
| SingleAttestation.deserialize | medium-fixture | 240 | 2621440 | 167.1 | 58.7 | 2.8x | 5x | yes |
| SingleAttestation.deserialize | small-fixture | 240 | 2621440 | 161.4 | 59.0 | 2.7x | 5x | yes |
| SingleAttestation.hash_tree_root | large-fixture | 240 | 122880 | 3727.2 | 1027.1 | 3.6x | 10x | yes |
| SingleAttestation.hash_tree_root | medium-fixture | 240 | 131072 | 3730.8 | 1025.6 | 3.6x | 10x | yes |
| SingleAttestation.hash_tree_root | small-fixture | 240 | 122880 | 3735.4 | 1028.7 | 3.6x | 10x | yes |
| SingleAttestation.serialize | large-fixture | 240 | 5000000 | 39.2 | 28.8 | 1.4x | 5x | yes |
| SingleAttestation.serialize | medium-fixture | 240 | 5000000 | 39.0 | 27.6 | 1.4x | 5x | yes |
| SingleAttestation.serialize | small-fixture | 240 | 5000000 | 39.0 | 29.0 | 1.3x | 5x | yes |
| Slot.deserialize | random | 8 | 5000000 | 9.8 | 23.3 | 0.4x | 5x | yes |
| Slot.deserialize | saturated | 8 | 5000000 | 9.8 | 23.9 | 0.4x | 5x | yes |
| Slot.deserialize | zero | 8 | 5000000 | 9.8 | 23.3 | 0.4x | 5x | yes |
| Slot.hash_tree_root | random | 8 | 5000000 | 3.4 | 137.7 | 0.0x | 10x | yes |
| Slot.hash_tree_root | saturated | 8 | 5000000 | 3.4 | 137.3 | 0.0x | 10x | yes |
| Slot.hash_tree_root | zero | 8 | 5000000 | 3.4 | 138.2 | 0.0x | 10x | yes |
| Slot.serialize | random | 8 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| Slot.serialize | saturated | 8 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| Slot.serialize | zero | 8 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| SubnetID.deserialize | random | 8 | 5000000 | 14.6 | 23.4 | 0.6x | 5x | yes |
| SubnetID.deserialize | saturated | 8 | 5000000 | 14.4 | 23.2 | 0.6x | 5x | yes |
| SubnetID.deserialize | zero | 8 | 5000000 | 14.4 | 23.5 | 0.6x | 5x | yes |
| SubnetID.hash_tree_root | random | 8 | 5000000 | 3.8 | 133.3 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 134.7 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | zero | 8 | 5000000 | 4.0 | 130.4 | 0.0x | 10x | yes |
| SubnetID.serialize | random | 8 | 5000000 | 6.0 | 7.9 | 0.8x | 5x | yes |
| SubnetID.serialize | saturated | 8 | 5000000 | 6.0 | 8.1 | 0.7x | 5x | yes |
| SubnetID.serialize | zero | 8 | 5000000 | 6.0 | 8.0 | 0.7x | 5x | yes |
| SyncAggregate.deserialize | large-fixture | 160 | 3145728 | 75.7 | 33.6 | 2.3x | 5x | yes |
| SyncAggregate.deserialize | medium-fixture | 160 | 5000000 | 75.6 | 33.8 | 2.2x | 5x | yes |
| SyncAggregate.deserialize | small-fixture | 160 | 3407872 | 71.3 | 33.9 | 2.1x | 5x | yes |
| SyncAggregate.hash_tree_root | large-fixture | 160 | 204800 | 1337.9 | 386.8 | 3.5x | 10x | yes |
| SyncAggregate.hash_tree_root | medium-fixture | 160 | 335872 | 1354.7 | 394.0 | 3.4x | 10x | yes |
| SyncAggregate.hash_tree_root | small-fixture | 160 | 204800 | 1337.9 | 387.0 | 3.5x | 10x | yes |
| SyncAggregate.serialize | large-fixture | 160 | 5000000 | 27.6 | 21.3 | 1.3x | 5x | yes |
| SyncAggregate.serialize | medium-fixture | 160 | 5000000 | 27.4 | 20.7 | 1.3x | 5x | yes |
| SyncAggregate.serialize | small-fixture | 160 | 5000000 | 27.4 | 21.7 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | large-fixture | 16 | 5000000 | 13.6 | 11.0 | 1.2x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | medium-fixture | 16 | 5000000 | 13.8 | 10.9 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | small-fixture | 16 | 5000000 | 13.8 | 10.9 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.hash_tree_root | large-fixture | 16 | 1572864 | 266.4 | 100.5 | 2.7x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | medium-fixture | 16 | 1572864 | 265.8 | 100.6 | 2.6x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | small-fixture | 16 | 1572864 | 265.8 | 100.4 | 2.6x | 10x | yes |
| SyncAggregatorSelectionData.serialize | large-fixture | 16 | 5000000 | 5.8 | 12.5 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | medium-fixture | 16 | 5000000 | 5.8 | 12.5 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | small-fixture | 16 | 5000000 | 5.8 | 12.4 | 0.5x | 5x | yes |
| SyncCommittee.deserialize | large-fixture | 24624 | 253952 | 1075.0 | 1119.1 | 1.0x | 5x | yes |
| SyncCommittee.deserialize | medium-fixture | 24624 | 409600 | 1079.1 | 1194.7 | 0.9x | 5x | yes |
| SyncCommittee.deserialize | small-fixture | 24624 | 253952 | 1078.9 | 1247.0 | 0.9x | 5x | yes |
| SyncCommittee.hash_tree_root | large-fixture | 24624 | 1664 | 283052.9 | 81297.7 | 3.5x | 10x | yes |
| SyncCommittee.hash_tree_root | medium-fixture | 24624 | 1664 | 283653.8 | 81418.6 | 3.5x | 10x | yes |
| SyncCommittee.hash_tree_root | small-fixture | 24624 | 1664 | 283653.8 | 81044.6 | 3.5x | 10x | yes |
| SyncCommittee.serialize | large-fixture | 24624 | 253952 | 1063.2 | 1664.1 | 0.6x | 5x | yes |
| SyncCommittee.serialize | medium-fixture | 24624 | 409600 | 1064.5 | 1657.3 | 0.6x | 5x | yes |
| SyncCommittee.serialize | small-fixture | 24624 | 253952 | 1071.1 | 1648.9 | 0.6x | 5x | yes |
| SyncCommitteeContribution.deserialize | large-fixture | 160 | 5000000 | 94.6 | 36.3 | 2.6x | 5x | yes |
| SyncCommitteeContribution.deserialize | medium-fixture | 160 | 5000000 | 91.2 | 35.3 | 2.6x | 5x | yes |
| SyncCommitteeContribution.deserialize | small-fixture | 160 | 5000000 | 91.4 | 35.9 | 2.5x | 5x | yes |
| SyncCommitteeContribution.hash_tree_root | large-fixture | 160 | 204800 | 2402.3 | 650.7 | 3.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | medium-fixture | 160 | 204800 | 2446.3 | 664.0 | 3.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | small-fixture | 160 | 204800 | 2402.3 | 650.6 | 3.7x | 10x | yes |
| SyncCommitteeContribution.serialize | large-fixture | 160 | 5000000 | 28.6 | 21.8 | 1.3x | 5x | yes |
| SyncCommitteeContribution.serialize | medium-fixture | 160 | 5000000 | 28.8 | 22.2 | 1.3x | 5x | yes |
| SyncCommitteeContribution.serialize | small-fixture | 160 | 5000000 | 28.8 | 21.7 | 1.3x | 5x | yes |
| SyncCommitteeMessage.deserialize | large-fixture | 144 | 5000000 | 69.8 | 18.2 | 3.8x | 5x | yes |
| SyncCommitteeMessage.deserialize | medium-fixture | 144 | 5000000 | 70.8 | 18.8 | 3.8x | 5x | yes |
| SyncCommitteeMessage.deserialize | small-fixture | 144 | 5000000 | 70.0 | 18.9 | 3.7x | 5x | yes |
| SyncCommitteeMessage.hash_tree_root | large-fixture | 144 | 167936 | 1595.8 | 449.5 | 3.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | medium-fixture | 144 | 286720 | 1593.9 | 449.7 | 3.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | small-fixture | 144 | 286720 | 1593.9 | 449.3 | 3.5x | 10x | yes |
| SyncCommitteeMessage.serialize | large-fixture | 144 | 5000000 | 28.2 | 20.5 | 1.4x | 5x | yes |
| SyncCommitteeMessage.serialize | medium-fixture | 144 | 5000000 | 28.4 | 20.5 | 1.4x | 5x | yes |
| SyncCommitteeMessage.serialize | small-fixture | 144 | 5000000 | 28.2 | 21.6 | 1.3x | 5x | yes |
| Transaction.deserialize | large | 1048576 | 7936 | 53931.5 | 41154.1 | 1.3x | 5x | yes |
| Transaction.deserialize | medium | 4096 | 1572864 | 248.6 | 260.6 | 1.0x | 5x | yes |
| Transaction.deserialize | small | 32 | 5000000 | 17.4 | 27.5 | 0.6x | 5x | yes |
| Transaction.hash_tree_root | large | 1048576 | 54 | 8870370.4 | 2212646.8 | 4.0x | 10x | yes |
| Transaction.hash_tree_root | medium | 4096 | 8192 | 41259.8 | 10041.2 | 4.1x | 10x | yes |
| Transaction.hash_tree_root | small | 32 | 65536 | 6835.9 | 1913.0 | 3.6x | 10x | yes |
| Transaction.serialize | large | 1048576 | 8192 | 46020.5 | 41478.7 | 1.1x | 5x | yes |
| Transaction.serialize | medium | 4096 | 2097152 | 200.7 | 255.3 | 0.8x | 5x | yes |
| Transaction.serialize | small | 32 | 5000000 | 11.8 | 12.7 | 0.9x | 5x | yes |
| Validator.deserialize | large-fixture | 121 | 3670016 | 68.1 | 32.7 | 2.1x | 5x | yes |
| Validator.deserialize | medium-fixture | 121 | 3670016 | 68.1 | 32.6 | 2.1x | 5x | yes |
| Validator.deserialize | small-fixture | 121 | 5000000 | 68.2 | 32.0 | 2.1x | 5x | yes |
| Validator.hash_tree_root | large-fixture | 121 | 126976 | 2134.3 | 591.3 | 3.6x | 10x | yes |
| Validator.hash_tree_root | medium-fixture | 121 | 126976 | 2142.1 | 589.7 | 3.6x | 10x | yes |
| Validator.hash_tree_root | small-fixture | 121 | 126976 | 2142.1 | 590.6 | 3.6x | 10x | yes |
| Validator.serialize | large-fixture | 121 | 5000000 | 21.4 | 20.2 | 1.1x | 5x | yes |
| Validator.serialize | medium-fixture | 121 | 5000000 | 21.2 | 20.2 | 1.1x | 5x | yes |
| Validator.serialize | small-fixture | 121 | 5000000 | 21.6 | 19.7 | 1.1x | 5x | yes |
| ValidatorIndex.deserialize | random | 8 | 5000000 | 10.4 | 23.3 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | saturated | 8 | 5000000 | 11.0 | 26.1 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | zero | 8 | 5000000 | 10.4 | 23.2 | 0.4x | 5x | yes |
| ValidatorIndex.hash_tree_root | random | 8 | 5000000 | 3.6 | 135.0 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 169.2 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 133.2 | 0.0x | 10x | yes |
| ValidatorIndex.serialize | random | 8 | 5000000 | 5.4 | 8.1 | 0.7x | 5x | yes |
| ValidatorIndex.serialize | saturated | 8 | 5000000 | 5.8 | 8.7 | 0.7x | 5x | yes |
| ValidatorIndex.serialize | zero | 8 | 5000000 | 5.4 | 8.3 | 0.7x | 5x | yes |
| Version.deserialize | random | 4 | 5000000 | 4.8 | 24.4 | 0.2x | 5x | yes |
| Version.deserialize | saturated | 4 | 5000000 | 5.0 | 24.3 | 0.2x | 5x | yes |
| Version.deserialize | zero | 4 | 5000000 | 6.4 | 31.5 | 0.2x | 5x | yes |
| Version.hash_tree_root | random | 4 | 5000000 | 3.0 | 137.5 | 0.0x | 10x | yes |
| Version.hash_tree_root | saturated | 4 | 5000000 | 3.0 | 133.5 | 0.0x | 10x | yes |
| Version.hash_tree_root | zero | 4 | 5000000 | 3.0 | 140.9 | 0.0x | 10x | yes |
| Version.serialize | random | 4 | 5000000 | 4.8 | 8.2 | 0.6x | 5x | yes |
| Version.serialize | saturated | 4 | 5000000 | 4.6 | 7.9 | 0.6x | 5x | yes |
| Version.serialize | zero | 4 | 5000000 | 5.8 | 9.8 | 0.6x | 5x | yes |
| VersionedHash.deserialize | random | 32 | 5000000 | 21.2 | 27.1 | 0.8x | 5x | yes |
| VersionedHash.deserialize | saturated | 32 | 5000000 | 20.6 | 26.9 | 0.8x | 5x | yes |
| VersionedHash.deserialize | zero | 32 | 5000000 | 20.4 | 27.3 | 0.7x | 5x | yes |
| VersionedHash.hash_tree_root | random | 32 | 5000000 | 4.2 | 127.2 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | saturated | 32 | 5000000 | 4.2 | 128.0 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | zero | 32 | 5000000 | 4.2 | 131.4 | 0.0x | 10x | yes |
| VersionedHash.serialize | random | 32 | 5000000 | 7.4 | 12.8 | 0.6x | 5x | yes |
| VersionedHash.serialize | saturated | 32 | 5000000 | 7.4 | 12.6 | 0.6x | 5x | yes |
| VersionedHash.serialize | zero | 32 | 5000000 | 7.4 | 12.5 | 0.6x | 5x | yes |
| VoluntaryExit.deserialize | large-fixture | 16 | 5000000 | 16.4 | 10.9 | 1.5x | 5x | yes |
| VoluntaryExit.deserialize | medium-fixture | 16 | 5000000 | 16.2 | 10.8 | 1.5x | 5x | yes |
| VoluntaryExit.deserialize | small-fixture | 16 | 5000000 | 16.4 | 10.6 | 1.5x | 5x | yes |
| VoluntaryExit.hash_tree_root | large-fixture | 16 | 1572864 | 270.2 | 100.3 | 2.7x | 10x | yes |
| VoluntaryExit.hash_tree_root | medium-fixture | 16 | 1572864 | 269.6 | 100.4 | 2.7x | 10x | yes |
| VoluntaryExit.hash_tree_root | small-fixture | 16 | 1572864 | 269.6 | 100.5 | 2.7x | 10x | yes |
| VoluntaryExit.serialize | large-fixture | 16 | 5000000 | 6.8 | 12.7 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | medium-fixture | 16 | 5000000 | 6.8 | 12.4 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | small-fixture | 16 | 5000000 | 6.8 | 12.5 | 0.5x | 5x | yes |
| Withdrawal.deserialize | large-fixture | 44 | 5000000 | 29.8 | 12.8 | 2.3x | 5x | yes |
| Withdrawal.deserialize | medium-fixture | 44 | 5000000 | 30.0 | 13.1 | 2.3x | 5x | yes |
| Withdrawal.deserialize | small-fixture | 44 | 5000000 | 29.8 | 12.9 | 2.3x | 5x | yes |
| Withdrawal.hash_tree_root | large-fixture | 44 | 524288 | 799.2 | 244.0 | 3.3x | 10x | yes |
| Withdrawal.hash_tree_root | medium-fixture | 44 | 524288 | 797.3 | 243.6 | 3.3x | 10x | yes |
| Withdrawal.hash_tree_root | small-fixture | 44 | 507904 | 799.4 | 244.0 | 3.3x | 10x | yes |
| Withdrawal.serialize | large-fixture | 44 | 5000000 | 10.2 | 15.3 | 0.7x | 5x | yes |
| Withdrawal.serialize | medium-fixture | 44 | 5000000 | 10.2 | 14.9 | 0.7x | 5x | yes |
| Withdrawal.serialize | small-fixture | 44 | 5000000 | 10.2 | 15.1 | 0.7x | 5x | yes |
| WithdrawalIndex.deserialize | random | 8 | 5000000 | 12.6 | 23.0 | 0.5x | 5x | yes |
| WithdrawalIndex.deserialize | saturated | 8 | 5000000 | 13.0 | 23.4 | 0.6x | 5x | yes |
| WithdrawalIndex.deserialize | zero | 8 | 5000000 | 12.6 | 23.0 | 0.5x | 5x | yes |
| WithdrawalIndex.hash_tree_root | random | 8 | 5000000 | 3.8 | 144.1 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 134.3 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 138.1 | 0.0x | 10x | yes |
| WithdrawalIndex.serialize | random | 8 | 5000000 | 6.2 | 8.1 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | saturated | 8 | 5000000 | 6.2 | 8.0 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | zero | 8 | 5000000 | 6.2 | 8.1 | 0.8x | 5x | yes |
| WithdrawalRequest.deserialize | large-fixture | 76 | 5000000 | 34.2 | 14.6 | 2.3x | 5x | yes |
| WithdrawalRequest.deserialize | medium-fixture | 76 | 5000000 | 34.2 | 15.0 | 2.3x | 5x | yes |
| WithdrawalRequest.deserialize | small-fixture | 76 | 5000000 | 34.2 | 14.7 | 2.3x | 5x | yes |
| WithdrawalRequest.hash_tree_root | large-fixture | 76 | 253952 | 1059.3 | 317.5 | 3.3x | 10x | yes |
| WithdrawalRequest.hash_tree_root | medium-fixture | 76 | 253952 | 1059.3 | 317.5 | 3.3x | 10x | yes |
| WithdrawalRequest.hash_tree_root | small-fixture | 76 | 409600 | 1059.6 | 317.3 | 3.3x | 10x | yes |
| WithdrawalRequest.serialize | large-fixture | 76 | 5000000 | 15.0 | 16.3 | 0.9x | 5x | yes |
| WithdrawalRequest.serialize | medium-fixture | 76 | 5000000 | 15.0 | 16.3 | 0.9x | 5x | yes |
| WithdrawalRequest.serialize | small-fixture | 76 | 5000000 | 15.2 | 16.3 | 0.9x | 5x | yes |
| boolean.deserialize | false | 1 | 5000000 | 4.6 | 22.9 | 0.2x | 5x | yes |
| boolean.deserialize | true | 1 | 5000000 | 4.4 | 23.6 | 0.2x | 5x | yes |
| boolean.hash_tree_root | false | 1 | 5000000 | 3.0 | 143.1 | 0.0x | 10x | yes |
| boolean.hash_tree_root | true | 1 | 5000000 | 3.0 | 136.9 | 0.0x | 10x | yes |
| boolean.serialize | false | 1 | 5000000 | 4.4 | 7.5 | 0.6x | 5x | yes |
| boolean.serialize | true | 1 | 5000000 | 4.8 | 7.7 | 0.6x | 5x | yes |
| uint256.deserialize | random | 32 | 5000000 | 19.0 | 27.3 | 0.7x | 5x | yes |
| uint256.deserialize | saturated | 32 | 5000000 | 17.2 | 27.0 | 0.6x | 5x | yes |
| uint256.deserialize | zero | 32 | 5000000 | 19.0 | 27.4 | 0.7x | 5x | yes |
| uint256.hash_tree_root | random | 32 | 5000000 | 4.0 | 124.4 | 0.0x | 10x | yes |
| uint256.hash_tree_root | saturated | 32 | 5000000 | 4.0 | 128.9 | 0.0x | 10x | yes |
| uint256.hash_tree_root | zero | 32 | 5000000 | 4.0 | 127.2 | 0.0x | 10x | yes |
| uint256.serialize | random | 32 | 5000000 | 6.4 | 12.5 | 0.5x | 5x | yes |
| uint256.serialize | saturated | 32 | 5000000 | 6.4 | 12.5 | 0.5x | 5x | yes |
| uint256.serialize | zero | 32 | 5000000 | 6.4 | 12.4 | 0.5x | 5x | yes |
| uint32.deserialize | random | 4 | 5000000 | 5.2 | 24.2 | 0.2x | 5x | yes |
| uint32.deserialize | saturated | 4 | 5000000 | 5.2 | 24.3 | 0.2x | 5x | yes |
| uint32.deserialize | zero | 4 | 5000000 | 5.2 | 24.1 | 0.2x | 5x | yes |
| uint32.hash_tree_root | random | 4 | 5000000 | 3.2 | 137.5 | 0.0x | 10x | yes |
| uint32.hash_tree_root | saturated | 4 | 5000000 | 3.2 | 141.0 | 0.0x | 10x | yes |
| uint32.hash_tree_root | zero | 4 | 5000000 | 3.2 | 133.7 | 0.0x | 10x | yes |
| uint32.serialize | random | 4 | 5000000 | 5.0 | 8.1 | 0.6x | 5x | yes |
| uint32.serialize | saturated | 4 | 5000000 | 5.0 | 8.0 | 0.6x | 5x | yes |
| uint32.serialize | zero | 4 | 5000000 | 5.0 | 8.2 | 0.6x | 5x | yes |
| uint64.deserialize | random | 8 | 5000000 | 12.8 | 23.4 | 0.5x | 5x | yes |
| uint64.deserialize | saturated | 8 | 5000000 | 12.8 | 23.4 | 0.5x | 5x | yes |
| uint64.deserialize | zero | 8 | 5000000 | 12.6 | 23.2 | 0.5x | 5x | yes |
| uint64.hash_tree_root | random | 8 | 5000000 | 3.6 | 137.9 | 0.0x | 10x | yes |
| uint64.hash_tree_root | saturated | 8 | 5000000 | 3.4 | 134.7 | 0.0x | 10x | yes |
| uint64.hash_tree_root | zero | 8 | 5000000 | 3.4 | 137.0 | 0.0x | 10x | yes |
| uint64.serialize | random | 8 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| uint64.serialize | saturated | 8 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| uint64.serialize | zero | 8 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| uint8.deserialize | random | 1 | 5000000 | 6.0 | 23.2 | 0.3x | 5x | yes |
| uint8.deserialize | saturated | 1 | 5000000 | 6.0 | 23.1 | 0.3x | 5x | yes |
| uint8.deserialize | zero | 1 | 5000000 | 6.0 | 23.1 | 0.3x | 5x | yes |
| uint8.hash_tree_root | random | 1 | 5000000 | 3.0 | 135.9 | 0.0x | 10x | yes |
| uint8.hash_tree_root | saturated | 1 | 5000000 | 3.0 | 134.7 | 0.0x | 10x | yes |
| uint8.hash_tree_root | zero | 1 | 5000000 | 3.0 | 134.7 | 0.0x | 10x | yes |
| uint8.serialize | random | 1 | 5000000 | 4.8 | 7.7 | 0.6x | 5x | yes |
| uint8.serialize | saturated | 1 | 5000000 | 4.8 | 7.5 | 0.6x | 5x | yes |
| uint8.serialize | zero | 1 | 5000000 | 4.8 | 7.4 | 0.6x | 5x | yes |

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
