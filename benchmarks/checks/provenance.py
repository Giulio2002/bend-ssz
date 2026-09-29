#!/usr/bin/env python3
"""Provenance stamp for the conformance evidence, and a check of it against the current tree.

    from provenance import stamp        # the conformance scripts: {**result, 'provenance': stamp()}
    python3 benchmarks/checks/provenance.py   # each evidence file: does its source hash match this tree?

A stamp records the git commit (from git, or EVIDENCE_COMMIT where the tree is a copy without
.git, as on the ssz server), the UTC time, the runtime toolchain actually used (the sha256 of the
bend binary and Base) and SOURCES: the sha256 of the files the tested programs are built from
(the generated object API types/*_generated.bend, in name order, concatenated; src/*.bend; and
the program drivers benchmarks/objprog/*.bend). The source hash is what ties a result to code:
it can be recomputed from any checkout.
"""
import datetime
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ['benchmarks/evidence/object_conformance.json', 'benchmarks/evidence/generic_object_conformance.json']


def _cat(pattern):
    h = hashlib.sha256()
    for q in sorted(ROOT.glob(pattern)):
        h.update(q.relative_to(ROOT).as_posix().encode() + b'\0' + q.read_bytes())
    return h.hexdigest()


def sources():
    return {p: _cat(p) for p in ('types/*_generated.bend', 'src/*.bend', 'benchmarks/objprog/*.bend')}


def runtime_bend():
    lock = json.loads((ROOT / 'benchmarks/toolchain.json').read_text())
    return os.environ.get('BEND_RUNTIME') or lock['bend']['path']


def stamp():
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
            'sources_sha256': sources()}


def main():
    cur = sources()
    stale = 0
    for e in EVIDENCE:
        p = ROOT / e
        prov = json.loads(p.read_text()).get('provenance') if p.exists() else None
        if not prov:
            print(f'{e}: no provenance stamp')
            stale += 1
            continue
        diff = [k for k in cur if prov['sources_sha256'].get(k) != cur[k]]
        print(f"{e}: commit {prov['git_commit']} at {prov['utc']}: "
              + ('sources match this tree' if not diff else 'sources differ from this tree: ' + ', '.join(diff)))
        stale += bool(diff)
    sys.exit(1 if stale else 0)


if __name__ == '__main__':
    main()
