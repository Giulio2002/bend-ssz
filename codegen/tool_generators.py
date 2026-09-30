#!/usr/bin/env python3
"""The tools/generate_*.py generators: rerun them and require the committed files byte for byte.

    python3 codegen/tool_generators.py            # run every reproducible tools generator in place
    python3 codegen/tool_generators.py --check    # run them in a scratch copy of the tree; nonzero
                                                  # exit if one writes anything that differs from
                                                  # the committed file, writes a new file, writes
                                                  # nothing, or exits nonzero

tools/generate_*.py wrote the early proof layer (proofs/*.bend: compatibility, identity, root
relation, codec and bit-packing proofs), some spec/ and types/ files, and benchmark scaffolding.
They take no arguments and are deterministic, so --check copies the tree (without .git, build/
and node_modules/) to a scratch directory, runs each one there in turn, and compares every file
it wrote (by modification time, or new) with the original tree. Each must write at least one
file (the files it writes are listed with -v) and every written file must equal the committed
one. Frozen files some of them write (spec/*.bend, types/fulu_model.bend, ...) are thereby
checked to be exactly what their generator produces, on top of frozen.lock.json.

ONE_SHOT lists the six that cannot be rerun from the tree or write no committed file, with the
reason; they are not run,
and the check fails if the set of tools/generate_*.py is not exactly REPRODUCIBLE + ONE_SHOT, so
a new generator must be classified. regen_all.py runs this with the codegen generators.
"""
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKIP_DIRS = {'.git', 'build', 'node_modules', '__pycache__'}
ONE_SHOT = {
    'generate_benchmarks_md': 'renders BENCHMARKS.md from a measurement report given as its argument '
                              '(benchmarks/run.py output); the report is not in the tree',
    'generate_compact_foundation': 'imported proofs/compact/found.bend once from a bend-collections '
                                   'snapshot outside this repository',
    'generate_missing_go_types': 'writes the Go reference types of the benchmark (benchmarks/fastssz/gen) '
                                 'and needs gofmt; not part of any proof',
    'generate_proof_memory_report': 'measures proof-check memory with macOS libproc; a measurement, '
                                    'not a generator of checked files',
    'generate_fulu_conversion_composition': 'writes a candidate module to build/ for review; its output '
                                            'is not a committed file',
    'generate_bench_schema': 'not a generator: a library that reads spec/fulu_schemas.bend for the '
                             'benchmark harness (and tools/verify_schemas.py) and writes nothing',
}


def all_generators():
    return sorted(p.stem for p in (ROOT / 'tools').glob('generate_*.py'))


def reproducible():
    return [g for g in all_generators() if g not in ONE_SHOT]


def snapshot(d):
    out = {}
    for r, ds, fs in os.walk(d):
        ds[:] = [x for x in ds if x not in SKIP_DIRS]
        for f in fs:
            p = os.path.join(r, f)
            st = os.lstat(p)
            out[os.path.relpath(p, d)] = (st.st_mtime_ns, st.st_size)
    return out


def run(gen, cwd):
    return subprocess.run([sys.executable, str(Path('tools') / (gen + '.py'))], cwd=cwd, capture_output=True,
                          text=True, timeout=900)


def check(verbose):
    problems = []
    unknown = [g for g in ONE_SHOT if g not in all_generators()]
    if unknown:
        problems.append('ONE_SHOT names generators that do not exist: ' + ', '.join(unknown))
    tmp = tempfile.mkdtemp(prefix='toolgen-')
    try:
        work = os.path.join(tmp, 'tree')
        shutil.copytree(ROOT, work, symlinks=True, ignore=lambda d, fs: [f for f in fs if f in SKIP_DIRS])
        for g in reproducible():
            before = snapshot(work)
            r = run(g, work)
            after = snapshot(work)
            wrote = sorted(k for k in after if before.get(k) != after[k])
            gone = sorted(k for k in before if k not in after)
            if r.returncode != 0:
                problems.append('%s exited %d: %s' % (g, r.returncode, (r.stderr or r.stdout).strip()[-300:]))
            if not wrote:
                problems.append('%s wrote no file' % g)
            differ = []
            for k in wrote:
                orig = ROOT / k
                new = Path(work) / k
                if not orig.exists():
                    differ.append(k + ' (new)')
                elif orig.read_bytes() != new.read_bytes():
                    differ.append(k)
                    shutil.copy2(orig, new)  # later generators see the committed file
            if differ:
                problems.append('%s writes files that differ from the committed ones: %s' % (g, ', '.join(differ)))
            if gone:
                problems.append('%s removed %s' % (g, ', '.join(gone)))
            if verbose:
                print('%s: %s' % (g, ', '.join(wrote)))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    if problems:
        print('tool_generators: STALE or not reproducible:\n  ' + '\n  '.join(problems))
        return 1
    print('tool_generators: %d tools/generate_*.py reproduce the committed files byte for byte; %d one-shot (not run): %s'
          % (len(reproducible()), len(ONE_SHOT), ', '.join(sorted(ONE_SHOT))))
    return 0


def write():
    bad = 0
    for g in reproducible():
        r = run(g, ROOT)
        if r.returncode != 0:
            print('%s exited %d: %s' % (g, r.returncode, (r.stderr or r.stdout).strip()[-300:]))
            bad = 1
    return bad


if __name__ == '__main__':
    if '--check' in sys.argv:
        sys.exit(check('-v' in sys.argv))
    sys.exit(write())
