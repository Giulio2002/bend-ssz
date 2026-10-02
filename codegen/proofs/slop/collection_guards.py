#!/usr/bin/env python3
"""The element operations of the generated collections: append / set / get / len (manual spec-mutation audit, round 2: a01, a03).

    python3 codegen/proofs/slop/collection_guards.py [--check]

Public counterexamples (the public entry points of the collection, `types/*_def_generated.bend`): a 257th `bl256_append` accepted,
`bl256_get(l, len)` answering `Some(0)`, `bl256_set(l, len, v)` writing one past the end, `bl256_append(l, 256)` spilling into the next
byte, `bits9_append` of a tenth bit, the new bit stored at the wrong index. No locked statement names these definitions.

One module per name X whose collection is a packed list of U32 elements (byte lists, uint16 lists) or a bit list,
proofs/slop/validity/<runtime>_<X>_collection_generated.bend, written from the generated definitions (the limit L, the largest element R
and the element size U are read from `p_app_n`, `p_set_n` and `p_at`; the generator stops when a definition does not have the expected shape):

  packed U32 list      <X>_serialize_vcoll_len_get         after appending [R, 1] the length is 2, get 0 / 1 are R / 1 and get 2 is None
                       <X>_serialize_vcoll_get_edge       on a list of three zeros get 2 is Some(0) and get 3 is None (the bound is i < n)
                       <X>_serialize_vcoll_append_range    the element R + 1 is refused and R is accepted
                       <X>_serialize_vcoll_append_full     (L * U <= 4096) a list of L zeros refuses one more element, one of L - 1 takes it
                       <X>_serialize_vcoll_set_edge        set at 3 on a list of three zeros is refused, at 2 accepted, with R + 1 refused
                       <X>_serialize_vcoll_set_write       set 1 to R leaves elements 0 and 2 at 0 and reads back R
  bit list             <X>_serialize_vcoll_first           append True to the empty list: accepted, length 1, get 0 is Some True, get 1 is None
                       <X>_serialize_vcoll_order           appending True, False, True reads back in that order, length 3
                       <X>_serialize_vcoll_full            (L <= 2048) a list of L bits refuses one more, one of L - 1 takes it and reads it back
                       <X>_serialize_vcoll_set_edge        set at the length is refused, inside accepted and read back, neighbours unchanged

Every statement is by computation. They are named so that api_gate files them under serialize_valid (the facade of X's encoder).
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

FULL_MAX = 4096        # bytes or bits a limit-edge law builds whole


def owners_of(tx, p):
    """the API names X whose encoder reaches the collection with prefix p: X's own shape, or a container with a field of that shape"""
    pat = re.compile(rf'\b{re.escape(p)}_[a-z]\w*\(')
    out = []
    for X in sorted(re.findall(r'^def (\w+)_encode\(', tx.text, re.M)):
        pre = X + '_'
        if any(n.startswith(pre) and pat.search(b) for n, b in tx.blk.items()):
            out.append(X)
    return out


def limit_of(guard):
    m = re.search(r'U32\.is_lt\(n, (\d+)\)', guard)
    if m:
        return int(m.group(1))
    m = re.search(r'U32\.is_le\(\(n \+ 1 : U32\), (\d+)\)', guard)
    return int(m.group(1)) if m else None


def packed_params(tx, p):
    """(L or None, R, U) of the packed U32 list with prefix p, or None when its definitions are not of the expected shape"""
    app = tx.blk.get(f'{p}_app_n', '')
    st = tx.blk.get(f'{p}_set_n', '')
    at = tx.blk.get(f'{p}_at', '')
    mr = re.search(r'U32\.is_le\(v, (\d+)\)', app)
    ms = re.search(r'U32\.is_le\(v, (\d+)\)', st)
    mu = re.search(r'\(i \* (\d+) : U32\)', at)
    g = re.search(rf'{re.escape(p)}_grow\((.*), o, n, v\)', app)
    if not (mr and ms and mu and g) or mr.group(1) != ms.group(1):
        return None
    return limit_of(g.group(1)), int(mr.group(1)), int(mu.group(1))


def packed_laws(X, p, L, R, U):
    T = f'T.{p}'
    lst = 'O.Words'
    maybe = 'Maybe<&1, U32>'
    ap = lambda o, v: f'ap({o}, {v})'   # noqa: E731
    out = []

    def law(tag, stmt):
        out.append(f'def {X}_serialize_vcoll_{tag}()\n    -> {{{stmt}}}:\n  {{==}}')

    def get(o, i):
        return f'Pair.snd({lst}, {maybe}, {T}_get({o}, {i}))'

    def ln(o):
        return f'Pair.snd({lst}, U32, {T}_len({o}))'

    def ok(call):
        return f'Pair.snd({lst}, Bool, {call})'
    two = ap(ap(f'{T}_default()', R), 1)
    law('len_get', f'({ln(two)}, ({get(two, 0)}, ({get(two, 1)}, {get(two, 2)}))) == (2, (Some{{{R}}}, (Some{{1}}, None{{}}))) : U32 & ({maybe} & ({maybe} & {maybe}))')
    z3 = f'O.words_new({3 * U})'
    law('get_edge', f'({get(z3, 2)}, ({get(z3, 3)}, {ln(z3)})) == (Some{{0}}, (None{{}}, 3)) : {maybe} & ({maybe} & U32)')
    law('append_range', f'({ok(f"{T}_append({T}_default(), {R + 1})")}, {ok(f"{T}_append({T}_default(), {R})")}) == (False{{}}, True{{}}) : Bool & Bool')
    if L is not None and 1 <= L and L * U <= FULL_MAX:
        full, almost = f'O.words_new({L * U})', f'O.words_new({(L - 1) * U})'
        law('append_full', f'({ok(f"{T}_append({full}, 0)")}, ({ok(f"{T}_append({almost}, 0)")}, {ln(ap(almost, 0))})) == (False{{}}, (True{{}}, {L})) : Bool & (Bool & U32)')
    law('set_edge', f'({ok(f"{T}_set({z3}, 3, 0)")}, ({ok(f"{T}_set({z3}, 2, 0)")}, {ok(f"{T}_set({z3}, 1, {R + 1})")})) == (False{{}}, (True{{}}, False{{}})) : Bool & (Bool & Bool)')
    s = f'Pair.fst({lst}, Bool, {T}_set({z3}, 1, {R}))'
    law('set_write', f'({get(s, 0)}, ({get(s, 1)}, {get(s, 2)})) == (Some{{0}}, (Some{{{R}}}, Some{{0}})) : {maybe} & ({maybe} & {maybe})')
    helper = f'def ap(o: {lst}, +v: U32) -> {lst}: Pair.fst({lst}, Bool, {T}_append(o, v))\n'
    return helper, out


