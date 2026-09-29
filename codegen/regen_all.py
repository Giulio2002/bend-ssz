#!/usr/bin/env python3
"""Regenerate every generated file, or check that none is stale.

    python3 codegen/regen_all.py                 # write mode, repeated until nothing changes
    python3 codegen/regen_all.py --check         # every generator's --check; nonzero exit if any is stale
    python3 codegen/regen_all.py --only a,b      # just these generators (names without .py), in order
    python3 codegen/regen_all.py --list          # the order the generators run in
    python3 codegen/regen_all.py -j N            # N generators at once (default min(8, cpus)); --serial or -j 1: one at a time

The generators are every codegen/*.py that accepts --check. generate.py (the object API, which
every law generator reads) runs first; the generators that index the others' outputs run last:
api_gate.py (one-import gates), api_facade.py (the per-name facades) and e2e_bridge.py (the
bridges and e2e/manifest.json). A law generator can read another's output (a facade records
its imports, a split module its parent's names), so write mode repeats the whole pass until
a pass leaves every --check clean (at most --passes, default 4).

Parallelism (-j): --check only reads, so every generator's check runs in the pool (heavy ones first; the
report is in generator order whatever the finishing order). Write mode runs generate.py alone, then the
middle generators in the pool, then the LAST ones one at a time; a middle generator that fails in the pool
(it may have read a file another was writing) is rerun alone before the pass counts, and the fixpoint check
that ends the run is what guarantees the result, as in the serial run.
"""
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIRST = ['generate']
LAST = ['api_gate', 'api_facade', 'e2e_bridge']
# the slowest generators (measured), started first so the pool's tail is short
HEAVY = ['var_cont_enc', 'var_winb', 'e2e_bridge', 'api_gate', 'spec_laws', 'root_laws_b', 'api_facade', 'valid_laws']
JOBS = 1
FAIL_WORDS = ('stale', 'traceback', 'error', 'orphan', 'left after', 'fail', 'not found', 'mismatch')


def generators():
    have = {}
    for p in sorted((ROOT / 'codegen').glob('*.py')):
        if p.name == 'regen_all.py':
            continue
        t = p.read_text(errors='replace')
        if "'--check'" in t or '"--check"' in t:
            have[p.stem] = p
    mid = [g for g in have if g not in FIRST and g not in LAST]
    return [g for g in FIRST if g in have] + mid + [g for g in LAST if g in have], have


def run(path, args):
    t0 = time.time()
    r = subprocess.run([sys.executable, str(path)] + args, cwd=ROOT, capture_output=True, text=True)
    out = (r.stdout + r.stderr).strip()
    bad = r.returncode != 0 or any(w in out.lower() for w in FAIL_WORDS)
    return bad, out, time.time() - t0


def run_many(gens, have, args):
    """[(bad, out, dt)] of run(have[g], args) for g in gens, in the order of gens; JOBS at a time, the slow ones first."""
    if JOBS <= 1 or len(gens) <= 1:
        return [run(have[g], args) for g in gens]
    start = sorted(gens, key=lambda g: (HEAVY.index(g) if g in HEAVY else len(HEAVY), gens.index(g)))
    with ThreadPoolExecutor(max_workers=JOBS) as ex:
        futs = {g: ex.submit(run, have[g], args) for g in start}
        return [futs[g].result() for g in gens]


def check(order, have, verbose):
    stale = []
    for g, (bad, out, dt) in zip(order, run_many(order, have, ['--check'])):
        if bad:
            stale.append(g)
            print(f'STALE {g} ({dt:.0f} s): {out.splitlines()[-1][:300] if out else ""}', flush=True)
        elif verbose:
            print(f'ok    {g} ({dt:.0f} s)', flush=True)
    return stale


def write_pass(order, have, k, verbose):
    """One write pass; a failure in the pool is retried alone, then exits like the serial run."""
    mid = [g for g in order if g not in FIRST and g not in LAST]
    if JOBS <= 1:
        groups = [[g] for g in order]
    else:
        groups = [[g] for g in order if g in FIRST] + [mid] + [[g] for g in order if g in LAST]
    for grp in groups:
        for g, (bad, out, dt) in zip(grp, run_many(grp, have, [])):
            if bad and len(grp) > 1 and ('traceback' in out.lower() or 'systemexit' in out.lower()):
                bad, out, dt2 = run(have[g], [])
                dt += dt2
            if bad and ('traceback' in out.lower() or 'systemexit' in out.lower()):
                print(f'FAIL  {g} ({dt:.0f} s): {out[-600:]}', flush=True)
                sys.exit(2)
            if verbose:
                print(f'pass {k} {g} ({dt:.0f} s)', flush=True)


def main():
    a = sys.argv[1:]
    order, have = generators()
    if '--only' in a:
        want = a[a.index('--only') + 1].split(',')
        unknown = [g for g in want if g not in have]
        if unknown:
            raise SystemExit(f'no such generator: {", ".join(unknown)}')
        order = [g for g in want]
    if '--list' in a:
        print('\n'.join(order))
        return
    verbose = '-v' in a
    global JOBS
    JOBS = 1 if '--serial' in a or ('--only' in a and '-j' not in a) else int(a[a.index('-j') + 1]) if '-j' in a else min(8, os.cpu_count() or 1)
    if '--check' in a:
        stale = check(order, have, verbose)
        print(f'{len(order) - len(stale)}/{len(order)} generators up to date')
        sys.exit(1 if stale else 0)
    passes = int(a[a.index('--passes') + 1]) if '--passes' in a else 4
    for k in range(1, passes + 1):
        write_pass(order, have, k, verbose)
        stale = check(order, have, False)
        if not stale:
            print(f'regenerated: every generator up to date after {k} pass(es)')
            return
        print(f'pass {k}: {len(stale)} generator(s) still stale, repeating', flush=True)
    raise SystemExit(f'still stale after {passes} passes: {", ".join(stale)}')


if __name__ == '__main__':
    main()
