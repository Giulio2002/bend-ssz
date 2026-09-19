import Base
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
    case Nil{}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{})), [True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{}], B.octet_inverse(True{}, False{}, False{}, False{}, False{}, False{}, False{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Nil{}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, True{}, False{}, False{}, False{}, False{}, False{}, False{})), [b0, True{}, False{}, False{}, False{}, False{}, False{}, False{}], B.octet_inverse(b0, True{}, False{}, False{}, False{}, False{}, False{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Nil{}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, True{}, False{}, False{}, False{}, False{}, False{})), [b0, b1, True{}, False{}, False{}, False{}, False{}, False{}], B.octet_inverse(b0, b1, True{}, False{}, False{}, False{}, False{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Nil{}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, True{}, False{}, False{}, False{}, False{})), [b0, b1, b2, True{}, False{}, False{}, False{}, False{}], B.octet_inverse(b0, b1, b2, True{}, False{}, False{}, False{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, True{}, False{}, False{}, False{})), [b0, b1, b2, b3, True{}, False{}, False{}, False{}], B.octet_inverse(b0, b1, b2, b3, True{}, False{}, False{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, True{}, False{}, False{})), [b0, b1, b2, b3, b4, True{}, False{}, False{}], B.octet_inverse(b0, b1, b2, b3, b4, True{}, False{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, b5, True{}, False{})), [b0, b1, b2, b3, b4, b5, True{}, False{}], B.octet_inverse(b0, b1, b2, b3, b4, b5, True{}, False{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, b5, b6, True{})), [b0, b1, b2, b3, b4, b5, b6, True{}], B.octet_inverse(b0, b1, b2, b3, b4, b5, b6, True{})) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand([])), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, b5, b6, b7)), [b0, b1, b2, b3, b4, b5, b6, b7], B.octet_inverse(b0, b1, b2, b3, b4, b5, b6, b7)) : {D.delimiter(List.reverse.go(&2, Bool, List.append(&2, Bool, _, D.expand(P.pack(List.append(&2, Bool, tail, [True{}])))), acc), 7n) == Some{List.reverse.go(&2, Bool, acc, bits)} : Maybe<&2, +List<Bool>>}
      delimiter_packed_acc(tail, b7 <> b6 <> b5 <> b4 <> b3 <> b2 <> b1 <> b0 <> acc)

law delimiter_packed:
  for +bits: +List<Bool>
  {D.delimiter(List.reverse(&2, Bool, D.expand(P.pack(List.append(&2, Bool, bits, [True{}])))), 7n) == Some{bits} : Maybe<&2, +List<Bool>>}
def delimiter_packed(bits): delimiter_packed_acc(bits, [])
