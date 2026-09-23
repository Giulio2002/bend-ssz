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
* each side independently calibrates its repetition count toward a 250 ms
  sample (capped at five million operations); every result is consumed;
* timings are normalized by that side's actual count. `operations_per_sample`
  is the Bend count for report compatibility; `reference_operations_per_sample`
  is the Go count. Both counts and all per-operation samples are recorded;
  capped short batches can still be affected by timer quantization;
* samples alternate between the two implementations, at least five each, in a
  fresh process per sample.

The Bend side is the typed owning object API (types/fulu_obj.bend, generated
from codegen/fulu.yaml), measured through benchmarks/objprog/g*.bend - one
program per group of names, because the pinned compiler cannot fit all 109
types into one program's compile budget:

* deserialize - bytes to a fully constructed typed object: the generated
  validator, the generated reader that builds the record and its owned packed
  collections, and a fold over every field of the result so that no
  construction work is left unevaluated (record fields are lazy);
* serialize - object to fresh canonical bytes, after one untimed decode (Go
  likewise decodes into its struct before timing MarshalSSZ); each encoding is
  consumed by reading its last word;
* hash_tree_root - the root of that object, with one hasher (a Merkle scratch
  buffer with its zero table) created before the clock starts, as fastssz
  reuses its package-level zero-hash table; every root is consumed.

The name is selected by its index in the frozen schema order; the program that
holds it is types/obj_groups.json. The verification pass for every workload
decodes, re-encodes (which must reproduce the input byte for byte) and hashes
the object.
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

# The operator's validation interpreter has no python-snappy or YAML library, so
# fixtures are read with the checked pure-Python block decoder
# (benchmarks/snappy_block.py; benchmarks/checks/snappy_check.py compares it with
# python-snappy on all 5,440 fixtures) and the one-line roots.yaml by pattern.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import snappy_block as snappy  # noqa: E402

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


def bend_version():
    # 2.0.25 answers `bend version`; 2.0.16 answered `bend --version`
    for flag in ('version', '--version'):
        r = subprocess.run([BEND, flag], cwd=ROOT, env=ENV, text=True, capture_output=True)
        if r.returncode == 0 and r.stdout.startswith('bend '):
            return r.stdout.strip()
    raise SystemExit('cannot determine the Bend compiler version')


def sh(command, cwd=ROOT, env=ENV):
    result = subprocess.run(command, cwd=cwd, env=env, text=True, capture_output=True)
    if result.returncode:
        raise SystemExit(f'command failed: {command}\n{result.stdout}\n{result.stderr}')
    return result.stdout


