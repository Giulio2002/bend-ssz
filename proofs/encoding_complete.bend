import Base
import ../src/primitives.bend as I
import ../spec/primitives.bend as S
import ../types/primitive.bend as T
import ./codec_inverse.bend as C
import ./word_facts.bend as W
import ./primitive_invariants.bend as V
import ./primitives.bend as Basic
import ./integer_encoding.bend as Encode

law zero_lookup:
  for +xs: +List<U32>
  for +index: Nat
  for +e: {I.all_zero(xs) == True{} : Bool}
  {I.at(xs, index) == 0 : U32}
def zero_lookup(xs, index, e):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      match index:
        case 0n: W.u32_equal_sound(h, 0, V.and_left(U32.is_eq(h, 0), I.all_zero(t), e))
        case 1n+p: zero_lookup(t, p, V.and_right(U32.is_eq(h, 0), I.all_zero(t), e))

# A successful narrowing preserves every zero-defaulted lookup.
def same_lookup(index: Nat, xs: +List<U32>, r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{ys}: {I.at(ys, index) == I.at(xs, index) : U32}

law accept_lookup:
  for ok: Bool
  for +xs: +List<U32>
  for +index: Nat
  for +e: {I.all_zero(xs) == ok : Bool}
  same_lookup(index, xs, I.accept_bytes(ok, []))
def accept_lookup(ok, xs, index, e):
  match ok:
    case False{}: Unit{}
    case True{}: Equal.sym(U32, I.at(xs, index), 0, zero_lookup(xs, index, e))

def predecessor(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

law prepend_lookup:
  for +index: Nat
  for +h: U32
  for +xs: +List<U32>
  for +r: Maybe<&2, +List<U32>>
  for e: same_lookup(predecessor(index), xs, r)
  same_lookup(index, h <> xs, I.prepend(h, r))
def prepend_lookup(index, h, xs, r, e):
  match index:
    case 0n:
      match r:
        case None{}: Unit{}
        case Some{ys}: {==}
    case 1n+p:
      match r:
        case None{}: Unit{}
        case Some{ys}: e

law narrow_lookup:
  for +n: Nat
  for +xs: +List<U32>
  for +index: Nat
  same_lookup(index, xs, I.narrow(n, xs))
def narrow_lookup(n, xs, index):
  match n:
    case 0n: accept_lookup(I.all_zero(xs), xs, index, {==})
    case 1n+p:
      match xs:
        case Nil{}: Unit{}
        case Con{h, t}: prepend_lookup(index, h, t, I.narrow(p, t), narrow_lookup(p, t, predecessor(index)))

def same_limb(index: Nat, xs: +List<U32>, r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{ys}: {I.read_limb(ys, index) == I.read_limb(xs, index) : U32}

law read_branch:
  for +index: Nat
  for +xs: +List<U32>
  for +r: Maybe<&2, +List<U32>>
  for e0: same_lookup(index, xs, r)
  for e1: same_lookup(1n+index, xs, r)
  for e2: same_lookup(2n+index, xs, r)
  for e3: same_lookup(3n+index, xs, r)
  same_limb(index, xs, r)
def read_branch(index, xs, r, e0, e1, e2, e3):
  match r:
    case None{}: Unit{}
    case Some{ys}:
      %e0 : {I.read_limb(ys, index) == U32.or(_, U32.or(U32.shln(I.at(xs, 1n+index), 8n), U32.or(U32.shln(I.at(xs, 2n+index), 16n), U32.shln(I.at(xs, 3n+index), 24n)))) : U32}
      %e1 : {I.read_limb(ys, index) == U32.or(I.at(ys, index), U32.or(U32.shln(_, 8n), U32.or(U32.shln(I.at(xs, 2n+index), 16n), U32.shln(I.at(xs, 3n+index), 24n)))) : U32}
      %e2 : {I.read_limb(ys, index) == U32.or(I.at(ys, index), U32.or(U32.shln(I.at(ys, 1n+index), 8n), U32.or(U32.shln(_, 16n), U32.shln(I.at(xs, 3n+index), 24n)))) : U32}
      %e3 : {I.read_limb(ys, index) == U32.or(I.at(ys, index), U32.or(U32.shln(I.at(ys, 1n+index), 8n), U32.or(U32.shln(I.at(ys, 2n+index), 16n), U32.shln(_, 24n)))) : U32}
      {==}

law narrow_limb:
  for +n: Nat
  for +xs: +List<U32>
  for +index: Nat
  same_limb(index, xs, I.narrow(n, xs))
def narrow_limb(n, xs, index):
  read_branch(index, xs, I.narrow(n, xs), narrow_lookup(n, xs, index), narrow_lookup(n, xs, 1n+index), narrow_lookup(n, xs, 2n+index), narrow_lookup(n, xs, 3n+index))

def same_value(xs: +List<U32>, r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{ys}: {I.decoded(ys) == I.decoded(xs) : T.UInt}

law value_branch:
  for +xs: +List<U32>
  for +r: Maybe<&2, +List<U32>>
  for e0: same_limb(0n, xs, r)
  for e1: same_limb(4n, xs, r)
  for e2: same_limb(8n, xs, r)
  for e3: same_limb(12n, xs, r)
  for e4: same_limb(16n, xs, r)
  for e5: same_limb(20n, xs, r)
  for e6: same_limb(24n, xs, r)
  for e7: same_limb(28n, xs, r)
  same_value(xs, r)
def value_branch(xs, r, e0, e1, e2, e3, e4, e5, e6, e7):
  match r:
    case None{}: Unit{}
    case Some{ys}:
      %e0 : {I.decoded(ys) == T.UInt{_, I.read_limb(xs, 4n), I.read_limb(xs, 8n), I.read_limb(xs, 12n), I.read_limb(xs, 16n), I.read_limb(xs, 20n), I.read_limb(xs, 24n), I.read_limb(xs, 28n)} : T.UInt}
      %e1 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), _, I.read_limb(xs, 8n), I.read_limb(xs, 12n), I.read_limb(xs, 16n), I.read_limb(xs, 20n), I.read_limb(xs, 24n), I.read_limb(xs, 28n)} : T.UInt}
      %e2 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), I.read_limb(ys, 4n), _, I.read_limb(xs, 12n), I.read_limb(xs, 16n), I.read_limb(xs, 20n), I.read_limb(xs, 24n), I.read_limb(xs, 28n)} : T.UInt}
      %e3 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), I.read_limb(ys, 4n), I.read_limb(ys, 8n), _, I.read_limb(xs, 16n), I.read_limb(xs, 20n), I.read_limb(xs, 24n), I.read_limb(xs, 28n)} : T.UInt}
      %e4 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), I.read_limb(ys, 4n), I.read_limb(ys, 8n), I.read_limb(ys, 12n), _, I.read_limb(xs, 20n), I.read_limb(xs, 24n), I.read_limb(xs, 28n)} : T.UInt}
      %e5 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), I.read_limb(ys, 4n), I.read_limb(ys, 8n), I.read_limb(ys, 12n), I.read_limb(ys, 16n), _, I.read_limb(xs, 24n), I.read_limb(xs, 28n)} : T.UInt}
      %e6 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), I.read_limb(ys, 4n), I.read_limb(ys, 8n), I.read_limb(ys, 12n), I.read_limb(ys, 16n), I.read_limb(ys, 20n), _, I.read_limb(xs, 28n)} : T.UInt}
      %e7 : {I.decoded(ys) == T.UInt{I.read_limb(ys, 0n), I.read_limb(ys, 4n), I.read_limb(ys, 8n), I.read_limb(ys, 12n), I.read_limb(ys, 16n), I.read_limb(ys, 20n), I.read_limb(ys, 24n), _} : T.UInt}
      {==}

