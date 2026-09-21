> **Development milestone:** final memory-repair conformance rerun passed; packed-runtime migration and native speed gates remain incomplete. See [snapshot evidence](SNAPSHOT_STATUS.md).

# bend-ssz

Pure Bend SSZ for all **109 pinned mainnet Fulu names**, with serialization,
deserialization, exact rejection, hash-tree-root and typed adapters. Includes the
user's pinned Bend SHA-256 implementation and its functional proofs.

**Reviewed research library.** Public refinement proofs are checked against
independent Bend specifications. The compiler, runtime and host machinery are
outside those proofs; root totality is conditional on the documented root domain.
Read [the detailed review](REVIEW.md) before interpreting “formally verified.”
The current codec is not performance-competitive with fastssz on BeaconState.
This private snapshot is published with that limitation and the root-domain
qualification intact; correction and sequential-deserialization research run separately.

## Proven properties

| API / obligation | Guarantee |
|---|---|
| Serialization | Exact independent canonical encoding for legal types; illegal types reject |
| Deserialization | Accepts exactly canonical encodings and returns exactly their values |
| Rejection / uniqueness | Rejects exactly outside the legal canonical image; encodings are injective |
| Hash-tree-root | Exact independent root relation; successful results are 32 byte-range bytes |
| Root totality | Root exists for serializable values with uint256-representable mixed lengths |
| Fulu names | Typed composition for every constructor of the closed 109-name index |
| SHA-256 | Actual byte API equals the independent vendored FIPS model and returns 32 bytes |

Proof roots: [END_TO_END.bend](END_TO_END.bend), [PROOF.bend](PROOF.bend),
[HASH_PROOF.bend](HASH_PROOF.bend). See [PROOF_STATUS.md](PROOF_STATUS.md) for the
current obligation table; historical notes below it are not the current status.

> **Status of this working copy.** The decoder is a compact cursor decoder over
> packed storage. Both halves are now written and checked: `bend PROOF.bend`
> and `bend END_TO_END.bend` report "All terms check." with zero unsafe
> annotations, and the frozen gate `automation/root_domain_acceptance.py`
> (proofs + 51 runtime tests + all 5440 official SSZ cases + `END_TO_END.bend`)
> exits 0 on this copy. Checking `PROOF.bend` costs 5.1-5.7 GB of physical
> footprint (it varies between runs) and about 50 s; the measurement method, the per-module numbers and the
> two normalization blow-ups that were repaired are recorded in
> [WORK_LOG.md](WORK_LOG.md) (`PROOF_STATUS.md` is frozen for this iteration
> and its "Current state" section predates these runs).
> Native memory results are in [MEMORY_REVIEW.md](MEMORY_REVIEW.md) and native
> performance against Go fastssz in [BENCHMARKS.md](BENCHMARKS.md); the
> performance contract is **not** met and that document says so.
>
> The runtime still stores input as a linked chunk list and sequence children
> as a cons spine. Measurements of the pinned runtime (see
> [docs/LAW_API_MAP.md](docs/LAW_API_MAP.md) and `benchmarks/probes/`) show that
> an array-backed, index-addressed representation is what the remaining speed
> and memory depend on, and that `Array` in Bend 2.0.16 is linear, so that
> migration is a different decoder and a different proof development. It is
> designed and justified there, and not implemented.

## Evidence

The preserved Bend 2.0.16 worker acceptance passed **5,440 official SSZ cases**
(295 mainnet Fulu static + 5,145 generic), **51 runtime tests / 20,009 assertions**,
and both proof roots with zero unsafe annotations. The publication review verifies
source attribution and records fresh checks in [CHECKS.json](CHECKS.json).

An independent static AST comparison matches all 109 schemas to the vendored
Python reference; all 59 container field lists also match. This is finite
transcription evidence, not a formal proof of the Ethereum prose or Python parser.
The recovery workflow independently reran acceptance (exit 0), obtained auditor
approval and was marked complete. Two low-severity evidence-label findings and this
review's broader scope qualifications are retained in [REVIEW.md](REVIEW.md).

## Layout

- `src/`: generic codec, decoder, roots and supporting runtime functions.
- `types/`: neutral representations and concrete named Fulu APIs.
- `spec/`: independent semantics and schema constants.
- `proofs/`: checked refinements and composition lemmas.
- `vendor/`: pinned consensus reference and Bend SHA dependency.
- `fixtures/`, `cases.json`, `fixtures.manifest.json`: every selected official input.
- `tests/`, `tools/`, `automation/`: runtime transport, generators and frozen gates.
- `evidence/review-20260919/`: review checks, source manifests and logs.

## Reproduce

Use the exact **Bend 2.0.16** binary/Base hashes in
`automation/toolchain.json`, Bun 1.4.2, and Python 3.12 with `requirements.txt`.
The earlier 2.0.5 entry in `upstream.lock.json` records historical provenance.

```sh
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
mkdir -p build
bend PROOF.bend
bend END_TO_END.bend
.venv/bin/python tools/run_runtime_tests.py tests/sha256.test.ts tests/new/*.test.ts
.venv/bin/python tests/new/test_transport.py
.venv/bin/python tests/new/test_run_evidence.py
.venv/bin/python automation/acceptance.py
```

The preserved harness uses absolute Bend/Bun paths from the original machine.
On another machine, update those paths in `automation/toolchain.json`,
`automation/acceptance.py`, `tools/run_runtime_tests.py`, `tools/spectests.py` and
`tools/probe_backend.py`, keeping binary/Base hashes unchanged. Path changes
produce a new harness provenance; rerun validation and record it. The examples
above do not install Bend or Bun. A full official gate can take 40–50 minutes or
longer under contention.

Public calls are `src/ssz.{serialize,deserialize,hash_tree_root}` for neutral
schemas/values and `types/fulu.BeaconState.{serialize,deserialize,hash_tree_root}`
(and analogous names) for typed values. Codecs return `Maybe`: `None` is semantic
rejection. Process crashes, memory exhaustion or timeouts are not rejection.
Raw typed constructors do not enforce every length/bound at construction time.

This repository covers SSZ only, not consensus transitions, BLS/KZG verification,
production resource safety, or compiler correctness. Historical development notes
are retained in [docs/HISTORICAL_README.md](docs/HISTORICAL_README.md).

## Benchmarks

[BeaconState results and runner](benchmarks/README.md) compare all five official
Fulu fixtures with fastssz. Select a fixture with `--case case_0` or use `--case all`.
Timings measure each library's native public APIs; setup is excluded. The separate
Opus-5 research run targets sequential deserialization while retaining full checks.
