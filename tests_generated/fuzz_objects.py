"""Differential fuzzing of the typed object API against the independent oracle.

    /opt/homebrew/bin/python3 tests_generated/fuzz_objects.py [--seed N]
        [--valid K] [--invalid M] [--only Name,Name] [--budget SECONDS]

For every one of the 109 mainnet Fulu names the campaign runs two kinds of case
through the native object programs (build/obj-g<k>, generated from the same
YAML schema as the runtime):

  valid    a pseudo-random value of the type is built here, serialized by
           codegen/oracle.py (an independent SSZ implementation that shares no
           code with the runtime), and given to the program. The program must
           decode it, re-encode it to exactly the same bytes, and report the
           same full 32-byte hash_tree_root the oracle computes.

  invalid  a valid encoding is corrupted - a byte flipped, a prefix or suffix
           cut off, extra bytes appended, an offset word rewritten, a list or
           vector length changed, a bitlist delimiter cleared, a bitvector or
           boolean padding bit set. The oracle decides whether the result is
           still a legal encoding; the program must agree, and whenever both
           accept, the re-encoded bytes must equal the input exactly (SSZ is
           canonical, so an accepted input has only one encoding).

Every case is derived from a recorded seed, so a failure reproduces with
--seed and --only. Findings are written to benchmarks/evidence/fuzz_objects.json
with the exact counts, the mutation kinds exercised and any mismatching case
(input bytes included) so it can be turned into a regression.
"""
import argparse
import hashlib
import json
import os
import pathlib
import random
import re
import subprocess
import sys
import time

ROOT = pathlib.Path(__file__).resolve().parents[1]
os.chdir(ROOT)
sys.path.insert(0, str(ROOT / 'codegen'))
import oracle  # noqa: E402
import schema  # noqa: E402

TY = schema.load('codegen/fulu.yaml')
GROUPS = json.loads((ROOT / 'types/obj_groups.json').read_text())
FUZZ_OPS = json.loads((ROOT / 'types/obj_fuzz_ops.json').read_text())
TMP = ROOT / 'build/fuzz'
TMP.mkdir(parents=True, exist_ok=True)

# A generated value stays small: lists get a few elements, so a case is a
# process run of a few milliseconds and the campaign covers many shapes rather
# than a few enormous ones. Vectors keep their declared length - that is what
# makes them vectors - so the large fixed vectors are exercised at full size.
MAX_LIST = 3


def gen(t, rng, depth=0):
    k = t.kind
    if k == 'bool':
        return rng.random() < 0.5
    if k == 'uint':
        # biased towards the boundaries, where the codecs are most likely wrong
        return rng.choice([0, 1, (1 << (8 * t.size)) - 1, rng.getrandbits(8 * t.size)])
    if k == 'bytes':
        return bytes(rng.getrandbits(8) for _ in range(t.size))
    if k == 'bits':
        return [rng.random() < 0.5 for _ in range(t.size)]
    if k == 'bytelist':
        return bytes(rng.getrandbits(8) for _ in range(rng.randint(0, min(t.size, MAX_LIST * 8))))
    if k == 'bitlist':
        return [rng.random() < 0.5 for _ in range(rng.randint(0, min(t.size, MAX_LIST * 9)))]
    if k == 'vector':
        return [gen(t.elem, rng, depth + 1) for _ in range(t.size)]
    if k == 'list':
        return [gen(t.elem, rng, depth + 1) for _ in range(rng.randint(0, min(t.size, MAX_LIST)))]
    if k == 'container':
        return {f: gen(ft, rng, depth + 1) for f, ft in t.fields}
    raise SystemExit('cannot generate kind ' + k)


MUTATIONS = ['flip_byte', 'truncate', 'extend', 'offset_word', 'zero_prefix', 'grow_last',
             'drop_last', 'set_high_bit', 'swap_bytes', 'empty']


