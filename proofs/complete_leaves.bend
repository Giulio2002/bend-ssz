import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/primitives.bend as IP
import ../spec/primitives.bend as SP
import ../spec/codec.bend as SC
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./word_facts.bend as F
import ./cursor_leaves.bend as CL
import ./primitive_invariants.bend as V
import ./nat_order.bend as NO
import ./encoding_complete.bend as Complete
import ./integer_encoding.bend as IE
import ../spec/bytes.bend as SBytes
import ../spec/byte_list.bend as SByteList
import ../src/bytes.bend as IBytes
import ../src/byte_list.bend as IByteList
import ./bytes.bend as ByteVectorLaws
import ../spec/nat_bytes.bend as SLength
import ../spec/bitfields.bend as SBits
import ../src/bitfields.bend as IBits
import ./bit_vector_canonical.bend as BitVectorLaws
import ./bit_list_codec.bend as BitListLaws
import ./bit_list_canonical.bend as BitListCanon
import ./schema_lookups.bend as SchemaLookups
import ../spec/bit_packing.bend as SPack
import ../src/lists.bend as Lists
import ./lists.bend as L
import ./leaf_sizes.bend as Leaf

# Completeness of the packed cursor decoder, leaf by leaf.
#
# `cursor_sound.go_sound` says an accepted region re-encodes to itself. These
# laws say the converse for the leaves: a region that already HOLDS the
# independent encoding of a value is accepted, and the value it yields is
# exactly that value. Together they pin the decoder to the specification in
# both directions.
#
# Every law is stated against `P.slice_bytes`, the byte list a slice denotes,
# and against the frozen `spec/` modules; no implementation encoder appears.

# The completeness obligation for one region.
def parsed_as(value: T.Value, sl: P.Slice, size: Nat, out: D.Out) -> Type:
  match out:
    case D.Parsed{v, rest}:
      {C.to_value(v) == value : T.Value}
      & {P.slice_bytes(rest) == List.drop(&2, U32, P.slice_bytes(sl), size) : +List<U32>}
      & {List.length(&2, U32, P.slice_bytes(rest)) == P.slice_size(rest) : Nat}
    case _: Empty

# The bytes of a one-fragment parts result, used to read the independent
# encoding out of the premise.
def fragment_bytes(r: Maybe<&2, +List<T.Part>>) -> +List<U32>:
  match r:
    case Some{Con{T.Fixed{xs}, Nil{}}}: xs
    case Some{Con{T.Variable{xs}, Nil{}}}: xs
    case _: []

# The region premise: the first `size` bytes of the slice are exactly the
# independent encoding of `value` at `schema`, as one fragment.
def holds(schema: T.Schema, value: T.Value, sl: P.Slice, size: Nat) -> Type:
  {SC.parts(value, schema) == Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(sl), size))]} : Maybe<&2, +List<T.Part>>}

law encoded_bytes:
  for +schema: T.Schema
  for +value: T.Value
  for +sl: P.Slice
  for +size: Nat
  for encoded: holds(schema, value, sl, size)
  {fragment_bytes(SC.parts(value, schema)) == fragment_bytes(Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(sl), size))]}) : +List<U32>}
def encoded_bytes(schema, value, sl, size, encoded):
  Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, fragment_bytes, SC.parts(value, schema), Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(sl), size))]}, encoded)

# A region whose byte count is known from the encoding it holds.
law size_of_encoding:
  for +xs: P.Slice
  for +n: Nat
  for +ys: +List<U32>
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +same: {ys == List.take(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
  {List.length(&2, U32, ys) == n : Nat}
def size_of_encoding(xs, n, ys, wf, room, same):
  %Equal.sym(+List<U32>, ys, List.take(&2, U32, P.slice_bytes(xs), n), same) : {List.length(&2, U32, _) == n : Nat}
  PK.take_length(P.slice_bytes(xs), n, CL.sized_by_wf(xs, n, wf, room))

# The first byte of a region is the first byte of the encoding it holds.
law first_byte:
  for +xs: P.Slice
  for +n: Nat
  for +ys: +List<U32>
  for +positive: {Nat.is_lt(0n, n) == True{} : Bool}
  for +same: {ys == List.take(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
  {P.byte_at(xs, 0n) == IP.at(ys, 0n) : U32}
def first_byte(xs, n, ys, positive, same):
  %Equal.sym(+List<U32>, ys, List.take(&2, U32, P.slice_bytes(xs), n), same) : {P.byte_at(xs, 0n) == IP.at(_, 0n) : U32}
  Equal.trans(U32, P.byte_at(xs, 0n), IP.at(P.slice_bytes(xs), 0n), IP.at(List.take(&2, U32, P.slice_bytes(xs), n), 0n),
    PK.byte_at_view(xs, 0n),
    Equal.sym(U32, IP.at(List.take(&2, U32, P.slice_bytes(xs), n), 0n), IP.at(P.slice_bytes(xs), 0n), PK.at_take_low(P.slice_bytes(xs), n, 0n, positive)))

# ---------------------------------------------------------------------------
# Boolean.
law boolean_complete:
  for +b: Bool
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for encoded: holds(T.Boolean{}, T.BooleanValue{b}, xs, n)
  parsed_as(T.BooleanValue{b}, xs, n, D.go(T.Boolean{}, 1n, 0n, D.Region{n, xs}))
def boolean_complete(b, n, xs, wf, room, encoded):
  match b:
    case False{}:
      +enc = encoded_bytes(T.Boolean{}, T.BooleanValue{False{}}, xs, n, encoded)
      +len = size_of_encoding(xs, n, [0], wf, room, enc)
      +enc1 = Equal.trans(+List<U32>, [0], List.take(&2, U32, P.slice_bytes(xs), n), List.take(&2, U32, P.slice_bytes(xs), 1n), enc,
        Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), n, 1n, Equal.sym(Nat, 1n, n, len)))
      %len : parsed_as(T.BooleanValue{False{}}, xs, _, D.go(T.Boolean{}, 1n, 0n, D.Region{_, xs}))
      %Equal.sym(U32, P.byte_at(xs, 0n), 0, first_byte(xs, 1n, [0], {==}, enc1)) : parsed_as(T.BooleanValue{False{}}, xs, 1n, D.boolean_byte(U32.is_eq(_, 0), U32.is_eq(_, 1), P.adv(xs, 1n)))
      ({==}, (PK.adv_view(xs, 1n), PK.wf_adv(xs, 1n, wf)))
    case True{}:
      +enc = encoded_bytes(T.Boolean{}, T.BooleanValue{True{}}, xs, n, encoded)
      +len = size_of_encoding(xs, n, [1], wf, room, enc)
      +enc1 = Equal.trans(+List<U32>, [1], List.take(&2, U32, P.slice_bytes(xs), n), List.take(&2, U32, P.slice_bytes(xs), 1n), enc,
        Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), n, 1n, Equal.sym(Nat, 1n, n, len)))
      %len : parsed_as(T.BooleanValue{True{}}, xs, _, D.go(T.Boolean{}, 1n, 0n, D.Region{_, xs}))
      %Equal.sym(U32, P.byte_at(xs, 0n), 1, first_byte(xs, 1n, [1], {==}, enc1)) : parsed_as(T.BooleanValue{True{}}, xs, 1n, D.boolean_byte(U32.is_eq(_, 0), U32.is_eq(_, 1), P.adv(xs, 1n)))
      ({==}, (PK.adv_view(xs, 1n), PK.wf_adv(xs, 1n, wf)))

