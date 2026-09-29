#!/usr/bin/env python3
"""The runtime split (docs/RUNTIME_SPLIT.md): the typed object runtime codegen/generate.py computes as two
monoliths (Fulu's and the generic forms'; neither is written), cut per readable name and operation into

    types/<Name>_def_generated.bend            the name's types, default, field access, update, force, dump, fuzz
    types/<Name>_encode_ssz_generated.bend     what its encoder, serializer, writers, size and validity pass reach
    types/<Name>_decode_ssz_generated.bend     what its decoder, validator, reader and builder reach
    types/<Name>_hashtreeroot_generated.bend   what its hash_tree_root / root reach

(Bend imports only plain path segments; the spelling is split_rel's).

and their index types/runtime_index.json (every symbol's file; each monolith's imports and definitions in
order). Called by codegen/generate.py (so its --check covers them); `python3 codegen/runtime_refs.py --check`
runs the split's own check alone.

Consumers. A generator writes its modules as before, against the runtime as one module
(`import <p>types/fulu_obj.bend as T` / generic_obj.bend, and T.<sym>), and passes each module through
rewire (rewire_out) before its --check comparison and its write: the monolith import becomes the imports
of exactly the split files the module uses, T.<sym> their alias's. A generator that parses another
generated module reads it through unwire (its split qualifiers as T. again); one that reads the runtime's
definitions reads mono_text. Hand-written modules are rewired once, by the same function.

Shared basic types. The generic runtime's definitions that Fulu's has with the same text (boolean /
uintN helpers, Bitvector4, ...) are Fulu's; its own definitions of those owners go in the same files.

Owners. Every top-level definition of a monolith has an owner: the longest runtime prefix it
extends (a shape's p, an API name, a word record's name), a boxed shape's (X_bx) being its container's.
An owner's readable name is codegen/names.py's for an API name (FuluBeaconBlock, ComplexTestStruct,
uint8, ...); a shape that is some API name's representation takes the first such name's (b32 is
FuluBytes32's); a shape no name has takes a structural name (Fulu_list_Withdrawal_16,
Fulu_bitlist_131072, list_uint16_1024, ...). Owners with one readable name share its files.

Operations. Within an owner, a definition belongs to the operation whose entry points (decode: _decode,
_ok, _read, _build; encode: _encode, _serialize, _putk, _putn, _put, _putv, _size, _valid;
hashtreeroot: _hash_tree_root, _root) are the only ones reaching it through the owner's own calls;
a definition reached by none, or by two, or by a definition of the def file, is the def file's. So a
def file calls only def files, an operation's file its own owner's def file and other owners' files,
and the files' imports are acyclic (the monolith's order is a dependency order).

References. A reference to another file's definition (a function, a type, a constructor) is
qualified by that file's alias (<Name>_<op letter>: d def, e encode_ssz, r decode_ssz, h hashtreeroot);
a file imports exactly the files it references, in the monolith's order.

The check (split_check): the split files' definitions, with those qualifiers removed, are exactly the
monolith's (every definition in one file, text for text), and the import graph is acyclic.
"""
import functools
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
OUT = ROOT / 'types'

OPS = ['def', 'encode_ssz', 'decode_ssz', 'hashtreeroot']


def split_rel(name, op):
    """A split file's path under types/ (the one place its spelling is decided)."""
    return f'{name}_{op}_generated.bend'


SPLIT_GLOB = '*_generated.bend'
# the import prefix from one split file to another, and to the repository's root
TO_SPLIT = './'
TO_ROOT = '../'
LETTER = {'def': 'd', 'encode_ssz': 'e', 'decode_ssz': 'r', 'hashtreeroot': 'h'}
ROOTS = {
    'decode_ssz': ['decode', 'ok', 'read', 'build'],
    'encode_ssz': ['encode', 'serialize', 'putk', 'putn', 'put', 'putv', 'size', 'valid'],
    'hashtreeroot': ['hash_tree_root', 'root'],
}
IDENT = re.compile(r'(?<![\w.])([A-Za-z_][A-Za-z0-9_]*)\b(?!\.)')


