"""Intrinsic octet inverse lemmas and arbitrary-list structural induction. The octet
lemmas are symbolic in the eight bits (low_bit, octet_bits, octet_word): no
256-way case split is evaluated (was 1.8 s in each of 852 importing checks)."""
from pathlib import Path
b=[f'b{i}' for i in range(8)]
args=', '.join(b)
s='''import Base
import ../src/bit_packing.bend as P
import ../src/bit_decoding.bend as O
import ../src/bit_decode.bend as D
import ../spec/primitives.bend as Domain
import ./power_division.bend as Words
import ./word_split.bend as Split
import ./integer_decoding.bend as Integer
import ./primitive_invariants.bend as V
import ./word_facts.bend as WZ

'''

# Symbolic in the eight bits (no 256-way case splits): a byte's octet word has its
# bits at positions 0..7 (octet_word), and octet reads bit i back (octet_bits).
def wd(xs):
    t = 'WNil{}'
    for x in reversed(xs):
        t = 'WCon{' + x + ', ' + t + '}'
    return t
W8 = wd(b)
E8 = f'Words.embed8({W8})'
F = 'False{}'
bsig = ', '.join(f'+{x}: Bool' for x in b)
s += """def and_true(+x: Bool) -> {Bool.and(x, True{}) == x : Bool}:
  match x:
    case True{}: {==}
    case False{}: {==}

def or_false(+x: Bool) -> {Bool.or(x, False{}) == x : Bool}:
  match x:
    case True{}: {==}
    case False{}: {==}

# The low bit of any word, read as octet reads it.
law low_bit:
  for +x: Bool
  for +t: Word(31n)
  {U32.is_eq(U32.and(U32{WCon{x, t}}, 1), 1) == x : Bool}
def low_bit(x, t):
  match x:
    case True{}:
      %Equal.sym(Word(31n), Word.and(31n, t, Word.zero(31n)), Word.zero(31n), WZ.and_zero(31n, t)) : {U32.is_eq(U32{WCon{True{}, _}}, 1) == True{} : Bool}
      {==}
    case False{}:
      %Equal.sym(Word(31n), Word.and(31n, t, Word.zero(31n)), Word.zero(31n), WZ.and_zero(31n, t)) : {U32.is_eq(U32{WCon{False{}, _}}, 1) == False{} : Bool}
      {==}

"""
term = lambda k: f'U32.is_eq(U32.and(U32.shrn({E8}, {k}n), 1), 1)'
s += f'law octet_bits:\n' + ''.join(f'  for +{x}: Bool\n' for x in b) + f'  {{O.octet({E8}) == [{args}] : +List<Bool>}}\ndef octet_bits({args}):\n'
for k in range(8):
    T = wd(b[k + 1:] + [F] * (24 + k))
    row = b[:k] + ['_'] + [term(m) for m in range(k + 1, 8)]
    s += f'  %Equal.sym(Bool, {term(k)}, b{k}, low_bit(b{k}, {T})) :\n    {{[{", ".join(row)}] == [{args}] : +List<Bool>}}\n'
s += '  {==}\n\n'
for k in range(8):
    Z = 'U32{' + wd([F] * k + ['x'] + [F] * (31 - k)) + '}'
    s += f'def pick{k}(+x: Bool) -> {{Bool.pick(U32, x, {1 << k}, 0) == {Z} : U32}}:\n  match x:\n    case True{{}}: {{==}}\n    case False{{}}: {{==}}\n'
s += '\n'
def chain(ws):
    t = '0'
    for x in reversed(ws):
        t = f'U32.or({x}, {t})'
    return t
picks = [f'Bool.pick(U32, b{k}, {1 << k}, 0)' for k in range(8)]
zs = ['U32{' + wd([F] * k + [f'b{k}'] + [F] * (31 - k)) + '}' for k in range(8)]
s += f'law octet_word:\n' + ''.join(f'  for +{x}: Bool\n' for x in b) + f'  {{P.octet({args}) == {E8} : U32}}\ndef octet_word({args}):\n'
for k in range(8):
    cur = zs[:k] + ['_'] + picks[k + 1:]
    s += f'  %Equal.sym(U32, {picks[k]}, {zs[k]}, pick{k}(b{k})) :\n    {{{chain(cur)} == {E8} : U32}}\n'