# ---------------------------------------------------------------------------
# Null: the empty region.
law null_complete:
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for encoded: holds(T.Null{}, T.NullValue{}, xs, n)
  parsed_as(T.NullValue{}, xs, n, D.go(T.Null{}, 1n, 0n, D.Region{n, xs}))
def null_complete(n, xs, wf, room, encoded):
  +enc = encoded_bytes(T.Null{}, T.NullValue{}, xs, n, encoded)
  +len = size_of_encoding(xs, n, [], wf, room, enc)
  %len : parsed_as(T.NullValue{}, xs, _, D.go(T.Null{}, 1n, 0n, D.Region{_, xs}))
  ({==}, (Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))), wf))

# ---------------------------------------------------------------------------
# Shared shape helpers: reading the independent encoding out of a one-fragment
# parts result, and the two decoder guards a leaf region passes.
def bytes_of(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case Some{xs}: xs
    case None{}: []

def is_some_bytes(r: Maybe<&2, +List<U32>>) -> Bool:
  match r:
    case Some{xs}: True{}
    case None{}: False{}

def parts_present(r: Maybe<&2, +List<T.Part>>) -> Bool:
  match r:
    case Some{ps}: True{}
    case None{}: False{}

law present_one:
  for r: Maybe<&2, +List<U32>>
  for +width: Maybe<&2, Nat>
  {parts_present(SC.one(r, width)) == is_some_bytes(r) : Bool}
def present_one(r, width):
  match r:
    case None{}: {==}
    case Some{xs}: {==}

law bytes_one:
  for r: Maybe<&2, +List<U32>>
  for width: Maybe<&2, Nat>
  {fragment_bytes(SC.one(r, width)) == bytes_of(r) : +List<U32>}
def bytes_one(r, width):
  match r:
    case None{}: {==}
    case Some{xs}:
      match width:
        case None{}: {==}
        case Some{k}: {==}

law encoding_some:
  for r: Maybe<&2, +List<U32>>
  for +present: {is_some_bytes(r) == True{} : Bool}
  {r == Some{bytes_of(r)} : Maybe<&2, +List<U32>>}
def encoding_some(r, present):
  match r:
    case None{}: Empty.absurd({None{} == Some{bytes_of(None{})} : Maybe<&2, +List<U32>>}, F.false_true(present))
    case Some{xs}: {==}

law scope_length:
  for +n: Nat
  for +xs: +List<U32>
  for +ok: {SP.byte_scope(n, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == n : Nat}
def scope_length(n, xs, ok):
  match n xs:
    case 0n Nil{}: {==}
    case 0n Con{h, t}: Empty.absurd({1n+List.length(&2, U32, t) == 0n : Nat}, F.false_true(ok))
    case 1n+p Nil{}: Empty.absurd({0n == 1n+p : Nat}, F.false_true(ok))
    case 1n+p Con{h, t}:
      Equal.cong(Nat, Nat, m => 1n+m, List.length(&2, U32, t), p,
        scope_length(p, t, V.and_right(U32.is_lt(h, 256), SP.byte_scope(p, t), ok)))

law nat_eq_refl:
  for +a: Nat
  {D.nat_eq(a, a) == True{} : Bool}
def nat_eq_refl(a):
  match a:
    case 0n: {==}
    case 1n+p: nat_eq_refl(p)

law nat_eq_true:
  for +a: Nat
  for +b: Nat
  for +same: {a == b : Nat}
  {D.nat_eq(a, b) == True{} : Bool}
def nat_eq_true(a, b, same):
  %same : {D.nat_eq(a, _) == True{} : Bool}
  nat_eq_refl(a)

law nat_le_true:
  for +a: Nat
  for +b: Nat
  for +small: {Nat.is_le(a, b) == True{} : Bool}
  {D.nat_le(a, b) == True{} : Bool}
def nat_le_true(a, b, small):
  Equal.trans(Bool, D.nat_le(a, b), Nat.is_le(a, b), True{}, CL.nat_le_correct(a, b), small)

# ---------------------------------------------------------------------------
# Unsigned leaf: the region holds the little-endian digits of the value.
law uint_complete:
  for +w: Primitive.Width
  for +v: Primitive.UInt
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +encoded: {SC.parts(T.UnsignedValue{v}, T.Unsigned{w}) == Some{[SC.fragment(SS.fixed_size(T.Unsigned{w}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  parsed_as(T.UnsignedValue{v}, xs, n, D.go(T.Unsigned{w}, 1n, 0n, D.Region{n, xs}))
def uint_complete(w, v, n, xs, wf, room, encoded):
  +zs = bytes_of(SP.uint_encoding(w, v))
  +present = Equal.trans(Bool, is_some_bytes(SP.uint_encoding(w, v)), parts_present(SC.parts(T.UnsignedValue{v}, T.Unsigned{w})), True{},
    Equal.sym(Bool, parts_present(SC.one(SP.uint_encoding(w, v), Some{SP.byte_width(w)})), is_some_bytes(SP.uint_encoding(w, v)), present_one(SP.uint_encoding(w, v), Some{SP.byte_width(w)})),
    Equal.cong(Maybe<&2, +List<T.Part>>, Bool, parts_present, SC.parts(T.UnsignedValue{v}, T.Unsigned{w}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{w}), List.take(&2, U32, P.slice_bytes(xs), n))]}, encoded))
  +espec = encoding_some(SP.uint_encoding(w, v), present)
  +eimpl = Equal.trans(Maybe<&2, +List<U32>>, IP.uint_serialize(w, v), SP.uint_encoding(w, v), Some{zs}, IE.uint_serialize_correct(w, v), espec)
  +enc = Equal.trans(+List<U32>, zs, fragment_bytes(SC.parts(T.UnsignedValue{v}, T.Unsigned{w})), List.take(&2, U32, P.slice_bytes(xs), n),
    Equal.sym(+List<U32>, fragment_bytes(SC.one(SP.uint_encoding(w, v), Some{SP.byte_width(w)})), zs, bytes_one(SP.uint_encoding(w, v), Some{SP.byte_width(w)})),
    encoded_bytes(T.Unsigned{w}, T.UnsignedValue{v}, xs, n, encoded))
  +width = Equal.trans(Nat, n, List.length(&2, U32, zs), IP.width(w),
    Equal.sym(Nat, List.length(&2, U32, zs), n, size_of_encoding(xs, n, zs, wf, room, enc)),
    scope_length(IP.width(w), zs, Complete.serialized_scope(w, v, zs, eimpl)))
  +decoded = Equal.trans(Primitive.UInt, P.uint_of(xs, IP.width(w)), IP.decoded(zs), v,
    Equal.trans(Primitive.UInt, P.uint_of(xs, IP.width(w)), IP.decoded(List.take(&2, U32, P.slice_bytes(xs), IP.width(w))), IP.decoded(zs),
      PK.uint_of_view(xs, IP.width(w)),
      Equal.cong(+List<U32>, Primitive.UInt, ys => IP.decoded(ys), List.take(&2, U32, P.slice_bytes(xs), IP.width(w)), zs,
        Equal.sym(+List<U32>, zs, List.take(&2, U32, P.slice_bytes(xs), IP.width(w)),
          Equal.trans(+List<U32>, zs, List.take(&2, U32, P.slice_bytes(xs), n), List.take(&2, U32, P.slice_bytes(xs), IP.width(w)), enc,
            Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), n, IP.width(w), width))))),
    Complete.serialized_value(w, v, zs, eimpl))
  %Equal.sym(Bool, D.nat_eq(n, IP.width(w)), True{}, nat_eq_true(n, IP.width(w), width)) : parsed_as(T.UnsignedValue{v}, xs, n, D.uint_leaf(_, w, xs))
  %decoded : parsed_as(T.UnsignedValue{_}, xs, n, D.Parsed{C.CUint{P.uint_of(xs, IP.width(w))}, P.adv(xs, IP.width(w))})
  ({==},
   (Equal.trans(+List<U32>, P.slice_bytes(P.adv(xs, IP.width(w))), List.drop(&2, U32, P.slice_bytes(xs), IP.width(w)), List.drop(&2, U32, P.slice_bytes(xs), n),
      PK.adv_view(xs, IP.width(w)),
      Equal.cong(Nat, +List<U32>, k => List.drop(&2, U32, P.slice_bytes(xs), k), IP.width(w), n, Equal.sym(Nat, n, IP.width(w), width))),
    PK.wf_adv(xs, IP.width(w), wf)))

# ---------------------------------------------------------------------------
# A specification `optional` that produced a value had its condition hold, and
# produced exactly the value it was given.
law optional_some:
  for ok: Bool
  for +ys: +List<U32>
  for +zs: +List<U32>
  for +e: {SP.optional(ok, ys) == Some{zs} : Maybe<&2, +List<U32>>}
  {ok == True{} : Bool} & {ys == zs : +List<U32>}
def optional_some(ok, ys, zs, e):
  match ok:
    case False{}:
      Empty.absurd({False{} == True{} : Bool} & {ys == zs : +List<U32>},
        F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, is_some_bytes, None{}, Some{zs}, e)))
    case True{}:
      ({==}, Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, bytes_of, Some{ys}, Some{zs}, e))

