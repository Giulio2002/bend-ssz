"""Compact runtime schemas for the official ssz_generic test types.

The ssz_generic cases use 144 distinct schemas, described by the frozen
tools/test_schemas.py (which reads them from the pinned consensus-spec test
format README; it never executes reference SSZ code). This generator converts
each description into the tuple form tools/generate_cschema.py already compiles
and emits:

  types/generic_cschema.bend        G0 .. G143, one compact schema each
  types/generic_cschema_index.bend  by_index(i), a balanced dispatch
  build/generic-index.json          the schema description of each index

Descriptions are keyed by their canonical JSON, so a case finds its index from
its own schema, never from its name or expected outcome.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import generate_cschema as G  # noqa: E402
import test_schemas as TS  # noqa: E402

TARGET = ROOT / 'types/generic_cschema.bend'
SPEC = ROOT / 'types/generic_spec.bend'
LITERAL = ROOT / 'build/cschema_literal/generic_cschema.bend'
WIDTH_CTORS = {1: 'U8', 2: 'U16', 4: 'U32Width', 8: 'U64', 16: 'U128', 32: 'U256'}
INDEX = ROOT / 'types/generic_cschema_index.bend'


def key(schema):
    return json.dumps(schema, sort_keys=True, separators=(',', ':'))


def to_tree(s):
    """A test-schema description as a generate_cschema tuple tree."""
    kind = s['kind']
    if kind == 'bool':
        return ('Boolean',)
    if kind == 'uint':
        return ('Unsigned', s['size'])
    if kind == 'bytes':
        return ('ByteVector', s['length'])
    if kind == 'bytelist':
        return ('ByteList', s['limit'])
    if kind == 'bits':
        return ('BitVector', s['length'])
    if kind == 'bitlist':
        return ('BitList', s['limit'])
    if kind == 'vector':
        return ('Vector', to_tree(s['element']), s['length'])
    if kind == 'list':
        return ('ListOf', to_tree(s['element']), s['limit'])
    if kind == 'container':
        names = [n for n, _ in s['fields']]
        if len(set(names)) != len(names):
            return ('Null',)  # duplicate field names: an illegal type
        chain = ('End',)
        for _, field in reversed(s['fields']):
            chain = ('Chain', to_tree(field), chain)
        return ('Container', chain)
    if kind == 'progressive_list':
        return ('ProgressiveList', to_tree(s['element']))
    if kind == 'progressive_bits':
        return ('ProgressiveBits',)
    if kind == 'progressive_container':
        names = [n for n, _ in s['fields']]
        if len(set(names)) != len(names):
            return ('Null',)
        chain = ('End',)
        for _, field in reversed(s['fields']):
            chain = ('Chain', to_tree(field), chain)
        return ('ProgressiveContainer', chain, tuple(bool(a) for a in s['active']))
    if kind == 'compatible_union':
        return ('CompatibleUnion', tuple(s['selectors']), tuple(to_tree(o) for o in s['options']))
    raise SystemExit('unsupported test schema kind: ' + kind)


def nat(n):
    """A Nat term: a literal below 2^32, else hi * 2^32 + lo."""
    if n < (1 << 32):
        return '%dn' % n
    hi, lo = n >> 32, n & 0xFFFFFFFF
    return 'Nat.add(Nat.mul(%dn, Nat.mul(65536n, 65536n)), %dn)' % (hi, lo)


def chain(terms):
    out = 'T.End{}'
    for t in reversed(terms):
        out = 'T.Chain{%s, %s}' % (t, out)
    return out


def strings(names):
    return '[%s]' % ', '.join(json.dumps(n) for n in names)


def spec_term(s):
    """The test-schema description as a spec schema (types/schema.bend) term."""
    kind = s['kind']
    if kind == 'bool':
        return 'T.Boolean{}'
    if kind == 'uint':
        return 'T.Unsigned{P.%s{}}' % WIDTH_CTORS[s['size']]
    if kind == 'bytes':
        return 'T.ByteVector{%s}' % nat(s['length'])
    if kind == 'bytelist':
        return 'T.ByteList{%s}' % nat(s['limit'])
    if kind == 'bits':
        return 'T.BitVector{%s}' % nat(s['length'])
    if kind == 'bitlist':
        return 'T.BitList{%s}' % nat(s['limit'])
    if kind == 'vector':
        return 'T.Vector{%s, %s}' % (spec_term(s['element']), nat(s['length']))
    if kind == 'list':
        return 'T.ListOf{%s, %s}' % (spec_term(s['element']), nat(s['limit']))
    if kind == 'container':
        return 'T.Container{%s, %s}' % (strings([n for n, _ in s['fields']]),
                                        chain([spec_term(f) for _, f in s['fields']]))
    if kind == 'progressive_list':
        return 'T.ProgressiveList{%s}' % spec_term(s['element'])
    if kind == 'progressive_bits':
        return 'T.ProgressiveBits{}'
    if kind == 'progressive_container':
        return 'T.ProgressiveContainer{%s, %s, [%s]}' % (
            strings([n for n, _ in s['fields']]), chain([spec_term(f) for _, f in s['fields']]),
            ', '.join('True{}' if a else 'False{}' for a in s['active']))
    if kind == 'compatible_union':
        return 'T.CompatibleUnion{[%s], %s}' % (', '.join(str(x) for x in s['selectors']),
                                                chain([spec_term(o) for o in s['options']]))
    raise SystemExit('unsupported test schema kind: ' + kind)


def main():
    cases = [c for c in json.loads((ROOT / 'cases.json').read_text()) if '/ssz_generic/' in c]
    descriptions = {}
    for case in cases:
        schema = TS.for_case(case)
        descriptions.setdefault(key(schema), schema)
    keys = sorted(descriptions)
    names = ['G%d' % i for i in range(len(keys))]
    lines = [
        'import Base',
        'import ../../src/cschema.bend as S',
        '',
        '# Generated by tools/generate_cschema_generic.py from the frozen',
        '# tools/test_schemas.py descriptions of the official ssz_generic types.',
        '# Do not edit by hand.',
        '',
    ]
    G.SHARED.clear()
    unsupported = []
    for name, k in zip(names, keys):
        tree = to_tree(descriptions[k])
        try:
            body = G.emit(tree, top=True)
        except SystemExit as why:
            # Not yet expressible in the compact schema: emit an explicit
            # placeholder that no input validates against, and list it.
            unsupported.append((name, str(why)))
            body = 'S.CFNone{}'
        lines.append('def %s() -> S.CS: %s' % (name, body))
        G.SHARED.setdefault(tree, name)
    LITERAL.parent.mkdir(parents=True, exist_ok=True)
    LITERAL.write_text('\n'.join(lines) + '\n')
    runtime = ['import Base', 'import ../src/cschema.bend as S', 'import ../src/ccompile.bend as K',
               'import ./generic_spec.bend as GS', '',
               '# Generated by tools/generate_cschema_generic.py. The compact schema of each',
               '# official ssz_generic test type is compiled from its spec schema',
               '# (types/generic_spec.bend) by src/ccompile.bend. Do not edit by hand.', '']
    for name in names:
        runtime.append('def %s() -> S.CS: K.compile(GS.%s())' % (name, name))
    TARGET.write_text('\n'.join(runtime) + '\n')
    spec = ['import Base', 'import ../types/schema.bend as T', 'import ../types/primitive.bend as P', '',
            '# Generated by tools/generate_cschema_generic.py: the official ssz_generic',
            '# test types as spec schemas (types/schema.bend), in the order of',
            '# build/generic-index.json. The compact runtime compiles these with',
            '# src/ccompile.bend. Do not edit by hand.', '']
    for name, k in zip(names, keys):
        spec.append('def %s() -> T.Schema: %s' % (name, spec_term(descriptions[k])))
    SPEC.write_text('\n'.join(spec) + '\n')
    legal_names = {name for name, k in zip(names, keys) if G.legal(to_tree(descriptions[k]))}
    INDEX.write_text(G.emit_index(names, './generic_spec.bend', 'tools/generate_cschema_generic.py',
                                  'build/generic-index.json', spec=True, legal_names=legal_names))
    (ROOT / 'build').mkdir(exist_ok=True)
    (ROOT / 'build/generic-index.json').write_text(json.dumps(
        {'schemas': [descriptions[k] for k in keys], 'unsupported': [n for n, _ in unsupported]}, indent=1) + '\n')
    print('wrote %s: %d schemas, %d not yet expressible' % (TARGET.relative_to(ROOT), len(keys), len(unsupported)))


if __name__ == '__main__':
    main()