# The measured API is the typed owning object API: one generated program per
# group of names (benchmarks/objprog/g*.bend), SSZ_MODE selecting the
# operation (1 decode, 2 encode, 3 root; 0 decodes, encodes and hashes once
# for the verification pass).
MODES = {'deserialize': '1', 'serialize': '2', 'hash_tree_root': '3'}
GROUPS = json.loads((ROOT / 'types/obj_groups.json').read_text()) if (ROOT / 'types/obj_groups.json').exists() else {}
PY3 = '/opt/homebrew/bin/python3'   # the generator needs PyYAML
COMPILE_CAP_BYTES = 6.5e9
COMPILE_ATTEMPTS = 4
# The pinned compiler is a Bun (JavaScriptCore) executable. On a loaded machine
# its collector falls behind and one compile of the same source peaks anywhere
# from 5 to over 6.5 GB. Telling JSC to size its heap for 3 GB of RAM makes it
# collect earlier (2.98-3.77 GB, against 6.20 GB without it), and the emitted
# C is byte-identical. This affects compiler processes only; the measured
# programs are native C.
COMPILE_ENV = {**ENV, 'BUN_JSC_forceRAMSize': '3000000000'}
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
        p = subprocess.Popen([BEND, source, '-o', str(target)], cwd=ROOT, env=COMPILE_ENV, text=True,
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
    global GROUPS
    sh([PY3, 'codegen/check_schema.py'])
    sh([PY3, 'codegen/generate.py'])
    GROUPS = json.loads((ROOT / 'types/obj_groups.json').read_text())
    sh([sys.executable, 'tools/generate_missing_go_types.py'])
    sh([sys.executable, 'tools/generate_bench_go.py'])
    sources = source_manifest()
    (OUT / 'source-before-build.json').write_text(json.dumps(sources, indent=2) + '\n')
    log('building native Bend benchmark executables (typed object API)')
    for k in sorted({g['group'] for g in GROUPS.values()}):
        source = f'benchmarks/objprog/g{k}.bend'
        capped_compile(source, OUT / f'bend-obj-g{k}', log)
        capped_compile(source, OUT / f'bend-obj-g{k}.c', log)
    log('building native Go reference executable')
    sh(['go', 'build', '-o', str(OUT / 'go-bench'), '.'], cwd=ROOT / 'benchmarks/fastssz')
    if source_manifest() != sources:
        raise SystemExit('Sources changed during compilation; refusing mixed-source benchmark')
    return sources


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
        root = re.search(r"^root: '0x([0-9a-f]{64})'\s*$", (directory / 'roots.yaml').read_text(), re.M).group(1)
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

def bend_program(name):
    return OUT / f"bend-obj-g{GROUPS[name]['group']}"


def bend_env(name, path, ops, mode='1', output=None):
    env = {**ENV, 'SSZ_MODE': mode, 'SSZ_INDEX': str(GROUPS[name]['index']),
           'SSZ_INPUT': str(path), 'SSZ_OPS': str(ops)}
    if output is not None:
        env['SSZ_OUTPUT'] = str(output)
    return env


def run_bend(name, path, operation, ops, verify):
    output = path.with_suffix('.bend-out.ssz')
    text = sh([str(bend_program(name))] + BEND_FLAGS,
              env=bend_env(name, path, ops, MODES[operation],
                           output if operation == 'serialize' else None))
    milliseconds = int(re.search(r'\bMS=(\d+)', text).group(1))
    result = {'text': text, 'ns': milliseconds * 1_000_000, 'roundtrip': None, 'rootsum': None}
    if 'ROOTSUM=' in text:
        result['rootsum'] = int(re.search(r'ROOTSUM=(\d+)', text).group(1))
    if verify:
        # One verification run of the object API on this workload: decode into
        # the typed object, encode it into fresh bytes (which must equal the
        # input byte for byte) and hash the object (the checksum Go prints).
        output.unlink(missing_ok=True)
        checked = sh([str(bend_program(name))] + BEND_FLAGS,
                     env=bend_env(name, path, 1, '0', output))
        result['roundtrip'] = output.exists() and output.read_bytes() == path.read_bytes()
        output.unlink(missing_ok=True)
        result['rootsum'] = int(re.search(r'ROOTSUM=(\d+)', checked).group(1))
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
        bend_rejected = rejects([str(bend_program(name))] + BEND_FLAGS, bend_env(name, broken, 1, '1'))
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


def measure_pair(bend, reference, samples):
    """Same workload/operation, independently calibrated native batches."""
    bend_ops, _ = calibrate(bend)
    reference_ops, _ = calibrate(reference)
    bend_ns, reference_ns = [], []
    for index in range(samples):
        order = ['bend', 'go'] if index % 2 == 0 else ['go', 'bend']
        for side in order:
            if side == 'bend':
                bend_ns.append(bend(bend_ops)['ns'] / bend_ops)
            else:
                reference_ns.append(reference(reference_ops)['ns'] / reference_ops)
    return bend_ops, reference_ops, bend_ns, reference_ns


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

    sources = build(log)
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
                ops, reference_ops, bend_ns, reference_ns = measure_pair(
                    lambda n: run_bend(name, path, operation, n, verify=False),
                    lambda n: run_go(name, impl, path, operation, n),
                    arguments.samples)
                row = {
                    'operation': f'{name}.{operation}',
                    'workload': case['workload'],
                    'size': len(case['bytes']),
                    'verified': agreed,
                    'operations_per_sample': ops,
                    'reference_operations_per_sample': reference_ops,
                    'calibration': 'independent-per-side',
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
        'bend_compiler': bend_version(),
        'reference_compiler': sh(['go', 'version']).strip(),
        'bend_flags': ' '.join(BEND_FLAGS) + ' (native C backend, release build)',
        'reference_flags': 'go build (release defaults), GOMAXPROCS=1',
        'reference_revision': 'go-eth2-client v0.27.2 with fastssz v0.1.4 (pinned in benchmarks/fastssz/go.mod)',
    }
    final_sources = source_manifest()
    changed_sources = sorted(k for k in sources.keys() | final_sources.keys()
                             if sources.get(k) != final_sources.get(k))
    groups = sorted({g['group'] for g in GROUPS.values()})
    artifacts = {str(p.relative_to(ROOT)): digest(p)
                 for p in [OUT / f'bend-obj-g{k}' for k in groups]
                 + [OUT / f'bend-obj-g{k}.c' for k in groups]
                 + [OUT / 'go-bench', log_path]}
    report = {
        'backend': 'native-c',
        'reference': CONTRACT['reference'],
        'generated_at': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
        'environment': environment,
        'source_sha256': sources,
        'source_sha256_capture': 'after generators, before compilation',
        'source_unchanged': not changed_sources,
        'source_changes_during_measurement': changed_sources,
        'artifacts': artifacts,
        'benchmarks': rows,
        'skipped': skipped,
        'rejection_checks': rejections,
        'bend_api': 'typed owning object API: types/fulu_obj.bend through benchmarks/objprog/g*.bend '
                    '(decode builds the object, encode writes fresh bytes from it, root hashes it)',
        'bend_compiles': COMPILES,
        'bend_compile_env': {'BUN_JSC_forceRAMSize': COMPILE_ENV['BUN_JSC_forceRAMSize']},
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
    if changed_sources:
        raise SystemExit('Sources changed during measurement; report is historical only: '
                         + ', '.join(changed_sources))


def source_manifest():
    """Hash source inputs, excluding generated measurement outputs.

    Called after code generation but BEFORE compilation. The final report must
    retain these hashes even if the worker edits source while timing runs.
    """
    sources = {}
    suffixes = {'.bend', '.c', '.h', '.py', '.go', '.json', '.mod', '.sum', '.sh', '.ts'}
    for folder in ['src', 'types', 'proofs', 'spec', 'benchmarks', 'native_bench', 'tools', 'automation']:
        base = ROOT / folder
        if not base.exists():
            continue
        for path in base.rglob('*'):
            relative = path.relative_to(ROOT)
            # benchmarks/evidence is hashed too: the frozen gate
            # (automation/performance_gate.py) requires a current hash for every
            # .json/.py under benchmarks/, evidence included, and rejected a
            # report that left them out. The runner never writes there; the
            # evidence must simply stay unchanged while a run is in progress.
            if folder == 'benchmarks' and len(relative.parts) > 1 and relative.parts[1] == 'inputs':
                continue
            if path.is_file() and path.suffix in suffixes and '__pycache__' not in relative.parts:
                sources[str(relative)] = digest(path)
    for path in list(ROOT.glob('*.bend')) + [ROOT / 'cases.json']:
        if path.is_file():
            sources[str(path.relative_to(ROOT))] = digest(path)
    return sources


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def shutil_which(command):
    return Path(command).is_file()


if __name__ == '__main__':
    main()
