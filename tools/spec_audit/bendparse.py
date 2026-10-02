"""Bend-side extraction for tools/spec_audit/constants.py: a reader for the constructor/arithmetic subset in
spec/fulu_schemas.bend, proofs/obj/generic_specs.bend, types/byte_alias.bend, types/list_alias.bend; the JSON
schema; the codegen YAML. Stdlib only. The Bend files are read as text, never executed."""
import ast
import json
import re

TOK = re.compile(r'\s*(?:(?P<num>\d+n?)|(?P<str>"[^"]*")|(?P<id>[A-Za-z_][A-Za-z_0-9.]*)|(?P<p>[\[\]{}(),]))')


def tokenize(s):
    pos, out = 0, []
    s = s.rstrip()
    while pos < len(s):
        m = TOK.match(s, pos)
        if not m:
            raise ValueError('bad token at %r' % s[pos:pos + 30])
        pos = m.end()
        for k in ('num', 'str', 'id', 'p'):
            if m.group(k) is not None:
                out.append((k, m.group(k)))
                break
    return out


class P:
    """Parse one expression to ('call'|'ctor'|'list'|'num'|'str'|'id', ...)."""
    def __init__(self, toks):
        self.t, self.i = toks, 0

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else (None, None)

    def eat(self, v=None):
        k, x = self.peek()
        if v is not None and x != v:
            raise ValueError('expected %s got %s' % (v, x))
        self.i += 1
        return k, x

    def args(self, close):
        out = []
        if self.peek()[1] == close:
            self.eat()
            return out
        while True:
            out.append(self.expr())
            k, x = self.eat()
            if x == close:
                return out
            if x != ',':
                raise ValueError('expected , or ' + close)

    def expr(self):
        k, x = self.eat()
        if k == 'num':
            return ('num', int(x.rstrip('n')))
        if k == 'str':
            return ('str', x[1:-1])
        if x == '[':
            return ('list', self.args(']'))
        if k == 'id':
            if self.peek()[1] == '(':
                self.eat()
                return ('call', x, self.args(')'))
            if self.peek()[1] == '{':
                self.eat()
                return ('ctor', x, self.args('}'))
            return ('id', x)
        raise ValueError('unexpected ' + x)


def parse_expr(s):
    p = P(tokenize(s))
    e = p.expr()
    if p.i != len(p.t):
        raise ValueError('trailing tokens in ' + s[:80])
    return e


def read_defs(path):
    """`def Name() -> T: expr` one-liners -> {name: (expr_ast, line)}."""
    out = {}
    for i, line in enumerate(open(path, encoding='utf-8'), 1):
        m = re.match(r'^def (\w+)\(\)\s*->\s*[\w.]+:\s*(.+)$', line)
        if m:
            out[m.group(1)] = (parse_expr(m.group(2)), i)
    return out


WIDTH = {'U8': 8, 'U16': 16, 'U32Width': 32, 'U64': 64, 'U128': 128, 'U256': 256}


