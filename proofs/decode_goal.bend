import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/decode.bend as D
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ../src/primitives.bend as IP
import ../src/bytes.bend as IBytes
import ../src/byte_list.bend as IByteList
import ../src/bitfields.bend as IBits
import ../spec/codec.bend as S
import ../spec/schema.bend as SS
import ../spec/primitives.bend as SP
import ../spec/bytes.bend as SBytes
import ../spec/byte_list.bend as SByteList
import ../spec/bitfields.bend as SBits
import ../spec/bit_packing.bend as SPack
import ../spec/nat_bytes.bend as N
import ./encoding_complete.bend as Complete
import ./integer_decoding.bend as Integer
import ./bytes.bend as ByteVectorLaws
import ./byte_list.bend as ByteListLaws
import ./bit_vector_canonical.bend as BitVectorLaws
import ./bit_list_codec.bend as BitListLaws
import ./bit_packing.bend as Packing
import ./leaf_sizes.bend as Leaf
import ./layout_image.bend as Image
import ./layout_image_headers.bend as H
import ./lists.bend as L
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ../src/layout.bend as IL
import ../spec/layout.bend as E
import ./decode_facts.bend as F
import ./exact_division.bend as Division
import ./layout.bend as Layout
import ./u32_order.bend as U32Order
import ./decode_monotone.bend as Mono
import ./bit_vector_inverse.bend as Eq
import ./schema.bend as Sch
import ./layout_headers.bend as Headers
import ../spec/layout_decoding.bend as LD
import ./layout_offset_value.bend as Offset
import ./nat_bytes.bend as Digits
import ./nat_order.bend as Order
import ./nat_algebra.bend as A

# Proof views for the canonical decoder inverse. The traversal witness is a
# structural size of the decoded VALUE; decode_budget.accepts_finite later
# moves any such finite witness to the actual public, input-derived budget.
def fuel(value: T.Value) -> Nat:
  match value:
    case T.Items{h, t}: 1n+Nat.add(fuel(h), fuel(t))
    case T.Sequence{items}: 1n+fuel(items)
    case T.Selected{s, v}: 1n+fuel(v)
    case _: 1n

def content(part: T.Part) -> +List<U32>:
  match part:
    case T.Fixed{xs}: xs
    case T.Variable{xs}: xs

# A single encoded type decodes back to exactly its value at its fuel, and its
# bytes lie in the normative byte domain.
def single_bytes(schema: T.Schema, value: T.Value, xs: +List<U32>) -> Type:
  {D.decode_go(fuel(value), schema, xs, [], T.EmptyItems{}) == Some{value} : Maybe<&2, T.Value>} & {SP.bytes_domain(xs) == True{} : Bool}

def single_goal(schema: T.Schema, value: T.Value, ps: +List<T.Part>) -> Type:
  match ps:
    case Con{p, Nil{}}: single_bytes(schema, value, content(p))
    case _: Unit

# A schema forest decodes its child slices onto any accumulator.
def forest_goal(schema: T.Schema, value: T.Value, ps: +List<T.Part>) -> Type:
  @+acc: T.Value -> {D.decode_go(fuel(value), schema, [], H.values(ps), acc) == Some{D.reverse_items(acc, value)} : Maybe<&2, T.Value>}

def single_result(schema: T.Schema, value: T.Value, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{ps}: single_goal(schema, value, ps)

def forest_result(schema: T.Schema, value: T.Value, result: Maybe<&2, +List<T.Part>>) -> Type:
  match result:
    case None{}: Unit
    case Some{ps}: forest_goal(schema, value, ps)

def inverse_result(schema: T.Schema, value: T.Value, result: Maybe<&2, +List<T.Part>>) -> Type:
  match schema:
    case T.Chain{h, t}: forest_result(T.Chain{h, t}, value, result)
    case T.End{}: forest_result(T.End{}, value, result)
    case T.Repeat{e}: forest_result(T.Repeat{e}, value, result)
    case _: single_result(schema, value, result)

law content_fragment:
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  {content(S.fragment(width, xs)) == xs : +List<U32>}
def content_fragment(width, xs):
  match width:
    case None{}: {==}
    case Some{n}: {==}

law one_leaf:
  for +schema: T.Schema
  for +value: T.Value
  for +encoded: Maybe<&2, +List<U32>>
  for +width: Maybe<&2, Nat>
  for known: @+xs: +List<U32> -> @+e: {encoded == Some{xs} : Maybe<&2, +List<U32>>} -> single_bytes(schema, value, xs)
  single_result(schema, value, S.one(encoded, width))
def one_leaf(schema, value, encoded, width, known):
  match encoded:
    case None{}: Unit{}
    case Some{xs}:
      %Equal.sym(+List<U32>, content(S.fragment(width, xs)), xs, content_fragment(width, xs)) : single_bytes(schema, value, _)
      known(xs, {==})

law scope_domain:
  for +n: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(n, xs) == True{} : Bool}
  {SP.bytes_domain(xs) == True{} : Bool}
def scope_domain(n, xs, e):
  match n:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: Empty.absurd({SP.bytes_domain(h <> t) == True{} : Bool}, W.false_true(e))
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: V.and_true(U32.is_lt(h, 256), SP.bytes_domain(t), V.and_left(U32.is_lt(h, 256), SP.byte_scope(p, t), e), scope_domain(p, t, V.and_right(U32.is_lt(h, 256), SP.byte_scope(p, t), e)))

law boolean_leaf:
  for +b: Bool
  single_bytes(T.Boolean{}, T.BooleanValue{b}, SP.boolean_encoding(b))
def boolean_leaf(b):
  match b:
    case False{}: ({==}, {==})
    case True{}: ({==}, {==})

def uint_present(r: Maybe<&2, Primitive.UInt>) -> Bool:
  match r:
    case None{}: False{}
    case Some{v}: True{}

law integer_ok:
  for +ok: Bool
  for +xs: +List<U32>
  for +v: Primitive.UInt
  for e: {SP.optional_integer(ok, xs) == Some{v} : Maybe<&2, Primitive.UInt>}
  {ok == True{} : Bool}
def integer_ok(ok, xs, v, e):
  match ok:
    case False{}: Equal.cong(Maybe<&2, Primitive.UInt>, Bool, r => uint_present(r), None{}, Some{v}, e)
    case True{}: {==}

law uint_leaf:
  for +w: Primitive.Width
  for +v: Primitive.UInt
  for +xs: +List<U32>
  for +e: {SP.uint_encoding(w, v) == Some{xs} : Maybe<&2, +List<U32>>}
  single_bytes(T.Unsigned{w}, T.UnsignedValue{v}, xs)
def uint_leaf(w, v, xs, e):
  (Equal.cong(Maybe<&2, Primitive.UInt>, Maybe<&2, T.Value>, r => D.unsigned(r), IP.uint_deserialize(w, xs), Some{v}, Complete.uint_decoding_complete(w, v, xs, e)),
   scope_domain(SP.byte_width(w), xs, integer_ok(SP.byte_scope(SP.byte_width(w), xs), xs, v,
     Equal.trans(Maybe<&2, Primitive.UInt>, SP.uint_decoding(w, xs), IP.uint_deserialize(w, xs), Some{v}, Equal.sym(Maybe<&2, Primitive.UInt>, IP.uint_deserialize(w, xs), SP.uint_decoding(w, xs), Integer.uint_deserialize_correct(w, xs)), Complete.uint_decoding_complete(w, v, xs, e)))))

law vector_domain_bytes:
  for +n: Nat
  for +v: +List<U32>
  for e: {SBytes.vector_domain(n, v) == True{} : Bool}
  {SP.bytes_domain(v) == True{} : Bool}
def vector_domain_bytes(n, v, e):
  match n:
    case 0n: Empty.absurd({SP.bytes_domain(v) == True{} : Bool}, W.false_true(e))
    case 1n+p: scope_domain(1n+p, v, V.and_left(SP.byte_scope(1n+p, v), SBytes.size_fits(1n+p), e))

