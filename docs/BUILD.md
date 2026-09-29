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

    tools/check_all.sh [--jobs 10] [--list FILE] [--out DIR]   # all files; logs and summary.tsv under build/check_all
    tools/check.sh <file.bend>                                  # one file

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
