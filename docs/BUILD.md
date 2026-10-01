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

    tools/check_fast.sh [--jobs 20] [--target S] [--out DIR] [--files LIST] [--tarballs DIR]  # all files; logs under build/check_fast
    tools/check.sh <file.bend>                                                # one file

Bend has no module cache: checking a file checks every definition of every module in its import
closure (`book_valid` walks the whole book), so checking the ~5,300 files one by one re-checks the
shared modules (`src/`, `spec/`, `END_TO_END.bend`, the big encoder interfaces) thousands of times
(about 58,000 CPU seconds). `check_fast.sh` instead groups the root files (those no other file
imports; their closures cover every file, which `tools/umbrellas.py` asserts) by shared imports into
umbrellas: files that only import them, so one run of an umbrella checks each module of its closure
once. The recorded run (`benchmarks/evidence/check_fast.json`, commit <!-- fig:check_commit -->240c3161<!-- /fig -->):
<!-- fig:check_umbrellas -->46<!-- /fig --> umbrellas over <!-- fig:check_files -->6,113<!-- /fig --> files,
<!-- fig:check_cpu -->2,794<!-- /fig --> CPU seconds, <!-- fig:check_wall -->5.9<!-- /fig --> minutes wall at 20 jobs on
the ssz server, the slowest umbrella <!-- fig:check_slowest -->320<!-- /fig --> s. A
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

`check.sh` runs `<toolchain>/bin/bend <file> --check-only` with the checker pinned in
`toolchain.lock.json` (Bend main 01875127, after v2.0.34, plus commits 45663e0a and aa99b746 of the fork
branch Giulio2002/bend `rigid-subterms` (45663e0a was the head of bendlang/bend#1210, closed unmerged;
aa99b746 was never submitted upstream): see
[TRUST.md](TRUST.md); found through `BEND_TOOLCHAIN`, default the ssz server's
`/srv/ssz-optimization/toolchain-rigid-aa99b746`; a source layout, `bun-linux-x64/bun` +
`bend-src/bend2/main.ts`, is also accepted) and the SHA-256 package
(`BEND_LIB`, default the vendored `vendor/bendhub`, BendHub bend-collections@1.0.0.0), and prints
`ALL PROOFS CHECK` and a final
`CHECK_TIME <seconds> <peak KB>` line. Before any run, `tools/verify_pins.py` compares the
checker's files and the package with the lock's sha256s and refuses a mismatch (exit 3).
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
| stack | `ulimit -s 16384` and a JavaScriptCore budget of 10,485,760 bytes (`BUN_JSC_maxPerThreadStackUsage`; JSC's own default is 5 MB) |

The stack is pinned by `tools/check.sh` itself (`CHECK_STACK_KB`, `CHECK_JSC_STACK`), so a shell's or an
environment's limits never change a result. It matters because the checker recurses once per level of a
conversion: a conversion that compares two unary numerals recurses once per unit. It bears on whether a
check finishes, never on what it accepts (an overflow is a failure). JSC stops at the smaller of the two
limits, and JSC caps itself at its budget whatever `ulimit -s` says (a larger `ulimit -s` alone changes nothing; the budget must be raised too). The depth
probe `{U32.to_nat(n) == <n>n}` by `{==}` checks up to n ≈ 14,100 at 2.5 MB, ≈ 28,800 at 5 MB (JSC's default),
≈ 58,600 at the pinned 10 MB, ≈ 114,500 at 20 MB, for the compiled `bin/bend` and for 2.0.28 alike. Near the limit a result can vary from run to run (JIT tiering changes the
frame sizes), so the proofs are written to stay well below it: large literal facts are reached by
evaluating `Nat.is_eq` (the checker's machine loops over a numeral without recursing), literal sums are
written small-first (`Nat.add` recurses on its first argument), and a term that a rewrite must find is
spelled as the code it unfolds from. What the gate is: the full check at the pin (10 MB), which passes, and the
`e2e/vec_uint256_512_e2e_comp_generated.bend` flake test at the pin (40 runs, 8 at a time: 40/40). What is only informational:
the headroom run, a full check at 5 MB (`tools/check_fast.sh --jsc-stack 5242880`, stamp
`benchmarks/evidence/check_fast_jsc5242880.json`). It shows how shallow the proofs are, not that a result is stable: observed history of the 5 MB run: 46 of 46 on f4c3d9ea, 45 of 46 on d73efc07 (umbrella 022, the FuluDataColumnSidecar decoder group, "the machine stack overflowed"); of the 2.5 MB run: 11 of 46 umbrellas fail (000, 007, 014, 016, 019, 020, 021, 022, 024, 038, 045; `benchmarks/evidence/check_fast_jsc2621440_FAILED.log`). The failure rate is not monotone in the budget: that same file overflowed in 9 of 40 runs (8 at a time) at 5 MB
and in 0 of 8 at 2.5 MB, so a passing 5 MB run is one sample of a process that fails some of the time. What gives
reliability is the pin, 10 MB, where the same flake test is 40/40. Each
umbrella log starts with a `CHECK_STACK` line recording the limits it ran under. (The first port branch's "half budget"
runs, `check_fast_jsc2621440.json`, were mislabelled: `check_fast.sh` did not export the budget to the umbrellas, so they
ran at the default 5 MB.)

Umbrellas get a larger heap (`UMB_MEMMAX`, default 16 GB; `UMB_TIMEOUT`, default 1200 s).
Target per file: 60 s and 8 GB (e2e files 45 s).

**No retry on a stack overflow.** An umbrella passes only on exit 0 with the exact line `ALL PROOFS CHECK`; "the machine stack
overflowed" is a failure, never retried. (The 2.0.28 build had a one-time retry for a nondeterministic overflow under load; the
rigid-subterms checker removed the cause instead: conversions are kept shallow in the proofs, `tools/check.sh` pins the stack
(`ulimit -s 16384`, JSC budget 10485760 bytes), and the pin run is the gate; the 5 MB headroom run is informational, see above.)

**The gate run.** `tools/check_fast.sh --tarballs DIR` (or `CHECK_TARBALLS=DIR`) also checks the fixture manifest against the pinned
upstream release archives (`tools/verify_fixtures.py --tarballs DIR`, archives cached in DIR) and records it in the stamp:
`fixtures_tarballs_verified: true`, the tarball and manifest hashes. A run without it (the offline check of the committed
fixtures against `fixtures.manifest.json`) stamps `false`. `tools/strictcheck.sh DIR [TARBALL_DIR]`, run on the server, runs every
generator's `--check` and the same fixture check.

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

## Fast iteration

`tools/iter.sh [--gen a,b] [--base REF] [-j N] [--no-regen] [--cache] [files...]` is the dev loop. It
rsyncs the checkout to a per-user server directory, runs `codegen/regen_all.py --touched` (only the
generators whose traced inputs changed since their last clean run; stamps in `build/regen_stamps.json`),
then checks with `tools/check.sh` only the `.bend` files that changed locally, were rewritten by the
regeneration, or are named, at most `-j` (4) at once, with no localization and no full-check lock. It prints
PASS/FAIL per file with seconds and the failing location, and pulls the regenerated files back.
`--cache` uses a dev-only toolchain with a module cache (`/srv/ssz-optimization/toolchain-dev-cache`,
rigid Bend + bendlang/bend#1209): a cache trusts earlier results, so it is never a gate and never makes a
stamp. Only the full `tools/check_fast.sh` (with localization) and strictcheck gate a merge; iter.sh results
are not evidence. `regen_all.py --check` stays the authority on generated files; `--touched` output is
byte-identical to a full regeneration.
