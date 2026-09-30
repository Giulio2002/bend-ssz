#!/usr/bin/env python3
"""Extract a clean, self-contained proof foundation for the compact runtime.

The checked array and U32 foundation developed for the DSA job lives in the
pinned bend-collections snapshot (proofs/lib/{array,u32,u32alg,u32half,...}).
Its modules import word lemmas from an LRU reference development whose module
graph also reaches two template instances (`invariants.representation~0`,
`invariants.identities~0`), which the pinned CLI counts as unsafe annotations.
SSZ requires zero, so the files are not imported as they are.

This tool copies only the definitions that the requested roots actually
depend on - law/def pairs and types, followed transitively through import
aliases and local references - into one flat module, renaming every copied
name with a per-module prefix. Nothing is re-proved or edited by hand: every
copied body is the checked upstream text with references renamed. The output
records the snapshot commit and the sha256 of every source file it read.
Bend re-checks the output; a missing or unsound piece fails that check.

Port to Bend 2.0.34 Base (the snapshot was written for 2.0.28): names Base removed are
rewritten to what they became (BASE_RENAMES: Nat.div.fin/Nat.mod.fin are the Pair
projections), and the blocks listed in PORT are read from tools/compact_foundation_port.bend
(the snapshot's proofs restated for the new Array.get.go/Array.swap.go) instead of the snapshot.

    python3 tools/generate_compact_foundation.py
"""
import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = Path('/Users/monkeair/work/published-snapshots/bend-collections')
SNAPSHOT_COMMIT = 'c18a4bf9d34550baa426fff208fc0d29973b9637'  # files are read at this commit (git show)
OUT = ROOT / 'proofs/compact/found.bend'

# Roots: every definition of these modules, plus the listed single names.
ROOT_MODULES = [
    'spec/common.bend',
    'proofs/lib/logic.bend',
    'proofs/lib/nat.bend',
    'proofs/lib/list.bend',
    'proofs/lib/flat.bend',
    'proofs/lib/array.bend',
    'proofs/lib/u32.bend',
    'proofs/lib/u32alg.bend',
    'proofs/lib/u32half.bend',
]

# (module, block names) read from PORT_FILE instead of the snapshot; PORT_FILE is written with
# that module's import aliases.
PORT_FILE = ROOT / 'tools/compact_foundation_port.bend'
PORT = {'proofs/lib/array.bend': ['get_go', 'swap_go', 'get', 'swap']}
# Base 2.0.34 removed these; each becomes the term it abbreviated (applied form, then bare).
BASE_RENAMES = [
    (re.compile(r'\bNat\.div\.fin\('), 'Pair.fst(Nat, Nat, '),
    (re.compile(r'\bNat\.mod\.fin\('), 'Pair.snd(Nat, Nat, '),
    (re.compile(r'\bNat\.div\.fin\b'), 'qr => Pair.fst(Nat, Nat, qr)'),
    (re.compile(r'\bNat\.mod\.fin\b'), 'qr => Pair.snd(Nat, Nat, qr)'),
]

HEADER = re.compile(r'^(def|law|type)\s+([A-Za-z_][A-Za-z0-9_.~]*)')
IMPORT = re.compile(r'^import\s+(\S+)\s+as\s+([A-Za-z_][A-Za-z0-9_]*)')
IDENT = re.compile(r'(?<![A-Za-z0-9_.~])([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)')


class Module:
    def __init__(self, rel):
        self.rel = rel
        text = subprocess.run(['git', 'show', f'{SNAPSHOT_COMMIT}:{rel}'], cwd=SNAPSHOT, capture_output=True,
                              text=True, check=True).stdout
        self.sha = hashlib.sha256(text.encode()).hexdigest()
        self.aliases = {}
        self.blocks = []          # (kind, name, lines)
        pending = []
        current = None
        for line in text.split('\n'):
            m = IMPORT.match(line)
            if m:
                if m.group(1) != 'Base':
                    target = os.path.normpath(os.path.join(os.path.dirname(rel), m.group(1)))
                    self.aliases[m.group(2)] = target
                continue
            if line.startswith('import '):
                continue
            h = HEADER.match(line)
            if h:
                current = [h.group(1), h.group(2), pending + [line]]
                pending = []
                self.blocks.append(current)
            elif line.startswith('#') and (current is None or not line.startswith('#  ')):
                pending.append(line)
            elif line.strip() == '':
                if current is not None:
                    current[2].append(line)
                else:
                    pending = []
            else:
                if current is None:
                    raise SystemExit(f'{rel}: unexpected top-level line {line!r}')
                current[2].append(line)
        if rel in PORT:
            port = {}
            cur = None
            for line in PORT_FILE.read_text().split('\n'):
                h = HEADER.match(line)
                if h:
                    cur = port.setdefault(h.group(2), [])
                if cur is not None and not line.startswith('#'):
                    cur.append(line)
            for b in self.blocks:
                if b[1] in PORT[rel]:
                    k = next(j for j, l in enumerate(b[2]) if HEADER.match(l))
                    b[2] = b[2][:k] + port.pop(b[1])
            if port or len({b[1] for b in self.blocks} & set(PORT[rel])) != len(PORT[rel]):
                raise SystemExit(f'{rel}: PORT blocks not matched')
            self.port_sha = hashlib.sha256(PORT_FILE.read_bytes()).hexdigest()
        self.names = {name for _, name, _ in self.blocks}
        # constructor names of local types
        self.ctors = {}
        for kind, name, lines in self.blocks:
            if kind == 'type':
                for l in lines[1:]:
                    c = re.match(r'^\s+([A-Za-z_][A-Za-z0-9_]*)\{', l)
                    if c:
                        self.ctors[c.group(1)] = name


