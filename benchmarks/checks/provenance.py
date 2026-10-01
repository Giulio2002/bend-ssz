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
import re
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
    'benchmarks/evidence/runtime_tests.json': 'tools/run_runtime_tests.py',
}
# files a harness depends on beyond COMMON_HARNESS (the Bun tests and their loader)
EXTRA_HARNESS = {'tools/run_runtime_tests.py': ('tools/bend_loader.ts', 'tests/*.test.ts', 'tests/**/*.test.ts')}
# the native programs the harnesses run, and the source each is built from
PROGRAMS = (('build/obj-g', 'benchmarks/objprog/g'), ('build/obj-x', 'benchmarks/objprog/x'),
            ('build/fuzz-f', 'benchmarks/objprog/f'), ('build/compact-', 'benchmarks/compact/'))
BEND_FLAGS = ['--threads', '1', '--gpu', 'off']   # as benchmarks/run.py compiles and runs them


def _cat(pattern, root=None):
    root = root or ROOT
    h = hashlib.sha256()
    for q in sorted(root.glob(pattern)):
        h.update(q.relative_to(root).as_posix().encode() + b'\0' + q.read_bytes())
    return h.hexdigest()


def sources(root=None):
    return {p: _cat(p, root) for p in SOURCES}


def harness(script):
    rel = Path(script).resolve().relative_to(ROOT).as_posix()
    out = {f: hashlib.sha256((ROOT / f).read_bytes()).hexdigest() for f in (rel,) + COMMON_HARNESS}
    for pat in EXTRA_HARNESS.get(rel, ()):
        out[pat] = _cat(pat)
    return out


def import_cone(entry):
    """Every .bend file reachable from `entry` by `import ./x.bend` lines (as benchmarks/quick.py reads it)."""
    seen, todo = [], [entry.resolve()]
    while todo:
        f = todo.pop()
        if f in seen:
            continue
        seen.append(f)
        for m in re.finditer(r'^import\s+(\S+\.bend)', f.read_text(), re.M):
            if not m.group(1).startswith('0x'):
                todo.append((f.parent / m.group(1)).resolve())
    return sorted(seen)


def program_key(entry, bend, base):
    """The cache key benchmarks/quick.py gives a program: the compiler, Base, the flags and the import cone."""
    h = hashlib.sha256()
    h.update(bend.read_bytes())
    h.update(base.read_bytes())
    h.update(' '.join(BEND_FLAGS).encode())
    for f in import_cone(entry):
        h.update(str(f.relative_to(ROOT)).encode())
        h.update(f.read_bytes())
    return h.hexdigest()[:20]


def executables(bend, base):
    """Every native program present under build/, with the sha256 of the executable, the cache entry it links to
    (named <prefix><k>-<key>) and the key that entry must have if it was built from this tree by this compiler."""
    out = {}
    for pre, src in PROGRAMS:
        d, stem = (ROOT / pre).parent, (ROOT / pre).name
        for q in sorted(d.glob(stem + '*')):
            n = q.name[len(stem):]
            entry = ROOT / (src + n + '.bend')
            if not entry.exists() or not q.exists():
                continue
            target = q.resolve().name if q.is_symlink() else None
            out[q.name] = {'sha256': hashlib.sha256(q.read_bytes()).hexdigest(), 'cache_entry': target,
                           'source': entry.relative_to(ROOT).as_posix(),
                           'expected_key': program_key(entry, bend, base) if base.exists() else None}
    return out


