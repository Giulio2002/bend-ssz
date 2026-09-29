#!/usr/bin/env python3
"""Light definition modules: keep the root laws' heavy imports out of modules that only state against
their definitions.

Bend re-checks every imported module on every run (no module cache), and the root-law modules
(proofs/obj/root_names.bend, packed_bytes.bend, words_obj.bend, ...) reach zero_roots.bend (the 63
zero-subtree SHA-256 evaluations, ~6 s) and ~300 further modules. Most encode/decode e2e files use
those modules only for their *definitions* (the object's view `v_<p>`, representation invariants
`rep_*`, ...): measured on vec_uint8_8_e2e_generated, taking them from a light module halves the check
(50.3 s -> 26.6 s, 552 -> 221 modules).

Two passes.

split(text, seeds, light_rel, gen): a heavy module's generator passes its text and the names of the
definitions to move (seeds: a set or a predicate on names). The seeds and every top-level definition
they reference (transitively, laws included) move to the light module `<X>_light.bend` beside it, with
exactly the imports they use; the heavy module imports it (as `LV`, or LV<n> if taken) and qualifies its
references. gen=None (a hand-written module) writes no GENERATED header; the caller then maintains
both files by hand. Returns (heavy_text, light_text). The symbols are therefore
the light module's everywhere: statements stay syntactically identical between heavy and light
importers.

light(text): every module (runtime_refs.rewire runs it, so each generator that rewires inherits it;
hand-written modules are passed once with --fix): an import of a module X that has a light companion
X_light is pointed at the companion when every symbol used through it is the companion's; when only
some are, the companion is imported beside it (alias A_L) and those references say A_L. An import
whose alias is never used is dropped when its module reaches zero_roots (only those: dropping cheap
imports would churn files for nothing). Idempotent.

    python3 codegen/light_split.py --fix [<file.bend>...]    apply light() to hand-written modules (default: all of them)
    python3 codegen/light_split.py --check [<file.bend>...]  fail when light() would change one
"""
import functools
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SUFFIX = '_light'
HEAVY_MARK = 'proofs/obj/zero_roots.bend'
IMP = re.compile(r'^import (\S+?)([A-Za-z0-9_]+)\.bend as (\w+)[ \t]*$', re.M)
TOP = re.compile(r'^(def|law|type) ([A-Za-z_][A-Za-z0-9_]*)')
IDENT = re.compile(r'(?<![\w.])([A-Za-z_][A-Za-z0-9_]*)\b(?!\.)')

# light modules produced in this process (basename -> def names), preferred over the disk copy
_MEM = {}
_MEMT = {}
_DISK = {}
_BYNAME = None
_CLOS = {}


_TOK = re.compile(r'#.*|"[^"]*(?:"|\Z)', re.S)


def _code_sub(pat, q, line):
    """pat.sub(q, ..) on a line's code, not its comment or strings."""
    if '#' not in line and '"' not in line:
        return pat.sub(q, line)
    out, i = [], 0
    for m in _TOK.finditer(line):
        if m.start() > i:
            out.append(pat.sub(q, line[i:m.start()]))
        out.append(m.group(0))
        i = m.end()
    if i < len(line):
        out.append(pat.sub(q, line[i:]))
    return ''.join(out)


def _code(text):
    """text without comments and strings (for reference scans)."""
    return '\n'.join(l.split('#')[0] for l in text.split('\n'))


def blocks(text):
    """(head lines, [block]) with block = (name or None, kind, lines). A block is a top-level def / law /
    type with the comment lines directly above it; the head is everything before the first block."""
    lines = text.split('\n')
    starts = []
    for i, l in enumerate(lines):
        if TOP.match(l):
            j = i
            while j > 0 and lines[j - 1].startswith('#'):
                j -= 1
            starts.append((j, i))
    if not starts:
        return lines, []
    head = lines[:starts[0][0]]
    out = []
    for k, (j, i) in enumerate(starts):
        end = starts[k + 1][0] if k + 1 < len(starts) else len(lines)
        m = TOP.match(lines[i])
        out.append((m.group(2), m.group(1), lines[j:end]))
    return head, out


def _ctors(bl):
    """the constructor names of the type blocks among bl (a moved type takes its constructors along)"""
    return {m.group(1) for b in bl if b[1] == 'type' for l in b[2][1:] if (m := re.match(r'\s+([A-Za-z_]\w*)\{', l))}


def _refs(lines, names):
    code = _code('\n'.join(lines))
    return {m.group(1) for m in IDENT.finditer(code)} & names


def _aliases_used(lines):
    code = _code('\n'.join(lines))
    return {m.group(1) for m in re.finditer(r'(?<![\w.])([A-Za-z_]\w*)\.[A-Za-z_]', code)}