MODULES = {}


def module(rel):
    if rel not in MODULES:
        MODULES[rel] = Module(rel)
    return MODULES[rel]


def tag(rel):
    stem = Path(rel).stem
    parent = Path(rel).parent.name
    return {'lib': '', 'spec': 'spec_', 'proofs': 'lru_', 'src': 'lrusrc_',
            'types': 'lrutypes_'}.get(parent, parent + '_') + stem


def new_name(rel, name):
    return f'{tag(rel)}__{name.replace(".", "_").replace("~", "_t")}'


def references(mod, lines):
    """(module, name) pairs a block refers to."""
    out = set()
    body = '\n'.join(l for l in lines if not l.lstrip().startswith('#'))
    for m in IDENT.finditer(body):
        tok = m.group(1)
        parts = tok.split('.')
        if parts[0] in mod.aliases and len(parts) > 1:
            target = module(mod.aliases[parts[0]])
            rest = '.'.join(parts[1:])
            # longest dotted prefix that is a definition there
            for k in range(len(parts) - 1, 0, -1):
                cand = '.'.join(parts[1:1 + k])
                if cand in target.names:
                    out.add((target.rel, cand))
                    break
                if cand in target.ctors:
                    out.add((target.rel, target.ctors[cand]))
                    break
        else:
            for k in range(len(parts), 0, -1):
                cand = '.'.join(parts[:k])
                if cand in mod.names:
                    out.add((mod.rel, cand))
                    break
            if parts[0] in mod.ctors:
                out.add((mod.rel, mod.ctors[parts[0]]))
    return out


def rewrite(mod, lines):
    def sub(m):
        tok = m.group(1)
        parts = tok.split('.')
        if parts[0] in mod.aliases and len(parts) > 1:
            target = module(mod.aliases[parts[0]])
            for k in range(len(parts) - 1, 0, -1):
                cand = '.'.join(parts[1:1 + k])
                if cand in target.names:
                    return new_name(target.rel, cand) + ''.join('.' + p for p in parts[1 + k:])
                if cand in target.ctors:
                    return cand + ''.join('.' + p for p in parts[1 + k:])
            raise SystemExit(f'{mod.rel}: unresolved {tok}')
        for k in range(len(parts), 0, -1):
            cand = '.'.join(parts[:k])
            if cand in mod.names:
                return new_name(mod.rel, cand) + ''.join('.' + p for p in parts[k:])
        return tok
    out = []
    for l in lines:
        if l.lstrip().startswith('#'):
            out.append(l)
        else:
            l = IDENT.sub(sub, l)
            for r, w in BASE_RENAMES:
                l = r.sub(w, l)
            out.append(l)
    return out


def main():
    need = []
    for rel in ROOT_MODULES:
        mod = module(rel)
        need += [(rel, name) for _, name, _ in mod.blocks]
    seen = set()
    order = []
    stack = list(reversed(need))
    while stack:
        key = stack.pop()
        if key in seen:
            continue
        seen.add(key)
        mod = module(key[0])
        for kind, name, lines in mod.blocks:
            if name == key[1]:
                for dep in references(mod, lines):
                    if dep not in seen:
                        stack.append(dep)
        order.append(key)
    # emit in source order within each module, modules in dependency order
    deps = {}
    for rel, mod in MODULES.items():
        deps[rel] = set()
        for kind, name, lines in mod.blocks:
            if (rel, name) in seen:
                deps[rel] |= {d[0] for d in references(mod, lines) if d[0] != rel}
    emitted, mod_order = set(), []

    def visit(rel, trail=()):
        if rel in emitted:
            return
        if rel in trail:
            raise SystemExit('module cycle: ' + ' -> '.join(trail + (rel,)))
        for d in sorted(deps.get(rel, ())):
            visit(d, trail + (rel,))
        emitted.add(rel)
        mod_order.append(rel)
    for rel in sorted(MODULES):
        if any(k[0] == rel for k in seen):
            visit(rel)
    commit = SNAPSHOT_COMMIT
    out = ['import Base', '',
           '# GENERATED by tools/generate_compact_foundation.py - do not edit.',
           f'# Source: {SNAPSHOT} at commit {commit}.',
           '# Each block below is a checked upstream definition, copied with its',
           '# references renamed to this flat module (prefix = source module).',
           '# Source files read (sha256):']
    for rel in mod_order:
        out.append(f'#   {rel} {MODULES[rel].sha}')
    out.append('# Base 2.0.34 port: Nat.div.fin/Nat.mod.fin written as Pair.fst/Pair.snd, and')
    for rel, names in PORT.items():
        out.append(f'#   {rel} blocks {", ".join(names)} from {PORT_FILE.relative_to(ROOT)} {MODULES[rel].port_sha}')
    count = 0
    for rel in mod_order:
        mod = MODULES[rel]
        chosen = [(k, n, ls) for k, n, ls in mod.blocks if (rel, n) in seen]
        if not chosen:
            continue
        out += ['', f'# ==== {rel} ====', '']
        for kind, name, lines in chosen:
            count += 1
            new = rewrite(mod, lines)
            # rename the header itself
            new = [re.sub(r'^(def|law|type)\s+' + re.escape(new_name(rel, name)), lambda m: m.group(0), l) for l in new]
            while new and new[-1].strip() == '':
                new.pop()
            out += new + ['']
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text('\n'.join(out) + '\n')
    print(f'{OUT.relative_to(ROOT)}: {count} blocks from {len(mod_order)} modules')
    for rel in mod_order:
        n = sum(1 for k in seen if k[0] == rel)
        print(f'  {n:4d} {rel}')


if __name__ == '__main__':
    main()
