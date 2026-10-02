"""Reference-side extraction for tools/spec_audit/constants.py: consensus-specs markdown, presets and configs.

Stdlib only. Nothing here imports or executes pyspec: the markdown tables and python code blocks are read as text.
"""
import ast
import os
import re

FORKS = ['phase0', 'altair', 'bellatrix', 'capella', 'deneb', 'electra', 'fulu']
BASIC = {'boolean': ('bool',), 'bit': ('bool',), 'byte': ('uint', 8), 'uint8': ('uint', 8), 'uint16': ('uint', 16),
         'uint32': ('uint', 32), 'uint64': ('uint', 64), 'uint128': ('uint', 128), 'uint256': ('uint', 256)}
SUBSCRIPT = {'Vector', 'List', 'Bitvector', 'Bitlist', 'ByteVector', 'ByteList'}


def md_files(cs, fork):
    out = []
    base = os.path.join(cs, 'specs', fork)
    for root, _, files in os.walk(base):
        for f in sorted(files):
            p = os.path.join(root, f)
            if f.endswith('.md') and os.path.relpath(p, cs) != 'specs/phase0/deposit-contract.md':
                out.append(p)

    def key(p):  # pysetup/md_doc_paths.py sort_key: beacon-chain first, then polynomial-commitments, then the rest
        for i, k in enumerate(('beacon-chain', 'polynomial-commitments')):
            if k in p:
                return (i, p)
        return (2, p)
    return sorted(out, key=key)


def parse_flat_yaml(path):
    """KEY: value lines of a preset/config file -> {name: (value, line)}. Numeric values only."""
    out = {}
    for i, line in enumerate(open(path, encoding='utf-8'), 1):
        m = re.match(r'^([A-Z][A-Z0-9_]*):\s*([^#\s]+)', line)
        if not m:
            continue
        v = m.group(2).strip('\'"')
        try:
            out[m.group(1)] = (int(v, 0), i)
        except ValueError:
            pass
    return out


class RefError(Exception):
    pass


