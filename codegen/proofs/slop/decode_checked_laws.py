#!/usr/bin/env python3
"""The checked decoder `X_decode_checked(buf, size)` refuses a window the buffer does not hold, for every type (manual spec-mutation audit, round 3: d01).

    python3 codegen/proofs/slop/decode_checked_laws.py [--check]

Public counterexample: `T.uint256_decode_checked(O.Buf{one word, 32 bytes claimed}, 32)` answering a value read from storage that is not there
(the storage test dropped, or compared with the byte size, or taken from the buffer's size field instead of its storage); a window equal to the buffer
size refused. `X_decode_checked(buf, size)` is `X_dchk(size, B.size(buf))`, which asks `B.stored(buf)` for the storage words c and calls
`X_dchw(size, n, (buf, c))`: the window is inside the buffer (size <= n), at most NMAX = 4294967264 bytes (the size limit; it was below 2^31
before), and the storage holds ceil(size / 4) words; only then it decodes.
Only Checkpoint and proglist_uint8 had laws on it (docs/CRASH_HUNT.md CH-05, CH-06).

For every name X with a checked decoder, proofs/slop/validity/<runtime>_<X>_decode_checked_generated.bend holds. W is the default value of X as bytes (fixed
parts zero, variable parts empty, offsets at the end of the fixed part; up to 2048 bytes), S its length, V the value type of X:

  <X>_decode_vchecked_limit     X_dchw(NMAX + 1, NMAX + 1, (B.empty(), 2^30)) is None: one byte past NMAX, with storage for it
  <X>_decode_vchecked_nmax_above  X_dchw(NMAX + 1, 2^32 - 1, (buf, 2^30)) is None for every buffer: past NMAX inside a larger buffer
  <X>_decode_vchecked_nmax_wrap   X_dchw(2^32 - 1, 2^32 - 1, (buf, 0)) is None for every buffer: the largest U32 window (ceil(size / 4) wraps)
  <X>_decode_vchecked_nmax_at / _at_2pow31 (buf)      X_dchw(S, S, (buf, ceil(S / 4))) == X_dgo(True, buf, S) at S = NMAX and at S = 2^31: the guard lets the window
                                                      through (round 7 G1; every name: for a bounded name its decoder refuses such a window itself, the law pins the guard)
  with W (every fixed type up to 2048 bytes, every list, bit list, container and union whose default encodes that way):
  <X>_decode_vchecked_accept    the window W with the buffer size S and ceil(S / 4) words of storage is decoded, by X_dchw and by X_decode_checked
  <X>_decode_vchecked_window    a buffer one byte smaller than the window (size field S - 1): None
  <X>_decode_vchecked_storage   one word less than ceil(S / 4): None (a partial last word is storage too: floor instead of ceil is caught when 4 does not divide S)
  <X>_decode_vchecked_short     X_decode_checked of a buffer whose array holds W but whose size field is S - 1: None
  <X>_decode_vchecked_real      (S > 4) X_decode_checked of a one-word array claiming S bytes: None (the storage is counted from the array, not from the size field)
  without W (a type with no such default): window X_dchw(5, 4, ..), storage X_dchw(8, 8, (B.empty(), 1)), real X_decode_checked(Buf{one word, 8}, 8), all None.
  (manual audit round 14, a02/25, a02/05; S the size of a valid encoding: the fixed size, the default's size, or a list of one default element)
  <X>_decode_vchecked_storage_size (buf)  every name: X_dchw(S, S, (buf, ceil(S / 4) - 1)) == (buf, None): the storage test at the type's own size
                                    (the old storage law without W used B.empty(), whose claimed size 0 the window test refuses by itself)
  <X>_decode_vchecked_accept_size (buf)   without W: X_dchw(S, S, (buf, ceil(S / 4))) == X_dgo(True, buf, S)
  <X>_decode_vchecked_empty         every list, byte list and progressive list: the empty input decodes, by X_decode and X_decode_checked, to
                                    Some value of length 0 (<p>_len, p the list's validator prefix)
  The generator stops when a name has no valid size or a list has no length function; the api gate requires storage_size (and empty) per name.
The decode budget (docs/DECODE_AMPLIFICATION.md), X_decode_checked_budget(buf, size, budget):
  <X>_decode_vchecked_budget_cost    X_dcost(4096) is ((4096 >> 3) + 1) * K + 524288 (K the name's heap bytes per input byte, codegen/decode_cost.json)
  <X>_decode_vchecked_budget_refuse  X_dcost(size) saturated (2^32 - 1) or above the budget: (buf, None), for every buffer, size and budget
  <X>_decode_vchecked_budget_agree   X_dcost(size) < 2^32 - 1 and <= budget: X_decode_checked(buf, size), for every buffer, size and budget
  <X>_decode_vchecked_budget_saturated  (K >= 8) the bound of NMAX bytes saturates: refused with the budget 2^32 - 1 (docs/CRASH_HUNT.md R6-01)
  <X>_decode_vchecked_budget_cost_<size>  (K > 0) X_dcost at 858980000, 2^31, NMAX and, for K >= 8, the first saturated size and the one
                                     below it, as literals (manual audit round 7, r7-d01: the saturation guard and the wrap of the product)
  <X>_decode_vchecked_budget_covers_<Y>  U32.is_le(Y_dk(), X_dk()): X's K covers that of every name Y nested in it (aliases included)
  <X>_decode_vchecked_budget_zero    a budget of 0 refuses (every bound is at least the constant 524288)
  <X>_decode_vchecked_budget_accept  (with W) the budget 2^32 - 1 decodes W, as X_decode_checked does

By computation; filed by api_gate under decode_offsets (the `_decode_vchecked_` form). The generator stops when a checked decoder does not have the expected
shape, so that a change of the definition cannot silently drop the laws.
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
from codegen.impl.typed_object_runtime import decode_cost_k  # noqa: E402

DCHW = re.compile(r'^def (\w+)_dchw\(\+size: U32, \+n: U32, pair: B\.Buf & U32\) -> B\.Buf & Maybe<&1, ([\w.]+)>:\n'
                  r'  \(buf, \+c\) = pair\n'
                  r'  \w+_dgo\(Bool\.and\(Bool\.and\(U32\.is_le\(size, n\), U32\.is_le\(size, 4294967264\)\), U32\.is_le\(U32\.shrn\(\(size \+ 3 : U32\), 2n\), c\)\), buf, size\)$', re.M)
CHECKED = re.compile(r'^def (\w+)_decode_checked\(buf: B\.Buf, \+size: U32\) -> B\.Buf & Maybe<&1, [\w.]+>: \w+_dchk\(size, B\.size\(buf\)\)$', re.M)
DCHK = re.compile(r'^def (\w+)_dchk\(\+size: U32, pair: B\.Buf & U32\) -> B\.Buf & Maybe<&1, [\w.]+>:\n  \(buf, \+n\) = pair\n  \w+_dchw\(size, n, B\.stored\(buf\)\)$', re.M)



def canon(t):
    """the structure of a schema type, names and aliases dropped (an alias field such as BlobSidecar.blob has no name)"""
    if t is None:
        return None
    return (t.kind, t.size, canon(t.elem), tuple((f, canon(ft)) for f, ft in t.fields), t.active, t.selectors)


def nested(t):
    """every type strictly inside t"""
    out = []
    for _, ft in t.fields:
        out.append(ft)
        out += nested(ft)
    if t.elem is not None:
        out.append(t.elem)
        out += nested(t.elem)
    return out


def nested_k_violations(types, ks):
    """[(name, its K, nested name, its K)] where a name nested in another (by structure, aliases included) charges more than it"""
    by = {}
    for n, t in types.items():
        by.setdefault(canon(t), []).append(n)
    bad = []
    for n, t in types.items():
        for sub in nested(t):
            for m in by.get(canon(sub), []):
                if m != n and ks[m] > ks[n]:
                    bad.append((n, ks[n], m, ks[m]))
    return sorted(set(bad))


def dcost_val(size, k):
    """O.dcost(size, k) (src/obj.bend), for the literal laws"""
    if k == 0:
        return 524288
    w = (size >> 3) + 1
    return w * k + 524288 if w <= 4294443007 // k else 4294967295


NESTED = {}   # name -> the names with K > 0 nested in it (by structure), filled by outputs()

def enc0(t, depth=0):
    """the bytes of the default value of the schema type t (fixed parts zero, variable parts empty, offsets pointing at the end of the fixed part), or None"""
    if t is None or depth > 6:
        return None
    k = t.kind
    if t.fixed():
        return bytes(t.fixed_size())
    if k in ('list', 'bytelist', 'plist'):
        return b''
    if k in ('bitlist', 'pbits'):
        return b'\x01'
    if k in ('container', 'pcontainer', 'vector'):
        kids = [c for _, c in t.fields] if k != 'vector' else [t.elem] * t.size
        if len(kids) > 64:
            return None
        parts = [None if c.fixed() else enc0(c, depth + 1) for c in kids]
        if any(p is None and not c.fixed() for p, c in zip(parts, kids)):
            return None
        head = sum(c.fixed_size() if c.fixed() else 4 for c in kids)
        fixed, var = b'', b''
        for p, c in zip(parts, kids):
            if c.fixed():
                fixed += bytes(c.fixed_size())
            else:
                fixed += (head + len(var)).to_bytes(4, 'little')
                var += p
        return fixed + var
    if k == 'cunion' and t.fields and t.selectors:
        arm = enc0(t.fields[0][1], depth + 1)
        return None if arm is None else bytes([t.selectors[0]]) + arm
    return None


def window_of(t):
    """the bytes of a valid window of the type (at most 2048 bytes: it is decoded concretely), or None"""
    b = enc0(t)
    return b if b is not None and 1 <= len(b) <= 2048 else None


def valid_size(t):
    """the size S >= 1 of a valid encoding of the type (manual audit round 14, a02/25): a fixed type's own size, the default encoding's
    size when it is not empty, for a list whose default is empty the size of a list of one default element; None when none is known"""
    if t is None:
        return None
    if t.fixed():
        return t.fixed_size()
    b = enc0(t)
    if b:
        return len(b)
    if t.kind == 'bytelist' and t.size >= 1:
        return 1
    if t.kind in ('list', 'plist') and (t.kind == 'plist' or t.size >= 1):
        if t.elem.fixed():
            return t.elem.fixed_size()
        e = enc0(t.elem)
        return None if e is None else 4 + len(e)
    return None


def empty_valid(t):
    """the empty encoding is a valid value of the type (a list, byte list or progressive list at top level: the empty list)"""
    return t is not None and t.kind in ('list', 'bytelist', 'plist')


DECIN = re.compile(r'^def (\w+)_decode_in\(buf: B\.Buf, \+size: U32\)[^\n]*\n  \w+\(size, (\w+)_ok\(buf, 0, size\)\)', re.M)


def buffer(data, size=None):
    n = len(data) if size is None else size
    words = (len(data) + 3) // 4
    d = 0
    while (1 << d) < max(1, words):
        d += 1
    arr = f'Array.new(U32, {d}n, 0)'
    for i in range(words):
        w = int.from_bytes(data[4 * i:4 * i + 4].ljust(4, b'\0'), 'little')
        if w:
            arr = f'Array.set(U32, {arr}, {i}, {w})'
    return f'B.Buf{{{arr}, {n}}}'


def laws_of(X, V, win, S, lenp=None):
    val = V if V.startswith('O.') or V in ('U32', 'Bool') else f'T.{V}'
    M = f'Maybe<&1, {val}>'
    snd = lambda c: f'Pair.snd(B.Buf, {M}, {c})'    # noqa: E731
    out = []

    def law(tag, stmt):
        out.append(f'def {X}_decode_vchecked_{tag}()\n    -> {{{stmt}}}:\n  {{==}}')
    law('limit', f'{snd(f"T.{X}_dchw(4294967265, 4294967265, (B.empty(), 1073741824))")} == None{{}} : {M}')
    # above NMAX whatever the validator would say: the buffer is a variable, so only the refusal itself reduces (a decode of a symbolic buffer is stuck);
    # 2^32 - 1 is the size whose storage need (size + 3) >> 2 wraps to 0, NMAX + 1 the first size above the limit (round 4: a14)
    for tag, size, c in (('nmax_wrap', 4294967295, 0), ('nmax_above', 4294967265, 1073741824)):
        out.append(f'def {X}_decode_vchecked_{tag}(buf: B.Buf)\n    -> {{T.{X}_dchw({size}, 4294967295, (buf, {c})) == (buf, None{{}}) : B.Buf & {M}}}:\n  {{==}}')
    # and accepted up to NMAX (round 7 G1): at NMAX and at 2^31 the guard lets the window through to the decoder, whatever the buffer (both sides reduce
    # to the same decode of the symbolic buffer); a decoder whose cap went back to 2^31, or to any value below NMAX, fails these
    for tag, size, c in (('nmax_at', 4294967264, 1073741816), ('at_2pow31', 2147483648, 536870912)):
        out.append(f'def {X}_decode_vchecked_{tag}(buf: B.Buf)\n    -> {{T.{X}_dchw({size}, {size}, (buf, {c})) == T.{X}_dgo(True{{}}, buf, {size}) : B.Buf & {M}}}:\n  {{==}}')
    if win is None:
        # no known valid window: only what is refused whatever the type decodes
        law('window', f'{snd(f"T.{X}_dchw(5, 4, (B.empty(), 8))")} == None{{}} : {M}')
        law('storage', f'{snd(f"T.{X}_dchw(8, 8, (B.empty(), 1))")} == None{{}} : {M}')
        law('real', f'{snd(f"T.{X}_decode_checked(B.Buf{{Array.new(U32, 0n, 0), 8}}, 8)")} == None{{}} : {M}')
    else:
        s = len(win)
        words = (s + 3) // 4
        buf = buffer(win)
        some = f'is_some({snd(f"T.{X}_dchw({s}, {s}, ({buf}, {words}))")}, {snd(f"T.{X}_decode_checked({buf}, {s})")})'
        law('accept', f'{some} == (True{{}}, True{{}}) : Bool & Bool')
        law('window', f'{snd(f"T.{X}_dchw({s}, {s - 1}, ({buf}, {words}))")} == None{{}} : {M}')
        law('storage', f'{snd(f"T.{X}_dchw({s}, {s}, ({buf}, {words - 1}))")} == None{{}} : {M}')
        law('short', f'{snd(f"T.{X}_decode_checked({buffer(win, s - 1)}, {s})")} == None{{}} : {M}')
        if s > 4:
            law('real', f'{snd(f"T.{X}_decode_checked({buffer(win[:4], s)}, {s})")} == None{{}} : {M}')
    # (manual audit round 14, a02/25) the storage test at the type's own valid size S, for every name: a buffer that claims S bytes but stores one
    # word fewer than ceil(S / 4) is refused by the guard itself (the buffer is a variable, so a weakened storage test leaves a stuck decode, not
    # None); without W the matching acceptance at exactly ceil(S / 4) words (with W, `accept` pins it on the literal)
    w = (S + 3) // 4
    out.append(f'def {X}_decode_vchecked_storage_size(buf: B.Buf)\n    -> {{T.{X}_dchw({S}, {S}, (buf, {w - 1})) == (buf, None{{}}) : B.Buf & {M}}}:\n  {{==}}')
    if win is None:
        out.append(f'def {X}_decode_vchecked_accept_size(buf: B.Buf)\n    -> {{T.{X}_dchw({S}, {S}, (buf, {w})) == T.{X}_dgo(True{{}}, buf, {S}) : B.Buf & {M}}}:\n  {{==}}')
    if lenp is not None:
        # (manual audit round 14, a02/05) the empty input is the empty list: Some, of length 0, by the decoder and by the checked decoder
        law('empty', f'(lenof({snd(f"T.{X}_decode(B.empty(), 0)")}), lenof({snd(f"T.{X}_decode_checked(B.empty(), 0)")})) == (0, 0) : U32 & U32')
    # the decode budget (docs/DECODE_AMPLIFICATION.md): a size whose cost bound is above the budget is refused, any other is the checked decode
    k = decode_cost_k(X)
    ex = 4096
    cost = ((ex >> 3) + 1) * k + 524288 if k else 524288
    out.append(f'def {X}_decode_vchecked_budget_cost()\n    -> {{T.{X}_dcost({ex}) == {cost} : U32}}:\n  {{==}}')
    G = f'Bool.and(U32.is_lt(T.{X}_dcost(size), 4294967295), U32.is_le(T.{X}_dcost(size), budget))'
    for tag, bv, rhs in (('refuse', 'False{}', '(buf, None{})'), ('agree', 'True{}', f'T.{X}_decode_checked(buf, size)')):
        out.append(f'def {X}_decode_vchecked_budget_{tag}(buf: B.Buf, +size: U32, +budget: U32, +h: {{{G} == {bv} : Bool}})\n'
                   f'    -> {{T.{X}_decode_checked_budget(buf, size, budget) == {rhs} : B.Buf & {M}}}:\n'
                   f'  %Equal.sym(Bool, {G}, {bv}, h) : {{T.{X}_dcb(_, buf, size) == {rhs} : B.Buf & {M}}}\n  {{==}}')
    if k:
        # the bound's arithmetic pinned at literal sizes (manual audit round 7, r7-d01): large sizes, NMAX, and for K >= 8 the first size whose
        # bound does not fit 32 bits (saturated) and the size just below it (the largest bound that fits)
        pts = [858980000, 2147483648, 4294967264]
        if k >= 8:
            edge = (4294443007 // k) * 8
            pts += [edge - 8, edge]
        for sz in pts:
            out.append(f'def {X}_decode_vchecked_budget_cost_{sz}()\n    -> {{T.{X}_dcost({sz}) == {dcost_val(sz, k)} : U32}}:\n  {{==}}')
        # K covers every name nested in X (aliases included, docs/CRASH_HUNT.md R6-04), on the generated constants
        for m in NESTED.get(X, ()):
            out.append(f'def {X}_decode_vchecked_budget_covers_{m}()\n    -> {{U32.is_le(T.{m}_dk(), T.{X}_dk()) == True{{}} : Bool}}:\n  {{==}}')
    if k >= 8:
        # the bound of the largest size saturates: refused even with the largest budget (docs/CRASH_HUNT.md R6-01)
        law('budget_saturated', f'{snd(f"T.{X}_decode_checked_budget(B.empty(), 4294967264, 4294967295)")} == None{{}} : {M}')
    law('budget_zero', f'{snd(f"T.{X}_decode_checked_budget(B.empty(), 8, 0)")} == None{{}} : {M}')
    if win is not None:
        s_ = len(win)
        law('budget_accept', f'is_some({snd(f"T.{X}_decode_checked_budget({buffer(win)}, {s_}, 4294967295)")}, {snd(f"T.{X}_decode_checked({buffer(win)}, {s_})")}) == (True{{}}, True{{}}) : Bool & Bool')
    helper = (f'def some1(m: {M}) -> Bool:\n  match m:\n    case Some{{v}}: True{{}}\n    case None{{}}: False{{}}\n\n'
              f'def is_some(a: {M}, b: {M}) -> Bool & Bool: (some1(a), some1(b))\n')
    if lenp is not None:
        helper += (f'\ndef lenof(m: {M}) -> U32:\n  match m:\n    case Some{{v}}: Pair.snd({val}, U32, T.{lenp}_len(v))\n'
                   f'    case None{{}}: 4294967295\n')
    return helper, out


def module(tmod, X, helper, laws):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('decode_checked_laws'),
         f'# {X}: the checked decoder refuses a window the buffer does not hold (manual spec-mutation audit, round 3; docs/mutation_testing/MUTATION_PROOFS.md).', '', helper]
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    # the decode budget's K covers every nested name (docs/DECODE_AMPLIFICATION.md, docs/CRASH_HUNT.md R6-04)
    for names in (fu, gen):
        known = {n: t for n, t in names.items() if t is not None}
        ks = {}
        for n in known:
            try:
                ks[n] = decode_cost_k(n)
            except KeyError:
                pass
        bad = nested_k_violations({n: known[n] for n in ks}, ks)
        by = {}
        for n in ks:
            by.setdefault(canon(known[n]), []).append(n)
        for n in ks:
            NESTED[n] = sorted({m for sub in nested(known[n]) for m in by.get(canon(sub), []) if m != n and ks[m] > 0})
        if bad:
            raise SystemExit(f'decode_checked_laws: a name charges less than a name nested in it (codegen/decode_cost.json): {bad[:5]}')
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        want = {m.group(1) for m in CHECKED.finditer(tx.text)}
        have = {m.group(1): m.group(2) for m in DCHW.finditer(tx.text)}
        chk = {m.group(1) for m in DCHK.finditer(tx.text)}
        bad = sorted(want - set(have) | want - chk)
        if bad or len(re.findall(r'^def \w+_decode_checked\(', tx.text, re.M)) != len(want):
            raise SystemExit(f'decode_checked_laws: the checked decoder of {bad[:5] or "some name"} does not have the expected shape')
        prefix = {m.group(1): m.group(2) for m in DECIN.finditer(tx.text)}
        nosize = sorted(X for X in want if valid_size(names.get(X)) is None or valid_size(names.get(X)) > 4294967264)
        if nosize:
            raise SystemExit(f'decode_checked_laws: no valid size known for the storage law of {nosize[:5]} (round 14: every checked decoder has one)')
        nolen = sorted(X for X in want if empty_valid(names.get(X)) and not re.search(rf'^def {prefix.get(X, "?")}_len\(o: ', tx.text, re.M))
        if nolen:
            raise SystemExit(f'decode_checked_laws: no length function for the empty-decode law of {nolen[:5]}')
        for X in sorted(want):
            t = names.get(X)
            helper, laws = laws_of(X, have[X], window_of(t), valid_size(t), prefix[X] if empty_valid(t) else None)
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_decode_checked')] = module(tmod, X, helper, laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'decode_checked_laws', ('validity',), 'stale decode_checked laws: ', 'decode_checked laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
