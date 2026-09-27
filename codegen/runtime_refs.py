#!/usr/bin/env python3
"""The runtime split (docs/RUNTIME_SPLIT.md), additive stage: the generated runtime monoliths
types/fulu_obj.bend and types/generic_obj.bend, cut per readable name and operation into

    types/<Name>_def_generated.bend            the name's types, default, field access, update, force, dump, fuzz
    types/<Name>_encode_ssz_generated.bend     what its encoder, serializer, writers, size and validity pass reach
    types/<Name>_decode_ssz_generated.bend     what its decoder, validator, reader and builder reach
    types/<Name>_hashtreeroot_generated.bend   what its hash_tree_root / root reach

(Bend imports only plain path segments; the spelling is split_rel's).

next to the monoliths, which stay the runtime every proof imports (nothing imports these yet).
Called by codegen/generate.py (so its --check covers them); `python3 codegen/runtime_refs.py --check`
runs the split's own check alone.

Owners. Every top-level definition of a monolith has an owner: the longest runtime prefix it
extends (a shape's p, an API name, a word record's name), a boxed shape's (X_bx) being its container's.
An owner's readable name is codegen/names.py's for an API name (FuluBeaconBlock, ComplexTestStruct,
uint8, ...); a shape that is some API name's representation takes the first such name's (b32 is
FuluBytes32's); a shape no name has takes a structural name (Fulu_list_Withdrawal_16,
Fulu_bitlist_131072, list_uint16_1024, ...). Owners with one readable name share its files. The
generic runtime's own copies of the basic types boolean / uintN are Generic_<name> in this stage.

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


def split(text, g, names, readable, fork, taken=()):
    """({path: text}, files, file of each name, imports, header) of one monolith's split files.
    taken: file names another runtime writes (the fork-independent basic types, boolean and uintN, which
    the generic runtime also generates: its copies are Generic_<name> until the rewiring shares them)."""
    head, bl = blocks(text)
    file_of, cands = owners_of(g, names, readable, fork)
    file_of = {k: (f'Generic_{v}' if v in taken else v) for k, v in file_of.items()}
    top = {}
    owner = {}
    for nm, kind, b in bl:
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
    # per file: its definitions (monolith order) and references
    files = {}
    for nm, kind, b in bl:
        files.setdefault(fk[nm], []).append((nm, b))

    def alias(key):
        f, o = key
        return re.sub(r'\W', '_', f) + '_' + LETTER[o]
    out, deps = {}, {}
    for key, defs in files.items():
        f, o = key
        used = []
        body = []
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
        imps = [l.replace('import ../', 'import ' + TO_ROOT, 1) for l in head]
        order = {k: i for i, k in enumerate(files)}
        for k in sorted(used, key=lambda k: order[k]):
            imps.append(f'import {TO_SPLIT}{split_rel(k[0], k[1])} as {alias(k)}')
        text_ = '\n'.join(imps) + '\n\n# GENERATED by codegen/generate.py (codegen/runtime_refs.py): the runtime split, ' \
            f'additive stage; the runtime is still {MONO[fork]}.\n# {f}: {DOC[o]}\n\n' + '\n\n'.join(body) + '\n'
        out[OUT / split_rel(f, o)] = text_
    return out, files, fk, deps, head


MONO = {'Fulu': 'types/fulu_obj.bend', '': 'types/generic_obj.bend'}
DOC = {'def': 'its types, default, field access, update, force, dump and fuzz helpers',
       'encode_ssz': 'its encoder, serializer, writers, size and validity pass',
       'decode_ssz': 'its decoder, validator, reader and builder',
       'hashtreeroot': 'its hash_tree_root'}


def _is_local(x, b):
    """Top-level names are never shadowed by locals in the generated runtime (its locals are lowercase
    field / pair names, its top-level names prefixed); the server check of the split files is the guard."""
    return False


def split_check(mono_text, out_files, files, fk, deps):
    """The split files' definitions, qualifiers removed, are the monolith's; the imports are acyclic."""
    _, bl = blocks(mono_text)
    want = {nm: b for nm, _, b in bl}
    got = {}
    for key, defs in files.items():
        p = OUT / split_rel(key[0], key[1])
        t = out_files[p]
        _, gb = blocks(t)
        for nm, _, b in gb:
            if nm in got:
                raise SystemExit(f'runtime split: {nm} defined twice')
            got[nm] = re.sub(r'(?<![\w.])[A-Za-z_]\w*_[derh]\.(?=[A-Za-z_])', '', b)
    if set(got) != set(want):
        raise SystemExit(f'runtime split: definitions differ: {sorted(set(want) ^ set(got))[:10]}')
    bad = [nm for nm in want if got[nm] != want[nm]]
    if bad:
        raise SystemExit(f'runtime split: {len(bad)} definitions changed, e.g. {bad[:5]}')
    # acyclic
    state = {}

    def visit(k, stack):
        if state.get(k) == 2:
            return
        if state.get(k) == 1:
            raise SystemExit(f'runtime split: an import cycle through {k}')
        state[k] = 1
        for d in deps.get(k, []):
            visit(d, stack)
        state[k] = 2
    for k in deps:
        visit(k, ())
    return len(want)


def outputs(ctx=None):
    """{path: text} of both monoliths' split files. ctx: [(monolith text, Gen, names, fork prefix)] as
    codegen/generate.py computed them (standalone: recomputed through generate.py)."""
    import names as NM
    if ctx is None:
        import generate as G
        ctx = G.split_contexts()
    readable = NM.mapping()
    out = {}
    taken = set()
    for text, g, names, fork in ctx:
        o, files, fk, deps, _ = split(text, g, names, readable, fork, taken)
        taken |= {f for f, _ in files}
        split_check(text, o, files, fk, deps)
        clash = sorted(str(p.relative_to(ROOT)) for p in o if p in out)
        if clash:
            raise SystemExit(f'runtime split: two runtimes write {clash[:6]}')
        if len(o) != len(files):
            raise SystemExit('runtime split: two files of one runtime share a path')
        out.update(o)
    # no split file may take a path of types/ that is not a split file (the monoliths, the index files,
    # the hand-written types); split files are exactly the SPLIT_GLOB names
    import fnmatch
    others = [q for q in OUT.iterdir() if q.is_file() and not fnmatch.fnmatch(q.name, SPLIT_GLOB)]
    hit = sorted(q.name for q in others if q in out)
    stray = sorted(str(p.relative_to(ROOT)) for p in out if not fnmatch.fnmatch(p.name, SPLIT_GLOB) or p.parent != OUT)
    if hit or stray:
        raise SystemExit(f'runtime split: a name collision in types/: {hit[:6]} {stray[:6]}')
    return out


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
