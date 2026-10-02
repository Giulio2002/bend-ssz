#!/usr/bin/env python3
"""Regenerate every generated file, or check that none is stale.

    python3 codegen/regenerate_all.py                 # write mode, repeated until nothing changes
    python3 codegen/regenerate_all.py --check         # every generator's --check; nonzero exit if any is stale
    python3 codegen/regenerate_all.py --only a,b      # just these generators (names without .py), in order
    python3 codegen/regenerate_all.py --list          # the order the generators run in
    python3 codegen/regenerate_all.py --touched       # only the generators whose inputs changed since their last clean run (codegen/regenerate_touched.py)
    python3 codegen/regenerate_all.py -j N            # N generators at once (default min(8, cpus)); --serial or -j 1: one at a time

The generators are the entries of codegen/generator_registry.py (every script that accepts --check). typed_object_runtime.py (the object API, which
every law generator reads) runs first; the generators that index the others' outputs run last (codegen/generator_registry.py):
object_api_coverage_gate.py (one-import gates), object_api_facade_proofs.py (the per-name facades) and object_api_model_bridges.py (the
bridges and e2e/manifest.json), then end_to_end_statement_list.py (e2e/STATEMENTS.txt) and documentation_figures.py (the docs' coverage figures). A law generator can read another's output (a facade records
its imports, a split module its parent's names), so write mode repeats the whole pass until
a pass leaves every --check clean (at most --passes, default 16).

Parallelism (-j): --check only reads, so every generator's check runs in the pool (heavy ones first; the
report is in generator order whatever the finishing order). Write mode (pass 1 runs everything, later passes only what the last check found stale or failing) runs typed_object_runtime.py alone, then the
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
sys.path.insert(0, str(ROOT))
from codegen import generator_registry as registry  # noqa: E402  the list of generators, their stages and dependencies

JOBS = 1
FAIL_WORDS = ('stale', 'traceback', 'error', 'orphan', 'left after', 'fail', 'not found', 'mismatch')


def generators():
    """([name] in run order, {name: path of its script}), from codegen/generator_registry.py (tests/test_registry.py keeps it complete)."""
    order = registry.ordered()
    return [g.name for g in order], {g.name: g.path for g in order}


def _stage(name):
    return registry.by_name()[name].stage


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
    reg = registry.by_name()
    start = sorted(gens, key=lambda g: (reg[g].heavy if reg[g].heavy is not None else len(reg), gens.index(g)))
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


def write_groups(order):
    """the write pass's schedule: lists of generators, run one list after the other, the members of a list in the pool"""
    if JOBS <= 1:
        return [[g] for g in order]
    reg = registry.by_name()
    groups = [[g] for g in order if _stage(g) == 'first'] + [[g for g in order if _stage(g) == 'mid']]
    pools = {}
    for g in order:
        if _stage(g) == 'last':
            if reg[g].pool is None:
                groups.append([g])
            elif reg[g].pool not in pools:   # the pool's place is its first member's
                pools[reg[g].pool] = [g]
                groups.append(pools[reg[g].pool])
            else:
                pools[reg[g].pool].append(g)
    return groups


def write_pass(order, have, k, verbose, only=None):
    """One write pass; the generators that failed (they may read a file a later or concurrent generator
    writes) are returned, never fatal: a later pass reruns them. {name: last output}."""
    if only is not None:   # later passes: just the generators the last check found stale or failing
        order = [g for g in order if g in only]
    groups = write_groups(order)
    failed = {}
    for grp in groups:
        for g, (bad, out, dt) in zip(grp, run_many(grp, have, [])):
            if bad and ('traceback' in out.lower() or 'systemexit' in out.lower()):
                failed[g] = out[-600:]
                print(f'pass {k} {g} FAILED ({dt:.0f} s): {out.strip().splitlines()[-1][:200] if out.strip() else ""}', flush=True)
            elif verbose:
                print(f'pass {k} {g} ({dt:.0f} s)', flush=True)
    return failed


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
        print('\n'.join(str(have[g].relative_to(ROOT)) if '--paths' in a else g for g in order))
        return
    verbose = '-v' in a
    global JOBS
    JOBS = 1 if '--serial' in a or ('--only' in a and '-j' not in a) else int(a[a.index('-j') + 1]) if '-j' in a else min(8, os.cpu_count() or 1)
    if '--touched' in a or '--reset-stamps' in a:   # only what changed since the recorded stamps (regenerate_touched.py)
        import regenerate_touched
        return regenerate_touched.main(a, order, have)
    if '--check' in a:
        stale = check(order, have, verbose)
        print(f'{len(order) - len(stale)}/{len(order)} generators up to date')
        sys.exit(1 if stale else 0)
    passes = int(a[a.index('--passes') + 1]) if '--passes' in a else 16
    failed, stale = {}, []
    for k in range(1, passes + 1):
        failed = write_pass(order, have, k, verbose, None if k == 1 else set(stale) | set(failed))
        stale = check(order, have, False)
        if not stale and not failed:
            print(f'regenerated: every generator up to date after {k} pass(es)')
            return
        print(f'pass {k}: {len(failed)} failed, {len(stale)} stale ({", ".join(sorted(set(stale) | set(failed)))[:300]}), repeating', flush=True)
    for g, out in failed.items():
        print(f'FAIL  {g}: {out}', flush=True)
    raise SystemExit(f'still stale or failing after {passes} passes: {", ".join(sorted(set(stale) | set(failed)))}')


if __name__ == '__main__':
    main()
