#!/usr/bin/env python3
"""The plain element API of every collection kind (get / take, set, len, append) and every union's selector (manual spec-mutation audit, round 9).

    python3 codegen/proofs/slop/element_api_laws.py [--check]

Public counterexamples (round 9, docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md "Round 9 access laws"): on the standalone vectors and lists
(`vec_uint8_513`, `vec_uint16_5`, `proglist_uint32`, `vec_bool_5`, ...) `get(v, len)` answering Some (r9-a01), `set(v, len, x)` and a set with no
index test answering ok (a02 / a03), a uint8 / uint16 set admitting 2^k and writing it truncated (a04), `len` counting bytes (a05), get / set
at the wrong slot (a06 / a07), a boolean read wrong (a08), append writing the wrong slot or growing by one byte (a09), the byte API of the
bitvectors (b01..b04), the composite vectors and lists (c01..c04), and `<U>_selector` answering the selector of another option (f01). No law
spoke about these definitions: collection_guards covers only the packed lists whose append tests the element range and the bit lists, and
element_access_laws only the growing lists and the boxed vectors.

For every kind kp of a runtime with a public `kp_set(o, +i: U32, v: E)` and `kp_get` (or the boxed `kp_take`) and `kp_len`,
proofs/slop/validity/<runtime>_<X>_api_<kp>_generated.bend (X the name whose encoder is kp's own, else the smallest name reaching kp) holds,
with n the length of a rigid literal object F of the kind (a vector: its N elements, the slots 0, 1 and N - 1 holding distinct non-default
values e0, e1, e_last and the others the default element; a list: min(L, 3) distinct elements; a bit list: the bits True, False, True; the
composite kinds: F built from the default by set / append of the variant element of cached_list_roots.variant), w a value that differs
from the element it replaces and D the default object:

  <X>_serialize_vcoll_<kp>_api_get       len(F) is n; get(F, i) is Some{e_i} at i = 0, 1, n - 1 and None at i = n, n + 1, 2^32 - 1
  <X>_serialize_vcoll_<kp>_api_default   len(D) is N (a vector) or 0 (a list); get(D, 0) is Some{default element} (a vector) or None
  <X>_serialize_vcoll_<kp>_api_set_<i>   (i = 0, 1 when n > 2, n - 1) set(F, i, w) is accepted, get(., i) is Some{w}, len is still n and the
                                         slots i - 1, i + 1, 0 and n - 1 (inside the range, other than i) still hold their elements
  <X>_serialize_vcoll_<kp>_api_set_out   set(F, i, w) at i = n, n + 1, 2^32 - 1 is (F, False{}): refused, the object unchanged
  <X>_serialize_vcoll_<kp>_api_range     (an element of 1 or 2 bytes: uint8 / uint16 elements, byte lists and vectors, the byte API of a bit
                                         vector) set(F, 1, 2^(8U)) and set(F, 1, 2^32 - 1) are (F, False{}); set(F, 1, 2^(8U) - 1) is
                                         accepted and reads back. A uint32 / uint64 / uint128 / uint256 / boolean element is a U32 / O.U64 /
                                         record / Bool value: no value outside the element width exists, so the law has nothing to refuse.
  <X>_serialize_vcoll_<kp>_api_len       (a list) len after one append is 1, after a set on it still 1
  <X>_serialize_vcoll_<kp>_api_append    (a list) k = min(L, 3) appends of e0, e1, e2 to D are accepted, len is k, get j is Some{e_j} for
                                         j < k and None at k; when L = k one more append is refused; and (a packed or bit list with its own
                                         serializer) the checked serializer of the appended object equals that of the literal F
  <U>_serialize_vcoll_selector           (a union U) the selector of the default, and of U_ck{default of option k} for every option k, is
                                         the selector the schema declares for option k (codegen/core/generic_form_schemas.py)

Boolean elements hold True and False in F, so the reads of both values are stated. The values of F are computed here from the element
width (the U32 words of a record element, little-endian bytes of the smaller ones), never read back from the generated code; the element
width U of a packed kind is the divisor of its length (`kp_len_of`) and its largest value, when the setter tests one, must be 2^(8U) - 1
(else the generator stops). Every statement is by computation. The generator stops when a kind of the API has no access laws (the
coverage gate of this family): a kind whose element it cannot build, a set without a getter, a union whose selectors the schema does not
give. One exception, named: the list of cells (`l4096_b2048`, element O.Words of 2048 bytes) whose access is the subject of
cell_list_guards. Filed by api_gate under serialize_valid (`vcoll_*`).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402
from codegen.proofs.slop.collection_guards import owners_of  # noqa: E402
from codegen.proofs.slop.container_field_validity import type_decls  # noqa: E402
from codegen.proofs.slop.element_access_laws import element, owners_any, tup, ttyp  # noqa: E402

TOP = 4294967295
CELL_KINDS = {'l4096_b2048': 'cell_list_guards'}     # kinds whose access another generator states, by name


def own_name(tx, kp):
    """the API name whose encoder is kp's own (its `X_encode` calls kp's definitions directly), or None"""
    pat = re.compile(rf'(?<![\w.]){re.escape(kp)}_\w+\(')
    own = [X for X in sorted(re.findall(r'^def (\w+)_encode\(', tx.text, re.M)) if pat.search(tx.blk.get(f'{X}_encode', ''))]
    return own[0] if own else None


def limit(tx, kp):
    for n in sorted(tx.blk):
        if n.startswith(kp + '_app') or n == f'{kp}_push':
            m = re.search(r'U32\.is_lt\(n, (\d+)\)', tx.blk[n])
            if m:
                return int(m.group(1))
    return None


def record_decl(tx, E):
    """the field list of the Data record E: from the runtime's monolith, else from the split type files (the fork's uint256)"""
    pat = re.compile(rf'^type {re.escape(E)} is Data:\n  {re.escape(E)}\{{([^}}]*)\}}', re.M)
    m = pat.search(tx.text)
    if m is None:
        for f in sorted((ROOT / 'types').glob('*_def_generated.bend')):
            m = pat.search(f.read_text())
            if m:
                break
    return m


class Packed:
    """the elements of a packed kind (O.Words storage): their width, Bend literals and bytes"""

    def __init__(self, tx, kp, E):
        self.E = E
        lo = re.search(r'U32\.div\(n, (\d+)\)', tx.blk.get(f'{kp}_len_of', ''))
        self.U = int(lo.group(1)) if lo else 1
        self.R = None
        self.words = None
        if E == 'U32':
            if self.U not in (1, 2, 4):
                raise ValueError(f'{kp}: a U32 element of {self.U} bytes')
            m = re.search(r'U32\.is_le\(v, (\d+)\)', tx.blk.get(f'{kp}_set_n', ''))
            want = (1 << (8 * self.U)) - 1
            if self.U < 4:
                if not m or int(m.group(1)) != want:
                    raise ValueError(f'{kp}: the setter of a {self.U}-byte element does not refuse values above {want}')
                self.R = want
            self.vals = [want, 1, 0x5A5A5A5A & want]
            self.w = 0x3C3C3C3C & want
            self.dflt = 0
        elif E == 'Bool':
            if self.U != 1:
                raise ValueError(f'{kp}: a boolean element of {self.U} bytes')
            self.vals, self.w, self.dflt = [True, False, True], None, False
        elif E == 'O.U64':
            if self.U != 8:
                raise ValueError(f'{kp}: a uint64 element of {self.U} bytes')
            self.words = 2
        else:
            m = record_decl(tx, E)
            fs = [f.strip() for f in m.group(1).split(',')] if m else []
            if not fs or any(not f.endswith(': U32') for f in fs) or 4 * len(fs) != self.U:
                raise ValueError(f'{kp}: element {E} is not a record of {self.U // 4} U32 words')
            self.words = len(fs)
        if self.words:
            k = self.words
            self.vals = [[(0xFFFFFF00 + j) for j in range(k)], [j + 1 for j in range(k)], [(0x5A5A0000 + j) for j in range(k)]]
            self.w = [(0x3C3C0000 + j) for j in range(k)]
            self.dflt = [0] * k
        self.Eq = E if E in ('U32', 'Bool') or E.startswith('O.') else f'T.{E}'

    def new(self, cur):
        """a value other than cur"""
        if self.E == 'Bool':
            return not cur
        return self.w

    def lit(self, v):
        if self.E == 'Bool':
            return 'True{}' if v else 'False{}'
        if self.E == 'U32':
            return str(v)
        if self.E == 'O.U64':
            return f'O.U64{{{v[0]}, {v[1]}}}'
        return f'{self.Eq}{{{", ".join(str(x) for x in v)}}}'

    def bytes(self, v):
        if self.E == 'Bool':
            return [1 if v else 0]
        if self.E == 'U32':
            return [(v >> (8 * b)) & 255 for b in range(self.U)]
        return [(x >> (8 * b)) & 255 for x in v for b in range(4)]

    def obj(self, nbytes, slots):
        """the literal O.Words of nbytes bytes holding slots {i: value} (the other bytes zero)"""
        img = {}
        for i, v in slots.items():
            for b, x in enumerate(self.bytes(v)):
                p = i * self.U + b
                img[p >> 2] = img.get(p >> 2, 0) | (x << (8 * (p & 3)))
        o = f'O.words_new({nbytes})'
        for j in sorted(img):
            if img[j]:
                o = f'O.words_setw({o}, {j}, {img[j]})'
        return o


def pick_slots(n):
    return sorted({0, 1, n - 1} & set(range(n)))


def api_laws(X, kp, rep, Eq, getter, F, n, el, dl, newval, N, lst, ap_vals, own, Fser, rng, lit, L):
    """the laws of one kind; el(i) the element of F at slot i (a literal), dl the default element's literal"""
    T = f'T.{kp}'
    mb = f'Maybe<&1, {Eq}>'
    out = []

    def law(tag, pairs):
        lhs = [a for a, _, _ in pairs]
        rhs = [b for _, b, _ in pairs]
        typ = [f'({t})' if ' & ' in t else t for _, _, t in pairs]
        out.append(f'def {X}_serialize_vcoll_{kp}_api_{tag}()\n    -> {{{tup(lhs)} == {tup(rhs)} : {ttyp(typ)}}}:\n  {{==}}')

    def get(o, i):
        return f'Pair.snd({rep}, {mb}, {T}_{getter}({o}, {i}))'

    def ln(o):
        return f'Pair.snd({rep}, U32, {T}_len({o}))'

    def ok(call):
        return f'Pair.snd({rep}, Bool, {call})'

    def fst(call):
        return f'Pair.fst({rep}, Bool, {call})'
    D = f'{T}_default()'
    helper = f'def obj() -> {rep}: {F}'     # the literal object F, stated once
    F = 'obj()'
    outside = sorted({n, n + 1, TOP})
    law('get', [(ln(F), str(n), 'U32')] + [(get(F, i), f'Some{{{el(i)}}}', mb) for i in pick_slots(n)] + [(get(F, i), 'None{}', mb) for i in outside])
    if lst:
        law('default', [(ln(D), '0', 'U32'), (get(D, 0), 'None{}', mb)])
    else:
        law('default', [(ln(D), str(N), 'U32'), (get(D, 0), f'Some{{{dl}}}', mb), (get(D, N), 'None{}', mb)])
    for i in sorted({0, n - 1} | ({1} if n > 2 else set())):
        w = newval(i)
        st = f'{T}_set({F}, {i}, {w})'
        others = sorted({i - 1, i + 1, 0, n - 1} & set(range(n)) - {i})
        law(f'set_{i}', [(ok(st), 'True{}', 'Bool'), (get(fst(st), i), f'Some{{{w}}}', mb), (ln(fst(st)), str(n), 'U32')]
            + [(get(fst(st), j), f'Some{{{el(j)}}}', mb) for j in others])
    so = f'{rep} & Bool'
    law('set_out', [(f'{T}_set({F}, {i}, {newval(0)})', f'({F}, False{{}})', so) for i in outside])
    if rng is not None:
        j = 1 if n > 1 else 0
        st = f'{T}_set({F}, {j}, {rng})'
        law('range', [(f'{T}_set({F}, {j}, {rng + 1})', f'({F}, False{{}})', so), (f'{T}_set({F}, {j}, {TOP})', f'({F}, False{{}})', so),
                      (ok(st), 'True{}', 'Bool'), (get(fst(st), j), f'Some{{{rng}}}', mb)])
    if lst:
        a1 = fst(f'{T}_append({D}, {ap_vals[0]})')
        law('len', [(ln(a1), '1', 'U32'), (ln(fst(f'{T}_set({a1}, 0, {ap_vals[1] if len(ap_vals) > 1 else newval(0)})')), '1', 'U32')])
        k = len(ap_vals)
        s, oks = D, []
        for v in ap_vals:
            oks.append(ok(f'{T}_append({s}, {v})'))
            s = fst(f'{T}_append({s}, {v})')
        pairs = [(o, 'True{}', 'Bool') for o in oks] + [(ln(s), str(k), 'U32')] + [(get(s, j), f'Some{{{ap_vals[j]}}}', mb) for j in range(k)]
        pairs.append((get(s, k), 'None{}', mb))
        if L is not None and L == k:
            pairs.append((ok(f'{T}_append({s}, {ap_vals[0]})'), 'False{}', 'Bool'))
        if own and Fser:
            ser = f'T.{own}_serialize'
            pairs.append((f'Pair.snd({rep}, O.Encoded, {ser}({s}))', f'Pair.snd({rep}, O.Encoded, {ser}({F}))', 'O.Encoded'))
        law('append', pairs)
    return [helper] + out


