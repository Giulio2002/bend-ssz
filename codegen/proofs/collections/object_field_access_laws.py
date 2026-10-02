#!/usr/bin/env python3
"""Generate the mutation laws of the typed object API.

    /opt/homebrew/bin/python3 codegen/proofs/collections/object_field_access_laws.py [--check]

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

proofs/obj/codec_<k>.bend holds, for every name whose encoding is a whole
number of 32-bit words written at word-aligned positions, the codec laws

    round trip     decoding the encoding of any object returns that object;
    encoded size   the encoding has exactly the type's fixed size;
    length reject  a buffer one byte short, or one byte long, is rejected.

The class is stated, not selected by what happened to check: a shape qualifies
when it is fixed-size and every leaf of it occupies a whole number of words
(uint32/64/128/256, byte vectors and bit vectors whose length is a multiple of
four bytes, vectors and containers of such). For those the encoder stores whole
words and the decoder reads them back, so both sides of each equation reduce to
the same term and the proof is by computation. A shape with a sub-word leaf
(uint8, uint16, bool, an odd-length byte vector) writes with a shift and a mask
and reading it back is the word identity (x >> 8s) | ... == x, which is not a
definitional equality; those names need the bit lemmas and are not covered here.
Variable-size shapes need the offset development. Neither is claimed.

Every law is stated over an object built from variables - one variable per
field, nothing assumed about them - so it holds for every object of the type,
including the ones decode returns. The proofs are by computation: both sides
reduce to the same record. Element read-after-write for lists of objects, over the
public API, is in proofs/obj/coll_api_*.bend (codegen/proofs/collections/collection_api_laws.py), which needs the
array lemmas of proofs/compact.

A wide container (more than GROUP fields) keeps its fields in groups. Its laws
are stated with the group that holds the field expanded and the other groups
left as variables, which is what makes the untouched groups visible in the
statement; the laws of the group records cover the fields within a group.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import itertools
import sys

from codegen.impl import typed_object_runtime as G  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
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
        S, Re, Pe = f'T.{s.p}_Seq', qual(s.elem.rep), qual(s.pelem.rep)
        w(f'def {L}_write_rejected(arr: Array<{Re}>, +n: U32, +i: U32, v: {Pe})')
        w(f'    -> {{{p}_put_in(False{{}}, arr, n, i, v) == ({S}{{arr, n}}, False{{}}) : {S} & Bool}}:')
        w('  {==}')
        w(f'def {L}_write_keeps_length(arr: Array<{Re}>, +n: U32, +i: U32, v: {Pe})')
        w(f'    -> {{{p}_len(Pair.fst({S}, Bool, {p}_put_in(True{{}}, arr, n, i, v)))'
          f' == (Pair.fst({S}, Bool, {p}_put_in(True{{}}, arr, n, i, v)), n) : {S} & U32}}:')
        w('  {==}')
        if t.kind == 'list':
            w(f'def {L}_append_rejected(arr: Array<{Re}>, +n: U32, v: {Pe})')
            w(f'    -> {{{p}_app_in(False{{}}, arr, n, v) == ({S}{{arr, n}}, False{{}}) : {S} & Bool}}:')
            w('  {==}')
            w(f'def {L}_append_length(arr: Array<{Re}>, +n: U32, v: {Pe})')
            w(f'    -> {{{p}_len(Pair.fst({S}, Bool, {p}_app_in(True{{}}, arr, n, v)))'
              f' == (Pair.fst({S}, Bool, {p}_app_in(True{{}}, arr, n, v)), (n + 1 : U32)) : {S} & U32}}:')
            w('  {==}')


def word_aligned(t):
    """Does every leaf of this shape occupy a whole number of words?

    Then every field offset is a multiple of four as well, so the encoder's
    writes are whole-word stores and the decoder's reads are whole-word loads.
    """
    k = t.kind
    if k in ('uint', 'bytes'):
        return t.size % 4 == 0
    if k == 'bits':
        return t.size % 32 == 0
    if k == 'vector':
        return t.elem.fixed() and word_aligned(t.elem)
    if k == 'container':
        return bool(t.fields) and all(f.fixed() and word_aligned(f) for _, f in t.fields)
    return False


def value_term(g, t, c, bits):
    """A value of this shape built from fresh variables, one per stored word.

    A law stated over a variable of a record type cannot reduce: the encoder
    has to take the record apart, and a variable does not. Building the value
    from its words instead gives the checker something to compute with, and the
    statement still quantifies over every object of the type, because every
    object is that constructor applied to some words. A boolean leaf has no
    word to quantify over and only two values, so `bits` supplies one of them
    and the caller emits the law once for each combination - which is the whole
    type, not a sample of it.
    """
    s = g.shape(t)
    if s.kind == 'bool':
        return next(bits) + '{}', []
    if s.kind == 'u32':
        return f'x{next(c)}', [(f'x{next(c) - 1}', 'U32')]
    if s.kind == 'u64':
        a, b = f'x{next(c)}', f'x{next(c)}'
        return f'O.U64{{{a}, {b}}}', [(a, 'U32'), (b, 'U32')]
    if s.kind in ('rec', 'uwide'):
        vs = [f'x{next(c)}' for _ in range(s.nw)]
        return f'T.{s.rep}{{' + ', '.join(vs) + '}', [(v, 'U32') for v in vs]
    if s.kind == 'container':
        terms, params = [], []
        for _, ft in t.fields:
            term, ps = value_term(g, ft, c, bits)
            terms.append(term)
            params += ps
        return f'T.{s.t.name}{{' + ', '.join(terms) + '}', params
    raise ValueError(s.kind)


def buildable(g, t):
    """Can a value of this shape be built from word variables?

    Everything stored as words in the object: the scalars, the word records
    (byte vectors up to 256 bytes, bit vectors, the wide uints) and containers
    of those. A shape backed by an `Array` (`O.Words`, a sequence) is not: the
    only way to build one is `Array.new`, which fills every element with the
    same value, and a law stated over an all-equal array would be a law about
    a narrower domain than the type.
    """
    s = g.shape(t)
    if s.kind in ('u32', 'u64', 'rec', 'uwide', 'bool'):
        return True
    if s.kind == 'container':
        return all(buildable(g, ft) for _, ft in t.fields)
    return False


def bool_leaves(g, t):
    """How many boolean leaves the shape has; each one doubles the cases."""
    s = g.shape(t)
    if s.kind == 'bool':
        return 1
    if s.kind == 'container':
        return sum(bool_leaves(g, ft) for _, ft in t.fields)
    return 0


def codec_laws(w, g, n, t, size):
    """The codec laws of one aligned fixed name.

    A shape with `k` boolean leaves is stated `2^k` times, once for each
    combination, because a boolean has no word to quantify over; `k` is 0 or 1
    for every name in the schema, and the generator refuses more than three so
    that the enumeration can never quietly become a sample.
    """
    sh = g.shape(t)
    R = qual(sh.rep)
    k = bool_leaves(g, t)
    if k > 3:
        raise ValueError(f'{n}: {k} boolean leaves is too many to enumerate')
    for combo in itertools.product(('True', 'False'), repeat=k):
        suffix = '' if k == 0 else '_' + ''.join(b[0].lower() for b in combo)
        term, params = value_term(g, t, iter(range(1000)), iter(combo))
        sig = ', '.join(f'+{v}: {ty}' for v, ty in params)
        codec_body(w, n + suffix, n, term, sig, size, R)


def codec_body(w, law, n, term, sig, size, R):
    w(f'def {law}_encoded_size({sig})')
    w(f'    -> {{B.size(T.{n}_encode({term})) == (T.{n}_encode({term}), {size}) : B.Buf & U32}}:')
    w('  {==}')
    w(f'def {law}_roundtrip({sig})')
    w(f'    -> {{T.{n}_decode(T.{n}_encode({term}), {size})'
      f' == (T.{n}_encode({term}), Some{{{term}}}) : B.Buf & Maybe<&1, {R}>}}:')
    w('  {==}')
    w(f'def {law}_reject_short({sig})')
    w(f'    -> {{T.{n}_decode(T.{n}_encode({term}), {size - 1})'
      f' == (T.{n}_encode({term}), None{{}}) : B.Buf & Maybe<&1, {R}>}}:')
    w('  {==}')
    w(f'def {law}_reject_long({sig})')
    w(f'    -> {{T.{n}_decode(T.{n}_encode({term}), {size + 1})'
      f' == (T.{n}_encode({term}), None{{}}) : B.Buf & Maybe<&1, {R}>}}:')
    w('  {==}')


HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T', '']


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
            '# GENERATED by object_field_access_laws (codegen). Do not edit.',
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
            '# GENERATED by object_field_access_laws (codegen). Do not edit.',
            '# Collection laws: a rejected write or append leaves the value unchanged',
            '# and reports False, an accepted write keeps the length, and an accepted',
            '# append increases it by one.', '']
        w = lines.append
        for s in chunk:
            w(f'# ---- {s.p} ----')
            collection_laws(w, s)
            w('')
        out[ROOT / f'proofs/obj/collections_{k}.bend'] = '\n'.join(lines) + '\n'

    codecs = [(n, t, t.fixed_size()) for n, t in names.items()
              if t.fixed() and (word_aligned(t) or t.kind == 'bool')
              and g.shape(t).data and buildable(g, t)]
    kchunks = [codecs[i:i + PER_FILE] for i in range(0, len(codecs), PER_FILE)]
    for k, chunk in enumerate(kchunks):
        lines = list(HEAD) + [
            '# GENERATED by object_field_access_laws (codegen). Do not edit.',
            '# Codec laws of the names whose encoding is whole words at word-aligned',
            '# positions: decoding an encoding returns the object, the encoding has the',
            '# type\'s fixed size, and a buffer one byte short is rejected. Stated over a',
            '# variable, so they hold for every object of the type.', '']
        w = lines.append
        for n, ty, size in chunk:
            w(f'# ---- {n} ({size} bytes) ----')
            codec_laws(w, g, n, ty, size)
            w('')
        out[ROOT / f'proofs/obj/codec_{k}.bend'] = '\n'.join(lines) + '\n'

    # The same laws on the generic-form path. Its schemas are mostly variable
    # size or sub-word, so the aligned fixed class is small; it is stated for
    # every schema that falls in it, and for no other.
    sys.path.insert(0, str(ROOT / 'tools'))
    from codegen.core import generic_form_schemas as gen  # noqa: E402
    gg = G.Gen()
    gcodecs = []
    for n, ty, err in gen.inventory_all():
        if ty is None:
            continue
        if ty.fixed() and (word_aligned(ty) or ty.kind == 'bool') and gg.shape(ty).data and buildable(gg, ty):
            gcodecs.append((n, ty, ty.fixed_size()))
    ghead = ['import Base', 'import ../../src/buffer.bend as B',
             'import ../../src/obj.bend as O', 'import ../../types/generic_obj.bend as T', '']
    lines = list(ghead) + [
        '# GENERATED by object_field_access_laws (codegen). Do not edit.',
        '# The codec laws of proofs/obj/codec_*.bend, for the generic SSZ forms.',
        '# Only the schemas whose encoding is whole words at word-aligned positions',
        '# qualify; the rest are variable size or sub-word and are not claimed.', '']
    w = lines.append
    for n, ty, size in gcodecs:
        w(f'# ---- {n} ({size} bytes) ----')
        codec_laws(w, gg, n, ty, size)
        w('')
    out[ROOT / 'proofs/obj/gcodec_0.bend'] = '\n'.join(lines) + '\n'

    # The public checked encoder of every name whose object is Data: it
    # encodes exactly when the generated validity predicate holds and refuses
    # otherwise. Stated over a variable object, proved by rewriting with the
    # hypothesis - the predicate is the one serialize itself evaluates.
    ser = [(n, g.shape(t)) for n, t in names.items() if g.shape(t).data]
    schunks = [ser[i:i + PER_FILE * 3] for i in range(0, len(ser), PER_FILE * 3)]
    for k, chunk in enumerate(schunks):
        lines = list(HEAD) + [
            '# GENERATED by object_field_access_laws (codegen). Do not edit.',
            '# Checked encoder laws: a valid object serializes to its encoding, an',
            '# invalid representable one (uint8 above 255, bits past a byte vector,',
            '# nested invalid fields) is refused. Stated over a variable object.', '']
        w = lines.append
        for n, sh in chunk:
            R, pv = qual(sh.rep), f'T.{sh.p}_valid'
            w(f'def {n}_serialize_valid(+o: {R}, e: {{{pv}(o) == True{{}} : Bool}})')
            w(f'    -> {{T.{n}_serialize(o) == O.encoded(T.{n}_encode(o)) : O.Encoded}}:')
            w(f'  %Equal.sym(Bool, {pv}(o), True{{}}, e) : {{T.{n}_ser_pick(_, o) == O.encoded(T.{n}_encode(o)) : O.Encoded}}')
            w('  {==}')
            w(f'def {n}_serialize_refused(+o: {R}, e: {{{pv}(o) == False{{}} : Bool}})')
            w(f'    -> {{T.{n}_serialize(o) == O.refused() : O.Encoded}}:')
            w(f'  %Equal.sym(Bool, {pv}(o), False{{}}, e) : {{T.{n}_ser_pick(_, o) == O.refused() : O.Encoded}}')
            w('  {==}')
        out[ROOT / f'proofs/obj/serialize_{k}.bend'] = '\n'.join(lines) + '\n'

    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('*.bend')
                     if q not in out and q.name.split('_')[0] in ('fields', 'collections', 'codec', 'gcodec', 'serialize'))
    from codegen.impl import runtime_file_split as RR  # the runtime split: the modules import the per-name files they use
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale or orphans:
            print('stale generated laws: ' + ', '.join(stale + orphans))
            sys.exit(1)
        print('generated laws are current')
        sys.exit(0)
    for q in orphans:
        (ROOT / q).unlink()
        print('removed no-longer-generated ' + q)
    for p, t in out.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(t)
    print(f'{len(chunks)} field-law files over {len(recs)} records, '
          f'{len(cchunks)} collection-law files over {len(colls)} collections, '
          f'{len(kchunks)} codec-law files over {len(codecs)} aligned fixed names, '
          f'{len(gcodecs)} generic aligned fixed schemas')


if __name__ == '__main__':
    main()
