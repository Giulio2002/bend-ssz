import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/primitives.bend as IP
import ../spec/compatibility.bend as S
import ../spec/primitives.bend as SP
import ./primitives.bend as P
import ./validator_metadata.bend as M
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

# Structural identity soundness includes internal Named nodes.
law identical_sound:
  for +a: T.Schema
  for +b: T.Schema
  for +accepted: {I.identical(a, b) == True{} : Bool}
  {S.identical(a, b) == True{} : Bool}
def identical_sound(a, b, accepted):
  match a b:
    case T.Boolean{} T.Boolean{}:
      accepted
    case T.Boolean{} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.BitList{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Union{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Null{}:
      Empty.absurd({S.identical(T.Boolean{}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.End{}:
      Empty.absurd({S.identical(T.Boolean{}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Boolean{}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Boolean{}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Boolean{}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Boolean{} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Boolean{}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Unsigned{b0}:
      %P.width_correct(a0) : {Nat.is_eq(_, SP.byte_width(b0)) == True{} : Bool}
      %P.width_correct(b0) : {Nat.is_eq(IP.width(a0), _) == True{} : Bool}
      accepted
    case T.Unsigned{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Null{}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.End{}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Unsigned{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Unsigned{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ByteVector{b0}:
      accepted
    case T.ByteVector{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Boolean{}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Unsigned{c0}, b1}:
          %P.width_correct(c0) : {Bool.and(Nat.is_eq(a0, b1), Nat.is_eq(_, 1n)) == True{} : Bool}
          accepted
    case T.ByteVector{a0} T.Vector{T.ByteVector{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.ByteVector{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.ByteList{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.ByteList{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.BitVector{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.BitVector{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.BitList{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.BitList{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Vector{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Vector{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.ListOf{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.ListOf{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Container{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Container{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Union{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Union{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Null{}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Chain{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Chain{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.End{}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Repeat{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Repeat{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.Named{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.Named{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.ProgressiveList{c0}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.ProgressiveList{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.ProgressiveBits{}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.ProgressiveContainer{c0, c1, c2}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.ProgressiveContainer{c0, c1, c2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Vector{T.CompatibleUnion{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteVector{a0}, T.Vector{T.CompatibleUnion{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Null{}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.End{}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteVector{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ByteVector{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ByteList{b0}:
      accepted
    case T.ByteList{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Boolean{}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Unsigned{c0}, b1}:
          %P.width_correct(c0) : {Bool.and(Nat.is_eq(a0, b1), Nat.is_eq(_, 1n)) == True{} : Bool}
          accepted
    case T.ByteList{a0} T.ListOf{T.ByteVector{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.ByteVector{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.ByteList{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.ByteList{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.BitVector{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.BitVector{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.BitList{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.BitList{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Vector{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Vector{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.ListOf{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.ListOf{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Container{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Container{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Union{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Union{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Null{}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Chain{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Chain{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.End{}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Repeat{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Repeat{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.Named{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.Named{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.ProgressiveList{c0}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.ProgressiveList{c0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.ProgressiveBits{}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.ProgressiveContainer{c0, c1, c2}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.ProgressiveContainer{c0, c1, c2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ListOf{T.CompatibleUnion{c0, c1}, b1}:
          Empty.absurd({S.identical(T.ByteList{a0}, T.ListOf{T.CompatibleUnion{c0, c1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Null{}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.End{}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ByteList{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ByteList{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.BitVector{b0}:
      accepted
    case T.BitVector{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Null{}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.End{}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.BitVector{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.BitVector{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.BitList{b0}:
      accepted
    case T.BitList{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Null{}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.End{}:
      Empty.absurd({S.identical(T.BitList{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.BitList{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.BitList{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.BitList{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{c0}, a1} T.ByteVector{b0}:
          %P.width_correct(c0) : {Bool.and(Nat.is_eq(a1, b0), Nat.is_eq(_, 1n)) == True{} : Bool}
          accepted
    case T.Vector{T.ByteVector{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.ByteVector{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.ByteList{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.BitVector{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.BitList{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{c0, c1}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Vector{c0, c1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{c0, c1}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.ListOf{c0, c1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{c0, c1}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Container{c0, c1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Union{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{c0, c1}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Chain{c0, c1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Repeat{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{c0, c1}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.Named{c0, c1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{c0}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.ProgressiveList{c0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{c0, c1, c2}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{c0, c1, c2}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{c0, c1}, a1} T.ByteVector{b0}:
          Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{c0, c1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Boolean{}), accepted), identical_sound(T.Boolean{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Boolean{}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Unsigned{e0}), accepted), identical_sound(T.Boolean{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteVector{e0}), accepted), identical_sound(T.Boolean{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteList{e0}), accepted), identical_sound(T.Boolean{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitVector{e0}), accepted), identical_sound(T.Boolean{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitList{e0}), accepted), identical_sound(T.Boolean{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitList{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Vector{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ListOf{e0, e1}), accepted), identical_sound(T.Boolean{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Container{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Union{e0}), accepted), identical_sound(T.Boolean{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Union{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Null{}), accepted), identical_sound(T.Boolean{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Null{}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Chain{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.End{}), accepted), identical_sound(T.Boolean{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.End{}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Repeat{e0}), accepted), identical_sound(T.Boolean{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Named{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveList{e0}), accepted), identical_sound(T.Boolean{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveBits{}), accepted), identical_sound(T.Boolean{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Boolean{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Boolean{}), accepted), identical_sound(T.Unsigned{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Unsigned{e0}), accepted), identical_sound(T.Unsigned{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteVector{e0}), accepted), identical_sound(T.Unsigned{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteList{e0}), accepted), identical_sound(T.Unsigned{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitVector{e0}), accepted), identical_sound(T.Unsigned{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitList{e0}), accepted), identical_sound(T.Unsigned{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Container{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Union{e0}), accepted), identical_sound(T.Unsigned{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Null{}), accepted), identical_sound(T.Unsigned{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Null{}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.End{}), accepted), identical_sound(T.Unsigned{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.End{}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Repeat{e0}), accepted), identical_sound(T.Unsigned{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Named{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.Unsigned{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.Unsigned{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Unsigned{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Boolean{}), accepted), identical_sound(T.ByteVector{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Unsigned{e0}), accepted), identical_sound(T.ByteVector{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteVector{e0}), accepted), identical_sound(T.ByteVector{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteList{e0}), accepted), identical_sound(T.ByteVector{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitVector{e0}), accepted), identical_sound(T.ByteVector{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitList{e0}), accepted), identical_sound(T.ByteVector{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Container{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Union{e0}), accepted), identical_sound(T.ByteVector{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Null{}), accepted), identical_sound(T.ByteVector{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Null{}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.End{}), accepted), identical_sound(T.ByteVector{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.End{}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Repeat{e0}), accepted), identical_sound(T.ByteVector{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Named{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.ByteVector{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.ByteVector{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.ByteVector{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Boolean{}), accepted), identical_sound(T.ByteList{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Unsigned{e0}), accepted), identical_sound(T.ByteList{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteVector{e0}), accepted), identical_sound(T.ByteList{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteList{e0}), accepted), identical_sound(T.ByteList{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitVector{e0}), accepted), identical_sound(T.ByteList{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitList{e0}), accepted), identical_sound(T.ByteList{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Container{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Union{e0}), accepted), identical_sound(T.ByteList{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Null{}), accepted), identical_sound(T.ByteList{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Null{}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.End{}), accepted), identical_sound(T.ByteList{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.End{}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Repeat{e0}), accepted), identical_sound(T.ByteList{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Named{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.ByteList{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.ByteList{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.ByteList{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Boolean{}), accepted), identical_sound(T.BitVector{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Unsigned{e0}), accepted), identical_sound(T.BitVector{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteVector{e0}), accepted), identical_sound(T.BitVector{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteList{e0}), accepted), identical_sound(T.BitVector{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitVector{e0}), accepted), identical_sound(T.BitVector{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitList{e0}), accepted), identical_sound(T.BitVector{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Container{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Union{e0}), accepted), identical_sound(T.BitVector{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Null{}), accepted), identical_sound(T.BitVector{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Null{}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.End{}), accepted), identical_sound(T.BitVector{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.End{}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Repeat{e0}), accepted), identical_sound(T.BitVector{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Named{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.BitVector{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.BitVector{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.BitVector{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Boolean{}), accepted), identical_sound(T.BitList{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Unsigned{e0}), accepted), identical_sound(T.BitList{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteVector{e0}), accepted), identical_sound(T.BitList{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteList{e0}), accepted), identical_sound(T.BitList{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitVector{e0}), accepted), identical_sound(T.BitList{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitList{e0}), accepted), identical_sound(T.BitList{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Container{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Union{e0}), accepted), identical_sound(T.BitList{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Null{}), accepted), identical_sound(T.BitList{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Null{}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.End{}), accepted), identical_sound(T.BitList{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.End{}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Repeat{e0}), accepted), identical_sound(T.BitList{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Named{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.BitList{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.BitList{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.BitList{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Vector{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Boolean{}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitList{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Union{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Null{}), accepted), identical_sound(T.Vector{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Null{}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.End{}), accepted), identical_sound(T.Vector{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.End{}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Vector{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Vector{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Boolean{}), accepted), identical_sound(T.ListOf{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Boolean{}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteList{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitVector{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitList{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Union{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Union{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Null{}), accepted), identical_sound(T.ListOf{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Null{}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.End{}), accepted), identical_sound(T.ListOf{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.End{}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Repeat{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.ListOf{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Container{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Boolean{}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Container{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Container{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Container{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Container{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Container{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitList{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Container{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Union{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Null{}), accepted), identical_sound(T.Container{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Null{}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.End{}), accepted), identical_sound(T.Container{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.End{}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Container{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Container{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Container{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Container{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Boolean{}), accepted), identical_sound(T.Union{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Unsigned{e0}), accepted), identical_sound(T.Union{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteVector{e0}), accepted), identical_sound(T.Union{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteList{e0}), accepted), identical_sound(T.Union{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitVector{e0}), accepted), identical_sound(T.Union{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitList{e0}), accepted), identical_sound(T.Union{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.Union{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Container{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Union{e0}), accepted), identical_sound(T.Union{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Null{}), accepted), identical_sound(T.Union{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Null{}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.End{}), accepted), identical_sound(T.Union{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.End{}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Repeat{e0}), accepted), identical_sound(T.Union{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Named{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.Union{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.Union{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Union{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Union{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Boolean{}), accepted), identical_sound(T.Null{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Boolean{}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Unsigned{e0}), accepted), identical_sound(T.Null{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteVector{e0}), accepted), identical_sound(T.Null{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteList{e0}), accepted), identical_sound(T.Null{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitVector{e0}), accepted), identical_sound(T.Null{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitList{e0}), accepted), identical_sound(T.Null{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitList{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Vector{e0, e1}), accepted), identical_sound(T.Null{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ListOf{e0, e1}), accepted), identical_sound(T.Null{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Container{e0, e1}), accepted), identical_sound(T.Null{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Union{e0}), accepted), identical_sound(T.Null{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Union{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Null{}), accepted), identical_sound(T.Null{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Null{}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Chain{e0, e1}), accepted), identical_sound(T.Null{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.End{}), accepted), identical_sound(T.Null{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.End{}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Repeat{e0}), accepted), identical_sound(T.Null{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Named{e0, e1}), accepted), identical_sound(T.Null{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveList{e0}), accepted), identical_sound(T.Null{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveBits{}), accepted), identical_sound(T.Null{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Null{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Null{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Null{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Chain{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Boolean{}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitList{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Union{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Null{}), accepted), identical_sound(T.Chain{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Null{}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.End{}), accepted), identical_sound(T.Chain{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.End{}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Chain{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Chain{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Boolean{}), accepted), identical_sound(T.End{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Boolean{}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Unsigned{e0}), accepted), identical_sound(T.End{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteVector{e0}), accepted), identical_sound(T.End{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteList{e0}), accepted), identical_sound(T.End{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteList{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitVector{e0}), accepted), identical_sound(T.End{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitVector{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitList{e0}), accepted), identical_sound(T.End{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitList{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Vector{e0, e1}), accepted), identical_sound(T.End{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ListOf{e0, e1}), accepted), identical_sound(T.End{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Container{e0, e1}), accepted), identical_sound(T.End{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Union{e0}), accepted), identical_sound(T.End{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Union{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Null{}), accepted), identical_sound(T.End{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Null{}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Chain{e0, e1}), accepted), identical_sound(T.End{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.End{}), accepted), identical_sound(T.End{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.End{}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Repeat{e0}), accepted), identical_sound(T.End{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Repeat{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Named{e0, e1}), accepted), identical_sound(T.End{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveList{e0}), accepted), identical_sound(T.End{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveBits{}), accepted), identical_sound(T.End{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.End{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.End{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.End{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Boolean{}), accepted), identical_sound(T.Repeat{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Unsigned{e0}), accepted), identical_sound(T.Repeat{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteVector{e0}), accepted), identical_sound(T.Repeat{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteList{e0}), accepted), identical_sound(T.Repeat{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitVector{e0}), accepted), identical_sound(T.Repeat{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitList{e0}), accepted), identical_sound(T.Repeat{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Container{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Union{e0}), accepted), identical_sound(T.Repeat{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Null{}), accepted), identical_sound(T.Repeat{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Null{}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.End{}), accepted), identical_sound(T.Repeat{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.End{}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Repeat{e0}), accepted), identical_sound(T.Repeat{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Named{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.Repeat{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.Repeat{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Repeat{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Named{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Boolean{}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Named{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Named{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Named{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteList{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Named{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitVector{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Named{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitList{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Named{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Union{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Null{}), accepted), identical_sound(T.Named{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Null{}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.End{}), accepted), identical_sound(T.Named{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.End{}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Named{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Repeat{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Named{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Named{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.Named{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Boolean{}), accepted), identical_sound(T.ProgressiveList{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Boolean{}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Unsigned{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteVector{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteList{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteList{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitVector{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitVector{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitList{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitList{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Container{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Union{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Union{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Null{}), accepted), identical_sound(T.ProgressiveList{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Null{}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.End{}), accepted), identical_sound(T.ProgressiveList{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.End{}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Repeat{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Repeat{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Named{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.ProgressiveList{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Boolean{}), accepted), identical_sound(T.ProgressiveBits{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Boolean{}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Unsigned{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteVector{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteList{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteList{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitVector{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitVector{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitList{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitList{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Vector{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ListOf{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Container{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Union{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Union{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Null{}), accepted), identical_sound(T.ProgressiveBits{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Null{}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Chain{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.End{}), accepted), identical_sound(T.ProgressiveBits{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.End{}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Repeat{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Repeat{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Named{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveList{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), accepted), identical_sound(T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Null{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Null{}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.End{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.End{}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Boolean{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Boolean{}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteList{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitVector{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitList{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Union{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Union{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Null{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Null{}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.End{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.End{}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Repeat{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Boolean{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Unsigned{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Unsigned{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteVector{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteVector{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ByteList{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ByteList{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitVector{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitVector{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.BitList{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.BitList{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Vector{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Vector{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ListOf{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ListOf{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Container{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Container{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Union{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Union{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Null{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Null{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Chain{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Chain{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.End{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.End{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Repeat{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Repeat{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.Named{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.Named{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveList{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveList{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveBits{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.ProgressiveContainer{d0, d1, d2}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Vector{T.CompatibleUnion{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Vector{T.CompatibleUnion{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{c0}, a1} T.ByteList{b0}:
          %P.width_correct(c0) : {Bool.and(Nat.is_eq(a1, b0), Nat.is_eq(_, 1n)) == True{} : Bool}
          accepted
    case T.ListOf{T.ByteVector{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.ByteVector{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.ByteList{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.BitVector{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.BitList{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{c0, c1}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Vector{c0, c1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{c0, c1}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.ListOf{c0, c1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{c0, c1}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Container{c0, c1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Union{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{c0, c1}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Chain{c0, c1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Repeat{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{c0, c1}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.Named{c0, c1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{c0}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{c0}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{c0, c1, c2}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{c0, c1, c2}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{c0, c1}, a1} T.ByteList{b0}:
          Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{c0, c1}, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Boolean{}), accepted), identical_sound(T.Boolean{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Boolean{}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Unsigned{e0}), accepted), identical_sound(T.Boolean{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteVector{e0}), accepted), identical_sound(T.Boolean{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteList{e0}), accepted), identical_sound(T.Boolean{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitVector{e0}), accepted), identical_sound(T.Boolean{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitList{e0}), accepted), identical_sound(T.Boolean{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Vector{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ListOf{e0, e1}), accepted), identical_sound(T.Boolean{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Container{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Union{e0}), accepted), identical_sound(T.Boolean{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Union{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Null{}), accepted), identical_sound(T.Boolean{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Null{}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Chain{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.End{}), accepted), identical_sound(T.Boolean{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.End{}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Repeat{e0}), accepted), identical_sound(T.Boolean{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Named{e0, e1}), accepted), identical_sound(T.Boolean{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveList{e0}), accepted), identical_sound(T.Boolean{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveBits{}), accepted), identical_sound(T.Boolean{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Boolean{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Boolean{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Boolean{}), accepted), identical_sound(T.Unsigned{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Unsigned{e0}), accepted), identical_sound(T.Unsigned{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteVector{e0}), accepted), identical_sound(T.Unsigned{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteList{e0}), accepted), identical_sound(T.Unsigned{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitVector{e0}), accepted), identical_sound(T.Unsigned{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitList{e0}), accepted), identical_sound(T.Unsigned{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Container{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Union{e0}), accepted), identical_sound(T.Unsigned{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Null{}), accepted), identical_sound(T.Unsigned{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Null{}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.End{}), accepted), identical_sound(T.Unsigned{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.End{}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Repeat{e0}), accepted), identical_sound(T.Unsigned{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Named{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.Unsigned{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.Unsigned{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Unsigned{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Unsigned{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Boolean{}), accepted), identical_sound(T.ByteVector{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Unsigned{e0}), accepted), identical_sound(T.ByteVector{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteVector{e0}), accepted), identical_sound(T.ByteVector{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteList{e0}), accepted), identical_sound(T.ByteVector{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitVector{e0}), accepted), identical_sound(T.ByteVector{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitList{e0}), accepted), identical_sound(T.ByteVector{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Container{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Union{e0}), accepted), identical_sound(T.ByteVector{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Null{}), accepted), identical_sound(T.ByteVector{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Null{}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.End{}), accepted), identical_sound(T.ByteVector{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.End{}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Repeat{e0}), accepted), identical_sound(T.ByteVector{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Named{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.ByteVector{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.ByteVector{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.ByteVector{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteVector{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Boolean{}), accepted), identical_sound(T.ByteList{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Unsigned{e0}), accepted), identical_sound(T.ByteList{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteVector{e0}), accepted), identical_sound(T.ByteList{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteList{e0}), accepted), identical_sound(T.ByteList{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitVector{e0}), accepted), identical_sound(T.ByteList{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitList{e0}), accepted), identical_sound(T.ByteList{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Container{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Union{e0}), accepted), identical_sound(T.ByteList{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Null{}), accepted), identical_sound(T.ByteList{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Null{}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.End{}), accepted), identical_sound(T.ByteList{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.End{}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Repeat{e0}), accepted), identical_sound(T.ByteList{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Named{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.ByteList{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.ByteList{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.ByteList{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ByteList{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ByteList{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ByteList{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Boolean{}), accepted), identical_sound(T.BitVector{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Unsigned{e0}), accepted), identical_sound(T.BitVector{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteVector{e0}), accepted), identical_sound(T.BitVector{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteList{e0}), accepted), identical_sound(T.BitVector{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitVector{e0}), accepted), identical_sound(T.BitVector{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitList{e0}), accepted), identical_sound(T.BitVector{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Container{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Union{e0}), accepted), identical_sound(T.BitVector{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Null{}), accepted), identical_sound(T.BitVector{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Null{}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.End{}), accepted), identical_sound(T.BitVector{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.End{}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Repeat{e0}), accepted), identical_sound(T.BitVector{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Named{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.BitVector{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.BitVector{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.BitVector{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitVector{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.BitVector{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitVector{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Boolean{}), accepted), identical_sound(T.BitList{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Unsigned{e0}), accepted), identical_sound(T.BitList{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteVector{e0}), accepted), identical_sound(T.BitList{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteList{e0}), accepted), identical_sound(T.BitList{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitVector{e0}), accepted), identical_sound(T.BitList{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitList{e0}), accepted), identical_sound(T.BitList{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Container{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Union{e0}), accepted), identical_sound(T.BitList{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Null{}), accepted), identical_sound(T.BitList{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Null{}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.End{}), accepted), identical_sound(T.BitList{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.End{}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Repeat{e0}), accepted), identical_sound(T.BitList{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Named{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.BitList{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.BitList{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.BitList{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.BitList{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.BitList{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.BitList{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Vector{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Boolean{}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Union{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Null{}), accepted), identical_sound(T.Vector{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Null{}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.End{}), accepted), identical_sound(T.Vector{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.End{}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Vector{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Vector{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Vector{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Boolean{}), accepted), identical_sound(T.ListOf{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Boolean{}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.BitList{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Union{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Union{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Null{}), accepted), identical_sound(T.ListOf{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Null{}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.End{}), accepted), identical_sound(T.ListOf{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.End{}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.ListOf{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.ListOf{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ListOf{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Container{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Boolean{}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Container{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Container{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Container{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Container{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Container{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Container{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Union{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Null{}), accepted), identical_sound(T.Container{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Null{}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.End{}), accepted), identical_sound(T.Container{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.End{}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Container{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Container{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Container{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Container{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Container{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Boolean{}), accepted), identical_sound(T.Union{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Unsigned{e0}), accepted), identical_sound(T.Union{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteVector{e0}), accepted), identical_sound(T.Union{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteList{e0}), accepted), identical_sound(T.Union{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitVector{e0}), accepted), identical_sound(T.Union{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitList{e0}), accepted), identical_sound(T.Union{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.Union{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Container{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Union{e0}), accepted), identical_sound(T.Union{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Null{}), accepted), identical_sound(T.Union{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Null{}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.End{}), accepted), identical_sound(T.Union{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.End{}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Repeat{e0}), accepted), identical_sound(T.Union{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Named{e0, e1}), accepted), identical_sound(T.Union{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.Union{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.Union{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Union{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Union{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Union{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Union{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Boolean{}), accepted), identical_sound(T.Null{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Boolean{}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Unsigned{e0}), accepted), identical_sound(T.Null{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteVector{e0}), accepted), identical_sound(T.Null{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteList{e0}), accepted), identical_sound(T.Null{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitVector{e0}), accepted), identical_sound(T.Null{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitList{e0}), accepted), identical_sound(T.Null{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Vector{e0, e1}), accepted), identical_sound(T.Null{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ListOf{e0, e1}), accepted), identical_sound(T.Null{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Container{e0, e1}), accepted), identical_sound(T.Null{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Union{e0}), accepted), identical_sound(T.Null{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Union{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Null{}), accepted), identical_sound(T.Null{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Null{}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Chain{e0, e1}), accepted), identical_sound(T.Null{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.End{}), accepted), identical_sound(T.Null{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.End{}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Repeat{e0}), accepted), identical_sound(T.Null{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Named{e0, e1}), accepted), identical_sound(T.Null{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveList{e0}), accepted), identical_sound(T.Null{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveBits{}), accepted), identical_sound(T.Null{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Null{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Null{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Null{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Null{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Chain{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Boolean{}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Union{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Null{}), accepted), identical_sound(T.Chain{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Null{}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.End{}), accepted), identical_sound(T.Chain{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.End{}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Chain{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Chain{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Chain{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Boolean{}), accepted), identical_sound(T.End{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Boolean{}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Unsigned{e0}), accepted), identical_sound(T.End{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteVector{e0}), accepted), identical_sound(T.End{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteList{e0}), accepted), identical_sound(T.End{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitVector{e0}), accepted), identical_sound(T.End{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitList{e0}), accepted), identical_sound(T.End{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitList{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Vector{e0, e1}), accepted), identical_sound(T.End{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ListOf{e0, e1}), accepted), identical_sound(T.End{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Container{e0, e1}), accepted), identical_sound(T.End{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Union{e0}), accepted), identical_sound(T.End{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Union{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Null{}), accepted), identical_sound(T.End{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Null{}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Chain{e0, e1}), accepted), identical_sound(T.End{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.End{}), accepted), identical_sound(T.End{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.End{}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Repeat{e0}), accepted), identical_sound(T.End{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Named{e0, e1}), accepted), identical_sound(T.End{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveList{e0}), accepted), identical_sound(T.End{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveBits{}), accepted), identical_sound(T.End{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.End{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.End{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.End{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.End{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.End{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.End{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Boolean{}), accepted), identical_sound(T.Repeat{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Unsigned{e0}), accepted), identical_sound(T.Repeat{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteVector{e0}), accepted), identical_sound(T.Repeat{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteList{e0}), accepted), identical_sound(T.Repeat{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitVector{e0}), accepted), identical_sound(T.Repeat{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitList{e0}), accepted), identical_sound(T.Repeat{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Container{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Union{e0}), accepted), identical_sound(T.Repeat{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Null{}), accepted), identical_sound(T.Repeat{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Null{}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.End{}), accepted), identical_sound(T.Repeat{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.End{}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Repeat{e0}), accepted), identical_sound(T.Repeat{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Named{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.Repeat{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.Repeat{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Repeat{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Repeat{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Repeat{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Repeat{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Boolean{}), accepted), identical_sound(T.Named{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Boolean{}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.Named{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.Named{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.Named{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.Named{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.Named{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.BitList{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Union{e0}), accepted), identical_sound(T.Named{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Union{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Null{}), accepted), identical_sound(T.Named{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Null{}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.End{}), accepted), identical_sound(T.Named{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.End{}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.Named{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.Named{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.Named{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.Named{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.Named{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Boolean{}), accepted), identical_sound(T.ProgressiveList{d0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Boolean{}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Unsigned{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteVector{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteList{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitVector{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitList{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.BitList{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Vector{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ListOf{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Container{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Union{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Union{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Null{}), accepted), identical_sound(T.ProgressiveList{d0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Null{}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Chain{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.End{}), accepted), identical_sound(T.ProgressiveList{d0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.End{}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Repeat{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Named{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveList{e0}), accepted), identical_sound(T.ProgressiveList{d0}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveBits{}), accepted), identical_sound(T.ProgressiveList{d0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{d0}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Boolean{}), accepted), identical_sound(T.ProgressiveBits{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Boolean{}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Unsigned{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteVector{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteList{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitVector{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitList{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitList{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Vector{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ListOf{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Container{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Union{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Union{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Null{}), accepted), identical_sound(T.ProgressiveBits{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Null{}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Chain{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.End{}), accepted), identical_sound(T.ProgressiveBits{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.End{}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Repeat{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Named{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveList{e0}), accepted), identical_sound(T.ProgressiveBits{}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), accepted), identical_sound(T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Boolean{}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.BitList{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Union{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Null{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Null{}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.End{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.End{}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{d0, d1, d2}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Boolean{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Boolean{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Boolean{}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Unsigned{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Unsigned{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ByteVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteVector{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ByteList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ByteList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteList{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ByteList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ByteList{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.BitVector{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.BitVector{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitVector{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.BitVector{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitVector{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.BitList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.BitList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitList{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.BitList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.BitList{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Vector{e0, e1}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ListOf{e0, e1}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Container{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Container{e0, e1}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Union{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Union{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Union{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Union{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Union{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Null{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Null{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Null{}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Chain{e0, e1}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.End{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.End{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.End{}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Repeat{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Repeat{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Repeat{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Repeat{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Repeat{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.Named{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.Named{e0, e1}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveList{e0}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveBits{}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.ProgressiveContainer{e0, e1, e2}), accepted)))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      V.and_true(Nat.is_eq(a1, b1), S.identical(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}), V.and_left(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}), accepted), identical_sound(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}, V.and_right(Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{d0, d1}, T.CompatibleUnion{e0, e1}), accepted)))
    case T.ListOf{T.Boolean{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Null{}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.End{}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Boolean{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Unsigned{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Unsigned{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteVector{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteVector{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ByteList{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ByteList{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitVector{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitVector{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.BitList{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.BitList{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Vector{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Vector{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ListOf{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ListOf{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Container{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Container{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Union{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Union{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Null{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Null{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Chain{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Chain{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.End{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.End{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Repeat{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Repeat{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.Named{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.Named{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveList{d0}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveList{d0}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveBits{}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.ProgressiveContainer{d0, d1, d2}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ListOf{T.CompatibleUnion{d0, d1}, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ListOf{T.CompatibleUnion{d0, d1}, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Container{b0, b1}:
      %M.names_equal(a0, b0) : {Bool.and(_, S.identical(a1, b1)) == True{} : Bool}
      V.and_true(I.names_equal(a0, b0), S.identical(a1, b1), V.and_left(I.names_equal(a0, b0), I.identical(a1, b1), accepted), identical_sound(a1, b1, V.and_right(I.names_equal(a0, b0), I.identical(a1, b1), accepted)))
    case T.Container{a0, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Null{}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.End{}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Container{a0, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Container{a0, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.Union{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Union{b0}:
      identical_sound(a0, b0, accepted)
    case T.Union{a0} T.Null{}:
      Empty.absurd({S.identical(T.Union{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.End{}:
      Empty.absurd({S.identical(T.Union{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Union{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Union{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Union{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Union{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Union{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Boolean{}:
      Empty.absurd({S.identical(T.Null{}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Null{}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Null{}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Null{}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Null{}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.BitList{b0}:
      Empty.absurd({S.identical(T.Null{}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Null{}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Union{b0}:
      Empty.absurd({S.identical(T.Null{}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Null{}:
      accepted
    case T.Null{} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.End{}:
      Empty.absurd({S.identical(T.Null{}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Null{}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Null{}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Null{}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Null{}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Null{}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Null{} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Null{}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Null{}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Chain{b0, b1}:
      V.and_true(S.identical(a0, b0), S.identical(a1, b1), identical_sound(a0, b0, V.and_left(I.identical(a0, b0), I.identical(a1, b1), accepted)), identical_sound(a1, b1, V.and_right(I.identical(a0, b0), I.identical(a1, b1), accepted)))
    case T.Chain{a0, a1} T.End{}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Chain{a0, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Chain{a0, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Boolean{}:
      Empty.absurd({S.identical(T.End{}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.End{}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.End{}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ByteList{b0}:
      Empty.absurd({S.identical(T.End{}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.BitVector{b0}:
      Empty.absurd({S.identical(T.End{}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.BitList{b0}:
      Empty.absurd({S.identical(T.End{}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.End{}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.End{}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Union{b0}:
      Empty.absurd({S.identical(T.End{}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Null{}:
      Empty.absurd({S.identical(T.End{}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.End{}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.End{}:
      accepted
    case T.End{} T.Repeat{b0}:
      Empty.absurd({S.identical(T.End{}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.End{}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.End{}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.End{}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.End{}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.End{} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.End{}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Null{}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.End{}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Repeat{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Repeat{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Null{}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.End{}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.Named{b0, b1}:
      V.and_true(String.eq(a0, b0), S.identical(a1, b1), V.and_left(String.eq(a0, b0), I.identical(a1, b1), accepted), identical_sound(a1, b1, V.and_right(String.eq(a0, b0), I.identical(a1, b1), accepted)))
    case T.Named{a0, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.Named{a0, a1} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.Named{a0, a1}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Boolean{}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ByteList{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.BitList{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Union{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Null{}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.End{}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ProgressiveList{b0}:
      identical_sound(a0, b0, accepted)
    case T.ProgressiveList{a0} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveList{a0}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Boolean{}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ByteList{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.BitList{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Union{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Null{}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.End{}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.ProgressiveBits{}:
      accepted
    case T.ProgressiveBits{} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveBits{} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveBits{}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Boolean{}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ByteList{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.BitVector{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.BitList{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Null{}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.End{}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}:
      %M.names_equal(a0, b0) : {Bool.and(_, Bool.and(S.bits_equal(a2, b2), S.identical(a1, b1))) == True{} : Bool}
      %M.bits_equal(a2, b2) : {Bool.and(I.names_equal(a0, b0), Bool.and(_, S.identical(a1, b1))) == True{} : Bool}
      V.and_true(I.names_equal(a0, b0), Bool.and(I.bools_equal(a2, b2), S.identical(a1, b1)), V.and_left(I.names_equal(a0, b0), Bool.and(I.bools_equal(a2, b2), I.identical(a1, b1)), accepted), V.and_true(I.bools_equal(a2, b2), S.identical(a1, b1), V.and_left(I.bools_equal(a2, b2), I.identical(a1, b1), V.and_right(I.names_equal(a0, b0), Bool.and(I.bools_equal(a2, b2), I.identical(a1, b1)), accepted)), identical_sound(a1, b1, V.and_right(I.bools_equal(a2, b2), I.identical(a1, b1), V.and_right(I.names_equal(a0, b0), Bool.and(I.bools_equal(a2, b2), I.identical(a1, b1)), accepted)))))
    case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}:
      Empty.absurd({S.identical(T.ProgressiveContainer{a0, a1, a2}, T.CompatibleUnion{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Boolean{}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Boolean{}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Unsigned{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Unsigned{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ByteVector{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ByteVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ByteList{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ByteList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.BitVector{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.BitVector{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.BitList{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.BitList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Null{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.End{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Vector{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Vector{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Boolean{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Boolean{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Unsigned{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Unsigned{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteVector{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.ByteVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteList{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.ByteList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.BitVector{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.BitVector{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.BitList{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.BitList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Vector{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Vector{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ListOf{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.ListOf{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Container{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Container{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Union{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Union{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Null{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Null{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Chain{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Chain{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.End{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.End{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Repeat{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Repeat{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.Named{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.Named{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveList{e0}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.ProgressiveList{e0}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.ProgressiveBits{}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.ProgressiveContainer{e0, e1, e2}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ListOf{T.CompatibleUnion{e0, e1}, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ListOf{T.CompatibleUnion{e0, e1}, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Container{b0, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Container{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Union{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Union{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Null{}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Null{}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Chain{b0, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Chain{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.End{}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.End{}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Repeat{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Repeat{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.Named{b0, b1}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.Named{b0, b1}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ProgressiveList{b0}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ProgressiveList{b0}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ProgressiveBits{}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ProgressiveBits{}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.ProgressiveContainer{b0, b1, b2}:
      Empty.absurd({S.identical(T.CompatibleUnion{a0, a1}, T.ProgressiveContainer{b0, b1, b2}) == True{} : Bool}, W.false_true(accepted))
    case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}:
      %M.selectors_equal(a0, b0) : {Bool.and(_, S.identical(a1, b1)) == True{} : Bool}
      V.and_true(I.selectors_equal(a0, b0), S.identical(a1, b1), V.and_left(I.selectors_equal(a0, b0), I.identical(a1, b1), accepted), identical_sound(a1, b1, V.and_right(I.selectors_equal(a0, b0), I.identical(a1, b1), accepted)))
