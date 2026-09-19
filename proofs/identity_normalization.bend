import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P
import ../spec/primitives.bend as SP
import ../spec/compatibility.bend as S
import ./metadata_reflection.bend as M
import ./bit_vector_inverse.bend as N
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

# Proof-only normalization of the normative ByteVector/Vector[uint8] and
# ByteList/List[uint8] aliases. Runtime types and limits are not changed.
def normalize(schema: T.Schema) -> T.Schema:
  match schema:
    case T.Boolean{}: T.Boolean{}
    case T.Unsigned{x0}: T.Unsigned{x0}
    case T.ByteVector{x0}: T.Vector{T.Unsigned{P.U8{}}, x0}
    case T.ByteList{x0}: T.ListOf{T.Unsigned{P.U8{}}, x0}
    case T.BitVector{x0}: T.BitVector{x0}
    case T.BitList{x0}: T.BitList{x0}
    case T.Vector{x0, x1}: T.Vector{normalize(x0), x1}
    case T.ListOf{x0, x1}: T.ListOf{normalize(x0), x1}
    case T.Container{x0, x1}: T.Container{x0, normalize(x1)}
    case T.Union{x0}: T.Union{normalize(x0)}
    case T.Null{}: T.Null{}
    case T.Chain{x0, x1}: T.Chain{normalize(x0), normalize(x1)}
    case T.End{}: T.End{}
    case T.Repeat{x0}: T.Repeat{normalize(x0)}
    case T.Named{x0, x1}: T.Named{x0, normalize(x1)}
    case T.ProgressiveList{x0}: T.ProgressiveList{normalize(x0)}
    case T.ProgressiveBits{}: T.ProgressiveBits{}
    case T.ProgressiveContainer{x0, x1, x2}: T.ProgressiveContainer{x0, normalize(x1), x2}
    case T.CompatibleUnion{x0, x1}: T.CompatibleUnion{x0, normalize(x1)}

law width_sound:
  for +a: P.Width
  for +b: P.Width
  for same: {Nat.is_eq(SP.byte_width(a), SP.byte_width(b)) == True{} : Bool}
  {a == b : P.Width}
def width_sound(a, b, same):
  match a b:
    case P.U8{} P.U8{}: {==}
    case P.U8{} P.U16{}: Empty.absurd({P.U8{} == P.U16{} : P.Width}, W.false_true(same))
    case P.U8{} P.U32Width{}: Empty.absurd({P.U8{} == P.U32Width{} : P.Width}, W.false_true(same))
    case P.U8{} P.U64{}: Empty.absurd({P.U8{} == P.U64{} : P.Width}, W.false_true(same))
    case P.U8{} P.U128{}: Empty.absurd({P.U8{} == P.U128{} : P.Width}, W.false_true(same))
    case P.U8{} P.U256{}: Empty.absurd({P.U8{} == P.U256{} : P.Width}, W.false_true(same))
    case P.U16{} P.U8{}: Empty.absurd({P.U16{} == P.U8{} : P.Width}, W.false_true(same))
    case P.U16{} P.U16{}: {==}
    case P.U16{} P.U32Width{}: Empty.absurd({P.U16{} == P.U32Width{} : P.Width}, W.false_true(same))
    case P.U16{} P.U64{}: Empty.absurd({P.U16{} == P.U64{} : P.Width}, W.false_true(same))
    case P.U16{} P.U128{}: Empty.absurd({P.U16{} == P.U128{} : P.Width}, W.false_true(same))
    case P.U16{} P.U256{}: Empty.absurd({P.U16{} == P.U256{} : P.Width}, W.false_true(same))
    case P.U32Width{} P.U8{}: Empty.absurd({P.U32Width{} == P.U8{} : P.Width}, W.false_true(same))
    case P.U32Width{} P.U16{}: Empty.absurd({P.U32Width{} == P.U16{} : P.Width}, W.false_true(same))
    case P.U32Width{} P.U32Width{}: {==}
    case P.U32Width{} P.U64{}: Empty.absurd({P.U32Width{} == P.U64{} : P.Width}, W.false_true(same))
    case P.U32Width{} P.U128{}: Empty.absurd({P.U32Width{} == P.U128{} : P.Width}, W.false_true(same))
    case P.U32Width{} P.U256{}: Empty.absurd({P.U32Width{} == P.U256{} : P.Width}, W.false_true(same))
    case P.U64{} P.U8{}: Empty.absurd({P.U64{} == P.U8{} : P.Width}, W.false_true(same))
    case P.U64{} P.U16{}: Empty.absurd({P.U64{} == P.U16{} : P.Width}, W.false_true(same))
    case P.U64{} P.U32Width{}: Empty.absurd({P.U64{} == P.U32Width{} : P.Width}, W.false_true(same))
    case P.U64{} P.U64{}: {==}
    case P.U64{} P.U128{}: Empty.absurd({P.U64{} == P.U128{} : P.Width}, W.false_true(same))
    case P.U64{} P.U256{}: Empty.absurd({P.U64{} == P.U256{} : P.Width}, W.false_true(same))
    case P.U128{} P.U8{}: Empty.absurd({P.U128{} == P.U8{} : P.Width}, W.false_true(same))
    case P.U128{} P.U16{}: Empty.absurd({P.U128{} == P.U16{} : P.Width}, W.false_true(same))
    case P.U128{} P.U32Width{}: Empty.absurd({P.U128{} == P.U32Width{} : P.Width}, W.false_true(same))
    case P.U128{} P.U64{}: Empty.absurd({P.U128{} == P.U64{} : P.Width}, W.false_true(same))
    case P.U128{} P.U128{}: {==}
    case P.U128{} P.U256{}: Empty.absurd({P.U128{} == P.U256{} : P.Width}, W.false_true(same))
    case P.U256{} P.U8{}: Empty.absurd({P.U256{} == P.U8{} : P.Width}, W.false_true(same))
    case P.U256{} P.U16{}: Empty.absurd({P.U256{} == P.U16{} : P.Width}, W.false_true(same))
    case P.U256{} P.U32Width{}: Empty.absurd({P.U256{} == P.U32Width{} : P.Width}, W.false_true(same))
    case P.U256{} P.U64{}: Empty.absurd({P.U256{} == P.U64{} : P.Width}, W.false_true(same))
    case P.U256{} P.U128{}: Empty.absurd({P.U256{} == P.U128{} : P.Width}, W.false_true(same))
    case P.U256{} P.U256{}: {==}

