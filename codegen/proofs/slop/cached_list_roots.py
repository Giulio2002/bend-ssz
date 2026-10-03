#!/usr/bin/env python3
"""The cached tree of a list of composites agrees with the plain root (manual spec-mutation audit, round 3: g02, x08).

    python3 codegen/proofs/slop/cached_list_roots.py [--check]

Public counterexample (List[ProposerSlashing, 16] and the other cached list kinds): `X_cache(l)` then `X_cached_root` answers a digest that is not
`X_root(l)` after a dirty range that stops one leaf short, a digest array one slot short, a pad level missing, the right child read from node
2 j + 2; `X_cget(c, n)` (`X_ctake` for a boxed kind) answers some, `X_cset(c, n, v)` is accepted, the last `X_capp` of a full list is refused. Only 11 of the 17 kinds had
cached laws, and the laws of the others state nothing a mutant of these definitions changes.

For every list kind with a cached form and an element type the generator can vary (a first scalar field it can set; the kinds whose elements it
cannot vary are listed in docs/mutation_testing/MUTATION_PROOFS.md) proofs/slop/validity/<runtime>_<X>_vroot_<kp>_cache_generated.bend (X the
smallest container using the list) holds, symbolic in the hash length `hl` (the SHA of a symbolic `hl` stays a term: both sides are the same term
exactly when the same leaves are hashed in the same tree), with a, b two different elements and R the digest of `X_cached_root`, P the digest of `X_root`:

  <X>_vroot_<kp>_cache_app_n      R(capp^n(cache(empty), a b a b)) = P(append^n(empty, a b a b))  for n = 1 .. 4 (n <= the limit; limits above 2^13 have no plain root the checker can unfold:
                                  `app_fold` states the root of one element as the fold of its leaf with the zero subtrees, and the set laws compare with a fresh cache)
  <X>_vroot_<kp>_cache_set_3      the tree [a b a b] once rooted (clean), cset 3 then the root = the plain root of the set list (the dirty range reaches the last leaf)
  <X>_vroot_<kp>_cache_set_0      ... cset 0
  <X>_vroot_<kp>_cache_set_1_3    ... cset 1 then cset 3 (both ends of the dirty range move)
  <X>_vroot_<kp>_cache_end        cget at the length is None, cget inside is some; cset at the length is refused, inside accepted
  <X>_vroot_<kp>_cache_limit      (limit <= 16) capp at limit - 1 elements is accepted, at the limit refused
  <X>_vroot_<kp>_cache_dok        `O.cache_dok`: a depth of 32 or more is never accepted, a depth needs 2^d slots

Each is one module (the proofs stay under 2 minutes). Filed by api_gate under `root` (the `_vroot_` late rule).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import generic_form_schemas as generic  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402
from codegen.proofs.slop.container_field_validity import type_decls  # noqa: E402
from codegen.proofs.slop.tight_storage_root import owners_of_root  # noqa: E402

CACHED = re.compile(r'^def (\w+)_cached_root\(\+hl: Nat, h: B\.Buf, c: \w+_Cached, \+seg: U32\)', re.M)
N_MAX = 4
LIMIT_MAX = 16
PLAIN_MAX = 1 << 13        # the largest limit whose plain root the checker unfolds (a unary tree of 2^depth chunks)


def variant(tx, decls, E, depth=0):
    """a value of the composite E that differs from E_default(), built from its setters (None when no scalar field is reachable)"""
    if depth > 4 or E not in decls:
        return None
    for fn, ty in decls[E]:
        setter = f'T.{E}_set_{fn}'
        if f'{E}_set_{fn}' not in tx.blk:
            continue
        if ty == 'O.U64':
            return f'{setter}(T.{E}_default(), O.U64{{1, 0}})'
        if ty == 'U32':
            return f'{setter}(T.{E}_default(), 1)'
        if ty == 'Bool':
            return f'{setter}(T.{E}_default(), True{{}})'
        m = re.fullmatch(r'O\.Boxed<(\w+)>', ty)
        inner = m.group(1) if m else ty
        if inner in decls and not inner.startswith(f'{E}_g'):
            v = variant(tx, decls, inner, depth + 1)
            if v is not None:
                wrapped = f'T.{inner}_bx_wrap({v})' if m else v
                return f'{setter}(T.{E}_default(), {wrapped})'
    return None


def elements(tx, decls, E):
    """(a, b): two different valid elements"""
    if E == 'O.Words':
        return 'O.words_new(0)', 'O.words_new(1)'
    v = variant(tx, decls, E)
    return (f'T.{E}_default()', v) if v is not None else None


def fold_of(tx, kp, E):
    """(leaf, depth): the digest of an element as the cached tree takes it (the leaf of `kp_leaf_go`), and the depth of the limit"""
    pad = re.search(r'Nat\.sub\((\d+)n, d\)', tx.blk.get(f'{kp}_croot_pad', ''))
    lg = re.search(r'(\w+_root)\(hl, h, v, \(seg \+ 64 : U32\)\)', tx.blk.get(f'{kp}_leaf_go', ''))
    if not (pad and lg):
        return None
    fn = lg.group(1)
    boxed = fn.endswith('_bx_root')
    El = E if E.startswith('O.') else f'T.{E}'
    M = f'O.Boxed<{El}>' if boxed else El

    plain = bool(re.search(r'-> B\.Buf & D\.Digest:', tx.blk.get(fn, '').split('\n', 1)[0]))     # a fixed-size element's root answers the digest alone

    def leaf(a):
        arg = f'O.BSome{{{a}, O.BNone{{}}}}' if boxed else a
        if plain:
            return f'Pair.snd(B.Buf, D.Digest, T.{fn}(hl, B.empty(), {arg}, 64))'
        return f'Pair.snd({M}, D.Digest, Pair.snd(B.Buf, {M} & D.Digest, T.{fn}(hl, B.empty(), {arg}, 64)))'
    return leaf, int(pad.group(1))


def laws_of(X, kp, E, Lm, ab, es=None, first=None, fold=None, getter='cget'):
    T = f'T.{kp}'
    a, b = ab
    els = [a, b, a, b]
    out = []

    def law(tag, params, stmt):
        out.append((tag, f'def {X}_vroot_{kp}_cache_{tag}({params})\n    -> {{{stmt}}}:\n  {{==}}'))

    def seq(k):
        s = f'{T}_default()'
        for e in els[:k]:
            s = f'sa({s}, {e})'
        return s

    def cached(k):
        c = f'{T}_cache({T}_default())'
        for e in els[:k]:
            c = f'ca({c}, {e})'
        return c
    R = lambda c: f'rd(hl, {c})'    # noqa: E731
    deep = Lm > PLAIN_MAX
    # the reference of a cached root: the plain root of the list (it unfolds a tree of 2^depth chunks: only for the small limits), else a fresh cache of the same list
    P = (lambda s: f'pd(hl, {s})') if not deep else (lambda s: R(f'{T}_cache({s})'))    # noqa: E731
    if not deep:
        for k in range(1, min(N_MAX, Lm) + 1):
            law(f'app_{k}', '+hl: Nat', f'{R(cached(k))} == {P(seq(k))} : D.Digest')
    elif fold is not None:
        # one element: its root padded with the zero subtrees of every level up to the limit, then the length mixed in (the deep limits have no plain root to compare with)
        leaf, depth = fold
        r = leaf(a)
        for lvl in range(depth):
            r = f'D.node(hl, {r}, D.zconst({lvl}n))'
        law('app_fold', '+hl: Nat', f'{R(cached(1))} == O.mix_len(hl, {r}, 1) : D.Digest')
    if Lm >= N_MAX:
        base = seq(4)
        clean = f'rc(hl, {T}_cache({base}))'
        law('set_3', '+hl: Nat', f'{R(f"cs({clean}, 3, {a})")} == {P(f"ss({base}, 3, {a})")} : D.Digest')
        law('set_0', '+hl: Nat', f'{R(f"cs({clean}, 0, {b})")} == {P(f"ss({base}, 0, {b})")} : D.Digest')
        law('set_1_3', '+hl: Nat', f'{R(f"cs(cs({clean}, 1, {a}), 3, {a})")} == {P(f"ss(ss({base}, 1, {a}), 3, {a})")} : D.Digest')
    c3 = cached(min(3, Lm))
    k3 = min(3, Lm)
    law('end', '', f'({_flag(f"{T}_cset({c3}, {k3}, {a})")}, ({_flag(f"{T}_cset({c3}, {k3 - 1}, {b})")}, ({_none(f"{T}_{getter}({c3}, {k3})")}, {_none(f"{T}_{getter}({c3}, {k3 - 1})")}))) == (False{{}}, (True{{}}, (True{{}}, False{{}}))) : Bool & (Bool & (Bool & Bool))')
    if Lm <= LIMIT_MAX:
        full = f'{T}_cache({T}_default())'
        for i in range(Lm):
            full = f'ca({full}, {els[i % 2]})'
        almost = f'{T}_cache({T}_default())'
        for i in range(Lm - 1):
            almost = f'ca({almost}, {els[i % 2]})'
        law('limit', '', f'({_flag(f"{T}_capp({almost}, {a})")}, {_flag(f"{T}_capp({full}, {a})")}) == (True{{}}, False{{}}) : Bool & Bool')
    law('dok', '', '(O.cache_dok(Nat.is_lt(32n, 32n), 32n, 4294967295), (O.cache_dok(Nat.is_lt(31n, 32n), 31n, 2147483648), (O.cache_dok(Nat.is_lt(5n, 32n), 5n, 31), O.cache_dok(Nat.is_lt(5n, 32n), 5n, 32)))) == (False{}, (True{}, (False{}, True{}))) : Bool & (Bool & (Bool & Bool))')
    if es is not None and Lm >= 3 and first and ab[1].startswith(f'T.{E}_set_{first}('):
        # fixed-size elements are written back to back: the one non-zero byte of each variant element is where its position says (round 3: l01/04, l01/05)
        words = 1
        while 4 * (1 << words) < 3 * es + 8:
            words += 1
        exp = f'Array.new(U32, {words}n, 0)'
        vals = {}
        for i in (0, 2):
            q = es * i
            vals[q // 4] = vals.get(q // 4, 0) | (1 << (8 * (q % 4)))
        for w, v in sorted(vals.items()):
            exp = f'Array.set(U32, {exp}, {w}, {v})'
        s3 = f'{T}_default()'
        for e in (b, a, b):
            s3 = f'sa({s3}, {e})'
        out.append(('enc', f'def {X}_serialize_vcoll_{kp}_enc()\n    -> {{Pair.fst(Array<U32>, {T}_Seq & U32, {T}_putn(Array.new(U32, {words}n, 0), 0, {s3})) == {exp} : Array<U32>}}:\n  {{==}}'))
    return out


def _flag(call):
    return f'Pair.snd(CACHED, Bool, {call})'


def _none(call):
    return f'is_none(Pair.snd(CACHED, MAYBE, {call}))'


def helpers(kp, E0):
    E = E0 if E0.startswith('O.') else f'T.{E0}'
    T = f'T.{kp}'
    return '\n\n'.join([
        f'def sa(o: {T}_Seq, v: {E}) -> {T}_Seq: Pair.fst({T}_Seq, Bool, {T}_append(o, v))',
        f'def ss(o: {T}_Seq, +i: U32, v: {E}) -> {T}_Seq: Pair.fst({T}_Seq, Bool, {T}_set(o, i, v))',
        f'def ca(c: {T}_Cached, v: {E}) -> {T}_Cached: Pair.fst({T}_Cached, Bool, {T}_capp(c, v))',
        f'def cs(c: {T}_Cached, +i: U32, v: {E}) -> {T}_Cached: Pair.fst({T}_Cached, Bool, {T}_cset(c, i, v))',
        f'def rd(+hl: Nat, c: {T}_Cached) -> D.Digest: Pair.snd({T}_Cached, D.Digest, Pair.snd(B.Buf, {T}_Cached & D.Digest, {T}_cached_root(hl, B.empty(), c, 0)))',
        f'def rc(+hl: Nat, c: {T}_Cached) -> {T}_Cached: Pair.fst({T}_Cached, D.Digest, Pair.snd(B.Buf, {T}_Cached & D.Digest, {T}_cached_root(hl, B.empty(), c, 0)))',
        f'def pd(+hl: Nat, o: {T}_Seq) -> D.Digest: Pair.snd({T}_Seq, D.Digest, Pair.snd(B.Buf, {T}_Seq & D.Digest, {T}_root(hl, B.empty(), o, 0)))',
        f'def is_none(m: Maybe<&1, {E}>) -> Bool:\n  match m:\n    case Some{{v}}: False{{}}\n    case None{{}}: True{{}}'])


def module(tmod, X, kp, E, text):
    Eq = E if E.startswith('O.') else f'T.{E}'
    body = helpers(kp, E).replace('CACHED', f'T.{kp}_Cached').replace('MAYBE', f'Maybe<&1, {Eq}>')
    text = text.replace('CACHED', f'T.{kp}_Cached').replace('MAYBE', f'Maybe<&1, {Eq}>')
    return '\n'.join(['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/digest.bend as D', 'import ../../src/obj.bend as O',
                      f'import ../../types/{tmod}.bend as T', '', writer.header('cached_list_roots'),
                      f'# {X}: the cached tree of {kp} agrees with the plain root (manual spec-mutation audit, round 3; docs/mutation_testing/MUTATION_PROOFS.md).', '', body, '', text, ''])


def outputs():
    out = {}
    schemas = {'fulu': schema.load(ROOT / 'codegen/fulu.yaml'), 'generic': {n: t for n, t, e in generic.inventory_all() if e is None}}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        decls = type_decls(tx)
        for m in CACHED.finditer(tx.text):
            kp = m.group(1)
            ap = re.search(rf'^def {re.escape(kp)}_append\(o: \w+, v: ([\w.]+)\)', tx.text, re.M)
            lim = re.search(r'U32\.is_lt\(n, (\d+)\)', tx.blk.get(f'{kp}_capp_sz', '') or tx.blk.get(f'{kp}_capp', ''))
            owners = owners_of_root(tx, kp)
            if not (ap and lim and owners):
                continue
            E = ap.group(1)
            ab = elements(tx, decls, E)
            st = schemas[runtime].get(E)
            if E == 'O.Words' or (st is not None and st.kind == 'pcontainer'):     # byte-list elements root over a tree of 2^25 chunks (a unary Nat); a progressive container's setters answer pairs: documented limitations
                continue
            es = st.fixed_size() if st is not None and st.kind == 'container' and st.fixed() else None
            if ab is None:
                print(f'cached_list_roots: no variant element for {kp} ({E})')
                continue
            X = owners[0]
            for tag, text in laws_of(X, kp, E, int(lim.group(1)), ab, es, decls[E][0][0] if decls.get(E) else None, fold_of(tx, kp, E), 'cget' if f'{kp}_cget' in tx.blk else 'ctake'):
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_vroot_{kp}_cache_{tag}')] = module(tmod, X, kp, E, text)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'cached_list_roots', ('validity',), 'stale cached list root laws: ', 'cached list root laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