law rewrite_domain:
  for +v: +List<U32>
  for +xs: +List<U32>
  for same: {v == xs : +List<U32>}
  for domain: {SP.bytes_domain(v) == True{} : Bool}
  {SP.bytes_domain(xs) == True{} : Bool}
def rewrite_domain(v, xs, same, domain):
  %same : {SP.bytes_domain(_) == True{} : Bool}
  domain

law byte_vector_leaf:
  for +n: Nat
  for +v: +List<U32>
  for +xs: +List<U32>
  for +e: {SBytes.vector_encoding(n, v) == Some{xs} : Maybe<&2, +List<U32>>}
  single_bytes(T.ByteVector{n}, T.BytesValue{v}, xs)
def byte_vector_leaf(n, v, xs, e):
  (Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, T.Value>, r => D.bytes(r), IBytes.vector_deserialize(n, xs), Some{v}, ByteVectorLaws.vector_decoding_complete(n, v, xs, e)),
   rewrite_domain(v, xs, Image.optional_output(SBytes.vector_domain(n, v), v, xs, e), vector_domain_bytes(n, v, Image.optional_valid(SBytes.vector_domain(n, v), v, xs, e))))


law byte_list_leaf:
  for +n: Nat
  for +v: +List<U32>
  for +xs: +List<U32>
  for +e: {SByteList.encoding(n, v) == Some{xs} : Maybe<&2, +List<U32>>}
  single_bytes(T.ByteList{n}, T.BytesValue{v}, xs)
def byte_list_leaf(n, v, xs, e):
  (Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, T.Value>, r => D.bytes(r), IByteList.deserialize(n, xs), Some{v}, ByteListLaws.decoding_complete(n, v, xs, e)),
   rewrite_domain(v, xs, Image.optional_output(SByteList.domain(n, v), v, xs, e),
     V.and_left(SP.bytes_domain(v), Nat.is_le(List.length(&2, U32, v), n), V.and_left(Bool.and(SP.bytes_domain(v), Nat.is_le(List.length(&2, U32, v), n)), N.fits(4n, List.length(&2, U32, v)), Image.optional_valid(SByteList.domain(n, v), v, xs, e)))))

def bits_present(r: Maybe<&2, +List<U32>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{v}: True{}

def bits_contents(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{v}: v

law bits_ok:
  for +ok: Bool
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for e: {SBits.encoding(ok, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  {ok == True{} : Bool}
def bits_ok(ok, bits, xs, e):
  match ok:
    case False{}: Equal.cong(Maybe<&2, +List<U32>>, Bool, r => bits_present(r), None{}, Some{xs}, e)
    case True{}: {==}

law bits_out:
  for +ok: Bool
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for e: {SBits.encoding(ok, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  {SPack.pack(bits) == xs : +List<U32>}
def bits_out(ok, bits, xs, e):
  match ok:
    case False{}: Empty.absurd({SPack.pack(bits) == xs : +List<U32>}, W.false_true(Equal.cong(Maybe<&2, +List<U32>>, Bool, r => bits_present(r), None{}, Some{xs}, e)))
    case True{}: Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, r => bits_contents(r), Some{SPack.pack(bits)}, Some{xs}, e)

law pack_domain:
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for out: {SPack.pack(bits) == xs : +List<U32>}
  {SP.bytes_domain(xs) == True{} : Bool}
def pack_domain(bits, xs, out):
  %out : {SP.bytes_domain(_) == True{} : Bool}
  %Packing.pack_correct(bits) : {SP.bytes_domain(_) == True{} : Bool}
  Packing.pack_bytes(bits)

law vector_valid_of:
  for +n: Nat
  for +bits: +List<Bool>
  for e: {SBits.vector_domain(n, bits) == True{} : Bool}
  {IBits.vector_valid(n, bits) == True{} : Bool}
def vector_valid_of(n, bits, e):
  match n:
    case 0n: Empty.absurd({IBits.vector_valid(0n, bits) == True{} : Bool}, W.false_true(e))
    case 1n+p: e

law bit_vector_leaf:
  for +n: Nat
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for +e: {SBits.vector_encoding(n, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  single_bytes(T.BitVector{n}, T.BitsValue{bits}, xs)
def bit_vector_leaf(n, bits, xs, e):
  (Equal.cong(Maybe<&2, +List<Bool>>, Maybe<&2, T.Value>, r => D.bits(r), IBits.bitvector_deserialize(n, xs), Some{bits}, BitVectorLaws.normative_image_decodes(n, xs, bits, vector_valid_of(n, bits, bits_ok(SBits.vector_domain(n, bits), bits, xs, e)), e)),
   pack_domain(bits, xs, bits_out(SBits.vector_domain(n, bits), bits, xs, e)))

law bit_list_leaf:
  for +n: Nat
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for +e: {SBits.list_encoding(n, bits) == Some{xs} : Maybe<&2, +List<U32>>}
  single_bytes(T.BitList{n}, T.BitsValue{bits}, xs)
def bit_list_leaf(n, bits, xs, e):
  (Equal.cong(Maybe<&2, +List<Bool>>, Maybe<&2, T.Value>, r => D.bits(r), IBits.bitlist_deserialize(n, xs), Some{bits}, BitListLaws.normative_image_decodes(n, xs, bits, bits_ok(SBits.list_domain(n, bits), List.append(&2, Bool, bits, [True{}]), xs, e), e)),
   pack_domain(List.append(&2, Bool, bits, [True{}]), xs, bits_out(SBits.list_domain(n, bits), List.append(&2, Bool, bits, [True{}]), xs, e)))

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

law progressive_encoded:
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for +out: {SPack.pack(List.append(&2, Bool, bits, [True{}])) == xs : +List<U32>}
  {SBits.list_encoding(Nat.mul(Lists.length(U32, xs), 8n), bits) == Some{xs} : Maybe<&2, +List<U32>>}
def progressive_encoded(bits, xs, out):
  %Equal.sym(Bool, SBits.list_domain(Nat.mul(Lists.length(U32, xs), 8n), bits), True{}, progressive_capacity(bits, xs, out)) : {SBits.encoding(_, List.append(&2, Bool, bits, [True{}])) == Some{xs} : Maybe<&2, +List<U32>>}
  Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, r => Some{r}, SPack.pack(List.append(&2, Bool, bits, [True{}])), xs, out)

law progressive_bits_leaf:
  for +bits: +List<Bool>
  for +xs: +List<U32>
  for +e: {SBits.list_encoding(List.length(&2, Bool, bits), bits) == Some{xs} : Maybe<&2, +List<U32>>}
  single_bytes(T.ProgressiveBits{}, T.BitsValue{bits}, xs)
def progressive_bits_leaf(bits, xs, e):
  (Equal.cong(Maybe<&2, +List<Bool>>, Maybe<&2, T.Value>, r => D.bits(r), IBits.bitlist_deserialize(Nat.mul(Lists.length(U32, xs), 8n), xs), Some{bits},
     BitListLaws.normative_image_decodes(Nat.mul(Lists.length(U32, xs), 8n), xs, bits, progressive_capacity(bits, xs, bits_out(SBits.list_domain(List.length(&2, Bool, bits), bits), List.append(&2, Bool, bits, [True{}]), xs, e)), progressive_encoded(bits, xs, bits_out(SBits.list_domain(List.length(&2, Bool, bits), bits), List.append(&2, Bool, bits, [True{}]), xs, e)))),
   pack_domain(List.append(&2, Bool, bits, [True{}]), xs, bits_out(SBits.list_domain(List.length(&2, Bool, bits), bits), List.append(&2, Bool, bits, [True{}]), xs, e)))

# ---------------------------------------------------------------------------
# Item counts recovered by the actual decoder from canonical sequence images.

def positive(width: Maybe<&2, Nat>) -> Type:
  match width:
    case None{}: Unit
    case Some{n}: {Nat.is_lt(0n, n) == True{} : Bool}

law items_length:
  for +ps: +List<T.Part>
  for +k: Nat
  for +w: Nat
  for +bytes: +List<U32>
  for widths: {H.widths(ps) == List.replicate(Maybe<&2, Nat>, k, Some{1n+w}) : +List<Maybe<&2, Nat>>}
  for encoded: {E.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {List.length(&2, U32, bytes) == Nat.mul(k, 1n+w) : Nat}
def items_length(ps, k, w, bytes, widths, encoded):
  %encoded : V.sized(Nat.mul(k, 1n+w), _)
  F.encoded_sized(ps, Nat.mul(k, 1n+w),
    %Equal.sym(+List<Maybe<&2, Nat>>, H.widths(ps), List.replicate(Maybe<&2, Nat>, k, Some{1n+w}), widths) : {F.total(_) == Some{Nat.mul(k, 1n+w)} : Maybe<&2, Nat>}
    F.copies_total(k, 1n+w))

law fixed_items:
  for +ps: +List<T.Part>
  for +k: Nat
  for +w: Nat
  for +bytes: +List<U32>
  for widths: {H.widths(ps) == List.replicate(Maybe<&2, Nat>, k, Some{1n+w}) : +List<Maybe<&2, Nat>>}
  for encoded: {E.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.item_count(Some{1n+w}, bytes) == Some{k} : Maybe<&2, Nat>}
def fixed_items(ps, k, w, bytes, widths, encoded):
  %Equal.sym(Nat, Lists.length(U32, bytes), List.length(&2, U32, bytes), L.length_correct(U32, bytes)) : {D.nat_gate(Nat.is_eq(Nat.mod(_, 1n+w), 0n), Nat.div(_, 1n+w)) == Some{k} : Maybe<&2, Nat>}
  %Equal.sym(Nat, List.length(&2, U32, bytes), Nat.mul(k, 1n+w), items_length(ps, k, w, bytes, widths, encoded)) : {D.nat_gate(Nat.is_eq(Nat.mod(_, 1n+w), 0n), Nat.div(_, 1n+w)) == Some{k} : Maybe<&2, Nat>}
  %Equal.sym(Nat, Nat.mod(Nat.mul(k, 1n+w), 1n+w), 0n, Division.remainder(k, w)) : {D.nat_gate(Nat.is_eq(_, 0n), Nat.div(Nat.mul(k, 1n+w), 1n+w)) == Some{k} : Maybe<&2, Nat>}
  Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n}, Nat.div(Nat.mul(k, 1n+w), 1n+w), k, Division.quotient(k, w))


def list_tail(xs: +List<Maybe<&2, Nat>>) -> +List<Maybe<&2, Nat>>:
  match xs:
    case Nil{}: []
    case Con{h, t}: t

def list_nonempty(xs: +List<Maybe<&2, Nat>>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: True{}

def head_absent(xs: +List<Maybe<&2, Nat>>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}:
      match h:
        case None{}: True{}
        case Some{n}: False{}

law all_variable_size:
  for +ps: +List<T.Part>
  for +k: Nat
  for +widths: {H.widths(ps) == List.replicate(Maybe<&2, Nat>, k, None{}) : +List<Maybe<&2, Nat>>}
  {E.fixed_size(ps) == Nat.mul(k, 4n) : Nat}
def all_variable_size(ps, k, widths):
  match ps:
    case Nil{}:
      match k:
        case 0n: {==}
        case 1n+p: Empty.absurd({0n == Nat.mul(1n+p, 4n) : Nat}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, list_nonempty, [], List.replicate(Maybe<&2, Nat>, 1n+p, None{}), widths)))
    case Con{T.Fixed{x}, t}:
      match k:
        case 0n: Empty.absurd({E.fixed_size(T.Fixed{x} <> t) == 0n : Nat}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, list_nonempty, [], H.widths(T.Fixed{x} <> t), Equal.sym(+List<Maybe<&2, Nat>>, H.widths(T.Fixed{x} <> t), [], widths))))
        case 1n+p: Empty.absurd({E.fixed_size(T.Fixed{x} <> t) == Nat.mul(1n+p, 4n) : Nat}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, head_absent, H.widths(T.Fixed{x} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, None{}), widths)))
    case Con{T.Variable{x}, t}:
      match k:
        case 0n: Empty.absurd({E.fixed_size(T.Variable{x} <> t) == 0n : Nat}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, list_nonempty, [], H.widths(T.Variable{x} <> t), Equal.sym(+List<Maybe<&2, Nat>>, H.widths(T.Variable{x} <> t), [], widths))))
        case 1n+p: Equal.cong(Nat, Nat, n => 4n+n, E.fixed_size(t), Nat.mul(p, 4n), all_variable_size(t, p, Equal.cong(+List<Maybe<&2, Nat>>, +List<Maybe<&2, Nat>>, list_tail, H.widths(T.Variable{x} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, None{}), widths)))