law reflect:
  for +a: T.Schema
  for +b: T.Schema
  for +same: {S.identical(a, b) == True{} : Bool}
  {normalize(a) == normalize(b) : T.Schema}
def reflect(a, b, same):
  match a b:
    case T.Boolean{} T.Boolean{}: {==}
    case T.Boolean{} T.Unsigned{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ByteVector{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ByteList{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.BitVector{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.BitList{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Container{b0, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Union{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Null{}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Chain{b0, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.End{}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Repeat{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.Named{b0, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ProgressiveBits{}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Boolean{} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Boolean{}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Boolean{}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Unsigned{b0}: %width_sound(a0, b0, same) : {T.Unsigned{a0} == T.Unsigned{_} : T.Schema}
      {==}
    case T.Unsigned{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ByteList{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.BitVector{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.BitList{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Union{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Null{}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.End{}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Repeat{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Unsigned{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Unsigned{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Boolean{}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ByteVector{b0}: %N.nat_equal_sound(a0, b0, same) : {T.Vector{T.Unsigned{P.U8{}}, a0} == T.Vector{T.Unsigned{P.U8{}}, _} : T.Schema}
      {==}
    case T.ByteVector{a0} T.ByteList{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.BitVector{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.BitList{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Unsigned{bc0}, b1}: %Equal.cong(P.Width, T.Schema, w => T.Unsigned{w}, P.U8{}, bc0, Equal.sym(P.Width, bc0, P.U8{}, width_sound(bc0, P.U8{}, V.and_right(Nat.is_eq(a0, b1), Nat.is_eq(SP.byte_width(bc0), 1n), same)))) : {T.Vector{T.Unsigned{P.U8{}}, a0} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a0, b1, V.and_left(Nat.is_eq(a0, b1), Nat.is_eq(SP.byte_width(bc0), 1n), same)) : {T.Vector{T.Unsigned{P.U8{}}, a0} == T.Vector{T.Unsigned{P.U8{}}, _} : T.Schema}
      {==}
    case T.ByteVector{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Union{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Null{}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.End{}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Repeat{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ByteVector{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ByteVector{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Boolean{}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ByteList{b0}: %N.nat_equal_sound(a0, b0, same) : {T.ListOf{T.Unsigned{P.U8{}}, a0} == T.ListOf{T.Unsigned{P.U8{}}, _} : T.Schema}
      {==}
    case T.ByteList{a0} T.BitVector{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.BitList{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Unsigned{bc0}, b1}: %Equal.cong(P.Width, T.Schema, w => T.Unsigned{w}, P.U8{}, bc0, Equal.sym(P.Width, bc0, P.U8{}, width_sound(bc0, P.U8{}, V.and_right(Nat.is_eq(a0, b1), Nat.is_eq(SP.byte_width(bc0), 1n), same)))) : {T.ListOf{T.Unsigned{P.U8{}}, a0} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a0, b1, V.and_left(Nat.is_eq(a0, b1), Nat.is_eq(SP.byte_width(bc0), 1n), same)) : {T.ListOf{T.Unsigned{P.U8{}}, a0} == T.ListOf{T.Unsigned{P.U8{}}, _} : T.Schema}
      {==}
    case T.ByteList{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Union{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Null{}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.End{}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Repeat{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ByteList{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ByteList{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Boolean{}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ByteList{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.BitVector{b0}: %N.nat_equal_sound(a0, b0, same) : {T.BitVector{a0} == T.BitVector{_} : T.Schema}
      {==}
    case T.BitVector{a0} T.BitList{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Union{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Null{}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.End{}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Repeat{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.BitVector{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.BitVector{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Boolean{}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ByteList{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.BitVector{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.BitList{b0}: %N.nat_equal_sound(a0, b0, same) : {T.BitList{a0} == T.BitList{_} : T.Schema}
      {==}
    case T.BitList{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Union{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Null{}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.End{}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Repeat{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.BitList{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.BitList{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Boolean{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Boolean{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Boolean{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Boolean{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Boolean{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Boolean{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Boolean{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Boolean{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.End{}, b1}: %reflect(T.Boolean{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Boolean{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Boolean{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Boolean{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Boolean{}), a1} == T.Vector{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Boolean{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ByteVector{b0}: %Equal.cong(P.Width, T.Schema, w => T.Unsigned{w}, ac0, P.U8{}, width_sound(ac0, P.U8{}, V.and_right(Nat.is_eq(a1, b0), Nat.is_eq(SP.byte_width(ac0), 1n), same))) : {T.Vector{T.Unsigned{ac0}, a1} == T.Vector{_, b0} : T.Schema}
      %N.nat_equal_sound(a1, b0, V.and_left(Nat.is_eq(a1, b0), Nat.is_eq(SP.byte_width(ac0), 1n), same)) : {T.Vector{T.Unsigned{ac0}, a1} == T.Vector{T.Unsigned{ac0}, _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Unsigned{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Unsigned{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.Unsigned{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.End{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.End{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Unsigned{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Unsigned{ac0}), a1} == T.Vector{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Unsigned{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.ByteVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.ByteVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.ByteVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.End{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.End{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.ByteVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteVector{ac0}), a1} == T.Vector{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteVector{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.ByteList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.ByteList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.ByteList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.ByteList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.ByteList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.ByteList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.ByteList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.ByteList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.ByteList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.End{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.End{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.ByteList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.ByteList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.ByteList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ByteList{ac0}), a1} == T.Vector{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.ByteList{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.BitVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.BitVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.BitVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.BitVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.BitVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.BitVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.BitVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.BitVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.BitVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.End{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.End{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.BitVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.BitVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.BitVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.BitVector{ac0}), a1} == T.Vector{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitVector{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.BitList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.BitList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.BitList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.BitList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.BitList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.BitList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.BitList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.BitList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.BitList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.End{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.End{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.BitList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.BitList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.BitList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.BitList{ac0}), a1} == T.Vector{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.BitList{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Vector{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Vector{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: %reflect(T.Vector{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Vector{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Vector{ac0, ac1}), a1} == T.Vector{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Vector{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ListOf{ac0, ac1}), a1} == T.Vector{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.ListOf{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Container{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Container{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: %reflect(T.Container{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Container{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Container{ac0, ac1}), a1} == T.Vector{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Container{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Union{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Union{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Union{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Union{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Union{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Union{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Union{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Union{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.Union{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.End{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.End{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Union{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Union{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Union{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Union{ac0}), a1} == T.Vector{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Union{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Null{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Null{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Null{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Null{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Null{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Null{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Null{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Null{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Null{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Null{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Null{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Null{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.End{}, b1}: %reflect(T.Null{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Null{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Null{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Null{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Null{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Null{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Null{}), a1} == T.Vector{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Null{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Null{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Chain{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Chain{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: %reflect(T.Chain{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Chain{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Chain{ac0, ac1}), a1} == T.Vector{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Chain{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.End{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.End{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.End{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.End{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.End{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.End{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.End{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.End{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.End{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.End{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Null{}, b1}: %reflect(T.End{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.End{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.End{}, b1}: %reflect(T.End{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.End{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.End{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.End{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.End{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.End{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.End{}), a1} == T.Vector{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.End{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.End{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Repeat{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Repeat{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Repeat{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Repeat{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Repeat{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Repeat{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Repeat{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Repeat{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.Repeat{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.End{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.End{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Repeat{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Repeat{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Repeat{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Repeat{ac0}), a1} == T.Vector{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Repeat{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.Named{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: %reflect(T.Named{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: %reflect(T.Named{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.Named{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.Named{ac0, ac1}), a1} == T.Vector{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.Named{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.ProgressiveList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: %reflect(T.ProgressiveList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Null{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: %reflect(T.ProgressiveList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.End{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.End{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.ProgressiveList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveList{ac0}), a1} == T.Vector{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveList{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.ProgressiveBits{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: %reflect(T.ProgressiveBits{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: %reflect(T.ProgressiveBits{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveBits{}), a1} == T.Vector{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveBits{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.Vector{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.Vector{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Vector{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Boolean{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Boolean{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Boolean{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Boolean{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Boolean{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Boolean{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Boolean{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Boolean{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Boolean{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Boolean{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Boolean{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Boolean{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Boolean{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Boolean{}), a1} == T.ListOf{normalize(T.Boolean{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Boolean{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Boolean{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ByteList{b0}: %Equal.cong(P.Width, T.Schema, w => T.Unsigned{w}, ac0, P.U8{}, width_sound(ac0, P.U8{}, V.and_right(Nat.is_eq(a1, b0), Nat.is_eq(SP.byte_width(ac0), 1n), same))) : {T.ListOf{T.Unsigned{ac0}, a1} == T.ListOf{_, b0} : T.Schema}
      %N.nat_equal_sound(a1, b0, V.and_left(Nat.is_eq(a1, b0), Nat.is_eq(SP.byte_width(ac0), 1n), same)) : {T.ListOf{T.Unsigned{ac0}, a1} == T.ListOf{T.Unsigned{ac0}, _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Unsigned{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Unsigned{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Unsigned{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Unsigned{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Unsigned{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Unsigned{ac0}), a1} == T.ListOf{normalize(T.Unsigned{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Unsigned{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.ByteVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.ByteVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.ByteVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.ByteVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.ByteVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteVector{ac0}), a1} == T.ListOf{normalize(T.ByteVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteVector{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.ByteList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.ByteList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.ByteList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.ByteList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.ByteList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.ByteList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.ByteList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.ByteList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.ByteList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.ByteList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.ByteList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.ByteList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ByteList{ac0}), a1} == T.ListOf{normalize(T.ByteList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ByteList{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.BitVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.BitVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.BitVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.BitVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.BitVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.BitVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.BitVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.BitVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.BitVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.BitVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.BitVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.BitVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitVector{ac0}), a1} == T.ListOf{normalize(T.BitVector{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitVector{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.BitList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.BitList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.BitList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.BitList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.BitList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.BitList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.BitList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.BitList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.BitList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.BitList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.BitList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.BitList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.BitList{ac0}), a1} == T.ListOf{normalize(T.BitList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.BitList{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Vector{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Vector{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Vector{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Vector{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Vector{ac0, ac1}), a1} == T.ListOf{normalize(T.Vector{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Vector{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ListOf{ac0, ac1}), a1} == T.ListOf{normalize(T.ListOf{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ListOf{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Container{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Container{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Container{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Container{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Container{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Container{ac0, ac1}), a1} == T.ListOf{normalize(T.Container{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Container{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Union{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Union{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Union{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Union{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Union{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Union{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Union{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Union{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Union{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Union{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Union{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Union{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Union{ac0}), a1} == T.ListOf{normalize(T.Union{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Union{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Union{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Null{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Null{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Null{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Null{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Null{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Null{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Null{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Null{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Null{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Null{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Null{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Null{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Null{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Null{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Null{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Null{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Null{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Null{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Null{}), a1} == T.ListOf{normalize(T.Null{}), _} : T.Schema}
      {==}
    case T.ListOf{T.Null{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Null{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Null{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Chain{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Chain{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Chain{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Chain{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Chain{ac0, ac1}), a1} == T.ListOf{normalize(T.Chain{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Chain{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.End{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.End{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.End{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.End{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.End{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.End{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.End{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.End{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.End{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.End{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.End{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.End{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.End{}, b1}: %reflect(T.End{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.End{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.End{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.End{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.End{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.End{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.End{}), a1} == T.ListOf{normalize(T.End{}), _} : T.Schema}
      {==}
    case T.ListOf{T.End{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.End{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.End{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Repeat{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Repeat{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Repeat{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Repeat{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Repeat{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Repeat{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Repeat{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Repeat{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Repeat{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Repeat{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Repeat{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Repeat{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Repeat{ac0}), a1} == T.ListOf{normalize(T.Repeat{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Repeat{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.Named{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.Named{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: %reflect(T.Named{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.Named{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.Named{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.Named{ac0, ac1}), a1} == T.ListOf{normalize(T.Named{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.Named{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.ProgressiveList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.ProgressiveList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Null{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: %reflect(T.ProgressiveList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.End{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.ProgressiveList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveList{ac0}), a1} == T.ListOf{normalize(T.ProgressiveList{ac0}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveList{ac0}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.ProgressiveBits{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.ProgressiveBits{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: %reflect(T.ProgressiveBits{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.ProgressiveBits{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveBits{}), a1} == T.ListOf{normalize(T.ProgressiveBits{}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveBits{}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), a1} == T.ListOf{normalize(T.ProgressiveContainer{ac0, ac1, ac2}), _} : T.Schema}
      {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: %reflect(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{_, b1} : T.Schema}
      %N.nat_equal_sound(a1, b1, V.and_left(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), same)) : {T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), a1} == T.ListOf{normalize(T.CompatibleUnion{ac0, ac1}), _} : T.Schema}
      {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ListOf{T.CompatibleUnion{ac0, ac1}, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Boolean{}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.BitList{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Container{b0, b1}: %M.names_sound(a0, b0, V.and_left(S.names_equal(a0, b0), S.identical(a1, b1), same)) : {T.Container{a0, normalize(a1)} == T.Container{_, normalize(b1)} : T.Schema}
      %reflect(a1, b1, V.and_right(S.names_equal(a0, b0), S.identical(a1, b1), same)) : {T.Container{a0, normalize(a1)} == T.Container{a0, _} : T.Schema}
      {==}
    case T.Container{a0, a1} T.Union{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Null{}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.End{}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Container{a0, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Container{a0, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Boolean{}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ByteList{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.BitVector{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.BitList{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Union{b0}: %reflect(a0, b0, same) : {T.Union{normalize(a0)} == T.Union{_} : T.Schema}
      {==}
    case T.Union{a0} T.Null{}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.End{}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Repeat{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Union{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Union{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Boolean{}: Empty.absurd({normalize(T.Null{}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Unsigned{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ByteVector{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ByteList{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.BitVector{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.BitList{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Container{b0, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Union{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Null{}: {==}
    case T.Null{} T.Chain{b0, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.End{}: Empty.absurd({normalize(T.Null{}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Repeat{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.Named{b0, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Null{}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ProgressiveBits{}: Empty.absurd({normalize(T.Null{}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Null{} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Null{}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Null{} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Null{}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Boolean{}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.BitList{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Union{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Null{}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Chain{b0, b1}: %reflect(a0, b0, V.and_left(S.identical(a0, b0), S.identical(a1, b1), same)) : {T.Chain{normalize(a0), normalize(a1)} == T.Chain{_, normalize(b1)} : T.Schema}
      %reflect(a1, b1, V.and_right(S.identical(a0, b0), S.identical(a1, b1), same)) : {T.Chain{normalize(a0), normalize(a1)} == T.Chain{normalize(a0), _} : T.Schema}
      {==}
    case T.Chain{a0, a1} T.End{}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Chain{a0, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Chain{a0, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Boolean{}: Empty.absurd({normalize(T.End{}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.End{} T.Unsigned{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.ByteVector{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.ByteList{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.BitVector{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.BitList{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Container{b0, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.Union{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.Null{}: Empty.absurd({normalize(T.End{}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.End{} T.Chain{b0, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.End{}: {==}
    case T.End{} T.Repeat{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.Named{b0, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.End{} T.ProgressiveList{b0}: Empty.absurd({normalize(T.End{}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.End{} T.ProgressiveBits{}: Empty.absurd({normalize(T.End{}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.End{} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.End{}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.End{} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.End{}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Boolean{}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ByteList{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.BitVector{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.BitList{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Union{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Null{}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.End{}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Repeat{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Repeat{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Repeat{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Boolean{}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ByteList{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.BitVector{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.BitList{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Union{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Null{}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.End{}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Repeat{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.Named{b0, b1}: %M.string_sound(a0, b0, V.and_left(String.eq(a0, b0), S.identical(a1, b1), same)) : {T.Named{a0, normalize(a1)} == T.Named{_, normalize(b1)} : T.Schema}
      %reflect(a1, b1, V.and_right(String.eq(a0, b0), S.identical(a1, b1), same)) : {T.Named{a0, normalize(a1)} == T.Named{a0, _} : T.Schema}
      {==}
    case T.Named{a0, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.Named{a0, a1} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.Named{a0, a1}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Boolean{}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Unsigned{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ByteVector{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ByteList{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.BitVector{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.BitList{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Container{b0, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Union{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Null{}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Chain{b0, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.End{}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Repeat{b0}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.Named{b0, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ProgressiveList{b0}: %reflect(a0, b0, same) : {T.ProgressiveList{normalize(a0)} == T.ProgressiveList{_} : T.Schema}
      {==}
    case T.ProgressiveList{a0} T.ProgressiveBits{}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ProgressiveList{a0}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Boolean{}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Unsigned{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ByteVector{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ByteList{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.BitVector{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.BitList{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Container{b0, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Union{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Null{}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Chain{b0, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.End{}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Repeat{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.Named{b0, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.ProgressiveBits{}: {==}
    case T.ProgressiveBits{} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.ProgressiveBits{} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ProgressiveBits{}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Boolean{}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Unsigned{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ByteVector{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ByteList{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.BitVector{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.BitList{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Null{}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Chain{b0, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.End{}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: %M.names_sound(a0, b0, V.and_left(S.names_equal(a0, b0), Bool.and(S.bits_equal(a2, b2), S.identical(a1, b1)), same)) : {T.ProgressiveContainer{a0, normalize(a1), a2} == T.ProgressiveContainer{_, normalize(b1), b2} : T.Schema}
      %reflect(a1, b1, V.and_right(S.bits_equal(a2, b2), S.identical(a1, b1), V.and_right(S.names_equal(a0, b0), Bool.and(S.bits_equal(a2, b2), S.identical(a1, b1)), same))) : {T.ProgressiveContainer{a0, normalize(a1), a2} == T.ProgressiveContainer{a0, _, b2} : T.Schema}
      %M.bits_sound(a2, b2, V.and_left(S.bits_equal(a2, b2), S.identical(a1, b1), V.and_right(S.names_equal(a0, b0), Bool.and(S.bits_equal(a2, b2), S.identical(a1, b1)), same))) : {T.ProgressiveContainer{a0, normalize(a1), a2} == T.ProgressiveContainer{a0, normalize(a1), _} : T.Schema}
      {==}
    case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}: Empty.absurd({normalize(T.ProgressiveContainer{a0, a1, a2}) == normalize(T.CompatibleUnion{b0, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Boolean{}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Boolean{}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Unsigned{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Unsigned{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ByteVector{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ByteVector{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ByteList{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ByteList{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.BitVector{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.BitVector{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.BitList{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.BitList{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Boolean{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Union{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Null{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.End{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Vector{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Boolean{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Boolean{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Unsigned{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.ByteVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.ByteList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.BitVector{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.BitList{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.BitList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Vector{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.ListOf{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Container{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Union{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Union{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Null{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Null{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Chain{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.End{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.End{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Repeat{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.Named{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.ProgressiveList{bc0}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.ProgressiveBits{}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Container{b0, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Container{b0, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Union{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Union{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Null{}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Null{}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Chain{b0, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Chain{b0, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.End{}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.End{}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Repeat{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Repeat{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.Named{b0, b1}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.Named{b0, b1}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ProgressiveList{b0}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ProgressiveList{b0}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ProgressiveBits{}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ProgressiveBits{}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.ProgressiveContainer{b0, b1, b2}: Empty.absurd({normalize(T.CompatibleUnion{a0, a1}) == normalize(T.ProgressiveContainer{b0, b1, b2}) : T.Schema}, W.false_true(same))
    case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: %M.selectors_sound(a0, b0, V.and_left(S.selectors_equal(a0, b0), S.identical(a1, b1), same)) : {T.CompatibleUnion{a0, normalize(a1)} == T.CompatibleUnion{_, normalize(b1)} : T.Schema}
      %reflect(a1, b1, V.and_right(S.selectors_equal(a0, b0), S.identical(a1, b1), same)) : {T.CompatibleUnion{a0, normalize(a1)} == T.CompatibleUnion{a0, _} : T.Schema}
      {==}
