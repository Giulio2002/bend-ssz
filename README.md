> **Unfinished development snapshot:** compact runtime has finite tests and native memory evidence, but universal runtime proofs and full performance acceptance remain incomplete. See [snapshot status](SNAPSHOT_STATUS.md).

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

> **Status of this working copy (2026-09-21).** The primary runtime is now the
> **compact path**: one packed `Array<U32>` input buffer, an in-place validating
> decode whose result is a zero-copy view, field/element access on views,
> encode to a fresh packed buffer, and streaming `hash_tree_root` over the same
> buffer through the pinned BendHub SHA-256 package
> (`0xda83506fb9f059ead7afcfa2f498df5f/sha256.bend`). See "Public API" below.
> Checked so far: all 295 official `ssz_static` cases (59 Fulu types) produce
> the exact 32-byte root through it, 1,180 malformed variants agree with an
> independent validator, all five BeaconState fixtures round-trip byte for
> byte, and 49 field-access values match an independent reader. The native
> BeaconState decode overhead is at most 180 KB against the 32,000,000-byte
> limit ([MEMORY_REVIEW.md](MEMORY_REVIEW.md)).
>
> **Not yet done**, and not claimed: no proof covers the compact modules
> (`src/buffer`, `cschema`, `cscan`, `merkle_fast`, `croot`, `digest`, `api`,
> `access`), nor the packed-input → FIPS SHA bridge. The `ssz_generic` half of
> the official corpus (progressive lists and containers, compatible unions and
> the generic test schemas) does not yet run through the compact API. The
> native performance contract is not established (BENCHMARKS.md). The
> "Proven properties" table above, the proof roots and the 5,440-case evidence
> below are about the **legacy list-based API** (`src/ssz`, `src/packed`,
> `src/cvalue`, …). That API is kept only because those proofs are about it;
> the operator's instruction is to remove it from the production surface once
> the compact path carries the proofs.

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
| `API.run(0, schema, size, buf)` | decode: `Out{ok, _}`; `ok` says whether `[0, size)` is a canonical encoding of `schema`, and the validated window is the decoded value |
| `API.run(1, schema, size, buf)` | `hash_tree_root` of a validated window: `Out{True, digest}` |
| `A.field(schema, i, view, buf)`, `A.field_schema(schema, i)` | view and schema of container field `i` |
| `A.count(schema, view, buf)`, `A.elem(schema, i, view, buf)`, `A.elem_schema(schema)` | element count and element `i` of a vector or list |
| `A.uint64`, `A.boolean`, `A.byte` | scalars read in place |
| `A.encode(view, buf)` | the value's encoding as a fresh packed `Buf` |

Rejection is `ok = False`. Process crashes, memory exhaustion and timeouts are
not rejection. Native drivers: `native_bench/driver.bend` (memory
harness) and `benchmarks/compact/{dec,enc,root}.bend` (performance runner).

The legacy list-based calls (`src/ssz.{serialize,deserialize,hash_tree_root}`,
`types/fulu.*`) still exist for the checked proofs; they are not the primary
API.

This repository covers SSZ only, not consensus transitions, BLS/KZG verification,
production resource safety, or compiler correctness. Historical development notes
are retained in [docs/HISTORICAL_README.md](docs/HISTORICAL_README.md).

## Benchmarks

[BeaconState results and runner](benchmarks/README.md) compare all five official
Fulu fixtures with fastssz. Select a fixture with `--case case_0` or use `--case all`.
Timings measure each library's native public APIs; setup is excluded. The separate
Opus-5 research run targets sequential deserialization while retaining full checks.
