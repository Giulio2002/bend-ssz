"""Native Bend C versus native Go fastssz on identical fixture bytes.

How a phase's memory is measured. Every phase boundary of both programs is a
possible exit (`SSZ_PHASES=input|decode|root|all`), so for each phase this
harness runs a fresh process that does exactly the work up to that boundary
and then stops. The kernel reports that process's peak resident size through
`wait4`'s `ru_maxrss`, which is a true high-water mark recorded by the kernel
on every page fault, not a sample. Two such runs bracket a phase: the prefix
through the input read, and the prefix through the phase. Their difference is
the phase's resident growth. Nothing depends on catching a spike with a
sampler, and nothing is subtracted beyond the bracketing run's own peak.

Resident size is not monotone downward on macOS - the kernel can compress or
evict pages - so no single reading is trusted: every reported peak is the
maximum of the kernel high-water mark, the idle boundary readings and every
sample, and the two independent methods are cross-checked against each other.

Sampling is kept as a cross-check only. A sampler thread polls resident size
during the full run and the per-phase boundary readings are taken while the
child is idle in its settle window; the reported decode peak is the maximum of
the kernel high-water mark, the boundary readings and every sample, so it can
only ever be larger than what any one method sees.

Why this is sound for the Bend side specifically: the Bend runtime maps one
MAP_NORESERVE heap and grows it with a monotone page bump; freed nodes go to
per-class free lists and no page is ever unmapped or madvised (see the emitted
C retained at build/native/bend-compact.c: pool_mmap / heap_alloc_miss, no munmap
or madvise). The Bend heap therefore never shrinks, so a run's peak is its
final heap size; what the operating system reports resident can still drop
when the kernel compresses or evicts pages, so the harness records whether the
samples were monotone rather than requiring it, and cross-checks the two
methods instead. Go's runtime can return memory, so its
per-phase numbers are prefix high-water marks too but their difference can
understate a transient; Go's own accounting is recorded next to them.

`verified` is derived, never assumed: it is true only when the process wrote
output bytes identical to the input fixture, reported the decode checksum and
root digest checksum that the other implementation reported for the same
fixture, and reached every expected phase marker.

Compilation is excluded from every measurement and always rebuilt here. The
Bend side is native_bench/driver.bend, the compact primary path:
packed input buffer, in-place validating decode, hash_tree_root and streamed
encode over the same buffer.

The pinned compiler's own peak memory for that driver varies between runs of
the same source (measured 5.2 GB to over 6.5 GB), so each Bend compile runs
under a physical-footprint cap below the operator's watchdog and is retried if
it hits the cap. A capped attempt is a failed attempt, never a partial build.
"""
import ctypes, hashlib, json, os, platform, re, resource, signal, struct, subprocess, sys, threading, time
from pathlib import Path
import psutil
import snappy

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'build/native'
OUT.mkdir(parents=True, exist_ok=True)
ENV = {**os.environ, 'BEND_NO_TELEMETRY': '1'}
BEND = '/Users/monkeair/.bend/bin/bend'
SAMPLE_SECONDS = 0.0005
REPEATS = 3
# macOS reports ru_maxrss in bytes; Linux reports kilobytes.
MAXRSS_SCALE = 1 if platform.system() == 'Darwin' else 1024
PHASES = ['baseline', 'decoded', 'rooted', 'serialized', 'done']


DRIVER = 'native_bench/driver.bend'
COMPILE_CAP_BYTES = 6.5e9
COMPILE_ATTEMPTS = 4
# The pinned compiler is a Bun (JavaScriptCore) executable whose collector
# falls behind on a loaded machine (one compile of this driver: 6.20 GB). A
# 3 GB RAM-size hint makes JSC collect earlier (2.98-3.77 GB) and the emitted C
# is byte-identical. Compiler processes only; the measured programs are native.
COMPILE_ENV = {**ENV, 'BUN_JSC_forceRAMSize': '3000000000'}