law narrow_value:
  for +n: Nat
  for +xs: +List<U32>
  same_value(xs, I.narrow(n, xs))
def narrow_value(n, xs):
  value_branch(xs, I.narrow(n, xs), narrow_limb(n, xs, 0n), narrow_limb(n, xs, 4n), narrow_limb(n, xs, 8n), narrow_limb(n, xs, 12n), narrow_limb(n, xs, 16n), narrow_limb(n, xs, 20n), narrow_limb(n, xs, 24n), narrow_limb(n, xs, 28n))

law uint_bytes_inverse:
  for +v: T.UInt
  {I.decoded(I.uint_bytes(v)) == v : T.UInt}
def uint_bytes_inverse(v):
  match v:
    case T.UInt{a, b, c, d, e, f, g, h}:
      %C.limb_inverse(a) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{_, b, c, d, e, f, g, h} : T.UInt}
      %C.limb_inverse(b) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), _, c, d, e, f, g, h} : T.UInt}
      %C.limb_inverse(c) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), I.read_limb(I.limb(b), 0n), _, d, e, f, g, h} : T.UInt}
      %C.limb_inverse(d) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), I.read_limb(I.limb(b), 0n), I.read_limb(I.limb(c), 0n), _, e, f, g, h} : T.UInt}
      %C.limb_inverse(e) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), I.read_limb(I.limb(b), 0n), I.read_limb(I.limb(c), 0n), I.read_limb(I.limb(d), 0n), _, f, g, h} : T.UInt}
      %C.limb_inverse(f) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), I.read_limb(I.limb(b), 0n), I.read_limb(I.limb(c), 0n), I.read_limb(I.limb(d), 0n), I.read_limb(I.limb(e), 0n), _, g, h} : T.UInt}
      %C.limb_inverse(g) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), I.read_limb(I.limb(b), 0n), I.read_limb(I.limb(c), 0n), I.read_limb(I.limb(d), 0n), I.read_limb(I.limb(e), 0n), I.read_limb(I.limb(f), 0n), _, h} : T.UInt}
      %C.limb_inverse(h) : {I.decoded(I.uint_bytes(T.UInt{a, b, c, d, e, f, g, h})) == T.UInt{I.read_limb(I.limb(a), 0n), I.read_limb(I.limb(b), 0n), I.read_limb(I.limb(c), 0n), I.read_limb(I.limb(d), 0n), I.read_limb(I.limb(e), 0n), I.read_limb(I.limb(f), 0n), I.read_limb(I.limb(g), 0n), _} : T.UInt}
      {==}