# ---------------------------------------------------------------------------
# Byte-vector leaf: the region holds exactly the vector's bytes.
law facts_dom:
  for +ok: Bool
  for +x: +List<U32>
  for +y: +List<U32>
  for pair: {ok == True{} : Bool} & {x == y : +List<U32>}
  {ok == True{} : Bool}
def facts_dom(ok, x, y, pair):
  (l, r) = pair
  l

law facts_bytes:
  for +ok: Bool
  for +x: +List<U32>
  for +y: +List<U32>
  for pair: {ok == True{} : Bool} & {x == y : +List<U32>}
  {x == y : +List<U32>}
def facts_bytes(ok, x, y, pair):
  (l, r) = pair
  r

law vector_facts:
  for +m: Nat
  for +ys: +List<U32>
  for +n: Nat
  for +xs: P.Slice
  for +encoded: {SC.parts(T.BytesValue{ys}, T.ByteVector{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  {SBytes.vector_domain(m, ys) == True{} : Bool} & {ys == List.take(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
def vector_facts(m, ys, n, xs, encoded):
  +present = Equal.trans(Bool, is_some_bytes(SBytes.vector_encoding(m, ys)), parts_present(SC.parts(T.BytesValue{ys}, T.ByteVector{m})), True{},
    Equal.sym(Bool, parts_present(SC.one(SBytes.vector_encoding(m, ys), Some{m})), is_some_bytes(SBytes.vector_encoding(m, ys)), present_one(SBytes.vector_encoding(m, ys), Some{m})),
    Equal.cong(Maybe<&2, +List<T.Part>>, Bool, parts_present, SC.parts(T.BytesValue{ys}, T.ByteVector{m}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), n))]}, encoded))
  +enc = Equal.trans(+List<U32>, bytes_of(SBytes.vector_encoding(m, ys)), fragment_bytes(SC.parts(T.BytesValue{ys}, T.ByteVector{m})), List.take(&2, U32, P.slice_bytes(xs), n),
    Equal.sym(+List<U32>, fragment_bytes(SC.one(SBytes.vector_encoding(m, ys), Some{m})), bytes_of(SBytes.vector_encoding(m, ys)), bytes_one(SBytes.vector_encoding(m, ys), Some{m})),
    encoded_bytes(T.ByteVector{m}, T.BytesValue{ys}, xs, n, encoded))
  (facts_dom(SBytes.vector_domain(m, ys), ys, bytes_of(SBytes.vector_encoding(m, ys)), optional_some(SBytes.vector_domain(m, ys), ys, bytes_of(SBytes.vector_encoding(m, ys)), encoding_some(SBytes.vector_encoding(m, ys), present))),
   Equal.trans(+List<U32>, ys, bytes_of(SBytes.vector_encoding(m, ys)), List.take(&2, U32, P.slice_bytes(xs), n),
     facts_bytes(SBytes.vector_domain(m, ys), ys, bytes_of(SBytes.vector_encoding(m, ys)), optional_some(SBytes.vector_domain(m, ys), ys, bytes_of(SBytes.vector_encoding(m, ys)), encoding_some(SBytes.vector_encoding(m, ys), present))),
     enc))

law byte_vector_complete:
  for +m: Nat
  for +ys: +List<U32>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +encoded: {SC.parts(T.BytesValue{ys}, T.ByteVector{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteVector{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  parsed_as(T.BytesValue{ys}, xs, n, D.go(T.ByteVector{m}, 1n, 0n, D.Region{n, xs}))
def byte_vector_complete(m, ys, n, xs, wf, room, encoded):
  match m:
    case 0n:
      +dom = facts_dom(SBytes.vector_domain(0n, ys), ys, List.take(&2, U32, P.slice_bytes(xs), n), vector_facts(0n, ys, n, xs, encoded))
      Empty.absurd(parsed_as(T.BytesValue{ys}, xs, n, D.go(T.ByteVector{0n}, 1n, 0n, D.Region{n, xs})), F.false_true(dom))
    case 1n+p:
      +dom = facts_dom(SBytes.vector_domain(1n+p, ys), ys, List.take(&2, U32, P.slice_bytes(xs), n), vector_facts(1n+p, ys, n, xs, encoded))
      +ysenc = facts_bytes(SBytes.vector_domain(1n+p, ys), ys, List.take(&2, U32, P.slice_bytes(xs), n), vector_facts(1n+p, ys, n, xs, encoded))
      +scope = V.and_left(SP.byte_scope(1n+p, ys), SBytes.size_fits(1n+p), dom)
      +fits = V.and_right(SP.byte_scope(1n+p, ys), SBytes.size_fits(1n+p), dom)
      +nm = Equal.trans(Nat, n, List.length(&2, U32, ys), 1n+p,
        Equal.sym(Nat, List.length(&2, U32, ys), n, size_of_encoding(xs, n, ys, wf, room, ysenc)),
        scope_length(1n+p, ys, scope))
      +guard = V.and_true(D.nat_eq(n, 1n+p), Bool.and(Nat.is_lt(0n, 1n+p), D.fits(1n+p)), nat_eq_true(n, 1n+p, nm),
        V.and_true(Nat.is_lt(0n, 1n+p), D.fits(1n+p), {==}, fits))
      +contents = Equal.trans(+List<U32>, P.to_list(P.sub(xs, 1n+p)), List.take(&2, U32, P.slice_bytes(xs), 1n+p), ys,
        Equal.trans(+List<U32>, P.to_list(P.sub(xs, 1n+p)), P.slice_bytes(P.sub(xs, 1n+p)), List.take(&2, U32, P.slice_bytes(xs), 1n+p),
          PK.to_list_view(P.sub(xs, 1n+p), PK.wf_sub(xs, 1n+p, wf, CL.sized_room(1n+p, n, xs, room, nm))),
          PK.sub_view(xs, 1n+p)),
        Equal.sym(+List<U32>, ys, List.take(&2, U32, P.slice_bytes(xs), 1n+p),
          Equal.trans(+List<U32>, ys, List.take(&2, U32, P.slice_bytes(xs), n), List.take(&2, U32, P.slice_bytes(xs), 1n+p), ysenc,
            Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), n, 1n+p, nm))))
      %Equal.sym(Bool, Bool.and(D.nat_eq(n, 1n+p), Bool.and(Nat.is_lt(0n, 1n+p), D.fits(1n+p))), True{}, guard) : parsed_as(T.BytesValue{ys}, xs, n, D.bytes_leaf(_, 1n+p, xs))
      %contents : parsed_as(T.BytesValue{_}, xs, n, D.Parsed{C.CBytes{P.sub(xs, 1n+p)}, P.adv(xs, 1n+p)})
      ({==},
       (Equal.trans(+List<U32>, P.slice_bytes(P.adv(xs, 1n+p)), List.drop(&2, U32, P.slice_bytes(xs), 1n+p), List.drop(&2, U32, P.slice_bytes(xs), n),
          PK.adv_view(xs, 1n+p),
          Equal.cong(Nat, +List<U32>, k => List.drop(&2, U32, P.slice_bytes(xs), k), 1n+p, n, Equal.sym(Nat, n, 1n+p, nm))),
        PK.wf_adv(xs, 1n+p, wf)))

# ---------------------------------------------------------------------------
# Byte-list leaf: the region is the list's bytes, and the region size is the
# list length the specification accepted.
law list_facts:
  for +m: Nat
  for +ys: +List<U32>
  for +n: Nat
  for +xs: P.Slice
  for +encoded: {SC.parts(T.BytesValue{ys}, T.ByteList{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  {SByteList.domain(m, ys) == True{} : Bool} & {ys == List.take(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
def list_facts(m, ys, n, xs, encoded):
  +present = Equal.trans(Bool, is_some_bytes(SByteList.encoding(m, ys)), parts_present(SC.parts(T.BytesValue{ys}, T.ByteList{m})), True{},
    Equal.sym(Bool, parts_present(SC.one(SByteList.encoding(m, ys), None{})), is_some_bytes(SByteList.encoding(m, ys)), present_one(SByteList.encoding(m, ys), None{})),
    Equal.cong(Maybe<&2, +List<T.Part>>, Bool, parts_present, SC.parts(T.BytesValue{ys}, T.ByteList{m}), Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]}, encoded))
  +enc = Equal.trans(+List<U32>, bytes_of(SByteList.encoding(m, ys)), fragment_bytes(SC.parts(T.BytesValue{ys}, T.ByteList{m})), List.take(&2, U32, P.slice_bytes(xs), n),
    Equal.sym(+List<U32>, fragment_bytes(SC.one(SByteList.encoding(m, ys), None{})), bytes_of(SByteList.encoding(m, ys)), bytes_one(SByteList.encoding(m, ys), None{})),
    encoded_bytes(T.ByteList{m}, T.BytesValue{ys}, xs, n, encoded))
  (facts_dom(SByteList.domain(m, ys), ys, bytes_of(SByteList.encoding(m, ys)), optional_some(SByteList.domain(m, ys), ys, bytes_of(SByteList.encoding(m, ys)), encoding_some(SByteList.encoding(m, ys), present))),
   Equal.trans(+List<U32>, ys, bytes_of(SByteList.encoding(m, ys)), List.take(&2, U32, P.slice_bytes(xs), n),
     facts_bytes(SByteList.domain(m, ys), ys, bytes_of(SByteList.encoding(m, ys)), optional_some(SByteList.domain(m, ys), ys, bytes_of(SByteList.encoding(m, ys)), encoding_some(SByteList.encoding(m, ys), present))),
     enc))

law byte_list_complete:
  for +m: Nat
  for +ys: +List<U32>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +encoded: {SC.parts(T.BytesValue{ys}, T.ByteList{m}) == Some{[SC.fragment(SS.fixed_size(T.ByteList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  parsed_as(T.BytesValue{ys}, xs, n, D.go(T.ByteList{m}, 1n, 0n, D.Region{n, xs}))
def byte_list_complete(m, ys, n, xs, wf, room, encoded):
  +dom = facts_dom(SByteList.domain(m, ys), ys, List.take(&2, U32, P.slice_bytes(xs), n), list_facts(m, ys, n, xs, encoded))
  +ysenc = facts_bytes(SByteList.domain(m, ys), ys, List.take(&2, U32, P.slice_bytes(xs), n), list_facts(m, ys, n, xs, encoded))
  +len = size_of_encoding(xs, n, ys, wf, room, ysenc)
  +bound = V.and_right(SP.bytes_domain(ys), Nat.is_le(List.length(&2, U32, ys), m),
    V.and_left(Bool.and(SP.bytes_domain(ys), Nat.is_le(List.length(&2, U32, ys), m)), SLength.fits(4n, List.length(&2, U32, ys)), dom))
  +room4 = V.and_right(Bool.and(SP.bytes_domain(ys), Nat.is_le(List.length(&2, U32, ys), m)), SLength.fits(4n, List.length(&2, U32, ys)), dom)
  +guard = V.and_true(D.nat_le(n, m), D.fits(n),
    nat_le_true(n, m, Equal.trans(Bool, Nat.is_le(n, m), Nat.is_le(List.length(&2, U32, ys), m), True{},
      Equal.cong(Nat, Bool, k => Nat.is_le(k, m), n, List.length(&2, U32, ys), Equal.sym(Nat, List.length(&2, U32, ys), n, len)),
      bound)),
    Equal.trans(Bool, D.fits(n), SLength.fits(4n, List.length(&2, U32, ys)), True{},
      Equal.trans(Bool, D.fits(n), SLength.fits(4n, n), SLength.fits(4n, List.length(&2, U32, ys)),
        CL.fits_bridge(n),
        Equal.cong(Nat, Bool, k => SLength.fits(4n, k), n, List.length(&2, U32, ys), Equal.sym(Nat, List.length(&2, U32, ys), n, len))),
      room4))
  +contents = Equal.trans(+List<U32>, P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), ys,
    Equal.trans(+List<U32>, P.to_list(P.sub(xs, n)), P.slice_bytes(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n),
      PK.to_list_view(P.sub(xs, n), PK.wf_sub(xs, n, wf, room)),
      PK.sub_view(xs, n)),
    Equal.sym(+List<U32>, ys, List.take(&2, U32, P.slice_bytes(xs), n), ysenc))
  %Equal.sym(Bool, Bool.and(D.nat_le(n, m), D.fits(n)), True{}, guard) : parsed_as(T.BytesValue{ys}, xs, n, D.bytes_leaf(_, n, xs))
  %contents : parsed_as(T.BytesValue{_}, xs, n, D.Parsed{C.CBytes{P.sub(xs, n)}, P.adv(xs, n)})
  ({==}, (PK.adv_view(xs, n), PK.wf_adv(xs, n, wf)))

# ---------------------------------------------------------------------------
# Bitfield leaves. The decoder hands the region's bytes to the checked
# bitfield codecs, so completeness is the codecs' own normative-image law
# applied to exactly those bytes.
law bit_encoding_some:
  for ok: Bool
  for +bits: +List<Bool>
  for +zs: +List<U32>
  for +e: {SBits.encoding(ok, bits) == Some{zs} : Maybe<&2, +List<U32>>}
  {ok == True{} : Bool}
def bit_encoding_some(ok, bits, zs, e):
  match ok:
    case False{}: Empty.absurd({False{} == True{} : Bool}, F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, is_some_bytes, None{}, Some{zs}, e)))
    case True{}: {==}

law bit_region_bytes:
  for +schema: T.Schema
  for +bits: +List<Bool>
  for +r: Maybe<&2, +List<U32>>
  for +n: Nat
  for +xs: P.Slice
  for +shape: {SC.parts(T.BitsValue{bits}, schema) == SC.one(r, SS.fixed_size(schema)) : Maybe<&2, +List<T.Part>>}
  for +encoded: {SC.parts(T.BitsValue{bits}, schema) == Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  for +frag: {fragment_bytes(Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(xs), n))]}) == List.take(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
  {r == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
def bit_region_bytes(schema, bits, r, n, xs, shape, encoded, frag):
  +present = Equal.trans(Bool, is_some_bytes(r), parts_present(SC.one(r, SS.fixed_size(schema))), True{},
    Equal.sym(Bool, parts_present(SC.one(r, SS.fixed_size(schema))), is_some_bytes(r), present_one(r, SS.fixed_size(schema))),
    Equal.trans(Bool, parts_present(SC.one(r, SS.fixed_size(schema))), parts_present(SC.parts(T.BitsValue{bits}, schema)), True{},
      Equal.cong(Maybe<&2, +List<T.Part>>, Bool, parts_present, SC.one(r, SS.fixed_size(schema)), SC.parts(T.BitsValue{bits}, schema),
        Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(T.BitsValue{bits}, schema), SC.one(r, SS.fixed_size(schema)), shape)),
      Equal.cong(Maybe<&2, +List<T.Part>>, Bool, parts_present, SC.parts(T.BitsValue{bits}, schema), Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(xs), n))]}, encoded)))
  +bytes = Equal.trans(+List<U32>, bytes_of(r), fragment_bytes(SC.one(r, SS.fixed_size(schema))), List.take(&2, U32, P.slice_bytes(xs), n),
    Equal.sym(+List<U32>, fragment_bytes(SC.one(r, SS.fixed_size(schema))), bytes_of(r), bytes_one(r, SS.fixed_size(schema))),
    Equal.trans(+List<U32>, fragment_bytes(SC.one(r, SS.fixed_size(schema))), fragment_bytes(SC.parts(T.BitsValue{bits}, schema)), List.take(&2, U32, P.slice_bytes(xs), n),
      Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, fragment_bytes, SC.one(r, SS.fixed_size(schema)), SC.parts(T.BitsValue{bits}, schema),
        Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(T.BitsValue{bits}, schema), SC.one(r, SS.fixed_size(schema)), shape)),
      Equal.trans(+List<U32>, fragment_bytes(SC.parts(T.BitsValue{bits}, schema)), fragment_bytes(Some{[SC.fragment(SS.fixed_size(schema), List.take(&2, U32, P.slice_bytes(xs), n))]}), List.take(&2, U32, P.slice_bytes(xs), n),
        encoded_bytes(schema, T.BitsValue{bits}, xs, n, encoded), frag)))
  Equal.trans(Maybe<&2, +List<U32>>, r, Some{bytes_of(r)}, Some{List.take(&2, U32, P.slice_bytes(xs), n)},
    encoding_some(r, present),
    Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, ws => Some{ws}, bytes_of(r), List.take(&2, U32, P.slice_bytes(xs), n), bytes))

