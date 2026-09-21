import Base
import ../types/primitive.bend as Primitive
import ../types/schema.bend as T
import ./schema.bend as Schema
import ./codec.bend as Codec
import ./decode.bend as Decode
import ./root.bend as Root
import ./buffer.bend as Buf
import ./cschema.bend as CS
import ./api.bend as Compact
import ./access.bend as Access
import ./digest.bend as Digest

# ---------------------------------------------------------------------------
# Primary API: packed buffers and compact values.
#
# Input is a `Buf.Buf`, packed bytes four to a word, owned by the caller: every
# operation takes it and hands it back with its result, and nothing is copied
# out of it. A decoded value is an `Access.View` - a window of that buffer that
# validated against its schema - and it stays meaningful for as long as the
# caller keeps the buffer. Schemas are compact `CS.CS` trees; the 109 Fulu
# names are generated in types/fulu_cschema.bend (see also types/fulu.bend).
#
#   decode(schema, size, buf)       validate [0, size); Some(view) or None
#   decode_in(schema, off, len, buf) the same for any window
#   encode(view, buf)               the value's encoding as a fresh packed Buf
#   root(schema, view, buf)         hash_tree_root, streamed from the buffer
#   field / field_schema / count / elem / elem_schema / uint64 / boolean / byte
#                                   access without copying
#
# `None` is semantic rejection. Crashes, memory exhaustion and timeouts are not.

def view_if(ok: Bool, +off: U32, +len: U32) -> Maybe<&2, Access.View>:
  match ok:
    case True{}: Some{Access.View{off, len}}
    case False{}: None{}

def decoded(+off: U32, +len: U32, pair: Buf.Buf & Bool) -> Buf.Buf & Maybe<&2, Access.View>:
  (b, ok) = pair
  (b, view_if(ok, off, len))

def decode_in(+schema: CS.CS, +off: U32, +len: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>:
  decoded(off, len, Compact.validate_in(schema, off, len, buf))

def decode(+schema: CS.CS, +size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>:
  decode_in(schema, 0, size, buf)

def encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: Access.encode(v, buf)

# Root of a decoded view (it must have validated under `schema`). The root's
# intermediate digests and zero-subtree table live in the buffer's scratch.
def root(+schema: CS.CS, +v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest:
  Compact.root_in(schema, Access.view_off(v), Access.view_len(v), buf)

def field(+schema: CS.CS, +i: U32, +v: Access.View, buf: Buf.Buf) -> Buf.Buf & Access.View:
  Access.field(schema, i, v, buf)
def field_schema(+schema: CS.CS, +i: U32) -> CS.CS: Access.field_schema(schema, i)
def count(+schema: CS.CS, +v: Access.View, buf: Buf.Buf) -> Buf.Buf & U32: Access.count(schema, v, buf)
def elem(+schema: CS.CS, +i: U32, +v: Access.View, buf: Buf.Buf) -> Buf.Buf & Access.View:
  Access.elem(schema, i, v, buf)
def elem_schema(schema: CS.CS) -> CS.CS: Access.elem_schema(schema)
def uint64(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & (U32 & U32): Access.uint64(v, buf)
def boolean(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & U32: Access.boolean(v, buf)
def byte(+v: Access.View, +j: U32, buf: Buf.Buf) -> Buf.Buf & U32: Access.byte(v, j, buf)

# ---------------------------------------------------------------------------
# List-based model API. The frozen END_TO_END laws are stated over these; they
# remain until those laws are carried over to the compact API above.

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
