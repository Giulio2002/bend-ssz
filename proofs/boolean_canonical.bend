import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ./word_facts.bend as W

# Some carries the exact canonical encoding obligation; None makes no value claim.
def canonical(xs: +List<U32>, r: Maybe<&2, Bool>) -> Type:
  match r:
    case None{}: Unit
    case Some{b}: {S.boolean_encoding(b) == xs : +List<U32>}

law byte_canonical:
  for z: Bool
  for o: Bool
  for +h: U32
  for ez: {U32.is_eq(h, 0) == z : Bool}
  for eo: {U32.is_eq(h, 1) == o : Bool}
  canonical([h], I.boolean_decode_byte(z, o))
def byte_canonical(z, o, h, ez, eo):
  match z:
    case True{}:
      Equal.cong(U32, +List<U32>, x => [x], 0, h,
        Equal.sym(U32, h, 0, W.u32_equal_sound(h, 0, ez)))
    case False{}:
      match o:
        case False{}: Unit{}
        case True{}:
          Equal.cong(U32, +List<U32>, x => [x], 1, h,
            Equal.sym(U32, h, 1, W.u32_equal_sound(h, 1, eo)))

law boolean_decoding_canonical:
  for +xs: +List<U32>
  canonical(xs, I.boolean_deserialize(xs))
def boolean_decoding_canonical(xs):
  match xs:
    case Nil{}: Unit{}
    case Con{h, t}:
      match t:
        case Nil{}: byte_canonical(U32.is_eq(h, 0), U32.is_eq(h, 1), h, {==}, {==})
        case Con{x, rest}: Unit{}

law boolean_accepted_sound:
  for +xs: +List<U32>
  for b: Bool
  for e: {I.boolean_deserialize(xs) == Some{b} : Maybe<&2, Bool>}
  {S.boolean_encoding(b) == xs : +List<U32>}
def boolean_accepted_sound(xs, b, e):
  %e : canonical(xs, _)
  boolean_decoding_canonical(xs)

law boolean_root_scope:
  for b: Bool
  {S.byte_scope(32n, I.boolean_root(b)) == True{} : Bool}
def boolean_root_scope(b):
  match b:
    case False{}: {==}
    case True{}: {==}
