#!/usr/bin/env python3
"""Provenance stamp for the test evidence, and a check of it against the current tree.

    from provenance import stamp        # each harness: {**result, 'provenance': stamp(__file__)}
    python3 benchmarks/checks/provenance.py   # each evidence file: do its hashes match this tree?

A stamp records the git commit (from git, or EVIDENCE_COMMIT where the tree is a copy without
.git, as on the ssz server), the UTC time, the runtime toolchain actually used (the sha256 of the
bend binary and Base) and two sets of hashes that tie a result to code and can be recomputed from
any checkout:

  sources_sha256   per pattern of SOURCES, the sha256 of the matching files (sorted, path and
                   bytes): the whole typed object API types/*.bend (the per-name generated files
                   and the dispatch modules types/fulu_obj_*.bend, types/generic_obj_*.bend that
                   the programs call), src/*.bend, the program drivers benchmarks/objprog/*.bend
                   and benchmarks/compact/*.bend, and the vector set (cases.json,
                   fixtures.manifest.json);
  harness_sha256   the sha256 of each script that produced or judged the result: the harness
                   itself, this file, and the independent oracle and schema reader it relies on
                   (COMMON_HARNESS).

EVIDENCE maps every evidence file to its harness; `python3 benchmarks/checks/provenance.py`
reports, for each, whether its sources and harness match this tree (exit 1 if any does not, or
has no stamp).
"""
import datetime
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ('types/*.bend', 'src/*.bend', 'benchmarks/objprog/*.bend', 'benchmarks/compact/*.bend',
           'cases.json', 'fixtures.manifest.json')
COMMON_HARNESS = ('benchmarks/checks/provenance.py', 'codegen/oracle.py', 'codegen/schema.py',
                  'codegen/fulu.yaml', 'tools/test_schemas.py')
EVIDENCE = {
    'benchmarks/evidence/object_conformance.json': 'benchmarks/checks/object_conformance.py',
    'benchmarks/evidence/generic_object_conformance.json': 'benchmarks/checks/generic_object_conformance.py',
    'benchmarks/evidence/object_mutations.json': 'benchmarks/checks/object_mutations.py',
    'benchmarks/evidence/object_cache.json': 'benchmarks/checks/object_cache.py',
    'benchmarks/evidence/fuzz_objects.json': 'tests_generated/fuzz_objects.py',
    'benchmarks/evidence/object_mutation_tests.json': 'tests_generated/mutations.py',
    'benchmarks/evidence/invalid_objects.json': 'tests_generated/invalid_objects.py',
    'benchmarks/evidence/negative_api.json': 'tests_generated/negative_api.py',
}


def _cat(pattern):
    h = hashlib.sha256()
    for q in sorted(ROOT.glob(pattern)):
        h.update(q.relative_to(ROOT).as_posix().encode() + b'\0' + q.read_bytes())
    return h.hexdigest()


def sources():
    return {p: _cat(p) for p in SOURCES}


def harness(script):
    rel = Path(script).resolve().relative_to(ROOT).as_posix()
    return {f: hashlib.sha256((ROOT / f).read_bytes()).hexdigest() for f in (rel,) + COMMON_HARNESS}


def runtime_bend():
    lock = json.loads((ROOT / 'benchmarks/toolchain.json').read_text())
    return os.environ.get('BEND_RUNTIME') or lock['bend']['path']


def stamp(script):
    """The provenance of a result produced by `script` (the harness's __file__)."""
    try:
        commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True,
                                         stderr=subprocess.DEVNULL).strip()
        dirty = bool(subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'],
                                             cwd=ROOT, text=True).strip())
    except (OSError, subprocess.CalledProcessError):
        commit, dirty = os.environ.get('EVIDENCE_COMMIT', 'unknown'), None
    bend = Path(runtime_bend())
    base = bend.resolve().parents[1] / 'bend2/base.bend'
    return {'git_commit': commit, 'git_dirty': dirty,
            'utc': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
            'runtime': {'bend_sha256': hashlib.sha256(bend.read_bytes()).hexdigest(),
                        'base_sha256': hashlib.sha256(base.read_bytes()).hexdigest() if base.exists() else None},
            'argv': sys.argv[1:], 'sources_sha256': sources(), 'harness_sha256': harness(script)}


def main():
    cur = sources()
    stale = 0
    for e, script in EVIDENCE.items():
        p = ROOT / e
        prov = json.loads(p.read_text()).get('provenance') if p.exists() else None
        if not prov:
            print(f'{e}: no provenance stamp')
            stale += 1
            continue
        diff = [k for k in cur if prov['sources_sha256'].get(k) != cur[k]]
        want = harness(ROOT / script)
        diff += [k for k in want if prov.get('harness_sha256', {}).get(k) != want[k]]
        print(f"{e}: commit {prov['git_commit']} at {prov['utc']}: "
              + ('sources and harness match this tree' if not diff else 'differs from this tree: ' + ', '.join(diff)))
        stale += bool(diff)
    sys.exit(1 if stale else 0)


if __name__ == '__main__':
    main()