class Ref:
    def __init__(self, cs):
        self.cs = cs
        self.yaml = {}      # name -> (value, 'presets/mainnet/x.yaml:L')
        self.table = {}     # name -> (expr, 'specs/...md:L', fork)   latest definition wins
        self.table_hist = {}  # name -> list of (expr, loc, fork)
        self.classes = {}   # name -> {'fork', 'loc', 'fields': [(name, expr, line)]}
        self.class_hist = {}
        self.dups_in_fork = []
        self.used = set()   # constant names referenced while evaluating
        self.cache = {}
        self._load()

    def _load(self):
        cs = self.cs
        for fork in FORKS:
            p = os.path.join(cs, 'presets', 'mainnet', fork + '.yaml')
            if os.path.exists(p):
                for k, (v, ln) in parse_flat_yaml(p).items():
                    self.yaml[k] = (v, 'presets/mainnet/%s.yaml:%d' % (fork, ln))
        for k, (v, ln) in parse_flat_yaml(os.path.join(cs, 'configs', 'mainnet.yaml')).items():
            self.yaml.setdefault(k, (v, 'configs/mainnet.yaml:%d' % ln))
        for fork in FORKS:
            seen_this_fork = {}
            for path in md_files(cs, fork):
                rel = os.path.relpath(path, cs)
                self._scan_md(path, rel, fork, seen_this_fork)

    def _scan_md(self, path, rel, fork, seen):
        lines = open(path, encoding='utf-8').read().split('\n')
        in_py = False
        i = 0
        while i < len(lines):
            line = lines[i]
            if line.startswith('```'):
                in_py = (not in_py) and line.startswith('```python')
                i += 1
                continue
            if in_py:
                m = re.match(r'^class (\w+)\((\w+)\):\s*$', line)
                if m and m.group(2) == 'Container':
                    name, fields, j = m.group(1), [], i + 1
                    while j < len(lines) and lines[j].startswith('    ') and not lines[j].startswith('```'):
                        fm = re.match(r'^    (\w+): (.+?)\s*(?:#.*)?$', lines[j])
                        if fm:
                            fields.append((fm.group(1), fm.group(2).strip(), j + 1))
                        j += 1
                    entry = {'fork': fork, 'loc': '%s:%d' % (rel, i + 1), 'fields': fields}
                    if name in seen:
                        self.dups_in_fork.append((name, seen[name], entry['loc']))
                    seen[name] = entry['loc']
                    self.classes[name] = entry
                    self.class_hist.setdefault(name, []).append(entry)
                    i = j
                    continue
            else:
                m = re.match(r'^\|\s*`([A-Za-z_][A-Za-z0-9_]*)`\s*\|\s*`([^`]+)`', line)
                if m:
                    ent = (m.group(2).strip(), '%s:%d' % (rel, i + 1), fork)
                    self.table[m.group(1)] = ent
                    self.table_hist.setdefault(m.group(1), []).append(ent)
            i += 1

    # ---- constant evaluation --------------------------------------------------------------------------------
    def const(self, name, stack=()):
        """Integer value of a constant: preset/config yaml first, then the markdown tables."""
        if name in self.yaml:
            self.used.add(name)
            return self.yaml[name][0]
        if name in self.table:
            if name in stack:
                raise RefError('cycle at ' + name)
            expr, loc, fork = self.table[name]
            self.used.add(name)
            v = self.ev(ast.parse(expr, mode='eval').body, stack + (name,))
            if not isinstance(v, int):
                raise RefError('%s is not an integer: %r' % (name, v))
            return v
        raise RefError('unknown constant ' + name)

    def where(self, name):
        if name in self.yaml:
            return self.yaml[name][1]
        if name in self.table:
            return self.table[name][1]
        return None

    def ev(self, n, stack=()):
        if isinstance(n, ast.Constant):
            return n.value
        if isinstance(n, ast.Name):
            return self.const(n.id, stack)
        if isinstance(n, ast.UnaryOp) and isinstance(n.op, ast.USub):
            return -self.ev(n.operand, stack)
        if isinstance(n, ast.BinOp):
            a, b = self.ev(n.left, stack), self.ev(n.right, stack)
            ops = {ast.Add: lambda: a + b, ast.Sub: lambda: a - b, ast.Mult: lambda: a * b,
                   ast.FloorDiv: lambda: a // b, ast.Pow: lambda: a ** b, ast.Mod: lambda: a % b,
                   ast.LShift: lambda: a << b}
            return ops[type(n.op)]()
        if isinstance(n, ast.Call) and isinstance(n.func, ast.Name):
            if n.func.id == 'floorlog2':
                v = self.ev(n.args[0], stack)
                return v.bit_length() - 1
            if len(n.args) == 1:      # uint64(x), Epoch(x), GeneralizedIndex(x), DomainType('0x..'), ...
                return self.ev(n.args[0], stack)
        raise RefError('cannot evaluate ' + ast.dump(n)[:120])

    # ---- types ----------------------------------------------------------------------------------------------
    def type_of(self, expr, stack=()):
        """Normal form of a type expression. Aliases are expanded; containers are expanded in place."""
        return self._ty(ast.parse(expr, mode='eval').body, stack)

    def _ty(self, n, stack):
        if isinstance(n, ast.Name):
            return self.named(n.id, stack)
        if isinstance(n, ast.Subscript) and isinstance(n.value, ast.Name) and n.value.id in SUBSCRIPT:
            head = n.value.id
            args = n.slice.elts if isinstance(n.slice, ast.Tuple) else [n.slice]
            if head in ('Vector', 'List'):
                el, ln = self._ty(args[0], stack), self.ev(args[1], stack)
                if head == 'Vector':
                    return ('bytes', ln) if el == ('uint', 8) else ('vector', el, ln)
                return ('bytelist', ln) if el == ('uint', 8) else ('list', el, ln)
            ln = self.ev(args[0], stack)
            return {'Bitvector': ('bitvector', ln), 'Bitlist': ('bitlist', ln), 'ByteVector': ('bytes', ln),
                    'ByteList': ('bytelist', ln)}[head]
        raise RefError('unsupported type expression ' + ast.dump(n)[:120])

    def named(self, name, stack):
        if name in BASIC:
            return BASIC[name]
        m = re.fullmatch(r'Bytes(\d+)', name)
        if m:
            return ('bytes', int(m.group(1)))
        if name in stack:
            raise RefError('type cycle at ' + name)
        key = name
        if key in self.cache:
            return self.cache[key]
        if name in self.classes:
            fields = tuple((f, self._ty(ast.parse(e, mode='eval').body, stack + (name,))) for f, e, _ in self.classes[name]['fields'])
            r = ('container', fields)
        elif name in self.table:      # custom type table: `| Slot | uint64 |`
            r = self._ty(ast.parse(self.table[name][0], mode='eval').body, stack + (name,))
        else:
            raise RefError('unknown type ' + name)
        self.cache[key] = r
        return r

    def type_loc(self, name):
        if name in self.classes:
            return self.classes[name]['loc']
        if name in self.table:
            return self.table[name][1]
        return None