def blocks(text):
    """(header import lines, [(name, kind, text)]) of a monolith: its type / def blocks (comments dropped)."""
    parts = re.split(r'\n(?=def |type |# ---- )', text)
    head = [l for l in parts[0].split('\n') if l.startswith('import ')]
    out = []
    for b in parts[1:]:
        m = re.match(r'(def|type) ([A-Za-z0-9_]+)', b)
        if not m:
            continue
        out.append((m.group(2), m.group(1), b.rstrip('\n')))
    return head, out


def ctors(btext):
    """The constructors a type block declares."""
    return [m.group(1) for m in re.finditer(r'^  ([A-Za-z_]\w*)\{', btext, re.M)]


def shape_struct(t, readable, fork):
    """A structural name for a shape no API name has (a fork's own spelled with its prefix)."""
    import names as NM
    k = t.kind

    def el(e):
        if e.kind in ('container', 'pcontainer', 'cunion') or getattr(e, 'name', None):
            nm = e.name
            r = readable.get(nm, nm)
            return r[len(fork):] if fork and r.startswith(fork) else r
        return inner(e)

    def inner(e):
        k = e.kind
        if k == 'bool':
            return 'bool'
        if k == 'uint':
            return f'uint{8 * e.size}'
        if k == 'bytes':
            return f'bytevec_{e.size}'
        if k == 'bytelist':
            return f'bytelist_{e.size}'
        if k == 'bits':
            return f'bitvector_{e.size}'
        if k == 'bitlist':
            return f'bitlist_{e.size}'
        if k == 'pbits':
            return 'progbitlist'
        if k == 'vector':
            return f'vec_{el(e.elem)}_{e.size}'
        if k == 'list':
            return f'list_{el(e.elem)}_{e.size}'
        if k == 'plist':
            return f'proglist_{el(e.elem)}'
        raise SystemExit(f'runtime_refs: no structural name for {k}')
    s = inner(t) if not (t.kind in ('container', 'pcontainer', 'cunion')) else el(t)
    return f'{fork}_{s}' if fork else s


def owners_of(g, names, readable, fork):
    """({prefix: readable file name}, [prefixes, longest first], {word record: prefix})."""
    shape_ty = {}

    def walk(t):
        s = g.shape(t)
        shape_ty.setdefault(s.p, t)
        if getattr(t, 'elem', None) is not None:
            walk(t.elem)
        for _, ft in (getattr(t, 'fields', None) or ()):
            walk(ft)
    for n, t in names.items():
        walk(t)
    file_of = {}
    for n, t in names.items():
        file_of[n] = readable[n]
    for n, t in names.items():
        p = g.shape(t).p
        file_of.setdefault(p, readable[n])
    for s in g.order:
        if s.p in file_of:
            continue
        if s.p.endswith('_bx') and s.p[:-3] in file_of:
            file_of[s.p] = file_of[s.p[:-3]]
            continue
        t = shape_ty.get(s.p)
        if t is None:
            raise SystemExit(f'runtime_refs: no type for shape {s.p}')
        file_of[s.p] = shape_struct(t, readable, fork)
    recs = {}
    for s in g.order:
        rep = getattr(s, 'rep', '')
        if isinstance(rep, str) and re.fullmatch(r'[A-Za-z_]\w*', rep) and rep not in file_of:
            recs[rep] = s.p
    for r, p in recs.items():
        file_of[r] = file_of[p]
    cands = sorted(file_of, key=len, reverse=True)
    return file_of, cands


