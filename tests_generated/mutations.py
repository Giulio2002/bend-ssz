"""Mutation regressions for the typed object API (finite checks, not laws).

build/compact-omut (benchmarks/compact/omut.bend) decodes a real fixture,
applies updates through the generated object API and re-encodes. The expected
bytes are computed here from the same fixture with the independent oracle
(codegen/oracle.py), which shares no code with the Bend runtime. Rejection
cases must report STATUS=0 and leave the value byte-for-byte unchanged.

    /opt/homebrew/bin/python3 tests_generated/mutations.py
"""
import json
import os
import pathlib
import re
import subprocess
import sys

import snappy

ROOT = pathlib.Path(__file__).resolve().parents[1]
os.chdir(ROOT)
sys.path.insert(0, str(ROOT / 'codegen'))
import oracle  # noqa: E402
import schema  # noqa: E402

TY = schema.load('codegen/fulu.yaml')
CASES = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
tmp = pathlib.Path('build/performance/inputs')
tmp.mkdir(parents=True, exist_ok=True)


def fixture(name):
    c = next(c for c in CASES if f'/ssz_static/{name}/' in c)
    return snappy.decompress((pathlib.Path('fixtures') / c / 'serialized.ssz_snappy').read_bytes())


def run(mode, arg, data):
    f = tmp / 'mut-in.ssz'
    f.write_bytes(data)
    o = tmp / 'mut-obj.ssz'
    if o.exists():
        o.unlink()
    env = {**os.environ, 'SSZ_MODE': str(mode), 'SSZ_ARG': str(arg),
           'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(o)}
    r = subprocess.run(['build/compact-omut', '--threads', '1', '--gpu', 'off'],
                       env=env, capture_output=True, text=True)
    if r.returncode != 0:
        return None, r.stdout + r.stderr, None
    status = re.search(r'STATUS=(\d)', r.stdout)
    return (status.group(1) == '1' if status else None), r.stdout, (o.read_bytes() if o.exists() else None)


def check(label, got, want, ok, want_ok, results):
    good = (got == want) and (ok == want_ok)
    results.append({'case': label, 'accepted': ok, 'expected_accepted': want_ok,
                    'bytes_equal': got == want, 'pass': good})
    print(('pass ' if good else 'FAIL ') + label)
    return good


def main():
    results = []
    allok = True

    # Validator: two field updates; the expectation is the oracle's encoding
    # of the same value with those fields replaced.
    data = fixture('Validator')
    v = oracle.parse(TY['Validator'], data)
    arg = 123456789
    v2 = dict(v, effective_balance=arg, slashed=True)
    ok, out, got = run(0, arg, data)
    allok &= check('Validator.effective_balance := n, slashed := true', got,
                   oracle.serialize(TY['Validator'], v2), ok, True, results)

    # read-after-write through the getter
    ok, out, got = run(1, arg, data)
    readback = re.search(r'READBACK=(\d+)', out)
    v3 = dict(v, effective_balance=arg)
    allok &= check('Validator.effective_balance read-after-write', got,
                   oracle.serialize(TY['Validator'], v3),
                   ok and readback is not None and int(readback.group(1)) == arg, True, results)

    # Deposit: vector element replacement, and rejection at index == length
    data = fixture('Deposit')
    d = oracle.parse(TY['Deposit'], data)
    newleaf = bytes(range(32))
    d2 = dict(d, proof=[newleaf] + d['proof'][1:])
    ok, out, got = run(2, 0, data)
    allok &= check('Deposit.proof[0] := const', got, oracle.serialize(TY['Deposit'], d2), ok, True, results)
    ok, out, got = run(3, 0, data)
    allok &= check('Deposit.proof[33] rejected, value unchanged', got, data, ok, False, results)

    # ExecutionPayloadHeader: byte-list append inside and past the 32-byte limit
    data = fixture('ExecutionPayloadHeader')
    h = oracle.parse(TY['ExecutionPayloadHeader'], data)
    room = len(h['extra_data']) < 32
    h2 = dict(h, extra_data=h['extra_data'] + bytes([7])) if room else h
    ok, out, got = run(4, 7, data)
    allok &= check(f'ExecutionPayloadHeader.extra_data append (len {len(h["extra_data"])}/32)',
                   got, oracle.serialize(TY['ExecutionPayloadHeader'], h2), ok, room, results)

    # IndexedAttestation: list append, element replacement, out-of-range set
    data = fixture('IndexedAttestation')
    a = oracle.parse(TY['IndexedAttestation'], data)
    a2 = dict(a, attesting_indices=a['attesting_indices'] + [99])
    ok, out, got = run(5, 99, data)
    allok &= check('IndexedAttestation.attesting_indices append', got,
                   oracle.serialize(TY['IndexedAttestation'], a2), ok, True, results)
    a3 = dict(a, attesting_indices=[99] + a['attesting_indices'][1:])
    ok, out, got = run(6, 99, data)
    allok &= check('IndexedAttestation.attesting_indices[0] := n', got,
                   oracle.serialize(TY['IndexedAttestation'], a3), ok, True, results)
    ok, out, got = run(7, 99, data)
    allok &= check('IndexedAttestation.attesting_indices[len] rejected, value unchanged',
                   got, data, ok, False, results)

    json.dump({'results': results, 'pass': allok}, open('benchmarks/evidence/object_mutation_tests.json', 'w'), indent=1)
    print(('all mutation regressions pass' if allok else 'FAILURES') + f' ({len(results)} cases)')
    sys.exit(0 if allok else 1)


if __name__ == '__main__':
    main()
