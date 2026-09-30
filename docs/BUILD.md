# Regenerate and check

## Regenerate

    python3 codegen/regen_all.py            # write mode
    python3 codegen/regen_all.py --check    # stale check (CI)

`regen_all.py` (`--list` shows the order, `--only a,b` a subset, `-j N` parallelism) runs `codegen/generate.py`
first, then every law generator in import order, then `api_gate.py`, `api_facade.py` and
`e2e_bridge.py`, and repeats until a pass writes nothing (the facades and gates record their
imports, so one law change can take two passes). `--check` runs every generator's `--check`
and fails on any stale file. Requirements: Python 3.12 with `requirements.txt`.

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
once. About 30 umbrellas, 2,200 CPU seconds, about 3 minutes at 20 jobs on the ssz server. A
failure in any imported definition, or an open law, fails the umbrella exactly as it fails the file.

Failures are localized automatically: each failed umbrella is bisected into import-only halves
until single root files remain, and the script prints each failing root with its log and the
definition the checker names (`DIR/failed.tsv`; `--no-localize` skips this). One difference from
checking a file directly: an umbrella checks every file as an import, never as the top-level file,
and Bend resolves some qualified constructor and alias names differently at the top level (the
`types/fulu*.bend` files check only as imports). `--files LIST` checks only the listed files and
their imports.

`tools/check_costs.tsv` holds per-file check times (file, exit, ok, seconds, peak MB) measured once
with the pinned checker; `umbrellas.py` uses them only to balance the partition, never for coverage.

`check.sh` runs `bun <bend-src>/bend2/main.ts <file> --check-only` with the checker pinned in
`toolchain.lock.json` (Bend 2.0.28 + bendlang/bend#1075 at 3ddfb036; found through `BEND_TOOLCHAIN`,
default the ssz server's `/srv/ssz-optimization/toolchain-2.0.28`) and the SHA-256 package
(`BEND_LIB`, default the vendored `vendor/bendhub`), and prints `All terms check.` and a final
`CHECK_TIME <seconds> <peak KB>` line. Before any run, `tools/verify_pins.py` compares the
checker's files, Bun and the package with the lock's sha256s and refuses a mismatch (exit 3).
`check_fast.sh` also runs `tools/verify_frozen.py` first: the spec, the four roots' statements, and
the bridge statements with the definitions they reach must match `frozen.lock.json`. A deliberate
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
