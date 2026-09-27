import Base
import ../types/primitive.bend as Prim
import ../spec/primitives.bend as SP
import ./integer_encoding.bend as IntegerEnc
import ./primitive_invariants.bend as V

# An unsigned integer's encoding (its byte_width-digit prefix) is in the byte domain. Split out of
# root_total.bend so that encoding_domain.bend reaches it without root_total's imports (root_sound,
# type_validator_soundness and the compatibility proofs).

law result_domain:
  for +r: Maybe<&2, +List<U32>>
  for +x: +List<U32>
  for +same: {r == Some{x} : Maybe<&2, +List<U32>>}
  for known: V.byte_result(r)
  {SP.bytes_domain(x) == True{} : Bool}
def result_domain(r, x, same, known):
  %same : V.byte_result(_)
  known

law uint_prefix_domain:
  for +w: Prim.Width
  for +v: Prim.UInt
  for +valid: {SP.uint_domain(w, v) == True{} : Bool}
  {SP.bytes_domain(SP.prefix(SP.byte_width(w), SP.full_digits(v))) == True{} : Bool}
def uint_prefix_domain(w, v, valid):
  result_domain(SP.uint_encoding(w, v), SP.prefix(SP.byte_width(w), SP.full_digits(v)),
    %Equal.sym(Bool, SP.uint_domain(w, v), True{}, valid) : {SP.optional(_, SP.prefix(SP.byte_width(w), SP.full_digits(v))) == Some{SP.prefix(SP.byte_width(w), SP.full_digits(v))} : Maybe<&2, +List<U32>>}
    {==},
    %IntegerEnc.uint_serialize_correct(w, v) : V.byte_result(_)
    V.uint_serialized_bytes(w, v))
