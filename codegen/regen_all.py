#!/usr/bin/env python3
"""Regenerate every generated file, or check that none is stale.

    python3 codegen/regen_all.py                 # write mode, repeated until nothing changes
    python3 codegen/regen_all.py --check         # every generator's --check; nonzero exit if any is stale
    python3 codegen/regen_all.py --only a,b      # just these generators (names without .py), in order
    python3 codegen/regen_all.py --list          # the order the generators run in

The generators are every codegen/*.py that accepts --check. generate.py (the object API, which
every law generator reads) runs first; the generators that index the others' outputs run last:
api_gate.py (one-import gates), api_facade.py (the per-name facades) and e2e_bridge.py (the
bridges and e2e/manifest.json). A law generator can read another's output (a facade records
its imports, a split module its parent's names), so write mode repeats the whole pass until
a pass leaves every --check clean (at most --passes, default 4).
"""
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIRST = ['generate']
LAST = ['api_gate', 'api_facade', 'e2e_bridge']
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


def check(order, have, verbose):
    stale = []
    for g in order:
        bad, out, dt = run(have[g], ['--check'])
        if bad:
            stale.append(g)
            print(f'STALE {g} ({dt:.0f} s): {out.splitlines()[-1][:300] if out else ""}', flush=True)
        elif verbose:
            print(f'ok    {g} ({dt:.0f} s)', flush=True)
    return stale


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
    if '--check' in a:
        stale = check(order, have, verbose)
        print(f'{len(order) - len(stale)}/{len(order)} generators up to date')
        sys.exit(1 if stale else 0)
    passes = int(a[a.index('--passes') + 1]) if '--passes' in a else 4
    for k in range(1, passes + 1):
        for g in order:
            bad, out, dt = run(have[g], [])
            if bad and ('traceback' in out.lower() or 'systemexit' in out.lower()):
                print(f'FAIL  {g} ({dt:.0f} s): {out[-600:]}', flush=True)
                sys.exit(2)
            if verbose:
                print(f'pass {k} {g} ({dt:.0f} s)', flush=True)
        stale = check(order, have, False)
        if not stale:
            print(f'regenerated: every generator up to date after {k} pass(es)')
            return
        print(f'pass {k}: {len(stale)} generator(s) still stale, repeating', flush=True)
    raise SystemExit(f'still stale after {passes} passes: {", ".join(stale)}')


if __name__ == '__main__':
    main()