def mutate(data, rng):
    """One corruption of a valid encoding, with the kind that produced it."""
    kind = rng.choice(MUTATIONS)
    b = bytearray(data)
    if not b and kind not in ('extend', 'empty'):
        kind = 'extend'
    if kind == 'flip_byte':
        i = rng.randrange(len(b))
        b[i] ^= 1 << rng.randrange(8)
    elif kind == 'truncate':
        b = b[:rng.randrange(len(b))]
    elif kind == 'extend':
        b += bytes(rng.getrandbits(8) for _ in range(rng.randint(1, 4)))
    elif kind == 'offset_word':
        if len(b) < 4:
            b += bytes(4 - len(b))
        i = 4 * rng.randrange(max(1, len(b) // 4))
        b[i:i + 4] = rng.choice([0, 1, 3, 4, len(b), len(b) + 4, 0xFFFFFFFF,
                                 rng.getrandbits(32)]).to_bytes(4, 'little', signed=False)[:4]
    elif kind == 'zero_prefix':
        n = min(len(b), rng.randint(1, 4))
        b[:n] = bytes(n)
    elif kind == 'grow_last':
        b += bytes([rng.getrandbits(8)])
    elif kind == 'drop_last':
        b = b[:-1]
    elif kind == 'set_high_bit':
        i = rng.randrange(len(b))
        b[i] |= 0x80
    elif kind == 'swap_bytes':
        if len(b) >= 2:
            i, j = rng.randrange(len(b)), rng.randrange(len(b))
            b[i], b[j] = b[j], b[i]
    elif kind == 'empty':
        b = bytearray()
    return bytes(b), kind


# ---------------------------------------------------------------------------
# The mirror of the generated mutation API: the same value from the same seed,
# the same acceptance rule, computed here from the schema alone.

def _words(x, n):
    return [(x + j) % (1 << 32) for j in range(n)]


def seed_value(t, x):
    """The value the generated <shape>_seed(x) builds - see codegen/generate.py."""
    k = t.kind
    if k == 'bool':
        return (x & 1) == 1
    if k == 'uint':
        if t.size <= 4:
            return x & ((1 << (8 * t.size)) - 1)
        if t.size == 8:
            return x + (((x + 1) % (1 << 32)) << 32)
        ws = _words(x, t.size // 4)
        return int.from_bytes(b''.join(w.to_bytes(4, 'little') for w in ws), 'little')
    if k == 'bytes':
        raw = b''.join(w.to_bytes(4, 'little') for w in _words(x, (t.size + 3) // 4))
        return raw[:t.size]
    if k == 'bits':
        nw = (t.size + 31) // 32
        ws = _words(x, nw)
        if t.size % 32:
            ws[-1] &= (1 << (t.size % 32)) - 1
        return [(ws[i // 32] >> (i % 32)) & 1 == 1 for i in range(t.size)]
    if k == 'container':
        return {f: seed_value(ft, (x + 1 + i) % (1 << 32)) for i, (f, ft) in enumerate(t.fields)}
    raise SystemExit('no seed rule for kind ' + k)


def elem_seed(ct, seed):
    """The value one element of collection type `ct` gets from a seed."""
    if ct.kind in ('bytes', 'bytelist'):
        return seed & 255
    if ct.kind == 'bits' or ct.kind == 'bitlist':
        return (seed & 1) == 1
    return seed_value(ct.elem, seed)


def collection_len(ct, value):
    return len(value)


def apply_op(t, value, op, idx, seed):
    """Apply one operation of the name's table; return (value, accepted)."""
    value = json_copy(value)
    if op['kind'] == 'set_field':
        ft = dict(t.fields)[op['field']]
        value[op['field']] = seed_value(ft, seed)
        return value, True
    ct = dict(t.fields)[op['field']] if op['field'] is not None else t
    target = value[op['field']] if op['field'] is not None else value
    limit = ct.size
    if op['kind'] == 'set_elem':
        if idx >= collection_len(ct, target):
            return value, False
        new = elem_seed(ct, seed)
        if isinstance(target, (bytes, bytearray)):
            b = bytearray(target)
            b[idx] = new
            target = bytes(b)
        else:
            target = list(target)
            target[idx] = new
    else:                                   # append
        if collection_len(ct, target) + 1 > limit:
            return value, False
        new = elem_seed(ct, seed)
        if isinstance(target, (bytes, bytearray)):
            target = bytes(target) + bytes([new])
        else:
            target = list(target) + [new]
    if op['field'] is not None:
        value[op['field']] = target
        return value, True
    return target, True


def json_copy(v):
    if isinstance(v, dict):
        return {k: json_copy(x) for k, x in v.items()}
    if isinstance(v, list):
        return [json_copy(x) for x in v]
    return v


def run_fuzz_program(name, data, sel, idx, seed, mode=1):
    """One mutation through the generated driver of this name's fuzz program."""
    e = FUZZ_OPS[name]
    f = TMP / 'hist-in.ssz'
    out = TMP / 'hist-out.ssz'
    f.write_bytes(data)
    if out.exists():
        out.unlink()
    env = {**os.environ, 'SSZ_MODE': str(mode), 'SSZ_INDEX': str(e['index']), 'SSZ_SEL': str(sel),
           'SSZ_IDX': str(idx), 'SSZ_SEED': str(seed), 'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
    r = subprocess.run([f"build/fuzz-f{e['program']}", '--threads', '1', '--gpu', 'off'],
                       env=env, capture_output=True, text=True)
    decoded = 'DECODED=1' in r.stdout
    accepted = 'STATUS=1' in r.stdout
    m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
    root = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')) if m else None
    encoded = out.read_bytes() if out.exists() else None
    return decoded, accepted, root, encoded, r


def history(name, rng, length, findings, counts):
    """A chain of mutations: each step decodes the previous encoding, applies
    one operation of the type's table and re-encodes. The value is tracked here
    with the oracle, so bytes, acceptance and root are compared at every step."""
    entry = FUZZ_OPS[name]
    ops = entry['ops']
    if not ops:
        return
    t = TY[name]
    value = gen(t, rng)
    data = oracle.serialize(t, value)
    for step in range(length):
        sel = rng.randrange(len(ops))
        op = ops[sel]
        # indices in and out of range, and the boundary index itself
        idx = rng.choice([0, 1, rng.randrange(64), 4294967295,
                          max(0, collection_len(TY[name], value) - 1) if isinstance(value, (list, bytes)) else 0])
        seed = rng.getrandbits(32)
        want_value, want_ok = apply_op(t, value, op, idx, seed)
        decoded, accepted, root, encoded, r = run_fuzz_program(name, data, sel, idx, seed)
        counts['history'] += 1
        want_bytes = oracle.serialize(t, want_value)
        want_root = oracle.root(t, want_value)
        bad = (not decoded) or accepted != want_ok or encoded != want_bytes or root != want_root
        if bad:
            findings.append({'type': name, 'case': 'history', 'step': step, 'operation': op,
                             'sel': sel, 'index': idx, 'seed': seed, 'decoded': decoded,
                             'bend_accepts': accepted, 'oracle_accepts': want_ok,
                             'bytes_equal': encoded == want_bytes, 'root_equal': root == want_root,
                             'input_hex': data.hex()[:4096], 'stdout': r.stdout[-200:],
                             'stderr': r.stderr[-200:]})
            return
        value, data = want_value, encoded


def reference(t, data):
    """What the independent oracle says about these bytes: (accepted, root)."""
    try:
        v = oracle.parse(t, data)
    except Exception:
        return False, None
    # SSZ is canonical for a fixed schema: an accepted encoding must be the
    # only encoding of the value it decodes to, which the oracle re-checks.
    if oracle.serialize(t, v) != data:
        return False, None
    return True, oracle.root(t, v)


def run(name, data):
    g = GROUPS[name]
    f = TMP / 'in.ssz'
    out = TMP / 'out.ssz'
    f.write_bytes(data)
    if out.exists():
        out.unlink()
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(g['index']), 'SSZ_OPS': '1',
           'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
    r = subprocess.run([f"build/obj-g{g['group']}", '--threads', '1', '--gpu', 'off'],
                       env=env, capture_output=True, text=True)
    accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
    m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
    root = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')) if m else None
    encoded = out.read_bytes() if out.exists() else None
    return accepted, root, encoded, r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--seed', type=int, default=20260921)
    ap.add_argument('--valid', type=int, default=3)
    ap.add_argument('--invalid', type=int, default=6)
    ap.add_argument('--only', default=None)
    ap.add_argument('--history', type=int, default=6)
    ap.add_argument('--histories', type=int, default=2)
    ap.add_argument('--budget', type=float, default=3600.0)
    args = ap.parse_args()
    names = [n for n in TY if not args.only or n in args.only.split(',')]
    started = time.monotonic()
    counts = {'valid': 0, 'invalid': 0, 'accepted_invalid': 0, 'rejected_valid': 0, 'history': 0}
    kinds = {}
    findings, types_done = [], 0

    for name in names:
        t = TY[name]
        rng = random.Random(f'{args.seed}:{name}')
        for _ in range(args.valid):
            if time.monotonic() - started > args.budget:
                break
            value = gen(t, rng)
            data = oracle.serialize(t, value)
            want_root = oracle.root(t, value)
            accepted, root, encoded, r = run(name, data)
            counts['valid'] += 1
            if not (accepted and encoded == data and root == want_root):
                counts['rejected_valid'] += not accepted
                findings.append({'type': name, 'case': 'valid', 'seed': args.seed,
                                 'accepted': accepted, 'bytes_equal': encoded == data,
                                 'root_equal': root == want_root, 'len': len(data),
                                 'input_hex': data.hex()[:4096],
                                 'want_root': want_root.hex(),
                                 'got_root': root.hex() if root else None,
                                 'stdout': r.stdout[-200:], 'stderr': r.stderr[-200:]})
            for _ in range(args.invalid):
                if time.monotonic() - started > args.budget:
                    break
                bad, kind = mutate(data, rng)
                kinds[kind] = kinds.get(kind, 0) + 1
                ref_ok, ref_root = reference(t, bad)
                accepted, root, encoded, r = run(name, bad)
                counts['invalid'] += 1
                bad_result = accepted != ref_ok or (accepted and (encoded != bad or root != ref_root))
                if bad_result:
                    counts['accepted_invalid'] += accepted and not ref_ok
                    findings.append({'type': name, 'case': 'mutated', 'mutation': kind,
                                     'seed': args.seed, 'oracle_accepts': ref_ok,
                                     'bend_accepts': accepted,
                                     'bytes_equal': encoded == bad if accepted else None,
                                     'root_equal': (root == ref_root) if (accepted and ref_ok) else None,
                                     'len': len(bad), 'input_hex': bad.hex()[:4096],
                                     'stdout': r.stdout[-200:], 'stderr': r.stderr[-200:]})
        for _ in range(args.histories):
            if time.monotonic() - started > args.budget:
                break
            history(name, rng, args.history, findings, counts)
        types_done += 1
        if types_done % 10 == 0:
            print(f'{types_done}/{len(names)} types, {counts["valid"]} valid + {counts["invalid"]} '
                  f'mutated + {counts["history"]} history cases, {len(findings)} findings, '
                  f'{time.monotonic() - started:.0f}s',
                  flush=True)

    report = {
        'seed': args.seed, 'types': len(names), 'valid_per_type': args.valid,
        'mutations_per_value': args.invalid, 'histories_per_type': args.histories,
        'operations_per_history': args.history, 'counts': counts, 'mutation_kinds': kinds,
        'named_operations': {n: len(e['ops']) for n, e in FUZZ_OPS.items()},
        'elapsed_s': round(time.monotonic() - started, 1),
        'command': f'{sys.executable} tests_generated/fuzz_objects.py --seed {args.seed} '
                   f'--valid {args.valid} --invalid {args.invalid}',
        'toolchain': json.loads((ROOT / 'benchmarks/toolchain.json').read_text()),
        'source_sha256': {**{p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest()
                             for p in ['src/obj.bend', 'codegen/fulu.yaml', 'codegen/generate.py', 'codegen/oracle.py']},
                          # the runtime, split per name and operation: its files in name order, concatenated
                          'types/*_generated.bend': hashlib.sha256(b''.join(
                              q.read_bytes() for q in sorted((ROOT / 'types').glob('*_generated.bend')))).hexdigest()},
        'findings': findings[:50], 'findings_total': len(findings),
        'note': 'oracle = codegen/oracle.py, written from the SSZ specification and validated '
                'against the 295 official static cases; comparison is full bytes and full '
                '32-byte roots, not checksums',
    }
    out = ROOT / 'benchmarks/evidence/fuzz_objects.json'
    out.write_text(json.dumps(report, indent=1) + '\n')
    print(f'{counts["valid"]} valid, {counts["invalid"]} mutated and {counts["history"]} history '
          f'cases over {len(names)} types, {len(findings)} mismatches, {report["elapsed_s"]}s')
    sys.exit(1 if findings else 0)


if __name__ == '__main__':
    main()
