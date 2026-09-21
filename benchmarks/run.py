#!/usr/bin/env python3
"""Native Bend C versus pinned Go fastssz, per type and operation.

    python3 benchmarks/run.py --report build/performance/report.json

Both sides are freshly built here in release configuration and run as native
executables on the same machine, one sequential thread each (`--threads 1
--gpu off` for Bend, `GOMAXPROCS(1)` for Go). No Bun/JavaScript result appears
in this report.

For every (type, workload, operation):

* the workload bytes are prepared first - an official consensus-spec fixture
  where one exists, otherwise a deterministic seeded workload valid for the
  frozen schema - and reading them is outside every measured window;
* both implementations must round-trip those bytes exactly and agree on the
  checksum of the hash tree root before any timing is recorded, which is what
  `verified` in the report means;
* the operation is then repeated `operations_per_sample` times inside one
  timed region, calibrated so that a sample lasts long enough to be immune to
  timer quantization, and every result is consumed;
* samples alternate between the two implementations, at least five each, in a
  fresh process per sample.

The Bend side is the compact primary API, three programs built from
benchmarks/compact/ (one per operation, because the pinned compiler cannot fit
every walker and the any-type index into one program's compile budget):

* deserialize - `API.run(0, …)`, the in-place validating decode whose result is
  the validated view; every verdict is consumed and any rejection exits 1;
* serialize - `A.encode`, a fresh packed buffer holding the value's encoding,
  after one untimed decode (Go likewise decodes into its struct before timing
  MarshalSSZ); every encoding is consumed;
* hash_tree_root - `API.run(1, …)` on a validated buffer; every root is
  consumed.

The schema is selected by index (types/fulu_cschema_index.bend, order in
build/cschema-index.json). The runtime evaluates stored values eagerly
(benchmarks/probes/strictness.bend), so consuming one word of an encoding does
not skip the rest of it.
"""
import argparse
import ctypes
import hashlib
import json
import os
import platform
import re
import signal
import statistics
import struct
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from generate_bench_schema import Schemas, fixed_size  # noqa: E402

import snappy  # noqa: E402
from ruamel.yaml import YAML  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
BEND = '/Users/monkeair/.bend/bin/bend'
ENV = {**os.environ, 'BEND_NO_TELEMETRY': '1'}
OUT = ROOT / 'build/performance'
INPUTS = OUT / 'inputs'
BEND_FLAGS = ['--threads', '1', '--gpu', 'off']
MIN_SAMPLES = 5
TARGET_SECONDS = 0.25
MAX_OPS = 5_000_000
CONTRACT = json.loads((ROOT / 'automation/performance_contract.json').read_text())
OPERATIONS = ['deserialize', 'serialize', 'hash_tree_root']
yaml = YAML(typ='safe')


