import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/primitives.bend as IP
import ../spec/primitives.bend as SP
import ../spec/bytes.bend as SBytes
import ../spec/byte_list.bend as SByteList
import ../spec/nat_bytes.bend as SLength
import ../spec/codec.bend as SC
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./word_facts.bend as F
import ./word_facts.bend as W
import ./primitive_invariants.bend as V
import ./primitives.bend as Basic
import ./codec_inverse.bend as CI
import ./integer_encoding.bend as IE
import ../src/bitfields.bend as IBits
import ../spec/bitfields.bend as SBits
import ./bit_vector_canonical.bend as BVC
import ./bit_list_canonical.bend as BLC
import ./nat_order.bend as NO
import ../src/bit_packing.bend as IBitPack
import ../spec/bit_packing.bend as SBitPack
import ./bit_packing.bend as BPack

# Leaf refinements for the packed cursor decoder.
#
# Everything here is stated through `P.slice_bytes`, the byte list a slice
# denotes, so the leaf results are related to the frozen independent
# specification and never to another implementation.

# ---------------------------------------------------------------------------
# Packed storage is byte-ranged by construction: every byte it yields comes
# out of a masked word read, so the decoder needs no separate domain scan on
# the packed input.
law byte0_range:
  for +w: U32
  {U32.is_lt(P.byte0(w), 256) == True{} : Bool}
def byte0_range(w): F.masked_byte_bound(w)

law byte1_range:
  for +w: U32
  {U32.is_lt(P.byte1(w), 256) == True{} : Bool}
def byte1_range(w): F.masked_byte_bound(U32.shrn(w, 8n))

law byte2_range:
  for +w: U32
  {U32.is_lt(P.byte2(w), 256) == True{} : Bool}
def byte2_range(w): F.masked_byte_bound(U32.shrn(w, 16n))

law byte3_range:
  for +w: U32
  {U32.is_lt(P.byte3(w), 256) == True{} : Bool}
def byte3_range(w): F.shifted_byte_bound(w)

law word_bytes_domain:
  for +w: U32
  for +tail: +List<U32>
  for +rest: {SP.bytes_domain(tail) == True{} : Bool}
  {SP.bytes_domain(P.word_bytes(w, tail)) == True{} : Bool}
def word_bytes_domain(w, tail, rest):
  V.and_true(U32.is_lt(P.byte0(w), 256), SP.bytes_domain(P.byte1(w) <> (P.byte2(w) <> (P.byte3(w) <> tail))), byte0_range(w),
    V.and_true(U32.is_lt(P.byte1(w), 256), SP.bytes_domain(P.byte2(w) <> (P.byte3(w) <> tail)), byte1_range(w),
      V.and_true(U32.is_lt(P.byte2(w), 256), SP.bytes_domain(P.byte3(w) <> tail), byte2_range(w),
        V.and_true(U32.is_lt(P.byte3(w), 256), SP.bytes_domain(tail), byte3_range(w), rest))))

law chunk_bytes_domain:
  for +c: P.Chunk
  for +tail: +List<U32>
  for +rest: {SP.bytes_domain(tail) == True{} : Bool}
  {SP.bytes_domain(P.chunk_bytes(c, tail)) == True{} : Bool}
def chunk_bytes_domain(c, tail, rest):
  match c:
    case P.Chunk{+w0, +w1, +w2, +w3, +w4, +w5, +w6, +w7}:
      word_bytes_domain(w0, P.word_bytes(w1, P.word_bytes(w2, P.word_bytes(w3, P.word_bytes(w4, P.word_bytes(w5, P.word_bytes(w6, P.word_bytes(w7, tail))))))),
        word_bytes_domain(w1, P.word_bytes(w2, P.word_bytes(w3, P.word_bytes(w4, P.word_bytes(w5, P.word_bytes(w6, P.word_bytes(w7, tail)))))),
          word_bytes_domain(w2, P.word_bytes(w3, P.word_bytes(w4, P.word_bytes(w5, P.word_bytes(w6, P.word_bytes(w7, tail))))),
            word_bytes_domain(w3, P.word_bytes(w4, P.word_bytes(w5, P.word_bytes(w6, P.word_bytes(w7, tail)))),
              word_bytes_domain(w4, P.word_bytes(w5, P.word_bytes(w6, P.word_bytes(w7, tail))),
                word_bytes_domain(w5, P.word_bytes(w6, P.word_bytes(w7, tail)),
                  word_bytes_domain(w6, P.word_bytes(w7, tail),
                    word_bytes_domain(w7, tail, rest))))))))

