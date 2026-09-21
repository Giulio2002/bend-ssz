#!/usr/bin/env python3
"""One-time bootstrap of codegen/fulu.yaml from the pinned consensus pyspec.

codegen/fulu.yaml is the maintained, human-readable generator input. This
script only produced its first version: it reads the class and constant
definitions of vendor/consensus-specs/fulu_mainnet.py (the pinned mainnet Fulu
pyspec) and writes them with symbolic constants, in the pyspec's own notation.
It is kept so the derivation can be reproduced and diffed; the generator never
reads the pyspec. The YAML is checked independently against the frozen
structural inventory schemas/fulu_mainnet.json by codegen/check_schema.py.

    /opt/homebrew/bin/python3 codegen/bootstrap_pyspec.py > codegen/fulu.yaml
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / 'vendor/consensus-specs/fulu_mainnet.py'
NAMES = list(json.load(open(ROOT / 'schemas/fulu_mainnet.json')))
BASE = {'boolean', 'uint8', 'uint16', 'uint32', 'uint64', 'uint128', 'uint256',
        'Bytes1', 'Bytes4', 'Bytes8', 'Bytes20', 'Bytes32', 'Bytes48', 'Bytes96'}


def constants(text):
    out = {}
    for m in re.finditer(r'^([A-Z][A-Z0-9_]*) = (?:[A-Za-z0-9]+\()?([0-9*+\- ()]+?)\)?\s*$', text, re.M):
        name, expr = m.group(1), m.group(2)
        if re.fullmatch(r'[0-9*+\- ()]+', expr):
            try:
                out[name] = int(eval(expr, {'__builtins__': {}}))
            except Exception:
                pass
    for m in re.finditer(r'^([A-Z][A-Z0-9_]*) = GeneralizedIndex\((\d+)\)', text, re.M):
        out[m.group(1)] = int(m.group(2))
    return out


def classes(text):
    out = {}
    pat = re.compile(r'^class (\w+)\((.*?)\):\n((?:    .*\n|\n)*)', re.M | re.S)
    for m in re.finditer(r'^class (\w+)\(', text, re.M):
        start = m.end()
        depth, i = 1, start
        while depth:
            if text[i] == '(':
                depth += 1
            elif text[i] == ')':
                depth -= 1
            i += 1
        base = ' '.join(text[start:i - 1].split()).replace('  # type: ignore', '')
        base = re.sub(r'#.*', '', base).strip()
        body = []
        for line in text[i:].split('\n')[1:]:
            if line.strip() == '' or line.startswith('    '):
                body.append(line)
            else:
                break
        out[m.group(1)] = (base, body)
    return out


def main():
    text = SPEC.read_text()
    consts = constants(text)
    cls = classes(text)
    types = {}
    used = set()

    def note(expr):
        for tok in re.findall(r'[A-Z][A-Z0-9_]{2,}', expr):
            if tok in consts:
                used.add(tok)

    def visit(name):
        if name in types or name in BASE:
            return
        base, body = cls[name]
        if base == 'Container':
            fields = []
            for line in body:
                s = line.split('#')[0].strip()
                mm = re.fullmatch(r'(\w+): (.+)', s)
                if mm:
                    fields.append((mm.group(1), mm.group(2)))
            types[name] = ('container', fields)
            for _, t in fields:
                note(t)
                for ref in re.findall(r'\b[A-Z]\w*\b', t):
                    if ref in cls and ref not in consts:
                        visit(ref)
        else:
            base = re.sub(r'floorlog2\((\w+)\)', r'floorlog2(\1)', base)
            types[name] = ('alias', base)
            note(base)
            for ref in re.findall(r'\b[A-Z]\w*\b', base):
                if ref in cls and ref not in consts:
                    visit(ref)

    for n in NAMES:
        visit(n)
    print('# Mainnet Fulu SSZ schema: generator input for codegen/generate.py.')
    print('# Notation follows the consensus specs. Derived from the pinned pyspec')
    print('# vendor/consensus-specs/fulu_mainnet.py by codegen/bootstrap_pyspec.py and')
    print('# checked against the frozen schemas/fulu_mainnet.json by codegen/check_schema.py.')
    print('# Type expressions: boolean, uintN, BytesN, ByteVector[N], ByteList[N],')
    print('# Bitvector[N], Bitlist[N], Vector[T, N], List[T, N], or a type name; N is')
    print('# an integer, a constant, or +, -, *, exact //, parentheses and floorlog2(...).')
    print('constants:')
    for c in sorted(used):
        print(f'  {c}: {consts[c]}')
    print('types:')
    for n in NAMES:
        if n in BASE:
            print(f'  {n}: {n}')
    for n in NAMES:
        if n in BASE:
            continue
        kind, v = types[n]
        if kind == 'alias':
            print(f'  {n}: "{v}"')
        else:
            print(f'  {n}:')
            for f, t in v:
                print(f'    - {f}: "{t}"')
    extra = [n for n in types if n not in NAMES]
    if extra:
        print('# non-exported helper types: ' + ', '.join(extra), file=sys.stderr)


if __name__ == '__main__':
    main()