law variable_gate:
  for +c: Nat
  for +k: Nat
  for +len: Nat
  for eq: {c == Nat.mul(k, 4n) : Nat}
  for pos: {Nat.is_lt(0n, c) == True{} : Bool}
  for le: {Nat.is_le(c, len) == True{} : Bool}
  {D.variable_count(c, len) == Some{k} : Maybe<&2, Nat>}
def variable_gate(c, k, len, eq, pos, le):
  %Equal.sym(Bool, Nat.is_lt(0n, c), True{}, pos) : {D.nat_gate(Bool.and(_, Bool.and(Nat.is_eq(Nat.mod(c, 4n), 0n), Nat.is_le(c, len))), Nat.div(c, 4n)) == Some{k} : Maybe<&2, Nat>}
  %Equal.sym(Bool, Nat.is_le(c, len), True{}, le) : {D.nat_gate(Bool.and(True{}, Bool.and(Nat.is_eq(Nat.mod(c, 4n), 0n), _)), Nat.div(c, 4n)) == Some{k} : Maybe<&2, Nat>}
  %Equal.sym(Nat, c, Nat.mul(k, 4n), eq) : {D.nat_gate(Bool.and(True{}, Bool.and(Nat.is_eq(Nat.mod(_, 4n), 0n), True{})), Nat.div(_, 4n)) == Some{k} : Maybe<&2, Nat>}
  %Equal.sym(Nat, Nat.mod(Nat.mul(k, 4n), 4n), 0n, Division.remainder(k, 3n)) : {D.nat_gate(Bool.and(True{}, Bool.and(Nat.is_eq(_, 0n), True{})), Nat.div(Nat.mul(k, 4n), 4n)) == Some{k} : Maybe<&2, Nat>}
  Equal.cong(Nat, Maybe<&2, Nat>, n => Some{n}, Nat.div(Nat.mul(k, 4n), 4n), k, Division.quotient(k, 3n))

law offset_of_digits:
  for +c: Nat
  for fit: {N.fits(4n, c) == True{} : Bool}
  {IL.offset(N.digits(4n, c)) == c : Nat}
def offset_of_digits(c, fit):
  %Equal.sym(U32, IP.read_limb(N.digits(4n, c), 0n), SP.limb_value(N.digits(4n, c), 0n), Integer.read_limb_correct(N.digits(4n, c), 0n, Digits.digits_domain(4n, c))) : {U32.to_nat(_) == c : Nat}
  Offset.offset_digits(c, fit)

law count_prefix:
  for +c: Nat
  for +rest: +List<U32>
  for fit: {N.fits(4n, c) == True{} : Bool}
  {D.item_count(None{}, List.append(&2, U32, N.digits(4n, c), rest)) == D.variable_count(c, 4n+Lists.length(U32, rest)) : Maybe<&2, Nat>}
def count_prefix(c, rest, fit):
  %offset_of_digits(c, fit) : {D.item_count(None{}, List.append(&2, U32, N.digits(4n, c), rest)) == D.variable_count(_, 4n+Lists.length(U32, rest)) : Maybe<&2, Nat>}
  {==}

def pred4(n: Nat) -> Nat:
  match n:
    case 4n+p: p
    case _: 0n