law chunks_bytes_domain:
  for +cs: +List<P.Chunk>
  {SP.bytes_domain(P.chunks_bytes(cs)) == True{} : Bool}
def chunks_bytes_domain(cs):
  match cs:
    case Nil{}: {==}
    case Con{c, t}: chunk_bytes_domain(c, P.chunks_bytes(t), chunks_bytes_domain(t))

law domain_drop:
  for +xs: +List<U32>
  for +k: Nat
  for +good: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.bytes_domain(List.drop(&2, U32, xs, k)) == True{} : Bool}
def domain_drop(xs, k, good):
  match xs k:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: {==}
    case Con{h, t} 0n: good
    case Con{h, t} 1n+p: domain_drop(t, p, V.and_right(U32.is_lt(h, 256), SP.bytes_domain(t), good))

law domain_take:
  for +xs: +List<U32>
  for +k: Nat
  for +good: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.bytes_domain(List.take(&2, U32, xs, k)) == True{} : Bool}
def domain_take(xs, k, good):
  match xs k:
    case Nil{} _: {==}
    case Con{h, t} 0n: {==}
    case Con{h, t} 1n+p: V.and_true(U32.is_lt(h, 256), SP.bytes_domain(List.take(&2, U32, t, p)), V.and_left(U32.is_lt(h, 256), SP.bytes_domain(t), good), domain_take(t, p, V.and_right(U32.is_lt(h, 256), SP.bytes_domain(t), good)))

# Every slice denotes bytes in range.
law slice_domain:
  for +s: P.Slice
  {SP.bytes_domain(P.slice_bytes(s)) == True{} : Bool}
def slice_domain(s):
  match s:
    case P.Slice{cs, at, n}: domain_take(List.drop(&2, U32, P.chunks_bytes(cs), at), n, domain_drop(P.chunks_bytes(cs), at, chunks_bytes_domain(cs)))

