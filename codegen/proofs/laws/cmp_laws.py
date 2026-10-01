#!/usr/bin/env python3
"""Equivalence laws for the aligned-or-slow path choice of the word-vector writers, found by mutation testing
(`U32.is_eq((pos .&. 3), 0)` changed to `is_lt` / `is_le` / `is_ne` / `is_ge` ... in `X_put`).

    python3 codegen/proofs/laws/cmp_laws.py [--check]

`P_put(out, pos, Words{ws, n})` of a word-stored vector picks, by `pos .&. 3 == 0`, between two writers of the same
words: the unrolled aligned one (`P_pa0 .. P_paK`, a chain of single-word stores) and the general `O.put_words`.
They agree on every aligned position (the choice is a speed-up), so a guard that always takes the general writer
(`is_lt(x, 0)` is never true; `is_le(x, 0)` is `is_eq` on unsigned words) cannot change the result there; at an
unaligned position the original already takes `O.put_words`, and a guard that takes the aligned one is wrong.

proofs/obj/zcmpeq_<X>.bend (one module per name) holds, for every name whose put has that guard:

  <X>_cmp_a<q> / <X>_cmp_u<p>   : {T.P_put(O.out_at(D), p, O.Words{WS, N}) == T.P_pw(False{}, O.out_at(D), p, WS, N)}
      for a variable word list WS (N bytes: every word a variable) and a fresh output buffer of 2^D words, 2^D = twice
      the encoder's allocation. P_pw(False{}, ..) is the general writer with no guard: the left side is the writer
      the guard picks, the right the one it must agree with. For the aligned positions p = 4q (q = 0..3 and the last with q + words <= 2^D)
      the statement says the two writers store the same words (the aligned chain against the general writer), and the
      mutants that always take the general writer are exactly this statement; for p = 5, 6, 7 it says the guard sends
      an unaligned position to the general writer, which kills a guard that sends it to the aligned chain.
      By computation (`{==}`).

Not a proof for every position: the general writer's index arithmetic is `((q + n) - n)`-shaped, which the checker
does not fold for a symbolic q, so the positions are literals: q = 0, 1, 2, 3 and the last that fits (all of them
cost 70 to 100 s per name for the 64-word vectors). Every encoder of a name calls its put at position 0 of the buffer it
allocates, and a container at its schema offsets; the equivalence at other positions is argued, not checked.

Named so that api_gate files them under encode_eval; the module is zcmpeq_ so that it sorts after the name's own
proving files (a facade's first proving import must stay the spec/encx file).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402


def log2ceil(w):
    k = 0
    while (1 << k) < w:
        k += 1
    return k


def name_laws(runtime):
    text = RR.mono_text(runtime)
    out = {}
    for m in re.finditer(r'^def (\w+)_encode\(o: O\.Words\) -> [^\n:]*: \w+_enc_(?:out|put)\((\w+)_put\(O\.out_at\((\d+)n\), 0, o\)\)$', text, re.M):
        X, P, d = m.group(1), m.group(2), int(m.group(3))
        pm = re.search(rf'^def {P}_put\(out: Array<U32>, \+pos: U32, o: O\.Words\) -> Array<U32> & O\.Words:\n  match o:\n    case O\.Words\{{ws, \+n\}}: {P}_pw\(U32\.is_eq\(\(pos \.&\. 3 : U32\), 0\), out, pos, ws, n\)$', text, re.M)
        pas = sorted(int(x) for x in re.findall(rf'^def {P}_pa(\d+)\(', text, re.M))
        mv = re.search(rf'^def {P}_valid\(o: O\.Words\) -> [^\n:]*: O\.words_ok\(o, (\d+), (\d+), False\{{\}}, \d+\)$', text, re.M)
        if not (pm and pas and pas == list(range(len(pas))) and mv and mv.group(1) == mv.group(2)):
            continue
        nw, N = len(pas), int(mv.group(1))
        D = d + 1
        k = log2ceil(nw)
        xs = [f'x{i}' for i in range(nw)]
        ws = f'O.out_at({k}n)'
        for i, x in enumerate(xs):
            ws = f'Array.set(U32, {ws}, {i}, {x})'
        sig = ', '.join(f'+{x}: U32' for x in xs)
        L = []
        last = (1 << D) - nw
        for q in sorted({0, 1, 2, 3, last} & set(range(last + 1))):   # the first four word positions and the last that fits
            L.append((4 * q, f'a{q}'))
        for p in (5, 6, 7):
            L.append((p, f'u{p}'))
        laws = []
        for pos, tag in L:
            buf = f'O.out_at({D}n)'
            laws.append(f'def {X}_cmp_{tag}({sig}) -> {{T.{P}_put({buf}, {pos}, O.Words{{{ws}, {N}}}) == T.{P}_pw(False{{}}, {buf}, {pos}, {ws}, {N}) : Array<U32> & O.Words}}:\n  {{==}}')
        out[X] = laws
    return out


def module(tmod, X, laws):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('cmp_laws'),
         f'# {X}: the aligned-or-general writer choice of its put does not change the words written',
         '# (found by mutation testing; codegen/proofs/laws/cmp_laws.py). By computation on variable words.', '']
    for t in laws:
        L.append(t)
        L.append('')
    return '\n'.join(L)


def guard_module():
    """the guard's own arithmetic: pos .&. 3 is one of 0..3, and on those `is_le(k, 0)` is `is_eq(k, 0)` (an unsigned
    word is <= 0 only when it is 0) and `is_lt(k, 0)` is never true: so a guard written `is_le` is the original, and
    one written `is_lt` always takes the general writer (the statements of zcmpeq_<X> say that this changes no word)"""
    L = ['import Base', '', writer.header('cmp_laws'),
         '# The comparison of the aligned-or-general writer choice, on every value of pos .&. 3 (found by mutation testing;',
         '# codegen/proofs/laws/cmp_laws.py). By computation.', '']
    for k in range(4):
        L.append(f'def guard_le_is_eq_{k}() -> {{U32.is_le({k}, 0) == U32.is_eq({k}, 0) : Bool}}:\n  {{==}}\n')
        L.append(f'def guard_lt_is_never_{k}() -> {{U32.is_lt({k}, 0) == False{{}} : Bool}}:\n  {{==}}\n')
        L.append(f'def guard_ge_is_always_{k}() -> {{U32.is_ge({k}, 0) == True{{}} : Bool}}:\n  {{==}}\n')
    return '\n'.join(L)


def main():
    out, cnt, seen = {}, [], set()
    out[ROOT / 'proofs/obj/zcmpeq_guard.bend'] = guard_module()
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        laws = name_laws(runtime)
        n = 0
        for X, ls in laws.items():
            if X in seen:
                continue
            seen.add(X)
            out[ROOT / f'proofs/obj/zcmpeq_{X}.bend'] = module(tmod, X, ls)
            n += len(ls)
        cnt.append(n)
    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('zcmpeq_*.bend') if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale cmp laws: ', 'cmp laws are current', orphans)
    writer.write(out, orphans)
    print(f'{cnt} laws')


if __name__ == '__main__':
    main()