law rest_length:
  for +x: +List<U32>
  for +t: +List<T.Part>
  {List.length(&2, U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t))) == Nat.add(E.fixed_size(t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))) : Nat}
def rest_length(x, t):
  Equal.cong(Nat, Nat, pred4, List.length(&2, U32, List.append(&2, U32, E.fixed_parts(T.Variable{x} <> t, E.fixed_size(T.Variable{x} <> t)), E.payloads(T.Variable{x} <> t))), Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))), Layout.output_length(T.Variable{x} <> t, E.fixed_size(T.Variable{x} <> t)))

law variable_le:
  for +x: +List<U32>
  for +t: +List<T.Part>
  {Nat.is_le(E.fixed_size(T.Variable{x} <> t), 4n+Lists.length(U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t)))) == True{} : Bool}
def variable_le(x, t):
  %Equal.sym(Nat, Lists.length(U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t))), List.length(&2, U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t))), L.length_correct(U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t)))) : {Nat.is_le(E.fixed_size(T.Variable{x} <> t), 4n+_) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t))), Nat.add(E.fixed_size(t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))), rest_length(x, t)) : {Nat.is_le(E.fixed_size(T.Variable{x} <> t), 4n+_) == True{} : Bool}
  Order.below_sum(E.fixed_size(t), List.length(&2, U32, E.payloads(T.Variable{x} <> t)))

law variable_items:
  for +ps: +List<T.Part>
  for +k: Nat
  for +bytes: +List<U32>
  for +widths: {H.widths(ps) == List.replicate(Maybe<&2, Nat>, k, None{}) : +List<Maybe<&2, Nat>>}
  for +encoded: {E.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.item_count(None{}, bytes) == Some{k} : Maybe<&2, Nat>}
def variable_items(ps, k, bytes, widths, encoded):
  match ps:
    case Nil{}:
      match k:
        case 0n:
          %Equal.cong(Maybe<&2, +List<U32>>, +List<U32>, bits_contents, Some{[]}, Some{bytes}, encoded) : {D.item_count(None{}, _) == Some{0n} : Maybe<&2, Nat>}
          {==}
        case 1n+p: Empty.absurd({D.item_count(None{}, bytes) == Some{1n+p} : Maybe<&2, Nat>}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, list_nonempty, [], List.replicate(Maybe<&2, Nat>, 1n+p, None{}), widths)))
    case Con{T.Fixed{x}, t}:
      match k:
        case 0n: Empty.absurd({D.item_count(None{}, bytes) == Some{0n} : Maybe<&2, Nat>}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, list_nonempty, [], H.widths(T.Fixed{x} <> t), Equal.sym(+List<Maybe<&2, Nat>>, H.widths(T.Fixed{x} <> t), [], widths))))
        case 1n+p: Empty.absurd({D.item_count(None{}, bytes) == Some{1n+p} : Maybe<&2, Nat>}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, head_absent, H.widths(T.Fixed{x} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, None{}), widths)))
    case Con{T.Variable{x}, t}:
      match k:
        case 0n: Empty.absurd({D.item_count(None{}, bytes) == Some{0n} : Maybe<&2, Nat>}, W.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, list_nonempty, [], H.widths(T.Variable{x} <> t), Equal.sym(+List<Maybe<&2, Nat>>, H.widths(T.Variable{x} <> t), [], widths))))
        case 1n+p:
          %Image.optional_output(Bool.and(E.bytes_valid(T.Variable{x} <> t), N.fits(4n, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))))), List.append(&2, U32, E.fixed_parts(T.Variable{x} <> t, E.fixed_size(T.Variable{x} <> t)), E.payloads(T.Variable{x} <> t)), bytes, encoded) : {D.item_count(None{}, _) == Some{1n+p} : Maybe<&2, Nat>}
          Equal.trans(Maybe<&2, Nat>, D.item_count(None{}, List.append(&2, U32, N.digits(4n, E.fixed_size(T.Variable{x} <> t)), List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t)))), D.variable_count(E.fixed_size(T.Variable{x} <> t), 4n+Lists.length(U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t)))), Some{1n+p},
            count_prefix(E.fixed_size(T.Variable{x} <> t), List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t)),
              Digits.fits_monotone(4n, E.fixed_size(T.Variable{x} <> t), Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))), Order.below_sum(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))),
                V.and_right(E.bytes_valid(T.Variable{x} <> t), N.fits(4n, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, E.payloads(T.Variable{x} <> t)))), Image.optional_valid(Bool.and(E.bytes_valid(T.Variable{x} <> t), N.fits(4n, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, E.payloads(T.Variable{x} <> t))))), List.append(&2, U32, E.fixed_parts(T.Variable{x} <> t, E.fixed_size(T.Variable{x} <> t)), E.payloads(T.Variable{x} <> t)), bytes, encoded)))),
            variable_gate(E.fixed_size(T.Variable{x} <> t), 1n+p, 4n+Lists.length(U32, List.append(&2, U32, E.fixed_parts(t, Nat.add(E.fixed_size(T.Variable{x} <> t), List.length(&2, U32, x))), E.payloads(T.Variable{x} <> t))), all_variable_size(T.Variable{x} <> t, 1n+p, widths), {==}, variable_le(x, t)))

law count_some:
  for +n: Nat
  for +ps: +List<T.Part>
  for +k: Nat
  for +bytes: +List<U32>
  for pos: {Nat.is_lt(0n, n) == True{} : Bool}
  for +widths: {H.widths(ps) == List.replicate(Maybe<&2, Nat>, k, Some{n}) : +List<Maybe<&2, Nat>>}
  for +encoded: {E.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.item_count(Some{n}, bytes) == Some{k} : Maybe<&2, Nat>}
def count_some(n, ps, k, bytes, pos, widths, encoded):
  match n:
    case 0n: Empty.absurd({D.item_count(Some{0n}, bytes) == Some{k} : Maybe<&2, Nat>}, W.false_true(pos))
    case 1n+w: fixed_items(ps, k, w, bytes, widths, encoded)

law count_items:
  for +width: Maybe<&2, Nat>
  for +ps: +List<T.Part>
  for +k: Nat
  for +bytes: +List<U32>
  for pos: positive(width)
  for +widths: {H.widths(ps) == List.replicate(Maybe<&2, Nat>, k, width) : +List<Maybe<&2, Nat>>}
  for +encoded: {E.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.item_count(width, bytes) == Some{k} : Maybe<&2, Nat>}
def count_items(width, ps, k, bytes, pos, widths, encoded):
  match width:
    case None{}: variable_items(ps, k, bytes, widths, encoded)
    case Some{n}: count_some(n, ps, k, bytes, pos, widths, encoded)

# Positive widths: every legal fixed-size SSZ type has at least one byte.
law quotient_positive:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  {Nat.is_lt(0n, Nat.div.fin(Nat.divmod.go(n, m, 1n+d, r))) == True{} : Bool}
def quotient_positive(n, m, d, r):
  match n:
    case 0n: {==}
    case 1n+np:
      match m:
        case 0n: quotient_positive(np, r, 1n+d, 0n)
        case 1n+mp: quotient_positive(np, mp, d, 1n+r)

law bit_bytes_positive:
  for +n: Nat
  for legal: {Nat.is_lt(0n, n) == True{} : Bool}
  {Nat.is_lt(0n, Nat.div(Nat.add(n, 7n), 8n)) == True{} : Bool}
def bit_bytes_positive(n, legal):
  match n:
    case 0n: Empty.absurd({Nat.is_lt(0n, Nat.div(Nat.add(0n, 7n), 8n)) == True{} : Bool}, W.false_true(legal))
    case 1n+p:
      %Equal.sym(Nat, Nat.add(p, 7n), Nat.add(7n, p), A.add_commute(p, 7n)) : {Nat.is_lt(0n, Nat.div(1n+_, 8n)) == True{} : Bool}
      quotient_positive(p, 7n, 0n, 0n)

law mul_positive:
  for +n: Nat
  for +w: Nat
  for a: {Nat.is_lt(0n, n) == True{} : Bool}
  for b: {Nat.is_lt(0n, w) == True{} : Bool}
  {Nat.is_lt(0n, Nat.mul(n, w)) == True{} : Bool}