def pred(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

law succ_inj:
  for +a: Nat
  for +b: Nat
  for +same: {1n+a == 1n+b : Nat}
  {a == b : Nat}
def succ_inj(a, b, same): Equal.cong(Nat, Nat, pred, 1n+a, 1n+b, same)

# ---------------------------------------------------------------------------
# The decoder's cheap arithmetic guards are the standard comparisons.
law nat_eq_correct:
  for +a: Nat
  for +b: Nat
  {D.nat_eq(a, b) == Nat.is_eq(a, b) : Bool}
def nat_eq_correct(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: nat_eq_correct(p, q)

law nat_le_correct:
  for +a: Nat
  for +b: Nat
  {D.nat_le(a, b) == Nat.is_le(a, b) : Bool}
def nat_le_correct(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: nat_le_correct(p, q)

law nat_eq_sound:
  for +a: Nat
  for +b: Nat
  for +same: {D.nat_eq(a, b) == True{} : Bool}
  {a == b : Nat}
def nat_eq_sound(a, b, same):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: Empty.absurd({0n == 1n+q : Nat}, F.false_true(same))
    case 1n+p 0n: Empty.absurd({1n+p == 0n : Nat}, F.false_true(same))
    case 1n+p 1n+q: Equal.cong(Nat, Nat, m => 1n+m, p, q, nat_eq_sound(p, q, same))

law nat_le_sound:
  for +a: Nat
  for +b: Nat
  for +small: {D.nat_le(a, b) == True{} : Bool}
  {Nat.is_le(a, b) == True{} : Bool}
def nat_le_sound(a, b, small):
  Equal.trans(Bool, Nat.is_le(a, b), D.nat_le(a, b), True{}, Equal.sym(Bool, D.nat_le(a, b), Nat.is_le(a, b), nat_le_correct(a, b)), small)

# ---------------------------------------------------------------------------
# Byte-vector leaf: the decoded value is the region's bytes, and it re-encodes
# to exactly those bytes under the independent specification.
law scope_from_domain:
  for +xs: +List<U32>
  for +n: Nat
  for +sized: {List.length(&2, U32, xs) == n : Nat}
  for +good: {SP.bytes_domain(xs) == True{} : Bool}
  {SP.byte_scope(n, xs) == True{} : Bool}
def scope_from_domain(xs, n, sized, good):
  match xs n:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: Empty.absurd({SP.byte_scope(1n+p, []) == True{} : Bool}, F.false_true(Equal.cong(Nat, Bool, m => Nat.is_eq(m, 0n), 1n+p, 0n, Equal.sym(Nat, 0n, 1n+p, sized))))
    case Con{h, t} 0n: Empty.absurd({SP.byte_scope(0n, h <> t) == True{} : Bool}, F.false_true(Equal.cong(Nat, Bool, m => Nat.is_eq(m, 0n), 1n+List.length(&2, U32, t), 0n, sized)))
    case Con{h, t} 1n+p:
      V.and_true(U32.is_lt(h, 256), SP.byte_scope(p, t), V.and_left(U32.is_lt(h, 256), SP.bytes_domain(t), good),
        scope_from_domain(t, p, succ_inj(List.length(&2, U32, t), p, sized), V.and_right(U32.is_lt(h, 256), SP.bytes_domain(t), good)))

law vector_encoding_exact:
  for +m: Nat
  for +ys: +List<U32>
  for +sized: {List.length(&2, U32, ys) == m : Nat}
  for +good: {SP.bytes_domain(ys) == True{} : Bool}
  for +positive: {Nat.is_lt(0n, m) == True{} : Bool}
  for +room: {SBytes.size_fits(m) == True{} : Bool}
  {SBytes.vector_encoding(m, ys) == Some{ys} : Maybe<&2, +List<U32>>}
def vector_encoding_exact(m, ys, sized, good, positive, room):
  match m:
    case 0n: Empty.absurd({SBytes.vector_encoding(0n, ys) == Some{ys} : Maybe<&2, +List<U32>>}, F.false_true(positive))
    case 1n+p:
      %Equal.sym(Bool, Bool.and(SP.byte_scope(1n+p, ys), SBytes.size_fits(1n+p)), True{}, V.and_true(SP.byte_scope(1n+p, ys), SBytes.size_fits(1n+p), scope_from_domain(ys, 1n+p, sized, good), room)) : {SP.optional(_, ys) == Some{ys} : Maybe<&2, +List<U32>>}
      {==}

# ---------------------------------------------------------------------------
# What a decoded region must satisfy: the value re-encodes, under the frozen
# specification, to exactly the first `size` bytes the slice denotes, and the
# returned cursor denotes exactly the rest.
def region_sound(s: T.Schema, size: Nat, sl: P.Slice, out: D.Out) -> Type:
  match out:
    case D.Begin{r}: Empty
    case D.Parsed{v, rest}:
      {SC.parts(C.to_value(v), s) == Some{[SC.fragment(SS.fixed_size(s), List.take(&2, U32, P.slice_bytes(sl), size))]} : Maybe<&2, +List<T.Part>>}
      & {P.slice_bytes(rest) == List.drop(&2, U32, P.slice_bytes(sl), size) : +List<U32>}
      & {List.length(&2, U32, P.slice_bytes(rest)) == P.slice_size(rest) : Nat}
    case _: Unit

law sized_room:
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +same: {n == m : Nat}
  {Nat.is_le(m, P.slice_size(xs)) == True{} : Bool}
def sized_room(m, n, xs, room, same):
  %same : {Nat.is_le(_, P.slice_size(xs)) == True{} : Bool}
  room

law sized_by_wf:
  for +xs: P.Slice
  for +m: Nat
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(m, P.slice_size(xs)) == True{} : Bool}
  {Nat.is_le(m, List.length(&2, U32, P.slice_bytes(xs))) == True{} : Bool}
def sized_by_wf(xs, m, good, room):
  %Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(xs)), P.slice_size(xs), good) : {Nat.is_le(m, _) == True{} : Bool}
  room

law byte_vector_parts:
  for +m: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(m, P.slice_size(xs)) == True{} : Bool}
  for +positive: {Nat.is_lt(0n, m) == True{} : Bool}
  for +fits: {D.fits(m) == True{} : Bool}
  {SC.parts(C.to_value(C.CBytes{P.sub(xs, m)}), T.ByteVector{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), m))]} : Maybe<&2, +List<T.Part>>}
def byte_vector_parts(m, xs, good, room, positive, fits):
  %Equal.sym(+List<U32>, P.to_list(P.sub(xs, m)), P.slice_bytes(P.sub(xs, m)), PK.to_list_view(P.sub(xs, m), PK.wf_sub(xs, m, good, room))) : {SC.parts(T.BytesValue{_}, T.ByteVector{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), m))]} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(+List<U32>, P.slice_bytes(P.sub(xs, m)), List.take(&2, U32, P.slice_bytes(xs), m), PK.sub_view(xs, m)) : {SC.parts(T.BytesValue{_}, T.ByteVector{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), m))]} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, SBytes.vector_encoding(m, List.take(&2, U32, P.slice_bytes(xs), m)), Some{List.take(&2, U32, P.slice_bytes(xs), m)}, vector_encoding_exact(m, List.take(&2, U32, P.slice_bytes(xs), m), PK.take_length(P.slice_bytes(xs), m, sized_by_wf(xs, m, good, room)), domain_take(P.slice_bytes(xs), m, slice_domain(xs)), positive, fits)) : {SC.one(_, Some{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), m))]} : Maybe<&2, +List<T.Part>>}
  {==}

