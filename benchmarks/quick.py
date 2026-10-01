#!/usr/bin/env python3
"""Fast development loop: the SAME native public API as benchmarks/run.py, not an
acceptance gate.

    python3 benchmarks/quick.py                         # default screen
    python3 benchmarks/quick.py --only BeaconBlockBody --ops serialize
    python3 benchmarks/quick.py --only Transaction --ops deserialize --workloads large

What it does, in order:

1. runs the generator (codegen/generate.py) so the measured Bend program is the
   one the current YAML and generator produce - never a stale checked-in copy;
2. for every program group the selection needs, computes a cache key over the
   compiler executable, the compile flags, and the bytes of every .bend file in
   that program's import cone (benchmarks/objprog/g<k>.bend and everything it
   imports, transitively). A group whose key is cached is reused; otherwise it
   is compiled afresh (one compile at a time, under the same footprint cap as
   benchmarks/run.py). Editing src/obj.bend therefore rebuilds every group,
   editing one group's generated file rebuilds only that group;
3. builds the Go reference (benchmarks/fastssz) keyed the same way on its
   sources;
4. verifies each workload before timing it: the Bend program decodes, re-encodes
   byte-for-byte and hashes; Go round-trips; both root checksums agree with each
   other and with the official root where the workload is an official fixture;
5. times alternating Bend/Go samples through benchmarks/run.py's own
   measure_pair/run_bend/run_go (same programs, modes, forcing and consumption),
   with a shorter calibration target so a screen fits in the budget.

Compilation is reported separately and is not counted against --budget: the
budget bounds the warm measurement phase (default 60 s). Everything is written
to build/quick/report.json with raw per-sample timings; the report says
acceptance=false because a screen with fewer, shorter samples never replaces the
full suite.
"""
import argparse
import hashlib
import importlib.util
import json
import os
import re
import shutil
import signal
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT / 'build/quick/cache'
DEFAULT_ONLY = ('BeaconState,BeaconBlock,SignedBeaconBlock,BeaconBlockBody,'
                'LightClientFinalityUpdate,ExecutionPayloadHeader,Transaction')
DEFAULT_OPS = {'BeaconState': 'deserialize,serialize,hash_tree_root',
               'Transaction': 'deserialize'}
DEFAULT_WORKLOADS = {'Transaction': 'large'}


def load_runner():
    spec = importlib.util.spec_from_file_location('ssz_benchmark', ROOT / 'benchmarks/run.py')
    b = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(b)
    return b


def sha(data):
    return hashlib.sha256(data).hexdigest()


def import_cone(entry):
    """Every .bend file reachable from `entry` by `import ./x.bend` lines.
    Package imports (0x.../..) are pinned by content hash in their name."""
    seen, todo = [], [entry.resolve()]
    while todo:
        f = todo.pop()
        if f in seen:
            continue
        seen.append(f)
        for m in re.finditer(r'^import\s+(\S+\.bend)', f.read_text(), re.M):
            target = m.group(1)
            if target.startswith('0x'):
                continue
            todo.append((f.parent / target).resolve())
    return sorted(seen)


def group_key(b, k, prefix='g', entry=None):
    entry = entry or ROOT / f'benchmarks/objprog/{prefix}{k}.bend'
    h = hashlib.sha256()
    h.update(Path(b.BEND).read_bytes())
    # Base is part of every program's cone; a toolchain change replaces it too
    h.update((Path(b.BEND).resolve().parents[1] / 'bend2/base.bend').read_bytes())
    h.update(' '.join(b.BEND_FLAGS).encode())
    for f in import_cone(entry):
        h.update(str(f.relative_to(ROOT)).encode())
        h.update(f.read_bytes())
    return h.hexdigest()[:20]


