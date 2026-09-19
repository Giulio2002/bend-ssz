import Base
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./schema.bend as Schema
import ./codec.bend as Codec
import ./decode.bend as Decode
import ./root.bend as Root

def type_valid(schema: T.Schema) -> Bool: Schema.valid(schema)
def valid(schema: T.Schema, value: T.Value) -> Bool: Codec.valid(schema, value)
def serialize(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>: Codec.serialize(schema, value)
def deserialize(schema: T.Schema, bytes: +List<U32>) -> Maybe<&2, T.Value>: Decode.deserialize(schema, bytes)
def hash_tree_root(schema: T.Schema, value: T.Value) -> Maybe<&2, +List<U32>>: Root.hash_tree_root(schema, value)

def boolean_type() -> T.Schema: T.Boolean{}

def unsigned_type(w: Primitive.Width) -> T.Schema: T.Unsigned{w}

def byte_vector_type(n: Nat) -> T.Schema: T.ByteVector{n}

def byte_list_type(n: Nat) -> T.Schema: T.ByteList{n}

def bit_vector_type(n: Nat) -> T.Schema: T.BitVector{n}

def bit_list_type(n: Nat) -> T.Schema: T.BitList{n}

def vector_type(e: T.Schema, n: Nat) -> T.Schema: T.Vector{e, n}

def list_type(e: T.Schema, n: Nat) -> T.Schema: T.ListOf{e, n}

def container_type(names: +List<String>, fields: T.Schema) -> T.Schema: T.Container{names, fields}

def union_type(fields: T.Schema) -> T.Schema: T.Union{fields}

def null_type() -> T.Schema: T.Null{}

def progressive_list_type(e: T.Schema) -> T.Schema: T.ProgressiveList{e}

def progressive_bits_type() -> T.Schema: T.ProgressiveBits{}

def progressive_container_type(names: +List<String>, fields: T.Schema, active: +List<Bool>) -> T.Schema: T.ProgressiveContainer{names, fields, active}

def compatible_union_type(selectors: +List<U32>, options: T.Schema) -> T.Schema: T.CompatibleUnion{selectors, options}

def chain(h: T.Schema, t: T.Schema) -> T.Schema: T.Chain{h, t}

def end() -> T.Schema: T.End{}

def boolean_value(v: Bool) -> T.Value: T.BooleanValue{v}

def unsigned_value(v: Primitive.UInt) -> T.Value: T.UnsignedValue{v}

def bytes_value(v: +List<U32>) -> T.Value: T.BytesValue{v}

def bits_value(v: +List<Bool>) -> T.Value: T.BitsValue{v}

def sequence_value(v: T.Value) -> T.Value: T.Sequence{v}

def items(h: T.Value, t: T.Value) -> T.Value: T.Items{h, t}

def empty_items() -> T.Value: T.EmptyItems{}

def selected_value(s: U32, v: T.Value) -> T.Value: T.Selected{s, v}

def null_value() -> T.Value: T.NullValue{}
