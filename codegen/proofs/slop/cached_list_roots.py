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
  <X>_vroot_<kp>_cache_app_clean  a clean tree of [a b a], then capp b (it fits): the root of [a b a b]
  <X>_vroot_<kp>_cache_end        cget at the length is None, cget inside is some; cset at the length is refused, inside accepted
  <X>_vroot_<kp>_cache_limit      (limit <= 16) capp at limit - 1 elements is accepted, at the limit refused
  <X>_vroot_<kp>_cache_dok        `O.cache_dok`: a depth of 32 or more is never accepted, a depth needs 2^d slots
  <X>_vroot_<kp>_cache_take_<i>   (the kinds with `_ctake`; round 8: d01/18) a clean tree of [a b a], ctake i (i = 0, 2), then the root = the root of the
                                  list the plain `_take` leaves: the taken slot is marked dirty (an absent box is the zero leaf of both)

Round 8 (d01/14, d01/15, d01/18): EVERY list kind with a cached tree has these laws, and the generator stops when one has none (the coverage
gate). The elements: a progressive container is varied through its unchecked `_go` setter, a container of byte vectors only (HistoricalSummary,
ConsolidationRequest) through the first word of its first vector, and the transactions list (byte-list elements, whose root unfolds a tree
of 2^25 chunks unless the list is empty) holds empty byte lists only.

Round 11 (d02/01..06, d03/04, d03/05, d04/03: a growth that marks only leaves 0..n dirty, a set after a root that does not widen the window):

  <X>_vroot_<kp>_cache_app_5      five appends then one root (n = 1 .. 5 above): the growth to depth 3, where a padding parent must be the zero subtree;
                                  the 5-element laws (app_5, grow_5) compare with a fresh cache of the same list: past depth 2 a plain root spells an
                                  empty subtree as its constant D.zconst(h) and a cached tree as D.node(hl, zero, zero), the same digest at hl = 64 but
                                  another term for a symbolic hl
  <X>_vroot_<kp>_cache_grow_k     (k = 1 .. min(5, limit)) the root of the empty tree, then k appends each followed by a root: the root after the k-th
                                  is the plain root (growths from a clean tree at 1, 2 and 4 elements)
  <X>_vroot_<kp>_cache_set_<i>    for EVERY kind (limit 1 too): i the lowest (0) and the highest index of a clean tree of min(4, limit) elements (set_1_3
                                  as well); the transactions list (whose elements cannot vary by computation) states the dirty window after the
                                  sets: exactly (lowest set, highest set), where the window after a root is the empty (n, 0)