def bits_laws(X, p, L):
    T = f'T.{p}'
    lst, maybe = 'O.Bits', 'Maybe<&1, Bool>'
    out = []

    def law(tag, stmt):
        out.append(f'def {X}_serialize_vcoll_{tag}()\n    -> {{{stmt}}}:\n  {{==}}')

    def get(o, i):
        return f'Pair.snd({lst}, {maybe}, {T}_get({o}, {i}))'

    def ln(o):
        return f'Pair.snd({lst}, U32, {T}_len({o}))'

    def ok(call):
        return f'Pair.snd({lst}, Bool, {call})'
    one = f'ap({T}_default(), True{{}})'
    law('first', f'({ok(f"{T}_append({T}_default(), True{{}})")}, ({ln(one)}, ({get(one, 0)}, {get(one, 1)}))) == (True{{}}, (1, (Some{{True{{}}}}, None{{}}))) : Bool & (U32 & ({maybe} & {maybe}))')
    three = f'ap(ap({one}, False{{}}), True{{}})'
    small = L is not None and L < 3
    if not small:
        law('order', f'({ln(three)}, ({get(three, 0)}, ({get(three, 1)}, ({get(three, 2)}, {get(three, 3)})))) == (3, (Some{{True{{}}}}, (Some{{False{{}}}}, (Some{{True{{}}}}, None{{}})))) : U32 & ({maybe} & ({maybe} & ({maybe} & {maybe})))')
    if L is not None and 1 <= L <= 2048:
        full, almost = f'O.bits_zeros({L})', f'O.bits_zeros({L - 1})'
        law('full', f'({ok(f"{T}_append({full}, True{{}})")}, ({ok(f"{T}_append({almost}, True{{}})")}, {get(f"ap({almost}, True{{}})", L - 1)})) == (False{{}}, (True{{}}, Some{{True{{}}}})) : Bool & (Bool & {maybe})')
    n = min(L, 40) if L is not None else 40
    if n >= 2:
        z = f'O.bits_zeros({n})'
        s = f'Pair.fst({lst}, Bool, {T}_set({z}, {n - 1}, True{{}}))'
        law('set_edge', f'({ok(f"{T}_set({z}, {n}, True{{}})")}, ({ok(f"{T}_set({z}, {n - 1}, True{{}})")}, ({get(s, n - 1)}, {get(s, n - 2)}))) == (False{{}}, (True{{}}, (Some{{True{{}}}}, Some{{False{{}}}}))) : Bool & (Bool & ({maybe} & {maybe}))')
    helper = f'def ap(o: {lst}, v: Bool) -> {lst}: Pair.fst({lst}, Bool, {T}_append(o, v))\n'
    return helper, out


def module(tmod, X, helper, laws):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('collection_guards'),
         f'# {X}: the element operations of the collection (manual spec-mutation audit, round 2; docs/mutation_testing/MUTATION_PROOFS.md).', '', helper]
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        for m in re.finditer(r'^def (\w+)_append\(o: (O\.Words|O\.Bits), (\+?)v: (U32|Bool)\) -> [^\n:]*: \w+\(', tx.text, re.M):
            p, rep, _, vt = m.groups()
            if rep == 'O.Words' and vt == 'U32':
                prm = packed_params(tx, p)
                if prm is None:
                    continue
                build = lambda X, prm=prm, p=p: packed_laws(X, p, *prm)   # noqa: E731
            elif rep == 'O.Bits':
                g = re.search(r'_push\((U32\.is_lt\(n, \d+\)), o, v\)', tx.blk.get(f'{p}_app_n', ''))
                if not g:
                    continue
                build = lambda X, g=g, p=p: bits_laws(X, p, limit_of(g.group(1)))   # noqa: E731
            else:
                continue
            for X in owners_of(tx, p):
                helper, laws = build(f'{X}')
                laws = [l.replace(f'{X}_serialize_vcoll_', f'{X}_serialize_vcoll_{p}_') for l in laws]
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_collection_{p}')] = module(tmod, X, helper, laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'collection_guards', ('validity',), 'stale collection guard laws: ', 'collection guard laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
