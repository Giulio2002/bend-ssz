import Base
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./schema.bend as Schema
import ./codec.bend as Codec
import ./decode.bend as Decode
import ./root.bend as Root
import ./model.bend as Model

# The list-based SSZ model, re-exported from src/model.bend.
#
# This is NOT the production SSZ API. The production API is the generated typed
# owning object API: types/fulu_obj.bend for the 109 mainnet Fulu names and
# types/generic_obj.bend for the supported generic SSZ forms, both emitted by
# codegen/generate.py (see docs/CODEGEN.md). Packed buffers in, typed owning
# objects out, fresh packed bytes and 32-byte roots back.
#
# What remains here is the model the 29 frozen END_TO_END propositions are
# stated about, and the transport the 5,440 official cases run through in
# tools/spectests.py. It is kept because removing it would delete checked
# propositions the frozen acceptance gate requires, before equivalent generated
# laws exist; it is not on any measured path. The compact *view* codec that
# used to be the primary API here (decode to an Access.View over a packed
# buffer) was superseded by the object API and has been removed.

def type_valid(schema: T.Schema) -> Bool: Model.type_valid(schema)
def valid(schema: T.Schema, value: T.Value) -> Bool: Model.valid(schema, value)
def serialize(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>: Model.serialize(schema, value)
def deserialize(schema: T.Schema, bytes: +List<U32>) -> Maybe<&2, T.Value>: Model.deserialize(schema, bytes)
def hash_tree_root(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>: Model.hash_tree_root(schema, value)
def boolean_type() -> T.Schema: Model.boolean_type()
def unsigned_type(w: Primitive.Width) -> T.Schema: Model.unsigned_type(w)
def byte_vector_type(n: Nat) -> T.Schema: Model.byte_vector_type(n)
def byte_list_type(n: Nat) -> T.Schema: Model.byte_list_type(n)
def bit_vector_type(n: Nat) -> T.Schema: Model.bit_vector_type(n)
def bit_list_type(n: Nat) -> T.Schema: Model.bit_list_type(n)
def vector_type(e: T.Schema, n: Nat) -> T.Schema: Model.vector_type(e, n)
def list_type(e: T.Schema, n: Nat) -> T.Schema: Model.list_type(e, n)
def container_type(names: +List<String>, fields: T.Schema) -> T.Schema: Model.container_type(names, fields)
def union_type(fields: T.Schema) -> T.Schema: Model.union_type(fields)
def null_type() -> T.Schema: Model.null_type()
def progressive_list_type(e: T.Schema) -> T.Schema: Model.progressive_list_type(e)
def progressive_bits_type() -> T.Schema: Model.progressive_bits_type()
def progressive_container_type(names: +List<String>, fields: T.Schema, active: +List<Bool>) -> T.Schema: Model.progressive_container_type(names, fields, active)
def compatible_union_type(selectors: +List<U32>, options: T.Schema) -> T.Schema: Model.compatible_union_type(selectors, options)
def chain(h: T.Schema, t: T.Schema) -> T.Schema: Model.chain(h, t)
def end() -> T.Schema: Model.end()
def boolean_value(v: Bool) -> T.Value: Model.boolean_value(v)
def unsigned_value(v: Primitive.UInt) -> T.Value: Model.unsigned_value(v)
def bytes_value(v: +List<U32>) -> T.Value: Model.bytes_value(v)
def bits_value(v: +List<Bool>) -> T.Value: Model.bits_value(v)
def sequence_value(v: T.Value) -> T.Value: Model.sequence_value(v)
def items(h: T.Value, t: T.Value) -> T.Value: Model.items(h, t)
def empty_items() -> T.Value: Model.empty_items()
def selected_value(s: U32, v: T.Value) -> T.Value: Model.selected_value(s, v)
def null_value() -> T.Value: Model.null_value()
