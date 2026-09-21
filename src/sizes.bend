import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P

# Fixed sizes in machine words instead of unary `Nat`.
#
# `src/schema.bend` computes the same sizes as `Nat`, which is what the frozen
# specifications quantify over. The runtime cannot afford that: a list limit
# such as 2^40 is a unary numeral, and multiplying it out would allocate a
# numeral per byte. Every size here is a `U32`, every comparison is a machine
# comparison, and `None` means "not fixed size" exactly as in the spec-level
# function. `proofs/` relates the two.
def width_bytes(w: P.Width) -> U32:
  match w:
    case P.U8{}: 1
    case P.U16{}: 2
    case P.U32Width{}: 4
    case P.U64{}: 8
    case P.U128{}: 16
    case P.U256{}: 32

def add_size(a: Maybe<&2, U32>, b: Maybe<&2, U32>) -> Maybe<&2, U32>:
  match a b:
    case Some{x} Some{y}: Some{(x + y : U32)}
    case _ _: None{}

def scale_size(+n: U32, a: Maybe<&2, U32>) -> Maybe<&2, U32>:
  match a:
    case None{}: None{}
    case Some{x}: Some{(n * x : U32)}

# Bit vectors occupy ceil(length / 8) bytes.
def bit_bytes(+n: U32) -> U32: U32.shrn((n + 7 : U32), 3n)

def fixed_size(schema: T.Schema) -> Maybe<&2, U32>:
  match schema:
    case T.Boolean{}: Some{1}
    case T.Unsigned{w}: Some{width_bytes(w)}
    case T.ByteVector{n}: Some{U32.from_nat(n)}
    case T.ByteList{limit}: None{}
    case T.BitVector{n}: Some{bit_bytes(U32.from_nat(n))}
    case T.BitList{limit}: None{}
    case T.Vector{e, n}: scale_size(U32.from_nat(n), fixed_size(e))
    case T.ListOf{e, limit}: None{}
    case T.Container{names, fields}: fixed_size(fields)
    case T.Union{options}: None{}
    case T.Null{}: Some{0}
    case T.Chain{h, t}: add_size(fixed_size(h), fixed_size(t))
    case T.End{}: Some{0}
    case T.Repeat{e}: None{}
    case T.Named{name, s}: fixed_size(s)
    case T.ProgressiveList{e}: None{}
    case T.ProgressiveBits{}: None{}
    case T.ProgressiveContainer{names, fields, active}: None{}
    case T.CompatibleUnion{selectors, options}: None{}

def present(a: Maybe<&2, U32>) -> Bool:
  match a:
    case None{}: False{}
    case Some{x}: True{}

def is_fixed(schema: T.Schema) -> Bool: present(fixed_size(schema))

# Bytes a field contributes to the fixed part of its container: its own size
# when it is fixed, otherwise the four-byte offset.
def or_offset(a: Maybe<&2, U32>) -> U32:
  match a:
    case None{}: 4
    case Some{x}: x

def header_size(schema: T.Schema) -> U32: or_offset(fixed_size(schema))

def fixed_part(schema: T.Schema) -> U32:
  match schema:
    case T.Chain{h, t}: (header_size(h) + fixed_part(t) : U32)
    case T.End{}: 0
    case _: header_size(schema)

# Number of fields in a chain.
def field_count(schema: T.Schema) -> U32:
  match schema:
    case T.Chain{h, t}: (1 + field_count(t) : U32)
    case _: 0
