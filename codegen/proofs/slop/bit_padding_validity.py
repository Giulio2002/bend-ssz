#!/usr/bin/env python3
"""The bit-list validity table and the byte count of a bit list (manual spec-mutation audit: bv03/02, s01/01).

    python3 codegen/proofs/slop/bit_padding_validity.py [--check]

Public counterexamples. (bv03/02) `T.bitlist_5_serialize(O.Bits{[32], 5})`: a Bitlist[5] of 5 bits whose storage has the stray bit 5
set (the delimiter's place) must be refused; the validity pass `O.bits_ok` checks `bits_above_zero(k & 31, last word)`, and an
entry of that 32-entry table with a wrong mask accepts it. (s01/01) `T.progbitlist_hash_tree_root(h, O.Bits{ws, 4294967295})`
takes the byte count of 2^32 - 1 bits: ceil(n / 8) = 536870912, which `(n + 7) >> 3` in 32-bit arithmetic wraps to 0.

For every name X whose validity pass is `O.bits_ok` (every bit list, the progressive one, the Fulu bit lists) and for the
bit vector that closes with `O.bitvec_tail` (Bitvector[1281]), proofs/slop/validity/<runtime>_<X>_bits.bend holds

  <X>_serialize_vbits_table_<r>()   r = 0 .. 31: `O.bits_above_zero(r, x)` is True exactly when bits r .. 31 of x are zero,
      stated on the 32 words 2^b: the conjunction over b of (b >= r ? not bits_above_zero(r, 2^b) : bits_above_zero(r, 2^b)).
      Every bit of every entry's mask is pinned; an entry that is too narrow, too wide or shifted fails.
  <X>_serialize_vbits_nbytes()      `O.bits_nbytes(n)` is ceil(n / 8) at the edges of the U32 range (0, 1, 7, 8, 9, 2^32 - 9,
      2^32 - 8, 2^32 - 7, 2^32 - 1): a (n + 7) >> 3 that wraps above 2^32 - 8 gives 0 there.

They are named so that api_gate files them under serialize_valid (the facade of X's encoder).
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

NBYTES = [(n, (n + 7) // 8) for n in (0, 1, 7, 8, 9, 2 ** 32 - 9, 2 ** 32 - 8, 2 ** 32 - 7, 2 ** 32 - 1)]   # ceil(n / 8), exact


def table_law(X, r):
    terms = []
    for b in range(32):
        call = f'O.bits_above_zero({r}, {1 << b})'
        terms.append(f'Bool.not({call})' if b >= r else call)
    c = terms[-1]
    for t in reversed(terms[:-1]):
        c = f'Bool.and({t}, {c})'
    return f'def {X}_serialize_vbits_table_{r}()\n    -> {{{c} == True{{}} : Bool}}:\n  {{==}}'


def access_law(X, i):
    """the bit accessors on a list of 40 bits: the bit written at i reads back at i and at no neighbour (word and bit position)"""
    s = f'O.bits_set(O.bits_zeros(40), {i}, True{{}})'
    g = lambda j: f'Pair.snd(O.Bits, Bool, O.bits_get({s}, {j}))'   # noqa: E731
    return (f'def {X}_serialize_vbits_access_{i}()\n    -> {{({g(i)}, ({g(i - 1) if i else g(i + 1)}, {g(i + 1)})) == (True{{}}, (False{{}}, False{{}})) : Bool & (Bool & Bool)}}:\n  {{==}}')


def nbytes_law(X, name):
    terms = [f'U32.is_eq(O.bits_nbytes({n}), {want})' for n, want in NBYTES]
    c = terms[-1]
    for t in reversed(terms[:-1]):
        c = f'Bool.and({t}, {c})'
    return f'def {name}()\n    -> {{{c} == True{{}} : Bool}}:\n  {{==}}'


def module(X, laws):
    L = ['import Base', 'import ../../src/obj.bend as O', '', writer.header('bit_padding_validity'),
         f'# {X}: the bit-padding table and the bit count of a bit list (manual spec-mutation audit; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)




def names_of(tx):
    """X of every name whose validity pass is bits_ok, or closes with bitvec_tail (X's checked serializer calls p_putk, p's validity)"""
    valid = {m.group(1): m.group(0) for m in re.finditer(r'^def (\w+)_valid\(o: O\.(?:Bits|Words)\) -> [^\n:]*: [^\n]*$', tx.text, re.M)}
    out = []
    for m in re.finditer(r'^def (\w+)_serialize\(o: O\.(?:Bits|Words)\) ', tx.text, re.M):
        X = m.group(1)
        body = '\n'.join(tx.blk[n] for n in (f'{X}_serialize', f'{X}_senc_put', f'{X}_senc_out', f'{X}_senc_go', f'{X}_senc_sized') if n in tx.blk)
        p = re.search(r'\b(\w+)_putk\(', body)
        if p and p.group(1) in valid and ('O.bits_ok(' in valid[p.group(1)] or 'O.bitvec_tail(' in valid[p.group(1)]):
            out.append(X)
    return out


def outputs():
    out = {}
    for runtime in ('fulu', 'generic'):
        tx = MC.Text(runtime)
        for X in names_of(tx):
            laws = [table_law(X, r) for r in range(32)] + [nbytes_law(X, f"{X}_serialize_vbits_nbytes"), nbytes_law(X, f"{X}_vbits_nbytes")] + [access_law(X, i) for i in (0, 1, 7, 8, 15, 16, 17, 31, 32, 33, 39)]
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_bits')] = module(X, laws)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'bit_padding_validity', ('validity',), 'stale bit padding laws: ', 'bit padding laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
