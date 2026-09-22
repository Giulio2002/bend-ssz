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
| serialize | `X_encode(o)`: fresh canonical bytes from the object, after one untimed decode; every encoding is consumed | `MarshalSSZ` after one untimed decode |
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
bytes (Bend: decode, then `X_encode` compared byte for byte) and agree on the
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
| bend_compiler | bend 2.0.16 |
| reference_compiler | go version go1.25.5 darwin/arm64 |
| bend_flags | --threads 1 --gpu off (native C backend, release build) |
| reference_flags | go build (release defaults), GOMAXPROCS=1 |
| reference_revision | go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod) |

## Result against the frozen contract

* 978 measured workloads covering 327 of the 327 required operations.
* 938 of 978 workloads are within their operation limit (deserialize/serialize 5x, hash_tree_root 10x).

Ratio distribution over all measured workloads: minimum 0.0x, median 1.6x, maximum 8.4x.

* `deserialize`: 326 workloads, minimum 0.2x, median 1.6x, maximum 5.7x (limit 5x).
* `serialize`: 326 workloads, minimum 0.4x, median 1.1x, maximum 8.4x (limit 5x).
* `hash_tree_root`: 326 workloads, minimum 0.0x, median 3.2x, maximum 5.9x (limit 10x).

## What the numbers say

40 workloads exceed their limit. By operation:

* `deserialize`: 4 over the limit; worst: BlobSidecar large-fixture 5.7x, Transaction large 5.6x, ExecutionPayloadHeader medium-fixture 5.1x, ExecutionPayload large-fixture 5.1x.
* `serialize`: 36 over the limit; worst: SignedBeaconBlock medium-fixture 8.4x, BeaconBlock large-fixture 7.5x, SignedBeaconBlock small-fixture 7.3x, BeaconBlock small-fixture 7.3x, SignedBeaconBlock large-fixture 7.2x, BeaconBlockBody medium-fixture 7.1x.
* `hash_tree_root`: none over the limit.

## All measured workloads

| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |
|---|---|---:|---:|---:|---:|---:|---:|:--:|
| AggregateAndProof.deserialize | large-fixture | 346 | 1572864 | 272.8 | 107.7 | 2.5x | 5x | yes |
| AggregateAndProof.deserialize | medium-fixture | 345 | 1572864 | 270.2 | 108.4 | 2.5x | 5x | yes |
| AggregateAndProof.deserialize | small-fixture | 345 | 1572864 | 291.2 | 114.8 | 2.5x | 5x | yes |
| AggregateAndProof.hash_tree_root | large-fixture | 346 | 57344 | 8091.5 | 2126.7 | 3.8x | 10x | yes |
| AggregateAndProof.hash_tree_root | medium-fixture | 345 | 81920 | 5712.9 | 1521.5 | 3.8x | 10x | yes |
| AggregateAndProof.hash_tree_root | small-fixture | 345 | 57344 | 8126.4 | 2120.7 | 3.8x | 10x | yes |
| AggregateAndProof.serialize | large-fixture | 346 | 2097152 | 203.6 | 40.3 | 5.0x | 5x | no |
| AggregateAndProof.serialize | medium-fixture | 345 | 2097152 | 194.5 | 38.6 | 5.0x | 5x | no |
| AggregateAndProof.serialize | small-fixture | 345 | 2097152 | 198.4 | 40.4 | 4.9x | 5x | yes |
| Attestation.deserialize | large-fixture | 237 | 2097152 | 206.0 | 86.8 | 2.4x | 5x | yes |
| Attestation.deserialize | medium-fixture | 237 | 2097152 | 207.4 | 86.3 | 2.4x | 5x | yes |
| Attestation.deserialize | small-fixture | 237 | 2097152 | 206.5 | 87.0 | 2.4x | 5x | yes |
| Attestation.hash_tree_root | large-fixture | 237 | 73728 | 6442.6 | 1703.0 | 3.8x | 10x | yes |
| Attestation.hash_tree_root | medium-fixture | 237 | 73728 | 6442.6 | 1701.3 | 3.8x | 10x | yes |
| Attestation.hash_tree_root | small-fixture | 237 | 73728 | 6442.6 | 1100.1 | 5.9x | 10x | yes |
| Attestation.serialize | large-fixture | 237 | 3145728 | 147.2 | 30.8 | 4.8x | 5x | yes |
| Attestation.serialize | medium-fixture | 237 | 3145728 | 146.9 | 31.3 | 4.7x | 5x | yes |
| Attestation.serialize | small-fixture | 237 | 3145728 | 147.5 | 29.5 | 5.0x | 5x | no |
| AttestationData.deserialize | large-fixture | 128 | 5000000 | 83.4 | 38.1 | 2.2x | 5x | yes |
| AttestationData.deserialize | medium-fixture | 128 | 5000000 | 82.8 | 38.5 | 2.1x | 5x | yes |
| AttestationData.deserialize | small-fixture | 128 | 5000000 | 83.0 | 38.7 | 2.1x | 5x | yes |
| AttestationData.hash_tree_root | large-fixture | 128 | 221184 | 2138.5 | 600.3 | 3.6x | 10x | yes |
| AttestationData.hash_tree_root | medium-fixture | 128 | 126976 | 2142.1 | 600.6 | 3.6x | 10x | yes |
| AttestationData.hash_tree_root | small-fixture | 128 | 221184 | 2138.5 | 600.4 | 3.6x | 10x | yes |
| AttestationData.serialize | large-fixture | 128 | 5000000 | 27.2 | 19.2 | 1.4x | 5x | yes |
| AttestationData.serialize | medium-fixture | 128 | 5000000 | 27.2 | 19.4 | 1.4x | 5x | yes |
| AttestationData.serialize | small-fixture | 128 | 5000000 | 27.2 | 19.5 | 1.4x | 5x | yes |
| AttesterSlashing.deserialize | large-fixture | 624 | 1048576 | 464.4 | 175.1 | 2.7x | 5x | yes |
| AttesterSlashing.deserialize | medium-fixture | 552 | 1048576 | 453.0 | 170.5 | 2.7x | 5x | yes |
| AttesterSlashing.deserialize | small-fixture | 512 | 1048576 | 443.5 | 164.0 | 2.7x | 5x | yes |
| AttesterSlashing.hash_tree_root | large-fixture | 624 | 24576 | 16805.0 | 4413.0 | 3.8x | 10x | yes |
| AttesterSlashing.hash_tree_root | medium-fixture | 552 | 24576 | 16479.5 | 4258.7 | 3.9x | 10x | yes |
| AttesterSlashing.hash_tree_root | small-fixture | 512 | 24576 | 16235.4 | 4246.9 | 3.8x | 10x | yes |
| AttesterSlashing.serialize | large-fixture | 624 | 1572864 | 287.4 | 69.4 | 4.1x | 5x | yes |
| AttesterSlashing.serialize | medium-fixture | 552 | 1572864 | 285.5 | 61.6 | 4.6x | 5x | yes |
| AttesterSlashing.serialize | small-fixture | 512 | 1572864 | 242.2 | 55.5 | 4.4x | 5x | yes |
| BLSPubkey.deserialize | random | 48 | 5000000 | 30.4 | 28.0 | 1.1x | 5x | yes |
| BLSPubkey.deserialize | saturated | 48 | 5000000 | 32.0 | 27.9 | 1.1x | 5x | yes |
| BLSPubkey.deserialize | zero | 48 | 5000000 | 32.0 | 28.0 | 1.1x | 5x | yes |
| BLSPubkey.hash_tree_root | random | 48 | 1572864 | 274.0 | 227.1 | 1.2x | 10x | yes |
| BLSPubkey.hash_tree_root | saturated | 48 | 1572864 | 274.7 | 222.6 | 1.2x | 10x | yes |
| BLSPubkey.hash_tree_root | zero | 48 | 1572864 | 274.0 | 226.0 | 1.2x | 10x | yes |
| BLSPubkey.serialize | random | 48 | 5000000 | 12.6 | 13.2 | 1.0x | 5x | yes |
| BLSPubkey.serialize | saturated | 48 | 5000000 | 12.6 | 13.4 | 0.9x | 5x | yes |
| BLSPubkey.serialize | zero | 48 | 5000000 | 12.0 | 13.6 | 0.9x | 5x | yes |
| BLSSignature.deserialize | random | 96 | 5000000 | 48.4 | 30.4 | 1.6x | 5x | yes |
| BLSSignature.deserialize | saturated | 96 | 5000000 | 48.6 | 30.4 | 1.6x | 5x | yes |
| BLSSignature.deserialize | zero | 96 | 5000000 | 48.0 | 30.7 | 1.6x | 5x | yes |
| BLSSignature.hash_tree_root | random | 96 | 524288 | 808.7 | 371.1 | 2.2x | 10x | yes |
| BLSSignature.hash_tree_root | saturated | 96 | 524288 | 808.7 | 366.1 | 2.2x | 10x | yes |
| BLSSignature.hash_tree_root | zero | 96 | 524288 | 810.6 | 366.2 | 2.2x | 10x | yes |
| BLSSignature.serialize | random | 96 | 5000000 | 17.0 | 15.6 | 1.1x | 5x | yes |
| BLSSignature.serialize | saturated | 96 | 5000000 | 17.0 | 15.8 | 1.1x | 5x | yes |
| BLSSignature.serialize | zero | 96 | 5000000 | 16.6 | 15.7 | 1.1x | 5x | yes |
| BLSToExecutionChange.deserialize | large-fixture | 76 | 5000000 | 43.2 | 14.5 | 3.0x | 5x | yes |
| BLSToExecutionChange.deserialize | medium-fixture | 76 | 5000000 | 43.0 | 14.2 | 3.0x | 5x | yes |
| BLSToExecutionChange.deserialize | small-fixture | 76 | 5000000 | 43.2 | 14.5 | 3.0x | 5x | yes |
| BLSToExecutionChange.hash_tree_root | large-fixture | 76 | 409600 | 1071.8 | 317.2 | 3.4x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | medium-fixture | 76 | 253952 | 1071.1 | 317.8 | 3.4x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | small-fixture | 76 | 409600 | 1069.3 | 317.5 | 3.4x | 10x | yes |
| BLSToExecutionChange.serialize | large-fixture | 76 | 5000000 | 18.2 | 16.2 | 1.1x | 5x | yes |
| BLSToExecutionChange.serialize | medium-fixture | 76 | 5000000 | 18.2 | 15.9 | 1.1x | 5x | yes |
| BLSToExecutionChange.serialize | small-fixture | 76 | 5000000 | 18.2 | 16.3 | 1.1x | 5x | yes |
| BeaconBlock.deserialize | large-fixture | 21487 | 16384 | 25024.4 | 9595.6 | 2.6x | 5x | yes |
| BeaconBlock.deserialize | medium-fixture | 21424 | 24576 | 20182.3 | 8412.4 | 2.4x | 5x | yes |
| BeaconBlock.deserialize | small-fixture | 11198 | 32768 | 12329.1 | 2540.1 | 4.9x | 5x | yes |
| BeaconBlock.hash_tree_root | large-fixture | 21487 | 1536 | 297526.0 | 75162.5 | 4.0x | 10x | yes |
| BeaconBlock.hash_tree_root | medium-fixture | 21424 | 1280 | 320312.5 | 78886.3 | 4.1x | 10x | yes |
| BeaconBlock.hash_tree_root | small-fixture | 11198 | 2048 | 209960.9 | 53708.3 | 3.9x | 10x | yes |
| BeaconBlock.serialize | large-fixture | 21487 | 40960 | 10205.1 | 1355.5 | 7.5x | 5x | no |
| BeaconBlock.serialize | medium-fixture | 21424 | 49152 | 9643.6 | 1417.6 | 6.8x | 5x | no |
| BeaconBlock.serialize | small-fixture | 11198 | 40960 | 6176.8 | 851.5 | 7.3x | 5x | no |
| BeaconBlockBody.deserialize | large-fixture | 24042 | 16384 | 24902.3 | 9011.4 | 2.8x | 5x | yes |
| BeaconBlockBody.deserialize | medium-fixture | 19087 | 24576 | 16805.0 | 6247.4 | 2.7x | 5x | yes |
| BeaconBlockBody.deserialize | small-fixture | 11894 | 40960 | 11547.9 | 4368.5 | 2.6x | 5x | yes |
| BeaconBlockBody.hash_tree_root | large-fixture | 24042 | 1152 | 372395.8 | 91526.5 | 4.1x | 10x | yes |
| BeaconBlockBody.hash_tree_root | medium-fixture | 19087 | 1536 | 302734.4 | 76296.6 | 4.0x | 10x | yes |
| BeaconBlockBody.hash_tree_root | small-fixture | 11894 | 2048 | 219726.6 | 54998.1 | 4.0x | 10x | yes |
| BeaconBlockBody.serialize | large-fixture | 24042 | 40960 | 10913.1 | 1666.2 | 6.5x | 5x | no |
| BeaconBlockBody.serialize | medium-fixture | 19087 | 49152 | 8707.7 | 1226.4 | 7.1x | 5x | no |
| BeaconBlockBody.serialize | small-fixture | 11894 | 81920 | 5481.0 | 864.3 | 6.3x | 5x | no |
| BeaconBlockHeader.deserialize | large-fixture | 112 | 5000000 | 54.2 | 16.3 | 3.3x | 5x | yes |
| BeaconBlockHeader.deserialize | medium-fixture | 112 | 5000000 | 54.8 | 15.8 | 3.5x | 5x | yes |
| BeaconBlockHeader.deserialize | small-fixture | 112 | 5000000 | 54.4 | 16.0 | 3.4x | 5x | yes |
| BeaconBlockHeader.hash_tree_root | large-fixture | 112 | 143360 | 1639.2 | 449.1 | 3.6x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | medium-fixture | 112 | 253952 | 1602.7 | 444.4 | 3.6x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | small-fixture | 112 | 286720 | 1600.9 | 442.9 | 3.6x | 10x | yes |
| BeaconBlockHeader.serialize | large-fixture | 112 | 5000000 | 23.6 | 19.4 | 1.2x | 5x | yes |
| BeaconBlockHeader.serialize | medium-fixture | 112 | 5000000 | 23.6 | 19.7 | 1.2x | 5x | yes |
| BeaconBlockHeader.serialize | small-fixture | 112 | 5000000 | 21.8 | 17.9 | 1.2x | 5x | yes |
| BeaconState.deserialize | large-fixture | 2741095 | 768 | 678385.4 | 215305.9 | 3.2x | 5x | yes |
| BeaconState.deserialize | medium-fixture | 2740473 | 768 | 640625.0 | 210458.5 | 3.0x | 5x | yes |
| BeaconState.deserialize | small-fixture | 2738771 | 768 | 639322.9 | 207637.9 | 3.1x | 5x | yes |
| BeaconState.hash_tree_root | large-fixture | 2741095 | 9 | 27444444.4 | 7742932.8 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | medium-fixture | 2740473 | 20 | 23450000.0 | 6754050.9 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | small-fixture | 2738771 | 20 | 23350000.0 | 6758757.9 | 3.5x | 10x | yes |
| BeaconState.serialize | large-fixture | 2741095 | 896 | 494419.6 | 194817.2 | 2.5x | 5x | yes |
| BeaconState.serialize | medium-fixture | 2740473 | 896 | 493303.6 | 190277.0 | 2.6x | 5x | yes |
| BeaconState.serialize | small-fixture | 2738771 | 896 | 493303.6 | 191254.6 | 2.6x | 5x | yes |
| Blob.deserialize | random | 131072 | 16384 | 27465.8 | 5808.5 | 4.7x | 5x | yes |
| Blob.deserialize | saturated | 131072 | 16384 | 26550.3 | 5718.8 | 4.6x | 5x | yes |
| Blob.deserialize | zero | 131072 | 16384 | 28442.4 | 5811.7 | 4.9x | 5x | yes |
| Blob.hash_tree_root | random | 131072 | 384 | 1106770.8 | 283810.6 | 3.9x | 10x | yes |
| Blob.hash_tree_root | saturated | 131072 | 384 | 1106770.8 | 282883.4 | 3.9x | 10x | yes |
| Blob.hash_tree_root | zero | 131072 | 384 | 1106770.8 | 284035.6 | 3.9x | 10x | yes |
| Blob.serialize | random | 131072 | 24576 | 18473.3 | 4558.9 | 4.1x | 5x | yes |
| Blob.serialize | saturated | 131072 | 24576 | 20019.5 | 6287.0 | 3.2x | 5x | yes |
| Blob.serialize | zero | 131072 | 24576 | 18432.6 | 6101.0 | 3.0x | 5x | yes |
| BlobIdentifier.deserialize | large-fixture | 40 | 5000000 | 29.2 | 12.6 | 2.3x | 5x | yes |
| BlobIdentifier.deserialize | medium-fixture | 40 | 5000000 | 29.2 | 13.0 | 2.2x | 5x | yes |
| BlobIdentifier.deserialize | small-fixture | 40 | 5000000 | 29.2 | 12.9 | 2.3x | 5x | yes |
| BlobIdentifier.hash_tree_root | large-fixture | 40 | 1572864 | 278.5 | 102.1 | 2.7x | 10x | yes |
| BlobIdentifier.hash_tree_root | medium-fixture | 40 | 1572864 | 275.9 | 100.9 | 2.7x | 10x | yes |
| BlobIdentifier.hash_tree_root | small-fixture | 40 | 1572864 | 274.0 | 100.7 | 2.7x | 10x | yes |
| BlobIdentifier.serialize | large-fixture | 40 | 5000000 | 11.8 | 15.8 | 0.7x | 5x | yes |
| BlobIdentifier.serialize | medium-fixture | 40 | 5000000 | 12.2 | 15.9 | 0.8x | 5x | yes |
| BlobIdentifier.serialize | small-fixture | 40 | 5000000 | 11.0 | 14.7 | 0.8x | 5x | yes |
| BlobIndex.deserialize | random | 8 | 5000000 | 16.6 | 28.5 | 0.6x | 5x | yes |
| BlobIndex.deserialize | saturated | 8 | 5000000 | 16.6 | 28.7 | 0.6x | 5x | yes |
| BlobIndex.deserialize | zero | 8 | 5000000 | 13.8 | 23.2 | 0.6x | 5x | yes |
| BlobIndex.hash_tree_root | random | 8 | 5000000 | 6.0 | 155.7 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | saturated | 8 | 5000000 | 6.4 | 168.3 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | zero | 8 | 5000000 | 5.8 | 160.2 | 0.0x | 10x | yes |
| BlobIndex.serialize | random | 8 | 5000000 | 7.6 | 9.6 | 0.8x | 5x | yes |
| BlobIndex.serialize | saturated | 8 | 5000000 | 8.0 | 10.1 | 0.8x | 5x | yes |
| BlobIndex.serialize | zero | 8 | 5000000 | 7.0 | 8.4 | 0.8x | 5x | yes |
| BlobSidecar.deserialize | large-fixture | 131928 | 16384 | 26611.3 | 4684.0 | 5.7x | 5x | no |
| BlobSidecar.deserialize | medium-fixture | 131928 | 16384 | 26794.4 | 6262.9 | 4.3x | 5x | yes |
| BlobSidecar.deserialize | small-fixture | 131928 | 8192 | 28686.5 | 6134.1 | 4.7x | 5x | yes |
| BlobSidecar.hash_tree_root | large-fixture | 131928 | 384 | 1111979.2 | 274397.2 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | medium-fixture | 131928 | 384 | 1114583.3 | 274741.8 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | small-fixture | 131928 | 384 | 1117187.5 | 274650.2 | 4.1x | 10x | yes |
| BlobSidecar.serialize | large-fixture | 131928 | 16384 | 29052.7 | 4843.4 | 6.0x | 5x | no |
| BlobSidecar.serialize | medium-fixture | 131928 | 16384 | 28869.6 | 4831.9 | 6.0x | 5x | no |
| BlobSidecar.serialize | small-fixture | 131928 | 16384 | 28564.5 | 4754.2 | 6.0x | 5x | no |
| Bytes1.deserialize | random | 1 | 5000000 | 5.6 | 27.3 | 0.2x | 5x | yes |
| Bytes1.deserialize | saturated | 1 | 5000000 | 5.4 | 26.7 | 0.2x | 5x | yes |
| Bytes1.deserialize | zero | 1 | 5000000 | 4.6 | 23.0 | 0.2x | 5x | yes |
| Bytes1.hash_tree_root | random | 1 | 5000000 | 5.8 | 157.1 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | saturated | 1 | 5000000 | 5.8 | 160.3 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | zero | 1 | 5000000 | 5.4 | 152.2 | 0.0x | 10x | yes |
| Bytes1.serialize | random | 1 | 5000000 | 7.0 | 9.3 | 0.8x | 5x | yes |
| Bytes1.serialize | saturated | 1 | 5000000 | 6.6 | 8.9 | 0.7x | 5x | yes |
| Bytes1.serialize | zero | 1 | 5000000 | 5.8 | 7.7 | 0.8x | 5x | yes |
| Bytes20.deserialize | random | 20 | 5000000 | 19.0 | 31.7 | 0.6x | 5x | yes |
| Bytes20.deserialize | saturated | 20 | 5000000 | 18.6 | 31.3 | 0.6x | 5x | yes |
| Bytes20.deserialize | zero | 20 | 5000000 | 18.6 | 31.2 | 0.6x | 5x | yes |
| Bytes20.hash_tree_root | random | 20 | 5000000 | 6.0 | 165.5 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | saturated | 20 | 5000000 | 6.0 | 159.1 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | zero | 20 | 5000000 | 5.8 | 165.7 | 0.0x | 10x | yes |
| Bytes20.serialize | random | 20 | 5000000 | 8.6 | 14.8 | 0.6x | 5x | yes |
| Bytes20.serialize | saturated | 20 | 5000000 | 8.8 | 14.8 | 0.6x | 5x | yes |
| Bytes20.serialize | zero | 20 | 5000000 | 9.0 | 15.0 | 0.6x | 5x | yes |
| Bytes32.deserialize | random | 32 | 5000000 | 25.2 | 31.5 | 0.8x | 5x | yes |
| Bytes32.deserialize | saturated | 32 | 5000000 | 25.2 | 32.3 | 0.8x | 5x | yes |
| Bytes32.deserialize | zero | 32 | 5000000 | 24.0 | 31.5 | 0.8x | 5x | yes |
| Bytes32.hash_tree_root | random | 32 | 5000000 | 6.0 | 139.8 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | saturated | 32 | 5000000 | 6.0 | 147.3 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | zero | 32 | 5000000 | 6.0 | 145.9 | 0.0x | 10x | yes |
| Bytes32.serialize | random | 32 | 5000000 | 10.6 | 14.3 | 0.7x | 5x | yes |
| Bytes32.serialize | saturated | 32 | 5000000 | 10.8 | 14.5 | 0.7x | 5x | yes |
| Bytes32.serialize | zero | 32 | 5000000 | 9.6 | 14.6 | 0.7x | 5x | yes |
| Bytes4.deserialize | random | 4 | 5000000 | 5.4 | 28.1 | 0.2x | 5x | yes |
| Bytes4.deserialize | saturated | 4 | 5000000 | 5.4 | 29.9 | 0.2x | 5x | yes |
| Bytes4.deserialize | zero | 4 | 5000000 | 5.2 | 27.8 | 0.2x | 5x | yes |
| Bytes4.hash_tree_root | random | 4 | 5000000 | 5.8 | 158.1 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | saturated | 4 | 5000000 | 6.8 | 186.6 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | zero | 4 | 5000000 | 5.8 | 161.8 | 0.0x | 10x | yes |
| Bytes4.serialize | random | 4 | 5000000 | 6.4 | 9.1 | 0.7x | 5x | yes |
| Bytes4.serialize | saturated | 4 | 5000000 | 7.8 | 11.3 | 0.7x | 5x | yes |
| Bytes4.serialize | zero | 4 | 5000000 | 6.4 | 9.4 | 0.7x | 5x | yes |
| Bytes48.deserialize | random | 48 | 5000000 | 30.4 | 31.3 | 1.0x | 5x | yes |
| Bytes48.deserialize | saturated | 48 | 5000000 | 28.6 | 30.7 | 0.9x | 5x | yes |
| Bytes48.deserialize | zero | 48 | 5000000 | 29.6 | 32.3 | 0.9x | 5x | yes |
| Bytes48.hash_tree_root | random | 48 | 1048576 | 304.2 | 243.3 | 1.3x | 10x | yes |
| Bytes48.hash_tree_root | saturated | 48 | 1048576 | 305.2 | 248.5 | 1.2x | 10x | yes |
| Bytes48.hash_tree_root | zero | 48 | 1572864 | 298.8 | 250.5 | 1.2x | 10x | yes |
| Bytes48.serialize | random | 48 | 5000000 | 15.8 | 16.1 | 1.0x | 5x | yes |
| Bytes48.serialize | saturated | 48 | 5000000 | 15.6 | 16.5 | 0.9x | 5x | yes |
| Bytes48.serialize | zero | 48 | 5000000 | 14.4 | 15.3 | 0.9x | 5x | yes |
| Bytes8.deserialize | random | 8 | 5000000 | 13.2 | 29.5 | 0.4x | 5x | yes |
| Bytes8.deserialize | saturated | 8 | 5000000 | 13.6 | 28.9 | 0.5x | 5x | yes |
| Bytes8.deserialize | zero | 8 | 5000000 | 12.6 | 27.3 | 0.5x | 5x | yes |
| Bytes8.hash_tree_root | random | 8 | 5000000 | 6.0 | 162.2 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | saturated | 8 | 5000000 | 6.0 | 155.9 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | zero | 8 | 5000000 | 6.6 | 162.9 | 0.0x | 10x | yes |
| Bytes8.serialize | random | 8 | 5000000 | 8.8 | 10.1 | 0.9x | 5x | yes |
| Bytes8.serialize | saturated | 8 | 5000000 | 8.8 | 9.7 | 0.9x | 5x | yes |
| Bytes8.serialize | zero | 8 | 5000000 | 9.2 | 10.5 | 0.9x | 5x | yes |
| Bytes96.deserialize | random | 96 | 4980736 | 53.4 | 34.6 | 1.5x | 5x | yes |
| Bytes96.deserialize | saturated | 96 | 5000000 | 54.4 | 34.1 | 1.6x | 5x | yes |
| Bytes96.deserialize | zero | 96 | 5000000 | 56.0 | 35.7 | 1.6x | 5x | yes |
| Bytes96.hash_tree_root | random | 96 | 507904 | 858.4 | 397.3 | 2.2x | 10x | yes |
| Bytes96.hash_tree_root | saturated | 96 | 507904 | 848.6 | 385.0 | 2.2x | 10x | yes |
| Bytes96.hash_tree_root | zero | 96 | 507904 | 874.2 | 401.6 | 2.2x | 10x | yes |
| Bytes96.serialize | random | 96 | 5000000 | 21.0 | 18.4 | 1.1x | 5x | yes |
| Bytes96.serialize | saturated | 96 | 5000000 | 22.0 | 19.0 | 1.2x | 5x | yes |
| Bytes96.serialize | zero | 96 | 5000000 | 20.0 | 18.4 | 1.1x | 5x | yes |
| Cell.deserialize | random | 2048 | 524288 | 572.2 | 180.8 | 3.2x | 5x | yes |
| Cell.deserialize | saturated | 2048 | 524288 | 621.8 | 182.1 | 3.4x | 5x | yes |
| Cell.deserialize | zero | 2048 | 524288 | 593.2 | 176.6 | 3.4x | 5x | yes |
| Cell.hash_tree_root | random | 2048 | 24576 | 17374.7 | 4650.6 | 3.7x | 10x | yes |
| Cell.hash_tree_root | saturated | 2048 | 24576 | 17089.8 | 4623.7 | 3.7x | 10x | yes |
| Cell.hash_tree_root | zero | 2048 | 24576 | 17537.4 | 4736.2 | 3.7x | 10x | yes |
| Cell.serialize | random | 2048 | 1048576 | 419.6 | 152.0 | 2.8x | 5x | yes |
| Cell.serialize | saturated | 2048 | 1048576 | 420.6 | 153.2 | 2.7x | 5x | yes |
| Cell.serialize | zero | 2048 | 1048576 | 410.1 | 148.2 | 2.8x | 5x | yes |
| CellIndex.deserialize | random | 8 | 5000000 | 16.2 | 27.0 | 0.6x | 5x | yes |
| CellIndex.deserialize | saturated | 8 | 5000000 | 16.0 | 27.0 | 0.6x | 5x | yes |
| CellIndex.deserialize | zero | 8 | 5000000 | 14.8 | 25.1 | 0.6x | 5x | yes |
| CellIndex.hash_tree_root | random | 8 | 5000000 | 6.0 | 157.2 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | saturated | 8 | 5000000 | 6.0 | 175.5 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | zero | 8 | 5000000 | 6.0 | 164.1 | 0.0x | 10x | yes |
| CellIndex.serialize | random | 8 | 5000000 | 7.0 | 9.5 | 0.7x | 5x | yes |
| CellIndex.serialize | saturated | 8 | 5000000 | 7.0 | 9.5 | 0.7x | 5x | yes |
| CellIndex.serialize | zero | 8 | 5000000 | 7.8 | 10.6 | 0.7x | 5x | yes |
| Checkpoint.deserialize | large-fixture | 40 | 5000000 | 31.0 | 14.0 | 2.2x | 5x | yes |
| Checkpoint.deserialize | medium-fixture | 40 | 5000000 | 29.6 | 13.0 | 2.3x | 5x | yes |
| Checkpoint.deserialize | small-fixture | 40 | 5000000 | 33.6 | 14.9 | 2.3x | 5x | yes |
| Checkpoint.hash_tree_root | large-fixture | 40 | 1048576 | 284.2 | 107.3 | 2.6x | 10x | yes |
| Checkpoint.hash_tree_root | medium-fixture | 40 | 1572864 | 288.0 | 107.5 | 2.7x | 10x | yes |
| Checkpoint.hash_tree_root | small-fixture | 40 | 1572864 | 274.7 | 101.3 | 2.7x | 10x | yes |
| Checkpoint.serialize | large-fixture | 40 | 5000000 | 12.4 | 15.9 | 0.8x | 5x | yes |
| Checkpoint.serialize | medium-fixture | 40 | 5000000 | 12.0 | 16.3 | 0.7x | 5x | yes |
| Checkpoint.serialize | small-fixture | 40 | 5000000 | 12.6 | 16.5 | 0.8x | 5x | yes |
| ColumnIndex.deserialize | random | 8 | 5000000 | 16.2 | 28.7 | 0.6x | 5x | yes |
| ColumnIndex.deserialize | saturated | 8 | 5000000 | 15.6 | 27.5 | 0.6x | 5x | yes |
| ColumnIndex.deserialize | zero | 8 | 5000000 | 14.6 | 25.5 | 0.6x | 5x | yes |
| ColumnIndex.hash_tree_root | random | 8 | 5000000 | 6.0 | 159.5 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | saturated | 8 | 5000000 | 6.2 | 169.0 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | zero | 8 | 5000000 | 6.6 | 173.2 | 0.0x | 10x | yes |
| ColumnIndex.serialize | random | 8 | 5000000 | 7.4 | 9.9 | 0.8x | 5x | yes |
| ColumnIndex.serialize | saturated | 8 | 5000000 | 7.6 | 9.6 | 0.8x | 5x | yes |
| ColumnIndex.serialize | zero | 8 | 5000000 | 7.0 | 9.3 | 0.8x | 5x | yes |
| CommitmentIndex.deserialize | random | 8 | 5000000 | 17.4 | 29.4 | 0.6x | 5x | yes |
| CommitmentIndex.deserialize | saturated | 8 | 5000000 | 15.8 | 27.2 | 0.6x | 5x | yes |
| CommitmentIndex.deserialize | zero | 8 | 5000000 | 16.0 | 27.1 | 0.6x | 5x | yes |
| CommitmentIndex.hash_tree_root | random | 8 | 5000000 | 5.8 | 160.2 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | saturated | 8 | 5000000 | 5.8 | 161.6 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | zero | 8 | 5000000 | 5.8 | 160.1 | 0.0x | 10x | yes |
| CommitmentIndex.serialize | random | 8 | 5000000 | 7.4 | 9.7 | 0.8x | 5x | yes |
| CommitmentIndex.serialize | saturated | 8 | 5000000 | 7.0 | 9.7 | 0.7x | 5x | yes |
| CommitmentIndex.serialize | zero | 8 | 5000000 | 7.0 | 9.5 | 0.7x | 5x | yes |
| CommitteeIndex.deserialize | random | 8 | 5000000 | 12.6 | 27.8 | 0.5x | 5x | yes |
| CommitteeIndex.deserialize | saturated | 8 | 5000000 | 12.4 | 27.9 | 0.4x | 5x | yes |
| CommitteeIndex.deserialize | zero | 8 | 5000000 | 12.8 | 28.3 | 0.5x | 5x | yes |
| CommitteeIndex.hash_tree_root | random | 8 | 5000000 | 6.0 | 153.5 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | saturated | 8 | 5000000 | 5.8 | 162.7 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | zero | 8 | 5000000 | 6.0 | 159.7 | 0.0x | 10x | yes |
| CommitteeIndex.serialize | random | 8 | 5000000 | 6.4 | 9.8 | 0.7x | 5x | yes |
| CommitteeIndex.serialize | saturated | 8 | 5000000 | 6.0 | 9.6 | 0.6x | 5x | yes |
| CommitteeIndex.serialize | zero | 8 | 5000000 | 6.2 | 10.0 | 0.6x | 5x | yes |
| ConsolidationRequest.deserialize | large-fixture | 116 | 5000000 | 57.2 | 17.1 | 3.3x | 5x | yes |
| ConsolidationRequest.deserialize | medium-fixture | 116 | 5000000 | 58.0 | 17.6 | 3.3x | 5x | yes |
| ConsolidationRequest.deserialize | small-fixture | 116 | 5000000 | 64.2 | 18.8 | 3.4x | 5x | yes |
| ConsolidationRequest.hash_tree_root | large-fixture | 116 | 286720 | 1346.3 | 395.3 | 3.4x | 10x | yes |
| ConsolidationRequest.hash_tree_root | medium-fixture | 116 | 286720 | 1342.8 | 394.9 | 3.4x | 10x | yes |
| ConsolidationRequest.hash_tree_root | small-fixture | 116 | 167936 | 1333.8 | 395.1 | 3.4x | 10x | yes |
| ConsolidationRequest.serialize | large-fixture | 116 | 5000000 | 32.0 | 20.4 | 1.6x | 5x | yes |
| ConsolidationRequest.serialize | medium-fixture | 116 | 5000000 | 32.2 | 21.4 | 1.5x | 5x | yes |
| ConsolidationRequest.serialize | small-fixture | 116 | 5000000 | 31.8 | 20.9 | 1.5x | 5x | yes |
| ContributionAndProof.deserialize | large-fixture | 264 | 3670016 | 141.1 | 67.4 | 2.1x | 5x | yes |
| ContributionAndProof.deserialize | medium-fixture | 264 | 3670016 | 145.8 | 67.3 | 2.2x | 5x | yes |
| ContributionAndProof.deserialize | small-fixture | 264 | 3670016 | 136.0 | 65.7 | 2.1x | 5x | yes |
| ContributionAndProof.hash_tree_root | large-fixture | 264 | 106496 | 4000.2 | 1072.0 | 3.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | medium-fixture | 264 | 114688 | 4002.2 | 1072.8 | 3.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | small-fixture | 264 | 106496 | 4009.5 | 1071.6 | 3.7x | 10x | yes |
| ContributionAndProof.serialize | large-fixture | 264 | 2621440 | 177.4 | 33.1 | 5.4x | 5x | no |
| ContributionAndProof.serialize | medium-fixture | 264 | 2621440 | 172.0 | 32.9 | 5.2x | 5x | no |
| ContributionAndProof.serialize | small-fixture | 264 | 2621440 | 178.9 | 33.5 | 5.3x | 5x | no |
| CurrentSyncCommitteeBranch.deserialize | random | 192 | 4194304 | 114.0 | 44.1 | 2.6x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | saturated | 192 | 4718592 | 113.8 | 44.2 | 2.6x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 119.0 | 47.4 | 2.5x | 5x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | random | 192 | 204800 | 2124.0 | 649.7 | 3.3x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | saturated | 192 | 204800 | 2089.8 | 648.5 | 3.2x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | zero | 192 | 221184 | 2124.9 | 652.2 | 3.3x | 10x | yes |
| CurrentSyncCommitteeBranch.serialize | random | 192 | 2097152 | 120.6 | 26.2 | 4.6x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | saturated | 192 | 4194304 | 108.0 | 23.6 | 4.6x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | zero | 192 | 3670016 | 109.3 | 23.9 | 4.6x | 5x | yes |
| CustodyIndex.deserialize | random | 8 | 5000000 | 11.8 | 31.1 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | saturated | 8 | 5000000 | 11.6 | 31.2 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | zero | 8 | 5000000 | 10.2 | 27.0 | 0.4x | 5x | yes |
| CustodyIndex.hash_tree_root | random | 8 | 5000000 | 6.4 | 178.2 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | saturated | 8 | 5000000 | 6.4 | 175.7 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | zero | 8 | 5000000 | 7.0 | 177.9 | 0.0x | 10x | yes |
| CustodyIndex.serialize | random | 8 | 5000000 | 6.6 | 11.0 | 0.6x | 5x | yes |
| CustodyIndex.serialize | saturated | 8 | 5000000 | 6.2 | 10.4 | 0.6x | 5x | yes |
| CustodyIndex.serialize | zero | 8 | 5000000 | 6.2 | 10.6 | 0.6x | 5x | yes |
| DataColumnSidecar.deserialize | large-fixture | 19076 | 122880 | 4296.9 | 1760.9 | 2.4x | 5x | yes |
| DataColumnSidecar.deserialize | medium-fixture | 17028 | 65536 | 3875.7 | 1583.4 | 2.4x | 5x | yes |
| DataColumnSidecar.deserialize | small-fixture | 6500 | 253952 | 1649.9 | 771.7 | 2.1x | 5x | yes |
| DataColumnSidecar.hash_tree_root | large-fixture | 19076 | 2432 | 174342.1 | 42508.2 | 4.1x | 10x | yes |
| DataColumnSidecar.hash_tree_root | medium-fixture | 17028 | 2816 | 156605.1 | 38188.3 | 4.1x | 10x | yes |
| DataColumnSidecar.hash_tree_root | small-fixture | 6500 | 6400 | 60625.0 | 14941.1 | 4.1x | 10x | yes |
| DataColumnSidecar.serialize | large-fixture | 19076 | 65536 | 3814.7 | 1017.2 | 3.8x | 5x | yes |
| DataColumnSidecar.serialize | medium-fixture | 17028 | 122880 | 3857.4 | 913.4 | 4.2x | 5x | yes |
| DataColumnSidecar.serialize | small-fixture | 6500 | 204800 | 1342.8 | 399.1 | 3.4x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | large-fixture | 92 | 5000000 | 96.2 | 54.0 | 1.8x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | medium-fixture | 60 | 5000000 | 71.8 | 52.4 | 1.4x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | small-fixture | 36 | 5000000 | 56.2 | 35.9 | 1.6x | 5x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | large-fixture | 92 | 204800 | 2158.2 | 527.7 | 4.1x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | medium-fixture | 60 | 221184 | 1880.8 | 520.7 | 3.6x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | small-fixture | 36 | 524288 | 555.0 | 179.4 | 3.1x | 10x | yes |
| DataColumnsByRootIdentifier.serialize | large-fixture | 92 | 5000000 | 89.2 | 23.3 | 3.8x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | medium-fixture | 60 | 5000000 | 28.6 | 19.5 | 1.5x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | small-fixture | 36 | 5000000 | 27.0 | 18.9 | 1.4x | 5x | yes |
| Deposit.deserialize | large-fixture | 1240 | 1048576 | 475.9 | 672.4 | 0.7x | 5x | yes |
| Deposit.deserialize | medium-fixture | 1240 | 1048576 | 466.3 | 693.5 | 0.7x | 5x | yes |
| Deposit.deserialize | small-fixture | 1240 | 1048576 | 464.4 | 663.8 | 0.7x | 5x | yes |
| Deposit.hash_tree_root | large-fixture | 1240 | 32768 | 12603.8 | 3283.9 | 3.8x | 10x | yes |
| Deposit.hash_tree_root | medium-fixture | 1240 | 32768 | 12359.6 | 3214.7 | 3.8x | 10x | yes |
| Deposit.hash_tree_root | small-fixture | 1240 | 32768 | 12481.7 | 3239.3 | 3.9x | 10x | yes |
| Deposit.serialize | large-fixture | 1240 | 1048576 | 372.9 | 121.2 | 3.1x | 5x | yes |
| Deposit.serialize | medium-fixture | 1240 | 1048576 | 370.0 | 115.3 | 3.2x | 5x | yes |
| Deposit.serialize | small-fixture | 1240 | 1048576 | 379.6 | 120.5 | 3.1x | 5x | yes |
| DepositData.deserialize | large-fixture | 184 | 4718592 | 121.6 | 45.7 | 2.7x | 5x | yes |
| DepositData.deserialize | medium-fixture | 184 | 2621440 | 114.8 | 41.0 | 2.8x | 5x | yes |
| DepositData.deserialize | small-fixture | 184 | 4194304 | 117.3 | 43.8 | 2.7x | 5x | yes |
| DepositData.hash_tree_root | large-fixture | 184 | 221184 | 1880.8 | 524.8 | 3.6x | 10x | yes |
| DepositData.hash_tree_root | medium-fixture | 184 | 221184 | 1889.8 | 528.4 | 3.6x | 10x | yes |
| DepositData.hash_tree_root | small-fixture | 184 | 221184 | 1876.3 | 526.6 | 3.6x | 10x | yes |
| DepositData.serialize | large-fixture | 184 | 5000000 | 48.2 | 25.8 | 1.9x | 5x | yes |
| DepositData.serialize | medium-fixture | 184 | 5000000 | 50.2 | 28.8 | 1.7x | 5x | yes |
| DepositData.serialize | small-fixture | 184 | 5000000 | 46.6 | 26.5 | 1.8x | 5x | yes |
| DepositMessage.deserialize | large-fixture | 88 | 5000000 | 41.2 | 34.3 | 1.2x | 5x | yes |
| DepositMessage.deserialize | medium-fixture | 88 | 5000000 | 41.4 | 32.8 | 1.3x | 5x | yes |
| DepositMessage.deserialize | small-fixture | 88 | 5000000 | 38.0 | 31.8 | 1.2x | 5x | yes |
| DepositMessage.hash_tree_root | large-fixture | 88 | 204800 | 1098.6 | 326.6 | 3.4x | 10x | yes |
| DepositMessage.hash_tree_root | medium-fixture | 88 | 204800 | 1103.5 | 326.0 | 3.4x | 10x | yes |
| DepositMessage.hash_tree_root | small-fixture | 88 | 204800 | 1103.5 | 332.0 | 3.3x | 10x | yes |
| DepositMessage.serialize | large-fixture | 88 | 5000000 | 22.4 | 20.6 | 1.1x | 5x | yes |
| DepositMessage.serialize | medium-fixture | 88 | 5000000 | 22.2 | 19.9 | 1.1x | 5x | yes |
| DepositMessage.serialize | small-fixture | 88 | 5000000 | 23.0 | 21.1 | 1.1x | 5x | yes |
| DepositRequest.deserialize | large-fixture | 192 | 2359296 | 131.8 | 49.2 | 2.7x | 5x | yes |
| DepositRequest.deserialize | medium-fixture | 192 | 4194304 | 116.8 | 41.6 | 2.8x | 5x | yes |
| DepositRequest.deserialize | small-fixture | 192 | 4718592 | 114.9 | 42.3 | 2.7x | 5x | yes |
| DepositRequest.hash_tree_root | large-fixture | 192 | 155648 | 2704.8 | 735.4 | 3.7x | 10x | yes |
| DepositRequest.hash_tree_root | medium-fixture | 192 | 155648 | 2711.2 | 739.9 | 3.7x | 10x | yes |
| DepositRequest.hash_tree_root | small-fixture | 192 | 155648 | 2698.4 | 728.5 | 3.7x | 10x | yes |
| DepositRequest.serialize | large-fixture | 192 | 5000000 | 58.4 | 29.3 | 2.0x | 5x | yes |
| DepositRequest.serialize | medium-fixture | 192 | 5000000 | 53.6 | 26.9 | 2.0x | 5x | yes |
| DepositRequest.serialize | small-fixture | 192 | 5000000 | 53.8 | 26.5 | 2.0x | 5x | yes |
| Domain.deserialize | random | 32 | 5000000 | 32.0 | 33.4 | 1.0x | 5x | yes |
| Domain.deserialize | saturated | 32 | 5000000 | 31.4 | 33.1 | 0.9x | 5x | yes |
| Domain.deserialize | zero | 32 | 5000000 | 28.8 | 29.7 | 1.0x | 5x | yes |
| Domain.hash_tree_root | random | 32 | 5000000 | 6.4 | 153.2 | 0.0x | 10x | yes |
| Domain.hash_tree_root | saturated | 32 | 5000000 | 6.6 | 151.9 | 0.0x | 10x | yes |
| Domain.hash_tree_root | zero | 32 | 5000000 | 6.8 | 166.3 | 0.0x | 10x | yes |
| Domain.serialize | random | 32 | 5000000 | 10.8 | 14.9 | 0.7x | 5x | yes |
| Domain.serialize | saturated | 32 | 5000000 | 10.8 | 15.0 | 0.7x | 5x | yes |
| Domain.serialize | zero | 32 | 5000000 | 11.2 | 16.0 | 0.7x | 5x | yes |
| DomainType.deserialize | random | 4 | 5000000 | 6.0 | 29.3 | 0.2x | 5x | yes |
| DomainType.deserialize | saturated | 4 | 5000000 | 6.0 | 29.9 | 0.2x | 5x | yes |
| DomainType.deserialize | zero | 4 | 5000000 | 5.8 | 29.5 | 0.2x | 5x | yes |
| DomainType.hash_tree_root | random | 4 | 5000000 | 6.0 | 164.3 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | saturated | 4 | 5000000 | 6.0 | 162.3 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | zero | 4 | 5000000 | 6.0 | 163.0 | 0.0x | 10x | yes |
| DomainType.serialize | random | 4 | 5000000 | 7.2 | 9.7 | 0.7x | 5x | yes |
| DomainType.serialize | saturated | 4 | 5000000 | 7.0 | 9.9 | 0.7x | 5x | yes |
| DomainType.serialize | zero | 4 | 5000000 | 7.2 | 9.9 | 0.7x | 5x | yes |
| Epoch.deserialize | random | 8 | 5000000 | 12.4 | 28.8 | 0.4x | 5x | yes |
| Epoch.deserialize | saturated | 8 | 5000000 | 13.2 | 30.2 | 0.4x | 5x | yes |
| Epoch.deserialize | zero | 8 | 5000000 | 12.2 | 28.7 | 0.4x | 5x | yes |
| Epoch.hash_tree_root | random | 8 | 5000000 | 6.0 | 160.5 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | saturated | 8 | 5000000 | 6.0 | 166.8 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | zero | 8 | 5000000 | 6.0 | 167.4 | 0.0x | 10x | yes |
| Epoch.serialize | random | 8 | 5000000 | 6.2 | 10.1 | 0.6x | 5x | yes |
| Epoch.serialize | saturated | 8 | 5000000 | 6.6 | 10.7 | 0.6x | 5x | yes |
| Epoch.serialize | zero | 8 | 5000000 | 6.2 | 10.3 | 0.6x | 5x | yes |
| Eth1Block.deserialize | large-fixture | 48 | 5000000 | 25.0 | 30.9 | 0.8x | 5x | yes |
| Eth1Block.deserialize | medium-fixture | 48 | 5000000 | 25.2 | 31.8 | 0.8x | 5x | yes |
| Eth1Block.deserialize | small-fixture | 48 | 5000000 | 27.8 | 34.4 | 0.8x | 5x | yes |
| Eth1Block.hash_tree_root | large-fixture | 48 | 507904 | 813.1 | 243.9 | 3.3x | 10x | yes |
| Eth1Block.hash_tree_root | medium-fixture | 48 | 409600 | 817.9 | 244.6 | 3.3x | 10x | yes |
| Eth1Block.hash_tree_root | small-fixture | 48 | 507904 | 811.2 | 244.7 | 3.3x | 10x | yes |
| Eth1Block.serialize | large-fixture | 48 | 5000000 | 11.2 | 18.1 | 0.6x | 5x | yes |
| Eth1Block.serialize | medium-fixture | 48 | 5000000 | 11.8 | 18.8 | 0.6x | 5x | yes |
| Eth1Block.serialize | small-fixture | 48 | 5000000 | 11.2 | 18.4 | 0.6x | 5x | yes |
| Eth1Data.deserialize | large-fixture | 72 | 5000000 | 44.6 | 45.3 | 1.0x | 5x | yes |
| Eth1Data.deserialize | medium-fixture | 72 | 5000000 | 43.0 | 45.8 | 0.9x | 5x | yes |
| Eth1Data.deserialize | small-fixture | 72 | 5000000 | 41.8 | 45.5 | 0.9x | 5x | yes |
| Eth1Data.hash_tree_root | large-fixture | 72 | 253952 | 850.6 | 250.6 | 3.4x | 10x | yes |
| Eth1Data.hash_tree_root | medium-fixture | 72 | 507904 | 805.3 | 243.0 | 3.3x | 10x | yes |
| Eth1Data.hash_tree_root | small-fixture | 72 | 507904 | 809.2 | 242.1 | 3.3x | 10x | yes |
| Eth1Data.serialize | large-fixture | 72 | 5000000 | 21.0 | 20.7 | 1.0x | 5x | yes |
| Eth1Data.serialize | medium-fixture | 72 | 5000000 | 21.4 | 20.7 | 1.0x | 5x | yes |
| Eth1Data.serialize | small-fixture | 72 | 5000000 | 21.2 | 20.6 | 1.0x | 5x | yes |
| Ether.deserialize | random | 8 | 5000000 | 14.6 | 29.9 | 0.5x | 5x | yes |
| Ether.deserialize | saturated | 8 | 5000000 | 14.2 | 28.7 | 0.5x | 5x | yes |
| Ether.deserialize | zero | 8 | 5000000 | 12.8 | 25.3 | 0.5x | 5x | yes |
| Ether.hash_tree_root | random | 8 | 5000000 | 6.0 | 165.4 | 0.0x | 10x | yes |
| Ether.hash_tree_root | saturated | 8 | 5000000 | 6.0 | 159.0 | 0.0x | 10x | yes |
| Ether.hash_tree_root | zero | 8 | 5000000 | 6.4 | 173.4 | 0.0x | 10x | yes |
| Ether.serialize | random | 8 | 5000000 | 7.4 | 10.4 | 0.7x | 5x | yes |
| Ether.serialize | saturated | 8 | 5000000 | 7.4 | 10.1 | 0.7x | 5x | yes |
| Ether.serialize | zero | 8 | 5000000 | 7.0 | 9.5 | 0.7x | 5x | yes |
| ExecutionAddress.deserialize | random | 20 | 5000000 | 19.6 | 33.3 | 0.6x | 5x | yes |
| ExecutionAddress.deserialize | saturated | 20 | 5000000 | 19.2 | 32.7 | 0.6x | 5x | yes |
| ExecutionAddress.deserialize | zero | 20 | 5000000 | 18.0 | 32.9 | 0.5x | 5x | yes |
| ExecutionAddress.hash_tree_root | random | 20 | 5000000 | 6.2 | 174.3 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | saturated | 20 | 5000000 | 6.2 | 167.7 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | zero | 20 | 5000000 | 6.2 | 166.3 | 0.0x | 10x | yes |
| ExecutionAddress.serialize | random | 20 | 5000000 | 8.0 | 15.1 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | saturated | 20 | 5000000 | 8.0 | 15.1 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | zero | 20 | 5000000 | 7.8 | 14.8 | 0.5x | 5x | yes |
| ExecutionBranch.deserialize | random | 128 | 4718592 | 101.5 | 36.6 | 2.8x | 5x | yes |
| ExecutionBranch.deserialize | saturated | 128 | 4718592 | 101.9 | 36.3 | 2.8x | 5x | yes |
| ExecutionBranch.deserialize | zero | 128 | 4194304 | 102.5 | 35.9 | 2.9x | 5x | yes |
| ExecutionBranch.hash_tree_root | random | 128 | 507904 | 891.9 | 403.4 | 2.2x | 10x | yes |
| ExecutionBranch.hash_tree_root | saturated | 128 | 507904 | 872.2 | 405.5 | 2.2x | 10x | yes |
| ExecutionBranch.hash_tree_root | zero | 128 | 507904 | 872.2 | 401.4 | 2.2x | 10x | yes |
| ExecutionBranch.serialize | random | 128 | 5000000 | 70.8 | 18.4 | 3.8x | 5x | yes |
| ExecutionBranch.serialize | saturated | 128 | 5000000 | 73.4 | 19.7 | 3.7x | 5x | yes |
| ExecutionBranch.serialize | zero | 128 | 5000000 | 70.8 | 18.6 | 3.8x | 5x | yes |
| ExecutionPayload.deserialize | large-fixture | 4033 | 163840 | 3064.0 | 604.3 | 5.1x | 5x | no |
| ExecutionPayload.deserialize | medium-fixture | 2445 | 167936 | 1816.2 | 481.1 | 3.8x | 5x | yes |
| ExecutionPayload.deserialize | small-fixture | 1921 | 335872 | 1589.9 | 332.6 | 4.8x | 5x | yes |
| ExecutionPayload.hash_tree_root | large-fixture | 4033 | 3968 | 101058.5 | 24435.4 | 4.1x | 10x | yes |
| ExecutionPayload.hash_tree_root | medium-fixture | 2445 | 3968 | 62752.0 | 15359.1 | 4.1x | 10x | yes |
| ExecutionPayload.hash_tree_root | small-fixture | 1921 | 8192 | 47485.4 | 11588.1 | 4.1x | 10x | yes |
| ExecutionPayload.serialize | large-fixture | 4033 | 335872 | 1527.4 | 333.7 | 4.6x | 5x | yes |
| ExecutionPayload.serialize | medium-fixture | 2445 | 409600 | 1042.5 | 243.7 | 4.3x | 5x | yes |
| ExecutionPayload.serialize | small-fixture | 1921 | 507904 | 811.2 | 191.4 | 4.2x | 5x | yes |
| ExecutionPayloadHeader.deserialize | large-fixture | 604 | 1048576 | 487.3 | 100.2 | 4.9x | 5x | yes |
| ExecutionPayloadHeader.deserialize | medium-fixture | 594 | 1048576 | 492.1 | 95.7 | 5.1x | 5x | no |
| ExecutionPayloadHeader.deserialize | small-fixture | 590 | 1048576 | 476.8 | 99.8 | 4.8x | 5x | yes |
| ExecutionPayloadHeader.hash_tree_root | large-fixture | 604 | 49152 | 7873.5 | 2010.7 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | medium-fixture | 594 | 49152 | 7873.5 | 2012.7 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | small-fixture | 590 | 49152 | 7995.6 | 2053.1 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.serialize | large-fixture | 604 | 524288 | 492.1 | 76.9 | 6.4x | 5x | no |
| ExecutionPayloadHeader.serialize | medium-fixture | 594 | 524288 | 503.5 | 76.7 | 6.6x | 5x | no |
| ExecutionPayloadHeader.serialize | small-fixture | 590 | 524288 | 490.2 | 74.8 | 6.6x | 5x | no |
| ExecutionRequests.deserialize | large-fixture | 1624 | 524288 | 825.9 | 462.6 | 1.8x | 5x | yes |
| ExecutionRequests.deserialize | medium-fixture | 1004 | 524288 | 581.7 | 287.4 | 2.0x | 5x | yes |
| ExecutionRequests.deserialize | small-fixture | 396 | 2097152 | 268.9 | 145.5 | 1.8x | 5x | yes |
| ExecutionRequests.hash_tree_root | large-fixture | 1624 | 8192 | 31738.3 | 8098.2 | 3.9x | 10x | yes |
| ExecutionRequests.hash_tree_root | medium-fixture | 1004 | 16384 | 19287.1 | 5223.7 | 3.7x | 10x | yes |
| ExecutionRequests.hash_tree_root | small-fixture | 396 | 32768 | 11413.6 | 2878.4 | 4.0x | 10x | yes |
| ExecutionRequests.serialize | large-fixture | 1624 | 524288 | 581.7 | 154.6 | 3.8x | 5x | yes |
| ExecutionRequests.serialize | medium-fixture | 1004 | 1048576 | 316.6 | 102.4 | 3.1x | 5x | yes |
| ExecutionRequests.serialize | small-fixture | 396 | 2097152 | 197.9 | 51.2 | 3.9x | 5x | yes |
| FinalityBranch.deserialize | random | 224 | 4194304 | 108.5 | 44.1 | 2.5x | 5x | yes |
| FinalityBranch.deserialize | saturated | 224 | 4194304 | 109.0 | 43.2 | 2.5x | 5x | yes |
| FinalityBranch.deserialize | zero | 224 | 4718592 | 108.5 | 43.6 | 2.5x | 5x | yes |
| FinalityBranch.hash_tree_root | random | 224 | 221184 | 2020.9 | 721.7 | 2.8x | 10x | yes |
| FinalityBranch.hash_tree_root | saturated | 224 | 126976 | 2102.8 | 720.6 | 2.9x | 10x | yes |
| FinalityBranch.hash_tree_root | zero | 224 | 126976 | 2047.6 | 715.2 | 2.9x | 10x | yes |
| FinalityBranch.serialize | random | 224 | 4194304 | 107.0 | 25.8 | 4.1x | 5x | yes |
| FinalityBranch.serialize | saturated | 224 | 4194304 | 106.3 | 26.3 | 4.0x | 5x | yes |
| FinalityBranch.serialize | zero | 224 | 4194304 | 106.1 | 25.8 | 4.1x | 5x | yes |
| Fork.deserialize | large-fixture | 16 | 5000000 | 16.2 | 11.9 | 1.4x | 5x | yes |
| Fork.deserialize | medium-fixture | 16 | 5000000 | 16.2 | 11.9 | 1.4x | 5x | yes |
| Fork.deserialize | small-fixture | 16 | 5000000 | 16.4 | 12.1 | 1.4x | 5x | yes |
| Fork.hash_tree_root | large-fixture | 16 | 507904 | 825.0 | 254.6 | 3.2x | 10x | yes |
| Fork.hash_tree_root | medium-fixture | 16 | 507904 | 832.8 | 251.4 | 3.3x | 10x | yes |
| Fork.hash_tree_root | small-fixture | 16 | 507904 | 826.9 | 256.6 | 3.2x | 10x | yes |
| Fork.serialize | large-fixture | 16 | 5000000 | 9.6 | 15.8 | 0.6x | 5x | yes |
| Fork.serialize | medium-fixture | 16 | 5000000 | 9.4 | 15.7 | 0.6x | 5x | yes |
| Fork.serialize | small-fixture | 16 | 5000000 | 9.4 | 16.2 | 0.6x | 5x | yes |
| ForkData.deserialize | large-fixture | 36 | 5000000 | 31.6 | 14.5 | 2.2x | 5x | yes |
| ForkData.deserialize | medium-fixture | 36 | 5000000 | 29.6 | 14.2 | 2.1x | 5x | yes |
| ForkData.deserialize | small-fixture | 36 | 5000000 | 31.6 | 14.4 | 2.2x | 5x | yes |
| ForkData.hash_tree_root | large-fixture | 36 | 1048576 | 321.4 | 123.1 | 2.6x | 10x | yes |
| ForkData.hash_tree_root | medium-fixture | 36 | 1048576 | 296.6 | 111.7 | 2.7x | 10x | yes |
| ForkData.hash_tree_root | small-fixture | 36 | 1048576 | 300.4 | 111.8 | 2.7x | 10x | yes |
| ForkData.serialize | large-fixture | 36 | 5000000 | 14.0 | 17.7 | 0.8x | 5x | yes |
| ForkData.serialize | medium-fixture | 36 | 5000000 | 13.4 | 16.6 | 0.8x | 5x | yes |
| ForkData.serialize | small-fixture | 36 | 5000000 | 14.0 | 17.6 | 0.8x | 5x | yes |
| ForkDigest.deserialize | random | 4 | 5000000 | 6.8 | 31.1 | 0.2x | 5x | yes |
| ForkDigest.deserialize | saturated | 4 | 5000000 | 7.0 | 30.8 | 0.2x | 5x | yes |
| ForkDigest.deserialize | zero | 4 | 5000000 | 7.2 | 31.0 | 0.2x | 5x | yes |
| ForkDigest.hash_tree_root | random | 4 | 5000000 | 6.0 | 165.8 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | saturated | 4 | 5000000 | 6.2 | 160.7 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | zero | 4 | 5000000 | 6.4 | 170.1 | 0.0x | 10x | yes |
| ForkDigest.serialize | random | 4 | 5000000 | 7.0 | 9.7 | 0.7x | 5x | yes |
| ForkDigest.serialize | saturated | 4 | 5000000 | 7.0 | 9.9 | 0.7x | 5x | yes |
| ForkDigest.serialize | zero | 4 | 5000000 | 7.4 | 10.4 | 0.7x | 5x | yes |
| G1Point.deserialize | random | 48 | 5000000 | 31.8 | 34.0 | 0.9x | 5x | yes |
| G1Point.deserialize | saturated | 48 | 5000000 | 31.2 | 33.7 | 0.9x | 5x | yes |
| G1Point.deserialize | zero | 48 | 5000000 | 32.4 | 35.8 | 0.9x | 5x | yes |
| G1Point.hash_tree_root | random | 48 | 1048576 | 320.4 | 268.0 | 1.2x | 10x | yes |
| G1Point.hash_tree_root | saturated | 48 | 1048576 | 312.8 | 258.5 | 1.2x | 10x | yes |
| G1Point.hash_tree_root | zero | 48 | 1048576 | 310.9 | 258.0 | 1.2x | 10x | yes |
| G1Point.serialize | random | 48 | 5000000 | 16.8 | 16.8 | 1.0x | 5x | yes |
| G1Point.serialize | saturated | 48 | 5000000 | 17.0 | 17.1 | 1.0x | 5x | yes |
| G1Point.serialize | zero | 48 | 5000000 | 15.6 | 17.1 | 0.9x | 5x | yes |
| G2Point.deserialize | random | 96 | 5000000 | 53.8 | 34.9 | 1.5x | 5x | yes |
| G2Point.deserialize | saturated | 96 | 5000000 | 57.0 | 35.8 | 1.6x | 5x | yes |
| G2Point.deserialize | zero | 96 | 5000000 | 57.2 | 36.2 | 1.6x | 5x | yes |
| G2Point.hash_tree_root | random | 96 | 507904 | 888.0 | 406.0 | 2.2x | 10x | yes |
| G2Point.hash_tree_root | saturated | 96 | 507904 | 884.0 | 411.9 | 2.1x | 10x | yes |
| G2Point.hash_tree_root | zero | 96 | 507904 | 884.0 | 405.3 | 2.2x | 10x | yes |
| G2Point.serialize | random | 96 | 5000000 | 21.4 | 20.5 | 1.0x | 5x | yes |
| G2Point.serialize | saturated | 96 | 5000000 | 21.4 | 19.8 | 1.1x | 5x | yes |
| G2Point.serialize | zero | 96 | 5000000 | 20.4 | 19.6 | 1.0x | 5x | yes |
| Gwei.deserialize | random | 8 | 5000000 | 13.6 | 29.6 | 0.5x | 5x | yes |
| Gwei.deserialize | saturated | 8 | 5000000 | 13.6 | 29.7 | 0.5x | 5x | yes |
| Gwei.deserialize | zero | 8 | 5000000 | 11.4 | 27.5 | 0.4x | 5x | yes |
| Gwei.hash_tree_root | random | 8 | 5000000 | 6.4 | 174.0 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | saturated | 8 | 5000000 | 6.2 | 166.9 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | zero | 8 | 5000000 | 6.4 | 170.5 | 0.0x | 10x | yes |
| Gwei.serialize | random | 8 | 5000000 | 6.8 | 10.9 | 0.6x | 5x | yes |
| Gwei.serialize | saturated | 8 | 5000000 | 6.8 | 10.1 | 0.7x | 5x | yes |
| Gwei.serialize | zero | 8 | 5000000 | 6.8 | 10.9 | 0.6x | 5x | yes |
| Hash32.deserialize | random | 32 | 5000000 | 21.2 | 34.2 | 0.6x | 5x | yes |
| Hash32.deserialize | saturated | 32 | 5000000 | 22.2 | 33.8 | 0.7x | 5x | yes |
| Hash32.deserialize | zero | 32 | 5000000 | 19.8 | 34.4 | 0.6x | 5x | yes |
| Hash32.hash_tree_root | random | 32 | 5000000 | 6.2 | 156.7 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | saturated | 32 | 5000000 | 6.2 | 152.3 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | zero | 32 | 5000000 | 6.4 | 154.4 | 0.0x | 10x | yes |
| Hash32.serialize | random | 32 | 5000000 | 9.2 | 16.1 | 0.6x | 5x | yes |
| Hash32.serialize | saturated | 32 | 5000000 | 9.2 | 15.7 | 0.6x | 5x | yes |
| Hash32.serialize | zero | 32 | 5000000 | 9.0 | 15.3 | 0.6x | 5x | yes |
| HistoricalBatch.deserialize | large-fixture | 524288 | 3968 | 125504.0 | 354823.1 | 0.4x | 5x | yes |
| HistoricalBatch.deserialize | medium-fixture | 524288 | 4480 | 122544.6 | 363673.1 | 0.3x | 5x | yes |
| HistoricalBatch.deserialize | small-fixture | 524288 | 3968 | 123235.9 | 355656.5 | 0.3x | 5x | yes |
| HistoricalBatch.hash_tree_root | large-fixture | 524288 | 100 | 4570000.0 | 1192903.2 | 3.8x | 10x | yes |
| HistoricalBatch.hash_tree_root | medium-fixture | 524288 | 100 | 4660000.0 | 1236413.0 | 3.8x | 10x | yes |
| HistoricalBatch.hash_tree_root | small-fixture | 524288 | 100 | 4600000.0 | 1210104.5 | 3.8x | 10x | yes |
| HistoricalBatch.serialize | large-fixture | 524288 | 3200 | 79687.5 | 73277.5 | 1.1x | 5x | yes |
| HistoricalBatch.serialize | medium-fixture | 524288 | 3200 | 77500.0 | 71559.3 | 1.1x | 5x | yes |
| HistoricalBatch.serialize | small-fixture | 524288 | 3200 | 79062.5 | 72425.4 | 1.1x | 5x | yes |
| HistoricalSummary.deserialize | large-fixture | 64 | 5000000 | 42.0 | 14.9 | 2.8x | 5x | yes |
| HistoricalSummary.deserialize | medium-fixture | 64 | 5000000 | 41.8 | 14.5 | 2.9x | 5x | yes |
| HistoricalSummary.deserialize | small-fixture | 64 | 5000000 | 41.4 | 14.5 | 2.9x | 5x | yes |
| HistoricalSummary.hash_tree_root | large-fixture | 64 | 1048576 | 298.5 | 109.4 | 2.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | medium-fixture | 64 | 1048576 | 295.6 | 108.1 | 2.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | small-fixture | 64 | 1048576 | 307.1 | 112.9 | 2.7x | 10x | yes |
| HistoricalSummary.serialize | large-fixture | 64 | 5000000 | 18.4 | 18.1 | 1.0x | 5x | yes |
| HistoricalSummary.serialize | medium-fixture | 64 | 5000000 | 18.4 | 16.9 | 1.1x | 5x | yes |
| HistoricalSummary.serialize | small-fixture | 64 | 5000000 | 18.0 | 16.6 | 1.1x | 5x | yes |
| IndexedAttestation.deserialize | large-fixture | 308 | 1572864 | 276.6 | 106.0 | 2.6x | 5x | yes |
| IndexedAttestation.deserialize | medium-fixture | 284 | 1572864 | 288.0 | 103.7 | 2.8x | 5x | yes |
| IndexedAttestation.deserialize | small-fixture | 236 | 2097152 | 260.8 | 94.9 | 2.7x | 5x | yes |
| IndexedAttestation.hash_tree_root | large-fixture | 308 | 49152 | 8667.0 | 2311.7 | 3.7x | 10x | yes |
| IndexedAttestation.hash_tree_root | medium-fixture | 284 | 49152 | 8748.4 | 2221.6 | 3.9x | 10x | yes |
| IndexedAttestation.hash_tree_root | small-fixture | 236 | 49152 | 8483.9 | 2271.9 | 3.7x | 10x | yes |
| IndexedAttestation.serialize | large-fixture | 308 | 2097152 | 193.6 | 43.3 | 4.5x | 5x | yes |
| IndexedAttestation.serialize | medium-fixture | 284 | 2097152 | 188.8 | 38.5 | 4.9x | 5x | yes |
| IndexedAttestation.serialize | small-fixture | 236 | 2621440 | 167.5 | 33.7 | 5.0x | 5x | yes |
| KZGCommitment.deserialize | random | 48 | 5000000 | 37.8 | 32.7 | 1.2x | 5x | yes |
| KZGCommitment.deserialize | saturated | 48 | 5000000 | 35.0 | 32.7 | 1.1x | 5x | yes |
| KZGCommitment.deserialize | zero | 48 | 5000000 | 32.6 | 32.2 | 1.0x | 5x | yes |
| KZGCommitment.hash_tree_root | random | 48 | 1048576 | 308.0 | 257.7 | 1.2x | 10x | yes |
| KZGCommitment.hash_tree_root | saturated | 48 | 1048576 | 305.2 | 251.1 | 1.2x | 10x | yes |
| KZGCommitment.hash_tree_root | zero | 48 | 1048576 | 315.7 | 258.7 | 1.2x | 10x | yes |
| KZGCommitment.serialize | random | 48 | 5000000 | 16.0 | 16.8 | 0.9x | 5x | yes |
| KZGCommitment.serialize | saturated | 48 | 5000000 | 16.2 | 16.5 | 1.0x | 5x | yes |
| KZGCommitment.serialize | zero | 48 | 5000000 | 14.2 | 17.0 | 0.8x | 5x | yes |
| KZGProof.deserialize | random | 48 | 5000000 | 31.6 | 33.9 | 0.9x | 5x | yes |
| KZGProof.deserialize | saturated | 48 | 5000000 | 30.6 | 33.0 | 0.9x | 5x | yes |
| KZGProof.deserialize | zero | 48 | 5000000 | 28.8 | 33.3 | 0.9x | 5x | yes |
| KZGProof.hash_tree_root | random | 48 | 1048576 | 299.5 | 251.0 | 1.2x | 10x | yes |
| KZGProof.hash_tree_root | saturated | 48 | 1048576 | 311.9 | 262.8 | 1.2x | 10x | yes |
| KZGProof.hash_tree_root | zero | 48 | 1048576 | 308.0 | 275.2 | 1.1x | 10x | yes |
| KZGProof.serialize | random | 48 | 5000000 | 12.4 | 16.2 | 0.8x | 5x | yes |
| KZGProof.serialize | saturated | 48 | 5000000 | 12.6 | 16.8 | 0.7x | 5x | yes |
| KZGProof.serialize | zero | 48 | 5000000 | 12.0 | 17.3 | 0.7x | 5x | yes |
| LightClientBootstrap.deserialize | large-fixture | 25676 | 90112 | 6048.0 | 10109.6 | 0.6x | 5x | yes |
| LightClientBootstrap.deserialize | medium-fixture | 25666 | 90112 | 5748.4 | 10560.1 | 0.5x | 5x | yes |
| LightClientBootstrap.deserialize | small-fixture | 25651 | 81920 | 5786.1 | 10208.4 | 0.6x | 5x | yes |
| LightClientBootstrap.hash_tree_root | large-fixture | 25676 | 1536 | 318359.4 | 83636.7 | 3.8x | 10x | yes |
| LightClientBootstrap.hash_tree_root | medium-fixture | 25666 | 1408 | 323153.4 | 86406.0 | 3.7x | 10x | yes |
| LightClientBootstrap.hash_tree_root | small-fixture | 25651 | 1408 | 316761.4 | 83612.7 | 3.8x | 10x | yes |
| LightClientBootstrap.serialize | large-fixture | 25676 | 98304 | 4486.1 | 1997.8 | 2.2x | 5x | yes |
| LightClientBootstrap.serialize | medium-fixture | 25666 | 98304 | 4496.3 | 1995.5 | 2.3x | 5x | yes |
| LightClientBootstrap.serialize | small-fixture | 25651 | 98304 | 4496.3 | 2073.1 | 2.2x | 5x | yes |
| LightClientFinalityUpdate.deserialize | large-fixture | 2096 | 286720 | 1949.6 | 1147.4 | 1.7x | 5x | yes |
| LightClientFinalityUpdate.deserialize | medium-fixture | 2078 | 143360 | 1904.3 | 1123.5 | 1.7x | 5x | yes |
| LightClientFinalityUpdate.deserialize | small-fixture | 2066 | 253952 | 1945.2 | 1119.3 | 1.7x | 5x | yes |
| LightClientFinalityUpdate.hash_tree_root | large-fixture | 2096 | 8192 | 29052.7 | 7354.7 | 4.0x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | medium-fixture | 2078 | 8192 | 28686.5 | 7281.6 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | small-fixture | 2066 | 16384 | 28442.4 | 7256.9 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.serialize | large-fixture | 2096 | 204800 | 1289.1 | 198.0 | 6.5x | 5x | no |
| LightClientFinalityUpdate.serialize | medium-fixture | 2078 | 335872 | 1292.2 | 190.0 | 6.8x | 5x | no |
| LightClientFinalityUpdate.serialize | small-fixture | 2066 | 335872 | 1280.2 | 198.1 | 6.5x | 5x | no |
| LightClientHeader.deserialize | large-fixture | 860 | 524288 | 743.9 | 440.4 | 1.7x | 5x | yes |
| LightClientHeader.deserialize | medium-fixture | 850 | 524288 | 749.6 | 444.6 | 1.7x | 5x | yes |
| LightClientHeader.deserialize | small-fixture | 830 | 524288 | 736.2 | 436.1 | 1.7x | 5x | yes |
| LightClientHeader.hash_tree_root | large-fixture | 860 | 32768 | 11535.6 | 2971.1 | 3.9x | 10x | yes |
| LightClientHeader.hash_tree_root | medium-fixture | 850 | 32768 | 11444.1 | 2964.0 | 3.9x | 10x | yes |
| LightClientHeader.hash_tree_root | small-fixture | 830 | 32768 | 11596.7 | 2991.5 | 3.9x | 10x | yes |
| LightClientHeader.serialize | large-fixture | 860 | 1048576 | 480.7 | 91.5 | 5.3x | 5x | no |
| LightClientHeader.serialize | medium-fixture | 850 | 524288 | 473.0 | 92.1 | 5.1x | 5x | no |
| LightClientHeader.serialize | small-fixture | 830 | 524288 | 471.1 | 90.7 | 5.2x | 5x | no |
| LightClientOptimisticUpdate.deserialize | large-fixture | 1031 | 507904 | 876.1 | 529.2 | 1.7x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | medium-fixture | 1013 | 507904 | 956.9 | 572.9 | 1.7x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | small-fixture | 1000 | 507904 | 840.7 | 520.4 | 1.6x | 5x | yes |
| LightClientOptimisticUpdate.hash_tree_root | large-fixture | 1031 | 24576 | 13875.3 | 3610.7 | 3.8x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | medium-fixture | 1013 | 32768 | 13793.9 | 3606.4 | 3.8x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | small-fixture | 1000 | 24576 | 14241.5 | 3609.7 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.serialize | large-fixture | 1031 | 524288 | 625.6 | 121.5 | 5.1x | 5x | no |
| LightClientOptimisticUpdate.serialize | medium-fixture | 1013 | 524288 | 558.9 | 107.3 | 5.2x | 5x | no |
| LightClientOptimisticUpdate.serialize | small-fixture | 1000 | 524288 | 545.5 | 107.6 | 5.1x | 5x | no |
| LightClientUpdate.deserialize | large-fixture | 26914 | 73728 | 7080.1 | 10746.7 | 0.7x | 5x | yes |
| LightClientUpdate.deserialize | medium-fixture | 26893 | 40960 | 7177.7 | 11483.7 | 0.6x | 5x | yes |
| LightClientUpdate.deserialize | small-fixture | 26885 | 73728 | 7270.0 | 11436.7 | 0.6x | 5x | yes |
| LightClientUpdate.hash_tree_root | large-fixture | 26914 | 1280 | 332812.5 | 86819.1 | 3.8x | 10x | yes |
| LightClientUpdate.hash_tree_root | medium-fixture | 26893 | 1408 | 334517.0 | 87888.1 | 3.8x | 10x | yes |
| LightClientUpdate.hash_tree_root | small-fixture | 26885 | 1280 | 331250.0 | 87920.7 | 3.8x | 10x | yes |
| LightClientUpdate.serialize | large-fixture | 26914 | 81920 | 5444.3 | 2180.9 | 2.5x | 5x | yes |
| LightClientUpdate.serialize | medium-fixture | 26893 | 81920 | 5297.9 | 2115.7 | 2.5x | 5x | yes |
| LightClientUpdate.serialize | small-fixture | 26885 | 81920 | 5212.4 | 2087.9 | 2.5x | 5x | yes |
| MatrixEntry.deserialize | large-fixture | 2112 | 524288 | 661.8 | 193.4 | 3.4x | 5x | yes |
| MatrixEntry.deserialize | medium-fixture | 2112 | 524288 | 656.1 | 194.1 | 3.4x | 5x | yes |
| MatrixEntry.deserialize | small-fixture | 2112 | 524288 | 648.5 | 195.8 | 3.3x | 5x | yes |
| MatrixEntry.hash_tree_root | large-fixture | 2112 | 24576 | 19246.4 | 4769.2 | 4.0x | 10x | yes |
| MatrixEntry.hash_tree_root | medium-fixture | 2112 | 16384 | 19409.2 | 4769.7 | 4.1x | 10x | yes |
| MatrixEntry.hash_tree_root | small-fixture | 2112 | 12288 | 19368.5 | 4753.9 | 4.1x | 10x | yes |
| MatrixEntry.serialize | large-fixture | 2112 | 524288 | 604.6 | 162.4 | 3.7x | 5x | yes |
| MatrixEntry.serialize | medium-fixture | 2112 | 524288 | 589.4 | 159.6 | 3.7x | 5x | yes |
| MatrixEntry.serialize | small-fixture | 2112 | 524288 | 600.8 | 155.2 | 3.9x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | random | 192 | 4718592 | 112.3 | 43.8 | 2.6x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | saturated | 192 | 4718592 | 114.4 | 43.7 | 2.6x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | zero | 192 | 4718592 | 109.8 | 42.0 | 2.6x | 5x | yes |
| NextSyncCommitteeBranch.hash_tree_root | random | 192 | 221184 | 2061.6 | 638.5 | 3.2x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | saturated | 192 | 221184 | 2115.9 | 650.5 | 3.3x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | zero | 192 | 221184 | 2061.6 | 635.3 | 3.2x | 10x | yes |
| NextSyncCommitteeBranch.serialize | random | 192 | 4194304 | 105.9 | 23.7 | 4.5x | 5x | yes |
| NextSyncCommitteeBranch.serialize | saturated | 192 | 4194304 | 108.2 | 22.9 | 4.7x | 5x | yes |
| NextSyncCommitteeBranch.serialize | zero | 192 | 4194304 | 103.0 | 23.6 | 4.4x | 5x | yes |
| NodeID.deserialize | random | 32 | 5000000 | 35.0 | 34.3 | 1.0x | 5x | yes |
| NodeID.deserialize | saturated | 32 | 5000000 | 35.0 | 34.8 | 1.0x | 5x | yes |
| NodeID.deserialize | zero | 32 | 5000000 | 27.2 | 31.7 | 0.9x | 5x | yes |
| NodeID.hash_tree_root | random | 32 | 5000000 | 6.8 | 161.9 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | saturated | 32 | 5000000 | 7.0 | 158.9 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | zero | 32 | 5000000 | 7.2 | 167.9 | 0.0x | 10x | yes |
| NodeID.serialize | random | 32 | 5000000 | 11.6 | 15.9 | 0.7x | 5x | yes |
| NodeID.serialize | saturated | 32 | 5000000 | 11.6 | 15.9 | 0.7x | 5x | yes |
| NodeID.serialize | zero | 32 | 5000000 | 10.6 | 16.0 | 0.7x | 5x | yes |
| ParticipationFlags.deserialize | random | 1 | 5000000 | 7.4 | 29.4 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | saturated | 1 | 5000000 | 7.4 | 29.3 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | zero | 1 | 5000000 | 7.4 | 29.8 | 0.2x | 5x | yes |
| ParticipationFlags.hash_tree_root | random | 1 | 5000000 | 6.0 | 171.5 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | saturated | 1 | 5000000 | 6.0 | 175.7 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | zero | 1 | 5000000 | 6.2 | 175.8 | 0.0x | 10x | yes |
| ParticipationFlags.serialize | random | 1 | 5000000 | 6.6 | 9.8 | 0.7x | 5x | yes |
| ParticipationFlags.serialize | saturated | 1 | 5000000 | 6.6 | 9.5 | 0.7x | 5x | yes |
| ParticipationFlags.serialize | zero | 1 | 5000000 | 6.8 | 9.7 | 0.7x | 5x | yes |
| PayloadId.deserialize | random | 8 | 5000000 | 17.4 | 30.3 | 0.6x | 5x | yes |
| PayloadId.deserialize | saturated | 8 | 5000000 | 17.4 | 29.9 | 0.6x | 5x | yes |
| PayloadId.deserialize | zero | 8 | 5000000 | 17.0 | 30.2 | 0.6x | 5x | yes |
| PayloadId.hash_tree_root | random | 8 | 5000000 | 6.6 | 177.6 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | saturated | 8 | 5000000 | 6.4 | 172.4 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | zero | 8 | 5000000 | 6.4 | 171.5 | 0.0x | 10x | yes |
| PayloadId.serialize | random | 8 | 5000000 | 8.8 | 10.6 | 0.8x | 5x | yes |
| PayloadId.serialize | saturated | 8 | 5000000 | 8.8 | 10.5 | 0.8x | 5x | yes |
| PayloadId.serialize | zero | 8 | 5000000 | 8.8 | 10.3 | 0.9x | 5x | yes |
| PendingAttestation.deserialize | large-fixture | 150 | 3145728 | 171.7 | 82.6 | 2.1x | 5x | yes |
| PendingAttestation.deserialize | medium-fixture | 149 | 3145728 | 183.4 | 82.9 | 2.2x | 5x | yes |
| PendingAttestation.deserialize | small-fixture | 149 | 2621440 | 169.0 | 79.5 | 2.1x | 5x | yes |
| PendingAttestation.hash_tree_root | large-fixture | 150 | 106496 | 4234.9 | 1174.1 | 3.6x | 10x | yes |
| PendingAttestation.hash_tree_root | medium-fixture | 149 | 98304 | 4272.5 | 1173.0 | 3.6x | 10x | yes |
| PendingAttestation.hash_tree_root | small-fixture | 149 | 106496 | 4300.6 | 1173.0 | 3.7x | 10x | yes |
| PendingAttestation.serialize | large-fixture | 150 | 3145728 | 136.7 | 28.8 | 4.7x | 5x | yes |
| PendingAttestation.serialize | medium-fixture | 149 | 3145728 | 143.7 | 30.6 | 4.7x | 5x | yes |
| PendingAttestation.serialize | small-fixture | 149 | 3145728 | 138.0 | 30.6 | 4.5x | 5x | yes |
| PendingConsolidation.deserialize | large-fixture | 16 | 5000000 | 16.2 | 11.9 | 1.4x | 5x | yes |
| PendingConsolidation.deserialize | medium-fixture | 16 | 5000000 | 16.2 | 12.1 | 1.3x | 5x | yes |
| PendingConsolidation.deserialize | small-fixture | 16 | 5000000 | 16.6 | 12.0 | 1.4x | 5x | yes |
| PendingConsolidation.hash_tree_root | large-fixture | 16 | 1048576 | 300.4 | 111.4 | 2.7x | 10x | yes |
| PendingConsolidation.hash_tree_root | medium-fixture | 16 | 1048576 | 300.4 | 111.6 | 2.7x | 10x | yes |
| PendingConsolidation.hash_tree_root | small-fixture | 16 | 1048576 | 293.7 | 108.7 | 2.7x | 10x | yes |
| PendingConsolidation.serialize | large-fixture | 16 | 5000000 | 7.8 | 15.1 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | medium-fixture | 16 | 5000000 | 7.8 | 15.1 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | small-fixture | 16 | 5000000 | 8.0 | 15.2 | 0.5x | 5x | yes |
| PendingDeposit.deserialize | large-fixture | 192 | 4718592 | 105.5 | 46.3 | 2.3x | 5x | yes |
| PendingDeposit.deserialize | medium-fixture | 192 | 4718592 | 112.3 | 47.1 | 2.4x | 5x | yes |
| PendingDeposit.deserialize | small-fixture | 192 | 4718592 | 108.5 | 45.9 | 2.4x | 5x | yes |
| PendingDeposit.hash_tree_root | large-fixture | 192 | 155648 | 2833.3 | 783.1 | 3.6x | 10x | yes |
| PendingDeposit.hash_tree_root | medium-fixture | 192 | 139264 | 2807.6 | 776.0 | 3.6x | 10x | yes |
| PendingDeposit.hash_tree_root | small-fixture | 192 | 155648 | 2801.2 | 767.9 | 3.6x | 10x | yes |
| PendingDeposit.serialize | large-fixture | 192 | 5000000 | 53.8 | 27.8 | 1.9x | 5x | yes |
| PendingDeposit.serialize | medium-fixture | 192 | 5000000 | 53.4 | 27.6 | 1.9x | 5x | yes |
| PendingDeposit.serialize | small-fixture | 192 | 5000000 | 56.2 | 29.7 | 1.9x | 5x | yes |
| PendingPartialWithdrawal.deserialize | large-fixture | 24 | 5000000 | 21.6 | 14.3 | 1.5x | 5x | yes |
| PendingPartialWithdrawal.deserialize | medium-fixture | 24 | 5000000 | 22.4 | 14.5 | 1.5x | 5x | yes |
| PendingPartialWithdrawal.deserialize | small-fixture | 24 | 5000000 | 24.8 | 17.3 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.hash_tree_root | large-fixture | 24 | 253952 | 921.4 | 265.2 | 3.5x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | medium-fixture | 24 | 409600 | 886.2 | 264.2 | 3.4x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | small-fixture | 24 | 204800 | 981.4 | 292.1 | 3.4x | 10x | yes |
| PendingPartialWithdrawal.serialize | large-fixture | 24 | 5000000 | 8.2 | 17.4 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | medium-fixture | 24 | 5000000 | 8.2 | 18.2 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | small-fixture | 24 | 5000000 | 11.4 | 24.3 | 0.5x | 5x | yes |
| PowBlock.deserialize | large-fixture | 96 | 5000000 | 52.2 | 72.1 | 0.7x | 5x | yes |
| PowBlock.deserialize | medium-fixture | 96 | 5000000 | 50.4 | 73.5 | 0.7x | 5x | yes |
| PowBlock.deserialize | small-fixture | 96 | 5000000 | 50.6 | 67.9 | 0.7x | 5x | yes |
| PowBlock.hash_tree_root | large-fixture | 96 | 253952 | 889.9 | 265.9 | 3.3x | 10x | yes |
| PowBlock.hash_tree_root | medium-fixture | 96 | 409600 | 878.9 | 263.8 | 3.3x | 10x | yes |
| PowBlock.hash_tree_root | small-fixture | 96 | 253952 | 889.9 | 267.0 | 3.3x | 10x | yes |
| PowBlock.serialize | large-fixture | 96 | 5000000 | 26.6 | 22.5 | 1.2x | 5x | yes |
| PowBlock.serialize | medium-fixture | 96 | 5000000 | 30.0 | 26.3 | 1.1x | 5x | yes |
| PowBlock.serialize | small-fixture | 96 | 5000000 | 25.6 | 22.9 | 1.1x | 5x | yes |
| ProposerSlashing.deserialize | large-fixture | 416 | 1572864 | 359.9 | 107.9 | 3.3x | 5x | yes |
| ProposerSlashing.deserialize | medium-fixture | 416 | 1572864 | 347.8 | 105.5 | 3.3x | 5x | yes |
| ProposerSlashing.deserialize | small-fixture | 416 | 1572864 | 363.0 | 108.0 | 3.4x | 5x | yes |
| ProposerSlashing.hash_tree_root | large-fixture | 416 | 65536 | 6027.2 | 1639.4 | 3.7x | 10x | yes |
| ProposerSlashing.hash_tree_root | medium-fixture | 416 | 65536 | 6088.3 | 1654.0 | 3.7x | 10x | yes |
| ProposerSlashing.hash_tree_root | small-fixture | 416 | 73728 | 6659.6 | 1799.7 | 3.7x | 10x | yes |
| ProposerSlashing.serialize | large-fixture | 416 | 1572864 | 221.9 | 46.6 | 4.8x | 5x | yes |
| ProposerSlashing.serialize | medium-fixture | 416 | 2097152 | 221.3 | 46.1 | 4.8x | 5x | yes |
| ProposerSlashing.serialize | small-fixture | 416 | 2097152 | 219.3 | 47.5 | 4.6x | 5x | yes |
| Root.deserialize | random | 32 | 5000000 | 27.2 | 35.0 | 0.8x | 5x | yes |
| Root.deserialize | saturated | 32 | 5000000 | 25.6 | 35.7 | 0.7x | 5x | yes |
| Root.deserialize | zero | 32 | 5000000 | 23.8 | 31.3 | 0.8x | 5x | yes |
| Root.hash_tree_root | random | 32 | 5000000 | 6.8 | 161.0 | 0.0x | 10x | yes |
| Root.hash_tree_root | saturated | 32 | 5000000 | 6.8 | 160.1 | 0.0x | 10x | yes |
| Root.hash_tree_root | zero | 32 | 5000000 | 6.8 | 167.5 | 0.0x | 10x | yes |
| Root.serialize | random | 32 | 5000000 | 10.8 | 16.1 | 0.7x | 5x | yes |
| Root.serialize | saturated | 32 | 5000000 | 11.2 | 16.2 | 0.7x | 5x | yes |
| Root.serialize | zero | 32 | 5000000 | 11.0 | 16.2 | 0.7x | 5x | yes |
| RowIndex.deserialize | random | 8 | 5000000 | 17.8 | 30.5 | 0.6x | 5x | yes |
| RowIndex.deserialize | saturated | 8 | 5000000 | 23.4 | 39.4 | 0.6x | 5x | yes |
| RowIndex.deserialize | zero | 8 | 5000000 | 17.8 | 29.5 | 0.6x | 5x | yes |
| RowIndex.hash_tree_root | random | 8 | 5000000 | 7.8 | 221.8 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | saturated | 8 | 5000000 | 7.6 | 216.6 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | zero | 8 | 5000000 | 6.4 | 169.6 | 0.0x | 10x | yes |
| RowIndex.serialize | random | 8 | 5000000 | 7.8 | 10.6 | 0.7x | 5x | yes |
| RowIndex.serialize | saturated | 8 | 5000000 | 9.2 | 12.4 | 0.7x | 5x | yes |
| RowIndex.serialize | zero | 8 | 5000000 | 7.8 | 10.6 | 0.7x | 5x | yes |
| SignedAggregateAndProof.deserialize | large-fixture | 446 | 1048576 | 453.9 | 166.2 | 2.7x | 5x | yes |
| SignedAggregateAndProof.deserialize | medium-fixture | 445 | 1048576 | 458.7 | 167.8 | 2.7x | 5x | yes |
| SignedAggregateAndProof.deserialize | small-fixture | 445 | 1048576 | 602.7 | 196.1 | 3.1x | 5x | yes |
| SignedAggregateAndProof.hash_tree_root | large-fixture | 446 | 40960 | 9838.9 | 2594.1 | 3.8x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | medium-fixture | 445 | 57344 | 7167.3 | 1974.4 | 3.6x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | small-fixture | 445 | 40960 | 9814.5 | 2616.1 | 3.8x | 10x | yes |
| SignedAggregateAndProof.serialize | large-fixture | 446 | 786432 | 317.9 | 59.7 | 5.3x | 5x | no |
| SignedAggregateAndProof.serialize | medium-fixture | 445 | 1048576 | 322.3 | 59.2 | 5.4x | 5x | no |
| SignedAggregateAndProof.serialize | small-fixture | 445 | 1048576 | 336.6 | 61.4 | 5.5x | 5x | no |
| SignedBLSToExecutionChange.deserialize | large-fixture | 172 | 4194304 | 117.1 | 42.1 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | medium-fixture | 172 | 2359296 | 114.9 | 39.2 | 2.9x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | small-fixture | 172 | 4194304 | 128.3 | 43.1 | 3.0x | 5x | yes |
| SignedBLSToExecutionChange.hash_tree_root | large-fixture | 172 | 102400 | 2363.3 | 662.7 | 3.6x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | medium-fixture | 172 | 180224 | 2319.3 | 645.8 | 3.6x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | small-fixture | 172 | 180224 | 2274.9 | 652.1 | 3.5x | 10x | yes |
| SignedBLSToExecutionChange.serialize | large-fixture | 172 | 5000000 | 51.2 | 29.3 | 1.7x | 5x | yes |
| SignedBLSToExecutionChange.serialize | medium-fixture | 172 | 4980736 | 49.2 | 29.1 | 1.7x | 5x | yes |
| SignedBLSToExecutionChange.serialize | small-fixture | 172 | 5000000 | 48.4 | 27.9 | 1.7x | 5x | yes |
| SignedBeaconBlock.deserialize | large-fixture | 23999 | 16384 | 34362.8 | 12182.3 | 2.8x | 5x | yes |
| SignedBeaconBlock.deserialize | medium-fixture | 18718 | 16384 | 26916.5 | 9326.7 | 2.9x | 5x | yes |
| SignedBeaconBlock.deserialize | small-fixture | 16683 | 24576 | 20874.0 | 8891.2 | 2.3x | 5x | yes |
| SignedBeaconBlock.hash_tree_root | large-fixture | 23999 | 1152 | 358506.9 | 91407.7 | 3.9x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | medium-fixture | 18718 | 1408 | 289062.5 | 75283.6 | 3.8x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | small-fixture | 16683 | 1792 | 239397.3 | 61792.3 | 3.9x | 10x | yes |
| SignedBeaconBlock.serialize | large-fixture | 23999 | 32768 | 12237.5 | 1694.7 | 7.2x | 5x | no |
| SignedBeaconBlock.serialize | medium-fixture | 18718 | 40960 | 11181.6 | 1337.9 | 8.4x | 5x | no |
| SignedBeaconBlock.serialize | small-fixture | 16683 | 49152 | 9012.9 | 1238.4 | 7.3x | 5x | no |
| SignedBeaconBlockHeader.deserialize | large-fixture | 208 | 3145728 | 167.5 | 43.2 | 3.9x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | medium-fixture | 208 | 3145728 | 171.0 | 43.4 | 3.9x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | small-fixture | 208 | 2621440 | 172.8 | 43.3 | 4.0x | 5x | yes |
| SignedBeaconBlockHeader.hash_tree_root | large-fixture | 208 | 155648 | 2794.8 | 771.4 | 3.6x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | medium-fixture | 208 | 155648 | 2743.4 | 746.6 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | small-fixture | 208 | 139264 | 2778.9 | 765.0 | 3.6x | 10x | yes |
| SignedBeaconBlockHeader.serialize | large-fixture | 208 | 5000000 | 56.4 | 28.9 | 2.0x | 5x | yes |
| SignedBeaconBlockHeader.serialize | medium-fixture | 208 | 5000000 | 55.6 | 29.8 | 1.9x | 5x | yes |
| SignedBeaconBlockHeader.serialize | small-fixture | 208 | 5000000 | 56.8 | 28.7 | 2.0x | 5x | yes |
| SignedContributionAndProof.deserialize | large-fixture | 360 | 2097152 | 240.3 | 100.9 | 2.4x | 5x | yes |
| SignedContributionAndProof.deserialize | medium-fixture | 360 | 2097152 | 235.6 | 99.4 | 2.4x | 5x | yes |
| SignedContributionAndProof.deserialize | small-fixture | 360 | 2097152 | 244.6 | 101.9 | 2.4x | 5x | yes |
| SignedContributionAndProof.hash_tree_root | large-fixture | 360 | 81920 | 5224.6 | 1387.4 | 3.8x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | medium-fixture | 360 | 81920 | 5273.4 | 1445.3 | 3.6x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | small-fixture | 360 | 81920 | 5407.7 | 1442.6 | 3.7x | 10x | yes |
| SignedContributionAndProof.serialize | large-fixture | 360 | 1572864 | 241.0 | 43.7 | 5.5x | 5x | no |
| SignedContributionAndProof.serialize | medium-fixture | 360 | 1572864 | 244.8 | 43.3 | 5.7x | 5x | no |
| SignedContributionAndProof.serialize | small-fixture | 360 | 1572864 | 241.6 | 43.5 | 5.5x | 5x | no |
| SignedVoluntaryExit.deserialize | large-fixture | 112 | 5000000 | 60.0 | 33.4 | 1.8x | 5x | yes |
| SignedVoluntaryExit.deserialize | medium-fixture | 112 | 5000000 | 64.8 | 34.9 | 1.9x | 5x | yes |
| SignedVoluntaryExit.deserialize | small-fixture | 112 | 5000000 | 59.6 | 33.4 | 1.8x | 5x | yes |
| SignedVoluntaryExit.hash_tree_root | large-fixture | 112 | 286720 | 1402.1 | 419.9 | 3.3x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | medium-fixture | 112 | 286720 | 1377.7 | 403.1 | 3.4x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | small-fixture | 112 | 286720 | 1388.1 | 410.6 | 3.4x | 10x | yes |
| SignedVoluntaryExit.serialize | large-fixture | 112 | 5000000 | 28.2 | 22.6 | 1.2x | 5x | yes |
| SignedVoluntaryExit.serialize | medium-fixture | 112 | 5000000 | 28.2 | 23.2 | 1.2x | 5x | yes |
| SignedVoluntaryExit.serialize | small-fixture | 112 | 5000000 | 28.2 | 24.0 | 1.2x | 5x | yes |
| SigningData.deserialize | large-fixture | 64 | 5000000 | 41.2 | 14.6 | 2.8x | 5x | yes |
| SigningData.deserialize | medium-fixture | 64 | 5000000 | 41.0 | 14.8 | 2.8x | 5x | yes |
| SigningData.deserialize | small-fixture | 64 | 5000000 | 41.0 | 14.5 | 2.8x | 5x | yes |
| SigningData.hash_tree_root | large-fixture | 64 | 1048576 | 306.1 | 112.2 | 2.7x | 10x | yes |
| SigningData.hash_tree_root | medium-fixture | 64 | 1048576 | 294.7 | 108.5 | 2.7x | 10x | yes |
| SigningData.hash_tree_root | small-fixture | 64 | 1048576 | 291.8 | 108.9 | 2.7x | 10x | yes |
| SigningData.serialize | large-fixture | 64 | 5000000 | 19.4 | 18.7 | 1.0x | 5x | yes |
| SigningData.serialize | medium-fixture | 64 | 5000000 | 19.0 | 18.0 | 1.1x | 5x | yes |
| SigningData.serialize | small-fixture | 64 | 5000000 | 19.2 | 18.3 | 1.0x | 5x | yes |
| SingleAttestation.deserialize | large-fixture | 240 | 2621440 | 199.9 | 74.8 | 2.7x | 5x | yes |
| SingleAttestation.deserialize | medium-fixture | 240 | 2621440 | 196.8 | 75.9 | 2.6x | 5x | yes |
| SingleAttestation.deserialize | small-fixture | 240 | 2621440 | 187.3 | 73.6 | 2.5x | 5x | yes |
| SingleAttestation.hash_tree_root | large-fixture | 240 | 106496 | 4047.1 | 1108.3 | 3.7x | 10x | yes |
| SingleAttestation.hash_tree_root | medium-fixture | 240 | 106496 | 4000.2 | 1116.2 | 3.6x | 10x | yes |
| SingleAttestation.hash_tree_root | small-fixture | 240 | 106496 | 3859.3 | 1082.8 | 3.6x | 10x | yes |
| SingleAttestation.serialize | large-fixture | 240 | 3932160 | 65.9 | 36.1 | 1.8x | 5x | yes |
| SingleAttestation.serialize | medium-fixture | 240 | 5000000 | 64.0 | 34.9 | 1.8x | 5x | yes |
| SingleAttestation.serialize | small-fixture | 240 | 5000000 | 63.6 | 33.2 | 1.9x | 5x | yes |
| Slot.deserialize | random | 8 | 5000000 | 14.0 | 31.4 | 0.4x | 5x | yes |
| Slot.deserialize | saturated | 8 | 5000000 | 14.0 | 31.7 | 0.4x | 5x | yes |
| Slot.deserialize | zero | 8 | 5000000 | 11.6 | 26.8 | 0.4x | 5x | yes |
| Slot.hash_tree_root | random | 8 | 5000000 | 7.0 | 179.4 | 0.0x | 10x | yes |
| Slot.hash_tree_root | saturated | 8 | 5000000 | 6.6 | 173.5 | 0.0x | 10x | yes |
| Slot.hash_tree_root | zero | 8 | 5000000 | 7.0 | 183.4 | 0.0x | 10x | yes |
| Slot.serialize | random | 8 | 5000000 | 6.8 | 10.5 | 0.6x | 5x | yes |
| Slot.serialize | saturated | 8 | 5000000 | 7.0 | 11.4 | 0.6x | 5x | yes |
| Slot.serialize | zero | 8 | 5000000 | 6.6 | 10.4 | 0.6x | 5x | yes |
| SubnetID.deserialize | random | 8 | 5000000 | 15.2 | 31.8 | 0.5x | 5x | yes |
| SubnetID.deserialize | saturated | 8 | 5000000 | 16.2 | 32.1 | 0.5x | 5x | yes |
| SubnetID.deserialize | zero | 8 | 5000000 | 16.0 | 30.3 | 0.5x | 5x | yes |
| SubnetID.hash_tree_root | random | 8 | 5000000 | 6.6 | 182.1 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | saturated | 8 | 5000000 | 6.6 | 176.8 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | zero | 8 | 5000000 | 6.4 | 175.8 | 0.0x | 10x | yes |
| SubnetID.serialize | random | 8 | 5000000 | 7.8 | 10.5 | 0.7x | 5x | yes |
| SubnetID.serialize | saturated | 8 | 5000000 | 7.8 | 10.7 | 0.7x | 5x | yes |
| SubnetID.serialize | zero | 8 | 5000000 | 7.8 | 11.2 | 0.7x | 5x | yes |
| SyncAggregate.deserialize | large-fixture | 160 | 5000000 | 105.0 | 50.9 | 2.1x | 5x | yes |
| SyncAggregate.deserialize | medium-fixture | 160 | 5000000 | 87.4 | 42.9 | 2.0x | 5x | yes |
| SyncAggregate.deserialize | small-fixture | 160 | 5000000 | 86.6 | 42.0 | 2.1x | 5x | yes |
| SyncAggregate.hash_tree_root | large-fixture | 160 | 286720 | 1447.4 | 416.7 | 3.5x | 10x | yes |
| SyncAggregate.hash_tree_root | medium-fixture | 160 | 167936 | 1482.7 | 429.0 | 3.5x | 10x | yes |
| SyncAggregate.hash_tree_root | small-fixture | 160 | 286720 | 1430.0 | 422.6 | 3.4x | 10x | yes |
| SyncAggregate.serialize | large-fixture | 160 | 5000000 | 45.2 | 26.4 | 1.7x | 5x | yes |
| SyncAggregate.serialize | medium-fixture | 160 | 5000000 | 45.4 | 26.9 | 1.7x | 5x | yes |
| SyncAggregate.serialize | small-fixture | 160 | 5000000 | 44.6 | 25.6 | 1.7x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | large-fixture | 16 | 5000000 | 14.6 | 12.5 | 1.2x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | medium-fixture | 16 | 5000000 | 14.0 | 12.0 | 1.2x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | small-fixture | 16 | 5000000 | 14.2 | 12.3 | 1.2x | 5x | yes |
| SyncAggregatorSelectionData.hash_tree_root | large-fixture | 16 | 1048576 | 299.5 | 111.6 | 2.7x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | medium-fixture | 16 | 1048576 | 298.5 | 111.6 | 2.7x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | small-fixture | 16 | 1048576 | 294.7 | 111.7 | 2.6x | 10x | yes |
| SyncAggregatorSelectionData.serialize | large-fixture | 16 | 5000000 | 7.2 | 16.2 | 0.4x | 5x | yes |
| SyncAggregatorSelectionData.serialize | medium-fixture | 16 | 5000000 | 7.0 | 15.1 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | small-fixture | 16 | 5000000 | 7.0 | 16.0 | 0.4x | 5x | yes |
| SyncCommittee.deserialize | large-fixture | 24624 | 114688 | 4664.8 | 1476.1 | 3.2x | 5x | yes |
| SyncCommittee.deserialize | medium-fixture | 24624 | 106496 | 4629.3 | 1457.8 | 3.2x | 5x | yes |
| SyncCommittee.deserialize | small-fixture | 24624 | 114688 | 4630.0 | 1414.4 | 3.3x | 5x | yes |
| SyncCommittee.hash_tree_root | large-fixture | 24624 | 1408 | 314630.7 | 89654.9 | 3.5x | 10x | yes |
| SyncCommittee.hash_tree_root | medium-fixture | 24624 | 1408 | 314630.7 | 89589.6 | 3.5x | 10x | yes |
| SyncCommittee.hash_tree_root | small-fixture | 24624 | 1408 | 314630.7 | 89739.3 | 3.5x | 10x | yes |
| SyncCommittee.serialize | large-fixture | 24624 | 106496 | 4535.4 | 1927.4 | 2.4x | 5x | yes |
| SyncCommittee.serialize | medium-fixture | 24624 | 53248 | 4432.1 | 1839.0 | 2.4x | 5x | yes |
| SyncCommittee.serialize | small-fixture | 24624 | 106496 | 4394.5 | 1826.5 | 2.4x | 5x | yes |
| SyncCommitteeContribution.deserialize | large-fixture | 160 | 5000000 | 106.6 | 44.3 | 2.4x | 5x | yes |
| SyncCommitteeContribution.deserialize | medium-fixture | 160 | 5000000 | 101.4 | 44.4 | 2.3x | 5x | yes |
| SyncCommitteeContribution.deserialize | small-fixture | 160 | 5000000 | 101.2 | 45.1 | 2.2x | 5x | yes |
| SyncCommitteeContribution.hash_tree_root | large-fixture | 160 | 155648 | 2576.3 | 704.4 | 3.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | medium-fixture | 160 | 155648 | 2634.1 | 722.6 | 3.6x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | small-fixture | 160 | 155648 | 2614.9 | 711.6 | 3.7x | 10x | yes |
| SyncCommitteeContribution.serialize | large-fixture | 160 | 5000000 | 46.4 | 28.1 | 1.6x | 5x | yes |
| SyncCommitteeContribution.serialize | medium-fixture | 160 | 5000000 | 47.6 | 27.7 | 1.7x | 5x | yes |
| SyncCommitteeContribution.serialize | small-fixture | 160 | 5000000 | 47.4 | 27.7 | 1.7x | 5x | yes |
| SyncCommitteeMessage.deserialize | large-fixture | 144 | 3407872 | 79.8 | 23.1 | 3.5x | 5x | yes |
| SyncCommitteeMessage.deserialize | medium-fixture | 144 | 5000000 | 84.0 | 22.6 | 3.7x | 5x | yes |
| SyncCommitteeMessage.deserialize | small-fixture | 144 | 3407872 | 82.5 | 23.7 | 3.5x | 5x | yes |
| SyncCommitteeMessage.hash_tree_root | large-fixture | 144 | 126976 | 1772.0 | 500.2 | 3.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | medium-fixture | 144 | 221184 | 1718.0 | 494.2 | 3.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | small-fixture | 144 | 221184 | 1803.9 | 510.6 | 3.5x | 10x | yes |
| SyncCommitteeMessage.serialize | large-fixture | 144 | 5000000 | 45.4 | 28.6 | 1.6x | 5x | yes |
| SyncCommitteeMessage.serialize | medium-fixture | 144 | 5000000 | 42.8 | 27.1 | 1.6x | 5x | yes |
| SyncCommitteeMessage.serialize | small-fixture | 144 | 5000000 | 43.6 | 28.3 | 1.5x | 5x | yes |
| Transaction.deserialize | large | 1048576 | 2048 | 272949.2 | 48793.6 | 5.6x | 5x | no |
| Transaction.deserialize | medium | 4096 | 253952 | 1185.3 | 329.4 | 3.6x | 5x | yes |
| Transaction.deserialize | small | 32 | 5000000 | 61.2 | 33.3 | 1.8x | 5x | yes |
| Transaction.hash_tree_root | large | 1048576 | 25 | 9880000.0 | 2459183.3 | 4.0x | 10x | yes |
| Transaction.hash_tree_root | medium | 4096 | 7936 | 45236.9 | 11034.6 | 4.1x | 10x | yes |
| Transaction.hash_tree_root | small | 32 | 49152 | 7649.7 | 2122.3 | 3.6x | 10x | yes |
| Transaction.serialize | large | 1048576 | 2816 | 175426.1 | 49170.9 | 3.6x | 5x | yes |
| Transaction.serialize | medium | 4096 | 524288 | 782.0 | 293.0 | 2.7x | 5x | yes |
| Transaction.serialize | small | 32 | 5000000 | 23.4 | 16.8 | 1.4x | 5x | yes |
| Validator.deserialize | large-fixture | 121 | 3407872 | 81.3 | 39.5 | 2.1x | 5x | yes |
| Validator.deserialize | medium-fixture | 121 | 3407872 | 86.6 | 43.5 | 2.0x | 5x | yes |
| Validator.deserialize | small-fixture | 121 | 3407872 | 82.7 | 40.4 | 2.0x | 5x | yes |
| Validator.hash_tree_root | large-fixture | 121 | 163840 | 2307.1 | 642.9 | 3.6x | 10x | yes |
| Validator.hash_tree_root | medium-fixture | 121 | 155648 | 2377.2 | 647.8 | 3.7x | 10x | yes |
| Validator.hash_tree_root | small-fixture | 121 | 163840 | 2331.5 | 646.3 | 3.6x | 10x | yes |
| Validator.serialize | large-fixture | 121 | 5000000 | 34.2 | 27.4 | 1.2x | 5x | yes |
| Validator.serialize | medium-fixture | 121 | 5000000 | 32.8 | 27.3 | 1.2x | 5x | yes |
| Validator.serialize | small-fixture | 121 | 5000000 | 32.6 | 27.5 | 1.2x | 5x | yes |
| ValidatorIndex.deserialize | random | 8 | 5000000 | 14.4 | 32.6 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | saturated | 8 | 5000000 | 14.6 | 33.7 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | zero | 8 | 5000000 | 11.8 | 27.3 | 0.4x | 5x | yes |
| ValidatorIndex.hash_tree_root | random | 8 | 5000000 | 6.8 | 191.5 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | saturated | 8 | 5000000 | 6.8 | 180.6 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | zero | 8 | 5000000 | 7.0 | 184.2 | 0.0x | 10x | yes |
| ValidatorIndex.serialize | random | 8 | 5000000 | 7.2 | 11.4 | 0.6x | 5x | yes |
| ValidatorIndex.serialize | saturated | 8 | 5000000 | 7.4 | 11.3 | 0.7x | 5x | yes |
| ValidatorIndex.serialize | zero | 8 | 5000000 | 6.8 | 10.6 | 0.6x | 5x | yes |
| Version.deserialize | random | 4 | 5000000 | 7.0 | 33.1 | 0.2x | 5x | yes |
| Version.deserialize | saturated | 4 | 5000000 | 6.6 | 32.6 | 0.2x | 5x | yes |
| Version.deserialize | zero | 4 | 5000000 | 7.0 | 33.8 | 0.2x | 5x | yes |
| Version.hash_tree_root | random | 4 | 5000000 | 6.4 | 182.1 | 0.0x | 10x | yes |
| Version.hash_tree_root | saturated | 4 | 5000000 | 6.8 | 193.5 | 0.0x | 10x | yes |
| Version.hash_tree_root | zero | 4 | 5000000 | 6.8 | 186.9 | 0.0x | 10x | yes |
| Version.serialize | random | 4 | 5000000 | 6.8 | 10.7 | 0.6x | 5x | yes |
| Version.serialize | saturated | 4 | 5000000 | 6.4 | 10.3 | 0.6x | 5x | yes |
| Version.serialize | zero | 4 | 5000000 | 7.0 | 11.1 | 0.6x | 5x | yes |
| VersionedHash.deserialize | random | 32 | 5000000 | 28.8 | 35.4 | 0.8x | 5x | yes |
| VersionedHash.deserialize | saturated | 32 | 5000000 | 28.0 | 36.7 | 0.8x | 5x | yes |
| VersionedHash.deserialize | zero | 32 | 5000000 | 28.0 | 36.7 | 0.8x | 5x | yes |
| VersionedHash.hash_tree_root | random | 32 | 5000000 | 7.2 | 170.0 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | saturated | 32 | 5000000 | 6.8 | 168.6 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | zero | 32 | 5000000 | 6.6 | 172.8 | 0.0x | 10x | yes |
| VersionedHash.serialize | random | 32 | 5000000 | 12.6 | 16.7 | 0.8x | 5x | yes |
| VersionedHash.serialize | saturated | 32 | 5000000 | 12.8 | 17.8 | 0.7x | 5x | yes |
| VersionedHash.serialize | zero | 32 | 5000000 | 11.0 | 17.1 | 0.6x | 5x | yes |
| VoluntaryExit.deserialize | large-fixture | 16 | 5000000 | 17.4 | 12.6 | 1.4x | 5x | yes |
| VoluntaryExit.deserialize | medium-fixture | 16 | 5000000 | 16.6 | 12.4 | 1.3x | 5x | yes |
| VoluntaryExit.deserialize | small-fixture | 16 | 5000000 | 19.6 | 14.1 | 1.4x | 5x | yes |
| VoluntaryExit.hash_tree_root | large-fixture | 16 | 1048576 | 311.9 | 114.6 | 2.7x | 10x | yes |
| VoluntaryExit.hash_tree_root | medium-fixture | 16 | 1048576 | 311.9 | 113.7 | 2.7x | 10x | yes |
| VoluntaryExit.hash_tree_root | small-fixture | 16 | 1048576 | 300.4 | 111.3 | 2.7x | 10x | yes |
| VoluntaryExit.serialize | large-fixture | 16 | 5000000 | 8.8 | 16.3 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | medium-fixture | 16 | 5000000 | 8.8 | 15.9 | 0.6x | 5x | yes |
| VoluntaryExit.serialize | small-fixture | 16 | 5000000 | 8.8 | 16.3 | 0.5x | 5x | yes |
| Withdrawal.deserialize | large-fixture | 44 | 5000000 | 36.0 | 14.8 | 2.4x | 5x | yes |
| Withdrawal.deserialize | medium-fixture | 44 | 5000000 | 36.2 | 15.5 | 2.3x | 5x | yes |
| Withdrawal.deserialize | small-fixture | 44 | 5000000 | 35.2 | 15.2 | 2.3x | 5x | yes |
| Withdrawal.hash_tree_root | large-fixture | 44 | 409600 | 893.6 | 270.5 | 3.3x | 10x | yes |
| Withdrawal.hash_tree_root | medium-fixture | 44 | 253952 | 929.3 | 273.1 | 3.4x | 10x | yes |
| Withdrawal.hash_tree_root | small-fixture | 44 | 253952 | 901.7 | 271.7 | 3.3x | 10x | yes |
| Withdrawal.serialize | large-fixture | 44 | 5000000 | 15.2 | 19.0 | 0.8x | 5x | yes |
| Withdrawal.serialize | medium-fixture | 44 | 5000000 | 15.4 | 19.2 | 0.8x | 5x | yes |
| Withdrawal.serialize | small-fixture | 44 | 5000000 | 15.2 | 19.5 | 0.8x | 5x | yes |
| WithdrawalIndex.deserialize | random | 8 | 5000000 | 18.0 | 31.4 | 0.6x | 5x | yes |
| WithdrawalIndex.deserialize | saturated | 8 | 5000000 | 18.8 | 31.7 | 0.6x | 5x | yes |
| WithdrawalIndex.deserialize | zero | 8 | 5000000 | 16.0 | 28.3 | 0.6x | 5x | yes |
| WithdrawalIndex.hash_tree_root | random | 8 | 5000000 | 6.6 | 183.8 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | saturated | 8 | 5000000 | 7.0 | 182.1 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | zero | 8 | 5000000 | 7.0 | 189.7 | 0.0x | 10x | yes |
| WithdrawalIndex.serialize | random | 8 | 5000000 | 8.0 | 10.4 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | saturated | 8 | 5000000 | 8.2 | 10.7 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | zero | 8 | 5000000 | 8.0 | 11.0 | 0.7x | 5x | yes |
| WithdrawalRequest.deserialize | large-fixture | 76 | 5000000 | 41.2 | 16.9 | 2.4x | 5x | yes |
| WithdrawalRequest.deserialize | medium-fixture | 76 | 5000000 | 40.0 | 16.9 | 2.4x | 5x | yes |
| WithdrawalRequest.deserialize | small-fixture | 76 | 5000000 | 46.2 | 19.2 | 2.4x | 5x | yes |
| WithdrawalRequest.hash_tree_root | large-fixture | 76 | 335872 | 1188.0 | 353.0 | 3.4x | 10x | yes |
| WithdrawalRequest.hash_tree_root | medium-fixture | 76 | 335872 | 1185.0 | 353.4 | 3.4x | 10x | yes |
| WithdrawalRequest.hash_tree_root | small-fixture | 76 | 335872 | 1182.0 | 352.3 | 3.4x | 10x | yes |
| WithdrawalRequest.serialize | large-fixture | 76 | 5000000 | 24.2 | 22.3 | 1.1x | 5x | yes |
| WithdrawalRequest.serialize | medium-fixture | 76 | 5000000 | 23.4 | 22.1 | 1.1x | 5x | yes |
| WithdrawalRequest.serialize | small-fixture | 76 | 5000000 | 23.0 | 21.4 | 1.1x | 5x | yes |
| boolean.deserialize | false | 1 | 5000000 | 6.8 | 27.0 | 0.3x | 5x | yes |
| boolean.deserialize | true | 1 | 5000000 | 8.0 | 31.8 | 0.3x | 5x | yes |
| boolean.hash_tree_root | false | 1 | 5000000 | 6.8 | 195.8 | 0.0x | 10x | yes |
| boolean.hash_tree_root | true | 1 | 5000000 | 6.6 | 174.8 | 0.0x | 10x | yes |
| boolean.serialize | false | 1 | 5000000 | 5.8 | 9.8 | 0.6x | 5x | yes |
| boolean.serialize | true | 1 | 5000000 | 5.8 | 10.2 | 0.6x | 5x | yes |
| uint256.deserialize | random | 32 | 5000000 | 24.0 | 38.2 | 0.6x | 5x | yes |
| uint256.deserialize | saturated | 32 | 5000000 | 22.8 | 38.0 | 0.6x | 5x | yes |
| uint256.deserialize | zero | 32 | 5000000 | 22.6 | 37.7 | 0.6x | 5x | yes |
| uint256.hash_tree_root | random | 32 | 5000000 | 7.2 | 167.4 | 0.0x | 10x | yes |
| uint256.hash_tree_root | saturated | 32 | 5000000 | 7.2 | 165.8 | 0.0x | 10x | yes |
| uint256.hash_tree_root | zero | 32 | 5000000 | 7.2 | 170.5 | 0.0x | 10x | yes |
| uint256.serialize | random | 32 | 5000000 | 10.0 | 17.4 | 0.6x | 5x | yes |
| uint256.serialize | saturated | 32 | 5000000 | 9.6 | 17.4 | 0.6x | 5x | yes |
| uint256.serialize | zero | 32 | 5000000 | 9.8 | 17.2 | 0.6x | 5x | yes |
| uint32.deserialize | random | 4 | 5000000 | 6.6 | 33.5 | 0.2x | 5x | yes |
| uint32.deserialize | saturated | 4 | 5000000 | 6.6 | 33.3 | 0.2x | 5x | yes |
| uint32.deserialize | zero | 4 | 5000000 | 6.8 | 33.0 | 0.2x | 5x | yes |
| uint32.hash_tree_root | random | 4 | 5000000 | 6.4 | 184.6 | 0.0x | 10x | yes |
| uint32.hash_tree_root | saturated | 4 | 5000000 | 6.6 | 181.8 | 0.0x | 10x | yes |
| uint32.hash_tree_root | zero | 4 | 5000000 | 6.4 | 186.6 | 0.0x | 10x | yes |
| uint32.serialize | random | 4 | 5000000 | 6.4 | 10.8 | 0.6x | 5x | yes |
| uint32.serialize | saturated | 4 | 5000000 | 6.0 | 10.7 | 0.6x | 5x | yes |
| uint32.serialize | zero | 4 | 5000000 | 6.6 | 11.2 | 0.6x | 5x | yes |
| uint64.deserialize | random | 8 | 5000000 | 15.6 | 36.1 | 0.4x | 5x | yes |
| uint64.deserialize | saturated | 8 | 5000000 | 14.2 | 32.4 | 0.4x | 5x | yes |
| uint64.deserialize | zero | 8 | 5000000 | 14.0 | 32.6 | 0.4x | 5x | yes |
| uint64.hash_tree_root | random | 8 | 5000000 | 6.8 | 178.3 | 0.0x | 10x | yes |
| uint64.hash_tree_root | saturated | 8 | 5000000 | 6.4 | 181.8 | 0.0x | 10x | yes |
| uint64.hash_tree_root | zero | 8 | 5000000 | 7.6 | 211.7 | 0.0x | 10x | yes |
| uint64.serialize | random | 8 | 5000000 | 7.2 | 11.6 | 0.6x | 5x | yes |
| uint64.serialize | saturated | 8 | 5000000 | 7.0 | 10.9 | 0.6x | 5x | yes |
| uint64.serialize | zero | 8 | 5000000 | 7.8 | 12.4 | 0.6x | 5x | yes |
| uint8.deserialize | random | 1 | 5000000 | 7.8 | 35.0 | 0.2x | 5x | yes |
| uint8.deserialize | saturated | 1 | 5000000 | 6.8 | 30.2 | 0.2x | 5x | yes |
| uint8.deserialize | zero | 1 | 5000000 | 6.8 | 31.6 | 0.2x | 5x | yes |
| uint8.hash_tree_root | random | 1 | 5000000 | 6.4 | 180.3 | 0.0x | 10x | yes |
| uint8.hash_tree_root | saturated | 1 | 5000000 | 6.4 | 181.5 | 0.0x | 10x | yes |
| uint8.hash_tree_root | zero | 1 | 5000000 | 7.6 | 204.9 | 0.0x | 10x | yes |
| uint8.serialize | random | 1 | 5000000 | 6.4 | 10.7 | 0.6x | 5x | yes |
| uint8.serialize | saturated | 1 | 5000000 | 6.0 | 9.7 | 0.6x | 5x | yes |
| uint8.serialize | zero | 1 | 5000000 | 6.2 | 10.2 | 0.6x | 5x | yes |

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
