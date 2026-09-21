#!/usr/bin/env python3
"""Check codegen/fulu.yaml against the frozen Fulu inventory.

schemas/fulu_mainnet.json is the frozen, independently pinned structural
schema of the 109 mainnet Fulu names. Every YAML name must resolve to exactly
the same structure (field names and order, widths, lengths, limits, nesting),
the name sets must be equal, and the YAML must define no other exported name.
A second check runs the resolver on malformed documents and requires each to
be rejected with a SchemaError.

    /opt/homebrew/bin/python3 codegen/check_schema.py
"""
import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import schema  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]


def main():
    frozen = json.load(open(ROOT / 'schemas/fulu_mainnet.json'))
    types = schema.load(ROOT / 'codegen/fulu.yaml')
    bad = []
    if list(types) != list(frozen):
        missing = [n for n in frozen if n not in types]
        extra = [n for n in types if n not in frozen]
        if missing or extra:
            bad.append(f'name sets differ: missing {missing} extra {extra}')
    for n, want in frozen.items():
        if n in types and schema.to_json(types[n]) != want:
            bad.append(f'{n}: structure differs from the frozen schema')
    negatives = {
        'unknown constant': 'constants: {}\ntypes:\n  A:\n    - x: "List[uint8, NOPE]"\n',
        'unknown type': 'constants: {}\ntypes:\n  A:\n    - x: Nope\n',
        'duplicate field': 'constants: {}\ntypes:\n  A:\n    - x: uint8\n    - x: uint8\n',
        'empty container': 'constants: {}\ntypes:\n  A: []\n',
        'zero vector': 'constants: {}\ntypes:\n  A: "Vector[uint8, 0]"\n',
        'bad uint': 'constants: {}\ntypes:\n  A:\n    - x: uint7\n',
        'recursion': 'constants: {}\ntypes:\n  A:\n    - x: A\n',
        'bad section': 'types: {}\n',
        'bad expression': 'constants: {}\ntypes:\n  A: "List[uint8, 3 / 2]"\n',
        'union unsupported': 'constants: {}\ntypes:\n  A: "Union[None, uint8]"\n',
    }
    for label, text in negatives.items():
        with tempfile.NamedTemporaryFile('w', suffix='.yaml', delete=False) as f:
            f.write(text)
        try:
            schema.load(f.name)
            bad.append(f'malformed document accepted: {label}')
        except schema.SchemaError:
            pass
    for b in bad:
        print('FAIL', b)
    print(f'{len(frozen)} frozen names; {len(types)} YAML names; '
          f'{len(negatives)} malformed documents; {"OK" if not bad else "FAILED"}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
