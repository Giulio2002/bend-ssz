#!/usr/bin/env python3
"""Equivalence laws for the aligned-or-general path choice of the word-vector writers, found by mutation testing
(`U32.is_eq((pos .&. 3), 0)` changed to `is_lt` / `is_le` / `is_ge` in `X_put`).

    python3 codegen/proofs/mutation_coverage/aligned_write_guard.py [--check]

`P_put(out, pos, Words{ws, n})` of a word-stored vector picks, by `pos .&. 3 == 0`, between two writers of the same
words: the unrolled aligned chain (`P_pa0 .. P_paK`, single-word stores) and the general `O.put_words`. They agree at
every aligned position, so a guard that always takes the general writer (`is_lt(x, 0)` is never true; `is_le(x, 0)`
is `is_eq` on unsigned words) changes nothing, and a guard that takes the chain at an unaligned position is wrong.

proofs/mutation_coverage/alignment/<X>_aligned_path.bend (one module per name whose put has that guard) proves, for every X:

  <X>_cmp_all    for every aligned position pos (e3: pos .&. 3 == 0), every word index q = pos >> 2 with value Q, and every
                 pair of perfect trees D (destination, 2^dd words, Q + nw <= 2^dd) and S (the nw source words):
                   P_put(thaw D, pos, Words{thaw S, N}) == P_pw(False{}, thaw D, pos, thaw S, N)
                 the writer the guard picks equals the general writer. The proof models both writers on trees (`cpt`):
                 the chain by `<X>_fa<i>` (one lemma per word, the index q + i tracked through arr_copy.bend's `ix`, `getv`,
                 `setv`), the general writer by arr_copy.bend's `put_al` / `blk` and aligned_path_library.bend's `tl<k>` (the tail
                 of `O.acopy`, whose index terms `(q + n) - r` the checker does not fold, so only their values are
                 tracked), glued by `<X>_acg`.
  <X>_cmp_unal   for every unaligned position (the guard is False), every buffer and word list:
                 P_put(out, pos, Words{ws, n}) == P_pw(False{}, out, pos, ws, n): the guard sends it to the general writer,
                 and a guard that takes the chain there (`is_ge`) fails this statement.

aligned_path_guard.bend: on the four values of pos .&. 3, `is_le(k, 0) == is_eq(k, 0)`, `is_lt(k, 0)` is never true, `is_ge(k, 0)`
always. Together: a guard `is_le` is the original guard on every position; a guard `is_lt` always takes the general
writer, which by `<X>_cmp_all` agrees with the chain on every aligned position and is what the original does on the
others; neither changes the result of `X_put`.

Named so that api_gate files them under encode_eval; api_gate reads the mutation-coverage modules after the name's own
proving files (a facade's first proving import must stay the spec/encx file).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core.shared_laws import law_module, per_name  # noqa: E402
from codegen.core import mutation_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402


def log2ceil(w):
    k = 0
    while (1 << k) < w:
        k += 1
    return k


def name_laws(runtime):
    text = RR.mono_text(runtime)
    out = {}
    for m in re.finditer(r'^def (\w+)_encode\(o: O\.Words\) -> [^\n:]*: \w+_enc_(?:out|put)\((\w+)_put\(O\.out_at\((\d+)n\), 0, o\)\)$', text, re.M):
        X, P = m.group(1), m.group(2)
        pm = re.search(rf'^def {P}_put\(out: Array<U32>, \+pos: U32, o: O\.Words\) -> Array<U32> & O\.Words:\n  match o:\n    case O\.Words\{{ws, \+n\}}: {P}_pw\(U32\.is_eq\(\(pos \.&\. 3 : U32\), 0\), out, pos, ws, n\)$', text, re.M)
        pas = sorted(int(x) for x in re.findall(rf'^def {P}_pa(\d+)\(', text, re.M))
        mv = re.search(rf'^def {P}_valid\(o: O\.Words\) -> [^\n:]*: (?:O\.bools_ok\()?O\.words_ok\(o, (\d+), (\d+), False\{{\}}, \d+\)\)?$', text, re.M)
        if not (pm and pas and pas == list(range(len(pas))) and mv and mv.group(1) == mv.group(2) and int(mv.group(1)) == 4 * len(pas)):
            continue
        nw, N = len(pas), int(mv.group(1))
        out[X] = ['\n'.join(name_proof(X, P, nw, N))]
    return out


# ---- the proof for every aligned position -------------------------------------------------------------------
# The aligned chain (P_pa0 .. P_pa<nw-1>) and the general writer's whole-word copy (O.acopy) both store word i of the
# source at word q + i of the destination. proofs/obj/arr_copy.bend already models O.acopy on perfect trees for a
# symbolic index (`blk`, `cpt`, `split`, `put_al`); what it lacks, and what the checker's missing index folding
# makes necessary, is (a) the same model for the tail of acopy (fewer than eight words: `tl<k>` below, with the
# index terms kept as the U32 expressions the writer builds and only their values tracked), (b) the model of the
# aligned chain (`fa<i>`), and (c) the glue. Everything is stated over a symbolic word index q (its value Q is a Nat
# with Q + words <= 2^dd), perfect trees D (destination) and S (source), so every aligned position of every buffer.

def P2(d):
    return f'F.spec_common__pow2({d})'


def thaw(t):
    return f'F.array__thaw(U32, {t})'


def slots(t):
    return f'F.array__slots(U32, {t})'


def nthc(t, k):
    return f'F.flat__nthc({slots(t)}, {k})'


def upd(dd, D, j, v):
    return f'F.array__upd(U32, {dd}, {D}, {j}, {v})'


TREES = '+ds: Nat, +dd: Nat, +S: F.array__Tree<U32>, +D: F.array__Tree<U32>'
BASEH = ('+hs: {Nat.is_lt(ds, 32n) == True{} : Bool}, +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}')
PERF = ('+ps: {F.array__perfect(U32, ds, S) == True{} : Bool}, +pd: {F.array__perfect(U32, dd, D) == True{} : Bool}')


def lib_module():
    """aligned_path_library: the model of O.ac_w and of the tail of O.acopy (k = 1 .. 7 words) on perfect trees"""
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../compact/found.bend as F',
         'import ./arr_copy.bend as AC', '', writer.header('aligned_write_guard'),
         '# The model of the tail of O.acopy (fewer than eight single-word copies) on perfect trees, for symbolic indices a, b',
         '# whose values A, Bn are tracked (codegen/proofs/mutation_coverage/aligned_write_guard.py; arr_copy.bend has the blocks).', '']
    w = L.append
    w(f'def acw(+b: U32, +Bn: Nat, +dd: Nat, +D: F.array__Tree<U32>, src: Array<U32>, +w: U32, +eb: {{U32.to_nat(b) == Bn : Nat}}, +hdd: {{Nat.is_lt(dd, 32n) == True{{}} : Bool}},')
    w(f'    +hk: {{Nat.is_lt(Bn, {P2("dd")}) == True{{}} : Bool}}, +pd: {{F.array__perfect(U32, dd, D) == True{{}} : Bool}})')
    w(f'    -> {{O.ac_w(b, {thaw("D")}, (src, w)) == ({thaw(upd("dd", "D", "Bn", "w"))}, src) : Array<U32> & Array<U32>}}:')
    w(f'  %Equal.sym(Array<U32>, Array.set(U32, {thaw("D")}, b, w), {thaw(upd("dd", "D", "Bn", "w"))}, AC.setv(dd, D, b, Bn, w, eb, hdd, hk, pd)) :')
    w('    {(_, src) == (' + thaw(upd("dd", "D", "Bn", "w")) + ', src) : Array<U32> & Array<U32>}')
    w('  {==}')
    w('')
    for k in range(1, 8):
        sig = (f'def tl{k}(+a: U32, +b: U32, +A: Nat, +Bn: Nat, {TREES}, +ea: {{U32.to_nat(a) == A : Nat}}, +eb: {{U32.to_nat(b) == Bn : Nat}},\n'
               f'    {BASEH},\n'
               f'    +hA: {{Nat.is_le(Nat.add({k}n, A), {P2("ds")}) == True{{}} : Bool}}, +hB: {{Nat.is_le(Nat.add({k}n, Bn), {P2("dd")}) == True{{}} : Bool}},\n'
               f'    {PERF})\n'
               f'    -> {{O.ac_tail({k}n, a, b, ({thaw("D")}, {thaw("S")})) == ({thaw(f"AC.cpt(dd, {k}n, A, Bn, D, {slots(chr(83))})")}, {thaw("S")}) : Array<U32> & Array<U32>}}:')
        w(sig)
        w(f'  +hb1 = AC.lt_off(0n, {k}n, Bn, {P2("dd")}, {{==}}, hB)')
        w(f'  +ha1 = AC.lt_off(0n, {k}n, A, {P2("ds")}, {{==}}, hA)')
        wv = nthc('S', 'A')
        u = upd('dd', 'D', 'Bn', wv)
        w(f'  %Equal.sym(Array<U32> & U32, Array.get(U32, {thaw("S")}, a), ({thaw("S")}, {wv}), AC.getv(ds, S, a, A, ea, hs, ha1, ps)) :')
        w(f'    {{O.ac_tail({k - 1}n, U32.add(a, 1), U32.add(b, 1), O.ac_w(b, {thaw("D")}, _)) == ({thaw(f"AC.cpt(dd, {k}n, A, Bn, D, {slots(chr(83))})")}, {thaw("S")}) : Array<U32> & Array<U32>}}')
        w(f'  %Equal.sym(Array<U32> & Array<U32>, O.ac_w(b, {thaw("D")}, ({thaw("S")}, {wv})), ({thaw(u)}, {thaw("S")}), acw(b, Bn, dd, D, {thaw("S")}, {wv}, eb, hdd, hb1, pd)) :')
        w(f'    {{O.ac_tail({k - 1}n, U32.add(a, 1), U32.add(b, 1), _) == ({thaw(f"AC.cpt(dd, {k}n, A, Bn, D, {slots(chr(83))})")}, {thaw("S")}) : Array<U32> & Array<U32>}}')
        if k == 1:
            w('  {==}')
        else:
            w(f'  +hb2 = AC.lt_off(1n, {k}n, Bn, {P2("dd")}, {{==}}, hB)')
            w(f'  +ha2 = AC.lt_off(1n, {k}n, A, {P2("ds")}, {{==}}, hA)')
            w(f'  +ea1 = AC.ix(a, 1, A, ds, ea, hs, F.nat__lt_le(Nat.add(1n, A), {P2("ds")}, ha2))')
            w(f'  +eb1 = AC.ix(b, 1, Bn, dd, eb, hdd, F.nat__lt_le(Nat.add(1n, Bn), {P2("dd")}, hb2))')
            w(f'  tl{k - 1}(U32.add(a, 1), U32.add(b, 1), Nat.add(1n, A), Nat.add(1n, Bn), ds, dd, S, {upd("dd", "D", "Bn", wv)}, ea1, eb1, hs, hdd, hA, hB, ps, F.array__upd_perfect(U32, dd, D, Bn, {wv}, pd))')
        w('')
    return '\n'.join(L)


def name_proof(X, P, nw, N):
    """the lemmas and the two laws (aligned, any q: `<X>_cmp_all`; unaligned, any position: `<X>_cmp_unal`) of one name"""
    r, kb = nw % 8, nw // 8
    m = 8 * kb
    L = []
    w = L.append
    SL = slots('S')
    HA = f'+hA: {{Nat.is_le(Nat.add({nw}n, 0n), {P2("ds")}) == True{{}} : Bool}}'
    HB = f'+hB: {{Nat.is_le(Nat.add({nw}n, Q), {P2("dd")}) == True{{}} : Bool}}'
    EQ = '+eq: {U32.to_nat(q) == Q : Nat}'
    sigq = f'+q: U32, +Q: Nat, {TREES}, {EQ}, {BASEH}, {HA}, {HB}, {PERF}'
    argq = 'q, Q, ds, dd, S, D, eq, hs, hdd, hA, hB, ps, pd'
    # the aligned chain, last word first
    for i in range(nw - 1, -1, -1):
        wv = nthc('S', f'{i}n')
        cp = f'AC.cpt(dd, {nw - i}n, {i}n, Nat.add({i}n, Q), D, {SL})'
        w(f'def {X}_fa{i}({sigq})')
        w(f'    -> {{T.{P}_pa{i}(q, {thaw("D")}, ({thaw("S")}, {wv})) == ({thaw(cp)}, {thaw("S")}) : Array<U32> & Array<U32>}}:')
        w(f'  +hb1 = AC.lt_off({i}n, {nw}n, Q, {P2("dd")}, {{==}}, hB)')
        w(f'  +eb1 = AC.ix(q, {i}, Q, dd, eq, hdd, F.nat__lt_le(Nat.add({i}n, Q), {P2("dd")}, hb1))')
        u = upd('dd', 'D', f'Nat.add({i}n, Q)', wv)
        setrw = f'%Equal.sym(Array<U32>, Array.set(U32, {thaw("D")}, U32.add(q, {i}), {wv}), {thaw(u)}, AC.setv(dd, D, U32.add(q, {i}), Nat.add({i}n, Q), {wv}, eb1, hdd, hb1, pd)) :'
        if i == nw - 1:
            w('  ' + setrw)
            w(f'    {{(_, {thaw("S")}) == ({thaw(cp)}, {thaw("S")}) : Array<U32> & Array<U32>}}')
            w('  {==}')
        else:
            w(f'  +ha1 = AC.lt_off({i + 1}n, {nw}n, 0n, {P2("ds")}, {{==}}, hA)')
            w('  ' + setrw)
            w(f'    {{T.{P}_pa{i + 1}(q, _, Array.get(U32, {thaw("S")}, {i + 1})) == ({thaw(cp)}, {thaw("S")}) : Array<U32> & Array<U32>}}')
            w(f'  %Equal.sym(Array<U32> & U32, Array.get(U32, {thaw("S")}, {i + 1}), ({thaw("S")}, {nthc("S", f"{i + 1}n")}), AC.getv(ds, S, {i + 1}, {i + 1}n, {{==}}, hs, ha1, ps)) :')
            w(f'    {{T.{P}_pa{i + 1}(q, {thaw(u)}, _) == ({thaw(cp)}, {thaw("S")}) : Array<U32> & Array<U32>}}')
            w(f'  {X}_fa{i + 1}(q, Q, ds, dd, S, {u}, eq, hs, hdd, hA, hB, ps, F.array__upd_perfect(U32, dd, D, Nat.add({i}n, Q), {wv}, pd))')
        w('')
    cpall = f'AC.cpt(dd, {nw}n, 0n, Q, D, {SL})'
    w(f'def {X}_fch({sigq})')
    w(f'    -> {{T.{P}_pal({N}, T.{P}_pa0(q, {thaw("D")}, Array.get(U32, {thaw("S")}, 0))) == ({thaw(cpall)}, O.Words{{{thaw("S")}, {N}}}) : Array<U32> & O.Words}}:')
    w(f'  +ha0 = AC.lt_off(0n, {nw}n, 0n, {P2("ds")}, {{==}}, hA)')
    w(f'  %Equal.sym(Array<U32> & U32, Array.get(U32, {thaw("S")}, 0), ({thaw("S")}, {nthc("S", "0n")}), AC.getv(ds, S, 0, 0n, {{==}}, hs, ha0, ps)) :')
    w(f'    {{T.{P}_pal({N}, T.{P}_pa0(q, {thaw("D")}, _)) == ({thaw(cpall)}, O.Words{{{thaw("S")}, {N}}}) : Array<U32> & O.Words}}')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, T.{P}_pa0(q, {thaw("D")}, ({thaw("S")}, {nthc("S", "0n")})), ({thaw(cpall)}, {thaw("S")}), {X}_fa0({argq})) :')
    w(f'    {{T.{P}_pal({N}, _) == ({thaw(cpall)}, O.Words{{{thaw("S")}, {N}}}) : Array<U32> & O.Words}}')
    w('  {==}')
    w('')
    # the general writer's whole-word copy
    sigb = f'+b: U32, +Bn: Nat, {TREES}, +eb: {{U32.to_nat(b) == Bn : Nat}}, {BASEH}, {HA}, {HB.replace("Q", "Bn")}, {PERF}'
    cpb = f'AC.cpt(dd, {nw}n, 0n, Bn, D, {SL})'
    if r:
        w(f'def {X}_lele(+b: U32, +Bn: Nat, +dd: Nat, +eb: {{U32.to_nat(b) == Bn : Nat}}, +hdd: {{Nat.is_lt(dd, 32n) == True{{}} : Bool}}, +hB: {{Nat.is_le(Nat.add({nw}n, Bn), {P2("dd")}) == True{{}} : Bool}})')
        w(f'    -> {{Nat.is_le(U32.to_nat({r}), U32.to_nat(U32.add(b, {nw}))) == True{{}} : Bool}}:')
        w(f'  +eadd = AC.ix(b, {nw}, Bn, dd, eb, hdd, hB)')
        w(f'  %Equal.sym(Nat, U32.to_nat(U32.add(b, {nw})), Nat.add(U32.to_nat({nw}), Bn), eadd) :')
        w(f'    {{Nat.is_le(U32.to_nat({r}), _) == True{{}} : Bool}}')
        w('  F.nat__zero_le(Bn)' if kb == 0 else '  {==}')
        w('')
        w(f'def {X}_sublem(+b: U32, +Bn: Nat, +dd: Nat, +eb: {{U32.to_nat(b) == Bn : Nat}}, +hdd: {{Nat.is_lt(dd, 32n) == True{{}} : Bool}}, +hB: {{Nat.is_le(Nat.add({nw}n, Bn), {P2("dd")}) == True{{}} : Bool}})')
        w(f'    -> {{U32.to_nat(U32.sub(U32.add(b, {nw}), {r})) == Nat.add({m}n, Bn) : Nat}}:')
        w(f'  +eadd = AC.ix(b, {nw}, Bn, dd, eb, hdd, hB)')
        w(f'  +e1 = F.u32__sub_nat(U32.add(b, {nw}), {r}, {X}_lele(b, Bn, dd, eb, hdd, hB))')
        w(f'  %Equal.sym(Nat, U32.to_nat(U32.sub(U32.add(b, {nw}), {r})), Nat.sub(U32.to_nat(U32.add(b, {nw})), U32.to_nat({r})), e1) :')
        w(f'    {{_ == Nat.add({m}n, Bn) : Nat}}')
        w(f'  %Equal.sym(Nat, U32.to_nat(U32.add(b, {nw})), Nat.add(U32.to_nat({nw}), Bn), eadd) :')
        w(f'    {{Nat.sub(_, U32.to_nat({r})) == Nat.add({m}n, Bn) : Nat}}')
        w('  F.nat__sub_zero(Bn)' if kb == 0 else '  {==}')
        w('')
    w(f'def {X}_acg({sigb})')
    w(f'    -> {{O.acopy({nw}, 0, b, {thaw("D")}, {thaw("S")}) == ({thaw(cpb)}, {thaw("S")}) : Array<U32> & Array<U32>}}:')
    if r == 0:
        w(f'  AC.blk({kb}n, {nw}n, 0, b, 0n, Bn, ds, dd, S, D, {{==}}, {{==}}, eb, hs, hdd, hA, hB, ps, pd)')
    elif kb == 0:
        w(f'  ZL.tl{r}(0, U32.sub(U32.add(b, {nw}), {r}), 0n, Bn, ds, dd, S, D, {{==}}, {X}_sublem(b, Bn, dd, eb, hdd, hB), hs, hdd, hA, hB, ps, pd)')
    else:
        dm = f'AC.cpt(dd, {m}n, 0n, Bn, D, {SL})'
        sub = f'U32.sub(U32.add(b, {nw}), {r})'
        w(f'  +hAm = F.nat__le_trans(Nat.add({m}n, 0n), Nat.add({nw}n, 0n), {P2("ds")}, {{==}}, hA)')
        w(f'  +hBm = F.nat__le_trans(Nat.add({m}n, Bn), Nat.add({nw}n, Bn), {P2("dd")}, AC.le_addl({r}n, Bn), hB)')
        w(f'  +bk = AC.blk({kb}n, {m}n, 0, b, 0n, Bn, ds, dd, S, D, {{==}}, {{==}}, eb, hs, hdd, hAm, hBm, ps, pd)')
        w(f'  %Equal.sym(Array<U32> & Array<U32>, O.ac_blk({kb}n, 0, b, ({thaw("D")}, {thaw("S")})), ({thaw(dm)}, {thaw("S")}), bk) :')
        w(f'    {{O.ac_tail({r}n, {m}, {sub}, _) == ({thaw(cpb)}, {thaw("S")}) : Array<U32> & Array<U32>}}')
        w(f'  %Equal.sym(F.array__Tree<U32>, {cpb}, AC.cpt(dd, {r}n, Nat.add({m}n, 0n), Nat.add({m}n, Bn), {dm}, {SL}), AC.split(dd, {m}n, {r}n, 0n, Bn, D, {SL})) :')
        w(f'    {{O.ac_tail({r}n, {m}, {sub}, ({thaw(dm)}, {thaw("S")})) == ({thaw("_")}, {thaw("S")}) : Array<U32> & Array<U32>}}')
        w(f'  ZL.tl{r}({m}, {sub}, Nat.add({m}n, 0n), Nat.add({m}n, Bn), ds, dd, S, {dm}, {{==}}, {X}_sublem(b, Bn, dd, eb, hdd, hB), hs, hdd, hA, hB, ps, AC.cpt_perfect(dd, {m}n, 0n, Bn, D, {SL}, pd))')
    w('')
    # every aligned position
    r0 = f'({thaw(cpall)}, {thaw("S")})'
    w(f'def {X}_cmp_all(+pos: U32, +Q: Nat, {TREES}, +e3: {{(pos .&. 3 : U32) == 0 : U32}}, +eq: {{U32.to_nat(U32.shrn(pos, 2n)) == Q : Nat}}, {BASEH}, {HA}, {HB}, {PERF})')
    w(f'    -> {{T.{P}_put({thaw("D")}, pos, O.Words{{{thaw("S")}, {N}}}) == T.{P}_pw(False{{}}, {thaw("D")}, pos, {thaw("S")}, {N}) : Array<U32> & O.Words}}:')
    w(f'  +ec = {X}_acg(U32.shrn(pos, 2n), Q, ds, dd, S, D, eq, hs, hdd, hA, hB, ps, pd)')
    w(f'  +pa = AC.put_al({thaw("D")}, {thaw("S")}, pos, {N}, {r0}, {{==}}, e3, {{==}}, ec)')
    w(f'  %Equal.sym(Array<U32> & O.Words, O.put_words({thaw("D")}, pos, O.Words{{{thaw("S")}, {N}}}), O.put_fin({N}, {r0}), pa) :')
    w(f'    {{T.{P}_put({thaw("D")}, pos, O.Words{{{thaw("S")}, {N}}}) == _ : Array<U32> & O.Words}}')
    w(f'  %Equal.sym(U32, U32.and(pos, 3), 0, e3) :')
    w(f'    {{T.{P}_pw(U32.is_eq(_, 0), {thaw("D")}, pos, {thaw("S")}, {N}) == O.put_fin({N}, {r0}) : Array<U32> & O.Words}}')
    w(f'  {X}_fch(U32.shrn(pos, 2n), Q, ds, dd, S, D, eq, hs, hdd, hA, hB, ps, pd)')
    w('')
    # every unaligned position, every buffer and word list
    w(f'def {X}_cmp_unal(out: Array<U32>, ws: Array<U32>, +pos: U32, +n: U32, +eu: {{U32.is_eq((pos .&. 3 : U32), 0) == False{{}} : Bool}})')
    w(f'    -> {{T.{P}_put(out, pos, O.Words{{ws, n}}) == T.{P}_pw(False{{}}, out, pos, ws, n) : Array<U32> & O.Words}}:')
    w(f'  %Equal.sym(Bool, U32.is_eq((pos .&. 3 : U32), 0), False{{}}, eu) :')
    w(f'    {{T.{P}_pw(_, out, pos, ws, n) == T.{P}_pw(False{{}}, out, pos, ws, n) : Array<U32> & O.Words}}')
    w('  {==}')
    w('')
    return L


def module(tmod, X, laws):
    return law_module('aligned_write_guard', [f'# {X}: the aligned-or-general writer choice of its put does not change the words written',
                                   '# (found by mutation testing; codegen/proofs/mutation_coverage/aligned_write_guard.py). By computation on variable words.'], laws, tmod,
                      ['import ../compact/found.bend as F', 'import ./arr_copy.bend as AC', 'import ./aligned_path_library.bend as ZL'])


def guard_module():
    """the guard's own arithmetic: pos .&. 3 is one of 0..3, and on those `is_le(k, 0)` is `is_eq(k, 0)` (an unsigned
    word is <= 0 only when it is 0) and `is_lt(k, 0)` is never true: so a guard written `is_le` is the original, and
    one written `is_lt` always takes the general writer (the statements of <X>_aligned_path say that this changes no word)"""
    L = ['import Base', '', writer.header('aligned_write_guard'),
         '# The comparison of the aligned-or-general writer choice, on every value of pos .&. 3 (found by mutation testing;',
         '# codegen/proofs/mutation_coverage/aligned_write_guard.py). By computation.', '']
    for k in range(4):
        L.append(f'def guard_le_is_eq_{k}() -> {{U32.is_le({k}, 0) == U32.is_eq({k}, 0) : Bool}}:\n  {{==}}\n')
        L.append(f'def guard_lt_is_never_{k}() -> {{U32.is_lt({k}, 0) == False{{}} : Bool}}:\n  {{==}}\n')
        L.append(f'def guard_ge_is_always_{k}() -> {{U32.is_ge({k}, 0) == True{{}} : Bool}}:\n  {{==}}\n')
    return '\n'.join(L)


def main():
    out, cnt = per_name(name_laws, module, lambda X: LAYOUT.module_path('alignment', f'{X}_aligned_path'))
    out[LAYOUT.module_path('alignment', 'aligned_path_guard')] = guard_module()
    out[LAYOUT.module_path('alignment', 'aligned_path_library')] = lib_module()
    if LAYOUT.finish(RR.rewire_out(out), 'aligned_write_guard', ('alignment',), 'stale aligned write guard laws: ', 'aligned write guard laws are current', '--check' in sys.argv):
        print(f'{cnt} laws')


if __name__ == '__main__':
    main()
