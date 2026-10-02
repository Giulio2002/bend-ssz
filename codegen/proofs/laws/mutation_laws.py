#!/usr/bin/env python3
"""Laws that pin two parts of the runtime the other laws of a name leave to its callers, found by mutation testing
(docs/MUTATION_PROOFS.md): the reported size of a boxed fixed-size object, and the upper bound of a byte vector's
validity check.

    python3 codegen/proofs/laws/mutation_laws.py [--check]

proofs/obj/mutation_laws_<fulu|generic>.bend holds

  <X>_encoded_size(o: O.Boxed<X>, v: X)      for every name whose size pass reports a literal size
      : {size(T.<X>_bx_size(o)) == size(T.<X>_encode(v))}
      the size the boxed size pass reports (what the containers that hold the name add up) is the length of the
      encoding of any object of the name. A wrong constant in the size pass now changes this statement's value.
  <X>_serialize_over()                       for every byte vector whose validity pass is `O.words_ok(o, N, N, False{}, 1)`
      : {T.<X>_serialize(O.Words{ws, N + 1}) == (O.Words{ws, N + 1}, O.refused())}  with ws = O.out_at(k), k the least
      depth whose storage holds N + 1 bytes (the check reads the storage's size, so the statement needs a concrete one:
      with room the bound is the only thing that refuses it)
      one byte more than the vector holds is refused by the checked serializer.
  <X>_serialize_in()                         the same names up to 4096 bytes (Blob's encoding is too big to compute): a vector of exactly N bytes is serialized to its encoding
      : {T.<X>_serialize(O.Words{ws, N}) == (fst(T.<X>_encode(..)), O.encoded(snd(T.<X>_encode(..))))}  (the lower
      bound: a check that refuses N bytes would pass `_over` and fail here). The statements
      that existed pinned the accepted length (`hvo`, `valid_default`) but not the first refused one.

Both are by computation. They are named so that api_gate files them under encoded_size and serialize_valid, so
they reach each name's proofs/api/<X>_encode_ssz_proof_generated.bend (which tools/check.sh and the mutation
harness check).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core.shared_laws import OBJ, RUNTIMES, finish  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402

IN_MAX = 4096  # bytes: `_in` computes the whole encoding (Blob's 131072 bytes did not check in 600 s)
BX = re.compile(r'^def (\w+)_bx_size\(o: O\.Boxed<([^\n]+)>\) -> [^\n]*: \(o, (\d+)\)$', re.M)
SER = re.compile(r'^def (\w+)_serialize\(o: ([\w.]+)\) -> [^\n:]*: \1_senc_out\((\w+)_putk\(O\.out_at\(\d+n\), 0, o\)\)$', re.M)


def valid_bytes(text, p):
    """N when `p`'s validity pass is O.words_ok(o, N, N, False{}, 1): a byte vector of N bytes"""
    m = re.search(rf'^def {p}_valid\(o: O\.Words\) -> [^\n:]*: O\.words_ok\(o, (\d+), (\d+), False\{{\}}, 1\)$', text, re.M)
    return int(m.group(1)) if m and m.group(1) == m.group(2) else None


def module(runtime, tmod):
    text = RR.mono_text(runtime)
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('mutation_laws'),
         '# Laws that pin the reported size of a boxed fixed-size object and the first refused length of a byte vector',
         '# (found by mutation testing; docs/MUTATION_PROOFS.md). Each is by computation.', '']
    w = L.append
    enc = set(re.findall(r'^def (\w+)_encode\(', text, re.M))
    n = 0
    for X, rep, size in BX.findall(text):
        if X not in enc:
            continue
        R = qual(rep)
        w(f'# ---- {X}: the boxed size pass reports the encoding\'s {size} bytes ----')
        w(f'def {X}_encoded_size(o: O.Boxed<{R}>, v: {R})')
        w(f'    -> {{Pair.snd(O.Boxed<{R}>, U32, T.{X}_bx_size(o)) == Pair.snd(B.Buf, U32, B.size(T.{X}_encode(v))) : U32}}:')
        w('  {==}')
        n += 1
    for X, rep, P in SER.findall(text):
        N = valid_bytes(text, P)
        if rep != 'O.Words' or N is None:
            continue
        w(f'# ---- {X}: {N + 1} bytes is not a {N}-byte vector ----')
        k = 0
        while (1 << k) < ((N + 4) >> 2) + 1:
            k += 1
        ws = f'O.out_at({k}n)'
        w(f'def {X}_serialize_over() -> {{T.{X}_serialize(O.Words{{{ws}, {N + 1}}}) == (O.Words{{{ws}, {N + 1}}}, O.refused()) : O.Words & O.Encoded}}:')
        w('  {==}')
        if N > IN_MAX:
            n += 1
            continue
        k = 0
        while (1 << k) < (N >> 2) + 1:
            k += 1
        o = f'O.Words{{O.out_at({k}n), {N}}}'
        enc_ = f'T.{X}_encode({o})'
        w(f'def {X}_serialize_in() -> {{T.{X}_serialize({o}) == (Pair.fst(O.Words, B.Buf, {enc_}), O.encoded(Pair.snd(O.Words, B.Buf, {enc_}))) : O.Words & O.Encoded}}:')
        w('  {==}')
        n += 1
    return '\n'.join(L) + '\n', n


def main():
    out, cnt = {}, []
    for runtime, tmod in RUNTIMES:
        t, n = module(runtime, tmod)
        if n:
            out[OBJ / f'mutation_laws_{runtime}.bend'] = t
        cnt.append(n)
    if finish(RR.rewire_out(out), ('mutation_laws_*.bend',), 'stale mutation laws: ', 'mutation laws are current', '--check' in sys.argv):
        print(f'{cnt} laws')


if __name__ == '__main__':
    main()
