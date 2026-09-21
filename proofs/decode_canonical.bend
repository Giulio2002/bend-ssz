import Base
import ../src/primitives.bend as Primitive
import ../src/ssz.bend as API
import ../src/schema.bend as Schema
import ../src/packing.bend as Packing
import ../src/lists.bend as Lists
import ../types/schema.bend as T
import ../src/decode.bend as I
import ./decode_top.bend as Top
import ../src/codec.bend as Codec
import ../spec/byte_sequence.bend as S
import ./bytes.bend as B
import ./word_facts.bend as W
import ./primitive_invariants.bend as V

law equality_acc:
  for +a: +List<U32>
  for +b: +List<U32>
  for +ok: Bool
  {I.equal_bytes_go(a, b, ok) == Bool.and(ok, S.equal(a, b)) : Bool}
def equality_acc(a, b, ok):
  match a b:
    case Nil{} Nil{}: Equal.sym(Bool, Bool.and(ok, True{}), ok, B.and_identity(ok))
    case Nil{} Con{y, ys}: Equal.sym(Bool, Bool.and(ok, False{}), False{}, B.and_zero(ok))
    case Con{x, xs} Nil{}: Equal.sym(Bool, Bool.and(ok, False{}), False{}, B.and_zero(ok))
    case Con{x, xs} Con{y, ys}:
      %B.and_associative(ok, U32.is_eq(x, y), S.equal(xs, ys)) : {I.equal_bytes_go(xs, ys, Bool.and(ok, U32.is_eq(x, y))) == _ : Bool}
      equality_acc(xs, ys, Bool.and(ok, U32.is_eq(x, y)))

law equality_correct:
  for +a: +List<U32>
  for +b: +List<U32>
  {I.equal_bytes(a, b) == S.equal(a, b) : Bool}
def equality_correct(a, b): equality_acc(a, b, True{})

law equality_sound:
  for +a: +List<U32>
  for +b: +List<U32>
  for +same: {S.equal(a, b) == True{} : Bool}
  {a == b : +List<U32>}
def equality_sound(a, b, same):
  match a b:
    case Nil{} Nil{}: {==}
    case Nil{} Con{y, ys}: Empty.absurd({[] == y <> ys : +List<U32>}, W.false_true(same))
    case Con{x, xs} Nil{}: Empty.absurd({x <> xs == [] : +List<U32>}, W.false_true(same))
    case Con{x, xs} Con{y, ys}:
      %W.u32_equal_sound(x, y, V.and_left(U32.is_eq(x, y), S.equal(xs, ys), same)) : {x <> xs == _ <> ys : +List<U32>}
      Equal.cong(+List<U32>, +List<U32>, tail => x <> tail, xs, ys, equality_sound(xs, ys, V.and_right(U32.is_eq(x, y), S.equal(xs, ys), same)))

law actual_equality_sound:
  for +a: +List<U32>
  for +b: +List<U32>
  for same: {I.equal_bytes(a, b) == True{} : Bool}
  {a == b : +List<U32>}
def actual_equality_sound(a, b, same):
  equality_sound(a, b, Equal.trans(Bool, S.equal(a, b), I.equal_bytes(a, b), True{}, Equal.sym(Bool, I.equal_bytes(a, b), S.equal(a, b), equality_correct(a, b)), same))

# This property reaches the actual serializer. It is a decoder soundness
# layer, not the missing independent generic codec refinement/completeness.
def canonical_output(schema: T.Schema, input: +List<U32>, result: Maybe<&2, T.Value>) -> Type:
  match result:
    case None{}: Unit
    case Some{value}: {Codec.serialize(schema, value) == Some{input} : Maybe<&2, +List<U32>>}

law canonical_gate:
  for +ok: Bool
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for +encoded: +List<U32>
  for selected: {I.equal_bytes(encoded, input) == ok : Bool}
  for serialized: {Codec.serialize(schema, value) == Some{encoded} : Maybe<&2, +List<U32>>}
  canonical_output(schema, input, I.value_gate(ok, value))
def canonical_gate(ok, schema, input, value, encoded, selected, serialized):
  match ok:
    case False{}: Unit{}
    case True{}:
      %actual_equality_sound(encoded, input, selected) : {Codec.serialize(schema, value) == Some{_} : Maybe<&2, +List<U32>>}
      serialized

law canonical_bytes_sound:
  for +encoded: Maybe<&2, +List<U32>>
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for serialized: {Codec.serialize(schema, value) == encoded : Maybe<&2, +List<U32>>}
  canonical_output(schema, input, I.canonical_bytes(encoded, input, value))
def canonical_bytes_sound(encoded, schema, input, value, serialized):
  match encoded:
    case None{}: Unit{}
    case Some{xs}: canonical_gate(I.equal_bytes(xs, input), schema, input, value, xs, {==}, serialized)

law canonical_sound:
  for +result: Maybe<&2, T.Value>
  for +schema: T.Schema
  for +input: +List<U32>
  canonical_output(schema, input, I.canonical(result, schema, input))
def canonical_sound(result, schema, input):
  match result:
    case None{}: Unit{}
    case Some{value}: canonical_bytes_sound(Codec.serialize(schema, value), schema, input, value, {==})

