> Development snapshot: all 978 speed workloads and the native memory gate pass, with measurement caveats. Compact-runtime universal proofs remain unfinished; retained model proofs do not prove the new implementation. See [SNAPSHOT_STATUS.md](SNAPSHOT_STATUS.md).

# bend-ssz

Pure Bend SSZ for all **109 pinned mainnet Fulu names**, with serialization,
deserialization, exact rejection, hash-tree-root and typed adapters. Includes the
user's pinned Bend SHA-256 implementation and its functional proofs.

**Research snapshot, not a fully verified release.** The compact packed-buffer
runtime passes the latest development speed and native memory gates. Universal
refinement proofs for that runtime are still being built. The retained recursive
model has checked public laws, but those laws do not establish correctness of the
new compact implementation. Compiler, runtime and host machinery remain outside
the functional proofs. See [current evidence](SNAPSHOT_STATUS.md) and the
[historical review](REVIEW.md) for their respective boundaries.

## Retained recursive-model properties

The following describes the retained model proofs, not completed compact-runtime proofs.

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

> **Status of this working copy (2026-09-21).** The primary runtime is the
> **compact path**: one packed `Array<U32>` input buffer, an in-place validating
> decode whose result is a zero-copy view, field/element access on views,
> encode to a fresh packed buffer, and streaming `hash_tree_root` whose
> intermediate digests live in the buffer's own packed scratch. It hashes
> through the pinned BendHub SHA-256 package
> (`0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend`). See "Public API" below
> and [docs/FASTSSZ_EQUIVALENCE.md](docs/FASTSSZ_EQUIVALENCE.md).
>
> Native evidence (Bend-generated C): **all 5,440 official SSZ cases** pass
> through the compact API. That is 295 `ssz_static` cases (decode accepts,
> exact 32-byte root) and 5,145 `ssz_generic` cases: valid ones decode, give
> the exact root and re-encode byte for byte, invalid ones are rejected.
> Progressive lists, bit lists and containers and compatible unions are
> included. 1,180 malformed variants agree with an independent validator. The
> BeaconState decode overhead is at most a few hundred KB against the
> 32,000,000-byte limit ([MEMORY_REVIEW.md](MEMORY_REVIEW.md)). JS/Bun
> compatibility evidence: the 51 runtime tests pass (20,009 assertions).
>
> **Not yet done**, and not claimed: no checked proof covers the compact
> modules (`src/buffer`, `cschema`, `cscan`, `access`, `croot`,
> `merkle_fast`, `digest`, `api`), nor the packed-input → FIPS SHA bridge; the
> plan is [docs/COMPACT_PROOF_PLAN.md](docs/COMPACT_PROOF_PLAN.md). The
> "Proven properties" table above, the proof roots and the historical evidence
> below are about the **legacy list-based model API** (`src/ssz`
> serialize/deserialize/hash_tree_root, `src/packed`, `src/cvalue`, …), which
> is kept because those proofs are about it. The native performance contract
> is reported in BENCHMARKS.md.

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

### Public API (compact, primary)

`src/api.bend`, `src/access.bend`, schemas in `types/fulu_cschema.bend` (one
definition per Fulu name, generated from `spec/fulu_schemas.bend` by
`tools/generate_cschema.py`; `types/fulu_cschema_index.bend` selects one by
number). Input is a `B.Buf` (`src/buffer.bend`): packed bytes, four per word.
The caller owns the buffer; every operation takes it and gives it back with
its result, and a view stays meaningful for as long as the caller keeps the
buffer.

| call | result |
|---|---|
| `Ssz.decode(schema, size, buf)` / `Ssz.decode_in(schema, off, len, buf)` | `Some(view)` if the window is a canonical encoding of `schema`, else `None` (`API.validate_in` underneath) |
| `Ssz.root(schema, view, buf)` | `hash_tree_root` of a decoded view (`API.root_in`); the buffer's scratch holds every intermediate digest and the zero-subtree table, filled once per buffer |
| `Ssz.encode(view, buf)` | the value's encoding as a fresh packed `Buf` |
| `Ssz.field / field_schema / count / elem / elem_schema` | views and schemas of fields and elements, without copying |
| `Ssz.uint64`, `Ssz.boolean`, `Ssz.byte` | scalars read in place |
| `Fulu.X.compact()`, `X.decode(size, buf)`, `X.encode(view, buf)`, `X.root(view, buf)` | the same for each of the 109 Fulu names (`types/fulu.bend`) |

Schemas are compact `CS` trees: `types/fulu_cschema.bend` for the 109 Fulu
names (generated from `spec/fulu_schemas.bend` by `tools/generate_cschema.py`)
and `types/generic_cschema.bend` for the official generic test schemas
(generated from `tools/test_schemas.py` by
`tools/generate_cschema_generic.py`), each with a balanced by-number index.
`None` is semantic rejection; crashes, memory exhaustion and timeouts are not.

Native programs: `native_bench/driver.bend` (memory harness),
`benchmarks/compact/{dec,enc,root}.bend` (performance runner, Fulu types) and
`g{dec,enc,root}.bend` (generic conformance). The conformance checks are
`benchmarks/checks/{static,generic}_conformance.py` and
`static_mutations.py`.

The legacy list-based calls (`Ssz.serialize/deserialize/hash_tree_root` over
byte lists and `T.Value`, and `types/fulu.*` typed values) still exist for the
checked proofs; they are the model API, not the primary one.

This repository covers SSZ only, not consensus transitions, BLS/KZG verification,
production resource safety, or compiler correctness. Historical development notes
are retained in [docs/HISTORICAL_README.md](docs/HISTORICAL_README.md).

## Benchmarks

[BeaconState results and runner](benchmarks/README.md) compare all five official
Fulu fixtures with fastssz. Select a fixture with `--case case_0` or use `--case all`.
Timings measure each library's native public APIs; setup is excluded. The separate
Opus-5 research run targets sequential deserialization while retaining full checks.