def value_preserved(v: T.UInt, r: Maybe<&2, +List<U32>>) -> Type:
  match r:
    case None{}: Unit
    case Some{ys}: {I.decoded(ys) == v : T.UInt}

law preserve_branch:
  for +v: T.UInt
  for r: Maybe<&2, +List<U32>>
  for e: same_value(I.uint_bytes(v), r)
  value_preserved(v, r)
def preserve_branch(v, r, e):
  match r:
    case None{}: Unit{}
    case Some{ys}: Equal.trans(T.UInt, I.decoded(ys), I.decoded(I.uint_bytes(v)), v, e, uint_bytes_inverse(v))

law uint_encoding_lossless:
  for +w: T.Width
  for +v: T.UInt
  value_preserved(v, I.uint_serialize(w, v))
def uint_encoding_lossless(w, v):
  preserve_branch(v, I.uint_serialize(w, v), narrow_value(I.width(w), I.uint_bytes(v)))

law serialized_scope:
  for +w: T.Width
  for +v: T.UInt
  for xs: +List<U32>
  for e: {I.uint_serialize(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {S.byte_scope(I.width(w), xs) == True{} : Bool}
def serialized_scope(w, v, xs, e):
  %e : V.scoped(I.width(w), _)
  V.uint_serialized_scope(w, v)

law serialized_value:
  for +w: T.Width
  for +v: T.UInt
  for xs: +List<U32>
  for e: {I.uint_serialize(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {I.decoded(xs) == v : T.UInt}
def serialized_value(w, v, xs, e):
  %e : value_preserved(v, _)
  uint_encoding_lossless(w, v)

law uint_roundtrip:
  for +w: T.Width
  for +v: T.UInt
  for +xs: +List<U32>
  for +e: {I.uint_serialize(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {I.uint_deserialize(w, xs) == Some{v} : Maybe<&2, T.UInt>}
def uint_roundtrip(w, v, xs, e):
  %Equal.sym(Bool, I.valid_bytes(I.width(w), xs), True{},
    Equal.trans(Bool, I.valid_bytes(I.width(w), xs), S.byte_scope(I.width(w), xs), True{},
      Basic.byte_scope_correct(I.width(w), xs), serialized_scope(w, v, xs, e))) :
    {I.decode_checked(_, xs) == Some{v} : Maybe<&2, T.UInt>}
  Equal.cong(T.UInt, Maybe<&2, T.UInt>, v => Some{v}, I.decoded(xs), v, serialized_value(w, v, xs, e))

law uint_decoding_complete:
  for +w: T.Width
  for +v: T.UInt
  for +xs: +List<U32>
  for e: {S.uint_encoding(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
  {I.uint_deserialize(w, xs) == Some{v} : Maybe<&2, T.UInt>}
def uint_decoding_complete(w, v, xs, e):
  uint_roundtrip(w, v, xs,
    Equal.trans(Maybe<&2, +List<U32>>, I.uint_serialize(w, v), S.uint_encoding(w, v), Some{xs}, Encode.uint_serialize_correct(w, v), e))

law uint_accepted_sound:
  for +w: T.Width
  for +xs: +List<U32>
  for +v: T.UInt
  for e: {I.uint_deserialize(w, xs) == Some{v} : Maybe<&2, T.UInt>}
  {S.uint_encoding(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
def uint_accepted_sound(w, xs, v, e):
  Equal.trans(Maybe<&2, +List<U32>>, S.uint_encoding(w, v), I.uint_serialize(w, v), Some{xs},
    Equal.sym(Maybe<&2, +List<U32>>, I.uint_serialize(w, v), S.uint_encoding(w, v), Encode.uint_serialize_correct(w, v)),
    C.uint_accepted_reencode(w, xs, v, e))

law uint_accepted_domain:
  for +w: T.Width
  for +xs: +List<U32>
  for +v: T.UInt
  for e: {I.uint_deserialize(w, xs) == Some{v} : Maybe<&2, T.UInt>}
  {I.uint_valid(w, v) == True{} : Bool}
def uint_accepted_domain(w, xs, v, e):
  Equal.cong(Maybe<&2, +List<U32>>, Bool, r => I.is_some(r), I.uint_serialize(w, v), Some{xs},
    C.uint_accepted_reencode(w, xs, v, e))