law deserialize_gate_sound:
  for +ok: Bool
  for +schema: T.Schema
  for +input: +List<U32>
  for +raw: Maybe<&2, T.Value>
  canonical_output(schema, input, I.value_result(ok, I.canonical(raw, schema, input)))
def deserialize_gate_sound(ok, schema, input, raw):
  match ok:
    case False{}: Unit{}
    case True{}: canonical_sound(raw, schema, input)

law canonical_result:
  for +schema: T.Schema
  for +input: +List<U32>
  for +result: Maybe<&2, T.Value>
  for +evaluated: {I.deserialize(schema, input) == result : Maybe<&2, T.Value>}
  canonical_output(schema, input, result)
def canonical_result(schema, input, result, evaluated):
  match result:
    case None{}: Unit{}
    case Some{value}: Top.accepted_serializes(schema, input, value, evaluated)

law deserialize_canonical:
  for +schema: T.Schema
  for +input: +List<U32>
  canonical_output(schema, input, I.deserialize(schema, input))
def deserialize_canonical(schema, input):
  canonical_result(schema, input, I.deserialize(schema, input), {==})

# The decoder never re-serializes to decide acceptance: the structural offset
# and region checks already force the canonical encoding (decode_top).
law accepted_serializes_exactly:
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for accepted: {I.deserialize(schema, input) == Some{value} : Maybe<&2, T.Value>}
  {Codec.serialize(schema, value) == Some{input} : Maybe<&2, +List<U32>>}
def accepted_serializes_exactly(schema, input, value, accepted):
  %accepted : canonical_output(schema, input, _)
  deserialize_canonical(schema, input)

law public_accepted_serializes_exactly:
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for accepted: {API.deserialize(schema, input) == Some{value} : Maybe<&2, T.Value>}
  {API.serialize(schema, value) == Some{input} : Maybe<&2, +List<U32>>}
def public_accepted_serializes_exactly(schema, input, value, accepted):
  accepted_serializes_exactly(schema, input, value, accepted)

law equality_reflexive:
  for +xs: +List<U32>
  {S.equal(xs, xs) == True{} : Bool}
def equality_reflexive(xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: V.and_true(U32.is_eq(h, h), S.equal(t, t), W.word_equal_reflexive(h), equality_reflexive(t))

law actual_equality_reflexive:
  for +xs: +List<U32>
  {I.equal_bytes(xs, xs) == True{} : Bool}
def actual_equality_reflexive(xs):
  Equal.trans(Bool, I.equal_bytes(xs, xs), S.equal(xs, xs), True{}, equality_correct(xs, xs), equality_reflexive(xs))

# The canonical filter neither changes nor rejects any raw result whose actual
# encoding is the input. Raw decoding completeness remains a separate theorem.
law canonical_preserves_encoding:
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for encoded: {Codec.serialize(schema, value) == Some{input} : Maybe<&2, +List<U32>>}
  {I.canonical(Some{value}, schema, input) == Some{value} : Maybe<&2, T.Value>}
def canonical_preserves_encoding(schema, input, value, encoded):
  %Equal.sym(Maybe<&2, +List<U32>>, Codec.serialize(schema, value), Some{input}, encoded) : {I.canonical_bytes(_, input, value) == Some{value} : Maybe<&2, T.Value>}
  %Equal.sym(Bool, I.equal_bytes(input, input), True{}, actual_equality_reflexive(input)) : {I.value_gate(_, value) == Some{value} : Maybe<&2, T.Value>}
  {==}

law accepted_value_valid:
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for accepted: {API.deserialize(schema, input) == Some{value} : Maybe<&2, T.Value>}
  {API.valid(schema, value) == True{} : Bool}
def accepted_value_valid(schema, input, value, accepted):
  Equal.cong(Maybe<&2, +List<U32>>, Bool, result => Primitive.is_some(result), Codec.serialize(schema, value), Some{input}, public_accepted_serializes_exactly(schema, input, value, accepted))

law serialization_gate_valid:
  for +ok: Bool
  for -next: Unit -> Maybe<&2, +List<T.Part>>
  for present: {Primitive.is_some(Codec.unwrap(Codec.gate(ok, next))) == True{} : Bool}
  {ok == True{} : Bool}
def serialization_gate_valid(ok, next, present):
  match ok:
    case False{}: Empty.absurd({False{} == True{} : Bool}, W.false_true(present))
    case True{}: {==}

law valid_type_valid:
  for +schema: T.Schema
  for +value: T.Value
  for valid: {API.valid(schema, value) == True{} : Bool}
  {API.type_valid(schema) == True{} : Bool}
def valid_type_valid(schema, value, valid):
  serialization_gate_valid(Schema.valid(schema), u => Codec.encode(value, schema), valid)

law accepted_type_valid:
  for +schema: T.Schema
  for +input: +List<U32>
  for +value: T.Value
  for accepted: {API.deserialize(schema, input) == Some{value} : Maybe<&2, T.Value>}
  {API.type_valid(schema) == True{} : Bool}
def accepted_type_valid(schema, input, value, accepted):
  valid_type_valid(schema, value, accepted_value_valid(schema, input, value, accepted))