def assign(text, g, names, readable, fork, prior=None):
    """(head, blocks, fk, files) of one monolith: every definition's file key (readable name, operation) and
    the files' definitions in the monolith's order. prior: an earlier runtime's (fk, {name: block}); a
    definition it has with the same text (the fork-independent basic types' helpers, boolean / uintN)
    is that runtime's, not copied; this runtime's own definitions of those owners share their files."""
    head, bl = blocks(text)
    pfk, pblk = prior if prior else ({}, {})
    shared = {nm for nm, _, b in bl if pblk.get(nm) == b}
    file_of, cands = owners_of(g, names, readable, fork)
    top = {}
    owner = {}
    for nm, kind, b in bl:
        if nm in shared:
            continue
        o = None
        for c in cands:
            if nm == c or nm.startswith(c + '_'):
                o = c
                break
        if o is None:
            raise SystemExit(f'runtime_refs: {nm} has no owner')
        owner[nm] = o
        top[nm] = (kind, b)
    # the calls within an owner
    calls = {}
    for nm, (kind, b) in top.items():
        calls[nm] = {x for x in IDENT.findall(b) if x in top and x != nm}
    # operations by reachability from the entry points, within a file (its owners together)
    fown = {nm: file_of[owner[nm]] for nm in top}

    def reach(roots):
        seen, st = set(), list(roots)
        while st:
            x = st.pop()
            if x in seen:
                continue
            seen.add(x)
            st.extend(y for y in calls[x] if fown[y] == fown[x])
        return seen
    by_file = {}
    for nm in top:
        by_file.setdefault(fown[nm], []).append(nm)
    op = {}
    for f, members in by_file.items():
        os_ = {owner[x] for x in members}
        R = {}
        for opn, sufs in ROOTS.items():
            roots = [f'{o}_{s_}' for o in os_ for s_ in sufs if f'{o}_{s_}' in top and fown[f'{o}_{s_}'] == f]
            for x in reach(roots):
                R.setdefault(x, set()).add(opn)
        # the def roots: what no operation reaches; what they reach is shared (def)
        droots = [x for x in members if x not in R]
        for x in reach(droots):
            R.setdefault(x, set()).add('def')
        for x in members:
            rs = R.get(x, {'def'})
            op[x] = next(iter(rs)) if len(rs) == 1 else 'def'
            if top[x][0] == 'type':
                op[x] = 'def'
    # the constructors, by their type's file
    ctor_of = {}
    for nm, (kind, b) in top.items():
        if kind == 'type':
            for c in ctors(b):
                ctor_of[c] = nm
    fk = {nm: (file_of[owner[nm]], op[nm]) for nm in top}
    for c, tn in ctor_of.items():
        fk.setdefault(c, fk[tn])
    for nm, kind, b in bl:
        if nm in shared:
            fk[nm] = pfk[nm]
            for c in (ctors(b) if kind == 'type' else ()):
                fk[c] = pfk[c]
    files = {}
    for nm, kind, b in bl:
        if nm not in shared:
            files.setdefault(fk[nm], []).append((nm, b))
    return head, bl, fk, files


def alias(key):
    """A split file's import alias: its readable name and its operation's letter (the one place it is spelled)."""
    f, o = key
    return re.sub(r'\W', '_', f) + '_' + LETTER[o]


def render(runtimes):
    """{path: text} and the import graph of the split files of all runtimes together.
    runtimes: [(head, fk, files, fork)]; a file key two runtimes share holds the first's definitions, then
    the next's. A reference is qualified by its own runtime's fk."""
    order, keyed = [], {}
    for head, fk, files, fork in runtimes:
        for key, defs in files.items():
            if key not in keyed:
                keyed[key] = []
                order.append(key)
            keyed[key].append((head, fk, defs, fork))
    pos = {k: i for i, k in enumerate(order)}
    out, deps = {}, {}
    for key in order:
        f, o = key
        used, body, heads, monos = [], [], [], []
        for head, fk, defs, fork in keyed[key]:
            for l in head:
                if l not in heads:
                    heads.append(l)
            monos.append(RTNAME[fork])
            for nm, b in defs:
                def q(m):
                    x = m.group(1)
                    if x in fk and fk[x] != key and not _is_local(x, b):
                        if fk[x] not in used:
                            used.append(fk[x])
                        return f'{alias(fk[x])}.{x}'
                    return x
                body.append(IDENT.sub(q, b))
        deps[key] = used
        imps = [l.replace('import ../', 'import ' + TO_ROOT, 1) for l in heads]
        for k in sorted(used, key=lambda k: pos[k]):
            imps.append(f'import {TO_SPLIT}{split_rel(k[0], k[1])} as {alias(k)}')
        src = ' and '.join(monos)
        text_ = '\n'.join(imps) + '\n\n# GENERATED by codegen/generate.py (codegen/runtime_refs.py): the typed object runtime ' \
            f'({src}), split per name and operation.\n# {f}: {DOC[o]}\n\n' + '\n\n'.join(body) + '\n'
        out[OUT / split_rel(f, o)] = text_
    return out, deps, order


