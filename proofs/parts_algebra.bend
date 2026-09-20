import Base
import ../types/schema.bend as T
import ../spec/layout.bend as S
import ./lists.bend as L
import ./layout.bend as LA
import ./primitive_invariants.bend as V
import ./bytes.bend as B
import ./packing.bend as PK
import ../spec/nat_bytes.bend as N
import ../spec/primitives.bend as SP

# Algebra of the frozen layout specification over part-list concatenation.
#
# The cursor decoder walks a layout left to right, so every step splits the
# part list of a region into an already-decoded prefix and the remainder.
# These laws say how the specification's fixed region, payload region and
# domain check decompose along that split; nothing here mentions the decoder.

law payloads_append:
  for +a: +List<T.Part>
  for +b: +List<T.Part>
  {S.payloads(List.append(&2, T.Part, a, b)) == List.append(&2, U32, S.payloads(a), S.payloads(b)) : +List<U32>}
def payloads_append(a, b):
  match a:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: payloads_append(t, b)
        case T.Variable{xs}:
          %Equal.sym(+List<U32>, S.payloads(List.append(&2, T.Part, t, b)), List.append(&2, U32, S.payloads(t), S.payloads(b)), payloads_append(t, b)) : {List.append(&2, U32, xs, _) == List.append(&2, U32, List.append(&2, U32, xs, S.payloads(t)), S.payloads(b)) : +List<U32>}
          Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, S.payloads(t)), S.payloads(b)), List.append(&2, U32, xs, List.append(&2, U32, S.payloads(t), S.payloads(b))), L.append_associative(U32, xs, S.payloads(t), S.payloads(b)))

law fixed_size_append:
  for +a: +List<T.Part>
  for +b: +List<T.Part>
  {S.fixed_size(List.append(&2, T.Part, a, b)) == Nat.add(S.fixed_size(a), S.fixed_size(b)) : Nat}
def fixed_size_append(a, b):
  match a:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(Nat, S.fixed_size(List.append(&2, T.Part, t, b)), Nat.add(S.fixed_size(t), S.fixed_size(b)), fixed_size_append(t, b)) : {Nat.add(S.slot(h), _) == Nat.add(Nat.add(S.slot(h), S.fixed_size(t)), S.fixed_size(b)) : Nat}
      Equal.sym(Nat, Nat.add(Nat.add(S.slot(h), S.fixed_size(t)), S.fixed_size(b)), Nat.add(S.slot(h), Nat.add(S.fixed_size(t), S.fixed_size(b))), LA.add_associative(S.slot(h), S.fixed_size(t), S.fixed_size(b)))

# The fixed region of a concatenation is the fixed region of the prefix
# followed by the fixed region of the suffix, whose offset cursor has advanced
# by exactly the prefix's payload bytes.
law fixed_parts_append:
  for +a: +List<T.Part>
  for +b: +List<T.Part>
  for +off: Nat
  {S.fixed_parts(List.append(&2, T.Part, a, b), off) == List.append(&2, U32, S.fixed_parts(a, off), S.fixed_parts(b, Nat.add(off, List.length(&2, U32, S.payloads(a))))) : +List<U32>}