def mul_positive(n, w, a, b):
  match n:
    case 0n: Empty.absurd({Nat.is_lt(0n, Nat.mul(0n, w)) == True{} : Bool}, W.false_true(a))
    case 1n+p:
      match w:
        case 0n: Empty.absurd({Nat.is_lt(0n, Nat.mul(1n+p, 0n)) == True{} : Bool}, W.false_true(b))
        case 1n+q: {==}

law times_positive:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  for legal: {Nat.is_lt(0n, n) == True{} : Bool}
  for inner: positive(width)
  positive(SS.times(n, width))
def times_positive(n, width, legal, inner):
  match width:
    case None{}: Unit{}
    case Some{w}: mul_positive(n, w, legal, inner)

law add_positive:
  for +x: Nat
  for +y: Nat
  for inner: {Nat.is_lt(0n, x) == True{} : Bool}
  {Nat.is_lt(0n, Nat.add(x, y)) == True{} : Bool}
def add_positive(x, y, inner):
  match x:
    case 0n: Empty.absurd({Nat.is_lt(0n, Nat.add(0n, y)) == True{} : Bool}, W.false_true(inner))
    case 1n+p: {==}

law sum_positive:
  for +a: Maybe<&2, Nat>
  for +b: Maybe<&2, Nat>
  for inner: positive(a)
  positive(SS.sum(a, b))
def sum_positive(a, b, inner):
  match a b:
    case None{} _: Unit{}
    case Some{x} None{}: Unit{}
    case Some{x} Some{y}: add_positive(x, y, inner)


# ---------------------------------------------------------------------------
# Composite steps: the actual layout decoder recovers the independent child
# slices, and the recursive forest decoder rebuilds the value.

law layout_bytes:
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {SP.bytes_domain(bytes) == True{} : Bool}
def layout_bytes(cps, bytes, encoded):
  %Image.optional_output(Bool.and(E.bytes_valid(cps), N.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))))), List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps)), bytes, encoded) : {SP.bytes_domain(_) == True{} : Bool}
  %Equal.sym(Bool, SP.bytes_domain(List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps))), E.bytes_valid(cps), Layout.output_domain(cps, E.fixed_size(cps))) : {_ == True{} : Bool}
  V.and_left(E.bytes_valid(cps), N.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps)))), Image.optional_valid(Bool.and(E.bytes_valid(cps), N.fits(4n, Nat.add(E.fixed_size(cps), List.length(&2, U32, E.payloads(cps))))), List.append(&2, U32, E.fixed_parts(cps, E.fixed_size(cps)), E.payloads(cps)), bytes, encoded))

law slices_decoded:
  for +widths: +List<Maybe<&2, Nat>>
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for +same: {H.widths(cps) == widths : +List<Maybe<&2, Nat>>}
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {IL.decode(widths, bytes) == Some{H.values(cps)} : Maybe<&2, +List<+List<U32>>>}
def slices_decoded(widths, cps, bytes, same, encoded):
  %same : {IL.decode(_, bytes) == Some{H.values(cps)} : Maybe<&2, +List<+List<U32>>>}
  Equal.trans(Maybe<&2, +List<+List<U32>>>, IL.decode(H.widths(cps), bytes), LD.decoding(H.widths(cps), bytes), Some{H.values(cps)}, Headers.decode_correct(H.widths(cps), bytes), Image.encoding_image_complete(cps, bytes, encoded))