def git_state():
    """(commit, dirty, tree): from the checkout; in a copy without .git (the ssz server) from EVIDENCE_COMMIT,
    EVIDENCE_DIRTY and EVIDENCE_TREE, which tools/run_evidence.sh sets from the checkout it refuses to run when dirty."""
    try:
        commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True, stderr=subprocess.DEVNULL).strip()
        dirty = bool(subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'],
                                             cwd=ROOT, text=True).strip())
        tree = subprocess.check_output(['git', 'rev-parse', 'HEAD^{tree}'], cwd=ROOT, text=True).strip()
        return commit, dirty, tree
    except (OSError, subprocess.CalledProcessError):
        d = os.environ.get('EVIDENCE_DIRTY')
        return (os.environ.get('EVIDENCE_COMMIT', 'unknown'), None if d is None else d == '1',
                os.environ.get('EVIDENCE_TREE'))


def runtime_bend():
    lock = json.loads((ROOT / 'benchmarks/toolchain.json').read_text())
    return os.environ.get('BEND_RUNTIME') or lock['bend']['path']


def stamp(script):
    """The provenance of a result produced by `script` (the harness's __file__)."""
    commit, dirty, tree = git_state()
    bend = Path(runtime_bend())
    base = bend.resolve().parents[1] / 'bend2/base.bend'
    return {'git_commit': commit, 'git_dirty': dirty, 'git_tree': tree,
            'utc': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
            'runtime': {'bend_sha256': hashlib.sha256(bend.read_bytes()).hexdigest(),
                        'base_sha256': hashlib.sha256(base.read_bytes()).hexdigest() if base.exists() else None},
            'executables': executables(bend, base),
            'argv': sys.argv[1:], 'sources_sha256': sources(), 'harness_sha256': harness(script)}


def sources_at(commit):
    """sources() of a git commit (read from the object store), to bind a recorded commit to a recorded hash."""
    import tempfile
    with tempfile.TemporaryDirectory() as t:
        tar = subprocess.Popen(['git', 'archive', commit, '--', 'types', 'src', 'benchmarks/objprog', 'benchmarks/compact',
                                'cases.json', 'fixtures.manifest.json'], cwd=ROOT, stdout=subprocess.PIPE)
        subprocess.run(['tar', '-x', '-C', t], stdin=tar.stdout, check=True)
        tar.wait()
        return sources(Path(t))


def _bend_for(rt):
    """The compiler of a recorded run, if the one at hand is it (its sha256 equals the recorded one)."""
    try:
        b = Path(runtime_bend())
        return b if hashlib.sha256(b.read_bytes()).hexdigest() == rt.get('bend_sha256') else None
    except OSError:
        return None


def _base_for(rt):
    b = _bend_for(rt)
    return b.resolve().parents[1] / 'bend2/base.bend' if b else None


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
        # the repository state it was made from: clean, and the recorded commit holds exactly the recorded sources
        if prov.get('git_dirty') is not False:
            diff.append('git_dirty is %r (the evidence must be made from a clean checkout)' % (prov.get('git_dirty'),))
        commit = prov.get('git_commit', 'unknown')
        try:
            at = sources_at(commit)
            diff += ['commit %s holds other %s' % (commit[:8], k) for k in at if at[k] != prov['sources_sha256'].get(k)]
        except (OSError, subprocess.CalledProcessError):
            pass   # no .git or the commit is not here: the hashes above still bind the evidence to this tree
        # the programs it ran: built from this tree's sources by the compiler it records
        rt = prov.get('runtime', {})
        for name, e in prov.get('executables', {}).items():
            if e['cache_entry'] is None:
                diff.append(f'{name}: not a cache link (benchmarks/quick.py builds the programs)')
                continue
            bend = _bend_for(rt)
            want_key = program_key(ROOT / e['source'], bend, _base_for(rt)) if bend else None
            if e['cache_entry'].rsplit('-', 1)[-1] != e['expected_key'] or (want_key and want_key != e['expected_key']):
                diff.append(f'{name}: built from other sources than this tree')
        print(f"{e}: commit {prov['git_commit']} at {prov['utc']}: "
              + ('sources and harness match this tree' if not diff else 'differs from this tree: ' + ', '.join(diff)))
        stale += bool(diff)
    sys.exit(1 if stale else 0)


if __name__ == '__main__':
    main()