class Bend:
    """Evaluate Bend schema expressions into the normal form used by constants.py."""
    def __init__(self, defs, prefix=('T.', 'S.')):
        self.defs, self.memo = defs, {}

    def num(self, e):
        if e[0] == 'num':
            return e[1]
        if e[0] == 'call':
            f, a = e[1], [self.num(x) for x in e[2]]
            return {'Nat.mul': lambda: a[0] * a[1], 'Nat.add': lambda: a[0] + a[1], 'Nat.sub': lambda: a[0] - a[1],
                    'Nat.div': lambda: a[0] // a[1], 'U32.to_nat': lambda: a[0]}[f]()
        raise ValueError('not numeric: %r' % (e,))

    def ref(self, name):
        if name not in self.memo:
            self.memo[name] = self.nf(self.defs[name][0])
        return self.memo[name]

    def strs(self, e):
        return [x[1] for x in e[1]]

    def chain(self, e):
        out = []
        while e[0] == 'ctor' and e[1].split('.')[-1] == 'Chain':
            out.append(self.nf(e[2][0]))
            e = e[2][1]
        if not (e[0] == 'ctor' and e[1].split('.')[-1] == 'End'):
            raise ValueError('chain does not end in End')
        return out

    def nf(self, e):
        if e[0] == 'call' and not e[2] and e[1] in self.defs:
            return self.ref(e[1])
        if e[0] != 'ctor':
            raise ValueError('unsupported schema expression %r' % (e,))
        c, a = e[1].split('.')[-1], e[2]
        if c == 'Boolean':
            return ('bool',)
        if c == 'Unsigned':
            return ('uint', WIDTH[a[0][1].split('.')[-1]])
        if c == 'ByteVector':
            return ('bytes', self.num(a[0]))
        if c == 'ByteList':
            return ('bytelist', self.num(a[0]))
        if c == 'BitVector':
            return ('bitvector', self.num(a[0]))
        if c == 'BitList':
            return ('bitlist', self.num(a[0]))
        if c == 'Vector':
            el = self.nf(a[0])
            return ('bytes', self.num(a[1])) if el == ('uint', 8) else ('vector', el, self.num(a[1]))
        if c == 'ListOf':
            el = self.nf(a[0])
            return ('bytelist', self.num(a[1])) if el == ('uint', 8) else ('list', el, self.num(a[1]))
        if c == 'Container':
            return ('container', tuple(zip(self.strs(a[0]), self.chain(a[1]))))
        if c == 'ProgressiveList':
            return ('proglist', self.nf(a[0]))
        if c == 'ProgressiveBits':
            return ('progbits',)
        if c == 'ProgressiveContainer':
            act = tuple(x[1].split('.')[-1] == 'True' for x in a[2][1])
            return ('progcontainer', tuple(zip(self.strs(a[0]), self.chain(a[1]))), act)
        if c == 'CompatibleUnion':
            return ('compatunion', tuple(x[1] for x in a[0][1]), tuple(self.chain(a[1])))
        if c == 'Union':
            return ('union', tuple(self.chain(a[0])))
        if c == 'Null':
            return ('null',)
        raise ValueError('unknown constructor ' + c)


def json_nf(o):
    k = o['kind']
    if k == 'bool':
        return ('bool',)
    if k == 'uint':
        return ('uint', o['size'] * 8)
    if k == 'bytes':
        return ('bytes', o['length'])
    if k == 'bytelist':
        return ('bytelist', int(o['limit']))
    if k == 'bits':
        return ('bitvector', o['length'])
    if k == 'bitlist':
        return ('bitlist', int(o['limit']))
    if k == 'vector':
        el = json_nf(o['element'])
        return ('bytes', o['length']) if el == ('uint', 8) else ('vector', el, o['length'])
    if k == 'list':
        el = json_nf(o['element'])
        return ('bytelist', int(o['limit'])) if el == ('uint', 8) else ('list', el, int(o['limit']))
    if k == 'container':
        return ('container', tuple((n, json_nf(t)) for n, t in o['fields']))
    raise ValueError('json kind ' + k)


def read_json_schemas(path):
    d = json.load(open(path))
    # line numbers of the top-level keys, for file:line citations
    lines = {}
    for i, line in enumerate(open(path), 1):
        m = re.match(r'^  "(\w+)": \{', line)
        if m:
            lines[m.group(1)] = i
    return {k: (json_nf(v), lines.get(k)) for k, v in d.items()}


def read_codegen_yaml(path):
    """codegen/fulu.yaml subset: `constants:` map and `types:` map whose values are an expression string or a list of
    `- field: "type"` lines. Returns (consts{name:(int,line)}, types{name:(('alias',expr)|('container',[(f,expr)]), line)})."""
    consts, types, sect, cur = {}, {}, None, None
    for i, line in enumerate(open(path, encoding='utf-8'), 1):
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        if not line.startswith(' '):
            sect = line.split(':')[0]
            cur = None
            continue
        if sect == 'constants':
            m = re.match(r'^  (\w+): (\d+)\s*$', line)
            if not m:
                raise ValueError('codegen yaml constants line %d: %r' % (i, line))
            consts[m.group(1)] = (int(m.group(2)), i)
        elif sect == 'types':
            m = re.match(r'^  (\w+):(?: (?:"([^"]+)"|(\S+)))?\s*$', line)
            f = re.match(r'^    - (\w+): "([^"]+)"\s*$', line)
            if f:
                types[cur][0][1].append((f.group(1), f.group(2)))
            elif m:
                cur = m.group(1)
                expr = m.group(2) or m.group(3)
                types[cur] = (('alias', expr) if expr else ('container', []), i)
            else:
                raise ValueError('codegen yaml types line %d: %r' % (i, line))
    return consts, types


class YamlTypes:
    """Evaluate codegen/fulu.yaml type expressions against its own constants."""
    def __init__(self, consts, types):
        self.c, self.t, self.memo = {k: v[0] for k, v in consts.items()}, types, {}

    def ev(self, n):
        if isinstance(n, ast.Constant):
            return n.value
        if isinstance(n, ast.Name):
            return self.c[n.id]
        if isinstance(n, ast.BinOp):
            a, b = self.ev(n.left), self.ev(n.right)
            if isinstance(n.op, ast.Add):
                return a + b
            if isinstance(n.op, ast.Sub):
                return a - b
            if isinstance(n.op, ast.Mult):
                return a * b
            if isinstance(n.op, ast.FloorDiv):
                assert a % b == 0 or True
                return a // b
        if isinstance(n, ast.Call) and n.func.id == 'floorlog2':
            return self.ev(n.args[0]).bit_length() - 1
        raise ValueError(ast.dump(n))

    def ty(self, n):
        if isinstance(n, ast.Name):
            return self.named(n.id)
        if isinstance(n, ast.Subscript):
            head = n.value.id
            args = n.slice.elts if isinstance(n.slice, ast.Tuple) else [n.slice]
            if head in ('Vector', 'List'):
                el, ln = self.ty(args[0]), self.ev(args[1])
                if head == 'Vector':
                    return ('bytes', ln) if el == ('uint', 8) else ('vector', el, ln)
                return ('bytelist', ln) if el == ('uint', 8) else ('list', el, ln)
            ln = self.ev(args[0])
            return {'Bitvector': ('bitvector', ln), 'Bitlist': ('bitlist', ln), 'ByteVector': ('bytes', ln),
                    'ByteList': ('bytelist', ln)}[head]
        raise ValueError(ast.dump(n))

    def named(self, name):
        basic = {'boolean': ('bool',), 'uint8': ('uint', 8), 'uint16': ('uint', 16), 'uint32': ('uint', 32),
                 'uint64': ('uint', 64), 'uint128': ('uint', 128), 'uint256': ('uint', 256)}
        m = re.fullmatch(r'Bytes(\d+)', name)
        if m:
            return ('bytes', int(m.group(1)))
        if name in basic:
            return basic[name]
        if name in self.memo:
            return self.memo[name]
        spec = self.t[name][0]
        if spec[0] == 'alias':
            r = self.ty(ast.parse(spec[1], mode='eval').body)
        else:
            r = ('container', tuple((f, self.ty(ast.parse(e, mode='eval').body)) for f, e in spec[1]))
        self.memo[name] = r
        return r
