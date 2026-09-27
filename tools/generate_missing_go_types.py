#!/usr/bin/env python3
"""Generate fastssz definitions for the contract types the pinned
go-eth2-client does not carry.

The benchmark contract requires a reference comparison for all 109 Fulu types;
go-eth2-client v0.27.2 defines SSZ methods for 47 of the 59 containers. For
the remaining ones this emits Go structs - derived mechanically from the same
frozen schemas in spec/fulu_schemas.bend that the Bend side uses - and runs
pinned fastssz's own code generator (sszgen, fastssz v0.1.4) over them, which
is exactly how fastssz users obtain SSZ methods. Nothing here hand-writes an
encoder.

    python3 tools/generate_missing_go_types.py
"""
import json
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_bench_schema import Schemas, fixed_size
from generate_bench_go import go_candidates

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / 'benchmarks/fastssz/gen'


def camel(name):
    return ''.join(part.capitalize() for part in re.split(r'[^A-Za-z0-9]+', name) if part)


def key_of(node):
    """Structural key, so a nested container is recognised as a named type."""
    kind = node['kind']
    if kind == 'container':
        return 'container(' + ','.join(key_of(f) for f in node['fields']) + ')'
    if kind == 'vector':
        return f'vector({key_of(node["element"])},{node["count"]})'
    if kind == 'list':
        return f'list({key_of(node["element"])},{node["limit"]})'
    if kind in ('byte_vector', 'bit_vector'):
        return f'{kind}({node["size"]})'
    if kind in ('byte_list', 'bit_list'):
        return f'{kind}({node["limit"]})'
    if kind == 'uint':
        return f'uint({node["size"]})'
    return kind


class Emitter:
    def __init__(self, named):
        self.named = named          # structural key -> contract name
        self.structs = {}           # go type name -> source
        self.pending = []

    def type_name(self, node, fallback):
        return self.named.get(key_of(node), fallback)

    def go_type(self, node, fallback, tags):
        """Go type for a field, appending sszgen tags into `tags`."""
        kind = node['kind']
        if kind == 'boolean':
            return 'bool'
        if kind == 'uint':
            if node['size'] in (1, 4, 8):
                return {1: 'uint8', 4: 'uint32', 8: 'uint64'}[node['size']]
            tags.append(f'ssz-size:"{node["size"]}"')
            return '[]byte'
        if kind == 'byte_vector':
            tags.append(f'ssz-size:"{node["size"]}"')
            return '[]byte'
        if kind == 'bit_vector':
            tags.append(f'ssz-size:"{node["size"]}"')
            return '[]byte'
        if kind == 'byte_list':
            tags.append(f'ssz-max:"{node["limit"]}"')
            return '[]byte'
        if kind == 'bit_list':
            tags.append(f'ssz-max:"{node["limit"]}"')
            return 'bitfield.Bitlist'
        if kind == 'vector':
            element = node['element']
            if element['kind'] in ('byte_vector',):
                tags.append(f'ssz-size:"{node["count"]},{element["size"]}"')
                return '[][]byte'
            if element['kind'] == 'uint' and element['size'] in (1, 4, 8):
                tags.append(f'ssz-size:"{node["count"]}"')
                return '[]' + {1: 'uint8', 4: 'uint32', 8: 'uint64'}[element['size']]
            inner = self.struct_for(element, fallback + 'Item')
            tags.append(f'ssz-size:"{node["count"]}"')
            return '[]*' + inner
        if kind == 'list':
            element = node['element']
            if element['kind'] == 'byte_vector':
                tags.append(f'ssz-max:"{node["limit"]}"')
                tags.append(f'ssz-size:"?,{element["size"]}"')
                return '[][]byte'
            if element['kind'] == 'uint' and element['size'] in (1, 4, 8):
                tags.append(f'ssz-max:"{node["limit"]}"')
                return '[]' + {1: 'uint8', 4: 'uint32', 8: 'uint64'}[element['size']]
            if element['kind'] == 'byte_list':
                tags.append(f'ssz-max:"{node["limit"]},{element["limit"]}"')
                return '[][]byte'
            inner = self.struct_for(element, fallback + 'Item')
            tags.append(f'ssz-max:"{node["limit"]}"')
            return '[]*' + inner
        if kind == 'container':
            return '*' + self.struct_for(node, fallback)
        raise ValueError('unsupported field kind ' + kind)

    def struct_for(self, node, fallback):
        name = self.type_name(node, fallback)
        if name in self.structs:
            return name
        self.structs[name] = ''  # reserve, recursion-safe
        lines = [f'type {name} struct {{']
        for field_name, field in zip(node['names'], node['fields']):
            tags = []
            go_field = camel(field_name)
            go_type = self.go_type(field, name + go_field, tags)
            tag = (' `ssz:"" ' + ' '.join(tags) + '`') if tags else ''
            if tags:
                tag = ' `' + ' '.join(tags) + '`'
            lines.append(f'\t{go_field} {go_type}{tag}')
        lines.append('}')
        self.structs[name] = '\n'.join(lines)
        return name


def main():
    schemas = Schemas()
    contract = json.loads((ROOT / 'benchmarks/performance_contract.json').read_text())
    names = sorted({op.rsplit('.', 1)[0] for op in contract['required_operations']})
    # Which container types the pinned go-eth2-client does not define.
    available = go_candidates()
    missing = [n for n in names
               if schemas.resolve(n)['kind'] == 'container' and n not in available]
    if not missing:
        print('nothing to generate')
        return

    parsed = {name: schemas.resolve(name) for name in names}
    named = {}
    for name, node in parsed.items():
        named.setdefault(key_of(node), name)

    emitter = Emitter(named)
    for name in missing:
        emitter.struct_for(parsed[name], name)

    GEN.mkdir(parents=True, exist_ok=True)
    source = ['// Code generated by tools/generate_missing_go_types.py from',
              '// spec/fulu_schemas.bend; SSZ methods are generated from these by',
              '// pinned fastssz sszgen. DO NOT EDIT.',
              'package gen', '',
              'import "github.com/prysmaticlabs/go-bitfield"', '',
              'var _ = bitfield.Bitlist(nil)', '']
    for name in sorted(emitter.structs):
        source.append(emitter.structs[name])
        source.append('')
    (GEN / 'types.go').write_text('\n'.join(source))

    subprocess.run(['gofmt', '-w', str(GEN / 'types.go')], check=True)
    result = subprocess.run(['go', 'run', 'github.com/ferranbt/fastssz/sszgen', '--path', 'gen'],
                            cwd=ROOT / 'benchmarks/fastssz', text=True, capture_output=True,
                            env={**__import__('os').environ, 'GOFLAGS': '-mod=mod', 'GOPROXY': 'off'})
    print(result.stdout + result.stderr)
    if result.returncode:
        raise SystemExit('sszgen failed')
    print('generated', len(emitter.structs), 'Go types for', len(missing), 'contract types')


if __name__ == '__main__':
    main()