Round 12 (d01/02, d01/03, d02/03: the cache of a non-empty list with the window starting at leaf 1, or the empty list's depth):

  <X>_vroot_<kp>_cache_nonempty_k R(cache(list of k elements)) = P(the list), k = 1, 2 and (limit >= 4) 3
The coverage gate asks app_<min(5, limit)>, grow_<min(5, limit)>, set_0, set_<min(4, limit) - 1>, nonempty_1 and nonempty_<min(2, limit)> of every kind.

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
N_MAX = 4          # the clean tree the set laws start from (and the app_clean law) holds 4 elements
APP_MAX = 5        # appends from the empty tree before one root (round 11: 5 crosses the growth to depth 3)
GROW_MAX = 5       # appends from the empty tree, each followed by a root (round 11)
LIMIT_MAX = 16
PLAIN_MAX = 1 << 13        # the largest limit whose plain root the checker unfolds (a unary tree of 2^depth chunks)


def variant(tx, decls, E, depth=0, words=None):
    """a value of the composite E that differs from E_default(), built from its setters (None when no scalar field is reachable)"""
    if words is None:
        # a scalar field anywhere first (the laws written before round 8 keep their elements); a word vector only when there is none
        return variant(tx, decls, E, depth, False) or variant(tx, decls, E, depth, True)
    if depth > 4 or E not in decls:
        return None
    if words and decls[E] and all(ty == 'U32' for _, ty in decls[E]) and f'{E}_default' not in tx.blk:
        # a word vector (Bytes20, Bytes32, Bytes48: a record of U32 words with no setters of its own): its first word is 1 (round 8: the
        # cached trees of HistoricalSummary and ConsolidationRequest, whose fields are all byte vectors)
        return f'T.{E}{{{", ".join(["1"] + ["0"] * (len(decls[E]) - 1))}}}'
    for fn, ty in decls[E]:
        name = f'{E}_set_{fn}'
        if name not in tx.blk:
            continue
        # a progressive container's checked setter answers the object and the flag: its unchecked `_go` body (or the first component)
        pair = ' & Bool' in tx.blk[name].split('\n', 1)[0].split('->')[-1]
        if pair and f'{name}_go' in tx.blk:
            name, pair = f'{name}_go', False
        setter = f'T.{name}'

        def put(v):
            return f'Pair.fst(T.{E}, Bool, {setter}(T.{E}_default(), {v}))' if pair else f'{setter}(T.{E}_default(), {v})'
        if ty == 'O.U64':
            return put('O.U64{1, 0}')
        if ty == 'U32':
            return put('1')
        if ty == 'Bool':
            return put('True{}')
        m = re.fullmatch(r'O\.Boxed<(\w+)>', ty)
        inner = m.group(1) if m else ty
        if inner in decls and not inner.startswith(f'{E}_g'):
            v = variant(tx, decls, inner, depth + 1, words)
            if v is not None:
                return put(f'T.{inner}_bx_wrap({v})' if m else v)
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


def laws_of(X, kp, E, Lm, ab, es=None, first=None, fold=None, getter='cget', sym=False):
    T = f'T.{kp}'
    a, b = ab
    els = [a, b, a, b, a]
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
    # (round 11) past 4 elements (depth 3) a plain root spells an empty subtree of height >= 1 as its constant D.zconst(h), while a cached tree hashes
    # D.node(hl, zero, zero): equal at hl = 64, different terms for a symbolic hl. The 5-element laws compare with a fresh cache of the same list
    # (whose window is the whole tree; the nonempty laws tie a fresh cache to the plain root)
    Pk = lambda k, s: P(s) if k <= N_MAX else R(f"{T}_cache({s})")    # noqa: E731
    for k in range(1, min(APP_MAX, Lm) + 1):     # the tree grows at 2^d elements: the deep kinds compare with a fresh cache of the same list
        law(f'app_{k}', '+hl: Nat', f'{R(cached(k))} == {Pk(k, seq(k))} : D.Digest')
    if deep and fold is not None:
        leaf, depth = fold
        r = leaf(a)
        for lvl in range(depth):
            r = f'D.node(hl, {r}, D.zconst({lvl}n))'
        law('app_fold', '+hl: Nat', f'{R(cached(1))} == O.mix_len(hl, {r}, 1) : D.Digest')
    # (round 11: d02/01..06) the tree grows one level when an append finds it full; each append from the empty tree followed by a root: the
    # root after the k-th append is the plain root (k up to 5 crosses the growths at 1, 2 and 4 elements, the last one to depth 3, where a
    # growth that marks only the leaves 0..n dirty leaves a padding parent at D.zero instead of the zero subtree)
    for k in range(1, min(GROW_MAX, Lm) + 1):
        c = f'rc(hl, {T}_cache({T}_default()))'
        for e in els[:k - 1]:
            c = f'rc(hl, ca({c}, {e}))'
        law(f'grow_{k}', '+hl: Nat', f'{R(f"ca({c}, {els[k - 1]})")} == {Pk(k, seq(k))} : D.Digest')
    # (round 12: d01/02, d01/03, d02/03) the cache of a NON-EMPTY list (as a decoder or the plain API hands it over): its fresh dirty window and
    # depth are those of the list, not of the empty one; 1 element, 2, and 3 (an odd count below a power of two) when the limit allows
    for k in sorted({1, min(2, Lm), min(3, Lm) if Lm >= 4 else 1}):
        law(f'nonempty_{k}', '+hl: Nat', f'{R(f"{T}_cache({seq(k)})")} == {Pk(k, seq(k))} : D.Digest')
    # (round 11: d03/04, d03/05, d04/03) a set after a root moves both ends of the dirty window, for every kind (the limit-1 list too): a set at
    # the lowest index and at the highest index of a clean tree of min(4, limit) elements; the value set differs from the one there. The
    # transactions list holds empty byte lists only (a non-empty one roots over 2^25 chunks, past the checker's time; a symbolic one leaves the
    # leaf pipeline stuck at different points on the two sides): its set laws state the dirty window itself, which must be exactly the set
    # slots (the window after a root is empty, (n, 0)); the root laws above show that the window is what gets rehashed
    k0 = min(4, Lm)
    base = seq(k0)
    clean = f'rc(hl, {T}_cache({base}))'

    def other(i):
        return b if els[i] == a else a

    def setlaw(tag, sets):
        c, s = clean, base
        for i in sets:
            c, s = f'cs({c}, {i}, {other(i)})', f'ss({s}, {i}, {other(i)})'
        if sym:
            law(tag, '+hl: Nat', f'win({c}) == ({sets[0]}, {sets[-1]}) : U32 & U32')
        else:
            law(tag, '+hl: Nat', f'{R(c)} == {P(s)} : D.Digest')
    for i in sorted({k0 - 1, 0}, reverse=True):
        setlaw(f'set_{i}', [i])
    if Lm >= N_MAX:
        # a clean tree of 3 elements (depth 2, room for 4), then an append that fits: the dirty range must reach the new slot (round 4: c01/05)
        law('app_clean', '+hl: Nat', f'{R(f"ca(rc(hl, {T}_cache({seq(3)})), {els[3]})")} == {P(seq(4))} : D.Digest')
        setlaw('set_1_3', [1, 3])
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
    if getter == 'ctake':
        # (round 8: d01/18) `_ctake` moves the element out of a CLEAN tree and must mark its slot dirty: the cached root afterwards is the root of
        # the list the plain `_take` leaves (the slot an absent box, a zero leaf for both); a ctake that keeps the dirty window answers the old leaf
        clean = f'rc(hl, {T}_cache({seq(k3)}))'
        for i in sorted({0, k3 - 1}):
            law(f'take_{i}', '+hl: Nat', f'{R(f"Pair.fst(CACHED, MAYBE, {T}_ctake({clean}, {i}))")} == {P(f"Pair.fst({T}_Seq, MAYBE, {T}_take({seq(k3)}, {i}))")} : D.Digest')
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
    if 'win(' in text:
        # the dirty window (lo, hi) of a cached tree (round 11: the set laws of the transactions list)
        body += (f'\n\ndef win(c: T.{kp}_Cached) -> U32 & U32:\n  match c:\n'
                 f'    case T.{kp}_Cached{{arr, +n, +d, nodes, +lo, +hi}}: (lo, hi)')
    text = text.replace('CACHED', f'T.{kp}_Cached').replace('MAYBE', f'Maybe<&1, {Eq}>')
    return '\n'.join(['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/digest.bend as D', 'import ../../src/obj.bend as O',
                      f'import ../../types/{tmod}.bend as T', '', writer.header('cached_list_roots'),
                      f'# {X}: the cached tree of {kp} agrees with the plain root (manual spec-mutation audit, round 3; docs/mutation_testing/MUTATION_PROOFS.md).', '', body, '', text, ''])


def outputs():
    out = {}
    missing = []
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
                missing.append(f'{kp}: no append, capp limit or owner')
                continue
            E = ap.group(1)
            ab = elements(tx, decls, E)
            st = schemas[runtime].get(E)
            if E == 'O.Words':
                # (round 8: d01/18) a byte-list element roots over a tree of 2^25 chunks (a unary Nat in the checker) unless it is empty: the
                # laws of the transactions list hold empty elements only (an empty list roots at once to the zero subtree; an absent box is the zero chunk)
                ab = ('O.words_new(0)', 'O.words_new(0)')
            es = st.fixed_size() if st is not None and st.kind == 'container' and st.fixed() else None
            if ab is None:
                missing.append(f'{kp}: no variant element ({E})')
                continue
            X = owners[0]
            Lm = int(lim.group(1))
            laws = laws_of(X, kp, E, Lm, ab, es, decls[E][0][0] if decls.get(E) else None, fold_of(tx, kp, E), 'cget' if f'{kp}_cget' in tx.blk else 'ctake',
                           sym=E == 'O.Words')
            # (round 11) the coverage gate also asks, for every kind, the growth laws up to 5 appends (one root after all, a root after each)
            # and the set-after-root laws at the lowest and the highest index
            tags = {tag for tag, _ in laws}
            k0 = min(N_MAX, Lm)
            need = {f'app_{min(APP_MAX, Lm)}', f'grow_{min(GROW_MAX, Lm)}', 'set_0', f'set_{k0 - 1}', 'nonempty_1', f'nonempty_{min(2, Lm)}'}
            if not need <= tags:
                missing.append(f'{kp}: no {", ".join(sorted(need - tags))}')
            for tag, text in laws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_vroot_{kp}_cache_{tag}')] = module(tmod, X, kp, E, text)
    if missing:
        # the coverage gate (round 8: d01/14, d01/15, the l10 and transactions trees had none): every list kind with a cached tree has its laws
        raise SystemExit('cached_list_roots: cached list kinds without laws: ' + '; '.join(missing))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'cached_list_roots', ('validity',), 'stale cached list root laws: ', 'cached list root laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
