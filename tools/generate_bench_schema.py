#!/usr/bin/env python3
"""Read the independent Fulu schemas out of spec/fulu_schemas.bend.

The benchmark harness needs, for every contract type name, enough structure to
(a) generate a valid synthetic workload when no official fixture exists and
(b) describe the reference implementation. The schemas themselves are frozen;
this module only reads them, it never redefines a type.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

WIDTHS = {'P.U8{}': 1, 'P.U32Width{}': 4, 'P.U64{}': 8, 'P.U256{}': 32}


def _split_args(text):
    """Split `a, b, c` at top level (brackets and braces are nested)."""
    parts, depth, current = [], 0, ''
    for ch in text:
        if ch in '{[(':
            depth += 1
        elif ch in '}])':
            depth -= 1
        if ch == ',' and depth == 0:
            parts.append(current.strip())
            current = ''
        else:
            current += ch
    if current.strip():
        parts.append(current.strip())
    return parts


def _number(text):
    text = text.strip()
    m = re.fullmatch(r'(\d+)n', text)
    if m:
        return int(m.group(1))
    m = re.fullmatch(r'U32\.to_nat\((\d+)\)', text)
    if m:
        return int(m.group(1))
    m = re.fullmatch(r'Nat\.mul\((.+)\)', text, re.S)
    if m:
        a, b = _split_args(m.group(1))
        return _number(a) * _number(b)
    raise ValueError('unsupported size expression: ' + text)


class Schemas:
    def __init__(self):
        source = (ROOT / 'spec/fulu_schemas.bend').read_text()
        self.bodies = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.+)$', source, re.M))
        # `def Name() -> T.Schema: SchemaN()` gives the contract name of SchemaN.
        self.names = {n: b for n, b in self.bodies.items()}

    def resolve(self, name):
        """Structure of a type name as a nested description."""
        body = self.names[name]
        return self.parse(body)

    def parse(self, expr):
        expr = expr.strip()
        m = re.fullmatch(r'(Schema\d+)\(\)', expr)
        if m:
            return self.parse(self.bodies[m.group(1)])
        if expr == 'T.Boolean{}':
            return {'kind': 'boolean', 'size': 1}
        m = re.fullmatch(r'T\.Unsigned\{(.+)\}', expr)
        if m:
            return {'kind': 'uint', 'size': WIDTHS[m.group(1).strip()]}
        m = re.fullmatch(r'T\.ByteVector\{(.+)\}', expr)
        if m:
            return {'kind': 'byte_vector', 'size': _number(m.group(1))}
        m = re.fullmatch(r'T\.ByteList\{(.+)\}', expr)
        if m:
            return {'kind': 'byte_list', 'limit': _number(m.group(1))}
        m = re.fullmatch(r'T\.BitVector\{(.+)\}', expr)
        if m:
            bits = _number(m.group(1))
            return {'kind': 'bit_vector', 'bits': bits, 'size': (bits + 7) // 8}
        m = re.fullmatch(r'T\.BitList\{(.+)\}', expr)
        if m:
            return {'kind': 'bit_list', 'limit': _number(m.group(1))}
        m = re.fullmatch(r'T\.Vector\{(.+)\}', expr, re.S)
        if m:
            element, count = _split_args(m.group(1))
            return {'kind': 'vector', 'element': self.parse(element), 'count': _number(count)}
        m = re.fullmatch(r'T\.ListOf\{(.+)\}', expr, re.S)
        if m:
            element, limit = _split_args(m.group(1))
            return {'kind': 'list', 'element': self.parse(element), 'limit': _number(limit)}
        m = re.fullmatch(r'T\.Container\{\[(.*?)\], (.+)\}', expr, re.S)
        if m:
            names = [x.strip().strip('"') for x in _split_args(m.group(1))]
            return {'kind': 'container', 'names': names, 'fields': self.chain(m.group(2))}
        raise ValueError('unsupported schema expression: ' + expr[:80])

    def chain(self, expr):
        expr = expr.strip()
        fields = []
        while True:
            m = re.fullmatch(r'T\.Chain\{(.+)\}', expr, re.S)
            if not m:
                if expr != 'T.End{}':
                    raise ValueError('unterminated field chain: ' + expr[:60])
                return fields
            head, tail = _split_args(m.group(1))
            fields.append(self.parse(head))
            expr = tail.strip()


def fixed_size(node):
    """Serialized size in bytes, or None when the type is variable size."""
    kind = node['kind']
    if kind in ('boolean', 'uint', 'byte_vector', 'bit_vector'):
        return node['size']
    if kind in ('byte_list', 'bit_list', 'list'):
        return None
    if kind == 'vector':
        inner = fixed_size(node['element'])
        return None if inner is None else inner * node['count']
    if kind == 'container':
        total = 0
        for field in node['fields']:
            inner = fixed_size(field)
            if inner is None:
                return None
            total += inner
        return total
    raise ValueError('unknown kind ' + kind)