for k in range(8):
    cur = b[:k] + ['_'] + [f'Bool.or(b{m}, False{{}})' for m in range(k + 1, 8)]
    s += f'  %Equal.sym(Bool, Bool.or(b{k}, False{{}}), b{k}, or_false(b{k})) :\n    {{U32{{{wd(cur + [F] * 24)}}} == {E8} : U32}}\n'
s += '  {==}\n\n'
s += 'law octet_inverse:\n' + ''.join(f'  for +{x}: Bool\n' for x in b) + f'  {{O.octet(P.octet({args})) == [{args}] : +List<Bool>}}\ndef octet_inverse({args}):\n'
s += f'  %Equal.sym(U32, P.octet({args}), {E8}, octet_word({args})) : {{O.octet(_) == [{args}] : +List<Bool>}}\n  octet_bits({args})\n'
s += """
law embedded_reencode:
  for +w: Word(8n)
  {P.pack(O.octet(Words.embed8(w))) == [Words.embed8(w)] : +List<U32>}
def embedded_reencode(w):
  match w:
"""
s += f'    case {wd(["+" + x for x in b])}:\n'
s += f'      %Equal.sym(+List<Bool>, O.octet({E8}), [{args}], octet_bits({args})) : {{P.pack(_) == [{E8}] : +List<U32>}}\n'
s += f'      %Equal.sym(U32, P.octet({args}), {E8}, octet_word({args})) : {{[_] == [{E8}] : +List<U32>}}\n'
s += '      {==}\n'
s+='''
law octet_reencode:
  for +x: U32
  for e: {U32.is_lt(x, 256) == True{} : Bool}
  {P.pack(O.octet(x)) == [x] : +List<U32>}
def octet_reencode(x, e):
  %Equal.sym(U32, x, Words.embed8(Split.take(8n, 32n, Words.bits(x))), Integer.byte_shape(x, e)) : {P.pack(O.octet(_)) == [_] : +List<U32>}
  embedded_reencode(Split.take(8n, 32n, Words.bits(x)))

law repack_expanded:
  for +xs: +List<U32>
  for +e: {Domain.bytes_domain(xs) == True{} : Bool}
  {P.pack(D.expand(xs)) == xs : +List<U32>}
def repack_expanded(xs, e):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %octet_reencode(h, V.and_left(U32.is_lt(h, 256), Domain.bytes_domain(t), e)) :
        {P.pack(D.expand(xs)) == List.append(&2, U32, _, t) : +List<U32>}
      %repack_expanded(t, V.and_right(U32.is_lt(h, 256), Domain.bytes_domain(t), e)) :
        {P.pack(D.expand(xs)) == List.append(&2, U32, P.pack(O.octet(h)), _) : +List<U32>}
      {==}

law take_packed:
  for +bits: +List<Bool>
  {D.take(List.length(&2, Bool, bits), D.expand(P.pack(bits))) == Some{bits} : Maybe<&2, +List<Bool>>}
def take_packed(bits):
  match bits:
    case Nil{}: {==}
'''
for size in range(1,9):
 tail='tail' if size==8 else 'Nil{}'
 for x in reversed(b[:size]):tail=f'Con{{{x}, {tail}}}'
 vals=b[:size]+['False{}']*(8-size);args=', '.join(vals)
 rest='P.pack(tail)' if size==8 else '[]'
 s+=f'    case {tail}:\n'
 s+=f'      %Equal.sym(+List<Bool>, O.octet(P.octet({args})), [{args}], octet_inverse({args})) : {{D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand({rest}))) == Some{{bits}} : Maybe<&2, +List<Bool>>}}\n'
 if size<8:s+='      {==}\n'
 else:
  cons='r'
  for x in reversed(b):cons=f'D.cons({x}, {cons})'
  s+=f'      Equal.cong(Maybe<&2, +List<Bool>>, Maybe<&2, +List<Bool>>, r => {cons}, D.take(List.length(&2, Bool, tail), D.expand(P.pack(tail))), Some{{tail}}, take_packed(tail))\n'
Path('proofs/bit_inverse.bend').write_text(s)
