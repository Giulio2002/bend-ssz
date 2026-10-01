# Native SSZ benchmarks — Bend C versus Go fastssz

Reproduce exactly these numbers with:

```
python3 benchmarks/run.py --report build/performance/report.json
python3 tools/generate_benchmarks_md.py build/performance/report.json
```

## Method

Both sides are native and built fresh by the runner, one sequential thread each.
Bend is the **generated typed owning object API** through its native C
backend, run with `--threads 1 --gpu off`; the measured programs are
`benchmarks/objprog/g<k>.bend` over `types/<Name>_*_generated.bend`, which
`codegen/impl/generate.py` emits from `codegen/fulu.yaml` (see docs/LAYOUT.md).
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
  SHA, foreign crypto or intrinsics. On the Apple M4 host of iteration 22 a
  64-byte node cost about 0.26 us against Go's ~0.06 us, so `hash_tree_root`
  starts about 4x behind before any walking overhead (not re-measured on the
  host of this report). Whether every row meets its 10x limit is stated
  below from this report's own numbers.
* Encode allocates its output with `Array.new(U32, d, 0)`, the only
  allocation the pinned Base offers, which zero-fills a power-of-two number
  of words (measured 0.24 ns/word on the iteration-22 Apple M4 host, against
  0.19 ns/word for the copy itself). Go's `make`/`append` does not pay that. For a flat value such as
  `Blob` the zero-fill alone costs about as much as Go's whole marshal. This
  is a property of the available primitives and is reported, not worked
  around.
* The machine was not idle: other user processes ran throughout (on the
  Linux host a load average near 100 on 48 CPUs). Samples alternate between
  the two sides, so the load affects both, but it widens the sample spread.

| environment | |
|---|---|
| cpu | Intel(R) Xeon(R) Gold 5412U |
| os | Linux-7.0.0-22-generic-x86_64-with-glibc2.43 |
| bend_compiler | bend 2.0.25 |
| reference_compiler | go version go1.26.0 linux/amd64 |
| bend_flags | --threads 1 --gpu off (native C backend, release build) |
| reference_flags | go build (release defaults), GOMAXPROCS=1 |
| reference_revision | go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod) |

## Result against the frozen contract

* 978 measured workloads covering 327 of the 327 required operations.
* 978 of 978 workloads are within their operation limit (deserialize/serialize 5x, hash_tree_root 10x).

Ratio distribution over all measured workloads: minimum 0.0x, median 0.8x, maximum 7.6x.

* `deserialize`: 326 workloads, minimum 0.1x, median 0.8x, maximum 3.0x (limit 5x).
* `serialize`: 326 workloads, minimum 0.4x, median 0.7x, maximum 2.8x (limit 5x).
* `hash_tree_root`: 326 workloads, minimum 0.0x, median 3.9x, maximum 7.6x (limit 10x).

## What the numbers say

Every measured workload is within its limit.

Closest to their limits (median ratio / limit), the rows to re-measure first when
the host changes:

* `Attestation.hash_tree_root` small-fixture: 7.6x of 10x
* `ExecutionPayload.hash_tree_root` medium-fixture: 7.4x of 10x
* `LightClientFinalityUpdate.hash_tree_root` medium-fixture: 7.4x of 10x
* `IndexedAttestation.hash_tree_root` medium-fixture: 6.7x of 10x
* `DataColumnSidecar.hash_tree_root` medium-fixture: 6.7x of 10x

## All measured workloads

| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |
|---|---|---:|---:|---:|---:|---:|---:|:--:|
| AggregateAndProof.deserialize | large-fixture | 346 | 507904 | 685.2 | 380.4 | 1.8x | 5x | yes |
| AggregateAndProof.deserialize | medium-fixture | 345 | 524288 | 728.6 | 424.7 | 1.7x | 5x | yes |
| AggregateAndProof.deserialize | small-fixture | 345 | 524288 | 644.7 | 438.2 | 1.5x | 5x | yes |
| AggregateAndProof.hash_tree_root | large-fixture | 346 | 16384 | 22155.8 | 5109.6 | 4.3x | 10x | yes |
| AggregateAndProof.hash_tree_root | medium-fixture | 345 | 24576 | 16723.6 | 3652.3 | 4.6x | 10x | yes |
| AggregateAndProof.hash_tree_root | small-fixture | 345 | 12288 | 25065.1 | 5317.3 | 4.7x | 10x | yes |
| AggregateAndProof.serialize | large-fixture | 346 | 1310720 | 235.7 | 157.2 | 1.5x | 5x | yes |
| AggregateAndProof.serialize | medium-fixture | 345 | 1572864 | 265.8 | 166.5 | 1.6x | 5x | yes |
| AggregateAndProof.serialize | small-fixture | 345 | 1572864 | 295.0 | 168.7 | 1.7x | 5x | yes |
| Attestation.deserialize | large-fixture | 237 | 524288 | 619.9 | 332.6 | 1.9x | 5x | yes |
| Attestation.deserialize | medium-fixture | 237 | 524288 | 516.9 | 336.4 | 1.5x | 5x | yes |
| Attestation.deserialize | small-fixture | 237 | 524288 | 492.1 | 306.6 | 1.6x | 5x | yes |
| Attestation.hash_tree_root | large-fixture | 237 | 16384 | 22644.0 | 4888.3 | 4.6x | 10x | yes |
| Attestation.hash_tree_root | medium-fixture | 237 | 16384 | 21484.4 | 4218.0 | 5.1x | 10x | yes |
| Attestation.hash_tree_root | small-fixture | 237 | 16384 | 20202.6 | 2641.8 | 7.6x | 10x | yes |
| Attestation.serialize | large-fixture | 237 | 1572864 | 303.9 | 132.4 | 2.3x | 5x | yes |
| Attestation.serialize | medium-fixture | 237 | 1048576 | 337.6 | 121.4 | 2.8x | 5x | yes |
| Attestation.serialize | small-fixture | 237 | 1572864 | 258.8 | 122.2 | 2.1x | 5x | yes |
| AttestationData.deserialize | large-fixture | 128 | 1572864 | 241.0 | 145.5 | 1.7x | 5x | yes |
| AttestationData.deserialize | medium-fixture | 128 | 1048576 | 245.1 | 168.9 | 1.5x | 5x | yes |
| AttestationData.deserialize | small-fixture | 128 | 1572864 | 262.6 | 161.2 | 1.6x | 5x | yes |
| AttestationData.hash_tree_root | large-fixture | 128 | 73728 | 6971.6 | 1379.0 | 5.1x | 10x | yes |
| AttestationData.hash_tree_root | medium-fixture | 128 | 32768 | 5920.4 | 1365.6 | 4.3x | 10x | yes |
| AttestationData.hash_tree_root | small-fixture | 128 | 45056 | 6591.8 | 1788.8 | 3.7x | 10x | yes |
| AttestationData.serialize | large-fixture | 128 | 5000000 | 51.4 | 77.8 | 0.7x | 5x | yes |
| AttestationData.serialize | medium-fixture | 128 | 5000000 | 64.8 | 79.9 | 0.8x | 5x | yes |
| AttestationData.serialize | small-fixture | 128 | 5000000 | 49.6 | 79.7 | 0.6x | 5x | yes |
| AttesterSlashing.deserialize | large-fixture | 624 | 335872 | 1170.1 | 721.6 | 1.6x | 5x | yes |
| AttesterSlashing.deserialize | medium-fixture | 552 | 409600 | 1184.1 | 699.6 | 1.7x | 5x | yes |
| AttesterSlashing.deserialize | small-fixture | 512 | 204800 | 1049.8 | 638.2 | 1.6x | 5x | yes |
| AttesterSlashing.hash_tree_root | large-fixture | 624 | 6400 | 58125.0 | 10611.3 | 5.5x | 10x | yes |
| AttesterSlashing.hash_tree_root | medium-fixture | 552 | 7936 | 50151.2 | 10312.4 | 4.9x | 10x | yes |
| AttesterSlashing.hash_tree_root | small-fixture | 512 | 8192 | 63476.6 | 10383.6 | 6.1x | 10x | yes |
| AttesterSlashing.serialize | large-fixture | 624 | 524288 | 494.0 | 273.0 | 1.8x | 5x | yes |
| AttesterSlashing.serialize | medium-fixture | 552 | 524288 | 547.4 | 232.7 | 2.4x | 5x | yes |
| AttesterSlashing.serialize | small-fixture | 512 | 1048576 | 479.7 | 236.9 | 2.0x | 5x | yes |
| BLSPubkey.deserialize | random | 48 | 2883584 | 90.2 | 101.4 | 0.9x | 5x | yes |
| BLSPubkey.deserialize | saturated | 48 | 2883584 | 87.0 | 104.8 | 0.8x | 5x | yes |
| BLSPubkey.deserialize | zero | 48 | 3407872 | 85.1 | 106.4 | 0.8x | 5x | yes |
| BLSPubkey.hash_tree_root | random | 48 | 253952 | 1008.1 | 689.3 | 1.5x | 10x | yes |
| BLSPubkey.hash_tree_root | saturated | 48 | 671744 | 920.0 | 809.7 | 1.1x | 10x | yes |
| BLSPubkey.hash_tree_root | zero | 48 | 507904 | 1055.3 | 720.0 | 1.5x | 10x | yes |
| BLSPubkey.serialize | random | 48 | 5000000 | 32.4 | 49.5 | 0.7x | 5x | yes |
| BLSPubkey.serialize | saturated | 48 | 5000000 | 30.4 | 50.9 | 0.6x | 5x | yes |
| BLSPubkey.serialize | zero | 48 | 5000000 | 30.6 | 46.2 | 0.7x | 5x | yes |
| BLSSignature.deserialize | random | 96 | 1835008 | 167.8 | 113.4 | 1.5x | 5x | yes |
| BLSSignature.deserialize | saturated | 96 | 2097152 | 159.3 | 116.6 | 1.4x | 5x | yes |
| BLSSignature.deserialize | zero | 96 | 2621440 | 156.0 | 134.7 | 1.2x | 5x | yes |
| BLSSignature.hash_tree_root | random | 96 | 102400 | 2500.0 | 1238.5 | 2.0x | 10x | yes |
| BLSSignature.hash_tree_root | saturated | 96 | 155648 | 2338.6 | 1179.3 | 2.0x | 10x | yes |
| BLSSignature.hash_tree_root | zero | 96 | 110592 | 2902.6 | 1116.4 | 2.6x | 10x | yes |
| BLSSignature.serialize | random | 96 | 5000000 | 49.8 | 57.4 | 0.9x | 5x | yes |
| BLSSignature.serialize | saturated | 96 | 5000000 | 39.2 | 58.0 | 0.7x | 5x | yes |
| BLSSignature.serialize | zero | 96 | 4980736 | 43.8 | 58.9 | 0.7x | 5x | yes |
| BLSToExecutionChange.deserialize | large-fixture | 76 | 2097152 | 145.4 | 61.9 | 2.3x | 5x | yes |
| BLSToExecutionChange.deserialize | medium-fixture | 76 | 2621440 | 129.7 | 60.9 | 2.1x | 5x | yes |
| BLSToExecutionChange.deserialize | small-fixture | 76 | 2621440 | 138.5 | 67.2 | 2.1x | 5x | yes |
| BLSToExecutionChange.hash_tree_root | large-fixture | 76 | 122880 | 3466.8 | 776.5 | 4.5x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | medium-fixture | 76 | 102400 | 4043.0 | 734.9 | 5.5x | 10x | yes |
| BLSToExecutionChange.hash_tree_root | small-fixture | 76 | 131072 | 3402.7 | 800.1 | 4.3x | 10x | yes |
| BLSToExecutionChange.serialize | large-fixture | 76 | 5000000 | 37.0 | 69.0 | 0.5x | 5x | yes |
| BLSToExecutionChange.serialize | medium-fixture | 76 | 5000000 | 40.8 | 70.7 | 0.6x | 5x | yes |
| BLSToExecutionChange.serialize | small-fixture | 76 | 5000000 | 44.6 | 64.7 | 0.7x | 5x | yes |
| BeaconBlock.deserialize | large-fixture | 21487 | 16384 | 26306.2 | 34691.5 | 0.8x | 5x | yes |
| BeaconBlock.deserialize | medium-fixture | 21424 | 16384 | 22155.8 | 30427.4 | 0.7x | 5x | yes |
| BeaconBlock.deserialize | small-fixture | 11198 | 16384 | 20263.7 | 10792.1 | 1.9x | 5x | yes |
| BeaconBlock.hash_tree_root | large-fixture | 21487 | 256 | 972656.2 | 184307.8 | 5.3x | 10x | yes |
| BeaconBlock.hash_tree_root | medium-fixture | 21424 | 384 | 1083333.3 | 192009.4 | 5.6x | 10x | yes |
| BeaconBlock.hash_tree_root | small-fixture | 11198 | 512 | 675781.2 | 135501.0 | 5.0x | 10x | yes |
| BeaconBlock.serialize | large-fixture | 21487 | 32768 | 14831.5 | 8229.4 | 1.8x | 5x | yes |
| BeaconBlock.serialize | medium-fixture | 21424 | 32768 | 12237.5 | 6722.3 | 1.8x | 5x | yes |
| BeaconBlock.serialize | small-fixture | 11198 | 28672 | 8510.0 | 4003.0 | 2.1x | 5x | yes |
| BeaconBlockBody.deserialize | large-fixture | 24042 | 16384 | 23559.6 | 33168.1 | 0.7x | 5x | yes |
| BeaconBlockBody.deserialize | medium-fixture | 19087 | 16384 | 23864.7 | 23078.4 | 1.0x | 5x | yes |
| BeaconBlockBody.deserialize | small-fixture | 11894 | 20480 | 16455.1 | 17191.6 | 1.0x | 5x | yes |
| BeaconBlockBody.hash_tree_root | large-fixture | 24042 | 384 | 1242187.5 | 234589.9 | 5.3x | 10x | yes |
| BeaconBlockBody.hash_tree_root | medium-fixture | 19087 | 384 | 1072916.7 | 207389.9 | 5.2x | 10x | yes |
| BeaconBlockBody.hash_tree_root | small-fixture | 11894 | 640 | 748437.5 | 130665.2 | 5.7x | 10x | yes |
| BeaconBlockBody.serialize | large-fixture | 24042 | 20480 | 12451.2 | 9170.8 | 1.4x | 5x | yes |
| BeaconBlockBody.serialize | medium-fixture | 19087 | 40960 | 11474.6 | 6717.3 | 1.7x | 5x | yes |
| BeaconBlockBody.serialize | small-fixture | 11894 | 40960 | 7690.4 | 4440.1 | 1.7x | 5x | yes |
| BeaconBlockHeader.deserialize | large-fixture | 112 | 2621440 | 156.0 | 76.0 | 2.1x | 5x | yes |
| BeaconBlockHeader.deserialize | medium-fixture | 112 | 3145728 | 162.8 | 71.5 | 2.3x | 5x | yes |
| BeaconBlockHeader.deserialize | small-fixture | 112 | 2097152 | 148.3 | 71.6 | 2.1x | 5x | yes |
| BeaconBlockHeader.hash_tree_root | large-fixture | 112 | 73728 | 4882.8 | 1039.9 | 4.7x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | medium-fixture | 112 | 114688 | 5092.1 | 1028.3 | 5.0x | 10x | yes |
| BeaconBlockHeader.hash_tree_root | small-fixture | 112 | 57344 | 5214.1 | 1135.7 | 4.6x | 10x | yes |
| BeaconBlockHeader.serialize | large-fixture | 112 | 5000000 | 45.8 | 78.1 | 0.6x | 5x | yes |
| BeaconBlockHeader.serialize | medium-fixture | 112 | 5000000 | 49.8 | 82.4 | 0.6x | 5x | yes |
| BeaconBlockHeader.serialize | small-fixture | 112 | 5000000 | 60.0 | 80.6 | 0.7x | 5x | yes |
| BeaconState.deserialize | large-fixture | 2741095 | 496 | 717741.9 | 758911.7 | 0.9x | 5x | yes |
| BeaconState.deserialize | medium-fixture | 2740473 | 400 | 675000.0 | 730893.1 | 0.9x | 5x | yes |
| BeaconState.deserialize | small-fixture | 2738771 | 496 | 737903.2 | 762520.1 | 1.0x | 5x | yes |
| BeaconState.hash_tree_root | large-fixture | 2741095 | 4 | 82750000.0 | 18097368.4 | 4.6x | 10x | yes |
| BeaconState.hash_tree_root | medium-fixture | 2740473 | 4 | 77750000.0 | 17285063.5 | 4.5x | 10x | yes |
| BeaconState.hash_tree_root | small-fixture | 2738771 | 4 | 74500000.0 | 17878167.8 | 4.2x | 10x | yes |
| BeaconState.serialize | large-fixture | 2741095 | 384 | 815104.2 | 846646.9 | 1.0x | 5x | yes |
| BeaconState.serialize | medium-fixture | 2740473 | 640 | 767187.5 | 784431.7 | 1.0x | 5x | yes |
| BeaconState.serialize | small-fixture | 2738771 | 512 | 748046.9 | 752565.5 | 1.0x | 5x | yes |
| Blob.deserialize | random | 131072 | 16384 | 25634.8 | 27732.7 | 0.9x | 5x | yes |
| Blob.deserialize | saturated | 131072 | 16384 | 22766.1 | 24376.1 | 0.9x | 5x | yes |
| Blob.deserialize | zero | 131072 | 16384 | 27526.9 | 24043.0 | 1.1x | 5x | yes |
| Blob.hash_tree_root | random | 131072 | 82 | 3585365.9 | 731355.1 | 4.9x | 10x | yes |
| Blob.hash_tree_root | saturated | 131072 | 64 | 4453125.0 | 850035.8 | 5.2x | 10x | yes |
| Blob.hash_tree_root | zero | 131072 | 82 | 3646341.5 | 763725.7 | 4.8x | 10x | yes |
| Blob.serialize | random | 131072 | 16384 | 19897.5 | 26158.3 | 0.8x | 5x | yes |
| Blob.serialize | saturated | 131072 | 24576 | 24007.2 | 25033.9 | 1.0x | 5x | yes |
| Blob.serialize | zero | 131072 | 16384 | 21484.4 | 26930.7 | 0.8x | 5x | yes |
| BlobIdentifier.deserialize | large-fixture | 40 | 5000000 | 68.2 | 47.1 | 1.4x | 5x | yes |
| BlobIdentifier.deserialize | medium-fixture | 40 | 5000000 | 70.8 | 56.5 | 1.3x | 5x | yes |
| BlobIdentifier.deserialize | small-fixture | 40 | 5000000 | 64.2 | 53.0 | 1.2x | 5x | yes |
| BlobIdentifier.hash_tree_root | large-fixture | 40 | 262144 | 793.5 | 224.0 | 3.5x | 10x | yes |
| BlobIdentifier.hash_tree_root | medium-fixture | 40 | 524288 | 862.1 | 219.3 | 3.9x | 10x | yes |
| BlobIdentifier.hash_tree_root | small-fixture | 40 | 409600 | 920.4 | 219.2 | 4.2x | 10x | yes |
| BlobIdentifier.serialize | large-fixture | 40 | 5000000 | 26.8 | 58.6 | 0.5x | 5x | yes |
| BlobIdentifier.serialize | medium-fixture | 40 | 5000000 | 27.6 | 53.0 | 0.5x | 5x | yes |
| BlobIdentifier.serialize | small-fixture | 40 | 5000000 | 32.8 | 54.3 | 0.6x | 5x | yes |
| BlobIndex.deserialize | random | 8 | 5000000 | 42.0 | 83.3 | 0.5x | 5x | yes |
| BlobIndex.deserialize | saturated | 8 | 5000000 | 40.8 | 85.2 | 0.5x | 5x | yes |
| BlobIndex.deserialize | zero | 8 | 5000000 | 35.8 | 83.8 | 0.4x | 5x | yes |
| BlobIndex.hash_tree_root | random | 8 | 5000000 | 15.6 | 519.2 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | saturated | 8 | 5000000 | 15.8 | 465.6 | 0.0x | 10x | yes |
| BlobIndex.hash_tree_root | zero | 8 | 5000000 | 15.4 | 538.4 | 0.0x | 10x | yes |
| BlobIndex.serialize | random | 8 | 5000000 | 18.6 | 29.4 | 0.6x | 5x | yes |
| BlobIndex.serialize | saturated | 8 | 5000000 | 18.0 | 25.8 | 0.7x | 5x | yes |
| BlobIndex.serialize | zero | 8 | 5000000 | 18.2 | 28.1 | 0.6x | 5x | yes |
| BlobSidecar.deserialize | large-fixture | 131928 | 16384 | 25085.4 | 26599.0 | 0.9x | 5x | yes |
| BlobSidecar.deserialize | medium-fixture | 131928 | 16384 | 24780.3 | 26931.0 | 0.9x | 5x | yes |
| BlobSidecar.deserialize | small-fixture | 131928 | 16384 | 25817.9 | 28103.2 | 0.9x | 5x | yes |
| BlobSidecar.hash_tree_root | large-fixture | 131928 | 100 | 3980000.0 | 647481.3 | 6.1x | 10x | yes |
| BlobSidecar.hash_tree_root | medium-fixture | 131928 | 124 | 3717741.9 | 684204.8 | 5.4x | 10x | yes |
| BlobSidecar.hash_tree_root | small-fixture | 131928 | 50 | 3440000.0 | 659837.4 | 5.2x | 10x | yes |
| BlobSidecar.serialize | large-fixture | 131928 | 16384 | 25695.8 | 25403.8 | 1.0x | 5x | yes |
| BlobSidecar.serialize | medium-fixture | 131928 | 16384 | 26306.2 | 26740.3 | 1.0x | 5x | yes |
| BlobSidecar.serialize | small-fixture | 131928 | 16384 | 26855.5 | 27503.2 | 1.0x | 5x | yes |
| Bytes1.deserialize | random | 1 | 5000000 | 17.0 | 75.5 | 0.2x | 5x | yes |
| Bytes1.deserialize | saturated | 1 | 5000000 | 17.6 | 84.7 | 0.2x | 5x | yes |
| Bytes1.deserialize | zero | 1 | 5000000 | 19.8 | 88.3 | 0.2x | 5x | yes |
| Bytes1.hash_tree_root | random | 1 | 5000000 | 11.8 | 541.0 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | saturated | 1 | 5000000 | 12.0 | 477.1 | 0.0x | 10x | yes |
| Bytes1.hash_tree_root | zero | 1 | 5000000 | 13.0 | 502.3 | 0.0x | 10x | yes |
| Bytes1.serialize | random | 1 | 5000000 | 16.8 | 20.4 | 0.8x | 5x | yes |
| Bytes1.serialize | saturated | 1 | 5000000 | 16.2 | 20.8 | 0.8x | 5x | yes |
| Bytes1.serialize | zero | 1 | 5000000 | 15.0 | 18.0 | 0.8x | 5x | yes |
| Bytes20.deserialize | random | 20 | 5000000 | 49.8 | 114.6 | 0.4x | 5x | yes |
| Bytes20.deserialize | saturated | 20 | 5000000 | 49.2 | 111.6 | 0.4x | 5x | yes |
| Bytes20.deserialize | zero | 20 | 4456448 | 53.6 | 96.2 | 0.6x | 5x | yes |
| Bytes20.hash_tree_root | random | 20 | 5000000 | 16.6 | 462.8 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | saturated | 20 | 5000000 | 16.4 | 507.6 | 0.0x | 10x | yes |
| Bytes20.hash_tree_root | zero | 20 | 5000000 | 18.0 | 552.5 | 0.0x | 10x | yes |
| Bytes20.serialize | random | 20 | 5000000 | 21.8 | 41.2 | 0.5x | 5x | yes |
| Bytes20.serialize | saturated | 20 | 5000000 | 23.0 | 41.5 | 0.6x | 5x | yes |
| Bytes20.serialize | zero | 20 | 5000000 | 31.2 | 43.1 | 0.7x | 5x | yes |
| Bytes32.deserialize | random | 32 | 4194304 | 71.5 | 109.6 | 0.7x | 5x | yes |
| Bytes32.deserialize | saturated | 32 | 5000000 | 67.2 | 99.3 | 0.7x | 5x | yes |
| Bytes32.deserialize | zero | 32 | 5000000 | 70.2 | 98.3 | 0.7x | 5x | yes |
| Bytes32.hash_tree_root | random | 32 | 5000000 | 19.4 | 422.8 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | saturated | 32 | 5000000 | 20.8 | 452.9 | 0.0x | 10x | yes |
| Bytes32.hash_tree_root | zero | 32 | 5000000 | 17.6 | 443.1 | 0.0x | 10x | yes |
| Bytes32.serialize | random | 32 | 5000000 | 24.8 | 44.0 | 0.6x | 5x | yes |
| Bytes32.serialize | saturated | 32 | 5000000 | 25.2 | 40.2 | 0.6x | 5x | yes |
| Bytes32.serialize | zero | 32 | 5000000 | 24.0 | 46.1 | 0.5x | 5x | yes |
| Bytes4.deserialize | random | 4 | 5000000 | 15.6 | 80.3 | 0.2x | 5x | yes |
| Bytes4.deserialize | saturated | 4 | 5000000 | 20.0 | 88.4 | 0.2x | 5x | yes |
| Bytes4.deserialize | zero | 4 | 5000000 | 17.8 | 81.9 | 0.2x | 5x | yes |
| Bytes4.hash_tree_root | random | 4 | 5000000 | 15.4 | 550.6 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | saturated | 4 | 5000000 | 13.6 | 528.5 | 0.0x | 10x | yes |
| Bytes4.hash_tree_root | zero | 4 | 5000000 | 11.6 | 500.1 | 0.0x | 10x | yes |
| Bytes4.serialize | random | 4 | 5000000 | 16.4 | 26.8 | 0.6x | 5x | yes |
| Bytes4.serialize | saturated | 4 | 5000000 | 16.4 | 23.4 | 0.7x | 5x | yes |
| Bytes4.serialize | zero | 4 | 5000000 | 14.8 | 24.1 | 0.6x | 5x | yes |
| Bytes48.deserialize | random | 48 | 2621440 | 72.9 | 107.2 | 0.7x | 5x | yes |
| Bytes48.deserialize | saturated | 48 | 5000000 | 92.0 | 114.5 | 0.8x | 5x | yes |
| Bytes48.deserialize | zero | 48 | 5000000 | 88.6 | 110.2 | 0.8x | 5x | yes |
| Bytes48.hash_tree_root | random | 48 | 253952 | 1130.1 | 780.4 | 1.4x | 10x | yes |
| Bytes48.hash_tree_root | saturated | 48 | 524288 | 921.2 | 758.7 | 1.2x | 10x | yes |
| Bytes48.hash_tree_root | zero | 48 | 524288 | 1024.2 | 831.3 | 1.2x | 10x | yes |
| Bytes48.serialize | random | 48 | 5000000 | 38.2 | 50.4 | 0.8x | 5x | yes |
| Bytes48.serialize | saturated | 48 | 5000000 | 37.4 | 44.7 | 0.8x | 5x | yes |
| Bytes48.serialize | zero | 48 | 5000000 | 44.6 | 57.8 | 0.8x | 5x | yes |
| Bytes8.deserialize | random | 8 | 5000000 | 40.4 | 87.4 | 0.5x | 5x | yes |
| Bytes8.deserialize | saturated | 8 | 5000000 | 40.8 | 78.9 | 0.5x | 5x | yes |
| Bytes8.deserialize | zero | 8 | 5000000 | 39.0 | 87.1 | 0.4x | 5x | yes |
| Bytes8.hash_tree_root | random | 8 | 5000000 | 19.8 | 562.0 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | saturated | 8 | 5000000 | 15.8 | 529.4 | 0.0x | 10x | yes |
| Bytes8.hash_tree_root | zero | 8 | 5000000 | 16.8 | 498.7 | 0.0x | 10x | yes |
| Bytes8.serialize | random | 8 | 5000000 | 18.0 | 36.0 | 0.5x | 5x | yes |
| Bytes8.serialize | saturated | 8 | 5000000 | 18.8 | 37.0 | 0.5x | 5x | yes |
| Bytes8.serialize | zero | 8 | 5000000 | 22.8 | 32.0 | 0.7x | 5x | yes |
| Bytes96.deserialize | random | 96 | 3145728 | 148.5 | 115.2 | 1.3x | 5x | yes |
| Bytes96.deserialize | saturated | 96 | 1572864 | 146.2 | 115.6 | 1.3x | 5x | yes |
| Bytes96.deserialize | zero | 96 | 2097152 | 148.3 | 116.9 | 1.3x | 5x | yes |
| Bytes96.hash_tree_root | random | 96 | 110592 | 3327.5 | 1074.4 | 3.1x | 10x | yes |
| Bytes96.hash_tree_root | saturated | 96 | 163840 | 2447.5 | 1032.4 | 2.4x | 10x | yes |
| Bytes96.hash_tree_root | zero | 96 | 163840 | 2386.5 | 1038.0 | 2.3x | 10x | yes |
| Bytes96.serialize | random | 96 | 5000000 | 40.4 | 56.5 | 0.7x | 5x | yes |
| Bytes96.serialize | saturated | 96 | 5000000 | 41.6 | 55.8 | 0.7x | 5x | yes |
| Bytes96.serialize | zero | 96 | 5000000 | 45.2 | 58.9 | 0.8x | 5x | yes |
| Cell.deserialize | random | 2048 | 1048576 | 330.0 | 664.0 | 0.5x | 5x | yes |
| Cell.deserialize | saturated | 2048 | 1572864 | 346.5 | 657.5 | 0.5x | 5x | yes |
| Cell.deserialize | zero | 2048 | 1048576 | 351.0 | 635.2 | 0.6x | 5x | yes |
| Cell.hash_tree_root | random | 2048 | 6400 | 51406.2 | 11546.5 | 4.5x | 10x | yes |
| Cell.hash_tree_root | saturated | 2048 | 8960 | 50892.9 | 11842.0 | 4.3x | 10x | yes |
| Cell.hash_tree_root | zero | 2048 | 6400 | 52187.5 | 11983.3 | 4.4x | 10x | yes |
| Cell.serialize | random | 2048 | 1048576 | 310.9 | 539.6 | 0.6x | 5x | yes |
| Cell.serialize | saturated | 2048 | 1048576 | 371.9 | 582.9 | 0.6x | 5x | yes |
| Cell.serialize | zero | 2048 | 1048576 | 387.2 | 575.3 | 0.7x | 5x | yes |
| CellIndex.deserialize | random | 8 | 5000000 | 33.6 | 87.5 | 0.4x | 5x | yes |
| CellIndex.deserialize | saturated | 8 | 5000000 | 41.4 | 77.9 | 0.5x | 5x | yes |
| CellIndex.deserialize | zero | 8 | 5000000 | 35.0 | 96.8 | 0.4x | 5x | yes |
| CellIndex.hash_tree_root | random | 8 | 5000000 | 15.2 | 487.5 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | saturated | 8 | 5000000 | 18.0 | 499.0 | 0.0x | 10x | yes |
| CellIndex.hash_tree_root | zero | 8 | 5000000 | 14.4 | 453.7 | 0.0x | 10x | yes |
| CellIndex.serialize | random | 8 | 5000000 | 19.2 | 34.9 | 0.5x | 5x | yes |
| CellIndex.serialize | saturated | 8 | 5000000 | 19.6 | 30.2 | 0.6x | 5x | yes |
| CellIndex.serialize | zero | 8 | 5000000 | 16.8 | 26.9 | 0.6x | 5x | yes |
| Checkpoint.deserialize | large-fixture | 40 | 5000000 | 77.0 | 49.1 | 1.6x | 5x | yes |
| Checkpoint.deserialize | medium-fixture | 40 | 3407872 | 71.0 | 53.4 | 1.3x | 5x | yes |
| Checkpoint.deserialize | small-fixture | 40 | 5000000 | 77.8 | 51.7 | 1.5x | 5x | yes |
| Checkpoint.hash_tree_root | large-fixture | 40 | 262144 | 888.8 | 231.5 | 3.8x | 10x | yes |
| Checkpoint.hash_tree_root | medium-fixture | 40 | 409600 | 815.4 | 218.9 | 3.7x | 10x | yes |
| Checkpoint.hash_tree_root | small-fixture | 40 | 507904 | 886.0 | 218.0 | 4.1x | 10x | yes |
| Checkpoint.serialize | large-fixture | 40 | 5000000 | 32.8 | 52.2 | 0.6x | 5x | yes |
| Checkpoint.serialize | medium-fixture | 40 | 5000000 | 30.0 | 51.4 | 0.6x | 5x | yes |
| Checkpoint.serialize | small-fixture | 40 | 5000000 | 33.0 | 50.4 | 0.7x | 5x | yes |
| ColumnIndex.deserialize | random | 8 | 5000000 | 38.6 | 89.3 | 0.4x | 5x | yes |
| ColumnIndex.deserialize | saturated | 8 | 5000000 | 42.6 | 88.0 | 0.5x | 5x | yes |
| ColumnIndex.deserialize | zero | 8 | 5000000 | 40.8 | 89.9 | 0.5x | 5x | yes |
| ColumnIndex.hash_tree_root | random | 8 | 5000000 | 16.8 | 496.5 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | saturated | 8 | 5000000 | 18.2 | 506.3 | 0.0x | 10x | yes |
| ColumnIndex.hash_tree_root | zero | 8 | 5000000 | 15.6 | 467.5 | 0.0x | 10x | yes |
| ColumnIndex.serialize | random | 8 | 5000000 | 22.4 | 30.8 | 0.7x | 5x | yes |
| ColumnIndex.serialize | saturated | 8 | 5000000 | 23.2 | 33.2 | 0.7x | 5x | yes |
| ColumnIndex.serialize | zero | 8 | 5000000 | 22.0 | 30.6 | 0.7x | 5x | yes |
| CommitmentIndex.deserialize | random | 8 | 5000000 | 37.8 | 88.3 | 0.4x | 5x | yes |
| CommitmentIndex.deserialize | saturated | 8 | 5000000 | 41.6 | 89.7 | 0.5x | 5x | yes |
| CommitmentIndex.deserialize | zero | 8 | 4456448 | 38.4 | 88.7 | 0.4x | 5x | yes |
| CommitmentIndex.hash_tree_root | random | 8 | 5000000 | 18.8 | 494.1 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | saturated | 8 | 5000000 | 17.4 | 534.8 | 0.0x | 10x | yes |
| CommitmentIndex.hash_tree_root | zero | 8 | 5000000 | 18.0 | 546.1 | 0.0x | 10x | yes |
| CommitmentIndex.serialize | random | 8 | 5000000 | 23.8 | 38.8 | 0.6x | 5x | yes |
| CommitmentIndex.serialize | saturated | 8 | 5000000 | 20.0 | 31.0 | 0.6x | 5x | yes |
| CommitmentIndex.serialize | zero | 8 | 5000000 | 30.0 | 33.2 | 0.9x | 5x | yes |
| CommitteeIndex.deserialize | random | 8 | 5000000 | 45.0 | 96.6 | 0.5x | 5x | yes |
| CommitteeIndex.deserialize | saturated | 8 | 5000000 | 36.6 | 83.0 | 0.4x | 5x | yes |
| CommitteeIndex.deserialize | zero | 8 | 5000000 | 36.6 | 84.8 | 0.4x | 5x | yes |
| CommitteeIndex.hash_tree_root | random | 8 | 5000000 | 15.0 | 465.0 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | saturated | 8 | 5000000 | 16.8 | 540.0 | 0.0x | 10x | yes |
| CommitteeIndex.hash_tree_root | zero | 8 | 5000000 | 14.6 | 494.2 | 0.0x | 10x | yes |
| CommitteeIndex.serialize | random | 8 | 5000000 | 14.8 | 28.6 | 0.5x | 5x | yes |
| CommitteeIndex.serialize | saturated | 8 | 5000000 | 17.0 | 30.7 | 0.6x | 5x | yes |
| CommitteeIndex.serialize | zero | 8 | 5000000 | 18.2 | 28.4 | 0.6x | 5x | yes |
| ConsolidationRequest.deserialize | large-fixture | 116 | 2621440 | 162.1 | 75.6 | 2.1x | 5x | yes |
| ConsolidationRequest.deserialize | medium-fixture | 116 | 2621440 | 180.4 | 74.0 | 2.4x | 5x | yes |
| ConsolidationRequest.deserialize | small-fixture | 116 | 2097152 | 164.5 | 72.1 | 2.3x | 5x | yes |
| ConsolidationRequest.hash_tree_root | large-fixture | 116 | 106496 | 4788.9 | 928.7 | 5.2x | 10x | yes |
| ConsolidationRequest.hash_tree_root | medium-fixture | 116 | 131072 | 5149.8 | 982.1 | 5.2x | 10x | yes |
| ConsolidationRequest.hash_tree_root | small-fixture | 116 | 61440 | 4085.3 | 1001.1 | 4.1x | 10x | yes |
| ConsolidationRequest.serialize | large-fixture | 116 | 5000000 | 51.2 | 76.0 | 0.7x | 5x | yes |
| ConsolidationRequest.serialize | medium-fixture | 116 | 5000000 | 61.4 | 94.1 | 0.7x | 5x | yes |
| ConsolidationRequest.serialize | small-fixture | 116 | 5000000 | 50.0 | 77.1 | 0.6x | 5x | yes |
| ContributionAndProof.deserialize | large-fixture | 264 | 1048576 | 374.8 | 212.0 | 1.8x | 5x | yes |
| ContributionAndProof.deserialize | medium-fixture | 264 | 1048576 | 392.0 | 216.4 | 1.8x | 5x | yes |
| ContributionAndProof.deserialize | small-fixture | 264 | 1048576 | 356.7 | 205.8 | 1.7x | 5x | yes |
| ContributionAndProof.hash_tree_root | large-fixture | 264 | 24576 | 12247.7 | 2493.6 | 4.9x | 10x | yes |
| ContributionAndProof.hash_tree_root | medium-fixture | 264 | 32768 | 11261.0 | 2546.3 | 4.4x | 10x | yes |
| ContributionAndProof.hash_tree_root | small-fixture | 264 | 20480 | 13964.8 | 2567.6 | 5.4x | 10x | yes |
| ContributionAndProof.serialize | large-fixture | 264 | 3145728 | 104.3 | 125.5 | 0.8x | 5x | yes |
| ContributionAndProof.serialize | medium-fixture | 264 | 3670016 | 99.5 | 124.8 | 0.8x | 5x | yes |
| ContributionAndProof.serialize | small-fixture | 264 | 4718592 | 101.1 | 136.3 | 0.7x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | random | 192 | 5000000 | 66.0 | 137.7 | 0.5x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | saturated | 192 | 3932160 | 68.2 | 144.5 | 0.5x | 5x | yes |
| CurrentSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 72.8 | 156.8 | 0.5x | 5x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | random | 192 | 49152 | 5350.7 | 1823.6 | 2.9x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | saturated | 192 | 81920 | 5383.3 | 1644.6 | 3.3x | 10x | yes |
| CurrentSyncCommitteeBranch.hash_tree_root | zero | 192 | 81920 | 4858.4 | 1760.2 | 2.8x | 10x | yes |
| CurrentSyncCommitteeBranch.serialize | random | 192 | 5000000 | 50.0 | 94.2 | 0.5x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 54.0 | 98.3 | 0.5x | 5x | yes |
| CurrentSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 53.8 | 87.4 | 0.6x | 5x | yes |
| CustodyIndex.deserialize | random | 8 | 5000000 | 27.6 | 86.1 | 0.3x | 5x | yes |
| CustodyIndex.deserialize | saturated | 8 | 5000000 | 31.8 | 83.7 | 0.4x | 5x | yes |
| CustodyIndex.deserialize | zero | 8 | 5000000 | 27.6 | 94.0 | 0.3x | 5x | yes |
| CustodyIndex.hash_tree_root | random | 8 | 5000000 | 13.8 | 492.6 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | saturated | 8 | 5000000 | 13.0 | 496.0 | 0.0x | 10x | yes |
| CustodyIndex.hash_tree_root | zero | 8 | 5000000 | 13.8 | 497.0 | 0.0x | 10x | yes |
| CustodyIndex.serialize | random | 8 | 5000000 | 15.6 | 31.1 | 0.5x | 5x | yes |
| CustodyIndex.serialize | saturated | 8 | 5000000 | 17.8 | 33.6 | 0.5x | 5x | yes |
| CustodyIndex.serialize | zero | 8 | 5000000 | 15.2 | 30.2 | 0.5x | 5x | yes |
| DataColumnSidecar.deserialize | large-fixture | 19076 | 53248 | 4281.9 | 8230.6 | 0.5x | 5x | yes |
| DataColumnSidecar.deserialize | medium-fixture | 17028 | 106496 | 3511.9 | 7792.7 | 0.5x | 5x | yes |
| DataColumnSidecar.deserialize | small-fixture | 6500 | 204800 | 1655.3 | 3273.6 | 0.5x | 5x | yes |
| DataColumnSidecar.hash_tree_root | large-fixture | 19076 | 896 | 553571.4 | 111434.2 | 5.0x | 10x | yes |
| DataColumnSidecar.hash_tree_root | medium-fixture | 17028 | 896 | 669642.9 | 99987.2 | 6.7x | 10x | yes |
| DataColumnSidecar.hash_tree_root | small-fixture | 6500 | 2432 | 225740.1 | 36641.7 | 6.2x | 10x | yes |
| DataColumnSidecar.serialize | large-fixture | 19076 | 69632 | 3690.8 | 3994.3 | 0.9x | 5x | yes |
| DataColumnSidecar.serialize | medium-fixture | 17028 | 81920 | 3601.1 | 3601.6 | 1.0x | 5x | yes |
| DataColumnSidecar.serialize | small-fixture | 6500 | 507904 | 1181.3 | 1468.5 | 0.8x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | large-fixture | 92 | 3145728 | 135.1 | 206.1 | 0.7x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | medium-fixture | 60 | 2097152 | 113.0 | 177.0 | 0.6x | 5x | yes |
| DataColumnsByRootIdentifier.deserialize | small-fixture | 36 | 2359296 | 91.6 | 132.5 | 0.7x | 5x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | large-fixture | 92 | 45056 | 7279.8 | 1408.0 | 5.2x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | medium-fixture | 60 | 40960 | 7128.9 | 1450.6 | 4.9x | 10x | yes |
| DataColumnsByRootIdentifier.hash_tree_root | small-fixture | 36 | 180224 | 2064.1 | 542.8 | 3.8x | 10x | yes |
| DataColumnsByRootIdentifier.serialize | large-fixture | 92 | 5000000 | 80.0 | 85.4 | 0.9x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | medium-fixture | 60 | 5000000 | 59.6 | 74.3 | 0.8x | 5x | yes |
| DataColumnsByRootIdentifier.serialize | small-fixture | 36 | 5000000 | 44.8 | 63.1 | 0.7x | 5x | yes |
| Deposit.deserialize | large-fixture | 1240 | 1048576 | 527.4 | 2261.1 | 0.2x | 5x | yes |
| Deposit.deserialize | medium-fixture | 1240 | 524288 | 486.4 | 2246.1 | 0.2x | 5x | yes |
| Deposit.deserialize | small-fixture | 1240 | 524288 | 547.4 | 2448.0 | 0.2x | 5x | yes |
| Deposit.hash_tree_root | large-fixture | 1240 | 8192 | 36010.7 | 7661.9 | 4.7x | 10x | yes |
| Deposit.hash_tree_root | medium-fixture | 1240 | 8192 | 43579.1 | 8828.6 | 4.9x | 10x | yes |
| Deposit.hash_tree_root | small-fixture | 1240 | 6400 | 44531.2 | 7281.5 | 6.1x | 10x | yes |
| Deposit.serialize | large-fixture | 1240 | 2097152 | 265.1 | 493.1 | 0.5x | 5x | yes |
| Deposit.serialize | medium-fixture | 1240 | 1572864 | 234.0 | 558.7 | 0.4x | 5x | yes |
| Deposit.serialize | small-fixture | 1240 | 1048576 | 245.1 | 509.5 | 0.5x | 5x | yes |
| DepositData.deserialize | large-fixture | 184 | 1048576 | 311.9 | 144.7 | 2.2x | 5x | yes |
| DepositData.deserialize | medium-fixture | 184 | 1048576 | 332.8 | 148.0 | 2.2x | 5x | yes |
| DepositData.deserialize | small-fixture | 184 | 1048576 | 330.0 | 148.7 | 2.2x | 5x | yes |
| DepositData.hash_tree_root | large-fixture | 184 | 57344 | 6051.2 | 1272.9 | 4.8x | 10x | yes |
| DepositData.hash_tree_root | medium-fixture | 184 | 40960 | 5664.1 | 1308.3 | 4.3x | 10x | yes |
| DepositData.hash_tree_root | small-fixture | 184 | 61440 | 6103.5 | 1178.5 | 5.2x | 10x | yes |
| DepositData.serialize | large-fixture | 184 | 4194304 | 76.5 | 101.0 | 0.8x | 5x | yes |
| DepositData.serialize | medium-fixture | 184 | 5000000 | 87.8 | 95.5 | 0.9x | 5x | yes |
| DepositData.serialize | small-fixture | 184 | 4194304 | 80.1 | 110.1 | 0.7x | 5x | yes |
| DepositMessage.deserialize | large-fixture | 88 | 2621440 | 125.1 | 138.1 | 0.9x | 5x | yes |
| DepositMessage.deserialize | medium-fixture | 88 | 3670016 | 116.6 | 126.5 | 0.9x | 5x | yes |
| DepositMessage.deserialize | small-fixture | 88 | 3145728 | 116.3 | 129.0 | 0.9x | 5x | yes |
| DepositMessage.hash_tree_root | large-fixture | 88 | 131072 | 3669.7 | 778.7 | 4.7x | 10x | yes |
| DepositMessage.hash_tree_root | medium-fixture | 88 | 110592 | 3418.0 | 754.4 | 4.5x | 10x | yes |
| DepositMessage.hash_tree_root | small-fixture | 88 | 57344 | 3243.6 | 756.9 | 4.3x | 10x | yes |
| DepositMessage.serialize | large-fixture | 88 | 5000000 | 39.8 | 67.0 | 0.6x | 5x | yes |
| DepositMessage.serialize | medium-fixture | 88 | 5000000 | 44.8 | 65.9 | 0.7x | 5x | yes |
| DepositMessage.serialize | small-fixture | 88 | 5000000 | 50.6 | 69.0 | 0.7x | 5x | yes |
| DepositRequest.deserialize | large-fixture | 192 | 1048576 | 341.4 | 152.3 | 2.2x | 5x | yes |
| DepositRequest.deserialize | medium-fixture | 192 | 1572864 | 347.8 | 171.9 | 2.0x | 5x | yes |
| DepositRequest.deserialize | small-fixture | 192 | 1048576 | 354.8 | 178.8 | 2.0x | 5x | yes |
| DepositRequest.hash_tree_root | large-fixture | 192 | 57344 | 8911.1 | 1885.6 | 4.7x | 10x | yes |
| DepositRequest.hash_tree_root | medium-fixture | 192 | 32768 | 8789.1 | 1761.8 | 5.0x | 10x | yes |
| DepositRequest.hash_tree_root | small-fixture | 192 | 49152 | 9480.8 | 1848.7 | 5.1x | 10x | yes |
| DepositRequest.serialize | large-fixture | 192 | 5000000 | 79.0 | 108.8 | 0.7x | 5x | yes |
| DepositRequest.serialize | medium-fixture | 192 | 5000000 | 70.6 | 107.0 | 0.7x | 5x | yes |
| DepositRequest.serialize | small-fixture | 192 | 5000000 | 75.2 | 102.8 | 0.7x | 5x | yes |
| Domain.deserialize | random | 32 | 5000000 | 70.4 | 113.8 | 0.6x | 5x | yes |
| Domain.deserialize | saturated | 32 | 5000000 | 60.2 | 96.2 | 0.6x | 5x | yes |
| Domain.deserialize | zero | 32 | 5000000 | 61.0 | 105.7 | 0.6x | 5x | yes |
| Domain.hash_tree_root | random | 32 | 5000000 | 17.8 | 445.9 | 0.0x | 10x | yes |
| Domain.hash_tree_root | saturated | 32 | 5000000 | 19.2 | 436.0 | 0.0x | 10x | yes |
| Domain.hash_tree_root | zero | 32 | 5000000 | 24.2 | 469.2 | 0.1x | 10x | yes |
| Domain.serialize | random | 32 | 5000000 | 33.8 | 53.6 | 0.6x | 5x | yes |
| Domain.serialize | saturated | 32 | 5000000 | 27.6 | 43.8 | 0.6x | 5x | yes |
| Domain.serialize | zero | 32 | 5000000 | 29.8 | 54.4 | 0.5x | 5x | yes |
| DomainType.deserialize | random | 4 | 5000000 | 18.0 | 80.3 | 0.2x | 5x | yes |
| DomainType.deserialize | saturated | 4 | 5000000 | 19.2 | 78.7 | 0.2x | 5x | yes |
| DomainType.deserialize | zero | 4 | 5000000 | 18.0 | 78.5 | 0.2x | 5x | yes |
| DomainType.hash_tree_root | random | 4 | 5000000 | 10.4 | 496.8 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | saturated | 4 | 5000000 | 14.6 | 482.1 | 0.0x | 10x | yes |
| DomainType.hash_tree_root | zero | 4 | 5000000 | 11.8 | 467.6 | 0.0x | 10x | yes |
| DomainType.serialize | random | 4 | 5000000 | 16.0 | 28.1 | 0.6x | 5x | yes |
| DomainType.serialize | saturated | 4 | 5000000 | 16.4 | 24.5 | 0.7x | 5x | yes |
| DomainType.serialize | zero | 4 | 5000000 | 17.4 | 23.1 | 0.8x | 5x | yes |
| Epoch.deserialize | random | 8 | 5000000 | 37.8 | 99.6 | 0.4x | 5x | yes |
| Epoch.deserialize | saturated | 8 | 5000000 | 38.4 | 88.7 | 0.4x | 5x | yes |
| Epoch.deserialize | zero | 8 | 5000000 | 39.8 | 86.1 | 0.5x | 5x | yes |
| Epoch.hash_tree_root | random | 8 | 5000000 | 13.2 | 491.3 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | saturated | 8 | 5000000 | 14.4 | 451.0 | 0.0x | 10x | yes |
| Epoch.hash_tree_root | zero | 8 | 5000000 | 14.2 | 486.1 | 0.0x | 10x | yes |
| Epoch.serialize | random | 8 | 5000000 | 17.2 | 30.5 | 0.6x | 5x | yes |
| Epoch.serialize | saturated | 8 | 5000000 | 22.4 | 35.9 | 0.6x | 5x | yes |
| Epoch.serialize | zero | 8 | 5000000 | 17.2 | 27.6 | 0.6x | 5x | yes |
| Eth1Block.deserialize | large-fixture | 48 | 5000000 | 98.6 | 119.0 | 0.8x | 5x | yes |
| Eth1Block.deserialize | medium-fixture | 48 | 4194304 | 88.0 | 104.1 | 0.8x | 5x | yes |
| Eth1Block.deserialize | small-fixture | 48 | 3670016 | 106.0 | 123.0 | 0.9x | 5x | yes |
| Eth1Block.hash_tree_root | large-fixture | 48 | 143360 | 2629.7 | 555.9 | 4.7x | 10x | yes |
| Eth1Block.hash_tree_root | medium-fixture | 48 | 212992 | 2864.0 | 616.3 | 4.6x | 10x | yes |
| Eth1Block.hash_tree_root | small-fixture | 48 | 143360 | 3159.9 | 587.0 | 5.4x | 10x | yes |
| Eth1Block.serialize | large-fixture | 48 | 5000000 | 37.0 | 61.7 | 0.6x | 5x | yes |
| Eth1Block.serialize | medium-fixture | 48 | 5000000 | 36.8 | 62.6 | 0.6x | 5x | yes |
| Eth1Block.serialize | small-fixture | 48 | 5000000 | 34.0 | 56.6 | 0.6x | 5x | yes |
| Eth1Data.deserialize | large-fixture | 72 | 3670016 | 115.5 | 148.8 | 0.8x | 5x | yes |
| Eth1Data.deserialize | medium-fixture | 72 | 3145728 | 124.3 | 163.9 | 0.8x | 5x | yes |
| Eth1Data.deserialize | small-fixture | 72 | 4194304 | 111.3 | 152.1 | 0.7x | 5x | yes |
| Eth1Data.hash_tree_root | large-fixture | 72 | 102400 | 2695.3 | 575.8 | 4.7x | 10x | yes |
| Eth1Data.hash_tree_root | medium-fixture | 72 | 110592 | 2504.7 | 560.9 | 4.5x | 10x | yes |
| Eth1Data.hash_tree_root | small-fixture | 72 | 122880 | 2294.9 | 534.2 | 4.3x | 10x | yes |
| Eth1Data.serialize | large-fixture | 72 | 5000000 | 39.2 | 81.2 | 0.5x | 5x | yes |
| Eth1Data.serialize | medium-fixture | 72 | 5000000 | 38.2 | 68.5 | 0.6x | 5x | yes |
| Eth1Data.serialize | small-fixture | 72 | 5000000 | 39.0 | 67.0 | 0.6x | 5x | yes |
| Ether.deserialize | random | 8 | 5000000 | 32.2 | 83.0 | 0.4x | 5x | yes |
| Ether.deserialize | saturated | 8 | 5000000 | 32.4 | 87.1 | 0.4x | 5x | yes |
| Ether.deserialize | zero | 8 | 5000000 | 32.0 | 83.5 | 0.4x | 5x | yes |
| Ether.hash_tree_root | random | 8 | 5000000 | 18.0 | 471.4 | 0.0x | 10x | yes |
| Ether.hash_tree_root | saturated | 8 | 5000000 | 15.6 | 545.3 | 0.0x | 10x | yes |
| Ether.hash_tree_root | zero | 8 | 5000000 | 20.6 | 533.5 | 0.0x | 10x | yes |
| Ether.serialize | random | 8 | 5000000 | 18.6 | 28.6 | 0.7x | 5x | yes |
| Ether.serialize | saturated | 8 | 5000000 | 19.0 | 33.9 | 0.6x | 5x | yes |
| Ether.serialize | zero | 8 | 5000000 | 18.6 | 30.0 | 0.6x | 5x | yes |
| ExecutionAddress.deserialize | random | 20 | 5000000 | 44.8 | 91.3 | 0.5x | 5x | yes |
| ExecutionAddress.deserialize | saturated | 20 | 5000000 | 42.4 | 94.9 | 0.4x | 5x | yes |
| ExecutionAddress.deserialize | zero | 20 | 5000000 | 39.6 | 116.8 | 0.3x | 5x | yes |
| ExecutionAddress.hash_tree_root | random | 20 | 5000000 | 15.8 | 499.3 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | saturated | 20 | 5000000 | 15.0 | 494.0 | 0.0x | 10x | yes |
| ExecutionAddress.hash_tree_root | zero | 20 | 5000000 | 15.8 | 509.8 | 0.0x | 10x | yes |
| ExecutionAddress.serialize | random | 20 | 5000000 | 25.2 | 54.4 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | saturated | 20 | 5000000 | 20.4 | 40.9 | 0.5x | 5x | yes |
| ExecutionAddress.serialize | zero | 20 | 5000000 | 21.2 | 39.1 | 0.5x | 5x | yes |
| ExecutionBranch.deserialize | random | 128 | 3407872 | 70.4 | 128.5 | 0.5x | 5x | yes |
| ExecutionBranch.deserialize | saturated | 128 | 4456448 | 83.5 | 132.1 | 0.6x | 5x | yes |
| ExecutionBranch.deserialize | zero | 128 | 5000000 | 59.6 | 141.3 | 0.4x | 5x | yes |
| ExecutionBranch.hash_tree_root | random | 128 | 65536 | 3784.2 | 1345.2 | 2.8x | 10x | yes |
| ExecutionBranch.hash_tree_root | saturated | 128 | 106496 | 3061.1 | 1390.8 | 2.2x | 10x | yes |
| ExecutionBranch.hash_tree_root | zero | 128 | 110592 | 2812.1 | 1330.7 | 2.1x | 10x | yes |
| ExecutionBranch.serialize | random | 128 | 5000000 | 53.4 | 72.7 | 0.7x | 5x | yes |
| ExecutionBranch.serialize | saturated | 128 | 5000000 | 47.6 | 71.5 | 0.7x | 5x | yes |
| ExecutionBranch.serialize | zero | 128 | 5000000 | 39.0 | 64.4 | 0.6x | 5x | yes |
| ExecutionPayload.deserialize | large-fixture | 4033 | 126976 | 2748.6 | 1916.8 | 1.4x | 5x | yes |
| ExecutionPayload.deserialize | medium-fixture | 2445 | 167936 | 2054.4 | 1632.9 | 1.3x | 5x | yes |
| ExecutionPayload.deserialize | small-fixture | 1921 | 253952 | 1760.2 | 1141.5 | 1.5x | 5x | yes |
| ExecutionPayload.hash_tree_root | large-fixture | 4033 | 1088 | 356617.6 | 56379.5 | 6.3x | 10x | yes |
| ExecutionPayload.hash_tree_root | medium-fixture | 2445 | 1664 | 254206.7 | 34141.2 | 7.4x | 10x | yes |
| ExecutionPayload.hash_tree_root | small-fixture | 1921 | 2624 | 163109.8 | 27871.0 | 5.9x | 10x | yes |
| ExecutionPayload.serialize | large-fixture | 4033 | 167936 | 1994.8 | 1376.1 | 1.4x | 5x | yes |
| ExecutionPayload.serialize | medium-fixture | 2445 | 253952 | 1653.9 | 1048.2 | 1.6x | 5x | yes |
| ExecutionPayload.serialize | small-fixture | 1921 | 335872 | 1012.3 | 787.6 | 1.3x | 5x | yes |
| ExecutionPayloadHeader.deserialize | large-fixture | 604 | 524288 | 827.8 | 389.9 | 2.1x | 5x | yes |
| ExecutionPayloadHeader.deserialize | medium-fixture | 594 | 507904 | 830.9 | 350.5 | 2.4x | 5x | yes |
| ExecutionPayloadHeader.deserialize | small-fixture | 590 | 507904 | 1002.2 | 347.8 | 2.9x | 5x | yes |
| ExecutionPayloadHeader.hash_tree_root | large-fixture | 604 | 8192 | 29174.8 | 5182.8 | 5.6x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | medium-fixture | 594 | 16384 | 25085.4 | 4778.2 | 5.2x | 10x | yes |
| ExecutionPayloadHeader.hash_tree_root | small-fixture | 590 | 16384 | 23620.6 | 4898.9 | 4.8x | 10x | yes |
| ExecutionPayloadHeader.serialize | large-fixture | 604 | 524288 | 526.4 | 278.4 | 1.9x | 5x | yes |
| ExecutionPayloadHeader.serialize | medium-fixture | 594 | 524288 | 497.8 | 278.5 | 1.8x | 5x | yes |
| ExecutionPayloadHeader.serialize | small-fixture | 590 | 1048576 | 568.4 | 257.9 | 2.2x | 5x | yes |
| ExecutionRequests.deserialize | large-fixture | 1624 | 163840 | 2465.8 | 1600.6 | 1.5x | 5x | yes |
| ExecutionRequests.deserialize | medium-fixture | 1004 | 286720 | 1722.9 | 1041.6 | 1.7x | 5x | yes |
| ExecutionRequests.deserialize | small-fixture | 396 | 507904 | 531.6 | 454.5 | 1.2x | 5x | yes |
| ExecutionRequests.hash_tree_root | large-fixture | 1624 | 3968 | 90473.8 | 18742.8 | 4.8x | 10x | yes |
| ExecutionRequests.hash_tree_root | medium-fixture | 1004 | 4096 | 60546.9 | 11524.3 | 5.3x | 10x | yes |
| ExecutionRequests.hash_tree_root | small-fixture | 396 | 8192 | 33203.1 | 6776.5 | 4.9x | 10x | yes |
| ExecutionRequests.serialize | large-fixture | 1624 | 819200 | 698.2 | 576.8 | 1.2x | 5x | yes |
| ExecutionRequests.serialize | medium-fixture | 1004 | 1048576 | 404.4 | 420.8 | 1.0x | 5x | yes |
| ExecutionRequests.serialize | small-fixture | 396 | 1572864 | 174.8 | 193.9 | 0.9x | 5x | yes |
| FinalityBranch.deserialize | random | 224 | 4718592 | 88.2 | 161.2 | 0.5x | 5x | yes |
| FinalityBranch.deserialize | saturated | 224 | 5000000 | 75.6 | 146.1 | 0.5x | 5x | yes |
| FinalityBranch.deserialize | zero | 224 | 3407872 | 80.1 | 154.9 | 0.5x | 5x | yes |
| FinalityBranch.hash_tree_root | random | 224 | 45056 | 5393.3 | 1961.1 | 2.8x | 10x | yes |
| FinalityBranch.hash_tree_root | saturated | 224 | 45056 | 6680.6 | 2058.4 | 3.2x | 10x | yes |
| FinalityBranch.hash_tree_root | zero | 224 | 57344 | 5231.6 | 1911.4 | 2.7x | 10x | yes |
| FinalityBranch.serialize | random | 224 | 5000000 | 49.0 | 97.1 | 0.5x | 5x | yes |
| FinalityBranch.serialize | saturated | 224 | 4980736 | 43.2 | 98.0 | 0.4x | 5x | yes |
| FinalityBranch.serialize | zero | 224 | 5000000 | 49.8 | 92.6 | 0.5x | 5x | yes |
| Fork.deserialize | large-fixture | 16 | 5000000 | 52.4 | 39.8 | 1.3x | 5x | yes |
| Fork.deserialize | medium-fixture | 16 | 5000000 | 45.2 | 40.0 | 1.1x | 5x | yes |
| Fork.deserialize | small-fixture | 16 | 5000000 | 45.4 | 37.1 | 1.2x | 5x | yes |
| Fork.hash_tree_root | large-fixture | 16 | 221184 | 2559.0 | 681.7 | 3.8x | 10x | yes |
| Fork.hash_tree_root | medium-fixture | 16 | 126976 | 2598.9 | 600.7 | 4.3x | 10x | yes |
| Fork.hash_tree_root | small-fixture | 16 | 126976 | 2551.7 | 546.5 | 4.7x | 10x | yes |
| Fork.serialize | large-fixture | 16 | 5000000 | 22.8 | 45.4 | 0.5x | 5x | yes |
| Fork.serialize | medium-fixture | 16 | 5000000 | 22.6 | 53.2 | 0.4x | 5x | yes |
| Fork.serialize | small-fixture | 16 | 5000000 | 24.4 | 44.9 | 0.5x | 5x | yes |
| ForkData.deserialize | large-fixture | 36 | 2359296 | 105.5 | 59.0 | 1.8x | 5x | yes |
| ForkData.deserialize | medium-fixture | 36 | 2883584 | 86.7 | 47.4 | 1.8x | 5x | yes |
| ForkData.deserialize | small-fixture | 36 | 2883584 | 73.2 | 53.5 | 1.4x | 5x | yes |
| ForkData.hash_tree_root | large-fixture | 36 | 409600 | 986.3 | 260.5 | 3.8x | 10x | yes |
| ForkData.hash_tree_root | medium-fixture | 36 | 524288 | 1009.0 | 276.4 | 3.7x | 10x | yes |
| ForkData.hash_tree_root | small-fixture | 36 | 524288 | 837.3 | 232.1 | 3.6x | 10x | yes |
| ForkData.serialize | large-fixture | 36 | 5000000 | 30.8 | 60.3 | 0.5x | 5x | yes |
| ForkData.serialize | medium-fixture | 36 | 5000000 | 29.0 | 56.4 | 0.5x | 5x | yes |
| ForkData.serialize | small-fixture | 36 | 5000000 | 27.4 | 55.5 | 0.5x | 5x | yes |
| ForkDigest.deserialize | random | 4 | 5000000 | 24.6 | 89.5 | 0.3x | 5x | yes |
| ForkDigest.deserialize | saturated | 4 | 5000000 | 19.4 | 81.9 | 0.2x | 5x | yes |
| ForkDigest.deserialize | zero | 4 | 5000000 | 22.4 | 99.1 | 0.2x | 5x | yes |
| ForkDigest.hash_tree_root | random | 4 | 5000000 | 13.2 | 470.0 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | saturated | 4 | 5000000 | 14.8 | 574.2 | 0.0x | 10x | yes |
| ForkDigest.hash_tree_root | zero | 4 | 5000000 | 15.4 | 526.8 | 0.0x | 10x | yes |
| ForkDigest.serialize | random | 4 | 5000000 | 20.0 | 28.6 | 0.7x | 5x | yes |
| ForkDigest.serialize | saturated | 4 | 5000000 | 16.2 | 24.3 | 0.7x | 5x | yes |
| ForkDigest.serialize | zero | 4 | 5000000 | 20.2 | 28.8 | 0.7x | 5x | yes |
| G1Point.deserialize | random | 48 | 3145728 | 93.1 | 109.4 | 0.9x | 5x | yes |
| G1Point.deserialize | saturated | 48 | 2883584 | 108.2 | 109.3 | 1.0x | 5x | yes |
| G1Point.deserialize | zero | 48 | 5000000 | 104.2 | 108.4 | 1.0x | 5x | yes |
| G1Point.hash_tree_root | random | 48 | 262144 | 1209.3 | 773.6 | 1.6x | 10x | yes |
| G1Point.hash_tree_root | saturated | 48 | 671744 | 809.8 | 841.5 | 1.0x | 10x | yes |
| G1Point.hash_tree_root | zero | 48 | 524288 | 1131.1 | 717.7 | 1.6x | 10x | yes |
| G1Point.serialize | random | 48 | 5000000 | 41.2 | 50.5 | 0.8x | 5x | yes |
| G1Point.serialize | saturated | 48 | 5000000 | 38.0 | 51.1 | 0.7x | 5x | yes |
| G1Point.serialize | zero | 48 | 5000000 | 30.0 | 55.3 | 0.5x | 5x | yes |
| G2Point.deserialize | random | 96 | 2097152 | 143.5 | 126.2 | 1.1x | 5x | yes |
| G2Point.deserialize | saturated | 96 | 3145728 | 146.9 | 121.3 | 1.2x | 5x | yes |
| G2Point.deserialize | zero | 96 | 3145728 | 150.7 | 115.0 | 1.3x | 5x | yes |
| G2Point.hash_tree_root | random | 96 | 163840 | 2526.9 | 1064.8 | 2.4x | 10x | yes |
| G2Point.hash_tree_root | saturated | 96 | 102400 | 2636.7 | 1213.1 | 2.2x | 10x | yes |
| G2Point.hash_tree_root | zero | 96 | 204800 | 3320.3 | 1147.8 | 2.9x | 10x | yes |
| G2Point.serialize | random | 96 | 5000000 | 40.6 | 62.7 | 0.6x | 5x | yes |
| G2Point.serialize | saturated | 96 | 5000000 | 44.8 | 60.7 | 0.7x | 5x | yes |
| G2Point.serialize | zero | 96 | 5000000 | 44.6 | 60.9 | 0.7x | 5x | yes |
| Gwei.deserialize | random | 8 | 5000000 | 35.8 | 87.1 | 0.4x | 5x | yes |
| Gwei.deserialize | saturated | 8 | 5000000 | 30.2 | 86.9 | 0.3x | 5x | yes |
| Gwei.deserialize | zero | 8 | 5000000 | 37.6 | 86.3 | 0.4x | 5x | yes |
| Gwei.hash_tree_root | random | 8 | 5000000 | 16.0 | 461.6 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | saturated | 8 | 5000000 | 17.6 | 477.6 | 0.0x | 10x | yes |
| Gwei.hash_tree_root | zero | 8 | 5000000 | 15.8 | 490.7 | 0.0x | 10x | yes |
| Gwei.serialize | random | 8 | 5000000 | 15.8 | 32.6 | 0.5x | 5x | yes |
| Gwei.serialize | saturated | 8 | 5000000 | 18.0 | 27.5 | 0.7x | 5x | yes |
| Gwei.serialize | zero | 8 | 5000000 | 16.0 | 27.9 | 0.6x | 5x | yes |
| Hash32.deserialize | random | 32 | 2883584 | 62.4 | 102.5 | 0.6x | 5x | yes |
| Hash32.deserialize | saturated | 32 | 5000000 | 63.6 | 111.7 | 0.6x | 5x | yes |
| Hash32.deserialize | zero | 32 | 5000000 | 69.2 | 110.9 | 0.6x | 5x | yes |
| Hash32.hash_tree_root | random | 32 | 5000000 | 17.6 | 498.6 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | saturated | 32 | 5000000 | 17.4 | 420.0 | 0.0x | 10x | yes |
| Hash32.hash_tree_root | zero | 32 | 5000000 | 20.2 | 511.5 | 0.0x | 10x | yes |
| Hash32.serialize | random | 32 | 5000000 | 24.4 | 49.5 | 0.5x | 5x | yes |
| Hash32.serialize | saturated | 32 | 5000000 | 20.8 | 49.2 | 0.4x | 5x | yes |
| Hash32.serialize | zero | 32 | 5000000 | 21.2 | 53.8 | 0.4x | 5x | yes |
| HistoricalBatch.deserialize | large-fixture | 524288 | 4864 | 104440.8 | 1223831.8 | 0.1x | 5x | yes |
| HistoricalBatch.deserialize | medium-fixture | 524288 | 3456 | 119213.0 | 1025497.1 | 0.1x | 5x | yes |
| HistoricalBatch.deserialize | small-fixture | 524288 | 3968 | 111139.1 | 1112361.7 | 0.1x | 5x | yes |
| HistoricalBatch.hash_tree_root | large-fixture | 524288 | 32 | 14593750.0 | 2757304.5 | 5.3x | 10x | yes |
| HistoricalBatch.hash_tree_root | medium-fixture | 524288 | 20 | 15450000.0 | 2680010.4 | 5.8x | 10x | yes |
| HistoricalBatch.hash_tree_root | small-fixture | 524288 | 22 | 14545454.5 | 2733426.5 | 5.3x | 10x | yes |
| HistoricalBatch.serialize | large-fixture | 524288 | 6400 | 92343.8 | 211637.9 | 0.4x | 5x | yes |
| HistoricalBatch.serialize | medium-fixture | 524288 | 3456 | 83044.0 | 218769.4 | 0.4x | 5x | yes |
| HistoricalBatch.serialize | small-fixture | 524288 | 5248 | 87080.8 | 234246.3 | 0.4x | 5x | yes |
| HistoricalSummary.deserialize | large-fixture | 64 | 3670016 | 111.7 | 55.8 | 2.0x | 5x | yes |
| HistoricalSummary.deserialize | medium-fixture | 64 | 3670016 | 111.7 | 53.9 | 2.1x | 5x | yes |
| HistoricalSummary.deserialize | small-fixture | 64 | 2621440 | 112.9 | 52.2 | 2.2x | 5x | yes |
| HistoricalSummary.hash_tree_root | large-fixture | 64 | 409600 | 881.3 | 241.2 | 3.7x | 10x | yes |
| HistoricalSummary.hash_tree_root | medium-fixture | 64 | 524288 | 877.4 | 229.7 | 3.8x | 10x | yes |
| HistoricalSummary.hash_tree_root | small-fixture | 64 | 253952 | 1051.4 | 226.9 | 4.6x | 10x | yes |
| HistoricalSummary.serialize | large-fixture | 64 | 5000000 | 31.4 | 69.2 | 0.5x | 5x | yes |
| HistoricalSummary.serialize | medium-fixture | 64 | 5000000 | 29.6 | 65.3 | 0.5x | 5x | yes |
| HistoricalSummary.serialize | small-fixture | 64 | 5000000 | 42.4 | 68.3 | 0.6x | 5x | yes |
| IndexedAttestation.deserialize | large-fixture | 308 | 524288 | 555.0 | 350.5 | 1.6x | 5x | yes |
| IndexedAttestation.deserialize | medium-fixture | 284 | 524288 | 537.9 | 340.2 | 1.6x | 5x | yes |
| IndexedAttestation.deserialize | small-fixture | 236 | 524288 | 581.7 | 328.9 | 1.8x | 5x | yes |
| IndexedAttestation.hash_tree_root | large-fixture | 308 | 16384 | 27221.7 | 6103.1 | 4.5x | 10x | yes |
| IndexedAttestation.hash_tree_root | medium-fixture | 284 | 8192 | 35400.4 | 5248.2 | 6.7x | 10x | yes |
| IndexedAttestation.hash_tree_root | small-fixture | 236 | 16384 | 28503.4 | 5558.7 | 5.1x | 10x | yes |
| IndexedAttestation.serialize | large-fixture | 308 | 1572864 | 284.2 | 152.5 | 1.9x | 5x | yes |
| IndexedAttestation.serialize | medium-fixture | 284 | 1048576 | 292.8 | 142.5 | 2.1x | 5x | yes |
| IndexedAttestation.serialize | small-fixture | 236 | 786432 | 251.8 | 128.9 | 2.0x | 5x | yes |
| KZGCommitment.deserialize | random | 48 | 5000000 | 86.2 | 98.5 | 0.9x | 5x | yes |
| KZGCommitment.deserialize | saturated | 48 | 2621440 | 83.5 | 103.9 | 0.8x | 5x | yes |
| KZGCommitment.deserialize | zero | 48 | 2359296 | 97.9 | 116.7 | 0.8x | 5x | yes |
| KZGCommitment.hash_tree_root | random | 48 | 409600 | 964.4 | 739.5 | 1.3x | 10x | yes |
| KZGCommitment.hash_tree_root | saturated | 48 | 524288 | 1096.7 | 720.5 | 1.5x | 10x | yes |
| KZGCommitment.hash_tree_root | zero | 48 | 335872 | 967.6 | 800.3 | 1.2x | 10x | yes |
| KZGCommitment.serialize | random | 48 | 5000000 | 34.8 | 57.5 | 0.6x | 5x | yes |
| KZGCommitment.serialize | saturated | 48 | 5000000 | 31.6 | 47.1 | 0.7x | 5x | yes |
| KZGCommitment.serialize | zero | 48 | 5000000 | 30.2 | 51.9 | 0.6x | 5x | yes |
| KZGProof.deserialize | random | 48 | 3670016 | 76.0 | 102.2 | 0.7x | 5x | yes |
| KZGProof.deserialize | saturated | 48 | 4718592 | 91.1 | 108.9 | 0.8x | 5x | yes |
| KZGProof.deserialize | zero | 48 | 5000000 | 78.6 | 100.7 | 0.8x | 5x | yes |
| KZGProof.hash_tree_root | random | 48 | 409600 | 1057.1 | 731.3 | 1.4x | 10x | yes |
| KZGProof.hash_tree_root | saturated | 48 | 524288 | 831.6 | 737.0 | 1.1x | 10x | yes |
| KZGProof.hash_tree_root | zero | 48 | 524288 | 806.8 | 697.2 | 1.2x | 10x | yes |
| KZGProof.serialize | random | 48 | 5000000 | 26.6 | 50.4 | 0.5x | 5x | yes |
| KZGProof.serialize | saturated | 48 | 5000000 | 26.2 | 55.0 | 0.5x | 5x | yes |
| KZGProof.serialize | zero | 48 | 5000000 | 27.8 | 47.6 | 0.6x | 5x | yes |
| LightClientBootstrap.deserialize | large-fixture | 25676 | 73728 | 5045.6 | 29754.9 | 0.2x | 5x | yes |
| LightClientBootstrap.deserialize | medium-fixture | 25666 | 81920 | 5127.0 | 33392.0 | 0.2x | 5x | yes |
| LightClientBootstrap.deserialize | small-fixture | 25651 | 53248 | 6404.0 | 33653.5 | 0.2x | 5x | yes |
| LightClientBootstrap.hash_tree_root | large-fixture | 25676 | 512 | 951171.9 | 171803.7 | 5.5x | 10x | yes |
| LightClientBootstrap.hash_tree_root | medium-fixture | 25666 | 256 | 1054687.5 | 191676.1 | 5.5x | 10x | yes |
| LightClientBootstrap.hash_tree_root | small-fixture | 25651 | 320 | 987500.0 | 185397.0 | 5.3x | 10x | yes |
| LightClientBootstrap.serialize | large-fixture | 25676 | 81920 | 4614.3 | 8187.9 | 0.6x | 5x | yes |
| LightClientBootstrap.serialize | medium-fixture | 25666 | 73728 | 4516.6 | 8221.1 | 0.5x | 5x | yes |
| LightClientBootstrap.serialize | small-fixture | 25651 | 98304 | 5045.6 | 8538.8 | 0.6x | 5x | yes |
| LightClientFinalityUpdate.deserialize | large-fixture | 2096 | 155648 | 2807.6 | 3461.4 | 0.8x | 5x | yes |
| LightClientFinalityUpdate.deserialize | medium-fixture | 2078 | 102400 | 2861.3 | 3449.8 | 0.8x | 5x | yes |
| LightClientFinalityUpdate.deserialize | small-fixture | 2066 | 90112 | 2963.0 | 3764.2 | 0.8x | 5x | yes |
| LightClientFinalityUpdate.hash_tree_root | large-fixture | 2096 | 3200 | 79062.5 | 16482.4 | 4.8x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | medium-fixture | 2078 | 3968 | 120967.7 | 16275.3 | 7.4x | 10x | yes |
| LightClientFinalityUpdate.hash_tree_root | small-fixture | 2066 | 3968 | 79385.1 | 16500.5 | 4.8x | 10x | yes |
| LightClientFinalityUpdate.serialize | large-fixture | 2096 | 204800 | 1728.5 | 838.0 | 2.1x | 5x | yes |
| LightClientFinalityUpdate.serialize | medium-fixture | 2078 | 204800 | 1567.4 | 798.9 | 2.0x | 5x | yes |
| LightClientFinalityUpdate.serialize | small-fixture | 2066 | 167936 | 2227.0 | 870.9 | 2.6x | 5x | yes |
| LightClientHeader.deserialize | large-fixture | 860 | 335872 | 1217.7 | 1313.6 | 0.9x | 5x | yes |
| LightClientHeader.deserialize | medium-fixture | 850 | 253952 | 1181.3 | 1332.5 | 0.9x | 5x | yes |
| LightClientHeader.deserialize | small-fixture | 830 | 262144 | 1159.7 | 1282.1 | 0.9x | 5x | yes |
| LightClientHeader.hash_tree_root | large-fixture | 860 | 7936 | 36038.3 | 7032.0 | 5.1x | 10x | yes |
| LightClientHeader.hash_tree_root | medium-fixture | 850 | 8192 | 36377.0 | 6910.1 | 5.3x | 10x | yes |
| LightClientHeader.hash_tree_root | small-fixture | 830 | 8192 | 36132.8 | 6865.3 | 5.3x | 10x | yes |
| LightClientHeader.serialize | large-fixture | 860 | 524288 | 713.3 | 338.4 | 2.1x | 5x | yes |
| LightClientHeader.serialize | medium-fixture | 850 | 524288 | 640.9 | 356.1 | 1.8x | 5x | yes |
| LightClientHeader.serialize | small-fixture | 830 | 524288 | 536.0 | 306.3 | 1.8x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | large-fixture | 1031 | 286720 | 1573.0 | 1620.7 | 1.0x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | medium-fixture | 1013 | 204800 | 1650.4 | 1708.4 | 1.0x | 5x | yes |
| LightClientOptimisticUpdate.deserialize | small-fixture | 1000 | 204800 | 1494.1 | 1618.4 | 0.9x | 5x | yes |
| LightClientOptimisticUpdate.hash_tree_root | large-fixture | 1031 | 8192 | 39672.9 | 8373.6 | 4.7x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | medium-fixture | 1013 | 7936 | 47505.0 | 8399.4 | 5.7x | 10x | yes |
| LightClientOptimisticUpdate.hash_tree_root | small-fixture | 1000 | 8192 | 44067.4 | 8462.5 | 5.2x | 10x | yes |
| LightClientOptimisticUpdate.serialize | large-fixture | 1031 | 524288 | 778.2 | 465.2 | 1.7x | 5x | yes |
| LightClientOptimisticUpdate.serialize | medium-fixture | 1013 | 409600 | 730.0 | 441.0 | 1.7x | 5x | yes |
| LightClientOptimisticUpdate.serialize | small-fixture | 1000 | 524288 | 768.7 | 397.4 | 1.9x | 5x | yes |
| LightClientUpdate.deserialize | large-fixture | 26914 | 49152 | 9419.8 | 35920.0 | 0.3x | 5x | yes |
| LightClientUpdate.deserialize | medium-fixture | 26893 | 57344 | 8475.2 | 35840.4 | 0.2x | 5x | yes |
| LightClientUpdate.deserialize | small-fixture | 26885 | 49152 | 8077.0 | 37495.0 | 0.2x | 5x | yes |
| LightClientUpdate.hash_tree_root | large-fixture | 26914 | 512 | 937500.0 | 183970.6 | 5.1x | 10x | yes |
| LightClientUpdate.hash_tree_root | medium-fixture | 26893 | 192 | 1005208.3 | 220324.0 | 4.6x | 10x | yes |
| LightClientUpdate.hash_tree_root | small-fixture | 26885 | 256 | 1109375.0 | 191587.6 | 5.8x | 10x | yes |
| LightClientUpdate.serialize | large-fixture | 26914 | 57344 | 6731.3 | 8353.8 | 0.8x | 5x | yes |
| LightClientUpdate.serialize | medium-fixture | 26893 | 40960 | 6225.6 | 8732.1 | 0.7x | 5x | yes |
| LightClientUpdate.serialize | small-fixture | 26885 | 57344 | 6626.7 | 8907.0 | 0.7x | 5x | yes |
| MatrixEntry.deserialize | large-fixture | 2112 | 1048576 | 450.1 | 686.3 | 0.7x | 5x | yes |
| MatrixEntry.deserialize | medium-fixture | 2112 | 1048576 | 404.4 | 717.4 | 0.6x | 5x | yes |
| MatrixEntry.deserialize | small-fixture | 2112 | 1048576 | 439.6 | 692.7 | 0.6x | 5x | yes |
| MatrixEntry.hash_tree_root | large-fixture | 2112 | 3968 | 59727.8 | 11279.2 | 5.3x | 10x | yes |
| MatrixEntry.hash_tree_root | medium-fixture | 2112 | 6400 | 60625.0 | 10407.0 | 5.8x | 10x | yes |
| MatrixEntry.hash_tree_root | small-fixture | 2112 | 7936 | 56451.6 | 10504.5 | 5.4x | 10x | yes |
| MatrixEntry.serialize | large-fixture | 2112 | 1048576 | 359.5 | 555.1 | 0.6x | 5x | yes |
| MatrixEntry.serialize | medium-fixture | 2112 | 1048576 | 356.7 | 562.0 | 0.6x | 5x | yes |
| MatrixEntry.serialize | small-fixture | 2112 | 1048576 | 330.0 | 574.6 | 0.6x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | random | 192 | 3932160 | 61.8 | 139.0 | 0.4x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | saturated | 192 | 2883584 | 71.1 | 159.9 | 0.4x | 5x | yes |
| NextSyncCommitteeBranch.deserialize | zero | 192 | 5000000 | 68.6 | 144.1 | 0.5x | 5x | yes |
| NextSyncCommitteeBranch.hash_tree_root | random | 192 | 90112 | 4993.8 | 1677.7 | 3.0x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | saturated | 192 | 65536 | 5416.9 | 1679.0 | 3.2x | 10x | yes |
| NextSyncCommitteeBranch.hash_tree_root | zero | 192 | 73728 | 5995.0 | 1718.4 | 3.5x | 10x | yes |
| NextSyncCommitteeBranch.serialize | random | 192 | 4980736 | 50.8 | 88.9 | 0.6x | 5x | yes |
| NextSyncCommitteeBranch.serialize | saturated | 192 | 5000000 | 58.2 | 85.9 | 0.7x | 5x | yes |
| NextSyncCommitteeBranch.serialize | zero | 192 | 5000000 | 50.6 | 84.0 | 0.6x | 5x | yes |
| NodeID.deserialize | random | 32 | 3932160 | 61.8 | 105.7 | 0.6x | 5x | yes |
| NodeID.deserialize | saturated | 32 | 4194304 | 69.1 | 107.6 | 0.6x | 5x | yes |
| NodeID.deserialize | zero | 32 | 3407872 | 68.4 | 94.8 | 0.7x | 5x | yes |
| NodeID.hash_tree_root | random | 32 | 5000000 | 18.8 | 452.9 | 0.0x | 10x | yes |
| NodeID.hash_tree_root | saturated | 32 | 5000000 | 24.6 | 418.3 | 0.1x | 10x | yes |
| NodeID.hash_tree_root | zero | 32 | 5000000 | 17.6 | 396.1 | 0.0x | 10x | yes |
| NodeID.serialize | random | 32 | 5000000 | 25.0 | 43.6 | 0.6x | 5x | yes |
| NodeID.serialize | saturated | 32 | 5000000 | 29.2 | 46.9 | 0.6x | 5x | yes |
| NodeID.serialize | zero | 32 | 5000000 | 34.4 | 47.9 | 0.7x | 5x | yes |
| ParticipationFlags.deserialize | random | 1 | 5000000 | 17.6 | 79.7 | 0.2x | 5x | yes |
| ParticipationFlags.deserialize | saturated | 1 | 5000000 | 21.4 | 82.2 | 0.3x | 5x | yes |
| ParticipationFlags.deserialize | zero | 1 | 5000000 | 23.8 | 80.3 | 0.3x | 5x | yes |
| ParticipationFlags.hash_tree_root | random | 1 | 5000000 | 12.4 | 480.4 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | saturated | 1 | 5000000 | 12.6 | 504.0 | 0.0x | 10x | yes |
| ParticipationFlags.hash_tree_root | zero | 1 | 5000000 | 11.8 | 547.4 | 0.0x | 10x | yes |
| ParticipationFlags.serialize | random | 1 | 5000000 | 16.4 | 21.6 | 0.8x | 5x | yes |
| ParticipationFlags.serialize | saturated | 1 | 5000000 | 20.6 | 19.7 | 1.0x | 5x | yes |
| ParticipationFlags.serialize | zero | 1 | 5000000 | 15.4 | 20.9 | 0.7x | 5x | yes |
| PayloadId.deserialize | random | 8 | 5000000 | 33.0 | 82.5 | 0.4x | 5x | yes |
| PayloadId.deserialize | saturated | 8 | 5000000 | 30.8 | 84.1 | 0.4x | 5x | yes |
| PayloadId.deserialize | zero | 8 | 5000000 | 31.8 | 87.2 | 0.4x | 5x | yes |
| PayloadId.hash_tree_root | random | 8 | 5000000 | 15.6 | 572.2 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | saturated | 8 | 5000000 | 16.8 | 494.3 | 0.0x | 10x | yes |
| PayloadId.hash_tree_root | zero | 8 | 5000000 | 17.0 | 499.1 | 0.0x | 10x | yes |
| PayloadId.serialize | random | 8 | 5000000 | 22.8 | 32.8 | 0.7x | 5x | yes |
| PayloadId.serialize | saturated | 8 | 5000000 | 20.0 | 29.5 | 0.7x | 5x | yes |
| PayloadId.serialize | zero | 8 | 5000000 | 19.6 | 28.7 | 0.7x | 5x | yes |
| PendingAttestation.deserialize | large-fixture | 150 | 1048576 | 356.7 | 221.4 | 1.6x | 5x | yes |
| PendingAttestation.deserialize | medium-fixture | 149 | 1048576 | 357.6 | 262.4 | 1.4x | 5x | yes |
| PendingAttestation.deserialize | small-fixture | 149 | 1048576 | 331.9 | 223.7 | 1.5x | 5x | yes |
| PendingAttestation.hash_tree_root | large-fixture | 150 | 24576 | 11840.8 | 2742.9 | 4.3x | 10x | yes |
| PendingAttestation.hash_tree_root | medium-fixture | 149 | 24576 | 12980.1 | 2650.3 | 4.9x | 10x | yes |
| PendingAttestation.hash_tree_root | small-fixture | 149 | 24576 | 12654.6 | 2549.4 | 5.0x | 10x | yes |
| PendingAttestation.serialize | large-fixture | 150 | 2883584 | 106.5 | 114.0 | 0.9x | 5x | yes |
| PendingAttestation.serialize | medium-fixture | 149 | 4194304 | 121.8 | 115.7 | 1.1x | 5x | yes |
| PendingAttestation.serialize | small-fixture | 149 | 4194304 | 124.2 | 102.3 | 1.2x | 5x | yes |
| PendingConsolidation.deserialize | large-fixture | 16 | 3932160 | 54.2 | 39.1 | 1.4x | 5x | yes |
| PendingConsolidation.deserialize | medium-fixture | 16 | 5000000 | 43.6 | 40.2 | 1.1x | 5x | yes |
| PendingConsolidation.deserialize | small-fixture | 16 | 5000000 | 57.2 | 38.4 | 1.5x | 5x | yes |
| PendingConsolidation.hash_tree_root | large-fixture | 16 | 409600 | 752.0 | 227.8 | 3.3x | 10x | yes |
| PendingConsolidation.hash_tree_root | medium-fixture | 16 | 524288 | 791.5 | 258.4 | 3.1x | 10x | yes |
| PendingConsolidation.hash_tree_root | small-fixture | 16 | 262144 | 942.2 | 236.5 | 4.0x | 10x | yes |
| PendingConsolidation.serialize | large-fixture | 16 | 5000000 | 21.4 | 40.6 | 0.5x | 5x | yes |
| PendingConsolidation.serialize | medium-fixture | 16 | 5000000 | 25.0 | 42.0 | 0.6x | 5x | yes |
| PendingConsolidation.serialize | small-fixture | 16 | 5000000 | 23.0 | 45.2 | 0.5x | 5x | yes |
| PendingDeposit.deserialize | large-fixture | 192 | 1572864 | 299.5 | 146.4 | 2.0x | 5x | yes |
| PendingDeposit.deserialize | medium-fixture | 192 | 1572864 | 262.6 | 144.6 | 1.8x | 5x | yes |
| PendingDeposit.deserialize | small-fixture | 192 | 1572864 | 279.1 | 144.1 | 1.9x | 5x | yes |
| PendingDeposit.hash_tree_root | large-fixture | 192 | 24576 | 7853.2 | 1721.8 | 4.6x | 10x | yes |
| PendingDeposit.hash_tree_root | medium-fixture | 192 | 49152 | 9643.6 | 1698.6 | 5.7x | 10x | yes |
| PendingDeposit.hash_tree_root | small-fixture | 192 | 24576 | 9684.2 | 1783.2 | 5.4x | 10x | yes |
| PendingDeposit.serialize | large-fixture | 192 | 3407872 | 79.5 | 93.7 | 0.8x | 5x | yes |
| PendingDeposit.serialize | medium-fixture | 192 | 3407872 | 96.8 | 104.2 | 0.9x | 5x | yes |
| PendingDeposit.serialize | small-fixture | 192 | 4194304 | 91.6 | 94.6 | 1.0x | 5x | yes |
| PendingPartialWithdrawal.deserialize | large-fixture | 24 | 5000000 | 52.8 | 37.6 | 1.4x | 5x | yes |
| PendingPartialWithdrawal.deserialize | medium-fixture | 24 | 5000000 | 50.4 | 43.3 | 1.2x | 5x | yes |
| PendingPartialWithdrawal.deserialize | small-fixture | 24 | 5000000 | 48.0 | 40.9 | 1.2x | 5x | yes |
| PendingPartialWithdrawal.hash_tree_root | large-fixture | 24 | 110592 | 2387.2 | 600.0 | 4.0x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | medium-fixture | 24 | 102400 | 2285.2 | 558.7 | 4.1x | 10x | yes |
| PendingPartialWithdrawal.hash_tree_root | small-fixture | 24 | 131072 | 2761.8 | 593.9 | 4.7x | 10x | yes |
| PendingPartialWithdrawal.serialize | large-fixture | 24 | 5000000 | 25.2 | 49.3 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | medium-fixture | 24 | 5000000 | 23.0 | 46.8 | 0.5x | 5x | yes |
| PendingPartialWithdrawal.serialize | small-fixture | 24 | 5000000 | 24.6 | 48.3 | 0.5x | 5x | yes |
| PowBlock.deserialize | large-fixture | 96 | 1835008 | 162.4 | 240.7 | 0.7x | 5x | yes |
| PowBlock.deserialize | medium-fixture | 96 | 3145728 | 169.8 | 215.3 | 0.8x | 5x | yes |
| PowBlock.deserialize | small-fixture | 96 | 2621440 | 152.6 | 206.6 | 0.7x | 5x | yes |
| PowBlock.hash_tree_root | large-fixture | 96 | 155648 | 2428.6 | 527.9 | 4.6x | 10x | yes |
| PowBlock.hash_tree_root | medium-fixture | 96 | 167936 | 2495.0 | 694.3 | 3.6x | 10x | yes |
| PowBlock.hash_tree_root | small-fixture | 96 | 143360 | 2455.4 | 541.2 | 4.5x | 10x | yes |
| PowBlock.serialize | large-fixture | 96 | 5000000 | 45.6 | 77.4 | 0.6x | 5x | yes |
| PowBlock.serialize | medium-fixture | 96 | 4456448 | 40.2 | 79.5 | 0.5x | 5x | yes |
| PowBlock.serialize | small-fixture | 96 | 5000000 | 43.8 | 79.8 | 0.5x | 5x | yes |
| ProposerSlashing.deserialize | large-fixture | 416 | 524288 | 873.6 | 342.3 | 2.6x | 5x | yes |
| ProposerSlashing.deserialize | medium-fixture | 416 | 524288 | 829.7 | 330.2 | 2.5x | 5x | yes |
| ProposerSlashing.deserialize | small-fixture | 416 | 507904 | 763.9 | 321.9 | 2.4x | 5x | yes |
| ProposerSlashing.hash_tree_root | large-fixture | 416 | 12288 | 16927.1 | 3659.9 | 4.6x | 10x | yes |
| ProposerSlashing.hash_tree_root | medium-fixture | 416 | 32768 | 18524.2 | 3633.0 | 5.1x | 10x | yes |
| ProposerSlashing.hash_tree_root | small-fixture | 416 | 16384 | 16784.7 | 4057.1 | 4.1x | 10x | yes |
| ProposerSlashing.serialize | large-fixture | 416 | 2097152 | 202.7 | 192.4 | 1.1x | 5x | yes |
| ProposerSlashing.serialize | medium-fixture | 416 | 1048576 | 199.3 | 175.1 | 1.1x | 5x | yes |
| ProposerSlashing.serialize | small-fixture | 416 | 2097152 | 217.0 | 192.5 | 1.1x | 5x | yes |
| Root.deserialize | random | 32 | 4718592 | 67.6 | 101.7 | 0.7x | 5x | yes |
| Root.deserialize | saturated | 32 | 5000000 | 67.6 | 95.7 | 0.7x | 5x | yes |
| Root.deserialize | zero | 32 | 5000000 | 75.6 | 97.3 | 0.8x | 5x | yes |
| Root.hash_tree_root | random | 32 | 5000000 | 20.0 | 423.7 | 0.0x | 10x | yes |
| Root.hash_tree_root | saturated | 32 | 5000000 | 20.2 | 438.7 | 0.0x | 10x | yes |
| Root.hash_tree_root | zero | 32 | 5000000 | 19.0 | 427.5 | 0.0x | 10x | yes |
| Root.serialize | random | 32 | 5000000 | 25.0 | 42.0 | 0.6x | 5x | yes |
| Root.serialize | saturated | 32 | 5000000 | 29.8 | 46.4 | 0.6x | 5x | yes |
| Root.serialize | zero | 32 | 5000000 | 25.8 | 44.0 | 0.6x | 5x | yes |
| RowIndex.deserialize | random | 8 | 5000000 | 41.4 | 89.4 | 0.5x | 5x | yes |
| RowIndex.deserialize | saturated | 8 | 5000000 | 41.2 | 83.9 | 0.5x | 5x | yes |
| RowIndex.deserialize | zero | 8 | 5000000 | 42.6 | 94.9 | 0.4x | 5x | yes |
| RowIndex.hash_tree_root | random | 8 | 5000000 | 20.2 | 512.8 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | saturated | 8 | 5000000 | 19.2 | 491.7 | 0.0x | 10x | yes |
| RowIndex.hash_tree_root | zero | 8 | 5000000 | 18.6 | 494.9 | 0.0x | 10x | yes |
| RowIndex.serialize | random | 8 | 5000000 | 20.2 | 28.7 | 0.7x | 5x | yes |
| RowIndex.serialize | saturated | 8 | 5000000 | 19.2 | 30.3 | 0.6x | 5x | yes |
| RowIndex.serialize | zero | 8 | 5000000 | 25.8 | 32.2 | 0.8x | 5x | yes |
| SignedAggregateAndProof.deserialize | large-fixture | 446 | 253952 | 960.8 | 520.1 | 1.8x | 5x | yes |
| SignedAggregateAndProof.deserialize | medium-fixture | 445 | 204800 | 1142.6 | 579.9 | 2.0x | 5x | yes |
| SignedAggregateAndProof.deserialize | small-fixture | 445 | 409600 | 1027.8 | 523.7 | 2.0x | 5x | yes |
| SignedAggregateAndProof.hash_tree_root | large-fixture | 446 | 8192 | 32470.7 | 6710.8 | 4.8x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | medium-fixture | 445 | 16384 | 26611.3 | 4948.5 | 5.4x | 10x | yes |
| SignedAggregateAndProof.hash_tree_root | small-fixture | 445 | 8192 | 34423.8 | 6709.5 | 5.1x | 10x | yes |
| SignedAggregateAndProof.serialize | large-fixture | 446 | 1048576 | 548.4 | 203.2 | 2.7x | 5x | yes |
| SignedAggregateAndProof.serialize | medium-fixture | 445 | 1048576 | 472.1 | 210.9 | 2.2x | 5x | yes |
| SignedAggregateAndProof.serialize | small-fixture | 445 | 1048576 | 556.9 | 209.5 | 2.7x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | large-fixture | 172 | 1048576 | 236.5 | 135.0 | 1.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | medium-fixture | 172 | 1048576 | 248.0 | 134.5 | 1.8x | 5x | yes |
| SignedBLSToExecutionChange.deserialize | small-fixture | 172 | 1572864 | 263.8 | 152.5 | 1.7x | 5x | yes |
| SignedBLSToExecutionChange.hash_tree_root | large-fixture | 172 | 65536 | 6439.2 | 1704.2 | 3.8x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | medium-fixture | 172 | 40960 | 6860.4 | 1389.4 | 4.9x | 10x | yes |
| SignedBLSToExecutionChange.hash_tree_root | small-fixture | 172 | 45056 | 6725.0 | 1375.7 | 4.9x | 10x | yes |
| SignedBLSToExecutionChange.serialize | large-fixture | 172 | 5000000 | 63.8 | 95.9 | 0.7x | 5x | yes |
| SignedBLSToExecutionChange.serialize | medium-fixture | 172 | 5000000 | 62.8 | 95.7 | 0.7x | 5x | yes |
| SignedBLSToExecutionChange.serialize | small-fixture | 172 | 5000000 | 65.4 | 100.7 | 0.6x | 5x | yes |
| SignedBeaconBlock.deserialize | large-fixture | 23999 | 16384 | 26550.3 | 34875.4 | 0.8x | 5x | yes |
| SignedBeaconBlock.deserialize | medium-fixture | 18718 | 16384 | 27954.1 | 27486.2 | 1.0x | 5x | yes |
| SignedBeaconBlock.deserialize | small-fixture | 16683 | 24576 | 14892.6 | 24061.3 | 0.6x | 5x | yes |
| SignedBeaconBlock.hash_tree_root | large-fixture | 23999 | 384 | 1044270.8 | 196448.8 | 5.3x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | medium-fixture | 18718 | 512 | 798828.1 | 171607.6 | 4.7x | 10x | yes |
| SignedBeaconBlock.hash_tree_root | small-fixture | 16683 | 640 | 626562.5 | 134558.8 | 4.7x | 10x | yes |
| SignedBeaconBlock.serialize | large-fixture | 23999 | 24576 | 11800.1 | 9174.1 | 1.3x | 5x | yes |
| SignedBeaconBlock.serialize | medium-fixture | 18718 | 32768 | 11138.9 | 5996.1 | 1.9x | 5x | yes |
| SignedBeaconBlock.serialize | small-fixture | 16683 | 57344 | 8719.3 | 5926.0 | 1.5x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | large-fixture | 208 | 1048576 | 394.8 | 138.0 | 2.9x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | medium-fixture | 208 | 1048576 | 391.0 | 134.7 | 2.9x | 5x | yes |
| SignedBeaconBlockHeader.deserialize | small-fixture | 208 | 1048576 | 395.8 | 140.7 | 2.8x | 5x | yes |
| SignedBeaconBlockHeader.hash_tree_root | large-fixture | 208 | 40960 | 8325.2 | 1722.7 | 4.8x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | medium-fixture | 208 | 32768 | 7507.3 | 1718.7 | 4.4x | 10x | yes |
| SignedBeaconBlockHeader.hash_tree_root | small-fixture | 208 | 32768 | 11596.7 | 1822.1 | 6.4x | 10x | yes |
| SignedBeaconBlockHeader.serialize | large-fixture | 208 | 4194304 | 72.7 | 123.5 | 0.6x | 5x | yes |
| SignedBeaconBlockHeader.serialize | medium-fixture | 208 | 4456448 | 77.0 | 106.0 | 0.7x | 5x | yes |
| SignedBeaconBlockHeader.serialize | small-fixture | 208 | 5000000 | 70.0 | 103.0 | 0.7x | 5x | yes |
| SignedContributionAndProof.deserialize | large-fixture | 360 | 524288 | 579.8 | 289.3 | 2.0x | 5x | yes |
| SignedContributionAndProof.deserialize | medium-fixture | 360 | 524288 | 618.0 | 292.4 | 2.1x | 5x | yes |
| SignedContributionAndProof.deserialize | small-fixture | 360 | 524288 | 618.0 | 317.6 | 1.9x | 5x | yes |
| SignedContributionAndProof.hash_tree_root | large-fixture | 360 | 24576 | 19327.8 | 3123.0 | 6.2x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | medium-fixture | 360 | 24576 | 15991.2 | 3237.5 | 4.9x | 10x | yes |
| SignedContributionAndProof.hash_tree_root | small-fixture | 360 | 24576 | 18839.5 | 3233.7 | 5.8x | 10x | yes |
| SignedContributionAndProof.serialize | large-fixture | 360 | 1572864 | 172.3 | 161.5 | 1.1x | 5x | yes |
| SignedContributionAndProof.serialize | medium-fixture | 360 | 1572864 | 187.6 | 168.0 | 1.1x | 5x | yes |
| SignedContributionAndProof.serialize | small-fixture | 360 | 2097152 | 181.2 | 159.7 | 1.1x | 5x | yes |
| SignedVoluntaryExit.deserialize | large-fixture | 112 | 2621440 | 185.4 | 115.9 | 1.6x | 5x | yes |
| SignedVoluntaryExit.deserialize | medium-fixture | 112 | 1572864 | 171.7 | 128.4 | 1.3x | 5x | yes |
| SignedVoluntaryExit.deserialize | small-fixture | 112 | 2621440 | 154.5 | 124.7 | 1.2x | 5x | yes |
| SignedVoluntaryExit.hash_tree_root | large-fixture | 112 | 98304 | 4323.3 | 906.1 | 4.8x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | medium-fixture | 112 | 65536 | 4608.2 | 1153.0 | 4.0x | 10x | yes |
| SignedVoluntaryExit.hash_tree_root | small-fixture | 112 | 90112 | 3995.0 | 916.7 | 4.4x | 10x | yes |
| SignedVoluntaryExit.serialize | large-fixture | 112 | 5000000 | 60.2 | 82.3 | 0.7x | 5x | yes |
| SignedVoluntaryExit.serialize | medium-fixture | 112 | 5000000 | 57.6 | 72.0 | 0.8x | 5x | yes |
| SignedVoluntaryExit.serialize | small-fixture | 112 | 5000000 | 50.4 | 65.3 | 0.8x | 5x | yes |
| SigningData.deserialize | large-fixture | 64 | 1835008 | 107.9 | 57.9 | 1.9x | 5x | yes |
| SigningData.deserialize | medium-fixture | 64 | 4194304 | 112.3 | 52.7 | 2.1x | 5x | yes |
| SigningData.deserialize | small-fixture | 64 | 3145728 | 115.7 | 63.5 | 1.8x | 5x | yes |
| SigningData.hash_tree_root | large-fixture | 64 | 524288 | 974.7 | 217.3 | 4.5x | 10x | yes |
| SigningData.hash_tree_root | medium-fixture | 64 | 409600 | 842.3 | 229.0 | 3.7x | 10x | yes |
| SigningData.hash_tree_root | small-fixture | 64 | 524288 | 896.5 | 250.5 | 3.6x | 10x | yes |
| SigningData.serialize | large-fixture | 64 | 5000000 | 31.6 | 59.5 | 0.5x | 5x | yes |
| SigningData.serialize | medium-fixture | 64 | 5000000 | 33.2 | 60.8 | 0.5x | 5x | yes |
| SigningData.serialize | small-fixture | 64 | 5000000 | 35.0 | 69.0 | 0.5x | 5x | yes |
| SingleAttestation.deserialize | large-fixture | 240 | 1048576 | 476.8 | 220.1 | 2.2x | 5x | yes |
| SingleAttestation.deserialize | medium-fixture | 240 | 524288 | 467.3 | 235.0 | 2.0x | 5x | yes |
| SingleAttestation.deserialize | small-fixture | 240 | 524288 | 467.3 | 220.1 | 2.1x | 5x | yes |
| SingleAttestation.hash_tree_root | large-fixture | 240 | 40960 | 12085.0 | 2751.8 | 4.4x | 10x | yes |
| SingleAttestation.hash_tree_root | medium-fixture | 240 | 24576 | 11637.4 | 2425.9 | 4.8x | 10x | yes |
| SingleAttestation.hash_tree_root | small-fixture | 240 | 24576 | 11189.8 | 2401.4 | 4.7x | 10x | yes |
| SingleAttestation.serialize | large-fixture | 240 | 3407872 | 88.0 | 133.0 | 0.7x | 5x | yes |
| SingleAttestation.serialize | medium-fixture | 240 | 5000000 | 85.8 | 122.0 | 0.7x | 5x | yes |
| SingleAttestation.serialize | small-fixture | 240 | 5000000 | 84.8 | 127.7 | 0.7x | 5x | yes |
| Slot.deserialize | random | 8 | 5000000 | 30.2 | 84.4 | 0.4x | 5x | yes |
| Slot.deserialize | saturated | 8 | 5000000 | 27.2 | 81.5 | 0.3x | 5x | yes |
| Slot.deserialize | zero | 8 | 5000000 | 28.6 | 91.6 | 0.3x | 5x | yes |
| Slot.hash_tree_root | random | 8 | 5000000 | 14.2 | 516.5 | 0.0x | 10x | yes |
| Slot.hash_tree_root | saturated | 8 | 5000000 | 13.6 | 472.6 | 0.0x | 10x | yes |
| Slot.hash_tree_root | zero | 8 | 5000000 | 14.0 | 494.6 | 0.0x | 10x | yes |
| Slot.serialize | random | 8 | 5000000 | 21.2 | 31.2 | 0.7x | 5x | yes |
| Slot.serialize | saturated | 8 | 5000000 | 18.4 | 28.0 | 0.7x | 5x | yes |
| Slot.serialize | zero | 8 | 5000000 | 19.6 | 29.7 | 0.7x | 5x | yes |
| SubnetID.deserialize | random | 8 | 5000000 | 35.2 | 81.6 | 0.4x | 5x | yes |
| SubnetID.deserialize | saturated | 8 | 5000000 | 46.6 | 85.5 | 0.5x | 5x | yes |
| SubnetID.deserialize | zero | 8 | 5000000 | 40.0 | 81.6 | 0.5x | 5x | yes |
| SubnetID.hash_tree_root | random | 8 | 5000000 | 19.4 | 492.2 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | saturated | 8 | 5000000 | 15.6 | 470.2 | 0.0x | 10x | yes |
| SubnetID.hash_tree_root | zero | 8 | 5000000 | 18.8 | 454.9 | 0.0x | 10x | yes |
| SubnetID.serialize | random | 8 | 5000000 | 19.6 | 30.2 | 0.6x | 5x | yes |
| SubnetID.serialize | saturated | 8 | 5000000 | 18.4 | 31.2 | 0.6x | 5x | yes |
| SubnetID.serialize | zero | 8 | 5000000 | 20.4 | 28.6 | 0.7x | 5x | yes |
| SyncAggregate.deserialize | large-fixture | 160 | 2097152 | 218.4 | 132.0 | 1.7x | 5x | yes |
| SyncAggregate.deserialize | medium-fixture | 160 | 1310720 | 224.3 | 129.4 | 1.7x | 5x | yes |
| SyncAggregate.deserialize | small-fixture | 160 | 2097152 | 223.6 | 134.1 | 1.7x | 5x | yes |
| SyncAggregate.hash_tree_root | large-fixture | 160 | 106496 | 4413.3 | 926.8 | 4.8x | 10x | yes |
| SyncAggregate.hash_tree_root | medium-fixture | 160 | 69632 | 4997.7 | 1150.0 | 4.3x | 10x | yes |
| SyncAggregate.hash_tree_root | small-fixture | 160 | 131072 | 4379.3 | 917.7 | 4.8x | 10x | yes |
| SyncAggregate.serialize | large-fixture | 160 | 5000000 | 67.2 | 92.0 | 0.7x | 5x | yes |
| SyncAggregate.serialize | medium-fixture | 160 | 5000000 | 68.2 | 84.6 | 0.8x | 5x | yes |
| SyncAggregate.serialize | small-fixture | 160 | 5000000 | 59.6 | 93.0 | 0.6x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | large-fixture | 16 | 5000000 | 41.4 | 39.9 | 1.0x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | medium-fixture | 16 | 3932160 | 52.1 | 38.6 | 1.4x | 5x | yes |
| SyncAggregatorSelectionData.deserialize | small-fixture | 16 | 5000000 | 53.2 | 41.5 | 1.3x | 5x | yes |
| SyncAggregatorSelectionData.hash_tree_root | large-fixture | 16 | 507904 | 734.4 | 260.5 | 2.8x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | medium-fixture | 16 | 335872 | 830.7 | 243.5 | 3.4x | 10x | yes |
| SyncAggregatorSelectionData.hash_tree_root | small-fixture | 16 | 524288 | 841.1 | 234.9 | 3.6x | 10x | yes |
| SyncAggregatorSelectionData.serialize | large-fixture | 16 | 5000000 | 18.0 | 40.8 | 0.4x | 5x | yes |
| SyncAggregatorSelectionData.serialize | medium-fixture | 16 | 5000000 | 16.0 | 43.6 | 0.4x | 5x | yes |
| SyncAggregatorSelectionData.serialize | small-fixture | 16 | 5000000 | 18.2 | 45.4 | 0.4x | 5x | yes |
| SyncCommittee.deserialize | large-fixture | 24624 | 69632 | 3619.0 | 7537.3 | 0.5x | 5x | yes |
| SyncCommittee.deserialize | medium-fixture | 24624 | 90112 | 3329.2 | 7449.7 | 0.4x | 5x | yes |
| SyncCommittee.deserialize | small-fixture | 24624 | 106496 | 3690.3 | 7275.9 | 0.5x | 5x | yes |
| SyncCommittee.hash_tree_root | large-fixture | 24624 | 512 | 869140.6 | 206904.4 | 4.2x | 10x | yes |
| SyncCommittee.hash_tree_root | medium-fixture | 24624 | 384 | 966145.8 | 213614.0 | 4.5x | 10x | yes |
| SyncCommittee.hash_tree_root | small-fixture | 24624 | 256 | 917968.8 | 214348.2 | 4.3x | 10x | yes |
| SyncCommittee.serialize | large-fixture | 24624 | 131072 | 3906.2 | 7730.1 | 0.5x | 5x | yes |
| SyncCommittee.serialize | medium-fixture | 24624 | 69632 | 3992.4 | 7338.5 | 0.5x | 5x | yes |
| SyncCommittee.serialize | small-fixture | 24624 | 81920 | 4614.3 | 7349.1 | 0.6x | 5x | yes |
| SyncCommitteeContribution.deserialize | large-fixture | 160 | 1048576 | 274.7 | 128.6 | 2.1x | 5x | yes |
| SyncCommitteeContribution.deserialize | medium-fixture | 160 | 1572864 | 265.1 | 131.3 | 2.0x | 5x | yes |
| SyncCommitteeContribution.deserialize | small-fixture | 160 | 1048576 | 252.7 | 147.7 | 1.7x | 5x | yes |
| SyncCommitteeContribution.hash_tree_root | large-fixture | 160 | 40960 | 7153.3 | 1559.9 | 4.6x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | medium-fixture | 160 | 32768 | 7080.1 | 1567.0 | 4.5x | 10x | yes |
| SyncCommitteeContribution.hash_tree_root | small-fixture | 160 | 40960 | 7714.8 | 1571.6 | 4.9x | 10x | yes |
| SyncCommitteeContribution.serialize | large-fixture | 160 | 5000000 | 64.2 | 87.6 | 0.7x | 5x | yes |
| SyncCommitteeContribution.serialize | medium-fixture | 160 | 4456448 | 59.7 | 81.3 | 0.7x | 5x | yes |
| SyncCommitteeContribution.serialize | small-fixture | 160 | 5000000 | 72.2 | 95.4 | 0.8x | 5x | yes |
| SyncCommitteeMessage.deserialize | large-fixture | 144 | 1572864 | 200.3 | 84.7 | 2.4x | 5x | yes |
| SyncCommitteeMessage.deserialize | medium-fixture | 144 | 1048576 | 243.2 | 81.2 | 3.0x | 5x | yes |
| SyncCommitteeMessage.deserialize | small-fixture | 144 | 1572864 | 220.6 | 76.8 | 2.9x | 5x | yes |
| SyncCommitteeMessage.hash_tree_root | large-fixture | 144 | 53248 | 4713.8 | 1036.7 | 4.5x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | medium-fixture | 144 | 65536 | 4821.8 | 1092.8 | 4.4x | 10x | yes |
| SyncCommitteeMessage.hash_tree_root | small-fixture | 144 | 57344 | 5353.7 | 1088.0 | 4.9x | 10x | yes |
| SyncCommitteeMessage.serialize | large-fixture | 144 | 5000000 | 64.2 | 80.4 | 0.8x | 5x | yes |
| SyncCommitteeMessage.serialize | medium-fixture | 144 | 4456448 | 62.2 | 77.8 | 0.8x | 5x | yes |
| SyncCommitteeMessage.serialize | small-fixture | 144 | 5000000 | 74.6 | 85.5 | 0.9x | 5x | yes |
| Transaction.deserialize | large | 1048576 | 1280 | 252343.8 | 160140.4 | 1.6x | 5x | yes |
| Transaction.deserialize | medium | 4096 | 524288 | 738.1 | 1214.2 | 0.6x | 5x | yes |
| Transaction.deserialize | small | 32 | 5000000 | 54.2 | 95.3 | 0.6x | 5x | yes |
| Transaction.hash_tree_root | large | 1048576 | 10 | 29200000.0 | 5520891.4 | 5.3x | 10x | yes |
| Transaction.hash_tree_root | medium | 4096 | 1600 | 117500.0 | 25516.5 | 4.6x | 10x | yes |
| Transaction.hash_tree_root | small | 32 | 16384 | 29113.8 | 4974.4 | 5.9x | 10x | yes |
| Transaction.serialize | large | 1048576 | 2176 | 237132.4 | 162659.7 | 1.5x | 5x | yes |
| Transaction.serialize | medium | 4096 | 507904 | 781.6 | 1025.6 | 0.8x | 5x | yes |
| Transaction.serialize | small | 32 | 5000000 | 35.6 | 42.5 | 0.8x | 5x | yes |
| Validator.deserialize | large-fixture | 121 | 1310720 | 192.3 | 125.7 | 1.5x | 5x | yes |
| Validator.deserialize | medium-fixture | 121 | 2097152 | 219.3 | 127.7 | 1.7x | 5x | yes |
| Validator.deserialize | small-fixture | 121 | 1310720 | 186.2 | 129.3 | 1.4x | 5x | yes |
| Validator.hash_tree_root | large-fixture | 121 | 49152 | 7385.3 | 1390.8 | 5.3x | 10x | yes |
| Validator.hash_tree_root | medium-fixture | 121 | 57344 | 6469.7 | 1340.5 | 4.8x | 10x | yes |
| Validator.hash_tree_root | small-fixture | 121 | 49152 | 6876.6 | 1404.2 | 4.9x | 10x | yes |
| Validator.serialize | large-fixture | 121 | 3407872 | 53.7 | 86.9 | 0.6x | 5x | yes |
| Validator.serialize | medium-fixture | 121 | 4980736 | 51.8 | 87.6 | 0.6x | 5x | yes |
| Validator.serialize | small-fixture | 121 | 5000000 | 54.0 | 88.1 | 0.6x | 5x | yes |
| ValidatorIndex.deserialize | random | 8 | 5000000 | 32.2 | 87.0 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | saturated | 8 | 5000000 | 33.2 | 86.8 | 0.4x | 5x | yes |
| ValidatorIndex.deserialize | zero | 8 | 5000000 | 32.8 | 84.5 | 0.4x | 5x | yes |
| ValidatorIndex.hash_tree_root | random | 8 | 5000000 | 17.0 | 517.6 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | saturated | 8 | 5000000 | 16.4 | 527.5 | 0.0x | 10x | yes |
| ValidatorIndex.hash_tree_root | zero | 8 | 5000000 | 17.2 | 498.2 | 0.0x | 10x | yes |
| ValidatorIndex.serialize | random | 8 | 5000000 | 19.0 | 30.3 | 0.6x | 5x | yes |
| ValidatorIndex.serialize | saturated | 8 | 5000000 | 15.6 | 28.7 | 0.5x | 5x | yes |
| ValidatorIndex.serialize | zero | 8 | 5000000 | 20.4 | 33.4 | 0.6x | 5x | yes |
| Version.deserialize | random | 4 | 5000000 | 16.2 | 90.2 | 0.2x | 5x | yes |
| Version.deserialize | saturated | 4 | 5000000 | 16.8 | 90.1 | 0.2x | 5x | yes |
| Version.deserialize | zero | 4 | 5000000 | 18.4 | 78.5 | 0.2x | 5x | yes |
| Version.hash_tree_root | random | 4 | 5000000 | 12.8 | 470.3 | 0.0x | 10x | yes |
| Version.hash_tree_root | saturated | 4 | 5000000 | 13.2 | 475.5 | 0.0x | 10x | yes |
| Version.hash_tree_root | zero | 4 | 5000000 | 14.4 | 495.3 | 0.0x | 10x | yes |
| Version.serialize | random | 4 | 5000000 | 14.0 | 25.7 | 0.5x | 5x | yes |
| Version.serialize | saturated | 4 | 5000000 | 15.6 | 23.5 | 0.7x | 5x | yes |
| Version.serialize | zero | 4 | 5000000 | 21.0 | 28.5 | 0.7x | 5x | yes |
| VersionedHash.deserialize | random | 32 | 5000000 | 56.8 | 100.7 | 0.6x | 5x | yes |
| VersionedHash.deserialize | saturated | 32 | 5000000 | 62.2 | 95.8 | 0.6x | 5x | yes |
| VersionedHash.deserialize | zero | 32 | 5000000 | 58.2 | 97.6 | 0.6x | 5x | yes |
| VersionedHash.hash_tree_root | random | 32 | 5000000 | 18.4 | 410.1 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | saturated | 32 | 5000000 | 19.4 | 433.6 | 0.0x | 10x | yes |
| VersionedHash.hash_tree_root | zero | 32 | 5000000 | 21.2 | 440.4 | 0.0x | 10x | yes |
| VersionedHash.serialize | random | 32 | 5000000 | 25.4 | 41.2 | 0.6x | 5x | yes |
| VersionedHash.serialize | saturated | 32 | 5000000 | 26.6 | 49.8 | 0.5x | 5x | yes |
| VersionedHash.serialize | zero | 32 | 5000000 | 26.8 | 49.5 | 0.5x | 5x | yes |
| VoluntaryExit.deserialize | large-fixture | 16 | 5000000 | 49.2 | 40.7 | 1.2x | 5x | yes |
| VoluntaryExit.deserialize | medium-fixture | 16 | 4980736 | 46.8 | 45.8 | 1.0x | 5x | yes |
| VoluntaryExit.deserialize | small-fixture | 16 | 5000000 | 46.0 | 39.8 | 1.2x | 5x | yes |
| VoluntaryExit.hash_tree_root | large-fixture | 16 | 507904 | 1122.3 | 247.2 | 4.5x | 10x | yes |
| VoluntaryExit.hash_tree_root | medium-fixture | 16 | 524288 | 846.9 | 223.3 | 3.8x | 10x | yes |
| VoluntaryExit.hash_tree_root | small-fixture | 16 | 204800 | 717.8 | 219.7 | 3.3x | 10x | yes |
| VoluntaryExit.serialize | large-fixture | 16 | 5000000 | 19.6 | 43.7 | 0.4x | 5x | yes |
| VoluntaryExit.serialize | medium-fixture | 16 | 5000000 | 21.6 | 44.8 | 0.5x | 5x | yes |
| VoluntaryExit.serialize | small-fixture | 16 | 5000000 | 22.2 | 47.8 | 0.5x | 5x | yes |
| Withdrawal.deserialize | large-fixture | 44 | 3670016 | 76.0 | 55.0 | 1.4x | 5x | yes |
| Withdrawal.deserialize | medium-fixture | 44 | 2883584 | 84.6 | 50.6 | 1.7x | 5x | yes |
| Withdrawal.deserialize | small-fixture | 44 | 3670016 | 82.3 | 51.5 | 1.6x | 5x | yes |
| Withdrawal.hash_tree_root | large-fixture | 44 | 102400 | 2441.4 | 582.3 | 4.2x | 10x | yes |
| Withdrawal.hash_tree_root | medium-fixture | 44 | 143360 | 2573.9 | 579.6 | 4.4x | 10x | yes |
| Withdrawal.hash_tree_root | small-fixture | 44 | 81920 | 2502.4 | 639.8 | 3.9x | 10x | yes |
| Withdrawal.serialize | large-fixture | 44 | 5000000 | 36.4 | 55.9 | 0.7x | 5x | yes |
| Withdrawal.serialize | medium-fixture | 44 | 5000000 | 27.4 | 60.6 | 0.5x | 5x | yes |
| Withdrawal.serialize | small-fixture | 44 | 5000000 | 28.2 | 56.9 | 0.5x | 5x | yes |
| WithdrawalIndex.deserialize | random | 8 | 5000000 | 35.8 | 94.2 | 0.4x | 5x | yes |
| WithdrawalIndex.deserialize | saturated | 8 | 5000000 | 35.8 | 77.5 | 0.5x | 5x | yes |
| WithdrawalIndex.deserialize | zero | 8 | 5000000 | 34.6 | 93.3 | 0.4x | 5x | yes |
| WithdrawalIndex.hash_tree_root | random | 8 | 5000000 | 16.2 | 466.7 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | saturated | 8 | 5000000 | 18.0 | 526.2 | 0.0x | 10x | yes |
| WithdrawalIndex.hash_tree_root | zero | 8 | 5000000 | 14.8 | 468.5 | 0.0x | 10x | yes |
| WithdrawalIndex.serialize | random | 8 | 5000000 | 19.6 | 27.6 | 0.7x | 5x | yes |
| WithdrawalIndex.serialize | saturated | 8 | 5000000 | 23.8 | 28.9 | 0.8x | 5x | yes |
| WithdrawalIndex.serialize | zero | 8 | 5000000 | 19.8 | 29.4 | 0.7x | 5x | yes |
| WithdrawalRequest.deserialize | large-fixture | 76 | 3145728 | 111.3 | 60.9 | 1.8x | 5x | yes |
| WithdrawalRequest.deserialize | medium-fixture | 76 | 2097152 | 127.8 | 58.0 | 2.2x | 5x | yes |
| WithdrawalRequest.deserialize | small-fixture | 76 | 2097152 | 117.3 | 57.6 | 2.0x | 5x | yes |
| WithdrawalRequest.hash_tree_root | large-fixture | 76 | 65536 | 3372.2 | 765.0 | 4.4x | 10x | yes |
| WithdrawalRequest.hash_tree_root | medium-fixture | 76 | 122880 | 3678.4 | 732.0 | 5.0x | 10x | yes |
| WithdrawalRequest.hash_tree_root | small-fixture | 76 | 131072 | 3364.6 | 758.9 | 4.4x | 10x | yes |
| WithdrawalRequest.serialize | large-fixture | 76 | 5000000 | 35.0 | 61.4 | 0.6x | 5x | yes |
| WithdrawalRequest.serialize | medium-fixture | 76 | 5000000 | 34.0 | 69.0 | 0.5x | 5x | yes |
| WithdrawalRequest.serialize | small-fixture | 76 | 5000000 | 33.0 | 65.5 | 0.5x | 5x | yes |
| boolean.deserialize | false | 1 | 5000000 | 13.6 | 76.8 | 0.2x | 5x | yes |
| boolean.deserialize | true | 1 | 5000000 | 14.4 | 76.9 | 0.2x | 5x | yes |
| boolean.hash_tree_root | false | 1 | 5000000 | 12.0 | 465.1 | 0.0x | 10x | yes |
| boolean.hash_tree_root | true | 1 | 5000000 | 12.8 | 524.7 | 0.0x | 10x | yes |
| boolean.serialize | false | 1 | 5000000 | 15.2 | 19.7 | 0.8x | 5x | yes |
| boolean.serialize | true | 1 | 5000000 | 14.4 | 17.5 | 0.8x | 5x | yes |
| uint256.deserialize | random | 32 | 4980736 | 50.4 | 95.6 | 0.5x | 5x | yes |
| uint256.deserialize | saturated | 32 | 5000000 | 53.0 | 98.7 | 0.5x | 5x | yes |
| uint256.deserialize | zero | 32 | 5000000 | 53.6 | 96.2 | 0.6x | 5x | yes |
| uint256.hash_tree_root | random | 32 | 5000000 | 17.4 | 390.9 | 0.0x | 10x | yes |
| uint256.hash_tree_root | saturated | 32 | 5000000 | 16.2 | 407.6 | 0.0x | 10x | yes |
| uint256.hash_tree_root | zero | 32 | 5000000 | 17.4 | 386.9 | 0.0x | 10x | yes |
| uint256.serialize | random | 32 | 5000000 | 20.8 | 43.2 | 0.5x | 5x | yes |
| uint256.serialize | saturated | 32 | 5000000 | 21.8 | 43.7 | 0.5x | 5x | yes |
| uint256.serialize | zero | 32 | 5000000 | 21.2 | 42.6 | 0.5x | 5x | yes |
| uint32.deserialize | random | 4 | 5000000 | 13.8 | 76.8 | 0.2x | 5x | yes |
| uint32.deserialize | saturated | 4 | 5000000 | 14.6 | 83.4 | 0.2x | 5x | yes |
| uint32.deserialize | zero | 4 | 5000000 | 15.8 | 80.3 | 0.2x | 5x | yes |
| uint32.hash_tree_root | random | 4 | 5000000 | 12.2 | 536.7 | 0.0x | 10x | yes |
| uint32.hash_tree_root | saturated | 4 | 5000000 | 12.6 | 517.1 | 0.0x | 10x | yes |
| uint32.hash_tree_root | zero | 4 | 5000000 | 14.0 | 515.8 | 0.0x | 10x | yes |
| uint32.serialize | random | 4 | 5000000 | 16.4 | 26.3 | 0.6x | 5x | yes |
| uint32.serialize | saturated | 4 | 5000000 | 12.8 | 24.4 | 0.5x | 5x | yes |
| uint32.serialize | zero | 4 | 5000000 | 14.0 | 24.1 | 0.6x | 5x | yes |
| uint64.deserialize | random | 8 | 5000000 | 31.6 | 92.8 | 0.3x | 5x | yes |
| uint64.deserialize | saturated | 8 | 5000000 | 48.0 | 96.4 | 0.5x | 5x | yes |
| uint64.deserialize | zero | 8 | 5000000 | 34.6 | 83.6 | 0.4x | 5x | yes |
| uint64.hash_tree_root | random | 8 | 5000000 | 14.6 | 486.3 | 0.0x | 10x | yes |
| uint64.hash_tree_root | saturated | 8 | 5000000 | 14.4 | 507.7 | 0.0x | 10x | yes |
| uint64.hash_tree_root | zero | 8 | 5000000 | 14.4 | 523.4 | 0.0x | 10x | yes |
| uint64.serialize | random | 8 | 5000000 | 16.6 | 27.6 | 0.6x | 5x | yes |
| uint64.serialize | saturated | 8 | 5000000 | 17.0 | 30.3 | 0.6x | 5x | yes |
| uint64.serialize | zero | 8 | 5000000 | 20.4 | 30.7 | 0.7x | 5x | yes |
| uint8.deserialize | random | 1 | 5000000 | 16.4 | 79.6 | 0.2x | 5x | yes |
| uint8.deserialize | saturated | 1 | 5000000 | 17.6 | 75.4 | 0.2x | 5x | yes |
| uint8.deserialize | zero | 1 | 5000000 | 18.4 | 77.6 | 0.2x | 5x | yes |
| uint8.hash_tree_root | random | 1 | 5000000 | 14.8 | 498.0 | 0.0x | 10x | yes |
| uint8.hash_tree_root | saturated | 1 | 5000000 | 13.6 | 502.9 | 0.0x | 10x | yes |
| uint8.hash_tree_root | zero | 1 | 5000000 | 15.4 | 529.3 | 0.0x | 10x | yes |
| uint8.serialize | random | 1 | 5000000 | 15.0 | 20.8 | 0.7x | 5x | yes |
| uint8.serialize | saturated | 1 | 5000000 | 15.8 | 18.9 | 0.8x | 5x | yes |
| uint8.serialize | zero | 1 | 5000000 | 16.2 | 19.6 | 0.8x | 5x | yes |

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
