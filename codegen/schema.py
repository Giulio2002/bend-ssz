"""Load and resolve codegen/fulu.yaml.

The YAML names types in consensus-spec notation. `load(path)` parses it,
resolves every type expression to a small tree (`Ty`) and returns the named
types in file order. Anything malformed or unsupported raises SchemaError with
the offending name and expression; the generator never guesses.
"""
import ast
import re
from dataclasses import dataclass, field
from typing import List, Optional, Tuple



class SchemaError(Exception):
    pass


@dataclass(frozen=True)
class Ty:
    kind: str                      # bool uint bytes bytelist bits bitlist vector list container
                                   # plist pbits pcontainer cunion  (the generic SSZ forms)
    size: int = 0                  # uint: bytes; bytes/bits/vector: length; lists: limit
    elem: Optional['Ty'] = None
    fields: Tuple[Tuple[str, 'Ty'], ...] = ()
    name: Optional[str] = None     # the named container (or alias) this came from
    active: Tuple[int, ...] = ()   # pcontainer: the active-position mask
    selectors: Tuple[int, ...] = ()  # cunion: one selector per option (options are `fields`)

    def fixed(self) -> bool:
        if self.kind in ('bool', 'uint', 'bytes', 'bits'):
            return True
        if self.kind == 'vector':
            return self.elem.fixed()
        if self.kind in ('container', 'pcontainer'):
            return all(t.fixed() for _, t in self.fields)
        return False

    def fixed_size(self) -> int:
        k = self.kind
        if k == 'bool':
            return 1
        if k == 'uint':
            return self.size
        if k == 'bytes':
            return self.size
        if k == 'bits':
            return (self.size + 7) // 8
        if k == 'vector':
            return self.size * self.elem.fixed_size()
        if k in ('container', 'pcontainer'):
            return sum(t.fixed_size() for _, t in self.fields)
        raise SchemaError(f'variable-size type has no fixed size: {k}')

    def header(self) -> int:
        return self.fixed_size() if self.fixed() else 4


UINTS = {'uint8': 1, 'uint16': 2, 'uint32': 4, 'uint64': 8, 'uint128': 16, 'uint256': 32}


def _eval(expr, consts, where):
    node = ast.parse(expr, mode='eval').body

    def ev(n):
        if isinstance(n, ast.Constant) and isinstance(n.value, int):
            return n.value
        if isinstance(n, ast.Name):
            if n.id not in consts:
                raise SchemaError(f'{where}: unknown constant {n.id}')
            return consts[n.id]
        if isinstance(n, ast.BinOp) and isinstance(n.op, ast.FloorDiv):
            a, b = ev(n.left), ev(n.right)
            if b == 0 or a % b:
                raise SchemaError(f'{where}: {expr!r} is not an exact division')
            return a // b
        if isinstance(n, ast.BinOp) and isinstance(n.op, (ast.Add, ast.Sub, ast.Mult, ast.Pow)):
            a, b = ev(n.left), ev(n.right)
            return {ast.Add: a + b, ast.Sub: a - b, ast.Mult: a * b, ast.Pow: a ** b if b < 64 else None}[type(n.op)]
        if isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id == 'floorlog2' and len(n.args) == 1:
            v = ev(n.args[0])
            if v <= 0:
                raise SchemaError(f'{where}: floorlog2 of a non-positive value')
            return v.bit_length() - 1
        raise SchemaError(f'{where}: unsupported size expression {expr!r}')

    v = ev(node)
    if v is None or v < 0:
        raise SchemaError(f'{where}: invalid size {expr!r}')
    return v


def _split_args(s):
    depth, cur, out = 0, '', []
    for ch in s:
        if ch in '[(':
            depth += 1
        elif ch in '])':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    out.append(cur.strip())
    return out


