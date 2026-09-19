"""Generate intrinsic octet padding cases and an unbounded recursive step."""
from pathlib import Path
s='''import Base
import ../src/bit_packing.bend as P
import ./bit_delimiter.bend as L
import ./bit_padding.bend as A
import ./word_facts.bend as W

law pack_padding:
  for +bits: +List<Bool>
  for +padding: Nat
  for +bound: {Nat.is_le(padding, 7n) == True{} : Bool}
  for +alignment: {A.aligned(List.append(&2, Bool, bits, True{} <> L.zeros(padding, []))) == True{} : Bool}
  {P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(padding, []))) : +List<U32>}
def pack_padding(bits, padding, bound, alignment):
  match bits:
'''
b=[f'b{i}' for i in range(8)]
for n in range(9):
 pat='tail' if n==8 else 'Nil{}'
 for x in reversed(b[:n]):pat=f'Con{{{x}, {pat}}}'
 s+=f'    case {pat}:\n'
 if n==8:
  s+='      Equal.cong(+List<U32>, +List<U32>, xs => P.octet('+', '.join(b)+') <> xs, P.pack(List.append(&2, Bool, tail, [True{}])), P.pack(List.append(&2, Bool, tail, True{} <> L.zeros(padding, []))), pack_padding(tail, padding, bound, alignment))\n'
 else:
  s+='      match padding:\n'
  for q in range(9):
   patq=f'{q}n' if q<8 else '8n+p'
   s+=f'        case {patq}: '
   if q==7-n:s+='{==}\n'
   else:
    arg=patq if q<8 else '8n+p'
    s+=f'Empty.absurd({{P.pack(List.append(&2, Bool, bits, [True{{}}])) == P.pack(List.append(&2, Bool, bits, True{{}} <> L.zeros({arg}, []))) : +List<U32>}}, W.false_true('+('alignment' if q<8 else 'bound')+'))\n'
Path('proofs/bit_padding_pack.bend').write_text(s)
