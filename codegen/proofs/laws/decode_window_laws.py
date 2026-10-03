#!/usr/bin/env python3
"""The decode window: `X_decode(buf, size)` answers None for a window that is not inside the buffer (docs/CRASH_HUNT.md CH-06).

    python3 codegen/proofs/laws/decode_window_laws.py [--check]

`X_decode(buf, size)` is `X_dwin(size, B.size(buf))`: `X_dwgo(U32.is_le(size, n), buf, size)` with n the buffer's size, which is
`X_decode_in(buf, size)` (the decoder of a window inside the buffer: the validator, then the reader) when the window fits and
`(buf, None{})` when it does not. Every decode law of the library was proved on the decoder that trusted the window; it is
proved on `X_decode_in` as before, and these lemmas carry it to `X_decode`:

  <X>_win_none(buf, m, h)           h: X_decode_in(buf, m) == (buf, None{})              gives X_decode(buf, m) == (buf, None{})
                                    for every window m, whether it fits or not
  <X>_win_some(buf, m, r, hle, h)   hle: U32.is_le(m, L.bsz(buf)) == True{}, h: X_decode_in(buf, m) == r   gives X_decode(buf, m) == r
                                    the one premise a law that decodes (Some) needs: the window is inside the buffer
  <X>_win_out(buf, m, hgt)          hgt: U32.is_le(m, L.bsz(buf)) == False{}              gives X_decode(buf, m) == (buf, None{})
                                    a window past the end of the buffer (size > B.size(buf), also when off + size would wrap) is refused

proofs/obj/decode_window_library_generated.bend holds `bsz` (the size field of a buffer) and `le_refl` (U32.is_le(n, n), for a buffer of
a symbolic size n decoded whole). One module per decoder, proofs/obj/decode_window_<Name>_generated.bend. The laws that state a result
of `X_decode` get their lemma through codegen/proofs/support/decode_window.py, which wraps them as the rewiring of the runtime
imports does (runtime_file_split.rewire).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core.law_module_helpers import finish  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402

LIBRARY = ROOT / 'proofs/obj/decode_window_library_generated.bend'
DECODE = re.compile(r'^def (\w+)_decode\(buf: B\.Buf, \+size: U32\) -> B\.Buf & Maybe<&1, ([\w.]+)>:', re.M)


def library():
    return f"""import Base

{writer.header('decode_window_laws')}
# The decode window (see codegen/proofs/laws/decode_window_laws.py): the size field of a buffer, and U32.is_le(n, n).

def bsz(buf: B.Buf) -> U32:
  match buf:
    case B.Buf{{ws, +n}}: n

def bool_cmp_refl(b: Bool) -> {{Bool.cmp(b, b) == EQ{{}} : Cmp}}:
  match b:
    case False{{}}: {{==}}
    case True{{}}: {{==}}

def cmp_refl(+n: Nat, w: Word(n)) -> {{Word.cmp(n, w, w) == EQ{{}} : Cmp}}:
  match n:
    case 0n:
      match w:
        case WNil{{}}: {{==}}
    case 1n+ +p:
      match w:
        case WCon{{b, t}}:
          %Equal.sym(Cmp, Word.cmp(p, t, t), EQ{{}}, cmp_refl(p, t)) : {{Word.cmp.fin(b, b, _) == EQ{{}} : Cmp}}
          bool_cmp_refl(b)

def le_refl(x: U32) -> {{U32.is_le(x, x) == True{{}} : Bool}}:
  match x:
    case U32{{w}}:
      %Equal.sym(Cmp, Word.cmp(32n, w, w), EQ{{}}, cmp_refl(32n, w)) : {{Cmp.is_le(_) == True{{}} : Bool}}
      {{==}}
""".replace("import Base\n", "import Base\nimport ../../src/buffer.bend as B\n", 1)


def module(name, X, rep, rep_import):
    r, d = f'{name}_r', f'{name}_d'
    T = f'B.Buf & Maybe<&1, {rep}>'
    imps = ['import Base', 'import ../../src/buffer.bend as B', 'import ../word_facts.bend as W', 'import ./decode_window_library_generated.bend as L']
    if rep_import:
        imps.append(rep_import)
    imps.append(f'import ../../types/{name}_decode_ssz_generated.bend as {r}')
    return '\n'.join(imps) + f"""