def fixed_parts_append(a, b, off):
  match a:
    case Nil{}: Equal.cong(Nat, +List<U32>, k => S.fixed_parts(b, k), off, Nat.add(off, 0n), Equal.sym(Nat, Nat.add(off, 0n), off, PK.add_zero(off)))
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          %Equal.sym(+List<U32>, S.fixed_parts(List.append(&2, T.Part, t, b), off), List.append(&2, U32, S.fixed_parts(t, off), S.fixed_parts(b, Nat.add(off, List.length(&2, U32, S.payloads(t))))), fixed_parts_append(t, b, off)) : {List.append(&2, U32, xs, _) == List.append(&2, U32, List.append(&2, U32, xs, S.fixed_parts(t, off)), S.fixed_parts(b, Nat.add(off, List.length(&2, U32, S.payloads(t))))) : +List<U32>}
          Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, S.fixed_parts(t, off)), S.fixed_parts(b, Nat.add(off, List.length(&2, U32, S.payloads(t))))), List.append(&2, U32, xs, List.append(&2, U32, S.fixed_parts(t, off), S.fixed_parts(b, Nat.add(off, List.length(&2, U32, S.payloads(t)))))), L.append_associative(U32, xs, S.fixed_parts(t, off), S.fixed_parts(b, Nat.add(off, List.length(&2, U32, S.payloads(t))))))
        case T.Variable{xs}:
          %LA.advance_total(off, xs, S.payloads(t)) : {S.fixed_parts(List.append(&2, T.Part, T.Variable{xs} <> t, b), off) == List.append(&2, U32, S.fixed_parts(T.Variable{xs} <> t, off), S.fixed_parts(b, _)) : +List<U32>}
          %Equal.sym(+List<U32>, S.fixed_parts(List.append(&2, T.Part, t, b), Nat.add(off, List.length(&2, U32, xs))), List.append(&2, U32, S.fixed_parts(t, Nat.add(off, List.length(&2, U32, xs))), S.fixed_parts(b, Nat.add(Nat.add(off, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t))))), fixed_parts_append(t, b, Nat.add(off, List.length(&2, U32, xs)))) : {List.append(&2, U32, N.digits(4n, off), _) == List.append(&2, U32, List.append(&2, U32, N.digits(4n, off), S.fixed_parts(t, Nat.add(off, List.length(&2, U32, xs)))), S.fixed_parts(b, Nat.add(Nat.add(off, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t))))) : +List<U32>}
          Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, N.digits(4n, off), S.fixed_parts(t, Nat.add(off, List.length(&2, U32, xs)))), S.fixed_parts(b, Nat.add(Nat.add(off, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t))))), List.append(&2, U32, N.digits(4n, off), List.append(&2, U32, S.fixed_parts(t, Nat.add(off, List.length(&2, U32, xs))), S.fixed_parts(b, Nat.add(Nat.add(off, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t)))))), L.append_associative(U32, N.digits(4n, off), S.fixed_parts(t, Nat.add(off, List.length(&2, U32, xs))), S.fixed_parts(b, Nat.add(Nat.add(off, List.length(&2, U32, xs)), List.length(&2, U32, S.payloads(t))))))

law bytes_valid_append:
  for +a: +List<T.Part>
  for +b: +List<T.Part>
  {S.bytes_valid(List.append(&2, T.Part, a, b)) == Bool.and(S.bytes_valid(a), S.bytes_valid(b)) : Bool}
def bytes_valid_append(a, b):
  match a:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}:
          %Equal.sym(Bool, S.bytes_valid(List.append(&2, T.Part, t, b)), Bool.and(S.bytes_valid(t), S.bytes_valid(b)), bytes_valid_append(t, b)) : {Bool.and(SP.bytes_domain(xs), _) == Bool.and(Bool.and(SP.bytes_domain(xs), S.bytes_valid(t)), S.bytes_valid(b)) : Bool}
          Equal.sym(Bool, Bool.and(Bool.and(SP.bytes_domain(xs), S.bytes_valid(t)), S.bytes_valid(b)), Bool.and(SP.bytes_domain(xs), Bool.and(S.bytes_valid(t), S.bytes_valid(b))), B.and_associative(SP.bytes_domain(xs), S.bytes_valid(t), S.bytes_valid(b)))
        case T.Variable{xs}:
          %Equal.sym(Bool, S.bytes_valid(List.append(&2, T.Part, t, b)), Bool.and(S.bytes_valid(t), S.bytes_valid(b)), bytes_valid_append(t, b)) : {Bool.and(SP.bytes_domain(xs), _) == Bool.and(Bool.and(SP.bytes_domain(xs), S.bytes_valid(t)), S.bytes_valid(b)) : Bool}
          Equal.sym(Bool, Bool.and(Bool.and(SP.bytes_domain(xs), S.bytes_valid(t)), S.bytes_valid(b)), Bool.and(SP.bytes_domain(xs), Bool.and(S.bytes_valid(t), S.bytes_valid(b))), B.and_associative(SP.bytes_domain(xs), S.bytes_valid(t), S.bytes_valid(b)))
