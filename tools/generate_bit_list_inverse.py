"""Generate structural octet cases, not fixture cases or a size restriction."""
from pathlib import Path
s='''import Base
import ../src/bit_packing.bend as P
import ../src/bit_decoding.bend as O
import ../src/bit_decode.bend as D
import ./bit_inverse.bend as B

# The accumulator generalization makes the eight-bit recursive step literal.
# Every list length is covered by structural recursion.
law delimiter_packed_acc:
  for +bits: +List<Bool>
  for +acc: +List<Bool>
  {D.delimiter(List.reverse.go(&2, Bool, D.expand(P.pack(List.append(&2, Bool, bits, [True{}]))), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
def delimiter_packed_acc(bits, acc):
  match bits:
'''
b=[f'b{i}' for i in range(8)]
for n in range(9):
 pat='tail' if n==8 else 'Nil{}'
 for x in reversed(b[:n]):pat=f'Con{{{x}, {pat}}}'
 vals=b if n==8 else b[:n]+['True{}']+['False{}']*(7-n)
 args=', '.join(vals)
 rest='P.pack(List.append(&2, Bool, tail, [True{}]))' if n==8 else '[]'
 s+=f'    case {pat}:\n'
 s+=f'      %Equal.sym(+List<Bool>, O.octet(P.octet({args})), [{args}], B.octet_inverse({args})) : {{D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand({rest})), acc), 7n) == Some{{List.reverse.go(&2, Bool, acc, bits)}} : Maybe<&2, +List<Bool>>}}\n'
 if n<8:s+='      {==}\n'
 else:s+='      delimiter_packed_acc(tail, '+ ' <> '.join(reversed(b))+' <> acc)\n'
s+='''
law delimiter_packed:
  for +bits: +List<Bool>
  {D.delimiter(List.reverse(&2, Bool, D.expand(P.pack(List.append(&2, Bool, bits, [True{}])))), 7n) == Some{bits} : Maybe<&2, +List<Bool>>}
def delimiter_packed(bits): delimiter_packed_acc(bits, [])
'''
Path('proofs/bit_list_inverse.bend').write_text(s)