law byte_vector_leaf_sound:
  for +ok: Bool
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +same: {Bool.and(D.nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), D.fits(m))) == ok : Bool}
  region_sound(T.ByteVector{m}, n, xs, D.bytes_leaf(ok, m, xs))
def byte_vector_leaf_sound(ok, m, n, xs, good, room, same):
  match ok:
    case False{}: Unit{}
    case True{}:
      %Equal.sym(Nat, n, m, nat_eq_sound(n, m, V.and_left(D.nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), D.fits(m)), same))) : region_sound(T.ByteVector{m}, _, xs, D.bytes_leaf(True{}, m, xs))
      (byte_vector_parts(m, xs, good, sized_room(m, n, xs, room, nat_eq_sound(n, m, V.and_left(D.nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), D.fits(m)), same))),
         V.and_left(Nat.is_lt(0n, m), D.fits(m), V.and_right(D.nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), D.fits(m)), same)),
         V.and_right(Nat.is_lt(0n, m), D.fits(m), V.and_right(D.nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), D.fits(m)), same))),
       (PK.adv_view(xs, m), PK.wf_adv(xs, m, good)))

# ---------------------------------------------------------------------------
# Byte-list leaf.
law fits_bridge:
  for +n: Nat
  {D.fits(n) == SLength.fits(4n, n) : Bool}
def fits_bridge(n): {==}

law byte_list_encoding_exact:
  for +cap: Nat
  for +ys: +List<U32>
  for +good: {SP.bytes_domain(ys) == True{} : Bool}
  for +bound: {Nat.is_le(List.length(&2, U32, ys), cap) == True{} : Bool}
  for +room: {SLength.fits(4n, List.length(&2, U32, ys)) == True{} : Bool}
  {SByteList.encoding(cap, ys) == Some{ys} : Maybe<&2, +List<U32>>}
def byte_list_encoding_exact(cap, ys, good, bound, room):
  %Equal.sym(Bool, Bool.and(Bool.and(SP.bytes_domain(ys), Nat.is_le(List.length(&2, U32, ys), cap)), SLength.fits(4n, List.length(&2, U32, ys))), True{}, V.and_true(Bool.and(SP.bytes_domain(ys), Nat.is_le(List.length(&2, U32, ys), cap)), SLength.fits(4n, List.length(&2, U32, ys)), V.and_true(SP.bytes_domain(ys), Nat.is_le(List.length(&2, U32, ys), cap), good, bound), room)) : {SP.optional(_, ys) == Some{ys} : Maybe<&2, +List<U32>>}
  {==}

law taken_length:
  for +xs: P.Slice
  for +n: Nat
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  {List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)) == n : Nat}
def taken_length(xs, n, good, room):
  PK.take_length(P.slice_bytes(xs), n, sized_by_wf(xs, n, good, room))

law taken_bound:
  for +xs: P.Slice
  for +n: Nat
  for +m: Nat
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +bound: {D.nat_le(n, m) == True{} : Bool}
  {Nat.is_le(List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)), m) == True{} : Bool}
def taken_bound(xs, n, m, good, room, bound):
  %Equal.sym(Nat, List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)), n, taken_length(xs, n, good, room)) : {Nat.is_le(_, m) == True{} : Bool}
  nat_le_sound(n, m, bound)

law taken_fits:
  for +xs: P.Slice
  for +n: Nat
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +fits: {SLength.fits(4n, n) == True{} : Bool}
  {SLength.fits(4n, List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n))) == True{} : Bool}
def taken_fits(xs, n, good, room, fits):
  %Equal.sym(Nat, List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)), n, taken_length(xs, n, good, room)) : {SLength.fits(4n, _) == True{} : Bool}
  fits

# ---------------------------------------------------------------------------
# Boolean and null leaves.