law slices_step:
  for +forest: T.Schema
  for +items: T.Value
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for +ws: +List<Maybe<&2, Nat>>
  for +same: {H.widths(cps) == ws : +List<Maybe<&2, Nat>>}
  for inner: forest_goal(forest, items, cps)
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.slices(IL.decode(ws, bytes), ps => D.sequence(D.decode_go(fuel(items), forest, [], ps, T.EmptyItems{}))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
def slices_step(forest, items, cps, bytes, ws, same, inner, encoded):
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, IL.decode(ws, bytes), Some{H.values(cps)}, slices_decoded(ws, cps, bytes, same, encoded)) : {D.slices(_, ps => D.sequence(D.decode_go(fuel(items), forest, [], ps, T.EmptyItems{}))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  %Equal.sym(Maybe<&2, T.Value>, D.decode_go(fuel(items), forest, [], H.values(cps), T.EmptyItems{}), Some{D.reverse_items(T.EmptyItems{}, items)}, inner(T.EmptyItems{})) : {D.sequence(_) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  {==}

law replicate_widths:
  for +e: T.Schema
  for +k: Nat
  for +cps: +List<T.Part>
  for +rshape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, k, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  {H.widths(cps) == Lists.replicate(Maybe<&2, Nat>, k, I.fixed_size(e)) : +List<Maybe<&2, Nat>>}
def replicate_widths(e, k, cps, rshape):
  %Equal.sym(Maybe<&2, Nat>, I.fixed_size(e), SS.fixed_size(e), Sch.fixed_size_correct(e)) : {H.widths(cps) == Lists.replicate(Maybe<&2, Nat>, k, _) : +List<Maybe<&2, Nat>>}
  %Equal.sym(+List<Maybe<&2, Nat>>, Lists.replicate(Maybe<&2, Nat>, k, SS.fixed_size(e)), List.replicate(Maybe<&2, Nat>, k, SS.fixed_size(e)), L.replicate_correct(Maybe<&2, Nat>, k, SS.fixed_size(e))) : {H.widths(cps) == _ : +List<Maybe<&2, Nat>>}
  rshape

law counted_items:
  for +e: T.Schema
  for +k: Nat
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for pos: positive(SS.fixed_size(e))
  for +rshape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, k, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.item_count(I.fixed_size(e), bytes) == Some{k} : Maybe<&2, Nat>}
def counted_items(e, k, cps, bytes, pos, rshape, encoded):
  %Equal.sym(Maybe<&2, Nat>, I.fixed_size(e), SS.fixed_size(e), Sch.fixed_size_correct(e)) : {D.item_count(_, bytes) == Some{k} : Maybe<&2, Nat>}
  count_items(SS.fixed_size(e), cps, k, bytes, pos, rshape, encoded)

law list_step:
  for +e: T.Schema
  for +limit: Nat
  for +items: T.Value
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for pos: positive(SS.fixed_size(e))
  for +bound: {Nat.is_le(S.count(items), limit) == True{} : Bool}
  for +rshape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, S.count(items), SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for inner: forest_goal(T.Repeat{e}, items, cps)
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.decode_go(1n+fuel(items), T.ListOf{e, limit}, bytes, [], T.EmptyItems{}) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
def list_step(e, limit, items, cps, bytes, pos, bound, rshape, inner, encoded):
  %Equal.sym(Maybe<&2, Nat>, D.item_count(I.fixed_size(e), bytes), Some{S.count(items)}, counted_items(e, S.count(items), cps, bytes, pos, rshape, encoded)) : {D.with_count(_, +n => D.gate(Nat.is_le(n, limit), u => D.slices(IL.decode(Lists.replicate(Maybe<&2, Nat>, n, I.fixed_size(e)), bytes), ps => D.sequence(D.decode_go(fuel(items), T.Repeat{e}, [], ps, T.EmptyItems{}))))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  %Equal.sym(Bool, Nat.is_le(S.count(items), limit), True{}, bound) : {D.gate(_, u => D.slices(IL.decode(Lists.replicate(Maybe<&2, Nat>, S.count(items), I.fixed_size(e)), bytes), ps => D.sequence(D.decode_go(fuel(items), T.Repeat{e}, [], ps, T.EmptyItems{})))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  slices_step(T.Repeat{e}, items, cps, bytes, Lists.replicate(Maybe<&2, Nat>, S.count(items), I.fixed_size(e)), replicate_widths(e, S.count(items), cps, rshape), inner, encoded)

law progressive_list_step:
  for +e: T.Schema
  for +items: T.Value
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for pos: positive(SS.fixed_size(e))
  for +rshape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, S.count(items), SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for inner: forest_goal(T.Repeat{e}, items, cps)
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.decode_go(1n+fuel(items), T.ProgressiveList{e}, bytes, [], T.EmptyItems{}) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
def progressive_list_step(e, items, cps, bytes, pos, rshape, inner, encoded):
  %Equal.sym(Maybe<&2, Nat>, D.item_count(I.fixed_size(e), bytes), Some{S.count(items)}, counted_items(e, S.count(items), cps, bytes, pos, rshape, encoded)) : {D.with_count(_, n => D.slices(IL.decode(Lists.replicate(Maybe<&2, Nat>, n, I.fixed_size(e)), bytes), ps => D.sequence(D.decode_go(fuel(items), T.Repeat{e}, [], ps, T.EmptyItems{})))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  slices_step(T.Repeat{e}, items, cps, bytes, Lists.replicate(Maybe<&2, Nat>, S.count(items), I.fixed_size(e)), replicate_widths(e, S.count(items), cps, rshape), inner, encoded)

law nat_eq_refl:
  for +n: Nat
  {Nat.is_eq(n, n) == True{} : Bool}
def nat_eq_refl(n):
  match n:
    case 0n: {==}
    case 1n+p: nat_eq_refl(p)

law vector_step:
  for +e: T.Schema
  for +n: Nat
  for +items: T.Value
  for +cps: +List<T.Part>
  for +bytes: +List<U32>
  for pos: positive(SS.fixed_size(e))
  for +size: {S.count(items) == n : Nat}
  for +rshape: {H.widths(cps) == List.replicate(Maybe<&2, Nat>, S.count(items), SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for inner: forest_goal(T.Repeat{e}, items, cps)
  for +encoded: {E.encoding(cps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {D.decode_go(1n+fuel(items), T.Vector{e, n}, bytes, [], T.EmptyItems{}) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
def vector_step(e, n, items, cps, bytes, pos, size, rshape, inner, encoded):
  %Equal.sym(Maybe<&2, Nat>, D.item_count(I.fixed_size(e), bytes), Some{S.count(items)}, counted_items(e, S.count(items), cps, bytes, pos, rshape, encoded)) : {D.with_count(_, k => D.gate(Nat.is_eq(k, n), u => D.slices(IL.decode(Lists.replicate(Maybe<&2, Nat>, n, I.fixed_size(e)), bytes), ps => D.sequence(D.decode_go(fuel(items), T.Repeat{e}, [], ps, T.EmptyItems{}))))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  %size : {D.gate(Nat.is_eq(S.count(items), _), u => D.slices(IL.decode(Lists.replicate(Maybe<&2, Nat>, _, I.fixed_size(e)), bytes), ps => D.sequence(D.decode_go(fuel(items), T.Repeat{e}, [], ps, T.EmptyItems{})))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  %Equal.sym(Bool, Nat.is_eq(S.count(items), S.count(items)), True{}, nat_eq_refl(S.count(items))) : {D.gate(_, u => D.slices(IL.decode(Lists.replicate(Maybe<&2, Nat>, S.count(items), I.fixed_size(e)), bytes), ps => D.sequence(D.decode_go(fuel(items), T.Repeat{e}, [], ps, T.EmptyItems{})))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  slices_step(T.Repeat{e}, items, cps, bytes, Lists.replicate(Maybe<&2, Nat>, S.count(items), I.fixed_size(e)), replicate_widths(e, S.count(items), cps, rshape), inner, encoded)

law chain_same:
  for +ws: +List<Maybe<&2, Nat>>
  for +size: Maybe<&2, Nat>
  for +cps: +List<T.Part>
  for shape: F.chain_fact(ws, size, Some{cps})
  {H.widths(cps) == ws : +List<Maybe<&2, Nat>>}
def chain_same(ws, size, cps, shape):
  (same, tot) = shape
  same

law list_inverse:
  for +e: T.Schema
  for +limit: Nat
  for +items: T.Value
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for +bound: {Nat.is_le(S.count(items), limit) == ok : Bool}
  for pos: positive(SS.fixed_size(e))
  for shape: F.repeat_fact(List.replicate(Maybe<&2, Nat>, S.count(items), SS.fixed_size(e)), r)
  for inner: forest_result(T.Repeat{e}, items, r)
  single_result(T.ListOf{e, limit}, T.Sequence{items}, S.require(ok, S.aggregate(r, None{})))
def list_inverse(e, limit, items, ok, r, bound, pos, shape, inner):
  match ok:
    case False{}: Unit{}
    case True{}:
      match r:
        case None{}: Unit{}
        case Some{cps}: one_leaf(T.ListOf{e, limit}, T.Sequence{items}, E.encoding(cps), None{}, bytes => enc => (list_step(e, limit, items, cps, bytes, pos, bound, shape, inner, enc), layout_bytes(cps, bytes, enc)))

law progressive_list_inverse:
  for +e: T.Schema
  for +items: T.Value
  for +r: Maybe<&2, +List<T.Part>>
  for pos: positive(SS.fixed_size(e))
  for shape: F.repeat_fact(List.replicate(Maybe<&2, Nat>, S.count(items), SS.fixed_size(e)), r)
  for inner: forest_result(T.Repeat{e}, items, r)
  single_result(T.ProgressiveList{e}, T.Sequence{items}, S.aggregate(r, None{}))
def progressive_list_inverse(e, items, r, pos, shape, inner):
  match r:
    case None{}: Unit{}
    case Some{cps}: one_leaf(T.ProgressiveList{e}, T.Sequence{items}, E.encoding(cps), None{}, bytes => enc => (progressive_list_step(e, items, cps, bytes, pos, shape, inner, enc), layout_bytes(cps, bytes, enc)))

law vector_inverse:
  for +e: T.Schema
  for +n: Nat
  for +items: T.Value
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for +condition: {Bool.and(Nat.is_lt(0n, n), Nat.is_eq(S.count(items), n)) == ok : Bool}
  for pos: positive(SS.fixed_size(e))
  for shape: F.repeat_fact(List.replicate(Maybe<&2, Nat>, S.count(items), SS.fixed_size(e)), r)
  for inner: forest_result(T.Repeat{e}, items, r)
  single_result(T.Vector{e, n}, T.Sequence{items}, S.require(ok, S.aggregate(r, SS.times(n, SS.fixed_size(e)))))
def vector_inverse(e, n, items, ok, r, condition, pos, shape, inner):
  match ok:
    case False{}: Unit{}
    case True{}:
      match r:
        case None{}: Unit{}
        case Some{cps}: one_leaf(T.Vector{e, n}, T.Sequence{items}, E.encoding(cps), SS.times(n, SS.fixed_size(e)), bytes => enc => (vector_step(e, n, items, cps, bytes, pos, Eq.nat_equal_sound(S.count(items), n, V.and_right(Nat.is_lt(0n, n), Nat.is_eq(S.count(items), n), condition)), shape, inner, enc), layout_bytes(cps, bytes, enc)))

law container_inverse:
  for +schema: T.Schema
  for +fields: T.Schema
  for +items: T.Value
  for +r: Maybe<&2, +List<T.Part>>
  for +impl: {I.widths(fields) == F.widths(fields) : +List<Maybe<&2, Nat>>}
  for step: @+cps: +List<T.Part> -> @+bytes: +List<U32> -> {D.slices(IL.decode(I.widths(fields), bytes), ps => D.sequence(D.decode_go(fuel(items), fields, [], ps, T.EmptyItems{}))) == Some{T.Sequence{items}} : Maybe<&2, T.Value>} -> {D.decode_go(1n+fuel(items), schema, bytes, [], T.EmptyItems{}) == Some{T.Sequence{items}} : Maybe<&2, T.Value>}
  for shape: F.chain_fact(F.widths(fields), SS.fixed_size(fields), r)
  for inner: forest_result(fields, items, r)
  single_result(schema, T.Sequence{items}, S.aggregate(r, SS.fixed_size(fields)))
def container_inverse(schema, fields, items, r, impl, step, shape, inner):
  match r:
    case None{}: Unit{}
    case Some{cps}: one_leaf(schema, T.Sequence{items}, E.encoding(cps), SS.fixed_size(fields), bytes => enc => (step(cps, bytes, slices_step(fields, items, cps, bytes, I.widths(fields), Equal.trans(+List<Maybe<&2, Nat>>, H.widths(cps), F.widths(fields), I.widths(fields), chain_same(F.widths(fields), SS.fixed_size(fields), cps, shape), Equal.sym(+List<Maybe<&2, Nat>>, I.widths(fields), F.widths(fields), impl)), inner, enc)), layout_bytes(cps, bytes, enc)))

# ---------------------------------------------------------------------------
# Union selectors.

law selected_decodes:
  for +lookup: Maybe<&2, T.Schema>
  for +sel: U32
  for +v: T.Value
  for +s: T.Schema
  for +xs: +List<U32>
  for found: {lookup == Some{s} : Maybe<&2, T.Schema>}
  for decoded: {D.decode_go(fuel(v), s, xs, [], T.EmptyItems{}) == Some{v} : Maybe<&2, T.Value>}
  {D.option(lookup, t => D.selected(sel, D.decode_go(fuel(v), t, xs, [], T.EmptyItems{}))) == Some{T.Selected{sel, v}} : Maybe<&2, T.Value>}
def selected_decodes(lookup, sel, v, s, xs, found, decoded):
  %Equal.sym(Maybe<&2, T.Schema>, lookup, Some{s}, found) : {D.option(_, t => D.selected(sel, D.decode_go(fuel(v), t, xs, [], T.EmptyItems{}))) == Some{T.Selected{sel, v}} : Maybe<&2, T.Value>}
  %Equal.sym(Maybe<&2, T.Value>, D.decode_go(fuel(v), s, xs, [], T.EmptyItems{}), Some{v}, decoded) : {D.selected(sel, _) == Some{T.Selected{sel, v}} : Maybe<&2, T.Value>}
  {==}

law tagged_parts:
  for +schema: T.Schema
  for +sel: U32
  for +v: T.Value
  for +s: T.Schema
  for +ps: +List<T.Part>
  for +small: {U32.is_lt(sel, 256) == True{} : Bool}
  for step: @+xs: +List<U32> -> {D.decode_go(fuel(v), s, xs, [], T.EmptyItems{}) == Some{v} : Maybe<&2, T.Value>} -> {D.decode_go(1n+fuel(v), schema, sel <> xs, [], T.EmptyItems{}) == Some{T.Selected{sel, v}} : Maybe<&2, T.Value>}
  for inner: single_goal(s, v, ps)
  single_result(schema, T.Selected{sel, v}, S.tagged(sel, Some{ps}))
def tagged_parts(schema, sel, v, s, ps, small, step, inner):
  match ps:
    case Nil{}: Unit{}
    case Con{T.Fixed{xs}, Nil{}}:
      (decoded, domain) = inner
      (step(xs, decoded), V.and_true(U32.is_lt(sel, 256), SP.bytes_domain(xs), small, domain))
    case Con{T.Variable{xs}, Nil{}}:
      (decoded, domain) = inner
      (step(xs, decoded), V.and_true(U32.is_lt(sel, 256), SP.bytes_domain(xs), small, domain))
    case Con{T.Fixed{xs}, Con{p, q}}: Unit{}
    case Con{T.Variable{xs}, Con{p, q}}: Unit{}

law tagged_result:
  for +schema: T.Schema
  for +sel: U32
  for +v: T.Value
  for +s: T.Schema
  for +r: Maybe<&2, +List<T.Part>>
  for +small: {U32.is_lt(sel, 256) == True{} : Bool}
  for step: @+xs: +List<U32> -> {D.decode_go(fuel(v), s, xs, [], T.EmptyItems{}) == Some{v} : Maybe<&2, T.Value>} -> {D.decode_go(1n+fuel(v), schema, sel <> xs, [], T.EmptyItems{}) == Some{T.Selected{sel, v}} : Maybe<&2, T.Value>}
  for inner: single_result(s, v, r)
  single_result(schema, T.Selected{sel, v}, S.tagged(sel, r))
def tagged_result(schema, sel, v, s, r, small, step, inner):
  match r:
    case None{}: Unit{}
    case Some{ps}: tagged_parts(schema, sel, v, s, ps, small, step, inner)

def option_ok(s: T.Schema) -> Bool:
  match s:
    case T.Null{}: True{}
    case _: I.valid_go(s, False{})

def selection(sel: U32, found: Maybe<&2, T.Schema>) -> Type:
  match found:
    case None{}: Unit
    case Some{s}: {option_ok(s) == True{} : Bool} & {U32.is_lt(sel, 256) == True{} : Bool}

law union_found:
  for +schema: T.Schema
  for +sel: U32
  for +v: T.Value
  for +found: Maybe<&2, T.Schema>
  for facts: selection(sel, found)
  for step: @+s: T.Schema -> {found == Some{s} : Maybe<&2, T.Schema>} -> @+xs: +List<U32> -> {D.decode_go(fuel(v), s, xs, [], T.EmptyItems{}) == Some{v} : Maybe<&2, T.Value>} -> {D.decode_go(1n+fuel(v), schema, sel <> xs, [], T.EmptyItems{}) == Some{T.Selected{sel, v}} : Maybe<&2, T.Value>}
  for recur: @+s: T.Schema -> @+valid: {option_ok(s) == True{} : Bool} -> single_result(s, v, S.parts(v, s))
  single_result(schema, T.Selected{sel, v}, S.with_option(found, s => S.tagged(sel, S.parts(v, s))))
def union_found(schema, sel, v, found, facts, step, recur):
  match found:
    case None{}: Unit{}
    case Some{s}:
      (valid, small) = facts
      tagged_result(schema, sel, v, s, S.parts(v, s), small, step(s, {==}), recur(s, valid))

law lt_le:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for ab: {Nat.is_lt(a, b) == True{} : Bool}
  for bc: {Nat.is_le(b, c) == True{} : Bool}
  {Nat.is_lt(a, c) == True{} : Bool}
def lt_le(a, b, c, ab, bc):
  match a:
    case 0n:
      match b:
        case 0n: Empty.absurd({Nat.is_lt(0n, c) == True{} : Bool}, W.false_true(ab))
        case 1n+q:
          match c:
            case 0n: Empty.absurd({Nat.is_lt(0n, 0n) == True{} : Bool}, W.false_true(bc))
            case 1n+r: {==}
    case 1n+p:
      match b:
        case 0n: Empty.absurd({Nat.is_lt(1n+p, c) == True{} : Bool}, W.false_true(ab))
        case 1n+q:
          match c:
            case 0n: Empty.absurd({Nat.is_lt(1n+p, 0n) == True{} : Bool}, W.false_true(bc))
            case 1n+r: lt_le(p, q, r, ab, bc)

law u32_below:
  for +x: U32
  for +limit: U32
  for +bound: Nat
  for small: {Nat.is_lt(U32.to_nat(x), bound) == True{} : Bool}
  for fits: {Nat.is_le(bound, U32.to_nat(limit)) == True{} : Bool}
  {U32.is_lt(x, limit) == True{} : Bool}
def u32_below(x, limit, bound, small, fits):
  %Equal.sym(Bool, U32.is_lt(x, limit), Nat.is_lt(U32.to_nat(x), U32.to_nat(limit)), U32Order.u32_less(x, limit)) : {_ == True{} : Bool}
  lt_le(U32.to_nat(x), bound, U32.to_nat(limit), small, fits)

law u32_widen:
  for +h: U32
  for small: {U32.is_lt(h, 128) == True{} : Bool}
  {U32.is_lt(h, 256) == True{} : Bool}
def u32_widen(h, small):
  u32_below(h, 256, 128n,
    %U32Order.u32_less(h, 128) : {_ == True{} : Bool}
    small, {==})

# Accumulated forest decoding (Chain and Repeat share the actual step shape).
law accumulate_step:
  for +s: T.Schema
  for +rest: T.Schema
  for +h: T.Value
  for +t: T.Value
  for +xs: +List<U32>
  for +vals: +List<+List<U32>>
  for +acc: T.Value
  for head: {D.decode_go(fuel(h), s, xs, [], T.EmptyItems{}) == Some{h} : Maybe<&2, T.Value>}
  for tail: @+prior: T.Value -> {D.decode_go(fuel(t), rest, [], vals, prior) == Some{D.reverse_items(prior, t)} : Maybe<&2, T.Value>}
  {D.accumulate(D.decode_go(Nat.add(fuel(h), fuel(t)), s, xs, [], T.EmptyItems{}), acc, next => D.decode_go(Nat.add(fuel(h), fuel(t)), rest, [], vals, next)) == Some{D.reverse_items(acc, T.Items{h, t})} : Maybe<&2, T.Value>}
def accumulate_step(s, rest, h, t, xs, vals, acc, head, tail):
  %Equal.sym(Maybe<&2, T.Value>, D.decode_go(Nat.add(fuel(h), fuel(t)), s, xs, [], T.EmptyItems{}), Some{h}, Mono.successful_extension(fuel(h), fuel(t), s, xs, [], T.EmptyItems{}, h, head)) : {D.accumulate(_, acc, next => D.decode_go(Nat.add(fuel(h), fuel(t)), rest, [], vals, next)) == Some{D.reverse_items(acc, T.Items{h, t})} : Maybe<&2, T.Value>}
  %A.add_commute(fuel(t), fuel(h)) : {D.decode_go(_, rest, [], vals, T.Items{h, acc}) == Some{D.reverse_items(acc, T.Items{h, t})} : Maybe<&2, T.Value>}
  Mono.successful_extension(fuel(t), fuel(h), rest, [], vals, T.Items{h, acc}, D.reverse_items(T.Items{h, acc}, t), tail(T.Items{h, acc}))

law chain_parts_inverse:
  for +s: T.Schema
  for +rest: T.Schema
  for +h: T.Value
  for +t: T.Value
  for +hps: +List<T.Part>
  for +tps: +List<T.Part>
  for single: F.single(SS.fixed_size(s), hps)
  for head: single_goal(s, h, hps)
  for tail: forest_goal(rest, t, tps)
  forest_goal(T.Chain{s, rest}, T.Items{h, t}, List.append(&2, T.Part, hps, tps))
def chain_parts_inverse(s, rest, h, t, hps, tps, single, head, tail):
  match hps:
    case Nil{}:
      match single:
    case Con{T.Fixed{xs}, Nil{}}:
      (decoded, domain) = head
      acc => accumulate_step(s, rest, h, t, xs, H.values(tps), acc, decoded, tail)
    case Con{T.Variable{xs}, Nil{}}:
      (decoded, domain) = head
      acc => accumulate_step(s, rest, h, t, xs, H.values(tps), acc, decoded, tail)
    case Con{T.Fixed{xs}, Con{p, q}}:
      match single:
    case Con{T.Variable{xs}, Con{p, q}}:
      match single:

law chain_inverse:
  for +s: T.Schema
  for +rest: T.Schema
  for +h: T.Value
  for +t: T.Value
  for +hr: Maybe<&2, +List<T.Part>>
  for +tr: Maybe<&2, +List<T.Part>>
  for single: F.single_result(SS.fixed_size(s), hr)
  for head: single_result(s, h, hr)
  for tail: forest_result(rest, t, tr)
  forest_result(T.Chain{s, rest}, T.Items{h, t}, S.concatenate(hr, tr))
def chain_inverse(s, rest, h, t, hr, tr, single, head, tail):
  match hr tr:
    case None{} _: Unit{}
    case Some{hps} None{}: Unit{}
    case Some{hps} Some{tps}: chain_parts_inverse(s, rest, h, t, hps, tps, single, head, tail)

law repeat_parts_inverse:
  for +s: T.Schema
  for +h: T.Value
  for +t: T.Value
  for +hps: +List<T.Part>
  for +tps: +List<T.Part>
  for single: F.single(SS.fixed_size(s), hps)
  for head: single_goal(s, h, hps)
  for tail: forest_goal(T.Repeat{s}, t, tps)
  forest_goal(T.Repeat{s}, T.Items{h, t}, List.append(&2, T.Part, hps, tps))
def repeat_parts_inverse(s, h, t, hps, tps, single, head, tail):
  match hps:
    case Nil{}:
      match single:
    case Con{T.Fixed{xs}, Nil{}}:
      (decoded, domain) = head
      acc => accumulate_step(s, T.Repeat{s}, h, t, xs, H.values(tps), acc, decoded, tail)
    case Con{T.Variable{xs}, Nil{}}:
      (decoded, domain) = head
      acc => accumulate_step(s, T.Repeat{s}, h, t, xs, H.values(tps), acc, decoded, tail)
    case Con{T.Fixed{xs}, Con{p, q}}:
      match single:
    case Con{T.Variable{xs}, Con{p, q}}:
      match single:

law repeat_inverse:
  for +s: T.Schema
  for +h: T.Value
  for +t: T.Value
  for +hr: Maybe<&2, +List<T.Part>>
  for +tr: Maybe<&2, +List<T.Part>>
  for single: F.single_result(SS.fixed_size(s), hr)
  for head: single_result(s, h, hr)
  for tail: forest_result(T.Repeat{s}, t, tr)
  forest_result(T.Repeat{s}, T.Items{h, t}, S.concatenate(hr, tr))
def repeat_inverse(s, h, t, hr, tr, single, head, tail):
  match hr tr:
    case None{} _: Unit{}
    case Some{hps} None{}: Unit{}
    case Some{hps} Some{tps}: repeat_parts_inverse(s, h, t, hps, tps, single, head, tail)

def index_fact(j: Nat, c: Nat, found: Maybe<&2, T.Schema>) -> Type:
  match found:
    case None{}: Unit
    case Some{s}: {option_ok(s) == True{} : Bool} & {Nat.is_lt(j, c) == True{} : Bool}

law index_shift:
  for +j: Nat
  for +c: Nat
  for +found: Maybe<&2, T.Schema>
  for known: index_fact(j, c, found)
  index_fact(1n+j, 1n+c, found)
def index_shift(j, c, found, known):
  match found:
    case None{}: Unit{}
    case Some{s}: known

law index_widen:
  for +j: Nat
  for +c: Nat
  for +found: Maybe<&2, T.Schema>
  for known: index_fact(j, c, found)
  for +bound: {Nat.is_le(c, 127n) == True{} : Bool}
  index_fact(1n+j, 128n, found)
def index_widen(j, c, found, known, bound):
  match found:
    case None{}: Unit{}
    case Some{s}:
      (valid, less) = known
      (valid, lt_le(j, c, 127n, less, bound))

law index_selection:
  for +sel: U32
  for +found: Maybe<&2, T.Schema>
  for known: index_fact(U32.to_nat(sel), 128n, found)
  selection(sel, found)
def index_selection(sel, found, known):
  match found:
    case None{}: Unit{}
    case Some{s}:
      (valid, less) = known
      (valid, u32_below(sel, 256, 128n, less, {==}))

law compat_select:
  for +found: Bool
  for +h: U32
  for +sel: U32
  for +o: T.Schema
  for +rest: Maybe<&2, T.Schema>
  for +same: {U32.is_eq(h, sel) == found : Bool}
  for +small: {U32.is_lt(h, 256) == True{} : Bool}
  for +valid: {option_ok(o) == True{} : Bool}
  for known: selection(sel, rest)
  selection(sel, SS.selected(found, o, rest))
def compat_select(found, h, sel, o, rest, same, small, valid, known):
  match found:
    case False{}: known
    case True{}:
      (valid, %W.u32_equal_sound(h, sel, same) : {U32.is_lt(_, 256) == True{} : Bool}
       small)
