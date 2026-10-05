#!/usr/bin/env python3
"""The boundary of the append guard of every collection (manual spec-mutation audit, round 3: g01).

    python3 codegen/proofs/slop/append_guard_bounds.py [--check]

Public counterexample: `T.proglist_uint32_append(l, v)` on a list of 1073741815 elements accepted or refused by a guard that is off by one (`n < 1073741817`
for `n < 1073741816`), a list of 2^32 - 2 bits refused, a list of 4095 cells refused, an append to a full storage accepted: the round-2 laws test one count far
above or below the guard, so a constant that is off by one survived. Since crash-fix 3 every guard is `n < min(N, bound)` AND the storage holds n elements
(`ceil(n * U / 4) <= storage words`, or `n <= array size`): `X_app_c` / `X_app_sz` / `X_capp_sz` / `X_app_w`.

For every collection p with such a guard (packed lists of U32, U64, Bool, Bytes32, Bytes48, Uint128, Uint256 elements; bit lists; lists of composites held
as arrays, plain and cached; the cell list) and for every container X that owns it, proofs/slop/validity/<runtime>_<X>_appb_<p>_generated.bend holds, on
objects whose storage is an array of 2^d slots (`Array.new` builds it lazily: a list of 2^30 elements costs nothing to state), the flag of the append:

  <X>_serialize_vcoll_<p>_appb_below    count G - 1 (storage holds it with room)          accepted
  <X>_serialize_vcoll_<p>_appb_at       count G (the guard's bound)                        refused
  <X>_serialize_vcoll_<p>_appb_above    count G + 1 (when it still fits the type)          refused
  <X>_serialize_vcoll_<p>_appb_fit      the storage holds exactly the count                accepted (the storage test is `<=`)
  <X>_serialize_vcoll_<p>_appb_short    one more than the storage holds                    refused (the storage test exists, and counts words, not bytes)

  <X>_serialize_vcoll_<p>_appb_at_sz / _below_sz  (a list of composites whose bound G is 2^32 - 1: no array of 2^32 slots exists) the guard step
                                                   `p_app_sz(n, v, (storage, G))` at n = G refused, at n = G - 1 accepted

where G is the bound printed in the guard (`U32.is_lt(n, G)`). Filed by api_gate under serialize_valid (the `vcoll_` form).
Round 13 (p01/03, 04, 06, 07): every progressive list kind has these laws. An element type whose default is not `<T>_default` (Uint128's
`u128_default`, the inner list's `pl_VarTestStruct_default`) uses the type's one zero-argument default, and a collection that is only an element of
another collection (proglist_VarTestStruct) is filed under the owners of the collection that holds it.
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

U32_MAX = 1 << 32
PACKED = re.compile(r'^def (\w+)_app_c\(\+v: ([\w.]+), \+n: U32, pair: O\.Words & U32\) -> O\.Words & Bool:', re.M)
BITS = re.compile(r'^def (\w+)_app_c\(v: Bool, \+n: U32, pair: O\.Bits & U32\) -> O\.Bits & Bool:', re.M)
CELLS = re.compile(r'^def (\w+)_app_w\(o: O\.Words, \+n: U32, \+sc: U32, \+vn: U32, pair: Array<U32> & U32\) -> O\.Words & Bool:', re.M)
SEQ = re.compile(r'^def (\w+)_app_sz\(\+n: U32, v: ([\w.]+), pair: [^\n]*\) -> \w+_Seq & Bool:', re.M)
CACHED = re.compile(r'^def (\w+)_capp_sz\(\+n: U32, \+d: Nat,', re.M)


def bound(text):
    m = re.search(r'U32\.is_lt\(n, (\d+)\)', text)
    return int(m.group(1)) if m else None


def depth(slots):
    """d with 2^d >= slots"""
    return max(0, (max(1, slots) - 1).bit_length())


def element(tx, ty):
    """a valid element of the element type of a packed list, or None"""
    simple = {'U32': '0', 'Bool': 'False{}', 'O.U64': 'O.U64{0, 0}'}
    if ty in simple:
        return simple[ty]
    name = ty.split('.')[-1].split('_d.')[-1]
    if f'{name}_default' in tx.blk:
        return f'T.{name}_default()'
    d = default_of(tx, name)
    return f'T.{d}()' if d else None


def default_of(tx, name):
    """(round 13: p01/03, 04) the runtime's default of the type `name` when it is not `<name>_default` (Uint128: `u128_default`,
    pl_VarTestStruct_Seq: `pl_VarTestStruct_default`): the one zero-argument `*_default` definition returning that type"""
    found = sorted(set(re.findall(rf'^def (\w+_default)\(\) -> (?:\w+\.)?{re.escape(name)}:', tx.text, re.M)))
    return found[0] if len(found) == 1 else None


class Laws:
    def __init__(self, X, p):
        self.X, self.p, self.out = X, p, []

    def add(self, tag, call, want):
        self.out.append(f'def {self.X}_serialize_vcoll_{self.p}_appb_{tag}()\n    -> {{{call} == {want}{{}} : Bool}}:\n  {{==}}')


def packed_laws(tx, X, p, ty):
    blk = tx.blk[f'{p}_app_c']
    G = bound(blk)
    mu = re.search(r'\(n \* (\d+) : U32\)', blk)
    v = element(tx, ty)
    if G is None or not mu or v is None:
        return None
    U = int(mu.group(1))
    L = Laws(X, p)

    def flag(n, log=None):
        # the storage: 2^d words, the room `words_fit` wants for one more element, so that nothing is copied
        words = ((n + 1) * U + 31) // 32 * 8 + 8
        arr = f'Array.new(U32, {depth(words) if log is None else log}n, 0)'
        return f'Pair.snd(O.Words, Bool, T.{p}_append(O.Words{{{arr}, {n * U}}}, {v}))'
    for tag, n, want in (('below', G - 1, 'True'), ('at', G, 'False'), ('above', G + 1, 'False')):
        # (round 13: p01/04) a refused count whose size n * U still fits is stated even when (n + 1) * U wraps (proglist_uint256 at
        # n = 134217727: a guard `n <= G` would accept it and the grown size wrap to 0)
        if n >= 0 and ((n + 1) * U < U32_MAX or (want == 'False' and n * U < U32_MAX)):
            L.add(tag, flag(n), want)
    fit = 32 // U
    if 1 <= fit < G:
        L.add('fit', flag(fit, 3), 'True')
        L.add('short', flag(fit + 1, 3), 'False')
    return L.out


def bits_laws(tx, X, p):
    G = bound(tx.blk[f'{p}_app_c'])
    if G is None:
        return None
    L = Laws(X, p)

    def flag(n, log=None):
        arr = f'Array.new(U32, {depth(n // 32 + 16) if log is None else log}n, 0)'
        return f'Pair.snd(O.Bits, Bool, T.{p}_append(O.Bits{{{arr}, {n}}}, True{{}}))'
    for tag, n, want in (('below', G - 1, 'True'), ('at', G, 'False'), ('above', G + 1, 'False')):
        if 0 <= n < U32_MAX:
            L.add(tag, flag(n), want)
    if G > 33:
        L.add('fit', flag(32, 0), 'True')
        L.add('short', flag(33, 0), 'False')
    return L.out


def cells_laws(tx, X, p):
    G = bound(tx.blk[f'{p}_app_w'])
    if G is None:
        return None
    L = Laws(X, p)
    cell = 'O.words_new(2048)'

    def flag(n, log=None):
        arr = f'Array.new(U32, {depth((n + 1) * 512 + 64) if log is None else log}n, 0)'
        return f'Pair.snd(O.Words, Bool, T.{p}_append(O.Words{{{arr}, {n * 2048}}}, {cell}))'
    for tag, n, want in (('below', G - 1, 'True'), ('at', G, 'False'), ('above', G + 1, 'False')):
        L.add(tag, flag(n), want)
    L.add('short', flag(1, 0), 'False')
    return L.out


def seq_laws(tx, X, p, ty, cached):
    blk = tx.blk[f'{p}_capp_sz' if cached else f'{p}_app_sz']
    G = bound(blk)
    name = ty.split('.')[-1].split('_d.')[-1]
    if G is None or element(tx, name) is None or f'{p}_fill' not in tx.blk:
        return None
    L = Laws(X, p)
    v = element(tx, ty)
    if v is None:
        return None
    seq = f'T.{p}_Seq'
    cc = f'T.{p}_Cached'

    def flag(n, slots):
        d = depth(slots)
        if cached:
            return f'Pair.snd({cc}, Bool, T.{p}_capp({cc}{{T.{p}_fill({d}n), {n}, {depth(n + 1)}n, T.{p}_dfill({depth(n + 1) + 1}n), 0, 0}}, {v}))'
        return f'Pair.snd({seq}, Bool, T.{p}_append({seq}{{T.{p}_fill({d}n), {n}}}, {v}))'
    for tag, n, want in (('below', G - 1, 'True'), ('at', G, 'False'), ('above', G + 1, 'False')):
        if 0 <= n < U32_MAX - 1 and (want == 'False' or n < (1 << 31)):     # an array of 2^32 slots has no U32 size: the bound below it cannot be held
            L.add(tag, flag(n, n + 2), want)
    if not cached and not 0 <= G < U32_MAX - 1:
        # (round 13: p01/06, 07) the guard's bound is 2^32 - 1: no array holds that many slots, so the guard's step `_app_sz` is asked
        # directly with storage claiming G slots: the count G is refused by the bound alone (a guard `n <= G` accepts it)
        L.add('at_sz', f'Pair.snd({seq}, Bool, T.{p}_app_sz({G}, {v}, (T.{p}_fill(0n), {G})))', 'False')
        L.add('below_sz', f'Pair.snd({seq}, Bool, T.{p}_app_sz({G - 1}, {v}, (T.{p}_fill(0n), {G})))', 'True')
    if G >= 6:      # the storage cases need counts below the limit
        L.add('fit', flag(3, 4), 'True')
        L.add('short', flag(5, 4), 'False')
    return L.out


def nested_owners(tx, p, prefixes):
    """(round 13: p01/06) a collection no API name's encoder calls directly (proglist_VarTestStruct, only an element of proglist_proglist_VarTestStruct):
    the owners of the collections whose definitions call it"""
    pat = re.compile(rf'\b{re.escape(p)}_[a-z]\w*\(')
    out = set()
    for q in prefixes:
        if q != p and any(n.startswith(q + '_') and not n.startswith(p + '_') and pat.search(b) for n, b in tx.blk.items()):
            out.update(owners_of(tx, q))
    return sorted(out)


def module(tmod, X, p, laws):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('append_guard_bounds'),
         f'# {X}: the boundary of the append guard of {p} (manual spec-mutation audit, round 3; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        found = []
        for m in PACKED.finditer(tx.text):
            found.append((m.group(1), lambda X, p=m.group(1), ty=m.group(2): packed_laws(tx, X, p, ty)))
        for m in BITS.finditer(tx.text):
            found.append((m.group(1), lambda X, p=m.group(1): bits_laws(tx, X, p)))
        for m in CELLS.finditer(tx.text):
            found.append((m.group(1), lambda X, p=m.group(1): cells_laws(tx, X, p)))
        for m in SEQ.finditer(tx.text):
            found.append((m.group(1), lambda X, p=m.group(1), ty=m.group(2): seq_laws(tx, X, p, ty, False)))
        for m in CACHED.finditer(tx.text):
            ty = re.search(rf'^def {re.escape(m.group(1))}_capp\(c: \w+, v: ([\w.]+)\)', tx.text, re.M)
            if ty:
                found.append((m.group(1) + '#c', lambda X, p=m.group(1), t=ty.group(1): seq_laws(tx, X, p, t, True)))
        prefixes = sorted({key.split('#')[0] for key, _ in found}, key=len, reverse=True)
        for key, build in found:
            p = key.split('#')[0]
            for X in owners_of(tx, p) or nested_owners(tx, p, prefixes):
                laws = build(X)
                if laws:
                    suffix = '_c' if key.endswith('#c') else ''
                    out[LAYOUT.module_path('validity', f'{runtime}_{X}_appb_{p}{suffix}')] = module(tmod, X, p + suffix, laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'append_guard_bounds', ('validity',), 'stale append guard bound laws: ', 'append guard bound laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