law byte_list_parts:
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +bound: {D.nat_le(n, m) == True{} : Bool}
  for +fits: {SLength.fits(4n, n) == True{} : Bool}
  {SC.parts(C.to_value(C.CBytes{P.sub(xs, n)}), T.ByteList{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
def byte_list_parts(m, n, xs, good, room, bound, fits):
  %Equal.sym(+List<U32>, P.to_list(P.sub(xs, n)), P.slice_bytes(P.sub(xs, n)), PK.to_list_view(P.sub(xs, n), PK.wf_sub(xs, n, good, room))) : {SC.parts(T.BytesValue{_}, T.ByteList{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(+List<U32>, P.slice_bytes(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), PK.sub_view(xs, n)) : {SC.parts(T.BytesValue{_}, T.ByteList{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, SByteList.encoding(m, List.take(&2, U32, P.slice_bytes(xs), n)), Some{List.take(&2, U32, P.slice_bytes(xs), n)}, byte_list_encoding_exact(m, List.take(&2, U32, P.slice_bytes(xs), n), domain_take(P.slice_bytes(xs), n, slice_domain(xs)), taken_bound(xs, n, m, good, room, bound), taken_fits(xs, n, good, room, fits))) : {SC.one(_, None{}) == Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  {==}

law byte_list_leaf_sound:
  for +ok: Bool
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +same: {Bool.and(D.nat_le(n, m), D.fits(n)) == ok : Bool}
  region_sound(T.ByteList{m}, n, xs, D.bytes_leaf(ok, n, xs))
def byte_list_leaf_sound(ok, m, n, xs, good, room, same):
  match ok:
    case False{}: Unit{}
    case True{}:
      (byte_list_parts(m, n, xs, good, room,
         V.and_left(D.nat_le(n, m), D.fits(n), same),
         Equal.trans(Bool, SLength.fits(4n, n), D.fits(n), True{}, Equal.sym(Bool, D.fits(n), SLength.fits(4n, n), fits_bridge(n)), V.and_right(D.nat_le(n, m), D.fits(n), same))),
       (PK.adv_view(xs, n), PK.wf_adv(xs, n, good)))

law null_parts:
  for +xs: P.Slice
  {SC.parts(C.to_value(C.CNull{}), T.Null{}) == Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), 0n))]} : Maybe<&2, +List<T.Part>>}
def null_parts(xs):
  %Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), 0n), [], PK.take_zero(P.slice_bytes(xs))) : {Some{[T.Fixed{[]}]} == Some{[SC.fragment(Some{0n}, _)]} : Maybe<&2, +List<T.Part>>}
  {==}

law null_leaf_sound:
  for +ok: Bool
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +same: {D.nat_eq(n, 0n) == ok : Bool}
  region_sound(T.Null{}, n, xs, D.null_leaf(ok, xs))
def null_leaf_sound(ok, n, xs, good, same):
  match ok:
    case False{}: Unit{}
    case True{}:
      %Equal.sym(Nat, n, 0n, nat_eq_sound(n, 0n, same)) : region_sound(T.Null{}, _, xs, D.null_leaf(True{}, xs))
      (null_parts(xs), (Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))), good))

# ---------------------------------------------------------------------------
# Boolean leaf.
law take_one:
  for +xs: +List<U32>
  for +nonempty: {Nat.is_le(1n, List.length(&2, U32, xs)) == True{} : Bool}
  {List.take(&2, U32, xs, 1n) == [IP.at(xs, 0n)] : +List<U32>}
def take_one(xs, nonempty):
  match xs:
    case Nil{}: Empty.absurd({List.take(&2, U32, [], 1n) == [IP.at([], 0n)] : +List<U32>}, F.false_true(nonempty))
    case Con{h, t}: Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.take(&2, U32, t, 0n), [], PK.take_zero(t))

law boolean_encoding_matches:
  for +b: Bool
  for +byte: U32
  for +enc: {SP.boolean_encoding(b) == [byte] : +List<U32>}
  {SC.parts(C.to_value(C.CBool{b}), T.Boolean{}) == Some{[SC.fragment(Some{1n}, [byte])]} : Maybe<&2, +List<T.Part>>}
def boolean_encoding_matches(b, byte, enc):
  %enc : {SC.parts(C.to_value(C.CBool{b}), T.Boolean{}) == Some{[SC.fragment(Some{1n}, _)]} : Maybe<&2, +List<T.Part>>}
  {==}

law boolean_parts:
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(1n, P.slice_size(xs)) == True{} : Bool}
  for +b: Bool
  for +byte: U32
  for +same: {P.byte_at(xs, 0n) == byte : U32}
  for +enc: {SP.boolean_encoding(b) == [byte] : +List<U32>}
  {SC.parts(C.to_value(C.CBool{b}), T.Boolean{}) == Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), 1n))]} : Maybe<&2, +List<T.Part>>}