def split(text, seeds, light_rel, gen, alias=None):
    """(heavy, light) texts: the seeds and the definitions they reach, moved to light_rel (a path
    relative to the heavy module, e.g. './root_names_light.bend')."""
    head, bl = blocks(text)
    names = {b[0] for b in bl}
    laws = {b[0] for b in bl if b[1] == 'law'}
    by = {}
    for b in bl:
        by.setdefault(b[0], []).append(b)
    todo = [n for n in names if (seeds(n) if callable(seeds) else n in seeds)]
    moved = set()
    while todo:
        n = todo.pop()
        if n in moved:
            continue
        moved.add(n)
        for b in by[n]:
            todo.extend(_refs(b[2], names) - moved)
    if not moved:
        return text, None
    imports = [l for l in head if l.startswith('import ')]
    mv_lines = [l for b in bl if b[0] in moved for l in b[2]]
    used = _aliases_used(mv_lines)
    limp = ['import Base'] + [l for l in imports if (m := IMP.match(l)) and m.group(3) in used]
    base = Path(light_rel).name[:-len('.bend')]
    light_text = '\n'.join(limp + [''] + ([f'# GENERATED by {gen}. Do not edit.'] if gen else []) + [
                                    f'# The definitions of {base[:-len(SUFFIX)]}.bend that state no root law (its'
                                    f' light companion, codegen/light_split.py): importers that only',
                                    '# state against them skip the root laws\' imports.', ''] + mv_lines).rstrip('\n') + '\n'
    ctors = _ctors([b for b in bl if b[0] in moved]) - names
    _MEM[base] = set(moved) | ctors
    _MEMT[base] = light_text
    unlight.cache_clear()
    taken = {m.group(3) for m in IMP.finditer(text)}
    if alias is None:
        alias, k = 'LV', 1
        while alias in taken:
            k += 1
            alias = f'LV{k}'
    pat = re.compile(r'(?<![\w.])(' + '|'.join(sorted(moved | ctors, key=len, reverse=True)) + r')\b(?!\.)')
    keep = [b for b in bl if b[0] not in moved]
    body = []
    for b in keep:
        for l in b[2]:
            body.append(_code_sub(pat, lambda m: f'{alias}.{m.group(1)}', l))
    last = max((i for i, l in enumerate(head) if l.startswith('import ')), default=-1)
    head = head[:last + 1] + [f'import {light_rel} as {alias}'] + head[last + 1:]
    heavy_text = '\n'.join(head + body)
    return heavy_text, light_text


def _byname():
    global _BYNAME
    if _BYNAME is None:
        _BYNAME = {}
        for p in ROOT.glob('**/*' + SUFFIX + '.bend'):
            if 'node_modules' in p.parts:
                continue
            _BYNAME.setdefault(p.name[:-len('.bend')], []).append(p)
    return _BYNAME


def light_defs(base):
    """The definition names of the light companion `base` (e.g. 'root_names_light'), or None."""
    if base in _MEM:
        return _MEM[base]
    if base not in _DISK:
        ps = _byname().get(base, [])
        _DISK[base] = None if len(ps) != 1 else (lambda bl: {b[0] for b in bl} | _ctors(bl))(blocks(ps[0].read_text())[1])
    return _DISK[base]


def _resolve(prefix, stem):
    """The repository file an import names, by basename (import prefixes are relative; basenames of
    the modules involved here are unique)."""
    hits = _files_by_stem().get(stem, [])
    if len(hits) == 1:
        return hits[0]
    for h in hits:
        if str(h).endswith(prefix.lstrip('./').replace('../', '') + stem + '.bend'):
            return h
    return None


_STEMS = None


def _files_by_stem():
    global _STEMS
    if _STEMS is None:
        _STEMS = {}
        for p in ROOT.glob('**/*.bend'):
            if 'node_modules' in p.parts or '.git' in p.parts:
                continue
            _STEMS.setdefault(p.name[:-len('.bend')], []).append(p)
    return _STEMS


@functools.lru_cache(maxsize=None)
def _imports_of(x):
    """the resolved .bend import paths of module x (not 0x.. ones)"""
    return tuple((x.parent / m.group(1)).resolve() for m in re.finditer(r'^import (\S+\.bend)', x.read_text(), re.M)
                 if not m.group(1).startswith('0x'))


def _heavy(path):
    """Whether a module reaches zero_roots.bend through its imports."""
    if path is None:
        return False
    path = Path(path).resolve()
    if path in _CLOS:
        return _CLOS[path]
    _CLOS[path] = False
    seen, st, hit = set(), [path], False
    while st and not hit:
        x = st.pop()
        if x in seen or not x.exists():
            continue
        seen.add(x)
        if str(x).endswith(HEAVY_MARK):
            hit = True
            break
        st.extend(_imports_of(x))
    _CLOS[path] = hit
    return hit


_QUAL = re.compile(r'(?<![\w.])(\w+)\.([A-Za-z_]\w*)')


