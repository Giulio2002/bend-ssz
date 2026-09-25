# bend-ssz

Pure Bend SSZ for all **109 pinned mainnet Fulu names**, with serialization,
deserialization, exact rejection, hash-tree-root and typed adapters. SHA-256 and its
functional proofs come from the bend-collections library (BendHub package
`0xe4067e0d858024083f36a7abe7281e89`).

**Reviewed research library.** Public refinement proofs are checked against
independent Bend specifications. The compiler, runtime and host machinery are
outside those proofs; root totality is conditional on the documented root domain.
Read [the detailed review](REVIEW.md) before interpreting "formally verified."

**Current status (2026-09-25, Linux x86_64 host, stock Bend 2.0.25).**
- The frozen performance gate passes on the current sources: 978 workloads and
  327 operations, each within its limit (worst root 7.65x of 10x, worst codec
  2.99x of 5x).
- The native decode-memory run passes: 15/15 samples verified, worst Bend
  decode overhead 5,779,456 B against 32,000,000 B; Go's worst is 3,112,960 B.
- All 5,440 official SSZ cases pass through the generated object API. The 51
  runtime tests and the conformance, mutation, negative-API, cache,
  invalid-object and fresh-seed fuzz checks all pass
  (build/final_runtime).
- The proof picture is in docs/LAW_API_MAP.md and the WORK_LOG iteration-23
  table. Checked: root laws for 104 names (root_names 75, leaf_small 4,
  root_types 25) plus 123 of 136 generic forms, the cached root under
  arbitrary valid write/append histories, and producer laws for the
  representation invariants. Still open: BeaconState's root law, and the 5
  root_big names (Transaction, ExecutionPayload, BeaconBlockBody, BeaconBlock,
  SignedBeaconBlock), whose closed 2^30 limit fact the checker must evaluate in
  unary (being checked in the final sweep), codec total correctness beyond 83 names, and the
  migration of the END_TO_END/ROOT_DOMAIN propositions to the object API.
- `automation/native_memory_acceptance.py` still stops at its 2.0.16
  toolchain pin; docs/TOOLCHAIN.md gives the hash-only update.

## Public API: the generated typed owning objects

The SSZ implementation is **generated from a schema** (`codegen/fulu.yaml` for
the 109 mainnet Fulu names, the frozen official generic descriptions for the
supported generic SSZ forms). See [docs/CODEGEN.md](docs/CODEGEN.md) for the
inputs, the outputs and the reproducible regeneration command.

For every name `X` the generated API in `types/fulu_obj.bend` is

| Operation | Signature |
|---|---|
| deserialize | `X_decode(buf: B.Buf, size: U32) -> B.Buf & Maybe<X>` |
| serialize | `X_encode(o: X) -> X & B.Buf` (fresh canonical bytes) |
| hash_tree_root | `X_hash_tree_root(h: B.Buf, o: X) -> B.Buf & (X & D.Digest)` |
| field read / write | `X_get_<field>`, `X_set_<field>` |
| element read / write | `<coll>_at`, `<coll>_set` |
| list append | `<coll>_append` (rejects past the declared limit) |

`X` is a typed owning record: one field per SSZ field, `U32`/`O.U64` scalars,
packed `Array<U32>` storage for byte, bit and packed sequences, and an
array-backed sequence of element objects for sequences of composites. There is
no linked list anywhere on this path. Decoding **copies** out of the input
buffer, so the decoded object is independent of the caller's input: changing a
retained copy of the input cannot change the object. Updates consume and
return the object under Bend's affine rules; vectors offer element
replacement and no length-changing operation at all.

The same generated code serves the generic SSZ forms in
`types/generic_obj.bend`: progressive lists, progressive bit lists,
progressive containers and compatible unions, plus containers, vectors and
lists over every basic type.

`src/model.bend` (re-exported by `src/ssz.bend`) is the **list-based model**,
not a production path: it is the subject of the frozen `END_TO_END`
propositions and the transport the official cases run through under Bun. The
compact *view* codec that was the primary API before the object API existed
has been removed.

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

