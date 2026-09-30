# Regenerate and check

## Regenerate

    python3 codegen/regen_all.py            # write mode
    python3 codegen/regen_all.py --check    # stale check (CI)

`regen_all.py` (`--list` shows the order, `--only a,b` a subset, `-j N` parallelism) runs `codegen/generate.py`
first, then every law generator in import order, then `api_gate.py`, `api_facade.py` and
`e2e_bridge.py`, and repeats until a pass writes nothing (the facades and gates record their
imports, so one law change can take two passes). `--check` runs every generator's `--check`
and fails on any stale file. Requirements: Python 3.12 with `requirements.txt`.

The early proof layer (`proofs/*.bend`: compatibility, identity, root relation, codec and bit
packing proofs), a few `spec/` and `types/` files and benchmark scaffolding were written by the 68
`tools/generate_*.py`. `codegen/tool_generators.py --check` (one of the generators `regen_all.py
--check` runs) reruns the 62 reproducible ones in a scratch copy of the tree and fails if any
writes nothing, exits nonzero, or writes a file that differs from the committed one. The other
six are listed in its `ONE_SHOT` table with the reason: a Markdown renderer that needs a benchmark
report, a one-time import from a bend-collections snapshot, the Go reference types (need
`gofmt`), a macOS memory measurement, a candidate writer into `build/`, and a schema reader that
writes nothing.

## Check

Every `.bend` file outside `tools/` and `vendor/` must check. There is one full check:

    tools/check_fast.sh [--jobs 20] [--target S] [--out DIR] [--files LIST]  # all files; logs under build/check_fast
    tools/check.sh <file.bend>                                                # one file

Bend has no module cache: checking a file checks every definition of every module in its import
closure (`book_valid` walks the whole book), so checking the ~5,300 files one by one re-checks the
shared modules (`src/`, `spec/`, `END_TO_END.bend`, the big encoder interfaces) thousands of times
(about 58,000 CPU seconds). `check_fast.sh` instead groups the root files (those no other file
imports; their closures cover every file, which `tools/umbrellas.py` asserts) by shared imports into
umbrellas: files that only import them, so one run of an umbrella checks each module of its closure
once. The recorded run (`benchmarks/evidence/check_fast.json`, commit <!-- fig:check_commit -->2da67db8<!-- /fig -->):
<!-- fig:check_umbrellas -->40<!-- /fig --> umbrellas over <!-- fig:check_files -->5,686<!-- /fig --> files,
<!-- fig:check_cpu -->3,399<!-- /fig --> CPU seconds, <!-- fig:check_wall -->5.9<!-- /fig --> minutes wall at 20 jobs on
the ssz server, the slowest umbrella <!-- fig:check_slowest -->334<!-- /fig --> s. A
failure in any imported definition, or an open law, fails the umbrella exactly as it fails the file.

Failures are localized automatically: each failed umbrella is bisected into import-only halves
until single root files remain, and the script prints each failing root with its log and the
definition the checker names (`DIR/failed.tsv`; `--no-localize` skips this). One difference from
checking a file directly: an umbrella checks every file as an import, never as the top-level file,
and Bend resolves some qualified constructor and alias names differently at the top level: the
`types/fulu*.bend` files check only as imports. They import `../types/primitive.bend` from inside
`types/`; as the entry file, the checker (and the runtime compiler) resolves their qualified
constructor patterns (`case T.U8{}`) against the namespace `../types/primitive` and reports "a
declared constructor (unknown: ../types/primitive.U8)" (seen with the runtime compiler on
2026-09-30). Imported by other files, as in the full check, they check. Some of these files
(`types/fulu_model.bend`, `types/schema.bend`) are frozen, so their import paths are left as
they are. `--files LIST` checks only the listed files and
their imports.

`tools/check_costs.tsv` holds per-file check times (file, exit, ok, seconds, peak MB) measured once
with the pinned checker; `umbrellas.py` uses them only to balance the partition, never for coverage.

