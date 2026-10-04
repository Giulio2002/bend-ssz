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