def go_key():
    h = hashlib.sha256()
    for f in sorted((ROOT / 'benchmarks/fastssz').rglob('*')):
        if f.is_file() and f.suffix in {'.go', '.mod', '.sum'}:
            h.update(str(f.relative_to(ROOT)).encode())
            h.update(f.read_bytes())
    h.update(subprocess.run(['go', 'version'], capture_output=True, text=True).stdout.encode())
    return h.hexdigest()[:20]


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--only', default=DEFAULT_ONLY, help='comma separated type names')
    p.add_argument('--ops', default=None,
                   help='comma separated operations (default: serialize, all three for BeaconState)')
    p.add_argument('--workloads', default=None,
                   help='comma separated labels matched as prefixes (small, medium, large, zero, ...) or "all";'
                        ' default medium (large for Transaction)')
    p.add_argument('--budget', type=float, default=60, help='warm measurement budget, seconds (<=60)')
    p.add_argument('--samples', type=int, default=3)
    p.add_argument('--target', type=float, default=0.03, help='calibration target per sample, seconds')
    p.add_argument('--report', default='build/quick/report.json')
    p.add_argument('--build-generic', default=None,
                   help='"all" or comma separated generic program numbers: build (cached) and link them as '
                        'build/obj-x<k> for benchmarks/checks/generic_object_conformance.py, then exit')
    p.add_argument('--build-fuzz', default=None,
                   help='"all" or comma separated fuzz program numbers: build (cached) and link them as '
                        'build/fuzz-f<k> for tests_generated/fuzz_objects.py, then exit')
    p.add_argument('--build-compact', action='store_true',
                   help='build (cached, keyed like the others) every benchmarks/compact/*.bend and link it as '
                        'build/compact-<name> for the evidence checks, then exit')
    p.add_argument('--build', default=None,
                   help='"all" or comma separated group numbers: build (cached) and link them as build/obj-g<k> '
                        'for the conformance checks, then exit without measuring')
    a = p.parse_args()
    if not 0 < a.budget <= 60 or a.samples < 2:
        p.error('budget must be in (0,60], samples >= 2')
    b = load_runner()
    report_path = ROOT / a.report
    report_path.parent.mkdir(parents=True, exist_ok=True)
    CACHE.mkdir(parents=True, exist_ok=True)
    report = {'mode': 'quick-diagnostic', 'acceptance': False, 'status': 'incomplete',
              'note': 'screening only; benchmarks/run.py is the contract measurement',
              'benchmarks': [], 'compiles': [], 'budget_seconds': a.budget,
              'samples_per_side': a.samples, 'calibration_target_seconds': a.target}
    try:
        # 1. generate
        b.sh([b.PY3, 'codegen/generate.py'])
        b.GROUPS = json.loads((ROOT / 'types/obj_groups.json').read_text())
        if a.build_compact:
            for entry in sorted((ROOT / 'benchmarks/compact').glob('*.bend')):
                n = entry.stem
                key = group_key(b, n, 'c', entry)
                exe = CACHE / f'c-{n}-{key}'
                link = ROOT / 'build' / f'compact-{n}'
                link.unlink(missing_ok=True)
                if not exe.exists():
                    tmp = CACHE / f'c-{n}-{key}.tmp'
                    b.capped_compile(str(entry.relative_to(ROOT)), tmp, print)
                    tmp.rename(exe)
                link.symlink_to(exe)
                print(f'build/compact-{n} -> {exe.relative_to(ROOT)}')
            report['status'] = 'built'
            return
        if a.build or a.build_generic or a.build_fuzz:
            link_name = 'obj-{prefix}{k}'
            if a.build_fuzz:
                prefix = 'f'
                ops = json.loads((ROOT / 'types/obj_fuzz_ops.json').read_text())
                every = sorted({e['program'] for e in ops.values()})
                sel = a.build_fuzz
                link_name = 'fuzz-{prefix}{k}'
            elif a.build_generic:
                prefix = 'x'
                idx = json.loads((ROOT / 'types/generic_obj_index.json').read_text())['generated']
                every = sorted({g['group'] for g in idx.values()})
                sel = a.build_generic
            else:
                prefix = 'g'
                every = sorted({g['group'] for g in b.GROUPS.values()})
                sel = a.build
            ks = every if sel == 'all' else [int(x) for x in sel.split(',')]
            for k in ks:
                # never leave a previous build's program behind a failed compile
                (ROOT / 'build' / link_name.format(prefix=prefix, k=k)).unlink(missing_ok=True)
            for k in ks:
                key = group_key(b, k, prefix)
                exe = CACHE / f'{prefix}{k}-{key}'
                if not exe.exists():
                    started = time.monotonic()
                    tmp = CACHE / f'{prefix}{k}-{key}.tmp'
                    b.capped_compile(f'benchmarks/objprog/{prefix}{k}.bend', tmp, print)
                    tmp.rename(exe)
                    print(f'{prefix}{k}: compiled in {time.monotonic() - started:.1f} s')
                link = ROOT / 'build' / link_name.format(prefix=prefix, k=k)
                link.unlink(missing_ok=True)
                link.symlink_to(exe)
                print(f'build/{link_name.format(prefix=prefix, k=k)} -> {exe.relative_to(ROOT)}')
            report['status'] = 'built'
            return
        names = [n for n in a.only.split(',') if n]
        for n in names:
            if n not in b.GROUPS:
                raise SystemExit(f'unknown type {n}')
        # 2. programs, cached by import cone
        programs = {}
        for k in sorted({b.GROUPS[n]['group'] for n in names}):
            key = group_key(b, k)
            exe = CACHE / f'g{k}-{key}'
            if not exe.exists():
                started = time.monotonic()
                tmp = CACHE / f'g{k}-{key}.tmp'
                b.capped_compile(f'benchmarks/objprog/g{k}.bend', tmp, print)
                tmp.rename(exe)
                report['compiles'].append({'group': k, 'key': key, 'seconds': round(time.monotonic() - started, 1)})
            else:
                report['compiles'].append({'group': k, 'key': key, 'cached': True})
            programs[k] = exe
        gk = go_key()
        go = CACHE / f'go-bench-{gk}'
        if not go.exists():
            b.sh([sys.executable, 'tools/generate_missing_go_types.py'])
            b.sh([sys.executable, 'tools/generate_bench_go.py'])
            gk = go_key()
            go = CACHE / f'go-bench-{gk}'
            if not go.exists():
                b.sh(['go', 'build', '-o', str(go), '.'], cwd=ROOT / 'benchmarks/fastssz')
        report['artifacts'] = {str(x.relative_to(ROOT)): b.digest(x) for x in list(programs.values()) + [go]}
        b.bend_program = lambda name: programs[b.GROUPS[name]['group']]
        b.OUT = go.parent
        real_run_go = b.run_go

        def run_go(name, impl, path, operation, ops):
            text = b.sh([str(go), name, impl, str(path), operation, str(ops)])
            return {'text': text, 'ns': int(re.search(r'\bNS=(\d+)', text).group(1)),
                    'roundtrip': 'ROUNDTRIP=true' in text,
                    'rootsum': int(re.search(r'ROOTSUM=(\d+)', text).group(1))}
        b.run_go = run_go
        del real_run_go

        # 3. measure, bounded
        start = time.monotonic()

        def timeout(*_):
            raise TimeoutError('quick benchmark exceeded its budget; report is incomplete')
        signal.signal(signal.SIGALRM, timeout)
        signal.setitimer(signal.ITIMER_REAL, a.budget)
        b.TARGET_SECONDS = a.target
        schemas = b.Schemas()
        coverage = json.loads((ROOT / 'benchmarks/reference_coverage.json').read_text())
        generated = (ROOT / 'benchmarks/fastssz/generated.go').read_text()
        candidates = {}
        for m in re.finditer(r'^\t"(\w+)": \{(.+)\},$', generated, re.M):
            keys = re.findall(r'"([\w.]+)"', m.group(2))
            if keys and all('.' in k for k in keys):
                candidates[m.group(1)] = keys
        with tempfile.TemporaryDirectory(prefix='ssz-quick-') as scratch:
            for name in names:
                ops = (a.ops or DEFAULT_OPS.get(name, 'serialize')).split(',')
                cases = b.workloads_for(name, schemas.resolve(name))
                wanted = (a.workloads or DEFAULT_WORKLOADS.get(name, 'medium')).split(',')
                cases = [c for c in cases if 'all' in wanted or any(c['workload'].startswith(w) for w in wanted)]
                for case in cases:
                    path = Path(scratch) / f'{name}.{case["workload"]}.ssz'
                    path.write_bytes(case['bytes'])
                    official = sum(bytes.fromhex(case['root'])) if 'root' in case else None
                    if name in set(coverage['simple_types']):
                        impl = 'simple'
                        probe = run_go(name, impl, path, 'hash_tree_root', 1)
                    else:
                        impl, probe = b.choose_reference(name, candidates.get(name, []), path, official, print)
                    if impl is None or not probe['roundtrip']:
                        raise SystemExit(f'no reference for {name} {case["workload"]}')
                    first = b.run_bend(name, path, 'hash_tree_root', 1, verify=True)
                    if not first['roundtrip'] or first['rootsum'] != probe['rootsum'] or \
                            (official is not None and first['rootsum'] != official):
                        raise SystemExit(f'verification failed: {name} {case["workload"]}')
                    for op in ops:
                        n, m, x, y = b.measure_pair(lambda k: b.run_bend(name, path, op, k, False),
                                                    lambda k: run_go(name, impl, path, op, k), a.samples)
                        if min(x + y) <= 0:
                            raise SystemExit(f'timer floor reached: {name}.{op}')
                        ratio = statistics.median(x) / statistics.median(y)
                        limit = 10 if op == 'hash_tree_root' else 5
                        report['benchmarks'].append({
                            'operation': f'{name}.{op}', 'workload': case['workload'], 'size': len(case['bytes']),
                            'bend_ns': x, 'reference_ns': y, 'bend_ops': n, 'reference_ops': m,
                            'bend_median_ns': statistics.median(x), 'reference_median_ns': statistics.median(y),
                            'ratio': ratio, 'limit': limit})
                        print(f'{name + "." + op:<40} {case["workload"]:<16} bend {statistics.median(x):>11.1f} ns'
                              f'  go {statistics.median(y):>10.1f} ns  {ratio:6.2f}x'
                              f'{"  OVER" if ratio > limit else ""}', flush=True)
        report['measure_seconds'] = round(time.monotonic() - start, 1)
        report['status'] = 'complete'
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
        report_path.write_text(json.dumps(report, indent=2) + '\n')
    print(f'measured in {report.get("measure_seconds")} s; compiles: '
          + ', '.join(f"g{c['group']} {'cached' if c.get('cached') else str(c['seconds']) + ' s'}"
                      for c in report['compiles']))


if __name__ == '__main__':
    main()
