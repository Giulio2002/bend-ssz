#!/usr/bin/env python3
"""Generate the mutation laws of the typed object API.

    /opt/homebrew/bin/python3 codegen/laws.py [--check]

proofs/obj/fields_<k>.bend holds, for every container of types/fulu_obj.bend
and for every one of its fields, the laws

    read after write      reading a field right after writing it returns the
                          value written, in the object with that field replaced;
    unrelated unchanged   reading any other field returns what it was;
    overwrite             a second write to the same field wins;
    accepted / rejected   a checked write stores the value and reports True, a
                          rejected one returns the object unchanged and False;
    swap                  a field with its own storage hands back the old value.

proofs/obj/collections_<k>.bend holds, for every collection, the laws

    rejected write / append  leave the value unchanged and report False;
    accepted write           keeps the length;
    accepted append          increases the length by one.

Every law is stated over an object built from variables - one variable per
field, nothing assumed about them - so it holds for every object of the type,
including the ones decode returns. The proofs are by computation: both sides
reduce to the same record. Element read-after-write for lists of objects is in
proofs/obj/seq_elem.bend, which needs the array lemmas of proofs/compact.

A wide container (more than GROUP fields) keeps its fields in groups. Its laws
are stated with the group that holds the field expanded and the other groups
left as variables, which is what makes the untouched groups visible in the
statement; the laws of the group records cover the fields within a group.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate as G  # noqa: E402
import schema  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
PER_FILE = 12


def qual(rep):
    """The generated names live in module T, Bend's and the object runtime's in
    their own; a wrapper carries its argument, which needs the same treatment."""
    for pre in ('O.Boxed<', 'Array<'):
        if rep.startswith(pre) and rep.endswith('>'):
            return pre + qual(rep[len(pre):-1]) + '>'
    if rep in ('Bool', 'U32') or rep.startswith('O.'):
        return rep
    return 'T.' + rep


class Rec:
    """One record the field laws are stated over: a plain container, a group,
    or a wide container seen through one of its groups."""

    def __init__(self, p, law, params, build, fields, wide=False):
        self.p, self.law, self.params, self.build, self.fields, self.wide = p, law, params, build, fields, wide
        self.rep = None


def entries(g):
    out = []
    for s in g.order:
        if s.kind != 'container':
            continue
        F = s.fields
        R = qual(s.t.name)
        if len(F) <= G.GROUP:
            vs = [f'x{i}' for i in range(len(F))]
            params = [(v, G.plus(fs), qual(fs.rep)) for v, (_, fs) in zip(vs, F)]

            def build(j, term, vs=vs, s=s):
                xs = list(vs)
                if j is not None:
                    xs[j] = term
                return f'T.{s.t.name}{{' + ', '.join(xs) + '}'
            r = Rec('T.' + s.p, s.t.name, params, build, [(f, fs, i) for i, (f, fs) in enumerate(F)])
            r.rep = R
            out.append(r)
            continue
        chunks = [F[k:k + G.GROUP] for k in range(0, len(F), G.GROUP)]
        gnames = [f'{s.p}_g{k}' for k in range(len(chunks))]
        gdata = [all(fs.data for _, fs in c) for c in chunks]
        for k, c in enumerate(chunks):
            # the group record on its own
            vs = [f'x{i}' for i in range(len(c))]
            params = [(v, G.plus(fs), qual(fs.rep)) for v, (_, fs) in zip(vs, c)]

            def gbuild(j, term, vs=vs, gn=gnames[k]):
                xs = list(vs)
                if j is not None:
                    xs[j] = term
                return f'T.{gn}{{' + ', '.join(xs) + '}'
            r = Rec('T.' + gnames[k], gnames[k], params, gbuild, [(f, fs, i) for i, (f, fs) in enumerate(c)])
            r.rep = qual(gnames[k])
            out.append(r)
            # the wide container, with this group expanded and the others left whole
            gv = [f'g{i}' for i in range(len(chunks))]
            wparams = [(gv[i], '+' if gdata[i] else '', qual(gnames[i])) for i in range(len(chunks)) if i != k]
            wparams += params

            def wbuild(j, term, vs=vs, gv=gv, k=k, gn=gnames[k], s=s):
                xs = list(vs)
                if j is not None:
                    xs[j] = term
                gs = list(gv)
                gs[k] = f'T.{gn}{{' + ', '.join(xs) + '}'
                return f'T.{s.t.name}{{' + ', '.join(gs) + '}'
            r = Rec('T.' + s.p, f'{s.t.name}_obj_g{k}', wparams, wbuild,
                    [(f, fs, i) for i, (f, fs) in enumerate(c)], wide=True)
            r.rep = R
            out.append(r)
    return out


def field_laws(w, r):
    decl = ', '.join(f'{pl}{v}: {ty}' for v, pl, ty in r.params)
    built = r.build(None, None)
    p, L, R = r.p, r.law, r.rep
    for f, fs, j in r.fields:
        V = qual(fs.rep)
        dom = G.scalar_ok(fs, 'v')
        after = r.build(j, 'v')
        if fs.data and dom is None:
            w(f'def {L}_read_after_write_{f}({decl}, +v: {V})')
            w(f'    -> {{{p}_get_{f}({p}_set_{f}({built}, v)) == ({after}, v) : {R} & {V}}}:')
            w('  {==}')
            w(f'def {L}_overwrite_{f}({decl}, +v: {V}, +w2: {V})')
            w(f'    -> {{{p}_set_{f}({p}_set_{f}({built}, v), w2) == {r.build(j, "w2")} : {R}}}:')
            w('  {==}')
            if not r.wide:
                for g2, gs, k in r.fields:
                    if k == j or not gs.data or G.scalar_ok(gs, 'v') is not None:
                        continue
                    w(f'def {L}_unchanged_{f}_{g2}({decl}, +v: {V})')
                    w(f'    -> {{{p}_get_{g2}({p}_set_{f}({built}, v)) == ({after}, x{k}) : {R} & {qual(gs.rep)}}}:')
                    w('  {==}')
        elif fs.data:
            w(f'def {L}_write_rejected_{f}({decl}, +v: {V})')
            w(f'    -> {{{p}_put_{f}(False{{}}, {built}, v) == ({built}, False{{}}) : {R} & Bool}}:')
            w('  {==}')
            w(f'def {L}_write_accepted_{f}({decl}, +v: {V})')
            w(f'    -> {{{p}_put_{f}(True{{}}, {built}, v) == ({after}, True{{}}) : {R} & Bool}}:')
            w('  {==}')
            w(f'def {L}_read_after_write_{f}({decl}, +v: {V})')
            w(f'    -> {{{p}_get_{f}({p}_set_{f}_go({built}, v)) == ({after}, v) : {R} & {V}}}:')
            w('  {==}')
        else:
            w(f'def {L}_swap_{f}({decl}, y: {V})')
            w(f'    -> {{{p}_swap_{f}({built}, y) == ({r.build(j, "y")}, x{j}) : {R} & {V}}}:')
            w('  {==}')
            w(f'def {L}_replace_{f}({decl}, y: {V})')
            w(f'    -> {{{p}_set_{f}({built}, y) == {r.build(j, "y")} : {R}}}:')
            w('  {==}')


def collection_laws(w, s):
    p, L = 'T.' + s.p, s.p
    t, k = s.t, s.kind
    if k in ('packed', 'packed_elems', 'bytelist'):
        byteish = k == 'bytelist'
        el = None if byteish else s.g.shape(t.elem)
        es = 1 if byteish else t.elem.fixed_size()
        er = 'U32' if byteish else qual(el.rep)
        pl = '+' if byteish else G.plus(el)
        w(f'def {L}_write_rejected(ws: Array<U32>, +n: U32, +i: U32, {pl}v: {er})')
        w(f'    -> {{{p}_put_at(False{{}}, O.Words{{ws, n}}, i, v) == (O.Words{{ws, n}}, False{{}}) : O.Words & Bool}}:')
        w('  {==}')
        if t.kind in ('list', 'bytelist'):
            w(f'def {L}_append_rejected(ws: Array<U32>, +n: U32, +m: U32, {pl}v: {er})')
            w(f'    -> {{{p}_grow(False{{}}, O.Words{{ws, n}}, m, v) == (O.Words{{ws, n}}, False{{}}) : O.Words & Bool}}:')
            w('  {==}')
    elif k == 'bitlist':
        w(f'def {L}_write_rejected(ws: Array<U32>, +n: U32, +i: U32, b: Bool)')
        w(f'    -> {{{p}_put_at(False{{}}, O.Bits{{ws, n}}, i, b) == (O.Bits{{ws, n}}, False{{}}) : O.Bits & Bool}}:')
        w('  {==}')
        w(f'def {L}_append_rejected(ws: Array<U32>, +n: U32, b: Bool)')
        w(f'    -> {{{p}_push(False{{}}, O.Bits{{ws, n}}, b) == (O.Bits{{ws, n}}, False{{}}) : O.Bits & Bool}}:')
        w('  {==}')
    elif k == 'fixwords':
        w(f'def {L}_write_rejected(ws: Array<U32>, +n: U32, +i: U32, +v: U32)')
        w(f'    -> {{{p}_put_at(False{{}}, O.Words{{ws, n}}, i, v) == (O.Words{{ws, n}}, False{{}}) : O.Words & Bool}}:')
        w('  {==}')
    elif k == 'seq':
        S, Re = f'T.{s.p}_Seq', qual(s.elem.rep)
        w(f'def {L}_write_rejected(arr: Array<{Re}>, +n: U32, +i: U32, v: {Re})')
        w(f'    -> {{{p}_put_in(False{{}}, arr, n, i, v) == ({S}{{arr, n}}, False{{}}) : {S} & Bool}}:')
        w('  {==}')
        w(f'def {L}_write_keeps_length(arr: Array<{Re}>, +n: U32, +i: U32, v: {Re})')
        w(f'    -> {{{p}_len(Pair.fst({S}, Bool, {p}_put_in(True{{}}, arr, n, i, v)))'
          f' == (Pair.fst({S}, Bool, {p}_put_in(True{{}}, arr, n, i, v)), n) : {S} & U32}}:')
        w('  {==}')
        if t.kind == 'list':
            w(f'def {L}_append_rejected(arr: Array<{Re}>, +n: U32, v: {Re})')
            w(f'    -> {{{p}_app_in(False{{}}, arr, n, v) == ({S}{{arr, n}}, False{{}}) : {S} & Bool}}:')
            w('  {==}')
            w(f'def {L}_append_length(arr: Array<{Re}>, +n: U32, v: {Re})')
            w(f'    -> {{{p}_len(Pair.fst({S}, Bool, {p}_app_in(True{{}}, arr, n, v)))'
              f' == (Pair.fst({S}, Bool, {p}_app_in(True{{}}, arr, n, v)), (n + 1 : U32)) : {S} & U32}}:')
            w('  {==}')


HEAD = ['import Base', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T', '']


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for n, t in names.items():
        g.shape(t)
    recs = entries(g)
    colls = [s for s in g.order if s.kind in ('packed', 'packed_elems', 'bytelist', 'bitlist', 'fixwords', 'seq')]

    out = {}
    chunks = [recs[i:i + PER_FILE] for i in range(0, len(recs), PER_FILE)]
    for k, chunk in enumerate(chunks):
        lines = list(HEAD) + [
            '# GENERATED by codegen/laws.py. Do not edit.',
            '# Field laws: what a write does to the field written, what it leaves',
            '# alone, and what a read right after it returns. Stated over an object',
            '# built from variables, so they hold for every object of the type.', '']
        w = lines.append
        for r in chunk:
            w(f'# ---- {r.law} ----')
            field_laws(w, r)
            w('')
        out[ROOT / f'proofs/obj/fields_{k}.bend'] = '\n'.join(lines) + '\n'
    cchunks = [colls[i:i + PER_FILE * 2] for i in range(0, len(colls), PER_FILE * 2)]
    for k, chunk in enumerate(cchunks):
        lines = list(HEAD) + [
            '# GENERATED by codegen/laws.py. Do not edit.',
            '# Collection laws: a rejected write or append leaves the value unchanged',
            '# and reports False, an accepted write keeps the length, and an accepted',
            '# append increases it by one.', '']
        w = lines.append
        for s in chunk:
            w(f'# ---- {s.p} ----')
            collection_laws(w, s)
            w('')
        out[ROOT / f'proofs/obj/collections_{k}.bend'] = '\n'.join(lines) + '\n'

    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        print('stale generated laws: ' + ', '.join(stale) if stale else 'generated laws are current')
        sys.exit(1 if stale else 0)
    for p, t in out.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(t)
    print(f'{len(chunks)} field-law files over {len(recs)} records, '
          f'{len(cchunks)} collection-law files over {len(colls)} collections')


if __name__ == '__main__':
    main()
