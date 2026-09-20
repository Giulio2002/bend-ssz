# SSZ development snapshot

This is a progress snapshot, not completed native SSZ optimization or independent
final acceptance. It preserves the existing repository history.

## Substantial milestone: proof checking below 8 GB

The memory refactor factored repeated validator cases, packed-byte proofs,
generated adapter expressions and the root-domain witness. The three roots
recorded successful checks with zero unsafe annotations in their output:

| Proof entry | Recorded result | Wall time | Peak physical footprint |
|---|---|---:|---:|
| `PROOF.bend` | pass | 49.32 s | 5.13 GB |
| `END_TO_END.bend` | pass | 52.89 s | 5.37 GB |
| `ROOT_DOMAIN.bend` | pass | 54.49 s | 5.24 GB |

Raw checker logs and sampled traces are in `snapshot-evidence/`. These results
were produced in the active workspace shortly before export; they are not a new
independent audit of this exact commit. Earlier interrupted checks reached
13.6–20.5 GB each. The measurement wrapper now captures output in files to avoid
pipe deadlocks, records the actual exit status, and stops before 8 GB.

## Runtime benchmarks and remaining work

`BENCHMARKS.md` and `benchmarks/evidence/native-comparison.json` retain the
available historical performance/memory measurements. The previous full suite
had only 5/978 workloads within its speed limits; this snapshot does NOT claim
a speedup or a fresh performance pass. Native BeaconState decode overhead was
about 12.9 MB in prior samples; proof-checking memory is a separate measurement.

Complete the indexed-array runtime migration, compact encode/streaming root,
all 109 Fulu mainnet types, fresh runtime/spectest validation, native decode
overhead <=32,000,000 bytes, encode/decode <=5x fastssz and root <=10x, and an
independent semantic review. Preserve every required public law and its actual
runtime connection. Older status/validation documents may describe earlier code.
Fixtures remain governed by fixtures.manifest.json and upstream.lock.json;
large regenerated fixture caches are not added by this snapshot.
