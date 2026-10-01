"""Differential fuzzing of the typed object API against the independent oracle.

    /opt/homebrew/bin/python3 tests_generated/fuzz_objects.py [--seed N]
        [--valid K] [--invalid M] [--only Name,Name] [--budget SECONDS]

For every one of the 109 mainnet Fulu names (build/obj-g<k>) and every generic schema the generator supports
(build/obj-x<k>, the schemas of tools/test_schemas.py translated by codegen/core/generic.py) the campaign runs
these kinds of case through the native object programs, all derived from the schema alone:

  valid    a pseudo-random value of the type is built here, serialized by
           codegen/core/oracle.py (an independent SSZ implementation that shares no
           code with the runtime), and given to the program. The program must
           decode it, re-encode it to exactly the same bytes, and report the
           same full 32-byte hash_tree_root the oracle computes.

  boundary a valid encoding is corrupted at every field boundary the schema defines (the start of each field,
           each offset slot and the position it points to, each element of a collection; sampled evenly when
           there are more than --boundaries of them): a byte flipped just before and at the boundary, the
           encoding cut there, a byte or a word inserted there, a byte deleted there. Counted separately.

  invalid  a valid encoding is corrupted - a byte flipped, a prefix or suffix
           cut off, extra bytes appended, an offset word rewritten, a list or
           vector length changed, a bitlist delimiter cleared, a bitvector or
           boolean padding bit set. The oracle decides whether the result is
           still a legal encoding; the program must agree, and whenever both
           accept, the re-encoded bytes must equal the input exactly (SSZ is
           canonical, so an accepted input has only one encoding).

The valid values are not only random: per type a random one, a second random one, the all-zero value, the
maximal value (largest integers, 0xff bytes, set bits, lists at their limit when it is small), the empty value
(every list empty) and a list-boundary value (lists one short of their limit when it is small). The setter
histories (types whose generated API has setters: the others are leaves and aliases) apply --history operations
in each of --histories chains. Every case is derived from a recorded seed, so a failure reproduces with
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
sys.path.insert(0, str(ROOT / 'benchmarks/checks'))
from provenance import stamp  # noqa: E402
os.chdir(ROOT)
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / 'tools'))
from codegen.core import generic as GEN  # noqa: E402
from codegen.core import oracle  # noqa: E402
from codegen.core import schema  # noqa: E402

TY = schema.load('codegen/fulu.yaml')
GROUPS = json.loads((ROOT / 'types/obj_groups.json').read_text())
GENERIC_INDEX = json.loads((ROOT / 'types/generic_obj_index.json').read_text())['generated']
GENERIC_TY = {n: t for n, (t, _raw) in GEN.inventory().items() if n in GENERIC_INDEX}
PROGRAM = {}   # name -> (program path, driver index, family)
for _n in TY:
    PROGRAM[_n] = (f"build/obj-g{GROUPS[_n]['group']}", GROUPS[_n]['index'], 'fulu')
for _n, _t in GENERIC_TY.items():
    if _n not in PROGRAM:
        TY[_n] = _t
        PROGRAM[_n] = (f"build/obj-x{GENERIC_INDEX[_n]['group']}", GENERIC_INDEX[_n]['index'], 'generic')
FUZZ_OPS = json.loads((ROOT / 'types/obj_fuzz_ops.json').read_text())
TMP = ROOT / ('build/fuzz' + os.environ.get('SSZ_TMP_SUFFIX', ''))
TMP.mkdir(parents=True, exist_ok=True)

# A generated value stays small: lists get a few elements, so a case is a
# process run of a few milliseconds and the campaign covers many shapes rather
# than a few enormous ones. Vectors keep their declared length - that is what
# makes them vectors - so the large fixed vectors are exercised at full size.
MAX_LIST = 3


def _count(t, rng, mode):
    """the length of a list-like value of type t in a generation mode"""
    lim = t.size if t.kind in ('list', 'bitlist') else 10 ** 9
    if mode == 'empty':
        return 0
    if mode == 'full':
        return min(lim, MAX_LIST * 3)
    if mode == 'short':
        return max(0, min(lim - 1, MAX_LIST * 3))
    return rng.randint(0, min(lim, MAX_LIST))


def gen(t, rng, mode='random', depth=0):
    k = t.kind
    if k == 'bool':
        return {'zero': False, 'empty': False, 'max': True}.get(mode, rng.random() < 0.5)
    if k == 'uint':
        if mode in ('zero', 'empty'):
            return 0
        if mode == 'max':
            return (1 << (8 * t.size)) - 1
        # biased towards the boundaries, where the codecs are most likely wrong
        return rng.choice([0, 1, (1 << (8 * t.size)) - 1, rng.getrandbits(8 * t.size)])
    if k == 'bytes':
        return bytes(t.size) if mode in ('zero', 'empty') else (b'\xff' * t.size if mode == 'max' else
                                                            bytes(rng.getrandbits(8) for _ in range(t.size)))
    if k == 'bits':
        return [mode == 'max' or (mode not in ('zero', 'empty') and rng.random() < 0.5) for _ in range(t.size)]
    if k == 'bytelist':
        n = min(t.size, MAX_LIST * 8) if mode in ('full', 'max') else _count(t, rng, mode) * (1 if mode in ('empty', 'short') else 8)
        n = min(n, t.size)
        return b'\xff' * n if mode == 'max' else (bytes(n) if mode == 'zero' else bytes(rng.getrandbits(8) for _ in range(n)))
    if k in ('bitlist', 'pbits'):
        n = _count(t, rng, 'full' if mode == 'max' else mode) if k == 'bitlist' else (0 if mode == 'empty' else rng.randint(0, MAX_LIST * 9))
        return [mode == 'max' or (mode != 'zero' and rng.random() < 0.5) for _ in range(n)]
    if k == 'vector':
        return [gen(t.elem, rng, mode, depth + 1) for _ in range(t.size)]
    if k in ('list', 'plist'):
        n = _count(t, rng, mode if mode != 'max' else 'full') if k == 'list' else (0 if mode == 'empty' else rng.randint(0, MAX_LIST))
        return [gen(t.elem, rng, mode, depth + 1) for _ in range(n)]
    if k in ('container', 'pcontainer'):
        return {f: gen(ft, rng, mode, depth + 1) for f, ft in t.fields}
    if k == 'cunion':
        i = 0 if mode in ('zero', 'empty') else rng.randrange(len(t.fields))
        return {'selector': t.selectors[i], 'value': gen(t.fields[i][1], rng, mode, depth + 1)}
    raise SystemExit('cannot generate kind ' + k)


VALUE_MODES = ['random', 'random', 'zero', 'max', 'empty', 'short', 'random', 'full']


def bounds(t, v, base=0):
    """The byte positions of `serialize(t, v)` (offset by `base`) where a field, an offset slot or the thing an
    offset points to begins: the places a codec's length and offset arithmetic is decided."""
    k = t.kind
    out = {base}
    if k in ('container', 'pcontainer'):
        pos, head = base, sum(ft.header() for _, ft in t.fields)
        body = base + head
        for f, ft in t.fields:
            out.add(pos)
            if ft.fixed():
                out |= bounds(ft, v[f], pos)
            else:
                out.add(body)
                out |= bounds(ft, v[f], body)
                body += len(oracle.serialize(ft, v[f]))
            pos += ft.header()
        out.add(body)
    elif k in ('vector', 'list', 'plist'):
        e, n = t.elem, len(v)
        if e.fixed():
            w = e.fixed_size()
            for i in range(n):
                out.add(base + i * w)
                if e.kind in ('container', 'pcontainer', 'vector'):
                    out |= bounds(e, v[i], base + i * w)
        else:
            body = base + 4 * n
            for i in range(n):
                out.add(base + 4 * i)
                out.add(body)
                out |= bounds(e, v[i], body)
                body += len(oracle.serialize(e, v[i]))
    elif k == 'cunion':
        i = list(t.selectors).index(v['selector'])
        out.add(base + 1)
        out |= bounds(t.fields[i][1], v['value'], base + 1)
    elif k in ('bytelist', 'bitlist', 'pbits', 'bytes', 'bits'):
        out.add(base + len(oracle.serialize(t, v)))
    return out