def selector_law(U, opts, sels):
    lhs, rhs = [f'Pair.snd(T.{U}, U32, T.{U}_selector(T.{U}_default()))'], [str(sels[0])]
    for k, (c, Q) in enumerate(opts):
        lhs.append(f'Pair.snd(T.{U}, U32, T.{U}_selector(T.{c}{{{Q}}}))')
        rhs.append(str(sels[k]))
    return f'def {U}_serialize_vcoll_selector()\n    -> {{{tup(lhs)} == {tup(rhs)} : {ttyp(["U32"] * len(lhs))}}}:\n  {{==}}'


def kind_laws(tx, decls, kp, rep, E):
    """(X, laws) of one kind, or raise ValueError"""
    getter = 'take' if f'{kp}_take' in tx.blk else 'get' if f'{kp}_get' in tx.blk else None
    if getter is None or f'{kp}_len' not in tx.blk:
        raise ValueError(f'{kp}: set without a getter or len')
    lst = f'{kp}_append' in tx.blk
    L = limit(tx, kp) if lst else None
    if lst and L is None:
        raise ValueError(f'{kp}: append without a limit test')
    own = own_name(tx, kp)
    owners = ([own] if own else []) + owners_any(tx, kp)
    if not owners:
        raise ValueError(f'{kp}: no API name reaches it')
    X = owners[0]
    if rep == 'O.Words':
        pk = Packed(tx, kp, E)
        dm = re.search(r'O\.words_new\((\d+)\)', tx.blk.get(f'{kp}_default', ''))
        if not dm:
            raise ValueError(f'{kp}: default is not O.words_new')
        if lst:
            n = min(L, 3)
            slots = {i: pk.vals[i] for i in range(n)}
            N = 0
        else:
            N = int(dm.group(1)) // pk.U
            if N * pk.U != int(dm.group(1)) or N < 1:
                raise ValueError(f'{kp}: default of {dm.group(1)} bytes is not N elements of {pk.U}')
            n = N
            slots = {i: pk.vals[k] for k, i in enumerate(pick_slots(N))}
        F = pk.obj(n * pk.U, slots)
        el = lambda i: pk.lit(slots.get(i, pk.dflt))   # noqa: E731
        newval = lambda i: pk.lit(pk.new(slots.get(i, pk.dflt)))   # noqa: E731
        ap_vals = [pk.lit(pk.vals[i]) for i in range(min(L, 3))] if lst else []
        return X, api_laws(X, kp, rep, pk.Eq, getter, F, n, el, pk.lit(pk.dflt), newval, N, lst, ap_vals, own, True, pk.R, pk.lit, L)
    if rep == 'O.Bits':
        if E != 'Bool' or not lst:
            raise ValueError(f'{kp}: a bit kind that is not a bit list of Bool')
        n = min(L, 3)
        bits = [True, False, True][:n]
        word = sum(1 << i for i, b in enumerate(bits) if b)
        F = f'O.bits_setw(O.bits_zeros({n}), 0, {word})'
        lit = lambda b: 'True{}' if b else 'False{}'   # noqa: E731
        return X, api_laws(X, kp, rep, 'Bool', getter, F, n, lambda i: lit(bits[i]), 'False{}', lambda i: lit(not bits[i]), 0, True,
                           [lit(b) for b in bits], own, True, None, lit, L)
    # a composite element: F from the default by set / append (the variant of cached_list_roots, or a list holding one)
    ev = element(tx, decls, E)
    if ev is None:
        raise ValueError(f'{kp}: no element of {E} differing from the default')
    v, d = ev
    Eq = E if E.startswith('O.') else f'T.{E}'
    T = f'T.{kp}'
    if lst:
        n = min(L, 3)
        es = [v, d, v][:n]
        F = f'{T}_default()'
        for x in es:
            F = f'Pair.fst({T}_Seq, Bool, {T}_append({F}, {x}))'
        N = 0
    else:
        dn = re.search(r', (\d+)\}$', tx.blk.get(f'{kp}_default', ''))
        if not dn:
            raise ValueError(f'{kp}: vector length not found in its default')
        N = n = int(dn.group(1))
        es = [v] + [d] * (N - 1)
        F = f'Pair.fst({T}_Seq, Bool, {T}_set({T}_default(), 0, {v}))'
    el = lambda i: es[i]   # noqa: E731
    newval = lambda i: d if es[i] == v else v   # noqa: E731
    return X, api_laws(X, kp, f'{T}_Seq', Eq, getter, F, n, el, d, newval, N, lst, [v, d, v][:min(L, 3)] if lst else [], None, False, None, None, L)


