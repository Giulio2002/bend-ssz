import Base
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
    case Nil{}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: {==}
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Nil{}}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: {==}
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Nil{}}}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: {==}
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Con{b2, Nil{}}}}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: {==}
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: {==}
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: {==}
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}:
      match padding:
        case 0n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(0n, []))) : +List<U32>}, W.false_true(alignment))
        case 1n: {==}
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}:
      match padding:
        case 0n: {==}
        case 1n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(1n, []))) : +List<U32>}, W.false_true(alignment))
        case 2n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(2n, []))) : +List<U32>}, W.false_true(alignment))
        case 3n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(3n, []))) : +List<U32>}, W.false_true(alignment))
        case 4n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(4n, []))) : +List<U32>}, W.false_true(alignment))
        case 5n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(5n, []))) : +List<U32>}, W.false_true(alignment))
        case 6n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(6n, []))) : +List<U32>}, W.false_true(alignment))
        case 7n: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(7n, []))) : +List<U32>}, W.false_true(alignment))
        case 8n+p: Empty.absurd({P.pack(List.append(&2, Bool, bits, [True{}])) == P.pack(List.append(&2, Bool, bits, True{} <> L.zeros(8n+p, []))) : +List<U32>}, W.false_true(bound))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}:
      Equal.cong(+List<U32>, +List<U32>, xs => P.octet(b0, b1, b2, b3, b4, b5, b6, b7) <> xs, P.pack(List.append(&2, Bool, tail, [True{}])), P.pack(List.append(&2, Bool, tail, True{} <> L.zeros(padding, []))), pack_padding(tail, padding, bound, alignment))
