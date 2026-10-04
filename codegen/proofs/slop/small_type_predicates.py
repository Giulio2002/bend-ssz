#!/usr/bin/env python3
"""Small shared predicates of the decoders and encoders that no statement reads back (manual spec-mutation audit, round 3: x02, x03, x07, x11, u01).

    python3 codegen/proofs/slop/small_type_predicates.py [--check]

Public counterexamples: the uint16 decode of the bytes 34 12 answering 52 (the read keeps one byte); the decode of a bit list leaving the delimiter
set, clearing the wrong bit or the wrong word; the size of a Bitlist[k] answering floor(k / 8) bytes; a guarded child validation that is
`or`-ed into the running verdict; a union decoder that accepts selector 0 as the first arm. Each definition is shared by every type that decodes
or encodes the same way, so the laws state the shared definition on small concrete values, and are filed with the types that use it.

  uint16_decode_vread_u16_<off>          `O.rd_u16` of a buffer of known bytes at offsets 0 .. 3 (the aligned read and the three joins)
  <X>_decode_vbits_clear_<k>             (every bit list X) `O.bits_clear(k, (buf, ones))` clears bit k of an all-ones storage (k = 0, 9, 33, 40, 63)
  <X>_serialize_vbits_size               (every bit list X) `O.bits_size` of k bits is floor(k / 8) + 1 bytes (k = 0, 7, 8, 9, 64)
  <X>_serialize_vbits_sizek              (every bit list X) `O.bits_sizek`, the size pass of the checked serializer, of k bits on 4 words is floor(k / 8) + 1
                                         bytes, and the marker 2^32 - 1 at k = 128 (round 7 replay: bl04/02)
  <X>_decode_vand_pair                   (every container with a list of composites) `O.and_pair` is the conjunction, four cases
  <X>_decode_vsel_<tag>                  (every union X) the validator refuses the selectors 0 and one past the last arm and a selector with no payload,
                                         and accepts each fixed payload arm of zeros

Filed by api_gate under decode_offsets / serialize_valid (the `_decode_v...` and `_serialize_vbits_size` forms).
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
from codegen.proofs.slop.collection_guards import owners_of  # noqa: E402

W0, W1 = 0xBBAA1234, 0x0000DDCC           # the bytes 34 12 AA BB CC DD


def array(words, log=1):
    arr = f'Array.new(U32, {log}n, 0)'
    for i, v in enumerate(words):
        arr = f'Array.set(U32, {arr}, {i}, {v})'
    return arr


def read_laws():
    data = [0x34, 0x12, 0xAA, 0xBB, 0xCC, 0xDD, 0, 0]
    out = []
    for off in range(4):
        want = data[off] | (data[off + 1] << 8)
        out.append((f'read_u16_{off}', f'def uint16_decode_vread_u16_{off}()\n    -> {{Pair.snd(B.Buf, U32, O.rd_u16(B.Buf{{{array([W0, W1])}, 8}}, {off})) == {want} : U32}}:\n  {{==}}'))
    return out


def bits_laws(X):
    out = []
    for k in (0, 9, 33, 40, 63):
        words = [0xFFFFFFFF, 0xFFFFFFFF]
        words[k >> 5] &= ~(1 << (k & 31)) & 0xFFFFFFFF
        out.append((f'bits_clear_{k}', f'def {X}_decode_vbits_clear_{k}()\n    -> {{Pair.snd(B.Buf, O.Bits, O.bits_clear({k}, (B.empty(), O.Words{{{array([0xFFFFFFFF, 0xFFFFFFFF])}, 64}}))) == O.Bits{{{array(words)}, {k}}} : O.Bits}}:\n  {{==}}'))
    for_k = (0, 7, 8, 9, 64)
    items = [f'Pair.snd(O.Bits, U32, O.bits_size(O.Bits{{{array([0, 0])}, {k}}}))' for k in for_k]
    want = [str(k // 8 + 1) for k in for_k]

    def nest(xs):
        return xs[0] if len(xs) == 1 else f'({xs[0]}, {nest(xs[1:])})'
    ty = 'U32'
    for _ in for_k[1:]:
        ty = f'U32 & ({ty})'
    out.append(('bits_size', f'def {X}_serialize_vbits_size()\n    -> {{{nest(items)} == {nest(want)} : {ty}}}:\n  {{==}}'))
    # the size pass of the checked serializer (round 7 replay: bl04/02): `O.bits_sizek` on a storage of 4 words is floor(k / 8) + 1 too, and the
    # marker when the storage cannot hold the delimiter word (k = 128)
    for_k = (0, 7, 8, 9, 64, 127, 128)
    items = [f'Pair.snd(O.Bits, U32, O.bits_sizek(O.Bits{{{array([0, 0, 0, 0], 2)}, {k}}}))' for k in for_k]
    want = [str(k // 8 + 1) if (k >> 5) + 1 <= 4 else '4294967295' for k in for_k]
    ty = 'U32'
    for _ in for_k[1:]:
        ty = f'U32 & ({ty})'
    out.append(('bits_sizek', f'def {X}_serialize_vbits_sizek()\n    -> {{{nest(items)} == {nest(want)} : {ty}}}:\n  {{==}}'))
    return out


def and_law(X):
    cases = [(a, b) for a in ('True', 'False') for b in ('True', 'False')]
    items = [f'Pair.snd(B.Buf, Bool, O.and_pair({a}{{}}, (B.empty(), {b}{{}})))' for a, b in cases]
    want = ['True{}' if (a, b) == ('True', 'True') else 'False{}' for a, b in cases]
    return ('and_pair', f'def {X}_decode_vand_pair()\n    -> {{({items[0]}, ({items[1]}, ({items[2]}, {items[3]}))) == ({want[0]}, ({want[1]}, ({want[2]}, {want[3]}))) : Bool & (Bool & (Bool & Bool))}}:\n  {{==}}')


def union_laws(tx, X, t):
    """the selector tests of a union validator (round 3: u01/15)"""
    ok = f'T.{X}_ok'
    sels = list(t.selectors)
    out = []

    def buf(word, n):
        return f'B.Buf{{Array.new(U32, 0n, {word}), {n}}}'

    def law(tag, items, want):
        def nest(xs):
            return xs[0] if len(xs) == 1 else f'({xs[0]}, {nest(xs[1:])})'
        ty = 'Bool'
        for _ in items[1:]:
            ty = f'Bool & ({ty})'
        out.append((f'sel_{tag}', f'def {X}_decode_vsel_{tag}()\n    -> {{{nest(items)} == {nest(want)} : {ty}}}:\n  {{==}}'))
    refuse = sorted({0, max(sels) + 1, 255} - set(sels))
    law('outside', [f'Pair.snd(B.Buf, Bool, {ok}({buf(s, 2)}, 0, 2))' for s in refuse], ['False{}'] * len(refuse))
    law('empty', [f'Pair.snd(B.Buf, Bool, {ok}({buf(s, 1)}, 0, 1))' for s in sels[:1]], ['False{}'])
    fixed = [(s, ft) for s, (fn, ft) in zip(sels, t.fields) if ft.fixed() and 1 <= ft.fixed_size() <= 3]
    if fixed:
        law('arms', [f'Pair.snd(B.Buf, Bool, {ok}({buf(s, 1 + ft.fixed_size())}, 0, {1 + ft.fixed_size()}))' for s, ft in fixed], ['True{}'] * len(fixed))
    return out


def module(tmod, X, laws, comment):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '', writer.header('small_type_predicates'),
         f'# {X}: {comment} (manual spec-mutation audit, round 3; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def smallest(tx, names):
    return sorted(names, key=lambda X: (sum(1 for n in tx.blk if n.startswith(X + '_')), X))


def outputs():
    out = {}
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        if runtime == 'generic' and 'uint16_decode' in tx.text:
            out[LAYOUT.module_path('validity', 'generic_uint16_read')] = module(tmod, 'uint16', [t for _, t in read_laws()], 'a uint16 is the low two bytes of the word read')
        for m in re.finditer(r'^def (\w+)_read\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & O\.Bits: O\.bits_in\(buf, off, len\)', tx.text, re.M):
            for X in smallest(tx, owners_of(tx, m.group(1)))[:1]:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_bitops_{m.group(1)}')] = module(tmod, X, [t for _, t in bits_laws(X)], 'the decode and size of a bit list')
        ands = set()
        for n, b in tx.blk.items():
            if 'O.and_pair(' in b:
                p = n
                while p and f'{p}_default' not in tx.blk:      # the collection prefix of the block's name
                    p = p.rsplit('_', 1)[0] if '_' in p else ''
                if p:
                    ands |= set(owners_of(tx, p))
        for X in smallest(tx, ands)[:3]:
            out[LAYOUT.module_path('validity', f'{runtime}_{X}_and_pair')] = module(tmod, X, [and_law(X)[1]], 'the guarded child validation is a conjunction')
        for X, t in names.items():
            if t.kind == 'cunion' and f'{X}_ok' in tx.blk:
                laws = union_laws(tx, X, t)
                if laws:
                    out[LAYOUT.module_path('validity', f'{runtime}_{X}_selectors')] = module(tmod, X, [l for _, l in laws], 'the selector tests of the union validator')
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'small_type_predicates', ('validity',), 'stale small predicate laws: ', 'small predicate laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