def boolean_parts(xs, good, room, b, byte, same, enc):
  %Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), 1n), [IP.at(P.slice_bytes(xs), 0n)], take_one(P.slice_bytes(xs), sized_by_wf(xs, 1n, good, room))) : {SC.parts(C.to_value(C.CBool{b}), T.Boolean{}) == Some{[SC.fragment(Some{1n}, _)]} : Maybe<&2, +List<T.Part>>}
  %PK.byte_at_view(xs, 0n) : {SC.parts(C.to_value(C.CBool{b}), T.Boolean{}) == Some{[SC.fragment(Some{1n}, [_])]} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(U32, P.byte_at(xs, 0n), byte, same) : {SC.parts(C.to_value(C.CBool{b}), T.Boolean{}) == Some{[SC.fragment(Some{1n}, [_])]} : Maybe<&2, +List<T.Part>>}
  boolean_encoding_matches(b, byte, enc)

law boolean_byte_sound:
  for +zero: Bool
  for +one: Bool
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(1n, P.slice_size(xs)) == True{} : Bool}
  for +z: {U32.is_eq(P.byte_at(xs, 0n), 0) == zero : Bool}
  for +o: {U32.is_eq(P.byte_at(xs, 0n), 1) == one : Bool}
  region_sound(T.Boolean{}, 1n, xs, D.boolean_byte(zero, one, P.adv(xs, 1n)))
def boolean_byte_sound(zero, one, xs, good, room, z, o):
  match zero one:
    case True{} _: (boolean_parts(xs, good, room, False{}, 0, W.u32_equal_sound(P.byte_at(xs, 0n), 0, z), {==}), (PK.adv_view(xs, 1n), PK.wf_adv(xs, 1n, good)))
    case False{} True{}: (boolean_parts(xs, good, room, True{}, 1, W.u32_equal_sound(P.byte_at(xs, 0n), 1, o), {==}), (PK.adv_view(xs, 1n), PK.wf_adv(xs, 1n, good)))
    case False{} False{}: Unit{}

law boolean_leaf_sound:
  for +ok: Bool
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +same: {D.nat_eq(n, 1n) == ok : Bool}
  region_sound(T.Boolean{}, n, xs, D.boolean_leaf(ok, xs))
def boolean_leaf_sound(ok, n, xs, good, room, same):
  match ok:
    case False{}: Unit{}
    case True{}:
      %Equal.sym(Nat, n, 1n, nat_eq_sound(n, 1n, same)) : region_sound(T.Boolean{}, _, xs, D.boolean_leaf(True{}, xs))
      boolean_byte_sound(U32.is_eq(P.byte_at(xs, 0n), 0), U32.is_eq(P.byte_at(xs, 0n), 1), xs, good,
        sized_room(1n, n, xs, room, nat_eq_sound(n, 1n, same)), {==}, {==})

# ---------------------------------------------------------------------------
# Unsigned leaf. The width bytes at the cursor are read little-endian; the
# frozen specification re-encodes that value to exactly those bytes.
law uint_valid_bytes:
  for +w: Primitive.Width
  for +ys: +List<U32>
  for +sized: {List.length(&2, U32, ys) == IP.width(w) : Nat}
  for +good: {SP.bytes_domain(ys) == True{} : Bool}
  {IP.valid_bytes(IP.width(w), ys) == True{} : Bool}
def uint_valid_bytes(w, ys, sized, good):
  Equal.trans(Bool, IP.valid_bytes(IP.width(w), ys), SP.byte_scope(IP.width(w), ys), True{},
    Basic.byte_scope_correct(IP.width(w), ys),
    scope_from_domain(ys, IP.width(w), sized, good))

law uint_encoding_exact:
  for +w: Primitive.Width
  for +ys: +List<U32>
  for +sized: {List.length(&2, U32, ys) == IP.width(w) : Nat}
  for +good: {SP.bytes_domain(ys) == True{} : Bool}
  {SP.uint_encoding(w, IP.decoded(ys)) == Some{ys} : Maybe<&2, +List<U32>>}
