from pathlib import Path
# Intrinsic eight-bit elimination, independent of fixtures.
b=[f'b{i}' for i in range(8)]
args=', '.join(b)
s='import Base\n\ndef octet(+x: U32) -> +List<Bool>:\n  ['+', '.join(f'U32.is_eq(U32.and(U32.shrn(x, {i}n), 1), 1)' for i in range(8))+']\n'
Path('src/bit_decoding.bend').write_text(s)
s='import Base\n\n# Arithmetic digit i = floor(x / 2^i) mod 2, in increasing significance.\ndef octet(+x: U32) -> +List<Bool>:\n  ['+', '.join(f'U32.is_eq(U32.mod(U32.div(x, {1<<i}), 2), 1)' for i in range(8))+']\n'
Path('spec/bit_decoding.bend').write_text(s)
s='''import Base
import ../src/bit_decoding.bend as I
import ../spec/bit_decoding.bend as S
import ./power_division.bend as D
import ./word_split.bend as B
import ./integer_decoding.bend as Integer

law embedded_correct:
  for +w: Word(8n)
  {I.octet(D.embed8(w)) == S.octet(D.embed8(w)) : +List<Bool>}
def embedded_correct(w):
  match w:
'''
for x in range(256):
 pat='WNil{}'
 for i in reversed(range(8)):pat='WCon{'+('True{}' if x>>i&1 else 'False{}')+', '+pat+'}'
 s+=f'    case {pat}: {{==}}\n'
s+='''
law octet_correct:
  for +x: U32
  for e: {U32.is_lt(x, 256) == True{} : Bool}
  {I.octet(x) == S.octet(x) : +List<Bool>}
def octet_correct(x, e):
  %Equal.sym(U32, x, D.embed8(B.take(8n, 32n, D.bits(x))), Integer.byte_shape(x, e)) : {I.octet(_) == S.octet(_) : +List<Bool>}
  embedded_correct(B.take(8n, 32n, D.bits(x)))
'''
Path('proofs/bit_decoding.bend').write_text(s)