def light(text):
    """text with its imports pointed at light companions where they suffice, and its unused heavy
    imports dropped."""
    imps = list(IMP.finditer(text))
    if not imps:
        return text
    lines = text.split('\n')
    impset = {m.group(0) for m in imps}
    body = [l for l in lines if l not in impset]
    code = _code('\n'.join(body))
    replace, add, subs, drop = {}, {}, [], set()
    taken = {m.group(3) for m in imps}
    uses = {}
    for x in _QUAL.finditer(code):
        uses.setdefault(x.group(1), set()).add(x.group(2))
    for m in imps:
        pre, stem, a = m.group(1), m.group(2), m.group(3)
        used = uses.get(a, set())
        if not used:
            if not stem.endswith(SUFFIX) and _heavy(_resolve(pre, stem)):
                drop.add(m.group(0))
            continue
        if stem.endswith(SUFFIX):
            continue
        ld = light_defs(stem + SUFFIX)
        if not ld:
            continue
        mine = used & ld
        if not mine:
            continue
        lpath = f'import {pre}{stem}{SUFFIX}.bend'
        if mine == used:
            replace[m.group(0)] = f'{lpath} as {a}'
        else:
            la = a + '_L'
            while la in taken:
                la += '_'
            taken.add(la)
            add[m.group(0)] = f'{lpath} as {la}'
            subs.append((a, la, mine))
    if not (replace or add or drop or subs):
        return text
    out = []
    for l in lines:
        if l in drop:
            continue
        if l in replace:
            out.append(replace[l])
            continue
        if l in add:
            out.append(l)
            out.append(add[l])
            continue
        out.append(l)
    for a, la, mine in subs:
        pat = re.compile(rf'(?<![\w.]){a}\.(' + '|'.join(sorted(mine, key=len, reverse=True)) + r')\b')
        out = [l if l.startswith('import ') else _code_sub(pat, lambda x: f'{la}.{x.group(1)}', l) for l in out]
    # an import the rewrite made a duplicate of (same path and alias) is kept once
    seen, res = set(), []
    for l in out:
        if l.startswith('import ') and l in seen:
            continue
        if l.startswith('import '):
            seen.add(l)
        res.append(l)
    return '\n'.join(res)


@functools.lru_cache(maxsize=1024)
def unlight(text):
    """The inverse view, for generators that parse a module (runtime_refs.unwire runs it): the module as
    it read before any light split. A heavy module's own companion (imported as LV / LV<n>) is inlined
    back as local names (its definitions appended); an importer's companion (X_light as A) reads as X as A; a beside-import
    (X_light as A_L next to X as A) reads as A. Only for reading: never write its result."""
    imps = list(re.finditer(r'^import (\S+?)([A-Za-z0-9_]+)' + SUFFIX + r'\.bend as (\w+)[ \t]*$', text, re.M))
    if not imps:
        return text
    heavy = {m.group(2): m.group(3) for m in IMP.finditer(text) if not m.group(2).endswith(SUFFIX)}
    lines = text.split('\n')
    subs = []
    drop = set()
    ren = {}
    append = []
    for m in imps:
        pre, stem, a = m.group(1), m.group(2), m.group(3)
        if re.fullmatch(r'LV\d*', a):
            drop.add(m.group(0))
            subs.append((a, ''))
            ct = _MEMT.get(stem + SUFFIX)
            if ct is None:
                ps = _byname().get(stem + SUFFIX, [])
                ct = ps[0].read_text() if len(ps) == 1 else ''
            append.extend(l for b in blocks(ct)[1] for l in b[2])
        elif stem in heavy:
            drop.add(m.group(0))
            subs.append((a, heavy[stem] + '.'))
        else:
            ren[m.group(0)] = f'import {pre}{stem}.bend as {a}'
    out = []
    for l in lines:
        if l in drop:
            continue
        out.append(ren.get(l, l))
    if append:
        out = out + [''] + append
    for a, to in subs:
        pat = re.compile(rf'(?<![\w.]){a}\.([A-Za-z_]\w*)')
        ad = a + '.'
        out = [l if l.startswith('import ') or ad not in l else _code_sub(pat, lambda x: to + x.group(1), l) for l in out]
    return '\n'.join(out)


def hand_written():
    """The repository's hand-written Bend modules (no GENERATED header) under proofs/ and e2e/."""
    out = []
    for d in ('proofs', 'e2e'):
        for p in sorted((ROOT / d).glob('**/*.bend')):
            if 'GENERATED by' not in p.read_text():
                out.append(p)
    return out


def main():
    args = [a for a in sys.argv[1:] if a != '--no-big']
    mode = args[0] if args else ''
    if mode not in ('--fix', '--check'):
        sys.exit(__doc__)
    files = [Path(a) for a in args[1:]] or hand_written()
    bad = []
    for f in files:
        t = f.read_text()
        n = light(t)
        if n != t:
            if mode == '--fix':
                f.write_text(n)
                print(f)
            else:
                bad.append(str(f))
    if bad:
        sys.exit('light_split: stale light routing (run --fix): ' + ' '.join(bad[:10]))
    if mode == '--check':
        print('light routing of hand-written modules is current')


if __name__ == '__main__':
    main()