def sh(command, cwd=ROOT, env=ENV):
    result = subprocess.run(command, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode:
        raise SystemExit(f'command failed: {command}\n{result.stdout}\n{result.stderr}')
    return result.stdout


PROGRAMS = {'deserialize': 'dec', 'serialize': 'enc', 'hash_tree_root': 'root'}
INDEX = json.loads((ROOT / 'build/cschema-index.json').read_text()) if (ROOT / 'build/cschema-index.json').exists() else []
COMPILE_CAP_BYTES = 6.5e9
COMPILE_ATTEMPTS = 4
COMPILES = []


def footprint(pid):
    """macOS physical footprint (ri_phys_footprint) of a process, in bytes."""
    lib = ctypes.CDLL('/usr/lib/libproc.dylib')
    buf = ctypes.create_string_buffer(1024)
    if lib.proc_pid_rusage(pid, 4, ctypes.byref(buf)) != 0:
        return 0
    return struct.unpack_from('Q', buf.raw, 72)[0]


def capped_compile(source, target, log):
    """One Bend compile under a footprint cap below the operator watchdog. The
    pinned compiler's peak varies between compiles of the same source, so an
    attempt that hits the cap is killed and retried; every attempt is logged."""
    for attempt in range(COMPILE_ATTEMPTS):
        started = time.monotonic()
        p = subprocess.Popen([BEND, source, '-o', str(target)], cwd=ROOT, env=ENV, text=True,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        peak, capped = 0, False
        while p.poll() is None:
            peak = max(peak, footprint(p.pid))
            if peak >= COMPILE_CAP_BYTES:
                p.send_signal(signal.SIGKILL)
                capped = True
                break
            time.sleep(0.02)
        output = p.communicate()[0]
        COMPILES.append({'source': source, 'target': str(target.relative_to(ROOT)), 'attempt': attempt,
                         'peak_footprint_bytes': peak, 'capped': capped, 'exit': p.returncode,
                         'elapsed_s': round(time.monotonic() - started, 2)})
        log(f'  compile {source} -> {target.name}: attempt {attempt}, peak {peak / 1e9:.2f} GB'
            + (', hit the cap' if capped else f', exit {p.returncode}'))
        if not capped:
            if p.returncode:
                raise SystemExit(f'native build failed: {source}\n{output}')
            return
    raise SystemExit(f'native build failed: {source} hit the compile cap {COMPILE_ATTEMPTS} times')


def build(log):
    OUT.mkdir(parents=True, exist_ok=True)
    INPUTS.mkdir(parents=True, exist_ok=True)
    global INDEX
    sh([sys.executable, 'tools/generate_cschema.py'])
    INDEX = json.loads((ROOT / 'build/cschema-index.json').read_text())
    sh([sys.executable, 'tools/generate_missing_go_types.py'])
    sh([sys.executable, 'tools/generate_bench_go.py'])
    log('building native Bend benchmark executables (compact primary API)')
    for program in PROGRAMS.values():
        source = f'benchmarks/compact/{program}.bend'
        capped_compile(source, OUT / f'bend-{program}', log)
        capped_compile(source, OUT / f'bend-{program}.c', log)
    log('building native Go reference executable')
    sh(['go', 'build', '-o', str(OUT / 'go-bench'), '.'], cwd=ROOT / 'benchmarks/fastssz')


# ---------------------------------------------------------------------------
# Workloads.

def fixture_workloads(name):
    """Official consensus-spec fixtures for a type, smallest/median/largest."""
    cases = [c for c in json.loads((ROOT / 'cases.json').read_text())
             if c.split('/')[4:5] == [name] and '/ssz_static/' in c]
    prepared = []
    for case in cases:
        directory = ROOT / 'fixtures' / case
        data = snappy.decompress((directory / 'serialized.ssz_snappy').read_bytes())
        root = yaml.load((directory / 'roots.yaml').read_text())['root'].removeprefix('0x')
        prepared.append({'source': 'official fixture ' + case, 'bytes': data, 'root': root})
    prepared.sort(key=lambda w: len(w['bytes']))
    if not prepared:
        return []
    picks = [(prepared[0], 'small'), (prepared[len(prepared) // 2], 'medium'), (prepared[-1], 'large')]
    chosen, seen = [], set()
    for workload, label in picks:
        if id(workload) in seen:
            continue
        seen.add(id(workload))
        workload['workload'] = label + '-fixture'
        chosen.append(workload)
    return chosen


def synthetic_bytes(seed, length):
    """Deterministic pseudo-random bytes: a seeded SHA-256 keystream."""
    out = bytearray()
    counter = 0
    while len(out) < length:
        out += hashlib.sha256(f'{seed}:{counter}'.encode()).digest()
        counter += 1
    return bytes(out[:length])


def synthetic_workloads(name, node):
    """Seeded workloads for the contract types that have no official fixture."""
    kind = node['kind']
    size = fixed_size(node)
    if kind == 'boolean':
        # Only 0x00 and 0x01 are values of this type; both are edge cases.
        return [{'workload': 'false', 'source': 'the byte 0x00', 'bytes': b'\x00'},
                {'workload': 'true', 'source': 'the byte 0x01', 'bytes': b'\x01'}]
    if size is not None:
        return [
            {'workload': 'zero', 'source': f'synthetic all-zero {size} bytes', 'bytes': bytes(size)},
            {'workload': 'random', 'source': f'synthetic seeded {size} bytes', 'bytes': synthetic_bytes(name, size)},
            {'workload': 'saturated', 'source': f'synthetic all-ones {size} bytes', 'bytes': bytes([0xff] * size)},
        ]
    if kind == 'byte_list':
        limit = node['limit']
        sizes = [('small', min(32, limit)), ('medium', min(4096, limit)), ('large', min(1 << 20, limit))]
        return [{'workload': label, 'source': f'synthetic seeded byte list of {length} bytes',
                 'bytes': synthetic_bytes(f'{name}:{label}', length)} for label, length in sizes]
    return []


def workloads_for(name, node):
    chosen = fixture_workloads(name)
    if chosen:
        return chosen
    return synthetic_workloads(name, node)


# ---------------------------------------------------------------------------
# Measurement.

def bend_env(name, path, ops, output=None):
    env = {**ENV, 'SSZ_INDEX': str(INDEX.index(name)), 'SSZ_INPUT': str(path), 'SSZ_OPS': str(ops)}
    if output is not None:
        env['SSZ_OUTPUT'] = str(output)
    return env


def run_bend(name, path, operation, ops, verify):
    program = PROGRAMS[operation]
    output = path.with_suffix('.bend-out.ssz')
    text = sh([str(OUT / f'bend-{program}')] + BEND_FLAGS,
              env=bend_env(name, path, ops, output if program == 'enc' else None))
    milliseconds = int(re.search(r'\bMS=(\d+)', text).group(1))
    result = {'text': text, 'ns': milliseconds * 1_000_000, 'roundtrip': None, 'rootsum': None}
    if 'ROOTSUM=' in text:
        result['rootsum'] = int(re.search(r'ROOTSUM=(\d+)', text).group(1))
    if verify:
        # Round trip: decode then encode through the compact API must give the
        # input bytes back exactly; root: the checksum Go also prints.
        output.unlink(missing_ok=True)
        sh([str(OUT / 'bend-enc')] + BEND_FLAGS, env=bend_env(name, path, 1, output))
        result['roundtrip'] = output.exists() and output.read_bytes() == path.read_bytes()
        output.unlink(missing_ok=True)
        rooted = sh([str(OUT / 'bend-root')] + BEND_FLAGS, env=bend_env(name, path, 1))
        result['rootsum'] = int(re.search(r'ROOTSUM=(\d+)', rooted).group(1))
    return result


def run_go(name, impl, path, operation, ops):
    text = sh([str(OUT / 'go-bench'), name, impl, str(path), operation, str(ops)])
    return {'text': text, 'ns': int(re.search(r'\bNS=(\d+)', text).group(1)),
            'roundtrip': 'ROUNDTRIP=true' in text,
            'rootsum': int(re.search(r'ROOTSUM=(\d+)', text).group(1))}


def rejects(command, env=None):
    """True when the implementation refuses the input (non-zero exit)."""
    result = subprocess.run(command, cwd=ROOT, env=env or ENV, text=True, capture_output=True)
    return result.returncode != 0


def rejection_checks(name, impl, case, path):
    """Malformed inputs must be refused by both implementations.

    The mutations are the three structural failures SSZ must catch: a byte
    short, a byte too many, and - for variable-size types - an offset outside
    the region. The workload itself is known good, so any acceptance here is a
    real fault, and the two implementations are required to agree.
    """
    data = case['bytes']
    mutations = [('truncated', data[:-1]) if len(data) > 0 else None,
                 ('extended', data + b'\x00')]
    if len(data) >= 4 and int.from_bytes(data[:4], 'little') in range(4, len(data) + 1):
        mutations.append(('offset-out-of-range', (0xffffffff).to_bytes(4, 'little') + data[4:]))
    results = []
    for mutation in mutations:
        if mutation is None:
            continue
        label, mutated = mutation
        broken = path.with_suffix('.' + label + '.ssz')
        broken.write_bytes(mutated)
        bend_rejected = rejects([str(OUT / 'bend-dec')] + BEND_FLAGS, bend_env(name, broken, 1))
        reference_rejected = rejects([str(OUT / 'go-bench'), name, impl, str(broken), 'deserialize', '1'])
        broken.unlink(missing_ok=True)
        results.append({'type': name, 'workload': case['workload'], 'mutation': label,
                        'bend_rejected': bend_rejected, 'reference_rejected': reference_rejected,
                        'agree': bend_rejected == reference_rejected})
    return results


def calibrate(measure, ops=1):
    """Grow the batch until one sample is long enough to time precisely."""
    while ops < MAX_OPS:
        elapsed = measure(ops)['ns']
        if elapsed >= TARGET_SECONDS * 1e9:
            return ops, elapsed
        factor = max(2, min(64, int(TARGET_SECONDS * 1e9 / max(elapsed, 1e6))))
        ops = min(MAX_OPS, ops * factor)
    return ops, None


def choose_reference(name, candidates, path, official, log):
    """Pick the reference implementation that agrees with this workload.

    Several go-eth2-client packages define the same type name with different
    list limits, so reproducing the bytes is not enough: where the workload is
    an official fixture the candidate must also produce the official root.
    """
    fallback = None
    for impl in candidates:
        try:
            result = run_go(name, impl, path, 'hash_tree_root', 1)
        except SystemExit:
            continue
        if not result['roundtrip']:
            continue
        if official is None or result['rootsum'] == official:
            return impl, result
        fallback = fallback or (impl, result)
    if fallback:
        log(f'  no pinned reference implementation of {name} reproduces the official root')
    else:
        log(f'  no pinned reference implementation round-trips {name}')
    return None, None


# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--report', required=True)
    parser.add_argument('--only', default=None, help='comma separated type names')
    parser.add_argument('--samples', type=int, default=MIN_SAMPLES)
    arguments = parser.parse_args()
    report_path = Path(arguments.report).resolve()
    report_path.parent.mkdir(parents=True, exist_ok=True)
    log_path = OUT / 'benchmark.log'
    OUT.mkdir(parents=True, exist_ok=True)
    raw = open(log_path, 'w')

    def log(message):
        print(message, flush=True)
        raw.write(message + '\n')
        raw.flush()

    build(log)
    schemas = Schemas()
    coverage = json.loads((ROOT / 'benchmarks/reference_coverage.json').read_text())
    names = sorted({op.rsplit('.', 1)[0] for op in CONTRACT['required_operations']})
    if arguments.only:
        names = [n for n in names if n in arguments.only.split(',')]

    # Reference implementation keys, as generated.
    generated = (ROOT / 'benchmarks/fastssz/generated.go').read_text()
    container_candidates = {}
    for m in re.finditer(r'^\t"(\w+)": \{(.+)\},$', generated, re.M):
        keys = re.findall(r'"([\w.]+)"', m.group(2))
        if keys and all('.' in k for k in keys):
            container_candidates[m.group(1)] = keys
    simple_types = set(coverage['simple_types'])

    rows, skipped, rejections = [], [], []
    for name in names:
        node = schemas.resolve(name)
        cases = workloads_for(name, node)
        if not cases:
            skipped.append({'type': name, 'reason': 'no workload could be prepared'})
            continue
        for case in cases:
            path = INPUTS / f'{name}.{case["workload"]}.ssz'
            path.write_bytes(case['bytes'])
            official = sum(bytes.fromhex(case['root'])) if 'root' in case else None
            if name in simple_types:
                impl, probe = 'simple', run_go(name, 'simple', path, 'hash_tree_root', 1)
                if not probe['roundtrip']:
                    skipped.append({'type': name, 'workload': case['workload'],
                                    'reason': 'reference did not round-trip the workload'})
                    continue
            else:
                impl, probe = choose_reference(name, container_candidates.get(name, []), path, official, log)
                if impl is None:
                    skipped.append({'type': name, 'workload': case['workload'],
                                    'reason': 'no pinned go-eth2-client type reproduces these bytes'})
                    continue
            try:
                first = run_bend(name, path, 'hash_tree_root', 1, verify=True)
            except SystemExit as failure:
                skipped.append({'type': name, 'workload': case['workload'],
                                'reason': 'the Bend implementation refused this workload: '
                                          + str(failure).splitlines()[-1][:200]})
                continue
            agreed = bool(first['roundtrip'] and probe['roundtrip'] and first['rootsum'] == probe['rootsum']
                          and (official is None or first['rootsum'] == official))
            if not agreed:
                skipped.append({'type': name, 'workload': case['workload'],
                                'reason': f'implementations disagree (bend rootsum {first["rootsum"]},'
                                          f' reference {probe["rootsum"]}, official '
                                          f'{official if official is not None else "n/a"})'})
                continue
            rejections.extend(rejection_checks(name, impl, case, path))
            for operation in OPERATIONS:
                ops, _ = calibrate(lambda n: run_bend(name, path, operation, n, verify=False))
                bend_ns, reference_ns = [], []
                for index in range(arguments.samples):
                    order = ['bend', 'go'] if index % 2 == 0 else ['go', 'bend']
                    for side in order:
                        if side == 'bend':
                            bend_ns.append(run_bend(name, path, operation, ops, verify=False)['ns'] / ops)
                        else:
                            reference_ns.append(run_go(name, impl, path, operation, ops)['ns'] / ops)
                row = {
                    'operation': f'{name}.{operation}',
                    'workload': case['workload'],
                    'size': len(case['bytes']),
                    'verified': agreed,
                    'operations_per_sample': ops,
                    'bend_ns': bend_ns,
                    'reference_ns': reference_ns,
                    'reference_implementation': impl,
                    'workload_source': case['source'],
                    'root_checksum': first['rootsum'],
                    'official_root_checksum': official,
                }
                row['bend_median_ns'] = statistics.median(bend_ns)
                row['reference_median_ns'] = statistics.median(reference_ns)
                row['ratio'] = row['bend_median_ns'] / row['reference_median_ns']
                rows.append(row)
                log(f'{row["operation"]:<48} {case["workload"]:<16} x{ops:<8} '
                    f'bend {row["bend_median_ns"]:>12.1f} ns  ref {row["reference_median_ns"]:>10.1f} ns  '
                    f'{row["ratio"]:>8.1f}x')
    raw.close()

    environment = {
        'cpu': subprocess.run(['sysctl', '-n', 'machdep.cpu.brand_string'], capture_output=True, text=True).stdout.strip(),
        'os': platform.platform(),
        'bend_compiler': sh([BEND, '--version']).strip() if shutil_which(BEND) else 'bend 2.0.16',
        'reference_compiler': sh(['go', 'version']).strip(),
        'bend_flags': ' '.join(BEND_FLAGS) + ' (native C backend, release build)',
        'reference_flags': 'go build (release defaults), GOMAXPROCS=1',
        'reference_revision': 'go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod)',
    }
    sources = {}
    for folder in ['src', 'types', 'proofs', 'spec', 'benchmarks', 'native_bench']:
        base = ROOT / folder
        if base.exists():
            for path in base.rglob('*'):
                if path.is_file() and path.suffix in ['.bend', '.c', '.h', '.py', '.go', '.json', '.mod', '.sum', '.sh']:
                    sources[str(path.relative_to(ROOT))] = digest(path)
    for path in ROOT.glob('*.bend'):
        sources[str(path.relative_to(ROOT))] = digest(path)
    artifacts = {str(p.relative_to(ROOT)): digest(p)
                 for p in [OUT / f'bend-{program}' for program in PROGRAMS.values()]
                 + [OUT / f'bend-{program}.c' for program in PROGRAMS.values()]
                 + [OUT / 'go-bench', log_path]}
    report = {
        'backend': 'native-c',
        'reference': CONTRACT['reference'],
        'generated_at': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
        'environment': environment,
        'source_sha256': sources,
        'artifacts': artifacts,
        'benchmarks': rows,
        'skipped': skipped,
        'rejection_checks': rejections,
        'bend_api': 'compact primary API: benchmarks/compact/{dec,enc,root}.bend',
        'bend_compiles': COMPILES,
        'rejection_summary': {
            'checks': len(rejections),
            'bend_rejected': sum(1 for r in rejections if r['bend_rejected']),
            'reference_rejected': sum(1 for r in rejections if r['reference_rejected']),
            'disagreements': [r for r in rejections if not r['agree']],
        },
        'coverage': {
            'required_operations': len(CONTRACT['required_operations']),
            'covered_operations': len({row['operation'] for row in rows}),
            'missing_operations': sorted(set(CONTRACT['required_operations']) - {row['operation'] for row in rows}),
        },
    }
    report_path.write_text(json.dumps(report, indent=2) + '\n')
    print(f'{len(rows)} workloads, {report["coverage"]["covered_operations"]} of '
          f'{report["coverage"]["required_operations"]} required operations covered')


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def shutil_which(command):
    return Path(command).is_file()


if __name__ == '__main__':
    main()