law bit_vector_complete:
  for +m: Nat
  for +bits: +List<Bool>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +encoded: {SC.parts(T.BitsValue{bits}, T.BitVector{m}) == Some{[SC.fragment(SS.fixed_size(T.BitVector{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  parsed_as(T.BitsValue{bits}, xs, n, D.go(T.BitVector{m}, 1n, 0n, D.Region{n, xs}))
def bit_vector_complete(m, bits, n, xs, wf, room, encoded):
  +enc = bit_region_bytes(T.BitVector{m}, bits, SBits.vector_encoding(m, bits), n, xs, {==}, encoded, {==})
  +dom = bit_encoding_some(SBits.vector_domain(m, bits), bits, List.take(&2, U32, P.slice_bytes(xs), n), enc)
  +decodes = BitVectorLaws.normative_image_decodes(m, List.take(&2, U32, P.slice_bytes(xs), n), bits,
    SchemaLookups.vector_valid_of(m, bits, dom), enc)
  +region = Equal.trans(+List<U32>, P.to_list(P.sub(xs, n)), P.slice_bytes(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n),
    PK.to_list_view(P.sub(xs, n), PK.wf_sub(xs, n, wf, room)),
    PK.sub_view(xs, n))
  %Equal.sym(Maybe<&2, +List<Bool>>, IBits.bitvector_deserialize(m, P.to_list(P.sub(xs, n))), Some{bits},
    Equal.trans(Maybe<&2, +List<Bool>>, IBits.bitvector_deserialize(m, P.to_list(P.sub(xs, n))), IBits.bitvector_deserialize(m, List.take(&2, U32, P.slice_bytes(xs), n)), Some{bits},
      Equal.cong(+List<U32>, Maybe<&2, +List<Bool>>, ws => IBits.bitvector_deserialize(m, ws), P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), region),
      decodes)) : parsed_as(T.BitsValue{bits}, xs, n, D.bits_result(_, P.adv(xs, n)))
  ({==}, (PK.adv_view(xs, n), PK.wf_adv(xs, n, wf)))

# ---------------------------------------------------------------------------
# Progressive bitlists: the region's byte count always covers the bits it
# holds. Copied unchanged from the previous completeness development
# (proofs/decode_goal.bend), where it was proved against the frozen packing
# specification and never mentioned a decoder.
law cover:
  for +n: Nat
  {Nat.is_le(n, Nat.mul(SPack.byte_count(Nat.add(n, 1n)), 8n)) == True{} : Bool}
def cover(n):
  match n:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n: {==}
    case 5n: {==}
    case 6n: {==}
    case 7n: {==}
    case 8n+p: cover(p)

law progressive_capacity:
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for out: {SPack.pack(List.append(&2, Bool, bits, [True{}])) == xs : +List<U32>}
  {Nat.is_le(List.length(&2, Bool, bits), Nat.mul(Lists.length(U32, xs), 8n)) == True{} : Bool}
def progressive_capacity(bits, xs, out):
  %Equal.sym(Nat, Lists.length(U32, xs), List.length(&2, U32, xs), L.length_correct(U32, xs)) : {Nat.is_le(List.length(&2, Bool, bits), Nat.mul(_, 8n)) == True{} : Bool}
  %out : {Nat.is_le(List.length(&2, Bool, bits), Nat.mul(List.length(&2, U32, _), 8n)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, SPack.pack(List.append(&2, Bool, bits, [True{}]))), SPack.byte_count(List.length(&2, Bool, List.append(&2, Bool, bits, [True{}]))), Leaf.spec_pack_length(List.append(&2, Bool, bits, [True{}]))) : {Nat.is_le(List.length(&2, Bool, bits), Nat.mul(_, 8n)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, bits, [True{}])), Nat.add(List.length(&2, Bool, bits), 1n), L.append_length(Bool, bits, [True{}])) : {Nat.is_le(List.length(&2, Bool, bits), Nat.mul(SPack.byte_count(_), 8n)) == True{} : Bool}
  cover(List.length(&2, Bool, bits))


# ---------------------------------------------------------------------------
# Bit-list leaf.
law bit_list_complete:
  for +m: Nat
  for +bits: +List<Bool>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +encoded: {SC.parts(T.BitsValue{bits}, T.BitList{m}) == Some{[SC.fragment(SS.fixed_size(T.BitList{m}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  parsed_as(T.BitsValue{bits}, xs, n, D.go(T.BitList{m}, 1n, 0n, D.Region{n, xs}))
def bit_list_complete(m, bits, n, xs, wf, room, encoded):
  +enc = bit_region_bytes(T.BitList{m}, bits, SBits.list_encoding(m, bits), n, xs, {==}, encoded, {==})
  +dom = bit_encoding_some(SBits.list_domain(m, bits), List.append(&2, Bool, bits, [True{}]), List.take(&2, U32, P.slice_bytes(xs), n), enc)
  +decodes = BitListLaws.normative_image_decodes(m, List.take(&2, U32, P.slice_bytes(xs), n), bits, dom, enc)
  +region = Equal.trans(+List<U32>, P.to_list(P.sub(xs, n)), P.slice_bytes(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n),
    PK.to_list_view(P.sub(xs, n), PK.wf_sub(xs, n, wf, room)),
    PK.sub_view(xs, n))
  %Equal.sym(Maybe<&2, +List<Bool>>, IBits.bitlist_deserialize(m, P.to_list(P.sub(xs, n))), Some{bits},
    Equal.trans(Maybe<&2, +List<Bool>>, IBits.bitlist_deserialize(m, P.to_list(P.sub(xs, n))), IBits.bitlist_deserialize(m, List.take(&2, U32, P.slice_bytes(xs), n)), Some{bits},
      Equal.cong(+List<U32>, Maybe<&2, +List<Bool>>, ws => IBits.bitlist_deserialize(m, ws), P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), region),
      decodes)) : parsed_as(T.BitsValue{bits}, xs, n, D.bits_result(_, P.adv(xs, n)))
  ({==}, (PK.adv_view(xs, n), PK.wf_adv(xs, n, wf)))

# ---------------------------------------------------------------------------
# Progressive bitlist leaf: the capacity the decoder uses is the region's byte
# count times eight, which always covers the bits the region holds.
law bit_encoding_bytes:
  for ok: Bool
  for +ys: +List<Bool>
  for +zs: +List<U32>
  for +e: {SBits.encoding(ok, ys) == Some{zs} : Maybe<&2, +List<U32>>}
  {SPack.pack(ys) == zs : +List<U32>}
def bit_encoding_bytes(ok, ys, zs, e):
  match ok:
    case False{}: Empty.absurd({SPack.pack(ys) == zs : +List<U32>}, F.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, is_some_bytes, None{}, Some{zs}, e)))
    case True{}: Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, bytes_of, Some{SPack.pack(ys)}, Some{zs}, e)

law list_encoding_at:
  for +cap: Nat
  for +bits: +List<Bool>
  for +zs: +List<U32>
  for +valid: {SBits.list_domain(cap, bits) == True{} : Bool}
  for +packed: {SPack.pack(List.append(&2, Bool, bits, [True{}])) == zs : +List<U32>}
  {SBits.list_encoding(cap, bits) == Some{zs} : Maybe<&2, +List<U32>>}
def list_encoding_at(cap, bits, zs, valid, packed):
  %Equal.sym(Bool, SBits.list_domain(cap, bits), True{}, valid) : {SBits.encoding(_, List.append(&2, Bool, bits, [True{}])) == Some{zs} : Maybe<&2, +List<U32>>}
  Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, ws => Some{ws}, SPack.pack(List.append(&2, Bool, bits, [True{}])), zs, packed)

law progressive_bits_complete:
  for +bits: +List<Bool>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +encoded: {SC.parts(T.BitsValue{bits}, T.ProgressiveBits{}) == Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]} : Maybe<&2, +List<T.Part>>}
  parsed_as(T.BitsValue{bits}, xs, n, D.go(T.ProgressiveBits{}, 1n, 0n, D.Region{n, xs}))
def progressive_bits_complete(bits, n, xs, wf, room, encoded):
  +enc = bit_region_bytes(T.ProgressiveBits{}, bits, SBits.list_encoding(List.length(&2, Bool, bits), bits), n, xs, {==}, encoded, {==})
  +packed = bit_encoding_bytes(SBits.list_domain(List.length(&2, Bool, bits), bits), List.append(&2, Bool, bits, [True{}]), List.take(&2, U32, P.slice_bytes(xs), n), enc)
  +taken = PK.take_length(P.slice_bytes(xs), n, CL.sized_by_wf(xs, n, wf, room))
  +cap = progressive_capacity(bits, List.take(&2, U32, P.slice_bytes(xs), n), packed)
  +valid = Equal.trans(Bool, Nat.is_le(List.length(&2, Bool, bits), Nat.mul(n, 8n)), Nat.is_le(List.length(&2, Bool, bits), Nat.mul(Lists.length(U32, List.take(&2, U32, P.slice_bytes(xs), n)), 8n)), True{},
    Equal.cong(Nat, Bool, k => Nat.is_le(List.length(&2, Bool, bits), Nat.mul(k, 8n)), n, Lists.length(U32, List.take(&2, U32, P.slice_bytes(xs), n)),
      Equal.sym(Nat, Lists.length(U32, List.take(&2, U32, P.slice_bytes(xs), n)), n,
        Equal.trans(Nat, Lists.length(U32, List.take(&2, U32, P.slice_bytes(xs), n)), List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)), n,
          L.length_correct(U32, List.take(&2, U32, P.slice_bytes(xs), n)), taken))),
    cap)
  +enc2 = list_encoding_at(Nat.mul(n, 8n), bits, List.take(&2, U32, P.slice_bytes(xs), n), valid, packed)
  +decodes = BitListLaws.normative_image_decodes(Nat.mul(n, 8n), List.take(&2, U32, P.slice_bytes(xs), n), bits, valid, enc2)
  +region = Equal.trans(+List<U32>, P.to_list(P.sub(xs, n)), P.slice_bytes(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n),
    PK.to_list_view(P.sub(xs, n), PK.wf_sub(xs, n, wf, room)),
    PK.sub_view(xs, n))
  %Equal.sym(Maybe<&2, +List<Bool>>, IBits.bitlist_deserialize(Nat.mul(n, 8n), P.to_list(P.sub(xs, n))), Some{bits},
    Equal.trans(Maybe<&2, +List<Bool>>, IBits.bitlist_deserialize(Nat.mul(n, 8n), P.to_list(P.sub(xs, n))), IBits.bitlist_deserialize(Nat.mul(n, 8n), List.take(&2, U32, P.slice_bytes(xs), n)), Some{bits},
      Equal.cong(+List<U32>, Maybe<&2, +List<Bool>>, ws => IBits.bitlist_deserialize(Nat.mul(n, 8n), ws), P.to_list(P.sub(xs, n)), List.take(&2, U32, P.slice_bytes(xs), n), region),
      decodes)) : parsed_as(T.BitsValue{bits}, xs, n, D.bits_result(_, P.adv(xs, n)))
  ({==}, (PK.adv_view(xs, n), PK.wf_adv(xs, n, wf)))

# Small observers on optional naturals, used by the walk laws.
def is_some_nat(r: Maybe<&2, Nat>) -> Bool:
  match r:
    case Some{n}: True{}
    case None{}: False{}

def nat_of(r: Maybe<&2, Nat>) -> Nat:
  match r:
    case Some{n}: n
    case None{}: 0n
