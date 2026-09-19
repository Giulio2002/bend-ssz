import Base
import ../src/bit_packing.bend as P
import ../src/bit_decode.bend as D
import ./bit_delimiter.bend as L
import ./packing.bend as R
import ./word_facts.bend as W

law zeros_slide:
  for +n: Nat
  for +xs: +List<Bool>
  {L.zeros(n, False{} <> xs) == False{} <> L.zeros(n, xs) : +List<Bool>}
def zeros_slide(n, xs):
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(+List<Bool>, +List<Bool>, ys => False{} <> ys, L.zeros(p, False{} <> xs), False{} <> L.zeros(p, xs), zeros_slide(p, xs))

law reverse_zeros:
  for +n: Nat
  for +xs: +List<Bool>
  for +acc: +List<Bool>
  {List.reverse.go(&2, Bool, L.zeros(n, xs), acc) == List.reverse.go(&2, Bool, xs, L.zeros(n, acc)) : +List<Bool>}
def reverse_zeros(n, xs, acc):
  match n:
    case 0n: {==}
    case 1n+p:
      %zeros_slide(p, acc) : {List.reverse.go(&2, Bool, L.zeros(p, xs), False{} <> acc) == List.reverse.go(&2, Bool, xs, _) : +List<Bool>}
      reverse_zeros(p, xs, False{} <> acc)

law forward_shape:
  for +n: Nat
  for +bits: +List<Bool>
  {List.reverse(&2, Bool, L.zeros(n, True{} <> List.reverse(&2, Bool, bits))) == List.append(&2, Bool, bits, True{} <> L.zeros(n, [])) : +List<Bool>}
def forward_shape(n, bits):
  Equal.trans(+List<Bool>, List.reverse(&2, Bool, L.zeros(n, True{} <> List.reverse(&2, Bool, bits))), List.reverse.go(&2, Bool, List.reverse(&2, Bool, bits), True{} <> L.zeros(n, [])), List.append(&2, Bool, bits, True{} <> L.zeros(n, [])), reverse_zeros(n, True{} <> List.reverse(&2, Bool, bits), []), L.reverse_twice_acc(bits, [], True{} <> L.zeros(n, [])))

# Alignment is an intrinsic octet property, not a bound on list length.
def aligned(bits: +List<Bool>) -> Bool:
  match bits:
    case Nil{}: True{}
    case Con{a, Nil{}}: False{}
    case Con{a, Con{b, Nil{}}}: False{}
    case Con{a, Con{b, Con{c, Nil{}}}}: False{}
    case Con{a, Con{b, Con{c, Con{d, Nil{}}}}}: False{}
    case Con{a, Con{b, Con{c, Con{d, Con{e, Nil{}}}}}}: False{}
    case Con{a, Con{b, Con{c, Con{d, Con{e, Con{f, Nil{}}}}}}}: False{}
    case Con{a, Con{b, Con{c, Con{d, Con{e, Con{f, Con{g, Nil{}}}}}}}}: False{}
    case Con{a, Con{b, Con{c, Con{d, Con{e, Con{f, Con{g, Con{h, t}}}}}}}}: aligned(t)

law expand_aligned:
  for +xs: +List<U32>
  {aligned(D.expand(xs)) == True{} : Bool}
def expand_aligned(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: expand_aligned(t)
