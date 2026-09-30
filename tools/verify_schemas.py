#!/usr/bin/env python3
"""Cross-check the schema sources against each other, independently of the generators.

    python3 tools/verify_schemas.py      # exit 1 naming every difference

Four comparisons, each with its own reader (none of them imports a generator):

  1. vendor/consensus-specs/fulu_mainnet.py -> schemas/fulu_mainnet.json. The Python module is
     read with `ast`, never executed: top-level constants are evaluated (integers, + - * // **,
     the uint/alias wrappers, floorlog2), classes are resolved (aliases such as
     `class Slot(uint64)`, `Container` fields in order, List/Vector/Bitlist/Bitvector/ByteList/
     ByteVector[...], BytesN; a later definition of a class replaces an earlier one, as in
     Python). Every JSON name must equal the structure the module defines for it.
  2. schemas/fulu_mainnet.json -> spec/fulu_schemas.bend. The Bend file is parsed into terms
     (`def NAME() -> T.Schema: TERM`; T.Container{[names], T.Chain{..T.End{}}}, T.Unsigned{P.W{}},
     T.ByteVector/ByteList/BitVector/BitList{n}, T.Vector/ListOf{elem, n}, literals `Nn`,
     `U32.to_nat(N)` and `Nat.mul(a, b)`); the set of exported names must equal the JSON's and
     every structure must be equal.
  3. cases.json -> fixtures. Every case has its fixture files (serialized.ssz_snappy, plus
     value.yaml and roots.yaml for ssz_static, value.yaml and meta.yaml for a valid ssz_generic
     case) in fixtures.manifest.json and on disk, and every case directory of the manifest is in cases.json.
  4. cases.json -> the generic schemas. Every ssz_generic case resolves to a schema of the frozen
     generic descriptions (tools/test_schemas.py, read from the suite's README); the schemas of
     the supported forms (all but the zero-length vectors and bit vectors, which are not SSZ
     types), minus the five basic types the Fulu set already has, must be exactly the schemas of
     proofs/obj/generic_specs.bend (parsed as in 2, with ProgressiveList, ProgressiveBits,
     ProgressiveContainer and CompatibleUnion; the classes' field names A, B, .. are written
     f_A, f_B, .. there, which is undone), and every one of those must have a case.

codegen/check_schema.py (codegen/fulu.yaml against the JSON) runs this too, so strictcheck and
regen_all.py --check cover it; tools/check_fast.sh runs it before checking anything.
"""
import ast
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WIDTH = {'U8': 1, 'U16': 2, 'U32Width': 4, 'U32': 4, 'U64': 8, 'U128': 16, 'U256': 32}


def canon(s):
    """The JSON structural form with every number an int (the JSON writes limits as strings)."""
    if isinstance(s, dict):
        return {k: canon(v) for k, v in s.items()}
    if isinstance(s, list):
        return [canon(x) for x in s]
    if isinstance(s, str) and re.fullmatch(r'\d+', s):
        return int(s)
    return s


def key(s):
    return json.dumps(canon(s), sort_keys=True)


# ---------------------------------------------------------------- 1. the Python module

