#!/usr/bin/env python3
"""Pins the refusal branch of the length check of the list-shaped decoders, found by mutation testing
(`case False{}: (buf, False{})` of `P_ok_len` changed to `True{}`).

    python3 codegen/proofs/laws/okfalse_laws.py [--check]

`P_ok(buf, off, len) = P_ok_len(Bool.and(U32.is_eq(len, (U32.div(len, e) * e)), True{}), buf, off, len)`: the length of a
list of fixed-size elements must be a multiple of the element size. For an element of one byte (`U32.div(len, 1)`) the
test is always true, so the refusing branch of `P_ok_len` is never reached through `P_ok` (a proof that it is dead needs
`U32.div(x, 1) == x`, which the checker does not fold for a symbolic x). It is a definition of its own, so its refusal
is pinned directly:

proofs/obj/zokf_<X>.bend (one module per name whose decoder has that check; the z keeps it after the name's own proving files):

  <X>_okf_len(buf, off, len) : {T.P_ok_len(False{}, buf, off, len) == (buf, False{}) : B.Buf & Bool}

by computation. A check that accepts what it was told is false fails this statement. Named so that api_gate files it
under ok_eval (the decode facade).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re

from codegen.core import writer  # noqa: E402
from codegen.core.shared_laws import finish, per_name  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402


def name_laws(runtime):
    text = RR.mono_text(runtime)
    out = {}
    for m in re.finditer(r'^def (\w+)_decode\(buf: B\.Buf, \+size: U32\)[^\n]*\n  \w+\(size, (\w+)_ok\(buf, 0, size\)\)', text, re.M):
        X, P = m.group(1), m.group(2)
        ok = re.search(rf'^def {P}_ok\(buf: B\.Buf, \+off: U32, \+len: U32\)[^\n]*$', text, re.M)
        ol = re.search(rf'^def {P}_ok_len\(ok: Bool, buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & Bool:\n  match ok:\n    case True\{{\}}: [^\n]*\n    case False\{{\}}: \(buf, False\{{\}}\)$', text, re.M)
        if ok and ol and 'U32.div(len' in ok.group(0):
            out[X] = (f'def {X}_okf_len(buf: B.Buf, +off: U32, +len: U32) -> {{T.{P}_ok_len(False{{}}, buf, off, len) == (buf, False{{}}) : B.Buf & Bool}}:\n  {{==}}')
    return out


def module(tmod, X, law):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('okfalse_laws'),
         f'# {X}: the refusing branch of the length check of its decoder (found by mutation testing;',
         '# codegen/proofs/laws/okfalse_laws.py). By computation.', '', law, '']
    return '\n'.join(L)


def main():
    out, cnt = per_name(name_laws, module, 'zokf', weigh=lambda law: 1)
    if finish(out, ('zokf_*.bend',), 'stale ok-false laws: ', 'ok-false laws are current'):
        print(f'{cnt} laws')


if __name__ == '__main__':
    main()