BOUNDARY_KINDS = ['flip_before', 'flip_at', 'cut', 'insert_byte', 'insert_word', 'delete_byte']


def boundary_mutations(data, points, limit, rng):
    """[(mutated bytes, kind)]: every boundary kind at up to `limit` evenly spaced boundaries."""
    pts = sorted(p for p in points if 0 <= p <= len(data))
    if len(pts) > limit:
        step = len(pts) / limit
        pts = sorted({pts[int(i * step)] for i in range(limit)} | {pts[0], pts[-1]})
    out = []
    for p in pts:
        b = bytearray(data)
        if p >= 1:
            c = bytearray(data); c[p - 1] ^= 1 << rng.randrange(8); out.append((bytes(c), 'flip_before'))
        if p < len(data):
            c = bytearray(data); c[p] ^= 1 << rng.randrange(8); out.append((bytes(c), 'flip_at'))
            c = bytearray(data); del c[p]; out.append((bytes(c), 'delete_byte'))
        out.append((bytes(b[:p]), 'cut'))
        out.append((bytes(b[:p]) + bytes([rng.getrandbits(8)]) + bytes(b[p:]), 'insert_byte'))
        out.append((bytes(b[:p]) + rng.getrandbits(32).to_bytes(4, 'little') + bytes(b[p:]), 'insert_word'))
    return out


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
    """The value the generated <shape>_seed(x) builds - see codegen/impl/generate.py."""
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
    entry = FUZZ_OPS.get(name)
    ops = entry['ops'] if entry else []
    if not ops:
        return
    t = TY[name]
    value = gen(t, rng, rng.choice(['random', 'short', 'full']))
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
    prog, index, _fam = PROGRAM[name]
    f = TMP / 'in.ssz'
    out = TMP / 'out.ssz'
    f.write_bytes(data)
    if out.exists():
        out.unlink()
    env = {**os.environ, 'SSZ_MODE': '0', 'SSZ_INDEX': str(index), 'SSZ_OPS': '1',
           'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
    r = subprocess.run([prog, '--threads', '1', '--gpu', 'off'],
                       env=env, capture_output=True, text=True)
    accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
    m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
    root = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')) if m else None
    encoded = out.read_bytes() if out.exists() else None
    return accepted, root, encoded, r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--seed', type=int, default=20260921)
    ap.add_argument('--valid', type=int, default=8, help='valid values per type (VALUE_MODES, in order)')
    ap.add_argument('--invalid', type=int, default=8, help='random corruptions per valid value')
    ap.add_argument('--boundary-values', type=int, default=3, help='valid values per type that get every boundary corruption')
    ap.add_argument('--boundaries', type=int, default=32, help='boundaries sampled per value (a quarter above 50 kB)')
    ap.add_argument('--only', default=None)
    ap.add_argument('--history', type=int, default=10)
    ap.add_argument('--histories', type=int, default=6)
    ap.add_argument('--budget', type=float, default=3600.0)
    args = ap.parse_args()
    names = [n for n in TY if not args.only or n in args.only.split(',')]
    started = time.monotonic()
    counts = {'valid': 0, 'invalid': 0, 'boundary': 0, 'accepted_invalid': 0, 'rejected_valid': 0, 'history': 0}
    fam = {'fulu': {'types': 0, 'valid': 0, 'invalid': 0, 'boundary': 0, 'history': 0},
           'generic': {'types': 0, 'valid': 0, 'invalid': 0, 'boundary': 0, 'history': 0}}
    modes_run = {}
    kinds = {}
    findings, types_done = [], 0

    for name in names:
        t = TY[name]
        rng = random.Random(f'{args.seed}:{name}')
        family = PROGRAM[name][2]
        fam[family]['types'] += 1
        before = dict(counts)
        for vi in range(args.valid):
            if time.monotonic() - started > args.budget:
                break
            mode = VALUE_MODES[vi % len(VALUE_MODES)]
            modes_run[mode] = modes_run.get(mode, 0) + 1
            value = gen(t, rng, mode)
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
            todo = [(m, 'invalid') for m in (mutate(data, rng) for _ in range(args.invalid))]
            if vi < args.boundary_values:
                limit = args.boundaries if len(data) <= 50000 else max(4, args.boundaries // 4)
                todo += [(m, 'boundary') for m in boundary_mutations(data, bounds(t, value), limit, rng)]
            for (bad, kind), cls in todo:
                if time.monotonic() - started > args.budget:
                    break
                kinds[kind] = kinds.get(kind, 0) + 1
                ref_ok, ref_root = reference(t, bad)
                accepted, root, encoded, r = run(name, bad)
                counts[cls] += 1
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
        for c in ('valid', 'invalid', 'boundary', 'history'):
            fam[family][c] += counts[c] - before[c]
        types_done += 1
        if types_done % 10 == 0:
            print(f'{types_done}/{len(names)} types, {counts["valid"]} valid + {counts["invalid"]} random + {counts["boundary"]} boundary '
                  f'mutated + {counts["history"]} history cases, {len(findings)} findings, '
                  f'{time.monotonic() - started:.0f}s',
                  flush=True)

    report = {
        'seed': args.seed, 'types': len(names), 'valid_per_type': args.valid,
        'mutations_per_value': args.invalid, 'histories_per_type': args.histories,
        'operations_per_history': args.history, 'counts': counts, 'by_family': fam, 'value_modes': modes_run, 'mutation_kinds': kinds,
        'boundaries_per_value': args.boundaries, 'values_with_boundary_corruptions': args.boundary_values,
        'types_with_setters': sorted(n for n, e in FUZZ_OPS.items() if e['ops']),
        'types_without_setters': sorted(n for n, e in FUZZ_OPS.items() if not e['ops']),
        'generic_types': sorted(GENERIC_TY),
        'named_operations': {n: len(e['ops']) for n, e in FUZZ_OPS.items()},
        'elapsed_s': round(time.monotonic() - started, 1),
        'command': f'{sys.executable} tests_generated/fuzz_objects.py --seed {args.seed} '
                   f'--valid {args.valid} --invalid {args.invalid} --history {args.history} --histories {args.histories}',
        'toolchain': json.loads((ROOT / 'benchmarks/toolchain.json').read_text()),
        'source_sha256': {**{p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest()
                             for p in ['src/obj.bend', 'codegen/fulu.yaml', 'codegen/impl/generate.py', 'codegen/core/oracle.py']},
                          # the runtime, split per name and operation: its files in name order, concatenated
                          'types/*_generated.bend': hashlib.sha256(b''.join(
                              q.read_bytes() for q in sorted((ROOT / 'types').glob('*_generated.bend')))).hexdigest()},
        'findings': findings[:50], 'findings_total': len(findings), 'provenance': stamp(__file__),
        'note': 'oracle = codegen/core/oracle.py, written from the SSZ specification and validated '
                'against the 295 official static cases; comparison is full bytes and full '
                '32-byte roots, not checksums',
    }
    out = ROOT / 'benchmarks/evidence/fuzz_objects.json'
    out.write_text(json.dumps(report, indent=1) + '\n')
    print(f'{counts["valid"]} valid, {counts["invalid"]} random + {counts["boundary"]} boundary mutated and '
          f'{counts["history"]} history cases over {len(names)} types, {len(findings)} mismatches, {report["elapsed_s"]}s')
    sys.exit(1 if findings else 0)


if __name__ == '__main__':
    main()