def read_pyspec(path):
    tree = ast.parse(path.read_text())
    consts, classes = {}, {}
    basic = {'boolean': {'kind': 'bool', 'size': 1}, 'bit': {'kind': 'bool', 'size': 1},
             'byte': {'kind': 'uint', 'size': 1}}
    basic.update({'uint%d' % n: {'kind': 'uint', 'size': n // 8} for n in (8, 16, 32, 64, 128, 256)})

    def num(e):
        if isinstance(e, ast.Constant) and isinstance(e.value, int) and not isinstance(e.value, bool):
            return e.value
        if isinstance(e, ast.Name):
            return consts[e.id]
        if isinstance(e, ast.BinOp):
            a, b = num(e.left), num(e.right)
            op = type(e.op)
            return {ast.Add: lambda: a + b, ast.Sub: lambda: a - b, ast.Mult: lambda: a * b,
                    ast.FloorDiv: lambda: a // b, ast.Pow: lambda: a ** b, ast.LShift: lambda: a << b}[op]()
        if isinstance(e, ast.Call) and isinstance(e.func, ast.Name) and len(e.args) == 1 and not e.keywords:
            v = num(e.args[0])
            if e.func.id == 'floorlog2':
                return v.bit_length() - 1
            return v  # uint64(..), Gwei(..), GeneralizedIndex(..): the value itself
        raise KeyError(ast.dump(e))

    def typ(e):
        if isinstance(e, ast.Name):
            n = e.id
            if n in basic:
                return basic[n]
            m = re.fullmatch(r'Bytes(\d+)', n)
            if m:
                return {'kind': 'bytes', 'length': int(m[1])}
            return resolve(n)
        if isinstance(e, ast.Subscript) and isinstance(e.value, ast.Name):
            f = e.value.id
            args = e.slice.elts if isinstance(e.slice, ast.Tuple) else [e.slice]
            if f == 'List':
                return {'kind': 'list', 'element': typ(args[0]), 'limit': num(args[1])}
            if f == 'Vector':
                return {'kind': 'vector', 'element': typ(args[0]), 'length': num(args[1])}
            if f == 'Bitlist':
                return {'kind': 'bitlist', 'limit': num(args[0])}
            if f == 'Bitvector':
                return {'kind': 'bits', 'length': num(args[0])}
            if f == 'ByteList':
                return {'kind': 'bytelist', 'limit': num(args[0])}
            if f == 'ByteVector':
                return {'kind': 'bytes', 'length': num(args[0])}
        raise KeyError(ast.dump(e))

    done = {}

    def resolve(n):
        if n in done:
            return done[n]
        node = classes[n]
        base = node.bases[0]
        if isinstance(base, ast.Name) and base.id == 'Container':
            s = {'kind': 'container', 'fields': [[x.target.id, typ(x.annotation)] for x in node.body
                                                 if isinstance(x, ast.AnnAssign) and isinstance(x.target, ast.Name)]}
        else:
            s = typ(base)
        done[n] = s
        return s

    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            try:
                consts[node.targets[0].id] = num(node.value)
            except (KeyError, ZeroDivisionError, TypeError):
                pass
        elif isinstance(node, ast.ClassDef) and node.bases:
            classes[node.name] = node  # a later definition replaces an earlier one
    # the remerkleable byte vectors the module imports (Bytes1 .. Bytes96) are types too
    basic.update({'Bytes%d' % n: {'kind': 'bytes', 'length': n} for n in (1, 4, 8, 20, 32, 48, 64, 96)})
    out = {}
    for n in list(basic) + list(classes):
        try:
            out[n] = basic[n] if n in basic else resolve(n)
        except KeyError:
            pass  # not an SSZ type (a class over a non-SSZ base)
    return out


# ---------------------------------------------------------------- 2. Bend schema terms

TOKEN = re.compile(r'\s*(?:(?P<str>"[^"]*")|(?P<num>\d+n?)|(?P<name>[A-Za-z_][\w.]*)|(?P<p>[{}\[\](),]))')


def parse_term(text):
    toks, i = [], 0
    while i < len(text):
        m = TOKEN.match(text, i)
        if not m or m.end() == i:
            if text[i:].strip() == '':
                break
            raise ValueError('cannot read %r' % text[i:i + 30])
        toks.append(next((k, v) for k, v in m.groupdict().items() if v is not None))
        i = m.end()
    pos = [0]

    def peek():
        return toks[pos[0]] if pos[0] < len(toks) else (None, None)

    def take(v=None):
        t = toks[pos[0]]
        if v is not None and t[1] != v:
            raise ValueError('expected %s, got %s' % (v, t[1]))
        pos[0] += 1
        return t

    def term():
        k, v = take()
        if k == 'str':
            return ('str', v[1:-1])
        if k == 'num':
            return ('nat', int(v[:-1])) if v.endswith('n') else ('u32', int(v))
        if k == 'p' and v == '[':
            xs = []
            while peek()[1] != ']':
                xs.append(term())
                if peek()[1] == ',':
                    take(',')
            take(']')
            return ('list', xs)
        if k == 'name':
            if peek()[1] in ('{', '('):
                close = '}' if take()[1] == '{' else ')'
                args = []
                while peek()[1] != close:
                    args.append(term())
                    if peek()[1] == ',':
                        take(',')
                take(close)
                return ('ctor' if close == '}' else 'call', v, args)
            return ('ref', v)
        raise ValueError('unexpected %r' % v)

    t = term()
    if pos[0] != len(toks):
        raise ValueError('trailing tokens')
    return t


def read_bend_schemas(path, field_prefix=''):
    defs = {}
    for line in path.read_text().splitlines():
        m = re.match(r'def ([A-Za-z_]\w*)\(\) -> \w+\.Schema: (.*)$', line)
        if m:
            defs[m[1]] = parse_term(m[2])
    done = {}

    def nat(t):
        if t[0] in ('nat', 'u32'):
            return t[1]
        if t[0] == 'call' and t[1] == 'U32.to_nat':
            return nat(t[2][0])
        if t[0] == 'call' and t[1] == 'Nat.mul':
            return nat(t[2][0]) * nat(t[2][1])
        raise ValueError('not a number: %r' % (t,))

    def chain(t):
        out = []
        while t[1].endswith('.Chain'):
            out.append(sch(t[2][0]))
            t = t[2][1]
        if not t[1].endswith('.End'):
            raise ValueError('bad chain end %r' % (t[1],))
        return out

    def boolean(t):
        return {'True': True, 'False': False}[t[1]]

    def sch(t):
        if t[0] == 'call' and not t[2]:
            return schema(t[1])
        if t[0] != 'ctor':
            raise ValueError('not a schema: %r' % (t,))
        c, a = t[1].split('.')[-1], t[2]
        if c == 'Boolean':
            return {'kind': 'bool', 'size': 1}
        if c == 'Unsigned':
            return {'kind': 'uint', 'size': WIDTH[a[0][1].split('.')[-1]]}
        if c == 'ByteVector':
            return {'kind': 'bytes', 'length': nat(a[0])}
        if c == 'ByteList':
            return {'kind': 'bytelist', 'limit': nat(a[0])}
        if c == 'BitVector':
            return {'kind': 'bits', 'length': nat(a[0])}
        if c == 'BitList':
            return {'kind': 'bitlist', 'limit': nat(a[0])}
        if c == 'Vector':
            return {'kind': 'vector', 'element': sch(a[0]), 'length': nat(a[1])}
        if c == 'ListOf':
            return {'kind': 'list', 'element': sch(a[0]), 'limit': nat(a[1])}
        if c == 'ProgressiveList':
            return {'kind': 'progressive_list', 'element': sch(a[0])}
        if c == 'ProgressiveBits':
            return {'kind': 'progressive_bits'}
        if c in ('Container', 'ProgressiveContainer'):
            names = [x[1] for x in a[0][1]]
            if field_prefix:
                if not all(x.startswith(field_prefix) for x in names):
                    raise ValueError('field names without the %r prefix: %r' % (field_prefix, names))
                names = [x[len(field_prefix):] for x in names]
            s = {'kind': 'container', 'fields': [list(p) for p in zip(names, chain(a[1]))]}
            if len(names) != len(s['fields']):
                raise ValueError('field names and types differ in number')
            if c == 'ProgressiveContainer':
                s = {'kind': 'progressive_container', 'fields': s['fields'], 'active': [int(boolean(x)) for x in a[2][1]]}
            return s
        if c == 'CompatibleUnion':
            return {'kind': 'compatible_union', 'selectors': [nat(x) for x in a[0][1]], 'options': chain(a[1])}
        raise ValueError('unknown schema constructor ' + t[1])

    def schema(n):
        if n not in done:
            done[n] = sch(defs[n])
        return done[n]

    return {n: schema(n) for n in defs}


# ---------------------------------------------------------------- the checks

def main():
    bad = []
    frozen = json.loads((ROOT / 'schemas/fulu_mainnet.json').read_text())

    # 1. fulu_mainnet.py -> JSON
    py = read_pyspec(ROOT / 'vendor/consensus-specs/fulu_mainnet.py')
    for n, s in frozen.items():
        if n not in py:
            bad.append('fulu_mainnet.py defines no SSZ type %s (in the JSON)' % n)
        elif key(py[n]) != key(s):
            bad.append('%s: fulu_mainnet.py %s != JSON %s' % (n, key(py[n])[:200], key(s)[:200]))

    # 2. JSON -> spec/fulu_schemas.bend
    bend = {n: s for n, s in read_bend_schemas(ROOT / 'spec/fulu_schemas.bend').items()
            if not re.fullmatch(r'Schema\d+', n)}
    if set(bend) != set(frozen):
        bad.append('spec/fulu_schemas.bend names != JSON names: only in bend %s, only in JSON %s'
                   % (sorted(set(bend) - set(frozen)), sorted(set(frozen) - set(bend))))
    for n in sorted(set(bend) & set(frozen)):
        if key(bend[n]) != key(frozen[n]):
            bad.append('%s: spec/fulu_schemas.bend %s != JSON %s' % (n, key(bend[n])[:200], key(frozen[n])[:200]))

    # 3. cases.json -> fixtures
    cases = json.loads((ROOT / 'cases.json').read_text())
    manifest = json.loads((ROOT / 'fixtures.manifest.json').read_text())
    if len(set(cases)) != len(cases):
        bad.append('cases.json lists a case twice')
    dirs = {}
    for f in manifest:
        dirs.setdefault(f.rsplit('/', 1)[0], set()).add(f.rsplit('/', 1)[1])
    for c in cases:
        # ssz_static: value and roots; ssz_generic valid: value and meta (the root); invalid: the bytes
        need = {'serialized.ssz_snappy'} | ({'value.yaml', 'roots.yaml'} if '/ssz_static/' in c else
                                            {'value.yaml', 'meta.yaml'} if '/valid/' in c else set())
        missing = [x for x in sorted(need) if x not in dirs.get(c, ())]
        missing += [x for x in sorted(dirs.get(c, ())) if not (ROOT / 'fixtures' / c / x).exists()]
        if missing:
            bad.append('%s: fixture files missing: %s' % (c, ', '.join(missing)))
    extra = sorted(set(dirs) - set(cases))
    if extra:
        bad.append('%d fixture case directories are not in cases.json, e.g. %s' % (len(extra), extra[:3]))

    # 4. cases.json -> the generic schemas
    sys.path.insert(0, str(ROOT / 'tools'))
    import test_schemas  # the frozen generic descriptions (read from the suite's README)
    generic = [c for c in cases if '/ssz_generic/' in c]
    want = {}
    for c in generic:
        try:
            s = test_schemas.for_case(c)
        except (ValueError, KeyError, TypeError) as e:
            bad.append('%s: no generic schema (%s)' % (c, e))
            continue
        want.setdefault(key(s), s)
    zero = {k for k, s in want.items() if s['kind'] in ('vector', 'bits') and int(s['length']) == 0}
    shared = {key(frozen[n]) for n in ('boolean', 'uint8', 'uint32', 'uint64', 'uint256')}
    supported = set(want) - zero
    # the generic classes' field names (A, B, ...) are written f_A, f_B, ... in Bend (codegen/generic.py)
    gspecs = read_bend_schemas(ROOT / 'proofs/obj/generic_specs.bend', field_prefix='f_')
    have = {}
    for n, s in gspecs.items():
        if key(s) in have:
            bad.append('proofs/obj/generic_specs.bend: %s and %s are the same schema' % (have[key(s)], n))
        have[key(s)] = n
    only_cases = supported - shared - set(have)
    only_bend = set(have) - supported
    if only_cases:
        bad.append('%d supported generic schemas have no def in generic_specs.bend, e.g. %s'
                   % (len(only_cases), sorted(only_cases)[:2]))
    if only_bend:
        bad.append('%d generic_specs.bend schemas have no case: %s' % (len(only_bend), sorted(have[k] for k in only_bend)[:5]))
    if bad:
        print('verify_schemas: MISMATCH:\n  ' + '\n  '.join(bad[:60]))
        sys.exit(1)
    print('verify_schemas: fulu_mainnet.py = schemas/fulu_mainnet.json = spec/fulu_schemas.bend (%d names); '
          '%d cases with their fixtures; %d generic cases -> %d schemas (%d zero-length, not SSZ types), '
          '%d = %d in proofs/obj/generic_specs.bend + %d basic types shared with the Fulu set'
          % (len(frozen), len(cases), len(generic), len(want), len(zero), len(supported), len(have),
             len(supported & shared)))


if __name__ == '__main__':
    main()