**These universal laws are about the list-based model API, not about the
generated object codec.** Proof roots: [END_TO_END.bend](END_TO_END.bend),
[PROOF.bend](PROOF.bend), [HASH_PROOF.bend](HASH_PROOF.bend). The generated
path carries checked mutation, collection, cache and cost laws
(`proofs/obj/*.bend`, generated by `codegen/laws.py`) and a universal checked
soundness proof of the compact window scanner (`proofs/compact/sound.bend`),
but **no universal codec-correctness law for the generated validator and
reader yet**; that is the largest open obligation and is described in
[docs/COMPACT_PROOF_PLAN.md](docs/COMPACT_PROOF_PLAN.md) and WORK_LOG.md. What
the generated path does have is native evidence, listed next.

## Native evidence for the generated object API

All **5,440 official SSZ cases** run through the generated object API as native
Bend-compiled C:

* 295 `ssz_static` mainnet Fulu cases: decode, re-encode byte for byte, and the
  exact 32-byte `roots.yaml` root
  (`benchmarks/evidence/object_conformance.json`);
* 5,145 `ssz_generic` cases: 2,708 valid ones decode, re-encode byte for byte
  and give the exact `meta.yaml` root; 2,437 invalid ones are rejected
  (`benchmarks/evidence/generic_object_conformance.json`);
* 5,455 mutated inputs agree with an independent Python validator, with no
  disagreement (`benchmarks/evidence/object_mutations.json`).

JS/Bun compatibility evidence, reported separately and never as native
coverage: the 51 runtime tests (20,009 assertions) and the 5,440 official cases
through `tools/spectests.py` on the list model.

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

The current toolchain is stock **Bend 2.0.28** (updated 2026-09-25;
binary and Base hashes, the Linux host's clang for native builds, and the
protected `automation/toolchain.json` pin that still names 2.0.16 are in
[docs/TOOLCHAIN.md](docs/TOOLCHAIN.md); the editable pin is
`benchmarks/toolchain.json`). Bun 1.4.2, and Python 3.12 with `requirements.txt`.
The 2.0.16 evidence described above is historical.
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

### Generated programs and checks

| Program | Purpose |
|---|---|
| `benchmarks/objprog/g<k>.bend` | the measured Fulu object programs (twelve names each), used by `benchmarks/run.py` and `benchmarks/checks/object_conformance.py` |
| `benchmarks/objprog/x<k>.bend` | the generic-form object programs, used by `benchmarks/checks/generic_object_conformance.py` |
| `benchmarks/objprog/f<k>.bend` | the mutation/fuzz drivers, used by `tests_generated/fuzz_objects.py` |
| `native_bench/driver.bend` | the native decode-memory harness |

Schemas at run time are the generated records themselves; there is no schema
tree walked during decode, encode or root. `None` from a decode is semantic
rejection; crashes, memory exhaustion and timeouts are not.

`src/cscan.bend`, `src/cschema.bend`, `src/ccompile.bend` and their compact
schema tables are retained as **proof-carrying reference code**: they are the
subject of the universal soundness proof in `proofs/compact/sound.bend` and are
on no measured or production path. They are not deleted because deleting them
would delete checked proof coverage with nothing yet to replace it.

This repository covers SSZ only, not consensus transitions, BLS/KZG verification,
production resource safety, or compiler correctness. Historical development notes
are retained in [docs/HISTORICAL_README.md](docs/HISTORICAL_README.md).

## Benchmarks

[BENCHMARKS.md](BENCHMARKS.md) is the native contract measurement:
`benchmarks/run.py` compares the generated typed object API's decode (bytes to
a fully constructed object), encode (object to fresh bytes) and hash_tree_root
with Go fastssz for all 109 Fulu types, per workload. The gate is
`automation/performance_gate.py`. Native decode memory against Go is in
[MEMORY_REVIEW.md](MEMORY_REVIEW.md) (`native_bench/run.py`, gate
`automation/native_memory_acceptance.py`): worst Bend decode overhead
5,914,624 bytes over 15 verified samples, against a 32,000,000-byte limit
(Go fastssz worst 3,637,248 bytes on the same five fixtures). The older BeaconState-only
runner is described in [benchmarks/README.md](benchmarks/README.md).