RTNAME = {'Fulu': 'Fulu', '': 'generic'}
RUNTIME = {'Fulu': 'fulu', '': 'generic'}
DOC = {'def': 'its types, default, field access, update, force, dump and fuzz helpers',
       'encode_ssz': 'its encoder, serializer, writers, size and validity pass',
       'decode_ssz': 'its decoder, validator, reader and builder',
       'hashtreeroot': 'its hash_tree_root'}


def _is_local(x, b):
    """Top-level names are never shadowed by locals in the generated runtime (its locals are lowercase
    field / pair names, its top-level names prefixed); the server check of the split files is the guard."""
    return False


def strip_q(b):
    """A split file's definition with its file qualifiers removed (the monolith's text)."""
    return re.sub(r'(?<![\w.])[A-Za-z_]\w*_[derh]\.(?=[A-Za-z_])', '', b)


def split_check(mono_text, out_files, fk, files):
    """The split files hold every definition of the monolith, text for text (qualifiers removed): its own
    in its files, the ones it shares with an earlier runtime in that runtime's files."""
    _, bl = blocks(mono_text)
    want = {nm: b for nm, _, b in bl}
    got = {}
    for p, t in out_files.items():
        for nm, _, b in blocks(t)[1]:
            if nm in got:
                raise SystemExit(f'runtime split: {nm} defined twice')
            got[nm] = (p, strip_q(b))
    miss = [nm for nm in want if nm not in got]
    if miss:
        raise SystemExit(f'runtime split: definitions missing: {miss[:10]}')
    bad = [nm for nm in want if got[nm][1] != want[nm] or got[nm][0] != OUT / split_rel(*fk[nm])]
    if bad:
        raise SystemExit(f'runtime split: {len(bad)} definitions changed or misplaced, e.g. {bad[:5]}')
    return len(want)


def acyclic(deps):
    state = {}

    def visit(k):
        if state.get(k) == 2:
            return
        if state.get(k) == 1:
            raise SystemExit(f'runtime split: an import cycle through {k}')
        state[k] = 1
        for d in deps.get(k, []):
            visit(d)
        state[k] = 2
    for k in deps:
        visit(k)


INDEX = OUT / 'runtime_index.json'


def outputs(ctx=None):
    """{path: text} of the split files of both monoliths and their index (INDEX). ctx: [(monolith text, Gen,
    names, fork prefix)] as codegen/generate.py computed them (standalone: recomputed through generate.py)."""
    import json
    import names as NM
    if ctx is None:
        import generate as G
        ctx = G.split_contexts()
    readable = NM.mapping()
    rts, prior, monos = [], ({}, {}), []
    for text, g, names, fork in ctx:
        head, bl, fk, files = assign(text, g, names, readable, fork, prior)
        rts.append((head, fk, files, fork))
        monos.append((text, fk, files, fork, head, bl))
        pfk, pblk = prior
        prior = ({**pfk, **fk}, {**pblk, **{nm: b for nm, _, b in bl}})
    out, deps, order = render(rts)
    acyclic(deps)
    for text, fk, files, fork, head, bl in monos:
        split_check(text, out, fk, files)
    # the index: every symbol's file (both runtimes; a shared one is the first runtime's), each monolith's
    # imports and definitions in order (mono_text rebuilds it from the split files)
    allfk = prior[0]
    pos = {k: i for i, k in enumerate(order)}
    idx = {'files': [list(k) for k in order],
           'symbols': {s: pos[k] for s, k in sorted(allfk.items())},
           'monoliths': {RUNTIME[fork]: {'head': head, 'defs': [nm for nm, _, _ in bl]}
                         for text, fk, files, fork, head, bl in monos}}
    out[INDEX] = json.dumps(idx, indent=0, sort_keys=True) + '\n'
    # no split file may take a path of types/ that is not a split file (the monoliths, the index files,
    # the hand-written types); split files are exactly the SPLIT_GLOB names
    import fnmatch
    others = [q for q in OUT.iterdir() if q.is_file() and not fnmatch.fnmatch(q.name, SPLIT_GLOB)]
    hit = sorted(q.name for q in others if q in out and q != INDEX)
    stray = sorted(str(p.relative_to(ROOT)) for p in out if p != INDEX and (not fnmatch.fnmatch(p.name, SPLIT_GLOB) or p.parent != OUT))
    if hit or stray:
        raise SystemExit(f'runtime split: a name collision in types/: {hit[:6]} {stray[:6]}')
    return out


