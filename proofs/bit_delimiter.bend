import Base
import ../src/bit_decode.bend as D
import ./bit_take_unique.bend as U
import ./word_facts.bend as W
import ./nat_order.bend as N

# Accumulator identity proves reversal without assuming any list laws.
law reverse_twice_acc:
  for +xs: +List<Bool>
  for +ys: +List<Bool>
  for +zs: +List<Bool>
  {List.reverse.go(&2, Bool, List.reverse.go(&2, Bool, xs, ys), zs) == List.reverse.go(&2, Bool, ys, List.append(&2, Bool, xs, zs)) : +List<Bool>}
def reverse_twice_acc(xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: reverse_twice_acc(t, h <> ys, zs)

law append_empty:
  for +xs: +List<Bool>
  {List.append(&2, Bool, xs, []) == xs : +List<Bool>}
def append_empty(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Equal.cong(+List<Bool>, +List<Bool>, ys => h <> ys, List.append(&2, Bool, t, []), t, append_empty(t))

law reverse_twice:
  for +xs: +List<Bool>
  {List.reverse(&2, Bool, List.reverse(&2, Bool, xs)) == xs : +List<Bool>}
def reverse_twice(xs):
  Equal.trans(+List<Bool>, List.reverse(&2, Bool, List.reverse(&2, Bool, xs)), List.append(&2, Bool, xs, []), xs, reverse_twice_acc(xs, [], []), append_empty(xs))

def zeros(n: Nat, rest: +List<Bool>) -> +List<Bool>:
  match n:
    case 0n: rest
    case 1n+p: False{} <> zeros(p, rest)

# All natural padding counts are covered. Public decoding uses room = 7;
# this is the protocol's final-octet padding rule, not a resource bound.
law delimiter_insert_remove:
  for +padding: Nat
  for +spare: Nat
  for +bits: +List<Bool>
  {D.delimiter(zeros(padding, True{} <> List.reverse(&2, Bool, bits)), Nat.add(padding, spare)) == Some{bits} : Maybe<&2, +List<Bool>>}
def delimiter_insert_remove(padding, spare, bits):
  match padding:
    case 0n: Equal.cong(+List<Bool>, Maybe<&2, +List<Bool>>, xs => Some{xs}, List.reverse(&2, Bool, List.reverse(&2, Bool, bits)), bits, reverse_twice(bits))
    case 1n+p: delimiter_insert_remove(p, spare, bits)

# Count the zero bits consumed by the actual parser. This witness is only used
# by proofs; rejected inputs never receive an accepted-shape conclusion.
def removed(reversed: +List<Bool>, room: Nat) -> Nat:
  match reversed:
    case Nil{}: 0n
    case Con{h, t}:
      match h:
        case True{}: 0n
        case False{}:
          match room:
            case 0n: 0n
            case 1n+p: 1n+removed(t, p)

def value(r: Maybe<&2, +List<Bool>>) -> +List<Bool>:
  match r:
    case None{}: []
    case Some{bits}: bits

law delimiter_remove_insert:
  for +reversed: +List<Bool>
  for +room: Nat
  for +bits: +List<Bool>
  for +decoded: {D.delimiter(reversed, room) == Some{bits} : Maybe<&2, +List<Bool>>}
  {reversed == zeros(removed(reversed, room), True{} <> List.reverse(&2, Bool, bits)) : +List<Bool>}
def delimiter_remove_insert(reversed, room, bits, decoded):
  match reversed:
    case Nil{}:
      Empty.absurd({[] == zeros(removed([], room), True{} <> List.reverse(&2, Bool, bits)) : +List<Bool>}, W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, U.present, None{}, Some{bits}, decoded)))
    case Con{h, t}:
      match h:
        case True{}:
          +same = Equal.cong(Maybe<&2, +List<Bool>>, +List<Bool>, value, Some{List.reverse(&2, Bool, t)}, Some{bits}, decoded)
          Equal.cong(+List<Bool>, +List<Bool>, xs => True{} <> xs, t, List.reverse(&2, Bool, bits), Equal.trans(+List<Bool>, t, List.reverse(&2, Bool, List.reverse(&2, Bool, t)), List.reverse(&2, Bool, bits), Equal.sym(+List<Bool>, List.reverse(&2, Bool, List.reverse(&2, Bool, t)), t, reverse_twice(t)), Equal.cong(+List<Bool>, +List<Bool>, xs => List.reverse(&2, Bool, xs), List.reverse(&2, Bool, t), bits, same)))
        case False{}:
          match room:
            case 0n:
              Empty.absurd({False{} <> t == zeros(removed(False{} <> t, 0n), True{} <> List.reverse(&2, Bool, bits)) : +List<Bool>}, W.false_true(Equal.cong(Maybe<&2, +List<Bool>>, Bool, U.present, None{}, Some{bits}, decoded)))
            case 1n+p:
              Equal.cong(+List<Bool>, +List<Bool>, xs => False{} <> xs, t, zeros(removed(t, p), True{} <> List.reverse(&2, Bool, bits)), delimiter_remove_insert(t, p, bits, decoded))

law removed_bounded:
  for +reversed: +List<Bool>
  for +room: Nat
  {Nat.is_le(removed(reversed, room), room) == True{} : Bool}
def removed_bounded(reversed, room):
  match reversed:
    case Nil{}: N.zero_le(room)
    case Con{h, t}:
      match h:
        case True{}: N.zero_le(room)
        case False{}:
          match room:
            case 0n: {==}
            case 1n+p: removed_bounded(t, p)
