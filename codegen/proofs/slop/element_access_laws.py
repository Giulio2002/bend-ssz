#!/usr/bin/env python3
"""Appends that grow the storage keep the old elements; a boxed vector's take / set act on index i only (manual spec-mutation audit, round 8).

    python3 codegen/proofs/slop/element_access_laws.py [--check]

Public counterexamples (round 8): `r8-e01/04` the second `l8_Attestation_append` from the default grows the storage (`_room_pick` copies the
old elements into a tree of the new depth) and a copy of n - 1 elements leaves the last old one an absent box: the list is not valid and its
root changes. `coll_seq` / `coll_api_*` state appends on a list whose storage already has room, and `read_append` reads back the NEW element
only. `r8-e02/01..03` on `vec_VarTestStruct_2` (ComplexTestStruct.f_G): `take(v, 2)` answers Some (the index wraps on the 2-slot array),
`set(v, 2, x)` is accepted and overwrites element 0, `set(v, i, x)` writes slot 0: no law spoke about this vector kind's take / set.

For every list kind kp whose append can grow its storage (a `kp_room_pick`; limit L >= 2) proofs/slop/validity/<runtime>_<X>_access_<kp>_generated.bend
(X the smallest name whose root uses kp) holds, with v an element that differs from the default (cached_list_roots.variant; for a byte-list
element the one byte 7):

  <X>_serialize_vcoll_<kp>_append_grow   k = min(L, 3) appends of v to the default (growths at 1 and 2 elements): every append accepted, the
                                         list is valid, its length is k, and every element 0 .. k-1 reads back v (`_get`, or `_take` for the
                                         boxed kinds), so no growth drops or moves an old element

and for every vector kind kp with a boxed take (`kp_take`, length N from its default), d its default and v as above:

  <X>_serialize_vcoll_<kp>_read_set_<i>     (i = 0, N - 1) set(d, i, v) is accepted and take(., i) is Some{v}
  <X>_serialize_vcoll_<kp>_other_set_<i>    take(set(d, i, v), j) is Some{default element} for every j != i (set writes slot i only)
  <X>_serialize_vcoll_<kp>_out_of_range     set(d, N, v) is refused and leaves every element the default's; take(d, N) is None and leaves them too

Every statement is by computation. The generator stops when a kind has no element it can vary (the coverage gate of these laws). Filed by
api_gate under serialize_valid (`vcoll_*`).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402
from codegen.proofs.slop.cached_list_roots import variant  # noqa: E402
from codegen.proofs.slop.collection_guards import owners_of  # noqa: E402
from codegen.proofs.slop.container_field_validity import type_decls  # noqa: E402
from codegen.proofs.slop.tight_storage_root import owners_of_root  # noqa: E402

BYTE7 = 'O.Words{Array.set(U32, Array.new(U32, 0n, 0), 0, 7), 1}'     # the byte list [7]


def owners_any(tx, kp, depth=0):
    """the API names that reach kp: its own owners, else (an inner list: proglist_VarTestStruct inside List[List[..]]) those of a kind that uses it"""
    own = owners_of_root(tx, kp) or owners_of(tx, kp)
    if own or depth > 2:
        return own
    pat = re.compile(rf"(?<![\w.]){re.escape(kp)}_\w+\(")
    for n, b in sorted(tx.blk.items()):
        if not n.startswith(kp + "_") and pat.search(b):
            parts = n.split("_")
            for k in range(len(parts) - 1, 0, -1):
                kq = "_".join(parts[:k])
                if f"{kq}_root" in tx.blk and kq != kp:
                    own = owners_any(tx, kq, depth + 1)
                    if own:
                        return own
    return []


def element(tx, decls, E):
    """(v, d): an element that differs from the default, and the default element"""
    if E == 'O.Words':
        return BYTE7, 'O.words_new(0)'
    if E.endswith('_Seq') and f'{E[:-4]}_append' in tx.blk:
        # a list element (List[List[..]]): the inner list holding one element that differs from its default
        inner = re.search(rf'^def {re.escape(E[:-4])}_append\(o: \w+, v: ([\w.]+)\)', tx.text, re.M)
        el = element(tx, decls, inner.group(1)) if inner else None
        if el is None:
            return None
        return f'Pair.fst(T.{E}, Bool, T.{E[:-4]}_append(T.{E[:-4]}_default(), {el[0]}))', f'T.{E[:-4]}_default()'
    v = variant(tx, decls, E)
    return (v, f'T.{E}_default()') if v is not None else None


def tup(xs):
    """the right-nested pair of the terms xs"""
    return xs[0] if len(xs) == 1 else f'({xs[0]}, {tup(xs[1:])})'


def ttyp(ts):
    return ts[0] if len(ts) == 1 else f'{ts[0]} & ({ttyp(ts[1:])})' if len(ts) > 2 else f'{ts[0]} & {ts[1]}'


def grow_law(X, kp, Eq, v, L, getter):
    T = f'T.{kp}'
    seq, mb = f'{T}_Seq', f'Maybe<&1, {Eq}>'
    k = min(L, 3)
    s = f'{T}_default()'
    oks = []
    for _ in range(k):
        oks.append(f'Pair.snd({seq}, Bool, {T}_append({s}, {v}))')
        s = f'Pair.fst({seq}, Bool, {T}_append({s}, {v}))'
    reads = [f'Pair.snd({seq}, {mb}, {T}_{getter}({s}, {i}))' for i in range(k)]
    lhs = oks + [f'Pair.snd({seq}, Bool, {T}_valid({s}))', f'Pair.snd({seq}, U32, {T}_len({s}))'] + reads
    rhs = ['True{}'] * k + ['True{}', str(k)] + [f'Some{{{v}}}'] * k
    typ = ['Bool'] * (k + 1) + ['U32'] + [mb] * k
    return ('append_grow', f'def {X}_serialize_vcoll_{kp}_append_grow()\n    -> {{{tup(lhs)} == {tup(rhs)} : {ttyp(typ)}}}:\n  {{==}}')


def vector_laws(X, kp, Eq, v, d, N):
    T = f'T.{kp}'
    seq, mb = f'{T}_Seq', f'Maybe<&1, {Eq}>'
    dv = f'{T}_default()'
    out = []

    def take(o, i):
        return f'Pair.snd({seq}, {mb}, {T}_take({o}, {i}))'

    def law(tag, lhs, rhs, typ):
        out.append((tag, f'def {X}_serialize_vcoll_{kp}_{tag}()\n    -> {{{tup(lhs)} == {tup(rhs)} : {ttyp(typ)}}}:\n  {{==}}'))
    for i in sorted({0, N - 1}):
        st = f'{T}_set({dv}, {i}, {v})'
        law(f'read_set_{i}', [f'Pair.snd({seq}, Bool, {st})', take(f'Pair.fst({seq}, Bool, {st})', i)], ['True{}', f'Some{{{v}}}'], ['Bool', mb])
        others = [j for j in range(min(N, 4)) if j != i] + ([N - 1] if N > 4 and i != N - 1 else [])
        if others:
            law(f'other_set_{i}', [take(f'Pair.fst({seq}, Bool, {st})', j) for j in others], [f'Some{{{d}}}'] * len(others), [mb] * len(others))
    bad = f'{T}_set({dv}, {N}, {v})'
    tk = f'{T}_take({dv}, {N})'
    idx = sorted({0, N - 1})
    lhs = [f'Pair.snd({seq}, Bool, {bad})'] + [take(f'Pair.fst({seq}, Bool, {bad})', j) for j in idx]
    lhs += [f'Pair.snd({seq}, {mb}, {tk})'] + [take(f'Pair.fst({seq}, {mb}, {tk})', j) for j in idx]
    rhs = ['False{}'] + [f'Some{{{d}}}'] * len(idx) + ['None{}'] + [f'Some{{{d}}}'] * len(idx)
    law('out_of_range', lhs, rhs, ['Bool'] + [mb] * len(idx) + [mb] + [mb] * len(idx))
    return out


def module(tmod, X, kp, text):
    return '\n'.join(['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('element_access_laws'),
                      f'# {X}: the element access of {kp} (manual spec-mutation audit, round 8; docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md).', '', text, ''])


def outputs():
    out, missing = {}, []
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        decls = type_decls(tx)
        for kp in sorted(n[:-len('_room_pick')] for n in tx.blk if n.endswith('_room_pick')):
            ap = re.search(rf'^def {re.escape(kp)}_append\(o: \w+, v: ([\w.]+)\)', tx.text, re.M)
            lim = re.search(r'U32\.is_lt\(n, (\d+)\)', tx.blk.get(f'{kp}_app_sz', '') or tx.blk.get(f'{kp}_append', ''))
            owners = owners_any(tx, kp)
            getter = 'take' if f'{kp}_take' in tx.blk else 'get' if f'{kp}_get' in tx.blk else None
            L = int(lim.group(1)) if lim else 1 << 32
            if L < 2:
                continue            # a list of at most one element never grows its one-slot storage
            el = element(tx, decls, ap.group(1)) if ap else None
            if not (el and owners and getter and f'{kp}_valid' in tx.blk and f'{kp}_len' in tx.blk):
                missing.append(f'{runtime} {kp}: append growth')
                continue
            E = ap.group(1)
            Eq = E if E.startswith('O.') else f'T.{E}'
            X = owners[0]
            tag, text = grow_law(X, kp, Eq, el[0], L, getter)
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_access_{kp}')] = module(tmod, X, kp, text)
        for kp in sorted(n[:-len('_take')] for n in tx.blk if re.fullmatch(r'v\d+_\w+_take', n)):
            st = re.search(rf'^def {re.escape(kp)}_set\(o: \w+, \+i: U32, v: ([\w.]+)\)', tx.text, re.M)
            dn = re.search(r', (\d+)\}$', tx.blk.get(f'{kp}_default', ''))
            owners = owners_any(tx, kp)
            el = element(tx, decls, st.group(1)) if st else None
            if not (el and dn and owners):
                missing.append(f'{runtime} {kp}: vector take / set')
                continue
            E = st.group(1)
            Eq = E if E.startswith('O.') else f'T.{E}'
            X = owners[0]
            laws = vector_laws(X, kp, Eq, el[0], el[1], int(dn.group(1)))
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_vaccess_{kp}')] = module(tmod, X, kp, '\n\n'.join(t for _, t in laws))
    if missing:
        raise SystemExit('element_access_laws: kinds without access laws: ' + '; '.join(missing))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'element_access_laws', ('validity',), 'stale element access laws: ', 'element access laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
