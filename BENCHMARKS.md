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

Ratio distribution over all measured workloads: minimum 0.0x, median 1.1x, maximum 5.9x.

* `deserialize`: 326 workloads, minimum 0.1x, median 1.0x, maximum 4.3x (limit 5x).
* `serialize`: 326 workloads, minimum 0.4x, median 0.8x, maximum 4.1x (limit 5x).
* `hash_tree_root`: 326 workloads, minimum 0.0x, median 2.8x, maximum 5.9x (limit 10x).

## What the numbers say

Every measured workload is within its limit.

## All measured workloads

| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |
|---|---|---:|---:|---:|---:|---:|---:|:--:|
| AggregateAndProof.deserialize | large-fixture | 346 | 2097152 | 229.8 | 107.6 | 2.1x | 5x | yes |
| AggregateAndProof.deserialize | medium-fixture | 345 | 2097152 | 234.1 | 108.1 | 2.2x | 5x | yes |
| AggregateAndProof.deserialize | small-fixture | 345 | 1572864 | 239.7 | 115.3 | 2.1x | 5x | yes |
| AggregateAndProof.hash_tree_root | large-fixture | 346 | 57344 | 8109.0 | 2121.4 | 3.8x | 10x | yes |
| AggregateAndProof.hash_tree_root | medium-fixture | 345 | 73728 | 5683.1 | 1519.8 | 3.7x | 10x | yes |
| AggregateAndProof.hash_tree_root | small-fixture | 345 | 49152 | 8097.3 | 2125.3 | 3.8x | 10x | yes |
| AggregateAndProof.serialize | large-fixture | 346 | 4194304 | 117.5 | 39.5 | 3.0x | 5x | yes |
| AggregateAndProof.serialize | medium-fixture | 345 | 4194304 | 120.2 | 41.1 | 2.9x | 5x | yes |
| AggregateAndProof.serialize | small-fixture | 345 | 3670016 | 127.2 | 42.3 | 3.0x | 5x | yes |
| Attestation.deserialize | large-fixture | 237 | 2621440 | 159.8 | 87.8 | 1.8x | 5x | yes |
| Attestation.deserialize | medium-fixture | 237 | 2621440 | 166.7 | 87.8 | 1.9x | 5x | yes |
| Attestation.deserialize | small-fixture | 237 | 2621440 | 159.5 | 86.5 | 1.8x | 5x | yes |
| Attestation.hash_tree_root | large-fixture | 237 | 73728 | 6496.9 | 1704.1 | 3.8x | 10x | yes |
| Attestation.hash_tree_root | medium-fixture | 237 | 65536 | 6500.2 | 1705.0 | 3.8x | 10x | yes |
| Attestation.hash_tree_root | small-fixture | 237 | 65536 | 6500.2 | 1101.3 | 5.9x | 10x | yes |
| Attestation.serialize | large-fixture | 237 | 4194304 | 108.2 | 31.2 | 3.5x | 5x | yes |
| Attestation.serialize | medium-fixture | 237 | 4194304 | 112.5 | 31.0 | 3.6x | 5x | yes |
| Attestation.serialize | small-fixture | 237 | 4194304 | 111.6 | 31.2 | 3.6x | 5x | yes |
| AttestationData.deserialize | large-fixture | 128 | 5000000 | 85.0 | 38.3 | 2.2x | 5x | yes |
| AttestationData.deserialize | medium-fixture | 128 | 5000000 | 85.2 | 38.2 | 2.2x | 5x | yes |
| AttestationData.deserialize | small-fixture | 128 | 5000000 | 85.2 | 37.9 | 2.2x | 5x | yes |
| AttestationData.hash_tree_root | large-fixture | 128 | 221184 | 2129.4 | 600.8 | 3.5x | 10x | yes |
| AttestationData.hash_tree_root | medium-fixture | 128 | 221184 | 2124.9 | 601.0 | 3.5x | 10x | yes |
| AttestationData.hash_tree_root | small-fixture | 128 | 221184 | 2124.9 | 602.4 | 3.5x | 10x | yes |
| AttestationData.serialize | large-fixture | 128 | 5000000 | 22.8 | 19.4 | 1.2x | 5x | yes |
| AttestationData.serialize | medium-fixture | 128 | 5000000 | 22.6 | 19.2 | 1.2x | 5x | yes |
| AttestationData.serialize | small-fixture | 128 | 5000000 | 22.6 | 19.2 | 1.2x | 5x | yes |
| AttesterSlashing.deserialize | large-fixture | 624 | 1048576 | 342.4 | 179.5 | 1.9x | 5x | yes |
| AttesterSlashing.deserialize | medium-fixture | 552 | 1048576 | 345.2 | 172.7 | 2.0x | 5x | yes |
| AttesterSlashing.deserialize | small-fixture | 512 | 1048576 | 344.3 | 166.2 | 2.1x | 5x | yes |
| AttesterSlashing.hash_tree_root | large-fixture | 624 | 24576 | 16886.4 | 4415.0 | 3.8x | 10x | yes |
| AttesterSlashing.hash_tree_root | medium-fixture | 552 | 24576 | 16357.4 | 4263.1 | 3.8x | 10x | yes |
| AttesterSlashing.hash_tree_root | small-fixture | 512 | 24576 | 16357.4 | 4250.0 | 3.8x | 10x | yes |
| AttesterSlashing.serialize | large-fixture | 624 | 1310720 | 190.7 | 69.1 | 2.8x | 5x | yes |
| AttesterSlashing.serialize | medium-fixture | 552 | 2621440 | 186.9 | 56.4 | 3.3x | 5x | yes |
| AttesterSlashing.serialize | small-fixture | 512 | 2621440 | 182.0 | 56.2 | 3.2x | 5x | yes |
| BLSPubkey.deserialize | random | 48 | 5000000 | 32.6 | 28.3 | 1.2x | 5x | yes |
| BLSPubkey.deserialize | saturated | 48 | 5000000 | 31.6 | 28.2 | 1.1x | 5x | yes |
| BLSPubkey.deserialize | zero | 48 | 5000000 | 32.6 | 28.3 | 1.2x | 5x | yes |
| BLSPubkey.hash_tree_root | random | 48 | 1572864 | 274.7 | 238.0 | 1.2x | 10x | yes |
| BLSPubkey.hash_tree_root | saturated | 48 | 1572864 | 273.4 | 238.2 | 1.1x | 10x | yes |
| BLSPubkey.hash_tree_root | zero | 48 | 1572864 | 272.8 | 230.4 | 1.2x | 10x | yes |
| BLSPubkey.serialize | random | 48 | 5000000 | 10.4 | 13.1 | 0.8x | 5x | yes |
| BLSPubkey.serialize | saturated | 48 | 5000000 | 10.4 | 13.5 | 0.8x | 5x | yes |
| BLSPubkey.serialize | zero | 48 | 5000000 | 9.2 | 13.1 | 0.7x | 5x | yes |
| BLSSignature.deserialize | random | 96 | 5000000 | 48.8 | 31.0 | 1.6x | 5x | yes |
| BLSSignature.deserialize | saturated | 96 | 5000000 | 46.8 | 30.5 | 1.5x | 5x | yes |
| BLSSignature.deserialize | zero | 96 | 5000000 | 44.8 | 30.3 | 1.5x | 5x | yes |
| BLSSignature.hash_tree_root | random | 96 | 524288 | 808.7 | 371.3 | 2.2x | 10x | yes |
| BLSSignature.hash_tree_root | saturated | 96 | 524288 | 808.7 | 371.8 | 2.2x | 10x | yes |
| BLSSignature.hash_tree_root | zero | 96 | 507904 | 809.2 | 371.2 | 2.2x | 10x | yes |
| BLSSignature.serialize | random | 96 | 5000000 | 19.6 | 15.8 | 1.2x | 5x | yes |
| BLSSignature.serialize | saturated | 96 | 5000000 | 19.4 | 16.0 | 1.2x | 5x | yes |
| BLSSignature.serialize | zero | 96 | 5000000 | 18.2 | 15.9 | 1.1x | 5x | yes |
| BLSToExecutionChange.deserialize | large-fixture | 76 | 5000000 | 42.4 | 14.4 | 2.9x | 5x | yes |
| BLSToExecutionChange.deserialize | medium-fixture | 76 | 5000000 | 42.4 | 14.3 | 3.0x | 5x | yes |
| BLSToExecutionChange.deserialize | small-fixture | 76 | 5000000 | 42.4 | 14.9 | 2.9x | 5x | yes |
| BLSToExecutionChange.hash_tree_root | large-fixture | 76 | 253952 | 1067.1 | 317.7 | 3.4x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | medium-fixture | 76 | 253952 | 1067.1 | 317.4 | 3.4x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | small-fixture | 76 | 409600 | 1064.5 | 318.0 | 3.3x | 10x | yes |
| BLSToExecutionChange.serialize | large-fixture | 76 | 5000000 | 14.2 | 16.8 | 0.8x | 5x | yes |
| BLSToExecutionChange.serialize | medium-fixture | 76 | 5000000 | 14.2 | 16.0 | 0.9x | 5x | yes |
| BLSToExecutionChange.serialize | small-fixture | 76 | 5000000 | 14.2 | 16.1 | 0.9x | 5x | yes |
| BeaconBlock.deserialize | large-fixture | 21487 | 57344 | 7533.5 | 8822.8 | 0.9x | 5x | yes |
| BeaconBlock.deserialize | medium-fixture | 21424 | 65536 | 6744.4 | 7602.1 | 0.9x | 5x | yes |
| BeaconBlock.deserialize | small-fixture | 11198 | 81920 | 5822.8 | 2556.1 | 2.3x | 5x | yes |
| BeaconBlock.hash_tree_root | large-fixture | 21487 | 1664 | 290865.4 | 75295.0 | 3.9x | 10x | yes |
| BeaconBlock.hash_tree_root | medium-fixture | 21424 | 1536 | 318359.4 | 80540.1 | 4.0x | 10x | yes |
| BeaconBlock.hash_tree_root | small-fixture | 11198 | 1216 | 207236.8 | 53857.0 | 3.8x | 10x | yes |
| BeaconBlock.serialize | large-fixture | 21487 | 114688 | 4350.9 | 1393.3 | 3.1x | 5x | yes |
| BeaconBlock.serialize | medium-fixture | 21424 | 122880 | 3833.0 | 1254.9 | 3.1x | 5x | yes |
| BeaconBlock.serialize | small-fixture | 11198 | 163840 | 3057.9 | 753.3 | 4.1x | 5x | yes |
| BeaconBlockBody.deserialize | large-fixture | 24042 | 65536 | 7171.6 | 8884.4 | 0.8x | 5x | yes |
| BeaconBlockBody.deserialize | medium-fixture | 19087 | 73728 | 6266.3 | 6387.3 | 1.0x | 5x | yes |
| BeaconBlockBody.deserialize | small-fixture | 11894 | 106496 | 4441.5 | 4019.0 | 1.1x | 5x | yes |
| BeaconBlockBody.hash_tree_root | large-fixture | 24042 | 1280 | 364843.8 | 91358.2 | 4.0x | 10x | yes |
| BeaconBlockBody.hash_tree_root | medium-fixture | 19087 | 1664 | 296274.0 | 76204.8 | 3.9x | 10x | yes |
| BeaconBlockBody.hash_tree_root | small-fixture | 11894 | 2176 | 215533.1 | 55036.9 | 3.9x | 10x | yes |
| BeaconBlockBody.serialize | large-fixture | 24042 | 114688 | 4281.2 | 1479.7 | 2.9x | 5x | yes |
| BeaconBlockBody.serialize | medium-fixture | 19087 | 131072 | 3517.2 | 1132.5 | 3.1x | 5x | yes |
| BeaconBlockBody.serialize | small-fixture | 11894 | 180224 | 2668.9 | 767.0 | 3.5x | 5x | yes |
| BeaconBlockHeader.deserialize | large-fixture | 112 | 5000000 | 47.0 | 15.7 | 3.0x | 5x | yes |
| BeaconBlockHeader.deserialize | medium-fixture | 112 | 4980736 | 48.4 | 16.5 | 2.9x | 5x | yes |
| BeaconBlockHeader.deserialize | small-fixture | 112 | 5000000 | 48.6 | 16.0 | 3.0x | 5x | yes |
| BeaconBlockHeader.hash_tree_root | large-fixture | 112 | 286720 | 1597.4 | 443.2 | 3.6x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | medium-fixture | 112 | 286720 | 1590.4 | 442.6 | 3.6x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | small-fixture | 112 | 286720 | 1590.4 | 442.5 | 3.6x | 10x | yes |
| BeaconBlockHeader.serialize | large-fixture | 112 | 5000000 | 19.2 | 18.1 | 1.1x | 5x | yes |
| BeaconBlockHeader.serialize | medium-fixture | 112 | 5000000 | 19.4 | 18.1 | 1.1x | 5x | yes |
| BeaconBlockHeader.serialize | small-fixture | 112 | 5000000 | 19.2 | 18.0 | 1.1x | 5x | yes |
| BeaconState.deserialize | large-fixture | 2741095 | 1728 | 147569.4 | 188648.6 | 0.8x | 5x | yes |
| BeaconState.deserialize | medium-fixture | 2740473 | 3200 | 147500.0 | 186641.4 | 0.8x | 5x | yes |
| BeaconState.deserialize | small-fixture | 2738771 | 1728 | 146990.7 | 185612.8 | 0.8x | 5x | yes |
| BeaconState.hash_tree_root | large-fixture | 2741095 | 20 | 23700000.0 | 6776341.8 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | medium-fixture | 2740473 | 20 | 23700000.0 | 6813143.0 | 3.5x | 10x | yes |
| BeaconState.hash_tree_root | small-fixture | 2738771 | 20 | 23600000.0 | 6786493.6 | 3.5x | 10x | yes |
| BeaconState.serialize | large-fixture | 2741095 | 3456 | 139756.9 | 185842.4 | 0.8x | 5x | yes |
| BeaconState.serialize | medium-fixture | 2740473 | 3456 | 139756.9 | 185446.1 | 0.8x | 5x | yes |
| BeaconState.serialize | small-fixture | 2738771 | 3456 | 138888.9 | 184353.8 | 0.8x | 5x | yes |
| Blob.deserialize | random | 131072 | 65536 | 7247.9 | 5736.2 | 1.3x | 5x | yes |
| Blob.deserialize | saturated | 131072 | 40960 | 10083.0 | 5204.2 | 1.9x | 5x | yes |
| Blob.deserialize | zero | 131072 | 65536 | 7293.7 | 5683.9 | 1.3x | 5x | yes |
| Blob.hash_tree_root | random | 131072 | 384 | 1117187.5 | 282866.1 | 3.9x | 10x | yes |
| Blob.hash_tree_root | saturated | 131072 | 384 | 1114583.3 | 281559.8 | 4.0x | 10x | yes |
| Blob.hash_tree_root | zero | 131072 | 384 | 1114583.3 | 282726.8 | 3.9x | 10x | yes |
| Blob.serialize | random | 131072 | 81920 | 5664.1 | 5768.5 | 1.0x | 5x | yes |
| Blob.serialize | saturated | 131072 | 49152 | 8789.1 | 5665.0 | 1.6x | 5x | yes |
| Blob.serialize | zero | 131072 | 81920 | 5651.9 | 4865.3 | 1.2x | 5x | yes |
| BlobIdentifier.deserialize | large-fixture | 40 | 5000000 | 23.8 | 12.7 | 1.9x | 5x | yes |
| BlobIdentifier.deserialize | medium-fixture | 40 | 5000000 | 23.8 | 12.6 | 1.9x | 5x | yes |
| BlobIdentifier.deserialize | small-fixture | 40 | 5000000 | 23.6 | 12.6 | 1.9x | 5x | yes |
| BlobIdentifier.hash_tree_root | large-fixture | 40 | 1572864 | 274.0 | 103.8 | 2.6x | 10x | yes |
| BlobIdentifier.hash_tree_root | medium-fixture | 40 | 1572864 | 273.4 | 100.9 | 2.7x | 10x | yes |
| BlobIdentifier.hash_tree_root | small-fixture | 40 | 1572864 | 272.1 | 100.9 | 2.7x | 10x | yes |
| BlobIdentifier.serialize | large-fixture | 40 | 5000000 | 9.6 | 14.7 | 0.7x | 5x | yes |
| BlobIdentifier.serialize | medium-fixture | 40 | 5000000 | 9.4 | 14.8 | 0.6x | 5x | yes |
| BlobIdentifier.serialize | small-fixture | 40 | 5000000 | 9.6 | 14.9 | 0.6x | 5x | yes |
| BlobIndex.deserialize | random | 8 | 5000000 | 13.6 | 23.4 | 0.6x | 5x | yes |
| BlobIndex.deserialize | saturated | 8 | 5000000 | 13.4 | 23.1 | 0.6x | 5x | yes |
| BlobIndex.deserialize | zero | 8 | 5000000 | 13.6 | 23.3 | 0.6x | 5x | yes |
| BlobIndex.hash_tree_root | random | 8 | 5000000 | 3.8 | 142.2 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 149.3 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 149.2 | 0.0x | 10x | yes |
| BlobIndex.serialize | random | 8 | 5000000 | 6.8 | 8.2 | 0.8x | 5x | yes |
| BlobIndex.serialize | saturated | 8 | 5000000 | 6.8 | 8.3 | 0.8x | 5x | yes |
| BlobIndex.serialize | zero | 8 | 5000000 | 6.6 | 7.9 | 0.8x | 5x | yes |
| BlobSidecar.deserialize | large-fixture | 131928 | 65536 | 7522.6 | 6473.0 | 1.2x | 5x | yes |
| BlobSidecar.deserialize | medium-fixture | 131928 | 65536 | 7507.3 | 6157.9 | 1.2x | 5x | yes |
| BlobSidecar.deserialize | small-fixture | 131928 | 57344 | 7638.1 | 6291.7 | 1.2x | 5x | yes |
| BlobSidecar.hash_tree_root | large-fixture | 131928 | 384 | 1127604.2 | 275133.4 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | medium-fixture | 131928 | 384 | 1127604.2 | 274634.9 | 4.1x | 10x | yes |
| BlobSidecar.hash_tree_root | small-fixture | 131928 | 384 | 1127604.2 | 274653.6 | 4.1x | 10x | yes |
| BlobSidecar.serialize | large-fixture | 131928 | 73728 | 6496.9 | 4593.0 | 1.4x | 5x | yes |
| BlobSidecar.serialize | medium-fixture | 131928 | 65536 | 6607.1 | 5965.4 | 1.1x | 5x | yes |
| BlobSidecar.serialize | small-fixture | 131928 | 73728 | 6958.0 | 5096.4 | 1.4x | 5x | yes |
| Bytes1.deserialize | random | 1 | 5000000 | 7.4 | 22.9 | 0.3x | 5x | yes |
| Bytes1.deserialize | saturated | 1 | 5000000 | 7.4 | 22.7 | 0.3x | 5x | yes |
| Bytes1.deserialize | zero | 1 | 5000000 | 7.2 | 22.9 | 0.3x | 5x | yes |
| Bytes1.hash_tree_root | random | 1 | 5000000 | 3.0 | 136.5 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | saturated | 1 | 5000000 | 3.0 | 138.3 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | zero | 1 | 5000000 | 3.0 | 151.5 | 0.0x | 10x | yes |
| Bytes1.serialize | random | 1 | 5000000 | 5.4 | 7.6 | 0.7x | 5x | yes |
| Bytes1.serialize | saturated | 1 | 5000000 | 5.6 | 7.6 | 0.7x | 5x | yes |
| Bytes1.serialize | zero | 1 | 5000000 | 5.4 | 7.5 | 0.7x | 5x | yes |
| Bytes20.deserialize | random | 20 | 5000000 | 18.2 | 27.0 | 0.7x | 5x | yes |
| Bytes20.deserialize | saturated | 20 | 5000000 | 18.4 | 27.0 | 0.7x | 5x | yes |
| Bytes20.deserialize | zero | 20 | 5000000 | 18.4 | 27.0 | 0.7x | 5x | yes |
| Bytes20.hash_tree_root | random | 20 | 5000000 | 4.2 | 155.1 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | saturated | 20 | 5000000 | 4.2 | 149.3 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | zero | 20 | 5000000 | 4.2 | 147.9 | 0.0x | 10x | yes |
| Bytes20.serialize | random | 20 | 5000000 | 7.0 | 12.5 | 0.6x | 5x | yes |
| Bytes20.serialize | saturated | 20 | 5000000 | 7.0 | 12.5 | 0.6x | 5x | yes |
| Bytes20.serialize | zero | 20 | 5000000 | 7.0 | 12.8 | 0.5x | 5x | yes |
| Bytes32.deserialize | random | 32 | 5000000 | 30.8 | 30.2 | 1.0x | 5x | yes |
| Bytes32.deserialize | saturated | 32 | 5000000 | 28.6 | 30.9 | 0.9x | 5x | yes |
| Bytes32.deserialize | zero | 32 | 5000000 | 28.2 | 29.7 | 0.9x | 5x | yes |
| Bytes32.hash_tree_root | random | 32 | 5000000 | 4.6 | 136.4 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | saturated | 32 | 5000000 | 4.4 | 140.4 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | zero | 32 | 5000000 | 4.4 | 140.6 | 0.0x | 10x | yes |
| Bytes32.serialize | random | 32 | 5000000 | 8.4 | 13.7 | 0.6x | 5x | yes |
| Bytes32.serialize | saturated | 32 | 5000000 | 9.2 | 14.2 | 0.6x | 5x | yes |
| Bytes32.serialize | zero | 32 | 5000000 | 8.0 | 13.7 | 0.6x | 5x | yes |
| Bytes4.deserialize | random | 4 | 5000000 | 6.4 | 26.0 | 0.2x | 5x | yes |
| Bytes4.deserialize | saturated | 4 | 5000000 | 7.2 | 29.2 | 0.2x | 5x | yes |
| Bytes4.deserialize | zero | 4 | 5000000 | 6.2 | 25.9 | 0.2x | 5x | yes |
| Bytes4.hash_tree_root | random | 4 | 5000000 | 3.8 | 197.5 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | saturated | 4 | 5000000 | 3.4 | 167.3 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | zero | 4 | 5000000 | 3.0 | 150.8 | 0.0x | 10x | yes |
| Bytes4.serialize | random | 4 | 5000000 | 5.4 | 8.6 | 0.6x | 5x | yes |
| Bytes4.serialize | saturated | 4 | 5000000 | 5.6 | 9.1 | 0.6x | 5x | yes |
| Bytes4.serialize | zero | 4 | 5000000 | 5.4 | 8.7 | 0.6x | 5x | yes |
| Bytes48.deserialize | random | 48 | 5000000 | 27.4 | 28.4 | 1.0x | 5x | yes |
| Bytes48.deserialize | saturated | 48 | 5000000 | 28.6 | 30.0 | 1.0x | 5x | yes |
| Bytes48.deserialize | zero | 48 | 5000000 | 28.4 | 31.0 | 0.9x | 5x | yes |
| Bytes48.hash_tree_root | random | 48 | 1572864 | 284.2 | 261.3 | 1.1x | 10x | yes |
| Bytes48.hash_tree_root | saturated | 48 | 1572864 | 273.4 | 249.9 | 1.1x | 10x | yes |
| Bytes48.hash_tree_root | zero | 48 | 1572864 | 274.0 | 240.4 | 1.1x | 10x | yes |
| Bytes48.serialize | random | 48 | 5000000 | 11.6 | 14.7 | 0.8x | 5x | yes |
| Bytes48.serialize | saturated | 48 | 5000000 | 11.6 | 14.6 | 0.8x | 5x | yes |
| Bytes48.serialize | zero | 48 | 5000000 | 10.6 | 14.7 | 0.7x | 5x | yes |
| Bytes8.deserialize | random | 8 | 5000000 | 12.8 | 26.0 | 0.5x | 5x | yes |
| Bytes8.deserialize | saturated | 8 | 5000000 | 13.6 | 27.0 | 0.5x | 5x | yes |
| Bytes8.deserialize | zero | 8 | 5000000 | 11.4 | 23.4 | 0.5x | 5x | yes |
| Bytes8.hash_tree_root | random | 8 | 5000000 | 4.4 | 164.6 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | saturated | 8 | 5000000 | 4.2 | 152.2 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | zero | 8 | 5000000 | 4.2 | 157.2 | 0.0x | 10x | yes |
| Bytes8.serialize | random | 8 | 5000000 | 7.0 | 9.0 | 0.8x | 5x | yes |
| Bytes8.serialize | saturated | 8 | 5000000 | 7.2 | 9.4 | 0.8x | 5x | yes |
| Bytes8.serialize | zero | 8 | 5000000 | 6.6 | 8.4 | 0.8x | 5x | yes |
| Bytes96.deserialize | random | 96 | 5000000 | 61.0 | 36.3 | 1.7x | 5x | yes |
| Bytes96.deserialize | saturated | 96 | 5000000 | 51.0 | 30.7 | 1.7x | 5x | yes |
| Bytes96.deserialize | zero | 96 | 4980736 | 52.4 | 32.9 | 1.6x | 5x | yes |
| Bytes96.hash_tree_root | random | 96 | 507904 | 811.2 | 379.6 | 2.1x | 10x | yes |
| Bytes96.hash_tree_root | saturated | 96 | 524288 | 841.1 | 397.5 | 2.1x | 10x | yes |
| Bytes96.hash_tree_root | zero | 96 | 507904 | 834.8 | 399.9 | 2.1x | 10x | yes |
| Bytes96.serialize | random | 96 | 5000000 | 22.0 | 17.9 | 1.2x | 5x | yes |
| Bytes96.serialize | saturated | 96 | 5000000 | 20.4 | 16.6 | 1.2x | 5x | yes |
| Bytes96.serialize | zero | 96 | 5000000 | 23.8 | 21.2 | 1.1x | 5x | yes |
| Cell.deserialize | random | 2048 | 4194304 | 124.2 | 166.1 | 0.7x | 5x | yes |
| Cell.deserialize | saturated | 2048 | 2621440 | 169.8 | 166.0 | 1.0x | 5x | yes |
| Cell.deserialize | zero | 2048 | 4194304 | 124.5 | 171.6 | 0.7x | 5x | yes |
| Cell.hash_tree_root | random | 2048 | 24576 | 17171.2 | 4652.4 | 3.7x | 10x | yes |
| Cell.hash_tree_root | saturated | 2048 | 24576 | 17130.5 | 4646.6 | 3.7x | 10x | yes |
| Cell.hash_tree_root | zero | 2048 | 12288 | 17496.7 | 4619.4 | 3.8x | 10x | yes |
| Cell.serialize | random | 2048 | 4194304 | 107.8 | 161.5 | 0.7x | 5x | yes |
| Cell.serialize | saturated | 2048 | 3145728 | 159.3 | 145.1 | 1.1x | 5x | yes |
| Cell.serialize | zero | 2048 | 4194304 | 112.5 | 161.5 | 0.7x | 5x | yes |
| CellIndex.deserialize | random | 8 | 5000000 | 12.6 | 23.4 | 0.5x | 5x | yes |
| CellIndex.deserialize | saturated | 8 | 5000000 | 14.0 | 25.7 | 0.5x | 5x | yes |
| CellIndex.deserialize | zero | 8 | 5000000 | 12.6 | 23.3 | 0.5x | 5x | yes |
| CellIndex.hash_tree_root | random | 8 | 5000000 | 4.2 | 154.2 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | saturated | 8 | 5000000 | 4.4 | 163.6 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 142.8 | 0.0x | 10x | yes |
| CellIndex.serialize | random | 8 | 5000000 | 6.6 | 8.8 | 0.8x | 5x | yes |
| CellIndex.serialize | saturated | 8 | 5000000 | 6.8 | 9.2 | 0.7x | 5x | yes |
| CellIndex.serialize | zero | 8 | 5000000 | 6.2 | 8.1 | 0.8x | 5x | yes |
| Checkpoint.deserialize | large-fixture | 40 | 5000000 | 30.0 | 13.0 | 2.3x | 5x | yes |
| Checkpoint.deserialize | medium-fixture | 40 | 5000000 | 30.0 | 13.0 | 2.3x | 5x | yes |
| Checkpoint.deserialize | small-fixture | 40 | 5000000 | 32.8 | 14.2 | 2.3x | 5x | yes |
| Checkpoint.hash_tree_root | large-fixture | 40 | 1572864 | 274.0 | 101.2 | 2.7x | 10x | yes |
| Checkpoint.hash_tree_root | medium-fixture | 40 | 1572864 | 274.7 | 101.1 | 2.7x | 10x | yes |
| Checkpoint.hash_tree_root | small-fixture | 40 | 1572864 | 274.0 | 101.3 | 2.7x | 10x | yes |
| Checkpoint.serialize | large-fixture | 40 | 5000000 | 9.8 | 14.4 | 0.7x | 5x | yes |
| Checkpoint.serialize | medium-fixture | 40 | 5000000 | 9.8 | 14.4 | 0.7x | 5x | yes |
| Checkpoint.serialize | small-fixture | 40 | 5000000 | 10.8 | 15.6 | 0.7x | 5x | yes |
| ColumnIndex.deserialize | random | 8 | 5000000 | 11.4 | 25.2 | 0.5x | 5x | yes |
| ColumnIndex.deserialize | saturated | 8 | 5000000 | 11.8 | 26.6 | 0.4x | 5x | yes |
| ColumnIndex.deserialize | zero | 8 | 5000000 | 10.8 | 23.3 | 0.5x | 5x | yes |
| ColumnIndex.hash_tree_root | random | 8 | 5000000 | 4.6 | 167.2 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | saturated | 8 | 5000000 | 4.4 | 156.0 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | zero | 8 | 5000000 | 4.0 | 150.3 | 0.0x | 10x | yes |
| ColumnIndex.serialize | random | 8 | 5000000 | 7.0 | 9.5 | 0.7x | 5x | yes |
| ColumnIndex.serialize | saturated | 8 | 5000000 | 7.0 | 9.0 | 0.8x | 5x | yes |
| ColumnIndex.serialize | zero | 8 | 5000000 | 6.4 | 8.2 | 0.8x | 5x | yes |
| CommitmentIndex.deserialize | random | 8 | 5000000 | 13.0 | 26.5 | 0.5x | 5x | yes |
| CommitmentIndex.deserialize | saturated | 8 | 5000000 | 13.8 | 26.9 | 0.5x | 5x | yes |
| CommitmentIndex.deserialize | zero | 8 | 5000000 | 13.0 | 24.9 | 0.5x | 5x | yes |
| CommitmentIndex.hash_tree_root | random | 8 | 5000000 | 4.2 | 162.6 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | saturated | 8 | 5000000 | 4.2 | 153.3 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | zero | 8 | 5000000 | 4.2 | 159.6 | 0.0x | 10x | yes |
| CommitmentIndex.serialize | random | 8 | 5000000 | 7.0 | 9.3 | 0.8x | 5x | yes |
| CommitmentIndex.serialize | saturated | 8 | 5000000 | 7.2 | 9.8 | 0.7x | 5x | yes |
| CommitmentIndex.serialize | zero | 8 | 5000000 | 6.6 | 8.8 | 0.8x | 5x | yes |
| CommitteeIndex.deserialize | random | 8 | 5000000 | 14.8 | 25.3 | 0.6x | 5x | yes |
| CommitteeIndex.deserialize | saturated | 8 | 5000000 | 14.4 | 25.7 | 0.6x | 5x | yes |
| CommitteeIndex.deserialize | zero | 8 | 5000000 | 14.4 | 25.5 | 0.6x | 5x | yes |
| CommitteeIndex.hash_tree_root | random | 8 | 5000000 | 3.6 | 158.7 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 165.8 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 151.6 | 0.0x | 10x | yes |
| CommitteeIndex.serialize | random | 8 | 5000000 | 5.8 | 9.0 | 0.6x | 5x | yes |
| CommitteeIndex.serialize | saturated | 8 | 5000000 | 5.8 | 9.1 | 0.6x | 5x | yes |
| CommitteeIndex.serialize | zero | 8 | 5000000 | 5.8 | 8.7 | 0.7x | 5x | yes |
| ConsolidationRequest.deserialize | large-fixture | 116 | 5000000 | 54.4 | 16.6 | 3.3x | 5x | yes |
| ConsolidationRequest.deserialize | medium-fixture | 116 | 5000000 | 54.8 | 16.2 | 3.4x | 5x | yes |
| ConsolidationRequest.deserialize | small-fixture | 116 | 5000000 | 60.4 | 18.0 | 3.4x | 5x | yes |
| ConsolidationRequest.hash_tree_root | large-fixture | 116 | 204800 | 1328.1 | 394.0 | 3.4x | 10x | yes |
| ConsolidationRequest.hash_tree_root | medium-fixture | 116 | 335872 | 1333.8 | 394.7 | 3.4x | 10x | yes |
| ConsolidationRequest.hash_tree_root | small-fixture | 116 | 335872 | 1336.8 | 394.7 | 3.4x | 10x | yes |
| ConsolidationRequest.serialize | large-fixture | 116 | 5000000 | 20.4 | 17.9 | 1.1x | 5x | yes |
| ConsolidationRequest.serialize | medium-fixture | 116 | 5000000 | 20.4 | 18.7 | 1.1x | 5x | yes |
| ConsolidationRequest.serialize | small-fixture | 116 | 5000000 | 21.8 | 18.9 | 1.2x | 5x | yes |
| ContributionAndProof.deserialize | large-fixture | 264 | 3670016 | 121.0 | 58.5 | 2.1x | 5x | yes |
| ContributionAndProof.deserialize | medium-fixture | 264 | 3670016 | 121.8 | 58.1 | 2.1x | 5x | yes |
| ContributionAndProof.deserialize | small-fixture | 264 | 2097152 | 121.6 | 58.9 | 2.1x | 5x | yes |
| ContributionAndProof.hash_tree_root | large-fixture | 264 | 114688 | 4010.9 | 1073.5 | 3.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | medium-fixture | 264 | 106496 | 3990.8 | 1074.0 | 3.7x | 10x | yes |
| ContributionAndProof.hash_tree_root | small-fixture | 264 | 122880 | 3995.8 | 1074.0 | 3.7x | 10x | yes |
| ContributionAndProof.serialize | large-fixture | 264 | 5000000 | 48.2 | 30.2 | 1.6x | 5x | yes |
| ContributionAndProof.serialize | medium-fixture | 264 | 5000000 | 47.6 | 33.7 | 1.4x | 5x | yes |
| ContributionAndProof.serialize | small-fixture | 264 | 5000000 | 47.4 | 30.7 | 1.5x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 25.6 | 36.5 | 0.7x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | saturated | 192 | 5000000 | 25.2 | 35.9 | 0.7x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 23.0 | 36.7 | 0.6x | 5x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | random | 192 | 253952 | 1626.3 | 589.4 | 2.8x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | saturated | 192 | 286720 | 1625.3 | 588.7 | 2.8x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | zero | 192 | 253952 | 1626.3 | 597.7 | 2.7x | 10x | yes |
| CurrentSyncCommitteeBranch.serialize | random | 192 | 5000000 | 21.0 | 23.1 | 0.9x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 20.2 | 21.4 | 0.9x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 16.6 | 22.9 | 0.7x | 5x | yes |
| CustodyIndex.deserialize | random | 8 | 5000000 | 10.0 | 27.6 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | saturated | 8 | 5000000 | 9.0 | 25.6 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | zero | 8 | 5000000 | 8.2 | 23.1 | 0.4x | 5x | yes |
| CustodyIndex.hash_tree_root | random | 8 | 5000000 | 3.6 | 156.5 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | saturated | 8 | 5000000 | 3.4 | 156.4 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | zero | 8 | 5000000 | 3.4 | 163.8 | 0.0x | 10x | yes |
| CustodyIndex.serialize | random | 8 | 5000000 | 5.8 | 9.2 | 0.6x | 5x | yes |
| CustodyIndex.serialize | saturated | 8 | 5000000 | 5.4 | 9.0 | 0.6x | 5x | yes |
| CustodyIndex.serialize | zero | 8 | 5000000 | 5.0 | 7.9 | 0.6x | 5x | yes |
| DataColumnSidecar.deserialize | large-fixture | 19076 | 253952 | 1177.4 | 1749.4 | 0.7x | 5x | yes |
| DataColumnSidecar.deserialize | medium-fixture | 17028 | 253952 | 1023.8 | 1557.1 | 0.7x | 5x | yes |
| DataColumnSidecar.deserialize | small-fixture | 6500 | 524288 | 724.8 | 950.5 | 0.8x | 5x | yes |
| DataColumnSidecar.hash_tree_root | large-fixture | 19076 | 2560 | 178515.6 | 42393.8 | 4.2x | 10x | yes |
| DataColumnSidecar.hash_tree_root | medium-fixture | 17028 | 2560 | 160937.5 | 38383.3 | 4.2x | 10x | yes |
| DataColumnSidecar.hash_tree_root | small-fixture | 6500 | 6400 | 62343.8 | 14947.4 | 4.2x | 10x | yes |
| DataColumnSidecar.serialize | large-fixture | 19076 | 409600 | 1137.7 | 917.2 | 1.2x | 5x | yes |
| DataColumnSidecar.serialize | medium-fixture | 17028 | 409600 | 1076.7 | 826.5 | 1.3x | 5x | yes |
| DataColumnSidecar.serialize | small-fixture | 6500 | 524288 | 400.5 | 354.4 | 1.1x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | large-fixture | 92 | 5000000 | 33.8 | 49.4 | 0.7x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | medium-fixture | 60 | 5000000 | 32.6 | 50.0 | 0.7x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | small-fixture | 36 | 5000000 | 28.8 | 31.5 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | large-fixture | 92 | 221184 | 1944.1 | 563.3 | 3.5x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | medium-fixture | 60 | 221184 | 1894.4 | 520.4 | 3.6x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | small-fixture | 36 | 524288 | 545.5 | 177.3 | 3.1x | 10x | yes |
| DataColumnsByRootIdentifier.serialize | large-fixture | 92 | 5000000 | 19.8 | 22.3 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | medium-fixture | 60 | 5000000 | 17.4 | 18.5 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | small-fixture | 36 | 5000000 | 13.4 | 15.3 | 0.9x | 5x | yes |
| Deposit.deserialize | large-fixture | 1240 | 2621440 | 174.3 | 644.3 | 0.3x | 5x | yes |
| Deposit.deserialize | medium-fixture | 1240 | 2621440 | 189.2 | 650.9 | 0.3x | 5x | yes |
| Deposit.deserialize | small-fixture | 1240 | 2621440 | 193.0 | 651.6 | 0.3x | 5x | yes |
| Deposit.hash_tree_root | large-fixture | 1240 | 32768 | 12176.5 | 3165.9 | 3.8x | 10x | yes |
| Deposit.hash_tree_root | medium-fixture | 1240 | 32768 | 12207.0 | 3174.1 | 3.8x | 10x | yes |
| Deposit.hash_tree_root | small-fixture | 1240 | 24576 | 12207.0 | 3248.4 | 3.8x | 10x | yes |
| Deposit.serialize | large-fixture | 1240 | 4718592 | 95.4 | 118.5 | 0.8x | 5x | yes |
| Deposit.serialize | medium-fixture | 1240 | 5000000 | 99.0 | 129.8 | 0.8x | 5x | yes |
| Deposit.serialize | small-fixture | 1240 | 3670016 | 111.2 | 139.3 | 0.8x | 5x | yes |
| DepositData.deserialize | large-fixture | 184 | 4718592 | 111.1 | 38.6 | 2.9x | 5x | yes |
| DepositData.deserialize | medium-fixture | 184 | 2097152 | 118.3 | 41.0 | 2.9x | 5x | yes |
| DepositData.deserialize | small-fixture | 184 | 4194304 | 109.4 | 38.7 | 2.8x | 5x | yes |
| DepositData.hash_tree_root | large-fixture | 184 | 221184 | 1876.3 | 524.2 | 3.6x | 10x | yes |
| DepositData.hash_tree_root | medium-fixture | 184 | 253952 | 1870.4 | 525.0 | 3.6x | 10x | yes |
| DepositData.hash_tree_root | small-fixture | 184 | 221184 | 1984.8 | 583.1 | 3.4x | 10x | yes |
| DepositData.serialize | large-fixture | 184 | 5000000 | 34.2 | 24.6 | 1.4x | 5x | yes |
| DepositData.serialize | medium-fixture | 184 | 5000000 | 33.2 | 24.6 | 1.3x | 5x | yes |
| DepositData.serialize | small-fixture | 184 | 5000000 | 34.4 | 24.2 | 1.4x | 5x | yes |
| DepositMessage.deserialize | large-fixture | 88 | 5000000 | 36.8 | 31.3 | 1.2x | 5x | yes |
| DepositMessage.deserialize | medium-fixture | 88 | 5000000 | 38.6 | 33.5 | 1.2x | 5x | yes |
| DepositMessage.deserialize | small-fixture | 88 | 5000000 | 37.2 | 31.1 | 1.2x | 5x | yes |
| DepositMessage.hash_tree_root | large-fixture | 88 | 253952 | 1055.3 | 316.0 | 3.3x | 10x | yes |
| DepositMessage.hash_tree_root | medium-fixture | 88 | 253952 | 1055.3 | 316.7 | 3.3x | 10x | yes |
| DepositMessage.hash_tree_root | small-fixture | 88 | 253952 | 1059.3 | 316.4 | 3.3x | 10x | yes |
| DepositMessage.serialize | large-fixture | 88 | 5000000 | 14.8 | 17.6 | 0.8x | 5x | yes |
| DepositMessage.serialize | medium-fixture | 88 | 5000000 | 16.4 | 18.6 | 0.9x | 5x | yes |
| DepositMessage.serialize | small-fixture | 88 | 5000000 | 14.8 | 17.5 | 0.8x | 5x | yes |
| DepositRequest.deserialize | large-fixture | 192 | 4194304 | 113.0 | 37.8 | 3.0x | 5x | yes |
| DepositRequest.deserialize | medium-fixture | 192 | 3670016 | 115.8 | 39.6 | 2.9x | 5x | yes |
| DepositRequest.deserialize | small-fixture | 192 | 2097152 | 114.4 | 38.4 | 3.0x | 5x | yes |
| DepositRequest.hash_tree_root | large-fixture | 192 | 180224 | 2657.8 | 724.1 | 3.7x | 10x | yes |
| DepositRequest.hash_tree_root | medium-fixture | 192 | 155648 | 2666.3 | 724.6 | 3.7x | 10x | yes |
| DepositRequest.hash_tree_root | small-fixture | 192 | 163840 | 2661.1 | 724.6 | 3.7x | 10x | yes |
| DepositRequest.serialize | large-fixture | 192 | 5000000 | 33.6 | 23.9 | 1.4x | 5x | yes |
| DepositRequest.serialize | medium-fixture | 192 | 5000000 | 37.0 | 25.7 | 1.4x | 5x | yes |
| DepositRequest.serialize | small-fixture | 192 | 5000000 | 35.0 | 24.9 | 1.4x | 5x | yes |
| Domain.deserialize | random | 32 | 5000000 | 24.8 | 31.1 | 0.8x | 5x | yes |
| Domain.deserialize | saturated | 32 | 5000000 | 23.0 | 30.2 | 0.8x | 5x | yes |
| Domain.deserialize | zero | 32 | 5000000 | 21.0 | 27.6 | 0.8x | 5x | yes |
| Domain.hash_tree_root | random | 32 | 5000000 | 4.8 | 147.3 | 0.0x | 10x | yes |
| Domain.hash_tree_root | saturated | 32 | 5000000 | 4.8 | 145.1 | 0.0x | 10x | yes |
| Domain.hash_tree_root | zero | 32 | 5000000 | 4.8 | 144.0 | 0.0x | 10x | yes |
| Domain.serialize | random | 32 | 5000000 | 8.6 | 14.3 | 0.6x | 5x | yes |
| Domain.serialize | saturated | 32 | 5000000 | 8.4 | 14.1 | 0.6x | 5x | yes |
| Domain.serialize | zero | 32 | 5000000 | 8.0 | 13.0 | 0.6x | 5x | yes |
| DomainType.deserialize | random | 4 | 5000000 | 7.4 | 26.8 | 0.3x | 5x | yes |
| DomainType.deserialize | saturated | 4 | 5000000 | 7.4 | 26.7 | 0.3x | 5x | yes |
| DomainType.deserialize | zero | 4 | 5000000 | 7.6 | 26.6 | 0.3x | 5x | yes |
| DomainType.hash_tree_root | random | 4 | 5000000 | 3.2 | 154.7 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | saturated | 4 | 5000000 | 3.2 | 163.0 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | zero | 4 | 5000000 | 3.2 | 157.0 | 0.0x | 10x | yes |
| DomainType.serialize | random | 4 | 5000000 | 5.8 | 9.0 | 0.6x | 5x | yes |
| DomainType.serialize | saturated | 4 | 5000000 | 5.8 | 9.0 | 0.6x | 5x | yes |
| DomainType.serialize | zero | 4 | 5000000 | 5.8 | 8.8 | 0.7x | 5x | yes |
| Epoch.deserialize | random | 8 | 5000000 | 12.4 | 26.1 | 0.5x | 5x | yes |
| Epoch.deserialize | saturated | 8 | 5000000 | 12.4 | 25.2 | 0.5x | 5x | yes |
| Epoch.deserialize | zero | 8 | 5000000 | 12.2 | 26.6 | 0.5x | 5x | yes |
| Epoch.hash_tree_root | random | 8 | 5000000 | 3.8 | 156.2 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 166.6 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | zero | 8 | 5000000 | 3.8 | 154.4 | 0.0x | 10x | yes |
| Epoch.serialize | random | 8 | 5000000 | 5.8 | 9.2 | 0.6x | 5x | yes |
| Epoch.serialize | saturated | 8 | 5000000 | 5.8 | 8.8 | 0.7x | 5x | yes |
| Epoch.serialize | zero | 8 | 5000000 | 6.0 | 9.5 | 0.6x | 5x | yes |
| Eth1Block.deserialize | large-fixture | 48 | 5000000 | 26.0 | 28.1 | 0.9x | 5x | yes |
| Eth1Block.deserialize | medium-fixture | 48 | 5000000 | 25.6 | 27.9 | 0.9x | 5x | yes |
| Eth1Block.deserialize | small-fixture | 48 | 5000000 | 28.8 | 31.1 | 0.9x | 5x | yes |
| Eth1Block.hash_tree_root | large-fixture | 48 | 507904 | 791.5 | 238.7 | 3.3x | 10x | yes |
| Eth1Block.hash_tree_root | medium-fixture | 48 | 524288 | 789.6 | 239.1 | 3.3x | 10x | yes |
| Eth1Block.hash_tree_root | small-fixture | 48 | 524288 | 791.5 | 239.7 | 3.3x | 10x | yes |
| Eth1Block.serialize | large-fixture | 48 | 5000000 | 8.4 | 15.0 | 0.6x | 5x | yes |
| Eth1Block.serialize | medium-fixture | 48 | 5000000 | 8.6 | 15.0 | 0.6x | 5x | yes |
| Eth1Block.serialize | small-fixture | 48 | 5000000 | 9.4 | 17.0 | 0.6x | 5x | yes |
| Eth1Data.deserialize | large-fixture | 72 | 5000000 | 37.8 | 40.4 | 0.9x | 5x | yes |
| Eth1Data.deserialize | medium-fixture | 72 | 5000000 | 37.2 | 41.2 | 0.9x | 5x | yes |
| Eth1Data.deserialize | small-fixture | 72 | 5000000 | 37.2 | 41.0 | 0.9x | 5x | yes |
| Eth1Data.hash_tree_root | large-fixture | 72 | 524288 | 801.1 | 239.7 | 3.3x | 10x | yes |
| Eth1Data.hash_tree_root | medium-fixture | 72 | 524288 | 799.2 | 240.4 | 3.3x | 10x | yes |
| Eth1Data.hash_tree_root | small-fixture | 72 | 507904 | 801.3 | 240.3 | 3.3x | 10x | yes |
| Eth1Data.serialize | large-fixture | 72 | 5000000 | 13.4 | 16.6 | 0.8x | 5x | yes |
| Eth1Data.serialize | medium-fixture | 72 | 5000000 | 13.2 | 17.2 | 0.8x | 5x | yes |
| Eth1Data.serialize | small-fixture | 72 | 5000000 | 13.4 | 16.5 | 0.8x | 5x | yes |
| Ether.deserialize | random | 8 | 5000000 | 12.2 | 23.0 | 0.5x | 5x | yes |
| Ether.deserialize | saturated | 8 | 5000000 | 12.2 | 23.3 | 0.5x | 5x | yes |
| Ether.deserialize | zero | 8 | 5000000 | 12.0 | 23.2 | 0.5x | 5x | yes |
| Ether.hash_tree_root | random | 8 | 5000000 | 4.0 | 137.8 | 0.0x | 10x | yes |
| Ether.hash_tree_root | saturated | 8 | 5000000 | 4.0 | 137.4 | 0.0x | 10x | yes |
| Ether.hash_tree_root | zero | 8 | 5000000 | 4.0 | 134.6 | 0.0x | 10x | yes |
| Ether.serialize | random | 8 | 5000000 | 6.2 | 8.0 | 0.8x | 5x | yes |
| Ether.serialize | saturated | 8 | 5000000 | 6.4 | 8.0 | 0.8x | 5x | yes |
| Ether.serialize | zero | 8 | 5000000 | 6.2 | 8.0 | 0.8x | 5x | yes |
| ExecutionAddress.deserialize | random | 20 | 5000000 | 14.0 | 27.0 | 0.5x | 5x | yes |
| ExecutionAddress.deserialize | saturated | 20 | 5000000 | 14.0 | 27.0 | 0.5x | 5x | yes |
| ExecutionAddress.deserialize | zero | 20 | 5000000 | 13.6 | 27.4 | 0.5x | 5x | yes |
| ExecutionAddress.hash_tree_root | random | 20 | 5000000 | 3.6 | 144.5 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | saturated | 20 | 5000000 | 3.6 | 150.2 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | zero | 20 | 5000000 | 3.6 | 143.0 | 0.0x | 10x | yes |
| ExecutionAddress.serialize | random | 20 | 5000000 | 6.0 | 12.3 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | saturated | 20 | 5000000 | 6.2 | 12.5 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | zero | 20 | 5000000 | 6.0 | 12.4 | 0.5x | 5x | yes |
| ExecutionBranch.deserialize | random | 128 | 5000000 | 20.2 | 32.5 | 0.6x | 5x | yes |
| ExecutionBranch.deserialize | saturated | 128 | 5000000 | 20.4 | 32.5 | 0.6x | 5x | yes |
| ExecutionBranch.deserialize | zero | 128 | 5000000 | 19.2 | 31.4 | 0.6x | 5x | yes |
| ExecutionBranch.hash_tree_root | random | 128 | 507904 | 823.0 | 384.3 | 2.1x | 10x | yes |
| ExecutionBranch.hash_tree_root | saturated | 128 | 524288 | 824.0 | 377.4 | 2.2x | 10x | yes |
| ExecutionBranch.hash_tree_root | zero | 128 | 507904 | 821.0 | 379.6 | 2.2x | 10x | yes |
| ExecutionBranch.serialize | random | 128 | 5000000 | 14.2 | 16.9 | 0.8x | 5x | yes |
| ExecutionBranch.serialize | saturated | 128 | 5000000 | 14.2 | 16.7 | 0.8x | 5x | yes |
| ExecutionBranch.serialize | zero | 128 | 5000000 | 12.0 | 17.0 | 0.7x | 5x | yes |
| ExecutionPayload.deserialize | large-fixture | 4033 | 524288 | 780.1 | 531.3 | 1.5x | 5x | yes |
| ExecutionPayload.deserialize | medium-fixture | 2445 | 524288 | 560.8 | 411.4 | 1.4x | 5x | yes |
| ExecutionPayload.deserialize | small-fixture | 1921 | 1048576 | 461.6 | 285.4 | 1.6x | 5x | yes |
| ExecutionPayload.hash_tree_root | large-fixture | 4033 | 4480 | 95535.7 | 23875.2 | 4.0x | 10x | yes |
| ExecutionPayload.hash_tree_root | medium-fixture | 2445 | 7936 | 59601.8 | 14901.7 | 4.0x | 10x | yes |
| ExecutionPayload.hash_tree_root | small-fixture | 1921 | 8192 | 45410.2 | 11359.4 | 4.0x | 10x | yes |
| ExecutionPayload.serialize | large-fixture | 4033 | 524288 | 566.5 | 294.3 | 1.9x | 5x | yes |
| ExecutionPayload.serialize | medium-fixture | 2445 | 1048576 | 413.9 | 221.3 | 1.9x | 5x | yes |
| ExecutionPayload.serialize | small-fixture | 1921 | 1048576 | 341.4 | 163.5 | 2.1x | 5x | yes |
| ExecutionPayloadHeader.deserialize | large-fixture | 604 | 1572864 | 275.9 | 88.9 | 3.1x | 5x | yes |
| ExecutionPayloadHeader.deserialize | medium-fixture | 594 | 1572864 | 268.9 | 83.1 | 3.2x | 5x | yes |
| ExecutionPayloadHeader.deserialize | small-fixture | 590 | 1572864 | 272.8 | 84.7 | 3.2x | 5x | yes |
| ExecutionPayloadHeader.hash_tree_root | large-fixture | 604 | 32768 | 7690.4 | 1982.5 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | medium-fixture | 594 | 57344 | 7690.4 | 1974.9 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | small-fixture | 590 | 32768 | 7690.4 | 1971.9 | 3.9x | 10x | yes |
| ExecutionPayloadHeader.serialize | large-fixture | 604 | 2097152 | 227.5 | 63.6 | 3.6x | 5x | yes |
| ExecutionPayloadHeader.serialize | medium-fixture | 594 | 2097152 | 227.5 | 65.5 | 3.5x | 5x | yes |
| ExecutionPayloadHeader.serialize | small-fixture | 590 | 2097152 | 227.5 | 61.8 | 3.7x | 5x | yes |
| ExecutionRequests.deserialize | large-fixture | 1624 | 524288 | 566.5 | 382.7 | 1.5x | 5x | yes |
| ExecutionRequests.deserialize | medium-fixture | 1004 | 1048576 | 387.2 | 231.6 | 1.7x | 5x | yes |
| ExecutionRequests.deserialize | small-fixture | 396 | 2621440 | 169.0 | 118.2 | 1.4x | 5x | yes |
| ExecutionRequests.hash_tree_root | large-fixture | 1624 | 8192 | 29663.1 | 7751.4 | 3.8x | 10x | yes |
| ExecutionRequests.hash_tree_root | medium-fixture | 1004 | 24576 | 18107.1 | 4947.6 | 3.7x | 10x | yes |
| ExecutionRequests.hash_tree_root | small-fixture | 396 | 40960 | 10424.8 | 2730.9 | 3.8x | 10x | yes |
| ExecutionRequests.serialize | large-fixture | 1624 | 1048576 | 365.3 | 158.6 | 2.3x | 5x | yes |
| ExecutionRequests.serialize | medium-fixture | 1004 | 2621440 | 160.2 | 90.2 | 1.8x | 5x | yes |
| ExecutionRequests.serialize | small-fixture | 396 | 5000000 | 87.0 | 42.7 | 2.0x | 5x | yes |
| FinalityBranch.deserialize | random | 224 | 5000000 | 27.2 | 39.4 | 0.7x | 5x | yes |
| FinalityBranch.deserialize | saturated | 224 | 5000000 | 26.8 | 38.5 | 0.7x | 5x | yes |
| FinalityBranch.deserialize | zero | 224 | 5000000 | 24.6 | 37.5 | 0.7x | 5x | yes |
| FinalityBranch.hash_tree_root | random | 224 | 221184 | 1894.4 | 670.6 | 2.8x | 10x | yes |
| FinalityBranch.hash_tree_root | saturated | 224 | 126976 | 1898.0 | 666.0 | 2.8x | 10x | yes |
| FinalityBranch.hash_tree_root | zero | 224 | 253952 | 1909.8 | 673.1 | 2.8x | 10x | yes |
| FinalityBranch.serialize | random | 224 | 5000000 | 17.4 | 25.2 | 0.7x | 5x | yes |
| FinalityBranch.serialize | saturated | 224 | 5000000 | 17.4 | 24.6 | 0.7x | 5x | yes |
| FinalityBranch.serialize | zero | 224 | 5000000 | 14.4 | 22.0 | 0.7x | 5x | yes |
| Fork.deserialize | large-fixture | 16 | 5000000 | 17.2 | 10.9 | 1.6x | 5x | yes |
| Fork.deserialize | medium-fixture | 16 | 5000000 | 19.8 | 10.9 | 1.8x | 5x | yes |
| Fork.deserialize | small-fixture | 16 | 5000000 | 20.4 | 10.9 | 1.9x | 5x | yes |
| Fork.hash_tree_root | large-fixture | 16 | 524288 | 795.4 | 241.8 | 3.3x | 10x | yes |
| Fork.hash_tree_root | medium-fixture | 16 | 524288 | 793.5 | 242.0 | 3.3x | 10x | yes |
| Fork.hash_tree_root | small-fixture | 16 | 524288 | 793.5 | 242.3 | 3.3x | 10x | yes |
| Fork.serialize | large-fixture | 16 | 5000000 | 6.6 | 13.6 | 0.5x | 5x | yes |
| Fork.serialize | medium-fixture | 16 | 5000000 | 6.6 | 13.7 | 0.5x | 5x | yes |
| Fork.serialize | small-fixture | 16 | 5000000 | 6.6 | 13.8 | 0.5x | 5x | yes |
| ForkData.deserialize | large-fixture | 36 | 5000000 | 26.8 | 13.1 | 2.0x | 5x | yes |
| ForkData.deserialize | medium-fixture | 36 | 5000000 | 26.8 | 13.0 | 2.1x | 5x | yes |
| ForkData.deserialize | small-fixture | 36 | 5000000 | 26.8 | 12.8 | 2.1x | 5x | yes |
| ForkData.hash_tree_root | large-fixture | 36 | 1572864 | 272.1 | 103.2 | 2.6x | 10x | yes |
| ForkData.hash_tree_root | medium-fixture | 36 | 1572864 | 272.1 | 103.2 | 2.6x | 10x | yes |
| ForkData.hash_tree_root | small-fixture | 36 | 1572864 | 272.1 | 103.2 | 2.6x | 10x | yes |
| ForkData.serialize | large-fixture | 36 | 5000000 | 9.4 | 14.4 | 0.7x | 5x | yes |
| ForkData.serialize | medium-fixture | 36 | 5000000 | 9.2 | 14.6 | 0.6x | 5x | yes |
| ForkData.serialize | small-fixture | 36 | 5000000 | 9.4 | 14.3 | 0.7x | 5x | yes |
| ForkDigest.deserialize | random | 4 | 5000000 | 8.0 | 24.1 | 0.3x | 5x | yes |
| ForkDigest.deserialize | saturated | 4 | 5000000 | 8.0 | 24.1 | 0.3x | 5x | yes |
| ForkDigest.deserialize | zero | 4 | 5000000 | 8.0 | 24.1 | 0.3x | 5x | yes |
| ForkDigest.hash_tree_root | random | 4 | 5000000 | 3.0 | 136.3 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | saturated | 4 | 5000000 | 3.0 | 137.4 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | zero | 4 | 5000000 | 3.0 | 143.9 | 0.0x | 10x | yes |
| ForkDigest.serialize | random | 4 | 5000000 | 5.2 | 8.0 | 0.6x | 5x | yes |
| ForkDigest.serialize | saturated | 4 | 5000000 | 5.2 | 8.0 | 0.7x | 5x | yes |
| ForkDigest.serialize | zero | 4 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| G1Point.deserialize | random | 48 | 5000000 | 34.2 | 28.0 | 1.2x | 5x | yes |
| G1Point.deserialize | saturated | 48 | 5000000 | 33.0 | 27.8 | 1.2x | 5x | yes |
| G1Point.deserialize | zero | 48 | 5000000 | 32.2 | 27.8 | 1.2x | 5x | yes |
| G1Point.hash_tree_root | random | 48 | 1572864 | 273.4 | 225.3 | 1.2x | 10x | yes |
| G1Point.hash_tree_root | saturated | 48 | 1572864 | 272.8 | 232.4 | 1.2x | 10x | yes |
| G1Point.hash_tree_root | zero | 48 | 1572864 | 273.4 | 233.8 | 1.2x | 10x | yes |
| G1Point.serialize | random | 48 | 5000000 | 10.4 | 13.4 | 0.8x | 5x | yes |
| G1Point.serialize | saturated | 48 | 5000000 | 10.6 | 13.1 | 0.8x | 5x | yes |
| G1Point.serialize | zero | 48 | 5000000 | 9.8 | 13.2 | 0.7x | 5x | yes |
| G2Point.deserialize | random | 96 | 5000000 | 48.8 | 30.3 | 1.6x | 5x | yes |
| G2Point.deserialize | saturated | 96 | 5000000 | 46.2 | 30.7 | 1.5x | 5x | yes |
| G2Point.deserialize | zero | 96 | 5000000 | 44.6 | 30.5 | 1.5x | 5x | yes |
| G2Point.hash_tree_root | random | 96 | 507904 | 807.2 | 367.5 | 2.2x | 10x | yes |
| G2Point.hash_tree_root | saturated | 96 | 524288 | 810.6 | 371.9 | 2.2x | 10x | yes |
| G2Point.hash_tree_root | zero | 96 | 507904 | 809.2 | 368.0 | 2.2x | 10x | yes |
| G2Point.serialize | random | 96 | 5000000 | 19.0 | 16.1 | 1.2x | 5x | yes |
| G2Point.serialize | saturated | 96 | 5000000 | 19.0 | 15.9 | 1.2x | 5x | yes |
| G2Point.serialize | zero | 96 | 5000000 | 19.6 | 15.5 | 1.3x | 5x | yes |
| Gwei.deserialize | random | 8 | 5000000 | 10.4 | 23.7 | 0.4x | 5x | yes |
| Gwei.deserialize | saturated | 8 | 5000000 | 10.4 | 23.5 | 0.4x | 5x | yes |
| Gwei.deserialize | zero | 8 | 5000000 | 10.2 | 23.4 | 0.4x | 5x | yes |
| Gwei.hash_tree_root | random | 8 | 5000000 | 3.8 | 133.7 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 137.0 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | zero | 8 | 5000000 | 3.8 | 137.8 | 0.0x | 10x | yes |
| Gwei.serialize | random | 8 | 5000000 | 5.4 | 7.9 | 0.7x | 5x | yes |
| Gwei.serialize | saturated | 8 | 5000000 | 5.4 | 8.2 | 0.7x | 5x | yes |
| Gwei.serialize | zero | 8 | 5000000 | 5.4 | 7.9 | 0.7x | 5x | yes |
| Hash32.deserialize | random | 32 | 5000000 | 20.6 | 26.9 | 0.8x | 5x | yes |
| Hash32.deserialize | saturated | 32 | 5000000 | 20.6 | 26.7 | 0.8x | 5x | yes |
| Hash32.deserialize | zero | 32 | 5000000 | 19.8 | 27.3 | 0.7x | 5x | yes |
| Hash32.hash_tree_root | random | 32 | 5000000 | 3.6 | 121.8 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | saturated | 32 | 5000000 | 3.8 | 127.1 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | zero | 32 | 5000000 | 3.8 | 127.0 | 0.0x | 10x | yes |
| Hash32.serialize | random | 32 | 5000000 | 6.2 | 12.4 | 0.5x | 5x | yes |
| Hash32.serialize | saturated | 32 | 5000000 | 6.2 | 12.3 | 0.5x | 5x | yes |
| Hash32.serialize | zero | 32 | 5000000 | 6.2 | 12.4 | 0.5x | 5x | yes |
| HistoricalBatch.deserialize | large-fixture | 524288 | 16384 | 28869.6 | 320647.3 | 0.1x | 5x | yes |
| HistoricalBatch.deserialize | medium-fixture | 524288 | 16384 | 27954.1 | 299670.9 | 0.1x | 5x | yes |
| HistoricalBatch.deserialize | small-fixture | 524288 | 16384 | 27587.9 | 288286.5 | 0.1x | 5x | yes |
| HistoricalBatch.hash_tree_root | large-fixture | 524288 | 100 | 4450000.0 | 1143154.2 | 3.9x | 10x | yes |
| HistoricalBatch.hash_tree_root | medium-fixture | 524288 | 100 | 4470000.0 | 1147312.1 | 3.9x | 10x | yes |
| HistoricalBatch.hash_tree_root | small-fixture | 524288 | 100 | 4460000.0 | 1142233.0 | 3.9x | 10x | yes |
| HistoricalBatch.serialize | large-fixture | 524288 | 16384 | 25695.8 | 69130.6 | 0.4x | 5x | yes |
| HistoricalBatch.serialize | medium-fixture | 524288 | 16384 | 26550.3 | 73701.3 | 0.4x | 5x | yes |
| HistoricalBatch.serialize | small-fixture | 524288 | 16384 | 23254.4 | 64708.0 | 0.4x | 5x | yes |
| HistoricalSummary.deserialize | large-fixture | 64 | 5000000 | 38.2 | 13.3 | 2.9x | 5x | yes |
| HistoricalSummary.deserialize | medium-fixture | 64 | 5000000 | 38.4 | 13.5 | 2.8x | 5x | yes |
| HistoricalSummary.deserialize | small-fixture | 64 | 5000000 | 38.0 | 13.1 | 2.9x | 5x | yes |
| HistoricalSummary.hash_tree_root | large-fixture | 64 | 1572864 | 275.3 | 101.5 | 2.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | medium-fixture | 64 | 1572864 | 275.9 | 101.3 | 2.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | small-fixture | 64 | 1572864 | 276.6 | 101.5 | 2.7x | 10x | yes |
| HistoricalSummary.serialize | large-fixture | 64 | 5000000 | 12.6 | 15.0 | 0.8x | 5x | yes |
| HistoricalSummary.serialize | medium-fixture | 64 | 5000000 | 12.6 | 14.6 | 0.9x | 5x | yes |
| HistoricalSummary.serialize | small-fixture | 64 | 5000000 | 12.6 | 14.7 | 0.9x | 5x | yes |
| IndexedAttestation.deserialize | large-fixture | 308 | 2621440 | 167.5 | 85.1 | 2.0x | 5x | yes |
| IndexedAttestation.deserialize | medium-fixture | 284 | 2621440 | 175.5 | 79.6 | 2.2x | 5x | yes |
| IndexedAttestation.deserialize | small-fixture | 236 | 2621440 | 161.0 | 75.8 | 2.1x | 5x | yes |
| IndexedAttestation.hash_tree_root | large-fixture | 308 | 57344 | 8335.7 | 2184.3 | 3.8x | 10x | yes |
| IndexedAttestation.hash_tree_root | medium-fixture | 284 | 57344 | 8074.1 | 2113.7 | 3.8x | 10x | yes |
| IndexedAttestation.hash_tree_root | small-fixture | 236 | 57344 | 8074.1 | 2098.0 | 3.8x | 10x | yes |
| IndexedAttestation.serialize | large-fixture | 308 | 4194304 | 111.8 | 37.0 | 3.0x | 5x | yes |
| IndexedAttestation.serialize | medium-fixture | 284 | 4194304 | 111.8 | 33.4 | 3.3x | 5x | yes |
| IndexedAttestation.serialize | small-fixture | 236 | 4194304 | 107.0 | 29.2 | 3.7x | 5x | yes |
| KZGCommitment.deserialize | random | 48 | 5000000 | 31.6 | 27.3 | 1.2x | 5x | yes |
| KZGCommitment.deserialize | saturated | 48 | 5000000 | 31.4 | 27.9 | 1.1x | 5x | yes |
| KZGCommitment.deserialize | zero | 48 | 5000000 | 32.6 | 27.8 | 1.2x | 5x | yes |
| KZGCommitment.hash_tree_root | random | 48 | 1572864 | 272.8 | 225.3 | 1.2x | 10x | yes |
| KZGCommitment.hash_tree_root | saturated | 48 | 1572864 | 272.1 | 229.0 | 1.2x | 10x | yes |
| KZGCommitment.hash_tree_root | zero | 48 | 1572864 | 271.5 | 231.2 | 1.2x | 10x | yes |
| KZGCommitment.serialize | random | 48 | 5000000 | 11.2 | 13.2 | 0.8x | 5x | yes |
| KZGCommitment.serialize | saturated | 48 | 5000000 | 11.0 | 13.1 | 0.8x | 5x | yes |
| KZGCommitment.serialize | zero | 48 | 5000000 | 9.8 | 13.2 | 0.7x | 5x | yes |
| KZGProof.deserialize | random | 48 | 5000000 | 24.0 | 28.2 | 0.9x | 5x | yes |
| KZGProof.deserialize | saturated | 48 | 5000000 | 24.0 | 27.9 | 0.9x | 5x | yes |
| KZGProof.deserialize | zero | 48 | 5000000 | 22.2 | 27.7 | 0.8x | 5x | yes |
| KZGProof.hash_tree_root | random | 48 | 1572864 | 267.7 | 237.7 | 1.1x | 10x | yes |
| KZGProof.hash_tree_root | saturated | 48 | 1572864 | 267.0 | 232.9 | 1.1x | 10x | yes |
| KZGProof.hash_tree_root | zero | 48 | 1572864 | 267.0 | 226.5 | 1.2x | 10x | yes |
| KZGProof.serialize | random | 48 | 5000000 | 9.2 | 13.3 | 0.7x | 5x | yes |
| KZGProof.serialize | saturated | 48 | 5000000 | 9.2 | 13.1 | 0.7x | 5x | yes |
| KZGProof.serialize | zero | 48 | 5000000 | 8.4 | 13.1 | 0.6x | 5x | yes |
| LightClientBootstrap.deserialize | large-fixture | 25676 | 286720 | 1646.2 | 8360.4 | 0.2x | 5x | yes |
| LightClientBootstrap.deserialize | medium-fixture | 25666 | 286720 | 1642.7 | 8411.6 | 0.2x | 5x | yes |
| LightClientBootstrap.deserialize | small-fixture | 25651 | 167936 | 1643.5 | 8440.9 | 0.2x | 5x | yes |
| LightClientBootstrap.hash_tree_root | large-fixture | 25676 | 832 | 300480.8 | 77911.7 | 3.9x | 10x | yes |
| LightClientBootstrap.hash_tree_root | medium-fixture | 25666 | 1536 | 299479.2 | 78014.9 | 3.8x | 10x | yes |
| LightClientBootstrap.hash_tree_root | small-fixture | 25651 | 1664 | 299278.8 | 78051.0 | 3.8x | 10x | yes |
| LightClientBootstrap.serialize | large-fixture | 25676 | 204800 | 1367.2 | 1737.1 | 0.8x | 5x | yes |
| LightClientBootstrap.serialize | medium-fixture | 25666 | 335872 | 1363.6 | 1907.5 | 0.7x | 5x | yes |
| LightClientBootstrap.serialize | small-fixture | 25651 | 204800 | 1362.3 | 1910.0 | 0.7x | 5x | yes |
| LightClientFinalityUpdate.deserialize | large-fixture | 2096 | 524288 | 932.7 | 940.4 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.deserialize | medium-fixture | 2078 | 507904 | 941.1 | 926.5 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.deserialize | small-fixture | 2066 | 507904 | 929.3 | 934.9 | 1.0x | 5x | yes |
| LightClientFinalityUpdate.hash_tree_root | large-fixture | 2096 | 16384 | 26794.4 | 6821.1 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | medium-fixture | 2078 | 16384 | 26733.4 | 6827.6 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | small-fixture | 2066 | 16384 | 26855.5 | 6824.5 | 3.9x | 10x | yes |
| LightClientFinalityUpdate.serialize | large-fixture | 2096 | 524288 | 631.3 | 160.9 | 3.9x | 5x | yes |
| LightClientFinalityUpdate.serialize | medium-fixture | 2078 | 524288 | 627.5 | 172.8 | 3.6x | 5x | yes |
| LightClientFinalityUpdate.serialize | small-fixture | 2066 | 524288 | 625.6 | 170.8 | 3.7x | 5x | yes |
| LightClientHeader.deserialize | large-fixture | 860 | 1048576 | 380.5 | 360.3 | 1.1x | 5x | yes |
| LightClientHeader.deserialize | medium-fixture | 850 | 1048576 | 379.6 | 355.8 | 1.1x | 5x | yes |
| LightClientHeader.deserialize | small-fixture | 830 | 1048576 | 378.6 | 352.6 | 1.1x | 5x | yes |
| LightClientHeader.hash_tree_root | large-fixture | 860 | 40960 | 10937.5 | 2789.1 | 3.9x | 10x | yes |
| LightClientHeader.hash_tree_root | medium-fixture | 850 | 40960 | 10913.1 | 2791.0 | 3.9x | 10x | yes |
| LightClientHeader.hash_tree_root | small-fixture | 830 | 40960 | 10937.5 | 2789.8 | 3.9x | 10x | yes |
| LightClientHeader.serialize | large-fixture | 860 | 2097152 | 227.5 | 73.1 | 3.1x | 5x | yes |
| LightClientHeader.serialize | medium-fixture | 850 | 2097152 | 227.9 | 75.6 | 3.0x | 5x | yes |
| LightClientHeader.serialize | small-fixture | 830 | 2097152 | 227.5 | 78.0 | 2.9x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | large-fixture | 1031 | 524288 | 484.5 | 430.9 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | medium-fixture | 1013 | 524288 | 484.5 | 428.0 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | small-fixture | 1000 | 524288 | 480.7 | 420.2 | 1.1x | 5x | yes |
| LightClientOptimisticUpdate.hash_tree_root | large-fixture | 1031 | 32768 | 13061.5 | 3374.4 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | medium-fixture | 1013 | 32768 | 13092.0 | 3371.8 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | small-fixture | 1000 | 32768 | 13092.0 | 3367.8 | 3.9x | 10x | yes |
| LightClientOptimisticUpdate.serialize | large-fixture | 1031 | 1572864 | 274.0 | 102.7 | 2.7x | 5x | yes |
| LightClientOptimisticUpdate.serialize | medium-fixture | 1013 | 1572864 | 272.1 | 92.0 | 3.0x | 5x | yes |
| LightClientOptimisticUpdate.serialize | small-fixture | 1000 | 1572864 | 270.2 | 90.6 | 3.0x | 5x | yes |
| LightClientUpdate.deserialize | large-fixture | 26914 | 204800 | 2407.2 | 8898.6 | 0.3x | 5x | yes |
| LightClientUpdate.deserialize | medium-fixture | 26893 | 204800 | 2387.7 | 9079.1 | 0.3x | 5x | yes |
| LightClientUpdate.deserialize | small-fixture | 26885 | 204800 | 2407.2 | 8920.9 | 0.3x | 5x | yes |
| LightClientUpdate.hash_tree_root | large-fixture | 26914 | 1536 | 315104.2 | 81964.7 | 3.8x | 10x | yes |
| LightClientUpdate.hash_tree_root | medium-fixture | 26893 | 1536 | 315104.2 | 82029.9 | 3.8x | 10x | yes |
| LightClientUpdate.hash_tree_root | small-fixture | 26885 | 1536 | 315104.2 | 81939.7 | 3.8x | 10x | yes |
| LightClientUpdate.serialize | large-fixture | 26914 | 253952 | 1921.6 | 1851.7 | 1.0x | 5x | yes |
| LightClientUpdate.serialize | medium-fixture | 26893 | 253952 | 1886.2 | 1709.9 | 1.1x | 5x | yes |
| LightClientUpdate.serialize | small-fixture | 26885 | 253952 | 1917.7 | 1828.8 | 1.0x | 5x | yes |
| MatrixEntry.deserialize | large-fixture | 2112 | 3145728 | 137.6 | 172.3 | 0.8x | 5x | yes |
| MatrixEntry.deserialize | medium-fixture | 2112 | 3145728 | 137.0 | 174.1 | 0.8x | 5x | yes |
| MatrixEntry.deserialize | small-fixture | 2112 | 3145728 | 137.0 | 165.0 | 0.8x | 5x | yes |
| MatrixEntry.hash_tree_root | large-fixture | 2112 | 24576 | 18229.2 | 4471.4 | 4.1x | 10x | yes |
| MatrixEntry.hash_tree_root | medium-fixture | 2112 | 24576 | 18229.2 | 4473.3 | 4.1x | 10x | yes |
| MatrixEntry.hash_tree_root | small-fixture | 2112 | 24576 | 18188.5 | 4475.4 | 4.1x | 10x | yes |
| MatrixEntry.serialize | large-fixture | 2112 | 3670016 | 128.1 | 147.5 | 0.9x | 5x | yes |
| MatrixEntry.serialize | medium-fixture | 2112 | 3670016 | 127.5 | 136.4 | 0.9x | 5x | yes |
| MatrixEntry.serialize | small-fixture | 2112 | 3670016 | 127.0 | 143.1 | 0.9x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 26.4 | 34.9 | 0.8x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | saturated | 192 | 5000000 | 26.4 | 35.7 | 0.7x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 24.2 | 36.8 | 0.7x | 5x | yes |
| NextSyncCommitteeBranch.hash_tree_root | random | 192 | 167936 | 1619.7 | 587.5 | 2.8x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | saturated | 192 | 286720 | 1621.8 | 585.2 | 2.8x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | zero | 192 | 286720 | 1621.8 | 588.3 | 2.8x | 10x | yes |
| NextSyncCommitteeBranch.serialize | random | 192 | 5000000 | 19.6 | 20.3 | 1.0x | 5x | yes |
| NextSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 19.4 | 20.3 | 1.0x | 5x | yes |
| NextSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 15.2 | 19.9 | 0.8x | 5x | yes |
| NodeID.deserialize | random | 32 | 5000000 | 25.4 | 27.0 | 0.9x | 5x | yes |
| NodeID.deserialize | saturated | 32 | 5000000 | 26.4 | 27.0 | 1.0x | 5x | yes |
| NodeID.deserialize | zero | 32 | 5000000 | 27.4 | 27.3 | 1.0x | 5x | yes |
| NodeID.hash_tree_root | random | 32 | 5000000 | 4.4 | 126.8 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | saturated | 32 | 5000000 | 4.4 | 129.6 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | zero | 32 | 5000000 | 4.4 | 123.0 | 0.0x | 10x | yes |
| NodeID.serialize | random | 32 | 5000000 | 8.4 | 12.3 | 0.7x | 5x | yes |
| NodeID.serialize | saturated | 32 | 5000000 | 8.4 | 12.4 | 0.7x | 5x | yes |
| NodeID.serialize | zero | 32 | 5000000 | 7.2 | 12.7 | 0.6x | 5x | yes |
| ParticipationFlags.deserialize | random | 1 | 5000000 | 6.6 | 23.1 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | saturated | 1 | 5000000 | 6.6 | 22.8 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | zero | 1 | 5000000 | 6.6 | 22.4 | 0.3x | 5x | yes |
| ParticipationFlags.hash_tree_root | random | 1 | 5000000 | 3.0 | 141.9 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | saturated | 1 | 5000000 | 3.0 | 138.1 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | zero | 1 | 5000000 | 3.0 | 146.5 | 0.0x | 10x | yes |
| ParticipationFlags.serialize | random | 1 | 5000000 | 5.2 | 7.5 | 0.7x | 5x | yes |
| ParticipationFlags.serialize | saturated | 1 | 5000000 | 5.2 | 7.7 | 0.7x | 5x | yes |
| ParticipationFlags.serialize | zero | 1 | 5000000 | 5.2 | 7.6 | 0.7x | 5x | yes |
| PayloadId.deserialize | random | 8 | 5000000 | 11.0 | 23.4 | 0.5x | 5x | yes |
| PayloadId.deserialize | saturated | 8 | 5000000 | 10.8 | 23.3 | 0.5x | 5x | yes |
| PayloadId.deserialize | zero | 8 | 5000000 | 10.8 | 23.2 | 0.5x | 5x | yes |
| PayloadId.hash_tree_root | random | 8 | 5000000 | 3.8 | 137.7 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 135.2 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | zero | 8 | 5000000 | 4.0 | 138.5 | 0.0x | 10x | yes |
| PayloadId.serialize | random | 8 | 5000000 | 6.4 | 8.2 | 0.8x | 5x | yes |
| PayloadId.serialize | saturated | 8 | 5000000 | 6.4 | 8.2 | 0.8x | 5x | yes |
| PayloadId.serialize | zero | 8 | 5000000 | 6.4 | 7.9 | 0.8x | 5x | yes |
| PendingAttestation.deserialize | large-fixture | 150 | 4194304 | 107.0 | 64.1 | 1.7x | 5x | yes |
| PendingAttestation.deserialize | medium-fixture | 149 | 4194304 | 106.8 | 63.5 | 1.7x | 5x | yes |
| PendingAttestation.deserialize | small-fixture | 149 | 4194304 | 107.0 | 63.9 | 1.7x | 5x | yes |
| PendingAttestation.hash_tree_root | large-fixture | 150 | 114688 | 4010.9 | 1096.8 | 3.7x | 10x | yes |
| PendingAttestation.hash_tree_root | medium-fixture | 149 | 122880 | 4003.9 | 1094.6 | 3.7x | 10x | yes |
| PendingAttestation.hash_tree_root | small-fixture | 149 | 114688 | 4002.2 | 1095.5 | 3.7x | 10x | yes |
| PendingAttestation.serialize | large-fixture | 150 | 5000000 | 47.0 | 24.8 | 1.9x | 5x | yes |
| PendingAttestation.serialize | medium-fixture | 149 | 5000000 | 46.6 | 25.1 | 1.9x | 5x | yes |
| PendingAttestation.serialize | small-fixture | 149 | 5000000 | 47.0 | 24.6 | 1.9x | 5x | yes |
| PendingConsolidation.deserialize | large-fixture | 16 | 5000000 | 15.6 | 10.8 | 1.4x | 5x | yes |
| PendingConsolidation.deserialize | medium-fixture | 16 | 5000000 | 15.4 | 10.9 | 1.4x | 5x | yes |
| PendingConsolidation.deserialize | small-fixture | 16 | 5000000 | 15.6 | 10.9 | 1.4x | 5x | yes |
| PendingConsolidation.hash_tree_root | large-fixture | 16 | 1572864 | 270.2 | 100.3 | 2.7x | 10x | yes |
| PendingConsolidation.hash_tree_root | medium-fixture | 16 | 1572864 | 270.2 | 100.4 | 2.7x | 10x | yes |
| PendingConsolidation.hash_tree_root | small-fixture | 16 | 1572864 | 270.2 | 100.4 | 2.7x | 10x | yes |
| PendingConsolidation.serialize | large-fixture | 16 | 5000000 | 6.6 | 12.6 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | medium-fixture | 16 | 5000000 | 6.6 | 12.5 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | small-fixture | 16 | 5000000 | 6.6 | 12.6 | 0.5x | 5x | yes |
| PendingDeposit.deserialize | large-fixture | 192 | 5000000 | 87.2 | 38.3 | 2.3x | 5x | yes |
| PendingDeposit.deserialize | medium-fixture | 192 | 5000000 | 87.4 | 38.0 | 2.3x | 5x | yes |
| PendingDeposit.deserialize | small-fixture | 192 | 2621440 | 91.6 | 38.7 | 2.4x | 5x | yes |
| PendingDeposit.hash_tree_root | large-fixture | 192 | 180224 | 2646.7 | 723.3 | 3.7x | 10x | yes |
| PendingDeposit.hash_tree_root | medium-fixture | 192 | 180224 | 2646.7 | 724.7 | 3.7x | 10x | yes |
| PendingDeposit.hash_tree_root | small-fixture | 192 | 180224 | 2646.7 | 722.9 | 3.7x | 10x | yes |
| PendingDeposit.serialize | large-fixture | 192 | 5000000 | 31.2 | 22.9 | 1.4x | 5x | yes |
| PendingDeposit.serialize | medium-fixture | 192 | 5000000 | 31.2 | 23.0 | 1.4x | 5x | yes |
| PendingDeposit.serialize | small-fixture | 192 | 5000000 | 31.2 | 22.0 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | large-fixture | 24 | 5000000 | 17.8 | 12.7 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | medium-fixture | 24 | 5000000 | 17.4 | 12.5 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | small-fixture | 24 | 5000000 | 17.6 | 12.5 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.hash_tree_root | large-fixture | 24 | 524288 | 799.2 | 238.5 | 3.4x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | medium-fixture | 24 | 524288 | 797.3 | 238.4 | 3.3x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | small-fixture | 24 | 524288 | 797.3 | 238.3 | 3.3x | 10x | yes |
| PendingPartialWithdrawal.serialize | large-fixture | 24 | 5000000 | 6.8 | 14.7 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | medium-fixture | 24 | 5000000 | 6.8 | 14.5 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | small-fixture | 24 | 5000000 | 6.8 | 14.5 | 0.5x | 5x | yes |
| PowBlock.deserialize | large-fixture | 96 | 5000000 | 40.4 | 54.7 | 0.7x | 5x | yes |
| PowBlock.deserialize | medium-fixture | 96 | 5000000 | 40.8 | 56.5 | 0.7x | 5x | yes |
| PowBlock.deserialize | small-fixture | 96 | 5000000 | 40.6 | 56.1 | 0.7x | 5x | yes |
| PowBlock.hash_tree_root | large-fixture | 96 | 524288 | 799.2 | 240.2 | 3.3x | 10x | yes |
| PowBlock.hash_tree_root | medium-fixture | 96 | 524288 | 801.1 | 240.5 | 3.3x | 10x | yes |
| PowBlock.hash_tree_root | small-fixture | 96 | 524288 | 799.2 | 240.3 | 3.3x | 10x | yes |
| PowBlock.serialize | large-fixture | 96 | 5000000 | 16.2 | 17.3 | 0.9x | 5x | yes |
| PowBlock.serialize | medium-fixture | 96 | 5000000 | 16.2 | 17.7 | 0.9x | 5x | yes |
| PowBlock.serialize | small-fixture | 96 | 5000000 | 16.2 | 17.1 | 0.9x | 5x | yes |
| ProposerSlashing.deserialize | large-fixture | 416 | 1572864 | 265.1 | 83.9 | 3.2x | 5x | yes |
| ProposerSlashing.deserialize | medium-fixture | 416 | 1572864 | 261.3 | 83.3 | 3.1x | 5x | yes |
| ProposerSlashing.deserialize | small-fixture | 416 | 1572864 | 265.8 | 83.8 | 3.2x | 5x | yes |
| ProposerSlashing.hash_tree_root | large-fixture | 416 | 81920 | 5578.6 | 1511.5 | 3.7x | 10x | yes |
| ProposerSlashing.hash_tree_root | medium-fixture | 416 | 81920 | 5590.8 | 1511.3 | 3.7x | 10x | yes |
| ProposerSlashing.hash_tree_root | small-fixture | 416 | 81920 | 5578.6 | 1514.9 | 3.7x | 10x | yes |
| ProposerSlashing.serialize | large-fixture | 416 | 5000000 | 93.8 | 37.6 | 2.5x | 5x | yes |
| ProposerSlashing.serialize | medium-fixture | 416 | 5000000 | 93.6 | 38.9 | 2.4x | 5x | yes |
| ProposerSlashing.serialize | small-fixture | 416 | 5000000 | 93.8 | 38.8 | 2.4x | 5x | yes |
| Root.deserialize | random | 32 | 5000000 | 26.4 | 27.5 | 1.0x | 5x | yes |
| Root.deserialize | saturated | 32 | 5000000 | 27.0 | 27.2 | 1.0x | 5x | yes |
| Root.deserialize | zero | 32 | 5000000 | 26.8 | 26.9 | 1.0x | 5x | yes |
| Root.hash_tree_root | random | 32 | 5000000 | 4.2 | 131.4 | 0.0x | 10x | yes |
| Root.hash_tree_root | saturated | 32 | 5000000 | 4.2 | 127.2 | 0.0x | 10x | yes |
| Root.hash_tree_root | zero | 32 | 5000000 | 4.2 | 129.3 | 0.0x | 10x | yes |
| Root.serialize | random | 32 | 5000000 | 7.8 | 12.6 | 0.6x | 5x | yes |
| Root.serialize | saturated | 32 | 5000000 | 7.8 | 12.5 | 0.6x | 5x | yes |
| Root.serialize | zero | 32 | 5000000 | 7.2 | 12.3 | 0.6x | 5x | yes |
| RowIndex.deserialize | random | 8 | 5000000 | 13.4 | 23.0 | 0.6x | 5x | yes |
| RowIndex.deserialize | saturated | 8 | 5000000 | 13.6 | 23.3 | 0.6x | 5x | yes |
| RowIndex.deserialize | zero | 8 | 5000000 | 13.4 | 23.5 | 0.6x | 5x | yes |
| RowIndex.hash_tree_root | random | 8 | 5000000 | 3.8 | 135.1 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | saturated | 8 | 5000000 | 3.6 | 136.0 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | zero | 8 | 5000000 | 3.8 | 136.3 | 0.0x | 10x | yes |
| RowIndex.serialize | random | 8 | 5000000 | 6.2 | 8.1 | 0.8x | 5x | yes |
| RowIndex.serialize | saturated | 8 | 5000000 | 6.0 | 8.0 | 0.7x | 5x | yes |
| RowIndex.serialize | zero | 8 | 5000000 | 6.2 | 8.0 | 0.8x | 5x | yes |
| SignedAggregateAndProof.deserialize | large-fixture | 446 | 1572864 | 317.3 | 129.3 | 2.5x | 5x | yes |
| SignedAggregateAndProof.deserialize | medium-fixture | 445 | 786432 | 303.9 | 129.2 | 2.4x | 5x | yes |
| SignedAggregateAndProof.deserialize | small-fixture | 445 | 1572864 | 307.7 | 130.3 | 2.4x | 5x | yes |
| SignedAggregateAndProof.hash_tree_root | large-fixture | 446 | 49152 | 9216.3 | 2413.9 | 3.8x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | medium-fixture | 445 | 73728 | 6781.7 | 1809.2 | 3.7x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | small-fixture | 445 | 49152 | 9196.0 | 2414.2 | 3.8x | 10x | yes |
| SignedAggregateAndProof.serialize | large-fixture | 446 | 2621440 | 185.4 | 47.9 | 3.9x | 5x | yes |
| SignedAggregateAndProof.serialize | medium-fixture | 445 | 2621440 | 178.5 | 49.0 | 3.6x | 5x | yes |
| SignedAggregateAndProof.serialize | small-fixture | 445 | 2621440 | 182.7 | 48.9 | 3.7x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | large-fixture | 172 | 5000000 | 93.4 | 33.0 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | medium-fixture | 172 | 5000000 | 93.4 | 33.2 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | small-fixture | 172 | 2621440 | 95.4 | 33.5 | 2.8x | 5x | yes |
| SignedBLSToExecutionChange.hash_tree_root | large-fixture | 172 | 221184 | 2129.4 | 602.2 | 3.5x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | medium-fixture | 172 | 221184 | 2138.5 | 602.2 | 3.6x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | small-fixture | 172 | 221184 | 2134.0 | 601.8 | 3.5x | 10x | yes |
| SignedBLSToExecutionChange.serialize | large-fixture | 172 | 5000000 | 29.6 | 21.9 | 1.3x | 5x | yes |
| SignedBLSToExecutionChange.serialize | medium-fixture | 172 | 5000000 | 29.6 | 21.5 | 1.4x | 5x | yes |
| SignedBLSToExecutionChange.serialize | small-fixture | 172 | 5000000 | 29.6 | 22.6 | 1.3x | 5x | yes |
| SignedBeaconBlock.deserialize | large-fixture | 23999 | 57344 | 8213.6 | 8905.7 | 0.9x | 5x | yes |
| SignedBeaconBlock.deserialize | medium-fixture | 18718 | 65536 | 7553.1 | 7359.6 | 1.0x | 5x | yes |
| SignedBeaconBlock.deserialize | small-fixture | 16683 | 106496 | 4563.6 | 7013.0 | 0.7x | 5x | yes |
| SignedBeaconBlock.hash_tree_root | large-fixture | 23999 | 1408 | 328835.2 | 84331.2 | 3.9x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | medium-fixture | 18718 | 1792 | 266741.1 | 69306.0 | 3.8x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | small-fixture | 16683 | 2176 | 218290.4 | 56556.5 | 3.9x | 10x | yes |
| SignedBeaconBlock.serialize | large-fixture | 23999 | 114688 | 4263.7 | 1588.5 | 2.7x | 5x | yes |
| SignedBeaconBlock.serialize | medium-fixture | 18718 | 114688 | 4028.3 | 1176.5 | 3.4x | 5x | yes |
| SignedBeaconBlock.serialize | small-fixture | 16683 | 180224 | 2729.9 | 981.7 | 2.8x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | large-fixture | 208 | 3145728 | 142.7 | 35.5 | 4.0x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | medium-fixture | 208 | 3145728 | 154.8 | 35.9 | 4.3x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | small-fixture | 208 | 3145728 | 144.3 | 36.3 | 4.0x | 5x | yes |
| SignedBeaconBlockHeader.hash_tree_root | large-fixture | 208 | 180224 | 2663.4 | 729.2 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | medium-fixture | 208 | 180224 | 2668.9 | 728.5 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | small-fixture | 208 | 180224 | 2668.9 | 728.0 | 3.7x | 10x | yes |
| SignedBeaconBlockHeader.serialize | large-fixture | 208 | 5000000 | 35.2 | 25.2 | 1.4x | 5x | yes |
| SignedBeaconBlockHeader.serialize | medium-fixture | 208 | 5000000 | 35.2 | 24.4 | 1.4x | 5x | yes |
| SignedBeaconBlockHeader.serialize | small-fixture | 208 | 5000000 | 35.2 | 24.6 | 1.4x | 5x | yes |
| SignedContributionAndProof.deserialize | large-fixture | 360 | 2097152 | 216.0 | 84.8 | 2.5x | 5x | yes |
| SignedContributionAndProof.deserialize | medium-fixture | 360 | 2097152 | 215.5 | 82.8 | 2.6x | 5x | yes |
| SignedContributionAndProof.deserialize | small-fixture | 360 | 2097152 | 215.5 | 82.6 | 2.6x | 5x | yes |
| SignedContributionAndProof.hash_tree_root | large-fixture | 360 | 98304 | 5055.7 | 1360.8 | 3.7x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | medium-fixture | 360 | 90112 | 5060.4 | 1359.9 | 3.7x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | small-fixture | 360 | 98304 | 5055.7 | 1363.2 | 3.7x | 10x | yes |
| SignedContributionAndProof.serialize | large-fixture | 360 | 5000000 | 84.4 | 38.1 | 2.2x | 5x | yes |
| SignedContributionAndProof.serialize | medium-fixture | 360 | 5000000 | 84.4 | 36.6 | 2.3x | 5x | yes |
| SignedContributionAndProof.serialize | small-fixture | 360 | 5000000 | 84.4 | 36.8 | 2.3x | 5x | yes |
| SignedVoluntaryExit.deserialize | large-fixture | 112 | 5000000 | 54.0 | 29.5 | 1.8x | 5x | yes |
| SignedVoluntaryExit.deserialize | medium-fixture | 112 | 5000000 | 54.4 | 30.4 | 1.8x | 5x | yes |
| SignedVoluntaryExit.deserialize | small-fixture | 112 | 5000000 | 55.0 | 29.6 | 1.9x | 5x | yes |
| SignedVoluntaryExit.hash_tree_root | large-fixture | 112 | 204800 | 1342.8 | 391.2 | 3.4x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | medium-fixture | 112 | 204800 | 1337.9 | 391.3 | 3.4x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | small-fixture | 112 | 204800 | 1337.9 | 391.6 | 3.4x | 10x | yes |
| SignedVoluntaryExit.serialize | large-fixture | 112 | 5000000 | 20.8 | 18.9 | 1.1x | 5x | yes |
| SignedVoluntaryExit.serialize | medium-fixture | 112 | 5000000 | 20.6 | 19.0 | 1.1x | 5x | yes |
| SignedVoluntaryExit.serialize | small-fixture | 112 | 5000000 | 20.8 | 18.7 | 1.1x | 5x | yes |
| SigningData.deserialize | large-fixture | 64 | 5000000 | 41.0 | 13.4 | 3.1x | 5x | yes |
| SigningData.deserialize | medium-fixture | 64 | 5000000 | 41.0 | 13.5 | 3.0x | 5x | yes |
| SigningData.deserialize | small-fixture | 64 | 5000000 | 41.0 | 13.1 | 3.1x | 5x | yes |
| SigningData.hash_tree_root | large-fixture | 64 | 1572864 | 276.6 | 101.7 | 2.7x | 10x | yes |
| SigningData.hash_tree_root | medium-fixture | 64 | 1572864 | 275.3 | 101.7 | 2.7x | 10x | yes |
| SigningData.hash_tree_root | small-fixture | 64 | 1572864 | 275.3 | 101.7 | 2.7x | 10x | yes |
| SigningData.serialize | large-fixture | 64 | 5000000 | 12.6 | 14.9 | 0.8x | 5x | yes |
| SigningData.serialize | medium-fixture | 64 | 5000000 | 12.4 | 14.8 | 0.8x | 5x | yes |
| SigningData.serialize | small-fixture | 64 | 5000000 | 12.4 | 14.7 | 0.8x | 5x | yes |
| SingleAttestation.deserialize | large-fixture | 240 | 2621440 | 167.1 | 57.6 | 2.9x | 5x | yes |
| SingleAttestation.deserialize | medium-fixture | 240 | 2621440 | 165.9 | 58.3 | 2.8x | 5x | yes |
| SingleAttestation.deserialize | small-fixture | 240 | 2621440 | 162.5 | 57.8 | 2.8x | 5x | yes |
| SingleAttestation.hash_tree_root | large-fixture | 240 | 131072 | 3707.9 | 1025.6 | 3.6x | 10x | yes |
| SingleAttestation.hash_tree_root | medium-fixture | 240 | 131072 | 3715.5 | 1024.7 | 3.6x | 10x | yes |
| SingleAttestation.hash_tree_root | small-fixture | 240 | 131072 | 3715.5 | 1025.0 | 3.6x | 10x | yes |
| SingleAttestation.serialize | large-fixture | 240 | 5000000 | 38.2 | 28.9 | 1.3x | 5x | yes |
| SingleAttestation.serialize | medium-fixture | 240 | 5000000 | 38.2 | 27.0 | 1.4x | 5x | yes |
| SingleAttestation.serialize | small-fixture | 240 | 5000000 | 38.4 | 28.3 | 1.4x | 5x | yes |
| Slot.deserialize | random | 8 | 5000000 | 9.8 | 23.0 | 0.4x | 5x | yes |
| Slot.deserialize | saturated | 8 | 5000000 | 9.6 | 23.2 | 0.4x | 5x | yes |
| Slot.deserialize | zero | 8 | 5000000 | 9.8 | 23.4 | 0.4x | 5x | yes |
| Slot.hash_tree_root | random | 8 | 5000000 | 3.6 | 136.8 | 0.0x | 10x | yes |
| Slot.hash_tree_root | saturated | 8 | 5000000 | 3.6 | 138.5 | 0.0x | 10x | yes |
| Slot.hash_tree_root | zero | 8 | 5000000 | 3.4 | 141.1 | 0.0x | 10x | yes |
| Slot.serialize | random | 8 | 5000000 | 5.2 | 8.4 | 0.6x | 5x | yes |
| Slot.serialize | saturated | 8 | 5000000 | 5.2 | 8.3 | 0.6x | 5x | yes |
| Slot.serialize | zero | 8 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| SubnetID.deserialize | random | 8 | 5000000 | 14.6 | 23.6 | 0.6x | 5x | yes |
| SubnetID.deserialize | saturated | 8 | 5000000 | 14.4 | 23.2 | 0.6x | 5x | yes |
| SubnetID.deserialize | zero | 8 | 5000000 | 14.4 | 23.1 | 0.6x | 5x | yes |
| SubnetID.hash_tree_root | random | 8 | 5000000 | 3.8 | 141.8 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | saturated | 8 | 5000000 | 3.8 | 135.1 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | zero | 8 | 5000000 | 3.8 | 139.2 | 0.0x | 10x | yes |
| SubnetID.serialize | random | 8 | 5000000 | 6.0 | 8.3 | 0.7x | 5x | yes |
| SubnetID.serialize | saturated | 8 | 5000000 | 6.2 | 8.3 | 0.8x | 5x | yes |
| SubnetID.serialize | zero | 8 | 5000000 | 6.0 | 8.1 | 0.7x | 5x | yes |
| SyncAggregate.deserialize | large-fixture | 160 | 5000000 | 75.4 | 33.7 | 2.2x | 5x | yes |
| SyncAggregate.deserialize | medium-fixture | 160 | 5000000 | 74.8 | 33.4 | 2.2x | 5x | yes |
| SyncAggregate.deserialize | small-fixture | 160 | 5000000 | 72.4 | 33.5 | 2.2x | 5x | yes |
| SyncAggregate.hash_tree_root | large-fixture | 160 | 204800 | 1337.9 | 387.7 | 3.5x | 10x | yes |
| SyncAggregate.hash_tree_root | medium-fixture | 160 | 204800 | 1337.9 | 387.0 | 3.5x | 10x | yes |
| SyncAggregate.hash_tree_root | small-fixture | 160 | 204800 | 1337.9 | 387.4 | 3.5x | 10x | yes |
| SyncAggregate.serialize | large-fixture | 160 | 5000000 | 27.6 | 21.0 | 1.3x | 5x | yes |
| SyncAggregate.serialize | medium-fixture | 160 | 5000000 | 27.6 | 20.8 | 1.3x | 5x | yes |
| SyncAggregate.serialize | small-fixture | 160 | 5000000 | 27.4 | 20.7 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | large-fixture | 16 | 5000000 | 13.6 | 10.8 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | medium-fixture | 16 | 5000000 | 13.6 | 10.8 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | small-fixture | 16 | 5000000 | 13.6 | 10.7 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.hash_tree_root | large-fixture | 16 | 1572864 | 267.0 | 100.3 | 2.7x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | medium-fixture | 16 | 1572864 | 266.4 | 100.3 | 2.7x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | small-fixture | 16 | 1572864 | 267.0 | 100.4 | 2.7x | 10x | yes |
| SyncAggregatorSelectionData.serialize | large-fixture | 16 | 5000000 | 5.8 | 12.5 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | medium-fixture | 16 | 5000000 | 5.8 | 12.6 | 0.5x | 5x | yes |
| SyncAggregatorSelectionData.serialize | small-fixture | 16 | 5000000 | 5.8 | 12.3 | 0.5x | 5x | yes |
| SyncCommittee.deserialize | large-fixture | 24624 | 253952 | 1078.9 | 1189.1 | 0.9x | 5x | yes |
| SyncCommittee.deserialize | medium-fixture | 24624 | 253952 | 1078.9 | 1215.1 | 0.9x | 5x | yes |
| SyncCommittee.deserialize | small-fixture | 24624 | 409600 | 1076.7 | 1182.7 | 0.9x | 5x | yes |
| SyncCommittee.hash_tree_root | large-fixture | 24624 | 1664 | 284855.8 | 80969.1 | 3.5x | 10x | yes |
| SyncCommittee.hash_tree_root | medium-fixture | 24624 | 1664 | 284254.8 | 81352.4 | 3.5x | 10x | yes |
| SyncCommittee.hash_tree_root | small-fixture | 24624 | 1664 | 284855.8 | 81355.7 | 3.5x | 10x | yes |
| SyncCommittee.serialize | large-fixture | 24624 | 253952 | 1067.1 | 1579.4 | 0.7x | 5x | yes |
| SyncCommittee.serialize | medium-fixture | 24624 | 253952 | 1067.1 | 1701.7 | 0.6x | 5x | yes |
| SyncCommittee.serialize | small-fixture | 24624 | 253952 | 1067.1 | 1516.7 | 0.7x | 5x | yes |
| SyncCommitteeContribution.deserialize | large-fixture | 160 | 5000000 | 91.6 | 35.7 | 2.6x | 5x | yes |
| SyncCommitteeContribution.deserialize | medium-fixture | 160 | 5000000 | 91.8 | 35.2 | 2.6x | 5x | yes |
| SyncCommitteeContribution.deserialize | small-fixture | 160 | 5000000 | 91.8 | 34.8 | 2.6x | 5x | yes |
| SyncCommitteeContribution.hash_tree_root | large-fixture | 160 | 110592 | 2405.2 | 650.9 | 3.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | medium-fixture | 160 | 204800 | 2402.3 | 651.8 | 3.7x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | small-fixture | 160 | 110592 | 2405.2 | 651.4 | 3.7x | 10x | yes |
| SyncCommitteeContribution.serialize | large-fixture | 160 | 5000000 | 28.4 | 21.0 | 1.4x | 5x | yes |
| SyncCommitteeContribution.serialize | medium-fixture | 160 | 5000000 | 28.4 | 21.8 | 1.3x | 5x | yes |
| SyncCommitteeContribution.serialize | small-fixture | 160 | 5000000 | 28.4 | 21.8 | 1.3x | 5x | yes |
| SyncCommitteeMessage.deserialize | large-fixture | 144 | 5000000 | 69.8 | 18.2 | 3.8x | 5x | yes |
| SyncCommitteeMessage.deserialize | medium-fixture | 144 | 5000000 | 70.4 | 19.1 | 3.7x | 5x | yes |
| SyncCommitteeMessage.deserialize | small-fixture | 144 | 5000000 | 69.4 | 18.3 | 3.8x | 5x | yes |
| SyncCommitteeMessage.hash_tree_root | large-fixture | 144 | 167936 | 1589.9 | 448.9 | 3.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | medium-fixture | 144 | 286720 | 1590.4 | 449.8 | 3.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | small-fixture | 144 | 286720 | 1586.9 | 449.2 | 3.5x | 10x | yes |
| SyncCommitteeMessage.serialize | large-fixture | 144 | 5000000 | 28.6 | 20.8 | 1.4x | 5x | yes |
| SyncCommitteeMessage.serialize | medium-fixture | 144 | 5000000 | 28.4 | 20.5 | 1.4x | 5x | yes |
| SyncCommitteeMessage.serialize | small-fixture | 144 | 5000000 | 28.4 | 20.8 | 1.4x | 5x | yes |
| Transaction.deserialize | large | 1048576 | 8192 | 53955.1 | 41423.1 | 1.3x | 5x | yes |
| Transaction.deserialize | medium | 4096 | 1572864 | 252.4 | 268.8 | 0.9x | 5x | yes |
| Transaction.deserialize | small | 32 | 5000000 | 17.2 | 27.3 | 0.6x | 5x | yes |
| Transaction.hash_tree_root | large | 1048576 | 54 | 8925925.9 | 2212402.3 | 4.0x | 10x | yes |
| Transaction.hash_tree_root | medium | 4096 | 8192 | 39428.7 | 10042.9 | 3.9x | 10x | yes |
| Transaction.hash_tree_root | small | 32 | 65536 | 7003.8 | 1915.4 | 3.7x | 10x | yes |
| Transaction.serialize | large | 1048576 | 8192 | 45776.4 | 40930.5 | 1.1x | 5x | yes |
| Transaction.serialize | medium | 4096 | 2097152 | 202.2 | 239.0 | 0.8x | 5x | yes |
| Transaction.serialize | small | 32 | 5000000 | 12.0 | 12.4 | 1.0x | 5x | yes |
| Validator.deserialize | large-fixture | 121 | 5000000 | 68.0 | 31.7 | 2.1x | 5x | yes |
| Validator.deserialize | medium-fixture | 121 | 3670016 | 68.1 | 32.3 | 2.1x | 5x | yes |
| Validator.deserialize | small-fixture | 121 | 5000000 | 68.0 | 31.7 | 2.1x | 5x | yes |
| Validator.hash_tree_root | large-fixture | 121 | 221184 | 2129.4 | 589.4 | 3.6x | 10x | yes |
| Validator.hash_tree_root | medium-fixture | 121 | 221184 | 2129.4 | 588.7 | 3.6x | 10x | yes |
| Validator.hash_tree_root | small-fixture | 121 | 221184 | 2129.4 | 589.5 | 3.6x | 10x | yes |
| Validator.serialize | large-fixture | 121 | 5000000 | 22.0 | 19.2 | 1.1x | 5x | yes |
| Validator.serialize | medium-fixture | 121 | 5000000 | 21.8 | 20.0 | 1.1x | 5x | yes |
| Validator.serialize | small-fixture | 121 | 5000000 | 21.6 | 19.5 | 1.1x | 5x | yes |
| ValidatorIndex.deserialize | random | 8 | 5000000 | 10.6 | 23.4 | 0.5x | 5x | yes |
| ValidatorIndex.deserialize | saturated | 8 | 5000000 | 10.4 | 23.4 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | zero | 8 | 5000000 | 11.0 | 23.4 | 0.5x | 5x | yes |
| ValidatorIndex.hash_tree_root | random | 8 | 5000000 | 3.6 | 137.8 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | saturated | 8 | 5000000 | 3.6 | 138.4 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | zero | 8 | 5000000 | 3.6 | 144.3 | 0.0x | 10x | yes |
| ValidatorIndex.serialize | random | 8 | 5000000 | 5.4 | 8.1 | 0.7x | 5x | yes |
| ValidatorIndex.serialize | saturated | 8 | 5000000 | 5.4 | 8.0 | 0.7x | 5x | yes |
| ValidatorIndex.serialize | zero | 8 | 5000000 | 5.4 | 8.1 | 0.7x | 5x | yes |
| Version.deserialize | random | 4 | 5000000 | 5.0 | 24.0 | 0.2x | 5x | yes |
| Version.deserialize | saturated | 4 | 5000000 | 5.0 | 24.1 | 0.2x | 5x | yes |
| Version.deserialize | zero | 4 | 5000000 | 5.0 | 24.5 | 0.2x | 5x | yes |
| Version.hash_tree_root | random | 4 | 5000000 | 3.0 | 140.8 | 0.0x | 10x | yes |
| Version.hash_tree_root | saturated | 4 | 5000000 | 3.0 | 137.4 | 0.0x | 10x | yes |
| Version.hash_tree_root | zero | 4 | 5000000 | 3.0 | 132.2 | 0.0x | 10x | yes |
| Version.serialize | random | 4 | 5000000 | 4.8 | 8.1 | 0.6x | 5x | yes |
| Version.serialize | saturated | 4 | 5000000 | 4.8 | 8.2 | 0.6x | 5x | yes |
| Version.serialize | zero | 4 | 5000000 | 4.8 | 8.2 | 0.6x | 5x | yes |
| VersionedHash.deserialize | random | 32 | 5000000 | 21.4 | 27.1 | 0.8x | 5x | yes |
| VersionedHash.deserialize | saturated | 32 | 5000000 | 20.4 | 27.2 | 0.8x | 5x | yes |
| VersionedHash.deserialize | zero | 32 | 5000000 | 20.4 | 26.7 | 0.8x | 5x | yes |
| VersionedHash.hash_tree_root | random | 32 | 5000000 | 4.4 | 129.5 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | saturated | 32 | 5000000 | 4.4 | 125.6 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | zero | 32 | 5000000 | 4.4 | 128.2 | 0.0x | 10x | yes |
| VersionedHash.serialize | random | 32 | 5000000 | 7.4 | 12.5 | 0.6x | 5x | yes |
| VersionedHash.serialize | saturated | 32 | 5000000 | 7.6 | 12.5 | 0.6x | 5x | yes |
| VersionedHash.serialize | zero | 32 | 5000000 | 7.4 | 12.4 | 0.6x | 5x | yes |
| VoluntaryExit.deserialize | large-fixture | 16 | 5000000 | 16.0 | 10.6 | 1.5x | 5x | yes |
| VoluntaryExit.deserialize | medium-fixture | 16 | 5000000 | 16.2 | 10.9 | 1.5x | 5x | yes |
| VoluntaryExit.deserialize | small-fixture | 16 | 5000000 | 16.4 | 10.7 | 1.5x | 5x | yes |
| VoluntaryExit.hash_tree_root | large-fixture | 16 | 1572864 | 270.8 | 100.5 | 2.7x | 10x | yes |
| VoluntaryExit.hash_tree_root | medium-fixture | 16 | 1572864 | 270.8 | 100.6 | 2.7x | 10x | yes |
| VoluntaryExit.hash_tree_root | small-fixture | 16 | 1572864 | 270.2 | 100.3 | 2.7x | 10x | yes |
| VoluntaryExit.serialize | large-fixture | 16 | 5000000 | 6.8 | 12.7 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | medium-fixture | 16 | 5000000 | 6.6 | 12.6 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | small-fixture | 16 | 5000000 | 6.8 | 12.5 | 0.5x | 5x | yes |
| Withdrawal.deserialize | large-fixture | 44 | 5000000 | 29.8 | 13.1 | 2.3x | 5x | yes |
| Withdrawal.deserialize | medium-fixture | 44 | 5000000 | 29.6 | 12.8 | 2.3x | 5x | yes |
| Withdrawal.deserialize | small-fixture | 44 | 5000000 | 29.6 | 13.0 | 2.3x | 5x | yes |
| Withdrawal.hash_tree_root | large-fixture | 44 | 524288 | 804.9 | 243.3 | 3.3x | 10x | yes |
| Withdrawal.hash_tree_root | medium-fixture | 44 | 524288 | 803.0 | 243.4 | 3.3x | 10x | yes |
| Withdrawal.hash_tree_root | small-fixture | 44 | 524288 | 804.9 | 243.1 | 3.3x | 10x | yes |
| Withdrawal.serialize | large-fixture | 44 | 5000000 | 10.2 | 14.7 | 0.7x | 5x | yes |
| Withdrawal.serialize | medium-fixture | 44 | 5000000 | 10.2 | 14.9 | 0.7x | 5x | yes |
| Withdrawal.serialize | small-fixture | 44 | 5000000 | 10.0 | 15.3 | 0.7x | 5x | yes |
| WithdrawalIndex.deserialize | random | 8 | 5000000 | 13.0 | 23.3 | 0.6x | 5x | yes |
| WithdrawalIndex.deserialize | saturated | 8 | 5000000 | 12.8 | 23.3 | 0.5x | 5x | yes |
| WithdrawalIndex.deserialize | zero | 8 | 5000000 | 12.6 | 23.4 | 0.5x | 5x | yes |
| WithdrawalIndex.hash_tree_root | random | 8 | 5000000 | 3.6 | 138.0 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | saturated | 8 | 5000000 | 3.6 | 137.1 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | zero | 8 | 5000000 | 3.6 | 134.1 | 0.0x | 10x | yes |
| WithdrawalIndex.serialize | random | 8 | 5000000 | 6.4 | 8.1 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | saturated | 8 | 5000000 | 6.4 | 8.1 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | zero | 8 | 5000000 | 6.4 | 8.1 | 0.8x | 5x | yes |
| WithdrawalRequest.deserialize | large-fixture | 76 | 5000000 | 34.4 | 14.7 | 2.3x | 5x | yes |
| WithdrawalRequest.deserialize | medium-fixture | 76 | 5000000 | 34.2 | 14.8 | 2.3x | 5x | yes |
| WithdrawalRequest.deserialize | small-fixture | 76 | 5000000 | 34.2 | 14.7 | 2.3x | 5x | yes |
| WithdrawalRequest.hash_tree_root | large-fixture | 76 | 253952 | 1063.2 | 317.0 | 3.4x | 10x | yes |
| WithdrawalRequest.hash_tree_root | medium-fixture | 76 | 253952 | 1059.3 | 317.6 | 3.3x | 10x | yes |
| WithdrawalRequest.hash_tree_root | small-fixture | 76 | 409600 | 1059.6 | 317.0 | 3.3x | 10x | yes |
| WithdrawalRequest.serialize | large-fixture | 76 | 5000000 | 15.2 | 16.3 | 0.9x | 5x | yes |
| WithdrawalRequest.serialize | medium-fixture | 76 | 5000000 | 15.2 | 16.1 | 0.9x | 5x | yes |
| WithdrawalRequest.serialize | small-fixture | 76 | 5000000 | 15.2 | 16.6 | 0.9x | 5x | yes |
| boolean.deserialize | false | 1 | 5000000 | 4.4 | 23.1 | 0.2x | 5x | yes |
| boolean.deserialize | true | 1 | 5000000 | 4.6 | 23.0 | 0.2x | 5x | yes |
| boolean.hash_tree_root | false | 1 | 5000000 | 3.0 | 136.4 | 0.0x | 10x | yes |
| boolean.hash_tree_root | true | 1 | 5000000 | 3.0 | 141.0 | 0.0x | 10x | yes |
| boolean.serialize | false | 1 | 5000000 | 4.4 | 7.6 | 0.6x | 5x | yes |
| boolean.serialize | true | 1 | 5000000 | 4.6 | 7.6 | 0.6x | 5x | yes |
| uint256.deserialize | random | 32 | 5000000 | 17.0 | 27.4 | 0.6x | 5x | yes |
| uint256.deserialize | saturated | 32 | 5000000 | 17.0 | 27.1 | 0.6x | 5x | yes |
| uint256.deserialize | zero | 32 | 5000000 | 16.4 | 27.1 | 0.6x | 5x | yes |
| uint256.hash_tree_root | random | 32 | 5000000 | 4.0 | 126.5 | 0.0x | 10x | yes |
| uint256.hash_tree_root | saturated | 32 | 5000000 | 4.0 | 130.9 | 0.0x | 10x | yes |
| uint256.hash_tree_root | zero | 32 | 5000000 | 4.0 | 124.7 | 0.0x | 10x | yes |
| uint256.serialize | random | 32 | 5000000 | 6.2 | 12.4 | 0.5x | 5x | yes |
| uint256.serialize | saturated | 32 | 5000000 | 6.2 | 12.6 | 0.5x | 5x | yes |
| uint256.serialize | zero | 32 | 5000000 | 6.4 | 12.5 | 0.5x | 5x | yes |
| uint32.deserialize | random | 4 | 5000000 | 5.2 | 24.0 | 0.2x | 5x | yes |
| uint32.deserialize | saturated | 4 | 5000000 | 5.2 | 24.6 | 0.2x | 5x | yes |
| uint32.deserialize | zero | 4 | 5000000 | 5.2 | 24.1 | 0.2x | 5x | yes |
| uint32.hash_tree_root | random | 4 | 5000000 | 3.2 | 135.4 | 0.0x | 10x | yes |
| uint32.hash_tree_root | saturated | 4 | 5000000 | 3.2 | 137.0 | 0.0x | 10x | yes |
| uint32.hash_tree_root | zero | 4 | 5000000 | 3.2 | 141.2 | 0.0x | 10x | yes |
| uint32.serialize | random | 4 | 5000000 | 5.0 | 8.3 | 0.6x | 5x | yes |
| uint32.serialize | saturated | 4 | 5000000 | 5.0 | 8.1 | 0.6x | 5x | yes |
| uint32.serialize | zero | 4 | 5000000 | 5.0 | 8.1 | 0.6x | 5x | yes |
| uint64.deserialize | random | 8 | 5000000 | 12.8 | 23.2 | 0.6x | 5x | yes |
| uint64.deserialize | saturated | 8 | 5000000 | 12.8 | 23.4 | 0.5x | 5x | yes |
| uint64.deserialize | zero | 8 | 5000000 | 12.8 | 23.2 | 0.6x | 5x | yes |
| uint64.hash_tree_root | random | 8 | 5000000 | 3.6 | 137.7 | 0.0x | 10x | yes |
| uint64.hash_tree_root | saturated | 8 | 5000000 | 3.6 | 134.6 | 0.0x | 10x | yes |
| uint64.hash_tree_root | zero | 8 | 5000000 | 3.4 | 136.9 | 0.0x | 10x | yes |
| uint64.serialize | random | 8 | 5000000 | 5.2 | 8.0 | 0.6x | 5x | yes |
| uint64.serialize | saturated | 8 | 5000000 | 5.2 | 8.1 | 0.6x | 5x | yes |
| uint64.serialize | zero | 8 | 5000000 | 5.2 | 8.2 | 0.6x | 5x | yes |
| uint8.deserialize | random | 1 | 5000000 | 6.2 | 23.0 | 0.3x | 5x | yes |
| uint8.deserialize | saturated | 1 | 5000000 | 6.0 | 22.9 | 0.3x | 5x | yes |
| uint8.deserialize | zero | 1 | 5000000 | 6.2 | 22.9 | 0.3x | 5x | yes |
| uint8.hash_tree_root | random | 1 | 5000000 | 3.0 | 139.9 | 0.0x | 10x | yes |
| uint8.hash_tree_root | saturated | 1 | 5000000 | 3.0 | 134.2 | 0.0x | 10x | yes |
| uint8.hash_tree_root | zero | 1 | 5000000 | 3.0 | 137.3 | 0.0x | 10x | yes |
| uint8.serialize | random | 1 | 5000000 | 4.8 | 7.7 | 0.6x | 5x | yes |
| uint8.serialize | saturated | 1 | 5000000 | 4.6 | 7.5 | 0.6x | 5x | yes |
| uint8.serialize | zero | 1 | 5000000 | 4.6 | 7.5 | 0.6x | 5x | yes |

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
