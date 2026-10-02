#!/usr/bin/env python3
"""Audit which modules each entry point actually reaches.

    /opt/homebrew/bin/python3 codegen/docs/import_graph.py [--check]

Every `.bend` file in the workspace is a node; an `import path.bend as X` line
is an edge. The entry points are grouped by what they are for, so the question
the codegen-only requirement asks - is there still a legacy module on a
production path? - is answered by a reachability computation rather than by
reading import lines by hand.

`--check` fails if a module that is not part of the generated production path
becomes reachable from a measured or public entry point.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[2]))  # the repository root: `codegen` is importable when this file runs as a script
import functools
import re
import sys

from codegen.core.repository_paths import ROOT  # noqa: E402
IMPORT = re.compile(r'^\s*import\s+(\S+\.bend)\b', re.M)

# The public/measured entry points. Anything these reach is production.
# the typed object runtime, generated split per name and operation (codegen/impl/runtime_file_split.py): the 109
# mainnet Fulu names and the supported generic SSZ forms
PRODUCTION = sorted(str(p.relative_to(ROOT)) for p in (ROOT / 'types').glob('*_generated.bend'))
MEASURED = sorted(str(p.relative_to(ROOT)) for p in (ROOT / 'benchmarks/objprog').glob('g*.bend'))
MEASURED += [str(p.relative_to(ROOT)) for p in (ROOT / 'benchmarks/objprog').glob('x*.bend')]
MEASURED += ['native_bench/driver.bend']
OTHER = {
    'proof roots': ['PROOF.bend', 'END_TO_END.bend', 'ROOT_DOMAIN.bend', 'HASH_PROOF.bend'],
    # the list model: the frozen END_TO_END/ROOT_DOMAIN propositions speak about it; the Bun
    # runtime tests that exercised types/fulu.bend were removed (2026-09-30) because the runtime
    # compiler cannot compile types/fulu*.bend as an entry (see docs/BUILD.md, Tests)
    'legacy list model (frozen propositions, protected runtime tests)': ['src/ssz.bend', 'types/fulu.bend'],
    'independent specification': sorted(str(p.relative_to(ROOT)) for p in (ROOT / 'spec').glob('*.bend')),
}


@functools.lru_cache(maxsize=None)
def imports(rel):
    path = ROOT / rel
    if not path.exists():
        return ()
    out = []
    for raw in IMPORT.findall(path.read_text()):
        if raw.startswith('/') or raw.startswith('0x'):
            continue
        target = (path.parent / raw).resolve()
        try:
            out.append(str(target.relative_to(ROOT)))
        except ValueError:
            continue           # the pinned BendHub package, outside the tree
    return tuple(out)


def reach(roots):
    seen, stack = set(), list(roots)
    while stack:
        node = stack.pop()
        if node in seen:
            continue
        seen.add(node)
        stack.extend(imports(node))
    return seen


def main():
    production = reach(PRODUCTION)
    measured = reach(MEASURED)
    runtime = sorted(m for m in production if m.startswith('src/'))
    print('production entry points:', ', '.join(PRODUCTION))
    print(f'  reaches {len(production)} modules, {len(runtime)} of them in src/:')
    for m in runtime:
        print('   ', m)
    extra = sorted(m for m in measured - production if m.startswith('src/'))
    print(f'measured programs additionally reach {len(extra)} src/ modules:')
    for m in extra:
        print('   ', m)
    print()
    for label, roots in OTHER.items():
        got = reach(roots)
        overlap = sorted(m for m in got & production if m.startswith('src/'))
        only = sorted(m for m in got - production if m.startswith('src/'))
        print(f'{label}:')
        print(f'  {len(only)} src/ modules of its own, {len(overlap)} shared with production')
        if only:
            print('   own:', ', '.join(only))
    unreached = sorted(str(p.relative_to(ROOT)) for p in (ROOT / 'src').glob('*.bend')
                       if str(p.relative_to(ROOT)) not in reach(
                           PRODUCTION + MEASURED + [r for rs in OTHER.values() for r in rs]))
    print()
    print('src/ modules no entry point reaches:', ', '.join(unreached) if unreached else 'none')
    if '--check' in sys.argv:
        allowed = {'src/obj.bend', 'src/buffer.bend', 'src/digest.bend', 'src/merkle_fast.bend',
                   'src/sha256.bend', 'src/merkle.bend'}
        bad = sorted(set(runtime) - allowed)
        if bad:
            print('FAIL: production path reaches non-runtime modules: ' + ', '.join(bad))
            sys.exit(1)
        if unreached:
            print('FAIL: unreachable src/ modules: ' + ', '.join(unreached))
            sys.exit(1)
        print('OK: the production path reaches only the shared runtime primitives')


if __name__ == '__main__':
    main()
