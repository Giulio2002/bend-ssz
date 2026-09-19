# Fulu BeaconState SSZ benchmark

Named public APIs. Native input representations prebuilt. Correctness verifies exact serialized bytes and official root before timing. Fresh allocating deserialization/serialization; no cached Merkle tree. Compilation, disk IO and host representation conversion excluded. One untimed warmup per operation after correctness. Go: >=300ms per sample, single GOMAXPROCS; Bend: one operation per sample with --smol. GC enabled; no forced GC. Other workflows remain running: exploratory, shared-machine results.

| Fixture | Bytes | Operation | fastssz ms | Bend ms | Bend / fastssz |
|---|---:|---|---:|---:|---:|
| case_0 | 2740473 | deserialize | 0.186 | 6668.344 | 35819.7× |
| case_0 | 2740473 | serialize | 0.187 | 3118.166 | 16660.9× |
| case_0 | 2740473 | hash_tree_root | 8.233 | 8573.346 | 1041.4× |
| case_1 | 2740934 | deserialize | 0.270 | 5717.520 | 21173.5× |
| case_1 | 2740934 | serialize | 0.226 | 2707.652 | 11989.5× |
| case_1 | 2740934 | hash_tree_root | 8.232 | 10778.436 | 1309.4× |
| case_2 | 2741095 | deserialize | 0.226 | 8388.636 | 37089.5× |
| case_2 | 2741095 | serialize | 0.217 | 6982.268 | 32145.8× |
| case_2 | 2741095 | hash_tree_root | 8.227 | 15831.073 | 1924.4× |
| case_3 | 2739794 | deserialize | 0.414 | 8621.913 | 20843.2× |
| case_3 | 2739794 | serialize | 0.405 | 5603.694 | 13828.0× |
| case_3 | 2739794 | hash_tree_root | 12.950 | 27942.159 | 2157.7× |
| case_4 | 2738771 | deserialize | 0.380 | 6243.223 | 16440.2× |
| case_4 | 2738771 | serialize | 0.431 | 2004.245 | 4652.7× |
| case_4 | 2738771 | hash_tree_root | 15.066 | 7663.140 | 508.6× |
