#!/usr/bin/env python3
"""The element operations of a list of fixed-size cells: length, get, set, append and the word blit (round-2 faults a06-cells/08-10, a07-words-blit/04, 07).

    python3 codegen/proofs/slop/cell_list_guards.py [--check]

Public counterexamples (`types/Fulu_list_bytevec_2048_4096_def_generated.bend`, the one cell collection `List[Cell, 4096]` of
DataColumnSidecar): `l4096_b2048_len` of a column of 2047 cells answering 2048 (the count divides by 2047), `l4096_b2048_get(l, 0)` answering
2047 bytes or the cell at index 1, `l4096_b2048_set(l, 1, c)` followed by `get(l, 1)` leaving the old cell (the blit wrote at byte 2048
used as a word index), a source length of the blit off by one. No locked statement reads a cell back.

For every name X reaching a collection p whose definition has `p_blit(pair: O.Words & O.Words)` (cell size U from `p_at`, limit from `p_app_w`),
proofs/slop/validity/<runtime>_<X>_cells_<p>_<tag>_generated.bend (one law per module) holds, on cells that differ in their first and last word:

  <X>_serialize_vcoll_<p>_cell_len      `p_len_of((w, n))` at n = 0, U - 1, U, 2 U - 1, 2 U, 2047 U, 4096 U (the divisor)
  <X>_serialize_vcoll_<p>_cell_get_0 / _get_1 / _get_end   get 0 and 1 read back their own cell (length, first word, last word); get at the length is None
  <X>_serialize_vcoll_<p>_cell_set_get_0 / _set_get_1      set 1 then get 0 and 1: cell 0 unchanged, cell 1 as written (word 0 non-zero)
  <X>_serialize_vcoll_<p>_cell_refuse_<call>   set at the length, set or append of a cell one byte short or long or on a tight storage are refused; append of a good cell is accepted
  <X>_serialize_vcoll_<p>_cell_blit     `O.words_blit` at byte 8 writes words 2 and 3 of the destination only and returns its source with its
                                        length; an empty source changes nothing

By computation; filed by api_gate under serialize_valid (the `vcoll_` form).
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
from codegen.proofs.slop.collection_guards import owners_of  # noqa: E402

MAYBE = 'Maybe<&1, O.Words>'


def nest(items):
    return items[0] if len(items) == 1 else f'({items[0]}, {nest(items[1:])})'


def tnest(types):
    return types[0] if len(types) == 1 else f'{types[0]} & ({tnest(types[1:])})'


def params_of(tx, p):
    """(U, L) of the cell collection p, or None when its definitions are not of the expected shape"""
    at = tx.blk.get(f'{p}_at', '')
    app = tx.blk.get(f'{p}_app_w', '')
    mu = re.search(r'O\.words_slice\(o, \(i \* (\d+) : U32\), (\d+)\)', at)
    ml = re.search(r'U32\.is_lt\(n, (\d+)\)', app)
    if not (mu and ml) or mu.group(1) != mu.group(2) or int(mu.group(1)) % 4:
        return None
    return int(mu.group(1)), int(ml.group(1))


def laws_of(X, p, U, L):
    T = f'T.{p}'
    W = U // 4
    out = []

    def law(tag, stmt):
        out.append((tag, f'def {X}_serialize_vcoll_{p}_cell_{tag}()\n    -> {{{stmt}}}:\n  {{==}}'))

    def mk(a, b):
        return f'O.words_write(O.words_write(O.words_new({U}), 0, {a}, 4), {U - 4}, {b}, 4)'

    def ap(o, c):
        return f'ap({o}, {c})'
    l3 = ap(ap(ap(f'{T}_default()', mk(1, 2)), mk(3, 4)), mk(5, 6))

    def get(o, i):
        return f'sig(Pair.snd(O.Words, {MAYBE}, {T}_get({o}, {i})))'

    def ln(o):
        return f'Pair.snd(O.Words, U32, {T}_len({o}))'

    def ok(call):
        return f'Pair.snd(O.Words, Bool, {call})'
    ns = [0, U - 1, U, 2 * U - 1, 2 * U, 2047 * U, L * U]
    want = [n // U for n in ns]
    law('len', f'{nest([f"Pair.snd(O.Words, U32, {T}_len_of((O.words_new(0), {n})))" for n in ns])} == {nest([str(w) for w in want])} : {tnest(["U32"] * len(ns))}')
    sg = f'U32 & (U32 & U32)'
    l2 = ap(ap(f'{T}_default()', mk(1, 2)), mk(3, 4))
    l1 = ap(f'{T}_default()', mk(1, 2))
    law('get_0', f'{get(l1, 0)} == ({U}, (1, 2)) : {sg}')
    law('get_end', f'{get(l1, 1)} == (0, (0, 0)) : {sg}')
    law('get_1', f'{get(l2, 1)} == ({U}, (3, 4)) : {sg}')
    s = f'Pair.fst(O.Words, Bool, {T}_set({l2}, 1, {mk(7, 8)}))'
    for i, w in ((0, f'({U}, (1, 2))'), (1, f'({U}, (7, 8))')):
        law(f'set_get_{i}', f'{get(s, i)} == {w} : {sg}')
    short, long_ = f'O.words_new({U - 1})', f'O.words_new({U + 1})'
    tight = f'O.Words{{Array.new(U32, 0n, 0), {U}}}'
    for tag, call, want in (('set_end', f'{T}_set({l1}, 1, {mk(7, 8)})', 'False'), ('set_short', f'{T}_set({l1}, 0, {short})', 'False'),
                            ('set_long', f'{T}_set({l1}, 0, {long_})', 'False'), ('set_tight', f'{T}_set({l1}, 0, {tight})', 'False'),
                            ('app_short', f'{T}_append({T}_default(), {short})', 'False'), ('app_long', f'{T}_append({T}_default(), {long_})', 'False'),
                            ('app_tight', f'{T}_append({T}_default(), {tight})', 'False'), ('app_ok', f'{T}_append({T}_default(), {mk(7, 8)})', 'True')):
        law(f'refuse_{tag}', f'{ok(call)} == {want}{{}} : Bool')
    dst = 'O.words_new(64)'
    src = 'O.words_write(O.words_write(O.words_new(8), 0, 11, 4), 4, 22, 4)'
    b = f'O.words_blit({dst}, 8, {src})'
    d = lambda j: f'Pair.snd(O.Words, U32, O.words_word(Pair.fst(O.Words, O.Words, {b}), {j}))'  # noqa: E731
    r = f'Pair.snd(O.Words, O.Words, {b})'
    e = f'O.words_blit({dst}, 8, O.words_new(0))'
    law('blit', f'({nest([d(j) for j in (0, 1, 2, 3, 4, 8, 9)])}, ({cw(r, 0)}, ({cw(r, 1)}, ({clen(r)}, ({clen(f"Pair.snd(O.Words, O.Words, {e})")}, {cw(f"Pair.fst(O.Words, O.Words, {e})", 2)}))))) == '
        f'({nest(["0", "0", "11", "22", "0", "0", "0"])}, (11, (22, (8, (0, 0))))) : ({tnest(["U32"] * 7)}) & (U32 & (U32 & (U32 & (U32 & U32))))')
    helper = (f'def ap(o: O.Words, c: O.Words) -> O.Words: Pair.fst(O.Words, Bool, {T}_append(o, c))\n\n'
              f'def cw(c: O.Words, +j: U32) -> U32: Pair.snd(O.Words, U32, O.words_word(c, j))\n\n'
              f'def clen(c: O.Words) -> U32: Pair.snd(O.Words, U32, O.words_len(c))\n\n'
              f'def sig3(+n: U32, +a: U32, pair: O.Words & U32) -> U32 & (U32 & U32):\n  (c, +z) = pair\n  (n, (a, z))\n\n'
              f'def sig2(+n: U32, pair: O.Words & U32) -> U32 & (U32 & U32):\n  (c, +a) = pair\n  sig3(n, a, O.words_word(c, {W - 1}))\n\n'
              f'def sig1(pair: O.Words & U32) -> U32 & (U32 & U32):\n  (c, +n) = pair\n  sig2(n, O.words_word(c, 0))\n\n'
              f'def sigw(c: O.Words) -> U32 & (U32 & U32): sig1(O.words_len(c))\n\n'
              f'def sig(m: {MAYBE}) -> U32 & (U32 & U32):\n  match m:\n    case Some{{c}}: sigw(c)\n    case None{{}}: (0, (0, 0))\n')
    return helper, out


def cw(c, j):
    return f'Pair.snd(O.Words, U32, O.words_word({c}, {j}))'


def clen(c):
    return f'Pair.snd(O.Words, U32, O.words_len({c}))'


def module(tmod, X, helper, laws):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('cell_list_guards'),
         f'# {X}: the element operations of the cell collection (manual spec-mutation audit, round 2; docs/mutation_testing/MUTATION_PROOFS.md).', '', helper]
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        for m in re.finditer(r'^def (\w+)_blit\(pair: O\.Words & O\.Words\) -> O\.Words:', tx.text, re.M):
            p = m.group(1)
            prm = params_of(tx, p)
            if prm is None:
                continue
            for X in owners_of(tx, p):
                helper, laws = laws_of(X, p, *prm)
                for tag, text in laws:
                    out[LAYOUT.module_path('validity', f'{runtime}_{X}_cells_{p}_{tag}')] = module(tmod, X, helper, [text])
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'cell_list_guards', ('validity',), 'stale cell list guard laws: ', 'cell list guard laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