class Resolver:
    def __init__(self, consts, raw):
        self.consts = consts
        self.raw = raw
        self.done = {}
        self.busy = set()

    def named(self, name):
        if name in self.done:
            return self.done[name]
        if name not in self.raw:
            raise SchemaError(f'unknown type {name}')
        if name in self.busy:
            raise SchemaError(f'recursive type {name}')
        self.busy.add(name)
        body = self.raw[name]
        if isinstance(body, list):
            fields, seen = [], set()
            if not body:
                raise SchemaError(f'{name}: a container needs at least one field')
            for item in body:
                if not isinstance(item, dict) or len(item) != 1:
                    raise SchemaError(f'{name}: each field is one "name: type" mapping')
                (f, t), = item.items()
                if not re.fullmatch(r'[a-z_][a-z0-9_]*', str(f)):
                    raise SchemaError(f'{name}: bad field name {f!r}')
                if f in seen:
                    raise SchemaError(f'{name}: duplicate field {f}')
                seen.add(f)
                fields.append((f, self.expr(str(t), f'{name}.{f}')))
            ty = Ty('container', fields=tuple(fields), name=name)
        elif isinstance(body, str):
            if body == name:
                ty = self.expr(body, name, base=True)
            else:
                ty = self.expr(body, name)
        else:
            raise SchemaError(f'{name}: a type is a field list or a type expression')
        self.busy.discard(name)
        self.done[name] = ty
        return ty

    def expr(self, s, where, base=False):
        s = s.strip()
        if s == 'boolean':
            return Ty('bool')
        if s in UINTS:
            return Ty('uint', UINTS[s])
        m = re.fullmatch(r'Bytes(\d+)', s)
        if m:
            n = int(m.group(1))
            if n == 0:
                raise SchemaError(f'{where}: zero-length byte vector')
            return Ty('bytes', n)
        if base:
            raise SchemaError(f'{where}: unsupported base type {s}')
        m = re.fullmatch(r'(ByteVector|ByteList|Bitvector|Bitlist)\[(.+)\]', s)
        if m:
            n = _eval(m.group(2), self.consts, where)
            kind = {'ByteVector': 'bytes', 'ByteList': 'bytelist', 'Bitvector': 'bits', 'Bitlist': 'bitlist'}[m.group(1)]
            if kind in ('bytes', 'bits') and n == 0:
                raise SchemaError(f'{where}: zero-length {m.group(1)}')
            return Ty(kind, n)
        m = re.fullmatch(r'(Vector|List)\[(.+)\]', s)
        if m:
            args = _split_args(m.group(2))
            if len(args) != 2:
                raise SchemaError(f'{where}: {m.group(1)} takes an element type and a size')
            elem = self.expr(args[0], where)
            n = _eval(args[1], self.consts, where)
            if m.group(1) == 'Vector':
                if n == 0:
                    raise SchemaError(f'{where}: zero-length Vector')
                return Ty('vector', n, elem)
            return Ty('list', n, elem)
        if re.fullmatch(r'[A-Z]\w*', s):
            return self.named(s)
        raise SchemaError(f'{where}: unsupported type expression {s!r}')


def load(path):
    import yaml  # only the YAML front end needs PyYAML
    with open(path) as f:
        doc = yaml.safe_load(f)
    if not isinstance(doc, dict) or set(doc) - {'prefix'} != {'constants', 'types'}:
        raise SchemaError('the schema has the sections constants and types (and an optional prefix)')
    consts = doc['constants'] or {}
    for k, v in consts.items():
        if not re.fullmatch(r'[A-Z][A-Z0-9_]*', str(k)) or not isinstance(v, int) or isinstance(v, bool) or v < 0:
            raise SchemaError(f'constant {k}: a non-negative integer with an upper-case name')
    raw = doc['types']
    if not isinstance(raw, dict):
        raise SchemaError('types must be a mapping')
    r = Resolver(consts, raw)
    return {n: r.named(n) for n in raw}


def load_prefix(path):
    """The schema's hardfork prefix (its `prefix:` entry; '' when absent)."""
    import yaml
    with open(path) as f:
        doc = yaml.safe_load(f)
    pre = doc.get('prefix', '') if isinstance(doc, dict) else ''
    if pre and not re.fullmatch(r'[A-Z][A-Za-z0-9]*', str(pre)):
        raise SchemaError(f'prefix {pre!r}: a capitalised identifier')
    return str(pre or '')


def to_json(t):
    """The frozen inventory's structural form (schemas/fulu_mainnet.json)."""
    k = t.kind
    if k == 'bool':
        return {'kind': 'bool', 'size': 1}
    if k == 'uint':
        return {'kind': 'uint', 'size': t.size}
    if k == 'bytes':
        return {'kind': 'bytes', 'length': t.size}
    if k == 'bits':
        return {'kind': 'bits', 'length': t.size}
    if k == 'bytelist':
        return {'kind': 'bytelist', 'limit': str(t.size)}
    if k == 'bitlist':
        return {'kind': 'bitlist', 'limit': str(t.size)}
    if k == 'vector':
        return {'kind': 'vector', 'length': t.size, 'element': to_json(t.elem)}
    if k == 'list':
        return {'kind': 'list', 'limit': str(t.size), 'element': to_json(t.elem)}
    return {'kind': 'container', 'fields': [[f, to_json(ft)] for f, ft in t.fields]}
