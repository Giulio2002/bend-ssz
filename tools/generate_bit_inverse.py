"""Intrinsic octet inverse lemmas and arbitrary-list structural induction."""
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

'''
s+='law octet_inverse:\n'+''.join(f'  for +{x}: Bool\n' for x in b)+f'  {{O.octet(P.octet({args})) == [{args}] : +List<Bool>}}\ndef octet_inverse({args}):\n  match '+' '.join(b)+':\n'
for x in range(256):s+='    case '+' '.join('True{}' if x>>i&1 else 'False{}' for i in range(8))+': {==}\n'
s+='''
law embedded_reencode:
  for +w: Word(8n)
  {P.pack(O.octet(Words.embed8(w))) == [Words.embed8(w)] : +List<U32>}
def embedded_reencode(w):
  match w:
'''
for x in range(256):
 pat='WNil{}'
 for i in reversed(range(8)):pat='WCon{'+('True{}' if x>>i&1 else 'False{}')+', '+pat+'}'
 s+=f'    case {pat}: {{==}}\n'
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
