# Representation probes (native Bend C backend)

These are measurement probes, **not** part of the SSZ library and not an
alternative API: they exist to answer, with numbers from the pinned Bend 2.0.16
native backend on this machine, what the runtime can and cannot do. Every claim
about representation in MEMORY_REVIEW.md and docs/LAW_API_MAP.md is backed by
one of these.

Build and run each one with the same flags the benchmarks use:

```
/Users/monkeair/.bend/bin/bend benchmarks/probes/<name>.bend -o build/probes/<name>
./build/probes/<name> --threads 1 --gpu off
```

| probe | what it measures | result on Apple M4, Bend 2.0.16 native C, one thread |
|---|---|---|
| `array_get.bend` | 1,048,576 `Array.get` reads by index plus an add each | `MS=0` (under one millisecond, i.e. < 1 ns per indexed read) |
| `list_walk.bend` | walking and summing a 1,048,576-cell `+List<U32>` | `MS=2` (~2 ns per cons cell) |
| `list_to_array.bend` | filling a 2,740,473-slot `Array<U32>` from a byte list of the same length, then scanning it by index | `FILL_MS=4-5`, `SCAN_MS=0` over two runs (~1.6-1.8 ns per byte to convert, < 0.4 ns per byte to scan) |
| `record_alloc.bend` | building 200,000 two-field records and folding them | `BUILD_MS=1`, `FOLD_MS=0` (~5 ns per record) |
| `array_share.bend` | whether `Array<T>` can be marked `+` (duplicable) | **does not compile**: `expected: Data, observed: Type` |

Scale reference: the mainnet Fulu `BeaconState` fixtures are 2,738,771 -
2,741,095 bytes, Go fastssz decodes one in 0.35 ms, and the 5x limit for
`BeaconState.deserialize` is therefore 1.75 ms.

Two conclusions follow directly, and both are load-bearing for the architecture:

1. Indexed access over a native `Array` is essentially free relative to the
   contract (a full 2.74 MB indexed scan costs under a millisecond, inside the
   1.75 ms budget), while the current chunk-list representation decodes the same
   fixture in 24-27 ms. The representation, not the runtime, is what costs.
2. `Array<T>` has kind `Type`, not `Data`, so it cannot be duplicated: a decoder
   cannot hold a shared array view in two cursors. An array-backed decoder must
   thread the buffer linearly and address it by index, returning the buffer with
   every result. That is a different decoder and a different proof development
   from the slice-based one now in `src/`, not a drop-in substitution.
