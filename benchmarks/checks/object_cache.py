"""Cached element roots of a list of objects, against the independent oracle.

    /opt/homebrew/bin/python3 benchmarks/checks/object_cache.py

build/compact-ocache (benchmarks/compact/ocache.bend) decodes a real
BeaconState, takes its validators list and prints the root it computes under
seven modes: no cache, a fresh cache, a warm cache, a write with and without a
cache, an append with and without a cache. Every root must equal the root
codegen/oracle.py computes for the same list from the raw fixture bytes - code
that shares nothing with the runtime - and the cached and uncached roots must
agree with each other.

Wall-clock times of the modes are recorded too: mode 1 is one full hashing
pass, mode 2 is that pass plus a warm one, mode 3 that pass plus one element
rehashed. The differences are what caching buys; they are process times, so
they include the decode and are only meaningful as differences.
"""
import json
import os
import pathlib
import re
import subprocess
import sys
import time

import snappy

ROOT = pathlib.Path(__file__).resolve().parents[2]
os.chdir(ROOT)
sys.path.insert(0, str(ROOT / 'codegen'))
import oracle  # noqa: E402
import schema  # noqa: E402

TY = schema.load('codegen/fulu.yaml')
VALIDATORS = dict(TY['BeaconState'].fields)['validators']
EXE = 'build/compact-ocache'
ARG = 123456789
REPEATS = 3


def fixtures():
    cases = json.loads((ROOT / 'memory_bench/cases.json').read_text())
    for c in cases:
        data = snappy.decompress((ROOT / 'fixtures' / c['case'] / 'serialized.ssz_snappy').read_bytes())
        yield c['case'], data


HISTORY_SEEDS = [1, 7, 4242, 987654321, 2 ** 31 - 1]
HISTORY_STEPS = [0, 1, 5, 17]


def seed_validator(x):
    """The validator T.Validator_seed(x) builds: field i from seed x + 1 + i,
    exactly as codegen/generate.py emits it (see tests_generated/fuzz_objects.py
    for the general rule)."""
    sys.path.insert(0, str(ROOT / 'tests_generated'))
    import fuzz_objects
    return fuzz_objects.seed_value(TY['Validator'], x)


def history_values(vals, seed, steps):
    """The same seeded history the program applies, replayed on the oracle's
    value: write a seeded validator at an index, or append one, advancing the
    seed with the same generator."""
    out = list(vals)
    s = seed
    for _ in range(steps):
        op = s & 1
        idx = ((s >> 2) & 63) if (s & 2) == 0 else 100000
        if op == 0:
            if idx < len(out):
                out[idx] = seed_validator(s)
        else:
            out.append(seed_validator(s))
        s = (s * 1103515245 + 12345) % (1 << 32)
    return out


def run(mode, path, ops=1, arg=ARG):
    """One run of one mode: its root, its wall clock and the kernel's peak RSS
    for the whole process (/usr/bin/time -l, not a sampler)."""
    env = {**os.environ, 'SSZ_MODE': str(mode), 'SSZ_ARG': str(arg), 'SSZ_OPS': str(ops),
           'SSZ_INPUT': str(path),
           'SSZ_OUTPUT': str(ROOT / 'build/performance/inputs/cache-out.ssz')}
    started = time.monotonic()
    r = subprocess.run(['/usr/bin/time', '-l', EXE, '--threads', '1', '--gpu', 'off'],
                       env=env, capture_output=True, text=True)
    elapsed = time.monotonic() - started
    if r.returncode != 0:
        raise SystemExit(f'mode {mode} failed: {r.stdout}{r.stderr}')
    m = re.search(r'ROOT=([0-9,]+)', r.stdout)
    if not m:
        raise SystemExit(f'mode {mode} printed no root: {r.stdout}')
    rss = re.search(r'(\d+)\s+maximum resident set size', r.stderr)
    words = [int(x) for x in m.group(1).split(',')]
    return b''.join(w.to_bytes(4, 'big') for w in words), elapsed, int(rss.group(1)) if rss else 0


def expectations(vals):
    """What the oracle says each mode must print, for a list of validators."""
    plain = oracle.root(VALIDATORS, vals)
    appended = vals + [oracle.parse(TY['Validator'], bytes(TY['Validator'].fixed_size()))]
    want = {0: plain, 1: plain, 2: plain, 5: oracle.root(VALIDATORS, appended),
            6: oracle.root(VALIDATORS, appended), 7: oracle.root(VALIDATORS, [])}
    if vals:   # modes 3 and 4 write validator 0, which an empty list has not got
        updated = [dict(vals[0], effective_balance=ARG)] + vals[1:]
        want[3] = oracle.root(VALIDATORS, updated)
        want[4] = oracle.root(VALIDATORS, updated)
    return want