def union_selectors():
    from codegen.core import generic_form_schemas as G
    return {n: tuple(t.selectors) for n, (t, _) in G.inventory().items() if t.kind == 'cunion'}


def module(tmod, X, kp, laws):
    return '\n'.join(['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('element_api_laws'),
                      f'# {X}: the element API of {kp} (manual spec-mutation audit, round 9; docs/mutation_testing/MANUAL_SPEC_MUTATIONS.md).', '',
                      '\n\n'.join(laws), ''])


def outputs():
    out, missing = {}, []
    sels = None
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        decls = type_decls(tx)
        api = set(re.findall(r'^def (\w+)_(?:get|take|set|append|len)\(o: ', tx.text, re.M))     # every kind with an element API
        done = set(CELL_KINDS)
        for m in re.finditer(r'^def (\w+)_set\(o: ([\w.]+), \+i: U32, (?:\+?)v: ([\w.<>]+)\) -> ', tx.text, re.M):
            kp, rep, E = m.groups()
            done.add(kp)
            if kp in CELL_KINDS:
                continue
            try:
                X, laws = kind_laws(tx, decls, kp, rep, E)
            except ValueError as e:
                missing.append(f'{runtime} {e}')
                continue
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_api_{kp}')] = module(tmod, X, kp, laws)
        missing += [f'{runtime} {kp}: an element API without a `set(o, +i: U32, v)` of the expected shape' for kp in sorted(api - done)]
        for m in re.finditer(r'^def (\w+)_selector\((?:o|v): (\w+)\) -> ', tx.text, re.M):
            U = m.group(1)
            if sels is None:
                sels = union_selectors()
            opts = re.findall(rf'^  ({re.escape(U)}_c\d+)\{{\+?v: ([\w.]+)\}}', tx.text, re.M)
            if U not in sels or not opts or len(opts) != len(sels[U]):
                missing.append(f'{runtime} {U}: union selectors')
                continue
            dflt = []
            for c, Q in opts:
                if f'{Q}_default' not in tx.blk:
                    missing.append(f'{runtime} {U}: option {Q} has no default')
                    break
                dflt.append((c, f'T.{Q}_default()'))
            else:
                out[LAYOUT.module_path('validity', f'{runtime}_{U}_api_selector')] = module(tmod, U, U, [selector_law(U, dflt, sels[U])])
    if missing:
        raise SystemExit('element_api_laws: kinds without element API laws: ' + '; '.join(missing))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'element_api_laws', ('validity',), 'stale element API laws: ', 'element API laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
