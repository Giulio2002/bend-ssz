import Base
import ../types/schema.bend as T
import ../spec/compatibility.bend as S
import ../spec/primitives.bend as P
import ./identity_normalization.bend as N
import ./identity_equivalence.bend as E
import ./identity_logic.bend as L
import ./identity_unsigned.bend as U
import ../types/primitive.bend as Width

law decision:
  for +a: T.Schema
  for +b: T.Schema
  {S.identical(a, b) == S.identical(N.normalize(a), N.normalize(b)) : Bool}
def decision(a, b):
  match a b:
    case T.Boolean{} T.Boolean{}: {==}
    case T.Boolean{} T.Unsigned{b0}: {==}
    case T.Boolean{} T.ByteVector{b0}: {==}
    case T.Boolean{} T.ByteList{b0}: {==}
    case T.Boolean{} T.BitVector{b0}: {==}
    case T.Boolean{} T.BitList{b0}: {==}
    case T.Boolean{} T.Vector{T.Boolean{}, b1}: {==}
    case T.Boolean{} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.Null{}, b1}: {==}
    case T.Boolean{} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.Vector{T.End{}, b1}: {==}
    case T.Boolean{} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Boolean{} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Boolean{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Boolean{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Null{}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.ListOf{T.End{}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Boolean{} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Boolean{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Boolean{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Boolean{} T.Container{b0, b1}: {==}
    case T.Boolean{} T.Union{b0}: {==}
    case T.Boolean{} T.Null{}: {==}
    case T.Boolean{} T.Chain{b0, b1}: {==}
    case T.Boolean{} T.End{}: {==}
    case T.Boolean{} T.Repeat{b0}: {==}
    case T.Boolean{} T.Named{b0, b1}: {==}
    case T.Boolean{} T.ProgressiveList{b0}: {==}
    case T.Boolean{} T.ProgressiveBits{}: {==}
    case T.Boolean{} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Boolean{} T.CompatibleUnion{b0, b1}: {==}
    case T.Unsigned{a0} T.Boolean{}: {==}
    case T.Unsigned{a0} T.Unsigned{b0}: {==}
    case T.Unsigned{a0} T.ByteVector{b0}: {==}
    case T.Unsigned{a0} T.ByteList{b0}: {==}
    case T.Unsigned{a0} T.BitVector{b0}: {==}
    case T.Unsigned{a0} T.BitList{b0}: {==}
    case T.Unsigned{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Null{}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.End{}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Unsigned{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.End{}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Unsigned{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Unsigned{a0} T.Container{b0, b1}: {==}
    case T.Unsigned{a0} T.Union{b0}: {==}
    case T.Unsigned{a0} T.Null{}: {==}
    case T.Unsigned{a0} T.Chain{b0, b1}: {==}
    case T.Unsigned{a0} T.End{}: {==}
    case T.Unsigned{a0} T.Repeat{b0}: {==}
    case T.Unsigned{a0} T.Named{b0, b1}: {==}
    case T.Unsigned{a0} T.ProgressiveList{b0}: {==}
    case T.Unsigned{a0} T.ProgressiveBits{}: {==}
    case T.Unsigned{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Unsigned{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.ByteVector{a0} T.Boolean{}: {==}
    case T.ByteVector{a0} T.Unsigned{b0}: {==}
    case T.ByteVector{a0} T.ByteVector{b0}: L.and_right_true(Nat.is_eq(a0, b0))
    case T.ByteVector{a0} T.ByteList{b0}: {==}
    case T.ByteVector{a0} T.BitVector{b0}: {==}
    case T.ByteVector{a0} T.BitList{b0}: {==}
    case T.ByteVector{a0} T.Vector{T.Boolean{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a0, b1), Nat.is_eq(a0, b1), Nat.is_eq(P.byte_width(bc0), 1n), Nat.is_eq(1n, P.byte_width(bc0)), {==}, L.natural_symmetry(P.byte_width(bc0), 1n))
    case T.ByteVector{a0} T.Vector{T.ByteVector{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.ByteList{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.BitVector{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.BitList{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: U.false_conjunction(Nat.is_eq(a0, b1), S.identical(T.Unsigned{Width.U8{}}, T.Vector{N.normalize(bc0), bc1}), U.Vector_right(N.normalize(bc0), bc1, Width.U8{}))
    case T.ByteVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: U.false_conjunction(Nat.is_eq(a0, b1), S.identical(T.Unsigned{Width.U8{}}, T.ListOf{N.normalize(bc0), bc1}), U.ListOf_right(N.normalize(bc0), bc1, Width.U8{}))
    case T.ByteVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Union{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Null{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.End{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Repeat{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.ProgressiveBits{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteVector{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.End{}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ByteVector{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.Container{b0, b1}: {==}
    case T.ByteVector{a0} T.Union{b0}: {==}
    case T.ByteVector{a0} T.Null{}: {==}
    case T.ByteVector{a0} T.Chain{b0, b1}: {==}
    case T.ByteVector{a0} T.End{}: {==}
    case T.ByteVector{a0} T.Repeat{b0}: {==}
    case T.ByteVector{a0} T.Named{b0, b1}: {==}
    case T.ByteVector{a0} T.ProgressiveList{b0}: {==}
    case T.ByteVector{a0} T.ProgressiveBits{}: {==}
    case T.ByteVector{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ByteVector{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.ByteList{a0} T.Boolean{}: {==}
    case T.ByteList{a0} T.Unsigned{b0}: {==}
    case T.ByteList{a0} T.ByteVector{b0}: {==}
    case T.ByteList{a0} T.ByteList{b0}: L.and_right_true(Nat.is_eq(a0, b0))
    case T.ByteList{a0} T.BitVector{b0}: {==}
    case T.ByteList{a0} T.BitList{b0}: {==}
    case T.ByteList{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Null{}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.End{}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ByteList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Boolean{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a0, b1), Nat.is_eq(a0, b1), Nat.is_eq(P.byte_width(bc0), 1n), Nat.is_eq(1n, P.byte_width(bc0)), {==}, L.natural_symmetry(P.byte_width(bc0), 1n))
    case T.ByteList{a0} T.ListOf{T.ByteVector{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.ByteList{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.BitVector{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.BitList{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: U.false_conjunction(Nat.is_eq(a0, b1), S.identical(T.Unsigned{Width.U8{}}, T.Vector{N.normalize(bc0), bc1}), U.Vector_right(N.normalize(bc0), bc1, Width.U8{}))
    case T.ByteList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: U.false_conjunction(Nat.is_eq(a0, b1), S.identical(T.Unsigned{Width.U8{}}, T.ListOf{N.normalize(bc0), bc1}), U.ListOf_right(N.normalize(bc0), bc1, Width.U8{}))
    case T.ByteList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Union{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Null{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.End{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Repeat{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.ProgressiveBits{}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: L.and_right_false(Nat.is_eq(a0, b1))
    case T.ByteList{a0} T.Container{b0, b1}: {==}
    case T.ByteList{a0} T.Union{b0}: {==}
    case T.ByteList{a0} T.Null{}: {==}
    case T.ByteList{a0} T.Chain{b0, b1}: {==}
    case T.ByteList{a0} T.End{}: {==}
    case T.ByteList{a0} T.Repeat{b0}: {==}
    case T.ByteList{a0} T.Named{b0, b1}: {==}
    case T.ByteList{a0} T.ProgressiveList{b0}: {==}
    case T.ByteList{a0} T.ProgressiveBits{}: {==}
    case T.ByteList{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ByteList{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.BitVector{a0} T.Boolean{}: {==}
    case T.BitVector{a0} T.Unsigned{b0}: {==}
    case T.BitVector{a0} T.ByteVector{b0}: {==}
    case T.BitVector{a0} T.ByteList{b0}: {==}
    case T.BitVector{a0} T.BitVector{b0}: {==}
    case T.BitVector{a0} T.BitList{b0}: {==}
    case T.BitVector{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Null{}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.End{}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.BitVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.End{}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.BitVector{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.BitVector{a0} T.Container{b0, b1}: {==}
    case T.BitVector{a0} T.Union{b0}: {==}
    case T.BitVector{a0} T.Null{}: {==}
    case T.BitVector{a0} T.Chain{b0, b1}: {==}
    case T.BitVector{a0} T.End{}: {==}
    case T.BitVector{a0} T.Repeat{b0}: {==}
    case T.BitVector{a0} T.Named{b0, b1}: {==}
    case T.BitVector{a0} T.ProgressiveList{b0}: {==}
    case T.BitVector{a0} T.ProgressiveBits{}: {==}
    case T.BitVector{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.BitVector{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.BitList{a0} T.Boolean{}: {==}
    case T.BitList{a0} T.Unsigned{b0}: {==}
    case T.BitList{a0} T.ByteVector{b0}: {==}
    case T.BitList{a0} T.ByteList{b0}: {==}
    case T.BitList{a0} T.BitVector{b0}: {==}
    case T.BitList{a0} T.BitList{b0}: {==}
    case T.BitList{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Null{}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.Vector{T.End{}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.BitList{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.BitList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.BitList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.End{}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.BitList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.BitList{a0} T.Container{b0, b1}: {==}
    case T.BitList{a0} T.Union{b0}: {==}
    case T.BitList{a0} T.Null{}: {==}
    case T.BitList{a0} T.Chain{b0, b1}: {==}
    case T.BitList{a0} T.End{}: {==}
    case T.BitList{a0} T.Repeat{b0}: {==}
    case T.BitList{a0} T.Named{b0, b1}: {==}
    case T.BitList{a0} T.ProgressiveList{b0}: {==}
    case T.BitList{a0} T.ProgressiveBits{}: {==}
    case T.BitList{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.BitList{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.Boolean{}: {==}
    case T.Vector{T.Boolean{}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Boolean{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Boolean{})), {==}, decision(T.Boolean{}, T.Boolean{}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Boolean{}, T.Unsigned{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Boolean{}, T.ByteVector{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Boolean{}, T.ByteList{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Boolean{}, T.BitVector{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.BitList{bc0})), {==}, decision(T.Boolean{}, T.BitList{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Boolean{}, T.Vector{bc0, bc1}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Boolean{}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Boolean{}, T.Container{bc0, bc1}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Union{bc0})), {==}, decision(T.Boolean{}, T.Union{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Null{})), {==}, decision(T.Boolean{}, T.Null{}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Boolean{}, T.Chain{bc0, bc1}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.End{})), {==}, decision(T.Boolean{}, T.End{}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Boolean{}, T.Repeat{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Boolean{}, T.Named{bc0, bc1}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Boolean{}, T.ProgressiveList{bc0}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Boolean{}, T.ProgressiveBits{}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Boolean{}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.Union{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.Null{}: {==}
    case T.Vector{T.Boolean{}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.End{}: {==}
    case T.Vector{T.Boolean{}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Boolean{}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Boolean{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.Unsigned{ac0}, T.Boolean{}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Unsigned{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Unsigned{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Unsigned{ac0}, T.ByteList{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Unsigned{ac0}, T.BitVector{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.Unsigned{ac0}, T.BitList{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Union{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.Unsigned{ac0}, T.Union{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Null{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Null{})), {==}, decision(T.Unsigned{ac0}, T.Null{}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.End{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.End{})), {==}, decision(T.Unsigned{ac0}, T.End{}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Unsigned{ac0}, T.Repeat{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Unsigned{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Unsigned{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.End{}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.ByteVector{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Boolean{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.ByteVector{ac0}, T.Boolean{}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ByteVector{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ByteVector{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ByteVector{ac0}, T.ByteList{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ByteVector{ac0}, T.BitVector{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.ByteVector{ac0}, T.BitList{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Union{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.ByteVector{ac0}, T.Union{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Null{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Null{})), {==}, decision(T.ByteVector{ac0}, T.Null{}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.End{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.End{})), {==}, decision(T.ByteVector{ac0}, T.End{}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ByteVector{ac0}, T.Repeat{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ByteVector{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ByteVector{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.End{}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.ByteList{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Boolean{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.ByteList{ac0}, T.Boolean{}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ByteList{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ByteList{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ByteList{ac0}, T.ByteList{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ByteList{ac0}, T.BitVector{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.ByteList{ac0}, T.BitList{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Union{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.ByteList{ac0}, T.Union{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Null{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Null{})), {==}, decision(T.ByteList{ac0}, T.Null{}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.End{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.End{})), {==}, decision(T.ByteList{ac0}, T.End{}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ByteList{ac0}, T.Repeat{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ByteList{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ByteList{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.End{}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.BitVector{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Boolean{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.BitVector{ac0}, T.Boolean{}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.BitVector{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.BitVector{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.BitVector{ac0}, T.ByteList{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.BitVector{ac0}, T.BitVector{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.BitVector{ac0}, T.BitList{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Union{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.BitVector{ac0}, T.Union{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Null{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Null{})), {==}, decision(T.BitVector{ac0}, T.Null{}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.End{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.End{})), {==}, decision(T.BitVector{ac0}, T.End{}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.BitVector{ac0}, T.Repeat{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.BitVector{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.BitVector{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.End{}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.BitList{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Boolean{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.BitList{ac0}, T.Boolean{}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.BitList{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.BitList{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.BitList{ac0}, T.ByteList{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.BitList{ac0}, T.BitVector{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.BitList{ac0}, T.BitList{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Union{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.BitList{ac0}, T.Union{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Null{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Null{})), {==}, decision(T.BitList{ac0}, T.Null{}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.End{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.End{})), {==}, decision(T.BitList{ac0}, T.End{}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.BitList{ac0}, T.Repeat{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.BitList{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.BitList{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.End{}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: U.false_conjunction(Nat.is_eq(a1, b0), S.identical(T.Vector{N.normalize(ac0), ac1}, T.Unsigned{Width.U8{}}), U.Vector_left(N.normalize(ac0), ac1, Width.U8{}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Vector{ac0, ac1}, T.Boolean{}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.Unsigned{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.ByteVector{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.ByteList{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.BitVector{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.BitList{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Container{bc0, bc1}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.Union{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Vector{ac0, ac1}, T.Null{}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Vector{ac0, ac1}, T.End{}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.Repeat{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Named{bc0, bc1}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Vector{ac0, ac1}, T.ProgressiveBits{}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Null{}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.End{}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: U.false_conjunction(Nat.is_eq(a1, b0), S.identical(T.ListOf{N.normalize(ac0), ac1}, T.Unsigned{Width.U8{}}), U.ListOf_left(N.normalize(ac0), ac1, Width.U8{}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.ListOf{ac0, ac1}, T.Boolean{}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.Unsigned{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.ByteVector{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.ByteList{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.BitVector{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.BitList{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.Union{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.ListOf{ac0, ac1}, T.Null{}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.End{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.ListOf{ac0, ac1}, T.End{}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.Repeat{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ListOf{ac0, ac1}, T.ProgressiveBits{}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Null{}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.End{}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Container{ac0, ac1}, T.Boolean{}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Container{ac0, ac1}, T.Unsigned{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Container{ac0, ac1}, T.ByteVector{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Container{ac0, ac1}, T.ByteList{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Container{ac0, ac1}, T.BitVector{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Container{ac0, ac1}, T.BitList{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Container{bc0, bc1}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Container{ac0, ac1}, T.Union{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Container{ac0, ac1}, T.Null{}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Container{ac0, ac1}, T.End{}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Container{ac0, ac1}, T.Repeat{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Named{bc0, bc1}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Container{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Container{ac0, ac1}, T.ProgressiveBits{}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Null{}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.End{}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Union{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Boolean{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.Union{ac0}, T.Boolean{}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Union{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Union{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Union{ac0}, T.ByteList{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Union{ac0}, T.BitVector{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.Union{ac0}, T.BitList{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Union{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Union{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.Union{ac0}, T.Union{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Null{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Null{})), {==}, decision(T.Union{ac0}, T.Null{}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.End{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.End{})), {==}, decision(T.Union{ac0}, T.End{}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Union{ac0}, T.Repeat{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Union{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Union{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.End{}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Null{}, a1} T.Boolean{}: {==}
    case T.Vector{T.Null{}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Null{}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Null{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Null{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Null{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), S.identical(N.normalize(T.Null{}), N.normalize(T.Boolean{})), {==}, decision(T.Null{}, T.Boolean{}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Null{}, T.Unsigned{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Null{}, T.ByteVector{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Null{}, T.ByteList{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Null{}, T.BitVector{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.BitList{bc0})), {==}, decision(T.Null{}, T.BitList{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Null{}, T.Vector{bc0, bc1}))
    case T.Vector{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Null{}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Null{}, T.Container{bc0, bc1}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.Union{bc0})), {==}, decision(T.Null{}, T.Union{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), S.identical(N.normalize(T.Null{}), N.normalize(T.Null{})), {==}, decision(T.Null{}, T.Null{}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Null{}, T.Chain{bc0, bc1}))
    case T.Vector{T.Null{}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), S.identical(N.normalize(T.Null{}), N.normalize(T.End{})), {==}, decision(T.Null{}, T.End{}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Null{}, T.Repeat{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Null{}, T.Named{bc0, bc1}))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Null{}, T.ProgressiveList{bc0}))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), S.identical(N.normalize(T.Null{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Null{}, T.ProgressiveBits{}))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Null{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Null{}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Null{}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Null{}, a1} T.Union{b0}: {==}
    case T.Vector{T.Null{}, a1} T.Null{}: {==}
    case T.Vector{T.Null{}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Null{}, a1} T.End{}: {==}
    case T.Vector{T.Null{}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Null{}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Null{}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Null{}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Null{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Chain{ac0, ac1}, T.Boolean{}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.Unsigned{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.ByteVector{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.ByteList{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.BitVector{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.BitList{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Container{bc0, bc1}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.Union{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Chain{ac0, ac1}, T.Null{}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Chain{ac0, ac1}, T.End{}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.Repeat{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Named{bc0, bc1}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Chain{ac0, ac1}, T.ProgressiveBits{}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Null{}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.End{}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.End{}, a1} T.Boolean{}: {==}
    case T.Vector{T.End{}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.End{}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.End{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.End{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.End{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), S.identical(N.normalize(T.End{}), N.normalize(T.Boolean{})), {==}, decision(T.End{}, T.Boolean{}))
    case T.Vector{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.End{}, T.Unsigned{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.End{}, T.ByteVector{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.End{}, T.ByteList{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.End{}, T.BitVector{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.BitList{bc0})), {==}, decision(T.End{}, T.BitList{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.End{}, T.Vector{bc0, bc1}))
    case T.Vector{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.End{}, T.ListOf{bc0, bc1}))
    case T.Vector{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.End{}, T.Container{bc0, bc1}))
    case T.Vector{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.Union{bc0})), {==}, decision(T.End{}, T.Union{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), S.identical(N.normalize(T.End{}), N.normalize(T.Null{})), {==}, decision(T.End{}, T.Null{}))
    case T.Vector{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.End{}, T.Chain{bc0, bc1}))
    case T.Vector{T.End{}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), S.identical(N.normalize(T.End{}), N.normalize(T.End{})), {==}, decision(T.End{}, T.End{}))
    case T.Vector{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.End{}, T.Repeat{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.End{}, T.Named{bc0, bc1}))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.End{}, T.ProgressiveList{bc0}))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), S.identical(N.normalize(T.End{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.End{}, T.ProgressiveBits{}))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.End{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.End{}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.End{}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.End{}, a1} T.Union{b0}: {==}
    case T.Vector{T.End{}, a1} T.Null{}: {==}
    case T.Vector{T.End{}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.End{}, a1} T.End{}: {==}
    case T.Vector{T.End{}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.End{}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.End{}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.End{}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.End{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Repeat{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Boolean{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.Repeat{ac0}, T.Boolean{}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Repeat{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Repeat{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Repeat{ac0}, T.ByteList{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Repeat{ac0}, T.BitVector{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.Repeat{ac0}, T.BitList{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Union{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.Repeat{ac0}, T.Union{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Null{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Null{})), {==}, decision(T.Repeat{ac0}, T.Null{}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.End{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.End{})), {==}, decision(T.Repeat{ac0}, T.End{}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Repeat{ac0}, T.Repeat{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Repeat{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Repeat{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.End{}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Named{ac0, ac1}, T.Boolean{}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Named{ac0, ac1}, T.Unsigned{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Named{ac0, ac1}, T.ByteVector{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Named{ac0, ac1}, T.ByteList{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Named{ac0, ac1}, T.BitVector{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Named{ac0, ac1}, T.BitList{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Container{bc0, bc1}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Named{ac0, ac1}, T.Union{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Named{ac0, ac1}, T.Null{}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Named{ac0, ac1}, T.End{}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Named{ac0, ac1}, T.Repeat{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Named{bc0, bc1}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Named{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Named{ac0, ac1}, T.ProgressiveBits{}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Null{}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.End{}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Boolean{}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.ProgressiveList{ac0}, T.Boolean{}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.Unsigned{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.ByteVector{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.ByteList{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.BitVector{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.BitList{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Container{bc0, bc1}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.Union{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Null{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Null{})), {==}, decision(T.ProgressiveList{ac0}, T.Null{}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.End{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.End{})), {==}, decision(T.ProgressiveList{ac0}, T.End{}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.Repeat{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Named{bc0, bc1}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ProgressiveList{ac0}, T.ProgressiveBits{}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Union{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Null{}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.End{}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Boolean{}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Boolean{})), {==}, decision(T.ProgressiveBits{}, T.Boolean{}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ProgressiveBits{}, T.Unsigned{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ProgressiveBits{}, T.ByteVector{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ProgressiveBits{}, T.ByteList{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ProgressiveBits{}, T.BitVector{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.BitList{bc0})), {==}, decision(T.ProgressiveBits{}, T.BitList{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Vector{bc0, bc1}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.ListOf{bc0, bc1}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Container{bc0, bc1}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Union{bc0})), {==}, decision(T.ProgressiveBits{}, T.Union{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Null{})), {==}, decision(T.ProgressiveBits{}, T.Null{}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Chain{bc0, bc1}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.End{})), {==}, decision(T.ProgressiveBits{}, T.End{}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ProgressiveBits{}, T.Repeat{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Named{bc0, bc1}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ProgressiveBits{}, T.ProgressiveList{bc0}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ProgressiveBits{}, T.ProgressiveBits{}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Union{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Null{}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.End{}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Boolean{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.BitList{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Union{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Null{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.End{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Boolean{}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Null{}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.End{}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Boolean{}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Boolean{})), {==}, decision(T.Boolean{}, T.Boolean{}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Boolean{}, T.Unsigned{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Boolean{}, T.ByteVector{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Boolean{}, T.ByteList{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Boolean{}, T.BitVector{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.BitList{bc0})), {==}, decision(T.Boolean{}, T.BitList{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Boolean{}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Boolean{}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Boolean{}, T.Container{bc0, bc1}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Union{bc0})), {==}, decision(T.Boolean{}, T.Union{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Null{})), {==}, decision(T.Boolean{}, T.Null{}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Boolean{}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.End{})), {==}, decision(T.Boolean{}, T.End{}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Boolean{}, T.Repeat{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Boolean{}, T.Named{bc0, bc1}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Boolean{}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Boolean{}, T.ProgressiveBits{}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Boolean{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Boolean{}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Boolean{}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Null{}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.End{}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ByteList{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Boolean{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.Unsigned{ac0}, T.Boolean{}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Unsigned{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Unsigned{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Unsigned{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Unsigned{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.Unsigned{ac0}, T.BitList{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Union{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.Unsigned{ac0}, T.Union{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Null{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Null{})), {==}, decision(T.Unsigned{ac0}, T.Null{}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.End{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.End{})), {==}, decision(T.Unsigned{ac0}, T.End{}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Unsigned{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Unsigned{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Unsigned{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Unsigned{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Unsigned{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.ByteVector{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Boolean{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.ByteVector{ac0}, T.Boolean{}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ByteVector{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ByteVector{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ByteVector{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ByteVector{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.ByteVector{ac0}, T.BitList{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Union{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.ByteVector{ac0}, T.Union{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Null{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Null{})), {==}, decision(T.ByteVector{ac0}, T.Null{}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.End{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.End{})), {==}, decision(T.ByteVector{ac0}, T.End{}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ByteVector{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ByteVector{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ByteVector{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ByteVector{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.ByteVector{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.ByteList{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Boolean{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.ByteList{ac0}, T.Boolean{}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ByteList{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ByteList{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ByteList{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ByteList{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.ByteList{ac0}, T.BitList{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Union{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.ByteList{ac0}, T.Union{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Null{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Null{})), {==}, decision(T.ByteList{ac0}, T.Null{}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.End{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.End{})), {==}, decision(T.ByteList{ac0}, T.End{}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ByteList{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ByteList{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ByteList{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ByteList{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.ByteList{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.BitVector{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Boolean{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.BitVector{ac0}, T.Boolean{}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.BitVector{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.BitVector{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.BitVector{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.BitVector{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.BitVector{ac0}, T.BitList{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Union{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.BitVector{ac0}, T.Union{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Null{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Null{})), {==}, decision(T.BitVector{ac0}, T.Null{}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.End{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.End{})), {==}, decision(T.BitVector{ac0}, T.End{}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.BitVector{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.BitVector{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.BitVector{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.BitVector{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.BitVector{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.BitList{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Boolean{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.BitList{ac0}, T.Boolean{}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.BitList{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.BitList{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.BitList{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.BitList{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.BitList{ac0}, T.BitList{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Union{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.BitList{ac0}, T.Union{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Null{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Null{})), {==}, decision(T.BitList{ac0}, T.Null{}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.End{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.End{})), {==}, decision(T.BitList{ac0}, T.End{}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.BitList{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.BitList{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.BitList{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.BitList{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.BitList{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: U.false_conjunction(Nat.is_eq(a1, b0), S.identical(T.Vector{N.normalize(ac0), ac1}, T.Unsigned{Width.U8{}}), U.Vector_left(N.normalize(ac0), ac1, Width.U8{}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Vector{ac0, ac1}, T.Boolean{}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.Unsigned{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.ByteVector{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.ByteList{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.BitVector{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.BitList{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Container{bc0, bc1}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.Union{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Vector{ac0, ac1}, T.Null{}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Vector{ac0, ac1}, T.End{}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.Repeat{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.Named{bc0, bc1}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Vector{ac0, ac1}, T.ProgressiveBits{}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Vector{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Null{}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.End{}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: U.false_conjunction(Nat.is_eq(a1, b0), S.identical(T.ListOf{N.normalize(ac0), ac1}, T.Unsigned{Width.U8{}}), U.ListOf_left(N.normalize(ac0), ac1, Width.U8{}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.ListOf{ac0, ac1}, T.Boolean{}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.Unsigned{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.ByteVector{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.ByteList{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.BitVector{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.BitList{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.Union{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.ListOf{ac0, ac1}, T.Null{}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.End{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.ListOf{ac0, ac1}, T.End{}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.Repeat{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ListOf{ac0, ac1}, T.ProgressiveBits{}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ListOf{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Null{}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.End{}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Container{ac0, ac1}, T.Boolean{}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Container{ac0, ac1}, T.Unsigned{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Container{ac0, ac1}, T.ByteVector{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Container{ac0, ac1}, T.ByteList{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Container{ac0, ac1}, T.BitVector{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Container{ac0, ac1}, T.BitList{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Container{bc0, bc1}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Container{ac0, ac1}, T.Union{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Container{ac0, ac1}, T.Null{}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Container{ac0, ac1}, T.End{}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Container{ac0, ac1}, T.Repeat{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.Named{bc0, bc1}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Container{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Container{ac0, ac1}, T.ProgressiveBits{}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Container{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Null{}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.End{}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Union{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Boolean{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.Union{ac0}, T.Boolean{}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Union{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Union{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Union{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Union{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.Union{ac0}, T.BitList{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Union{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Union{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.Union{ac0}, T.Union{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Null{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Null{})), {==}, decision(T.Union{ac0}, T.Null{}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.End{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.End{})), {==}, decision(T.Union{ac0}, T.End{}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Union{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Union{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Union{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Union{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Union{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Union{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Null{}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Null{}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), S.identical(N.normalize(T.Null{}), N.normalize(T.Boolean{})), {==}, decision(T.Null{}, T.Boolean{}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Null{}, T.Unsigned{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Null{}, T.ByteVector{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Null{}, T.ByteList{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Null{}, T.BitVector{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.BitList{bc0})), {==}, decision(T.Null{}, T.BitList{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Null{}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Null{}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Null{}, T.Container{bc0, bc1}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.Union{bc0})), {==}, decision(T.Null{}, T.Union{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), S.identical(N.normalize(T.Null{}), N.normalize(T.Null{})), {==}, decision(T.Null{}, T.Null{}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Null{}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), S.identical(N.normalize(T.Null{}), N.normalize(T.End{})), {==}, decision(T.Null{}, T.End{}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Null{}, T.Repeat{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Null{}, T.Named{bc0, bc1}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Null{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Null{}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), S.identical(N.normalize(T.Null{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Null{}, T.ProgressiveBits{}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Null{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Null{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Null{}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Null{}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.Null{}: {==}
    case T.ListOf{T.Null{}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.End{}: {==}
    case T.ListOf{T.Null{}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Null{}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Null{}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Null{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Chain{ac0, ac1}, T.Boolean{}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.Unsigned{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.ByteVector{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.ByteList{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.BitVector{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.BitList{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Container{bc0, bc1}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.Union{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Chain{ac0, ac1}, T.Null{}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Chain{ac0, ac1}, T.End{}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.Repeat{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.Named{bc0, bc1}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Chain{ac0, ac1}, T.ProgressiveBits{}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Chain{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Null{}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.End{}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Boolean{}: {==}
    case T.ListOf{T.End{}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.End{}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.End{}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.End{}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.End{}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), S.identical(N.normalize(T.End{}), N.normalize(T.Boolean{})), {==}, decision(T.End{}, T.Boolean{}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.End{}, T.Unsigned{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.End{}, T.ByteVector{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.End{}, T.ByteList{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.End{}, T.BitVector{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.BitList{bc0})), {==}, decision(T.End{}, T.BitList{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.End{}, T.Vector{bc0, bc1}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.End{}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.End{}, T.Container{bc0, bc1}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.Union{bc0})), {==}, decision(T.End{}, T.Union{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), S.identical(N.normalize(T.End{}), N.normalize(T.Null{})), {==}, decision(T.End{}, T.Null{}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.End{}, T.Chain{bc0, bc1}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), S.identical(N.normalize(T.End{}), N.normalize(T.End{})), {==}, decision(T.End{}, T.End{}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.End{}, T.Repeat{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.End{}, T.Named{bc0, bc1}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.End{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.End{}, T.ProgressiveList{bc0}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), S.identical(N.normalize(T.End{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.End{}, T.ProgressiveBits{}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.End{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.End{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.End{}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.End{}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.End{}, a1} T.Union{b0}: {==}
    case T.ListOf{T.End{}, a1} T.Null{}: {==}
    case T.ListOf{T.End{}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.End{}, a1} T.End{}: {==}
    case T.ListOf{T.End{}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.End{}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.End{}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.End{}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.End{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Repeat{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Boolean{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.Repeat{ac0}, T.Boolean{}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Repeat{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Repeat{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Repeat{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Repeat{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.Repeat{ac0}, T.BitList{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Union{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.Repeat{ac0}, T.Union{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Null{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Null{})), {==}, decision(T.Repeat{ac0}, T.Null{}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.End{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.End{})), {==}, decision(T.Repeat{ac0}, T.End{}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Repeat{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Repeat{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Repeat{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Repeat{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Repeat{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.Named{ac0, ac1}, T.Boolean{}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.Named{ac0, ac1}, T.Unsigned{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.Named{ac0, ac1}, T.ByteVector{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.Named{ac0, ac1}, T.ByteList{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.Named{ac0, ac1}, T.BitVector{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.Named{ac0, ac1}, T.BitList{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Container{bc0, bc1}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.Named{ac0, ac1}, T.Union{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.Named{ac0, ac1}, T.Null{}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.End{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.Named{ac0, ac1}, T.End{}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.Named{ac0, ac1}, T.Repeat{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.Named{bc0, bc1}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.Named{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.Named{ac0, ac1}, T.ProgressiveBits{}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.Named{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Null{}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.End{}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Boolean{}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Boolean{})), {==}, decision(T.ProgressiveList{ac0}, T.Boolean{}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.Unsigned{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.ByteVector{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.ByteList{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.BitVector{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.BitList{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.BitList{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Container{bc0, bc1}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Union{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.Union{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Null{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Null{})), {==}, decision(T.ProgressiveList{ac0}, T.Null{}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.End{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.End{})), {==}, decision(T.ProgressiveList{ac0}, T.End{}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.Repeat{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.Named{bc0, bc1}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ProgressiveList{ac0}, T.ProgressiveBits{}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ProgressiveList{ac0}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Union{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Null{}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.End{}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Boolean{}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.ProgressiveBits{}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Boolean{})), {==}, decision(T.ProgressiveBits{}, T.Boolean{}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ProgressiveBits{}, T.Unsigned{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ProgressiveBits{}, T.ByteVector{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ProgressiveBits{}, T.ByteList{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ProgressiveBits{}, T.BitVector{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.BitList{bc0})), {==}, decision(T.ProgressiveBits{}, T.BitList{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Vector{bc0, bc1}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Container{bc0, bc1}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Union{bc0})), {==}, decision(T.ProgressiveBits{}, T.Union{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Null{})), {==}, decision(T.ProgressiveBits{}, T.Null{}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Chain{bc0, bc1}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.End{})), {==}, decision(T.ProgressiveBits{}, T.End{}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ProgressiveBits{}, T.Repeat{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.Named{bc0, bc1}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ProgressiveBits{}, T.ProgressiveList{bc0}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ProgressiveBits{}, T.ProgressiveBits{}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ProgressiveBits{}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Union{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Null{}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.End{}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Boolean{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ByteList{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.BitVector{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.BitList{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Union{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Null{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.End{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Repeat{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.ProgressiveContainer{ac0, ac1, ac2}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: L.and_right_false(Nat.is_eq(a1, b0))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Boolean{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Boolean{}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Unsigned{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ByteVector{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ByteList{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.BitVector{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.BitList{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Vector{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ListOf{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Container{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Union{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Null{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Null{}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Chain{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.End{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.End{}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Repeat{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.Named{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ProgressiveList{bc0})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ProgressiveBits{})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.ProgressiveContainer{bc0, bc1, bc2})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: E.and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(N.normalize(T.CompatibleUnion{ac0, ac1}), N.normalize(T.CompatibleUnion{bc0, bc1})), {==}, decision(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Container{a0, a1} T.Boolean{}: {==}
    case T.Container{a0, a1} T.Unsigned{b0}: {==}
    case T.Container{a0, a1} T.ByteVector{b0}: {==}
    case T.Container{a0, a1} T.ByteList{b0}: {==}
    case T.Container{a0, a1} T.BitVector{b0}: {==}
    case T.Container{a0, a1} T.BitList{b0}: {==}
    case T.Container{a0, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Null{}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.End{}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Container{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Container{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Container{a0, a1} T.Container{b0, b1}: E.and_equal(S.names_equal(a0, b0), S.names_equal(a0, b0), S.identical(a1, b1), S.identical(N.normalize(a1), N.normalize(b1)), {==}, decision(a1, b1))
    case T.Container{a0, a1} T.Union{b0}: {==}
    case T.Container{a0, a1} T.Null{}: {==}
    case T.Container{a0, a1} T.Chain{b0, b1}: {==}
    case T.Container{a0, a1} T.End{}: {==}
    case T.Container{a0, a1} T.Repeat{b0}: {==}
    case T.Container{a0, a1} T.Named{b0, b1}: {==}
    case T.Container{a0, a1} T.ProgressiveList{b0}: {==}
    case T.Container{a0, a1} T.ProgressiveBits{}: {==}
    case T.Container{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Container{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Union{a0} T.Boolean{}: {==}
    case T.Union{a0} T.Unsigned{b0}: {==}
    case T.Union{a0} T.ByteVector{b0}: {==}
    case T.Union{a0} T.ByteList{b0}: {==}
    case T.Union{a0} T.BitVector{b0}: {==}
    case T.Union{a0} T.BitList{b0}: {==}
    case T.Union{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.Union{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.Null{}, b1}: {==}
    case T.Union{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.Vector{T.End{}, b1}: {==}
    case T.Union{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Union{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Union{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Union{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.ListOf{T.End{}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Union{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Union{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Union{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Union{a0} T.Container{b0, b1}: {==}
    case T.Union{a0} T.Union{b0}: decision(a0, b0)
    case T.Union{a0} T.Null{}: {==}
    case T.Union{a0} T.Chain{b0, b1}: {==}
    case T.Union{a0} T.End{}: {==}
    case T.Union{a0} T.Repeat{b0}: {==}
    case T.Union{a0} T.Named{b0, b1}: {==}
    case T.Union{a0} T.ProgressiveList{b0}: {==}
    case T.Union{a0} T.ProgressiveBits{}: {==}
    case T.Union{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Union{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.Null{} T.Boolean{}: {==}
    case T.Null{} T.Unsigned{b0}: {==}
    case T.Null{} T.ByteVector{b0}: {==}
    case T.Null{} T.ByteList{b0}: {==}
    case T.Null{} T.BitVector{b0}: {==}
    case T.Null{} T.BitList{b0}: {==}
    case T.Null{} T.Vector{T.Boolean{}, b1}: {==}
    case T.Null{} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Null{} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Null{} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Null{} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.Null{}, b1}: {==}
    case T.Null{} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Null{} T.Vector{T.End{}, b1}: {==}
    case T.Null{} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Null{} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Null{} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Null{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Null{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Null{} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Null{} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Null{} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Null{} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Null{} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.Null{}, b1}: {==}
    case T.Null{} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Null{} T.ListOf{T.End{}, b1}: {==}
    case T.Null{} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Null{} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Null{} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Null{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Null{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Null{} T.Container{b0, b1}: {==}
    case T.Null{} T.Union{b0}: {==}
    case T.Null{} T.Null{}: {==}
    case T.Null{} T.Chain{b0, b1}: {==}
    case T.Null{} T.End{}: {==}
    case T.Null{} T.Repeat{b0}: {==}
    case T.Null{} T.Named{b0, b1}: {==}
    case T.Null{} T.ProgressiveList{b0}: {==}
    case T.Null{} T.ProgressiveBits{}: {==}
    case T.Null{} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Null{} T.CompatibleUnion{b0, b1}: {==}
    case T.Chain{a0, a1} T.Boolean{}: {==}
    case T.Chain{a0, a1} T.Unsigned{b0}: {==}
    case T.Chain{a0, a1} T.ByteVector{b0}: {==}
    case T.Chain{a0, a1} T.ByteList{b0}: {==}
    case T.Chain{a0, a1} T.BitVector{b0}: {==}
    case T.Chain{a0, a1} T.BitList{b0}: {==}
    case T.Chain{a0, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Null{}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.End{}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Chain{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Chain{a0, a1} T.Container{b0, b1}: {==}
    case T.Chain{a0, a1} T.Union{b0}: {==}
    case T.Chain{a0, a1} T.Null{}: {==}
    case T.Chain{a0, a1} T.Chain{b0, b1}: E.and_equal(S.identical(a0, b0), S.identical(N.normalize(a0), N.normalize(b0)), S.identical(a1, b1), S.identical(N.normalize(a1), N.normalize(b1)), decision(a0, b0), decision(a1, b1))
    case T.Chain{a0, a1} T.End{}: {==}
    case T.Chain{a0, a1} T.Repeat{b0}: {==}
    case T.Chain{a0, a1} T.Named{b0, b1}: {==}
    case T.Chain{a0, a1} T.ProgressiveList{b0}: {==}
    case T.Chain{a0, a1} T.ProgressiveBits{}: {==}
    case T.Chain{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Chain{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.End{} T.Boolean{}: {==}
    case T.End{} T.Unsigned{b0}: {==}
    case T.End{} T.ByteVector{b0}: {==}
    case T.End{} T.ByteList{b0}: {==}
    case T.End{} T.BitVector{b0}: {==}
    case T.End{} T.BitList{b0}: {==}
    case T.End{} T.Vector{T.Boolean{}, b1}: {==}
    case T.End{} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.End{} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.End{} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.End{} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.End{} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.End{} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.End{} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.End{} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.End{} T.Vector{T.Union{bc0}, b1}: {==}
    case T.End{} T.Vector{T.Null{}, b1}: {==}
    case T.End{} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.End{} T.Vector{T.End{}, b1}: {==}
    case T.End{} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.End{} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.End{} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.End{} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.End{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.End{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.End{} T.ListOf{T.Boolean{}, b1}: {==}
    case T.End{} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.End{} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.End{} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.End{} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.Null{}, b1}: {==}
    case T.End{} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.End{} T.ListOf{T.End{}, b1}: {==}
    case T.End{} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.End{} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.End{} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.End{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.End{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.End{} T.Container{b0, b1}: {==}
    case T.End{} T.Union{b0}: {==}
    case T.End{} T.Null{}: {==}
    case T.End{} T.Chain{b0, b1}: {==}
    case T.End{} T.End{}: {==}
    case T.End{} T.Repeat{b0}: {==}
    case T.End{} T.Named{b0, b1}: {==}
    case T.End{} T.ProgressiveList{b0}: {==}
    case T.End{} T.ProgressiveBits{}: {==}
    case T.End{} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.End{} T.CompatibleUnion{b0, b1}: {==}
    case T.Repeat{a0} T.Boolean{}: {==}
    case T.Repeat{a0} T.Unsigned{b0}: {==}
    case T.Repeat{a0} T.ByteVector{b0}: {==}
    case T.Repeat{a0} T.ByteList{b0}: {==}
    case T.Repeat{a0} T.BitVector{b0}: {==}
    case T.Repeat{a0} T.BitList{b0}: {==}
    case T.Repeat{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Null{}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.End{}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Repeat{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.End{}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Repeat{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Repeat{a0} T.Container{b0, b1}: {==}
    case T.Repeat{a0} T.Union{b0}: {==}
    case T.Repeat{a0} T.Null{}: {==}
    case T.Repeat{a0} T.Chain{b0, b1}: {==}
    case T.Repeat{a0} T.End{}: {==}
    case T.Repeat{a0} T.Repeat{b0}: {==}
    case T.Repeat{a0} T.Named{b0, b1}: {==}
    case T.Repeat{a0} T.ProgressiveList{b0}: {==}
    case T.Repeat{a0} T.ProgressiveBits{}: {==}
    case T.Repeat{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Repeat{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.Named{a0, a1} T.Boolean{}: {==}
    case T.Named{a0, a1} T.Unsigned{b0}: {==}
    case T.Named{a0, a1} T.ByteVector{b0}: {==}
    case T.Named{a0, a1} T.ByteList{b0}: {==}
    case T.Named{a0, a1} T.BitVector{b0}: {==}
    case T.Named{a0, a1} T.BitList{b0}: {==}
    case T.Named{a0, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Null{}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.End{}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Named{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.End{}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.Named{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.Named{a0, a1} T.Container{b0, b1}: {==}
    case T.Named{a0, a1} T.Union{b0}: {==}
    case T.Named{a0, a1} T.Null{}: {==}
    case T.Named{a0, a1} T.Chain{b0, b1}: {==}
    case T.Named{a0, a1} T.End{}: {==}
    case T.Named{a0, a1} T.Repeat{b0}: {==}
    case T.Named{a0, a1} T.Named{b0, b1}: E.and_equal(String.eq(a0, b0), String.eq(a0, b0), S.identical(a1, b1), S.identical(N.normalize(a1), N.normalize(b1)), {==}, decision(a1, b1))
    case T.Named{a0, a1} T.ProgressiveList{b0}: {==}
    case T.Named{a0, a1} T.ProgressiveBits{}: {==}
    case T.Named{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Named{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ProgressiveList{a0} T.Boolean{}: {==}
    case T.ProgressiveList{a0} T.Unsigned{b0}: {==}
    case T.ProgressiveList{a0} T.ByteVector{b0}: {==}
    case T.ProgressiveList{a0} T.ByteList{b0}: {==}
    case T.ProgressiveList{a0} T.BitVector{b0}: {==}
    case T.ProgressiveList{a0} T.BitList{b0}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Null{}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.End{}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ProgressiveList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.End{}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ProgressiveList{a0} T.Container{b0, b1}: {==}
    case T.ProgressiveList{a0} T.Union{b0}: {==}
    case T.ProgressiveList{a0} T.Null{}: {==}
    case T.ProgressiveList{a0} T.Chain{b0, b1}: {==}
    case T.ProgressiveList{a0} T.End{}: {==}
    case T.ProgressiveList{a0} T.Repeat{b0}: {==}
    case T.ProgressiveList{a0} T.Named{b0, b1}: {==}
    case T.ProgressiveList{a0} T.ProgressiveList{b0}: decision(a0, b0)
    case T.ProgressiveList{a0} T.ProgressiveBits{}: {==}
    case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.ProgressiveBits{} T.Boolean{}: {==}
    case T.ProgressiveBits{} T.Unsigned{b0}: {==}
    case T.ProgressiveBits{} T.ByteVector{b0}: {==}
    case T.ProgressiveBits{} T.ByteList{b0}: {==}
    case T.ProgressiveBits{} T.BitVector{b0}: {==}
    case T.ProgressiveBits{} T.BitList{b0}: {==}
    case T.ProgressiveBits{} T.Vector{T.Boolean{}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Null{}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.End{}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ProgressiveBits{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Boolean{}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Null{}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.End{}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ProgressiveBits{} T.Container{b0, b1}: {==}
    case T.ProgressiveBits{} T.Union{b0}: {==}
    case T.ProgressiveBits{} T.Null{}: {==}
    case T.ProgressiveBits{} T.Chain{b0, b1}: {==}
    case T.ProgressiveBits{} T.End{}: {==}
    case T.ProgressiveBits{} T.Repeat{b0}: {==}
    case T.ProgressiveBits{} T.Named{b0, b1}: {==}
    case T.ProgressiveBits{} T.ProgressiveList{b0}: {==}
    case T.ProgressiveBits{} T.ProgressiveBits{}: {==}
    case T.ProgressiveBits{} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ProgressiveBits{} T.CompatibleUnion{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Boolean{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Unsigned{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ByteVector{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ByteList{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.BitVector{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.BitList{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Boolean{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Null{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.End{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Boolean{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Null{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.End{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Null{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Chain{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.End{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: E.and_equal(S.names_equal(a0, b0), S.names_equal(a0, b0), Bool.and(S.bits_equal(a2, b2), S.identical(a1, b1)), Bool.and(S.bits_equal(a2, b2), S.identical(N.normalize(a1), N.normalize(b1))), {==}, E.and_equal(S.bits_equal(a2, b2), S.bits_equal(a2, b2), S.identical(a1, b1), S.identical(N.normalize(a1), N.normalize(b1)), {==}, decision(a1, b1)))
    case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Boolean{}: {==}
    case T.CompatibleUnion{a0, a1} T.Unsigned{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ByteVector{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ByteList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.BitVector{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.BitList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Boolean{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Union{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Null{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.End{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Boolean{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Null{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.End{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Container{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Union{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.Null{}: {==}
    case T.CompatibleUnion{a0, a1} T.Chain{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.End{}: {==}
    case T.CompatibleUnion{a0, a1} T.Repeat{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.Named{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ProgressiveList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ProgressiveBits{}: {==}
    case T.CompatibleUnion{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: E.and_equal(S.selectors_equal(a0, b0), S.selectors_equal(a0, b0), S.identical(a1, b1), S.identical(N.normalize(a1), N.normalize(b1)), {==}, decision(a1, b1))

# Replacement of an identical option preserves the entire identity decision,
# including rejection. This is needed by ordinary unions inside compatibility.
law replace_right:
  for +a: T.Schema
  for +b: T.Schema
  for +c: T.Schema
  for same: {S.identical(b, c) == True{} : Bool}
  {S.identical(a, b) == S.identical(a, c) : Bool}
def replace_right(a, b, c, same):
  Equal.trans(Bool, S.identical(a, b), S.identical(N.normalize(a), N.normalize(b)), S.identical(a, c), decision(a, b), Equal.trans(Bool, S.identical(N.normalize(a), N.normalize(b)), S.identical(N.normalize(a), N.normalize(c)), S.identical(a, c), Equal.cong(T.Schema, Bool, x => S.identical(N.normalize(a), x), N.normalize(b), N.normalize(c), N.reflect(b, c, same)), Equal.sym(Bool, S.identical(a, c), S.identical(N.normalize(a), N.normalize(c)), decision(a, c))))

law transitive:
  for +a: T.Schema
  for +b: T.Schema
  for +c: T.Schema
  for ab: {S.identical(a, b) == True{} : Bool}
  for bc: {S.identical(b, c) == True{} : Bool}
  {S.identical(a, c) == True{} : Bool}
def transitive(a, b, c, ab, bc):
  %replace_right(a, b, c, bc) : {_ == True{} : Bool}
  ab
