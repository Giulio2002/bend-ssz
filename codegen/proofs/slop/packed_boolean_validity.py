#!/usr/bin/env python3
"""Every byte of a packed boolean vector or list is 0 or 1 (manual spec-mutation audit: b04/01).

    python3 codegen/proofs/slop/packed_boolean_validity.py [--check]

Public counterexample: `T.vec_bool_5_serialize(O.Words{ws, 5})` with a storage word holding the byte 2 (a boolean byte of 2 is not
a boolean; `O.Words{ws, n}` is the representation's own constructor). The validity pass of every packed boolean collection ends in
`O.bools_ok`, whose scan `bo_go` accepts a word only if `x & 0xFEFEFEFE == 0`; a mask that lets another bit through accepts it.

For every name X whose validity is `O.bools_ok(O.words_ok(o, lo, hi, big, 1))` (vec_bool_N, proglist_bool)
proofs/slop/validity/<runtime>_<X>_booleans.bend holds, on a storage of n bytes (the vector's own length; 5 bytes for a
list: one whole word and a partial one),

  <X>_serialize_vbool_ok()           the bytes 1, 1, 1, 1, ... are valid                        (the mask is not too strong)
  <X>_serialize_vbool_<v>_at_<j>()   the byte v (2, 4, 128) at byte position j (each of the four bytes of word 0, the last byte
                                     of the storage, and byte 4, the first of word 1, when n >= 5) makes the collection invalid:
      {Pair.snd(O.Words, Bool, T.p_valid(O.Words{ws, n})) == False{} : Bool}.

By computation (the storage is a zero array with one word set). They are named so that api_gate files them under serialize_valid.
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

VALID = re.compile(r'^def (\w+)_valid\(o: O\.Words\) -> O\.Words & Bool: O\.bools_ok\(O\.words_ok\(o, (\d+), (\d+), (True|False)\{\}, 1\)\)$', re.M)
BAD_VALUES = (2, 4, 128)
LIST_BYTES = 5


def storage(n, sets):
    """O.Words of n bytes: zeros with the given {word index: word}"""
    e = f'O.words_new({n})'
    for j, v in sorted(sets.items()):
        e = f'O.words_setw({e}, {j}, {v})'
    return e


def word_mask(n, j):
    """the bytes of word j that lie inside the first n bytes, as a mask"""
    k = min(4, n - 4 * j)
    return (1 << (8 * k)) - 1


def laws_of(X, p, n):
    ones = {j: 0x01010101 & word_mask(n, j) for j in range((n + 3) // 4)} if n <= 16 else {0: 0x01010101}
    laws = [(f'{X}_serialize_vbool_ok', storage(n, ones), 'True')]
    spots = sorted({j for j in range(min(n, 4))} | {n - 1} | ({4} if n >= 5 else set()))
    for v in BAD_VALUES:
        for j in spots:
            laws.append((f'{X}_serialize_vbool_{v}_at_{j}', storage(n, {j // 4: v << (8 * (j % 4))}), 'False'))
    return [f'def {nm}()\n    -> {{Pair.snd(O.Words, Bool, T.{p}_valid({w})) == {r}{{}} : Bool}}:\n  {{==}}' for nm, w, r in laws]


def module(tmod, X, laws):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('packed_boolean_validity'),
         f'# {X}: every byte of a packed boolean collection is 0 or 1 (manual spec-mutation audit; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        for m in VALID.finditer(tx.text):
            p, lo, hi, big = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4) == 'True'
            n = hi if lo == hi and not big else LIST_BYTES
            if n > 1024:
                continue
            names = [s.group(1) for s in re.finditer(r'^def (\w+)_serialize\(o: O\.Words\) -> [^\n:]*: [^\n]*\b' + re.escape(p) + r'_putk\(', tx.text, re.M)]
            if not names:      # the variable-length forms spell the writer in a helper of their own
                for s in re.finditer(r'^def (\w+)_serialize\(o: O\.Words\) ', tx.text, re.M):
                    body = '\n'.join(tx.blk[b] for b in (f'{s.group(1)}_serialize', f'{s.group(1)}_senc_go', f'{s.group(1)}_senc_sized') if b in tx.blk)
                    if re.search(r'\b' + re.escape(p) + r'_putk\(', body):
                        names.append(s.group(1))
            for X in names:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_booleans')] = module(tmod, X, laws_of(X, p, n))
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'packed_boolean_validity', ('validity',), 'stale packed boolean laws: ', 'packed boolean laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
