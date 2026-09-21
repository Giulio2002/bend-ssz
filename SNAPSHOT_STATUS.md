## Latest: compact-path static conformance

The compact native API produced exact 32-byte expected roots for all 295 official
ssz_static cases covering 59 Fulu types (roots.yaml is the independent reference).
1180 modified inputs agreed with a separately written Python validity checker:
637 invalid and 543 valid. That checker shares schema parsing/size helpers with
the generator; it is not a wholly independent schema implementation. Reports and
scripts are preserved in snapshot-evidence/compact-static/. They are development
run evidence without a full per-run source fingerprint, not an independent audit
of this exact commit.

The compact path does NOT yet pass the entire 5440-case suite and still lacks
its universal runtime refinement proofs and required packed-SHA/FIPS bridge.
The ongoing performance log is partial. BeaconState hashing rows are about
33.5ms Bend versus 6.7ms Go; broader speed acceptance is pending. Decode remains
a validated buffer view vs Go materialization; do not interpret that timing as
equivalent materializing deserialization. Read the benchmark method for each API.

## Latest milestone: compact native buffer-view memory experiment

All 15 Bend samples across five ~2.74 MB BeaconState fixtures completed with
byte-for-byte round-trip output matches. Maximum measured decode overhead above
the input baseline: 229376 bytes (target 32000000). Raw report and log are in
snapshot-evidence/compact-native-memory.*.

THIS NEW PATH IS NOT YET FULLY PROVED OR ACCEPTED. Earlier proof and spectest
reports apply to earlier implementations and cannot certify this compact API.
This run has no complete source fingerprint; it was captured during development.

The decoded Bend result is a validated packed-buffer view. Go unmarshals a typed
struct and folds its fields; Bend's decode checksum here is only the byte length.
These are different amounts of downstream work, so decode timings do not establish
the <=5x speed gate. Bend serialization streams existing validated bytes to disk;
Go serializes its object, so those timings also need a comparable benchmark.
Root checksums are a diagnostic, not full digest-equality proof. Formal bridges,
full conformance/rejection checks and equal-work speed acceptance remain required.
The new SHA dependency is pinned through BendHub; its documented proof boundary
must remain explicit and required missing bridges must be completed.

---

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

## Fresh compatibility validation

On 2026-09-20 at 22:02 UTC the official suite passed **5440/5440 cases**,
with 159 backend batches and 11446 requests. Runtime tests passed **51/51**,
with 20009 assertions. END_TO_END also checked at the end of this run.
This suite uses the compatibility runtime through the Bend-to-JavaScript loader;
it is not evidence that the optimized native-C path meets its speed target.
Raw reports and the acceptance log are in `snapshot-evidence/`.

Source hashes in the spectest report compared with this export: 0 mismatches.
See `SNAPSHOT.json` for the exact list. These checks do not replace semantic audit.

## Complete proof-memory sweep — 2026-09-20 23:37 UTC

All **172 checks** in the sequential sweep completed successfully, including
individual proof modules and public entry points. Largest recorded physical
footprint was about **6.20 GB**, below the 8 GB user ceiling. The final PROOF
check recorded about 5.73 GB. This supersedes the earlier partial sweep counts;
it does not establish native performance acceptance or replace semantic audit.
The sampled footprint is not a kernel-enforced memory bound on macOS.
Raw current-sweep results/logs are in `snapshot-evidence/proof-memory-sweep*`;
historical failed scratch probes are excluded from this successful-sweep report.
These measurements do not include a complete source fingerprint for each check.

## Fresh native-memory gate — 2026-09-20 22:47 UTC

The native-memory gate passed after fresh proof/conformance prerequisites.
All 15 Bend samples decode with <=32,000,000 bytes overhead; the worst was
12,976,128 bytes. Five roughly 2.74 MB BeaconState spec fixtures, three samples
per implementation, native Bend-generated C versus Go fastssz on Apple M4.
These small spec states are not evidence for production validator populations.
Raw methodology and samples: `snapshot-evidence/native-memory-comparison.json`.
Decode timing includes the forcing checksum fold, as documented by the harness.

| Phase | Bend median range across fixtures | Go median range | Ratio range |
|---|---:|---:|---:|
| Decode + forcing fold | 18–20 ms | 1.276–1.430 ms | 13.84–14.89x |
| Hash-tree-root | 609–621 ms | 7.568–7.737 ms | 78.72–81.86x |
| Serialize | 349–367 ms | 0.282–0.331 ms | 1068–1283x |

These are native-memory harness phase measurements, not completed acceptance of
the complete performance workload suite. They expose remaining speed gaps,
especially serialization. This report does not carry a complete source hash
manifest; do not claim exact-commit benchmark certification from it. Source at
export is separately recorded. No speed gate or independent semantic audit passed.

## Runtime benchmarks and remaining work

`BENCHMARKS.md` and `benchmarks/evidence/native-comparison.json` retain the
available historical performance/memory measurements. The previous full suite
had only 5/978 workloads within its speed limits; this snapshot does NOT claim
a speedup or a fresh performance pass. Native BeaconState decode overhead was
about 12.9 MB in prior samples; proof-checking memory is a separate measurement.

Complete the indexed-array runtime migration, compact encode/streaming root,
all 109 Fulu mainnet types, native-path validation, native decode
overhead <=32,000,000 bytes, encode/decode <=5x fastssz and root <=10x, and an
independent semantic review. Preserve every required public law and its actual
runtime connection. Older status/validation documents may describe earlier code.
Fixtures remain governed by fixtures.manifest.json and upstream.lock.json;
large regenerated fixture caches are not added by this snapshot.

## Final memory-repair conformance rerun — 2026-09-21

This snapshot captures the preserved iteration-2 workspace, including the repaired
proof generators and validator dependency reduction. The final acceptance log
records 5440 official cases passed, zero failed, and END_TO_END all terms check.
The worker also recorded 51 runtime tests / 20009 assertions passed.
The later iteration-3+ packed-hasher and BendHub migration is still in progress
and is deliberately not represented as validated by these results.
The runner's failed structured response was a transport failure; it does not
constitute an audit approval. Full native speed acceptance remains incomplete.