def measure(label, path, vals, rows):
    want = expectations(vals)
    got, times, peaks = {}, {}, {}
    for mode in sorted(want):
        best, peak = None, 0
        for _ in range(REPEATS):
            root, elapsed, rss = run(mode, path)
            got[mode] = root
            best = elapsed if best is None else min(best, elapsed)
            peak = max(peak, rss)
        times[mode] = round(best, 4)
        peaks[mode] = peak
    ok = all(got[m] == want[m] for m in want)
    # what the cache itself costs: a heap of 2^(d+1) digests over the element
    # array's capacity, 32 bytes each, plus the two range words
    d = max(0, (max(1, len(vals)) - 1).bit_length())
    cache_bytes = (1 << (d + 1)) * 32 + 8
    rows.append({'case': label, 'validators': len(vals), 'pass': ok,
                 'cache_tree_depth': d, 'retained_cache_bytes': cache_bytes,
                 'peak_rss_bytes': {str(m): peaks[m] for m in sorted(peaks)},
                 'roots_hex': {str(m): got[m].hex() for m in sorted(got)},
                 'expected_hex': {str(m): want[m].hex() for m in sorted(want)},
                 'seconds_min_of_%d' % REPEATS: {str(m): times[m] for m in sorted(times)}})
    # mode 7 decodes and forces the list without hashing any of it, so the
    # hashing cost of each mode is its time minus that baseline
    base = times[7]
    hashing = {m: round(times[m] - base, 4) for m in times}
    rows[-1]['hashing_seconds'] = {str(m): hashing[m] for m in sorted(hashing)}
    # the marginal cost of the second root in each mode: mode 2 repeats the
    # root with nothing changed, mode 3 after one element write, mode 5 after
    # an append; mode 1 is the first (full) root
    marginal = {'warm': round(times[2] - times[1], 4), 'after_append': round(times[5] - times[1], 4)}
    if 3 in times:
        marginal['after_update'] = round(times[3] - times[1], 4)
    rows[-1]['marginal_second_root_seconds'] = marginal
    upd = f", after update {marginal['after_update']:+.4f}s" if 'after_update' in marginal else ''
    print(f'{"pass" if ok else "FAIL"} {label}: {len(vals)} validators; first root {hashing[1]:.4f}s, '
          f'uncached root {hashing[0]:.4f}s; second root warm {marginal["warm"]:+.4f}s{upd}, '
          f'after append {marginal["after_append"]:+.4f}s; cache {cache_bytes} bytes, '
          f'peak RSS {max(peaks.values())} bytes')
    return ok


def main():
    (ROOT / 'build/performance/inputs').mkdir(parents=True, exist_ok=True)
    rows, allok = [], True
    base = None
    for case, data in fixtures():
        path = ROOT / 'build/performance/inputs' / (case.split('/')[-1] + '.ssz')
        path.write_bytes(data)
        state = oracle.parse(TY['BeaconState'], data)
        if base is None and state['validators']:
            base = state
        allok &= measure(case, path, state['validators'], rows)
    # The fixtures hold a handful of validators each, too few for the warm root
    # to stand out of the process time. The same state with its validator list
    # grown (by repeating the validators it has) is re-serialized here with the
    # oracle and decoded by the same program: a synthetic input, not a fixture,
    # and its roots are checked against the oracle exactly like the others.
    for n in (1024, 8192):
        vals = [dict(base['validators'][i % len(base['validators'])]) for i in range(n)]
        big = dict(base, validators=vals)
        path = ROOT / 'build/performance/inputs' / f'synthetic-validators-{n}.ssz'
        path.write_bytes(oracle.serialize(TY['BeaconState'], big))
        allok &= measure(f'synthetic BeaconState with {n} validators', path, vals, rows)
    # Seeded mutation histories: the cached root, the uncached root of the same
    # history, and the oracle's root of the replayed history must all agree.
    hist_rows, hist_cases = [], 0
    for case, data in fixtures():
        path = ROOT / 'build/performance/inputs' / (case.split('/')[-1] + '.ssz')
        path.write_bytes(data)
        vals = oracle.parse(TY['BeaconState'], data)['validators']
        for seed in HISTORY_SEEDS:
            for steps in HISTORY_STEPS:
                want = oracle.root(VALIDATORS, history_values(vals, seed, steps))
                cached, _, _ = run(8, path, ops=steps, arg=seed)
                plain, _, _ = run(9, path, ops=steps, arg=seed)
                good = cached == want and plain == want
                allok &= good
                hist_cases += 1
                hist_rows.append({'case': case, 'seed': seed, 'steps': steps, 'pass': good,
                                  'cached_root': cached.hex(), 'uncached_root': plain.hex(),
                                  'oracle_root': want.hex()})
                if not good:
                    print(f'FAIL history {case} seed={seed} steps={steps}: cached={cached.hex()} '
                          f'uncached={plain.hex()} oracle={want.hex()}')
    print(f'{"pass" if all(r["pass"] for r in hist_rows) else "FAIL"} '
          f'{hist_cases} seeded mutation histories: cached root = uncached root = oracle root')

    out = ROOT / 'benchmarks/evidence/object_cache.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({'cases': rows, 'histories': hist_rows, 'pass': allok, 'arg': ARG,
                               'note': 'roots compared with codegen/oracle.py; times are whole-process '
                                       'wall clock including decode, min of %d' % REPEATS}, indent=1) + '\n')
    print(('all cached roots match the oracle' if allok else 'FAILURES') + f' ({len(rows)} fixtures)')
    sys.exit(0 if allok else 1)


if __name__ == '__main__':
    main()