`check.sh` runs `bun <bend-src>/bend2/main.ts <file> --check-only` with the checker pinned in
`toolchain.lock.json` (Bend 2.0.28 + the branch of bendlang/bend#1075, closed unmerged, at 3ddfb036: see
[TRUST.md](TRUST.md); found through `BEND_TOOLCHAIN`,
default the ssz server's `/srv/ssz-optimization/toolchain-2.0.28`) and the SHA-256 package
(`BEND_LIB`, default the vendored `vendor/bendhub`), and prints `All terms check.` and a final
`CHECK_TIME <seconds> <peak KB>` line. Before any run, `tools/verify_pins.py` compares the
checker's files, Bun and the package with the lock's sha256s and refuses a mismatch (exit 3).
`check_fast.sh` also runs `tools/verify_frozen.py` first: the spec, the four roots' statements, and
the bridge statements with the definitions they reach (in `src/` and `types/` too, except the
implementation under test) must match `frozen.lock.json`. A deliberate
statement change is recorded with `python3 tools/verify_frozen.py --update` in the same commit. It
then runs `tools/verify_no_escapes.py`, and at the end writes `DIR/stamp.json`
(`tools/check_stamp.py`: commit, checker commit, the sha256 of both locks, of every checked
`.bend` file, of each harness script and of the umbrella plan, every planned umbrella's result and
the totals). A full run (no `--files`) also writes it to `benchmarks/evidence/check_fast.json`,
which is committed after each full check on the server. The run fails if any umbrella fails *or*
if any planned umbrella has no result row (a run that died without a verdict); the stamp then
says `FAILED` and lists the missing umbrellas. `python3 tools/check_stamp.py verify
benchmarks/evidence/check_fast.json` recomputes the source, harness and lock hashes and exits 0
only if they equal the stamp's and its verdict is `all files check`, i.e. the tree in hand is
the one that was checked. Each check runs under the limits it was measured with:

| Limit | Value |
|---|---|
| memory | 12 GB (hard; `MemoryMax`), no swap |
| CPU | 2 cores, `nice 10` |
| wall time | 600 s |
| parallel checks | 10 |

Umbrellas get a larger heap (`UMB_MEMMAX`, default 16 GB; `UMB_TIMEOUT`, default 1200 s).
Target per file: 60 s and 8 GB (e2e files 45 s).

## Tests

Besides the proofs, the runtime has a small set of Bun tests of the compiled Bend modules and one
Python unit test:

    BUN=<bun> BEND_RUNTIME=<pinned runtime bend> python3 tools/run_runtime_tests.py   # tests/*.test.ts (on the ssz server)
    python3 -m unittest tests/test_run_evidence.py                                    # the evidence archive helper

`tests/sha256.test.ts` compares `src/sha256.bend` with Node's SHA-256 at the padding and chunk
boundaries; `tests/layout.test.ts` checks `src/layout.bend` against `spec/layout_decoding.bend`.
`run_runtime_tests.py` compiles each imported module with the runtime compiler pinned in
`benchmarks/toolchain.json` (`BEND_RUNTIME` names it where it is not at the lock's path; on the
ssz server `/srv/ssz-optimization/toolchain-2.0.28/bend/bin/bend`) and fails on any failure,
compile error or empty run; with no arguments it runs every `tests/**/*.test.ts`. Last run
2026-09-30 on the ssz server: 3/3 tests, 2,694 assertions. The thirteen older Bun tests of the
list-model layer (`tests/new/`, with their helpers `tools/primitive_backend.ts` and
`tools/generic_transport.ts`) were removed on 2026-09-30: each imported `types/fulu*.bend`,
which the runtime compiler cannot compile as an entry (above), so none of them had run since the
object API replaced that layer. `tests/new/test_transport.py` tested the JSON transport of the
former JS spectest runner, which `tools/spectests.py` no longer has, and `tools/probe_backend.py`
imported names `tools/spectests.py` no longer defines; both were removed too. The object API is
tested by the official vectors and the evidence in [RESULTS.md](RESULTS.md).
