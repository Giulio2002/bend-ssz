# SSZ work-in-progress snapshot

Captured from iteration 17 while its worker continued running. This publication
does not assert final acceptance or rerun the expensive validation gates.

Included: YAML-driven owning object codecs, mutations/appends and Merkle caches,
generated codec proof modules, runtime performance work, and retained evidence.
The documented codec-law subset covers 67/109 Fulu names and five generic
schemas. Full variable-size/sub-word codec correctness, comprehensive rejection,
and correspondence with the retained model-level laws remain unfinished.

The retained full performance report dated 2026-09-22T10:04:11Z has
978 workloads: 1 decode and 15 encode workloads exceed 5x Go; all hashing
workloads meet 10x. A later per-name timing experiment was rejected because
zero-time decode indicated elided work; do not treat it as acceptance.

Archived report hashes do **not** all match this snapshot. See SNAPSHOT.json for the exact mismatches; those benchmark numbers are historical evidence, not certification of these sources.

The worker reported passing official cases, memory checks and proof modules.
Those results and their scope must be read with docs/LAW_API_MAP.md; passing
PROOF.bend does not itself prove the generated production codecs end to end.