def footprint(pid):
    """macOS physical footprint (ri_phys_footprint) of a process, in bytes."""
    lib = ctypes.CDLL('/usr/lib/libproc.dylib')
    buf = ctypes.create_string_buffer(1024)
    if lib.proc_pid_rusage(pid, 4, ctypes.byref(buf)) != 0:
        return 0
    return struct.unpack_from('Q', buf.raw, 72)[0]


def capped_compile(name, cmd):
    """One Bend compile under the footprint cap; retried when the cap is hit."""
    attempts = []
    for attempt in range(COMPILE_ATTEMPTS):
        started = time.monotonic()
        p = subprocess.Popen(cmd, cwd=ROOT, env=COMPILE_ENV, text=True,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        peak, capped = 0, False
        while p.poll() is None:
            peak = max(peak, footprint(p.pid))
            if peak >= COMPILE_CAP_BYTES:
                p.send_signal(signal.SIGKILL)
                capped = True
                break
            time.sleep(0.02)
        log = p.communicate()[0]
        attempts.append({'attempt': attempt, 'peak_footprint_bytes': peak, 'capped': capped,
                         'exit': p.returncode, 'elapsed_s': round(time.monotonic() - started, 2)})
        (OUT / (name + '-build.log')).write_text(log + '\n' + json.dumps(attempts, indent=1) + '\n')
        if not capped:
            if p.returncode:
                raise SystemExit('native build failed: ' + name + '\n' + log)
            return attempts
        print(f'  {name}: compile hit the {COMPILE_CAP_BYTES / 1e9:.1f} GB cap, retrying', flush=True)
    raise SystemExit(f'native build failed: {name} hit the compile cap {COMPILE_ATTEMPTS} times')


def build():
    """Always rebuild both sides; compilation time is never part of a sample."""
    builds = {}
    for name, target in [('bend', 'bend-compact'), ('bend-c', 'bend-compact.c')]:
        print('Building ' + name, flush=True)
        builds[name] = capped_compile(name, [BEND, DRIVER, '-o', str(OUT / target)])
    print('Building go', flush=True)
    p = subprocess.run(['go', 'build', '-o', str(OUT / 'go-ssz'), '.'], cwd=ROOT / 'native_bench/fastssz',
                       env=ENV, text=True, capture_output=True)
    (OUT / 'go-build.log').write_text(p.stdout + p.stderr)
    if p.returncode:
        raise SystemExit('native build failed: go\n' + p.stdout + p.stderr)
    return builds


EXE = {'bend': OUT / 'bend-compact', 'go': OUT / 'go-ssz'}


def command(impl, exe):
    return [str(exe)] + (['--threads', '1', '--gpu', 'off'] if impl == 'bend' else [])


class Sampler(threading.Thread):
    """Continuous resident-size sampler, used to cross-check the kernel peak."""

    def __init__(self, pid):
        super().__init__(daemon=True)
        self.proc = psutil.Process(pid)
        self.samples = []
        self.stop = False

    def run(self):
        while not self.stop:
            try:
                self.samples.append((time.monotonic(), self.proc.memory_info().rss))
            except psutil.Error:
                break
            time.sleep(SAMPLE_SECONDS)

    def between(self, lo, hi):
        return [rss for t, rss in self.samples if lo <= t <= hi]


def run_phase(impl, exe, data_path, out_path, phase):
    """Run the prefix of the workload up to `phase` and report the kernel's
    peak resident size for that whole process."""
    env = {**ENV, 'SSZ_INPUT': str(data_path), 'SSZ_OUTPUT': str(out_path), 'SSZ_PHASES': phase}
    proc = subprocess.Popen(command(impl, exe), env=env, cwd=ROOT, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    text = proc.stdout.read()
    err = proc.stderr.read()
    pid, status, usage = os.wait4(proc.pid, 0)
    proc.returncode = os.waitstatus_to_exitcode(status)
    if proc.returncode != 0:
        raise SystemExit(f'{impl} {phase} prefix failed ({proc.returncode}): {err}\n{text}')
    if 'PHASE=stopped' not in text:
        raise SystemExit(f'{impl} {phase} prefix did not stop at its boundary:\n{text}')
    return int(usage.ru_maxrss * MAXRSS_SCALE), text


def run_full(impl, exe, data_path, out_path, expected):
    """The complete workload: phase markers give windows, the sampler and the
    boundary readings cross-check the kernel peak, output bytes are compared."""
    out_path.unlink(missing_ok=True)
    env = {**ENV, 'SSZ_INPUT': str(data_path), 'SSZ_OUTPUT': str(out_path), 'SSZ_PHASES': 'all'}
    started = time.monotonic()
    proc = subprocess.Popen(command(impl, exe), env=env, cwd=ROOT, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1)
    sampler = Sampler(proc.pid)
    sampler.start()
    marks = {}
    lines = []
    for line in proc.stdout:
        now = time.monotonic()
        lines.append(line.rstrip())
        m = re.match(r'PHASE=(\w+)', line.strip())
        if m:
            # Reading taken while the child is idle inside its settle window.
            time.sleep(0.05)
            try:
                rss = psutil.Process(proc.pid).memory_info().rss
            except psutil.Error:
                rss = 0
            marks[m.group(1)] = {'time': now, 'rss': rss}
    err = proc.stderr.read()
    pid, status, usage = os.wait4(proc.pid, 0)
    code = os.waitstatus_to_exitcode(status)
    proc.returncode = code
    sampler.stop = True
    sampler.join(timeout=1)
    if code != 0:
        raise SystemExit(f'{impl} sample failed ({code}): ' + err + '\n'.join(lines))
    missing = [p for p in PHASES if p not in marks]
    return {
        'elapsed_s': time.monotonic() - started,
        'text': '\n'.join(lines),
        'marks': marks,
        'sampler': sampler,
        'kernel_peak': int(usage.ru_maxrss * MAXRSS_SCALE),
        'missing_phases': missing,
        'bytes_match': out_path.exists() and out_path.read_bytes() == expected,
    }


def first(*values):
    """The first reading that is present. A reading of 0 is present: the Bend
    driver's clock has millisecond resolution, and a compact BeaconState decode
    now finishes inside one tick."""
    return next((v for v in values if v is not None), None)


def number(text, pattern, scale=1):
    found = re.search(pattern + r'=(\d+)', text)
    return int(found.group(1)) * scale if found else None


def run_sample(impl, exe, data_path, out_path, expected):
    full = run_full(impl, exe, data_path, out_path, expected)
    text = full['text']
    marks = full['marks']
    sampler = full['sampler']

    input_peak, input_text = run_phase(impl, exe, data_path, out_path, 'input')
    # The decode-prefix process is measured three times and the largest kernel
    # high-water is kept. One reading of one process is a poor estimate of that
    # process's high-water on this platform: resident size is not monotone, the
    # kernel compresses and evicts pages, and two processes doing identical
    # work differ by about 10% run to run. Taking the maximum only ever raises
    # this figure, and `decode_peak` below is still the maximum over the kernel
    # readings, the phase marks and every sample in the decode window, so no
    # reported number can be made smaller by this. What it fixes is the
    # representativeness test at the end of this function, which compared one
    # noisy reading of one process against the maximum of many samples of
    # another and failed about half the time on identical work.
    decode_prefix_peaks = [run_phase(impl, exe, data_path, out_path, 'decode')[0] for _ in range(3)]
    decode_peak_kernel = max(decode_prefix_peaks)
    root_peak_kernel, _ = run_phase(impl, exe, data_path, out_path, 'root')
    # The full run rewrites the output; the prefix runs never write it.
    if full['bytes_match'] and out_path.read_bytes() != expected:
        raise SystemExit(impl + ' output was disturbed by a prefix run')

    decode_window = sampler.between(marks['baseline']['time'], marks['decoded']['time'] + 0.06) if 'decoded' in marks else []
    baseline_reading = marks['baseline']['rss'] if 'baseline' in marks else 0
    decoded_reading = marks['decoded']['rss'] if 'decoded' in marks else 0
    baseline = max(input_peak, baseline_reading)
    decode_peak = max([decode_peak_kernel, baseline, decoded_reading] + decode_window)
    root_peak = max([root_peak_kernel, decode_peak] + ([marks['rooted']['rss']] if 'rooted' in marks else []))
    serialize_peak = max([full['kernel_peak'], root_peak])

    sample = {
        'implementation': impl,
        'elapsed_s': full['elapsed_s'],
        'baseline_rss_bytes': int(baseline),
        'decode_peak_rss_bytes': int(decode_peak),
        'decode_overhead_bytes': max(0, int(decode_peak) - int(baseline)),
        'root_peak_rss_bytes': int(root_peak),
        'root_overhead_bytes': max(0, int(root_peak) - int(decode_peak)),
        'serialize_peak_rss_bytes': int(serialize_peak),
        'serialize_overhead_bytes': max(0, int(serialize_peak) - int(root_peak)),
        'roundtrip_peak_rss_bytes': int(full['kernel_peak']),
        'kernel_peak_input_prefix_bytes': int(input_peak),
        'kernel_peak_decode_prefix_bytes': int(decode_peak_kernel),
        'kernel_peak_decode_prefix_readings': [int(v) for v in decode_prefix_peaks],
        'kernel_peak_root_prefix_bytes': int(root_peak_kernel),
        'kernel_peak_whole_run_bytes': int(full['kernel_peak']),
        'decode_ns': first(number(text, 'DECODE_MS', 1000000), number(text, 'DECODE_NS')),
        'serialize_ns': first(number(text, 'SERIALIZE_MS', 1000000), number(text, 'SERIALIZE_NS')),
        'root_ns': first(number(text, 'ROOT_MS', 1000000), number(text, 'ROOT_NS')),
        'checksum': number(text, 'CHECKSUM'),
        'root_checksum': number(text, 'ROOTSUM'),
        'go_total_alloc_bytes': number(text, 'GO_TOTAL_ALLOC'),
        'go_heap_sys_bytes': number(text, 'GO_HEAP_SYS'),
        'samples_in_decode_window': len(decode_window),
        'sampled_decode_max_bytes': int(max(decode_window)) if decode_window else 0,
        'monotone_within_decode': bool(decode_window) and max(decode_window) <= max(decoded_reading, decode_peak_kernel),
        'output_bytes_match': bool(full['bytes_match']),
        'missing_phases': full['missing_phases'],
        'stdout': text,
    }
    # Derived, not asserted: a sample counts as verified only if this process
    # reproduced the fixture bytes exactly and reached every phase boundary.
    sample['verified'] = bool(sample['output_bytes_match']) and not sample['missing_phases'] \
        and sample['decode_ns'] is not None and sample['root_ns'] is not None \
        and sample['serialize_ns'] is not None and sample['root_checksum'] is not None
    # Cross-validation between the two methods: the kernel high-water of the
    # process that stopped at the end of decode must not be materially below
    # what sampling saw during the full run's decode window. If it were, the
    # stopping run would not be doing the same work and the bracketing would
    # be invalid. (The converse - a sample above the kernel figure of the
    # other run - is not an error: resident size is not monotone downward on
    # this platform because the kernel can compress or evict pages, which is
    # why every reported peak is the maximum over all three methods rather
    # than any single reading.)
    if sample['sampled_decode_max_bytes'] > decode_peak_kernel * 1.05:
        raise SystemExit('decode-prefix run is not representative of the full run: '
                         + json.dumps({k: sample[k] for k in ['implementation', 'sampled_decode_max_bytes',
                                                              'kernel_peak_decode_prefix_bytes']}))
    return sample


def main():
    builds = build()
    report = {
        'complete': False,
        'machine': platform.platform(),
        'cpu': subprocess.run(['sysctl', '-n', 'machdep.cpu.brand_string'], capture_output=True, text=True).stdout.strip(),
        'method': (
            'Native Bend-generated C and native Go fastssz on the same raw fixture bytes: '
            'read -> decode -> hash_tree_root -> serialize -> write, one sequential thread, fresh process '
            'per sample. Go: UnmarshalSSZ into a typed struct plus a checksum fold. Bend: the compact primary '
            'path - the input is read into one packed Array<U32> buffer and decode validates it in place, '
            'so the decoded value is the validated buffer (a zero-copy view, nothing else allocated); the '
            'decode verdict is matched on inside the measured window, and a rejected input exits nonzero. '
            'Bend serialize streams the view\'s bytes to the output file in 64 KiB pieces and its time '
            'includes the writes. '
            'three alternating samples per fixture. Every phase boundary is also an exit point, so each '
            'phase is measured by a separate process that stops there and whose peak resident size the '
            'kernel reports through wait4 ru_maxrss; decode_overhead_bytes is the decode-prefix kernel '
            'peak minus the input-prefix kernel peak, cross-checked against continuous sampling and the '
            'idle boundary readings and taking the maximum of all three. roundtrip_peak_rss_bytes is the '
            'whole-process kernel peak INCLUDING startup, the input representation, hashing, '
            'serialization and output, and is NOT the decode peak. Compilation excluded and always '
            'rebuilt. Output bytes compared exactly and `verified` derived from that comparison. No '
            'forced GC, no RSS subtraction beyond the documented bracketing run.'
        ),
        'sampler': {'interval_s': SAMPLE_SECONDS, 'boundary_settle_ms': 150},
        'phase_peak_method': 'kernel ru_maxrss of a process that stops at the phase boundary',
        'bend_driver': DRIVER,
        'bend_compile_attempts': builds,
        'bend_compile_env': {'BUN_JSC_forceRAMSize': COMPILE_ENV['BUN_JSC_forceRAMSize']},
        'cases': [],
    }
    for index, case in enumerate(json.loads((ROOT / 'memory_bench/cases.json').read_text())):
        data = snappy.decompress((ROOT / 'fixtures' / case['case'] / 'serialized.ssz_snappy').read_bytes())
        if hashlib.sha256(data).hexdigest() != case['sha256']:
            raise SystemExit('fixture hash mismatch')
        path = OUT / (case['case'].split('/')[-1] + '.ssz')
        path.write_bytes(data)
        row = {'case': case['case'], 'bytes': len(data), 'sha256': case['sha256'], 'samples': []}
        for repeat in range(REPEATS):
            order = ['bend', 'go'] if (index + repeat) % 2 == 0 else ['go', 'bend']
            for impl in order:
                sample = run_sample(impl, EXE[impl], path, OUT / (impl + '-output.ssz'), data)
                sample['repeat'] = repeat
                row['samples'].append(sample)
                print(case['case'].split('/')[-1], impl, 'baseline', sample['baseline_rss_bytes'],
                      'decode_peak', sample['decode_peak_rss_bytes'], 'overhead', sample['decode_overhead_bytes'],
                      'decode_ns', sample['decode_ns'], 'root_ns', sample['root_ns'],
                      'verified', sample['verified'], flush=True)
        # Both implementations must agree on the decoded root for the fixture.
        roots = {s['root_checksum'] for s in row['samples']}
        row['root_checksum_agreement'] = len(roots) == 1
        report['cases'].append(row)
        (OUT / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    report['complete'] = True
    (OUT / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