# ---- generalized indices (ssz/merkle-proofs.md): only what the constant tables of the light-client / DAS specs need ----
def _p2c(n):
    return 1 if n <= 1 else 1 << (n - 1).bit_length()


def _item_len(nf):
    if nf[0] == 'bool':
        return 1
    if nf[0] == 'uint':
        return nf[1] // 8
    return 32


def _chunk_count(nf):
    k = nf[0]
    if k in ('bool', 'uint'):
        return 1
    if k in ('bitvector', 'bitlist'):
        return (nf[1] + 255) // 256
    if k in ('bytes', 'bytelist'):
        return (nf[1] + 31) // 32
    if k in ('vector', 'list'):
        return (nf[2] * _item_len(nf[1]) + 31) // 32
    if k == 'container':
        return len(nf[1])
    raise RefError('chunk_count of ' + k)


def gindex(nf, path):
    """get_generalized_index of ssz/merkle-proofs.md for a container/list path of field names and integer indices."""
    root = 1
    for p in path:
        k = nf[0]
        if k == 'container':
            names = [f for f, _ in nf[1]]
            pos, elem = names.index(p), nf[1][names.index(p)][1]
            base = 1
        elif k in ('list', 'vector'):
            elem, base = nf[1], (2 if k == 'list' else 1)
            pos = p * _item_len(elem) // 32 if elem[0] in ('bool', 'uint') else p
        else:
            raise RefError('path through ' + k)
        root = root * base * _p2c(_chunk_count(nf)) + pos
        nf = elem
    return root


def _install(cls):
    old_ev = cls.ev

    def ev(self, n, stack=()):
        import ast as _ast
        if isinstance(n, _ast.Call) and isinstance(n.func, _ast.Name):
            if n.func.id == 'ceillog2':
                v = self.ev(n.args[0], stack)
                return (v - 1).bit_length() if v > 1 else 0
            if n.func.id == 'get_generalized_index':
                t = n.args[0]
                if isinstance(t, _ast.Attribute):          # altair.BeaconState: the container as of that fork
                    ent = [e for e in self.class_hist[t.attr] if FORKS.index(e['fork']) <= FORKS.index(t.value.id)][-1]
                    nf = ('container', tuple((f, self.type_of_expr(e)) for f, e, _ in ent['fields']))
                else:
                    nf = self.named(t.id, stack)
                return gindex(nf, [a.value for a in n.args[1:]])
        return old_ev(self, n, stack)
    cls.ev = ev
    cls.type_of_expr = lambda self, e: self._ty(ast.parse(e, mode='eval').body, ())


_install(Ref)