# ==== the consumers: rewire a module's monolith imports to the split files it uses ====

_IX = None


def index():
    """The split's index (INDEX): (files [(name, op)], {symbol: file number}, monoliths)."""
    global _IX
    if _IX is None:
        import json
        d = json.loads(INDEX.read_text())
        _IX = ([tuple(k) for k in d['files']], d['symbols'], d['monoliths'])
    return _IX


MONO_IMP = re.compile(r'^import (\S*?)(fulu_obj|generic_obj)\.bend as (\w+)[ \t]*$', re.M)
SPLIT_IMP = re.compile(r'^import (\S*?)([A-Za-z0-9_]+)_(def|encode_ssz|decode_ssz|hashtreeroot)_generated\.bend as (\w+)[ \t]*$', re.M)
# the monolith aliases a generator may use without importing them (a text built around import lines
# copied from an already rewired module)
BARE = ('T', 'TG')


def rewire(text, missing=None):
    """_rewire, then codegen/light_split.py's light(): imports pointed at light definition companions,
    unused heavy imports dropped."""
    import light_split as LS
    return LS.light(_rewire(text, missing))


def _rewire(text, missing=None):
    """text with its monolith imports (import <p>fulu_obj.bend / generic_obj.bend as A) replaced by the
    imports of exactly the split files it uses (import <p><Name>_<op>_generated.bend as <alias>), every
    A.<sym> by <alias>.<sym>. Idempotent: split imports already present are recomputed the same way, and
    a bare T. / TG. (a module built around copied, already rewired imports) resolves too. A text importing
    neither is returned unchanged. A symbol the runtime does not define is an error, unless missing='owner'
    (a program that must fail to compile for naming it): it is then qualified by the file of its longest
    defined prefix (or that prefix's _default)."""
    mi = list(MONO_IMP.finditer(text))
    si = list(SPLIT_IMP.finditer(text))
    files, syms, _ = index()
    known = _aliases()
    copied = {m.group(1) for m in re.finditer(r'(?<![\w.])([A-Za-z_]\w*_[derh])\.[A-Za-z_]', text) if m.group(1) in known}
    if not mi and not si:
        if any(re.search(rf'(?<![\w.]){a}\.[A-Za-z_]', l.split('#')[0]) for a in copied for l in text.split('\n')):
            raise SystemExit(f'runtime_refs.rewire: split references ({sorted(copied)[:3]}) but no runtime import')
        return text
    pre = {m.group(1) for m in mi} | {m.group(1) for m in si}
    if len(pre) != 1:
        raise SystemExit(f'runtime_refs.rewire: runtime imports from several places: {sorted(pre)}')
    P = pre.pop()
    res = {m.group(3) for m in mi} | {m.group(4) for m in si} | copied
    lines = text.split('\n')
    drop = {m.group(0) for m in mi} | {m.group(0) for m in si}
    first = min(i for i, l in enumerate(lines) if l in drop)
    kept = [l for l in lines if l not in drop]
    bound = {m.group(1) for m in re.finditer(r'^import \S+ as (\w+)', '\n'.join(kept), re.M)}
    body = '\n'.join(kept)
    res |= {a for a in BARE if a not in bound and re.search(rf'(?<![\w.]){a}\.[A-Za-z_]', body)}
    used = set()
    pat = re.compile(r'(?<![\w.])(' + '|'.join(sorted(res, key=len, reverse=True)) + r')\.([A-Za-z_]\w*)')

    def q(m):
        x = m.group(2)
        k = syms.get(x)
        if k is None and missing == 'owner':
            ps = x.split('_')
            for j in range(len(ps) - 1, 0, -1):
                p_ = '_'.join(ps[:j])
                k = syms.get(p_, syms.get(p_ + '_default'))
                if k is not None:
                    break
        if k is None:
            raise SystemExit(f'runtime_refs.rewire: {m.group(1)}.{x} is not a runtime symbol')
        used.add(k)
        return f'{alias(files[k])}.{x}'
    kept = [_code_sub(pat, q, l) for l in kept]
    at = sum(1 for l in lines[:first] if l not in drop)
    imps = [f'import {P}{split_rel(*files[k])} as {alias(files[k])}' for k in sorted(used)]
    return '\n'.join(kept[:at] + imps + kept[at:])


