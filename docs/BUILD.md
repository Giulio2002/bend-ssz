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

Every `.bend` file outside `tools/` and `vendor/` must check:

    tools/check_fast.sh [--jobs 20] [--target S] [--out DIR]  # all files through umbrellas; build/check_fast
    tools/check_all.sh [--jobs 10] [--list FILE] [--out DIR]   # all files one by one; logs and summary.tsv under build/check_all
    tools/check.sh <file.bend>                                  # one file

Bend has no module cache: checking a file checks every definition of every module in its import
closure (`book_valid` walks the whole book), so `check_all.sh` re-checks the shared modules
(`src/`, `spec/`, `END_TO_END.bend`, the big encoder interfaces) thousands of times: about 58,000
CPU seconds, 55 minutes at 20 jobs. `check_fast.sh` checks the same files through umbrellas:
`tools/umbrellas.py` groups the root files (those no other file imports; their closures cover
every file) by shared imports into files that only import them, so one run of an umbrella checks
each module of its closure once. About 30 umbrellas, 2,200 CPU seconds, 4 minutes at 20 jobs. A
failure in any imported definition, or an open law (a TODO), fails the umbrella exactly as it fails
the file, and its log names the definition; `DIR/<n>.list` holds the umbrella's roots for
`check_all.sh --list`. One difference: an umbrella checks every file as an import, never as the
top-level file, and Bend resolves some qualified constructor and alias names differently at the
top level (the `types/fulu*.bend` files check only as imports, on main as well).

`check.sh` runs `bun <bend-src>/bend2/main.ts <file> --check-only` with Bend 2.0.28 + bendlang/bend#1075
(found through `BEND_TOOLCHAIN`, default the ssz server's `/srv/ssz-optimization/toolchain-2.0.28`; `BEND_LIB` for the SHA-256 package cache) and prints `All terms check.` and a final `CHECK_TIME <seconds> <peak KB>` line. Each check runs
under the limits it was measured with:

| Limit | Value |
|---|---|
| memory | 12 GB (hard; `MemoryMax`), no swap |
| CPU | 2 cores, `nice 10` |
| wall time | 600 s |
| parallel checks | 10 |

Target per file: 60 s and 8 GB (e2e files 45 s); the final sweep's figures go here.
<TODO: whole-repository time at 10 in parallel, from the final sweep.>
