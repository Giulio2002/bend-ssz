import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T

law boolean_serialize_correct:
  for b: Bool
  {I.boolean_serialize(b) == S.boolean_encoding(b) : +List<U32>}
def boolean_serialize_correct(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law choose_boolean_correct:
  for z: Bool
  for o: Bool
  {I.boolean_decode_byte(z, o) == S.choose_boolean(z, o) : Maybe<&2, Bool>}
def choose_boolean_correct(z, o):
  match z:
    case True{}: {==}
    case False{}:
      match o:
        case False{}: {==}
        case True{}: {==}

law boolean_deserialize_correct:
  for xs: +List<U32>
  {I.boolean_deserialize(xs) == S.boolean_decoding(xs) : Maybe<&2, Bool>}
def boolean_deserialize_correct(xs):
  match xs:
    case Nil{}: {==}
    case Con{+h, t}:
      match t:
        case Nil{}: choose_boolean_correct(U32.is_eq(h, 0), U32.is_eq(h, 1))
        case Con{x, rest}: {==}

law boolean_decoding_complete:
  for b: Bool
  {I.boolean_deserialize(S.boolean_encoding(b)) == Some{b} : Maybe<&2, Bool>}
def boolean_decoding_complete(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law boolean_hash_tree_root_correct:
  for b: Bool
  {I.boolean_root(b) == S.boolean_hash_tree_root(b) : +List<U32>}
def boolean_hash_tree_root_correct(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law boolean_root_length:
  for b: Bool
  {List.length(&2, U32, I.boolean_root(b)) == 32n : Nat}
def boolean_root_length(b):
  {==}

law byte_scope_correct:
  for n: Nat
  for xs: +List<U32>
  {I.valid_bytes(n, xs) == S.byte_scope(n, xs) : Bool}
def byte_scope_correct(n, xs):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{+h, t}: {==}
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{+h, t}:
          %byte_scope_correct(p, t) :
            {Bool.and(U32.is_lt(h, 256), I.valid_bytes(p, t)) == Bool.and(U32.is_lt(h, 256), _) : Bool}
          {==}

law padded_length:
  for n: Nat
  for xs: +List<U32>
  {List.length(&2, U32, I.pad(n, xs)) == n : Nat}
def padded_length(n, xs):
  match n:
    case 0n: {==}
    case 1n+p:
      match xs:
        case Nil{}:
          %padded_length(p, []) : {1n+List.length(&2, U32, I.pad(p, [])) == 1n+_ : Nat}
          {==}
        case Con{+h, t}:
          %padded_length(p, t) : {1n+List.length(&2, U32, I.pad(p, t)) == 1n+_ : Nat}
          {==}

# Rejection is observed from the actual API result, not from exceptions/timeouts.
def boolean_rejected(r: Maybe<&2, Bool>) -> Bool:
  match r:
    case None{}: True{}
    case Some{v}: False{}

law boolean_rejection_correct:
  for +xs: +List<U32>
  {boolean_rejected(I.boolean_deserialize(xs)) == boolean_rejected(S.boolean_decoding(xs)) : Bool}
def boolean_rejection_correct(xs):
  Equal.cong(Maybe<&2, Bool>, Bool, r => boolean_rejected(r),
    I.boolean_deserialize(xs), S.boolean_decoding(xs), boolean_deserialize_correct(xs))

law boolean_byte_domain:
  for b: Bool
  {S.byte_scope(1n, I.boolean_serialize(b)) == True{} : Bool}
def boolean_byte_domain(b):
  match b:
    case False{}: {==}
    case True{}: {==}

def integer_rejected(r: Maybe<&2, T.UInt>) -> Bool:
  match r:
    case None{}: True{}
    case Some{v}: False{}

law checked_decode_rejection:
  for ok: Bool
  for xs: +List<U32>
  {integer_rejected(I.decode_checked(ok, xs)) == Bool.not(ok) : Bool}
def checked_decode_rejection(ok, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law width_correct:
  for w: T.Width
  {I.width(w) == S.byte_width(w) : Nat}
def width_correct(w):
  match w:
    case T.U8{}: {==}
    case T.U16{}: {==}
    case T.U32Width{}: {==}
    case T.U64{}: {==}
    case T.U128{}: {==}
    case T.U256{}: {==}

law uint_rejection_correct:
  for +w: T.Width
  for +xs: +List<U32>
  {integer_rejected(I.uint_deserialize(w, xs)) == Bool.not(S.byte_scope(S.byte_width(w), xs)) : Bool}
def uint_rejection_correct(w, xs):
  %width_correct(w) :
    {integer_rejected(I.uint_deserialize(w, xs)) == Bool.not(S.byte_scope(_, xs)) : Bool}
  %byte_scope_correct(I.width(w), xs) :
    {integer_rejected(I.uint_deserialize(w, xs)) == Bool.not(_) : Bool}
  checked_decode_rejection(I.valid_bytes(I.width(w), xs), xs)

def lengths(r: Maybe<&2, +List<U32>>) -> Maybe<&2, Nat>:
  match r:
    case None{}: None{}
    case Some{xs}: Some{List.length(&2, U32, xs)}

def expected_root_length(r: Maybe<&2, +List<U32>>) -> Maybe<&2, Nat>:
  match r:
    case None{}: None{}
    case Some{xs}: Some{32n}

law root_checked_length:
  for r: Maybe<&2, +List<U32>>
  {lengths(I.root_checked(r)) == expected_root_length(r) : Maybe<&2, Nat>}
def root_checked_length(r):
  match r:
    case None{}: {==}
    case Some{xs}:
      %padded_length(32n, xs) : {Some{List.length(&2, U32, I.pad(32n, xs))} == Some{_} : Maybe<&2, Nat>}
      {==}

law uint_root_length:
  for w: T.Width
  for v: T.UInt
  {lengths(I.uint_root(w, v)) == expected_root_length(I.uint_serialize(w, v)) : Maybe<&2, Nat>}
def uint_root_length(w, v):
  root_checked_length(I.uint_serialize(w, v))