def uint_encoding_exact(w, ys, sized, good):
  Equal.trans(Maybe<&2, +List<U32>>, SP.uint_encoding(w, IP.decoded(ys)), IP.uint_serialize(w, IP.decoded(ys)), Some{ys},
    Equal.sym(Maybe<&2, +List<U32>>, IP.uint_serialize(w, IP.decoded(ys)), SP.uint_encoding(w, IP.decoded(ys)), IE.uint_serialize_correct(w, IP.decoded(ys))),
    CI.uint_accepted_reencode(w, ys, IP.decoded(ys),
      Equal.cong(Bool, Maybe<&2, Primitive.UInt>, b => IP.decode_checked(b, ys), IP.valid_bytes(IP.width(w), ys), True{}, uint_valid_bytes(w, ys, sized, good))))

law uint_parts:
  for +w: Primitive.Width
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(IP.width(w), P.slice_size(xs)) == True{} : Bool}
  {SC.parts(C.to_value(C.CUint{P.uint_of(xs, IP.width(w))}), T.Unsigned{w}) == Some{[SC.fragment(SS.fixed_size(T.Unsigned{w}), List.take(&2, U32, P.slice_bytes(xs), IP.width(w)))]} : Maybe<&2, +List<T.Part>>}
def uint_parts(w, xs, good, room):
  %Equal.sym(Primitive.UInt, P.uint_of(xs, IP.width(w)), IP.decoded(List.take(&2, U32, P.slice_bytes(xs), IP.width(w))), PK.uint_of_view(xs, IP.width(w))) : {SC.parts(T.UnsignedValue{_}, T.Unsigned{w}) == Some{[SC.fragment(SS.fixed_size(T.Unsigned{w}), List.take(&2, U32, P.slice_bytes(xs), IP.width(w)))]} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, SP.uint_encoding(w, IP.decoded(List.take(&2, U32, P.slice_bytes(xs), IP.width(w)))), Some{List.take(&2, U32, P.slice_bytes(xs), IP.width(w))}, uint_encoding_exact(w, List.take(&2, U32, P.slice_bytes(xs), IP.width(w)), PK.take_length(P.slice_bytes(xs), IP.width(w), sized_by_wf(xs, IP.width(w), good, room)), domain_take(P.slice_bytes(xs), IP.width(w), slice_domain(xs)))) : {SC.one(_, Some{SP.byte_width(w)}) == Some{[SC.fragment(SS.fixed_size(T.Unsigned{w}), List.take(&2, U32, P.slice_bytes(xs), IP.width(w)))]} : Maybe<&2, +List<T.Part>>}
  {==}

law uint_leaf_sound:
  for +ok: Bool
  for +w: Primitive.Width
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +same: {D.nat_eq(n, IP.width(w)) == ok : Bool}
  region_sound(T.Unsigned{w}, n, xs, D.uint_leaf(ok, w, xs))
def uint_leaf_sound(ok, w, n, xs, good, room, same):
  match ok:
    case False{}: Unit{}
    case True{}:
      %Equal.sym(Nat, n, IP.width(w), nat_eq_sound(n, IP.width(w), same)) : region_sound(T.Unsigned{w}, _, xs, D.uint_leaf(True{}, w, xs))
      (uint_parts(w, xs, good, sized_room(IP.width(w), n, xs, room, nat_eq_sound(n, IP.width(w), same))),
       (PK.adv_view(xs, IP.width(w)), PK.wf_adv(xs, IP.width(w), good)))

