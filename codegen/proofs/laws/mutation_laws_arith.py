#!/usr/bin/env python3
"""Laws that pin the word positions the encoders and the decoder write and read, found by mutation testing
(the `arithmetic` survivors: `q + k` / `pos + k` / `off + k` changed to `- k`).

    python3 codegen/proofs/laws/mutation_laws_arith.py [--check]

Why the existing statements missed them. A word index in the runtime's arrays is taken modulo the array's size (the
tree walk reads the low `d` bits of the index of a `2^d` word array), and every statement about an encoder or
decoder is about the buffer it allocates itself, of exactly the size of the object. There `q - k` and `q + k` name
the same word whenever `2k` is a multiple of the capacity (Fork: word 2 of 4; Bytes8: word 1 of 2), so a wrong sign is
invisible. The unaligned writers `P_pw1..3` run only at a byte offset that is not a multiple of 4, which no top-level
encoder passes, so nothing evaluates them at all. These laws evaluate the same definitions on a larger buffer, or
at an offset the top level never uses, where the two indices differ.

proofs/obj/wordpos_<X>.bend (one module per name, so a facade imports only its own) holds, for the
names that have the form:

  <X>_arith_pw<K>   K = 1, 2, 3: the unaligned writer P_pw<K> of a word list (leaf scalars, byte vectors, bit
                    vectors up to 513 bits) at word 3 of a zero buffer of at least four times the words it
                    touches writes the words of the list shifted up by K bytes (the expected array is computed
                    here from the shift, not from the writer: v << 8K split into 32-bit words, the carry word
                    included).
  <X>_arith_put     the writer of a fixed-size container (X_put) into a zero buffer four times the size of the
                    encoder's own emits the same words as the encoder (`X_encode`, whose bytes the spec laws fix).
  <X>_arith_putw    the writer of a word-stored vector (vec_*) at an aligned byte offset of a large zero buffer
                    stores the words of its storage at that offset, and returns the storage.
  <X>_arith_dec     the decoder of a multi-word byte vector reading a buffer four times as large as the value
                    returns the value (the read of word k is `off + 4k`).

All are by computation. The names start with `<X>_arith_` so that api_gate files them (encode_eval for the
writers, decode_accept for the decoder) and they land in the name's own facade.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core.paths import ROOT  # noqa: E402
from codegen.core.shared_laws import finish, law_module, per_name  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402

M32 = (1 << 32) - 1
Q0 = 3  # the word of the zero buffer the unaligned writers start at (odd: 2q is not a multiple of any capacity)


def depth_for(words):
    """least d with 2^d >= 4 * words"""
    d = 0
    while (1 << d) < 4 * words:
        d += 1
    return d


def word_vals(n, salt):
    """n distinct words with every byte non-zero (so the carry word and every byte show)"""
    return [0x80808080 | ((0x01234567 * (i + 1 + salt) + 0x0A0B0C0D) & 0x7F7F7F7F) for i in range(n)]


def arr(base, items):
    """an array literal: `base` (O.out_at(..)) with the nonzero words set at their indices"""
    t = base
    for i, w in items:
        if w:
            t = f'Array.set(U32, {t}, {i}, {w})'
    return t


def types_table():
    """{type name: [(field, field type)]} of the single-constructor object types of the generated def files"""
    tab = {}
    for p in sorted((ROOT / 'types').glob('*_def_generated.bend')):
        for m in re.finditer(r'^type (\w+) is Data:\n  \1\{([^}\n]*)\}', p.read_text(), re.M):
            tab[m.group(1)] = [tuple(x.strip().split(': ')) for x in m.group(2).split(',')]
    return tab


def build(ty, tab, cnt):
    """a concrete value of field type `ty` (small non-zero words), or None when the type is not fixed-shape"""
    def word():
        cnt[0] += 1
        return (cnt[0] * 29) % 251 + 1
    if ty == 'U32':
        return str(word())
    if ty == 'O.U64':
        return f'O.U64{{{word()}, {word()}}}'
    n = ty.split('.')[-1]
    if n not in tab:
        return None
    parts = [build(t, tab, cnt) for _, t in tab[n]]
    if any(p is None for p in parts):
        return None
    return f'T.{n}{{{", ".join(parts)}}}'


def name_laws(runtime):
    """{X: [law text]} for the names of one runtime"""
    text = RR.mono_text(runtime)
    tab = types_table()
    # X -> (P, d): the writer prefix and the depth of the encoder's own buffer
    enc = {}
    for m in re.finditer(r'^def (\w+)_encode\(([^\n]*)$', text, re.M):
        mm = re.search(r'(\w+)_put\(O\.out_at\((\d+)n\), 0, o\)', m.group(2))
        if mm:
            enc[m.group(1)] = (mm.group(1), int(mm.group(2)), m.group(2))
    out = {}
    pwre = re.compile(r'^def (\w+)_pw([123])\(out: Array<U32>, \+q: U32((?:, \+w\d+: U32)+)\) -> Array<U32>:', re.M)
    pws = {}
    for m in pwre.finditer(text):
        pws.setdefault(m.group(1), {})[int(m.group(2))] = len(re.findall(r'\+w\d+', m.group(3)))
    for X, (P, d, body) in sorted(enc.items()):
        L = []
        # ---- unaligned writers ----
        for K, n in sorted(pws.get(P, {}).items()):
            ws = word_vals(n, K)
            v = sum(w << (32 * i) for i, w in enumerate(ws)) << (8 * K)
            exp = [((v >> (32 * j)) & M32) for j in range(n + 1)]
            dd = depth_for(Q0 + n + 1)
            base = f'O.out_at({dd}n)'
            L.append(f'def {X}_arith_pw{K}() -> {{T.{P}_pw{K}({base}, {Q0}, {", ".join(map(str, ws))}) == {arr(base, [(Q0 + j, w) for j, w in enumerate(exp)])} : Array<U32>}}:\n  {{==}}')
        # ---- a fixed-size container's writer ----
        mp = re.search(rf'^def {P}_put\(out: Array<U32>, \+pos: U32, o: ([\w.]+)\) -> Array<U32>:', text, re.M)
        mo = re.search(r'O\.out_done\((\d+), ', body)
        if mp and mo and not re.search(rf'^def {P}_pw[123]\(', text, re.M):
            blk = re.search(rf'^def {P}_put\(.*?(?=^def |\Z)', text, re.M | re.S).group(0)
            tn = mp.group(1).split('.')[-1]
            if re.search(r'\(pos \+ [1-9]\d* : U32\)', blk) and tn in tab:
                cnt = [0]
                obj = build(mp.group(1), tab, cnt)
                if obj:
                    N = int(mo.group(1))
                    W = (N + 3) // 4
                    big = f'O.out_at({d + 2}n)'
                    pr = 'Pair.snd(B.Buf, +List<U32>, '
                    L.append(f'def {X}_arith_put() -> {{B.emit(T.{X}_encode({obj}), 0, {W}) == (T.{X}_encode({obj}), {pr}B.emit(O.out_done({N}, T.{P}_put({big}, 0, {obj})), 0, {W}))) : B.Buf & +List<U32>}}:\n  {{==}}')
        # ---- a word-stored vector's writer ----
        pas = sorted(int(x) for x in re.findall(rf'^def {P}_pa(\d+)\(', text, re.M))
        mw = re.search(rf'^def {P}_put\(out: Array<U32>, \+pos: U32, o: O\.Words\) -> Array<U32> & O\.Words:', text, re.M)
        mv = re.search(rf'O\.words_ok\(o, (\d+), (\d+), False\{{\}}, \d+\)', text[text.find(f'def {P}_valid('):][:300]) if f'def {P}_valid(' in text else None
        if pas and mw and mv and pas == list(range(len(pas))):
            nw = len(pas)
            N = int(mv.group(1))
            ws = word_vals(nw, 7)
            dd = depth_for(Q0 + nw)
            base = f'O.out_at({dd}n)'
            sto = arr(f'O.out_at({depth_for(nw) - 2 if depth_for(nw) > 2 else 0}n)', list(enumerate(ws)))
            L.append(f'def {X}_arith_putw() -> {{T.{P}_put({base}, {4 * Q0}, O.Words{{{sto}, {N}}}) == ({arr(base, [(Q0 + i, w) for i, w in enumerate(ws)])}, O.Words{{{sto}, {N}}}) : Array<U32> & O.Words}}:\n  {{==}}')
        if L:
            out[X] = L
    # ---- decoders of multi-word byte vectors ----
    for m in re.finditer(r'^def (\w+)_decode\(buf: B\.Buf, \+size: U32\)[^\n]*\n  (\w+)\(size, (\w+)_ok\(buf, 0, size\)\)', text, re.M):
        X, P = m.group(1), m.group(3)
        if not re.search(rf'^def {P}_r0\(', text, re.M) or X not in tab:
            continue
        mn = re.search(rf'^def {P}_ok\(buf: B\.Buf, \+off: U32, \+len: U32\)[^\n]*: {P}_ok_len\(U32\.is_eq\(len, (\d+)\)', text, re.M)
        if not mn or int(mn.group(1)) % 4 or not 8 <= int(mn.group(1)) <= 64 or any(t != 'U32' for _, t in tab[X]):
            continue
        N = int(mn.group(1))
        nw = N // 4
        if len(tab[X]) != nw:
            continue
        ws = word_vals(nw, 11)
        buf = f'B.Buf{{{arr(f"O.out_at({depth_for(nw)}n)", list(enumerate(ws)))}, {N}}}'
        out.setdefault(X, []).append(f'def {X}_arith_dec() -> {{T.{X}_decode({buf}, {N}) == ({buf}, Some{{T.{X}{{{", ".join(map(str, ws))}}}}}) : B.Buf & Maybe<&1, T.{X}>}}:\n  {{==}}')
    return out


def module(tmod, X, laws):
    return law_module('mutation_laws_arith', [f'# {X}: the word positions of its writers and reader, on buffers where a wrong sign names another word',
                                              '# (found by mutation testing; codegen/proofs/laws/mutation_laws_arith.py). Each is by computation.'], laws, tmod)


def main():
    out, cnt = per_name(name_laws, lambda tmod, X, ls: module(tmod, X, ls) + '\n', 'wordpos')
    if finish(RR.rewire_out(out), ('wordpos_*.bend',), 'stale arithmetic mutation laws: ', 'arithmetic mutation laws are current', '--check' in sys.argv):
        print(f'{cnt} laws')


if __name__ == '__main__':
    main()
