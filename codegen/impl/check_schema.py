#!/usr/bin/env python3
"""Check codegen/fulu.yaml against the frozen Fulu inventory.

schemas/fulu_mainnet.json is the frozen, independently pinned structural
schema of the 109 mainnet Fulu names. Every YAML name must resolve to exactly
the same structure (field names and order, widths, lengths, limits, nesting),
the name sets must be equal, and the YAML must define no other exported name.
A second check runs the resolver on malformed documents and requires each to
be rejected with a SchemaError.

    python3 codegen/impl/check_schema.py [--check]

It then runs tools/verify_schemas.py, the independent cross-checks of vendor/consensus-specs/
fulu_mainnet.py, schemas/fulu_mainnet.json and spec/fulu_schemas.bend, and of cases.json against
the fixtures and the generic schemas (proofs/obj/generic_specs.bend). It only reads, so --check
(the flag regen_all.py and strictcheck pass) changes nothing; the exit is nonzero if either fails.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[2]))  # the repository root: `codegen` is importable when this file runs as a script
import json
import subprocess
import sys
import tempfile

from codegen.core import schema  # noqa: E402

from codegen.core.paths import ROOT  # noqa: E402


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
    r = subprocess.run([sys.executable, str(ROOT / 'tools/verify_schemas.py')], capture_output=True, text=True)
    print((r.stdout + r.stderr).strip())
    sys.exit(1 if bad or r.returncode else 0)


if __name__ == '__main__':
    sys.argv = [a for a in sys.argv if a != '--check']  # read-only either way
    main()