{writer.header('decode_window_laws')}
# {X}: X_decode(buf, size) = X_dwin(size, B.size(buf)) answers X_decode_in(buf, size) for a window inside the buffer, None for one that is not.

def {X}_win_none_go(ok: Bool, buf: B.Buf, +m: U32, h: {{{r}.{X}_decode_in(buf, m) == (buf, None{{}}) : {T}}})
    -> {{{r}.{X}_dwgo(ok, buf, m) == (buf, None{{}}) : {T}}}:
  match ok:
    case True{{}}: h
    case False{{}}: {{==}}

def {X}_win_none(buf: B.Buf, +m: U32, h: {{{r}.{X}_decode_in(buf, m) == (buf, None{{}}) : {T}}})
    -> {{{r}.{X}_decode(buf, m) == (buf, None{{}}) : {T}}}:
  match buf:
    case B.Buf{{ws, +n}}: {X}_win_none_go(U32.is_le(m, n), B.Buf{{ws, n}}, m, h)

def {X}_win_some_go(ok: Bool, buf: B.Buf, +m: U32, r: {T}, hle: {{ok == True{{}} : Bool}}, h: {{{r}.{X}_decode_in(buf, m) == r : {T}}})
    -> {{{r}.{X}_dwgo(ok, buf, m) == r : {T}}}:
  match ok:
    case True{{}}: h
    case False{{}}: Empty.absurd({{{r}.{X}_dwgo(False{{}}, buf, m) == r : {T}}}, W.false_true(hle))

def {X}_win_some(buf: B.Buf, +m: U32, r: {T}, hle: {{U32.is_le(m, L.bsz(buf)) == True{{}} : Bool}}, h: {{{r}.{X}_decode_in(buf, m) == r : {T}}})
    -> {{{r}.{X}_decode(buf, m) == r : {T}}}:
  match buf:
    case B.Buf{{ws, +n}}: {X}_win_some_go(U32.is_le(m, n), B.Buf{{ws, n}}, m, r, hle, h)

def {X}_win_out_go(ok: Bool, buf: B.Buf, +m: U32, hgt: {{ok == False{{}} : Bool}})
    -> {{{r}.{X}_dwgo(ok, buf, m) == (buf, None{{}}) : {T}}}:
  match ok:
    case True{{}}: Empty.absurd({{{r}.{X}_dwgo(True{{}}, buf, m) == (buf, None{{}}) : {T}}}, W.false_true(hgt))
    case False{{}}: {{==}}

def {X}_win_out(buf: B.Buf, +m: U32, hgt: {{U32.is_le(m, L.bsz(buf)) == False{{}} : Bool}})
    -> {{{r}.{X}_decode(buf, m) == (buf, None{{}}) : {T}}}:
  match buf:
    case B.Buf{{ws, +n}}: {X}_win_out_go(U32.is_le(m, n), B.Buf{{ws, n}}, m, hgt)
"""


def outputs():
    out = {LIBRARY: library()}
    files, syms, _ = RR.index()
    for name, op in files:
        if op != 'decode_ssz':
            continue
        text = (ROOT / 'types' / RR.split_rel(name, op)).read_text()
        m = DECODE.search(text)
        assert m, name
        X, rep = m.group(1), m.group(2)
        alias = rep.split('.')[0]
        im = re.search(rf'^import (\S+) as {alias}$', text, re.M)
        rep_import = None
        if im:
            p = im.group(1)
            p = '../../types/' + p[2:] if p.startswith('./') else ('../' + p if p.startswith('../') else p)
            rep_import = f'import {p} as {alias}'
        out[ROOT / f'proofs/obj/decode_window_{name}_generated.bend'] = module(name, X, rep, rep_import)
    return out


def main():
    out = outputs()
    if finish(out, ('decode_window_*_generated.bend',), 'stale: ', 'decode window lemmas are current', '--check' in sys.argv):
        print(f'{len(out)} files')


if __name__ == '__main__':
    main()
