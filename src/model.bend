import Base
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./schema.bend as Schema
import ./codec.bend as Codec
import ./decode.bend as Decode
import ./root.bend as Root

# The list-based model API: neutral schemas and values (`T.Schema`,
# `T.Value`) and byte lists. The frozen END_TO_END and ROOT_DOMAIN laws are
# stated over these definitions, so the proof roots import this module rather
# than src/ssz.bend: checking them must not also elaborate the compact runtime
# and the SHA package, which pushed ROOT_DOMAIN over the proof-memory cap.
# src/ssz.bend re-exports every definition here unchanged, next to the compact
# primary API. This is the model, not the primary runtime.


def type_valid(schema: T.Schema) -> Bool: Schema.valid(schema)
def valid(schema: T.Schema, value: T.Value) -> Bool: Codec.valid(schema, value)
def serialize(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>: Codec.serialize(schema, value)
def deserialize(schema: T.Schema, bytes: +List<U32>) -> Maybe<&2, T.Value>: Decode.deserialize(schema, bytes)
def hash_tree_root(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>: Root.hash_tree_root(schema, value)
