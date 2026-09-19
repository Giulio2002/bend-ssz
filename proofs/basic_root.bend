import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T
import ./primitive_invariants.bend as V

law empty_padding:
  for n: Nat
  {I.pad(n, []) == S.zero_bytes(n) : +List<U32>}
def empty_padding(n):
  match n:
    case 0n: {==}
    case 1n+p:
      %empty_padding(p) : {0 <> I.pad(p, []) == 0 <> _ : +List<U32>}
      {==}

law padding_content:
  for +xs: +List<U32>
  for +n: Nat
  {I.pad(Nat.add(List.length(&2, U32, xs), n), xs) == List.append(&2, U32, xs, S.zero_bytes(n)) : +List<U32>}
def padding_content(xs, n):
  match xs:
    case Nil{}: empty_padding(n)
    case Con{h, t}:
      %padding_content(t, n) :
        {h <> I.pad(Nat.add(List.length(&2, U32, t), n), t) == h <> _ : +List<U32>}
      {==}

law width_padding:
  for +w: T.Width
  {Nat.add(I.width(w), Nat.sub(32n, I.width(w))) == 32n : Nat}
def width_padding(w):
  match w:
    case T.U8{}: {==}
    case T.U16{}: {==}
    case T.U32Width{}: {==}
    case T.U64{}: {==}
    case T.U128{}: {==}
    case T.U256{}: {==}

law root_of_encoding:
  for +w: T.Width
  for +r: Maybe<&2, +List<U32>>
  for es: V.sized(I.width(w), r)
  {I.root_checked(r) == S.pad_encoding(Nat.sub(32n, I.width(w)), r) : Maybe<&2, +List<U32>>}
def root_of_encoding(w, r, es):
  match r:
    case None{}: {==}
    case Some{xs}:
      %width_padding(w) :
        {Some{I.pad(_, xs)} == Some{List.append(&2, U32, xs, S.zero_bytes(Nat.sub(32n, I.width(w))))} : Maybe<&2, +List<U32>>}
      %es :
        {Some{I.pad(Nat.add(_, Nat.sub(32n, I.width(w))), xs)} == Some{List.append(&2, U32, xs, S.zero_bytes(Nat.sub(32n, I.width(w))))} : Maybe<&2, +List<U32>>}
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, xs => Some{xs},
        I.pad(Nat.add(List.length(&2, U32, xs), Nat.sub(32n, I.width(w))), xs),
        List.append(&2, U32, xs, S.zero_bytes(Nat.sub(32n, I.width(w)))),
        padding_content(xs, Nat.sub(32n, I.width(w))))

# Actual public root is the complete serialized byte string plus right zeroes.
# Integer arithmetic refinement is still needed to replace the encoder with S.uint_encoding.
law uint_root_from_encoding:
  for +w: T.Width
  for +v: T.UInt
  {I.uint_root(w, v) == S.pad_encoding(Nat.sub(32n, I.width(w)), I.uint_serialize(w, v)) : Maybe<&2, +List<U32>>}
def uint_root_from_encoding(w, v):
  root_of_encoding(w, I.uint_serialize(w, v), V.uint_serialized_length(w, v))

law zeros_domain:
  for n: Nat
  {S.bytes_domain(S.zero_bytes(n)) == True{} : Bool}
def zeros_domain(n):
  match n:
    case 0n: {==}
    case 1n+p: zeros_domain(p)

law pad_preserves_domain:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {S.bytes_domain(xs) == True{} : Bool}
  {S.bytes_domain(I.pad(n, xs)) == True{} : Bool}
def pad_preserves_domain(n, xs, e):
  match n:
    case 0n: {==}
    case 1n+p:
      match xs:
        case Nil{}: pad_preserves_domain(p, [], {==})
        case Con{h, t}:
          V.and_true(U32.is_lt(h, 256), S.bytes_domain(I.pad(p, t)),
            V.and_left(U32.is_lt(h, 256), S.bytes_domain(t), e),
            pad_preserves_domain(p, t, V.and_right(U32.is_lt(h, 256), S.bytes_domain(t), e)))

law root_checked_domain:
  for +r: Maybe<&2, +List<U32>>
  for e: V.byte_result(r)
  V.byte_result(I.root_checked(r))
def root_checked_domain(r, e):
  match r:
    case None{}: Unit{}
    case Some{xs}: pad_preserves_domain(32n, xs, e)

law uint_root_bytes:
  for +w: T.Width
  for +v: T.UInt
  V.byte_result(I.uint_root(w, v))
def uint_root_bytes(w, v):
  root_checked_domain(I.uint_serialize(w, v), V.uint_serialized_bytes(w, v))
