#!/usr/bin/env python3
"""Symbolic capacity laws: the allocation depth of an encoder or checked serializer, pinned without computing
anything (a continuation of buffer_capacity.py, whose default-object law is too slow past 2^10 words).

    python3 codegen/proofs/mutation_coverage/symbolic_buffer_capacity.py [--check]

`O.out_at(d)` is a zero array of 2^d words and word indices wrap modulo its size, so an encoder whose `d` is one too
small silently overwrites its own head. buffer_capacity.py states, for the default object, that the serializer's
buffer is the encoder's; computing it costs 74 s at 2^13 words and 406 s at 2^15 (Blob), and does not finish for
HistoricalBatch (2^17).

proofs/mutation_coverage/capacity/<X>_symbolic.bend (one module per name) holds, for every name whose serializer or encoder allocates with
`O.out_at(d)` (an encoder that reports its size inline, `O.out_done(N, P_put(O.out_at(d), 0, o))`, is stated the same way):

  <X>_serialize_capsym(o)   : {T.X_serialize(o) == T.X_senc_out(T.P_putk(O.out_at(dn), 0, o)) : ..}
  <X>_encode_capsym(o)      : {T.X_encode(o)    == T.X_enc_out(T.P_put(O.out_at(dn), 0, o)) : ..}

for a variable `o`. Both sides are stuck on the validity check (or the object), so the statement is by `{==}` in a
second: it compares the definition's allocation with `dn`, the least depth whose 2^d words hold the schema's
encoded size (ceil(N / 4) words, N the literal size the definition itself reports: `ser_done(.., N, ..)` /
`out_done(N, ..)`; the actual depth when the size is not a literal). A smaller or larger allocation changes the
array in the stuck term and so the statement's value; no write loop is evaluated, so the cost is independent of the
size of the name (1 s for Blob).

Named so that object_api_coverage_gate files them under serialize_valid and encode_eval: they land in the name's encode facade. The
object_api_coverage_gate scans proofs/mutation_coverage after proofs/obj, so these modules come after every other proving file of encode_eval: a facade's first proving import stays
the name's own spec/encx file (block_and_light_client_bridges/test_struct_and_union_bridges read it as P0). Consequence: a facade that holds a heavy statement
before this law (LightClientBootstrap_encode) still evaluates it first on a mutant.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core.law_module_helpers import law_module, per_name  # noqa: E402
from codegen.core import mutation_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.collections.object_field_access_laws import qual  # noqa: E402

SER = re.compile(r'^def (\w+)_serialize\(o: ([\w.]+)\) -> ([^\n:]*): (\w+_senc_(?:out|put))\((\w+)_putk\(O\.out_at\((\d+)n\), 0, o\)\)$', re.M)
ENC = re.compile(r'^def (\w+)_encode\(o: ([\w.]+)\) -> ([^\n:]*): (\w+_enc_(?:out|put))\((\w+_putn?)\(O\.out_at\((\d+)n\), 0, o\)\)$', re.M)
INL = re.compile(r'^def (\w+)_encode\((\+?o: [\w.]+)\) -> B\.Buf: O\.out_done\((\d+), (\w+_put)\(O\.out_at\((\d+)n\), 0, o\)\)$', re.M)
MISMATCH = []


def depth(N):
    d = 0
    while (1 << d) < (N + 3) // 4:
        d += 1
    return d


def schema_depth(text, wrapper, pat, X, actual):
    """the depth the literal size N in `wrapper`'s definition needs, or the actual depth when there is no literal"""
    m = re.search(rf'^def {wrapper}\(.*?(?=^def |\Z)', text, re.M | re.S)
    n = re.search(pat, m.group(0)) if m else None
    if not n:
        return actual
    d = depth(int(n.group(1)))
    if d != actual:
        MISMATCH.append((X, wrapper, actual, d))
        return actual
    return d


def ret_type(r):
    return ' & '.join(t.strip() if t.strip().startswith('B.') else qual(t.strip()) for t in r.split(' & '))


def name_laws(runtime):
    text = RR.mono_text(runtime)
    out = {}
    for m in SER.finditer(text):
        X, ty, ret, wrap, P, d = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5), int(m.group(6))
        dd = schema_depth(text, wrap, r'ser_done\(O\.is_poisoned\(fl\), (\d+),', X, d)
        out.setdefault(X, []).append(
            f'def {X}_serialize_capsym(o: {qual(ty)}) -> {{T.{X}_serialize(o) == T.{wrap}(T.{P}_putk(O.out_at({dd}n), 0, o)) : {ret_type(ret)}}}:\n  {{==}}')
    for m in ENC.finditer(text):
        X, ty, ret, wrap, put, d = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5), int(m.group(6))
        dd = schema_depth(text, wrap, r'out_done\((\d+),', X, d)
        out.setdefault(X, []).append(
            f'def {X}_encode_capsym(o: {qual(ty)}) -> {{T.{X}_encode(o) == T.{wrap}(T.{put}(O.out_at({dd}n), 0, o)) : {ret_type(ret)}}}:\n  {{==}}')
    for m in INL.finditer(text):
        X, par, N, put, d = m.group(1), m.group(2), int(m.group(3)), m.group(4), int(m.group(5))
        dd = depth(N)
        if dd != d:
            MISMATCH.append((X, 'encode', d, dd))
            dd = d
        pty = par.split(': ')[1]
        out.setdefault(X, []).append(
            f'def {X}_encode_capsym({par.split(": ")[0]}: {qual(pty)}) -> {{T.{X}_encode(o) == O.out_done({N}, T.{put}(O.out_at({dd}n), 0, o)) : B.Buf}}:\n  {{==}}')
    return out


def module(tmod, X, laws):
    return law_module('symbolic_buffer_capacity', [f'# {X}: the allocation depth of its encoder and checked serializer is the schema\'s',
                                               '# (found by mutation testing; codegen/proofs/mutation_coverage/symbolic_buffer_capacity.py). By computation on a variable object.'],
                      laws, tmod)


def main():
    out, cnt = per_name(name_laws, module, lambda X: LAYOUT.module_path('capacity', f'{X}_symbolic'))
    if LAYOUT.finish(RR.rewire_out(out), 'symbolic_buffer_capacity', ('capacity',), 'stale symbolic capacity laws: ', 'capsym laws are current', '--check' in sys.argv):
        print(f'{cnt} laws; depth differs from the size-derived one: {MISMATCH}')


if __name__ == '__main__':
    main()