# ---------------------------------------------------------------------------
# Bitfield leaves. The region bytes are materialised (bitfields are small in
# every supported schema) and handed to the checked bitfield codecs, whose
# canonicality laws say the accepted bit list re-encodes to exactly those
# bytes under the frozen specification.
law region_view:
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  {P.to_list(P.sub(xs, n)) == List.take(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
def region_view(n, xs, good, room):
  Equal.trans(+List<U32>, P.to_list(P.sub(xs, n)), P.slice_bytes(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n),
    PK.to_list_view(P.sub(xs, n), PK.wf_sub(xs, n, good, room)),
    PK.sub_view(xs, n))

law bit_vector_leaf_sound:
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for r: Maybe<&2, +List<Bool>>
  for same: {IBits.bitvector_deserialize(m, P.to_list(P.sub(xs, n))) == r : Maybe<&2, +List<Bool>>}
  region_sound(T.BitVector{m}, n, xs, D.bits_result(r, P.adv(xs, n)))
def bit_vector_leaf_sound(m, n, xs, good, room, r, same):
  match r:
    case None{}: Unit{}
    case Some{bs}:
      (%Equal.sym(Maybe<&2, +List<U32>>, SBits.vector_encoding(m, bs), Some{P.to_list(P.sub(xs, n))}, BVC.accepted_normative_canonical(m, P.to_list(P.sub(xs, n)), bs, same)) : {SC.one(_, Some{Nat.div(Nat.add(m, 7n), 8n)}) == Some{[SC.fragment(SS.fixed_size(T.BitVector{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
       %Equal.sym(+List<U32>, P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), region_view(n, xs, good, room)) : {Some{[SC.fragment(SS.fixed_size(T.BitVector{m}), _)]} == Some{[SC.fragment(SS.fixed_size(T.BitVector{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
       {==},
       (PK.adv_view(xs, n), PK.wf_adv(xs, n, good)))

law bit_list_leaf_sound:
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for r: Maybe<&2, +List<Bool>>
  for same: {IBits.bitlist_deserialize(m, P.to_list(P.sub(xs, n))) == r : Maybe<&2, +List<Bool>>}
  region_sound(T.BitList{m}, n, xs, D.bits_result(r, P.adv(xs, n)))
def bit_list_leaf_sound(m, n, xs, good, room, r, same):
  match r:
    case None{}: Unit{}
    case Some{bs}:
      (%Equal.sym(Maybe<&2, +List<U32>>, SBits.list_encoding(m, bs), Some{P.to_list(P.sub(xs, n))}, BLC.accepted_normative_canonical(m, P.to_list(P.sub(xs, n)), bs, same)) : {SC.one(_, None{}) == Some{[SC.fragment(SS.fixed_size(T.BitList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
       %Equal.sym(+List<U32>, P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), region_view(n, xs, good, room)) : {Some{[SC.fragment(SS.fixed_size(T.BitList{m}), _)]} == Some{[SC.fragment(SS.fixed_size(T.BitList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
       {==},
       (PK.adv_view(xs, n), PK.wf_adv(xs, n, good)))

# Progressive bitfields carry no declared capacity: the specification encodes
# them at their own length, which the decoded list satisfies by reflexivity.
law progressive_encoding_exact:
  for +cap: Nat
  for +ys: +List<U32>
  for +bs: +List<Bool>
  for decoded: {IBits.bitlist_deserialize(cap, ys) == Some{bs} : Maybe<&2, +List<Bool>>}
  {SBits.list_encoding(List.length(&2, Bool, bs), bs) == Some{ys} : Maybe<&2, +List<U32>>}
def progressive_encoding_exact(cap, ys, bs, decoded):
  %Equal.sym(Bool, SBits.list_domain(List.length(&2, Bool, bs), bs), True{}, NO.reflexive(List.length(&2, Bool, bs))) : {SBits.encoding(_, List.append(&2, Bool, bs, [True{}])) == Some{ys} : Maybe<&2, +List<U32>>}
  Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, zs => Some{zs}, SBitPack.pack(List.append(&2, Bool, bs, [True{}])), ys,
    Equal.trans(+List<U32>, SBitPack.pack(List.append(&2, Bool, bs, [True{}])), IBitPack.pack(List.append(&2, Bool, bs, [True{}])), ys,
      Equal.sym(+List<U32>, IBitPack.pack(List.append(&2, Bool, bs, [True{}])), SBitPack.pack(List.append(&2, Bool, bs, [True{}])), BPack.pack_correct(List.append(&2, Bool, bs, [True{}]))),
      BLC.accepted_packed(cap, ys, bs, decoded)))

law progressive_bits_leaf_sound:
  for +n: Nat
  for +xs: P.Slice
  for +good: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for r: Maybe<&2, +List<Bool>>
  for same: {IBits.bitlist_deserialize(Nat.mul(n, 8n), P.to_list(P.sub(xs, n))) == r : Maybe<&2, +List<Bool>>}
  region_sound(T.ProgressiveBits{}, n, xs, D.bits_result(r, P.adv(xs, n)))
def progressive_bits_leaf_sound(n, xs, good, room, r, same):
  match r:
    case None{}: Unit{}
    case Some{bs}:
      (%Equal.sym(Maybe<&2, +List<U32>>, SBits.list_encoding(List.length(&2, Bool, bs), bs), Some{P.to_list(P.sub(xs, n))}, progressive_encoding_exact(Nat.mul(n, 8n), P.to_list(P.sub(xs, n)), bs, same)) : {SC.one(_, None{}) == Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
       %Equal.sym(+List<U32>, P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), region_view(n, xs, good, room)) : {Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), _)]} == Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
       {==},
       (PK.adv_view(xs, n), PK.wf_adv(xs, n, good)))