def use_index(json_text):
    """Rewire against this index text (generate.py: the one it is about to write) instead of INDEX's."""
    global _IX, _AL, _GEN
    import json
    d = json.loads(json_text)
    _IX = ([tuple(k) for k in d['files']], d['symbols'], d['monoliths'])
    _AL = _GEN = None
    unwire.cache_clear()


_AL = None


def _aliases():
    global _AL
    if _AL is None:
        _AL = {alias(k) for k in index()[0]}
    return _AL


def rewire_out(out):
    """A generator's outputs ({path: text} or [(path, text)]) with every Bend module rewired."""
    if isinstance(out, dict):
        return {p: (rewire(t) if str(p).endswith('.bend') else t) for p, t in out.items()}
    return [(p, (rewire(t) if str(p).endswith('.bend') else t)) for p, t in out]


@functools.lru_cache(maxsize=1024)
def unwire(text, to='T'):
    """A rewired module's text with its split qualifiers spelled as the monolith's alias again (to.<sym>),
    for generators that parse another generated module by its T.<sym> references. The module reads as
    before any light split (codegen/light_split.py unlight)."""
    import light_split as LS
    text = LS.unlight(text)
    known = _aliases()
    pat = re.compile(r'(?<![\w.])([A-Za-z_]\w*_[derh])\.([A-Za-z_]\w*)')
    return '\n'.join(_code_sub(pat, lambda m: f'{to}.{m.group(2)}' if m.group(1) in known else m.group(0), l) if '.' in l else l
                     for l in text.split('\n'))


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


def runtime_of(text):
    """'generic' when a module uses the generic runtime (imports its monolith, or a symbol only it defines),
    else 'fulu'."""
    if re.search(r'^import \S*generic_obj\.bend as ', text, re.M):
        return 'generic'
    if re.search(r'^import \S*fulu_obj\.bend as ', text, re.M):
        return 'fulu'
    files, syms, monos = index()
    global _GEN
    if _GEN is None:
        _GEN = set(monos['generic']['defs']) - set(monos['fulu']['defs'])
    for m in re.finditer(r'(?<![\w.])([A-Za-z_]\w*_[derh])\.([A-Za-z_]\w*)', text):
        if m.group(2) in _GEN:
            return 'generic'
    return 'fulu'


_GEN = None


def mono_text(runtime):
    """A monolith's text as the split files hold it (its imports, then its definitions in order, qualifiers
    removed), for generators that read the runtime's definitions."""
    files, syms, monos = index()
    m = monos[runtime]
    cache = {}
    out = list(m['head']) + ['']
    for nm in m['defs']:
        p = OUT / split_rel(*files[syms[nm]])
        if p not in cache:
            cache[p] = {n: b for n, _, b in blocks(p.read_text())[1]}
        out.append(strip_q(cache[p][nm]) + '\n')
    return '\n'.join(out)


def main():
    out = outputs()
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        orph = [str(q.relative_to(ROOT)) for q in OUT.glob(SPLIT_GLOB) if q not in out] if OUT.exists() else []
        if stale or orph:
            print('stale runtime split: ' + ', '.join((stale + orph)[:10]))
            sys.exit(1)
        print(f'runtime split is current ({len(out)} files)')
        return
    for q in OUT.glob(SPLIT_GLOB):
        if q not in out:
            q.unlink()
    for p, t in out.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(t)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
